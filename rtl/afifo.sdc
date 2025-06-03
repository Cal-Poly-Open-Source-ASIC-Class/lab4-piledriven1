puts "\[INFO\]: Creating Clocks"
create_clock [get_ports clk_r] -name clk_r -period 73
set_propagated_clock clk_r
create_clock [get_ports clk_w] -name clk_w -period 61
set_propagated_clock clk_w

set_clock_groups -asynchronous -group [get_clocks {clk_r clk_w}]

puts "\[INFO\]: Setting Max Delay"

set read_period     [get_property -object_type clock [get_clocks {clk_r}] period]
set write_period    [get_property -object_type clock [get_clocks {clk_w}] period]
set min_period      [expr {min(${read_period}, ${write_period})}]

set_max_delay -from [get_pins g_wptr*df*/CLK] -to [get_pins g_wptr_sync*df*/D] $min_period
set_max_delay -from [get_pins g_rptr*df*/CLK] -to [get_pins g_rptr_sync*df*/D] $min_period
