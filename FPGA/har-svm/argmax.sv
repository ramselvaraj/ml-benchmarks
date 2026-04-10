module argmax #(
    parameter int NUM_CLASSES = 5,
    parameter int SCORE_W = 40,
    parameter int CLASS_W = 3
)(
    input  logic signed [NUM_CLASSES*SCORE_W-1:0] scores_flat,
    output logic        [CLASS_W-1:0]             max_index,
    output logic signed [SCORE_W-1:0]             max_score
);

    integer i;
    logic signed [SCORE_W-1:0] score_i;

    always_comb begin
        max_score = scores_flat[0 +: SCORE_W];
        max_index = 0;

        for (i = 1; i < NUM_CLASSES; i = i + 1) begin
            score_i = scores_flat[i*SCORE_W +: SCORE_W];
            if (score_i > max_score) begin
                max_score = score_i;
                max_index = i[CLASS_W-1:0];
            end
        end
    end

endmodule
