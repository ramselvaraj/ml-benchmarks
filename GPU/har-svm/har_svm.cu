#include <cuda_runtime.h>

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cfloat>
#include <cctype>
#include <cstdlib>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <map>
#include <numeric>
#include <random>
#include <set>
#include <sstream>
#include <string>
#include <unordered_map>
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

struct Dataset {
    std::vector<float> features;  // N x D
    std::vector<int> labels;      // N in [0, C)
    std::vector<std::string> raw_label_names;
    int size = 0;
    int num_features = 0;
    int num_classes = 0;
};

struct CsvSchema {
    char delimiter = ',';
    int label_col = -1;
    std::vector<int> feature_cols;
    std::vector<std::string> header;
};

struct ColumnEncoding {
    bool is_numeric = true;
    std::unordered_map<std::string, int> token_to_id;
};

struct Preprocessor {
    std::vector<ColumnEncoding> columns; // per feature col in CSV order used by feature_cols
    std::vector<float> mean;
    std::vector<float> stddev;
    std::unordered_map<std::string, int> label_to_id;
    std::vector<std::string> id_to_label;
};

struct PhaseTiming {
    double h2d_ms = 0.0;
    double score_ms = 0.0;
    double loss_ms = 0.0;
    double grad_ms = 0.0;
    double update_ms = 0.0;
    double total_wall_ms = 0.0;
};

struct EvalMetrics {
    double hinge_loss = 0.0;
    double accuracy = 0.0;
    double macro_precision = 0.0;
    double macro_recall = 0.0;
    double macro_f1 = 0.0;
    double total_infer_ms = 0.0;
    double avg_batch_ms = 0.0;
    double avg_sample_ms = 0.0;
    double throughput_samples_per_sec = 0.0;
    double p50_batch_ms = 0.0;
    double p95_batch_ms = 0.0;
    std::vector<int> confusion; // C x C
};

struct LatencyMetrics {
    double mean_ms = 0.0;
    double min_ms = 0.0;
    double max_ms = 0.0;
    double p50_ms = 0.0;
    double p95_ms = 0.0;
};

struct SvmParams {
    float* d_w = nullptr;   // [C, D]
    float* d_b = nullptr;   // [C]
    float* d_gw = nullptr;  // [C, D]
    float* d_gb = nullptr;  // [C]
    int num_classes = 0;
    int num_features = 0;
};

struct BatchBuffers {
    int max_batch = 0;
    int num_features = 0;
    int num_classes = 0;

    float* d_x = nullptr;         // [B, D]
    int* d_y = nullptr;           // [B]
    float* d_scores = nullptr;    // [B, C]
    float* d_losses = nullptr;    // [B]
    int* d_preds = nullptr;       // [B]
};

static inline size_t fbytes(size_t n) { return n * sizeof(float); }
static inline size_t ibytes(size_t n) { return n * sizeof(int); }

bool is_numeric_token(const std::string& token) {
    if (token.empty()) return false;
    char* endptr = nullptr;
    std::strtod(token.c_str(), &endptr);
    return endptr != token.c_str() && *endptr == '\0';
}

std::string trim(const std::string& s) {
    size_t start = 0;
    while (start < s.size() && std::isspace(static_cast<unsigned char>(s[start]))) ++start;
    size_t end = s.size();
    while (end > start && std::isspace(static_cast<unsigned char>(s[end - 1]))) --end;
    return s.substr(start, end - start);
}

std::vector<std::string> split_line(const std::string& line, char delim) {
    std::vector<std::string> out;
    std::stringstream ss(line);
    std::string token;
    while (std::getline(ss, token, delim)) out.push_back(trim(token));
    return out;
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

CsvSchema inspect_schema(const std::string& path) {
    std::ifstream fin(path);
    if (!fin) {
        std::cerr << "Failed to open: " << path << std::endl;
        std::exit(EXIT_FAILURE);
    }

    std::string header_line;
    if (!std::getline(fin, header_line)) {
        std::cerr << "Empty CSV: " << path << std::endl;
        std::exit(EXIT_FAILURE);
    }

    size_t commas = std::count(header_line.begin(), header_line.end(), ',');
    size_t semis = std::count(header_line.begin(), header_line.end(), ';');

    CsvSchema schema;
    schema.delimiter = (semis > commas) ? ';' : ',';
    schema.header = split_line(header_line, schema.delimiter);

    for (int i = 0; i < static_cast<int>(schema.header.size()); ++i) {
        std::string lower = schema.header[i];
        std::transform(lower.begin(), lower.end(), lower.begin(), [](unsigned char c) {
            return static_cast<char>(std::tolower(c));
            });
        if (lower == "class" || lower == "label" || lower == "activity") {
            schema.label_col = i;
        }
    }

    if (schema.label_col < 0) schema.label_col = static_cast<int>(schema.header.size()) - 1;

    for (int i = 0; i < static_cast<int>(schema.header.size()); ++i) {
        if (i != schema.label_col) schema.feature_cols.push_back(i);
    }

    if (schema.feature_cols.empty()) {
        std::cerr << "No feature columns detected in: " << path << std::endl;
        std::exit(EXIT_FAILURE);
    }
    return schema;
}

Dataset load_har_training_csv(const std::string& path, const CsvSchema& schema, Preprocessor& prep) {
    std::ifstream fin(path);
    if (!fin) {
        std::cerr << "Failed to open: " << path << std::endl;
        std::exit(EXIT_FAILURE);
    }

    std::string line;
    if (!std::getline(fin, line)) {
        std::cerr << "Empty CSV: " << path << std::endl;
        std::exit(EXIT_FAILURE);
    }

    prep.columns.assign(schema.feature_cols.size(), ColumnEncoding{});
    std::vector<std::vector<std::string>> raw_rows;
    std::vector<std::string> raw_labels;

    while (std::getline(fin, line)) {
        if (trim(line).empty()) continue;
        std::vector<std::string> tokens = split_line(line, schema.delimiter);
        if (tokens.size() != schema.header.size()) continue;

        std::vector<std::string> row;
        row.reserve(schema.feature_cols.size());
        for (size_t j = 0; j < schema.feature_cols.size(); ++j) {
            std::string token = tokens[schema.feature_cols[j]];
            row.push_back(token);
            if (!is_numeric_token(token)) prep.columns[j].is_numeric = false;
        }
        raw_rows.push_back(std::move(row));
        raw_labels.push_back(tokens[schema.label_col]);
    }

    if (raw_rows.empty()) {
        std::cerr << "No data rows found in: " << path << std::endl;
        std::exit(EXIT_FAILURE);
    }

    Dataset ds;
    ds.size = static_cast<int>(raw_rows.size());
    ds.num_features = static_cast<int>(schema.feature_cols.size());
    ds.features.assign(static_cast<size_t>(ds.size) * ds.num_features, 0.0f);
    ds.labels.resize(ds.size);
    ds.raw_label_names = raw_labels;

    prep.mean.assign(ds.num_features, 0.0f);
    prep.stddev.assign(ds.num_features, 1.0f);

    for (int j = 0; j < ds.num_features; ++j) {
        ColumnEncoding& enc = prep.columns[j];
        for (int i = 0; i < ds.size; ++i) {
            const std::string& tok = raw_rows[i][j];
            float value = 0.0f;
            if (enc.is_numeric) {
                value = std::stof(tok);
            }
            else {
                auto it = enc.token_to_id.find(tok);
                if (it == enc.token_to_id.end()) {
                    int new_id = static_cast<int>(enc.token_to_id.size());
                    enc.token_to_id[tok] = new_id;
                    value = static_cast<float>(new_id);
                }
                else {
                    value = static_cast<float>(it->second);
                }
            }
            ds.features[static_cast<size_t>(i) * ds.num_features + j] = value;
            prep.mean[j] += value;
        }
        prep.mean[j] /= static_cast<float>(ds.size);
    }

    for (int j = 0; j < ds.num_features; ++j) {
        double var = 0.0;
        for (int i = 0; i < ds.size; ++i) {
            double diff = ds.features[static_cast<size_t>(i) * ds.num_features + j] - prep.mean[j];
            var += diff * diff;
        }
        var /= std::max(1, ds.size - 1);
        prep.stddev[j] = static_cast<float>(std::sqrt(var + 1e-8));
        if (prep.stddev[j] < 1e-6f) prep.stddev[j] = 1.0f;

        for (int i = 0; i < ds.size; ++i) {
            float& ref = ds.features[static_cast<size_t>(i) * ds.num_features + j];
            ref = (ref - prep.mean[j]) / prep.stddev[j];
        }
    }

    for (int i = 0; i < ds.size; ++i) {
        const std::string& lbl = raw_labels[i];
        auto it = prep.label_to_id.find(lbl);
        if (it == prep.label_to_id.end()) {
            int id = static_cast<int>(prep.label_to_id.size());
            prep.label_to_id[lbl] = id;
            prep.id_to_label.push_back(lbl);
            ds.labels[i] = id;
        }
        else {
            ds.labels[i] = it->second;
        }
    }

    ds.num_classes = static_cast<int>(prep.label_to_id.size());
    std::cout << "Loaded " << ds.size << " training samples from " << path << std::endl;
    return ds;
}

Dataset load_har_eval_csv(const std::string& path, const CsvSchema& schema, const Preprocessor& prep) {
    std::ifstream fin(path);
    if (!fin) {
        std::cerr << "Failed to open: " << path << std::endl;
        std::exit(EXIT_FAILURE);
    }

    std::string line;
    if (!std::getline(fin, line)) {
        std::cerr << "Empty CSV: " << path << std::endl;
        std::exit(EXIT_FAILURE);
    }

    Dataset ds;
    ds.num_features = static_cast<int>(schema.feature_cols.size());
    ds.num_classes = static_cast<int>(prep.id_to_label.size());

    std::vector<float> feature_rows;
    std::vector<int> labels;
    std::vector<std::string> raw_labels;

    while (std::getline(fin, line)) {
        if (trim(line).empty()) continue;
        std::vector<std::string> tokens = split_line(line, schema.delimiter);
        if (tokens.size() != schema.header.size()) continue;

        for (int j = 0; j < ds.num_features; ++j) {
            const ColumnEncoding& enc = prep.columns[j];
            const std::string& tok = tokens[schema.feature_cols[j]];
            float value = 0.0f;
            if (enc.is_numeric) {
                value = std::stof(tok);
            }
            else {
                auto it = enc.token_to_id.find(tok);
                value = (it == enc.token_to_id.end()) ? -1.0f : static_cast<float>(it->second);
            }
            value = (value - prep.mean[j]) / prep.stddev[j];
            feature_rows.push_back(value);
        }

        const std::string& lbl = tokens[schema.label_col];
        auto lit = prep.label_to_id.find(lbl);
        if (lit == prep.label_to_id.end()) {
            std::cerr << "Encountered unseen label '" << lbl << "' in " << path << std::endl;
            std::exit(EXIT_FAILURE);
        }
        labels.push_back(lit->second);
        raw_labels.push_back(lbl);
    }

    ds.size = static_cast<int>(labels.size());
    ds.features = std::move(feature_rows);
    ds.labels = std::move(labels);
    ds.raw_label_names = std::move(raw_labels);

    std::cout << "Loaded " << ds.size << " evaluation samples from " << path << std::endl;
    return ds;
}

void init_params(SvmParams& params, int num_classes, int num_features) {
    params.num_classes = num_classes;
    params.num_features = num_features;

    std::vector<float> h_w(static_cast<size_t>(num_classes) * num_features);
    std::vector<float> h_b(num_classes, 0.0f);

    std::mt19937 rng(42);
    std::normal_distribution<float> dist(0.0f, 0.01f);
    for (float& v : h_w) v = dist(rng);

    CHECK_CUDA(cudaMalloc((void**)&params.d_w, fbytes(h_w.size())));
    CHECK_CUDA(cudaMalloc((void**)&params.d_b, fbytes(h_b.size())));
    CHECK_CUDA(cudaMalloc((void**)&params.d_gw, fbytes(h_w.size())));
    CHECK_CUDA(cudaMalloc((void**)&params.d_gb, fbytes(h_b.size())));

    CHECK_CUDA(cudaMemcpy(params.d_w, h_w.data(), fbytes(h_w.size()), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(params.d_b, h_b.data(), fbytes(h_b.size()), cudaMemcpyHostToDevice));
}

void free_params(SvmParams& params) {
    cudaFree(params.d_w);
    cudaFree(params.d_b);
    cudaFree(params.d_gw);
    cudaFree(params.d_gb);
}

void alloc_batch_buffers(BatchBuffers& buffers, int max_batch, int num_features, int num_classes) {
    buffers.max_batch = max_batch;
    buffers.num_features = num_features;
    buffers.num_classes = num_classes;

    CHECK_CUDA(cudaMalloc((void**)&buffers.d_x, fbytes(static_cast<size_t>(max_batch) * num_features)));
    CHECK_CUDA(cudaMalloc((void**)&buffers.d_y, ibytes(max_batch)));
    CHECK_CUDA(cudaMalloc((void**)&buffers.d_scores, fbytes(static_cast<size_t>(max_batch) * num_classes)));
    CHECK_CUDA(cudaMalloc((void**)&buffers.d_losses, fbytes(max_batch)));
    CHECK_CUDA(cudaMalloc((void**)&buffers.d_preds, ibytes(max_batch)));
}

void free_batch_buffers(BatchBuffers& buffers) {
    cudaFree(buffers.d_x);
    cudaFree(buffers.d_y);
    cudaFree(buffers.d_scores);
    cudaFree(buffers.d_losses);
    cudaFree(buffers.d_preds);
}

void copy_batch_to_pinned(
    const Dataset& ds,
    const std::vector<int>& order,
    int start,
    int batch_size,
    float* h_x,
    int* h_y
) {
    for (int i = 0; i < batch_size; ++i) {
        int idx = order[start + i];
        const float* src = ds.features.data() + static_cast<size_t>(idx) * ds.num_features;
        float* dst = h_x + static_cast<size_t>(i) * ds.num_features;
        std::copy(src, src + ds.num_features, dst);
        h_y[i] = ds.labels[idx];
    }
}

void copy_contiguous_batch_to_pinned(
    const Dataset& ds,
    int start,
    int batch_size,
    float* h_x,
    int* h_y
) {
    const float* src = ds.features.data() + static_cast<size_t>(start) * ds.num_features;
    std::copy(src, src + static_cast<size_t>(batch_size) * ds.num_features, h_x);
    std::copy(ds.labels.begin() + start, ds.labels.begin() + start + batch_size, h_y);
}

__global__ void compute_scores_kernel(
    const float* x,
    const float* w,
    const float* b,
    float* scores,
    int B,
    int D,
    int C
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int total = B * C;
    if (idx >= total) return;

    int sample = idx / C;
    int cls = idx % C;

    const float* x_row = x + static_cast<size_t>(sample) * D;
    const float* w_row = w + static_cast<size_t>(cls) * D;
    float sum = b[cls];
    for (int j = 0; j < D; ++j) sum += x_row[j] * w_row[j];
    scores[idx] = sum;
}

__global__ void hinge_loss_and_pred_kernel(
    const float* scores,
    const int* y,
    float* losses,
    int* preds,
    int B,
    int C
) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= B) return;

    const float* s = scores + static_cast<size_t>(i) * C;
    int yi = y[i];
    float sample_loss = 0.0f;
    int pred = 0;
    float best = s[0];

    for (int c = 0; c < C; ++c) {
        float label = (c == yi) ? 1.0f : -1.0f;
        float margin = 1.0f - label * s[c];
        if (margin > 0.0f) sample_loss += margin;
        if (s[c] > best) {
            best = s[c];
            pred = c;
        }
    }
    losses[i] = sample_loss;
    preds[i] = pred;
}

__global__ void compute_gradients_kernel(
    const float* x,
    const int* y,
    const float* scores,
    const float* w,
    float* gw,
    float* gb,
    int B,
    int D,
    int C,
    float reg_lambda
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int total = C * D;
    if (idx >= total) return;

    int c = idx / D;
    int j = idx % D;

    float grad = reg_lambda * w[idx];
    for (int i = 0; i < B; ++i) {
        float label = (c == y[i]) ? 1.0f : -1.0f;
        float margin = 1.0f - label * scores[static_cast<size_t>(i) * C + c];
        if (margin > 0.0f) grad += (-label * x[static_cast<size_t>(i) * D + j]) / B;
    }
    gw[idx] = grad;
}

__global__ void compute_bias_gradients_kernel(
    const int* y,
    const float* scores,
    float* gb,
    int B,
    int C
) {
    int c = blockIdx.x * blockDim.x + threadIdx.x;
    if (c >= C) return;

    float grad = 0.0f;
    for (int i = 0; i < B; ++i) {
        float label = (c == y[i]) ? 1.0f : -1.0f;
        float margin = 1.0f - label * scores[static_cast<size_t>(i) * C + c];
        if (margin > 0.0f) grad += (-label) / B;
    }
    gb[c] = grad;
}

__global__ void sgd_update_kernel(float* w, const float* gw, int n, float lr) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) w[idx] -= lr * gw[idx];
}

__global__ void sgd_update_bias_kernel(float* b, const float* gb, int n, float lr) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) b[idx] -= lr * gb[idx];
}

void forward_scores(const SvmParams& params, const BatchBuffers& buffers, int B) {
    int total = B * params.num_classes;
    int threads = 256;
    int blocks = (total + threads - 1) / threads;
    compute_scores_kernel << <blocks, threads >> > (
        buffers.d_x, params.d_w, params.d_b, buffers.d_scores,
        B, params.num_features, params.num_classes);
    CHECK_CUDA(cudaGetLastError());
}

void run_loss_and_pred(const BatchBuffers& buffers, int B, int C) {
    int threads = 256;
    int blocks = (B + threads - 1) / threads;
    hinge_loss_and_pred_kernel << <blocks, threads >> > (
        buffers.d_scores, buffers.d_y, buffers.d_losses, buffers.d_preds, B, C);
    CHECK_CUDA(cudaGetLastError());
}

void backward_pass(SvmParams& params, const BatchBuffers& buffers, int B, float reg_lambda) {
    int total = params.num_classes * params.num_features;
    int threads = 256;
    int blocks = (total + threads - 1) / threads;
    compute_gradients_kernel << <blocks, threads >> > (
        buffers.d_x, buffers.d_y, buffers.d_scores, params.d_w,
        params.d_gw, params.d_gb, B, params.num_features, params.num_classes, reg_lambda);
    CHECK_CUDA(cudaGetLastError());

    int bblocks = (params.num_classes + threads - 1) / threads;
    compute_bias_gradients_kernel << <bblocks, threads >> > (
        buffers.d_y, buffers.d_scores, params.d_gb, B, params.num_classes);
    CHECK_CUDA(cudaGetLastError());
}

void update_params(SvmParams& params, float lr) {
    int threads = 256;
    int total_w = params.num_classes * params.num_features;
    int blocks_w = (total_w + threads - 1) / threads;
    int blocks_b = (params.num_classes + threads - 1) / threads;
    sgd_update_kernel << <blocks_w, threads >> > (params.d_w, params.d_gw, total_w, lr);
    sgd_update_bias_kernel << <blocks_b, threads >> > (params.d_b, params.d_gb, params.num_classes, lr);
    CHECK_CUDA(cudaGetLastError());
}

EvalMetrics evaluate(const Dataset& ds, SvmParams& params, BatchBuffers& buffers, int batch_size) {
    float* h_batch_x = nullptr;
    int* h_batch_y = nullptr;
    CHECK_CUDA(cudaMallocHost((void**)&h_batch_x, fbytes(static_cast<size_t>(batch_size) * ds.num_features)));
    CHECK_CUDA(cudaMallocHost((void**)&h_batch_y, ibytes(batch_size)));

    std::vector<float> h_losses(batch_size);
    std::vector<int> h_preds(batch_size);
    std::vector<float> batch_lat_ms;
    batch_lat_ms.reserve((ds.size + batch_size - 1) / batch_size);

    cudaEvent_t ev0, ev1;
    CHECK_CUDA(cudaEventCreate(&ev0));
    CHECK_CUDA(cudaEventCreate(&ev1));

    double total_loss = 0.0;
    int correct = 0;
    int seen = 0;
    double total_infer_ms = 0.0;
    std::vector<int> confusion(static_cast<size_t>(ds.num_classes) * ds.num_classes, 0);

    int num_batches = (ds.size + batch_size - 1) / batch_size;
    for (int batch = 0; batch < num_batches; ++batch) {
        int start = batch * batch_size;
        int B = std::min(batch_size, ds.size - start);

        copy_contiguous_batch_to_pinned(ds, start, B, h_batch_x, h_batch_y);
        CHECK_CUDA(cudaMemcpy(buffers.d_x, h_batch_x, fbytes(static_cast<size_t>(B) * ds.num_features), cudaMemcpyHostToDevice));
        CHECK_CUDA(cudaMemcpy(buffers.d_y, h_batch_y, ibytes(B), cudaMemcpyHostToDevice));

        float ms = 0.0f;
        CHECK_CUDA(cudaEventRecord(ev0));
        forward_scores(params, buffers, B);
        run_loss_and_pred(buffers, B, ds.num_classes);
        CHECK_CUDA(cudaEventRecord(ev1));
        CHECK_CUDA(cudaEventSynchronize(ev1));
        CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));

        batch_lat_ms.push_back(ms);
        total_infer_ms += ms;

        CHECK_CUDA(cudaMemcpy(h_losses.data(), buffers.d_losses, fbytes(B), cudaMemcpyDeviceToHost));
        CHECK_CUDA(cudaMemcpy(h_preds.data(), buffers.d_preds, ibytes(B), cudaMemcpyDeviceToHost));

        for (int i = 0; i < B; ++i) {
            total_loss += h_losses[i];
            correct += (h_preds[i] == h_batch_y[i]);
            confusion[static_cast<size_t>(h_batch_y[i]) * ds.num_classes + h_preds[i]]++;
        }
        seen += B;
    }

    double macro_precision = 0.0;
    double macro_recall = 0.0;
    double macro_f1 = 0.0;
    for (int c = 0; c < ds.num_classes; ++c) {
        int tp = confusion[static_cast<size_t>(c) * ds.num_classes + c];
        int fp = 0;
        int fn = 0;
        for (int k = 0; k < ds.num_classes; ++k) {
            if (k != c) {
                fp += confusion[static_cast<size_t>(k) * ds.num_classes + c];
                fn += confusion[static_cast<size_t>(c) * ds.num_classes + k];
            }
        }
        double prec = (tp + fp) ? static_cast<double>(tp) / (tp + fp) : 0.0;
        double rec = (tp + fn) ? static_cast<double>(tp) / (tp + fn) : 0.0;
        double f1 = (prec + rec) ? (2.0 * prec * rec / (prec + rec)) : 0.0;
        macro_precision += prec;
        macro_recall += rec;
        macro_f1 += f1;
    }
    macro_precision /= ds.num_classes;
    macro_recall /= ds.num_classes;
    macro_f1 /= ds.num_classes;

    EvalMetrics m;
    m.hinge_loss = total_loss / seen;
    m.accuracy = static_cast<double>(correct) / seen;
    m.macro_precision = macro_precision;
    m.macro_recall = macro_recall;
    m.macro_f1 = macro_f1;
    m.total_infer_ms = total_infer_ms;
    m.avg_batch_ms = total_infer_ms / num_batches;
    m.avg_sample_ms = total_infer_ms / seen;
    m.throughput_samples_per_sec = 1000.0 * seen / std::max(total_infer_ms, 1e-9);
    m.p50_batch_ms = percentile(batch_lat_ms, 0.50);
    m.p95_batch_ms = percentile(batch_lat_ms, 0.95);
    m.confusion = std::move(confusion);

    CHECK_CUDA(cudaEventDestroy(ev0));
    CHECK_CUDA(cudaEventDestroy(ev1));
    CHECK_CUDA(cudaFreeHost(h_batch_x));
    CHECK_CUDA(cudaFreeHost(h_batch_y));
    return m;
}

PhaseTiming train(
    const Dataset& train_ds,
    const Dataset& test_ds,
    SvmParams& params,
    BatchBuffers& buffers,
    int epochs,
    int batch_size,
    float lr,
    float reg_lambda,
    EvalMetrics& final_test_metrics
) {
    float* h_batch_x = nullptr;
    int* h_batch_y = nullptr;
    CHECK_CUDA(cudaMallocHost((void**)&h_batch_x, fbytes(static_cast<size_t>(batch_size) * train_ds.num_features)));
    CHECK_CUDA(cudaMallocHost((void**)&h_batch_y, ibytes(batch_size)));

    std::vector<float> h_losses(batch_size);
    std::vector<int> h_preds(batch_size);
    std::vector<int> order(train_ds.size);
    std::iota(order.begin(), order.end(), 0);
    std::mt19937 rng(42);

    PhaseTiming timing;
    auto wall_begin = std::chrono::high_resolution_clock::now();

    cudaEvent_t ev0, ev1;
    CHECK_CUDA(cudaEventCreate(&ev0));
    CHECK_CUDA(cudaEventCreate(&ev1));

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
            CHECK_CUDA(cudaMemcpy(buffers.d_x, h_batch_x, fbytes(static_cast<size_t>(B) * train_ds.num_features), cudaMemcpyHostToDevice));
            CHECK_CUDA(cudaMemcpy(buffers.d_y, h_batch_y, ibytes(B), cudaMemcpyHostToDevice));
            CHECK_CUDA(cudaEventRecord(ev1));
            CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.h2d_ms += ms;
            epoch_ms += ms;

            CHECK_CUDA(cudaEventRecord(ev0));
            forward_scores(params, buffers, B);
            CHECK_CUDA(cudaEventRecord(ev1));
            CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.score_ms += ms;
            epoch_ms += ms;

            CHECK_CUDA(cudaEventRecord(ev0));
            run_loss_and_pred(buffers, B, train_ds.num_classes);
            CHECK_CUDA(cudaEventRecord(ev1));
            CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.loss_ms += ms;
            epoch_ms += ms;

            CHECK_CUDA(cudaMemcpy(h_losses.data(), buffers.d_losses, fbytes(B), cudaMemcpyDeviceToHost));
            CHECK_CUDA(cudaMemcpy(h_preds.data(), buffers.d_preds, ibytes(B), cudaMemcpyDeviceToHost));
            for (int i = 0; i < B; ++i) {
                epoch_loss += h_losses[i];
                correct += (h_preds[i] == h_batch_y[i]);
            }
            seen += B;

            CHECK_CUDA(cudaEventRecord(ev0));
            backward_pass(params, buffers, B, reg_lambda);
            CHECK_CUDA(cudaEventRecord(ev1));
            CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.grad_ms += ms;
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
            << " | train_hinge_loss=" << (epoch_loss / seen)
            << " | train_acc=" << (100.0 * correct / seen) << "%"
            << " | epoch_gpu_ms=" << epoch_ms
            << " | epoch_throughput=" << (1000.0 * seen / std::max(epoch_ms, 1e-9)) << " samples/s"
            << std::endl;

        final_test_metrics = evaluate(test_ds, params, buffers, batch_size);
        std::cout << "  test_hinge_loss=" << final_test_metrics.hinge_loss
            << " | test_acc=" << (100.0 * final_test_metrics.accuracy) << "%"
            << " | macro_f1=" << final_test_metrics.macro_f1
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

LatencyMetrics benchmark_single_sample_latency(
    const Dataset& ds,
    SvmParams& params,
    BatchBuffers& buffers,
    int warmup = 20,
    int reps = 200
) {
    float* h_x = nullptr;
    int* h_y = nullptr;
    CHECK_CUDA(cudaMallocHost((void**)&h_x, fbytes(ds.num_features)));
    CHECK_CUDA(cudaMallocHost((void**)&h_y, ibytes(1)));

    std::copy_n(ds.features.data(), ds.num_features, h_x);
    h_y[0] = ds.labels[0];

    CHECK_CUDA(cudaMemcpy(buffers.d_x, h_x, fbytes(ds.num_features), cudaMemcpyHostToDevice));
    CHECK_CUDA(cudaMemcpy(buffers.d_y, h_y, ibytes(1), cudaMemcpyHostToDevice));

    cudaEvent_t ev0, ev1;
    CHECK_CUDA(cudaEventCreate(&ev0));
    CHECK_CUDA(cudaEventCreate(&ev1));

    for (int i = 0; i < warmup; ++i) {
        forward_scores(params, buffers, 1);
        run_loss_and_pred(buffers, 1, ds.num_classes);
    }
    CHECK_CUDA(cudaDeviceSynchronize());

    std::vector<float> latencies;
    latencies.reserve(reps);
    for (int i = 0; i < reps; ++i) {
        float ms = 0.0f;
        CHECK_CUDA(cudaEventRecord(ev0));
        forward_scores(params, buffers, 1);
        run_loss_and_pred(buffers, 1, ds.num_classes);
        CHECK_CUDA(cudaEventRecord(ev1));
        CHECK_CUDA(cudaEventSynchronize(ev1));
        CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
        latencies.push_back(ms);
    }

    LatencyMetrics m;
    m.mean_ms = std::accumulate(latencies.begin(), latencies.end(), 0.0) / latencies.size();
    m.min_ms = *std::min_element(latencies.begin(), latencies.end());
    m.max_ms = *std::max_element(latencies.begin(), latencies.end());
    m.p50_ms = percentile(latencies, 0.50);
    m.p95_ms = percentile(latencies, 0.95);

    CHECK_CUDA(cudaEventDestroy(ev0));
    CHECK_CUDA(cudaEventDestroy(ev1));
    CHECK_CUDA(cudaFreeHost(h_x));
    CHECK_CUDA(cudaFreeHost(h_y));
    return m;
}

void print_model_info(int num_features, int num_classes, int batch_size) {
    size_t params_count = static_cast<size_t>(num_classes) * num_features + num_classes;
    size_t param_bytes = params_count * sizeof(float);
    size_t activation_floats =
        static_cast<size_t>(batch_size) * num_features +
        static_cast<size_t>(batch_size) * num_classes +
        static_cast<size_t>(batch_size) +
        static_cast<size_t>(batch_size);

    std::cout << "Model summary" << std::endl;
    std::cout << "  Model type: Linear one-vs-rest SVM" << std::endl;
    std::cout << "  Input features: " << num_features << std::endl;
    std::cout << "  Output classes: " << num_classes << std::endl;
    std::cout << "  Trainable params: " << params_count << std::endl;
    std::cout << "  Parameter memory: " << (param_bytes / 1024.0) << " KB" << std::endl;
    std::cout << "  Approx activation memory per batch: "
        << (activation_floats * sizeof(float) / (1024.0 * 1024.0)) << " MB" << std::endl;
}

void print_label_map(const std::vector<std::string>& labels) {
    std::cout << "Class mapping" << std::endl;
    for (size_t i = 0; i < labels.size(); ++i) {
        std::cout << "  " << i << " -> " << labels[i] << std::endl;
    }
}

void print_confusion_matrix(const EvalMetrics& metrics, const std::vector<std::string>& labels) {
    int C = static_cast<int>(labels.size());
    std::cout << "\nConfusion matrix (rows=true, cols=pred)" << std::endl;
    std::cout << std::setw(14) << " ";
    for (int c = 0; c < C; ++c) std::cout << std::setw(10) << c;
    std::cout << std::endl;
    for (int r = 0; r < C; ++r) {
        std::cout << std::setw(14) << r;
        for (int c = 0; c < C; ++c) {
            std::cout << std::setw(10) << metrics.confusion[static_cast<size_t>(r) * C + c];
        }
        std::cout << "    " << labels[r] << std::endl;
    }
}

int main(int argc, char** argv) {
    std::string train_csv = "har_train.csv";
    std::string test_csv = "har_test.csv";
    int epochs = 25;
    int batch_size = 128;
    float lr = 0.01f;
    float reg_lambda = 1e-4f;

    if (argc >= 3) {
        train_csv = argv[1];
        test_csv = argv[2];
    }
    if (argc >= 4) epochs = std::stoi(argv[3]);
    if (argc >= 5) batch_size = std::stoi(argv[4]);
    if (argc >= 6) lr = std::stof(argv[5]);
    if (argc >= 7) reg_lambda = std::stof(argv[6]);

    int device = 0;
    cudaDeviceProp prop{};
    CHECK_CUDA(cudaGetDeviceProperties(&prop, device));
    CHECK_CUDA(cudaSetDevice(device));

    std::cout << "Using GPU: " << prop.name << std::endl;
    std::cout << "Train CSV: " << train_csv << std::endl;
    std::cout << "Test CSV:  " << test_csv << std::endl;
    std::cout << "Epochs=" << epochs
        << ", batch_size=" << batch_size
        << ", lr=" << lr
        << ", reg_lambda=" << reg_lambda
        << std::endl;

    CsvSchema schema = inspect_schema(train_csv);
    Preprocessor prep;
    Dataset train_ds = load_har_training_csv(train_csv, schema, prep);
    Dataset test_ds = load_har_eval_csv(test_csv, schema, prep);

    print_model_info(train_ds.num_features, train_ds.num_classes, batch_size);
    print_label_map(prep.id_to_label);

    SvmParams params;
    BatchBuffers buffers;
    init_params(params, train_ds.num_classes, train_ds.num_features);
    alloc_batch_buffers(buffers, batch_size, train_ds.num_features, train_ds.num_classes);

    EvalMetrics test_metrics;
    PhaseTiming timing = train(train_ds, test_ds, params, buffers, epochs, batch_size, lr, reg_lambda, test_metrics);
    LatencyMetrics single = benchmark_single_sample_latency(test_ds, params, buffers);

    double measured_total = timing.h2d_ms + timing.score_ms + timing.loss_ms + timing.grad_ms + timing.update_ms;
    double total_batches = static_cast<double>((train_ds.size + batch_size - 1) / batch_size) * epochs;
    double avg_batch_train_ms = measured_total / std::max(total_batches, 1.0);
    double avg_epoch_ms = timing.total_wall_ms / std::max(epochs, 1);
    double train_throughput = 1000.0 * (static_cast<double>(train_ds.size) * epochs) / std::max(measured_total, 1e-9);

    std::cout << "\n================ Training Performance ================\n";
    std::cout << std::fixed << std::setprecision(4);
    std::cout << "Wall-clock total training time      : " << timing.total_wall_ms << " ms\n";
    std::cout << "Average wall-clock time / epoch     : " << avg_epoch_ms << " ms\n";
    std::cout << "Average measured GPU step / batch   : " << avg_batch_train_ms << " ms\n";
    std::cout << "Measured training throughput        : " << train_throughput << " samples/s\n";
    std::cout << "H2D copy time                       : " << timing.h2d_ms << " ms\n";
    std::cout << "Score compute time                  : " << timing.score_ms << " ms\n";
    std::cout << "Loss/prediction time                : " << timing.loss_ms << " ms\n";
    std::cout << "Gradient compute time               : " << timing.grad_ms << " ms\n";
    std::cout << "SGD update time                     : " << timing.update_ms << " ms\n";
    std::cout << "Score share of measured time        : " << (100.0 * timing.score_ms / std::max(measured_total, 1e-9)) << "%\n";
    std::cout << "Gradient share of measured time     : " << (100.0 * timing.grad_ms / std::max(measured_total, 1e-9)) << "%\n";
    std::cout << "Update share of measured time       : " << (100.0 * timing.update_ms / std::max(measured_total, 1e-9)) << "%\n";

    std::cout << "\n================ Inference Performance ================\n";
    std::cout << "Final test hinge loss               : " << test_metrics.hinge_loss << "\n";
    std::cout << "Final test accuracy                 : " << (100.0 * test_metrics.accuracy) << "%\n";
    std::cout << "Final macro precision               : " << test_metrics.macro_precision << "\n";
    std::cout << "Final macro recall                  : " << test_metrics.macro_recall << "\n";
    std::cout << "Final macro F1                      : " << test_metrics.macro_f1 << "\n";
    std::cout << "Total GPU inference time            : " << test_metrics.total_infer_ms << " ms\n";
    std::cout << "Average batch GPU latency           : " << test_metrics.avg_batch_ms << " ms\n";
    std::cout << "Average sample GPU latency          : " << test_metrics.avg_sample_ms << " ms\n";
    std::cout << "Batch latency p50                   : " << test_metrics.p50_batch_ms << " ms\n";
    std::cout << "Batch latency p95                   : " << test_metrics.p95_batch_ms << " ms\n";
    std::cout << "Inference throughput                : " << test_metrics.throughput_samples_per_sec << " samples/s\n";

    std::cout << "\n============= Single-Sample Latency Benchmark =============\n";
    std::cout << "Mean latency                        : " << single.mean_ms << " ms\n";
    std::cout << "Min latency                         : " << single.min_ms << " ms\n";
    std::cout << "Max latency                         : " << single.max_ms << " ms\n";
    std::cout << "p50 latency                         : " << single.p50_ms << " ms\n";
    std::cout << "p95 latency                         : " << single.p95_ms << " ms\n";

    print_confusion_matrix(test_metrics, prep.id_to_label);

    free_batch_buffers(buffers);
    free_params(params);
    CHECK_CUDA(cudaDeviceReset());
    return 0;
}
