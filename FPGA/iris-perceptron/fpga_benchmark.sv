`timescale 1ns / 1ps

module fpga_benchmark (
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic valid_out,
    input  logic y_pred,
    input  logic y_true,       // 1-bit: 0 or 1

    output logic [31:0] total_cycles,
    output logic [31:0] TP, TN, FP, FN,
    output logic [31:0] correct,
    output logic [31:0] total
);

    logic [31:0] cycle_counter;
    logic [31:0] start_cycle;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            cycle_counter <= 0;
        else
            cycle_counter <= cycle_counter + 1;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            start_cycle  <= 0;
            total_cycles <= 0;
        end else begin
            if (start)
                start_cycle <= cycle_counter;
            if (valid_out)
                total_cycles <= cycle_counter - start_cycle;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            TP <= 0; TN <= 0; FP <= 0; FN <= 0;
            correct <= 0;
            total   <= 0;
        end else if (valid_out) begin
            total <= total + 1;

            if (y_pred == y_true)
                correct <= correct + 1;

            if (y_true == 1'b1 && y_pred == 1'b1) TP <= TP + 1;
            if (y_true == 1'b0 && y_pred == 1'b0) TN <= TN + 1;
            if (y_true == 1'b0 && y_pred == 1'b1) FP <= FP + 1;
            if (y_true == 1'b1 && y_pred == 1'b0) FN <= FN + 1;
        end
    end

endmodule
