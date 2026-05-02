# run_cosim.tcl — Vitis HLS RTL cosim
#
# Generates RTL from the C++, runs the testbench through a cycle-accurate
# SystemC simulator, and reports the achieved cycle count + equivalence.
# This is where the "real" FPGA latency number comes from.
#
# Takes 10-30 min at SEQ_LEN=1024. For a quick correctness check, temporarily
# reduce SEQ_LEN to 256 in attention_top.h.

open_project -reset hls_project
set_top attention_int8_kernel
add_files         src/attention_int8.cpp
add_files -tb     tb/tb_attention_int8.cpp

open_solution -reset "solution_cosim"
set_part xcu280-fsvh2892-2L-e
create_clock -period 3.33 -name default

csynth_design
cosim_design -argv "testvectors/int8" -trace_level all -tool xsim

# Write a machine-readable summary
set rpt_file [glob -nocomplain hls_project/solution_cosim/sim/report/*_cosim.rpt]
if { $rpt_file ne "" } {
    file copy -force $rpt_file reports/cosim.rpt
    puts "Cosim report copied to reports/cosim.rpt"
}
exit
