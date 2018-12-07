--Owner: Senior Design Team Delta
--Component: RegisterX
--Description: This component is a register with a
--             settable, generic size
--Author: Michael Dougherty
--Start Date: 12/2/2018

--INPUTS:
--i_reset_l    : reset low
--i_clk        : input clock
--i_en         : enable input latch
--i_d          : the data to be latched
--OUTPUTS:
--o_q          : latched data to be read

LIBRARY ieee;
USE ieee. std_logic_1164.all;
USE ieee. std_logic_arith.all;
USE ieee. std_logic_unsigned.all;
 
ENTITY RegisterX IS
GENERIC(
	size : INTEGER
);
PORT( 
	i_clk     : IN STD_LOGIC;
	i_reset_l : IN STD_LOGIC;
	i_en      : IN STD_LOGIC;
	i_d       : IN STD_LOGIC_VECTOR(size - 1 downto 0);
	o_q       : OUT STD_LOGIC_VECTOR(size - 1 downto 0)
);
END RegisterX;
 
ARCHITECTURE behavioral of RegisterX is
BEGIN
	PROCESS(i_clk, i_reset_l)
	BEGIN
	IF(i_reset_l = '0') THEN
		o_q <= (OTHERS => '0')
	ELSIF(RISING_EDGE(i_clk)) THEN
		IF(i_en = '1') THEN
			o_q <= i_d;
		END IF;
	END IF;
	END PROCESS;
END behavioral;