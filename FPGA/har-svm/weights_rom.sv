module weights_rom #(
    parameter int NUM_CLASSES = 5,
    parameter int N = 13,
    parameter int DATA_W = 16,
    parameter int CLASS_W = 3
)(
    input  logic [CLASS_W-1:0] class_idx,
    output logic signed [N*DATA_W-1:0] w_flat
);

    always_comb begin
        case (class_idx)

            3'd0: w_flat = {
                -16'sd59,  16'sd12,  -16'sd69,  16'sd65,  16'sd12,  16'sd971,
                -16'sd452, -16'sd524, 16'sd278, -16'sd187, -16'sd32, -16'sd11,
                 16'sd110
            };

            3'd1: w_flat = {
                -16'sd28, -16'sd23,  16'sd15,   16'sd8,   -16'sd6,   16'sd86,
                -16'sd103, 16'sd28,  -16'sd48,  16'sd14,   16'sd21,  -16'sd5,
                -16'sd19
            };

            3'd2: w_flat = {
                 16'sd2,    16'sd71,  16'sd43,  -16'sd71,  16'sd44,  -16'sd590,
                 16'sd466,  16'sd160, -16'sd21,  16'sd20,   16'sd13, -16'sd63,
                 16'sd11
            };

            3'd3: w_flat = {
                -16'sd3,   -16'sd51,  16'sd85,  -16'sd115, 16'sd6,    16'sd97,
                -16'sd112,  16'sd14, -16'sd50,  -16'sd4,    16'sd0,    16'sd11,
                 16'sd2
            };

            3'd4: w_flat = {
                 16'sd49,  -16'sd47, -16'sd90,  16'sd115, -16'sd28, -16'sd180,
                 16'sd210, -16'sd127, 16'sd43,   16'sd62, -16'sd10,  16'sd40,
                 16'sd34
            };

            default: w_flat = '0;
        endcase
    end

endmodule
