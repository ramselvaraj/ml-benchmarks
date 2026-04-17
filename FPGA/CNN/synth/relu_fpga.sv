import cnn_types_fpga::*;

module relu_fpga #(
    parameter int N = 1
)(
    input  qint32_t in_data  [0:N-1],
    output qint32_t out_data [0:N-1]
);

  genvar i;
  generate
    for (i = 0; i < N; i++) begin : RELU_GEN
      assign out_data[i] = (in_data[i] < 0) ? 0 : in_data[i];
    end
  endgenerate

endmodule
