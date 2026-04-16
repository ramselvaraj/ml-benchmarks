module relu_int32 #(
    parameter int N  = 1,
    parameter int DW = 32
)(
    input  logic signed [DW-1:0] in_vec [0:N-1],
    output logic signed [DW-1:0] out_vec[0:N-1]
);

  integer i;
  always_comb begin
    for (i = 0; i < N; i = i + 1) begin
      if (in_vec[i] < 0)
        out_vec[i] = '0;
      else
        out_vec[i] = in_vec[i];
    end
  end

endmodule
