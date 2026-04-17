package cnn_pkg_fpga;

  // -------------------------
  // Data widths
  // -------------------------
  parameter int DW_DATA = 8;
  parameter int DW_ACC  = 32;

  // -------------------------
  // Image
  // -------------------------
  parameter int IMG_H = 28;
  parameter int IMG_W = 28;
  parameter int IMG_C = 1;

  // -------------------------
  // Kernel
  // -------------------------
  parameter int K = 3;

  // -------------------------
  // Channels
  // -------------------------
  parameter int C1_OUT = 32;
  parameter int C2_OUT = 64;
  parameter int C3_OUT = 64;

  // -------------------------
  // Derived dimensions
  // -------------------------
  parameter int C1_H = IMG_H - K + 1;
  parameter int C1_W = IMG_W - K + 1;

  parameter int P1_H = C1_H / 2;
  parameter int P1_W = C1_W / 2;

  parameter int C2_H = P1_H - K + 1;
  parameter int C2_W = P1_W - K + 1;

  parameter int P2_H = C2_H / 2;
  parameter int P2_W = C2_W / 2;

  parameter int C3_H = P2_H - K + 1;
  parameter int C3_W = P2_W - K + 1;

  parameter int FLAT_LEN = C3_H * C3_W * C3_OUT;

  // -------------------------
  // Fully connected
  // -------------------------
  parameter int FC1_OUT = 64;
  parameter int FC2_OUT = 10;

endpackage
