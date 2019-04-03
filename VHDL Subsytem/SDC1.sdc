create_clock -name i_clk -period 20 [get_ports {i_clk}]
create_clock -name i_clk50mhz -period 20 [get_ports {i_clk50mhz}]
derive_pll_clocks
derive_clock_uncertainty