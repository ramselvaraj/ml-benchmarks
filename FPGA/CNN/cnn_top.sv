import cnn_pkg::*;

module cnn_top #(
    parameter string FILE_X   = "test_vectors/sample_0_input_int8.txt",

    parameter string FILE_W1  = "quantized_int8/conv2d_weights_int8.txt",
    parameter string FILE_B1  = "quantized_int8/conv2d_biases_int8.txt",

    parameter string FILE_W2  = "quantized_int8/conv2d_1_weights_int8.txt",
    parameter string FILE_B2  = "quantized_int8/conv2d_1_biases_int8.txt",

    parameter string FILE_W3  = "quantized_int8/conv2d_2_weights_int8.txt",
    parameter string FILE_B3  = "quantized_int8/conv2d_2_biases_int8.txt",

    parameter string FILE_W4  = "quantized_int8/dense_weights_int8.txt",
    parameter string FILE_B4  = "quantized_int8/dense_biases_int8.txt",

    parameter string FILE_W5  = "quantized_int8/dense_1_weights_int8.txt",
    parameter string FILE_B5  = "quantized_int8/dense_1_biases_int8.txt"
)(
    output logic [3:0] pred_class,
    output logic signed [31:0] logits [0:9]
);

  // -------------------------
  // ROM-loaded parameters
  // -------------------------
  logic signed [7:0] img    [0:IMG_H*IMG_W*IMG_C-1];

  logic signed [7:0] w1     [0:K*K*IMG_C*C1_OUT-1];
  logic signed [7:0] b1     [0:C1_OUT-1];

  logic signed [7:0] w2     [0:K*K*C1_OUT*C2_OUT-1];
  logic signed [7:0] b2     [0:C2_OUT-1];

  logic signed [7:0] w3     [0:K*K*C2_OUT*C3_OUT-1];
  logic signed [7:0] b3     [0:C3_OUT-1];

  logic signed [7:0] w4     [0:FLAT_LEN*FC1_OUT-1];
  logic signed [7:0] b4     [0:FC1_OUT-1];

  logic signed [7:0] w5     [0:FC1_OUT*FC2_OUT-1];
  logic signed [7:0] b5     [0:FC2_OUT-1];

  // -------------------------
  // Intermediate signals
  // -------------------------
  logic signed [31:0] c1_out    [0:C1_H*C1_W*C1_OUT-1];
  logic signed [31:0] c1_relu   [0:C1_H*C1_W*C1_OUT-1];
  logic signed [31:0] p1_out    [0:P1_H*P1_W*C1_OUT-1];
  logic signed [7:0]  p1_q      [0:P1_H*P1_W*C1_OUT-1];

  logic signed [31:0] c2_out    [0:C2_H*C2_W*C2_OUT-1];
  logic signed [31:0] c2_relu   [0:C2_H*C2_W*C2_OUT-1];
  logic signed [31:0] p2_out    [0:P2_H*P2_W*C2_OUT-1];
  logic signed [7:0]  p2_q      [0:P2_H*P2_W*C2_OUT-1];

  logic signed [31:0] c3_out    [0:C3_H*C3_W*C3_OUT-1];
  logic signed [31:0] c3_relu   [0:C3_H*C3_W*C3_OUT-1];
  logic signed [7:0]  c3_q      [0:FLAT_LEN-1];

  logic signed [31:0] fc1_out   [0:FC1_OUT-1];
  logic signed [31:0] fc1_relu  [0:FC1_OUT-1];
  logic signed [31:0] fc2_out   [0:FC2_OUT-1];

  // -------------------------
  // Load memories
  // -------------------------
  dec_rom_1d #(.DEPTH(IMG_H*IMG_W*IMG_C), .DW(8), .FILE(FILE_X )) u_img (.mem(img));

  dec_rom_1d #(.DEPTH(K*K*IMG_C*C1_OUT),  .DW(8), .FILE(FILE_W1)) u_w1 (.mem(w1));
  dec_rom_1d #(.DEPTH(C1_OUT),            .DW(8), .FILE(FILE_B1)) u_b1 (.mem(b1));

  dec_rom_1d #(.DEPTH(K*K*C1_OUT*C2_OUT), .DW(8), .FILE(FILE_W2)) u_w2 (.mem(w2));
  dec_rom_1d #(.DEPTH(C2_OUT),            .DW(8), .FILE(FILE_B2)) u_b2 (.mem(b2));

  dec_rom_1d #(.DEPTH(K*K*C2_OUT*C3_OUT), .DW(8), .FILE(FILE_W3)) u_w3 (.mem(w3));
  dec_rom_1d #(.DEPTH(C3_OUT),            .DW(8), .FILE(FILE_B3)) u_b3 (.mem(b3));

  dec_rom_1d #(.DEPTH(FLAT_LEN*FC1_OUT),  .DW(8), .FILE(FILE_W4)) u_w4 (.mem(w4));
  dec_rom_1d #(.DEPTH(FC1_OUT),           .DW(8), .FILE(FILE_B4)) u_b4 (.mem(b4));

  dec_rom_1d #(.DEPTH(FC1_OUT*FC2_OUT),   .DW(8), .FILE(FILE_W5)) u_w5 (.mem(w5));
  dec_rom_1d #(.DEPTH(FC2_OUT),           .DW(8), .FILE(FILE_B5)) u_b5 (.mem(b5));

  // -------------------------
  // Conv1 -> ReLU -> Pool1 -> Requant
  // -------------------------
  conv2d_valid_int8 #(
      .H(IMG_H), .W(IMG_W), .CIN(IMG_C), .COUT(C1_OUT), .K(K)
  ) u_conv1 (
      .x(img), .w(w1), .b(b1), .y(c1_out)
  );

  relu_int32 #(.N(C1_H*C1_W*C1_OUT), .DW(32)) u_relu1 (
      .in_vec(c1_out), .out_vec(c1_relu)
  );

  maxpool2x2_int32 #(.H(C1_H), .W(C1_W), .C(C1_OUT), .DW(32)) u_pool1 (
      .x(c1_relu), .y(p1_out)
  );

  requantize_int32_to_int8 #(.N(P1_H*P1_W*C1_OUT), .SHIFT(8)) u_q1 (
      .in_vec(p1_out), .out_vec(p1_q)
  );

  // -------------------------
  // Conv2 -> ReLU -> Pool2 -> Requant
  // -------------------------
  conv2d_valid_int8 #(
      .H(P1_H), .W(P1_W), .CIN(C1_OUT), .COUT(C2_OUT), .K(K)
  ) u_conv2 (
      .x(p1_q), .w(w2), .b(b2), .y(c2_out)
  );

  relu_int32 #(.N(C2_H*C2_W*C2_OUT), .DW(32)) u_relu2 (
      .in_vec(c2_out), .out_vec(c2_relu)
  );

  maxpool2x2_int32 #(.H(C2_H), .W(C2_W), .C(C2_OUT), .DW(32)) u_pool2 (
      .x(c2_relu), .y(p2_out)
  );

  requantize_int32_to_int8 #(.N(P2_H*P2_W*C2_OUT), .SHIFT(8)) u_q2 (
      .in_vec(p2_out), .out_vec(p2_q)
  );

  // -------------------------
  // Conv3 -> ReLU -> Requant
  // -------------------------
  conv2d_valid_int8 #(
      .H(P2_H), .W(P2_W), .CIN(C2_OUT), .COUT(C3_OUT), .K(K)
  ) u_conv3 (
      .x(p2_q), .w(w3), .b(b3), .y(c3_out)
  );

  relu_int32 #(.N(C3_H*C3_W*C3_OUT), .DW(32)) u_relu3 (
      .in_vec(c3_out), .out_vec(c3_relu)
  );

  requantize_int32_to_int8 #(.N(FLAT_LEN), .SHIFT(8)) u_q3 (
      .in_vec(c3_relu), .out_vec(c3_q)
  );

  // -------------------------
  // FC1 -> ReLU
  // -------------------------
  dense_int8_int8 #(
      .IN_N(FLAT_LEN),
      .OUT_N(FC1_OUT)
  ) u_fc1 (
      .x(c3_q),
      .w(w4),
      .b(b4),
      .y(fc1_out)
  );

  relu_int32 #(.N(FC1_OUT), .DW(32)) u_relu4 (
      .in_vec(fc1_out),
      .out_vec(fc1_relu)
  );

  // -------------------------
  // FC2 -> logits
  // -------------------------
  dense_int32_int8 #(
      .IN_N(FC1_OUT),
      .OUT_N(FC2_OUT)
  ) u_fc2 (
      .x(fc1_relu),
      .w(w5),
      .b(b5),
      .y(fc2_out)
  );

  genvar gi;
  generate
    for (gi = 0; gi < FC2_OUT; gi = gi + 1) begin : LOGIT_ASSIGN
      assign logits[gi] = fc2_out[gi];
    end
  endgenerate

  argmax_cnn #(.N(10), .DW(32)) u_argmax (
      .in_vec(fc2_out),
      .arg_idx(pred_class),
      .max_val()
  );

endmodule
