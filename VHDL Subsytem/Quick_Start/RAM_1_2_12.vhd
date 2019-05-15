--Owner: Senior Design Team Delta
--Component: RegFile_1_2_12
--Description: This component is a simple ram with 1 write port,
--             2 read ports, and a data width of 12 bits.
--Author: Michael Dougherty
--Start Date: 12/2/2018

--INPUTS:
--i_clk          : input clock
--i_write_en     : enable latching of data on i_write_data
--i_write_select : select which register to write to
--i_write_data   : the data to be latched
--i_selectA      : select one register to read from on o_regA
--i_selectB      : select one register to read from on o_regB
--OUTPUTS:
--o_regA         : data latched in the register selected by i_selectA
--o_regB         : data latched in the register selected by i_selectB

LIBRARY ieee;
USE ieee. std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee. std_logic_unsigned.all;
USE work.CAMERA_PACK.all;
 
ENTITY RAM_1_2_12 IS

PORT( 
	i_clk          : IN STD_LOGIC;
	i_write_en     : IN STD_LOGIC;
	i_write_select : IN STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	i_write_data   : IN STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	i_selectA      : IN STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	i_selectB      : IN STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	o_regA         : OUT STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	o_regB         : OUT STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0)
);
END RAM_1_2_12;
 
ARCHITECTURE behavioral OF RAM_1_2_12 IS
--========================================
-- RAM Declaration
--========================================
	TYPE reg_array IS ARRAY(0 TO ((PICTURE_WIDTH * 4) - 1)) OF STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	SIGNAL regFile : reg_array;
--========================================
-- Local Architecture
--========================================
BEGIN
	PROCESS(i_clk)
	BEGIN
		IF(RISING_EDGE(i_clk)) THEN
			--writing
			IF(i_write_en = '1') THEN
				regFile(TO_INTEGER(UNSIGNED(i_write_select))) <= i_write_data;
			END IF;
			o_regA <= regFile(TO_INTEGER(UNSIGNED(i_selectA)));
			o_regB <= regFile(TO_INTEGER(UNSIGNED(i_selectB)));
		END IF;
	END PROCESS;
	
END behavioral;