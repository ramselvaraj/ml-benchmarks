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
set C_modelName {attention_int8_kernel_Pipeline_VITIS_LOOP_193_18_VITIS_LOOP_195_19}
set C_modelType { void 0 }
set C_modelArgList {
	{ gmem3 int 16 regular {axi_master 1}  }
	{ sext_ln89 int 63 regular  }
	{ l_state_16 float 32 regular  }
	{ l_state_17 float 32 regular  }
	{ l_state_18 float 32 regular  }
	{ l_state_19 float 32 regular  }
	{ l_state_20 float 32 regular  }
	{ l_state_21 float 32 regular  }
	{ l_state_22 float 32 regular  }
	{ l_state_23 float 32 regular  }
	{ O_tile float 32 regular {array 64 { 1 3 } 1 1 }  }
	{ O_tile_1 float 32 regular {array 64 { 1 3 } 1 1 }  }
	{ O_tile_2 float 32 regular {array 64 { 1 3 } 1 1 }  }
	{ O_tile_3 float 32 regular {array 64 { 1 3 } 1 1 }  }
	{ O_tile_4 float 32 regular {array 64 { 1 3 } 1 1 }  }
	{ O_tile_5 float 32 regular {array 64 { 1 3 } 1 1 }  }
	{ O_tile_6 float 32 regular {array 64 { 1 3 } 1 1 }  }
	{ O_tile_7 float 32 regular {array 64 { 1 3 } 1 1 }  }
}
set C_modelArgMapList {[ 
	{ "Name" : "gmem3", "interface" : "axi_master", "bitwidth" : 16, "direction" : "WRITEONLY", "bitSlice":[ {"cElement": [{"cName": "O_out","offset": { "type": "dynamic","port_name": "O_out","bundle": "control"},"direction": "WRITEONLY"}]}]} , 
 	{ "Name" : "sext_ln89", "interface" : "wire", "bitwidth" : 63, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_16", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_17", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_18", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_19", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_20", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_21", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_22", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "l_state_23", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile_1", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile_2", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile_3", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile_4", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile_5", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile_6", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "O_tile_7", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} ]}
# RTL Port declarations: 
set portNum 98
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
	{ sext_ln89 sc_in sc_lv 63 signal 1 } 
	{ l_state_16 sc_in sc_lv 32 signal 2 } 
	{ l_state_17 sc_in sc_lv 32 signal 3 } 
	{ l_state_18 sc_in sc_lv 32 signal 4 } 
	{ l_state_19 sc_in sc_lv 32 signal 5 } 
	{ l_state_20 sc_in sc_lv 32 signal 6 } 
	{ l_state_21 sc_in sc_lv 32 signal 7 } 
	{ l_state_22 sc_in sc_lv 32 signal 8 } 
	{ l_state_23 sc_in sc_lv 32 signal 9 } 
	{ O_tile_address0 sc_out sc_lv 6 signal 10 } 
	{ O_tile_ce0 sc_out sc_logic 1 signal 10 } 
	{ O_tile_q0 sc_in sc_lv 32 signal 10 } 
	{ O_tile_1_address0 sc_out sc_lv 6 signal 11 } 
	{ O_tile_1_ce0 sc_out sc_logic 1 signal 11 } 
	{ O_tile_1_q0 sc_in sc_lv 32 signal 11 } 
	{ O_tile_2_address0 sc_out sc_lv 6 signal 12 } 
	{ O_tile_2_ce0 sc_out sc_logic 1 signal 12 } 
	{ O_tile_2_q0 sc_in sc_lv 32 signal 12 } 
	{ O_tile_3_address0 sc_out sc_lv 6 signal 13 } 
	{ O_tile_3_ce0 sc_out sc_logic 1 signal 13 } 
	{ O_tile_3_q0 sc_in sc_lv 32 signal 13 } 
	{ O_tile_4_address0 sc_out sc_lv 6 signal 14 } 
	{ O_tile_4_ce0 sc_out sc_logic 1 signal 14 } 
	{ O_tile_4_q0 sc_in sc_lv 32 signal 14 } 
	{ O_tile_5_address0 sc_out sc_lv 6 signal 15 } 
	{ O_tile_5_ce0 sc_out sc_logic 1 signal 15 } 
	{ O_tile_5_q0 sc_in sc_lv 32 signal 15 } 
	{ O_tile_6_address0 sc_out sc_lv 6 signal 16 } 
	{ O_tile_6_ce0 sc_out sc_logic 1 signal 16 } 
	{ O_tile_6_q0 sc_in sc_lv 32 signal 16 } 
	{ O_tile_7_address0 sc_out sc_lv 6 signal 17 } 
	{ O_tile_7_ce0 sc_out sc_logic 1 signal 17 } 
	{ O_tile_7_q0 sc_in sc_lv 32 signal 17 } 
	{ grp_fu_5058_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_5058_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_5058_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_5058_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_7182_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_7182_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_7182_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_7182_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_11425_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_11425_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_11425_p_opcode sc_out sc_lv 5 signal -1 } 
	{ grp_fu_11425_p_dout0 sc_in sc_lv 1 signal -1 } 
	{ grp_fu_11425_p_ce sc_out sc_logic 1 signal -1 } 
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
 	{ "name": "sext_ln89", "direction": "in", "datatype": "sc_lv", "bitwidth":63, "type": "signal", "bundle":{"name": "sext_ln89", "role": "default" }} , 
 	{ "name": "l_state_16", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_16", "role": "default" }} , 
 	{ "name": "l_state_17", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_17", "role": "default" }} , 
 	{ "name": "l_state_18", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_18", "role": "default" }} , 
 	{ "name": "l_state_19", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_19", "role": "default" }} , 
 	{ "name": "l_state_20", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_20", "role": "default" }} , 
 	{ "name": "l_state_21", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_21", "role": "default" }} , 
 	{ "name": "l_state_22", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_22", "role": "default" }} , 
 	{ "name": "l_state_23", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_23", "role": "default" }} , 
 	{ "name": "O_tile_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile", "role": "address0" }} , 
 	{ "name": "O_tile_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile", "role": "ce0" }} , 
 	{ "name": "O_tile_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile", "role": "q0" }} , 
 	{ "name": "O_tile_1_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_1", "role": "address0" }} , 
 	{ "name": "O_tile_1_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_1", "role": "ce0" }} , 
 	{ "name": "O_tile_1_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_1", "role": "q0" }} , 
 	{ "name": "O_tile_2_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_2", "role": "address0" }} , 
 	{ "name": "O_tile_2_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_2", "role": "ce0" }} , 
 	{ "name": "O_tile_2_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_2", "role": "q0" }} , 
 	{ "name": "O_tile_3_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_3", "role": "address0" }} , 
 	{ "name": "O_tile_3_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_3", "role": "ce0" }} , 
 	{ "name": "O_tile_3_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_3", "role": "q0" }} , 
 	{ "name": "O_tile_4_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_4", "role": "address0" }} , 
 	{ "name": "O_tile_4_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_4", "role": "ce0" }} , 
 	{ "name": "O_tile_4_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_4", "role": "q0" }} , 
 	{ "name": "O_tile_5_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_5", "role": "address0" }} , 
 	{ "name": "O_tile_5_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_5", "role": "ce0" }} , 
 	{ "name": "O_tile_5_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_5", "role": "q0" }} , 
 	{ "name": "O_tile_6_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_6", "role": "address0" }} , 
 	{ "name": "O_tile_6_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_6", "role": "ce0" }} , 
 	{ "name": "O_tile_6_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_6", "role": "q0" }} , 
 	{ "name": "O_tile_7_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_7", "role": "address0" }} , 
 	{ "name": "O_tile_7_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_7", "role": "ce0" }} , 
 	{ "name": "O_tile_7_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_7", "role": "q0" }} , 
 	{ "name": "grp_fu_5058_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_5058_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_5058_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_5058_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_5058_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_5058_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_5058_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_5058_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_7182_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_7182_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_7182_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_7182_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_7182_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_7182_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_7182_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_7182_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_11425_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_11425_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_11425_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_11425_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_11425_p_opcode", "direction": "out", "datatype": "sc_lv", "bitwidth":5, "type": "signal", "bundle":{"name": "grp_fu_11425_p_opcode", "role": "default" }} , 
 	{ "name": "grp_fu_11425_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_11425_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_11425_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_11425_p_ce", "role": "default" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1", "2", "3", "4", "5"],
		"CDFG" : "attention_int8_kernel_Pipeline_VITIS_LOOP_193_18_VITIS_LOOP_195_19",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "536", "EstimateLatencyMax" : "536",
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
			{"Name" : "sext_ln89", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_16", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_17", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_18", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_19", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_20", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_21", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_22", "Type" : "None", "Direction" : "I"},
			{"Name" : "l_state_23", "Type" : "None", "Direction" : "I"},
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
				"LoopDec" : {"FSMBitwidth" : "1", "FirstState" : "ap_ST_fsm_pp0_stage0", "FirstStateIter" : "ap_enable_reg_pp0_iter0", "FirstStateBlock" : "ap_block_pp0_stage0_subdone", "LastState" : "ap_ST_fsm_pp0_stage0", "LastStateIter" : "ap_enable_reg_pp0_iter23", "LastStateBlock" : "ap_block_pp0_stage0_subdone", "QuitState" : "ap_ST_fsm_pp0_stage0", "QuitStateIter" : "ap_enable_reg_pp0_iter22", "QuitStateBlock" : "ap_block_pp0_stage0_subdone", "OneDepthLoop" : "0", "has_ap_ctrl" : "1", "has_continue" : "0"}}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sptohp_32ns_16_2_no_dsp_1_U754", "Parent" : "0"},
	{"ID" : "2", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mux_84_32_1_1_U755", "Parent" : "0"},
	{"ID" : "3", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mux_84_32_1_1_U756", "Parent" : "0"},
	{"ID" : "4", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mux_83_32_1_1_U757", "Parent" : "0"},
	{"ID" : "5", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.flow_control_loop_pipe_sequential_init_U", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	attention_int8_kernel_Pipeline_VITIS_LOOP_193_18_VITIS_LOOP_195_19 {
		gmem3 {Type O LastRead -1 FirstWrite 23}
		sext_ln89 {Type I LastRead 0 FirstWrite -1}
		l_state_16 {Type I LastRead 0 FirstWrite -1}
		l_state_17 {Type I LastRead 0 FirstWrite -1}
		l_state_18 {Type I LastRead 0 FirstWrite -1}
		l_state_19 {Type I LastRead 0 FirstWrite -1}
		l_state_20 {Type I LastRead 0 FirstWrite -1}
		l_state_21 {Type I LastRead 0 FirstWrite -1}
		l_state_22 {Type I LastRead 0 FirstWrite -1}
		l_state_23 {Type I LastRead 0 FirstWrite -1}
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
	{"Name" : "Latency", "Min" : "536", "Max" : "536"}
	, {"Name" : "Interval", "Min" : "536", "Max" : "536"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	 { m_axi {  { m_axi_gmem3_AWVALID VALID 1 1 }  { m_axi_gmem3_AWREADY READY 0 1 }  { m_axi_gmem3_AWADDR ADDR 1 64 }  { m_axi_gmem3_AWID ID 1 1 }  { m_axi_gmem3_AWLEN SIZE 1 32 }  { m_axi_gmem3_AWSIZE BURST 1 3 }  { m_axi_gmem3_AWBURST LOCK 1 2 }  { m_axi_gmem3_AWLOCK CACHE 1 2 }  { m_axi_gmem3_AWCACHE PROT 1 4 }  { m_axi_gmem3_AWPROT QOS 1 3 }  { m_axi_gmem3_AWQOS REGION 1 4 }  { m_axi_gmem3_AWREGION USER 1 4 }  { m_axi_gmem3_AWUSER DATA 1 1 }  { m_axi_gmem3_WVALID VALID 1 1 }  { m_axi_gmem3_WREADY READY 0 1 }  { m_axi_gmem3_WDATA FIFONUM 1 16 }  { m_axi_gmem3_WSTRB STRB 1 2 }  { m_axi_gmem3_WLAST LAST 1 1 }  { m_axi_gmem3_WID ID 1 1 }  { m_axi_gmem3_WUSER DATA 1 1 }  { m_axi_gmem3_ARVALID VALID 1 1 }  { m_axi_gmem3_ARREADY READY 0 1 }  { m_axi_gmem3_ARADDR ADDR 1 64 }  { m_axi_gmem3_ARID ID 1 1 }  { m_axi_gmem3_ARLEN SIZE 1 32 }  { m_axi_gmem3_ARSIZE BURST 1 3 }  { m_axi_gmem3_ARBURST LOCK 1 2 }  { m_axi_gmem3_ARLOCK CACHE 1 2 }  { m_axi_gmem3_ARCACHE PROT 1 4 }  { m_axi_gmem3_ARPROT QOS 1 3 }  { m_axi_gmem3_ARQOS REGION 1 4 }  { m_axi_gmem3_ARREGION USER 1 4 }  { m_axi_gmem3_ARUSER DATA 1 1 }  { m_axi_gmem3_RVALID VALID 0 1 }  { m_axi_gmem3_RREADY READY 1 1 }  { m_axi_gmem3_RDATA FIFONUM 0 16 }  { m_axi_gmem3_RLAST LAST 0 1 }  { m_axi_gmem3_RID ID 0 1 }  { m_axi_gmem3_RFIFONUM LEN 0 10 }  { m_axi_gmem3_RUSER DATA 0 1 }  { m_axi_gmem3_RRESP RESP 0 2 }  { m_axi_gmem3_BVALID VALID 0 1 }  { m_axi_gmem3_BREADY READY 1 1 }  { m_axi_gmem3_BRESP RESP 0 2 }  { m_axi_gmem3_BID ID 0 1 }  { m_axi_gmem3_BUSER DATA 0 1 } } }
	sext_ln89 { ap_none {  { sext_ln89 in_data 0 63 } } }
	l_state_16 { ap_none {  { l_state_16 in_data 0 32 } } }
	l_state_17 { ap_none {  { l_state_17 in_data 0 32 } } }
	l_state_18 { ap_none {  { l_state_18 in_data 0 32 } } }
	l_state_19 { ap_none {  { l_state_19 in_data 0 32 } } }
	l_state_20 { ap_none {  { l_state_20 in_data 0 32 } } }
	l_state_21 { ap_none {  { l_state_21 in_data 0 32 } } }
	l_state_22 { ap_none {  { l_state_22 in_data 0 32 } } }
	l_state_23 { ap_none {  { l_state_23 in_data 0 32 } } }
	O_tile { ap_memory {  { O_tile_address0 mem_address 1 6 }  { O_tile_ce0 mem_ce 1 1 }  { O_tile_q0 in_data 0 32 } } }
	O_tile_1 { ap_memory {  { O_tile_1_address0 mem_address 1 6 }  { O_tile_1_ce0 mem_ce 1 1 }  { O_tile_1_q0 in_data 0 32 } } }
	O_tile_2 { ap_memory {  { O_tile_2_address0 mem_address 1 6 }  { O_tile_2_ce0 mem_ce 1 1 }  { O_tile_2_q0 in_data 0 32 } } }
	O_tile_3 { ap_memory {  { O_tile_3_address0 mem_address 1 6 }  { O_tile_3_ce0 mem_ce 1 1 }  { O_tile_3_q0 in_data 0 32 } } }
	O_tile_4 { ap_memory {  { O_tile_4_address0 mem_address 1 6 }  { O_tile_4_ce0 mem_ce 1 1 }  { O_tile_4_q0 in_data 0 32 } } }
	O_tile_5 { ap_memory {  { O_tile_5_address0 mem_address 1 6 }  { O_tile_5_ce0 mem_ce 1 1 }  { O_tile_5_q0 in_data 0 32 } } }
	O_tile_6 { ap_memory {  { O_tile_6_address0 mem_address 1 6 }  { O_tile_6_ce0 mem_ce 1 1 }  { O_tile_6_q0 in_data 0 32 } } }
	O_tile_7 { ap_memory {  { O_tile_7_address0 mem_address 1 6 }  { O_tile_7_ce0 mem_ce 1 1 }  { O_tile_7_q0 in_data 0 32 } } }
}
