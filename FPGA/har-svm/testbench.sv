`timescale 1ns/1ps

module testbench;

    parameter int NUM_SAMPLES = 33127;
    parameter int NUM_FEATS   = 13;
    parameter int DATA_W      = 16;
    parameter int CLASS_W     = 3;

    localparam string TEST_X_PATH =
        "/home/a29208_asu/asap7_rundir/Project/SVM/data/har_test_x_q.txt";

    localparam string TEST_Y_PATH =
        "/home/a29208_asu/asap7_rundir/Project/SVM/data/har_test_y.txt";

    localparam string ACC_CSV_PATH =
        "/home/a29208_asu/asap7_rundir/Project/SVM/acc_results.csv";

    localparam string PERF_CSV_PATH =
        "/home/a29208_asu/asap7_rundir/Project/SVM/perf_results.csv";

    localparam string VCD_PATH =
        "/home/a29208_asu/asap7_rundir/Project/SVM/waveform.vcd";

    real FCLK_HZ = 100_000_000.0;

    logic clk;
    logic rst;
    logic start;
    logic done;

    logic signed [DATA_W-1:0] x [0:NUM_FEATS-1];

    logic [CLASS_W-1:0] prediction;
    logic signed [39:0] debug_score;
    logic [15:0] elapsed_cycles;

    logic [CLASS_W-1:0] y_true_mem [0:NUM_SAMPLES-1];

    int x_file;
    int y_file;
    int acc_file;
    int perf_file;

    int scan_status;
    int sample_idx;
    int correct;
    int wrong;

    logic [31:0] total_samples;
    logic [31:0] correct_samples;
    logic [31:0] wrong_samples;
    logic [31:0] total_cycles;

    logic [31:0] class0_correct, class1_correct, class2_correct, class3_correct, class4_correct;
    logic [31:0] class0_total,   class1_total,   class2_total,   class3_total,   class4_total;

    real accuracy;
    real phase_compute_ms;
    real latency_ms;
    real throughput;
    real achieved_gflops;
    real arith_intensity;

    svm_top dut (
        .clk(clk),
        .rst(rst),
        .start(start),

        .x0(x[0]),
        .x1(x[1]),
        .x2(x[2]),
        .x3(x[3]),
        .x4(x[4]),
        .x5(x[5]),
        .x6(x[6]),
        .x7(x[7]),
        .x8(x[8]),
        .x9(x[9]),
        .x10(x[10]),
        .x11(x[11]),
        .x12(x[12]),

        .done(done),
        .prediction(prediction),
        .debug_score(debug_score),
        .elapsed_cycles(elapsed_cycles)
    );

    fpga_benchmark_multiclass bench (
        .clk(clk),
        .rst(rst),
        .sample_done(done),
        .y_pred(prediction),
        .y_true(y_true_mem[sample_idx]),
        .sample_cycles(elapsed_cycles),

        .total_samples(total_samples),
        .correct_samples(correct_samples),
        .wrong_samples(wrong_samples),
        .total_cycles(total_cycles),

        .class0_correct(class0_correct),
        .class1_correct(class1_correct),
        .class2_correct(class2_correct),
        .class3_correct(class3_correct),
        .class4_correct(class4_correct),

        .class0_total(class0_total),
        .class1_total(class1_total),
        .class2_total(class2_total),
        .class3_total(class3_total),
        .class4_total(class4_total)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        start = 0;

        correct = 0;
        wrong   = 0;

        for (int i = 0; i < NUM_FEATS; i++) begin
            x[i] = '0;
        end

        $dumpfile(VCD_PATH);
        $dumpvars(0, testbench);

        repeat (5) @(posedge clk);
        rst = 0;
    end

    initial begin
        repeat (10) @(posedge clk);

        y_file = $fopen(TEST_Y_PATH, "r");
        if (y_file == 0) begin
            $display("ERROR: Could not open label file: %s", TEST_Y_PATH);
            $finish;
        end

        for (sample_idx = 0; sample_idx < NUM_SAMPLES; sample_idx++) begin
            scan_status = $fscanf(y_file, "%d\n", y_true_mem[sample_idx]);
            if (scan_status != 1) begin
                $display("ERROR: Failed reading label at sample %0d", sample_idx);
                $finish;
            end
        end

        $fclose(y_file);

        x_file = $fopen(TEST_X_PATH, "r");
        if (x_file == 0) begin
            $display("ERROR: Could not open input file: %s", TEST_X_PATH);
            $finish;
        end

        acc_file  = $fopen(ACC_CSV_PATH, "w");
        perf_file = $fopen(PERF_CSV_PATH, "w");

        if (acc_file == 0) begin
            $display("ERROR: Could not create acc_results.csv");
            $finish;
        end

        if (perf_file == 0) begin
            $display("ERROR: Could not create perf_results.csv");
            $finish;
        end

        $fdisplay(acc_file,
            "Model,Precision,Train_Acc,Val_Acc,Final_Loss,Conv_Epochs,MSE_Golden");

        $fdisplay(perf_file,
            "workload,dtype,batch_size,throughput,latency_p50,latency_p99,energy_total,avg_power,achieved_gflops,utilization_pct,arith_intensity,phase_staging,phase_compute,phase_output,tta_sec");

        for (sample_idx = 0; sample_idx < NUM_SAMPLES; sample_idx++) begin

            scan_status = $fscanf(
                x_file,
                "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n",
                x[0], x[1], x[2], x[3], x[4], x[5], x[6],
                x[7], x[8], x[9], x[10], x[11], x[12]
            );

            if (scan_status != NUM_FEATS) begin
                $display("ERROR: Failed reading input sample %0d. scan_status=%0d",
                         sample_idx, scan_status);
                $finish;
            end

            @(posedge clk);
            start <= 1'b1;

            @(posedge clk);
            start <= 1'b0;

            wait(done == 1'b1);
            @(posedge clk);

            if (prediction == y_true_mem[sample_idx]) begin
                correct++;
            end else begin
                wrong++;
            end

            $display("Sample %0d | True=%0d | Pred=%0d | Match=%0d | Cycles=%0d | Score=%0d",
                     sample_idx,
                     y_true_mem[sample_idx],
                     prediction,
                     prediction == y_true_mem[sample_idx],
                     elapsed_cycles,
                     debug_score);
        end

        $fclose(x_file);

        repeat (10) @(posedge clk);

        accuracy = ((correct + wrong) > 0)
                   ? (correct * 1.0 / (correct + wrong))
                   : 0.0;

        phase_compute_ms = (total_cycles / FCLK_HZ) * 1000.0;

        latency_ms = (total_samples > 0)
                     ? ((total_cycles * 1.0 / total_samples) / FCLK_HZ) * 1000.0
                     : 0.0;

        throughput = (phase_compute_ms > 0.0)
                     ? (total_samples / (phase_compute_ms / 1000.0))
                     : 0.0;

        achieved_gflops = (phase_compute_ms > 0.0)
                          ? ((total_samples * 130.0) /
                             (phase_compute_ms / 1000.0) /
                             1000000000.0)
                          : 0.0;

        arith_intensity = 130.0 / 26.0;

        $fdisplay(acc_file,
            "svm_multiclass,Fixed-16,N/A,%f,N/A,N/A,0.0",
            accuracy);

        $fdisplay(perf_file,
            "har_svm_multiclass,fixed_16,%0d,%f,%f,%f,SEE_VCD,SEE_VCD,%f,0.0,%f,0.0,%f,0.0,N/A",
            total_samples,
            throughput,
            latency_ms,
            latency_ms,
            achieved_gflops,
            arith_intensity,
            phase_compute_ms);

        $display("");
        $display("========================================");
        $display("SVM MULTICLASS FPGA BENCHMARK RESULTS");
        $display("========================================");
        $display("Generated acc_results.csv");
        $display("Generated perf_results.csv");
        $display("Generated waveform.vcd");
        $display("----------------------------------------");
        $display("Total samples     = %0d", correct + wrong);
        $display("Correct samples   = %0d", correct);
        $display("Wrong samples     = %0d", wrong);
        $display("Accuracy          = %0f %%", accuracy * 100.0);
        $display("Total cycles      = %0d", total_cycles);
        $display("Avg cycles/sample = %0f", total_cycles * 1.0 / total_samples);
        $display("Throughput        = %0f samples/sec", throughput);
        $display("Latency           = %0f ms", latency_ms);
        $display("Achieved GOPS     = %0f", achieved_gflops);
        $display("----------------------------------------");
        $display("Class 0 accuracy  = %0f %%", class0_total ? (class0_correct * 100.0) / class0_total : 0.0);
        $display("Class 1 accuracy  = %0f %%", class1_total ? (class1_correct * 100.0) / class1_total : 0.0);
        $display("Class 2 accuracy  = %0f %%", class2_total ? (class2_correct * 100.0) / class2_total : 0.0);
        $display("Class 3 accuracy  = %0f %%", class3_total ? (class3_correct * 100.0) / class3_total : 0.0);
        $display("Class 4 accuracy  = %0f %%", class4_total ? (class4_correct * 100.0) / class4_total : 0.0);
        $display("========================================");

        $fclose(acc_file);
        $fclose(perf_file);

        $finish;
    end

endmodule
