# Clock constraint for SVM FPGA benchmark
# 10 ns period = 100 MHz

create_clock -period 10.000 -name clk [get_ports clk]


# Optional output load for more realistic power/timing estimation

set_load 5.0 [all_outputs]


# Optional input/output delays
# Uncomment only if you are connecting this design to real external pins.

# set_input_delay  2.000 -clock clk [all_inputs]
# set_output_delay 2.000 -clock clk [all_outputs]
