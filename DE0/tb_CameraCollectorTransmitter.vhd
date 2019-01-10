--Owner: Senior Design Team Delta
--Component: Camera Collector and Transmitter Test Bench
--Description: This is a test bench to verify functionality of the 
--             CameraCollectorTransmitter component
--Author: Michael Dougherty
--Start Date: 1/8/2019

LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_CameraCollectorTransmitter IS
END tb_CameraCollectorTransmitter;

ARCHITECTURE behavioral OF tb_CameraCollectorTransmitter IS
--========================================
-- Component Declarations
--========================================
COMPONENT CameraCollectorTransmitter IS
PORT(
	i_clk              : IN STD_LOGIC;
	i_en               : IN STD_LOGIC;
	i_pixel_data       : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	i_lval             : IN STD_LOGIC;
	i_fval             : IN STD_LOGIC;
	i_pixel_read       : IN STD_LOGIC;
	o_pixel_data       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	o_valid_frame      : OUT STD_LOGIC;
	o_valid_pixel      : OUT STD_LOGIC                      
);
END COMPONENT;
--========================================
-- Constant Declarations
--========================================
CONSTANT T_clk : TIME:= 20 ns; -- 50MHz clock period
--========================================
-- Signal Declarations
--========================================
	SIGNAL i_clk              : STD_LOGIC;
	SIGNAL i_en               : STD_LOGIC;
	SIGNAL i_pixel_data       : STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL i_lval             : STD_LOGIC;
	SIGNAL i_fval             : STD_LOGIC;
	SIGNAL i_pixel_read       : STD_LOGIC;
	SIGNAL o_pixel_data       : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL o_valid_frame      : STD_LOGIC;
	SIGNAL o_valid_pixel      : STD_LOGIC;
BEGIN

--generate the clock signal
clock1_gen: PROCESS -- no sensitivity list
BEGIN
 i_clk <= '0';
 WAIT FOR T_clk/2;
 i_clk <= '1';
 WAIT FOR T_clk/2;
END PROCESS;

--========================================
-- DUT Port Mapping
--========================================
DUT : CameraCollectorTransmitter
PORT MAP(
	i_clk         => i_clk,        
   i_en          => i_en,         
   i_pixel_data  => i_pixel_data, 
   i_lval        => i_lval,       
   i_fval        => i_fval,       
	i_pixel_read  => i_pixel_read, 
   o_pixel_data  => o_pixel_data, 
   o_valid_frame => o_valid_frame,  
   o_valid_pixel => o_valid_pixel 
);

--========================================
-- TESTING
--========================================
--from 0 to 20 cycles test i_en. Should see state transition from awaitEnable, to restart, to awaitFrame.
i_en <= '0','1' AFTER 20*T_clk;
--i_pixel_data <= "000000000000";
i_lval <= '0';
i_fval <= '0';
i_pixel_read <= '0', '1' AFTER 25*T_clk, '0' AFTER 50*T_clk;

END behavioral;	


