// gen_acc_results.cu
// Trains the GPU perceptron on iris data and writes acc_results.csv.
// Also saves trained weights to a .bin file for use by gen_perf_results.
//
// Usage:
//   ./gen_acc  <train_csv> <test_csv> [epochs] [batch_size] [lr]
//              [weights_out.bin] [acc_results.csv]
//
// Defaults:
//   train_csv        = iris_train_80k.csv
//   test_csv         = iris_test_20k.csv
//   epochs           = 30
//   batch_size       = 16
//   lr               = 0.10
//   weights_out.bin  = perceptron_weights.bin
//   acc_results.csv  = results/gpu_cuda/perceptron/acc_results.csv

#include "perceptron_model.cuh"

#include <filesystem>

// Compute MSE between two float vectors
static double compute_mse(const std::vector<float>& a, const std::vector<float>& b) {
    if (a.size() != b.size() || a.empty()) return -1.0;
    double sum = 0.0;
    for (size_t i = 0; i < a.size(); ++i) {
        double diff = a[i] - b[i];
        sum += diff * diff;
    }
    return sum / a.size();
}

// Run inference and collect raw float scores for MSE_Golden comparison
static std::vector<float> collect_scores(
    const Dataset& ds, PerceptronParams& params, BatchBuffers& buffers, int batch_size
) {
    float* h_batch_x = nullptr;
    int*   h_batch_y = nullptr;
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_batch_x),
        bytes_of(static_cast<size_t>(batch_size) * NUM_FEATURES)));
    CHECK_CUDA(cudaMallocHost(reinterpret_cast<void**>(&h_batch_y), sizeof(int) * batch_size));

    std::vector<float> all_scores;
    all_scores.reserve(ds.size);
    std::vector<float> h_scores(batch_size);

    int num_batches = (ds.size + batch_size - 1) / batch_size;
    for (int b = 0; b < num_batches; ++b) {
        int start = b * batch_size;
        int B = std::min(batch_size, ds.size - start);
        copy_contiguous_batch(ds, start, B, h_batch_x, h_batch_y);
        CHECK_CUDA(cudaMemcpy(buffers.d_x, h_batch_x,
            bytes_of(static_cast<size_t>(B) * NUM_FEATURES), cudaMemcpyHostToDevice));
        forward_pass(params, buffers, B);
        CHECK_CUDA(cudaDeviceSynchronize());
        CHECK_CUDA(cudaMemcpy(h_scores.data(), buffers.d_scores, bytes_of(B), cudaMemcpyDeviceToHost));
        for (int i = 0; i < B; ++i) all_scores.push_back(h_scores[i]);
    }

    CHECK_CUDA(cudaFreeHost(h_batch_x));
    CHECK_CUDA(cudaFreeHost(h_batch_y));
    return all_scores;
}

// Load golden reference scores from a binary float file (written by cpu_python run)
// Returns empty vector if file does not exist (MSE_Golden will be reported as N/A)
static std::vector<float> load_golden_reference(const std::string& path, int expected_size) {
    FILE* f = fopen(path.c_str(), "rb");
    if (!f) {
        std::cout << "Golden reference file not found (" << path << "). MSE_Golden will be N/A.\n";
        return {};
    }
    std::vector<float> ref(expected_size);
    size_t read = fread(ref.data(), sizeof(float), expected_size, f);
    fclose(f);
    if (static_cast<int>(read) != expected_size) {
        std::cerr << "Warning: golden reference size mismatch (read=" << read
                  << ", expected=" << expected_size << "). MSE_Golden will be N/A.\n";
        return {};
    }
    std::cout << "Loaded golden reference from " << path << " (" << read << " scores)\n";
    return ref;
}

static void ensure_parent_dirs(const std::string& path) {
    std::filesystem::path p(path);
    if (p.has_parent_path()) {
        std::filesystem::create_directories(p.parent_path());
    }
}

int main(int argc, char** argv) {
    std::string train_csv       = "iris_train_80k.csv";
    std::string test_csv        = "iris_test_20k.csv";
    int         epochs          = 30;
    int         batch_size      = 16;
    float       lr              = 0.10f;
    std::string weights_out     = "perceptron_weights.bin";
    std::string acc_out         = "results/gpu_cuda/perceptron/acc_results.csv";
    // Optional: path to CPU golden reference scores (.bin of float32 scores for test set)
    std::string golden_ref      = "results/cpu_python/perceptron/golden_scores.bin";

    if (argc >= 2) train_csv   = argv[1];
    if (argc >= 3) test_csv    = argv[2];
    if (argc >= 4) epochs      = std::stoi(argv[3]);
    if (argc >= 5) batch_size  = std::stoi(argv[4]);
    if (argc >= 6) lr          = std::stof(argv[5]);
    if (argc >= 7) weights_out = argv[6];
    if (argc >= 8) acc_out     = argv[7];
    if (argc >= 9) golden_ref  = argv[8];

    // GPU setup
    int device = 0;
    cudaDeviceProp prop{};
    CHECK_CUDA(cudaGetDeviceProperties(&prop, device));
    CHECK_CUDA(cudaSetDevice(device));

    std::cout << "=== gen_acc_results ===\n"
              << "GPU        : " << prop.name << "\n"
              << "Train CSV  : " << train_csv << "\n"
              << "Test CSV   : " << test_csv  << "\n"
              << "Epochs=" << epochs << "  batch_size=" << batch_size << "  lr=" << lr << "\n\n";

    // Load & standardize data
    BinaryClassInfo class_info;
    Dataset train_ds = load_binary_iris_csv(train_csv, class_info, true);
    Dataset test_ds  = load_binary_iris_csv(test_csv,  class_info, false);

    StandardizationStats stats = fit_standardization(train_ds);
    apply_standardization(train_ds, stats);
    apply_standardization(test_ds,  stats);

    print_dataset_summary(train_ds, test_ds, class_info);
    print_model_info(batch_size);

    // Allocate GPU resources
    PerceptronParams params;
    BatchBuffers     buffers;
    init_params(params);
    alloc_batch_buffers(buffers, batch_size);

    // ----- Training -----
    EvalMetrics final_test_metrics;
    PhaseTiming timing = train(
        train_ds, test_ds, params, buffers, epochs, batch_size, lr, final_test_metrics);

    // ----- Post-training eval on train set -----
    std::cout << "\nEvaluating on train set...\n";
    EvalMetrics train_metrics = evaluate(train_ds, params, buffers, batch_size);

    print_learned_parameters(params);

    // ----- Save weights for gen_perf_results -----
    ensure_parent_dirs(weights_out);
    save_weights(params, weights_out);

    // ----- MSE_Golden -----
    std::vector<float> gpu_scores   = collect_scores(test_ds, params, buffers, batch_size);
    std::vector<float> golden_scores = load_golden_reference(golden_ref, test_ds.size);
    double mse_golden = compute_mse(gpu_scores, golden_scores);

    // Detect convergence epoch (first epoch where test acc >= final test acc, crude heuristic).
    // The train() loop already re-evaluates test each epoch; we don't store the per-epoch history
    // here to keep it lean. Report total epochs trained as Conv_Epochs if no separate tracking.
    int conv_epochs = epochs; // conservative: report full epochs

    // ----- Write acc_results.csv -----
    ensure_parent_dirs(acc_out);
    std::ofstream fout(acc_out);
    if (!fout) {
        std::cerr << "Cannot open output file: " << acc_out << std::endl;
        std::exit(EXIT_FAILURE);
    }

    // Header
    fout << "Model,Precision,Train_Acc,Val_Acc,Final_Loss,Conv_Epochs,MSE_Golden\n";

    // Row
    fout << std::fixed << std::setprecision(6);
    fout << "perceptron_gpu"           << ","   // Model
         << "fp32"                      << ","   // Precision
         << train_metrics.accuracy      << ","   // Train_Acc
         << final_test_metrics.accuracy << ","   // Val_Acc
         << final_test_metrics.loss     << ","   // Final_Loss
         << conv_epochs                 << ",";  // Conv_Epochs

    if (mse_golden >= 0.0)
        fout << mse_golden;
    else
        fout << "N/A";
    fout << "\n";

    fout.close();
    std::cout << "\nacc_results.csv written to: " << acc_out << "\n";

    // ----- Summary printout -----
    std::cout << std::fixed << std::setprecision(4)
              << "\n================ Accuracy Results ================\n"
              << "Train accuracy   : " << (100.0 * train_metrics.accuracy)      << "%\n"
              << "Val   accuracy   : " << (100.0 * final_test_metrics.accuracy) << "%\n"
              << "Final test loss  : " << final_test_metrics.loss               << "\n"
              << "Precision        : " << final_test_metrics.precision          << "\n"
              << "Recall           : " << final_test_metrics.recall             << "\n"
              << "F1 score         : " << final_test_metrics.f1                 << "\n"
              << "Conv epochs      : " << conv_epochs                           << "\n";
    if (mse_golden >= 0.0)
        std::cout << "MSE_Golden       : " << mse_golden << "\n";
    else
        std::cout << "MSE_Golden       : N/A (no golden reference)\n";

    // Cleanup
    free_batch_buffers(buffers);
    free_params(params);
    CHECK_CUDA(cudaDeviceReset());
    return 0;
}
