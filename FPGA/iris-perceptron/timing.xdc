# 1. Target Clock Frequency (12.0 ns / 83.33 MHz)
# This gives your internal 5-way addition enough time to finish, 
# resulting in a positive WNS and a realistic max speed.
create_clock -period 10.000 -name clk [get_ports clk]

# 2. Realistic Output Capacitance (5 pF)
# DO NOT REMOVE THIS. This is strictly required to get an accurate 
# internal Core Power reading and avoid the 52-Watt warning.
set_load 5.0 [all_outputs]