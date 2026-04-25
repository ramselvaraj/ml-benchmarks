`timescale 1ns / 1ps

module testbench;

    logic clk;
    logic rst;
    logic start;

    logic signed [15:0] x [4];
    logic y_pred;
    logic signed [31:0] debug_dot;
    logic [31:0] elapsed_cycles;

    logic y_true;
    int   file_in;
    int   file_acc_out;
    int   file_perf_out;
    int   ret;
    int   rc;
    reg [1023:0] header;

    logic start_run;
    logic valid_out;

    logic [31:0] total_cycles;
    logic [31:0] TP, TN, FP, FN;
    logic [31:0] correct_hw, total_hw;

    real FCLK_HZ = 100_000_000.0; // 100 MHz

    real phase_compute_ms;
    real throughput;
    real latency_ms;
    real accuracy;
    real achieved_gflops;
    real arith_intensity;

    real f0, f1_in, f2, f3;
    string label_str;

    // DUT Instantiation
    perceptron_top dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x_in(x),
        .y_out(y_pred),
        .debug_dot(debug_dot),
        .elapsed_cycles(elapsed_cycles)
    );

    // Benchmark module instantiation
    fpga_benchmark bench (
        .clk(clk),
        .rst(rst),
        .start(start_run),
        .valid_out(valid_out),
        .y_pred(y_pred),
        .y_true(y_true),
        .total_cycles(total_cycles),
        .TP(TP), .TN(TN), .FP(FP), .FN(FN),
        .correct(correct_hw),
        .total(total_hw)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // --- VCD Dump for Vivado Power Analyzer ---
        // This file is strictly required for Phase 2 "Power Pass"
        $dumpfile("waveform.vcd");
        $dumpvars(0, testbench);

        // Initialization
        clk = 0;
        rst = 1;
        start = 0;
        start_run = 0;
        valid_out = 0;
        x[0] = 0; x[1] = 0; x[2] = 0; x[3] = 0;
        
        #20;
        rst = 0;
    end

    initial begin
        // Open inputs and output CSV files
        file_in = $fopen("iris_test_20k.csv", "r");
        file_acc_out = $fopen("acc_results.csv", "w");
        file_perf_out = $fopen("perf_results.csv", "w");

        if (file_in == 0) begin
            $display("ERROR: Cannot open iris_test.csv");
            $finish;
        end

        // Write headers to output CSV files
        $fdisplay(file_acc_out, "Model,Precision,Train_Acc,Val_Acc,Final_Loss,Conv_Epochs,MSE_Golden");
        $fdisplay(file_perf_out, "workload,dtype,batch_size,throughput,latency_p50,latency_p99,energy_total,avg_power,achieved_gflops,utilization_pct,arith_intensity,phase_staging,phase_compute,phase_output,tta_sec");

        // Skip input header row
        rc = $fgets(header, file_in);

        // Pulse start_run for the benchmark module
        start_run = 1;
        @(posedge clk);
        start_run = 0;

        while (1) begin
            ret = $fscanf(file_in, "%f,%f,%f,%f,%s\n", f0, f1_in, f2, f3, label_str);

            if (ret != 5) break;

            if (label_str == "Setosa" || label_str == "setosa")
                y_true = 0;
            else if (label_str == "Versicolor" || label_str == "versicolor")
                y_true = 1;
            else continue;

            // Convert to Fixed 16.8
            x[0] = $rtoi(f0    * 256.0);
            x[1] = $rtoi(f1_in * 256.0);
            x[2] = $rtoi(f2    * 256.0);
            x[3] = $rtoi(f3    * 256.0);

            // Trigger DUT
            start = 1;
            @(posedge clk);
            start = 0;

            // Wait for deterministic compute (Assuming 4 cycles based on previous code)
            repeat (4) @(posedge clk);

            valid_out = 1;
            @(posedge clk);
            valid_out = 0;
        end

        // Wait for pipeline to flush
        repeat (5) @(posedge clk);

        // ==========================================
        // PERFORMANCE & ACCURACY METRICS CALCULATION
        // ==========================================
        
        // Time calculations
        phase_compute_ms = (total_cycles / FCLK_HZ) * 1000.0;
        latency_ms = (elapsed_cycles > 0) ? ((elapsed_cycles / FCLK_HZ) * 1000.0) : ((4.0 / FCLK_HZ) * 1000.0);
        
        // Throughput (samples per second)
        throughput = (phase_compute_ms > 0.0) ? (total_hw / (phase_compute_ms / 1000.0)) : 0.0;

        // Accuracy
        accuracy  = (total_hw > 0) ? (correct_hw * 1.0 / total_hw) : 0.0;

        // GFLOPS calculation: 4 inputs = 4 Multiplies + 3 Additions = 7 Operations per inference
        achieved_gflops = (phase_compute_ms > 0.0) ? ((total_hw * 7.0) / (phase_compute_ms / 1000.0) / 1000000000.0) : 0.0;
        
        // Arithmetic Intensity: 7 ops / (4 inputs * 2 bytes) = 7/8 = 0.875
        arith_intensity = 7.0 / 8.0;

        // ==========================================
        // WRITE TO CSV FILES
        // ==========================================
        
        // Write acc_results.csv
        // Model, Precision, Train_Acc, Val_Acc, Final_Loss, Conv_Epochs, MSE_Golden
        // Note: Inference only, so Train metrics are N/A. MSE_Golden relies on Python reference, defaulting to 0 for FPGA sim isolated run.
        $fdisplay(file_acc_out, "perceptron,Fixed-16.8,N/A,%f,N/A,N/A,0.0", accuracy);

        // Write perf_results.csv
        // workload, dtype, batch_size, throughput, latency_p50, latency_p99, energy_total, avg_power, achieved_gflops, utilization_pct, arith_intensity, phase_staging, phase_compute, phase_output, tta_sec
        // Note: FPGA latency is deterministic, so p50 = p99. Energy/Power require Vivado Analyzer (marked as SEE_VCD). Staging/Output is 0ms in sim.
        $fdisplay(file_perf_out, "iris_perceptron,fixed_16_8,%0d,%f,%f,%f,SEE_VCD,SEE_VCD,%f,0.0,%f,0.0,%f,0.0,N/A", 
                  total_hw, throughput, latency_ms, latency_ms, achieved_gflops, arith_intensity, phase_compute_ms);

        $display("======================================");
        $display("Simulation Complete.");
        $display("Generated acc_results.csv and perf_results.csv");
        $display("Generated waveform.vcd for Vivado Power Analyzer");
        $display("Accuracy = %f | Throughput = %f SPS", accuracy, throughput);
        $display("======================================");

        $fclose(file_in);
        $fclose(file_acc_out);
        $fclose(file_perf_out);
        $finish;
    end

endmodule


// ==========================================
// FPGA Benchmark Module
// ==========================================
`timescale 1ns / 1ps

module fpga_benchmark (
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic valid_out,
    input  logic y_pred,
    input  logic y_true,

    output logic [31:0] total_cycles,
    output logic [31:0] TP, TN, FP, FN,
    output logic [31:0] correct,
    output logic [31:0] total
);

    logic [31:0] cycle_counter;
    logic [31:0] start_cycle;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            cycle_counter <= 0;
        else
            cycle_counter <= cycle_counter + 1;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            start_cycle  <= 0;
            total_cycles <= 0;
        end else begin
            if (start)
                start_cycle <= cycle_counter;
            if (valid_out)
                total_cycles <= cycle_counter - start_cycle;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            TP <= 0; TN <= 0; FP <= 0; FN <= 0;
            correct <= 0;
            total   <= 0;
        end else if (valid_out) begin
            total <= total + 1;

            if (y_pred == y_true)
                correct <= correct + 1;

            if (y_true == 1'b1 && y_pred == 1'b1) TP <= TP + 1;
            if (y_true == 1'b0 && y_pred == 1'b0) TN <= TN + 1;
            if (y_true == 1'b0 && y_pred == 1'b1) FP <= FP + 1;
            if (y_true == 1'b1 && y_pred == 1'b0) FN <= FN + 1;
        end
    end

endmodule