--Owner: Senior Design Team Delta
--Component: RegFile
--Description: This component is a register file with
--             a generic number of registers, each with a generic 
--             bit width. Two registers can be
--             read at any given time, and one register can
--             be written to at a time. This regfile does
--             not support bypassing inputs directly to outputs
--Author: Michael Dougherty
--Start Date: 12/2/2018

--GENERICS:
--regNumber       : the number of registers in the regfile
--regNumberBinary : floor(log2(regNumber) + 1)
--                  the number of bits needed to represent regNumber
--                  in binary
--regWidth        : the number of bits in each register
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
USE iee.numeric_std.all;
USE ieee. std_logic_arith.all;
USE ieee. std_logic_unsigned.all;
 
ENTITY RegFileX IS
GENERIC(
	regNumber       : INTEGER;
	regNumberBinary : INTEGER;
	regWidth        : INTEGER
);
PORT( 
	i_clk          : IN STD_LOGIC;
	i_write_en     : IN STD_LOGIC;
	i_write_select : IN STD_LOGIC_VECTOR(regNumberBinary - 1 DOWNTO 0);
	i_write_data   : IN STD_LOGIC_VECTOR(regWidth - 1 DOWNTO 0);
	i_selectA      : IN STD_LOGIC_VECTOR(regNumberBinary - 1 DOWNTO 0);
	i_selectB      : IN STD_LOGIC_VECTOR(regNumberBinary - 1 DOWNTO 0);
	o_regA         : OUT STD_LOGIC_VECTOR(regWidth - 1 DOWNTO 0);
	o_regB         : OUT STD_LOGIC_VECTOR(regWidth - 1 DOWNTO 0)
);
END RegFileX;
 
ARCHITECTURE behavioral OF RegFileX IS
--========================================
-- Signal Declarations
--========================================
	TYPE reg_array IS ARRAY(0 TO regNumber) OF STD_LOGIC_VECTOR(regWidth - 1 DOWNTO 0);
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
		END IF;
	END PROCESS;
	--reading
	o_regA <= regFile(TO_INTEGER(UNSIGNED(i_selectA)));
	o_regB <= regFile(TO_INTEGER(UNSIGNED(i_selectB)));
	
END behavioral;