// gen_perf_results.cu
// Pure inference performance benchmark for the MNIST CNN.
// Loads pre-trained weights, concatenates train+test into one pool,
// runs 3-phase timed inference (phase_staging / phase_compute / phase_output),
// and writes a SINGLE row to perf_results.csv.
//
// Power/energy:
//   - Default: sampled via nvidia-smi subprocess (Windows-friendly, no NVML header required)
//   - Optional: compile with -DUSE_NVML to use the NVML API instead
//
// Usage:
//   ./gen_perf [train_csv] [test_csv] [weights.bin] [batch_size]
//              [perf_out.csv] [warmup_runs] [timed_runs]
//
// Defaults:
//   train_csv = mnist_train.csv
//   test_csv  = mnist_test.csv
//   weights   = cnn_weights.bin
//   batch_size = 64
//   perf_out   = results/gpu_cuda/mnist_cnn/perf_results.csv
//   warmup     = 3
//   timed_runs = 5

#include "cnn_model.cuh"

#include <atomic>
#include <thread>
#include <vector>
#include <string>
#include <numeric>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <algorithm>
#include <chrono>
#include <cstdlib>
#include <cstdio>
#include <cerrno>

#ifdef _WIN32
#include <direct.h>
#define popen  _popen
#define pclose _pclose
#else
#include <sys/stat.h>
#include <sys/types.h>
#endif

#ifdef USE_NVML
#include <nvml.h>
#endif

// ===========================================================================
// Small path helpers (no std::filesystem needed)
// ===========================================================================

static bool is_sep(char c) {
    return c == '/' || c == '\\';
}

static bool make_single_dir(const std::string& dir) {
    if (dir.empty()) return true;

#ifdef _WIN32
    int rc = _mkdir(dir.c_str());
#else
    int rc = mkdir(dir.c_str(), 0755);
#endif

    if (rc == 0) return true;
    if (errno == EEXIST) return true;
    return false;
}

static void ensure_parent_dirs(const std::string& path) {
    size_t pos = path.find_last_of("/\\");
    if (pos == std::string::npos) return;

    std::string dir = path.substr(0, pos);
    if (dir.empty()) return;

    std::string current;
    size_t start = 0;

#ifdef _WIN32
    if (dir.size() >= 2 && dir[1] == ':') {
        current = dir.substr(0, 2);
        start = 2;
    }
#endif

    for (size_t i = start; i < dir.size(); ++i) {
        current.push_back(dir[i]);

        if (is_sep(dir[i])) {
            std::string sub = current;
            while (!sub.empty() && is_sep(sub.back())) sub.pop_back();
            if (!sub.empty() && !(sub.size() == 2 && sub[1] == ':')) {
                make_single_dir(sub);
            }
        }
    }

    if (!(dir.size() == 2 && dir[1] == ':')) {
        make_single_dir(dir);
    }
}

// ===========================================================================
// Power sampling — two backends selectable at compile time
// ===========================================================================

#ifdef USE_NVML

struct PowerPoller {
    std::atomic<bool>  running{false};
    std::thread        thread;
    std::vector<float> samples_w;
    int                device_index = 0;
    bool               init_ok = false;
    bool               handle_ok = false;

    void start(int dev) {
        device_index = dev;
        running = false;
        init_ok = false;
        handle_ok = false;
        samples_w.clear();

        nvmlReturn_t st = nvmlInit();
        if (st != NVML_SUCCESS) {
            std::cerr << "[NVML] nvmlInit failed: " << nvmlErrorString(st) << "\n";
            return;
        }
        init_ok = true;

        nvmlDevice_t dh{};
        st = nvmlDeviceGetHandleByIndex(device_index, &dh);
        if (st != NVML_SUCCESS) {
            std::cerr << "[NVML] nvmlDeviceGetHandleByIndex failed: "
                      << nvmlErrorString(st) << "\n";
            return;
        }
        handle_ok = true;

        running = true;
        thread = std::thread([this, dh]() {
            while (running.load()) {
                unsigned int mw = 0;
                if (nvmlDeviceGetPowerUsage(dh, &mw) == NVML_SUCCESS) {
                    samples_w.push_back(static_cast<float>(mw) / 1000.0f);
                }
                std::this_thread::sleep_for(std::chrono::milliseconds(10));
            }
        });
    }

    void stop() {
        running = false;
        if (thread.joinable()) thread.join();

        if (init_ok) {
            nvmlReturn_t st = nvmlShutdown();
            if (st != NVML_SUCCESS) {
                std::cerr << "[NVML] nvmlShutdown failed: " << nvmlErrorString(st) << "\n";
            }
        }
    }

    bool active() const {
        return init_ok && handle_ok;
    }

    bool has_samples() const {
        return !samples_w.empty();
    }

    double mean_w() const {
        if (samples_w.empty()) return 0.0;
        return std::accumulate(samples_w.begin(), samples_w.end(), 0.0) /
               static_cast<double>(samples_w.size());
    }
};

#else

static const char* power_query_cmd() {
#ifdef _WIN32
    return "nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits 2>nul";
#else
    return "nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits 2>/dev/null";
#endif
}

struct PowerPoller {
    std::atomic<bool>  running{false};
    std::thread        thread;
    std::vector<float> samples_w;

    void start(int /*dev*/) {
        running = true;
        samples_w.clear();

        thread = std::thread([this]() {
            while (running.load()) {
                FILE* pipe = popen(power_query_cmd(), "r");
                if (pipe) {
                    char buf[128] = {};
                    if (fgets(buf, sizeof(buf), pipe)) {
                        try {
                            samples_w.push_back(std::stof(buf));
                        } catch (...) {
                        }
                    }
                    pclose(pipe);
                }

                std::this_thread::sleep_for(std::chrono::milliseconds(10));
            }
        });
    }

    void stop() {
        running = false;
        if (thread.joinable()) thread.join();
    }

    bool active() const {
        return true;
    }

    bool has_samples() const {
        return !samples_w.empty();
    }

    double mean_w() const {
        if (samples_w.empty()) return 0.0;
        return std::accumulate(samples_w.begin(), samples_w.end(), 0.0) /
               static_cast<double>(samples_w.size());
    }
};

#endif // USE_NVML

// ===========================================================================
// Dataset concat helper — merge train+test into one pool for inference
// ===========================================================================

static Dataset concat_datasets(const Dataset& a, const Dataset& b) {
    Dataset out;
    out.images.insert(out.images.end(), a.images.begin(), a.images.end());
    out.images.insert(out.images.end(), b.images.begin(), b.images.end());
    out.labels.insert(out.labels.end(), a.labels.begin(), a.labels.end());
    out.labels.insert(out.labels.end(), b.labels.begin(), b.labels.end());
    out.size = static_cast<int>(out.labels.size());
    return out;
}

// ===========================================================================
// PerfRow — one CSV row
// ===========================================================================

struct PerfRow {
    std::string workload;
    std::string dtype = "fp32";
    int batch_size = 0;
    int total_samples = 0;
    double throughput = 0.0;      // samples/s
    double latency_p50 = 0.0;     // ms
    double latency_p99 = 0.0;     // ms
    double energy_total = 0.0;    // J
    double avg_power = 0.0;       // W
    double achieved_gflops = 0.0;
    double utilization_pct = 0.0;
    double arith_intensity = 0.0;
    double phase_staging = 0.0;   // ms
    double phase_compute = 0.0;   // ms
    double phase_output = 0.0;    // ms
    std::string tta_sec = "N/A";
};

// ===========================================================================
// Arithmetic intensity for this CNN
// ===========================================================================

static double compute_flops_per_sample() {
    return 2.0 * (
        static_cast<double>(IMG_C) * C1_K * C1_K * C1_OUT * C1_H * C1_W +
        static_cast<double>(C1_OUT) * C2_K * C2_K * C2_OUT * C2_H * C2_W +
        static_cast<double>(FC_IN) * FC_OUT
    );
}

static double compute_arith_intensity(int N) {
    double ops = compute_flops_per_sample() * static_cast<double>(N);

    size_t n_params =
        static_cast<size_t>(C1_OUT) * IMG_C * C1_K * C1_K + C1_OUT +
        static_cast<size_t>(C2_OUT) * C1_OUT * C2_K * C2_K + C2_OUT +
        static_cast<size_t>(FC_OUT) * FC_IN + FC_OUT;

    double dram_b =
        static_cast<double>(N) * IMG_H * IMG_W * sizeof(float) +
        static_cast<double>(n_params) * sizeof(float);

    return ops / dram_b;
}

static double device_peak_gflops(const cudaDeviceProp& prop, int device) {
    int clock_khz = 0;
    CHECK_CUDA(cudaDeviceGetAttribute(&clock_khz, cudaDevAttrClockRate, device));
    double clock_ghz = clock_khz * 1e-6;
    return prop.multiProcessorCount * 64.0 * 2.0 * clock_ghz;
}

// ===========================================================================
// Single timed inference pass — 3 phases, cudaEvent_t
// Returns per-sample latency vector (ms) and fills phase totals
// ===========================================================================

static std::vector<float> run_inference_pass(
    const Dataset& ds,
    CnnParams& params,
    BatchBuffers& buffers,
    int batch_size,
    double& out_staging_ms,
    double& out_compute_ms,
    double& out_output_ms
) {
    float* h_x = nullptr;
    int*   h_y = nullptr;

    CHECK_CUDA(cudaMallocHost((void**)&h_x,
        bytes_of(static_cast<size_t>(batch_size) * IMG_H * IMG_W)));
    CHECK_CUDA(cudaMallocHost((void**)&h_y, sizeof(int) * batch_size));

    std::vector<int>   h_preds_out(batch_size);
    std::vector<float> per_sample_ms;
    per_sample_ms.reserve(static_cast<size_t>(ds.size));

    cudaEvent_t ev0, ev1;
    CHECK_CUDA(cudaEventCreate(&ev0));
    CHECK_CUDA(cudaEventCreate(&ev1));

    out_staging_ms = 0.0;
    out_compute_ms = 0.0;
    out_output_ms  = 0.0;

    int num_batches = (ds.size + batch_size - 1) / batch_size;

    for (int bat = 0; bat < num_batches; ++bat) {
        int start = bat * batch_size;
        int B = std::min(batch_size, ds.size - start);

        copy_contiguous_batch_to_pinned(ds, start, B, h_x, h_y);

        float ms = 0.0f;

        // Phase 1: H2D staging
        CHECK_CUDA(cudaDeviceSynchronize());
        CHECK_CUDA(cudaEventRecord(ev0));
        CHECK_CUDA(cudaMemcpy(
            buffers.d_x,
            h_x,
            bytes_of(static_cast<size_t>(B) * IMG_H * IMG_W),
            cudaMemcpyHostToDevice));
        CHECK_CUDA(cudaMemcpy(
            buffers.d_y,
            h_y,
            sizeof(int) * B,
            cudaMemcpyHostToDevice));
        CHECK_CUDA(cudaEventRecord(ev1));
        CHECK_CUDA(cudaEventSynchronize(ev1));
        CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
        out_staging_ms += ms;

        // Phase 2: compute
        CHECK_CUDA(cudaDeviceSynchronize());
        CHECK_CUDA(cudaEventRecord(ev0));
        forward_pass(params, buffers, B);
        run_loss_and_pred(buffers, B);
        CHECK_CUDA(cudaEventRecord(ev1));
        CHECK_CUDA(cudaEventSynchronize(ev1));
        CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
        out_compute_ms += ms;

        float sms = ms / static_cast<float>(B);
        for (int i = 0; i < B; ++i) per_sample_ms.push_back(sms);

        // Phase 3: D2H output
        CHECK_CUDA(cudaDeviceSynchronize());
        CHECK_CUDA(cudaEventRecord(ev0));
        CHECK_CUDA(cudaMemcpy(
            h_preds_out.data(),
            buffers.d_preds,
            sizeof(int) * B,
            cudaMemcpyDeviceToHost));
        CHECK_CUDA(cudaEventRecord(ev1));
        CHECK_CUDA(cudaEventSynchronize(ev1));
        CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
        out_output_ms += ms;
    }

    CHECK_CUDA(cudaEventDestroy(ev0));
    CHECK_CUDA(cudaEventDestroy(ev1));
    CHECK_CUDA(cudaFreeHost(h_x));
    CHECK_CUDA(cudaFreeHost(h_y));

    return per_sample_ms;
}

// ===========================================================================
// Benchmark: warmup + timed runs, power polling, aggregate into PerfRow
// ===========================================================================

static PerfRow benchmark(
    const std::string& workload_name,
    const Dataset& ds,
    CnnParams& params,
    BatchBuffers& buffers,
    int batch_size,
    int warmup_runs,
    int timed_runs,
    const cudaDeviceProp& prop,
    int device
) {
    std::cout << "\n[" << workload_name << "] Warming up (" << warmup_runs
              << " passes)...\n";
    for (int i = 0; i < warmup_runs; ++i) {
        double s, c, o;
        run_inference_pass(ds, params, buffers, batch_size, s, c, o);
    }
    CHECK_CUDA(cudaDeviceSynchronize());

    std::cout << "[" << workload_name << "] Timing (" << timed_runs
              << " passes)...\n";

    std::vector<double> staging_v, compute_v, output_v;
    std::vector<float>  all_lats;

    PowerPoller poller;
    poller.start(device);

    auto wall_t0 = std::chrono::high_resolution_clock::now();

    for (int r = 0; r < timed_runs; ++r) {
        double s, c, o;
        std::vector<float> lats =
            run_inference_pass(ds, params, buffers, batch_size, s, c, o);

        staging_v.push_back(s);
        compute_v.push_back(c);
        output_v.push_back(o);

        if (r == 0) all_lats = lats;
    }

    CHECK_CUDA(cudaDeviceSynchronize());
    auto wall_t1 = std::chrono::high_resolution_clock::now();

    poller.stop();

    double wall_ms = std::chrono::duration<double, std::milli>(wall_t1 - wall_t0).count();
    double mean_power = poller.has_samples() ? poller.mean_w() : 0.0;

    auto mean_v = [](const std::vector<double>& v) -> double {
        if (v.empty()) return 0.0;
        return std::accumulate(v.begin(), v.end(), 0.0) /
               static_cast<double>(v.size());
    };

    double avg_staging = mean_v(staging_v);
    double avg_compute = mean_v(compute_v);
    double avg_output  = mean_v(output_v);
    double avg_wall_ms = wall_ms / static_cast<double>(timed_runs);

    double throughput = (avg_compute > 0.0)
        ? (1000.0 * static_cast<double>(ds.size) / avg_compute)
        : 0.0;

    float p50 = all_lats.empty() ? 0.0f : percentile(all_lats, 0.50);
    float p99 = all_lats.empty() ? 0.0f : percentile(all_lats, 0.99);

    double energy_total = mean_power * (avg_wall_ms / 1000.0);
    double ops_total = compute_flops_per_sample() * static_cast<double>(ds.size);
    double achieved_gflops = (avg_compute > 0.0)
        ? (ops_total / (avg_compute * 1e-3) * 1e-9)
        : 0.0;

    double peak_gflops = device_peak_gflops(prop, device);
    double utilization = (peak_gflops > 0.0) ? (achieved_gflops / peak_gflops) : 0.0;
    double arith_intensity = compute_arith_intensity(ds.size);

    PerfRow row;
    row.workload = workload_name;
    row.batch_size = batch_size;
    row.total_samples = ds.size;
    row.throughput = throughput;
    row.latency_p50 = p50;
    row.latency_p99 = p99;
    row.energy_total = energy_total;
    row.avg_power = mean_power;
    row.achieved_gflops = achieved_gflops;
    row.utilization_pct = utilization;
    row.arith_intensity = arith_intensity;
    row.phase_staging = avg_staging;
    row.phase_compute = avg_compute;
    row.phase_output = avg_output;

    std::cout << std::fixed << std::setprecision(4)
              << " throughput : " << throughput << " samples/s\n"
              << " phase_staging : " << avg_staging << " ms\n"
              << " phase_compute : " << avg_compute << " ms\n"
              << " phase_output : " << avg_output << " ms\n"
              << " latency p50 : " << p50 << " ms\n"
              << " latency p99 : " << p99 << " ms\n"
              << " achieved GFLOPS : " << achieved_gflops << "\n"
              << " utilization : " << (utilization * 100.0) << "%\n"
              << " avg_power : " << mean_power << " W\n"
              << " energy_total : " << energy_total << " J\n";

#ifdef USE_NVML
    if (!poller.active()) {
        std::cerr << "[NVML] Power polling inactive. avg_power and energy_total will be 0.\n";
    } else if (!poller.has_samples()) {
        std::cerr << "[NVML] No power samples collected.\n";
    }
#else
    if (!poller.has_samples()) {
        std::cerr << "[power] No nvidia-smi power samples collected. "
                  << "Check that nvidia-smi is on PATH and power.draw is supported.\n";
    }
#endif

    return row;
}

// ===========================================================================
// Write perf_results.csv — single row
// ===========================================================================

static void write_perf_csv(const std::string& path, const PerfRow& row) {
    ensure_parent_dirs(path);

    std::ofstream fout(path);
    if (!fout) {
        std::cerr << "Cannot open: " << path << std::endl;
        std::exit(1);
    }

    fout << "workload,dtype,batch_size,total_samples,throughput,latency_p50,latency_p99,"
         << "energy_total,avg_power,achieved_gflops,utilization_pct,"
         << "arith_intensity,phase_staging,phase_compute,phase_output,tta_sec\n";

    fout << std::fixed << std::setprecision(6);
    fout << row.workload << ","
         << row.dtype << ","
         << row.batch_size << ","
         << row.total_samples << ","
         << row.throughput << ","
         << row.latency_p50 << ","
         << row.latency_p99 << ","
         << row.energy_total << ","
         << row.avg_power << ","
         << row.achieved_gflops << ","
         << row.utilization_pct << ","
         << row.arith_intensity << ","
         << row.phase_staging << ","
         << row.phase_compute << ","
         << row.phase_output << ","
         << row.tta_sec << "\n";

    fout.close();
    std::cout << "perf_results.csv written to: " << path << "\n";
}

// ===========================================================================
// main
// ===========================================================================

int main(int argc, char** argv) {
    std::string train_csv = "mnist_train.csv";
    std::string test_csv  = "mnist_test.csv";
    std::string weights   = "cnn_weights.bin";
    int batch_size        = 64;
    std::string perf_out  = "results/gpu_cuda/mnist_cnn/perf_results.csv";
    int warmup            = 3;
    int timed_runs        = 5;

    if (argc >= 2) train_csv = argv[1];
    if (argc >= 3) test_csv = argv[2];
    if (argc >= 4) weights = argv[3];
    if (argc >= 5) batch_size = std::stoi(argv[4]);
    if (argc >= 6) perf_out = argv[5];
    if (argc >= 7) warmup = std::stoi(argv[6]);
    if (argc >= 8) timed_runs = std::stoi(argv[7]);

    int device = 0;
    CHECK_CUDA(cudaSetDevice(device));

    cudaDeviceProp prop{};
    CHECK_CUDA(cudaGetDeviceProperties(&prop, device));

    std::cout << "=== gen_perf_results (MNIST CNN) ===\n"
              << "GPU : " << prop.name << "\n"
              << "Train CSV : " << train_csv << "\n"
              << "Test CSV : " << test_csv << "\n"
              << "Weights : " << weights << "\n"
              << "Batch size : " << batch_size << "\n"
              << "Warmup runs : " << warmup << "\n"
              << "Timed runs : " << timed_runs << "\n\n";

#ifdef USE_NVML
    std::cout << "[power] Backend: NVML\n";
#else
    std::cout << "[power] Backend: nvidia-smi subprocess\n";
#endif

    Dataset train_ds = load_mnist_csv(train_csv);
    Dataset test_ds  = load_mnist_csv(test_csv);
    Dataset combined = concat_datasets(train_ds, test_ds);

    std::cout << "Combined inference pool: " << combined.size << " samples "
              << "(train=" << train_ds.size << " + test=" << test_ds.size << ")\n";

    CnnParams params;
    BatchBuffers buffers;
    init_params(params);
    alloc_batch_buffers(buffers, batch_size);
    load_weights(params, weights);

    PerfRow row = benchmark(
        "mnist_cnn_gpu_infer",
        combined,
        params,
        buffers,
        batch_size,
        warmup,
        timed_runs,
        prop,
        device
    );

    std::cout << "\nSingle-image latency benchmark on test set...\n";
    LatencyMetrics single = benchmark_single_image_latency(test_ds, params, buffers);
    std::cout << std::fixed << std::setprecision(4)
              << " mean=" << single.mean_ms
              << " ms p50=" << single.p50_ms
              << " ms p95=" << single.p95_ms << " ms\n";

    write_perf_csv(perf_out, row);

    free_batch_buffers(buffers);
    free_params(params);
    CHECK_CUDA(cudaDeviceReset());
    return 0;
}