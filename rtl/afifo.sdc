puts "\[INFO\]: Creating Clocks"
create_clock [get_ports clk_r] -name clk_r -period 10
set_propagated_clock clk_r
create_clock [get_ports clk_w] -name clk_w -period 20
set_propagated_clock clk_w

set_clock_groups -asynchronous -group [get_clocks {clk_r clk_w}]