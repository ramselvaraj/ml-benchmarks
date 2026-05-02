// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2022.1 (64-bit)
// Tool Version Limit: 2022.04
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xattention_int8_kernel.h"

extern XAttention_int8_kernel_Config XAttention_int8_kernel_ConfigTable[];

XAttention_int8_kernel_Config *XAttention_int8_kernel_LookupConfig(u16 DeviceId) {
	XAttention_int8_kernel_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XATTENTION_INT8_KERNEL_NUM_INSTANCES; Index++) {
		if (XAttention_int8_kernel_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XAttention_int8_kernel_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XAttention_int8_kernel_Initialize(XAttention_int8_kernel *InstancePtr, u16 DeviceId) {
	XAttention_int8_kernel_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XAttention_int8_kernel_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XAttention_int8_kernel_CfgInitialize(InstancePtr, ConfigPtr);
}

#endif

