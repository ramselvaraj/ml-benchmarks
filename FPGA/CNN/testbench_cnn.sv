`timescale 1ns/1ps
`include "cnn_pkg.sv"

module testbench_cnn;

  parameter int N = 5;

  logic [3:0] pred_class [0:N-1];
  logic signed [31:0] logits [0:N-1][0:9];

  integer expected_pred;
  integer fd, code;
  integer correct = 0;

  integer file_acc_out;
  integer file_perf_out;

  real FCLK_HZ = 100_000_000.0;

  real accuracy;
  real phase_compute_ms;
  real throughput;
  real latency_ms;
  real achieved_gflops;
  real arith_intensity;

  integer cycles_per_sample;
  integer total_cycles;

  // Approximate operation count for your CNN.
  // Update this later if you want exact layer-by-layer operation count.
  real OPS_PER_SAMPLE = 500000.0;

  // Approximate memory read per sample:
  // 28*28 input INT8 = 784 bytes.
  // This is simplified and does not include all weights.
  real BYTES_PER_SAMPLE = 784.0;

  // -------------------------
  // Instantiate multiple CNNs
  // -------------------------
  genvar i;
  generate
    for (i = 0; i < N; i++) begin : CNN_ARRAY

      cnn_top #(
        .FILE_X($sformatf("test_vectors/sample_%0d_input_int8.txt", i)),
        .FILE_W1("quantized_int8/conv2d_weights_int8.txt"),
        .FILE_B1("quantized_int8/conv2d_biases_int8.txt"),
        .FILE_W2("quantized_int8/conv2d_1_weights_int8.txt"),
        .FILE_B2("quantized_int8/conv2d_1_biases_int8.txt"),
        .FILE_W3("quantized_int8/conv2d_2_weights_int8.txt"),
        .FILE_B3("quantized_int8/conv2d_2_biases_int8.txt"),
        .FILE_W4("quantized_int8/dense_weights_int8.txt"),
        .FILE_B4("quantized_int8/dense_biases_int8.txt"),
        .FILE_W5("quantized_int8/dense_1_weights_int8.txt"),
        .FILE_B5("quantized_int8/dense_1_biases_int8.txt")
      ) dut (
        .pred_class(pred_class[i]),
        .logits(logits[i])
      );

    end
  endgenerate

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, testbench_cnn);

    file_acc_out  = $fopen("acc_results.csv", "w");
    file_perf_out = $fopen("perf_results.csv", "w");

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

    #20;

    $display("====================================");
    $display("Starting CNN test on %0d samples", N);
    $display("====================================");

    for (int j = 0; j < N; j++) begin

      $display("====================================");
      $display("Sample %0d", j);
      $display("Prediction = %0d", pred_class[j]);

      fd = $fopen($sformatf("test_vectors/sample_%0d_expected_pred.txt", j), "r");

      if (fd != 0) begin
        code = $fscanf(fd, "%d", expected_pred);
        $fclose(fd);

        $display("Expected   = %0d", expected_pred);

        if (pred_class[j] == expected_pred) begin
          $display("MATCH");
          correct = correct + 1;
        end else begin
          $display("MISMATCH");
        end
      end else begin
        $display("ERROR: Could not open expected prediction file for sample %0d", j);
      end

    end

    accuracy = real'(correct) / real'(N);

    // Since this CNN testbench is combinational and waits only #20,
    // we model the benchmark latency as 1 cycle/sample.
    // If your CNN later becomes clocked/pipelined, replace this value.
    cycles_per_sample = 1;
    total_cycles = N * cycles_per_sample;

    phase_compute_ms = (real'(total_cycles) / FCLK_HZ) * 1000.0;
    latency_ms       = (real'(cycles_per_sample) / FCLK_HZ) * 1000.0;

    throughput = (phase_compute_ms > 0.0)
               ? (real'(N) / (phase_compute_ms / 1000.0))
               : 0.0;

    achieved_gflops = (phase_compute_ms > 0.0)
                    ? ((real'(N) * OPS_PER_SAMPLE) /
                       (phase_compute_ms / 1000.0) / 1000000000.0)
                    : 0.0;

    arith_intensity = OPS_PER_SAMPLE / BYTES_PER_SAMPLE;

    $display("====================================");
    $display("TOTAL       = %0d", N);
    $display("CORRECT     = %0d", correct);
    $display("ACCURACY    = %0.4f %%", accuracy * 100.0);
    $display("THROUGHPUT  = %0.4f samples/sec", throughput);
    $display("LATENCY     = %0.8f ms", latency_ms);
    $display("GFLOPS      = %0.6f", achieved_gflops);
    $display("ARITH INT   = %0.6f ops/byte", arith_intensity);
    $display("====================================");

    $fdisplay(file_acc_out,
      "cnn_mnist,Fixed-INT8,N/A,%f,N/A,N/A,0.0",
      accuracy);

    $fdisplay(file_perf_out,
      "cnn_mnist,int8,%0d,%f,%f,%f,SEE_VCD,SEE_VCD,%f,0.0,%f,0.0,%f,0.0,N/A",
      N,
      throughput,
      latency_ms,
      latency_ms,
      achieved_gflops,
      arith_intensity,
      phase_compute_ms);

    $display("CSV FILES GENERATED:");
    $display("acc_results.csv");
    $display("perf_results.csv");
    $display("waveform.vcd");

    $fclose(file_acc_out);
    $fclose(file_perf_out);

    $finish;
  end

endmodule
