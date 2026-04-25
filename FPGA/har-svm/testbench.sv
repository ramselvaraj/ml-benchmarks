`timescale 1ns/1ps

module testbench;

    parameter int N = 13;
    parameter int DATA_W = 16;
    parameter int BIAS_W = 32;
    parameter int ACC_W = 40;
    parameter int NUM_CLASSES = 5;
    parameter int CLASS_W = 3;
    parameter int NUM_SAMPLES = 33127;

    logic signed [N*DATA_W-1:0] x_flat;
    logic [CLASS_W-1:0]         pred_class;
    logic signed [ACC_W-1:0]    max_score;

    integer x_file, y_file, p_file;
    integer file_acc_out, file_perf_out;
    integer r, i, j, k;

    integer sample_features [0:N-1];
    integer true_label;
    integer python_pred;

    integer correct_true;
    integer correct_python;

    integer conf_mat [0:NUM_CLASSES-1][0:NUM_CLASSES-1];

    integer tp, fp_count, fn_count;
    real precision, recall, f1;
    real macro_precision, macro_recall, macro_f1;
    real accuracy_true, accuracy_python;

    real FCLK_HZ = 100_000_000.0;

    real phase_compute_ms;
    real throughput;
    real latency_ms;
    real achieved_gflops;
    real arith_intensity;

    integer total_cycles;
    integer cycles_per_sample;

    svm_top #(
        .N(N),
        .DATA_W(DATA_W),
        .BIAS_W(BIAS_W),
        .ACC_W(ACC_W),
        .NUM_CLASSES(NUM_CLASSES),
        .CLASS_W(CLASS_W)
    ) dut (
        .x_flat(x_flat),
        .pred_class(pred_class),
        .max_score(max_score)
    );

    task automatic load_sample_to_bus;
        integer m;
        begin
            x_flat = '0;
            for (m = 0; m < N; m = m + 1) begin
                x_flat[m*DATA_W +: DATA_W] = sample_features[m];
            end
        end
    endtask

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, testbench);

        correct_true   = 0;
        correct_python = 0;

        macro_precision = 0.0;
        macro_recall    = 0.0;
        macro_f1        = 0.0;

        cycles_per_sample = 1;
        total_cycles = NUM_SAMPLES * cycles_per_sample;

        for (i = 0; i < NUM_CLASSES; i = i + 1) begin
            for (j = 0; j < NUM_CLASSES; j = j + 1) begin
                conf_mat[i][j] = 0;
            end
        end

        x_file = $fopen("/home/a29208_asu/asap7_rundir/Project/har_test_x_q.txt", "r");
        y_file = $fopen("/home/a29208_asu/asap7_rundir/Project/har_test_y.txt", "r");
        p_file = $fopen("/home/a29208_asu/asap7_rundir/Project/har_test_pred_q.txt", "r");

        file_acc_out  = $fopen("acc_results.csv", "w");
        file_perf_out = $fopen("perf_results.csv", "w");

        if (x_file == 0) begin
            $display("ERROR: Could not open har_test_x_q.txt");
            $finish;
        end
        if (y_file == 0) begin
            $display("ERROR: Could not open har_test_y.txt");
            $finish;
        end
        if (p_file == 0) begin
            $display("ERROR: Could not open har_test_pred_q.txt");
            $finish;
        end
        if (file_acc_out == 0) begin
            $display("ERROR: Could not create acc_results.csv");
            $finish;
        end
        if (file_perf_out == 0) begin
            $display("ERROR: Could not create perf_results.csv");
            $finish;
        end

        $fdisplay(file_acc_out,
            "Model,Precision,Train_Acc,Val_Acc,Final_Loss,Conv_Epochs,MSE_Golden");

        $fdisplay(file_perf_out,
            "workload,dtype,batch_size,throughput,latency_p50,latency_p99,energy_total,avg_power,achieved_gflops,utilization_pct,arith_intensity,phase_staging,phase_compute,phase_output,tta_sec");

        $display("========================================");
        $display("Starting full HAR-SVM test on %0d samples", NUM_SAMPLES);
        $display("========================================");

        for (i = 0; i < NUM_SAMPLES; i = i + 1) begin

            r = $fscanf(
                x_file,
                "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
                sample_features[0],  sample_features[1],  sample_features[2],
                sample_features[3],  sample_features[4],  sample_features[5],
                sample_features[6],  sample_features[7],  sample_features[8],
                sample_features[9],  sample_features[10], sample_features[11],
                sample_features[12]
            );

            if (r != 13) begin
                $display("ERROR reading feature row %0d, fscanf returned %0d", i, r);
                $finish;
            end

            r = $fscanf(y_file, "%d\n", true_label);
            if (r != 1) begin
                $display("ERROR reading true label row %0d", i);
                $finish;
            end

            r = $fscanf(p_file, "%d\n", python_pred);
            if (r != 1) begin
                $display("ERROR reading python pred row %0d", i);
                $finish;
            end

            load_sample_to_bus();
            #1;

            if (pred_class == true_label)
                correct_true = correct_true + 1;

            if (pred_class == python_pred)
                correct_python = correct_python + 1;

            conf_mat[true_label][pred_class] =
                conf_mat[true_label][pred_class] + 1;

            if (i < 5) begin
                $display("----------------------------------------");
                $display("Sample %0d", i);
                $display("True label    = %0d", true_label);
                $display("Python pred   = %0d", python_pred);
                $display("FPGA pred     = %0d", pred_class);
                $display("Max score     = %0d", max_score);
                $display("score_0       = %0d", dut.score_0);
                $display("score_1       = %0d", dut.score_1);
                $display("score_2       = %0d", dut.score_2);
                $display("score_3       = %0d", dut.score_3);
                $display("score_4       = %0d", dut.score_4);
            end

            if ((i + 1) % 5000 == 0) begin
                $display("Processed %0d / %0d samples", i + 1, NUM_SAMPLES);
            end
        end

        accuracy_true   = real'(correct_true)   / real'(NUM_SAMPLES);
        accuracy_python = real'(correct_python) / real'(NUM_SAMPLES);

        $display("");
        $display("========================================");
        $display("FINAL RESULTS");
        $display("========================================");
        $display("Total samples                = %0d", NUM_SAMPLES);
        $display("Correct vs true labels       = %0d", correct_true);
        $display("Accuracy vs true labels      = %0.4f %%", accuracy_true * 100.0);
        $display("Match vs Python quantized    = %0d", correct_python);
        $display("Match rate vs Python q pred  = %0.4f %%", accuracy_python * 100.0);

        $display("");
        $display("Confusion Matrix (rows=true, cols=pred)");
        for (i = 0; i < NUM_CLASSES; i = i + 1) begin
            $write("Class %0d : ", i);
            for (j = 0; j < NUM_CLASSES; j = j + 1) begin
                $write("%0d ", conf_mat[i][j]);
            end
            $write("\n");
        end

        $display("");
        $display("Per-class metrics");

        for (i = 0; i < NUM_CLASSES; i = i + 1) begin
            tp = conf_mat[i][i];
            fp_count = 0;
            fn_count = 0;

            for (j = 0; j < NUM_CLASSES; j = j + 1) begin
                if (j != i) begin
                    fp_count = fp_count + conf_mat[j][i];
                    fn_count = fn_count + conf_mat[i][j];
                end
            end

            if ((tp + fp_count) > 0)
                precision = real'(tp) / real'(tp + fp_count);
            else
                precision = 0.0;

            if ((tp + fn_count) > 0)
                recall = real'(tp) / real'(tp + fn_count);
            else
                recall = 0.0;

            if ((precision + recall) > 0.0)
                f1 = 2.0 * precision * recall / (precision + recall);
            else
                f1 = 0.0;

            macro_precision = macro_precision + precision;
            macro_recall    = macro_recall + recall;
            macro_f1        = macro_f1 + f1;

            $display("Class %0d -> Precision = %0.4f, Recall = %0.4f, F1 = %0.4f",
                     i, precision, recall, f1);
        end

        macro_precision = macro_precision / NUM_CLASSES;
        macro_recall    = macro_recall    / NUM_CLASSES;
        macro_f1        = macro_f1        / NUM_CLASSES;

        phase_compute_ms = (real'(total_cycles) / FCLK_HZ) * 1000.0;
        latency_ms       = (real'(cycles_per_sample) / FCLK_HZ) * 1000.0;

        throughput = (phase_compute_ms > 0.0)
                   ? (real'(NUM_SAMPLES) / (phase_compute_ms / 1000.0))
                   : 0.0;

        // One-vs-rest linear SVM:
        // For each class: 13 multiplies + 12 adds = 25 ops
        // 5 classes => 125 ops/sample
        achieved_gflops = (phase_compute_ms > 0.0)
                         ? ((real'(NUM_SAMPLES) * 125.0) /
                            (phase_compute_ms / 1000.0) / 1000000000.0)
                         : 0.0;

        // Input bytes = 13 features * 2 bytes = 26 bytes
        // Arithmetic intensity = 125 ops / 26 bytes
        arith_intensity = 125.0 / 26.0;

        $fdisplay(file_acc_out,
                  "har_svm,Fixed-16.8,N/A,%f,N/A,N/A,%f",
                  accuracy_true,
                  1.0 - accuracy_python);

        $fdisplay(file_perf_out,
                  "har_svm,fixed_16_8,%0d,%f,%f,%f,SEE_VCD,SEE_VCD,%f,0.0,%f,0.0,%f,0.0,N/A",
                  NUM_SAMPLES,
                  throughput,
                  latency_ms,
                  latency_ms,
                  achieved_gflops,
                  arith_intensity,
                  phase_compute_ms);

        $display("");
        $display("========================================");
        $display("CSV FILES GENERATED");
        $display("acc_results.csv");
        $display("perf_results.csv");
        $display("waveform.vcd");
        $display("Macro Precision = %0.4f", macro_precision);
        $display("Macro Recall    = %0.4f", macro_recall);
        $display("Macro F1        = %0.4f", macro_f1);
        $display("Throughput      = %0.4f samples/sec", throughput);
        $display("Latency         = %0.8f ms", latency_ms);
        $display("========================================");

        $fclose(x_file);
        $fclose(y_file);
        $fclose(p_file);
        $fclose(file_acc_out);
        $fclose(file_perf_out);

        $finish;
    end

endmodule
