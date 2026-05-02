set moduleName attention_int8_kernel_Pipeline_VITIS_LOOP_168_14
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
set C_modelName {attention_int8_kernel_Pipeline_VITIS_LOOP_168_14}
set C_modelType { void 0 }
set C_modelArgList {
	{ i_4 int 6 regular  }
	{ scores float 32 regular {array 512 { 1 3 } 1 1 }  }
	{ scores_1 float 32 regular {array 512 { 1 3 } 1 1 }  }
	{ scores_2 float 32 regular {array 512 { 1 3 } 1 1 }  }
	{ scores_3 float 32 regular {array 512 { 1 3 } 1 1 }  }
	{ scores_4 float 32 regular {array 512 { 1 3 } 1 1 }  }
	{ scores_5 float 32 regular {array 512 { 1 3 } 1 1 }  }
	{ scores_6 float 32 regular {array 512 { 1 3 } 1 1 }  }
	{ scores_7 float 32 regular {array 512 { 1 3 } 1 1 }  }
	{ m_new float 32 regular  }
	{ p_out float 32 regular {pointer 1}  }
	{ p_out1 float 32 regular {pointer 1}  }
	{ p_out2 float 32 regular {pointer 1}  }
	{ p_out3 float 32 regular {pointer 1}  }
	{ p_out4 float 32 regular {pointer 1}  }
	{ p_out5 float 32 regular {pointer 1}  }
	{ p_out6 float 32 regular {pointer 1}  }
	{ p_out7 float 32 regular {pointer 1}  }
	{ p_out8 float 32 regular {pointer 1}  }
	{ p_out9 float 32 regular {pointer 1}  }
	{ p_out10 float 32 regular {pointer 1}  }
	{ p_out11 float 32 regular {pointer 1}  }
	{ p_out12 float 32 regular {pointer 1}  }
	{ p_out13 float 32 regular {pointer 1}  }
	{ p_out14 float 32 regular {pointer 1}  }
	{ p_out15 float 32 regular {pointer 1}  }
	{ p_out16 float 32 regular {pointer 1}  }
	{ p_out17 float 32 regular {pointer 1}  }
	{ p_out18 float 32 regular {pointer 1}  }
	{ p_out19 float 32 regular {pointer 1}  }
	{ p_out20 float 32 regular {pointer 1}  }
	{ p_out21 float 32 regular {pointer 1}  }
	{ p_out22 float 32 regular {pointer 1}  }
	{ p_out23 float 32 regular {pointer 1}  }
	{ p_out24 float 32 regular {pointer 1}  }
	{ p_out25 float 32 regular {pointer 1}  }
	{ p_out26 float 32 regular {pointer 1}  }
	{ p_out27 float 32 regular {pointer 1}  }
	{ p_out28 float 32 regular {pointer 1}  }
	{ p_out29 float 32 regular {pointer 1}  }
	{ p_out30 float 32 regular {pointer 1}  }
	{ p_out31 float 32 regular {pointer 1}  }
	{ p_out32 float 32 regular {pointer 1}  }
	{ p_out33 float 32 regular {pointer 1}  }
	{ p_out34 float 32 regular {pointer 1}  }
	{ p_out35 float 32 regular {pointer 1}  }
	{ p_out36 float 32 regular {pointer 1}  }
	{ p_out37 float 32 regular {pointer 1}  }
	{ p_out38 float 32 regular {pointer 1}  }
	{ p_out39 float 32 regular {pointer 1}  }
	{ p_out40 float 32 regular {pointer 1}  }
	{ p_out41 float 32 regular {pointer 1}  }
	{ p_out42 float 32 regular {pointer 1}  }
	{ p_out43 float 32 regular {pointer 1}  }
	{ p_out44 float 32 regular {pointer 1}  }
	{ p_out45 float 32 regular {pointer 1}  }
	{ p_out46 float 32 regular {pointer 1}  }
	{ p_out47 float 32 regular {pointer 1}  }
	{ p_out48 float 32 regular {pointer 1}  }
	{ p_out49 float 32 regular {pointer 1}  }
	{ p_out50 float 32 regular {pointer 1}  }
	{ p_out51 float 32 regular {pointer 1}  }
	{ p_out52 float 32 regular {pointer 1}  }
	{ p_out53 float 32 regular {pointer 1}  }
	{ p_out54 float 32 regular {pointer 1}  }
	{ p_out55 float 32 regular {pointer 1}  }
	{ p_out56 float 32 regular {pointer 1}  }
	{ p_out57 float 32 regular {pointer 1}  }
	{ p_out58 float 32 regular {pointer 1}  }
	{ p_out59 float 32 regular {pointer 1}  }
	{ p_out60 float 32 regular {pointer 1}  }
	{ p_out61 float 32 regular {pointer 1}  }
	{ p_out62 float 32 regular {pointer 1}  }
	{ p_out63 float 32 regular {pointer 1}  }
}
set hasAXIMCache 0
set AXIMCacheInstList { }
set C_modelArgMapList {[ 
	{ "Name" : "i_4", "interface" : "wire", "bitwidth" : 6, "direction" : "READONLY"} , 
 	{ "Name" : "scores", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "scores_1", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "scores_2", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "scores_3", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "scores_4", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "scores_5", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "scores_6", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "scores_7", "interface" : "memory", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "m_new", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "p_out", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out1", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out2", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out3", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out4", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out5", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out6", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out7", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out8", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out9", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out10", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out11", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out12", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out13", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out14", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out15", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out16", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out17", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out18", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out19", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out20", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out21", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out22", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out23", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out24", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out25", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out26", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out27", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out28", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out29", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out30", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out31", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out32", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out33", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out34", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out35", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out36", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out37", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out38", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out39", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out40", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out41", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out42", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out43", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out44", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out45", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out46", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out47", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out48", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out49", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out50", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out51", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out52", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out53", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out54", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out55", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out56", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out57", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out58", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out59", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out60", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out61", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out62", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "p_out63", "interface" : "wire", "bitwidth" : 32, "direction" : "WRITEONLY"} ]}
# RTL Port declarations: 
set portNum 200
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ i_4 sc_in sc_lv 6 signal 0 } 
	{ scores_address0 sc_out sc_lv 9 signal 1 } 
	{ scores_ce0 sc_out sc_logic 1 signal 1 } 
	{ scores_q0 sc_in sc_lv 32 signal 1 } 
	{ scores_1_address0 sc_out sc_lv 9 signal 2 } 
	{ scores_1_ce0 sc_out sc_logic 1 signal 2 } 
	{ scores_1_q0 sc_in sc_lv 32 signal 2 } 
	{ scores_2_address0 sc_out sc_lv 9 signal 3 } 
	{ scores_2_ce0 sc_out sc_logic 1 signal 3 } 
	{ scores_2_q0 sc_in sc_lv 32 signal 3 } 
	{ scores_3_address0 sc_out sc_lv 9 signal 4 } 
	{ scores_3_ce0 sc_out sc_logic 1 signal 4 } 
	{ scores_3_q0 sc_in sc_lv 32 signal 4 } 
	{ scores_4_address0 sc_out sc_lv 9 signal 5 } 
	{ scores_4_ce0 sc_out sc_logic 1 signal 5 } 
	{ scores_4_q0 sc_in sc_lv 32 signal 5 } 
	{ scores_5_address0 sc_out sc_lv 9 signal 6 } 
	{ scores_5_ce0 sc_out sc_logic 1 signal 6 } 
	{ scores_5_q0 sc_in sc_lv 32 signal 6 } 
	{ scores_6_address0 sc_out sc_lv 9 signal 7 } 
	{ scores_6_ce0 sc_out sc_logic 1 signal 7 } 
	{ scores_6_q0 sc_in sc_lv 32 signal 7 } 
	{ scores_7_address0 sc_out sc_lv 9 signal 8 } 
	{ scores_7_ce0 sc_out sc_logic 1 signal 8 } 
	{ scores_7_q0 sc_in sc_lv 32 signal 8 } 
	{ m_new sc_in sc_lv 32 signal 9 } 
	{ p_out sc_out sc_lv 32 signal 10 } 
	{ p_out_ap_vld sc_out sc_logic 1 outvld 10 } 
	{ p_out1 sc_out sc_lv 32 signal 11 } 
	{ p_out1_ap_vld sc_out sc_logic 1 outvld 11 } 
	{ p_out2 sc_out sc_lv 32 signal 12 } 
	{ p_out2_ap_vld sc_out sc_logic 1 outvld 12 } 
	{ p_out3 sc_out sc_lv 32 signal 13 } 
	{ p_out3_ap_vld sc_out sc_logic 1 outvld 13 } 
	{ p_out4 sc_out sc_lv 32 signal 14 } 
	{ p_out4_ap_vld sc_out sc_logic 1 outvld 14 } 
	{ p_out5 sc_out sc_lv 32 signal 15 } 
	{ p_out5_ap_vld sc_out sc_logic 1 outvld 15 } 
	{ p_out6 sc_out sc_lv 32 signal 16 } 
	{ p_out6_ap_vld sc_out sc_logic 1 outvld 16 } 
	{ p_out7 sc_out sc_lv 32 signal 17 } 
	{ p_out7_ap_vld sc_out sc_logic 1 outvld 17 } 
	{ p_out8 sc_out sc_lv 32 signal 18 } 
	{ p_out8_ap_vld sc_out sc_logic 1 outvld 18 } 
	{ p_out9 sc_out sc_lv 32 signal 19 } 
	{ p_out9_ap_vld sc_out sc_logic 1 outvld 19 } 
	{ p_out10 sc_out sc_lv 32 signal 20 } 
	{ p_out10_ap_vld sc_out sc_logic 1 outvld 20 } 
	{ p_out11 sc_out sc_lv 32 signal 21 } 
	{ p_out11_ap_vld sc_out sc_logic 1 outvld 21 } 
	{ p_out12 sc_out sc_lv 32 signal 22 } 
	{ p_out12_ap_vld sc_out sc_logic 1 outvld 22 } 
	{ p_out13 sc_out sc_lv 32 signal 23 } 
	{ p_out13_ap_vld sc_out sc_logic 1 outvld 23 } 
	{ p_out14 sc_out sc_lv 32 signal 24 } 
	{ p_out14_ap_vld sc_out sc_logic 1 outvld 24 } 
	{ p_out15 sc_out sc_lv 32 signal 25 } 
	{ p_out15_ap_vld sc_out sc_logic 1 outvld 25 } 
	{ p_out16 sc_out sc_lv 32 signal 26 } 
	{ p_out16_ap_vld sc_out sc_logic 1 outvld 26 } 
	{ p_out17 sc_out sc_lv 32 signal 27 } 
	{ p_out17_ap_vld sc_out sc_logic 1 outvld 27 } 
	{ p_out18 sc_out sc_lv 32 signal 28 } 
	{ p_out18_ap_vld sc_out sc_logic 1 outvld 28 } 
	{ p_out19 sc_out sc_lv 32 signal 29 } 
	{ p_out19_ap_vld sc_out sc_logic 1 outvld 29 } 
	{ p_out20 sc_out sc_lv 32 signal 30 } 
	{ p_out20_ap_vld sc_out sc_logic 1 outvld 30 } 
	{ p_out21 sc_out sc_lv 32 signal 31 } 
	{ p_out21_ap_vld sc_out sc_logic 1 outvld 31 } 
	{ p_out22 sc_out sc_lv 32 signal 32 } 
	{ p_out22_ap_vld sc_out sc_logic 1 outvld 32 } 
	{ p_out23 sc_out sc_lv 32 signal 33 } 
	{ p_out23_ap_vld sc_out sc_logic 1 outvld 33 } 
	{ p_out24 sc_out sc_lv 32 signal 34 } 
	{ p_out24_ap_vld sc_out sc_logic 1 outvld 34 } 
	{ p_out25 sc_out sc_lv 32 signal 35 } 
	{ p_out25_ap_vld sc_out sc_logic 1 outvld 35 } 
	{ p_out26 sc_out sc_lv 32 signal 36 } 
	{ p_out26_ap_vld sc_out sc_logic 1 outvld 36 } 
	{ p_out27 sc_out sc_lv 32 signal 37 } 
	{ p_out27_ap_vld sc_out sc_logic 1 outvld 37 } 
	{ p_out28 sc_out sc_lv 32 signal 38 } 
	{ p_out28_ap_vld sc_out sc_logic 1 outvld 38 } 
	{ p_out29 sc_out sc_lv 32 signal 39 } 
	{ p_out29_ap_vld sc_out sc_logic 1 outvld 39 } 
	{ p_out30 sc_out sc_lv 32 signal 40 } 
	{ p_out30_ap_vld sc_out sc_logic 1 outvld 40 } 
	{ p_out31 sc_out sc_lv 32 signal 41 } 
	{ p_out31_ap_vld sc_out sc_logic 1 outvld 41 } 
	{ p_out32 sc_out sc_lv 32 signal 42 } 
	{ p_out32_ap_vld sc_out sc_logic 1 outvld 42 } 
	{ p_out33 sc_out sc_lv 32 signal 43 } 
	{ p_out33_ap_vld sc_out sc_logic 1 outvld 43 } 
	{ p_out34 sc_out sc_lv 32 signal 44 } 
	{ p_out34_ap_vld sc_out sc_logic 1 outvld 44 } 
	{ p_out35 sc_out sc_lv 32 signal 45 } 
	{ p_out35_ap_vld sc_out sc_logic 1 outvld 45 } 
	{ p_out36 sc_out sc_lv 32 signal 46 } 
	{ p_out36_ap_vld sc_out sc_logic 1 outvld 46 } 
	{ p_out37 sc_out sc_lv 32 signal 47 } 
	{ p_out37_ap_vld sc_out sc_logic 1 outvld 47 } 
	{ p_out38 sc_out sc_lv 32 signal 48 } 
	{ p_out38_ap_vld sc_out sc_logic 1 outvld 48 } 
	{ p_out39 sc_out sc_lv 32 signal 49 } 
	{ p_out39_ap_vld sc_out sc_logic 1 outvld 49 } 
	{ p_out40 sc_out sc_lv 32 signal 50 } 
	{ p_out40_ap_vld sc_out sc_logic 1 outvld 50 } 
	{ p_out41 sc_out sc_lv 32 signal 51 } 
	{ p_out41_ap_vld sc_out sc_logic 1 outvld 51 } 
	{ p_out42 sc_out sc_lv 32 signal 52 } 
	{ p_out42_ap_vld sc_out sc_logic 1 outvld 52 } 
	{ p_out43 sc_out sc_lv 32 signal 53 } 
	{ p_out43_ap_vld sc_out sc_logic 1 outvld 53 } 
	{ p_out44 sc_out sc_lv 32 signal 54 } 
	{ p_out44_ap_vld sc_out sc_logic 1 outvld 54 } 
	{ p_out45 sc_out sc_lv 32 signal 55 } 
	{ p_out45_ap_vld sc_out sc_logic 1 outvld 55 } 
	{ p_out46 sc_out sc_lv 32 signal 56 } 
	{ p_out46_ap_vld sc_out sc_logic 1 outvld 56 } 
	{ p_out47 sc_out sc_lv 32 signal 57 } 
	{ p_out47_ap_vld sc_out sc_logic 1 outvld 57 } 
	{ p_out48 sc_out sc_lv 32 signal 58 } 
	{ p_out48_ap_vld sc_out sc_logic 1 outvld 58 } 
	{ p_out49 sc_out sc_lv 32 signal 59 } 
	{ p_out49_ap_vld sc_out sc_logic 1 outvld 59 } 
	{ p_out50 sc_out sc_lv 32 signal 60 } 
	{ p_out50_ap_vld sc_out sc_logic 1 outvld 60 } 
	{ p_out51 sc_out sc_lv 32 signal 61 } 
	{ p_out51_ap_vld sc_out sc_logic 1 outvld 61 } 
	{ p_out52 sc_out sc_lv 32 signal 62 } 
	{ p_out52_ap_vld sc_out sc_logic 1 outvld 62 } 
	{ p_out53 sc_out sc_lv 32 signal 63 } 
	{ p_out53_ap_vld sc_out sc_logic 1 outvld 63 } 
	{ p_out54 sc_out sc_lv 32 signal 64 } 
	{ p_out54_ap_vld sc_out sc_logic 1 outvld 64 } 
	{ p_out55 sc_out sc_lv 32 signal 65 } 
	{ p_out55_ap_vld sc_out sc_logic 1 outvld 65 } 
	{ p_out56 sc_out sc_lv 32 signal 66 } 
	{ p_out56_ap_vld sc_out sc_logic 1 outvld 66 } 
	{ p_out57 sc_out sc_lv 32 signal 67 } 
	{ p_out57_ap_vld sc_out sc_logic 1 outvld 67 } 
	{ p_out58 sc_out sc_lv 32 signal 68 } 
	{ p_out58_ap_vld sc_out sc_logic 1 outvld 68 } 
	{ p_out59 sc_out sc_lv 32 signal 69 } 
	{ p_out59_ap_vld sc_out sc_logic 1 outvld 69 } 
	{ p_out60 sc_out sc_lv 32 signal 70 } 
	{ p_out60_ap_vld sc_out sc_logic 1 outvld 70 } 
	{ p_out61 sc_out sc_lv 32 signal 71 } 
	{ p_out61_ap_vld sc_out sc_logic 1 outvld 71 } 
	{ p_out62 sc_out sc_lv 32 signal 72 } 
	{ p_out62_ap_vld sc_out sc_logic 1 outvld 72 } 
	{ p_out63 sc_out sc_lv 32 signal 73 } 
	{ p_out63_ap_vld sc_out sc_logic 1 outvld 73 } 
	{ grp_fu_47528_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_47528_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_47528_p_opcode sc_out sc_lv 1 signal -1 } 
	{ grp_fu_47528_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_47528_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_47529_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_47529_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_47529_p_opcode sc_out sc_lv 1 signal -1 } 
	{ grp_fu_47529_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_47529_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_47530_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_47530_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_47530_p_opcode sc_out sc_lv 1 signal -1 } 
	{ grp_fu_47530_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_47530_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_47531_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_47531_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_47531_p_opcode sc_out sc_lv 2 signal -1 } 
	{ grp_fu_47531_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_47531_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_49878_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_49878_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_49878_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_49878_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_49889_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_49889_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_49889_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_49889_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_52808_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_52808_p_din1 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_52808_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_52808_p_ce sc_out sc_logic 1 signal -1 } 
	{ grp_fu_52813_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_52813_p_dout0 sc_in sc_lv 32 signal -1 } 
	{ grp_fu_52813_p_ce sc_out sc_logic 1 signal -1 } 
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
 	{ "name": "i_4", "direction": "in", "datatype": "sc_lv", "bitwidth":6, "type": "signal", "bundle":{"name": "i_4", "role": "default" }} , 
 	{ "name": "scores_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "scores", "role": "address0" }} , 
 	{ "name": "scores_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scores", "role": "ce0" }} , 
 	{ "name": "scores_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "scores", "role": "q0" }} , 
 	{ "name": "scores_1_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "scores_1", "role": "address0" }} , 
 	{ "name": "scores_1_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scores_1", "role": "ce0" }} , 
 	{ "name": "scores_1_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "scores_1", "role": "q0" }} , 
 	{ "name": "scores_2_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "scores_2", "role": "address0" }} , 
 	{ "name": "scores_2_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scores_2", "role": "ce0" }} , 
 	{ "name": "scores_2_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "scores_2", "role": "q0" }} , 
 	{ "name": "scores_3_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "scores_3", "role": "address0" }} , 
 	{ "name": "scores_3_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scores_3", "role": "ce0" }} , 
 	{ "name": "scores_3_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "scores_3", "role": "q0" }} , 
 	{ "name": "scores_4_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "scores_4", "role": "address0" }} , 
 	{ "name": "scores_4_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scores_4", "role": "ce0" }} , 
 	{ "name": "scores_4_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "scores_4", "role": "q0" }} , 
 	{ "name": "scores_5_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "scores_5", "role": "address0" }} , 
 	{ "name": "scores_5_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scores_5", "role": "ce0" }} , 
 	{ "name": "scores_5_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "scores_5", "role": "q0" }} , 
 	{ "name": "scores_6_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "scores_6", "role": "address0" }} , 
 	{ "name": "scores_6_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scores_6", "role": "ce0" }} , 
 	{ "name": "scores_6_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "scores_6", "role": "q0" }} , 
 	{ "name": "scores_7_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "scores_7", "role": "address0" }} , 
 	{ "name": "scores_7_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "scores_7", "role": "ce0" }} , 
 	{ "name": "scores_7_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "scores_7", "role": "q0" }} , 
 	{ "name": "m_new", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "m_new", "role": "default" }} , 
 	{ "name": "p_out", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out", "role": "default" }} , 
 	{ "name": "p_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out", "role": "ap_vld" }} , 
 	{ "name": "p_out1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out1", "role": "default" }} , 
 	{ "name": "p_out1_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out1", "role": "ap_vld" }} , 
 	{ "name": "p_out2", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out2", "role": "default" }} , 
 	{ "name": "p_out2_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out2", "role": "ap_vld" }} , 
 	{ "name": "p_out3", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out3", "role": "default" }} , 
 	{ "name": "p_out3_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out3", "role": "ap_vld" }} , 
 	{ "name": "p_out4", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out4", "role": "default" }} , 
 	{ "name": "p_out4_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out4", "role": "ap_vld" }} , 
 	{ "name": "p_out5", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out5", "role": "default" }} , 
 	{ "name": "p_out5_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out5", "role": "ap_vld" }} , 
 	{ "name": "p_out6", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out6", "role": "default" }} , 
 	{ "name": "p_out6_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out6", "role": "ap_vld" }} , 
 	{ "name": "p_out7", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out7", "role": "default" }} , 
 	{ "name": "p_out7_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out7", "role": "ap_vld" }} , 
 	{ "name": "p_out8", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out8", "role": "default" }} , 
 	{ "name": "p_out8_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out8", "role": "ap_vld" }} , 
 	{ "name": "p_out9", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out9", "role": "default" }} , 
 	{ "name": "p_out9_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out9", "role": "ap_vld" }} , 
 	{ "name": "p_out10", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out10", "role": "default" }} , 
 	{ "name": "p_out10_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out10", "role": "ap_vld" }} , 
 	{ "name": "p_out11", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out11", "role": "default" }} , 
 	{ "name": "p_out11_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out11", "role": "ap_vld" }} , 
 	{ "name": "p_out12", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out12", "role": "default" }} , 
 	{ "name": "p_out12_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out12", "role": "ap_vld" }} , 
 	{ "name": "p_out13", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out13", "role": "default" }} , 
 	{ "name": "p_out13_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out13", "role": "ap_vld" }} , 
 	{ "name": "p_out14", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out14", "role": "default" }} , 
 	{ "name": "p_out14_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out14", "role": "ap_vld" }} , 
 	{ "name": "p_out15", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out15", "role": "default" }} , 
 	{ "name": "p_out15_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out15", "role": "ap_vld" }} , 
 	{ "name": "p_out16", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out16", "role": "default" }} , 
 	{ "name": "p_out16_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out16", "role": "ap_vld" }} , 
 	{ "name": "p_out17", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out17", "role": "default" }} , 
 	{ "name": "p_out17_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out17", "role": "ap_vld" }} , 
 	{ "name": "p_out18", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out18", "role": "default" }} , 
 	{ "name": "p_out18_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out18", "role": "ap_vld" }} , 
 	{ "name": "p_out19", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out19", "role": "default" }} , 
 	{ "name": "p_out19_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out19", "role": "ap_vld" }} , 
 	{ "name": "p_out20", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out20", "role": "default" }} , 
 	{ "name": "p_out20_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out20", "role": "ap_vld" }} , 
 	{ "name": "p_out21", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out21", "role": "default" }} , 
 	{ "name": "p_out21_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out21", "role": "ap_vld" }} , 
 	{ "name": "p_out22", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out22", "role": "default" }} , 
 	{ "name": "p_out22_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out22", "role": "ap_vld" }} , 
 	{ "name": "p_out23", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out23", "role": "default" }} , 
 	{ "name": "p_out23_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out23", "role": "ap_vld" }} , 
 	{ "name": "p_out24", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out24", "role": "default" }} , 
 	{ "name": "p_out24_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out24", "role": "ap_vld" }} , 
 	{ "name": "p_out25", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out25", "role": "default" }} , 
 	{ "name": "p_out25_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out25", "role": "ap_vld" }} , 
 	{ "name": "p_out26", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out26", "role": "default" }} , 
 	{ "name": "p_out26_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out26", "role": "ap_vld" }} , 
 	{ "name": "p_out27", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out27", "role": "default" }} , 
 	{ "name": "p_out27_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out27", "role": "ap_vld" }} , 
 	{ "name": "p_out28", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out28", "role": "default" }} , 
 	{ "name": "p_out28_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out28", "role": "ap_vld" }} , 
 	{ "name": "p_out29", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out29", "role": "default" }} , 
 	{ "name": "p_out29_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out29", "role": "ap_vld" }} , 
 	{ "name": "p_out30", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out30", "role": "default" }} , 
 	{ "name": "p_out30_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out30", "role": "ap_vld" }} , 
 	{ "name": "p_out31", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out31", "role": "default" }} , 
 	{ "name": "p_out31_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out31", "role": "ap_vld" }} , 
 	{ "name": "p_out32", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out32", "role": "default" }} , 
 	{ "name": "p_out32_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out32", "role": "ap_vld" }} , 
 	{ "name": "p_out33", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out33", "role": "default" }} , 
 	{ "name": "p_out33_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out33", "role": "ap_vld" }} , 
 	{ "name": "p_out34", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out34", "role": "default" }} , 
 	{ "name": "p_out34_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out34", "role": "ap_vld" }} , 
 	{ "name": "p_out35", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out35", "role": "default" }} , 
 	{ "name": "p_out35_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out35", "role": "ap_vld" }} , 
 	{ "name": "p_out36", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out36", "role": "default" }} , 
 	{ "name": "p_out36_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out36", "role": "ap_vld" }} , 
 	{ "name": "p_out37", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out37", "role": "default" }} , 
 	{ "name": "p_out37_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out37", "role": "ap_vld" }} , 
 	{ "name": "p_out38", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out38", "role": "default" }} , 
 	{ "name": "p_out38_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out38", "role": "ap_vld" }} , 
 	{ "name": "p_out39", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out39", "role": "default" }} , 
 	{ "name": "p_out39_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out39", "role": "ap_vld" }} , 
 	{ "name": "p_out40", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out40", "role": "default" }} , 
 	{ "name": "p_out40_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out40", "role": "ap_vld" }} , 
 	{ "name": "p_out41", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out41", "role": "default" }} , 
 	{ "name": "p_out41_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out41", "role": "ap_vld" }} , 
 	{ "name": "p_out42", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out42", "role": "default" }} , 
 	{ "name": "p_out42_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out42", "role": "ap_vld" }} , 
 	{ "name": "p_out43", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out43", "role": "default" }} , 
 	{ "name": "p_out43_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out43", "role": "ap_vld" }} , 
 	{ "name": "p_out44", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out44", "role": "default" }} , 
 	{ "name": "p_out44_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out44", "role": "ap_vld" }} , 
 	{ "name": "p_out45", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out45", "role": "default" }} , 
 	{ "name": "p_out45_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out45", "role": "ap_vld" }} , 
 	{ "name": "p_out46", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out46", "role": "default" }} , 
 	{ "name": "p_out46_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out46", "role": "ap_vld" }} , 
 	{ "name": "p_out47", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out47", "role": "default" }} , 
 	{ "name": "p_out47_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out47", "role": "ap_vld" }} , 
 	{ "name": "p_out48", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out48", "role": "default" }} , 
 	{ "name": "p_out48_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out48", "role": "ap_vld" }} , 
 	{ "name": "p_out49", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out49", "role": "default" }} , 
 	{ "name": "p_out49_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out49", "role": "ap_vld" }} , 
 	{ "name": "p_out50", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out50", "role": "default" }} , 
 	{ "name": "p_out50_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out50", "role": "ap_vld" }} , 
 	{ "name": "p_out51", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out51", "role": "default" }} , 
 	{ "name": "p_out51_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out51", "role": "ap_vld" }} , 
 	{ "name": "p_out52", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out52", "role": "default" }} , 
 	{ "name": "p_out52_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out52", "role": "ap_vld" }} , 
 	{ "name": "p_out53", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out53", "role": "default" }} , 
 	{ "name": "p_out53_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out53", "role": "ap_vld" }} , 
 	{ "name": "p_out54", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out54", "role": "default" }} , 
 	{ "name": "p_out54_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out54", "role": "ap_vld" }} , 
 	{ "name": "p_out55", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out55", "role": "default" }} , 
 	{ "name": "p_out55_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out55", "role": "ap_vld" }} , 
 	{ "name": "p_out56", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out56", "role": "default" }} , 
 	{ "name": "p_out56_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out56", "role": "ap_vld" }} , 
 	{ "name": "p_out57", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out57", "role": "default" }} , 
 	{ "name": "p_out57_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out57", "role": "ap_vld" }} , 
 	{ "name": "p_out58", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out58", "role": "default" }} , 
 	{ "name": "p_out58_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out58", "role": "ap_vld" }} , 
 	{ "name": "p_out59", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out59", "role": "default" }} , 
 	{ "name": "p_out59_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out59", "role": "ap_vld" }} , 
 	{ "name": "p_out60", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out60", "role": "default" }} , 
 	{ "name": "p_out60_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out60", "role": "ap_vld" }} , 
 	{ "name": "p_out61", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out61", "role": "default" }} , 
 	{ "name": "p_out61_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out61", "role": "ap_vld" }} , 
 	{ "name": "p_out62", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out62", "role": "default" }} , 
 	{ "name": "p_out62_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out62", "role": "ap_vld" }} , 
 	{ "name": "p_out63", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "p_out63", "role": "default" }} , 
 	{ "name": "p_out63_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "p_out63", "role": "ap_vld" }} , 
 	{ "name": "grp_fu_47528_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_47528_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_47528_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_47528_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_47528_p_opcode", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_47528_p_opcode", "role": "default" }} , 
 	{ "name": "grp_fu_47528_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_47528_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_47528_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_47528_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_47529_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_47529_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_47529_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_47529_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_47529_p_opcode", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_47529_p_opcode", "role": "default" }} , 
 	{ "name": "grp_fu_47529_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_47529_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_47529_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_47529_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_47530_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_47530_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_47530_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_47530_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_47530_p_opcode", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_47530_p_opcode", "role": "default" }} , 
 	{ "name": "grp_fu_47530_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_47530_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_47530_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_47530_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_47531_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_47531_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_47531_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_47531_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_47531_p_opcode", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "grp_fu_47531_p_opcode", "role": "default" }} , 
 	{ "name": "grp_fu_47531_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_47531_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_47531_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_47531_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_49878_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_49878_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_49878_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_49878_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_49878_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_49878_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_49878_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_49878_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_49889_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_49889_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_49889_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_49889_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_49889_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_49889_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_49889_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_49889_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_52808_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_52808_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_52808_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_52808_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_52808_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_52808_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_52808_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_52808_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_52813_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_52813_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_52813_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_52813_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_52813_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_52813_p_ce", "role": "default" }} , 
 	{ "name": "grp_fu_52816_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_52816_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_52816_p_din1", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_52816_p_din1", "role": "default" }} , 
 	{ "name": "grp_fu_52816_p_opcode", "direction": "out", "datatype": "sc_lv", "bitwidth":5, "type": "signal", "bundle":{"name": "grp_fu_52816_p_opcode", "role": "default" }} , 
 	{ "name": "grp_fu_52816_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_52816_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_52816_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_52816_p_ce", "role": "default" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1", "2", "3", "4", "5"],
		"CDFG" : "attention_int8_kernel_Pipeline_VITIS_LOOP_168_14",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "124", "EstimateLatencyMax" : "124",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"IsBlackBox" : "0",
		"Port" : [
			{"Name" : "i_4", "Type" : "None", "Direction" : "I"},
			{"Name" : "scores", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "scores_1", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "scores_2", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "scores_3", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "scores_4", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "scores_5", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "scores_6", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "scores_7", "Type" : "Memory", "Direction" : "I"},
			{"Name" : "m_new", "Type" : "None", "Direction" : "I"},
			{"Name" : "p_out", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out1", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out2", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out3", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out4", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out5", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out6", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out7", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out8", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out9", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out10", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out11", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out12", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out13", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out14", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out15", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out16", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out17", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out18", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out19", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out20", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out21", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out22", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out23", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out24", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out25", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out26", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out27", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out28", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out29", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out30", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out31", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out32", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out33", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out34", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out35", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out36", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out37", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out38", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out39", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out40", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out41", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out42", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out43", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out44", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out45", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out46", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out47", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out48", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out49", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out50", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out51", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out52", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out53", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out54", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out55", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out56", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out57", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out58", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out59", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out60", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out61", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out62", "Type" : "Vld", "Direction" : "O"},
			{"Name" : "p_out63", "Type" : "Vld", "Direction" : "O"}],
		"Loop" : [
			{"Name" : "VITIS_LOOP_168_14", "PipelineType" : "UPC",
				"LoopDec" : {"FSMBitwidth" : "1", "FirstState" : "ap_ST_fsm_pp0_stage0", "FirstStateIter" : "ap_enable_reg_pp0_iter0", "FirstStateBlock" : "ap_block_pp0_stage0_subdone", "LastState" : "ap_ST_fsm_pp0_stage0", "LastStateIter" : "ap_enable_reg_pp0_iter59", "LastStateBlock" : "ap_block_pp0_stage0_subdone", "QuitState" : "ap_ST_fsm_pp0_stage0", "QuitStateIter" : "ap_enable_reg_pp0_iter59", "QuitStateBlock" : "ap_block_pp0_stage0_subdone", "OneDepthLoop" : "0", "has_ap_ctrl" : "1", "has_continue" : "0"}}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.fcmp_32ns_32ns_1_2_no_dsp_1_U1195", "Parent" : "0"},
	{"ID" : "2", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sparsemux_17_3_32_1_1_U1196", "Parent" : "0"},
	{"ID" : "3", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sparsemux_131_7_32_1_1_U1197", "Parent" : "0"},
	{"ID" : "4", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.sparsemux_131_7_32_1_1_U1198", "Parent" : "0"},
	{"ID" : "5", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.flow_control_loop_pipe_sequential_init_U", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	attention_int8_kernel_Pipeline_VITIS_LOOP_168_14 {
		i_4 {Type I LastRead 0 FirstWrite -1}
		scores {Type I LastRead 0 FirstWrite -1}
		scores_1 {Type I LastRead 0 FirstWrite -1}
		scores_2 {Type I LastRead 0 FirstWrite -1}
		scores_3 {Type I LastRead 0 FirstWrite -1}
		scores_4 {Type I LastRead 0 FirstWrite -1}
		scores_5 {Type I LastRead 0 FirstWrite -1}
		scores_6 {Type I LastRead 0 FirstWrite -1}
		scores_7 {Type I LastRead 0 FirstWrite -1}
		m_new {Type I LastRead 0 FirstWrite -1}
		p_out {Type O LastRead -1 FirstWrite 58}
		p_out1 {Type O LastRead -1 FirstWrite 58}
		p_out2 {Type O LastRead -1 FirstWrite 58}
		p_out3 {Type O LastRead -1 FirstWrite 58}
		p_out4 {Type O LastRead -1 FirstWrite 58}
		p_out5 {Type O LastRead -1 FirstWrite 58}
		p_out6 {Type O LastRead -1 FirstWrite 58}
		p_out7 {Type O LastRead -1 FirstWrite 58}
		p_out8 {Type O LastRead -1 FirstWrite 58}
		p_out9 {Type O LastRead -1 FirstWrite 58}
		p_out10 {Type O LastRead -1 FirstWrite 58}
		p_out11 {Type O LastRead -1 FirstWrite 58}
		p_out12 {Type O LastRead -1 FirstWrite 58}
		p_out13 {Type O LastRead -1 FirstWrite 58}
		p_out14 {Type O LastRead -1 FirstWrite 58}
		p_out15 {Type O LastRead -1 FirstWrite 58}
		p_out16 {Type O LastRead -1 FirstWrite 58}
		p_out17 {Type O LastRead -1 FirstWrite 58}
		p_out18 {Type O LastRead -1 FirstWrite 58}
		p_out19 {Type O LastRead -1 FirstWrite 58}
		p_out20 {Type O LastRead -1 FirstWrite 58}
		p_out21 {Type O LastRead -1 FirstWrite 58}
		p_out22 {Type O LastRead -1 FirstWrite 58}
		p_out23 {Type O LastRead -1 FirstWrite 58}
		p_out24 {Type O LastRead -1 FirstWrite 58}
		p_out25 {Type O LastRead -1 FirstWrite 58}
		p_out26 {Type O LastRead -1 FirstWrite 58}
		p_out27 {Type O LastRead -1 FirstWrite 58}
		p_out28 {Type O LastRead -1 FirstWrite 58}
		p_out29 {Type O LastRead -1 FirstWrite 58}
		p_out30 {Type O LastRead -1 FirstWrite 58}
		p_out31 {Type O LastRead -1 FirstWrite 58}
		p_out32 {Type O LastRead -1 FirstWrite 58}
		p_out33 {Type O LastRead -1 FirstWrite 58}
		p_out34 {Type O LastRead -1 FirstWrite 58}
		p_out35 {Type O LastRead -1 FirstWrite 58}
		p_out36 {Type O LastRead -1 FirstWrite 58}
		p_out37 {Type O LastRead -1 FirstWrite 58}
		p_out38 {Type O LastRead -1 FirstWrite 58}
		p_out39 {Type O LastRead -1 FirstWrite 58}
		p_out40 {Type O LastRead -1 FirstWrite 58}
		p_out41 {Type O LastRead -1 FirstWrite 58}
		p_out42 {Type O LastRead -1 FirstWrite 58}
		p_out43 {Type O LastRead -1 FirstWrite 58}
		p_out44 {Type O LastRead -1 FirstWrite 58}
		p_out45 {Type O LastRead -1 FirstWrite 58}
		p_out46 {Type O LastRead -1 FirstWrite 58}
		p_out47 {Type O LastRead -1 FirstWrite 58}
		p_out48 {Type O LastRead -1 FirstWrite 58}
		p_out49 {Type O LastRead -1 FirstWrite 58}
		p_out50 {Type O LastRead -1 FirstWrite 58}
		p_out51 {Type O LastRead -1 FirstWrite 58}
		p_out52 {Type O LastRead -1 FirstWrite 58}
		p_out53 {Type O LastRead -1 FirstWrite 58}
		p_out54 {Type O LastRead -1 FirstWrite 58}
		p_out55 {Type O LastRead -1 FirstWrite 58}
		p_out56 {Type O LastRead -1 FirstWrite 58}
		p_out57 {Type O LastRead -1 FirstWrite 58}
		p_out58 {Type O LastRead -1 FirstWrite 58}
		p_out59 {Type O LastRead -1 FirstWrite 58}
		p_out60 {Type O LastRead -1 FirstWrite 58}
		p_out61 {Type O LastRead -1 FirstWrite 58}
		p_out62 {Type O LastRead -1 FirstWrite 58}
		p_out63 {Type O LastRead -1 FirstWrite 58}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "124", "Max" : "124"}
	, {"Name" : "Interval", "Min" : "124", "Max" : "124"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	i_4 { ap_none {  { i_4 in_data 0 6 } } }
	scores { ap_memory {  { scores_address0 mem_address 1 9 }  { scores_ce0 mem_ce 1 1 }  { scores_q0 in_data 0 32 } } }
	scores_1 { ap_memory {  { scores_1_address0 mem_address 1 9 }  { scores_1_ce0 mem_ce 1 1 }  { scores_1_q0 in_data 0 32 } } }
	scores_2 { ap_memory {  { scores_2_address0 mem_address 1 9 }  { scores_2_ce0 mem_ce 1 1 }  { scores_2_q0 in_data 0 32 } } }
	scores_3 { ap_memory {  { scores_3_address0 mem_address 1 9 }  { scores_3_ce0 mem_ce 1 1 }  { scores_3_q0 in_data 0 32 } } }
	scores_4 { ap_memory {  { scores_4_address0 mem_address 1 9 }  { scores_4_ce0 mem_ce 1 1 }  { scores_4_q0 in_data 0 32 } } }
	scores_5 { ap_memory {  { scores_5_address0 mem_address 1 9 }  { scores_5_ce0 mem_ce 1 1 }  { scores_5_q0 in_data 0 32 } } }
	scores_6 { ap_memory {  { scores_6_address0 mem_address 1 9 }  { scores_6_ce0 mem_ce 1 1 }  { scores_6_q0 in_data 0 32 } } }
	scores_7 { ap_memory {  { scores_7_address0 mem_address 1 9 }  { scores_7_ce0 mem_ce 1 1 }  { scores_7_q0 in_data 0 32 } } }
	m_new { ap_none {  { m_new in_data 0 32 } } }
	p_out { ap_vld {  { p_out out_data 1 32 }  { p_out_ap_vld out_vld 1 1 } } }
	p_out1 { ap_vld {  { p_out1 out_data 1 32 }  { p_out1_ap_vld out_vld 1 1 } } }
	p_out2 { ap_vld {  { p_out2 out_data 1 32 }  { p_out2_ap_vld out_vld 1 1 } } }
	p_out3 { ap_vld {  { p_out3 out_data 1 32 }  { p_out3_ap_vld out_vld 1 1 } } }
	p_out4 { ap_vld {  { p_out4 out_data 1 32 }  { p_out4_ap_vld out_vld 1 1 } } }
	p_out5 { ap_vld {  { p_out5 out_data 1 32 }  { p_out5_ap_vld out_vld 1 1 } } }
	p_out6 { ap_vld {  { p_out6 out_data 1 32 }  { p_out6_ap_vld out_vld 1 1 } } }
	p_out7 { ap_vld {  { p_out7 out_data 1 32 }  { p_out7_ap_vld out_vld 1 1 } } }
	p_out8 { ap_vld {  { p_out8 out_data 1 32 }  { p_out8_ap_vld out_vld 1 1 } } }
	p_out9 { ap_vld {  { p_out9 out_data 1 32 }  { p_out9_ap_vld out_vld 1 1 } } }
	p_out10 { ap_vld {  { p_out10 out_data 1 32 }  { p_out10_ap_vld out_vld 1 1 } } }
	p_out11 { ap_vld {  { p_out11 out_data 1 32 }  { p_out11_ap_vld out_vld 1 1 } } }
	p_out12 { ap_vld {  { p_out12 out_data 1 32 }  { p_out12_ap_vld out_vld 1 1 } } }
	p_out13 { ap_vld {  { p_out13 out_data 1 32 }  { p_out13_ap_vld out_vld 1 1 } } }
	p_out14 { ap_vld {  { p_out14 out_data 1 32 }  { p_out14_ap_vld out_vld 1 1 } } }
	p_out15 { ap_vld {  { p_out15 out_data 1 32 }  { p_out15_ap_vld out_vld 1 1 } } }
	p_out16 { ap_vld {  { p_out16 out_data 1 32 }  { p_out16_ap_vld out_vld 1 1 } } }
	p_out17 { ap_vld {  { p_out17 out_data 1 32 }  { p_out17_ap_vld out_vld 1 1 } } }
	p_out18 { ap_vld {  { p_out18 out_data 1 32 }  { p_out18_ap_vld out_vld 1 1 } } }
	p_out19 { ap_vld {  { p_out19 out_data 1 32 }  { p_out19_ap_vld out_vld 1 1 } } }
	p_out20 { ap_vld {  { p_out20 out_data 1 32 }  { p_out20_ap_vld out_vld 1 1 } } }
	p_out21 { ap_vld {  { p_out21 out_data 1 32 }  { p_out21_ap_vld out_vld 1 1 } } }
	p_out22 { ap_vld {  { p_out22 out_data 1 32 }  { p_out22_ap_vld out_vld 1 1 } } }
	p_out23 { ap_vld {  { p_out23 out_data 1 32 }  { p_out23_ap_vld out_vld 1 1 } } }
	p_out24 { ap_vld {  { p_out24 out_data 1 32 }  { p_out24_ap_vld out_vld 1 1 } } }
	p_out25 { ap_vld {  { p_out25 out_data 1 32 }  { p_out25_ap_vld out_vld 1 1 } } }
	p_out26 { ap_vld {  { p_out26 out_data 1 32 }  { p_out26_ap_vld out_vld 1 1 } } }
	p_out27 { ap_vld {  { p_out27 out_data 1 32 }  { p_out27_ap_vld out_vld 1 1 } } }
	p_out28 { ap_vld {  { p_out28 out_data 1 32 }  { p_out28_ap_vld out_vld 1 1 } } }
	p_out29 { ap_vld {  { p_out29 out_data 1 32 }  { p_out29_ap_vld out_vld 1 1 } } }
	p_out30 { ap_vld {  { p_out30 out_data 1 32 }  { p_out30_ap_vld out_vld 1 1 } } }
	p_out31 { ap_vld {  { p_out31 out_data 1 32 }  { p_out31_ap_vld out_vld 1 1 } } }
	p_out32 { ap_vld {  { p_out32 out_data 1 32 }  { p_out32_ap_vld out_vld 1 1 } } }
	p_out33 { ap_vld {  { p_out33 out_data 1 32 }  { p_out33_ap_vld out_vld 1 1 } } }
	p_out34 { ap_vld {  { p_out34 out_data 1 32 }  { p_out34_ap_vld out_vld 1 1 } } }
	p_out35 { ap_vld {  { p_out35 out_data 1 32 }  { p_out35_ap_vld out_vld 1 1 } } }
	p_out36 { ap_vld {  { p_out36 out_data 1 32 }  { p_out36_ap_vld out_vld 1 1 } } }
	p_out37 { ap_vld {  { p_out37 out_data 1 32 }  { p_out37_ap_vld out_vld 1 1 } } }
	p_out38 { ap_vld {  { p_out38 out_data 1 32 }  { p_out38_ap_vld out_vld 1 1 } } }
	p_out39 { ap_vld {  { p_out39 out_data 1 32 }  { p_out39_ap_vld out_vld 1 1 } } }
	p_out40 { ap_vld {  { p_out40 out_data 1 32 }  { p_out40_ap_vld out_vld 1 1 } } }
	p_out41 { ap_vld {  { p_out41 out_data 1 32 }  { p_out41_ap_vld out_vld 1 1 } } }
	p_out42 { ap_vld {  { p_out42 out_data 1 32 }  { p_out42_ap_vld out_vld 1 1 } } }
	p_out43 { ap_vld {  { p_out43 out_data 1 32 }  { p_out43_ap_vld out_vld 1 1 } } }
	p_out44 { ap_vld {  { p_out44 out_data 1 32 }  { p_out44_ap_vld out_vld 1 1 } } }
	p_out45 { ap_vld {  { p_out45 out_data 1 32 }  { p_out45_ap_vld out_vld 1 1 } } }
	p_out46 { ap_vld {  { p_out46 out_data 1 32 }  { p_out46_ap_vld out_vld 1 1 } } }
	p_out47 { ap_vld {  { p_out47 out_data 1 32 }  { p_out47_ap_vld out_vld 1 1 } } }
	p_out48 { ap_vld {  { p_out48 out_data 1 32 }  { p_out48_ap_vld out_vld 1 1 } } }
	p_out49 { ap_vld {  { p_out49 out_data 1 32 }  { p_out49_ap_vld out_vld 1 1 } } }
	p_out50 { ap_vld {  { p_out50 out_data 1 32 }  { p_out50_ap_vld out_vld 1 1 } } }
	p_out51 { ap_vld {  { p_out51 out_data 1 32 }  { p_out51_ap_vld out_vld 1 1 } } }
	p_out52 { ap_vld {  { p_out52 out_data 1 32 }  { p_out52_ap_vld out_vld 1 1 } } }
	p_out53 { ap_vld {  { p_out53 out_data 1 32 }  { p_out53_ap_vld out_vld 1 1 } } }
	p_out54 { ap_vld {  { p_out54 out_data 1 32 }  { p_out54_ap_vld out_vld 1 1 } } }
	p_out55 { ap_vld {  { p_out55 out_data 1 32 }  { p_out55_ap_vld out_vld 1 1 } } }
	p_out56 { ap_vld {  { p_out56 out_data 1 32 }  { p_out56_ap_vld out_vld 1 1 } } }
	p_out57 { ap_vld {  { p_out57 out_data 1 32 }  { p_out57_ap_vld out_vld 1 1 } } }
	p_out58 { ap_vld {  { p_out58 out_data 1 32 }  { p_out58_ap_vld out_vld 1 1 } } }
	p_out59 { ap_vld {  { p_out59 out_data 1 32 }  { p_out59_ap_vld out_vld 1 1 } } }
	p_out60 { ap_vld {  { p_out60 out_data 1 32 }  { p_out60_ap_vld out_vld 1 1 } } }
	p_out61 { ap_vld {  { p_out61 out_data 1 32 }  { p_out61_ap_vld out_vld 1 1 } } }
	p_out62 { ap_vld {  { p_out62 out_data 1 32 }  { p_out62_ap_vld out_vld 1 1 } } }
	p_out63 { ap_vld {  { p_out63 out_data 1 32 }  { p_out63_ap_vld out_vld 1 1 } } }
}
