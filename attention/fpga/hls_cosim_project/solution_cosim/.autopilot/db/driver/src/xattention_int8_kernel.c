// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.1 (64-bit)
// Tool Version Limit: 2022.04
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// ==============================================================
/***************************** Include Files *********************************/
#include "xattention_int8_kernel.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XAttention_int8_kernel_CfgInitialize(XAttention_int8_kernel *InstancePtr, XAttention_int8_kernel_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XAttention_int8_kernel_Start(XAttention_int8_kernel *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_AP_CTRL) & 0x80;
    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XAttention_int8_kernel_IsDone(XAttention_int8_kernel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XAttention_int8_kernel_IsIdle(XAttention_int8_kernel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XAttention_int8_kernel_IsReady(XAttention_int8_kernel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XAttention_int8_kernel_EnableAutoRestart(XAttention_int8_kernel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XAttention_int8_kernel_DisableAutoRestart(XAttention_int8_kernel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_AP_CTRL, 0);
}

void XAttention_int8_kernel_Set_Q_in(XAttention_int8_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_Q_IN_DATA, (u32)(Data));
    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_Q_IN_DATA + 4, (u32)(Data >> 32));
}

u64 XAttention_int8_kernel_Get_Q_in(XAttention_int8_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_Q_IN_DATA);
    Data += (u64)XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_Q_IN_DATA + 4) << 32;
    return Data;
}

void XAttention_int8_kernel_Set_K_in(XAttention_int8_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_K_IN_DATA, (u32)(Data));
    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_K_IN_DATA + 4, (u32)(Data >> 32));
}

u64 XAttention_int8_kernel_Get_K_in(XAttention_int8_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_K_IN_DATA);
    Data += (u64)XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_K_IN_DATA + 4) << 32;
    return Data;
}

void XAttention_int8_kernel_Set_V_in(XAttention_int8_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_V_IN_DATA, (u32)(Data));
    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_V_IN_DATA + 4, (u32)(Data >> 32));
}

u64 XAttention_int8_kernel_Get_V_in(XAttention_int8_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_V_IN_DATA);
    Data += (u64)XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_V_IN_DATA + 4) << 32;
    return Data;
}

void XAttention_int8_kernel_Set_O_out(XAttention_int8_kernel *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_O_OUT_DATA, (u32)(Data));
    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_O_OUT_DATA + 4, (u32)(Data >> 32));
}

u64 XAttention_int8_kernel_Get_O_out(XAttention_int8_kernel *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_O_OUT_DATA);
    Data += (u64)XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_O_OUT_DATA + 4) << 32;
    return Data;
}

void XAttention_int8_kernel_Set_q_scale(XAttention_int8_kernel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_Q_SCALE_DATA, Data);
}

u32 XAttention_int8_kernel_Get_q_scale(XAttention_int8_kernel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_Q_SCALE_DATA);
    return Data;
}

void XAttention_int8_kernel_Set_v_scale(XAttention_int8_kernel *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_V_SCALE_DATA, Data);
}

u32 XAttention_int8_kernel_Get_v_scale(XAttention_int8_kernel *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_V_SCALE_DATA);
    return Data;
}

void XAttention_int8_kernel_InterruptGlobalEnable(XAttention_int8_kernel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_GIE, 1);
}

void XAttention_int8_kernel_InterruptGlobalDisable(XAttention_int8_kernel *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_GIE, 0);
}

void XAttention_int8_kernel_InterruptEnable(XAttention_int8_kernel *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_IER);
    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_IER, Register | Mask);
}

void XAttention_int8_kernel_InterruptDisable(XAttention_int8_kernel *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_IER);
    XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_IER, Register & (~Mask));
}

void XAttention_int8_kernel_InterruptClear(XAttention_int8_kernel *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    //XAttention_int8_kernel_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_ISR, Mask);
}

u32 XAttention_int8_kernel_InterruptGetEnabled(XAttention_int8_kernel *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_IER);
}

u32 XAttention_int8_kernel_InterruptGetStatus(XAttention_int8_kernel *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    // Current Interrupt Clear Behavior is Clear on Read(COR).
    return XAttention_int8_kernel_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_INT8_KERNEL_CONTROL_ADDR_ISR);
}

