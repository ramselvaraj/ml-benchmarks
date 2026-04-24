// gen_perf_results.cu
// Pure inference performance benchmark for the GPU perceptron.
// Loads pre-trained weights produced by gen_acc_results, then runs
// 3-phase timed inference (phase_staging / phase_compute / phase_output)
// over ONE combined inference dataset = train + test, then writes perf_results.csv.
//
// Usage:
//   ./gen_perf  <train_csv> <test_csv> [weights.bin] [batch_size]
//               [perf_results.csv] [warmup_runs] [timed_runs]
//
// Defaults:
//   train_csv         = iris_train_80k.csv
//   test_csv          = iris_test_20k.csv
//   weights.bin       = perceptron_weights.bin
//   batch_size        = 16
//   perf_results.csv  = results/gpu_cuda/perceptron/perf_results.csv
//   warmup_runs       = 3   (full dataset passes, not timed)
//   timed_runs        = 5   (full dataset passes, averaged)
//
// Windows + NVML build example:
//   nvcc -DUSE_NVML gen_perf_results.cu -o gen_perf.exe ^
//     -I"%CUDA_PATH%\\include" "%CUDA_PATH%\\lib\\x64\\nvml.lib"

#include "perceptron_model.cuh"

#include <filesystem>
#include <thread>
#include <atomic>
#include <numeric>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <chrono>
#include <cstdlib>

#ifdef USE_NVML
#include <nvml.h>

struct NvmlPoller {
    std::atomic<bool>  running{false};
    std::thread        thread;
    std::vector<float> power_samples_w; // watts
    int                device_index = 0;
    bool               init_ok = false;
    bool               handle_ok = false;

    void start(int dev) {
        device_index = dev;
        running = false;
        init_ok = false;
        handle_ok = false;
        power_samples_w.clear();

        nvmlReturn_t st = nvmlInit();
        if (st != NVML_SUCCESS) {
            std::cerr << "[NVML] nvmlInit failed: " << nvmlErrorString(st) << "\n";
            return;
        }
        init_ok = true;

        nvmlDevice_t dev_handle{};
        st = nvmlDeviceGetHandleByIndex(device_index, &dev_handle);
        if (st != NVML_SUCCESS) {
            std::cerr << "[NVML] nvmlDeviceGetHandleByIndex failed: "
                      << nvmlErrorString(st) << "\n";
            return;
        }
        handle_ok = true;

        running = true;
        thread = std::thread([this, dev_handle]() {
            while (running.load()) {
                unsigned int mw = 0;
                nvmlReturn_t q = nvmlDeviceGetPowerUsage(dev_handle, &mw);
                if (q == NVML_SUCCESS) {
                    power_samples_w.push_back(static_cast<float>(mw) / 1000.0f);
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
        return !power_samples_w.empty();
    }

    double mean_power_w() const {
        if (power_samples_w.empty()) return 0.0;
        return std::accumulate(power_samples_w.begin(), power_samples_w.end(), 0.0) /
               static_cast<double>(power_samples_w.size());
    }
};
#endif // USE_NVML

// ---------------------------------------------------------------------------
// PerfRow — one row of perf_results.csv
// ---------------------------------------------------------------------------

struct PerfRow {
    std::string workload;
    std::string dtype;
    int         batch_size      = 0;
    double      throughput      = 0.0; // samples/s
    double      latency_p50     = 0.0; // ms per sample
    double      latency_p99     = 0.0; // ms per sample
    double      energy_total    = 0.0; // Joules (average per timed full-dataset pass)
    double      avg_power       = 0.0; // Watts
    double      achieved_gflops = 0.0;
    double      utilization_pct = 0.0; // 0.0-1.0
    double      arith_intensity = 0.0;
    double      phase_staging   = 0.0; // ms
    double      phase_compute   = 0.0; // ms
    double      phase_output    = 0.0; // ms
    std::string tta_sec         = "N/A";
};

// ---------------------------------------------------------------------------
// Arithmetic intensity (static for this model)
// ops per sample = 2*NUM_FEATURES (MAC) + 1 (bias add) + 1 (sign) ~ 2*F
// DRAM bytes per sample = NUM_FEATURES * sizeof(float) input
//                       + (NUM_FEATURES+1) * sizeof(float) params (once)
// Conservative: count full param reload once per pass
// ---------------------------------------------------------------------------

static double compute_arith_intensity(int N) {
    double ops    = static_cast<double>(N) * (2.0 * NUM_FEATURES + 1.0);
    double dram_b = static_cast<double>(N) * NUM_FEATURES * sizeof(float)
                  + (NUM_FEATURES + 1) * sizeof(float);
    return ops / dram_b;
}

static double device_peak_gflops(const cudaDeviceProp& prop, int device) {
    int clock_khz = 0;
    CHECK_CUDA(cudaDeviceGetAttribute(&clock_khz, cudaDevAttrClockRate, device));
    double clock_ghz = clock_khz * 1e-6; // kHz -> GHz
    double fp32_units_per_sm = 64.0;     // safe lower-bound for many NVIDIA architectures
    return prop.multiProcessorCount * fp32_units_per_sm * 2.0 * clock_ghz;
}

// ---------------------------------------------------------------------------
// Merge datasets (same feature layout expected)
// ---------------------------------------------------------------------------

static Dataset merge_datasets(const Dataset& a, const Dataset& b) {
    Dataset out;
    out.size = a.size + b.size;

    out.x.reserve(static_cast<size_t>(out.size) * NUM_FEATURES);
    out.y.reserve(static_cast<size_t>(out.size));

    out.x.insert(out.x.end(), a.x.begin(), a.x.end());
    out.x.insert(out.x.end(), b.x.begin(), b.x.end());

    out.y.insert(out.y.end(), a.y.begin(), a.y.end());
    out.y.insert(out.y.end(), b.y.begin(), b.y.end());

    return out;
}

// ---------------------------------------------------------------------------
// Single benchmark run over one dataset (3 phases, CUDA Events)
// Returns per-sample latency vector (ms) and fills phase timings
// ---------------------------------------------------------------------------

static std::vector<float> run_inference_pass(
    const Dataset& ds,
    PerceptronParams& params,
    BatchBuffers& buffers,
    int batch_size,
    double& out_staging_ms,
    double& out_compute_ms,
    double& out_output_ms
) {
    float* h_batch_x = nullptr;
    int*   h_batch_y = nullptr;

    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_batch_x),
        bytes_of(static_cast<size_t>(batch_size) * NUM_FEATURES)));
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_batch_y),
        sizeof(int) * batch_size));

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

    for (int b = 0; b < num_batches; ++b) {
        int start = b * batch_size;
        int B = std::min(batch_size, ds.size - start);

        copy_contiguous_batch(ds, start, B, h_batch_x, h_batch_y);

        float ms = 0.0f;

        // Phase 1: staging (H2D)
        CHECK_CUDA(cudaDeviceSynchronize());
        CHECK_CUDA(cudaEventRecord(ev0));
        CHECK_CUDA(cudaMemcpy(
            buffers.d_x,
            h_batch_x,
            bytes_of(static_cast<size_t>(B) * NUM_FEATURES),
            cudaMemcpyHostToDevice));
        CHECK_CUDA(cudaMemcpy(
            buffers.d_y,
            h_batch_y,
            sizeof(int) * B,
            cudaMemcpyHostToDevice));
        CHECK_CUDA(cudaEventRecord(ev1));
        CHECK_CUDA(cudaEventSynchronize(ev1));
        CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
        out_staging_ms += ms;

        // Phase 2: compute (kernels)
        CHECK_CUDA(cudaDeviceSynchronize());
        CHECK_CUDA(cudaEventRecord(ev0));
        forward_pass(params, buffers, B);
        metric_pass(buffers, B);
        CHECK_CUDA(cudaEventRecord(ev1));
        CHECK_CUDA(cudaEventSynchronize(ev1));
        CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
        out_compute_ms += ms;

        float sample_ms = ms / static_cast<float>(B);
        for (int i = 0; i < B; ++i) per_sample_ms.push_back(sample_ms);

        // Phase 3: output (D2H)
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
    CHECK_CUDA(cudaFreeHost(h_batch_x));
    CHECK_CUDA(cudaFreeHost(h_batch_y));

    return per_sample_ms;
}

// ---------------------------------------------------------------------------
// Benchmark one dataset: warmup + N timed runs, aggregate stats
// ---------------------------------------------------------------------------

static PerfRow benchmark_dataset(
    const std::string&    workload_name,
    const Dataset&        ds,
    PerceptronParams&     params,
    BatchBuffers&         buffers,
    int                   batch_size,
    int                   warmup_runs,
    int                   timed_runs,
    const cudaDeviceProp& prop,
    int                   device
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

    std::vector<double> staging_vec, compute_vec, output_vec;
    std::vector<float>  all_sample_latencies;

#ifdef USE_NVML
    NvmlPoller poller;
    poller.start(device);
#endif

    auto wall_start = std::chrono::high_resolution_clock::now();

    for (int r = 0; r < timed_runs; ++r) {
        double s, c, o;
        std::vector<float> lats =
            run_inference_pass(ds, params, buffers, batch_size, s, c, o);

        staging_vec.push_back(s);
        compute_vec.push_back(c);
        output_vec.push_back(o);

        if (r == 0) {
            all_sample_latencies = lats;
        }
    }

    CHECK_CUDA(cudaDeviceSynchronize());
    auto wall_end = std::chrono::high_resolution_clock::now();
    double wall_ms =
        std::chrono::duration<double, std::milli>(wall_end - wall_start).count();

#ifdef USE_NVML
    poller.stop();
    double mean_power = poller.has_samples() ? poller.mean_power_w() : 0.0;
#else
    double mean_power = 0.0;
#endif

    auto mean_vec = [](const std::vector<double>& v) -> double {
        if (v.empty()) return 0.0;
        return std::accumulate(v.begin(), v.end(), 0.0) /
               static_cast<double>(v.size());
    };

    double avg_staging_ms = mean_vec(staging_vec);
    double avg_compute_ms = mean_vec(compute_vec);
    double avg_output_ms  = mean_vec(output_vec);
    double avg_wall_ms    = wall_ms / static_cast<double>(timed_runs);

    double throughput = (avg_compute_ms > 0.0)
        ? (1000.0 * static_cast<double>(ds.size) / avg_compute_ms)
        : 0.0;

    float p50 = all_sample_latencies.empty() ? 0.0f : percentile(all_sample_latencies, 0.50);
    float p99 = all_sample_latencies.empty() ? 0.0f : percentile(all_sample_latencies, 0.99);

    double total_ops = static_cast<double>(ds.size) * (2.0 * NUM_FEATURES + 1.0);
    double compute_sec = avg_compute_ms * 1e-3;
    double achieved_gflops =
        (compute_sec > 0.0) ? ((total_ops * 1e-9) / compute_sec) : 0.0;

    double peak_gflops = device_peak_gflops(prop, device);
    double utilization =
        (peak_gflops > 0.0) ? (achieved_gflops / peak_gflops) : 0.0;

    double arith_intensity = compute_arith_intensity(ds.size);

    // Average energy per timed full-dataset pass.
    double energy_total = mean_power * (avg_wall_ms * 1e-3);

    PerfRow row;
    row.workload = workload_name;
    row.dtype = "fp32";
    row.batch_size = batch_size;
    row.throughput = throughput;
    row.latency_p50 = p50;
    row.latency_p99 = p99;
    row.energy_total = energy_total;
    row.avg_power = mean_power;
    row.achieved_gflops = achieved_gflops;
    row.utilization_pct = utilization;
    row.arith_intensity = arith_intensity;
    row.phase_staging = avg_staging_ms;
    row.phase_compute = avg_compute_ms;
    row.phase_output = avg_output_ms;
    row.tta_sec = "N/A";

#ifdef USE_NVML
    if (!poller.active()) {
        std::cerr << "[NVML] Power sampling inactive. avg_power and energy_total will be 0.\n";
    } else if (!poller.has_samples()) {
        std::cerr << "[NVML] No power samples collected. Your GPU/driver may not expose power draw.\n";
    }
#endif

    return row;
}

// ---------------------------------------------------------------------------
// Write perf_results.csv
// ---------------------------------------------------------------------------

static void write_perf_csv(const std::string& path, const std::vector<PerfRow>& rows) {
    std::filesystem::path p(path);
    if (p.has_parent_path()) {
        std::filesystem::create_directories(p.parent_path());
    }

    std::ofstream fout(path);
    if (!fout) {
        std::cerr << "Cannot open output file: " << path << std::endl;
        std::exit(EXIT_FAILURE);
    }

    fout << "workload,dtype,batch_size,throughput,latency_p50,latency_p99,"
         << "energy_total,avg_power,achieved_gflops,utilization_pct,"
         << "arith_intensity,phase_staging,phase_compute,phase_output,tta_sec\n";

    fout << std::fixed << std::setprecision(6);
    for (const auto& r : rows) {
        fout << r.workload << ","
             << r.dtype << ","
             << r.batch_size << ","
             << r.throughput << ","
             << r.latency_p50 << ","
             << r.latency_p99 << ","
             << r.energy_total << ","
             << r.avg_power << ","
             << r.achieved_gflops << ","
             << r.utilization_pct << ","
             << r.arith_intensity << ","
             << r.phase_staging << ","
             << r.phase_compute << ","
             << r.phase_output << ","
             << r.tta_sec << "\n";
    }

    fout.close();
    std::cout << "perf_results.csv written to: " << path << "\n";
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

int main(int argc, char** argv) {
    std::string train_csv  = "iris_train_80k.csv";
    std::string test_csv   = "iris_test_20k.csv";
    std::string weights_bin = "perceptron_weights.bin";
    int batch_size         = 16;
    std::string perf_out   = "results/gpu_cuda/perceptron/perf_results.csv";
    int warmup_runs        = 3;
    int timed_runs         = 5;

    if (argc >= 2) train_csv   = argv[1];
    if (argc >= 3) test_csv    = argv[2];
    if (argc >= 4) weights_bin = argv[3];
    if (argc >= 5) batch_size  = std::stoi(argv[4]);
    if (argc >= 6) perf_out    = argv[5];
    if (argc >= 7) warmup_runs = std::stoi(argv[6]);
    if (argc >= 8) timed_runs  = std::stoi(argv[7]);

    int device = 0;
    CHECK_CUDA(cudaSetDevice(device));

    cudaDeviceProp prop{};
    CHECK_CUDA(cudaGetDeviceProperties(&prop, device));

    std::cout << "=== gen_perf_results ===\n"
              << "GPU : " << prop.name << "\n"
              << "Train CSV : " << train_csv << "\n"
              << "Test CSV : " << test_csv << "\n"
              << "Weights : " << weights_bin << "\n"
              << "Batch size : " << batch_size << "\n"
              << "Warmup runs : " << warmup_runs << "\n"
              << "Timed runs : " << timed_runs << "\n\n";

#ifdef USE_NVML
    std::cout << "[NVML] Power sampling enabled at compile time.\n";
#else
    std::cout << "[NVML] Power sampling disabled (compile with -DUSE_NVML and link nvml.lib).\n";
#endif

    // Load & standardize — fit scaler on train only, then apply to both.
    BinaryClassInfo class_info;
    Dataset train_ds = load_binary_iris_csv(train_csv, class_info, true);
    Dataset test_ds  = load_binary_iris_csv(test_csv, class_info, false);

    StandardizationStats stats = fit_standardization(train_ds);
    apply_standardization(train_ds, stats);
    apply_standardization(test_ds, stats);

    print_dataset_summary(train_ds, test_ds, class_info);

    Dataset infer_ds = merge_datasets(train_ds, test_ds);

    std::cout << "\nCombined inference set size: " << infer_ds.size
              << " samples (" << train_ds.size << " train + "
              << test_ds.size << " test)\n";

    // Allocate GPU resources + load weights (no training)
    PerceptronParams params;
    BatchBuffers buffers;
    init_params(params);
    alloc_batch_buffers(buffers, batch_size);
    load_weights(params, weights_bin);

    // Single-sample latency benchmark on the combined inference set
    std::cout << "\nRunning single-sample latency benchmark on combined inference set...\n";
    LatencyMetrics single_lat = benchmark_single_sample_latency(infer_ds, params, buffers);
    std::cout << std::fixed << std::setprecision(4)
              << " p50=" << single_lat.p50_ms
              << " ms p95=" << single_lat.p95_ms
              << " ms mean=" << single_lat.mean_ms << " ms\n";

    // Benchmark the combined inference set once
    PerfRow infer_row = benchmark_dataset(
        "iris_perceptron_full_infer",
        infer_ds,
        params,
        buffers,
        batch_size,
        warmup_runs,
        timed_runs,
        prop,
        device
    );

    // Override with more accurate single-sample measurements
    infer_row.latency_p50 = single_lat.p50_ms;
    infer_row.latency_p99 = single_lat.p95_ms; // keep same convention as original code

    // Print summary
    std::cout << std::fixed << std::setprecision(4)
              << "\n================ Performance Results ================\n"
              << "FULL INFERENCE SET (train + test):\n"
              << " throughput : " << infer_row.throughput << " samples/s\n"
              << " phase_staging : " << infer_row.phase_staging << " ms\n"
              << " phase_compute : " << infer_row.phase_compute << " ms\n"
              << " phase_output : " << infer_row.phase_output << " ms\n"
              << " latency_p50 : " << infer_row.latency_p50 << " ms\n"
              << " latency_p99 : " << infer_row.latency_p99 << " ms\n"
              << " avg_power : " << infer_row.avg_power << " W\n"
              << " energy_total : " << infer_row.energy_total << " J\n"
              << " achieved_gflops : " << infer_row.achieved_gflops << "\n"
              << " utilization : " << (infer_row.utilization_pct * 100.0) << "%\n";

    write_perf_csv(perf_out, {infer_row});

    free_batch_buffers(buffers);
    free_params(params);

    CHECK_CUDA(cudaDeviceReset());
    return 0;
}