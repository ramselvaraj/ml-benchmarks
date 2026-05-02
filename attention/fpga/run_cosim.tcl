#=============================================================================
# run_cosim.tcl — Vitis HLS C-sim and cosim driver for attention_int8_kernel
#
# Usage from /home/siyenga7/FPGA:
#     cd ~/FPGA
#     vitis_hls -f run_cosim.tcl
#
# This is a self-contained Tcl script (separate from your existing v++ config
# flow) because cosim is most reliable through the classic vitis_hls Tcl
# interface. It does NOT touch your existing hls_component/ directory; it
# creates a parallel hls_cosim_project/.
#=============================================================================

# ---- Clean project for repeatable runs ----
open_project -reset hls_cosim_project
set_top attention_int8_kernel

# ---- Source files ----
add_files attention_int8.cpp
add_files attention_top.h
add_files -tb tb_attention_int8.cpp

# ---- Solution / target / clock ----
open_solution -reset solution_cosim
set_part xc7a200t-sbg484-1
create_clock -period 10 -name default

# ---- C simulation (fast — validates testbench against C++) ----
puts "================================================================"
puts "  C SIMULATION                                                  "
puts "================================================================"
csim_design -clean -ldflags "-fno-lto -fno-use-linker-plugin" -argv "/home/siyenga7/FPGA/testvectors/int8"

# ---- Synthesize so cosim has RTL to drive ----
puts "================================================================"
puts "  SYNTHESIS                                                     "
puts "================================================================"
csynth_design

# ---- Co-simulation (slow — actually tests the Verilog) ----
puts "================================================================"
puts "  CO-SIMULATION (10-30 min — go get coffee)                     "
puts "================================================================"
cosim_design -ldflags "-fno-lto -fno-use-linker-plugin" -argv "/home/siyenga7/FPGA/testvectors/int8" -tool xsim -trace_level none

puts "================================================================"
puts "  DONE.                                                         "
puts "  Cosim report: hls_cosim_project/solution_cosim/sim/report/    "
puts "================================================================"

exit
