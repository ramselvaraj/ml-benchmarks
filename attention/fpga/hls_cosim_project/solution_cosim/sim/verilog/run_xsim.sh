
/packages/apps/fpga/Vivado/2022.1/bin/xelab xil_defaultlib.apatb_attention_int8_kernel_top glbl -Oenable_linking_all_libraries  -prj attention_int8_kernel.prj -L smartconnect_v1_0 -L axi_protocol_checker_v1_1_12 -L axi_protocol_checker_v1_1_13 -L axis_protocol_checker_v1_1_11 -L axis_protocol_checker_v1_1_12 -L xil_defaultlib -L unisims_ver -L xpm  -L floating_point_v7_0_20 -L floating_point_v7_1_14 --lib "ieee_proposed=./ieee_proposed" -s attention_int8_kernel 
/packages/apps/fpga/Vivado/2022.1/bin/xsim --noieeewarnings attention_int8_kernel -tclbatch attention_int8_kernel.tcl 

