module weights_rom #(
    parameter int DATA_W  = 16,
    parameter int CLASS_W = 3,
    parameter int FEAT_W  = 4
)(
    input  logic [CLASS_W-1:0] class_idx,
    input  logic [FEAT_W-1:0]  feat_idx,
    output logic signed [DATA_W-1:0] w
);

    always_comb begin
        w = '0;

        case (class_idx)

            3'd0: begin
                case (feat_idx)
                    4'd0:  w =  16'sd110;
                    4'd1:  w = -16'sd11;
                    4'd2:  w = -16'sd32;
                    4'd3:  w = -16'sd187;
                    4'd4:  w =  16'sd278;
                    4'd5:  w = -16'sd524;
                    4'd6:  w = -16'sd452;
                    4'd7:  w =  16'sd971;
                    4'd8:  w =  16'sd12;
                    4'd9:  w =  16'sd65;
                    4'd10: w = -16'sd69;
                    4'd11: w =  16'sd12;
                    4'd12: w = -16'sd59;
                endcase
            end

            3'd1: begin
                case (feat_idx)
                    4'd0:  w = -16'sd19;
                    4'd1:  w = -16'sd5;
                    4'd2:  w =  16'sd21;
                    4'd3:  w =  16'sd14;
                    4'd4:  w = -16'sd48;
                    4'd5:  w =  16'sd28;
                    4'd6:  w = -16'sd103;
                    4'd7:  w =  16'sd86;
                    4'd8:  w = -16'sd6;
                    4'd9:  w =  16'sd8;
                    4'd10: w =  16'sd15;
                    4'd11: w = -16'sd23;
                    4'd12: w = -16'sd28;
                endcase
            end

            3'd2: begin
                case (feat_idx)
                    4'd0:  w =  16'sd11;
                    4'd1:  w = -16'sd63;
                    4'd2:  w =  16'sd13;
                    4'd3:  w =  16'sd20;
                    4'd4:  w = -16'sd21;
                    4'd5:  w =  16'sd160;
                    4'd6:  w =  16'sd466;
                    4'd7:  w = -16'sd590;
                    4'd8:  w =  16'sd44;
                    4'd9:  w = -16'sd71;
                    4'd10: w =  16'sd43;
                    4'd11: w =  16'sd71;
                    4'd12: w =  16'sd2;
                endcase
            end

            3'd3: begin
                case (feat_idx)
                    4'd0:  w =  16'sd2;
                    4'd1:  w =  16'sd11;
                    4'd2:  w =  16'sd0;
                    4'd3:  w = -16'sd4;
                    4'd4:  w = -16'sd50;
                    4'd5:  w =  16'sd14;
                    4'd6:  w = -16'sd112;
                    4'd7:  w =  16'sd97;
                    4'd8:  w =  16'sd6;
                    4'd9:  w = -16'sd115;
                    4'd10: w =  16'sd85;
                    4'd11: w = -16'sd51;
                    4'd12: w = -16'sd3;
                endcase
            end

            3'd4: begin
                case (feat_idx)
                    4'd0:  w =  16'sd34;
                    4'd1:  w =  16'sd40;
                    4'd2:  w = -16'sd10;
                    4'd3:  w =  16'sd62;
                    4'd4:  w =  16'sd43;
                    4'd5:  w = -16'sd127;
                    4'd6:  w =  16'sd210;
                    4'd7:  w = -16'sd180;
                    4'd8:  w = -16'sd28;
                    4'd9:  w =  16'sd115;
                    4'd10: w = -16'sd90;
                    4'd11: w = -16'sd47;
                    4'd12: w =  16'sd49;
                endcase
            end

        endcase
    end

endmodule
