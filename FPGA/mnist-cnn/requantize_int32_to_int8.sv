module requantize_int32_to_int8 #(
    parameter int N      = 1,
    parameter int IN_DW  = 32,
    parameter int OUT_DW = 8,
    parameter int SHIFT  = 8
)(
    input  logic signed [IN_DW-1:0] in_vec [0:N-1],
    output logic signed [OUT_DW-1:0] out_vec[0:N-1]
);

  integer i;
  logic signed [IN_DW-1:0] tmp;

  always_comb begin
    for (i = 0; i < N; i = i + 1) begin
      tmp = in_vec[i] >>> SHIFT;

      if (tmp > 127)
        out_vec[i] = 8'sd127;
      else if (tmp < -128)
        out_vec[i] = -8'sd128;
      else
        out_vec[i] = tmp[OUT_DW-1:0];
    end
  end

endmodule
