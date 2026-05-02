create_project prj -part xc7a200t-sbg484-1 -force
set_property target_language verilog [current_project]
set vivado_ver [version -short]
set COE_DIR "../../syn/verilog"
source "/home/siyenga7/FPGA/hls_cosim_project/solution_cosim/syn/verilog/attention_int8_kernel_sitofp_32ns_32_6_no_dsp_1_ip.tcl"
source "/home/siyenga7/FPGA/hls_cosim_project/solution_cosim/syn/verilog/attention_int8_kernel_faddfsub_32ns_32ns_32_7_full_dsp_1_ip.tcl"
source "/home/siyenga7/FPGA/hls_cosim_project/solution_cosim/syn/verilog/attention_int8_kernel_fmul_32ns_32ns_32_4_max_dsp_1_ip.tcl"
source "/home/siyenga7/FPGA/hls_cosim_project/solution_cosim/syn/verilog/attention_int8_kernel_fcmp_32ns_32ns_1_2_no_dsp_1_ip.tcl"
source "/home/siyenga7/FPGA/hls_cosim_project/solution_cosim/syn/verilog/attention_int8_kernel_fsub_32ns_32ns_32_7_full_dsp_1_ip.tcl"
source "/home/siyenga7/FPGA/hls_cosim_project/solution_cosim/syn/verilog/attention_int8_kernel_fadd_32ns_32ns_32_6_no_dsp_1_ip.tcl"
source "/home/siyenga7/FPGA/hls_cosim_project/solution_cosim/syn/verilog/attention_int8_kernel_fadd_32ns_32ns_32_7_full_dsp_1_ip.tcl"
source "/home/siyenga7/FPGA/hls_cosim_project/solution_cosim/syn/verilog/attention_int8_kernel_sptohp_32ns_16_2_no_dsp_1_ip.tcl"
source "/home/siyenga7/FPGA/hls_cosim_project/solution_cosim/syn/verilog/attention_int8_kernel_sitofp_32s_32_6_no_dsp_1_ip.tcl"
source "/home/siyenga7/FPGA/hls_cosim_project/solution_cosim/syn/verilog/attention_int8_kernel_fdiv_32ns_32ns_32_16_no_dsp_1_ip.tcl"
