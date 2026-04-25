`timescale 1ns/1ps

module cnn_benchmark (
    input logic clk,
    input logic rst,
    input logic start,
    input logic valid_out,

    input logic [3:0] pred_class,
    input logic [3:0] true_class,

    output logic [31:0] total_cycles,
    output logic [31:0] correct_samples,
    output logic [31:0] wrong_samples,
    output logic [31:0] total_samples
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
      start_cycle <= 0;
      total_cycles <= 0;
    end else begin
      if (start)
        start_cycle <= cycle_counter;

      if (valid_out)
        total_cycles <= total_cycles + (cycle_counter - start_cycle);
    end
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      correct_samples <= 0;
      wrong_samples <= 0;
      total_samples <= 0;
    end else if (valid_out) begin
      total_samples <= total_samples + 1;

      if (pred_class == true_class)
        correct_samples <= correct_samples + 1;
      else
        wrong_samples <= wrong_samples + 1;
    end
  end

endmodule
