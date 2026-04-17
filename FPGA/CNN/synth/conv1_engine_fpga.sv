import cnn_pkg_fpga::*;
import cnn_types_fpga::*;
`include "cnn_defs_fpga.svh"

module conv1_engine_fpga (
    input  logic clk,
    input  logic rst_n,
    input  logic start,

    input  qint8_t img_mem [0:IMG_H*IMG_W*IMG_C-1],

    output logic done,
    output qint32_t out_mem [0:C1_H*C1_W*C1_OUT-1]
);

  typedef enum logic [2:0] {
    S_IDLE,
    S_LOAD_BIAS,
    S_MAC,
    S_WRITE,
    S_NEXT,
    S_DONE
  } state_t;

  state_t state;

  // Output coordinates
  logic [$clog2(C1_H)-1:0] out_r;
  logic [$clog2(C1_W)-1:0] out_c;
  logic [$clog2(C1_OUT)-1:0] out_ch;

  // Kernel coordinates
  logic [$clog2(K)-1:0] kr;
  logic [$clog2(K)-1:0] kc;

  // ROM interface
  logic [$clog2(K*K*IMG_C*C1_OUT)-1:0] w_addr;
  qint8_t w_data;

  logic [$clog2(C1_OUT)-1:0] b_addr;
  qint8_t b_data;

  // Accumulator
  qint32_t acc;

  // Current image sample
  qint8_t x_data;

  // ROM instances
  conv1_weight_rom u_wrom (
      .addr(w_addr),
      .data(w_data)
  );

  conv1_bias_rom u_brom (
      .addr(b_addr),
      .data(b_data)
  );

  function automatic int img_idx(input int r, input int c, input int ch);
    return ((r * IMG_W + c) * IMG_C + ch);
  endfunction

  function automatic int out_idx(input int r, input int c, input int ch);
    return ((r * C1_W + c) * C1_OUT + ch);
  endfunction

  function automatic int w_idx(input int r, input int c, input int ci, input int co);
    return ((((r * K) + c) * IMG_C + ci) * C1_OUT + co);
  endfunction

  always_comb begin
    // IMG_C=1 for MNIST, so ci is always 0 here
    x_data = img_mem[img_idx(out_r + kr, out_c + kc, 0)];
    w_addr = w_idx(kr, kc, 0, out_ch);
    b_addr = out_ch;
  end

  integer i;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state  <= S_IDLE;
      done   <= 1'b0;
      out_r  <= '0;
      out_c  <= '0;
      out_ch <= '0;
      kr     <= '0;
      kc     <= '0;
      acc    <= '0;

      for (i = 0; i < C1_H*C1_W*C1_OUT; i = i + 1)
        out_mem[i] <= '0;
    end
    else begin
      case (state)
        S_IDLE: begin
          done <= 1'b0;
          if (start) begin
            out_r  <= '0;
            out_c  <= '0;
            out_ch <= '0;
            kr     <= '0;
            kc     <= '0;
            state  <= S_LOAD_BIAS;
          end
        end

        S_LOAD_BIAS: begin
          acc   <= $signed(b_data);
          kr    <= '0;
          kc    <= '0;
          state <= S_MAC;
        end

        S_MAC: begin
          acc <= acc + $signed(x_data) * $signed(w_data);

          if (kc == K-1) begin
            kc <= '0;
            if (kr == K-1) begin
              kr    <= '0;
              state <= S_WRITE;
            end
            else begin
              kr <= kr + 1'b1;
            end
          end
          else begin
            kc <= kc + 1'b1;
          end
        end

        S_WRITE: begin
          out_mem[out_idx(out_r, out_c, out_ch)] <= acc;
          state <= S_NEXT;
        end

        S_NEXT: begin
          if (out_ch == C1_OUT-1) begin
            out_ch <= '0;
            if (out_c == C1_W-1) begin
              out_c <= '0;
              if (out_r == C1_H-1) begin
                out_r <= '0;
                state <= S_DONE;
              end
              else begin
                out_r <= out_r + 1'b1;
                state <= S_LOAD_BIAS;
              end
            end
            else begin
              out_c <= out_c + 1'b1;
              state <= S_LOAD_BIAS;
            end
          end
          else begin
            out_ch <= out_ch + 1'b1;
            state  <= S_LOAD_BIAS;
          end
        end

        S_DONE: begin
          done <= 1'b1;
          if (!start)
            state <= S_IDLE;
        end

        default: begin
          state <= S_IDLE;
        end
      endcase
    end
  end

endmodule
