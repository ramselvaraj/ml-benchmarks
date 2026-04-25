module maxpool2x2_int32 #(
    parameter int H  = 26,
    parameter int W  = 26,
    parameter int C  = 32,
    parameter int DW = 32
)(
    input  logic signed [DW-1:0] x [0:H*W*C-1],
    output logic signed [DW-1:0] y [0:(H/2)*(W/2)*C-1]
);

  function automatic int x_idx(input int r, input int c, input int ch);
    return ((r*W + c)*C + ch);
  endfunction

  function automatic int y_idx(input int r, input int c, input int ch);
    return ((r*(W/2) + c)*C + ch);
  endfunction

  integer r, c, ch;
  logic signed [DW-1:0] m0, m1, m2, m3, m01, m23;

  always_comb begin
    for (r = 0; r < H/2; r = r + 1) begin
      for (c = 0; c < W/2; c = c + 1) begin
        for (ch = 0; ch < C; ch = ch + 1) begin
          m0 = x[x_idx(2*r,   2*c,   ch)];
          m1 = x[x_idx(2*r,   2*c+1, ch)];
          m2 = x[x_idx(2*r+1, 2*c,   ch)];
          m3 = x[x_idx(2*r+1, 2*c+1, ch)];

          m01 = (m0 > m1) ? m0 : m1;
          m23 = (m2 > m3) ? m2 : m3;
          y[y_idx(r, c, ch)] = (m01 > m23) ? m01 : m23;
        end
      end
    end
  end

endmodule
