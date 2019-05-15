--==============================================================================
-- Project : Pixel Collection
-- Author  : Kevin Hughes
-- Date    : Sunday, December 2nd, 2018
-- Module  : clock_divider
-- Desc.   : Divides the clock input. 
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--==============================================================================
-- CLOCK_DIVIDER Entity block
-- I_RST_N : Reset
-- I_CLK   : Clock to be divided
-- O_CLK   : Clock input divided
--==============================================================================
entity CLOCK_DIVIDER is port(
	I_RST_N : in std_logic;
	I_CLK   : in std_logic;
	O_CLK   : out std_logic
);end entity CLOCK_DIVIDER;

--==============================================================================
-- CLOCK_DIVIDER Architecture block
--==============================================================================
architecture RTL of CLOCK_DIVIDER is

--Intermediary clock signal declaration
signal S_CLK : STD_LOGIC := '0';

--Clock division integer declarations
signal   CLK_CNT : integer := 0;
constant CLK_DIV : integer := 2000;

begin

--Divides the clock signal by the CLK_DIV amount
DIVIDE: process(I_RST_N, I_CLK)
begin
	--Reset case
	if(I_RST_N = '0') then
		CLK_CNT <=  0;
		S_CLK   <= '0';
	--Rising edge clock case
	elsif rising_edge(I_CLK) then
		CLK_CNT <= CLK_CNT + 1;
		
		--Flip clock signal once division is reached
		if(CLK_CNT = CLK_DIV) then
			S_CLK   <= not S_CLK;
			CLK_CNT <= 0;
		end if;
		
	end if;
end process;


--Assign clock output
O_CLK <= S_CLK;

end architecture RTL;