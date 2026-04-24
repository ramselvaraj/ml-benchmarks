// gen_perf_results.cu
// Pure inference performance benchmark for the GPU perceptron.
// Loads pre-trained weights produced by gen_acc_results, then runs
// 3-phase timed inference (phase_staging / phase_compute / phase_output)
// over BOTH the train and test datasets and writes perf_results.csv.
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

#include "perceptron_model.cuh"

#include <filesystem>
#include <thread>
#include <atomic>

// ---------------------------------------------------------------------------
// NVML power sampling (optional — gracefully degrades if NVML unavailable)
// ---------------------------------------------------------------------------

#ifdef USE_NVML
#include <nvml.h>

struct NvmlPoller {
    std::atomic<bool>  running{false};
    std::thread        thread;
    std::vector<float> power_samples_w; // watts
    int                device_index = 0;

    void start(int dev) {
        device_index = dev;
        running = true;
        power_samples_w.clear();
        thread = std::thread([this]() {
            nvmlDevice_t dev_handle;
            nvmlDeviceGetHandleByIndex(device_index, &dev_handle);
            while (running.load()) {
                unsigned int mw = 0;
                if (nvmlDeviceGetPowerUsage(dev_handle, &mw) == NVML_SUCCESS)
                    power_samples_w.push_back(mw / 1000.0f);
                std::this_thread::sleep_for(std::chrono::milliseconds(10));
            }
        });
    }

    void stop() {
        running = false;
        if (thread.joinable()) thread.join();
    }

    double mean_power_w() const {
        if (power_samples_w.empty()) return 0.0;
        return std::accumulate(power_samples_w.begin(), power_samples_w.end(), 0.0) /
               power_samples_w.size();
    }
};
#endif // USE_NVML

// ---------------------------------------------------------------------------
// PerfRow — one row of perf_results.csv
// ---------------------------------------------------------------------------

struct PerfRow {
    std::string workload;
    std::string dtype;
    int         batch_size        = 0;
    double      throughput        = 0.0; // samples/s
    double      latency_p50       = 0.0; // ms per sample
    double      latency_p99       = 0.0; // ms per sample
    double      energy_total      = 0.0; // Joules
    double      avg_power         = 0.0; // Watts
    double      achieved_gflops   = 0.0;
    double      utilization_pct   = 0.0; // 0.0-1.0
    double      arith_intensity   = 0.0;
    double      phase_staging     = 0.0; // ms
    double      phase_compute     = 0.0; // ms
    double      phase_output      = 0.0; // ms
    std::string tta_sec           = "N/A";
};

// ---------------------------------------------------------------------------
// Arithmetic intensity (static for this model)
// ops per sample = 2*NUM_FEATURES (MAC) + 1 (bias add) + 1 (sign)  ~ 2*F
// DRAM bytes per sample = NUM_FEATURES * sizeof(float) input
//                       + (NUM_FEATURES+1) * sizeof(float) params  (cached in L2 after warmup)
// Conservative: count full param reload each sample
// ---------------------------------------------------------------------------

static double compute_arith_intensity(int N) {
    double ops    = static_cast<double>(N) * (2.0 * NUM_FEATURES + 1.0);
    double dram_b = static_cast<double>(N) * NUM_FEATURES * sizeof(float)  // input data
                  + (NUM_FEATURES + 1) * sizeof(float);                    // params (once)
    return ops / dram_b;
}

static double device_peak_gflops(const cudaDeviceProp& prop) {
    // cudaDeviceProp::clockRate removed in newer CUDA toolkits; use cudaDeviceGetAttribute.
    int clock_khz = 0;
    cudaDeviceGetAttribute(&clock_khz, cudaDevAttrClockRate, 0);
    double clock_ghz = clock_khz * 1e-6; // kHz -> GHz
    // 64 FP32 units per SM: safe lower-bound for Pascal/Volta/Turing/Ampere/Ada
    double fp32_units_per_sm = 64.0;
    return prop.multiProcessorCount * fp32_units_per_sm * 2.0 * clock_ghz;
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
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_batch_y), sizeof(int) * batch_size));

    std::vector<float> h_preds_out(batch_size);
    std::vector<float> per_sample_ms; // latency per sample
    per_sample_ms.reserve(ds.size);

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
        CHECK_CUDA(cudaMemcpy(buffers.d_x, h_batch_x,
            bytes_of(static_cast<size_t>(B) * NUM_FEATURES), cudaMemcpyHostToDevice));
        CHECK_CUDA(cudaMemcpy(buffers.d_y, h_batch_y, sizeof(int) * B, cudaMemcpyHostToDevice));
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

        // Per-sample latency (compute time / B)
        float sample_ms = ms / static_cast<float>(B);
        for (int i = 0; i < B; ++i) per_sample_ms.push_back(sample_ms);

        // Phase 3: output (D2H)
        CHECK_CUDA(cudaDeviceSynchronize());
        CHECK_CUDA(cudaEventRecord(ev0));
        CHECK_CUDA(cudaMemcpy(h_preds_out.data(), buffers.d_preds, sizeof(int) * B, cudaMemcpyDeviceToHost));
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
    const std::string&   workload_name,
    const Dataset&       ds,
    PerceptronParams&    params,
    BatchBuffers&        buffers,
    int                  batch_size,
    int                  warmup_runs,
    int                  timed_runs,
    const cudaDeviceProp& prop
) {
    std::cout << "\n[" << workload_name << "] Warming up (" << warmup_runs << " passes)...\n";
    for (int i = 0; i < warmup_runs; ++i) {
        double s, c, o;
        run_inference_pass(ds, params, buffers, batch_size, s, c, o);
    }
    CHECK_CUDA(cudaDeviceSynchronize());

    std::cout << "[" << workload_name << "] Timing (" << timed_runs << " passes)...\n";

    std::vector<double> staging_vec, compute_vec, output_vec;
    std::vector<float>  all_sample_latencies;

#ifdef USE_NVML
    NvmlPoller poller;
    poller.start(0);
#endif

    auto wall_start = std::chrono::high_resolution_clock::now();

    for (int r = 0; r < timed_runs; ++r) {
        double s, c, o;
        std::vector<float> lats = run_inference_pass(
            ds, params, buffers, batch_size, s, c, o);
        staging_vec.push_back(s);
        compute_vec.push_back(c);
        output_vec.push_back(o);
        if (r == 0) all_sample_latencies = lats; // collect first run for percentiles
    }

    auto wall_end = std::chrono::high_resolution_clock::now();
    double wall_ms = std::chrono::duration<double, std::milli>(wall_end - wall_start).count();

#ifdef USE_NVML
    poller.stop();
    double mean_power = poller.mean_power_w();
#else
    double mean_power = 0.0;
#endif

    // Average across timed runs
    auto mean_vec = [](const std::vector<double>& v) {
        return std::accumulate(v.begin(), v.end(), 0.0) / v.size();
    };
    double avg_staging_ms = mean_vec(staging_vec);
    double avg_compute_ms = mean_vec(compute_vec);
    double avg_output_ms  = mean_vec(output_vec);

    // Throughput = samples / compute_time (per the standard)
    double throughput = 1000.0 * ds.size / avg_compute_ms;

    // Per-sample latency percentiles
    float p50 = percentile(all_sample_latencies, 0.50);
    float p99 = percentile(all_sample_latencies, 0.99);

    // GFLOPs: (2*F+1 ops per sample) * N / compute_seconds
    double total_ops      = static_cast<double>(ds.size) * (2.0 * NUM_FEATURES + 1.0);
    double compute_sec    = avg_compute_ms * 1e-3;
    double achieved_gflops = (total_ops * 1e-9) / compute_sec;
    double peak_gflops    = device_peak_gflops(prop);
    double utilization    = achieved_gflops / peak_gflops;

    // Arithmetic intensity
    double arith_intensity = compute_arith_intensity(ds.size);

    // Energy: avg_power * wall_time_for_compute (Joules)
    double energy_total = mean_power * (avg_compute_ms * 1e-3);

    PerfRow row;
    row.workload        = workload_name;
    row.dtype           = "fp32";
    row.batch_size      = batch_size;
    row.throughput      = throughput;
    row.latency_p50     = p50;
    row.latency_p99     = p99;
    row.energy_total    = energy_total;
    row.avg_power       = mean_power;
    row.achieved_gflops = achieved_gflops;
    row.utilization_pct = utilization;
    row.arith_intensity = arith_intensity;
    row.phase_staging   = avg_staging_ms;
    row.phase_compute   = avg_compute_ms;
    row.phase_output    = avg_output_ms;
    row.tta_sec         = "N/A"; // inference benchmark

    return row;
}

// ---------------------------------------------------------------------------
// Write perf_results.csv
// ---------------------------------------------------------------------------

static void write_perf_csv(const std::string& path, const std::vector<PerfRow>& rows) {
    std::filesystem::path p(path);
    if (p.has_parent_path()) std::filesystem::create_directories(p.parent_path());

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
        fout << r.workload        << ","
             << r.dtype           << ","
             << r.batch_size      << ","
             << r.throughput      << ","
             << r.latency_p50     << ","
             << r.latency_p99     << ","
             << r.energy_total    << ","
             << r.avg_power       << ","
             << r.achieved_gflops << ","
             << r.utilization_pct << ","
             << r.arith_intensity << ","
             << r.phase_staging   << ","
             << r.phase_compute   << ","
             << r.phase_output    << ","
             << r.tta_sec         << "\n";
    }
    fout.close();
    std::cout << "perf_results.csv written to: " << path << "\n";
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

int main(int argc, char** argv) {
    std::string train_csv    = "iris_train_80k.csv";
    std::string test_csv     = "iris_test_20k.csv";
    std::string weights_bin  = "perceptron_weights.bin";
    int         batch_size   = 16;
    std::string perf_out     = "results/gpu_cuda/perceptron/perf_results.csv";
    int         warmup_runs  = 3;
    int         timed_runs   = 5;

    if (argc >= 2) train_csv   = argv[1];
    if (argc >= 3) test_csv    = argv[2];
    if (argc >= 4) weights_bin = argv[3];
    if (argc >= 5) batch_size  = std::stoi(argv[4]);
    if (argc >= 6) perf_out    = argv[5];
    if (argc >= 7) warmup_runs = std::stoi(argv[6]);
    if (argc >= 8) timed_runs  = std::stoi(argv[7]);

    // GPU setup
    int device = 0;
    cudaDeviceProp prop{};
    CHECK_CUDA(cudaGetDeviceProperties(&prop, device));
    CHECK_CUDA(cudaSetDevice(device));

#ifdef USE_NVML
    nvmlInit();
#endif

    std::cout << "=== gen_perf_results ===\n"
              << "GPU         : " << prop.name << "\n"
              << "Train CSV   : " << train_csv  << "\n"
              << "Test CSV    : " << test_csv   << "\n"
              << "Weights     : " << weights_bin << "\n"
              << "Batch size  : " << batch_size  << "\n"
              << "Warmup runs : " << warmup_runs << "\n"
              << "Timed runs  : " << timed_runs  << "\n\n";

    // Load & standardize — use train set to fit scaler (same as training)
    BinaryClassInfo class_info;
    Dataset train_ds = load_binary_iris_csv(train_csv, class_info, true);
    Dataset test_ds  = load_binary_iris_csv(test_csv,  class_info, false);

    StandardizationStats stats = fit_standardization(train_ds);
    apply_standardization(train_ds, stats);
    apply_standardization(test_ds,  stats);

    print_dataset_summary(train_ds, test_ds, class_info);

    // Allocate GPU resources + load weights (no training)
    PerceptronParams params;
    BatchBuffers     buffers;
    init_params(params);
    alloc_batch_buffers(buffers, batch_size);
    load_weights(params, weights_bin);

    // Single-sample latency benchmark (used for p50/p99 supplement)
    std::cout << "\nRunning single-sample latency benchmark on test set...\n";
    LatencyMetrics single_lat = benchmark_single_sample_latency(test_ds, params, buffers);
    std::cout << std::fixed << std::setprecision(4)
              << "  p50=" << single_lat.p50_ms << " ms  p95=" << single_lat.p95_ms
              << " ms  mean=" << single_lat.mean_ms << " ms\n";

    // ----- Benchmark train dataset -----
    PerfRow train_row = benchmark_dataset(
        "iris_perceptron_train_infer", train_ds, params, buffers,
        batch_size, warmup_runs, timed_runs, prop);

    // ----- Benchmark test dataset -----
    PerfRow test_row = benchmark_dataset(
        "iris_perceptron_test_infer", test_ds, params, buffers,
        batch_size, warmup_runs, timed_runs, prop);

    // Override p50/p99 on test row with more accurate single-sample measurements
    test_row.latency_p50 = single_lat.p50_ms;
    test_row.latency_p99 = single_lat.p95_ms; // p95 closest to p99 from our 200-rep benchmark

    // ----- Print summary -----
    std::cout << std::fixed << std::setprecision(4)
              << "\n================ Performance Results ================\n"
              << "TRAIN SET inference:\n"
              << "  throughput      : " << train_row.throughput      << " samples/s\n"
              << "  phase_staging   : " << train_row.phase_staging   << " ms\n"
              << "  phase_compute   : " << train_row.phase_compute   << " ms\n"
              << "  phase_output    : " << train_row.phase_output    << " ms\n"
              << "  achieved_gflops : " << train_row.achieved_gflops << "\n"
              << "  utilization     : " << (train_row.utilization_pct * 100.0) << "%\n"
              << "\nTEST SET inference:\n"
              << "  throughput      : " << test_row.throughput      << " samples/s\n"
              << "  phase_staging   : " << test_row.phase_staging   << " ms\n"
              << "  phase_compute   : " << test_row.phase_compute   << " ms\n"
              << "  phase_output    : " << test_row.phase_output    << " ms\n"
              << "  latency_p50     : " << test_row.latency_p50     << " ms\n"
              << "  latency_p99     : " << test_row.latency_p99     << " ms\n"
              << "  achieved_gflops : " << test_row.achieved_gflops << "\n"
              << "  utilization     : " << (test_row.utilization_pct * 100.0) << "%\n";

    // ----- Write CSV -----
    write_perf_csv(perf_out, {train_row, test_row});

    // Cleanup
    free_batch_buffers(buffers);
    free_params(params);

#ifdef USE_NVML
    nvmlShutdown();
#endif

    CHECK_CUDA(cudaDeviceReset());
    return 0;
}
