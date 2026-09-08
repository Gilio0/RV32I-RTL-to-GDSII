# Basic RV32I clock constraint

create_clock -name clk -period 20.000 [get_ports clk]

set_clock_uncertainty 0.20 [get_clocks clk]
set_input_delay 0.00 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 0.00 -clock clk [all_outputs]

# Initial conservative limits; refine after synthesis reports.
set_max_fanout 16 [current_design]
set_max_transition 1.00 [current_design]
