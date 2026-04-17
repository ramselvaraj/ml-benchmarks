import cnn_pkg_fpga::*;
import cnn_types_fpga::*;
`include "cnn_defs_fpga.svh"

module cnn_top_fpga (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    output logic done
);

  // Input image memory: 28x28x1 = 784
  qint8_t img_mem [0:IMG_H*IMG_W*IMG_C-1];

  // Conv1 output feature map: 26x26x32
  qint32_t conv1_out_mem [0:C1_H*C1_W*C1_OUT-1];

  // Optional init for a fixed test image
  // For board deployment later, this should be replaced by BRAM write path,
  // AXI, UART loader, DMA, etc.
  initial begin
    $readmemh("mem/sample_0_input_int8.mem", img_mem);
  end

  conv1_engine_fpga u_conv1 (
      .clk(clk),
      .rst_n(rst_n),
      .start(start),
      .img_mem(img_mem),
      .done(done),
      .out_mem(conv1_out_mem)
  );

endmodule
