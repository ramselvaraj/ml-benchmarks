`timescale 1ns/1ps
import cnn_pkg::*;

module testbench_cnn_multimac;

  parameter int N = 100;
  parameter real FCLK_HZ = 100_000_000.0;

  localparam string BASE = "/home/a29208_asu/asap7_rundir/Project/CNN/";
  localparam real OPS_PER_SAMPLE = 2794240.0;

  logic clk;
  logic rst;
  logic start;

  logic done;
  logic valid_out;
  logic [3:0] pred_class;
  logic signed [31:0] logits [0:9];
  logic [31:0] elapsed_cycles;

  logic signed [7:0] img_in [0:IMG_H*IMG_W-1];

  integer expected_label;
  integer correct;
  integer wrong;
  integer total_cycles_sw;

  integer fd;
  integer code;
  integer temp;

  integer file_acc_out;
  integer file_perf_out;

  real accuracy;
  real throughput;
  real latency_ms;
  real avg_cycles_per_sample;
  real achieved_gops;

  cnn_top_multimac #(
    .PAR_MAC(32)
  ) dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .img_in(img_in),
    .done(done),
    .valid_out(valid_out),
    .pred_class(pred_class),
    .logits(logits),
    .elapsed_cycles(elapsed_cycles)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  task load_sample(input int sample_id);
    string input_file;
    begin
      input_file = $sformatf("%stest_vectors/sample_%0d_input_int8.txt", BASE, sample_id);

      fd = $fopen(input_file, "r");
      if (fd == 0) begin
        $display("ERROR: Could not open %s", input_file);
        $finish;
      end

      for (int i = 0; i < IMG_H*IMG_W; i++) begin
        code = $fscanf(fd, "%d", temp);
        img_in[i] = temp[7:0];
      end

      $fclose(fd);
    end
  endtask

  task load_label(input int sample_id, output int label);
    string label_file;
    begin
      label_file = $sformatf("%stest_vectors/sample_%0d_expected_pred.txt", BASE, sample_id);

      fd = $fopen(label_file, "r");
      if (fd == 0) begin
        $display("ERROR: Could not open %s", label_file);
        $finish;
      end

      code = $fscanf(fd, "%d", label);
      $fclose(fd);
    end
  endtask

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, testbench_cnn_multimac);

    file_acc_out  = $fopen("acc_results.csv", "w");
    file_perf_out = $fopen("perf_results.csv", "w");

    $fdisplay(file_acc_out,
      "model,total_samples,correct_samples,wrong_samples,accuracy_percent");

    $fdisplay(file_perf_out,
      "model,dtype,total_samples,total_cycles,avg_cycles_per_sample,throughput_samples_per_sec,latency_ms,achieved_GOPS,vcd_file");

    rst = 1;
    start = 0;
    correct = 0;
    wrong = 0;
    total_cycles_sw = 0;

    repeat(10) @(posedge clk);
    rst = 0;
    repeat(5) @(posedge clk);

    $display("========================================");
    $display("CNN MULTI-MAC FPGA BENCHMARK STARTED");
    $display("PAR_MAC = 8");
    $display("========================================");

    for (int i = 0; i < N; i++) begin
      load_sample(i);
      load_label(i, expected_label);

      @(posedge clk);
      start = 1;
      @(posedge clk);
      start = 0;

      wait(valid_out == 1);

      total_cycles_sw = total_cycles_sw + elapsed_cycles;

      $display("----------------------------------------");
      $display("Sample %0d", i);
      $display("Expected   = %0d", expected_label);
      $display("Prediction = %0d", pred_class);
      $display("Cycles     = %0d", elapsed_cycles);

      if (pred_class == expected_label[3:0]) begin
        correct = correct + 1;
        $display("MATCH");
      end else begin
        wrong = wrong + 1;
        $display("MISMATCH");
      end

      @(posedge clk);
    end

    accuracy = (real'(correct) / real'(N)) * 100.0;
    avg_cycles_per_sample = real'(total_cycles_sw) / real'(N);
    latency_ms = (avg_cycles_per_sample / FCLK_HZ) * 1000.0;
    throughput = FCLK_HZ / avg_cycles_per_sample;
    achieved_gops = (OPS_PER_SAMPLE * throughput) / 1.0e9;

    $display("========================================");
    $display("CNN MULTI-MAC FPGA BENCHMARK RESULTS");
    $display("========================================");
    $display("Total samples     = %0d", N);
    $display("Correct samples   = %0d", correct);
    $display("Wrong samples     = %0d", wrong);
    $display("Accuracy          = %0.6f %%", accuracy);
    $display("Total cycles      = %0d", total_cycles_sw);
    $display("Avg cycles/sample = %0.6f", avg_cycles_per_sample);
    $display("Throughput        = %0.6f samples/sec", throughput);
    $display("Latency           = %0.6f ms", latency_ms);
    $display("Achieved GOPS     = %0.6f", achieved_gops);
    $display("VCD power file    = waveform.vcd");
    $display("========================================");

    $fdisplay(file_acc_out,
      "cnn_multimac_int8,%0d,%0d,%0d,%0.6f",
      N, correct, wrong, accuracy);

    $fdisplay(file_perf_out,
      "cnn_multimac_int8,INT8,%0d,%0d,%0.6f,%0.6f,%0.6f,%0.6f,waveform.vcd",
      N,
      total_cycles_sw,
      avg_cycles_per_sample,
      throughput,
      latency_ms,
      achieved_gops);

    $display("Generated acc_results.csv");
    $display("Generated perf_results.csv");
    $display("Generated waveform.vcd");

    $fclose(file_acc_out);
    $fclose(file_perf_out);

    $finish;
  end

endmodule
