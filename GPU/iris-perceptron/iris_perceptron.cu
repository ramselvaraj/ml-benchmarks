#include <cuda_runtime.h>

#include <algorithm>
#include <cctype>
#include <chrono>
#include <cmath>
#include <cstddef>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <numeric>
#include <random>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>

#define CHECK_CUDA(call)                                                       \
    do {                                                                       \
        cudaError_t err__ = (call);                                            \
        if (err__ != cudaSuccess) {                                            \
            std::cerr << "CUDA error at " << __FILE__ << ":" << __LINE__    \
                      << " -> " << cudaGetErrorString(err__) << std::endl;    \
            std::exit(EXIT_FAILURE);                                           \
        }                                                                      \
    } while (0)

constexpr int NUM_FEATURES = 4;

struct Dataset {
    std::vector<float> x;  // N x 4
    std::vector<int> y;    // N, encoded as {-1, +1}
    int size = 0;
};

struct BinaryClassInfo {
    std::string negative_label;
    std::string positive_label;
    int discarded_other_classes = 0;
};

struct StandardizationStats {
    float mean[NUM_FEATURES]{};
    float stddev[NUM_FEATURES]{};
};

struct PhaseTiming {
    double h2d_ms = 0.0;
    double forward_ms = 0.0;
    double metric_ms = 0.0;
    double backward_ms = 0.0;
    double update_ms = 0.0;
    double total_wall_ms = 0.0;
};

struct EvalMetrics {
    double loss = 0.0;
    double accuracy = 0.0;
    double precision = 0.0;
    double recall = 0.0;
    double f1 = 0.0;
    int tp = 0;
    int tn = 0;
    int fp = 0;
    int fn = 0;
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

struct PerceptronParams {
    float* d_w = nullptr;      // [4]
    float* d_b = nullptr;      // [1]
    float* d_gw = nullptr;     // [4]
    float* d_gb = nullptr;     // [1]
    int* d_mistakes = nullptr; // [1]
};

struct BatchBuffers {
    int max_batch = 0;
    float* d_x = nullptr;      // [B,4]
    int* d_y = nullptr;        // [B]
    float* d_scores = nullptr; // [B]
    int* d_preds = nullptr;    // [B]
    float* d_losses = nullptr; // [B]
    int* d_correct = nullptr;  // [B]
    int* d_errors = nullptr;   // [B]
};

static inline size_t bytes_of(size_t n) {
    return n * sizeof(float);
}

static inline std::string trim(const std::string& s) {
    size_t lo = 0;
    while (lo < s.size() && std::isspace(static_cast<unsigned char>(s[lo]))) {
        ++lo;
    }
    size_t hi = s.size();
    while (hi > lo && std::isspace(static_cast<unsigned char>(s[hi - 1]))) {
        --hi;
    }
    if (hi > lo && s[lo] == '"' && s[hi - 1] == '"') {
        ++lo;
        --hi;
    }
    return s.substr(lo, hi - lo);
}

static bool is_numeric_token(const std::string& token) {
    std::string t = trim(token);
    if (t.empty()) return false;
    char* end = nullptr;
    std::strtof(t.c_str(), &end);
    return end != t.c_str() && *end == '\0';
}

static std::vector<std::string> split_csv_simple(const std::string& line) {
    std::vector<std::string> out;
    std::stringstream ss(line);
    std::string token;
    while (std::getline(ss, token, ',')) {
        out.push_back(trim(token));
    }
    return out;
}

float percentile(std::vector<float> values, double q) {
    if (values.empty()) return 0.0f;
    std::sort(values.begin(), values.end());
    double pos = q * static_cast<double>(values.size() - 1);
    size_t lo = static_cast<size_t>(std::floor(pos));
    size_t hi = static_cast<size_t>(std::ceil(pos));
    double w = pos - static_cast<double>(lo);
    return static_cast<float>((1.0 - w) * values[lo] + w * values[hi]);
}

Dataset load_iris_binary_csv(const std::string& path, BinaryClassInfo& info) {
    std::ifstream fin(path);
    if (!fin) {
        std::cerr << "Failed to open: " << path << std::endl;
        std::exit(EXIT_FAILURE);
    }

    Dataset ds;
    std::vector<std::string> class_order;
    std::string line;
    int total_rows = 0;
    int kept_rows = 0;

    while (std::getline(fin, line)) {
        if (line.empty()) continue;
        std::vector<std::string> tokens = split_csv_simple(line);
        if (tokens.size() < 5) continue;

        std::string label;
        float features[NUM_FEATURES]{};
        bool valid_row = false;

        std::vector<float> numeric_before_label;
        for (size_t i = 0; i + 1 < tokens.size(); ++i) {
            if (is_numeric_token(tokens[i])) {
                numeric_before_label.push_back(std::strtof(tokens[i].c_str(), nullptr));
            }
        }
        if (numeric_before_label.size() >= 4) {
            size_t start = numeric_before_label.size() - 4;
            for (int j = 0; j < NUM_FEATURES; ++j) {
                features[j] = numeric_before_label[start + j];
            }
            label = trim(tokens.back());
            valid_row = true;
        }

        if (!valid_row) continue;
        ++total_rows;

        auto it = std::find(class_order.begin(), class_order.end(), label);
        if (it == class_order.end()) {
            class_order.push_back(label);
        }

        if (class_order.size() > 2 && label != class_order[0] && label != class_order[1]) {
            ++info.discarded_other_classes;
            continue;
        }

        if (class_order.size() < 2 && label != class_order[0]) {
            // unreachable in practice because the new label was already pushed above,
            // but kept here to make the logic obvious.
        }

        int y = (label == class_order[0]) ? -1 : +1;
        for (int j = 0; j < NUM_FEATURES; ++j) {
            ds.x.push_back(features[j]);
        }
        ds.y.push_back(y);
        ++kept_rows;
    }

    if (class_order.size() < 2 || kept_rows == 0) {
        std::cerr << "Could not find at least two valid Iris classes in " << path << std::endl;
        std::exit(EXIT_FAILURE);
    }

    info.negative_label = class_order[0];
    info.positive_label = class_order[1];
    ds.size = kept_rows;

    std::cout << "Loaded " << total_rows << " valid rows from " << path << std::endl;
    std::cout << "Keeping two classes for perceptron: [" << info.negative_label
              << "] -> -1, [" << info.positive_label << "] -> +1" << std::endl;
    if (info.discarded_other_classes > 0) {
        std::cout << "Discarded rows from other classes: " << info.discarded_other_classes << std::endl;
    }
    return ds;
}

void split_stratified(const Dataset& full, Dataset& train, Dataset& test, float train_ratio = 0.8f, int seed = 42) {
    std::vector<int> neg_idx;
    std::vector<int> pos_idx;
    neg_idx.reserve(full.size);
    pos_idx.reserve(full.size);

    for (int i = 0; i < full.size; ++i) {
        if (full.y[i] == -1) neg_idx.push_back(i);
        else pos_idx.push_back(i);
    }

    std::mt19937 rng(seed);
    std::shuffle(neg_idx.begin(), neg_idx.end(), rng);
    std::shuffle(pos_idx.begin(), pos_idx.end(), rng);

    auto append_subset = [&](const std::vector<int>& idx, Dataset& dst, int count) {
        for (int i = 0; i < count; ++i) {
            int src = idx[i];
            for (int j = 0; j < NUM_FEATURES; ++j) {
                dst.x.push_back(full.x[src * NUM_FEATURES + j]);
            }
            dst.y.push_back(full.y[src]);
        }
    };

    int neg_train = static_cast<int>(std::round(train_ratio * neg_idx.size()));
    int pos_train = static_cast<int>(std::round(train_ratio * pos_idx.size()));

    neg_train = std::max(1, std::min(neg_train, static_cast<int>(neg_idx.size()) - 1));
    pos_train = std::max(1, std::min(pos_train, static_cast<int>(pos_idx.size()) - 1));

    append_subset(neg_idx, train, neg_train);
    append_subset(pos_idx, train, pos_train);
    append_subset(std::vector<int>(neg_idx.begin() + neg_train, neg_idx.end()), test,
                  static_cast<int>(neg_idx.size()) - neg_train);
    append_subset(std::vector<int>(pos_idx.begin() + pos_train, pos_idx.end()), test,
                  static_cast<int>(pos_idx.size()) - pos_train);

    train.size = static_cast<int>(train.y.size());
    test.size = static_cast<int>(test.y.size());
}

StandardizationStats fit_standardization(const Dataset& train) {
    StandardizationStats stats;
    for (int j = 0; j < NUM_FEATURES; ++j) {
        double sum = 0.0;
        for (int i = 0; i < train.size; ++i) {
            sum += train.x[i * NUM_FEATURES + j];
        }
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

void apply_standardization(Dataset& ds, const StandardizationStats& stats) {
    for (int i = 0; i < ds.size; ++i) {
        for (int j = 0; j < NUM_FEATURES; ++j) {
            ds.x[i * NUM_FEATURES + j] =
                (ds.x[i * NUM_FEATURES + j] - stats.mean[j]) / stats.stddev[j];
        }
    }
}

void print_dataset_summary(const Dataset& train, const Dataset& test, const BinaryClassInfo& info) {
    auto count_label = [](const Dataset& ds, int label) {
        return static_cast<int>(std::count(ds.y.begin(), ds.y.end(), label));
    };

    std::cout << "Dataset summary" << std::endl;
    std::cout << "  Features per sample: " << NUM_FEATURES << std::endl;
    std::cout << "  Negative class (-1): " << info.negative_label << std::endl;
    std::cout << "  Positive class (+1): " << info.positive_label << std::endl;
    std::cout << "  Train samples: " << train.size
              << " (neg=" << count_label(train, -1)
              << ", pos=" << count_label(train, +1) << ")" << std::endl;
    std::cout << "  Test samples:  " << test.size
              << " (neg=" << count_label(test, -1)
              << ", pos=" << count_label(test, +1) << ")" << std::endl;
}

void print_model_info(int batch_size) {
    size_t params_count = NUM_FEATURES + 1;
    size_t param_bytes = params_count * sizeof(float);
    size_t activation_bytes =
        static_cast<size_t>(batch_size) * (NUM_FEATURES * sizeof(float) + sizeof(float) + 4 * sizeof(int));

    std::cout << "Model summary" << std::endl;
    std::cout << "  Model: Binary perceptron" << std::endl;
    std::cout << "  Input -> Output: 4 -> 1 sign(score)" << std::endl;
    std::cout << "  Trainable params: " << params_count << " (4 weights + 1 bias)" << std::endl;
    std::cout << "  Parameter memory: " << (param_bytes / 1024.0) << " KB" << std::endl;
    std::cout << "  Approx activation memory per batch: "
              << (activation_bytes / (1024.0 * 1024.0)) << " MB" << std::endl;
}

__global__ void perceptron_forward_kernel(
    const float* x,
    const float* w,
    const float* b,
    float* scores,
    int* preds,
    int batch_size
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= batch_size) return;

    const float* row = x + idx * NUM_FEATURES;
    float score = b[0];
    #pragma unroll
    for (int j = 0; j < NUM_FEATURES; ++j) {
        score += row[j] * w[j];
    }
    scores[idx] = score;
    preds[idx] = (score >= 0.0f) ? +1 : -1;
}

__global__ void perceptron_metric_kernel(
    const float* scores,
    const int* preds,
    const int* y,
    float* losses,
    int* correct,
    int* errors,
    int batch_size
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= batch_size) return;

    float margin = static_cast<float>(y[idx]) * scores[idx];
    losses[idx] = fmaxf(0.0f, -margin);
    correct[idx] = (preds[idx] == y[idx]) ? 1 : 0;
    errors[idx] = (preds[idx] == y[idx]) ? 0 : 1;
}

__global__ void zero_grad_kernel(float* gw, float* gb, int* mistakes) {
    int idx = threadIdx.x;
    if (idx < NUM_FEATURES) {
        gw[idx] = 0.0f;
    }
    if (idx == 0) {
        gb[0] = 0.0f;
        mistakes[0] = 0;
    }
}

__global__ void accumulate_misclassified_kernel(
    const float* x,
    const int* y,
    const int* errors,
    float* gw,
    float* gb,
    int* mistakes,
    int batch_size
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= batch_size) return;
    if (errors[idx] == 0) return;

    const float* row = x + idx * NUM_FEATURES;
    float yi = static_cast<float>(y[idx]);
    for (int j = 0; j < NUM_FEATURES; ++j) {
        atomicAdd(&gw[j], yi * row[j]);
    }
    atomicAdd(&gb[0], yi);
    atomicAdd(mistakes, 1);
}

__global__ void apply_update_kernel(float* w, float* b, const float* gw, const float* gb, const int* mistakes, float lr) {
    int idx = threadIdx.x;
    int m = mistakes[0];
    if (m <= 0) return;

    float scale = lr / static_cast<float>(m);
    if (idx < NUM_FEATURES) {
        w[idx] += scale * gw[idx];
    }
    if (idx == 0) {
        b[0] += scale * gb[0];
    }
}

void init_params(PerceptronParams& p) {
    std::vector<float> h_w(NUM_FEATURES, 0.0f);
    std::vector<float> h_b(1, 0.0f);

    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&p.d_w), bytes_of(NUM_FEATURES)));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&p.d_b), sizeof(float)));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&p.d_gw), bytes_of(NUM_FEATURES)));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&p.d_gb), sizeof(float)));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&p.d_mistakes), sizeof(int)));

    CHECK_CUDA(cudaMemcpy(p.d_w, h_w.data(), bytes_of(NUM_FEATURES), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(p.d_b, h_b.data(), sizeof(float), cudaMemcpyHostToDevice));
}

void free_params(PerceptronParams& p) {
    cudaFree(p.d_w);
    cudaFree(p.d_b);
    cudaFree(p.d_gw);
    cudaFree(p.d_gb);
    cudaFree(p.d_mistakes);
}

void alloc_batch_buffers(BatchBuffers& b, int max_batch) {
    b.max_batch = max_batch;
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&b.d_x), bytes_of(static_cast<size_t>(max_batch) * NUM_FEATURES)));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&b.d_y), sizeof(int) * max_batch));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&b.d_scores), bytes_of(max_batch)));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&b.d_preds), sizeof(int) * max_batch));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&b.d_losses), bytes_of(max_batch)));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&b.d_correct), sizeof(int) * max_batch));
    CHECK_CUDA(cudaMalloc(reinterpret_cast<void**>(&b.d_errors), sizeof(int) * max_batch));
}

void free_batch_buffers(BatchBuffers& b) {
    cudaFree(b.d_x);
    cudaFree(b.d_y);
    cudaFree(b.d_scores);
    cudaFree(b.d_preds);
    cudaFree(b.d_losses);
    cudaFree(b.d_correct);
    cudaFree(b.d_errors);
}

void copy_batch_by_index(
    const Dataset& ds,
    const std::vector<int>& indices,
    int start,
    int batch_size,
    float* h_x,
    int* h_y
) {
    for (int i = 0; i < batch_size; ++i) {
        int src = indices[start + i];
        for (int j = 0; j < NUM_FEATURES; ++j) {
            h_x[i * NUM_FEATURES + j] = ds.x[src * NUM_FEATURES + j];
        }
        h_y[i] = ds.y[src];
    }
}

void copy_contiguous_batch(
    const Dataset& ds,
    int start,
    int batch_size,
    float* h_x,
    int* h_y
) {
    for (int i = 0; i < batch_size; ++i) {
        int src = start + i;
        for (int j = 0; j < NUM_FEATURES; ++j) {
            h_x[i * NUM_FEATURES + j] = ds.x[src * NUM_FEATURES + j];
        }
        h_y[i] = ds.y[src];
    }
}

void forward_pass(const PerceptronParams& params, BatchBuffers& buffers, int batch_size) {
    int threads = 128;
    int blocks = (batch_size + threads - 1) / threads;
    perceptron_forward_kernel<<<blocks, threads>>>(
        buffers.d_x, params.d_w, params.d_b, buffers.d_scores, buffers.d_preds, batch_size);
    CHECK_CUDA(cudaGetLastError());
}

void metric_pass(BatchBuffers& buffers, int batch_size) {
    int threads = 128;
    int blocks = (batch_size + threads - 1) / threads;
    perceptron_metric_kernel<<<blocks, threads>>>(
        buffers.d_scores, buffers.d_preds, buffers.d_y,
        buffers.d_losses, buffers.d_correct, buffers.d_errors, batch_size);
    CHECK_CUDA(cudaGetLastError());
}

void backward_pass(PerceptronParams& params, BatchBuffers& buffers, int batch_size) {
    zero_grad_kernel<<<1, 32>>>(params.d_gw, params.d_gb, params.d_mistakes);
    CHECK_CUDA(cudaGetLastError());

    int threads = 128;
    int blocks = (batch_size + threads - 1) / threads;
    accumulate_misclassified_kernel<<<blocks, threads>>>(
        buffers.d_x, buffers.d_y, buffers.d_errors,
        params.d_gw, params.d_gb, params.d_mistakes, batch_size);
    CHECK_CUDA(cudaGetLastError());
}

void update_params(PerceptronParams& params, float lr) {
    apply_update_kernel<<<1, 32>>>(params.d_w, params.d_b, params.d_gw, params.d_gb, params.d_mistakes, lr);
    CHECK_CUDA(cudaGetLastError());
}

EvalMetrics evaluate(const Dataset& ds, PerceptronParams& params, BatchBuffers& buffers, int batch_size) {
    float* h_batch_x = nullptr;
    int* h_batch_y = nullptr;
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_batch_x), bytes_of(static_cast<size_t>(batch_size) * NUM_FEATURES)));
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_batch_y), sizeof(int) * batch_size));

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
    int tp = 0, tn = 0, fp = 0, fn = 0;
    double total_infer_ms = 0.0;

    int num_batches = (ds.size + batch_size - 1) / batch_size;
    for (int batch = 0; batch < num_batches; ++batch) {
        int start = batch * batch_size;
        int B = std::min(batch_size, ds.size - start);

        copy_contiguous_batch(ds, start, B, h_batch_x, h_batch_y);
        CHECK_CUDA(cudaMemcpy(buffers.d_x, h_batch_x, bytes_of(static_cast<size_t>(B) * NUM_FEATURES), cudaMemcpyHostToDevice));
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
            if (h_preds[i] == +1 && h_batch_y[i] == +1) ++tp;
            else if (h_preds[i] == -1 && h_batch_y[i] == -1) ++tn;
            else if (h_preds[i] == +1 && h_batch_y[i] == -1) ++fp;
            else if (h_preds[i] == -1 && h_batch_y[i] == +1) ++fn;
        }
        seen += B;
    }

    EvalMetrics m;
    m.loss = total_loss / seen;
    m.accuracy = static_cast<double>(correct) / seen;
    m.precision = (tp + fp) ? static_cast<double>(tp) / (tp + fp) : 0.0;
    m.recall = (tp + fn) ? static_cast<double>(tp) / (tp + fn) : 0.0;
    m.f1 = (m.precision + m.recall) ? (2.0 * m.precision * m.recall / (m.precision + m.recall)) : 0.0;
    m.tp = tp;
    m.tn = tn;
    m.fp = fp;
    m.fn = fn;
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
    PerceptronParams& params,
    BatchBuffers& buffers,
    int warmup = 20,
    int reps = 200
) {
    float* h_img = nullptr;
    int* h_lbl = nullptr;
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_img), bytes_of(NUM_FEATURES)));
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_lbl), sizeof(int)));

    for (int j = 0; j < NUM_FEATURES; ++j) {
        h_img[j] = test_ds.x[j];
    }
    h_lbl[0] = test_ds.y[0];

    CHECK_CUDA(cudaMemcpy(buffers.d_x, h_img, bytes_of(NUM_FEATURES), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(buffers.d_y, h_lbl, sizeof(int), cudaMemcpyHostToDevice));

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

PhaseTiming train(
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
    int* h_batch_y = nullptr;
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_batch_x), bytes_of(static_cast<size_t>(batch_size) * NUM_FEATURES)));
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_batch_y), sizeof(int) * batch_size));

    std::vector<float> h_losses(batch_size);
    std::vector<int> h_preds(batch_size);
    std::vector<int> order(train_ds.size);
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
        int correct = 0;
        int seen = 0;
        double epoch_ms = 0.0;

        int num_batches = (train_ds.size + batch_size - 1) / batch_size;
        for (int batch = 0; batch < num_batches; ++batch) {
            int start = batch * batch_size;
            int B = std::min(batch_size, train_ds.size - start);

            copy_batch_by_index(train_ds, order, start, B, h_batch_x, h_batch_y);

            float ms = 0.0f;
            CHECK_CUDA(cudaEventRecord(ev0));
            CHECK_CUDA(cudaMemcpy(buffers.d_x, h_batch_x, bytes_of(static_cast<size_t>(B) * NUM_FEATURES), cudaMemcpyHostToDevice));
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
            metric_pass(buffers, B);
            CHECK_CUDA(cudaEventRecord(ev1));
            CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.metric_ms += ms;
            epoch_ms += ms;

            CHECK_CUDA(cudaMemcpy(h_losses.data(), buffers.d_losses, bytes_of(B), cudaMemcpyDeviceToHost));
            CHECK_CUDA(cudaMemcpy(h_preds.data(), buffers.d_preds, sizeof(int) * B, cudaMemcpyDeviceToHost));
            for (int i = 0; i < B; ++i) {
                epoch_loss += h_losses[i];
                correct += (h_preds[i] == h_batch_y[i]) ? 1 : 0;
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
            update_params(params, lr);
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

void print_learned_parameters(PerceptronParams& params) {
    float h_w[NUM_FEATURES];
    float h_b = 0.0f;
    CHECK_CUDA(cudaMemcpy(h_w, params.d_w, bytes_of(NUM_FEATURES), cudaMemcpyDeviceToHost));
    CHECK_CUDA(cudaMemcpy(&h_b, params.d_b, sizeof(float), cudaMemcpyDeviceToHost));

    static const char* names[NUM_FEATURES] = {
        "sepal_length", "sepal_width", "petal_length", "petal_width"
    };

    std::cout << "\n================ Learned Perceptron Parameters ================\n";
    for (int j = 0; j < NUM_FEATURES; ++j) {
        std::cout << std::setw(16) << names[j] << " : " << h_w[j] << "\n";
    }
    std::cout << std::setw(16) << "bias" << " : " << h_b << "\n";
}

int main(int argc, char** argv) {
    std::string iris_csv = "iris.csv";
    int epochs = 30;
    int batch_size = 16;
    float lr = 0.10f;

    if (argc >= 2) iris_csv = argv[1];
    if (argc >= 3) epochs = std::stoi(argv[2]);
    if (argc >= 4) batch_size = std::stoi(argv[3]);
    if (argc >= 5) lr = std::stof(argv[4]);

    int device = 0;
    cudaDeviceProp prop{};
    CHECK_CUDA(cudaGetDeviceProperties(&prop, device));
    CHECK_CUDA(cudaSetDevice(device));

    std::cout << "Using GPU: " << prop.name << std::endl;
    std::cout << "CSV: " << iris_csv << std::endl;
    std::cout << "Epochs=" << epochs << ", batch_size=" << batch_size << ", lr=" << lr << std::endl;

    BinaryClassInfo class_info;
    Dataset full = load_iris_binary_csv(iris_csv, class_info);

    Dataset train_ds;
    Dataset test_ds;
    split_stratified(full, train_ds, test_ds);

    StandardizationStats stats = fit_standardization(train_ds);
    apply_standardization(train_ds, stats);
    apply_standardization(test_ds, stats);

    print_dataset_summary(train_ds, test_ds, class_info);
    print_model_info(batch_size);

    PerceptronParams params;
    BatchBuffers buffers;
    init_params(params);
    alloc_batch_buffers(buffers, batch_size);

    EvalMetrics test_metrics;
    PhaseTiming timing = train(train_ds, test_ds, params, buffers, epochs, batch_size, lr, test_metrics);
    LatencyMetrics single = benchmark_single_image_latency(test_ds, params, buffers);

    double total_batches = static_cast<double>((train_ds.size + batch_size - 1) / batch_size) * epochs;
    double measured_total = timing.h2d_ms + timing.forward_ms + timing.metric_ms + timing.backward_ms + timing.update_ms;
    double avg_batch_train_ms = measured_total / total_batches;
    double avg_epoch_ms = timing.total_wall_ms / epochs;
    double train_throughput = 1000.0 * (static_cast<double>(train_ds.size) * epochs) / measured_total;

    std::cout << "\n================ Training Performance ================\n";
    std::cout << std::fixed << std::setprecision(4);
    std::cout << "Wall-clock total training time      : " << timing.total_wall_ms << " ms\n";
    std::cout << "Average wall-clock time / epoch     : " << avg_epoch_ms << " ms\n";
    std::cout << "Average measured GPU step / batch   : " << avg_batch_train_ms << " ms\n";
    std::cout << "Measured training throughput        : " << train_throughput << " samples/s\n";
    std::cout << "H2D copy time                       : " << timing.h2d_ms << " ms\n";
    std::cout << "Forward pass time                   : " << timing.forward_ms << " ms\n";
    std::cout << "Metric/loss time                    : " << timing.metric_ms << " ms\n";
    std::cout << "Backward pass time                  : " << timing.backward_ms << " ms\n";
    std::cout << "Perceptron update time              : " << timing.update_ms << " ms\n";
    std::cout << "Forward share of measured time      : " << (100.0 * timing.forward_ms / measured_total) << "%\n";
    std::cout << "Backward share of measured time     : " << (100.0 * timing.backward_ms / measured_total) << "%\n";
    std::cout << "Update share of measured time       : " << (100.0 * timing.update_ms / measured_total) << "%\n";

    std::cout << "\n================ Inference Performance ================\n";
    std::cout << "Final test loss                     : " << test_metrics.loss << "\n";
    std::cout << "Final test accuracy                 : " << (100.0 * test_metrics.accuracy) << "%\n";
    std::cout << "Precision                           : " << test_metrics.precision << "\n";
    std::cout << "Recall                              : " << test_metrics.recall << "\n";
    std::cout << "F1 score                            : " << test_metrics.f1 << "\n";
    std::cout << "Confusion matrix (TP/TN/FP/FN)      : "
              << test_metrics.tp << " / " << test_metrics.tn << " / "
              << test_metrics.fp << " / " << test_metrics.fn << "\n";
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

    print_learned_parameters(params);

    free_batch_buffers(buffers);
    free_params(params);
    CHECK_CUDA(cudaDeviceReset());
    return 0;
}
