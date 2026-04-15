module svm_score #(
    parameter int N = 13,
    parameter int DATA_W = 16,
    parameter int BIAS_W = 32,
    parameter int ACC_W  = 40
)(
    input  logic signed [N*DATA_W-1:0] x_flat,
    input  logic signed [N*DATA_W-1:0] w_flat,
    input  logic signed [BIAS_W-1:0]   b,
    output logic signed [ACC_W-1:0]    score
);

    integer i;
    logic signed [DATA_W-1:0] x_i;
    logic signed [DATA_W-1:0] w_i;
    logic signed [2*DATA_W-1:0] mult;

    always_comb begin
        score = {{(ACC_W-BIAS_W){b[BIAS_W-1]}}, b};

        for (i = 0; i < N; i = i + 1) begin
            x_i  = x_flat[i*DATA_W +: DATA_W];
            w_i  = w_flat[i*DATA_W +: DATA_W];
            mult = x_i * w_i;
            score = score + {{(ACC_W-(2*DATA_W)){mult[2*DATA_W-1]}}, mult};
        end
    end

endmodule
