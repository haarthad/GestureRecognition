--Owner: Senior Design Team Delta
--Component: RegFile_1_4_12
--Description: This component was going to be a single register file with
--             1 write port, 4 read ports, with 12 bit registers.
--             However, Quartus cannot infer this type of RAM
--             and so will synthesize this component as a regfile
--             which takes up a LOT more LABs and ALMs. So we will
--             use two stacked 1 write 2 read rams to create a single
--             1 write 4 read ram.
--Author: Michael Dougherty
--Start Date: 12/2/2018

--INPUTS:
--i_clk          : input clock
--i_write_en     : enable latching of data on i_write_data
--i_write_select : select which register to write to
--i_write_data   : the data to be latched
--i_selectA      : select one register to read from on o_regA
--i_selectB      : select one register to read from on o_regB
--i_selectC      : select one register to read from on o_regC
--i_selectD      : select one register to read from on o_regD
--OUTPUTS:
--o_regA         : data latched in the register selected by i_selectA
--o_regB         : data latched in the register selected by i_selectB
--o_regC         : data latched in the register selected by i_selectC
--o_regD         : data latched in the register selected by i_selectD

LIBRARY ieee;
USE ieee. std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee. std_logic_unsigned.all;
USE work.CAMERA_PACK.all;
 
ENTITY RAM_1_4_12 IS

PORT( 
	i_clk          : IN STD_LOGIC;
	i_write_en     : IN STD_LOGIC;
	i_write_select : IN STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	i_write_data   : IN STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	i_selectA      : IN STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	i_selectB      : IN STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	i_selectC      : IN STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	i_selectD      : IN STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	o_regA         : OUT STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	o_regB         : OUT STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	o_regC         : OUT STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	o_regD         : OUT STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0)
);
END RAM_1_4_12;
 
ARCHITECTURE behavioral OF RAM_1_4_12 IS
--========================================
-- Signal Declarations
--========================================
	SIGNAL write_en_wire : STD_LOGIC;
	SIGNAL write_select_wire : STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	SIGNAL pixel_data_wire : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
--=======================================
-- Declare Components
--=======================================
COMPONENT RAM_1_2_12 IS
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
END COMPONENT;
BEGIN
--========================================
-- Map Components
--========================================
----------========================================
---------- RAM A
----------========================================
RAM_A: RAM_1_2_12
PORT MAP(
	i_clk          => i_clk,
	i_write_en     => write_en_wire,
	i_write_select => write_select_wire,
	i_write_data   => pixel_data_wire,
	i_selectA      => i_selectA, 
	i_selectB      => i_selectB,
	o_regA         => o_regA,
	o_regB         => o_regB
);
----------========================================
---------- RAM B
----------========================================
RAM_B: RAM_1_2_12
PORT MAP(
	i_clk          => i_clk,
	i_write_en     => write_en_wire,
	i_write_select => write_select_wire,
	i_write_data   => pixel_data_wire,
	i_selectA      => i_selectC, 
	i_selectB      => i_selectD,
	o_regA         => o_regC,
	o_regB         => o_regD
);
--========================================
-- Local Architecture
--========================================
	write_en_wire <= i_write_en;
	write_select_wire <= i_write_select;
	pixel_data_wire <= i_write_data;
END behavioral;