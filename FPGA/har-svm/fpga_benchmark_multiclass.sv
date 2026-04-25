module fpga_benchmark_multiclass #(
    parameter int NUM_CLASSES = 5,
    parameter int CLASS_W     = 3,
    parameter int COUNT_W     = 32
)(
    input  logic clk,
    input  logic rst,

    input  logic sample_done,
    input  logic [CLASS_W-1:0] y_pred,
    input  logic [CLASS_W-1:0] y_true,
    input  logic [15:0] sample_cycles,

    output logic [COUNT_W-1:0] total_samples,
    output logic [COUNT_W-1:0] correct_samples,
    output logic [COUNT_W-1:0] wrong_samples,
    output logic [COUNT_W-1:0] total_cycles,

    output logic [COUNT_W-1:0] class0_correct,
    output logic [COUNT_W-1:0] class1_correct,
    output logic [COUNT_W-1:0] class2_correct,
    output logic [COUNT_W-1:0] class3_correct,
    output logic [COUNT_W-1:0] class4_correct,

    output logic [COUNT_W-1:0] class0_total,
    output logic [COUNT_W-1:0] class1_total,
    output logic [COUNT_W-1:0] class2_total,
    output logic [COUNT_W-1:0] class3_total,
    output logic [COUNT_W-1:0] class4_total
);

    wire is_correct;
    assign is_correct = (y_pred == y_true);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            total_samples  <= '0;
            correct_samples <= '0;
            wrong_samples  <= '0;
            total_cycles   <= '0;

            class0_correct <= '0;
            class1_correct <= '0;
            class2_correct <= '0;
            class3_correct <= '0;
            class4_correct <= '0;

            class0_total   <= '0;
            class1_total   <= '0;
            class2_total   <= '0;
            class3_total   <= '0;
            class4_total   <= '0;
        end else begin
            if (sample_done) begin
                total_samples <= total_samples + 1'b1;
                total_cycles  <= total_cycles + sample_cycles;

                if (is_correct)
                    correct_samples <= correct_samples + 1'b1;
                else
                    wrong_samples <= wrong_samples + 1'b1;

                case (y_true)
                    3'd0: begin
                        class0_total <= class0_total + 1'b1;
                        if (is_correct) class0_correct <= class0_correct + 1'b1;
                    end

                    3'd1: begin
                        class1_total <= class1_total + 1'b1;
                        if (is_correct) class1_correct <= class1_correct + 1'b1;
                    end

                    3'd2: begin
                        class2_total <= class2_total + 1'b1;
                        if (is_correct) class2_correct <= class2_correct + 1'b1;
                    end

                    3'd3: begin
                        class3_total <= class3_total + 1'b1;
                        if (is_correct) class3_correct <= class3_correct + 1'b1;
                    end

                    3'd4: begin
                        class4_total <= class4_total + 1'b1;
                        if (is_correct) class4_correct <= class4_correct + 1'b1;
                    end

                    default: begin
                    end
                endcase
            end
        end
    end

endmodule
