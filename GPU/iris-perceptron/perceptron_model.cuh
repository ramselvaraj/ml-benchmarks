#pragma once

#include <cuda_runtime.h>

#include <algorithm>
#include <cctype>
#include <chrono>
#include <cmath>
#include <cstddef>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <numeric>
#include <random>
#include <sstream>
#include <string>
#include <vector>

// ---------------------------------------------------------------------------
// Error checking
// ---------------------------------------------------------------------------

#define CHECK_CUDA(call)                                                       \
    do {                                                                       \
        cudaError_t err__ = (call);                                            \
        if (err__ != cudaSuccess) {                                            \
            std::cerr << "CUDA error at " << __FILE__ << ":" << __LINE__      \
                      << " -> " << cudaGetErrorString(err__) << std::endl;    \
            std::exit(EXIT_FAILURE);                                           \
        }                                                                      \
    } while (0)

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

constexpr int NUM_FEATURES = 4;

// ---------------------------------------------------------------------------
// Structs
// ---------------------------------------------------------------------------

struct Dataset {
    std::vector<float> x;  // N x NUM_FEATURES
    std::vector<int>   y;  // N, encoded as {-1, +1}
    int size = 0;
};

struct BinaryClassInfo {
    std::string negative_label;
    std::string positive_label;
};

struct StandardizationStats {
    float mean[NUM_FEATURES]{};
    float stddev[NUM_FEATURES]{};
};

struct PhaseTiming {
    double h2d_ms      = 0.0;
    double forward_ms  = 0.0;
    double metric_ms   = 0.0;
    double backward_ms = 0.0;
    double update_ms   = 0.0;
    double total_wall_ms = 0.0;
};

struct EvalMetrics {
    double loss     = 0.0;
    double accuracy = 0.0;
    double precision = 0.0;
    double recall   = 0.0;
    double f1       = 0.0;
    int tp = 0, tn = 0, fp = 0, fn = 0;
    double total_infer_ms = 0.0;
    double avg_batch_ms   = 0.0;
    double avg_sample_ms  = 0.0;
    double throughput_samples_per_sec = 0.0;
    double p50_batch_ms = 0.0;
    double p95_batch_ms = 0.0;
};

struct LatencyMetrics {
    double mean_ms = 0.0;
    double min_ms  = 0.0;
    double max_ms  = 0.0;
    double p50_ms  = 0.0;
    double p95_ms  = 0.0;
};

struct PerceptronParams {
    float* d_w        = nullptr; // [NUM_FEATURES]
    float* d_b        = nullptr; // [1]
    float* d_gw       = nullptr; // [NUM_FEATURES]
    float* d_gb       = nullptr; // [1]
    int*   d_mistakes = nullptr; // [1]
};

struct BatchBuffers {
    int    max_batch  = 0;
    float* d_x        = nullptr; // [B, NUM_FEATURES]
    int*   d_y        = nullptr; // [B]
    float* d_scores   = nullptr; // [B]
    int*   d_preds    = nullptr; // [B]
    float* d_losses   = nullptr; // [B]
    int*   d_correct  = nullptr; // [B]
    int*   d_errors   = nullptr; // [B]
};

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

static inline size_t bytes_of(size_t n) { return n * sizeof(float); }

static inline std::string trim(const std::string& s) {
    size_t lo = 0;
    while (lo < s.size() && std::isspace(static_cast<unsigned char>(s[lo]))) ++lo;
    size_t hi = s.size();
    while (hi > lo && std::isspace(static_cast<unsigned char>(s[hi - 1]))) --hi;
    if (hi > lo && s[lo] == '"' && s[hi - 1] == '"') { ++lo; --hi; }
    return s.substr(lo, hi - lo);
}

static inline std::vector<std::string> split_csv_simple(const std::string& line) {
    std::vector<std::string> out;
    std::stringstream ss(line);
    std::string token;
    while (std::getline(ss, token, ',')) out.push_back(trim(token));
    return out;
}

static inline bool parse_float_token(const std::string& token, float& value) {
    std::string t = trim(token);
    if (t.empty()) return false;
    char* end = nullptr;
    value = std::strtof(t.c_str(), &end);
    return end != t.c_str() && *end == '\0';
}

static inline bool is_binary_indicator_value(float v) {
    return std::fabs(v) < 1e-6f || std::fabs(v - 1.0f) < 1e-6f;
}

static inline bool label_info_ready(const BinaryClassInfo& info) {
    return !info.negative_label.empty() && !info.positive_label.empty();
}

inline float percentile(std::vector<float> values, double q) {
    if (values.empty()) return 0.0f;
    std::sort(values.begin(), values.end());
    double pos = q * static_cast<double>(values.size() - 1);
    size_t lo = static_cast<size_t>(std::floor(pos));
    size_t hi = static_cast<size_t>(std::ceil(pos));
    double w = pos - static_cast<double>(lo);
    return static_cast<float>((1.0 - w) * values[lo] + w * values[hi]);
}

// ---------------------------------------------------------------------------
// Label encoding helpers
// ---------------------------------------------------------------------------

static inline int encode_scalar_label(const std::string& token, BinaryClassInfo& info) {
    float v = 0.0f;
    if (!parse_float_token(token, v)) return 2;
    if (std::fabs(v + 1.0f) < 1e-6f) {
        if (info.negative_label.empty()) info.negative_label = "-1";
        if (info.positive_label.empty()) info.positive_label = "+1";
        return -1;
    }
    if (std::fabs(v) < 1e-6f) {
        if (info.negative_label.empty()) info.negative_label = "0";
        if (info.positive_label.empty()) info.positive_label = "1";
        return -1;
    }
    if (std::fabs(v - 1.0f) < 1e-6f) {
        if (info.negative_label.empty()) info.negative_label = "0";
        if (info.positive_label.empty()) info.positive_label = "1";
        return +1;
    }
    return 2;
}

static inline int encode_text_label(const std::string& token, BinaryClassInfo& info, bool allow_discovery) {
    std::string label = trim(token);
    if (label.empty()) return 2;
    if (!info.negative_label.empty() && label == info.negative_label) return -1;
    if (!info.positive_label.empty() && label == info.positive_label) return +1;
    if (!allow_discovery) return 2;
    if (info.negative_label.empty()) { info.negative_label = label; return -1; }
    if (info.positive_label.empty()) { info.positive_label = label; return +1; }
    return 2;
}

static inline bool parse_one_hot_tail_row(
    const std::vector<std::string>& tokens,
    const std::vector<std::string>& header,
    float features[NUM_FEATURES],
    int& y,
    BinaryClassInfo& info,
    bool allow_discovery
) {
    if (tokens.size() < 6) return false;
    float a = 0.0f, b = 0.0f;
    if (!parse_float_token(tokens[tokens.size() - 2], a) ||
        !parse_float_token(tokens[tokens.size() - 1], b)) return false;
    if (!is_binary_indicator_value(a) || !is_binary_indicator_value(b)) return false;
    int ia = static_cast<int>(std::lround(a));
    int ib = static_cast<int>(std::lround(b));
    if (!((ia == 1 && ib == 0) || (ia == 0 && ib == 1))) return false;

    std::vector<float> num;
    num.reserve(tokens.size());
    for (size_t i = 0; i + 2 < tokens.size(); ++i) {
        float v = 0.0f;
        if (parse_float_token(tokens[i], v)) num.push_back(v);
    }
    if (num.size() < NUM_FEATURES) return false;
    size_t start = num.size() - NUM_FEATURES;
    for (int j = 0; j < NUM_FEATURES; ++j) features[j] = num[start + j];

    if (!label_info_ready(info)) {
        if (!allow_discovery) return false;
        if (header.size() >= 2) {
            info.negative_label = trim(header[header.size() - 2]);
            info.positive_label = trim(header[header.size() - 1]);
        }
        if (info.negative_label.empty()) info.negative_label = "class0";
        if (info.positive_label.empty()) info.positive_label = "class1";
    }
    y = (ia == 1 && ib == 0) ? -1 : +1;
    return true;
}

static inline bool parse_scalar_label_row(
    const std::vector<std::string>& tokens,
    float features[NUM_FEATURES],
    int& y,
    BinaryClassInfo& info,
    bool allow_discovery
) {
    if (tokens.size() < 5) return false;
    std::vector<float> num;
    num.reserve(tokens.size());
    for (size_t i = 0; i + 1 < tokens.size(); ++i) {
        float v = 0.0f;
        if (parse_float_token(tokens[i], v)) num.push_back(v);
    }
    if (num.size() < NUM_FEATURES) return false;
    size_t start = num.size() - NUM_FEATURES;
    for (int j = 0; j < NUM_FEATURES; ++j) features[j] = num[start + j];

    int encoded = encode_scalar_label(tokens.back(), info);
    if (encoded == 2) encoded = encode_text_label(tokens.back(), info, allow_discovery);
    if (encoded == 2) return false;
    y = encoded;
    return true;
}

// ---------------------------------------------------------------------------
// Dataset loading & preprocessing
// ---------------------------------------------------------------------------

inline Dataset load_binary_iris_csv(const std::string& path, BinaryClassInfo& info, bool allow_discovery) {
    std::ifstream fin(path);
    if (!fin) {
        std::cerr << "Failed to open: " << path << std::endl;
        std::exit(EXIT_FAILURE);
    }

    Dataset ds;
    std::string line;
    std::vector<std::string> header;
    bool header_checked = false;
    int raw_rows = 0, kept_rows = 0;

    while (std::getline(fin, line)) {
        if (trim(line).empty()) continue;
        ++raw_rows;
        std::vector<std::string> tokens = split_csv_simple(line);
        if (tokens.empty()) continue;

        float features[NUM_FEATURES]{};
        int y = 0;
        bool parsed = false;

        if (!header_checked) {
            header_checked = true;
            if (parse_one_hot_tail_row(tokens, {}, features, y, info, allow_discovery) ||
                parse_scalar_label_row(tokens, features, y, info, allow_discovery)) {
                parsed = true;
            } else {
                header = tokens;
                continue;
            }
        } else {
            parsed = parse_one_hot_tail_row(tokens, header, features, y, info, allow_discovery) ||
                     parse_scalar_label_row(tokens, features, y, info, allow_discovery);
        }

        if (!parsed) {
            std::cerr << "Could not parse row " << raw_rows << " in " << path << std::endl;
            std::exit(EXIT_FAILURE);
        }
        for (int j = 0; j < NUM_FEATURES; ++j) ds.x.push_back(features[j]);
        ds.y.push_back(y);
        ++kept_rows;
    }

    if (kept_rows == 0) {
        std::cerr << "No valid data rows found in " << path << std::endl;
        std::exit(EXIT_FAILURE);
    }
    if (!label_info_ready(info)) {
        std::cerr << "Could not infer binary class mapping from " << path << std::endl;
        std::exit(EXIT_FAILURE);
    }
    ds.size = kept_rows;
    std::cout << "Loaded " << kept_rows << " samples from " << path << std::endl;
    return ds;
}

inline StandardizationStats fit_standardization(const Dataset& train) {
    StandardizationStats stats;
    for (int j = 0; j < NUM_FEATURES; ++j) {
        double sum = 0.0;
        for (int i = 0; i < train.size; ++i) sum += train.x[i * NUM_FEATURES + j];
        stats.mean[j] = static_cast<float>(sum / train.size);
    }
    for (int j = 0; j < NUM_FEATURES; ++j) {
        double var = 0.0;
        for (int i = 0; i < train.size; ++i) {
            double diff = train.x[i * NUM_FEATURES + j] - stats.mean[j];
            var += diff * diff;
        }
        var /= train.size;
        stats.stddev[j] = static_cast<float>(std::sqrt(var));
        if (stats.stddev[j] < 1e-6f) stats.stddev[j] = 1.0f;
    }
    return stats;
}

inline void apply_standardization(Dataset& ds, const StandardizationStats& stats) {
    for (int i = 0; i < ds.size; ++i)
        for (int j = 0; j < NUM_FEATURES; ++j)
            ds.x[i * NUM_FEATURES + j] = (ds.x[i * NUM_FEATURES + j] - stats.mean[j]) / stats.stddev[j];
}

inline void print_dataset_summary(const Dataset& train, const Dataset& test, const BinaryClassInfo& info) {
    auto count_label = [](const Dataset& ds, int label) {
        return static_cast<int>(std::count(ds.y.begin(), ds.y.end(), label));
    };
    std::cout << "Dataset summary\n"
              << "  Features per sample: " << NUM_FEATURES << "\n"
              << "  Negative class (-1): " << info.negative_label << "\n"
              << "  Positive class (+1): " << info.positive_label << "\n"
              << "  Train samples: " << train.size
              << " (neg=" << count_label(train, -1) << ", pos=" << count_label(train, +1) << ")\n"
              << "  Test  samples: " << test.size
              << " (neg=" << count_label(test, -1) << ", pos=" << count_label(test, +1) << ")\n";
}

inline void print_model_info(int batch_size) {
    size_t params_count = NUM_FEATURES + 1;
    size_t param_bytes  = params_count * sizeof(float);
    size_t activation_bytes = static_cast<size_t>(batch_size) *
        (NUM_FEATURES * sizeof(float) + sizeof(float) + 4 * sizeof(int));
    std::cout << "Model summary\n"
              << "  Model: Binary perceptron\n"
              << "  Input -> Output: 4 -> 1 sign(score)\n"
              << "  Trainable params: " << params_count << " (4 weights + 1 bias)\n"
              << "  Parameter memory: " << (param_bytes / 1024.0) << " KB\n"
              << "  Approx activation memory per batch: " << (activation_bytes / (1024.0 * 1024.0)) << " MB\n";
}

// ---------------------------------------------------------------------------
// Weight serialization (used between gen_acc_results and gen_perf_results)
// ---------------------------------------------------------------------------

inline void save_weights(const PerceptronParams& p, const std::string& path) {
    float h_w[NUM_FEATURES];
    float h_b = 0.0f;
    CHECK_CUDA(cudaMemcpy(h_w, p.d_w, bytes_of(NUM_FEATURES), cudaMemcpyDeviceToHost));
    CHECK_CUDA(cudaMemcpy(&h_b, p.d_b, sizeof(float), cudaMemcpyDeviceToHost));
    FILE* f = fopen(path.c_str(), "wb");
    if (!f) { std::cerr << "Failed to open weights file for writing: " << path << std::endl; std::exit(EXIT_FAILURE); }
    fwrite(h_w, sizeof(float), NUM_FEATURES, f);
    fwrite(&h_b, sizeof(float), 1, f);
    fclose(f);
    std::cout << "Saved weights to " << path << std::endl;
}

inline void load_weights(PerceptronParams& p, const std::string& path) {
    float h_w[NUM_FEATURES];
    float h_b = 0.0f;
    FILE* f = fopen(path.c_str(), "rb");
    if (!f) { std::cerr << "Failed to open weights file: " << path << std::endl; std::exit(EXIT_FAILURE); }
    fread(h_w, sizeof(float), NUM_FEATURES, f);
    fread(&h_b, sizeof(float), 1, f);
    fclose(f);
    CHECK_CUDA(cudaMemcpy(p.d_w, h_w, bytes_of(NUM_FEATURES), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(p.d_b, &h_b, sizeof(float), cudaMemcpyHostToDevice));
    std::cout << "Loaded weights from " << path << std::endl;
}

// ---------------------------------------------------------------------------
// CUDA kernels
// ---------------------------------------------------------------------------

__global__ void perceptron_forward_kernel(
    const float* x, const float* w, const float* b,
    float* scores, int* preds, int batch_size
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= batch_size) return;
    const float* row = x + idx * NUM_FEATURES;
    float score = b[0];
#pragma unroll
    for (int j = 0; j < NUM_FEATURES; ++j) score += row[j] * w[j];
    scores[idx] = score;
    preds[idx]  = (score >= 0.0f) ? +1 : -1;
}

__global__ void perceptron_metric_kernel(
    const float* scores, const int* preds, const int* y,
    float* losses, int* correct, int* errors, int batch_size
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= batch_size) return;
    float margin = static_cast<float>(y[idx]) * scores[idx];
    losses[idx]  = fmaxf(0.0f, -margin);
    correct[idx] = (preds[idx] == y[idx]) ? 1 : 0;
    errors[idx]  = (preds[idx] == y[idx]) ? 0 : 1;
}

__global__ void zero_grad_kernel(float* gw, float* gb, int* mistakes) {
    int idx = threadIdx.x;
    if (idx < NUM_FEATURES) gw[idx] = 0.0f;
    if (idx == 0) { gb[0] = 0.0f; mistakes[0] = 0; }
}

__global__ void accumulate_misclassified_kernel(
    const float* x, const int* y, const int* errors,
    float* gw, float* gb, int* mistakes, int batch_size
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= batch_size || errors[idx] == 0) return;
    const float* row = x + idx * NUM_FEATURES;
    float yi = static_cast<float>(y[idx]);
    for (int j = 0; j < NUM_FEATURES; ++j) atomicAdd(&gw[j], yi * row[j]);
    atomicAdd(&gb[0], yi);
    atomicAdd(mistakes, 1);
}

__global__ void apply_update_kernel(
    float* w, float* b, const float* gw, const float* gb, const int* mistakes, float lr
) {
    int idx = threadIdx.x;
    int m = mistakes[0];
    if (m <= 0) return;
    float scale = lr / static_cast<float>(m);
    if (idx < NUM_FEATURES) w[idx] += scale * gw[idx];
    if (idx == 0) b[0] += scale * gb[0];
}

// ---------------------------------------------------------------------------
// GPU memory management
// ---------------------------------------------------------------------------

inline void init_params(PerceptronParams& p) {
    std::vector<float> h_w(NUM_FEATURES, 0.0f);
    std::vector<float> h_b(1, 0.0f);
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&p.d_w),        bytes_of(NUM_FEATURES)));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&p.d_b),        sizeof(float)));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&p.d_gw),       bytes_of(NUM_FEATURES)));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&p.d_gb),       sizeof(float)));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&p.d_mistakes),  sizeof(int)));
    CHECK_CUDA(cudaMemcpy(p.d_w, h_w.data(), bytes_of(NUM_FEATURES), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(p.d_b, h_b.data(), sizeof(float),          cudaMemcpyHostToDevice));
}

inline void free_params(PerceptronParams& p) {
    cudaFree(p.d_w); cudaFree(p.d_b);
    cudaFree(p.d_gw); cudaFree(p.d_gb);
    cudaFree(p.d_mistakes);
}

inline void alloc_batch_buffers(BatchBuffers& b, int max_batch) {
    b.max_batch = max_batch;
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&b.d_x),       bytes_of(static_cast<size_t>(max_batch) * NUM_FEATURES)));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&b.d_y),       sizeof(int) * max_batch));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&b.d_scores),  bytes_of(max_batch)));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&b.d_preds),   sizeof(int) * max_batch));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&b.d_losses),  bytes_of(max_batch)));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&b.d_correct), sizeof(int) * max_batch));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&b.d_errors),  sizeof(int) * max_batch));
}

inline void free_batch_buffers(BatchBuffers& b) {
    cudaFree(b.d_x); cudaFree(b.d_y); cudaFree(b.d_scores);
    cudaFree(b.d_preds); cudaFree(b.d_losses);
    cudaFree(b.d_correct); cudaFree(b.d_errors);
}

// ---------------------------------------------------------------------------
// Batch copy helpers
// ---------------------------------------------------------------------------

inline void copy_batch_by_index(
    const Dataset& ds, const std::vector<int>& indices,
    int start, int batch_size, float* h_x, int* h_y
) {
    for (int i = 0; i < batch_size; ++i) {
        int src = indices[start + i];
        for (int j = 0; j < NUM_FEATURES; ++j)
            h_x[i * NUM_FEATURES + j] = ds.x[src * NUM_FEATURES + j];
        h_y[i] = ds.y[src];
    }
}

inline void copy_contiguous_batch(
    const Dataset& ds, int start, int batch_size, float* h_x, int* h_y
) {
    for (int i = 0; i < batch_size; ++i) {
        int src = start + i;
        for (int j = 0; j < NUM_FEATURES; ++j)
            h_x[i * NUM_FEATURES + j] = ds.x[src * NUM_FEATURES + j];
        h_y[i] = ds.y[src];
    }
}

// ---------------------------------------------------------------------------
// Compute wrappers (thin wrappers around kernels)
// ---------------------------------------------------------------------------

inline void forward_pass(const PerceptronParams& params, BatchBuffers& buffers, int batch_size) {
    int threads = 128, blocks = (batch_size + threads - 1) / threads;
    perceptron_forward_kernel<<<blocks, threads>>>(
        buffers.d_x, params.d_w, params.d_b, buffers.d_scores, buffers.d_preds, batch_size);
    CHECK_CUDA(cudaGetLastError());
}

inline void metric_pass(BatchBuffers& buffers, int batch_size) {
    int threads = 128, blocks = (batch_size + threads - 1) / threads;
    perceptron_metric_kernel<<<blocks, threads>>>(
        buffers.d_scores, buffers.d_preds, buffers.d_y,
        buffers.d_losses, buffers.d_correct, buffers.d_errors, batch_size);
    CHECK_CUDA(cudaGetLastError());
}

inline void backward_pass(PerceptronParams& params, BatchBuffers& buffers, int batch_size) {
    zero_grad_kernel<<<1, 32>>>(params.d_gw, params.d_gb, params.d_mistakes);
    CHECK_CUDA(cudaGetLastError());
    int threads = 128, blocks = (batch_size + threads - 1) / threads;
    accumulate_misclassified_kernel<<<blocks, threads>>>(
        buffers.d_x, buffers.d_y, buffers.d_errors,
        params.d_gw, params.d_gb, params.d_mistakes, batch_size);
    CHECK_CUDA(cudaGetLastError());
}

inline void update_params(PerceptronParams& params, float lr) {
    apply_update_kernel<<<1, 32>>>(params.d_w, params.d_b, params.d_gw, params.d_gb, params.d_mistakes, lr);
    CHECK_CUDA(cudaGetLastError());
}

// ---------------------------------------------------------------------------
// evaluate() — batched inference over a full dataset
// ---------------------------------------------------------------------------

inline EvalMetrics evaluate(
    const Dataset& ds, PerceptronParams& params, BatchBuffers& buffers, int batch_size
) {
    float* h_batch_x = nullptr;
    int*   h_batch_y = nullptr;
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_batch_x),
        bytes_of(static_cast<size_t>(batch_size) * NUM_FEATURES)));
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_batch_y), sizeof(int) * batch_size));

    std::vector<float> h_losses(batch_size);
    std::vector<int>   h_preds(batch_size);
    std::vector<float> batch_ms;
    batch_ms.reserve((ds.size + batch_size - 1) / batch_size);

    cudaEvent_t ev0, ev1;
    CHECK_CUDA(cudaEventCreate(&ev0));
    CHECK_CUDA(cudaEventCreate(&ev1));

    double total_loss = 0.0;
    int correct = 0, seen = 0;
    int tp = 0, tn = 0, fp = 0, fn = 0;
    double total_infer_ms = 0.0;

    int num_batches = (ds.size + batch_size - 1) / batch_size;
    for (int batch = 0; batch < num_batches; ++batch) {
        int start = batch * batch_size;
        int B = std::min(batch_size, ds.size - start);

        copy_contiguous_batch(ds, start, B, h_batch_x, h_batch_y);
        CHECK_CUDA(cudaMemcpy(buffers.d_x, h_batch_x,
            bytes_of(static_cast<size_t>(B) * NUM_FEATURES), cudaMemcpyHostToDevice));
        CHECK_CUDA(cudaMemcpy(buffers.d_y, h_batch_y, sizeof(int) * B, cudaMemcpyHostToDevice));

        float ms = 0.0f;
        CHECK_CUDA(cudaEventRecord(ev0));
        forward_pass(params, buffers, B);
        metric_pass(buffers, B);
        CHECK_CUDA(cudaEventRecord(ev1));
        CHECK_CUDA(cudaEventSynchronize(ev1));
        CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));

        batch_ms.push_back(ms);
        total_infer_ms += ms;

        CHECK_CUDA(cudaMemcpy(h_losses.data(), buffers.d_losses, bytes_of(B), cudaMemcpyDeviceToHost));
        CHECK_CUDA(cudaMemcpy(h_preds.data(), buffers.d_preds, sizeof(int) * B, cudaMemcpyDeviceToHost));

        for (int i = 0; i < B; ++i) {
            total_loss += h_losses[i];
            correct += (h_preds[i] == h_batch_y[i]) ? 1 : 0;
            if      (h_preds[i] == +1 && h_batch_y[i] == +1) ++tp;
            else if (h_preds[i] == -1 && h_batch_y[i] == -1) ++tn;
            else if (h_preds[i] == +1 && h_batch_y[i] == -1) ++fp;
            else if (h_preds[i] == -1 && h_batch_y[i] == +1) ++fn;
        }
        seen += B;
    }

    EvalMetrics m;
    m.loss      = total_loss / seen;
    m.accuracy  = static_cast<double>(correct) / seen;
    m.precision = (tp + fp) ? static_cast<double>(tp) / (tp + fp) : 0.0;
    m.recall    = (tp + fn) ? static_cast<double>(tp) / (tp + fn) : 0.0;
    m.f1        = (m.precision + m.recall) ?
                  (2.0 * m.precision * m.recall / (m.precision + m.recall)) : 0.0;
    m.tp = tp; m.tn = tn; m.fp = fp; m.fn = fn;
    m.total_infer_ms            = total_infer_ms;
    m.avg_batch_ms              = total_infer_ms / num_batches;
    m.avg_sample_ms             = total_infer_ms / seen;
    m.throughput_samples_per_sec = 1000.0 * seen / total_infer_ms;
    m.p50_batch_ms = percentile(batch_ms, 0.50);
    m.p95_batch_ms = percentile(batch_ms, 0.95);

    CHECK_CUDA(cudaEventDestroy(ev0));
    CHECK_CUDA(cudaEventDestroy(ev1));
    CHECK_CUDA(cudaFreeHost(h_batch_x));
    CHECK_CUDA(cudaFreeHost(h_batch_y));
    return m;
}

// ---------------------------------------------------------------------------
// benchmark_single_sample_latency()
// ---------------------------------------------------------------------------

inline LatencyMetrics benchmark_single_sample_latency(
    const Dataset& ds, PerceptronParams& params, BatchBuffers& buffers,
    int warmup = 20, int reps = 200
) {
    float* h_sample = nullptr;
    int*   h_label  = nullptr;
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_sample), bytes_of(NUM_FEATURES)));
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_label),  sizeof(int)));

    for (int j = 0; j < NUM_FEATURES; ++j) h_sample[j] = ds.x[j];
    h_label[0] = ds.y[0];

    CHECK_CUDA(cudaMemcpy(buffers.d_x, h_sample, bytes_of(NUM_FEATURES), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(buffers.d_y, h_label,  sizeof(int),            cudaMemcpyHostToDevice));

    cudaEvent_t ev0, ev1;
    CHECK_CUDA(cudaEventCreate(&ev0));
    CHECK_CUDA(cudaEventCreate(&ev1));

    for (int i = 0; i < warmup; ++i) {
        forward_pass(params, buffers, 1);
        metric_pass(buffers, 1);
    }
    CHECK_CUDA(cudaDeviceSynchronize());

    std::vector<float> samples_ms;
    samples_ms.reserve(reps);
    for (int i = 0; i < reps; ++i) {
        float ms = 0.0f;
        CHECK_CUDA(cudaEventRecord(ev0));
        forward_pass(params, buffers, 1);
        metric_pass(buffers, 1);
        CHECK_CUDA(cudaEventRecord(ev1));
        CHECK_CUDA(cudaEventSynchronize(ev1));
        CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
        samples_ms.push_back(ms);
    }

    LatencyMetrics m;
    m.mean_ms = std::accumulate(samples_ms.begin(), samples_ms.end(), 0.0) / samples_ms.size();
    m.min_ms  = *std::min_element(samples_ms.begin(), samples_ms.end());
    m.max_ms  = *std::max_element(samples_ms.begin(), samples_ms.end());
    m.p50_ms  = percentile(samples_ms, 0.50);
    m.p95_ms  = percentile(samples_ms, 0.95);

    CHECK_CUDA(cudaEventDestroy(ev0));
    CHECK_CUDA(cudaEventDestroy(ev1));
    CHECK_CUDA(cudaFreeHost(h_sample));
    CHECK_CUDA(cudaFreeHost(h_label));
    return m;
}

// ---------------------------------------------------------------------------
// train() — full training loop, returns PhaseTiming + fills final_test_metrics
// ---------------------------------------------------------------------------

inline PhaseTiming train(
    const Dataset& train_ds,
    const Dataset& test_ds,
    PerceptronParams& params,
    BatchBuffers& buffers,
    int epochs,
    int batch_size,
    float lr,
    EvalMetrics& final_test_metrics
) {
    float* h_batch_x = nullptr;
    int*   h_batch_y = nullptr;
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_batch_x),
        bytes_of(static_cast<size_t>(batch_size) * NUM_FEATURES)));
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_batch_y), sizeof(int) * batch_size));

    std::vector<float> h_losses(batch_size);
    std::vector<int>   h_preds(batch_size);
    std::vector<int>   order(train_ds.size);
    std::iota(order.begin(), order.end(), 0);
    std::mt19937 rng(42);

    cudaEvent_t ev0, ev1;
    CHECK_CUDA(cudaEventCreate(&ev0));
    CHECK_CUDA(cudaEventCreate(&ev1));

    PhaseTiming timing;
    auto wall_begin = std::chrono::high_resolution_clock::now();

    for (int epoch = 0; epoch < epochs; ++epoch) {
        std::shuffle(order.begin(), order.end(), rng);
        double epoch_loss = 0.0;
        int correct = 0, seen = 0;
        double epoch_ms = 0.0;

        int num_batches = (train_ds.size + batch_size - 1) / batch_size;
        for (int batch = 0; batch < num_batches; ++batch) {
            int start = batch * batch_size;
            int B = std::min(batch_size, train_ds.size - start);

            copy_batch_by_index(train_ds, order, start, B, h_batch_x, h_batch_y);

            float ms = 0.0f;
            // H2D
            CHECK_CUDA(cudaEventRecord(ev0));
            CHECK_CUDA(cudaMemcpy(buffers.d_x, h_batch_x,
                bytes_of(static_cast<size_t>(B) * NUM_FEATURES), cudaMemcpyHostToDevice));
            CHECK_CUDA(cudaMemcpy(buffers.d_y, h_batch_y, sizeof(int) * B, cudaMemcpyHostToDevice));
            CHECK_CUDA(cudaEventRecord(ev1));
            CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.h2d_ms += ms; epoch_ms += ms;

            // Forward
            CHECK_CUDA(cudaEventRecord(ev0));
            forward_pass(params, buffers, B);
            CHECK_CUDA(cudaEventRecord(ev1));
            CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.forward_ms += ms; epoch_ms += ms;

            // Metric
            CHECK_CUDA(cudaEventRecord(ev0));
            metric_pass(buffers, B);
            CHECK_CUDA(cudaEventRecord(ev1));
            CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.metric_ms += ms; epoch_ms += ms;

            CHECK_CUDA(cudaMemcpy(h_losses.data(), buffers.d_losses, bytes_of(B), cudaMemcpyDeviceToHost));
            CHECK_CUDA(cudaMemcpy(h_preds.data(), buffers.d_preds, sizeof(int) * B, cudaMemcpyDeviceToHost));
            for (int i = 0; i < B; ++i) {
                epoch_loss += h_losses[i];
                correct += (h_preds[i] == h_batch_y[i]) ? 1 : 0;
            }
            seen += B;

            // Backward
            CHECK_CUDA(cudaEventRecord(ev0));
            backward_pass(params, buffers, B);
            CHECK_CUDA(cudaEventRecord(ev1));
            CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.backward_ms += ms; epoch_ms += ms;

            // Update
            CHECK_CUDA(cudaEventRecord(ev0));
            update_params(params, lr);
            CHECK_CUDA(cudaEventRecord(ev1));
            CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.update_ms += ms; epoch_ms += ms;
        }

        std::cout << std::fixed << std::setprecision(4)
            << "Epoch " << (epoch + 1) << "/" << epochs
            << " | train_loss=" << (epoch_loss / seen)
            << " | train_acc=" << (100.0 * correct / seen) << "%"
            << " | epoch_gpu_ms=" << epoch_ms
            << " | epoch_throughput=" << (1000.0 * seen / epoch_ms) << " samples/s\n";

        final_test_metrics = evaluate(test_ds, params, buffers, batch_size);
        std::cout << "  test_loss=" << final_test_metrics.loss
            << " | test_acc=" << (100.0 * final_test_metrics.accuracy) << "%"
            << " | infer_avg_batch_ms=" << final_test_metrics.avg_batch_ms << "\n";
    }

    auto wall_end = std::chrono::high_resolution_clock::now();
    timing.total_wall_ms =
        std::chrono::duration<double, std::milli>(wall_end - wall_begin).count();

    CHECK_CUDA(cudaEventDestroy(ev0));
    CHECK_CUDA(cudaEventDestroy(ev1));
    CHECK_CUDA(cudaFreeHost(h_batch_x));
    CHECK_CUDA(cudaFreeHost(h_batch_y));
    return timing;
}

// ---------------------------------------------------------------------------
// Utility: print learned weights
// ---------------------------------------------------------------------------

inline void print_learned_parameters(PerceptronParams& params) {
    float h_w[NUM_FEATURES];
    float h_b = 0.0f;
    CHECK_CUDA(cudaMemcpy(h_w, params.d_w, bytes_of(NUM_FEATURES), cudaMemcpyDeviceToHost));
    CHECK_CUDA(cudaMemcpy(&h_b, params.d_b, sizeof(float), cudaMemcpyDeviceToHost));
    static const char* names[NUM_FEATURES] = {
        "sepal_length", "sepal_width", "petal_length", "petal_width"
    };
    std::cout << "\n================ Learned Perceptron Parameters ================\n";
    for (int j = 0; j < NUM_FEATURES; ++j)
        std::cout << std::setw(16) << names[j] << " : " << h_w[j] << "\n";
    std::cout << std::setw(16) << "bias" << " : " << h_b << "\n";
}
