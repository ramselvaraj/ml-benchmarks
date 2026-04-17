import cnn_pkg_fpga::*;
import cnn_types_fpga::*;

module maxpool2x2_fpga #(
    parameter int H = 26,
    parameter int W = 26,
    parameter int C = 32
)(
    input  qint32_t in_data  [0:H*W*C-1],
    output qint32_t out_data [0:(H/2)*(W/2)*C-1]
);

  function automatic int in_idx(input int r, input int c, input int ch);
    return ((r * W + c) * C + ch);
  endfunction

  function automatic int out_idx(input int r, input int c, input int ch);
    return ((r * (W/2) + c) * C + ch);
  endfunction

  integer r, c, ch;

  always_comb begin
    for (r = 0; r < H/2; r = r + 1) begin
      for (c = 0; c < W/2; c = c + 1) begin
        for (ch = 0; ch < C; ch = ch + 1) begin

          qint32_t a, b, d, e;
          qint32_t m1, m2;

          a = in_data[in_idx(2*r,   2*c,   ch)];
          b = in_data[in_idx(2*r,   2*c+1, ch)];
          d = in_data[in_idx(2*r+1, 2*c,   ch)];
          e = in_data[in_idx(2*r+1, 2*c+1, ch)];

          m1 = (a > b) ? a : b;
          m2 = (d > e) ? d : e;

          out_data[out_idx(r, c, ch)] = (m1 > m2) ? m1 : m2;
        end
      end
    end
  end

endmodule
