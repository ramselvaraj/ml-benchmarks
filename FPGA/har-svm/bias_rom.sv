module bias_rom #(
    parameter int BIAS_W  = 32,
    parameter int CLASS_W = 3
)(
    input  logic [CLASS_W-1:0] class_idx,
    output logic signed [BIAS_W-1:0] b
);

    always_comb begin
        case (class_idx)
            3'd0: b = -32'sd518;
            3'd1: b = -32'sd230;
            3'd2: b = -32'sd159;
            3'd3: b = -32'sd242;
            3'd4: b = -32'sd174;
            default: b = '0;
        endcase
    end

endmodule
