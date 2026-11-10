current_design precision_lock_system_opt

create_clock -name core_clock -period 20.0 [get_ports clk]

set non_clock_inputs [all_inputs -no_clocks]

set_input_delay 2.0 -clock core_clock $non_clock_inputs
set_output_delay 2.0 -clock core_clock [all_outputs]
