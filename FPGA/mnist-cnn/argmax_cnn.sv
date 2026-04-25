module argmax_cnn #(
    parameter int N  = 10,
    parameter int DW = 32
)(
    input  logic signed [DW-1:0] in_vec [0:N-1],
    output logic [$clog2(N)-1:0] arg_idx,
    output logic signed [DW-1:0] max_val
);

  integer i;
  always_comb begin
    arg_idx = 0;
    max_val = in_vec[0];
    for (i = 1; i < N; i = i + 1) begin
      if (in_vec[i] > max_val) begin
        max_val = in_vec[i];
        arg_idx = i[$clog2(N)-1:0];
      end
    end
  end

endmodule
