// cnn_model.cuh
// Shared header for MNIST CNN — structs, helpers, all CUDA kernels,
// forward/backward/update wrappers, evaluate(), benchmark_single_image_latency(),
// and weight save/load.  Included by both gen_acc_results.cu and gen_perf_results.cu.
//
// Architecture: Conv(1->8,3x3)->ReLU->MaxPool->Conv(8->16,3x3)->ReLU->MaxPool->FC(400->10)

#pragma once

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

// ---------------------------------------------------------------------------
// Macro
// ---------------------------------------------------------------------------

#define CHECK_CUDA(call)                                                        \
    do {                                                                        \
        cudaError_t err__ = (call);                                             \
        if (err__ != cudaSuccess) {                                             \
            std::cerr << "CUDA error at " << __FILE__ << ":" << __LINE__       \
                      << " -> " << cudaGetErrorString(err__) << std::endl;     \
            std::exit(EXIT_FAILURE);                                            \
        }                                                                       \
    } while (0)

// ---------------------------------------------------------------------------
// Architecture constants
// ---------------------------------------------------------------------------

constexpr int IMG_H = 28;
constexpr int IMG_W = 28;
constexpr int IMG_C = 1;
constexpr int NUM_CLASSES = 10;

constexpr int C1_OUT = 8;
constexpr int C1_K   = 3;
constexpr int C1_H   = IMG_H - C1_K + 1; // 26
constexpr int C1_W   = IMG_W - C1_K + 1; // 26
constexpr int P1_H   = C1_H / 2;          // 13
constexpr int P1_W   = C1_W / 2;          // 13

constexpr int C2_OUT = 16;
constexpr int C2_K   = 3;
constexpr int C2_H   = P1_H - C2_K + 1;  // 11
constexpr int C2_W   = P1_W - C2_K + 1;  // 11
constexpr int P2_H   = C2_H / 2;          // 5
constexpr int P2_W   = C2_W / 2;          // 5
constexpr int FC_IN  = C2_OUT * P2_H * P2_W; // 400
constexpr int FC_OUT = NUM_CLASSES;

// ---------------------------------------------------------------------------
// Structs
// ---------------------------------------------------------------------------

struct Dataset {
    std::vector<float> images; // N x 784, normalised [0,1]
    std::vector<int>   labels; // N
    int size = 0;
};

struct PhaseTiming {
    double h2d_ms       = 0.0;
    double forward_ms   = 0.0;
    double loss_ms      = 0.0;
    double backward_ms  = 0.0;
    double update_ms    = 0.0;
    double total_wall_ms = 0.0;
};

struct EvalMetrics {
    double loss                      = 0.0;
    double accuracy                  = 0.0;
    double total_infer_ms            = 0.0;
    double avg_batch_ms              = 0.0;
    double avg_sample_ms             = 0.0;
    double throughput_samples_per_sec = 0.0;
    double p50_batch_ms              = 0.0;
    double p95_batch_ms              = 0.0;
};

struct LatencyMetrics {
    double mean_ms = 0.0;
    double min_ms  = 0.0;
    double max_ms  = 0.0;
    double p50_ms  = 0.0;
    double p95_ms  = 0.0;
};

struct CnnParams {
    float* d_w1  = nullptr;  float* d_b1  = nullptr;
    float* d_w2  = nullptr;  float* d_b2  = nullptr;
    float* d_w3  = nullptr;  float* d_b3  = nullptr;
    float* d_gw1 = nullptr;  float* d_gb1 = nullptr;
    float* d_gw2 = nullptr;  float* d_gb2 = nullptr;
    float* d_gw3 = nullptr;  float* d_gb3 = nullptr;
};

struct BatchBuffers {
    int max_batch = 0;
    float* d_x       = nullptr;  // [B,1,28,28]
    int*   d_y       = nullptr;  // [B]
    float* d_c1      = nullptr;  // [B,8,26,26]
    float* d_p1      = nullptr;  // [B,8,13,13]
    int*   d_p1_idx  = nullptr;
    float* d_c2      = nullptr;  // [B,16,11,11]
    float* d_p2      = nullptr;  // [B,400]
    int*   d_p2_idx  = nullptr;
    float* d_logits  = nullptr;  // [B,10]
    float* d_dlogits = nullptr;
    float* d_losses  = nullptr;  // [B]
    int*   d_preds   = nullptr;  // [B]
    float* d_dp2     = nullptr;  // [B,400]
    float* d_dc2     = nullptr;  // [B,16,11,11]
    float* d_dp1     = nullptr;  // [B,8,13,13]
    float* d_dc1     = nullptr;  // [B,8,26,26]
};

// ---------------------------------------------------------------------------
// Utilities
// ---------------------------------------------------------------------------

inline size_t bytes_of(size_t n) { return n * sizeof(float); }

inline int ceil_div(int a, int b) { return (a + b - 1) / b; }

inline float percentile(std::vector<float> v, double q) {
    if (v.empty()) return 0.0f;
    std::sort(v.begin(), v.end());
    double pos = q * static_cast<double>(v.size() - 1);
    size_t lo = static_cast<size_t>(std::floor(pos));
    size_t hi = static_cast<size_t>(std::ceil(pos));
    double w  = pos - static_cast<double>(lo);
    return static_cast<float>((1.0 - w) * v[lo] + w * v[hi]);
}

inline void he_init(std::vector<float>& w, int fan_in, std::mt19937& rng) {
    float stddev = std::sqrt(2.0f / static_cast<float>(fan_in));
    std::normal_distribution<float> dist(0.0f, stddev);
    for (auto& x : w) x = dist(rng);
}

// ---------------------------------------------------------------------------
// CSV loading
// ---------------------------------------------------------------------------

inline Dataset load_mnist_csv(const std::string& path) {
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
            if (std::isdigit(static_cast<unsigned char>(s[i]))) { has_digit = true; continue; }
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

// ---------------------------------------------------------------------------
// Model info
// ---------------------------------------------------------------------------

inline void print_model_info(int batch_size) {
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
    std::cout << "Model summary\n"
              << "  Conv1: 1x28x28  -> 8x26x26\n"
              << "  Pool1: 8x26x26  -> 8x13x13\n"
              << "  Conv2: 8x13x13  -> 16x11x11\n"
              << "  Pool2: 16x11x11 -> 16x5x5\n"
              << "  FC:    400      -> 10\n"
              << "  Trainable params: "  << params_count << "\n"
              << "  Parameter memory: "  << (param_bytes / 1024.0) << " KB\n"
              << "  Approx activation memory/batch: "
              << (activation_floats * sizeof(float) / (1024.0 * 1024.0)) << " MB\n";
}

// ---------------------------------------------------------------------------
// GPU resource management
// ---------------------------------------------------------------------------

inline void init_params(CnnParams& p) {
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

    CHECK_CUDA(cudaMalloc((void**)&p.d_w1,  bytes_of(h_w1.size())));
    CHECK_CUDA(cudaMalloc((void**)&p.d_b1,  bytes_of(h_b1.size())));
    CHECK_CUDA(cudaMalloc((void**)&p.d_w2,  bytes_of(h_w2.size())));
    CHECK_CUDA(cudaMalloc((void**)&p.d_b2,  bytes_of(h_b2.size())));
    CHECK_CUDA(cudaMalloc((void**)&p.d_w3,  bytes_of(h_w3.size())));
    CHECK_CUDA(cudaMalloc((void**)&p.d_b3,  bytes_of(h_b3.size())));
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

inline void free_params(CnnParams& p) {
    cudaFree(p.d_w1);  cudaFree(p.d_b1);
    cudaFree(p.d_w2);  cudaFree(p.d_b2);
    cudaFree(p.d_w3);  cudaFree(p.d_b3);
    cudaFree(p.d_gw1); cudaFree(p.d_gb1);
    cudaFree(p.d_gw2); cudaFree(p.d_gb2);
    cudaFree(p.d_gw3); cudaFree(p.d_gb3);
}

inline void alloc_batch_buffers(BatchBuffers& b, int max_batch) {
    b.max_batch = max_batch;
    CHECK_CUDA(cudaMalloc((void**)&b.d_x,      bytes_of(static_cast<size_t>(max_batch) * IMG_H * IMG_W)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_y,      sizeof(int) * max_batch));
    CHECK_CUDA(cudaMalloc((void**)&b.d_c1,     bytes_of(static_cast<size_t>(max_batch) * C1_OUT * C1_H * C1_W)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_p1,     bytes_of(static_cast<size_t>(max_batch) * C1_OUT * P1_H * P1_W)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_p1_idx, sizeof(int) * static_cast<size_t>(max_batch) * C1_OUT * P1_H * P1_W));
    CHECK_CUDA(cudaMalloc((void**)&b.d_c2,     bytes_of(static_cast<size_t>(max_batch) * C2_OUT * C2_H * C2_W)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_p2,     bytes_of(static_cast<size_t>(max_batch) * FC_IN)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_p2_idx, sizeof(int) * static_cast<size_t>(max_batch) * C2_OUT * P2_H * P2_W));
    CHECK_CUDA(cudaMalloc((void**)&b.d_logits, bytes_of(static_cast<size_t>(max_batch) * FC_OUT)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_dlogits,bytes_of(static_cast<size_t>(max_batch) * FC_OUT)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_losses, bytes_of(max_batch)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_preds,  sizeof(int) * max_batch));
    CHECK_CUDA(cudaMalloc((void**)&b.d_dp2,    bytes_of(static_cast<size_t>(max_batch) * FC_IN)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_dc2,    bytes_of(static_cast<size_t>(max_batch) * C2_OUT * C2_H * C2_W)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_dp1,    bytes_of(static_cast<size_t>(max_batch) * C1_OUT * P1_H * P1_W)));
    CHECK_CUDA(cudaMalloc((void**)&b.d_dc1,    bytes_of(static_cast<size_t>(max_batch) * C1_OUT * C1_H * C1_W)));
}

inline void free_batch_buffers(BatchBuffers& b) {
    cudaFree(b.d_x);      cudaFree(b.d_y);
    cudaFree(b.d_c1);     cudaFree(b.d_p1);    cudaFree(b.d_p1_idx);
    cudaFree(b.d_c2);     cudaFree(b.d_p2);    cudaFree(b.d_p2_idx);
    cudaFree(b.d_logits); cudaFree(b.d_dlogits);
    cudaFree(b.d_losses); cudaFree(b.d_preds);
    cudaFree(b.d_dp2);    cudaFree(b.d_dc2);
    cudaFree(b.d_dp1);    cudaFree(b.d_dc1);
}

// ---------------------------------------------------------------------------
// Weight serialisation  (used between gen_acc -> gen_perf)
// ---------------------------------------------------------------------------

inline void save_weights(const CnnParams& p, const std::string& path) {
    // Sizes
    constexpr size_t n_w1 = C1_OUT * IMG_C * C1_K * C1_K;
    constexpr size_t n_b1 = C1_OUT;
    constexpr size_t n_w2 = C2_OUT * C1_OUT * C2_K * C2_K;
    constexpr size_t n_b2 = C2_OUT;
    constexpr size_t n_w3 = FC_OUT * FC_IN;
    constexpr size_t n_b3 = FC_OUT;

    std::vector<float> h_w1(n_w1), h_b1(n_b1),
                       h_w2(n_w2), h_b2(n_b2),
                       h_w3(n_w3), h_b3(n_b3);

    CHECK_CUDA(cudaMemcpy(h_w1.data(), p.d_w1, bytes_of(n_w1), cudaMemcpyDeviceToHost));
    CHECK_CUDA(cudaMemcpy(h_b1.data(), p.d_b1, bytes_of(n_b1), cudaMemcpyDeviceToHost));
    CHECK_CUDA(cudaMemcpy(h_w2.data(), p.d_w2, bytes_of(n_w2), cudaMemcpyDeviceToHost));
    CHECK_CUDA(cudaMemcpy(h_b2.data(), p.d_b2, bytes_of(n_b2), cudaMemcpyDeviceToHost));
    CHECK_CUDA(cudaMemcpy(h_w3.data(), p.d_w3, bytes_of(n_w3), cudaMemcpyDeviceToHost));
    CHECK_CUDA(cudaMemcpy(h_b3.data(), p.d_b3, bytes_of(n_b3), cudaMemcpyDeviceToHost));

    FILE* f = fopen(path.c_str(), "wb");
    if (!f) { std::cerr << "Cannot write weights to: " << path << std::endl; std::exit(1); }
    fwrite(h_w1.data(), sizeof(float), n_w1, f);
    fwrite(h_b1.data(), sizeof(float), n_b1, f);
    fwrite(h_w2.data(), sizeof(float), n_w2, f);
    fwrite(h_b2.data(), sizeof(float), n_b2, f);
    fwrite(h_w3.data(), sizeof(float), n_w3, f);
    fwrite(h_b3.data(), sizeof(float), n_b3, f);
    fclose(f);
    std::cout << "Weights saved to: " << path << "\n";
}

inline void load_weights(CnnParams& p, const std::string& path) {
    constexpr size_t n_w1 = C1_OUT * IMG_C * C1_K * C1_K;
    constexpr size_t n_b1 = C1_OUT;
    constexpr size_t n_w2 = C2_OUT * C1_OUT * C2_K * C2_K;
    constexpr size_t n_b2 = C2_OUT;
    constexpr size_t n_w3 = FC_OUT * FC_IN;
    constexpr size_t n_b3 = FC_OUT;

    std::vector<float> h_w1(n_w1), h_b1(n_b1),
                       h_w2(n_w2), h_b2(n_b2),
                       h_w3(n_w3), h_b3(n_b3);

    FILE* f = fopen(path.c_str(), "rb");
    if (!f) { std::cerr << "Cannot open weights: " << path << std::endl; std::exit(1); }
    fread(h_w1.data(), sizeof(float), n_w1, f);
    fread(h_b1.data(), sizeof(float), n_b1, f);
    fread(h_w2.data(), sizeof(float), n_w2, f);
    fread(h_b2.data(), sizeof(float), n_b2, f);
    fread(h_w3.data(), sizeof(float), n_w3, f);
    fread(h_b3.data(), sizeof(float), n_b3, f);
    fclose(f);

    CHECK_CUDA(cudaMemcpy(p.d_w1, h_w1.data(), bytes_of(n_w1), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(p.d_b1, h_b1.data(), bytes_of(n_b1), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(p.d_w2, h_w2.data(), bytes_of(n_w2), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(p.d_b2, h_b2.data(), bytes_of(n_b2), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(p.d_w3, h_w3.data(), bytes_of(n_w3), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(p.d_b3, h_b3.data(), bytes_of(n_b3), cudaMemcpyHostToDevice));
    std::cout << "Weights loaded from: " << path << "\n";
}

// ---------------------------------------------------------------------------
// Batch copy helpers
// ---------------------------------------------------------------------------

inline void copy_batch_to_pinned(
    const Dataset& ds, const std::vector<int>& indices,
    int start, int B, float* h_x, int* h_y
) {
    for (int i = 0; i < B; ++i) {
        int idx = indices[start + i];
        std::copy_n(ds.images.data() + static_cast<size_t>(idx) * IMG_H * IMG_W,
                    IMG_H * IMG_W,
                    h_x + static_cast<size_t>(i) * IMG_H * IMG_W);
        h_y[i] = ds.labels[idx];
    }
}

inline void copy_contiguous_batch_to_pinned(
    const Dataset& ds, int start, int B, float* h_x, int* h_y
) {
    std::copy_n(ds.images.data() + static_cast<size_t>(start) * IMG_H * IMG_W,
                static_cast<size_t>(B) * IMG_H * IMG_W, h_x);
    std::copy_n(ds.labels.data() + start, B, h_y);
}

// ---------------------------------------------------------------------------
// CUDA Kernels
// ---------------------------------------------------------------------------

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
    int b  = idx / (OW * OH * Cout);
    float sum = bias[oc];
    for (int ic = 0; ic < Cin; ++ic)
        for (int kh = 0; kh < K; ++kh)
            for (int kw = 0; kw < K; ++kw)
                sum += x[((b * Cin + ic) * H + (oh + kh)) * W + (ow + kw)] *
                       w[((oc * Cin + ic) * K + kh) * K + kw];
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
    int OH = H / 2, OW = W / 2;
    if (idx >= B * C * OH * OW) return;
    int ow = idx % OW;
    int oh = (idx / OW) % OH;
    int c  = (idx / (OW * OH)) % C;
    int b  = idx / (OW * OH * C);
    float best = -FLT_MAX; int best_idx = 0;
    for (int dh = 0; dh < 2; ++dh)
        for (int dw = 0; dw < 2; ++dw) {
            int x_idx = ((b * C + c) * H + (oh * 2 + dh)) * W + (ow * 2 + dw);
            if (x[x_idx] > best) { best = x[x_idx]; best_idx = x_idx; }
        }
    y[idx] = best; idx_out[idx] = best_idx;
}

__global__ void maxpool2x2_backward_kernel(
    const float* d_out, const int* idx_out, float* d_in, int total
) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < total) d_in[idx_out[i]] = d_out[i];
}

__global__ void fc_forward_kernel(
    const float* x, const float* w, const float* bias, float* y,
    int B, int in_dim, int out_dim
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= B * out_dim) return;
    int o = idx % out_dim, b = idx / out_dim;
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
    const float* z  = logits  + b * classes;
    float*       dz = d_logits + b * classes;
    float max_logit = z[0];
    for (int j = 1; j < classes; ++j) max_logit = fmaxf(max_logit, z[j]);
    float sum_exp = 0.0f; int pred = 0; float best = z[0];
    for (int j = 0; j < classes; ++j) {
        float e = expf(z[j] - max_logit); dz[j] = e; sum_exp += e;
        if (z[j] > best) { best = z[j]; pred = j; }
    }
    int y = labels[b]; float prob_y = 0.0f;
    for (int j = 0; j < classes; ++j) {
        float p = dz[j] / sum_exp;
        dz[j] = p - (j == y ? 1.0f : 0.0f);
        if (j == y) prob_y = p;
    }
    losses[b] = -logf(fmaxf(prob_y, 1e-8f));
    preds[b]  = pred;
}

__global__ void fc_backward_input_kernel(
    const float* d_out, const float* w, float* d_in,
    int B, int in_dim, int out_dim
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= B * in_dim) return;
    int i = idx % in_dim, b = idx / in_dim;
    float sum = 0.0f;
    for (int o = 0; o < out_dim; ++o) sum += d_out[b * out_dim + o] * w[o * in_dim + i];
    d_in[idx] = sum;
}

__global__ void fc_backward_weight_kernel(
    const float* x, const float* d_out, float* d_w,
    int B, int in_dim, int out_dim
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= out_dim * in_dim) return;
    int i = idx % in_dim, o = idx / in_dim;
    float sum = 0.0f;
    for (int b = 0; b < B; ++b) sum += d_out[b * out_dim + o] * x[b * in_dim + i];
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
    if (idx >= B * Cin * H * W) return;
    int iw = idx % W, ih = (idx / W) % H, ic = (idx / (W * H)) % Cin, b = idx / (W * H * Cin);
    int OH = H - K + 1, OW = W - K + 1;
    float sum = 0.0f;
    for (int oc = 0; oc < Cout; ++oc)
        for (int kh = 0; kh < K; ++kh) {
            int oh = ih - kh; if (oh < 0 || oh >= OH) continue;
            for (int kw = 0; kw < K; ++kw) {
                int ow = iw - kw; if (ow < 0 || ow >= OW) continue;
                sum += d_out[((b * Cout + oc) * OH + oh) * OW + ow] *
                       w[((oc * Cin + ic) * K + kh) * K + kw];
            }
        }
    d_in[idx] = sum;
}

__global__ void conv2d_backward_weight_kernel(
    const float* x, const float* d_out, float* d_w,
    int B, int Cin, int H, int W, int Cout, int K
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= Cout * Cin * K * K) return;
    int kw = idx % K, kh = (idx / K) % K, ic = (idx / (K * K)) % Cin, oc = idx / (K * K * Cin);
    int OH = H - K + 1, OW = W - K + 1;
    float sum = 0.0f;
    for (int b = 0; b < B; ++b)
        for (int oh = 0; oh < OH; ++oh)
            for (int ow = 0; ow < OW; ++ow)
                sum += d_out[((b * Cout + oc) * OH + oh) * OW + ow] *
                       x[((b * Cin + ic) * H + (oh + kh)) * W + (ow + kw)];
    d_w[idx] = sum;
}

__global__ void conv2d_backward_bias_kernel(
    const float* d_out, float* d_b, int B, int Cout, int OH, int OW
) {
    int oc = blockIdx.x * blockDim.x + threadIdx.x;
    if (oc >= Cout) return;
    float sum = 0.0f;
    for (int b = 0; b < B; ++b)
        for (int oh = 0; oh < OH; ++oh)
            for (int ow = 0; ow < OW; ++ow)
                sum += d_out[((b * Cout + oc) * OH + oh) * OW + ow];
    d_b[oc] = sum;
}

__global__ void sgd_update_kernel(float* p, const float* g, float lr_scale, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) p[i] -= lr_scale * g[i];
}

// ---------------------------------------------------------------------------
// Compute wrappers
// ---------------------------------------------------------------------------

inline void forward_pass(const CnnParams& p, BatchBuffers& b, int B) {
    const int T = 256;
    int c1_total = B * C1_OUT * C1_H * C1_W;
    conv2d_forward_kernel<<<ceil_div(c1_total,T),T>>>(b.d_x, p.d_w1, p.d_b1, b.d_c1, B, IMG_C, IMG_H, IMG_W, C1_OUT, C1_K);
    relu_inplace_kernel<<<ceil_div(c1_total,T),T>>>(b.d_c1, c1_total);
    int p1_total = B * C1_OUT * P1_H * P1_W;
    maxpool2x2_forward_kernel<<<ceil_div(p1_total,T),T>>>(b.d_c1, b.d_p1, b.d_p1_idx, B, C1_OUT, C1_H, C1_W);
    int c2_total = B * C2_OUT * C2_H * C2_W;
    conv2d_forward_kernel<<<ceil_div(c2_total,T),T>>>(b.d_p1, p.d_w2, p.d_b2, b.d_c2, B, C1_OUT, P1_H, P1_W, C2_OUT, C2_K);
    relu_inplace_kernel<<<ceil_div(c2_total,T),T>>>(b.d_c2, c2_total);
    int p2_total = B * C2_OUT * P2_H * P2_W;
    maxpool2x2_forward_kernel<<<ceil_div(p2_total,T),T>>>(b.d_c2, b.d_p2, b.d_p2_idx, B, C2_OUT, C2_H, C2_W);
    fc_forward_kernel<<<ceil_div(B*FC_OUT,T),T>>>(b.d_p2, p.d_w3, p.d_b3, b.d_logits, B, FC_IN, FC_OUT);
}

inline void run_loss_and_pred(BatchBuffers& b, int B) {
    softmax_ce_backward_kernel<<<ceil_div(B,128),128>>>(
        b.d_logits, b.d_y, b.d_dlogits, b.d_losses, b.d_preds, B, NUM_CLASSES);
}

inline void backward_pass(const CnnParams& p, BatchBuffers& b, int B) {
    const int T = 256;
    fc_backward_weight_kernel<<<ceil_div(FC_OUT*FC_IN,T),T>>>(b.d_p2, b.d_dlogits, p.d_gw3, B, FC_IN, FC_OUT);
    fc_backward_bias_kernel<<<ceil_div(FC_OUT,T),T>>>(b.d_dlogits, p.d_gb3, B, FC_OUT);
    fc_backward_input_kernel<<<ceil_div(B*FC_IN,T),T>>>(b.d_dlogits, p.d_w3, b.d_dp2, B, FC_IN, FC_OUT);
    CHECK_CUDA(cudaMemset(b.d_dc2, 0, bytes_of(static_cast<size_t>(B)*C2_OUT*C2_H*C2_W)));
    maxpool2x2_backward_kernel<<<ceil_div(B*C2_OUT*P2_H*P2_W,T),T>>>(b.d_dp2, b.d_p2_idx, b.d_dc2, B*C2_OUT*P2_H*P2_W);
    relu_backward_inplace_kernel<<<ceil_div(B*C2_OUT*C2_H*C2_W,T),T>>>(b.d_dc2, b.d_c2, B*C2_OUT*C2_H*C2_W);
    conv2d_backward_weight_kernel<<<ceil_div(C2_OUT*C1_OUT*C2_K*C2_K,T),T>>>(b.d_p1, b.d_dc2, p.d_gw2, B, C1_OUT, P1_H, P1_W, C2_OUT, C2_K);
    conv2d_backward_bias_kernel<<<ceil_div(C2_OUT,T),T>>>(b.d_dc2, p.d_gb2, B, C2_OUT, C2_H, C2_W);
    conv2d_backward_input_kernel<<<ceil_div(B*C1_OUT*P1_H*P1_W,T),T>>>(b.d_dc2, p.d_w2, b.d_dp1, B, C1_OUT, P1_H, P1_W, C2_OUT, C2_K);
    CHECK_CUDA(cudaMemset(b.d_dc1, 0, bytes_of(static_cast<size_t>(B)*C1_OUT*C1_H*C1_W)));
    maxpool2x2_backward_kernel<<<ceil_div(B*C1_OUT*P1_H*P1_W,T),T>>>(b.d_dp1, b.d_p1_idx, b.d_dc1, B*C1_OUT*P1_H*P1_W);
    relu_backward_inplace_kernel<<<ceil_div(B*C1_OUT*C1_H*C1_W,T),T>>>(b.d_dc1, b.d_c1, B*C1_OUT*C1_H*C1_W);
    conv2d_backward_weight_kernel<<<ceil_div(C1_OUT*IMG_C*C1_K*C1_K,T),T>>>(b.d_x, b.d_dc1, p.d_gw1, B, IMG_C, IMG_H, IMG_W, C1_OUT, C1_K);
    conv2d_backward_bias_kernel<<<ceil_div(C1_OUT,T),T>>>(b.d_dc1, p.d_gb1, B, C1_OUT, C1_H, C1_W);
}

inline void update_params(CnnParams& p, float lr, int B) {
    const int T = 256;
    float s = lr / static_cast<float>(B);
    sgd_update_kernel<<<ceil_div(C1_OUT*IMG_C*C1_K*C1_K,T),T>>>(p.d_w1, p.d_gw1, s, C1_OUT*IMG_C*C1_K*C1_K);
    sgd_update_kernel<<<ceil_div(C1_OUT,T),T>>>(p.d_b1, p.d_gb1, s, C1_OUT);
    sgd_update_kernel<<<ceil_div(C2_OUT*C1_OUT*C2_K*C2_K,T),T>>>(p.d_w2, p.d_gw2, s, C2_OUT*C1_OUT*C2_K*C2_K);
    sgd_update_kernel<<<ceil_div(C2_OUT,T),T>>>(p.d_b2, p.d_gb2, s, C2_OUT);
    sgd_update_kernel<<<ceil_div(FC_OUT*FC_IN,T),T>>>(p.d_w3, p.d_gw3, s, FC_OUT*FC_IN);
    sgd_update_kernel<<<ceil_div(FC_OUT,T),T>>>(p.d_b3, p.d_gb3, s, FC_OUT);
}

// ---------------------------------------------------------------------------
// evaluate()
// ---------------------------------------------------------------------------

inline EvalMetrics evaluate(
    const Dataset& ds, CnnParams& params, BatchBuffers& buffers, int batch_size
) {
    float* h_x = nullptr; int* h_y = nullptr;
    CHECK_CUDA(cudaMallocHost((void**)&h_x, bytes_of(static_cast<size_t>(batch_size)*IMG_H*IMG_W)));
    CHECK_CUDA(cudaMallocHost((void**)&h_y, sizeof(int)*batch_size));
    std::vector<float> h_losses(batch_size);
    std::vector<int>   h_preds(batch_size);
    std::vector<float> batch_ms;
    cudaEvent_t ev0, ev1;
    CHECK_CUDA(cudaEventCreate(&ev0)); CHECK_CUDA(cudaEventCreate(&ev1));
    double total_loss = 0.0; int correct = 0, seen = 0;
    double total_infer_ms = 0.0;
    int num_batches = (ds.size + batch_size - 1) / batch_size;
    for (int bat = 0; bat < num_batches; ++bat) {
        int start = bat * batch_size;
        int B = std::min(batch_size, ds.size - start);
        copy_contiguous_batch_to_pinned(ds, start, B, h_x, h_y);
        CHECK_CUDA(cudaMemcpy(buffers.d_x, h_x, bytes_of(static_cast<size_t>(B)*IMG_H*IMG_W), cudaMemcpyHostToDevice));
        CHECK_CUDA(cudaMemcpy(buffers.d_y, h_y, sizeof(int)*B, cudaMemcpyHostToDevice));
        float ms = 0.0f;
        CHECK_CUDA(cudaEventRecord(ev0));
        forward_pass(params, buffers, B);
        run_loss_and_pred(buffers, B);
        CHECK_CUDA(cudaEventRecord(ev1)); CHECK_CUDA(cudaEventSynchronize(ev1));
        CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
        batch_ms.push_back(ms); total_infer_ms += ms;
        CHECK_CUDA(cudaMemcpy(h_losses.data(), buffers.d_losses, bytes_of(B), cudaMemcpyDeviceToHost));
        CHECK_CUDA(cudaMemcpy(h_preds.data(),  buffers.d_preds,  sizeof(int)*B, cudaMemcpyDeviceToHost));
        for (int i = 0; i < B; ++i) { total_loss += h_losses[i]; correct += (h_preds[i] == h_y[i]); }
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
    CHECK_CUDA(cudaEventDestroy(ev0)); CHECK_CUDA(cudaEventDestroy(ev1));
    CHECK_CUDA(cudaFreeHost(h_x)); CHECK_CUDA(cudaFreeHost(h_y));
    return m;
}

// ---------------------------------------------------------------------------
// benchmark_single_image_latency()
// ---------------------------------------------------------------------------

inline LatencyMetrics benchmark_single_image_latency(
    const Dataset& ds, CnnParams& params, BatchBuffers& buffers,
    int warmup = 20, int reps = 200
) {
    float* h_img = nullptr; int* h_lbl = nullptr;
    CHECK_CUDA(cudaMallocHost((void**)&h_img, bytes_of(IMG_H * IMG_W)));
    CHECK_CUDA(cudaMallocHost((void**)&h_lbl, sizeof(int)));
    std::copy_n(ds.images.data(), IMG_H * IMG_W, h_img);
    h_lbl[0] = ds.labels[0];
    CHECK_CUDA(cudaMemcpy(buffers.d_x, h_img, bytes_of(IMG_H * IMG_W), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(buffers.d_y, h_lbl, sizeof(int), cudaMemcpyHostToDevice));
    cudaEvent_t ev0, ev1;
    CHECK_CUDA(cudaEventCreate(&ev0)); CHECK_CUDA(cudaEventCreate(&ev1));
    for (int i = 0; i < warmup; ++i) { forward_pass(params, buffers, 1); run_loss_and_pred(buffers, 1); }
    CHECK_CUDA(cudaDeviceSynchronize());
    std::vector<float> samples_ms; samples_ms.reserve(reps);
    for (int i = 0; i < reps; ++i) {
        float ms = 0.0f;
        CHECK_CUDA(cudaEventRecord(ev0));
        forward_pass(params, buffers, 1); run_loss_and_pred(buffers, 1);
        CHECK_CUDA(cudaEventRecord(ev1)); CHECK_CUDA(cudaEventSynchronize(ev1));
        CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
        samples_ms.push_back(ms);
    }
    LatencyMetrics m;
    m.mean_ms = std::accumulate(samples_ms.begin(), samples_ms.end(), 0.0) / samples_ms.size();
    m.min_ms  = *std::min_element(samples_ms.begin(), samples_ms.end());
    m.max_ms  = *std::max_element(samples_ms.begin(), samples_ms.end());
    m.p50_ms  = percentile(samples_ms, 0.50);
    m.p95_ms  = percentile(samples_ms, 0.95);
    CHECK_CUDA(cudaEventDestroy(ev0)); CHECK_CUDA(cudaEventDestroy(ev1));
    CHECK_CUDA(cudaFreeHost(h_img)); CHECK_CUDA(cudaFreeHost(h_lbl));
    return m;
}
