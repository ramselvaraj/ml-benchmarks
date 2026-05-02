// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2023.2 (64-bit)
// Tool Version Limit: 2023.10
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef XATTENTION_INT8_KERNEL_H
#define XATTENTION_INT8_KERNEL_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
#else
#include <stdint.h>
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stddef.h>
#endif
#include "xattention_int8_kernel_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
#else
typedef struct {
#ifdef SDT
    char *Name;
#else
    u16 DeviceId;
#endif
    u64 Control_BaseAddress;
} XAttention_int8_kernel_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u32 IsReady;
} XAttention_int8_kernel;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XAttention_int8_kernel_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XAttention_int8_kernel_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XAttention_int8_kernel_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XAttention_int8_kernel_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset))

#define Xil_AssertVoid(expr)    assert(expr)
#define Xil_AssertNonvoid(expr) assert(expr)

#define XST_SUCCESS             0
#define XST_DEVICE_NOT_FOUND    2
#define XST_OPEN_DEVICE_FAILED  3
#define XIL_COMPONENT_IS_READY  1
#endif

/************************** Function Prototypes *****************************/
#ifndef __linux__
#ifdef SDT
int XAttention_int8_kernel_Initialize(XAttention_int8_kernel *InstancePtr, UINTPTR BaseAddress);
XAttention_int8_kernel_Config* XAttention_int8_kernel_LookupConfig(UINTPTR BaseAddress);
#else
int XAttention_int8_kernel_Initialize(XAttention_int8_kernel *InstancePtr, u16 DeviceId);
XAttention_int8_kernel_Config* XAttention_int8_kernel_LookupConfig(u16 DeviceId);
#endif
int XAttention_int8_kernel_CfgInitialize(XAttention_int8_kernel *InstancePtr, XAttention_int8_kernel_Config *ConfigPtr);
#else
int XAttention_int8_kernel_Initialize(XAttention_int8_kernel *InstancePtr, const char* InstanceName);
int XAttention_int8_kernel_Release(XAttention_int8_kernel *InstancePtr);
#endif

void XAttention_int8_kernel_Start(XAttention_int8_kernel *InstancePtr);
u32 XAttention_int8_kernel_IsDone(XAttention_int8_kernel *InstancePtr);
u32 XAttention_int8_kernel_IsIdle(XAttention_int8_kernel *InstancePtr);
u32 XAttention_int8_kernel_IsReady(XAttention_int8_kernel *InstancePtr);
void XAttention_int8_kernel_EnableAutoRestart(XAttention_int8_kernel *InstancePtr);
void XAttention_int8_kernel_DisableAutoRestart(XAttention_int8_kernel *InstancePtr);

void XAttention_int8_kernel_Set_Q_in(XAttention_int8_kernel *InstancePtr, u64 Data);
u64 XAttention_int8_kernel_Get_Q_in(XAttention_int8_kernel *InstancePtr);
void XAttention_int8_kernel_Set_K_in(XAttention_int8_kernel *InstancePtr, u64 Data);
u64 XAttention_int8_kernel_Get_K_in(XAttention_int8_kernel *InstancePtr);
void XAttention_int8_kernel_Set_V_in(XAttention_int8_kernel *InstancePtr, u64 Data);
u64 XAttention_int8_kernel_Get_V_in(XAttention_int8_kernel *InstancePtr);
void XAttention_int8_kernel_Set_O_out(XAttention_int8_kernel *InstancePtr, u64 Data);
u64 XAttention_int8_kernel_Get_O_out(XAttention_int8_kernel *InstancePtr);
void XAttention_int8_kernel_Set_q_scale(XAttention_int8_kernel *InstancePtr, u32 Data);
u32 XAttention_int8_kernel_Get_q_scale(XAttention_int8_kernel *InstancePtr);
void XAttention_int8_kernel_Set_v_scale(XAttention_int8_kernel *InstancePtr, u32 Data);
u32 XAttention_int8_kernel_Get_v_scale(XAttention_int8_kernel *InstancePtr);

void XAttention_int8_kernel_InterruptGlobalEnable(XAttention_int8_kernel *InstancePtr);
void XAttention_int8_kernel_InterruptGlobalDisable(XAttention_int8_kernel *InstancePtr);
void XAttention_int8_kernel_InterruptEnable(XAttention_int8_kernel *InstancePtr, u32 Mask);
void XAttention_int8_kernel_InterruptDisable(XAttention_int8_kernel *InstancePtr, u32 Mask);
void XAttention_int8_kernel_InterruptClear(XAttention_int8_kernel *InstancePtr, u32 Mask);
u32 XAttention_int8_kernel_InterruptGetEnabled(XAttention_int8_kernel *InstancePtr);
u32 XAttention_int8_kernel_InterruptGetStatus(XAttention_int8_kernel *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
