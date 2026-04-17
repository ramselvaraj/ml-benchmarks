import cnn_pkg_fpga::*;
import cnn_types_fpga::*;

module conv1_weight_rom (
    input  logic [$clog2(K*K*IMG_C*C1_OUT)-1:0] addr,
    output qint8_t data
);

  // 3*3*1*32 = 288
  localparam int DEPTH = K*K*IMG_C*C1_OUT;

  qint8_t rom [0:DEPTH-1];

  initial begin
    // Vivado-friendly memory init
    $readmemh("mem/conv1_weights.mem", rom);
  end

  assign data = rom[addr];

endmodule
