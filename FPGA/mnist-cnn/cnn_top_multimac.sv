`timescale 1ns/1ps
import cnn_pkg::*;

module cnn_top_multimac #(
    parameter int PAR_MAC = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic start,

    input  logic signed [7:0] img_in [0:IMG_H*IMG_W-1],

    output logic done,
    output logic valid_out,
    output logic [3:0] pred_class,
    output logic signed [31:0] logits [0:9],
    output logic [31:0] elapsed_cycles
);

  localparam string BASE = "/home/a29208_asu/asap7_rundir/Project/CNN/";

  localparam int DOT1 = K*K*IMG_C;
  localparam int DOT2 = K*K*C1_OUT;
  localparam int DOT3 = K*K*C2_OUT;
  localparam int DOT4 = FLAT_LEN;
  localparam int DOT5 = FC1_OUT;

  logic signed [7:0]  w1 [0:K*K*IMG_C*C1_OUT-1];
  logic signed [31:0] b1 [0:C1_OUT-1];

  logic signed [7:0]  w2 [0:K*K*C1_OUT*C2_OUT-1];
  logic signed [31:0] b2 [0:C2_OUT-1];

  logic signed [7:0]  w3 [0:K*K*C2_OUT*C3_OUT-1];
  logic signed [31:0] b3 [0:C3_OUT-1];

  logic signed [7:0]  w4 [0:FLAT_LEN*FC1_OUT-1];
  logic signed [31:0] b4 [0:FC1_OUT-1];

  logic signed [7:0]  w5 [0:FC1_OUT*FC2_OUT-1];
  logic signed [31:0] b5 [0:FC2_OUT-1];

  logic signed [7:0] img [0:IMG_H*IMG_W-1];

  logic signed [31:0] c1 [0:C1_H*C1_W*C1_OUT-1];
  logic signed [7:0]  p1 [0:P1_H*P1_W*C1_OUT-1];

  logic signed [31:0] c2 [0:C2_H*C2_W*C2_OUT-1];
  logic signed [7:0]  p2 [0:P2_H*P2_W*C2_OUT-1];

  logic signed [31:0] c3 [0:C3_H*C3_W*C3_OUT-1];
  logic signed [7:0]  c3q [0:FLAT_LEN-1];

  logic signed [31:0] fc1 [0:FC1_OUT-1];
  logic signed [7:0]  fc1q [0:FC1_OUT-1];
  logic signed [31:0] fc2 [0:FC2_OUT-1];

  integer fd_load;
  integer val_load;
  integer code_load;

  initial begin
    fd_load = $fopen({BASE, "quantized_int8/conv2d_weights_int8.txt"}, "r");
    if (fd_load == 0) begin $display("ERROR opening conv2d_weights_int8.txt"); $finish; end
    for (int i = 0; i < K*K*IMG_C*C1_OUT; i++) begin
      code_load = $fscanf(fd_load, "%d", val_load);
      w1[i] = val_load[7:0];
    end
    $fclose(fd_load);

    fd_load = $fopen({BASE, "quantized_int8/conv2d_biases_int8.txt"}, "r");
    if (fd_load == 0) begin $display("ERROR opening conv2d_biases_int8.txt"); $finish; end
    for (int i = 0; i < C1_OUT; i++) begin
      code_load = $fscanf(fd_load, "%d", val_load);
      b1[i] = val_load;
    end
    $fclose(fd_load);

    fd_load = $fopen({BASE, "quantized_int8/conv2d_1_weights_int8.txt"}, "r");
    if (fd_load == 0) begin $display("ERROR opening conv2d_1_weights_int8.txt"); $finish; end
    for (int i = 0; i < K*K*C1_OUT*C2_OUT; i++) begin
      code_load = $fscanf(fd_load, "%d", val_load);
      w2[i] = val_load[7:0];
    end
    $fclose(fd_load);

    fd_load = $fopen({BASE, "quantized_int8/conv2d_1_biases_int8.txt"}, "r");
    if (fd_load == 0) begin $display("ERROR opening conv2d_1_biases_int8.txt"); $finish; end
    for (int i = 0; i < C2_OUT; i++) begin
      code_load = $fscanf(fd_load, "%d", val_load);
      b2[i] = val_load;
    end
    $fclose(fd_load);

    fd_load = $fopen({BASE, "quantized_int8/conv2d_2_weights_int8.txt"}, "r");
    if (fd_load == 0) begin $display("ERROR opening conv2d_2_weights_int8.txt"); $finish; end
    for (int i = 0; i < K*K*C2_OUT*C3_OUT; i++) begin
      code_load = $fscanf(fd_load, "%d", val_load);
      w3[i] = val_load[7:0];
    end
    $fclose(fd_load);

    fd_load = $fopen({BASE, "quantized_int8/conv2d_2_biases_int8.txt"}, "r");
    if (fd_load == 0) begin $display("ERROR opening conv2d_2_biases_int8.txt"); $finish; end
    for (int i = 0; i < C3_OUT; i++) begin
      code_load = $fscanf(fd_load, "%d", val_load);
      b3[i] = val_load;
    end
    $fclose(fd_load);

    fd_load = $fopen({BASE, "quantized_int8/dense_weights_int8.txt"}, "r");
    if (fd_load == 0) begin $display("ERROR opening dense_weights_int8.txt"); $finish; end
    for (int i = 0; i < FLAT_LEN*FC1_OUT; i++) begin
      code_load = $fscanf(fd_load, "%d", val_load);
      w4[i] = val_load[7:0];
    end
    $fclose(fd_load);

    fd_load = $fopen({BASE, "quantized_int8/dense_biases_int8.txt"}, "r");
    if (fd_load == 0) begin $display("ERROR opening dense_biases_int8.txt"); $finish; end
    for (int i = 0; i < FC1_OUT; i++) begin
      code_load = $fscanf(fd_load, "%d", val_load);
      b4[i] = val_load;
    end
    $fclose(fd_load);

    fd_load = $fopen({BASE, "quantized_int8/dense_1_weights_int8.txt"}, "r");
    if (fd_load == 0) begin $display("ERROR opening dense_1_weights_int8.txt"); $finish; end
    for (int i = 0; i < FC1_OUT*FC2_OUT; i++) begin
      code_load = $fscanf(fd_load, "%d", val_load);
      w5[i] = val_load[7:0];
    end
    $fclose(fd_load);

    fd_load = $fopen({BASE, "quantized_int8/dense_1_biases_int8.txt"}, "r");
    if (fd_load == 0) begin $display("ERROR opening dense_1_biases_int8.txt"); $finish; end
    for (int i = 0; i < FC2_OUT; i++) begin
      code_load = $fscanf(fd_load, "%d", val_load);
      b5[i] = val_load;
    end
    $fclose(fd_load);
  end

  typedef enum logic [4:0] {
    IDLE,
    LOAD_IMG,

    C1_INIT, C1_MAC, C1_SAVE,
    P1_RUN,

    C2_INIT, C2_MAC, C2_SAVE,
    P2_RUN,

    C3_INIT, C3_MAC, C3_SAVE,
    C3Q_RUN,

    FC1_INIT, FC1_MAC, FC1_SAVE,
    FC2_INIT, FC2_MAC, FC2_SAVE,

    ARGMAX_INIT, ARGMAX_RUN,
    DONE_STATE
  } state_t;

  state_t state;

  int idx;
  int oh, ow, oc;
  int mac_base;
  int pool_idx;
  int dense_o;
  int arg_i;

  logic signed [31:0] acc;
  logic signed [31:0] max_val;
  logic [3:0] max_idx;

  logic [31:0] cycle_counter;
  logic [31:0] start_cycle;

  function automatic signed [7:0] requant8(input signed [31:0] v);
    logic signed [31:0] shifted;
    begin
      shifted = v >>> 8;
      if (shifted > 127)
        requant8 = 8'sd127;
      else if (shifted < -128)
        requant8 = -8'sd128;
      else
        requant8 = shifted[7:0];
    end
  endfunction

  function automatic signed [31:0] relu32(input signed [31:0] v);
    begin
      relu32 = (v < 0) ? 32'sd0 : v;
    end
  endfunction

  function automatic signed [31:0] conv1_sum(input int base, input int y, input int x, input int outc);
    int m, kh, kw, ic;
    logic signed [31:0] s;
    begin
      s = 0;
      for (int lane = 0; lane < PAR_MAC; lane++) begin
        m = base + lane;
        if (m < DOT1) begin
          ic = m % IMG_C;
          kw = (m / IMG_C) % K;
          kh = m / (IMG_C*K);
          s = s + img[(y+kh)*IMG_W + (x+kw)] *
                  w1[((kh*K + kw)*IMG_C + ic)*C1_OUT + outc];
        end
      end
      conv1_sum = s;
    end
  endfunction

  function automatic signed [31:0] conv2_sum(input int base, input int y, input int x, input int outc);
    int m, kh, kw, ic;
    logic signed [31:0] s;
    begin
      s = 0;
      for (int lane = 0; lane < PAR_MAC; lane++) begin
        m = base + lane;
        if (m < DOT2) begin
          ic = m % C1_OUT;
          kw = (m / C1_OUT) % K;
          kh = m / (C1_OUT*K);
          s = s + p1[((y+kh)*P1_W + (x+kw))*C1_OUT + ic] *
                  w2[((kh*K + kw)*C1_OUT + ic)*C2_OUT + outc];
        end
      end
      conv2_sum = s;
    end
  endfunction

  function automatic signed [31:0] conv3_sum(input int base, input int y, input int x, input int outc);
    int m, kh, kw, ic;
    logic signed [31:0] s;
    begin
      s = 0;
      for (int lane = 0; lane < PAR_MAC; lane++) begin
        m = base + lane;
        if (m < DOT3) begin
          ic = m % C2_OUT;
          kw = (m / C2_OUT) % K;
          kh = m / (C2_OUT*K);
          s = s + p2[((y+kh)*P2_W + (x+kw))*C2_OUT + ic] *
                  w3[((kh*K + kw)*C2_OUT + ic)*C3_OUT + outc];
        end
      end
      conv3_sum = s;
    end
  endfunction

  function automatic signed [31:0] fc1_sum(input int base, input int outc);
    int m;
    logic signed [31:0] s;
    begin
      s = 0;
      for (int lane = 0; lane < PAR_MAC; lane++) begin
        m = base + lane;
        if (m < DOT4) begin
          s = s + c3q[m] * w4[m*FC1_OUT + outc];
        end
      end
      fc1_sum = s;
    end
  endfunction

  function automatic signed [31:0] fc2_sum(input int base, input int outc);
    int m;
    logic signed [31:0] s;
    begin
      s = 0;
      for (int lane = 0; lane < PAR_MAC; lane++) begin
        m = base + lane;
        if (m < DOT5) begin
          s = s + fc1q[m] * w5[m*FC2_OUT + outc];
        end
      end
      fc2_sum = s;
    end
  endfunction

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= IDLE;
      done <= 0;
      valid_out <= 0;
      pred_class <= 0;
      elapsed_cycles <= 0;

      idx <= 0;
      oh <= 0;
      ow <= 0;
      oc <= 0;
      mac_base <= 0;
      pool_idx <= 0;
      dense_o <= 0;
      arg_i <= 0;

      acc <= 0;
      max_val <= 0;
      max_idx <= 0;

      cycle_counter <= 0;
      start_cycle <= 0;
    end else begin
      cycle_counter <= cycle_counter + 1;
      done <= 0;
      valid_out <= 0;

      case (state)

        IDLE: begin
          if (start) begin
            start_cycle <= cycle_counter;
            idx <= 0;
            state <= LOAD_IMG;
          end
        end

        LOAD_IMG: begin
          img[idx] <= img_in[idx];
          if (idx == IMG_H*IMG_W-1) begin
            idx <= 0;
            oh <= 0;
            ow <= 0;
            oc <= 0;
            state <= C1_INIT;
          end else begin
            idx <= idx + 1;
          end
        end

        C1_INIT: begin
          acc <= b1[oc];
          mac_base <= 0;
          state <= C1_MAC;
        end

        C1_MAC: begin
          acc <= acc + conv1_sum(mac_base, oh, ow, oc);
          if (mac_base + PAR_MAC >= DOT1)
            state <= C1_SAVE;
          else
            mac_base <= mac_base + PAR_MAC;
        end

        C1_SAVE: begin
          c1[(oh*C1_W + ow)*C1_OUT + oc] <= relu32(acc);

          if (oc == C1_OUT-1) begin
            oc <= 0;
            if (ow == C1_W-1) begin
              ow <= 0;
              if (oh == C1_H-1) begin
                oh <= 0;
                pool_idx <= 0;
                state <= P1_RUN;
              end else begin
                oh <= oh + 1;
                state <= C1_INIT;
              end
            end else begin
              ow <= ow + 1;
              state <= C1_INIT;
            end
          end else begin
            oc <= oc + 1;
            state <= C1_INIT;
          end
        end

        P1_RUN: begin
          int ph, pw, pc;
          logic signed [31:0] a, b, c, d, m;

          pc = pool_idx % C1_OUT;
          pw = (pool_idx / C1_OUT) % P1_W;
          ph = pool_idx / (P1_W*C1_OUT);

          a = c1[((2*ph)*C1_W + (2*pw))*C1_OUT + pc];
          b = c1[((2*ph)*C1_W + (2*pw+1))*C1_OUT + pc];
          c = c1[((2*ph+1)*C1_W + (2*pw))*C1_OUT + pc];
          d = c1[((2*ph+1)*C1_W + (2*pw+1))*C1_OUT + pc];

          m = a;
          if (b > m) m = b;
          if (c > m) m = c;
          if (d > m) m = d;

          p1[pool_idx] <= requant8(m);

          if (pool_idx == P1_H*P1_W*C1_OUT-1) begin
            pool_idx <= 0;
            oh <= 0;
            ow <= 0;
            oc <= 0;
            state <= C2_INIT;
          end else begin
            pool_idx <= pool_idx + 1;
          end
        end

        C2_INIT: begin
          acc <= b2[oc];
          mac_base <= 0;
          state <= C2_MAC;
        end

        C2_MAC: begin
          acc <= acc + conv2_sum(mac_base, oh, ow, oc);
          if (mac_base + PAR_MAC >= DOT2)
            state <= C2_SAVE;
          else
            mac_base <= mac_base + PAR_MAC;
        end

        C2_SAVE: begin
          c2[(oh*C2_W + ow)*C2_OUT + oc] <= relu32(acc);

          if (oc == C2_OUT-1) begin
            oc <= 0;
            if (ow == C2_W-1) begin
              ow <= 0;
              if (oh == C2_H-1) begin
                oh <= 0;
                pool_idx <= 0;
                state <= P2_RUN;
              end else begin
                oh <= oh + 1;
                state <= C2_INIT;
              end
            end else begin
              ow <= ow + 1;
              state <= C2_INIT;
            end
          end else begin
            oc <= oc + 1;
            state <= C2_INIT;
          end
        end

        P2_RUN: begin
          int ph, pw, pc;
          logic signed [31:0] a, b, c, d, m;

          pc = pool_idx % C2_OUT;
          pw = (pool_idx / C2_OUT) % P2_W;
          ph = pool_idx / (P2_W*C2_OUT);

          a = c2[((2*ph)*C2_W + (2*pw))*C2_OUT + pc];
          b = c2[((2*ph)*C2_W + (2*pw+1))*C2_OUT + pc];
          c = c2[((2*ph+1)*C2_W + (2*pw))*C2_OUT + pc];
          d = c2[((2*ph+1)*C2_W + (2*pw+1))*C2_OUT + pc];

          m = a;
          if (b > m) m = b;
          if (c > m) m = c;
          if (d > m) m = d;

          p2[pool_idx] <= requant8(m);

          if (pool_idx == P2_H*P2_W*C2_OUT-1) begin
            pool_idx <= 0;
            oh <= 0;
            ow <= 0;
            oc <= 0;
            state <= C3_INIT;
          end else begin
            pool_idx <= pool_idx + 1;
          end
        end

        C3_INIT: begin
          acc <= b3[oc];
          mac_base <= 0;
          state <= C3_MAC;
        end

        C3_MAC: begin
          acc <= acc + conv3_sum(mac_base, oh, ow, oc);
          if (mac_base + PAR_MAC >= DOT3)
            state <= C3_SAVE;
          else
            mac_base <= mac_base + PAR_MAC;
        end

        C3_SAVE: begin
          c3[(oh*C3_W + ow)*C3_OUT + oc] <= relu32(acc);

          if (oc == C3_OUT-1) begin
            oc <= 0;
            if (ow == C3_W-1) begin
              ow <= 0;
              if (oh == C3_H-1) begin
                idx <= 0;
                state <= C3Q_RUN;
              end else begin
                oh <= oh + 1;
                state <= C3_INIT;
              end
            end else begin
              ow <= ow + 1;
              state <= C3_INIT;
            end
          end else begin
            oc <= oc + 1;
            state <= C3_INIT;
          end
        end

        C3Q_RUN: begin
          c3q[idx] <= requant8(c3[idx]);
          if (idx == FLAT_LEN-1) begin
            dense_o <= 0;
            state <= FC1_INIT;
          end else begin
            idx <= idx + 1;
          end
        end

        FC1_INIT: begin
          acc <= b4[dense_o];
          mac_base <= 0;
          state <= FC1_MAC;
        end

        FC1_MAC: begin
          acc <= acc + fc1_sum(mac_base, dense_o);
          if (mac_base + PAR_MAC >= DOT4)
            state <= FC1_SAVE;
          else
            mac_base <= mac_base + PAR_MAC;
        end

        FC1_SAVE: begin
          fc1[dense_o] <= relu32(acc);
          fc1q[dense_o] <= requant8(relu32(acc));

          if (dense_o == FC1_OUT-1) begin
            dense_o <= 0;
            state <= FC2_INIT;
          end else begin
            dense_o <= dense_o + 1;
            state <= FC1_INIT;
          end
        end

        FC2_INIT: begin
          acc <= b5[dense_o];
          mac_base <= 0;
          state <= FC2_MAC;
        end

        FC2_MAC: begin
          acc <= acc + fc2_sum(mac_base, dense_o);
          if (mac_base + PAR_MAC >= DOT5)
            state <= FC2_SAVE;
          else
            mac_base <= mac_base + PAR_MAC;
        end

        FC2_SAVE: begin
          fc2[dense_o] <= acc;
          logits[dense_o] <= acc;

          if (dense_o == FC2_OUT-1) begin
            state <= ARGMAX_INIT;
          end else begin
            dense_o <= dense_o + 1;
            state <= FC2_INIT;
          end
        end

        ARGMAX_INIT: begin
          max_val <= fc2[0];
          max_idx <= 0;
          arg_i <= 1;
          state <= ARGMAX_RUN;
        end

        ARGMAX_RUN: begin
          if (arg_i == FC2_OUT-1) begin
            if (fc2[arg_i] > max_val)
              pred_class <= arg_i[3:0];
            else
              pred_class <= max_idx;

            elapsed_cycles <= cycle_counter - start_cycle;
            state <= DONE_STATE;
          end else begin
            if (fc2[arg_i] > max_val) begin
              max_val <= fc2[arg_i];
              max_idx <= arg_i[3:0];
            end
            arg_i <= arg_i + 1;
          end
        end

        DONE_STATE: begin
          done <= 1;
          valid_out <= 1;
          state <= IDLE;
        end

      endcase
    end
  end

endmodule
