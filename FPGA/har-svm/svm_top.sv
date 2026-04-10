module svm_top #(
    parameter int N = 13,
    parameter int DATA_W = 16,
    parameter int BIAS_W = 32,
    parameter int ACC_W = 40,
    parameter int NUM_CLASSES = 5,
    parameter int CLASS_W = 3
)(
    input  logic signed [N*DATA_W-1:0] x_flat,
    output logic [CLASS_W-1:0]         pred_class,
    output logic signed [ACC_W-1:0]    max_score
);

    logic signed [N*DATA_W-1:0] w_flat_0, w_flat_1, w_flat_2, w_flat_3, w_flat_4;
    logic signed [BIAS_W-1:0]   b_0, b_1, b_2, b_3, b_4;
    logic signed [ACC_W-1:0]    score_0, score_1, score_2, score_3, score_4;

    logic signed [NUM_CLASSES*ACC_W-1:0] scores_flat;

    weights_rom #(
        .NUM_CLASSES(NUM_CLASSES),
        .N(N),
        .DATA_W(DATA_W),
        .CLASS_W(CLASS_W)
    ) weights_rom_0 (
        .class_idx(3'd0),
        .w_flat(w_flat_0)
    );

    weights_rom #(
        .NUM_CLASSES(NUM_CLASSES),
        .N(N),
        .DATA_W(DATA_W),
        .CLASS_W(CLASS_W)
    ) weights_rom_1 (
        .class_idx(3'd1),
        .w_flat(w_flat_1)
    );

    weights_rom #(
        .NUM_CLASSES(NUM_CLASSES),
        .N(N),
        .DATA_W(DATA_W),
        .CLASS_W(CLASS_W)
    ) weights_rom_2 (
        .class_idx(3'd2),
        .w_flat(w_flat_2)
    );

    weights_rom #(
        .NUM_CLASSES(NUM_CLASSES),
        .N(N),
        .DATA_W(DATA_W),
        .CLASS_W(CLASS_W)
    ) weights_rom_3 (
        .class_idx(3'd3),
        .w_flat(w_flat_3)
    );

    weights_rom #(
        .NUM_CLASSES(NUM_CLASSES),
        .N(N),
        .DATA_W(DATA_W),
        .CLASS_W(CLASS_W)
    ) weights_rom_4 (
        .class_idx(3'd4),
        .w_flat(w_flat_4)
    );

    bias_rom #(
        .NUM_CLASSES(NUM_CLASSES),
        .BIAS_W(BIAS_W),
        .CLASS_W(CLASS_W)
    ) bias_rom_0 (
        .class_idx(3'd0),
        .b(b_0)
    );

    bias_rom #(
        .NUM_CLASSES(NUM_CLASSES),
        .BIAS_W(BIAS_W),
        .CLASS_W(CLASS_W)
    ) bias_rom_1 (
        .class_idx(3'd1),
        .b(b_1)
    );

    bias_rom #(
        .NUM_CLASSES(NUM_CLASSES),
        .BIAS_W(BIAS_W),
        .CLASS_W(CLASS_W)
    ) bias_rom_2 (
        .class_idx(3'd2),
        .b(b_2)
    );

    bias_rom #(
        .NUM_CLASSES(NUM_CLASSES),
        .BIAS_W(BIAS_W),
        .CLASS_W(CLASS_W)
    ) bias_rom_3 (
        .class_idx(3'd3),
        .b(b_3)
    );

    bias_rom #(
        .NUM_CLASSES(NUM_CLASSES),
        .BIAS_W(BIAS_W),
        .CLASS_W(CLASS_W)
    ) bias_rom_4 (
        .class_idx(3'd4),
        .b(b_4)
    );

    svm_score #(
        .N(N),
        .DATA_W(DATA_W),
        .BIAS_W(BIAS_W),
        .ACC_W(ACC_W)
    ) svm_score_0 (
        .x_flat(x_flat),
        .w_flat(w_flat_0),
        .b(b_0),
        .score(score_0)
    );

    svm_score #(
        .N(N),
        .DATA_W(DATA_W),
        .BIAS_W(BIAS_W),
        .ACC_W(ACC_W)
    ) svm_score_1 (
        .x_flat(x_flat),
        .w_flat(w_flat_1),
        .b(b_1),
        .score(score_1)
    );

    svm_score #(
        .N(N),
        .DATA_W(DATA_W),
        .BIAS_W(BIAS_W),
        .ACC_W(ACC_W)
    ) svm_score_2 (
        .x_flat(x_flat),
        .w_flat(w_flat_2),
        .b(b_2),
        .score(score_2)
    );

    svm_score #(
        .N(N),
        .DATA_W(DATA_W),
        .BIAS_W(BIAS_W),
        .ACC_W(ACC_W)
    ) svm_score_3 (
        .x_flat(x_flat),
        .w_flat(w_flat_3),
        .b(b_3),
        .score(score_3)
    );

    svm_score #(
        .N(N),
        .DATA_W(DATA_W),
        .BIAS_W(BIAS_W),
        .ACC_W(ACC_W)
    ) svm_score_4 (
        .x_flat(x_flat),
        .w_flat(w_flat_4),
        .b(b_4),
        .score(score_4)
    );

    assign scores_flat = {score_4, score_3, score_2, score_1, score_0};

    argmax #(
        .NUM_CLASSES(NUM_CLASSES),
        .SCORE_W(ACC_W),
        .CLASS_W(CLASS_W)
    ) argmax_inst (
        .scores_flat(scores_flat),
        .max_index(pred_class),
        .max_score(max_score)
    );

endmodule
