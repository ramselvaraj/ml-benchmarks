set ModuleHierarchy {[{
"Name" : "attention_int8_kernel","ID" : "0","Type" : "sequential",
"SubLoops" : [
	{"Name" : "VITIS_LOOP_81_1_VITIS_LOOP_89_2","ID" : "1","Type" : "no",
	"SubInsts" : [
	{"Name" : "grp_attention_int8_kernel_Pipeline_VITIS_LOOP_101_3_VITIS_LOOP_102_4_fu_50797","ID" : "2","Type" : "sequential",
			"SubLoops" : [
			{"Name" : "VITIS_LOOP_101_3_VITIS_LOOP_102_4","ID" : "3","Type" : "pipeline"},]},
	{"Name" : "grp_attention_int8_kernel_Pipeline_VITIS_LOOP_108_5_fu_50932","ID" : "4","Type" : "sequential",
			"SubLoops" : [
			{"Name" : "VITIS_LOOP_108_5","ID" : "5","Type" : "pipeline"},]},
	{"Name" : "grp_attention_int8_kernel_Pipeline_VITIS_LOOP_193_18_VITIS_LOOP_195_19_fu_50944","ID" : "6","Type" : "sequential",
			"SubLoops" : [
			{"Name" : "VITIS_LOOP_193_18_VITIS_LOOP_195_19","ID" : "7","Type" : "pipeline"},]},],
	"SubLoops" : [
	{"Name" : "VITIS_LOOP_118_7","ID" : "8","Type" : "no",
		"SubInsts" : [
		{"Name" : "grp_attention_int8_kernel_Pipeline_VITIS_LOOP_130_8_VITIS_LOOP_131_9_fu_51087","ID" : "9","Type" : "sequential",
				"SubLoops" : [
				{"Name" : "VITIS_LOOP_130_8_VITIS_LOOP_131_9","ID" : "10","Type" : "pipeline"},]},],
		"SubLoops" : [
		{"Name" : "VITIS_LOOP_144_10","ID" : "11","Type" : "no",
			"SubInsts" : [
			{"Name" : "grp_attention_int8_kernel_Pipeline_VITIS_LOOP_146_11_fu_51737","ID" : "12","Type" : "sequential",
					"SubLoops" : [
					{"Name" : "VITIS_LOOP_146_11","ID" : "13","Type" : "pipeline"},]},]},
		{"Name" : "VITIS_LOOP_161_13","ID" : "14","Type" : "no",
			"SubInsts" : [
			{"Name" : "grp_attention_int8_kernel_Pipeline_VITIS_LOOP_168_14_fu_52139","ID" : "15","Type" : "sequential",
					"SubLoops" : [
					{"Name" : "VITIS_LOOP_168_14","ID" : "16","Type" : "pipeline"},]},
			{"Name" : "grp_attention_int8_kernel_Pipeline_VITIS_LOOP_180_16_fu_52217","ID" : "17","Type" : "sequential",
					"SubLoops" : [
					{"Name" : "VITIS_LOOP_180_16","ID" : "18","Type" : "pipeline"},]},]},]},]},]
}]}