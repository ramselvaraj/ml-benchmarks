import cnn_pkg_fpga::*;
import cnn_types_fpga::*;

module conv1_bias_rom (
    input  logic [$clog2(C1_OUT)-1:0] addr,
    output qint8_t data
);

  qint8_t rom [0:C1_OUT-1];

  initial begin
    $readmemh("mem/conv1_biases.mem", rom);
  end

  assign data = rom[addr];

endmodule
