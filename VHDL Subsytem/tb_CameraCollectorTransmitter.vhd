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
	SIGNAL i_lval             : STD_LOGIC := '0';
	SIGNAL i_fval             : STD_LOGIC;
	SIGNAL i_pixel_read       : STD_LOGIC := '0';
	SIGNAL o_pixel_data       : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL o_valid_frame      : STD_LOGIC;
	SIGNAL o_valid_pixel      : STD_LOGIC;
	SIGNAL pixel_gen_switch   : STD_LOGIC := '0';
	SIGNAL pixel_gen          : STD_LOGIC_VECTOR(11 DOWNTO 0) := "000000000000"; 
	SIGNAL lval_gen           : INTEGER := 0;
	SIGNAL total_sent         : INTEGER := 0;
	SIGNAL read_gen_switch    : STD_LOGIC;
	SIGNAL read_gen_delay     : INTEGER := 0;
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
--0 to 20 cycles test i_en. Should see state transition from awaitEnable, to restart, to awaitFrame.
--25 to 50 cycles test i_pixel_read high for 20 cycles asserts i_finished and state moves to restart.
--55 to 70 cycles test i_fval going high changes state from await_frame to collect
i_en <= '0','1' AFTER 20*T_clk;
--i_pixel_data <= "000000000000";
--i_lval <= '0';
i_fval <= '0', '1' AFTER 55*T_clk, '0' AFTER 314305*T_clk;
read_gen_switch <= '0', '1' AFTER 314310*T_clk;
--i_pixel_read <= '0', '1' AFTER 25*T_clk, '0' AFTER 50*T_clk;
pixel_gen_switch <= '0', '1' AFTER 75*T_clk;

--generate pixel data from camera
pixel_generation: PROCESS(i_clk)
BEGIN
	IF(RISING_EDGE(i_clk)) THEN
		IF(pixel_gen_switch = '1') THEN
			IF(lval_gen > 649) THEN
				lval_gen <= 0;
				i_lval <= '0';
			ELSIF(lval_gen < 640) THEN
				lval_gen <= lval_gen +1;
				i_lval <= '1';
				total_sent <= total_sent + 1;
			ELSE
				lval_gen <= lval_gen +1;
				i_lval <= '0';
			END IF;
			
			IF(pixel_gen = "111111111111") THEN
				pixel_gen <= "000000000000"; 
			ELSE
				pixel_gen <= STD_LOGIC_VECTOR(UNSIGNED(pixel_gen)+1);
			END IF;
		END IF;
	END IF;
END PROCESS;

--generate i_pixel_read signal
read_generation: PROCESS(i_clk)
BEGIN
	IF(read_gen_switch = '1') THEN
		IF(read_gen_delay < 4) THEN
			read_gen_delay <= read_gen_delay + 1;
		ELSIF(read_gen_delay = 4) THEN
			read_gen_delay <= read_gen_delay + 1;
			i_pixel_read <= NOT i_pixel_read;
		ELSE
			read_gen_delay <= 0;
		END IF;
	ELSE
		i_pixel_read <= '0';
	END IF;
END PROCESS;

i_pixel_data <= pixel_gen;

END behavioral;	


