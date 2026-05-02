// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.1 (64-bit)
// Tool Version Limit: 2022.04
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// ==============================================================

extern "C" void AESL_WRAP_attention_int8_kernel (
volatile void* Q_in,
volatile void* K_in,
volatile void* V_in,
volatile void* O_out,
float q_scale,
float v_scale);
