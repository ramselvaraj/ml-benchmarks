// gen_acc_results.cu
// Train the MNIST CNN and write acc_results.csv.
// Also saves cnn_weights.bin for use by gen_perf_results.
//
// Usage:
//   ./gen_acc  [train_csv] [test_csv] [epochs] [batch_size] [lr]
//              [acc_out.csv] [weights.bin]
//
// Defaults:
//   train_csv   = mnist_train.csv
//   test_csv    = mnist_test.csv
//   epochs      = 3
//   batch_size  = 64
//   lr          = 0.02
//   acc_out     = results/gpu_cuda/mnist_cnn/acc_results.csv
//   weights.bin = cnn_weights.bin

#include "cnn_model.cuh"
#include <filesystem>

// ---------------------------------------------------------------------------
// train() — full training loop, returns PhaseTiming + fills final_test_metrics
//           and per_epoch_train_accs for convergence detection
// ---------------------------------------------------------------------------

static PhaseTiming train(
    const Dataset&       train_ds,
    const Dataset&       test_ds,
    CnnParams&           params,
    BatchBuffers&        buffers,
    int                  epochs,
    int                  batch_size,
    float                lr,
    EvalMetrics&         final_test_metrics,
    std::vector<double>& per_epoch_train_accs
) {
    float* h_x = nullptr; int* h_y = nullptr;
    CHECK_CUDA(cudaMallocHost((void**)&h_x, bytes_of(static_cast<size_t>(batch_size)*IMG_H*IMG_W)));
    CHECK_CUDA(cudaMallocHost((void**)&h_y, sizeof(int)*batch_size));

    std::vector<float> h_losses(batch_size);
    std::vector<int>   h_preds(batch_size);
    std::vector<int>   order(train_ds.size);
    std::iota(order.begin(), order.end(), 0);
    std::mt19937 rng(123);

    cudaEvent_t ev0, ev1;
    CHECK_CUDA(cudaEventCreate(&ev0)); CHECK_CUDA(cudaEventCreate(&ev1));

    PhaseTiming timing;
    auto wall_begin = std::chrono::high_resolution_clock::now();
    int batches_per_epoch = (train_ds.size + batch_size - 1) / batch_size;

    for (int epoch = 0; epoch < epochs; ++epoch) {
        std::shuffle(order.begin(), order.end(), rng);
        double epoch_loss = 0.0; int correct = 0, seen = 0;
        double epoch_ms = 0.0;

        for (int bat = 0; bat < batches_per_epoch; ++bat) {
            int start = bat * batch_size;
            int B = std::min(batch_size, train_ds.size - start);
            copy_batch_to_pinned(train_ds, order, start, B, h_x, h_y);
            float ms = 0.0f;

            CHECK_CUDA(cudaEventRecord(ev0));
            CHECK_CUDA(cudaMemcpy(buffers.d_x, h_x, bytes_of(static_cast<size_t>(B)*IMG_H*IMG_W), cudaMemcpyHostToDevice));
            CHECK_CUDA(cudaMemcpy(buffers.d_y, h_y, sizeof(int)*B, cudaMemcpyHostToDevice));
            CHECK_CUDA(cudaEventRecord(ev1)); CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.h2d_ms += ms; epoch_ms += ms;

            CHECK_CUDA(cudaEventRecord(ev0));
            forward_pass(params, buffers, B);
            CHECK_CUDA(cudaEventRecord(ev1)); CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.forward_ms += ms; epoch_ms += ms;

            CHECK_CUDA(cudaEventRecord(ev0));
            run_loss_and_pred(buffers, B);
            CHECK_CUDA(cudaEventRecord(ev1)); CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.loss_ms += ms; epoch_ms += ms;

            CHECK_CUDA(cudaMemcpy(h_losses.data(), buffers.d_losses, bytes_of(B), cudaMemcpyDeviceToHost));
            CHECK_CUDA(cudaMemcpy(h_preds.data(),  buffers.d_preds,  sizeof(int)*B, cudaMemcpyDeviceToHost));
            for (int i = 0; i < B; ++i) { epoch_loss += h_losses[i]; correct += (h_preds[i] == h_y[i]); }
            seen += B;

            CHECK_CUDA(cudaEventRecord(ev0));
            backward_pass(params, buffers, B);
            CHECK_CUDA(cudaEventRecord(ev1)); CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.backward_ms += ms; epoch_ms += ms;

            CHECK_CUDA(cudaEventRecord(ev0));
            update_params(params, lr, B);
            CHECK_CUDA(cudaEventRecord(ev1)); CHECK_CUDA(cudaEventSynchronize(ev1));
            CHECK_CUDA(cudaEventElapsedTime(&ms, ev0, ev1));
            timing.update_ms += ms; epoch_ms += ms;
        }

        double train_acc = static_cast<double>(correct) / seen;
        per_epoch_train_accs.push_back(train_acc);

        std::cout << std::fixed << std::setprecision(4)
                  << "Epoch " << (epoch+1) << "/" << epochs
                  << " | train_loss=" << (epoch_loss/seen)
                  << " | train_acc="  << (100.0*train_acc) << "%"
                  << " | epoch_gpu_ms=" << epoch_ms
                  << " | throughput=" << (1000.0*seen/epoch_ms) << " samples/s\n";

        final_test_metrics = evaluate(test_ds, params, buffers, batch_size);
        std::cout << "  test_loss=" << final_test_metrics.loss
                  << " | test_acc=" << (100.0*final_test_metrics.accuracy) << "%"
                  << " | avg_batch_ms=" << final_test_metrics.avg_batch_ms << "\n";
    }

    auto wall_end = std::chrono::high_resolution_clock::now();
    timing.total_wall_ms = std::chrono::duration<double,std::milli>(wall_end - wall_begin).count();
    CHECK_CUDA(cudaEventDestroy(ev0)); CHECK_CUDA(cudaEventDestroy(ev1));
    CHECK_CUDA(cudaFreeHost(h_x)); CHECK_CUDA(cudaFreeHost(h_y));
    return timing;
}

// ---------------------------------------------------------------------------
// Detect convergence epoch (first epoch where improvement < 0.001)
// ---------------------------------------------------------------------------

static int detect_convergence_epoch(const std::vector<double>& accs) {
    for (int i = 1; i < static_cast<int>(accs.size()); ++i)
        if ((accs[i] - accs[i-1]) < 0.001) return i + 1; // 1-indexed
    return static_cast<int>(accs.size());
}

// ---------------------------------------------------------------------------
// Write acc_results.csv
// ---------------------------------------------------------------------------

static void write_acc_csv(
    const std::string& path,
    const std::string& model_name,
    int                batch_size,
    const EvalMetrics& train_metrics,
    const EvalMetrics& test_metrics,
    int                conv_epoch,
    double             final_loss
) {
    std::filesystem::path p(path);
    if (p.has_parent_path()) std::filesystem::create_directories(p.parent_path());
    std::ofstream fout(path);
    if (!fout) { std::cerr << "Cannot open: " << path << std::endl; std::exit(1); }

    fout << "Model,Precision,Batch_Size,Train_Acc,Val_Acc,Final_Loss,Conv_Epochs\n";
    fout << std::fixed << std::setprecision(6);
    fout << model_name                           << ","
         << "fp32"                               << ","
         << batch_size                           << ","
         << train_metrics.accuracy               << ","
         << test_metrics.accuracy                << ","
         << final_loss                           << ","
         << conv_epoch                           << "\n";

    fout.close();
    std::cout << "acc_results.csv written to: " << path << "\n";
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

int main(int argc, char** argv) {
    std::string train_csv  = "mnist_train.csv";
    std::string test_csv   = "mnist_test.csv";
    int         epochs     = 3;
    int         batch_size = 64;
    float       lr         = 0.02f;
    std::string acc_out    = "results/gpu_cuda/mnist_cnn/acc_results.csv";
    std::string wts_out    = "cnn_weights.bin";

    if (argc >= 2) train_csv  = argv[1];
    if (argc >= 3) test_csv   = argv[2];
    if (argc >= 4) epochs     = std::stoi(argv[3]);
    if (argc >= 5) batch_size = std::stoi(argv[4]);
    if (argc >= 6) lr         = std::stof(argv[5]);
    if (argc >= 7) acc_out    = argv[6];
    if (argc >= 8) wts_out    = argv[7];

    int device = 0;
    cudaDeviceProp prop{};
    CHECK_CUDA(cudaGetDeviceProperties(&prop, device));
    CHECK_CUDA(cudaSetDevice(device));

    std::cout << "=== gen_acc_results (MNIST CNN) ===\n"
              << "GPU        : " << prop.name  << "\n"
              << "Train CSV  : " << train_csv  << "\n"
              << "Test CSV   : " << test_csv   << "\n"
              << "Epochs     : " << epochs     << "\n"
              << "Batch size : " << batch_size << "\n"
              << "LR         : " << lr         << "\n\n";

    Dataset train_ds = load_mnist_csv(train_csv);
    Dataset test_ds  = load_mnist_csv(test_csv);
    print_model_info(batch_size);

    CnnParams    params;
    BatchBuffers buffers;
    init_params(params);
    alloc_batch_buffers(buffers, batch_size);

    EvalMetrics          final_test_metrics;
    std::vector<double>  per_epoch_train_accs;
    PhaseTiming timing = train(train_ds, test_ds, params, buffers,
                               epochs, batch_size, lr,
                               final_test_metrics, per_epoch_train_accs);

    // Evaluate on train set for Train_Acc in CSV
    std::cout << "\nEvaluating on train set for acc_results.csv...\n";
    EvalMetrics train_metrics = evaluate(train_ds, params, buffers, batch_size);

    int  conv_epoch  = detect_convergence_epoch(per_epoch_train_accs);
    double final_loss = final_test_metrics.loss;

    // Training performance summary
    double measured_total = timing.h2d_ms + timing.forward_ms + timing.loss_ms +
                            timing.backward_ms + timing.update_ms;
    double total_batches  = static_cast<double>((train_ds.size + batch_size - 1) / batch_size) * epochs;
    std::cout << std::fixed << std::setprecision(4)
              << "\n========== Training Performance ==========\n"
              << "Wall-clock total         : " << timing.total_wall_ms << " ms\n"
              << "Avg wall-clock / epoch   : " << timing.total_wall_ms / epochs << " ms\n"
              << "Avg GPU step / batch     : " << measured_total / total_batches << " ms\n"
              << "H2D                      : " << timing.h2d_ms     << " ms\n"
              << "Forward                  : " << timing.forward_ms << " ms\n"
              << "Loss/softmax             : " << timing.loss_ms    << " ms\n"
              << "Backward                 : " << timing.backward_ms<< " ms\n"
              << "SGD update               : " << timing.update_ms  << " ms\n"
              << "Forward share            : " << (100.0*timing.forward_ms/measured_total)  << "%\n"
              << "Backward share           : " << (100.0*timing.backward_ms/measured_total) << "%\n"
              << "\n========== Accuracy ==========\n"
              << "Train accuracy           : " << (100.0*train_metrics.accuracy) << "%\n"
              << "Test  accuracy           : " << (100.0*final_test_metrics.accuracy) << "%\n"
              << "Final test loss          : " << final_loss << "\n"
              << "Convergence epoch        : " << conv_epoch << "\n";

    // Single-image latency
    LatencyMetrics single = benchmark_single_image_latency(test_ds, params, buffers);
    std::cout << "\n========== Single-Image Latency ==========\n"
              << "Mean=" << single.mean_ms << " ms  p50=" << single.p50_ms
              << " ms  p95=" << single.p95_ms << " ms\n";

    // Save weights for gen_perf_results
    save_weights(params, wts_out);

    // Write CSV
    write_acc_csv(acc_out, "mnist_cnn_gpu", batch_size,
                  train_metrics, final_test_metrics, conv_epoch, final_loss);

    free_batch_buffers(buffers);
    free_params(params);
    CHECK_CUDA(cudaDeviceReset());
    return 0;
}
