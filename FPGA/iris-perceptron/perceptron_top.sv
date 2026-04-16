`timescale 1ns / 1ps

module perceptron_top (
    input  logic clk,
    input  logic rst,
    input  logic start,

    input  logic signed [15:0] x_in [4],
    output logic y_out,
    output logic signed [31:0] debug_dot,
    output logic [31:0] elapsed_cycles
);

    localparam signed [15:0] W0   = -16'sd538;
    localparam signed [15:0] W1   = -16'sd1946;
    localparam signed [15:0] W2   =  16'sd2611;
    localparam signed [15:0] W3   =  16'sd1254;
    localparam signed [15:0] BIAS = -16'sd256;

    logic signed [31:0] mult0, mult1, mult2, mult3;
    logic signed [31:0] sum;

    logic [31:0] cycle_counter;
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            cycle_counter <= 0;
        else
            cycle_counter <= cycle_counter + 1;
    end

    // Pipeline Stage 1: multiply
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            mult0 <= 0; mult1 <= 0; mult2 <= 0; mult3 <= 0;
        end else begin
            mult0 <= x_in[0] * W0;
            mult1 <= x_in[1] * W1;
            mult2 <= x_in[2] * W2;
            mult3 <= x_in[3] * W3;
        end
    end

    // Pipeline Stage 2: accumulate
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            sum <= 0;
        else
            sum <= mult0 + mult1 + mult2 + mult3 + BIAS;
    end

    // Pipeline Stage 3: activation (step function)
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            y_out <= 0;
        else
            y_out <= (sum >= 0);
    end

    assign debug_dot = sum;

    // Latency measurement (3-cycle pipeline after start)
    logic [31:0] start_cycle, end_cycle;
    logic [1:0] latency_counter;
    logic measuring;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            measuring       <= 0;
            latency_counter <= 0;
            start_cycle     <= 0;
            end_cycle       <= 0;
        end else begin
            if (start) begin
                start_cycle     <= cycle_counter;
                latency_counter <= 0;
                measuring       <= 1;
            end else if (measuring) begin
                latency_counter <= latency_counter + 1;
                if (latency_counter == 2'd3) begin
                    end_cycle <= cycle_counter;
                    measuring <= 0;
                end
            end
        end
    end

    assign elapsed_cycles = end_cycle - start_cycle;

endmodule
