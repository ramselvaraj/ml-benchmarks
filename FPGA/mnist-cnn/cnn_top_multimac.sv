`timescale 1ns/1ps
import cnn_pkg::*;

module cnn_top_multimac #(
    parameter int PAR_MAC = 64,

    parameter int C1_SHIFT  = 8,
    parameter int C2_SHIFT  = 8,
    parameter int C3_SHIFT  = 8,
    parameter int FC1_SHIFT = 8,

    parameter string W1_FILE = "mem_data/conv2d_weights_int8.mem",
    parameter string B1_FILE = "mem_data/conv2d_biases_int32.mem",

    parameter string W2_FILE = "mem_data/conv2d_1_weights_int8.mem",
    parameter string B2_FILE = "mem_data/conv2d_1_biases_int32.mem",

    parameter string W3_FILE = "mem_data/conv2d_2_weights_int8.mem",
    parameter string B3_FILE = "mem_data/conv2d_2_biases_int32.mem",

    parameter string W4_FILE = "mem_data/dense_1_weights_int8.mem",
    parameter string B4_FILE = "mem_data/dense_1_biases_int32.mem",

    parameter string W5_FILE = "mem_data/dense_weights_int8.mem",
    parameter string B5_FILE = "mem_data/dense_biases_int32.mem"
)(
    input  logic clk,
    input  logic rst,
    input  logic start,

    input  logic signed [7:0] img_in [0:IMG_H*IMG_W-1],

    output logic        done,
    output logic        valid_out,
    output logic [3:0]  pred_class,
    output logic signed [31:0] logits [0:9],
    output logic [31:0] elapsed_cycles
);

  localparam int DOT1 = K*K*IMG_C;
  localparam int DOT2 = K*K*C1_OUT;
  localparam int DOT3 = K*K*C2_OUT;
  localparam int DOT4 = FLAT_LEN;
  localparam int DOT5 = FC1_OUT;

  (* rom_style = "block" *) logic signed [7:0]  w1 [0:K*K*IMG_C*C1_OUT-1];
  (* rom_style = "block" *) logic signed [31:0] b1 [0:C1_OUT-1];

  (* rom_style = "block" *) logic signed [7:0]  w2 [0:K*K*C1_OUT*C2_OUT-1];
  (* rom_style = "block" *) logic signed [31:0] b2 [0:C2_OUT-1];

  (* rom_style = "block" *) logic signed [7:0]  w3 [0:K*K*C2_OUT*C3_OUT-1];
  (* rom_style = "block" *) logic signed [31:0] b3 [0:C3_OUT-1];

  (* rom_style = "block" *) logic signed [7:0]  w4 [0:FLAT_LEN*FC1_OUT-1];
  (* rom_style = "block" *) logic signed [31:0] b4 [0:FC1_OUT-1];

  (* rom_style = "block" *) logic signed [7:0]  w5 [0:FC1_OUT*FC2_OUT-1];
  (* rom_style = "block" *) logic signed [31:0] b5 [0:FC2_OUT-1];

  initial begin
    $readmemh(W1_FILE, w1);  $readmemh(B1_FILE, b1);
    $readmemh(W2_FILE, w2);  $readmemh(B2_FILE, b2);
    $readmemh(W3_FILE, w3);  $readmemh(B3_FILE, b3);
    $readmemh(W4_FILE, w4);  $readmemh(B4_FILE, b4);
    $readmemh(W5_FILE, w5);  $readmemh(B5_FILE, b5);
  end

  logic signed [7:0]  img  [0:IMG_H*IMG_W-1];

  logic signed [31:0] c1   [0:C1_H*C1_W*C1_OUT-1];
  logic signed [7:0]  p1   [0:P1_H*P1_W*C1_OUT-1];

  logic signed [31:0] c2   [0:C2_H*C2_W*C2_OUT-1];
  logic signed [7:0]  p2   [0:P2_H*P2_W*C2_OUT-1];

  logic signed [31:0] c3   [0:C3_H*C3_W*C3_OUT-1];
  logic signed [7:0]  c3q  [0:FLAT_LEN-1];

  logic signed [31:0] fc1  [0:FC1_OUT-1];
  logic signed [7:0]  fc1q [0:FC1_OUT-1];
  logic signed [31:0] fc2  [0:FC2_OUT-1];

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

  int idx, oh, ow, oc;
  int mac_base, pool_idx, dense_o, arg_i;

  logic signed [31:0] acc, max_val;
  logic [3:0]         max_idx;
  logic [31:0]        cycle_counter, start_cycle;

  int pool_ph1, pool_pw1, pool_pc1;
  logic signed [31:0] pool_a1, pool_b1, pool_c1, pool_d1, pool_m1;

  always_comb begin
    pool_pc1 = pool_idx % C1_OUT;
    pool_pw1 = (pool_idx / C1_OUT) % P1_W;
    pool_ph1 = pool_idx / (P1_W * C1_OUT);

    pool_a1 = c1[((2*pool_ph1  )*C1_W + (2*pool_pw1  ))*C1_OUT + pool_pc1];
    pool_b1 = c1[((2*pool_ph1  )*C1_W + (2*pool_pw1+1))*C1_OUT + pool_pc1];
    pool_c1 = c1[((2*pool_ph1+1)*C1_W + (2*pool_pw1  ))*C1_OUT + pool_pc1];
    pool_d1 = c1[((2*pool_ph1+1)*C1_W + (2*pool_pw1+1))*C1_OUT + pool_pc1];

    pool_m1 = pool_a1;
    if (pool_b1 > pool_m1) pool_m1 = pool_b1;
    if (pool_c1 > pool_m1) pool_m1 = pool_c1;
    if (pool_d1 > pool_m1) pool_m1 = pool_d1;
  end

  int pool_ph2, pool_pw2, pool_pc2;
  logic signed [31:0] pool_a2, pool_b2, pool_c2, pool_d2, pool_m2;

  always_comb begin
    pool_pc2 = pool_idx % C2_OUT;
    pool_pw2 = (pool_idx / C2_OUT) % P2_W;
    pool_ph2 = pool_idx / (P2_W * C2_OUT);

    pool_a2 = c2[((2*pool_ph2  )*C2_W + (2*pool_pw2  ))*C2_OUT + pool_pc2];
    pool_b2 = c2[((2*pool_ph2  )*C2_W + (2*pool_pw2+1))*C2_OUT + pool_pc2];
    pool_c2 = c2[((2*pool_ph2+1)*C2_W + (2*pool_pw2  ))*C2_OUT + pool_pc2];
    pool_d2 = c2[((2*pool_ph2+1)*C2_W + (2*pool_pw2+1))*C2_OUT + pool_pc2];

    pool_m2 = pool_a2;
    if (pool_b2 > pool_m2) pool_m2 = pool_b2;
    if (pool_c2 > pool_m2) pool_m2 = pool_c2;
    if (pool_d2 > pool_m2) pool_m2 = pool_d2;
  end

  function automatic signed [31:0] mul_int8(
      input logic signed [7:0] a,
      input logic signed [7:0] b
  );
    logic signed [31:0] aa;
    logic signed [31:0] bb;
    begin
      aa = {{24{a[7]}}, a};
      bb = {{24{b[7]}}, b};
      mul_int8 = aa * bb;
    end
  endfunction

  function automatic signed [7:0] requant8_shift(
      input signed [31:0] v,
      input int shift
  );
    logic signed [31:0] sh;
    begin
      sh = v >>> shift;
      if      (sh >  127) requant8_shift =  8'sd127;
      else if (sh < -128) requant8_shift = -8'sd128;
      else                requant8_shift = sh[7:0];
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
          kh = m / (IMG_C * K);
          s = s + mul_int8(img[(y+kh)*IMG_W + (x+kw)],
                           w1[((kh*K + kw)*IMG_C + ic)*C1_OUT + outc]);
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
          kh = m / (C1_OUT * K);
          s = s + mul_int8(p1[((y+kh)*P1_W + (x+kw))*C1_OUT + ic],
                           w2[((kh*K + kw)*C1_OUT + ic)*C2_OUT + outc]);
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
          kh = m / (C2_OUT * K);
          s = s + mul_int8(p2[((y+kh)*P2_W + (x+kw))*C2_OUT + ic],
                           w3[((kh*K + kw)*C2_OUT + ic)*C3_OUT + outc]);
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
        if (m < DOT4)
          s = s + mul_int8(c3q[m], w4[m*FC1_OUT + outc]);
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
        if (m < DOT5)
          s = s + mul_int8(fc1q[m], w5[m*FC2_OUT + outc]);
      end
      fc2_sum = s;
    end
  endfunction

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state          <= IDLE;
      done           <= 1'b0;
      valid_out      <= 1'b0;
      pred_class     <= 4'd0;
      elapsed_cycles <= 32'd0;
      idx            <= 0;
      oh             <= 0;
      ow             <= 0;
      oc             <= 0;
      mac_base       <= 0;
      pool_idx       <= 0;
      dense_o        <= 0;
      arg_i          <= 0;
      acc            <= 32'sd0;
      max_val        <= 32'sd0;
      max_idx        <= 4'd0;
      cycle_counter  <= 32'd0;
      start_cycle    <= 32'd0;
    end else begin
      cycle_counter <= cycle_counter + 1;
      done          <= 1'b0;
      valid_out     <= 1'b0;

      case (state)

        IDLE: begin
          if (start) begin
            start_cycle <= cycle_counter;
            idx         <= 0;
            state       <= LOAD_IMG;
          end
        end

        LOAD_IMG: begin
          img[idx] <= img_in[idx];
          if (idx == IMG_H*IMG_W-1) begin
            idx   <= 0;
            oh    <= 0;
            ow    <= 0;
            oc    <= 0;
            state <= C1_INIT;
          end else begin
            idx <= idx + 1;
          end
        end

        C1_INIT: begin
          acc      <= b1[oc];
          mac_base <= 0;
          state    <= C1_MAC;
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
                oh       <= 0;
                pool_idx <= 0;
                state    <= P1_RUN;
              end else begin
                oh    <= oh + 1;
                state <= C1_INIT;
              end
            end else begin
              ow    <= ow + 1;
              state <= C1_INIT;
            end
          end else begin
            oc    <= oc + 1;
            state <= C1_INIT;
          end
        end

        P1_RUN: begin
          p1[pool_idx] <= requant8_shift(pool_m1, C1_SHIFT);
          if (pool_idx == P1_H*P1_W*C1_OUT-1) begin
            pool_idx <= 0;
            oh       <= 0;
            ow       <= 0;
            oc       <= 0;
            state    <= C2_INIT;
          end else begin
            pool_idx <= pool_idx + 1;
          end
        end

        C2_INIT: begin
          acc      <= b2[oc];
          mac_base <= 0;
          state    <= C2_MAC;
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
                oh       <= 0;
                pool_idx <= 0;
                state    <= P2_RUN;
              end else begin
                oh    <= oh + 1;
                state <= C2_INIT;
              end
            end else begin
              ow    <= ow + 1;
              state <= C2_INIT;
            end
          end else begin
            oc    <= oc + 1;
            state <= C2_INIT;
          end
        end

        P2_RUN: begin
          p2[pool_idx] <= requant8_shift(pool_m2, C2_SHIFT);
          if (pool_idx == P2_H*P2_W*C2_OUT-1) begin
            pool_idx <= 0;
            oh       <= 0;
            ow       <= 0;
            oc       <= 0;
            state    <= C3_INIT;
          end else begin
            pool_idx <= pool_idx + 1;
          end
        end

        C3_INIT: begin
          acc      <= b3[oc];
          mac_base <= 0;
          state    <= C3_MAC;
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
                idx   <= 0;
                state <= C3Q_RUN;
              end else begin
                oh    <= oh + 1;
                state <= C3_INIT;
              end
            end else begin
              ow    <= ow + 1;
              state <= C3_INIT;
            end
          end else begin
            oc    <= oc + 1;
            state <= C3_INIT;
          end
        end

        C3Q_RUN: begin
          c3q[idx] <= requant8_shift(c3[idx], C3_SHIFT);
          if (idx == FLAT_LEN-1) begin
            dense_o <= 0;
            state   <= FC1_INIT;
          end else begin
            idx <= idx + 1;
          end
        end

        FC1_INIT: begin
          acc      <= b4[dense_o];
          mac_base <= 0;
          state    <= FC1_MAC;
        end

        FC1_MAC: begin
          acc <= acc + fc1_sum(mac_base, dense_o);
          if (mac_base + PAR_MAC >= DOT4)
            state <= FC1_SAVE;
          else
            mac_base <= mac_base + PAR_MAC;
        end

        FC1_SAVE: begin
          fc1[dense_o]  <= relu32(acc);
          fc1q[dense_o] <= requant8_shift(relu32(acc), FC1_SHIFT);

          if (dense_o == FC1_OUT-1) begin
            dense_o <= 0;
            state   <= FC2_INIT;
          end else begin
            dense_o <= dense_o + 1;
            state   <= FC1_INIT;
          end
        end

        FC2_INIT: begin
          acc      <= b5[dense_o];
          mac_base <= 0;
          state    <= FC2_MAC;
        end

        FC2_MAC: begin
          acc <= acc + fc2_sum(mac_base, dense_o);
          if (mac_base + PAR_MAC >= DOT5)
            state <= FC2_SAVE;
          else
            mac_base <= mac_base + PAR_MAC;
        end

        FC2_SAVE: begin
          fc2[dense_o]    <= acc;
          logits[dense_o] <= acc;

          if (dense_o == FC2_OUT-1) begin
            state <= ARGMAX_INIT;
          end else begin
            dense_o <= dense_o + 1;
            state   <= FC2_INIT;
          end
        end

        ARGMAX_INIT: begin
          max_val <= fc2[0];
          max_idx <= 4'd0;
          arg_i   <= 1;
          state   <= ARGMAX_RUN;
        end

        ARGMAX_RUN: begin
          if (fc2[arg_i] > max_val) begin
            max_val <= fc2[arg_i];
            max_idx <= arg_i[3:0];
          end

          if (arg_i == FC2_OUT-1) begin
            if (fc2[arg_i] > max_val)
              pred_class <= arg_i[3:0];
            else
              pred_class <= max_idx;

            elapsed_cycles <= cycle_counter - start_cycle;
            state          <= DONE_STATE;
          end else begin
            arg_i <= arg_i + 1;
          end
        end

        DONE_STATE: begin
          done      <= 1'b1;
          valid_out <= 1'b1;
          state     <= IDLE;
        end

        default: begin
          state <= IDLE;
        end

      endcase
    end
  end

endmodule
