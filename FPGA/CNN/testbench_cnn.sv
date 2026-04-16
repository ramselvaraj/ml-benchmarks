`timescale 1ns/1ps
`include "cnn_pkg.sv"

module testbench_cnn;

  parameter int N = 5;  // number of samples

  logic [3:0] pred_class [0:N-1];
  logic signed [31:0] logits [0:N-1][0:9];

  integer expected_pred;
  integer fd, code;
  integer correct = 0;

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

  // -------------------------
  // Check results
  // -------------------------
  initial begin
    #20;

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
          correct++;
        end else begin
          $display("MISMATCH");
        end
      end

    end

    $display("====================================");
    $display("TOTAL = %0d", N);
    $display("CORRECT = %0d", correct);
    $display("ACCURACY = %0f", (correct*100.0)/N);
    $display("====================================");

    $finish;
  end

endmodule
