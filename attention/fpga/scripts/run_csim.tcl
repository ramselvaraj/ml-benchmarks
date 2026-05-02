# run_csim.tcl — Vitis HLS C-simulation driver
#
# Compiles the kernel + testbench as plain C++ (no hardware generation) and
# runs the testbench. Fast way to validate numerical correctness before
# committing time to cosim/synthesis.
#
# Invoke from the fpga/ directory:
#     vitis_hls -f scripts/run_csim.tcl

open_project -reset hls_project
set_top attention_int8_kernel
add_files         src/attention_int8.cpp
add_files -tb     tb/tb_attention_int8.cpp

open_solution -reset "solution_csim"
set_part xcu280-fsvh2892-2L-e
create_clock -period 3.33 -name default       ;# 300 MHz target, as in README

csim_design -clean -argv "testvectors/int8"
# Exit with the C-sim's own return code so shell scripts can react.
exit [llength [glob -nocomplain csim.log]]
