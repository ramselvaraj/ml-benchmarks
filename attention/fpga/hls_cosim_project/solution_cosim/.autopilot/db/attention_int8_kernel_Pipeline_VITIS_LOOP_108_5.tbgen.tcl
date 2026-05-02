set moduleName attention_int8_kernel_Pipeline_VITIS_LOOP_108_5
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
set C_modelName {attention_int8_kernel_Pipeline_VITIS_LOOP_108_5}
set C_modelType { void 0 }
set C_modelArgList {
	{ O_tile float 32 regular {array 64 { 0 0 } 0 1 }  }
	{ O_tile_1 float 32 regular {array 64 { 0 0 } 0 1 }  }
	{ O_tile_2 float 32 regular {array 64 { 0 0 } 0 1 }  }
	{ O_tile_3 float 32 regular {array 64 { 0 0 } 0 1 }  }
	{ O_tile_4 float 32 regular {array 64 { 0 0 } 0 1 }  }
	{ O_tile_5 float 32 regular {array 64 { 0 0 } 0 1 }  }
	{ O_tile_6 float 32 regular {array 64 { 0 0 } 0 1 }  }
	{ O_tile_7 float 32 regular {array 64 { 0 0 } 0 1 }  }
	{ l_state_7_out float 32 regular {pointer 1}  }
	{ l_state_6_out float 32 regular {pointer 1}  }
	{ l_state_5_out float 32 regular {pointer 1}  }
	{ l_state_4_out float 32 regular {pointer 1}  }
	{ l_state_3_out float 32 regular {pointer 1}  }
	{ l_state_2_out float 32 regular {pointer 1}  }
	{ l_state_1_out float 32 regular {pointer 1}  }
	{ l_state_out float 32 regular {pointer 1}  }
	{ m_state_7_out float 32 regular {pointer 1}  }
	{ m_state_6_out float 32 regular {pointer 1}  }
	{ m_state_5_out float 32 regular {pointer 1}  }
	{ m_state_4_out float 32 regular {pointer 1}  }
	{ m_state_3_out float 32 regular {pointer 1}  }
	{ m_state_2_out float 32 regular {pointer 1}  }
	{ m_state_1_out float 32 regular {pointer 1}  }
	{ m_state_out float 32 regular {pointer 1}  }
}
set C_modelArgMapList {[ 
	{ "Name" : "O_tile", "interface" : "memory", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "O_tile_1", "interface" : "memory", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "O_tile_2", "interface" : "memory", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "O_tile_3", "interface" : "memory", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "O_tile_4", "interface" : "memory", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "O_tile_5", "interface" : "memory", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "O_tile_6", "interface" : "memory", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "O_tile_7", "interface" : "memory", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "l_state_7_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "l_state_6_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "l_state_5_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "l_state_4_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "l_state_3_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "l_state_2_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "l_state_1_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "l_state_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "m_state_7_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "m_state_6_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "m_state_5_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "m_state_4_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "m_state_3_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "m_state_2_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "m_state_1_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "m_state_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} ]}
# RTL Port declarations: 
set portNum 102
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ O_tile_address0 sc_out sc_lv 6 signal 0 } 
	{ O_tile_ce0 sc_out sc_logic 1 signal 0 } 
	{ O_tile_we0 sc_out sc_logic 1 signal 0 } 
	{ O_tile_d0 sc_out sc_lv 32 signal 0 } 
	{ O_tile_address1 sc_out sc_lv 6 signal 0 } 
	{ O_tile_ce1 sc_out sc_logic 1 signal 0 } 
	{ O_tile_we1 sc_out sc_logic 1 signal 0 } 
	{ O_tile_d1 sc_out sc_lv 32 signal 0 } 
	{ O_tile_1_address0 sc_out sc_lv 6 signal 1 } 
	{ O_tile_1_ce0 sc_out sc_logic 1 signal 1 } 
	{ O_tile_1_we0 sc_out sc_logic 1 signal 1 } 
	{ O_tile_1_d0 sc_out sc_lv 32 signal 1 } 
	{ O_tile_1_address1 sc_out sc_lv 6 signal 1 } 
	{ O_tile_1_ce1 sc_out sc_logic 1 signal 1 } 
	{ O_tile_1_we1 sc_out sc_logic 1 signal 1 } 
	{ O_tile_1_d1 sc_out sc_lv 32 signal 1 } 
	{ O_tile_2_address0 sc_out sc_lv 6 signal 2 } 
	{ O_tile_2_ce0 sc_out sc_logic 1 signal 2 } 
	{ O_tile_2_we0 sc_out sc_logic 1 signal 2 } 
	{ O_tile_2_d0 sc_out sc_lv 32 signal 2 } 
	{ O_tile_2_address1 sc_out sc_lv 6 signal 2 } 
	{ O_tile_2_ce1 sc_out sc_logic 1 signal 2 } 
	{ O_tile_2_we1 sc_out sc_logic 1 signal 2 } 
	{ O_tile_2_d1 sc_out sc_lv 32 signal 2 } 
	{ O_tile_3_address0 sc_out sc_lv 6 signal 3 } 
	{ O_tile_3_ce0 sc_out sc_logic 1 signal 3 } 
	{ O_tile_3_we0 sc_out sc_logic 1 signal 3 } 
	{ O_tile_3_d0 sc_out sc_lv 32 signal 3 } 
	{ O_tile_3_address1 sc_out sc_lv 6 signal 3 } 
	{ O_tile_3_ce1 sc_out sc_logic 1 signal 3 } 
	{ O_tile_3_we1 sc_out sc_logic 1 signal 3 } 
	{ O_tile_3_d1 sc_out sc_lv 32 signal 3 } 
	{ O_tile_4_address0 sc_out sc_lv 6 signal 4 } 
	{ O_tile_4_ce0 sc_out sc_logic 1 signal 4 } 
	{ O_tile_4_we0 sc_out sc_logic 1 signal 4 } 
	{ O_tile_4_d0 sc_out sc_lv 32 signal 4 } 
	{ O_tile_4_address1 sc_out sc_lv 6 signal 4 } 
	{ O_tile_4_ce1 sc_out sc_logic 1 signal 4 } 
	{ O_tile_4_we1 sc_out sc_logic 1 signal 4 } 
	{ O_tile_4_d1 sc_out sc_lv 32 signal 4 } 
	{ O_tile_5_address0 sc_out sc_lv 6 signal 5 } 
	{ O_tile_5_ce0 sc_out sc_logic 1 signal 5 } 
	{ O_tile_5_we0 sc_out sc_logic 1 signal 5 } 
	{ O_tile_5_d0 sc_out sc_lv 32 signal 5 } 
	{ O_tile_5_address1 sc_out sc_lv 6 signal 5 } 
	{ O_tile_5_ce1 sc_out sc_logic 1 signal 5 } 
	{ O_tile_5_we1 sc_out sc_logic 1 signal 5 } 
	{ O_tile_5_d1 sc_out sc_lv 32 signal 5 } 
	{ O_tile_6_address0 sc_out sc_lv 6 signal 6 } 
	{ O_tile_6_ce0 sc_out sc_logic 1 signal 6 } 
	{ O_tile_6_we0 sc_out sc_logic 1 signal 6 } 
	{ O_tile_6_d0 sc_out sc_lv 32 signal 6 } 
	{ O_tile_6_address1 sc_out sc_lv 6 signal 6 } 
	{ O_tile_6_ce1 sc_out sc_logic 1 signal 6 } 
	{ O_tile_6_we1 sc_out sc_logic 1 signal 6 } 
	{ O_tile_6_d1 sc_out sc_lv 32 signal 6 } 
	{ O_tile_7_address0 sc_out sc_lv 6 signal 7 } 
	{ O_tile_7_ce0 sc_out sc_logic 1 signal 7 } 
	{ O_tile_7_we0 sc_out sc_logic 1 signal 7 } 
	{ O_tile_7_d0 sc_out sc_lv 32 signal 7 } 
	{ O_tile_7_address1 sc_out sc_lv 6 signal 7 } 
	{ O_tile_7_ce1 sc_out sc_logic 1 signal 7 } 
	{ O_tile_7_we1 sc_out sc_logic 1 signal 7 } 
	{ O_tile_7_d1 sc_out sc_lv 32 signal 7 } 
	{ l_state_7_out sc_out sc_lv 32 signal 8 } 
	{ l_state_7_out_ap_vld sc_out sc_logic 1 outvld 8 } 
	{ l_state_6_out sc_out sc_lv 32 signal 9 } 
	{ l_state_6_out_ap_vld sc_out sc_logic 1 outvld 9 } 
	{ l_state_5_out sc_out sc_lv 32 signal 10 } 
	{ l_state_5_out_ap_vld sc_out sc_logic 1 outvld 10 } 
	{ l_state_4_out sc_out sc_lv 32 signal 11 } 
	{ l_state_4_out_ap_vld sc_out sc_logic 1 outvld 11 } 
	{ l_state_3_out sc_out sc_lv 32 signal 12 } 
	{ l_state_3_out_ap_vld sc_out sc_logic 1 outvld 12 } 
	{ l_state_2_out sc_out sc_lv 32 signal 13 } 
	{ l_state_2_out_ap_vld sc_out sc_logic 1 outvld 13 } 
	{ l_state_1_out sc_out sc_lv 32 signal 14 } 
	{ l_state_1_out_ap_vld sc_out sc_logic 1 outvld 14 } 
	{ l_state_out sc_out sc_lv 32 signal 15 } 
	{ l_state_out_ap_vld sc_out sc_logic 1 outvld 15 } 
	{ m_state_7_out sc_out sc_lv 32 signal 16 } 
	{ m_state_7_out_ap_vld sc_out sc_logic 1 outvld 16 } 
	{ m_state_6_out sc_out sc_lv 32 signal 17 } 
	{ m_state_6_out_ap_vld sc_out sc_logic 1 outvld 17 } 
	{ m_state_5_out sc_out sc_lv 32 signal 18 } 
	{ m_state_5_out_ap_vld sc_out sc_logic 1 outvld 18 } 
	{ m_state_4_out sc_out sc_lv 32 signal 19 } 
	{ m_state_4_out_ap_vld sc_out sc_logic 1 outvld 19 } 
	{ m_state_3_out sc_out sc_lv 32 signal 20 } 
	{ m_state_3_out_ap_vld sc_out sc_logic 1 outvld 20 } 
	{ m_state_2_out sc_out sc_lv 32 signal 21 } 
	{ m_state_2_out_ap_vld sc_out sc_logic 1 outvld 21 } 
	{ m_state_1_out sc_out sc_lv 32 signal 22 } 
	{ m_state_1_out_ap_vld sc_out sc_logic 1 outvld 22 } 
	{ m_state_out sc_out sc_lv 32 signal 23 } 
	{ m_state_out_ap_vld sc_out sc_logic 1 outvld 23 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "O_tile_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile", "role": "address0" }} , 
 	{ "name": "O_tile_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile", "role": "ce0" }} , 
 	{ "name": "O_tile_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile", "role": "we0" }} , 
 	{ "name": "O_tile_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile", "role": "d0" }} , 
 	{ "name": "O_tile_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile", "role": "address1" }} , 
 	{ "name": "O_tile_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile", "role": "ce1" }} , 
 	{ "name": "O_tile_we1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile", "role": "we1" }} , 
 	{ "name": "O_tile_d1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile", "role": "d1" }} , 
 	{ "name": "O_tile_1_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_1", "role": "address0" }} , 
 	{ "name": "O_tile_1_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_1", "role": "ce0" }} , 
 	{ "name": "O_tile_1_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_1", "role": "we0" }} , 
 	{ "name": "O_tile_1_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_1", "role": "d0" }} , 
 	{ "name": "O_tile_1_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_1", "role": "address1" }} , 
 	{ "name": "O_tile_1_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_1", "role": "ce1" }} , 
 	{ "name": "O_tile_1_we1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_1", "role": "we1" }} , 
 	{ "name": "O_tile_1_d1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_1", "role": "d1" }} , 
 	{ "name": "O_tile_2_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_2", "role": "address0" }} , 
 	{ "name": "O_tile_2_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_2", "role": "ce0" }} , 
 	{ "name": "O_tile_2_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_2", "role": "we0" }} , 
 	{ "name": "O_tile_2_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_2", "role": "d0" }} , 
 	{ "name": "O_tile_2_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_2", "role": "address1" }} , 
 	{ "name": "O_tile_2_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_2", "role": "ce1" }} , 
 	{ "name": "O_tile_2_we1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_2", "role": "we1" }} , 
 	{ "name": "O_tile_2_d1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_2", "role": "d1" }} , 
 	{ "name": "O_tile_3_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_3", "role": "address0" }} , 
 	{ "name": "O_tile_3_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_3", "role": "ce0" }} , 
 	{ "name": "O_tile_3_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_3", "role": "we0" }} , 
 	{ "name": "O_tile_3_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_3", "role": "d0" }} , 
 	{ "name": "O_tile_3_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_3", "role": "address1" }} , 
 	{ "name": "O_tile_3_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_3", "role": "ce1" }} , 
 	{ "name": "O_tile_3_we1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_3", "role": "we1" }} , 
 	{ "name": "O_tile_3_d1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_3", "role": "d1" }} , 
 	{ "name": "O_tile_4_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_4", "role": "address0" }} , 
 	{ "name": "O_tile_4_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_4", "role": "ce0" }} , 
 	{ "name": "O_tile_4_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_4", "role": "we0" }} , 
 	{ "name": "O_tile_4_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_4", "role": "d0" }} , 
 	{ "name": "O_tile_4_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_4", "role": "address1" }} , 
 	{ "name": "O_tile_4_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_4", "role": "ce1" }} , 
 	{ "name": "O_tile_4_we1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_4", "role": "we1" }} , 
 	{ "name": "O_tile_4_d1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_4", "role": "d1" }} , 
 	{ "name": "O_tile_5_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_5", "role": "address0" }} , 
 	{ "name": "O_tile_5_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_5", "role": "ce0" }} , 
 	{ "name": "O_tile_5_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_5", "role": "we0" }} , 
 	{ "name": "O_tile_5_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_5", "role": "d0" }} , 
 	{ "name": "O_tile_5_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_5", "role": "address1" }} , 
 	{ "name": "O_tile_5_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_5", "role": "ce1" }} , 
 	{ "name": "O_tile_5_we1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_5", "role": "we1" }} , 
 	{ "name": "O_tile_5_d1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_5", "role": "d1" }} , 
 	{ "name": "O_tile_6_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_6", "role": "address0" }} , 
 	{ "name": "O_tile_6_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_6", "role": "ce0" }} , 
 	{ "name": "O_tile_6_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_6", "role": "we0" }} , 
 	{ "name": "O_tile_6_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_6", "role": "d0" }} , 
 	{ "name": "O_tile_6_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_6", "role": "address1" }} , 
 	{ "name": "O_tile_6_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_6", "role": "ce1" }} , 
 	{ "name": "O_tile_6_we1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_6", "role": "we1" }} , 
 	{ "name": "O_tile_6_d1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_6", "role": "d1" }} , 
 	{ "name": "O_tile_7_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_7", "role": "address0" }} , 
 	{ "name": "O_tile_7_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_7", "role": "ce0" }} , 
 	{ "name": "O_tile_7_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_7", "role": "we0" }} , 
 	{ "name": "O_tile_7_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_7", "role": "d0" }} , 
 	{ "name": "O_tile_7_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "O_tile_7", "role": "address1" }} , 
 	{ "name": "O_tile_7_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_7", "role": "ce1" }} , 
 	{ "name": "O_tile_7_we1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "O_tile_7", "role": "we1" }} , 
 	{ "name": "O_tile_7_d1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "O_tile_7", "role": "d1" }} , 
 	{ "name": "l_state_7_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_7_out", "role": "default" }} , 
 	{ "name": "l_state_7_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "l_state_7_out", "role": "ap_vld" }} , 
 	{ "name": "l_state_6_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_6_out", "role": "default" }} , 
 	{ "name": "l_state_6_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "l_state_6_out", "role": "ap_vld" }} , 
 	{ "name": "l_state_5_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_5_out", "role": "default" }} , 
 	{ "name": "l_state_5_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "l_state_5_out", "role": "ap_vld" }} , 
 	{ "name": "l_state_4_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_4_out", "role": "default" }} , 
 	{ "name": "l_state_4_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "l_state_4_out", "role": "ap_vld" }} , 
 	{ "name": "l_state_3_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_3_out", "role": "default" }} , 
 	{ "name": "l_state_3_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "l_state_3_out", "role": "ap_vld" }} , 
 	{ "name": "l_state_2_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_2_out", "role": "default" }} , 
 	{ "name": "l_state_2_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "l_state_2_out", "role": "ap_vld" }} , 
 	{ "name": "l_state_1_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_1_out", "role": "default" }} , 
 	{ "name": "l_state_1_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "l_state_1_out", "role": "ap_vld" }} , 
 	{ "name": "l_state_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "l_state_out", "role": "default" }} , 
 	{ "name": "l_state_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "l_state_out", "role": "ap_vld" }} , 
 	{ "name": "m_state_7_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "m_state_7_out", "role": "default" }} , 
 	{ "name": "m_state_7_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "m_state_7_out", "role": "ap_vld" }} , 
 	{ "name": "m_state_6_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "m_state_6_out", "role": "default" }} , 
 	{ "name": "m_state_6_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "m_state_6_out", "role": "ap_vld" }} , 
 	{ "name": "m_state_5_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "m_state_5_out", "role": "default" }} , 
 	{ "name": "m_state_5_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "m_state_5_out", "role": "ap_vld" }} , 
 	{ "name": "m_state_4_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "m_state_4_out", "role": "default" }} , 
 	{ "name": "m_state_4_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "m_state_4_out", "role": "ap_vld" }} , 
 	{ "name": "m_state_3_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "m_state_3_out", "role": "default" }} , 
 	{ "name": "m_state_3_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "m_state_3_out", "role": "ap_vld" }} , 
 	{ "name": "m_state_2_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "m_state_2_out", "role": "default" }} , 
 	{ "name": "m_state_2_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "m_state_2_out", "role": "ap_vld" }} , 
 	{ "name": "m_state_1_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "m_state_1_out", "role": "default" }} , 
 	{ "name": "m_state_1_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "m_state_1_out", "role": "ap_vld" }} , 
 	{ "name": "m_state_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "m_state_out", "role": "default" }} , 
 	{ "name": "m_state_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "m_state_out", "role": "ap_vld" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1"],
		"CDFG" : "attention_int8_kernel_Pipeline_VITIS_LOOP_108_5",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "34", "EstimateLatencyMax" : "34",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"IsBlackBox" : "0",
		"Port" : [
			{"Name" : "O_tile", "Type" : "Memory", "Direction" : "O"},
			{"Name" : "O_tile_1", "Type" : "Memory", "Direction" : "O"},
			{"Name" : "O_tile_2", "Type" : "Memory", "Direction" : "O"},
			{"Name" : "O_tile_3", "Type" : "Memory", "Direction" : "O"},
			{"Name" : "O_tile_4", "Type" : "Memory", "Direction" : "O"},
			{"Name" : "O_tile_5", "Type" : "Memory", "Direction" : "O"},
			{"Name" : "O_tile_6", "Type" : "Memory", "Direction" : "O"},
			{"Name" : "O_tile_7", "Type" : "Memory", "Direction" : "O"},
			{"Name" : "l_state_7_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "l_state_6_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "l_state_5_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "l_state_4_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "l_state_3_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "l_state_2_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "l_state_1_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "l_state_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "m_state_7_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "m_state_6_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "m_state_5_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "m_state_4_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "m_state_3_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "m_state_2_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "m_state_1_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "m_state_out", "Type" : "Vld", "Direction" : "O"}],
		"Loop" : [
			{"Name" : "VITIS_LOOP_108_5", "PipelineType" : "NotSupport"}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.flow_control_loop_pipe_sequential_init_U", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	attention_int8_kernel_Pipeline_VITIS_LOOP_108_5 {
		O_tile {Type O LastRead -1 FirstWrite 0}
		O_tile_1 {Type O LastRead -1 FirstWrite 0}
		O_tile_2 {Type O LastRead -1 FirstWrite 0}
		O_tile_3 {Type O LastRead -1 FirstWrite 0}
		O_tile_4 {Type O LastRead -1 FirstWrite 0}
		O_tile_5 {Type O LastRead -1 FirstWrite 0}
		O_tile_6 {Type O LastRead -1 FirstWrite 0}
		O_tile_7 {Type O LastRead -1 FirstWrite 0}
		l_state_7_out {Type O LastRead -1 FirstWrite 0}
		l_state_6_out {Type O LastRead -1 FirstWrite 0}
		l_state_5_out {Type O LastRead -1 FirstWrite 0}
		l_state_4_out {Type O LastRead -1 FirstWrite 0}
		l_state_3_out {Type O LastRead -1 FirstWrite 0}
		l_state_2_out {Type O LastRead -1 FirstWrite 0}
		l_state_1_out {Type O LastRead -1 FirstWrite 0}
		l_state_out {Type O LastRead -1 FirstWrite 0}
		m_state_7_out {Type O LastRead -1 FirstWrite 0}
		m_state_6_out {Type O LastRead -1 FirstWrite 0}
		m_state_5_out {Type O LastRead -1 FirstWrite 0}
		m_state_4_out {Type O LastRead -1 FirstWrite 0}
		m_state_3_out {Type O LastRead -1 FirstWrite 0}
		m_state_2_out {Type O LastRead -1 FirstWrite 0}
		m_state_1_out {Type O LastRead -1 FirstWrite 0}
		m_state_out {Type O LastRead -1 FirstWrite 0}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "34", "Max" : "34"}
	, {"Name" : "Interval", "Min" : "34", "Max" : "34"}
]}

set PipelineEnableSignalInfo {[
]}

set Spec2ImplPortList { 
	O_tile { ap_memory {  { O_tile_address0 mem_address 1 6 }  { O_tile_ce0 mem_ce 1 1 }  { O_tile_we0 mem_we 1 1 }  { O_tile_d0 mem_din 1 32 }  { O_tile_address1 MemPortADDR2 1 6 }  { O_tile_ce1 MemPortCE2 1 1 }  { O_tile_we1 MemPortWE2 1 1 }  { O_tile_d1 MemPortDIN2 1 32 } } }
	O_tile_1 { ap_memory {  { O_tile_1_address0 mem_address 1 6 }  { O_tile_1_ce0 mem_ce 1 1 }  { O_tile_1_we0 mem_we 1 1 }  { O_tile_1_d0 mem_din 1 32 }  { O_tile_1_address1 MemPortADDR2 1 6 }  { O_tile_1_ce1 MemPortCE2 1 1 }  { O_tile_1_we1 MemPortWE2 1 1 }  { O_tile_1_d1 MemPortDIN2 1 32 } } }
	O_tile_2 { ap_memory {  { O_tile_2_address0 mem_address 1 6 }  { O_tile_2_ce0 mem_ce 1 1 }  { O_tile_2_we0 mem_we 1 1 }  { O_tile_2_d0 mem_din 1 32 }  { O_tile_2_address1 MemPortADDR2 1 6 }  { O_tile_2_ce1 MemPortCE2 1 1 }  { O_tile_2_we1 MemPortWE2 1 1 }  { O_tile_2_d1 MemPortDIN2 1 32 } } }
	O_tile_3 { ap_memory {  { O_tile_3_address0 mem_address 1 6 }  { O_tile_3_ce0 mem_ce 1 1 }  { O_tile_3_we0 mem_we 1 1 }  { O_tile_3_d0 mem_din 1 32 }  { O_tile_3_address1 MemPortADDR2 1 6 }  { O_tile_3_ce1 MemPortCE2 1 1 }  { O_tile_3_we1 MemPortWE2 1 1 }  { O_tile_3_d1 MemPortDIN2 1 32 } } }
	O_tile_4 { ap_memory {  { O_tile_4_address0 mem_address 1 6 }  { O_tile_4_ce0 mem_ce 1 1 }  { O_tile_4_we0 mem_we 1 1 }  { O_tile_4_d0 mem_din 1 32 }  { O_tile_4_address1 MemPortADDR2 1 6 }  { O_tile_4_ce1 MemPortCE2 1 1 }  { O_tile_4_we1 MemPortWE2 1 1 }  { O_tile_4_d1 MemPortDIN2 1 32 } } }
	O_tile_5 { ap_memory {  { O_tile_5_address0 mem_address 1 6 }  { O_tile_5_ce0 mem_ce 1 1 }  { O_tile_5_we0 mem_we 1 1 }  { O_tile_5_d0 mem_din 1 32 }  { O_tile_5_address1 MemPortADDR2 1 6 }  { O_tile_5_ce1 MemPortCE2 1 1 }  { O_tile_5_we1 MemPortWE2 1 1 }  { O_tile_5_d1 MemPortDIN2 1 32 } } }
	O_tile_6 { ap_memory {  { O_tile_6_address0 mem_address 1 6 }  { O_tile_6_ce0 mem_ce 1 1 }  { O_tile_6_we0 mem_we 1 1 }  { O_tile_6_d0 mem_din 1 32 }  { O_tile_6_address1 MemPortADDR2 1 6 }  { O_tile_6_ce1 MemPortCE2 1 1 }  { O_tile_6_we1 MemPortWE2 1 1 }  { O_tile_6_d1 MemPortDIN2 1 32 } } }
	O_tile_7 { ap_memory {  { O_tile_7_address0 mem_address 1 6 }  { O_tile_7_ce0 mem_ce 1 1 }  { O_tile_7_we0 mem_we 1 1 }  { O_tile_7_d0 mem_din 1 32 }  { O_tile_7_address1 MemPortADDR2 1 6 }  { O_tile_7_ce1 MemPortCE2 1 1 }  { O_tile_7_we1 MemPortWE2 1 1 }  { O_tile_7_d1 MemPortDIN2 1 32 } } }
	l_state_7_out { ap_vld {  { l_state_7_out out_data 1 32 }  { l_state_7_out_ap_vld out_vld 1 1 } } }
	l_state_6_out { ap_vld {  { l_state_6_out out_data 1 32 }  { l_state_6_out_ap_vld out_vld 1 1 } } }
	l_state_5_out { ap_vld {  { l_state_5_out out_data 1 32 }  { l_state_5_out_ap_vld out_vld 1 1 } } }
	l_state_4_out { ap_vld {  { l_state_4_out out_data 1 32 }  { l_state_4_out_ap_vld out_vld 1 1 } } }
	l_state_3_out { ap_vld {  { l_state_3_out out_data 1 32 }  { l_state_3_out_ap_vld out_vld 1 1 } } }
	l_state_2_out { ap_vld {  { l_state_2_out out_data 1 32 }  { l_state_2_out_ap_vld out_vld 1 1 } } }
	l_state_1_out { ap_vld {  { l_state_1_out out_data 1 32 }  { l_state_1_out_ap_vld out_vld 1 1 } } }
	l_state_out { ap_vld {  { l_state_out out_data 1 32 }  { l_state_out_ap_vld out_vld 1 1 } } }
	m_state_7_out { ap_vld {  { m_state_7_out out_data 1 32 }  { m_state_7_out_ap_vld out_vld 1 1 } } }
	m_state_6_out { ap_vld {  { m_state_6_out out_data 1 32 }  { m_state_6_out_ap_vld out_vld 1 1 } } }
	m_state_5_out { ap_vld {  { m_state_5_out out_data 1 32 }  { m_state_5_out_ap_vld out_vld 1 1 } } }
	m_state_4_out { ap_vld {  { m_state_4_out out_data 1 32 }  { m_state_4_out_ap_vld out_vld 1 1 } } }
	m_state_3_out { ap_vld {  { m_state_3_out out_data 1 32 }  { m_state_3_out_ap_vld out_vld 1 1 } } }
	m_state_2_out { ap_vld {  { m_state_2_out out_data 1 32 }  { m_state_2_out_ap_vld out_vld 1 1 } } }
	m_state_1_out { ap_vld {  { m_state_1_out out_data 1 32 }  { m_state_1_out_ap_vld out_vld 1 1 } } }
	m_state_out { ap_vld {  { m_state_out out_data 1 32 }  { m_state_out_ap_vld out_vld 1 1 } } }
}
