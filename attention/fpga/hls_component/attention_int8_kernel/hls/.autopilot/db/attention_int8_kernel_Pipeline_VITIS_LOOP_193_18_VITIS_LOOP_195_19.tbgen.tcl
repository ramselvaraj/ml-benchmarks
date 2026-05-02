set moduleName attention_int8_kernel_Pipeline_VITIS_LOOP_193_18_VITIS_LOOP_195_19
set isTopModule 0
set isCombinational 0
set isDatapathOnly 0
set isPipelined 1
set pipeline_type none
set FunctionProtocol ap_ctrl_hs
set isOneStateSeq 0
set ProfileFlag 0
set StallSigGenFlag 0
set isEnableWaveformDebug 1
set hasInterrupt 0
set DLRegFirstOffset 0
set DLRegItemOffset 0
set C_modelName {attention_int8_kernel_Pipeline_VITIS_LOOP_193_18_VITIS_LOOP_195_19}
set C_modelType { void 0 }
set C_modelArgList {
	{ gmem3 int 16 regular {axi_master 1}  }
	{ sext_ln81 int 63 regular  }
	{ l_state float 32 regular  }
	{ l_state_1 float 32 regular  }
	{ l_state_2 float 32 regular  }
	{ l_state_3 float 32 regular  }
	{ l_state_4 float 32 regular  }
	{ l_state_5 float 32 regular  }
	{ l_state_6 float 32 regular  }
	{ l_state_7 float 32 regular  }
	{ l_state_8 float 32 regular  }
	{ l_state_9 float 32 regular  }
	{ l_state_10 float 32 regular  }
	{ l_state_11 float 32 regular  }
	{ l_state_12 float 32 regular  }
	{ l_state_13 float 32 regular  }
	{ l_state_14 float 32 regular  }
	{ l_state_15 float 32 regular  }
	{ l_state_16 float 32 regular  }
	{ l_state_17 float 32 regular  }
	{ l_state_18 float 32 regular  }
	{ l_state_19 float 32 regular  }
	{ l_state_20 float 32 regular  }
	{ l_state_21 float 32 regular  }
	{ l_state_22 float 32 regular  }
	{ l_state_23 float 32 regular  }
	{ l_state_24 float 32 regular  }
	{ l_state_25 float 32 regular  }
	{ l_state_26 float 32 regular  }
	{ l_state_27 float 32 regular  }
	{ l_state_28 float 32 regular  }
	{ l_state_29 float 32 regular  }
	{ l_state_30 float 32 regular  }
	{ l_state_31 float 32 regular  }
	{ l_state_32 float 32 regular  }
	{ l_state_33 float 32 regular  }
	{ l_state_34 float 32 regular  }
	{ l_state_35 float 32 regular  }
	{ l_state_36 float 32 regular  }
	{ l_state_37 float 32 regular  }
	{ l_state_38 float 32 regular  }
	{ l_state_39 float 32 regular  }
	{ l_state_40 float 32 regular  }
	{ l_state_41 float 32 regular  }
	{ l_state_42 float 32 regular  }
	{ l_state_43 float 32 regular  }
	{ l_state_44 float 32 regular  }
	{ l_state_45 float 32 regular  }
	{ l_state_46 float 32 regular  }
	{ l_state_47 float 32 regular  }
	{ l_state_48 float 32 regular  }
	{ l_state_49 float 32 regular  }
	{ l_state_50 float 32 regular  }
	{ l_state_51 float 32 regular  }
	{ l_state_52 float 32 regular  }
	{ l_state_53 float 32 regular  }
	{ l_state_54 float 32 regular  }
	{ l_state_55 float 32 regular  }
	{ l_state_56 float 32 regular  }
	{ l_state_57 float 32 regular  }
	{ l_state_58 float 32 regular  }
	{ l_state_59 float 32 regular  }
	{ l_state_60 float 32 regular  }
	{ l_state_61 float 32 regular  }
	{ l_state_62 float 32 regular  }
	{ l_state_63 float 32 regular  }
	{ O_tile float 32 regular {array 1024 { 1 3 } 1 1 }  }
	{ O_tile_1 float 32 regular {array 1024 { 1 3 } 1 1 }  }
	{ O_tile_2 float 32 regular {array 1024 { 1 3 } 1 1 }  }
	{ O_tile_3 float 32 regular {array 1024 { 1 3 } 1 1 }  }
	{ O_tile_4 float 32 regular {array 1024 { 1 3 } 1 1 }  }
	{ O_tile_5 float 32 regular {array 1024 { 1 3 } 1 1 }  }
	{ O_tile_6 float 32 regular {array 1024 { 1 3 } 1 1 }  }
	{ O_tile_7 float 32 regular {array 1024 { 1 3 } 1 1 }  }
}
set hasAXIMCache 0
set AXIMCacheInstList { }
set C_modelArgMapList {[ 
	{ "Name" : "gmem3", "interface" : "axi_master", "bitwidth" : 16, "direction" : "WRITEONLY", "bitSlice":[ {"cElement": [{"cName": "O_out","offset": { "type": "dynamic","port_name": "O_out","bundle": "control"},"direction": "WRITEONLY"}]}]} , 
 	{ "Name" : "sext_ln81", "interface" : "wire", "bitwidth" : 63, "direction" : "READONLY"} , 
 	{ "Name" : "l_state", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_1", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_2", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_3", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_4", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_5", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_6", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_7", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_8", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_9", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_10", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_11", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_12", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_13", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_14", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_15", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_16", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_17", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_18", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_19", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_20", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_21", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_22", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_23", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_24", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_25", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_26", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_27", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_28", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_29", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_30", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_31", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_32", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_33", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_34", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_35", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_36", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_37", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_38", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_39", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_40", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_41", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_42", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_43", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_44", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_45", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_46", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_47", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_48", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_49", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_50", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_51", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_52", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_53", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_54", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_55", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_56", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_57", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_58", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_59", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_60", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_61", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_62", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_63", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile_1", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile_2", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile_3", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile_4", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile_5", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile_6", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile_7", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} ]}
# RTL Port declarations: 
set portNum 154
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ m_axi_gmem3_AWVALID sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmem3_AWREADY sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmem3_AWADDR sc_out sc_lv 64 signal 0 } 
	{ m_axi_gmem3_AWID sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmem3_AWLEN sc_out sc_lv 32 signal 0 } 
	{ m_axi_gmem3_AWSIZE sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmem3_AWBURST sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmem3_AWLOCK sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmem3_AWCACHE sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmem3_AWPROT sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmem3_AWQOS sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmem3_AWREGION sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmem3_AWUSER sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmem3_WVALID sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmem3_WREADY sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmem3_WDATA sc_out sc_lv 16 signal 0 } 
	{ m_axi_gmem3_WSTRB sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmem3_WLAST sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmem3_WID sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmem3_WUSER sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmem3_ARVALID sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmem3_ARREADY sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmem3_ARADDR sc_out sc_lv 64 signal 0 } 
	{ m_axi_gmem3_ARID sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmem3_ARLEN sc_out sc_lv 32 signal 0 } 
	{ m_axi_gmem3_ARSIZE sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmem3_ARBURST sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmem3_ARLOCK sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmem3_ARCACHE sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmem3_ARPROT sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmem3_ARQOS sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmem3_ARREGION sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmem3_ARUSER sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmem3_RVALID sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmem3_RREADY sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmem3_RDATA sc_in sc_lv 16 signal 0 } 
	{ m_axi_gmem3_RLAST sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmem3_RID sc_in sc_lv 1 signal 0 } 
	{ m_axi_gmem3_RFIFONUM sc_in sc_lv 10 signal 0 } 
	{ m_axi_gmem3_RUSER sc_in sc_lv 1 signal 0 } 
	{ m_axi_gmem3_RRESP sc_in sc_lv 2 signal 0 } 
	{ m_axi_gmem3_BVALID sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmem3_BREADY sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmem3_BRESP sc_in sc_lv 2 signal 0 } 
	{ m_axi_gmem3_BID sc_in sc_lv 1 signal 0 } 
	{ m_axi_gmem3_BUSER sc_in sc_lv 1 signal 0 } 
	{ sext_ln81 sc_in sc_lv 63 signal 1 } 
	{ l_state sc_in sc_lv 32 signal 2 } 
	{ l_state_1 sc_in sc_lv 32 signal 3 } 
	{ l_state_2 sc_in sc_lv 32 signal 4 } 
	{ l_state_3 sc_in sc_lv 32 signal 5 } 
	{ l_state_4 sc_in sc_lv 32 signal 6 } 
	{ l_state_5 sc_in sc_lv 32 signal 7 } 
	{ l_state_6 sc_in sc_lv 32 signal 8 } 
	{ l_state_7 sc_in sc_lv 32 signal 9 } 
	{ l_state_8 sc_in sc_lv 32 signal 10 } 
	{ l_state_9 sc_in sc_lv 32 signal 11 } 
	{ l_state_10 sc_in sc_lv 32 signal 12 } 
	{ l_state_11 sc_in sc_lv 32 signal 13 } 
	{ l_state_12 sc_in sc_lv 32 signal 14 } 
	{ l_state_13 sc_in sc_lv 32 signal 15 } 
	{ l_state_14 sc_in sc_lv 32 signal 16 } 
	{ l_state_15 sc_in sc_lv 32 signal 17 } 
	{ l_state_16 sc_in sc_lv 32 signal 18 } 
	{ l_state_17 sc_in sc_lv 32 signal 19 } 
	{ l_state_18 sc_in sc_lv 32 signal 20 } 
	{ l_state_19 sc_in sc_lv 32 signal 21 } 
	{ l_state_20 sc_in sc_lv 32 signal 22 } 
	{ l_state_21 sc_in sc_lv 32 signal 23 } 
	{ l_state_22 sc_in sc_lv 32 signal 24 } 
	{ l_state_23 sc_in sc_lv 32 signal 25 } 
	{ l_state_24 sc_in sc_lv 32 signal 26 } 
	{ l_state_25 sc_in sc_lv 32 signal 27 } 
	{ l_state_26 sc_in sc_lv 32 signal 28 } 
	{ l_state_27 sc_in sc_lv 32 signal 29 } 
	{ l_state_28 sc_in sc_lv 32 signal 30 } 
	{ l_state_29 sc_in sc_lv 32 signal 31 } 
	{ l_state_30 sc_in sc_lv 32 signal 32 } 
	{ l_state_31 sc_in sc_lv 32 signal 33 } 
	{ l_state_32 sc_in sc_lv 32 signal 34 } 
	{ l_state_33 sc_in sc_lv 32 signal 35 } 
	{ l_state_34 sc_in sc_lv 32 signal 36 } 
	{ l_state_35 sc_in sc_lv 32 signal 37 } 
	{ l_state_36 sc_in sc_lv 32 signal 38 } 
	{ l_state_37 sc_in sc_lv 32 signal 39 } 
	{ l_state_38 sc_in sc_lv 32 signal 40 } 
	{ l_state_39 sc_in sc_lv 32 signal 41 } 
	{ l_state_40 sc_in sc_lv 32 signal 42 } 
	{ l_state_41 sc_in sc_lv 32 signal 43 } 
	{ l_state_42 sc_in sc_lv 32 signal 44 } 
	{ l_state_43 sc_in sc_lv 32 signal 45 } 
	{ l_state_44 sc_in sc_lv 32 signal 46 } 
	{ l_state_45 sc_in sc_lv 32 signal 47 } 
	{ l_state_46 sc_in sc_lv 32 signal 48 } 
	{ l_state_47 sc_in sc_lv 32 signal 49 } 
	{ l_state_48 sc_in sc_lv 32 signal 50 } 
	{ l_state_49 sc_in sc_lv 32 signal 51 } 
	{ l_state_50 sc_in sc_lv 32 signal 52 } 
	{ l_state_51 sc_in sc_lv 32 signal 53 } 
	{ l_state_52 sc_in sc_lv 32 signal 54 } 
	{ l_state_53 sc_in sc_lv 32 signal 55 } 
	{ l_state_54 sc_in sc_lv 32 signal 56 } 
	{ l_state_55 sc_in sc_lv 32 signal 57 } 
	{ l_state_56 sc_in sc_lv 32 signal 58 } 
	{ l_state_57 sc_in sc_lv 32 signal 59 } 
	{ l_state_58 sc_in sc_lv 32 signal 60 } 
	{ l_state_59 sc_in sc_lv 32 signal 61 } 
	{ l_state_60 sc_in sc_lv 32 signal 62 } 
	{ l_state_61 sc_in sc_lv 32 signal 63 } 
	{ l_state_62 sc_in sc_lv 32 signal 64 } 
	{ l_state_63 sc_in sc_lv 32 signal 65 } 
	{ O_tile_address0 sc_out sc_lv 10 signal 66 } 
	{ O_tile_ce0 sc_out sc_logic 1 signal 66 } 
	{ O_tile_q0 sc_in sc_lv 32 signal 66 } 
	{ O_tile_1_address0 sc_out sc_lv 10 signal 67 } 
	{ O_tile_1_ce0 sc_out sc_logic 1 signal 67 } 
	{ O_tile_1_q0 sc_in sc_lv 32 signal 67 } 
	{ O_tile_2_address0 sc_out sc_lv 10 signal 68 } 
	{ O_tile_2_ce0 sc_out sc_logic 1 signal 68 } 
	{ O_tile_2_q0 sc_in sc_lv 32 signal 68 } 
	{ O_tile_3_address0 sc_out sc_lv 10 signal 69 } 
	{ O_tile_3_ce0 sc_out sc_logic 1 signal 69 } 
	{ O_tile_3_q0 sc_in sc_lv 32 signal 69 } 
	{ O_tile_4_address0 sc_out sc_lv 10 signal 70 } 
	{ O_tile_4_ce0 sc_out sc_logic 1 signal 70 } 
	{ O_tile_4_q0 sc_in sc_lv 32 signal 70 } 
	{ O_tile_5_address0 sc_out sc_lv 10 signal 71 } 
	{ O_tile_5_ce0 sc_out sc_logic 1 signal 71 } 
	{ O_tile_5_q0 sc_in sc_lv 32 signal 71 } 
	{ O_tile_6_address0 sc_out sc_lv 10 signal 72 } 
	{ O_tile_6_ce0 sc_out sc_logic 1 signal 72 } 
	{ O_tile_6_q0 sc_in sc_lv 32 signal 72 } 
	{ O_tile_7_address0 sc_out sc_lv 10 signal 73 } 
	{ O_tile_7_ce0 sc_out sc_logic 1 signal 73 } 
	{ O_tile_7_q0 sc_in sc_lv 32 signal 73 } 
	{ grp_fu_49878_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_49878_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_49878_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_49878_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_52808_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_52808_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_52808_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_52808_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_52816_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_52816_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_52816_p_opcode sc_out sc_lv 5 signal -1 } 
	{ grp_fu_52816_p_dout0 sc_in sc_lv 1 signal -1 } 
	{ grp_fu_52816_p_ce sc_out sc_logic 1 signal -1 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "m_axi_gmem3_AWVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "AWVALID" }} , 
 	{ "name": "m_axi_gmem3_AWREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "AWREADY" }} , 
 	{ "name": "m_axi_gmem3_AWADDR", "direction": "out", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "gmem3", "role": "AWADDR" }} , 
 	{ "name": "m_axi_gmem3_AWID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "AWID" }} , 
 	{ "name": "m_axi_gmem3_AWLEN", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "gmem3", "role": "AWLEN" }} , 
 	{ "name": "m_axi_gmem3_AWSIZE", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmem3", "role": "AWSIZE" }} , 
 	{ "name": "m_axi_gmem3_AWBURST", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmem3", "role": "AWBURST" }} , 
 	{ "name": "m_axi_gmem3_AWLOCK", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmem3", "role": "AWLOCK" }} , 
 	{ "name": "m_axi_gmem3_AWCACHE", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmem3", "role": "AWCACHE" }} , 
 	{ "name": "m_axi_gmem3_AWPROT", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmem3", "role": "AWPROT" }} , 
 	{ "name": "m_axi_gmem3_AWQOS", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmem3", "role": "AWQOS" }} , 
 	{ "name": "m_axi_gmem3_AWREGION", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmem3", "role": "AWREGION" }} , 
 	{ "name": "m_axi_gmem3_AWUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "AWUSER" }} , 
 	{ "name": "m_axi_gmem3_WVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "WVALID" }} , 
 	{ "name": "m_axi_gmem3_WREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "WREADY" }} , 
 	{ "name": "m_axi_gmem3_WDATA", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "gmem3", "role": "WDATA" }} , 
 	{ "name": "m_axi_gmem3_WSTRB", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmem3", "role": "WSTRB" }} , 
 	{ "name": "m_axi_gmem3_WLAST", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "WLAST" }} , 
 	{ "name": "m_axi_gmem3_WID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "WID" }} , 
 	{ "name": "m_axi_gmem3_WUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "WUSER" }} , 
 	{ "name": "m_axi_gmem3_ARVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "ARVALID" }} , 
 	{ "name": "m_axi_gmem3_ARREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "ARREADY" }} , 
 	{ "name": "m_axi_gmem3_ARADDR", "direction": "out", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "gmem3", "role": "ARADDR" }} , 
 	{ "name": "m_axi_gmem3_ARID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "ARID" }} , 
 	{ "name": "m_axi_gmem3_ARLEN", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "gmem3", "role": "ARLEN" }} , 
 	{ "name": "m_axi_gmem3_ARSIZE", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmem3", "role": "ARSIZE" }} , 
 	{ "name": "m_axi_gmem3_ARBURST", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmem3", "role": "ARBURST" }} , 
 	{ "name": "m_axi_gmem3_ARLOCK", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmem3", "role": "ARLOCK" }} , 
 	{ "name": "m_axi_gmem3_ARCACHE", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmem3", "role": "ARCACHE" }} , 
 	{ "name": "m_axi_gmem3_ARPROT", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmem3", "role": "ARPROT" }} , 
 	{ "name": "m_axi_gmem3_ARQOS", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmem3", "role": "ARQOS" }} , 
 	{ "name": "m_axi_gmem3_ARREGION", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmem3", "role": "ARREGION" }} , 
 	{ "name": "m_axi_gmem3_ARUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "ARUSER" }} , 
 	{ "name": "m_axi_gmem3_RVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "RVALID" }} , 
 	{ "name": "m_axi_gmem3_RREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "RREADY" }} , 
 	{ "name": "m_axi_gmem3_RDATA", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "gmem3", "role": "RDATA" }} , 
 	{ "name": "m_axi_gmem3_RLAST", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "RLAST" }} , 
 	{ "name": "m_axi_gmem3_RID", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "RID" }} , 
 	{ "name": "m_axi_gmem3_RFIFONUM", "direction": "in", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "gmem3", "role": "RFIFONUM" }} , 
 	{ "name": "m_axi_gmem3_RUSER", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "RUSER" }} , 
 	{ "name": "m_axi_gmem3_RRESP", "direction": "in", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmem3", "role": "RRESP" }} , 
 	{ "name": "m_axi_gmem3_BVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "BVALID" }} , 
 	{ "name": "m_axi_gmem3_BREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "BREADY" }} , 
 	{ "name": "m_axi_gmem3_BRESP", "direction": "in", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmem3", "role": "BRESP" }} , 
 	{ "name": "m_axi_gmem3_BID", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "BID" }} , 
 	{ "name": "m_axi_gmem3_BUSER", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmem3", "role": "BUSER" }} , 
 	{ "name": "sext_ln81", "direction": "in", "datatype": "sc_lv", "bitwidth":63, "type": "signal", "bundle":{"name": "sext_ln81", "role": "default" }} , 
 	{ "name": "l_state", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state", "role": "default" }} , 
 	{ "name": "l_state_1", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_1", "role": "default" }} , 
 	{ "name": "l_state_2", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_2", "role": "default" }} , 
 	{ "name": "l_state_3", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_3", "role": "default" }} , 
 	{ "name": "l_state_4", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_4", "role": "default" }} , 
 	{ "name": "l_state_5", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_5", "role": "default" }} , 
 	{ "name": "l_state_6", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_6", "role": "default" }} , 
 	{ "name": "l_state_7", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_7", "role": "default" }} , 
 	{ "name": "l_state_8", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_8", "role": "default" }} , 
 	{ "name": "l_state_9", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_9", "role": "default" }} , 
 	{ "name": "l_state_10", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_10", "role": "default" }} , 
 	{ "name": "l_state_11", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_11", "role": "default" }} , 
 	{ "name": "l_state_12", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_12", "role": "default" }} , 
 	{ "name": "l_state_13", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_13", "role": "default" }} , 
 	{ "name": "l_state_14", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_14", "role": "default" }} , 
 	{ "name": "l_state_15", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_15", "role": "default" }} , 
 	{ "name": "l_state_16", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_16", "role": "default" }} , 
 	{ "name": "l_state_17", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_17", "role": "default" }} , 
 	{ "name": "l_state_18", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_18", "role": "default" }} , 
 	{ "name": "l_state_19", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_19", "role": "default" }} , 
 	{ "name": "l_state_20", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_20", "role": "default" }} , 
 	{ "name": "l_state_21", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_21", "role": "default" }} , 
 	{ "name": "l_state_22", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_22", "role": "default" }} , 
 	{ "name": "l_state_23", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_23", "role": "default" }} , 
 	{ "name": "l_state_24", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_24", "role": "default" }} , 
 	{ "name": "l_state_25", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_25", "role": "default" }} , 
 	{ "name": "l_state_26", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_26", "role": "default" }} , 
 	{ "name": "l_state_27", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_27", "role": "default" }} , 
 	{ "name": "l_state_28", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_28", "role": "default" }} , 
 	{ "name": "l_state_29", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_29", "role": "default" }} , 
 	{ "name": "l_state_30", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_30", "role": "default" }} , 
 	{ "name": "l_state_31", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_31", "role": "default" }} , 
 	{ "name": "l_state_32", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_32", "role": "default" }} , 
 	{ "name": "l_state_33", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_33", "role": "default" }} , 
 	{ "name": "l_state_34", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_34", "role": "default" }} , 
 	{ "name": "l_state_35", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_35", "role": "default" }} , 
 	{ "name": "l_state_36", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_36", "role": "default" }} , 
 	{ "name": "l_state_37", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_37", "role": "default" }} , 
 	{ "name": "l_state_38", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_38", "role": "default" }} , 
 	{ "name": "l_state_39", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_39", "role": "default" }} , 
 	{ "name": "l_state_40", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_40", "role": "default" }} , 
 	{ "name": "l_state_41", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_41", "role": "default" }} , 
 	{ "name": "l_state_42", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_42", "role": "default" }} , 
 	{ "name": "l_state_43", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_43", "role": "default" }} , 
 	{ "name": "l_state_44", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_44", "role": "default" }} , 
 	{ "name": "l_state_45", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_45", "role": "default" }} , 
 	{ "name": "l_state_46", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_46", "role": "default" }} , 
 	{ "name": "l_state_47", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_47", "role": "default" }} , 
 	{ "name": "l_state_48", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_48", "role": "default" }} , 
 	{ "name": "l_state_49", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_49", "role": "default" }} , 
 	{ "name": "l_state_50", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_50", "role": "default" }} , 
 	{ "name": "l_state_51", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_51", "role": "default" }} , 
 	{ "name": "l_state_52", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_52", "role": "default" }} , 
 	{ "name": "l_state_53", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_53", "role": "default" }} , 
 	{ "name": "l_state_54", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_54", "role": "default" }} , 
 	{ "name": "l_state_55", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_55", "role": "default" }} , 
 	{ "name": "l_state_56", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_56", "role": "default" }} , 
 	{ "name": "l_state_57", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_57", "role": "default" }} , 
 	{ "name": "l_state_58", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_58", "role": "default" }} , 
 	{ "name": "l_state_59", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_59", "role": "default" }} , 
 	{ "name": "l_state_60", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_60", "role": "default" }} , 
 	{ "name": "l_state_61", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_61", "role": "default" }} , 
 	{ "name": "l_state_62", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_62", "role": "default" }} , 
 	{ "name": "l_state_63", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_63", "role": "default" }} , 
 	{ "name": "O_tile_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "O_tile", "role": "address0" }} , 
 	{ "name": "O_tile_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile", "role": "ce0" }} , 
 	{ "name": "O_tile_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile", "role": "q0" }} , 
 	{ "name": "O_tile_1_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "O_tile_1", "role": "address0" }} , 
 	{ "name": "O_tile_1_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_1", "role": "ce0" }} , 
 	{ "name": "O_tile_1_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_1", "role": "q0" }} , 
 	{ "name": "O_tile_2_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "O_tile_2", "role": "address0" }} , 
 	{ "name": "O_tile_2_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_2", "role": "ce0" }} , 
 	{ "name": "O_tile_2_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_2", "role": "q0" }} , 
 	{ "name": "O_tile_3_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "O_tile_3", "role": "address0" }} , 
 	{ "name": "O_tile_3_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_3", "role": "ce0" }} , 
 	{ "name": "O_tile_3_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_3", "role": "q0" }} , 
 	{ "name": "O_tile_4_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "O_tile_4", "role": "address0" }} , 
 	{ "name": "O_tile_4_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_4", "role": "ce0" }} , 
 	{ "name": "O_tile_4_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_4", "role": "q0" }} , 
 	{ "name": "O_tile_5_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "O_tile_5", "role": "address0" }} , 
 	{ "name": "O_tile_5_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_5", "role": "ce0" }} , 
 	{ "name": "O_tile_5_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_5", "role": "q0" }} , 
 	{ "name": "O_tile_6_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "O_tile_6", "role": "address0" }} , 
 	{ "name": "O_tile_6_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_6", "role": "ce0" }} , 
 	{ "name": "O_tile_6_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_6", "role": "q0" }} , 
 	{ "name": "O_tile_7_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":10, "type": "signal", "bundle":{"name": "O_tile_7", "role": "address0" }} , 
 	{ "name": "O_tile_7_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_7", "role": "ce0" }} , 
 	{ "name": "O_tile_7_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_7", "role": "q0" }} , 
 	{ "name": "grp_fu_49878_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_49878_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_49878_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_49878_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_49878_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_49878_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_49878_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_49878_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_52808_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_52808_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_52808_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_52808_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_52808_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_52808_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_52808_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_52808_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_52816_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_52816_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_52816_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_52816_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_52816_p_opcode", "direction": "out", "datatype": "sc_lv", "bitwidth":5, "type": "signal", "bundle":{"name": "grp_fu_52816_p_opcode", "role": "default" }} , 
 	{ "name": "grp_fu_52816_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_52816_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_52816_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_52816_p_ce", "role": "default" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1", "2", "3", "4"],
		"CDFG" : "attention_int8_kernel_Pipeline_VITIS_LOOP_193_18_VITIS_LOOP_195_19",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "8216", "EstimateLatencyMax" : "8216",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"IsBlackBox" : "0",
		"Port" : [
			{"Name" : "gmem3", "Type" : "MAXI", "Direction" : "O",
				"BlockSignal" : [
					{"Name" : "gmem3_blk_n_W", "Type" : "RtlSignal"}]},
			{"Name" : "sext_ln81", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_1", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_2", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_3", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_4", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_5", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_6", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_7", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_8", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_9", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_10", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_11", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_12", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_13", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_14", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_15", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_16", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_17", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_18", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_19", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_20", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_21", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_22", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_23", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_24", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_25", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_26", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_27", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_28", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_29", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_30", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_31", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_32", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_33", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_34", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_35", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_36", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_37", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_38", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_39", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_40", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_41", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_42", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_43", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_44", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_45", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_46", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_47", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_48", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_49", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_50", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_51", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_52", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_53", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_54", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_55", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_56", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_57", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_58", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_59", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_60", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_61", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_62", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_63", "Type" : "None", "Direction" : "I"},
			{"Name" : "O_tile", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "O_tile_1", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "O_tile_2", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "O_tile_3", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "O_tile_4", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "O_tile_5", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "O_tile_6", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "O_tile_7", "Type" : "Memory", "Direction" : "I"}],
		"Loop" : [
			{"Name" : "VITIS_LOOP_193_18_VITIS_LOOP_195_19", "PipelineType" : "UPC",
				"LoopDec" : {"FSMBitwidth" : "1", "FirstState" : "ap_ST_fsm_pp0_stage0", "FirstStateIter" : "ap_enable_reg_pp0_iter0", "FirstStateBlock" : "ap_block_pp0_stage0_subdone", "LastState" : "ap_ST_fsm_pp0_stage0", "LastStateIter" : "ap_enable_reg_pp0_iter23", "LastStateBlock" : "ap_block_pp0_stage0_subdone", "QuitState" : "ap_ST_fsm_pp0_stage0", "QuitStateIter" : "ap_enable_reg_pp0_iter23", "QuitStateBlock" : "ap_block_pp0_stage0_subdone", "OneDepthLoop" : "0", "has_ap_ctrl" : "1", "has_continue" : "0"}}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sptohp_32ns_16_2_no_dsp_1_U2190", "Parent" : "0"},
	{"ID" : "2", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sparsemux_129_6_32_1_1_U2191", "Parent" : "0"},
	{"ID" : "3", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sparsemux_17_3_32_1_1_U2192", "Parent" : "0"},
	{"ID" : "4", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.flow_control_loop_pipe_sequential_init_U", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	attention_int8_kernel_Pipeline_VITIS_LOOP_193_18_VITIS_LOOP_195_19 {
		gmem3 {Type O LastRead -1 FirstWrite 23}
		sext_ln81 {Type I LastRead 0 FirstWrite -1}
		l_state {Type I LastRead 0 FirstWrite -1}
		l_state_1 {Type I LastRead 0 FirstWrite -1}
		l_state_2 {Type I LastRead 0 FirstWrite -1}
		l_state_3 {Type I LastRead 0 FirstWrite -1}
		l_state_4 {Type I LastRead 0 FirstWrite -1}
		l_state_5 {Type I LastRead 0 FirstWrite -1}
		l_state_6 {Type I LastRead 0 FirstWrite -1}
		l_state_7 {Type I LastRead 0 FirstWrite -1}
		l_state_8 {Type I LastRead 0 FirstWrite -1}
		l_state_9 {Type I LastRead 0 FirstWrite -1}
		l_state_10 {Type I LastRead 0 FirstWrite -1}
		l_state_11 {Type I LastRead 0 FirstWrite -1}
		l_state_12 {Type I LastRead 0 FirstWrite -1}
		l_state_13 {Type I LastRead 0 FirstWrite -1}
		l_state_14 {Type I LastRead 0 FirstWrite -1}
		l_state_15 {Type I LastRead 0 FirstWrite -1}
		l_state_16 {Type I LastRead 0 FirstWrite -1}
		l_state_17 {Type I LastRead 0 FirstWrite -1}
		l_state_18 {Type I LastRead 0 FirstWrite -1}
		l_state_19 {Type I LastRead 0 FirstWrite -1}
		l_state_20 {Type I LastRead 0 FirstWrite -1}
		l_state_21 {Type I LastRead 0 FirstWrite -1}
		l_state_22 {Type I LastRead 0 FirstWrite -1}
		l_state_23 {Type I LastRead 0 FirstWrite -1}
		l_state_24 {Type I LastRead 0 FirstWrite -1}
		l_state_25 {Type I LastRead 0 FirstWrite -1}
		l_state_26 {Type I LastRead 0 FirstWrite -1}
		l_state_27 {Type I LastRead 0 FirstWrite -1}
		l_state_28 {Type I LastRead 0 FirstWrite -1}
		l_state_29 {Type I LastRead 0 FirstWrite -1}
		l_state_30 {Type I LastRead 0 FirstWrite -1}
		l_state_31 {Type I LastRead 0 FirstWrite -1}
		l_state_32 {Type I LastRead 0 FirstWrite -1}
		l_state_33 {Type I LastRead 0 FirstWrite -1}
		l_state_34 {Type I LastRead 0 FirstWrite -1}
		l_state_35 {Type I LastRead 0 FirstWrite -1}
		l_state_36 {Type I LastRead 0 FirstWrite -1}
		l_state_37 {Type I LastRead 0 FirstWrite -1}
		l_state_38 {Type I LastRead 0 FirstWrite -1}
		l_state_39 {Type I LastRead 0 FirstWrite -1}
		l_state_40 {Type I LastRead 0 FirstWrite -1}
		l_state_41 {Type I LastRead 0 FirstWrite -1}
		l_state_42 {Type I LastRead 0 FirstWrite -1}
		l_state_43 {Type I LastRead 0 FirstWrite -1}
		l_state_44 {Type I LastRead 0 FirstWrite -1}
		l_state_45 {Type I LastRead 0 FirstWrite -1}
		l_state_46 {Type I LastRead 0 FirstWrite -1}
		l_state_47 {Type I LastRead 0 FirstWrite -1}
		l_state_48 {Type I LastRead 0 FirstWrite -1}
		l_state_49 {Type I LastRead 0 FirstWrite -1}
		l_state_50 {Type I LastRead 0 FirstWrite -1}
		l_state_51 {Type I LastRead 0 FirstWrite -1}
		l_state_52 {Type I LastRead 0 FirstWrite -1}
		l_state_53 {Type I LastRead 0 FirstWrite -1}
		l_state_54 {Type I LastRead 0 FirstWrite -1}
		l_state_55 {Type I LastRead 0 FirstWrite -1}
		l_state_56 {Type I LastRead 0 FirstWrite -1}
		l_state_57 {Type I LastRead 0 FirstWrite -1}
		l_state_58 {Type I LastRead 0 FirstWrite -1}
		l_state_59 {Type I LastRead 0 FirstWrite -1}
		l_state_60 {Type I LastRead 0 FirstWrite -1}
		l_state_61 {Type I LastRead 0 FirstWrite -1}
		l_state_62 {Type I LastRead 0 FirstWrite -1}
		l_state_63 {Type I LastRead 0 FirstWrite -1}
		O_tile {Type I LastRead 15 FirstWrite -1}
		O_tile_1 {Type I LastRead 15 FirstWrite -1}
		O_tile_2 {Type I LastRead 15 FirstWrite -1}
		O_tile_3 {Type I LastRead 15 FirstWrite -1}
		O_tile_4 {Type I LastRead 15 FirstWrite -1}
		O_tile_5 {Type I LastRead 15 FirstWrite -1}
		O_tile_6 {Type I LastRead 15 FirstWrite -1}
		O_tile_7 {Type I LastRead 15 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "8216", "Max" : "8216"}
	, {"Name" : "Interval", "Min" : "8216", "Max" : "8216"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	 { m_axi {  { m_axi_gmem3_AWVALID VALID 1 1 }  { m_axi_gmem3_AWREADY READY 0 1 }  { m_axi_gmem3_AWADDR ADDR 1 64 }  { m_axi_gmem3_AWID ID 1 1 }  { m_axi_gmem3_AWLEN SIZE 1 32 }  { m_axi_gmem3_AWSIZE BURST 1 3 }  { m_axi_gmem3_AWBURST LOCK 1 2 }  { m_axi_gmem3_AWLOCK CACHE 1 2 }  { m_axi_gmem3_AWCACHE PROT 1 4 }  { m_axi_gmem3_AWPROT QOS 1 3 }  { m_axi_gmem3_AWQOS REGION 1 4 }  { m_axi_gmem3_AWREGION USER 1 4 }  { m_axi_gmem3_AWUSER DATA 1 1 }  { m_axi_gmem3_WVALID VALID 1 1 }  { m_axi_gmem3_WREADY READY 0 1 }  { m_axi_gmem3_WDATA FIFONUM 1 16 }  { m_axi_gmem3_WSTRB STRB 1 2 }  { m_axi_gmem3_WLAST LAST 1 1 }  { m_axi_gmem3_WID ID 1 1 }  { m_axi_gmem3_WUSER DATA 1 1 }  { m_axi_gmem3_ARVALID VALID 1 1 }  { m_axi_gmem3_ARREADY READY 0 1 }  { m_axi_gmem3_ARADDR ADDR 1 64 }  { m_axi_gmem3_ARID ID 1 1 }  { m_axi_gmem3_ARLEN SIZE 1 32 }  { m_axi_gmem3_ARSIZE BURST 1 3 }  { m_axi_gmem3_ARBURST LOCK 1 2 }  { m_axi_gmem3_ARLOCK CACHE 1 2 }  { m_axi_gmem3_ARCACHE PROT 1 4 }  { m_axi_gmem3_ARPROT QOS 1 3 }  { m_axi_gmem3_ARQOS REGION 1 4 }  { m_axi_gmem3_ARREGION USER 1 4 }  { m_axi_gmem3_ARUSER DATA 1 1 }  { m_axi_gmem3_RVALID VALID 0 1 }  { m_axi_gmem3_RREADY READY 1 1 }  { m_axi_gmem3_RDATA FIFONUM 0 16 }  { m_axi_gmem3_RLAST LAST 0 1 }  { m_axi_gmem3_RID ID 0 1 }  { m_axi_gmem3_RFIFONUM LEN 0 10 }  { m_axi_gmem3_RUSER DATA 0 1 }  { m_axi_gmem3_RRESP RESP 0 2 }  { m_axi_gmem3_BVALID VALID 0 1 }  { m_axi_gmem3_BREADY READY 1 1 }  { m_axi_gmem3_BRESP RESP 0 2 }  { m_axi_gmem3_BID ID 0 1 }  { m_axi_gmem3_BUSER DATA 0 1 } } }
	sext_ln81 { ap_none {  { sext_ln81 in_data 0 63 } } }
	l_state { ap_none {  { l_state in_data 0 32 } } }
	l_state_1 { ap_none {  { l_state_1 in_data 0 32 } } }
	l_state_2 { ap_none {  { l_state_2 in_data 0 32 } } }
	l_state_3 { ap_none {  { l_state_3 in_data 0 32 } } }
	l_state_4 { ap_none {  { l_state_4 in_data 0 32 } } }
	l_state_5 { ap_none {  { l_state_5 in_data 0 32 } } }
	l_state_6 { ap_none {  { l_state_6 in_data 0 32 } } }
	l_state_7 { ap_none {  { l_state_7 in_data 0 32 } } }
	l_state_8 { ap_none {  { l_state_8 in_data 0 32 } } }
	l_state_9 { ap_none {  { l_state_9 in_data 0 32 } } }
	l_state_10 { ap_none {  { l_state_10 in_data 0 32 } } }
	l_state_11 { ap_none {  { l_state_11 in_data 0 32 } } }
	l_state_12 { ap_none {  { l_state_12 in_data 0 32 } } }
	l_state_13 { ap_none {  { l_state_13 in_data 0 32 } } }
	l_state_14 { ap_none {  { l_state_14 in_data 0 32 } } }
	l_state_15 { ap_none {  { l_state_15 in_data 0 32 } } }
	l_state_16 { ap_none {  { l_state_16 in_data 0 32 } } }
	l_state_17 { ap_none {  { l_state_17 in_data 0 32 } } }
	l_state_18 { ap_none {  { l_state_18 in_data 0 32 } } }
	l_state_19 { ap_none {  { l_state_19 in_data 0 32 } } }
	l_state_20 { ap_none {  { l_state_20 in_data 0 32 } } }
	l_state_21 { ap_none {  { l_state_21 in_data 0 32 } } }
	l_state_22 { ap_none {  { l_state_22 in_data 0 32 } } }
	l_state_23 { ap_none {  { l_state_23 in_data 0 32 } } }
	l_state_24 { ap_none {  { l_state_24 in_data 0 32 } } }
	l_state_25 { ap_none {  { l_state_25 in_data 0 32 } } }
	l_state_26 { ap_none {  { l_state_26 in_data 0 32 } } }
	l_state_27 { ap_none {  { l_state_27 in_data 0 32 } } }
	l_state_28 { ap_none {  { l_state_28 in_data 0 32 } } }
	l_state_29 { ap_none {  { l_state_29 in_data 0 32 } } }
	l_state_30 { ap_none {  { l_state_30 in_data 0 32 } } }
	l_state_31 { ap_none {  { l_state_31 in_data 0 32 } } }
	l_state_32 { ap_none {  { l_state_32 in_data 0 32 } } }
	l_state_33 { ap_none {  { l_state_33 in_data 0 32 } } }
	l_state_34 { ap_none {  { l_state_34 in_data 0 32 } } }
	l_state_35 { ap_none {  { l_state_35 in_data 0 32 } } }
	l_state_36 { ap_none {  { l_state_36 in_data 0 32 } } }
	l_state_37 { ap_none {  { l_state_37 in_data 0 32 } } }
	l_state_38 { ap_none {  { l_state_38 in_data 0 32 } } }
	l_state_39 { ap_none {  { l_state_39 in_data 0 32 } } }
	l_state_40 { ap_none {  { l_state_40 in_data 0 32 } } }
	l_state_41 { ap_none {  { l_state_41 in_data 0 32 } } }
	l_state_42 { ap_none {  { l_state_42 in_data 0 32 } } }
	l_state_43 { ap_none {  { l_state_43 in_data 0 32 } } }
	l_state_44 { ap_none {  { l_state_44 in_data 0 32 } } }
	l_state_45 { ap_none {  { l_state_45 in_data 0 32 } } }
	l_state_46 { ap_none {  { l_state_46 in_data 0 32 } } }
	l_state_47 { ap_none {  { l_state_47 in_data 0 32 } } }
	l_state_48 { ap_none {  { l_state_48 in_data 0 32 } } }
	l_state_49 { ap_none {  { l_state_49 in_data 0 32 } } }
	l_state_50 { ap_none {  { l_state_50 in_data 0 32 } } }
	l_state_51 { ap_none {  { l_state_51 in_data 0 32 } } }
	l_state_52 { ap_none {  { l_state_52 in_data 0 32 } } }
	l_state_53 { ap_none {  { l_state_53 in_data 0 32 } } }
	l_state_54 { ap_none {  { l_state_54 in_data 0 32 } } }
	l_state_55 { ap_none {  { l_state_55 in_data 0 32 } } }
	l_state_56 { ap_none {  { l_state_56 in_data 0 32 } } }
	l_state_57 { ap_none {  { l_state_57 in_data 0 32 } } }
	l_state_58 { ap_none {  { l_state_58 in_data 0 32 } } }
	l_state_59 { ap_none {  { l_state_59 in_data 0 32 } } }
	l_state_60 { ap_none {  { l_state_60 in_data 0 32 } } }
	l_state_61 { ap_none {  { l_state_61 in_data 0 32 } } }
	l_state_62 { ap_none {  { l_state_62 in_data 0 32 } } }
	l_state_63 { ap_none {  { l_state_63 in_data 0 32 } } }
	O_tile { ap_memory {  { O_tile_address0 mem_address 1 10 }  { O_tile_ce0 mem_ce 1 1 }  { O_tile_q0 in_data 0 32 } } }
	O_tile_1 { ap_memory {  { O_tile_1_address0 mem_address 1 10 }  { O_tile_1_ce0 mem_ce 1 1 }  { O_tile_1_q0 in_data 0 32 } } }
	O_tile_2 { ap_memory {  { O_tile_2_address0 mem_address 1 10 }  { O_tile_2_ce0 mem_ce 1 1 }  { O_tile_2_q0 in_data 0 32 } } }
	O_tile_3 { ap_memory {  { O_tile_3_address0 mem_address 1 10 }  { O_tile_3_ce0 mem_ce 1 1 }  { O_tile_3_q0 in_data 0 32 } } }
	O_tile_4 { ap_memory {  { O_tile_4_address0 mem_address 1 10 }  { O_tile_4_ce0 mem_ce 1 1 }  { O_tile_4_q0 in_data 0 32 } } }
	O_tile_5 { ap_memory {  { O_tile_5_address0 mem_address 1 10 }  { O_tile_5_ce0 mem_ce 1 1 }  { O_tile_5_q0 in_data 0 32 } } }
	O_tile_6 { ap_memory {  { O_tile_6_address0 mem_address 1 10 }  { O_tile_6_ce0 mem_ce 1 1 }  { O_tile_6_q0 in_data 0 32 } } }
	O_tile_7 { ap_memory {  { O_tile_7_address0 mem_address 1 10 }  { O_tile_7_ce0 mem_ce 1 1 }  { O_tile_7_q0 in_data 0 32 } } }
}
