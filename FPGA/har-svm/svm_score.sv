module svm_score #(
    parameter int DATA_W = 16,
    parameter int ACC_W  = 40
)(
    input  logic signed [DATA_W-1:0] x_i,
    input  logic signed [DATA_W-1:0] w_i,
    input  logic signed [ACC_W-1:0]  acc_in,
    output logic signed [ACC_W-1:0]  acc_out
);

    logic signed [2*DATA_W-1:0] mult;

    always_comb begin
        mult    = x_i * w_i;
        acc_out = acc_in + {{(ACC_W-(2*DATA_W)){mult[2*DATA_W-1]}}, mult};
    end

endmodule
