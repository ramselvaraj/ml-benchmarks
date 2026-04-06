// Tiny CNN for MNIST CSVs using raw CUDA kernels.
// Architecture: Conv(1->8,3x3) -> ReLU -> MaxPool -> Conv(8->16,3x3) -> ReLU -> MaxPool -> FC(400->10).
// Includes training, evaluation, per-stage GPU timing, batch-latency stats, and single-image latency benchmarking.

#include <cuda_runtime.h>

#include <algorithm>
#include <cctype>
#include <cstdlib>
#include <chrono>
#include <cmath>
#include <cfloat>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <random>
#include <sstream>
#include <string>
#include <vector>

#define CHECK_CUDA(call)                                                        \
    do {                                                                        \
        cudaError_t err__ = (call);                                             \
        if (err__ != cudaSuccess) {                                             \
            std::cerr << "CUDA error at " << __FILE__ << ":" << __LINE__      \
                      << " -> " << cudaGetErrorString(err__) << std::endl;     \
            std::exit(EXIT_FAILURE);                                            \
        }                                                                       \
    } while (0)

constexpr int IMG_H = 28;
constexpr int IMG_W = 28;
constexpr int IMG_C = 1;
constexpr int NUM_CLASSES = 10;

constexpr int C1_OUT = 8;
constexpr int C1_K = 3;
constexpr int C1_H = IMG_H - C1_K + 1; // 26
constexpr int C1_W = IMG_W - C1_K + 1; // 26
constexpr int P1_H = C1_H / 2;         // 13
constexpr int P1_W = C1_W / 2;         // 13

constexpr int C2_OUT = 16;
constexpr int C2_K = 3;
constexpr int C2_H = P1_H - C2_K + 1;  // 11
constexpr int C2_W = P1_W - C2_K + 1;  // 11
constexpr int P2_H = C2_H / 2;         // 5
constexpr int P2_W = C2_W / 2;         // 5
constexpr int FC_IN = C2_OUT * P2_H * P2_W; // 400
constexpr int FC_OUT = NUM_CLASSES;

struct Dataset {
    std::vector<float> images; // N x 784, normalized to [0,1]
    std::vector<int> labels;   // N
    int size = 0;
};

struct PhaseTiming {
    double h2d_ms = 0.0;
    double forward_ms = 0.0;
    double loss_ms = 0.0;
    double backward_ms = 0.0;
    double update_ms = 0.0;
    double total_wall_ms = 0.0;
};

struct EvalMetrics {
    double loss = 0.0;
    double accuracy = 0.0;
    double total_infer_ms = 0.0;
    double avg_batch_ms = 0.0;
    double avg_sample_ms = 0.0;
    double throughput_samples_per_sec = 0.0;
    double p50_batch_ms = 0.0;
    double p95_batch_ms = 0.0;
};

struct LatencyMetrics {
    double mean_ms = 0.0;
    double min_ms = 0.0;
    double max_ms = 0.0;
    double p50_ms = 0.0;
    double p95_ms = 0.0;
};

struct CnnParams {
    float* d_w1 = nullptr;
    float* d_b1 = nullptr;
    float* d_w2 = nullptr;
    float* d_b2 = nullptr;
    float* d_w3 = nullptr;
    float* d_b3 = nullptr;

    float* d_gw1 = nullptr;
    float* d_gb1 = nullptr;
    float* d_gw2 = nullptr;
    float* d_gb2 = nullptr;
    float* d_gw3 = nullptr;
    float* d_gb3 = nullptr;
};

struct BatchBuffers {
    int max_batch = 0;

    float* d_x = nullptr;       // [B,1,28,28]
    int* d_y = nullptr;       // [B]

    float* d_c1 = nullptr;      // [B,8,26,26]
    float* d_p1 = nullptr;      // [B,8,13,13]
    int* d_p1_idx = nullptr;  // [B,8,13,13]

    float* d_c2 = nullptr;      // [B,16,11,11]
    float* d_p2 = nullptr;      // [B,400]
    int* d_p2_idx = nullptr;  // [B,16,5,5]

    float* d_logits = nullptr;  // [B,10]
    float* d_dlogits = nullptr; // [B,10]
    float* d_losses = nullptr;  // [B]
    int* d_preds = nullptr;   // [B]

    float* d_dp2 = nullptr;     // [B,400]
    float* d_dc2 = nullptr;     // [B,16,11,11]
    float* d_dp1 = nullptr;     // [B,8,13,13]
    float* d_dc1 = nullptr;     // [B,8,26,26]
};

struct EvalMetrics;
EvalMetrics evaluate(const Dataset& ds, CnnParams& params, BatchBuffers& buffers, int batch_size);

inline size_t bytes_of(size_t n) {
    return n * sizeof(float);
}

Dataset load_mnist_csv(const std::string& path) {
    std::ifstream fin(path);
    if (!fin) {
        std::cerr << "Failed to open: " << path << std::endl;
        std::exit(EXIT_FAILURE);
    }

    Dataset ds;
    std::string line;
    ds.images.reserve(60000 * IMG_H * IMG_W);
    ds.labels.reserve(60000);

    auto looks_numeric = [](const std::string& s) {
        if (s.empty()) return false;
        size_t i = (s[0] == '-' || s[0] == '+') ? 1 : 0;
        bool has_digit = false;
        for (; i < s.size(); ++i) {
            if (std::isdigit(static_cast<unsigned char>(s[i]))) {
                has_digit = true;
                continue;
            }
            if (s[i] == '.') continue;
            return false;
        }
        return has_digit;
        };

    while (std::getline(fin, line)) {
        if (line.empty()) continue;
        std::stringstream ss(line);
        std::string token;

        if (!std::getline(ss, token, ',')) continue;
        if (!looks_numeric(token)) continue; // skip optional header

        ds.labels.push_back(std::stoi(token));

        for (int i = 0; i < IMG_H * IMG_W; ++i) {
            if (!std::getline(ss, token, ',')) {
                std::cerr << "Malformed CSV row in " << path << std::endl;
                std::exit(EXIT_FAILURE);
            }
            ds.images.push_back(std::stof(token) / 255.0f);
        }
    }

    ds.size = static_cast<int>(ds.labels.size());
    std::cout << "Loaded " << ds.size << " samples from " << path << std::endl;
    return ds;
}

float percentile(std::vector<float> v, double q) {
    if (v.empty()) return 0.0f;
    std::sort(v.begin(), v.end());
    double pos = q * static_cast<double>(v.size() - 1);
    size_t lo = static_cast<size_t>(std::floor(pos));
    size_t hi = static_cast<size_t>(std::ceil(pos));
    double w = pos - static_cast<double>(lo);
    return static_cast<float>((1.0 - w) * v[lo] + w * v[hi]);
}

void he_init(std::vector<float>& w, int fan_in, std::mt19937& rng) {
    float stddev = std::sqrt(2.0f / static_cast<float>(fan_in));
    std::normal_distribution<float> dist(0.0f, stddev);
    for (auto& x : w) x = dist(rng);
}

void init_params(CnnParams& p) {
    std::mt19937 rng(42);

    std::vector<float> h_w1(C1_OUT * IMG_C * C1_K * C1_K);
    std::vector<float> h_b1(C1_OUT, 0.0f);
    std::vector<float> h_w2(C2_OUT * C1_OUT * C2_K * C2_K);
    std::vector<float> h_b2(C2_OUT, 0.0f);
    std::vector<float> h_w3(FC_OUT * FC_IN);
    std::vector<float> h_b3(FC_OUT, 0.0f);

    he_init(h_w1, IMG_C * C1_K * C1_K, rng);
    he_init(h_w2, C1_OUT * C2_K * C2_K, rng);
    he_init(h_w3, FC_IN, rng);

    CHECK_CUDA(cudaMalloc((void**)&p.d_w1, bytes_of(h_w1.size())));
    CHECK_CUDA(cudaMalloc((void**)&p.d_b1, bytes_of(h_b1.size())));
    CHECK_CUDA(cudaMalloc((void**)&p.d_w2, bytes_of(h_w2.size())));
    CHECK_CUDA(cudaMalloc((void**)&p.d_b2, bytes_of(h_b2.size())));
    CHECK_CUDA(cudaMalloc((void**)&p.d_w3, bytes_of(h_w3.size())));
    CHECK_CUDA(cudaMalloc((void**)&p.d_b3, bytes_of(h_b3.size())));

    CHECK_CUDA(cudaMalloc((void**)&p.d_gw1, bytes_of(h_w1.size())));
    CHECK_CUDA(cudaMalloc((void**)&p.d_gb1, bytes_of(h_b1.size())));
    CHECK_CUDA(cudaMalloc((void**)&p.d_gw2, bytes_of(h_w2.size())));
    CHECK_CUDA(cudaMalloc((void**)&p.d_gb2, bytes_of(h_b2.size())));
    CHECK_CUDA(cudaMalloc((void**)&p.d_gw3, bytes_of(h_w3.size())));
    CHECK_CUDA(cudaMalloc((void**)&p.d_gb3, bytes_of(h_b3.size())));

    CHECK_CUDA(cudaMemcpy(p.d_w1, h_w1.data(), bytes_of(h_w1.size()), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(p.d_b1, h_b1.data(), bytes_of(h_b1.size()), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(p.d_w2, h_w2.data(), bytes_of(h_w2.size()), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(p.d_b2, h_b2.data(), bytes_of(h_b2.size()), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(p.d_w3, h_w3.data(), bytes_of(h_w3.size()), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(p.d_b3, h_b3.data(), bytes_of(h_b3.size()), cudaMemcpyHostToDevice));
}

void free_params(CnnParams& p) {
    cudaFree(p.d_w1); cudaFree(p.d_b1); cudaFree(p.d_w2); cudaFree(p.d_b2); cudaFree(p.d_w3); cudaFree(p.d_b3);
    cudaFree(p.d_gw1); cudaFree(p.d_gb1); cudaFree(p.d_gw2); cudaFree(p.d_gb2); cudaFree(p.d_gw3); cudaFree(p.d_gb3);
}

void alloc_batch_buffers(BatchBuffers& b, int max_batch) {
    b.max_batch = max_batch;
    CHECK_CUDA(cudaMalloc((void**)&b.d_x, bytes_of(static_cast<size_t>(max_batch) * IMG_H * IMG_W)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_y, sizeof(int) * max_batch));

    CHECK_CUDA(cudaMalloc((void**)&b.d_c1, bytes_of(static_cast<size_t>(max_batch) * C1_OUT * C1_H * C1_W)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_p1, bytes_of(static_cast<size_t>(max_batch) * C1_OUT * P1_H * P1_W)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_p1_idx, sizeof(int) * static_cast<size_t>(max_batch) * C1_OUT * P1_H * P1_W));

    CHECK_CUDA(cudaMalloc((void**)&b.d_c2, bytes_of(static_cast<size_t>(max_batch) * C2_OUT * C2_H * C2_W)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_p2, bytes_of(static_cast<size_t>(max_batch) * FC_IN)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_p2_idx, sizeof(int) * static_cast<size_t>(max_batch) * C2_OUT * P2_H * P2_W));

    CHECK_CUDA(cudaMalloc((void**)&b.d_logits, bytes_of(static_cast<size_t>(max_batch) * FC_OUT)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_dlogits, bytes_of(static_cast<size_t>(max_batch) * FC_OUT)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_losses, bytes_of(max_batch)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_preds, sizeof(int) * max_batch));

    CHECK_CUDA(cudaMalloc((void**)&b.d_dp2, bytes_of(static_cast<size_t>(max_batch) * FC_IN)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_dc2, bytes_of(static_cast<size_t>(max_batch) * C2_OUT * C2_H * C2_W)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_dp1, bytes_of(static_cast<size_t>(max_batch) * C1_OUT * P1_H * P1_W)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_dc1, bytes_of(static_cast<size_t>(max_batch) * C1_OUT * C1_H * C1_W)));
}

void free_batch_buffers(BatchBuffers& b) {
    cudaFree(b.d_x); cudaFree(b.d_y);
    cudaFree(b.d_c1); cudaFree(b.d_p1); cudaFree(b.d_p1_idx);
    cudaFree(b.d_c2); cudaFree(b.d_p2); cudaFree(b.d_p2_idx);
    cudaFree(b.d_logits); cudaFree(b.d_dlogits); cudaFree(b.d_losses); cudaFree(b.d_preds);
    cudaFree(b.d_dp2); cudaFree(b.d_dc2); cudaFree(b.d_dp1); cudaFree(b.d_dc1);
}

__global__ void conv2d_forward_kernel(
    const float* x, const float* w, const float* bias, float* y,
    int B, int Cin, int H, int W, int Cout, int K
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int OH = H - K + 1;
    int OW = W - K + 1;
    int total = B * Cout * OH * OW;
    if (idx >= total) return;

    int ow = idx % OW;
    int oh = (idx / OW) % OH;
    int oc = (idx / (OW * OH)) % Cout;
    int b = idx / (OW * OH * Cout);

    float sum = bias[oc];
    for (int ic = 0; ic < Cin; ++ic) {
        for (int kh = 0; kh < K; ++kh) {
            for (int kw = 0; kw < K; ++kw) {
                int in_h = oh + kh;
                int in_w = ow + kw;
                int x_idx = ((b * Cin + ic) * H + in_h) * W + in_w;
                int w_idx = ((oc * Cin + ic) * K + kh) * K + kw;
                sum += x[x_idx] * w[w_idx];
            }
        }
    }
    y[idx] = sum;
}

__global__ void relu_inplace_kernel(float* x, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) x[i] = fmaxf(0.0f, x[i]);
}

__global__ void relu_backward_inplace_kernel(float* grad, const float* activated, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) grad[i] = activated[i] > 0.0f ? grad[i] : 0.0f;
}

__global__ void maxpool2x2_forward_kernel(
    const float* x, float* y, int* idx_out,
    int B, int C, int H, int W
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int OH = H / 2;
    int OW = W / 2;
    int total = B * C * OH * OW;
    if (idx >= total) return;

    int ow = idx % OW;
    int oh = (idx / OW) % OH;
    int c = (idx / (OW * OH)) % C;
    int b = idx / (OW * OH * C);

    int in_h0 = oh * 2;
    int in_w0 = ow * 2;

    float best = -FLT_MAX;
    int best_idx = 0;

    for (int dh = 0; dh < 2; ++dh) {
        for (int dw = 0; dw < 2; ++dw) {
            int ih = in_h0 + dh;
            int iw = in_w0 + dw;
            int x_idx = ((b * C + c) * H + ih) * W + iw;
            float v = x[x_idx];
            if (v > best) {
                best = v;
                best_idx = x_idx;
            }
        }
    }

    y[idx] = best;
    idx_out[idx] = best_idx;
}

__global__ void maxpool2x2_backward_kernel(
    const float* d_out, const int* idx_out, float* d_in, int total
) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < total) {
        d_in[idx_out[i]] = d_out[i];
    }
}

__global__ void fc_forward_kernel(
    const float* x, const float* w, const float* bias, float* y,
    int B, int in_dim, int out_dim
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int total = B * out_dim;
    if (idx >= total) return;

    int o = idx % out_dim;
    int b = idx / out_dim;

    float sum = bias[o];
    const float* xb = x + b * in_dim;
    const float* wo = w + o * in_dim;
    for (int i = 0; i < in_dim; ++i) sum += xb[i] * wo[i];
    y[idx] = sum;
}

__global__ void softmax_ce_backward_kernel(
    const float* logits, const int* labels,
    float* d_logits, float* losses, int* preds,
    int B, int classes
) {
    int b = blockIdx.x * blockDim.x + threadIdx.x;
    if (b >= B) return;

    const float* z = logits + b * classes;
    float* dz = d_logits + b * classes;

    float max_logit = z[0];
    for (int j = 1; j < classes; ++j) max_logit = fmaxf(max_logit, z[j]);

    float sum_exp = 0.0f;
    int pred = 0;
    float best = z[0];
    for (int j = 0; j < classes; ++j) {
        float e = expf(z[j] - max_logit);
        dz[j] = e;
        sum_exp += e;
        if (z[j] > best) {
            best = z[j];
            pred = j;
        }
    }

    int y = labels[b];
    float prob_y = 0.0f;
    for (int j = 0; j < classes; ++j) {
        float p = dz[j] / sum_exp;
        dz[j] = p - (j == y ? 1.0f : 0.0f);
        if (j == y) prob_y = p;
    }

    losses[b] = -logf(fmaxf(prob_y, 1e-8f));
    preds[b] = pred;
}

__global__ void fc_backward_input_kernel(
    const float* d_out, const float* w, float* d_in,
    int B, int in_dim, int out_dim
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int total = B * in_dim;
    if (idx >= total) return;

    int i = idx % in_dim;
    int b = idx / in_dim;

    float sum = 0.0f;
    for (int o = 0; o < out_dim; ++o) {
        sum += d_out[b * out_dim + o] * w[o * in_dim + i];
    }
    d_in[idx] = sum;
}

__global__ void fc_backward_weight_kernel(
    const float* x, const float* d_out, float* d_w,
    int B, int in_dim, int out_dim
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int total = out_dim * in_dim;
    if (idx >= total) return;

    int i = idx % in_dim;
    int o = idx / in_dim;

    float sum = 0.0f;
    for (int b = 0; b < B; ++b) {
        sum += d_out[b * out_dim + o] * x[b * in_dim + i];
    }
    d_w[idx] = sum;
}

__global__ void fc_backward_bias_kernel(
    const float* d_out, float* d_b, int B, int out_dim
) {
    int o = blockIdx.x * blockDim.x + threadIdx.x;
    if (o >= out_dim) return;

    float sum = 0.0f;
    for (int b = 0; b < B; ++b) sum += d_out[b * out_dim + o];
    d_b[o] = sum;
}

__global__ void conv2d_backward_input_kernel(
    const float* d_out, const float* w, float* d_in,
    int B, int Cin, int H, int W, int Cout, int K
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int total = B * Cin * H * W;
    if (idx >= total) return;

    int iw = idx % W;
    int ih = (idx / W) % H;
    int ic = (idx / (W * H)) % Cin;
    int b = idx / (W * H * Cin);

    int OH = H - K + 1;
    int OW = W - K + 1;
    float sum = 0.0f;

    for (int oc = 0; oc < Cout; ++oc) {
        for (int kh = 0; kh < K; ++kh) {
            int oh = ih - kh;
            if (oh < 0 || oh >= OH) continue;
            for (int kw = 0; kw < K; ++kw) {
                int ow = iw - kw;
                if (ow < 0 || ow >= OW) continue;
                int dout_idx = ((b * Cout + oc) * OH + oh) * OW + ow;
                int w_idx = ((oc * Cin + ic) * K + kh) * K + kw;
                sum += d_out[dout_idx] * w[w_idx];
            }
        }
    }
    d_in[idx] = sum;
}

__global__ void conv2d_backward_weight_kernel(
    const float* x, const float* d_out, float* d_w,
    int B, int Cin, int H, int W, int Cout, int K
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int total = Cout * Cin * K * K;
    if (idx >= total) return;

    int kw = idx % K;
    int kh = (idx / K) % K;
    int ic = (idx / (K * K)) % Cin;
    int oc = idx / (K * K * Cin);

    int OH = H - K + 1;
    int OW = W - K + 1;
    float sum = 0.0f;

    for (int b = 0; b < B; ++b) {
        for (int oh = 0; oh < OH; ++oh) {
            for (int ow = 0; ow < OW; ++ow) {
                int x_idx = ((b * Cin + ic) * H + (oh + kh)) * W + (ow + kw);
                int dout_idx = ((b * Cout + oc) * OH + oh) * OW + ow;
                sum += d_out[dout_idx] * x[x_idx];
            }
        }
    }
    d_w[idx] = sum;
}

__global__ void conv2d_backward_bias_kernel(
    const float* d_out, float* d_b,
    int B, int Cout, int OH, int OW
) {
    int oc = blockIdx.x * blockDim.x + threadIdx.x;
    if (oc >= Cout) return;

    float sum = 0.0f;
    for (int b = 0; b < B; ++b) {
        for (int oh = 0; oh < OH; ++oh) {
            for (int ow = 0; ow < OW; ++ow) {
                int idx = ((b * Cout + oc) * OH + oh) * OW + ow;
                sum += d_out[idx];
            }
        }
    }
    d_b[oc] = sum;
}

__global__ void sgd_update_kernel(float* p, const float* g, float lr_scale, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) p[i] -= lr_scale * g[i];
}

inline int ceil_div(int a, int b) {
    return (a + b - 1) / b;
}

void forward_pass(const CnnParams& p, BatchBuffers& b, int B) {
    const int threads = 256;

    int c1_total = B * C1_OUT * C1_H * C1_W;
    conv2d_forward_kernel << <ceil_div(c1_total, threads), threads >> > (
        b.d_x, p.d_w1, p.d_b1, b.d_c1, B, IMG_C, IMG_H, IMG_W, C1_OUT, C1_K
        );
    relu_inplace_kernel << <ceil_div(c1_total, threads), threads >> > (b.d_c1, c1_total);

    int p1_total = B * C1_OUT * P1_H * P1_W;
    maxpool2x2_forward_kernel << <ceil_div(p1_total, threads), threads >> > (
        b.d_c1, b.d_p1, b.d_p1_idx, B, C1_OUT, C1_H, C1_W
        );

    int c2_total = B * C2_OUT * C2_H * C2_W;
    conv2d_forward_kernel << <ceil_div(c2_total, threads), threads >> > (
        b.d_p1, p.d_w2, p.d_b2, b.d_c2, B, C1_OUT, P1_H, P1_W, C2_OUT, C2_K
        );
    relu_inplace_kernel << <ceil_div(c2_total, threads), threads >> > (b.d_c2, c2_total);

    int p2_total = B * C2_OUT * P2_H * P2_W;
    maxpool2x2_forward_kernel << <ceil_div(p2_total, threads), threads >> > (
        b.d_c2, b.d_p2, b.d_p2_idx, B, C2_OUT, C2_H, C2_W
        );

    int logits_total = B * FC_OUT;
    fc_forward_kernel << <ceil_div(logits_total, threads), threads >> > (
        b.d_p2, p.d_w3, p.d_b3, b.d_logits, B, FC_IN, FC_OUT
        );
}

void backward_pass(const CnnParams& p, BatchBuffers& b, int B) {
    const int threads = 256;

    fc_backward_weight_kernel << <ceil_div(FC_OUT * FC_IN, threads), threads >> > (
        b.d_p2, b.d_dlogits, p.d_gw3, B, FC_IN, FC_OUT
        );
    fc_backward_bias_kernel << <ceil_div(FC_OUT, threads), threads >> > (
        b.d_dlogits, p.d_gb3, B, FC_OUT
        );
    fc_backward_input_kernel << <ceil_div(B * FC_IN, threads), threads >> > (
        b.d_dlogits, p.d_w3, b.d_dp2, B, FC_IN, FC_OUT
        );

    CHECK_CUDA(cudaMemset(b.d_dc2, 0, bytes_of(static_cast<size_t>(B) * C2_OUT * C2_H * C2_W)));
    maxpool2x2_backward_kernel << <ceil_div(B * C2_OUT * P2_H * P2_W, threads), threads >> > (
        b.d_dp2, b.d_p2_idx, b.d_dc2, B * C2_OUT * P2_H * P2_W
        );
    relu_backward_inplace_kernel << <ceil_div(B * C2_OUT * C2_H * C2_W, threads), threads >> > (
        b.d_dc2, b.d_c2, B * C2_OUT * C2_H * C2_W
        );

    conv2d_backward_weight_kernel << <ceil_div(C2_OUT * C1_OUT * C2_K * C2_K, threads), threads >> > (
        b.d_p1, b.d_dc2, p.d_gw2, B, C1_OUT, P1_H, P1_W, C2_OUT, C2_K
        );
    conv2d_backward_bias_kernel << <ceil_div(C2_OUT, threads), threads >> > (
        b.d_dc2, p.d_gb2, B, C2_OUT, C2_H, C2_W
        );
    conv2d_backward_input_kernel << <ceil_div(B * C1_OUT * P1_H * P1_W, threads), threads >> > (
        b.d_dc2, p.d_w2, b.d_dp1, B, C1_OUT, P1_H, P1_W, C2_OUT, C2_K
        );

    CHECK_CUDA(cudaMemset(b.d_dc1, 0, bytes_of(static_cast<size_t>(B) * C1_OUT * C1_H * C1_W)));
    maxpool2x2_backward_kernel << <ceil_div(B * C1_OUT * P1_H * P1_W, threads), threads >> > (
        b.d_dp1, b.d_p1_idx, b.d_dc1, B * C1_OUT * P1_H * P1_W
        );
    relu_backward_inplace_kernel << <ceil_div(B * C1_OUT * C1_H * C1_W, threads), threads >> > (
        b.d_dc1, b.d_c1, B * C1_OUT * C1_H * C1_W
        );

    conv2d_backward_weight_kernel << <ceil_div(C1_OUT * IMG_C * C1_K * C1_K, threads), threads >> > (
        b.d_x, b.d_dc1, p.d_gw1, B, IMG_C, IMG_H, IMG_W, C1_OUT, C1_K
        );
    conv2d_backward_bias_kernel << <ceil_div(C1_OUT, threads), threads >> > (
        b.d_dc1, p.d_gb1, B, C1_OUT, C1_H, C1_W
        );
}

void update_params(CnnParams& p, float lr, int B) {
    const int threads = 256;
    float lr_scale = lr / static_cast<float>(B);

    sgd_update_kernel << <ceil_div(C1_OUT * IMG_C * C1_K * C1_K, threads), threads >> > (p.d_w1, p.d_gw1, lr_scale, C1_OUT * IMG_C * C1_K * C1_K);
    sgd_update_kernel << <ceil_div(C1_OUT, threads), threads >> > (p.d_b1, p.d_gb1, lr_scale, C1_OUT);
    sgd_update_kernel << <ceil_div(C2_OUT * C1_OUT * C2_K * C2_K, threads), threads >> > (p.d_w2, p.d_gw2, lr_scale, C2_OUT * C1_OUT * C2_K * C2_K);
    sgd_update_kernel << <ceil_div(C2_OUT, threads), threads >> > (p.d_b2, p.d_gb2, lr_scale, C2_OUT);
    sgd_update_kernel << <ceil_div(FC_OUT * FC_IN, threads), threads >> > (p.d_w3, p.d_gw3, lr_scale, FC_OUT * FC_IN);
    sgd_update_kernel << <ceil_div(FC_OUT, threads), threads >> > (p.d_b3, p.d_gb3, lr_scale, FC_OUT);
}

void copy_batch_to_pinned(
    const Dataset& ds,
    const std::vector<int>& indices,
    int start,
    int B,
    float* h_x,
    int* h_y
) {
    for (int i = 0; i < B; ++i) {
        int idx = indices[start + i];
        std::copy_n(ds.images.data() + static_cast<size_t>(idx) * IMG_H * IMG_W,
            IMG_H * IMG_W,
            h_x + static_cast<size_t>(i) * IMG_H * IMG_W);
        h_y[i] = ds.labels[idx];
    }
}

void copy_contiguous_batch_to_pinned(
    const Dataset& ds,
    int start,
    int B,
    float* h_x,
    int* h_y
) {
    std::copy_n(ds.images.data() + static_cast<size_t>(start) * IMG_H * IMG_W,
        static_cast<size_t>(B) * IMG_H * IMG_W,
        h_x);
    std::copy_n(ds.labels.data() + start, B, h_y);
}

void run_loss_and_pred(BatchBuffers& b, int B) {
    const int threads = 128;
    softmax_ce_backward_kernel << <ceil_div(B, threads), threads >> > (
        b.d_logits, b.d_y, b.d_dlogits, b.d_losses, b.d_preds, B, NUM_CLASSES
        );
}

PhaseTiming train(
    const Dataset& train_ds,
    const Dataset& test_ds,
    CnnParams& params,
    BatchBuffers& buffers,
    int epochs,
    int batch_size,
    float lr,
    EvalMetrics& final_test_metrics
) {
    float* h_batch_x = nullptr;
    int* h_batch_y = nullptr;
    CHECK_CUDA(cudaMallocHost((void**)&h_batch_x, bytes_of(static_cast<size_t>(batch_size) * IMG_H * IMG_W)));
    CHECK_CUDA(cudaMallocHost((void**)&h_batch_y, sizeof(int) * batch_size));

    std::vector<float> h_losses(batch_size);
    std::vector<int> h_preds(batch_size);

    std::vector<int> order(train_ds.size);
    std::iota(order.begin(), order.end(), 0);
    std::mt19937 rng(123);

    cudaEvent_t ev0, ev1;
    CHECK_CUDA(cudaEventCreate(&ev0));
    CHECK_CUDA(cudaEventCreate(&ev1));

    PhaseTiming timing;
    auto wall_begin = std::chrono::high_resolution_clock::now();

    int batches_per_epoch = (train_ds.size + batch_size - 1) / batch_size;

    for (int epoch = 0; epoch < epochs; ++epoch) {
        std::shuffle(order.begin(), order.end(), rng);

        double epoch_loss = 0.0;
        int correct = 0;
        int seen = 0;
        double epoch_ms = 0.0;

        for (int batch = 0; batch < batches_per_epoch; ++batch) {
            int start = batch * batch_size;
            int B = std::min(batch_size, train_ds.size - start);

            copy_batch_to_pinned(train_ds, order, start, B, h_batch_x, h_batch_y);

            float ms = 0.0f;

            CHECK_CUDA(cudaEventRecord(ev0));
            CHECK_CUDA(cudaMemcpy(buffers.d_x, h_batch_x, bytes_of(static_cast<size_t>(B) * IMG_H * IMG_W), cudaMemcpyHostToDevice));
            CHECK_CUDA(cudaMemcpy(buffers.d_y, h_batch_y, sizeof(int) * B, cudaMemcpyHostToDevice));
            CHECK_CUDA(cudaEventRecord(ev1));
            CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.h2d_ms += ms;
            epoch_ms += ms;

            CHECK_CUDA(cudaEventRecord(ev0));
            forward_pass(params, buffers, B);
            CHECK_CUDA(cudaEventRecord(ev1));
            CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.forward_ms += ms;
            epoch_ms += ms;

            CHECK_CUDA(cudaEventRecord(ev0));
            run_loss_and_pred(buffers, B);
            CHECK_CUDA(cudaEventRecord(ev1));
            CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.loss_ms += ms;
            epoch_ms += ms;

            CHECK_CUDA(cudaMemcpy(h_losses.data(), buffers.d_losses, bytes_of(B), cudaMemcpyDeviceToHost));
            CHECK_CUDA(cudaMemcpy(h_preds.data(), buffers.d_preds, sizeof(int) * B, cudaMemcpyDeviceToHost));
            for (int i = 0; i < B; ++i) {
                epoch_loss += h_losses[i];
                correct += (h_preds[i] == h_batch_y[i]);
            }
            seen += B;

            CHECK_CUDA(cudaEventRecord(ev0));
            backward_pass(params, buffers, B);
            CHECK_CUDA(cudaEventRecord(ev1));
            CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.backward_ms += ms;
            epoch_ms += ms;

            CHECK_CUDA(cudaEventRecord(ev0));
            update_params(params, lr, B);
            CHECK_CUDA(cudaEventRecord(ev1));
            CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.update_ms += ms;
            epoch_ms += ms;
        }

        std::cout << std::fixed << std::setprecision(4)
            << "Epoch " << (epoch + 1) << "/" << epochs
            << " | train_loss=" << (epoch_loss / seen)
            << " | train_acc=" << (100.0 * correct / seen) << "%"
            << " | epoch_gpu_ms=" << epoch_ms
            << " | epoch_throughput=" << (1000.0 * seen / epoch_ms) << " samples/s"
            << std::endl;

        final_test_metrics = evaluate(test_ds, params, buffers, batch_size);
        std::cout << "  test_loss=" << final_test_metrics.loss
            << " | test_acc=" << (100.0 * final_test_metrics.accuracy) << "%"
            << " | infer_avg_batch_ms=" << final_test_metrics.avg_batch_ms
            << std::endl;
    }

    auto wall_end = std::chrono::high_resolution_clock::now();
    timing.total_wall_ms = std::chrono::duration<double, std::milli>(wall_end - wall_begin).count();

    CHECK_CUDA(cudaEventDestroy(ev0));
    CHECK_CUDA(cudaEventDestroy(ev1));
    CHECK_CUDA(cudaFreeHost(h_batch_x));
    CHECK_CUDA(cudaFreeHost(h_batch_y));
    return timing;
}

EvalMetrics evaluate(
    const Dataset& ds,
    CnnParams& params,
    BatchBuffers& buffers,
    int batch_size
) {
    float* h_batch_x = nullptr;
    int* h_batch_y = nullptr;
    CHECK_CUDA(cudaMallocHost((void**)&h_batch_x, bytes_of(static_cast<size_t>(batch_size) * IMG_H * IMG_W)));
    CHECK_CUDA(cudaMallocHost((void**)&h_batch_y, sizeof(int) * batch_size));

    std::vector<float> h_losses(batch_size);
    std::vector<int> h_preds(batch_size);
    std::vector<float> batch_ms;
    batch_ms.reserve((ds.size + batch_size - 1) / batch_size);

    cudaEvent_t ev0, ev1;
    CHECK_CUDA(cudaEventCreate(&ev0));
    CHECK_CUDA(cudaEventCreate(&ev1));

    double total_loss = 0.0;
    int correct = 0;
    int seen = 0;
    double total_infer_ms = 0.0;

    int num_batches = (ds.size + batch_size - 1) / batch_size;
    for (int batch = 0; batch < num_batches; ++batch) {
        int start = batch * batch_size;
        int B = std::min(batch_size, ds.size - start);

        copy_contiguous_batch_to_pinned(ds, start, B, h_batch_x, h_batch_y);
        CHECK_CUDA(cudaMemcpy(buffers.d_x, h_batch_x, bytes_of(static_cast<size_t>(B) * IMG_H * IMG_W), cudaMemcpyHostToDevice));
        CHECK_CUDA(cudaMemcpy(buffers.d_y, h_batch_y, sizeof(int) * B, cudaMemcpyHostToDevice));

        float ms = 0.0f;
        CHECK_CUDA(cudaEventRecord(ev0));
        forward_pass(params, buffers, B);
        run_loss_and_pred(buffers, B);
        CHECK_CUDA(cudaEventRecord(ev1));
        CHECK_CUDA(cudaEventSynchronize(ev1));
        CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));

        batch_ms.push_back(ms);
        total_infer_ms += ms;

        CHECK_CUDA(cudaMemcpy(h_losses.data(), buffers.d_losses, bytes_of(B), cudaMemcpyDeviceToHost));
        CHECK_CUDA(cudaMemcpy(h_preds.data(), buffers.d_preds, sizeof(int) * B, cudaMemcpyDeviceToHost));
        for (int i = 0; i < B; ++i) {
            total_loss += h_losses[i];
            correct += (h_preds[i] == h_batch_y[i]);
        }
        seen += B;
    }

    EvalMetrics m;
    m.loss = total_loss / seen;
    m.accuracy = static_cast<double>(correct) / seen;
    m.total_infer_ms = total_infer_ms;
    m.avg_batch_ms = total_infer_ms / num_batches;
    m.avg_sample_ms = total_infer_ms / seen;
    m.throughput_samples_per_sec = 1000.0 * seen / total_infer_ms;
    m.p50_batch_ms = percentile(batch_ms, 0.50);
    m.p95_batch_ms = percentile(batch_ms, 0.95);

    CHECK_CUDA(cudaEventDestroy(ev0));
    CHECK_CUDA(cudaEventDestroy(ev1));
    CHECK_CUDA(cudaFreeHost(h_batch_x));
    CHECK_CUDA(cudaFreeHost(h_batch_y));
    return m;
}

LatencyMetrics benchmark_single_image_latency(
    const Dataset& test_ds,
    CnnParams& params,
    BatchBuffers& buffers,
    int warmup = 20,
    int reps = 200
) {
    float* h_img = nullptr;
    int* h_lbl = nullptr;
    CHECK_CUDA(cudaMallocHost((void**)&h_img, bytes_of(IMG_H * IMG_W)));
    CHECK_CUDA(cudaMallocHost((void**)&h_lbl, sizeof(int)));

    std::copy_n(test_ds.images.data(), IMG_H * IMG_W, h_img);
    h_lbl[0] = test_ds.labels[0];

    CHECK_CUDA(cudaMemcpy(buffers.d_x, h_img, bytes_of(IMG_H * IMG_W), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(buffers.d_y, h_lbl, sizeof(int), cudaMemcpyHostToDevice));

    cudaEvent_t ev0, ev1;
    CHECK_CUDA(cudaEventCreate(&ev0));
    CHECK_CUDA(cudaEventCreate(&ev1));

    for (int i = 0; i < warmup; ++i) {
        forward_pass(params, buffers, 1);
        run_loss_and_pred(buffers, 1);
    }
    CHECK_CUDA(cudaDeviceSynchronize());

    std::vector<float> samples_ms;
    samples_ms.reserve(reps);
    for (int i = 0; i < reps; ++i) {
        float ms = 0.0f;
        CHECK_CUDA(cudaEventRecord(ev0));
        forward_pass(params, buffers, 1);
        run_loss_and_pred(buffers, 1);
        CHECK_CUDA(cudaEventRecord(ev1));
        CHECK_CUDA(cudaEventSynchronize(ev1));
        CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
        samples_ms.push_back(ms);
    }

    LatencyMetrics m;
    m.mean_ms = std::accumulate(samples_ms.begin(), samples_ms.end(), 0.0) / samples_ms.size();
    m.min_ms = *std::min_element(samples_ms.begin(), samples_ms.end());
    m.max_ms = *std::max_element(samples_ms.begin(), samples_ms.end());
    m.p50_ms = percentile(samples_ms, 0.50);
    m.p95_ms = percentile(samples_ms, 0.95);

    CHECK_CUDA(cudaEventDestroy(ev0));
    CHECK_CUDA(cudaEventDestroy(ev1));
    CHECK_CUDA(cudaFreeHost(h_img));
    CHECK_CUDA(cudaFreeHost(h_lbl));
    return m;
}

void print_model_info(int batch_size) {
    size_t params_count =
        C1_OUT * IMG_C * C1_K * C1_K + C1_OUT +
        C2_OUT * C1_OUT * C2_K * C2_K + C2_OUT +
        FC_OUT * FC_IN + FC_OUT;

    size_t param_bytes = params_count * sizeof(float);

    size_t activation_floats =
        static_cast<size_t>(batch_size) * IMG_H * IMG_W +
        static_cast<size_t>(batch_size) * C1_OUT * C1_H * C1_W +
        static_cast<size_t>(batch_size) * C1_OUT * P1_H * P1_W +
        static_cast<size_t>(batch_size) * C2_OUT * C2_H * C2_W +
        static_cast<size_t>(batch_size) * FC_IN +
        static_cast<size_t>(batch_size) * FC_OUT;

    std::cout << "Model summary" << std::endl;
    std::cout << "  Conv1: 1x28x28 -> 8x26x26" << std::endl;
    std::cout << "  Pool1: 8x26x26 -> 8x13x13" << std::endl;
    std::cout << "  Conv2: 8x13x13 -> 16x11x11" << std::endl;
    std::cout << "  Pool2: 16x11x11 -> 16x5x5" << std::endl;
    std::cout << "  FC: 400 -> 10" << std::endl;
    std::cout << "  Trainable params: " << params_count << std::endl;
    std::cout << "  Parameter memory: " << (param_bytes / 1024.0) << " KB" << std::endl;
    std::cout << "  Approx activation memory per batch: "
        << (activation_floats * sizeof(float) / (1024.0 * 1024.0)) << " MB"
        << std::endl;
}

int main(int argc, char** argv) {
    std::string train_csv = "mnist_train.csv";
    std::string test_csv = "mnist_test.csv";
    int epochs = 3;
    int batch_size = 64;
    float lr = 0.02f;

    if (argc >= 3) {
        train_csv = argv[1];
        test_csv = argv[2];
    }
    if (argc >= 4) epochs = std::stoi(argv[3]);
    if (argc >= 5) batch_size = std::stoi(argv[4]);
    if (argc >= 6) lr = std::stof(argv[5]);

    int device = 0;
    cudaDeviceProp prop{};
    CHECK_CUDA(cudaGetDeviceProperties(&prop, device));
    CHECK_CUDA(cudaSetDevice(device));

    std::cout << "Using GPU: " << prop.name << std::endl;
    std::cout << "Train CSV: " << train_csv << std::endl;
    std::cout << "Test CSV:  " << test_csv << std::endl;
    std::cout << "Epochs=" << epochs << ", batch_size=" << batch_size << ", lr=" << lr << std::endl;

    Dataset train_ds = load_mnist_csv(train_csv);
    Dataset test_ds = load_mnist_csv(test_csv);

    print_model_info(batch_size);

    CnnParams params;
    BatchBuffers buffers;
    init_params(params);
    alloc_batch_buffers(buffers, batch_size);

    EvalMetrics test_metrics;
    PhaseTiming timing = train(train_ds, test_ds, params, buffers, epochs, batch_size, lr, test_metrics);
    LatencyMetrics single = benchmark_single_image_latency(test_ds, params, buffers);

    double total_batches = static_cast<double>((train_ds.size + batch_size - 1) / batch_size) * epochs;
    double avg_batch_train_ms = (timing.h2d_ms + timing.forward_ms + timing.loss_ms + timing.backward_ms + timing.update_ms) / total_batches;
    double avg_epoch_ms = timing.total_wall_ms / epochs;
    double train_throughput = 1000.0 * (static_cast<double>(train_ds.size) * epochs) /
        (timing.h2d_ms + timing.forward_ms + timing.loss_ms + timing.backward_ms + timing.update_ms);

    std::cout << "\n================ Training Performance ================\n";
    std::cout << std::fixed << std::setprecision(4);
    std::cout << "Wall-clock total training time      : " << timing.total_wall_ms << " ms\n";
    std::cout << "Average wall-clock time / epoch     : " << avg_epoch_ms << " ms\n";
    std::cout << "Average measured GPU step / batch   : " << avg_batch_train_ms << " ms\n";
    std::cout << "Measured training throughput        : " << train_throughput << " samples/s\n";
    std::cout << "H2D copy time                       : " << timing.h2d_ms << " ms\n";
    std::cout << "Forward pass time                   : " << timing.forward_ms << " ms\n";
    std::cout << "Loss/softmax time                   : " << timing.loss_ms << " ms\n";
    std::cout << "Backward pass time                  : " << timing.backward_ms << " ms\n";
    std::cout << "SGD update time                     : " << timing.update_ms << " ms\n";

    double measured_total = timing.h2d_ms + timing.forward_ms + timing.loss_ms + timing.backward_ms + timing.update_ms;
    std::cout << "Forward share of measured time      : " << (100.0 * timing.forward_ms / measured_total) << "%\n";
    std::cout << "Backward share of measured time     : " << (100.0 * timing.backward_ms / measured_total) << "%\n";
    std::cout << "Update share of measured time       : " << (100.0 * timing.update_ms / measured_total) << "%\n";

    std::cout << "\n================ Inference Performance ================\n";
    std::cout << "Final test loss                     : " << test_metrics.loss << "\n";
    std::cout << "Final test accuracy                 : " << (100.0 * test_metrics.accuracy) << "%\n";
    std::cout << "Total GPU inference time            : " << test_metrics.total_infer_ms << " ms\n";
    std::cout << "Average batch GPU latency           : " << test_metrics.avg_batch_ms << " ms\n";
    std::cout << "Average sample GPU latency          : " << test_metrics.avg_sample_ms << " ms\n";
    std::cout << "Batch latency p50                   : " << test_metrics.p50_batch_ms << " ms\n";
    std::cout << "Batch latency p95                   : " << test_metrics.p95_batch_ms << " ms\n";
    std::cout << "Inference throughput                : " << test_metrics.throughput_samples_per_sec << " samples/s\n";

    std::cout << "\n============= Single-Image Latency Benchmark =============\n";
    std::cout << "Mean latency                        : " << single.mean_ms << " ms\n";
    std::cout << "Min latency                         : " << single.min_ms << " ms\n";
    std::cout << "Max latency                         : " << single.max_ms << " ms\n";
    std::cout << "p50 latency                         : " << single.p50_ms << " ms\n";
    std::cout << "p95 latency                         : " << single.p95_ms << " ms\n";

    free_batch_buffers(buffers);
    free_params(params);
    CHECK_CUDA(cudaDeviceReset());
    return 0;
}
