# run_synth.tcl — HLS synthesis + utilization reporting for U280
#
# Produces reports/csynth.rpt with Fmax, DSP / BRAM / URAM utilization,
# latency in cycles, II, and per-loop analysis. Does NOT run full Vivado P&R
# (which would be needed for a bitstream); the csynth estimate is the
# standard reference point for FPGA-accelerator papers that don't push to
# hardware.
#
# Takes 5-15 min for the INT8 kernel at default parameters.

open_project -reset hls_project
set_top attention_int8_kernel
add_files src/attention_int8.cpp

open_solution -reset "solution_synth"
set_part xcu280-fsvh2892-2L-e
create_clock -period 3.33 -name default        ;# 300 MHz target

# Optimization directives
config_compile -pipeline_loops 64
config_export -format xo -output hls_project/attention_int8.xo

csynth_design

# Copy the key report out to a stable location.
set syn_rpt [glob -nocomplain hls_project/solution_synth/syn/report/*_csynth.rpt]
if { $syn_rpt ne "" } {
    file mkdir reports
    file copy -force $syn_rpt reports/csynth.rpt
    puts "Synthesis report copied to reports/csynth.rpt"
}

# Also emit a short one-liner for quick grepping.
set f [open reports/summary.txt w]
puts $f "Target: xcu280-fsvh2892-2L-e, 300 MHz target"
puts $f "See reports/csynth.rpt for DSP/BRAM/URAM utilization + Fmax."
close $f

exit
