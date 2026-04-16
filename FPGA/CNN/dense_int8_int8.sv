module dense_int8_int8 #(
    parameter int IN_N  = 576,
    parameter int OUT_N = 64,
    parameter int DW_X  = 8,
    parameter int DW_W  = 8,
    parameter int DW_B  = 8,
    parameter int DW_Y  = 32
)(
    input  logic signed [DW_X-1:0] x [0:IN_N-1],
    input  logic signed [DW_W-1:0] w [0:IN_N*OUT_N-1],
    input  logic signed [DW_B-1:0] b [0:OUT_N-1],
    output logic signed [DW_Y-1:0] y [0:OUT_N-1]
);

  function automatic int w_idx(input int i, input int o);
    return (i*OUT_N + o);
  endfunction

  integer o, i;
  logic signed [DW_Y-1:0] acc;

  always_comb begin
    for (o = 0; o < OUT_N; o = o + 1) begin
      acc = b[o];
      for (i = 0; i < IN_N; i = i + 1)
        acc = acc + x[i] * w[w_idx(i, o)];
      y[o] = acc;
    end
  end

endmodule
