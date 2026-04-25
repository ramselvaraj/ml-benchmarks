module conv2d_valid_int8 #(
    parameter int H    = 28,
    parameter int W    = 28,
    parameter int CIN  = 1,
    parameter int COUT = 32,
    parameter int K    = 3,
    parameter int DW_X = 8,
    parameter int DW_W = 8,
    parameter int DW_B = 8,
    parameter int DW_Y = 32
)(
    input  logic signed [DW_X-1:0] x [0:H*W*CIN-1],
    input  logic signed [DW_W-1:0] w [0:K*K*CIN*COUT-1],
    input  logic signed [DW_B-1:0] b [0:COUT-1],
    output logic signed [DW_Y-1:0] y [0:(H-K+1)*(W-K+1)*COUT-1]
);

  function automatic int x_idx(input int r, input int c, input int ch);
    return ((r*W + c)*CIN + ch);
  endfunction

  function automatic int w_idx(input int kr, input int kc, input int ci, input int co);
    return ((((kr*K + kc)*CIN + ci)*COUT) + co);
  endfunction

  function automatic int y_idx(input int r, input int c, input int co);
    return (((r*(W-K+1) + c)*COUT) + co);
  endfunction

  integer r, c, co, kr, kc, ci;
  logic signed [DW_Y-1:0] acc;

  always_comb begin
    for (r = 0; r < (H-K+1); r = r + 1) begin
      for (c = 0; c < (W-K+1); c = c + 1) begin
        for (co = 0; co < COUT; co = co + 1) begin
          acc = b[co];
          for (kr = 0; kr < K; kr = kr + 1) begin
            for (kc = 0; kc < K; kc = kc + 1) begin
              for (ci = 0; ci < CIN; ci = ci + 1) begin
                acc = acc + x[x_idx(r+kr, c+kc, ci)] * w[w_idx(kr, kc, ci, co)];
              end
            end
          end
          y[y_idx(r, c, co)] = acc;
        end
      end
    end
  end

endmodule
