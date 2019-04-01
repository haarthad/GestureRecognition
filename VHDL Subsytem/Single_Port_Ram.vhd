--Single port ram vhdl provided by intel/altera at https://www.intel.com/content/www/us/en/programmable/support/support-resources/design-examples/design-software/vhdl/vhd-single-port-ram.html
--modified for this project
library ieee;
use ieee.std_logic_1164.all;

entity single_port_ram is
	port
	(
		data	: in std_logic_vector(7 downto 0);
		addr	: in natural range 0 to ((GREYSCALE_PICTURE_WIDTH * GREYSCALE_PICTURE_HEIGHT) - 1);
		we		: in std_logic := '1';
		clk	: in std_logic;
		q		: out std_logic_vector(7 downto 0)
	);
	
end entity;

architecture rtl of single_port_ram is

	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(7 downto 0);
	type memory_t is array(((GREYSCALE_PICTURE_WIDTH * GREYSCALE_PICTURE_HEIGHT) - 1) downto 0) of word_t;
	
	-- Declare the RAM signal.
	signal ram : memory_t;
	
	-- Register to hold the address
	signal addr_reg : natural range 0 to ((GREYSCALE_PICTURE_WIDTH * GREYSCALE_PICTURE_HEIGHT) - 1);

begin

	process(clk)
	begin
		if(rising_edge(clk)) then
			if(we = '1') then
				ram(addr) <= data;
			end if;
			
			-- Register the address for reading
			addr_reg <= addr;
		end if;
	
	end process;
	
	q <= ram(addr_reg);
	
end rtl;