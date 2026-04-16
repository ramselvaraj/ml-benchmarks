package cnn_pkg;

  parameter int DW_IN   = 8;
  parameter int DW_W    = 8;
  parameter int DW_B    = 8;
  parameter int DW_ACC  = 32;

  parameter int IMG_H   = 28;
  parameter int IMG_W   = 28;
  parameter int IMG_C   = 1;

  parameter int K       = 3;

  parameter int C1_OUT  = 32;
  parameter int C2_OUT  = 64;
  parameter int C3_OUT  = 64;

  parameter int FC1_OUT = 64;
  parameter int FC2_OUT = 10;

  parameter int C1_H = 26;
  parameter int C1_W = 26;
  parameter int P1_H = 13;
  parameter int P1_W = 13;

  parameter int C2_H = 11;
  parameter int C2_W = 11;
  parameter int P2_H = 5;
  parameter int P2_W = 5;

  parameter int C3_H = 3;
  parameter int C3_W = 3;

  parameter int FLAT_LEN = 3*3*64; // 576

endpackage
