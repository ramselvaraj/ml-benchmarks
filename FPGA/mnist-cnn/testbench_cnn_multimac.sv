

`timescale 1ns/1ps
import cnn_pkg::*;

module testbench_cnn_multimac;

  // ---- Configurable parameters ---------------------------------
  parameter int    N           = 1000;             // samples to test
  parameter real   FCLK_HZ     = 100_000_000.0;   // 100 MHz
  parameter string BASE        = "./";             // path to project dir
  parameter int    DUT_PAR_MAC = 32;               // must match DUT instantiation below

  // Derived from architecture — update if layers change
  // See derivation in header comment above
  localparam real OPS_PER_SAMPLE = 2794240.0;

  // ---- Clock / reset / control ---------------------------------
  logic clk;
  logic rst;
  logic start;

  // ---- DUT outputs ---------------------------------------------
  logic        done;
  logic        valid_out;
  logic [3:0]  pred_class;
  logic signed [31:0] logits [0:9];
  logic [31:0] elapsed_cycles;

  // ---- Image input buffer --------------------------------------
  logic signed [7:0] img_in [0:IMG_H*IMG_W-1];

  // ---- Simulation-only bookkeeping ----------------------------
  integer expected_label;
  integer correct, wrong;
  integer total_cycles_sw;
  integer fd, code, temp;
  integer file_acc_out, file_perf_out;
  string  input_file, label_file;

  // ---- Metrics -------------------------------------------------
  real accuracy, throughput, latency_ms;
  real avg_cycles_per_sample, achieved_gops;

  // ---- DUT instantiation ---------------------------------------
  cnn_top_multimac #(
    .PAR_MAC (DUT_PAR_MAC),
    .W1_FILE ({BASE, "quantized_int8/w1.mem"}),
    .B1_FILE ({BASE, "quantized_int8/b1.mem"}),
    .W2_FILE ({BASE, "quantized_int8/w2.mem"}),
    .B2_FILE ({BASE, "quantized_int8/b2.mem"}),
    .W3_FILE ({BASE, "quantized_int8/w3.mem"}),
    .B3_FILE ({BASE, "quantized_int8/b3.mem"}),
    .W4_FILE ({BASE, "quantized_int8/w4.mem"}),
    .B4_FILE ({BASE, "quantized_int8/b4.mem"}),
    .W5_FILE ({BASE, "quantized_int8/w5.mem"}),
    .B5_FILE ({BASE, "quantized_int8/b5.mem"})
  ) dut (
    .clk           (clk),
    .rst           (rst),
    .start         (start),
    .img_in        (img_in),
    .done          (done),
    .valid_out     (valid_out),
    .pred_class    (pred_class),
    .logits        (logits),
    .elapsed_cycles(elapsed_cycles)
  );

  // ---- Clock generation ----------------------------------------
  initial clk = 1'b0;
  always  #5 clk = ~clk;   // 10 ns period = 100 MHz


  task automatic load_sample(input int sample_id);
    begin
      input_file = $sformatf("%stest_vectors/sample_%0d_input_int8.txt",
                             BASE, sample_id);
      fd = $fopen(input_file, "r");
      if (fd == 0) begin
        $display("ERROR: cannot open %s", input_file);
        $finish;
      end
      for (int i = 0; i < IMG_H*IMG_W; i++) begin
        code = $fscanf(fd, "%d", temp);
        img_in[i] = temp[7:0];
      end
      $fclose(fd);
    end
  endtask

  // Load the expected label for one sample
  task automatic load_label(input int sample_id, output int label);
    begin
      label_file = $sformatf("%stest_vectors/sample_%0d_expected_pred.txt",
                             BASE, sample_id);
      fd = $fopen(label_file, "r");
      if (fd == 0) begin
        $display("ERROR: cannot open %s", label_file);
        $finish;
      end
      code = $fscanf(fd, "%d", label);
      $fclose(fd);
    end
  endtask

  // ---- Main simulation body ------------------------------------
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, testbench_cnn_multimac);

    // Open output CSV files
    file_acc_out  = $fopen({BASE, "acc_results.csv"},  "w");
    file_perf_out = $fopen({BASE, "perf_results.csv"}, "w");
    if (file_acc_out  == 0) begin $display("ERROR: cannot create acc_results.csv");  $finish; end
    if (file_perf_out == 0) begin $display("ERROR: cannot create perf_results.csv"); $finish; end

    $fdisplay(file_acc_out,
      "model,total_samples,correct_samples,wrong_samples,accuracy_percent");
    $fdisplay(file_perf_out,
      "model,dtype,total_samples,total_cycles,avg_cycles_per_sample,"
      "throughput_samples_per_sec,latency_ms,achieved_GOPS,vcd_file");

    // Reset
    rst              = 1'b1;
    start            = 1'b0;
    correct          = 0;
    wrong            = 0;
    total_cycles_sw  = 0;

    repeat (10) @(posedge clk);
    rst = 1'b0;
    repeat  (5) @(posedge clk);

    $display("========================================");
    $display("CNN MULTI-MAC FPGA BENCHMARK STARTED");
    $display("PAR_MAC        = %0d", DUT_PAR_MAC);
    $display("Samples to run = %0d", N);
    $display("Clock          = %0.0f MHz", FCLK_HZ / 1e6);
    $display("========================================");


    for (int i = 0; i < N; i++) begin
      load_sample(i);
      load_label(i, expected_label);

      // Assert start for one cycle
      @(posedge clk);
      start = 1'b1;
      @(posedge clk);
      start = 1'b0;

      // Wait for DUT to assert valid_out
      wait (valid_out === 1'b1);
      @(posedge clk);  
      total_cycles_sw = total_cycles_sw + int'(elapsed_cycles);

      if (pred_class == expected_label[3:0]) begin
        correct++;
        if (i < 20 || i % 100 == 0)
          $display("Sample %4d | Expected %0d | Got %0d | MATCH   | Cycles %0d",
                   i, expected_label, pred_class, elapsed_cycles);
      end else begin
        wrong++;
        $display("Sample %4d | Expected %0d | Got %0d | MISMATCH | Cycles %0d",
                 i, expected_label, pred_class, elapsed_cycles);
      end
    end


    accuracy             = (real'(correct) / real'(N)) * 100.0;
    avg_cycles_per_sample= real'(total_cycles_sw) / real'(N);
    latency_ms           = (avg_cycles_per_sample / FCLK_HZ) * 1000.0;
    throughput           = FCLK_HZ / avg_cycles_per_sample;
    achieved_gops        = (OPS_PER_SAMPLE * throughput) / 1.0e9;


    $display("");
    $display("========================================");
    $display("CNN MULTI-MAC FPGA BENCHMARK RESULTS");
    $display("========================================");
    $display("Total samples      = %0d",    N);
    $display("Correct            = %0d",    correct);
    $display("Wrong              = %0d",    wrong);
    $display("Accuracy           = %.4f %%", accuracy);
    $display("Total cycles       = %0d",    total_cycles_sw);
    $display("Avg cycles/sample  = %.2f",   avg_cycles_per_sample);
    $display("Throughput         = %.2f samples/sec", throughput);
    $display("Latency (avg)      = %.4f ms",  latency_ms);
    $display("Achieved GOPS      = %.6f",   achieved_gops);
    $display("VCD file           = waveform.vcd");
    $display("========================================");


    $fdisplay(file_acc_out,
      "cnn_multimac_int8,%0d,%0d,%0d,%.6f",
      N, correct, wrong, accuracy);

    $fdisplay(file_perf_out,
      "cnn_multimac_int8,INT8,%0d,%0d,%.6f,%.6f,%.6f,%.6f,waveform.vcd",
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
