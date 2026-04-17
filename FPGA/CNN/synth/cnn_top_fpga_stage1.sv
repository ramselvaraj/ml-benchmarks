import cnn_pkg_fpga::*;
import cnn_types_fpga::*;
`include "cnn_defs_fpga.svh"

module cnn_top_fpga_stage1 (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    output logic done
);

  // -------------------------
  // Memories
  // -------------------------

  // Input image
  qint8_t img_mem [0:IMG_H*IMG_W*IMG_C-1];

  // Conv1 output
  qint32_t conv1_out [0:C1_H*C1_W*C1_OUT-1];

  // ReLU output
  qint32_t relu_out [0:C1_H*C1_W*C1_OUT-1];

  // Pool output
  qint32_t pool_out [0:P1_H*P1_W*C1_OUT-1];

  // -------------------------
  // Control signals
  // -------------------------

  logic conv1_done;

  // -------------------------
  // Load test image (for now)
  // -------------------------
  initial begin
    $readmemh("mem/sample_0_input_int8.mem", img_mem);
  end

  // -------------------------
  // Conv1 Engine
  // -------------------------
  conv1_engine_fpga u_conv1 (
      .clk(clk),
      .rst_n(rst_n),
      .start(start),
      .img_mem(img_mem),
      .done(conv1_done),
      .out_mem(conv1_out)
  );

  // -------------------------
  // ReLU (combinational)
  // -------------------------
  relu_fpga #(
      .N(C1_H*C1_W*C1_OUT)
  ) u_relu (
      .in_data(conv1_out),
      .out_data(relu_out)
  );

  // -------------------------
  // MaxPool 2x2
  // -------------------------
  maxpool2x2_fpga #(
      .H(C1_H),
      .W(C1_W),
      .C(C1_OUT)
  ) u_pool (
      .in_data(relu_out),
      .out_data(pool_out)
  );

  // -------------------------
  // Done logic
  // -------------------------
  assign done = conv1_done;

endmodule
