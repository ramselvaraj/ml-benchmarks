module svm_top #(
    parameter int NUM_CLASSES = 5,
    parameter int NUM_FEATS   = 13,
    parameter int DATA_W      = 16,
    parameter int ACC_W       = 40,
    parameter int CLASS_W     = 3,
    parameter int FEAT_W      = 4
)(
    input  logic clk,
    input  logic rst,
    input  logic start,

    input  logic signed [DATA_W-1:0] x0,
    input  logic signed [DATA_W-1:0] x1,
    input  logic signed [DATA_W-1:0] x2,
    input  logic signed [DATA_W-1:0] x3,
    input  logic signed [DATA_W-1:0] x4,
    input  logic signed [DATA_W-1:0] x5,
    input  logic signed [DATA_W-1:0] x6,
    input  logic signed [DATA_W-1:0] x7,
    input  logic signed [DATA_W-1:0] x8,
    input  logic signed [DATA_W-1:0] x9,
    input  logic signed [DATA_W-1:0] x10,
    input  logic signed [DATA_W-1:0] x11,
    input  logic signed [DATA_W-1:0] x12,

    output logic done,
    output logic [CLASS_W-1:0] prediction,
    output logic signed [ACC_W-1:0] debug_score,
    output logic [15:0] elapsed_cycles
);

    typedef enum logic [2:0] {
        IDLE,
        INIT_CLASS,
        MAC_RUN,
        ADD_BIAS,
        UPDATE_MAX,
        FINISH
    } state_t;

    state_t state;

    logic [CLASS_W-1:0] class_idx;
    logic [FEAT_W-1:0]  feat_idx;

    logic signed [ACC_W-1:0] acc;
    logic signed [ACC_W-1:0] acc_next;
    logic signed [ACC_W-1:0] score_with_bias;

    logic signed [ACC_W-1:0] max_score;
    logic first_class;

    logic signed [DATA_W-1:0] x_i;
    logic signed [DATA_W-1:0] w_i;
    logic signed [31:0]       b_i;

    always_comb begin
        case (feat_idx)
            4'd0:  x_i = x0;
            4'd1:  x_i = x1;
            4'd2:  x_i = x2;
            4'd3:  x_i = x3;
            4'd4:  x_i = x4;
            4'd5:  x_i = x5;
            4'd6:  x_i = x6;
            4'd7:  x_i = x7;
            4'd8:  x_i = x8;
            4'd9:  x_i = x9;
            4'd10: x_i = x10;
            4'd11: x_i = x11;
            4'd12: x_i = x12;
            default: x_i = '0;
        endcase
    end

    weights_rom #(
        .DATA_W(DATA_W),
        .CLASS_W(CLASS_W),
        .FEAT_W(FEAT_W)
    ) u_weights_rom (
        .class_idx(class_idx),
        .feat_idx(feat_idx),
        .w(w_i)
    );

    bias_rom #(
        .BIAS_W(32),
        .CLASS_W(CLASS_W)
    ) u_bias_rom (
        .class_idx(class_idx),
        .b(b_i)
    );

    svm_score #(
        .DATA_W(DATA_W),
        .ACC_W(ACC_W)
    ) u_svm_score (
        .x_i(x_i),
        .w_i(w_i),
        .acc_in(acc),
        .acc_out(acc_next)
    );

    always_comb begin
        score_with_bias = acc + {{(ACC_W-32){b_i[31]}}, b_i};
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state          <= IDLE;
            class_idx      <= '0;
            feat_idx       <= '0;
            acc            <= '0;
            max_score      <= '0;
            prediction     <= '0;
            done           <= 1'b0;
            first_class    <= 1'b1;
            debug_score    <= '0;
            elapsed_cycles <= 16'd0;
        end else begin
            case (state)

                IDLE: begin
                    done <= 1'b0;
                    elapsed_cycles <= 16'd0;

                    if (start) begin
                        class_idx   <= '0;
                        feat_idx    <= '0;
                        acc         <= '0;
                        max_score   <= '0;
                        prediction  <= '0;
                        first_class <= 1'b1;
                        state       <= INIT_CLASS;
                    end
                end

                INIT_CLASS: begin
                    acc      <= '0;
                    feat_idx <= '0;
                    state    <= MAC_RUN;
                end

                MAC_RUN: begin
                    elapsed_cycles <= elapsed_cycles + 16'd1;
                    acc <= acc_next;

                    if (feat_idx == NUM_FEATS-1) begin
                        state <= ADD_BIAS;
                    end else begin
                        feat_idx <= feat_idx + 1'b1;
                    end
                end

                ADD_BIAS: begin
                    elapsed_cycles <= elapsed_cycles + 16'd1;
                    debug_score <= score_with_bias;
                    state <= UPDATE_MAX;
                end

                UPDATE_MAX: begin
                    elapsed_cycles <= elapsed_cycles + 16'd1;

                    if (first_class || score_with_bias > max_score) begin
                        max_score  <= score_with_bias;
                        prediction <= class_idx;
                    end

                    first_class <= 1'b0;

                    if (class_idx == NUM_CLASSES-1) begin
                        state <= FINISH;
                    end else begin
                        class_idx <= class_idx + 1'b1;
                        state <= INIT_CLASS;
                    end
                end

                FINISH: begin
                    elapsed_cycles <= elapsed_cycles + 16'd1;
                    done <= 1'b1;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule
