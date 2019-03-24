--Owner: Senior Design Team Delta
--Component: ImageStore Test Bench
--Description: This is a test bench to verify functionality of the 
--             ImageStore component
--Author: Michael Dougherty
--Start Date: 1/8/2019

LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_ImageStore IS
END tb_ImageStore;

ARCHITECTURE behavioral OF tb_ImageStore IS
--========================================
-- Component Declarations
--========================================
COMPONENT ImageStore IS
PORT(
	i_clk          : IN STD_LOGIC;
	i_swapped      : IN STD_LOGIC;
	i_finished     : IN STD_LOGIC;
	i_regA         : IN STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	i_regB         : IN STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	i_regC         : IN STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	i_regD         : IN STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	i_selectSram   : IN STD_LOGIC_VECTOR(GREYSCALE_REG_NUM_BIN - 1 DOWNTO 0);
	o_selectA      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	o_selectB      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	o_selectC      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	o_selectD      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	o_sram         : OUT STD_LOGIC_VECTOR(GREYSCALE_PIXEL_WIDTH - 1 DOWNTO 0)              
);
END COMPONENT;
--========================================
-- Constant Declarations
--========================================
CONSTANT T_clk : TIME:= 20 ns; -- 50MHz clock period
--========================================
-- Signal Declarations
--========================================
	SIGNAL i_clk          : STD_LOGIC;
	SIGNAL i_swapped      : STD_LOGIC;
	SIGNAL i_finished     : STD_LOGIC;
	SIGNAL i_regA         : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	SIGNAL i_regB         : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	SIGNAL i_regC         : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	SIGNAL i_regD         : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	SIGNAL i_selectSram   : STD_LOGIC_VECTOR(GREYSCALE_REG_NUM_BIN - 1 DOWNTO 0);
	SIGNAL o_selectA      : STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	SIGNAL o_selectB      : STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	SIGNAL o_selectC      : STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0); 
	SIGNAL o_selectD      : STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	SIGNAL o_sram         : STD_LOGIC_VECTOR(GREYSCALE_PIXEL_WIDTH - 1 DOWNTO 0);
	
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
DUT : ImageStore
PORT MAP(
	i_clk        => i_clk,        
   i_swapped    => i_swapped,    
   i_finished   => i_finished,   
   i_regA       => i_regA,       
   i_regB       => i_regB,       
	i_regC       => i_regC,       
   i_regD       => i_regD,       
   i_selectSram => i_selectSram,  
   o_selectA    => o_selectA,    
   o_selectB    => o_selectB,   
	o_selectC    => o_selectC,   
	o_selectD    => o_selectD,   
	o_sram       => o_sram      
);

--========================================
-- TESTING
--========================================
i_en <= '0','1' AFTER 20*T_clk;
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

--grab a pixel if in COLLECT state and increment pixel count.
--also increments row count
collectPixel : PROCESS(i_clk, i_finished)
BEGIN
	IF(i_finished = '1') THEN
		pixelCount   <= 0;
		rowCount     <= 0;
		write_en_wire <= '0';
		write_select_wire <= (OTHERS => '0');
		i_swapped_wire <= '0';
	ELSIF(RISING_EDGE(i_clk)) THEN
		IF(pstate = COLLECT) THEN
			IF(i_lval = '1') THEN
				write_en_wire <= '1';
				pixelCount    <= pixelCount + 1;
				--increment the write address of the front/back buffer
				IF(UNSIGNED(write_select_wire) < ((PICTURE_WIDTH * 4) - 1)) THEN -- was IF(UNSIGNED(write_select_wire) < ((PICTURE_WIDTH * 4) - 1)) THEN
					write_select_wire <= STD_LOGIC_VECTOR(UNSIGNED(write_select_wire) + 1 );
					IF(UNSIGNED(write_select_wire) = ((PICTURE_WIDTH * 2) - 1)) THEN
						i_swapped_wire <= '1';
					ELSE
						i_swapped_wire <= '0';
					END IF;
				ELSIF(UNSIGNED(write_select_wire) = ((PICTURE_WIDTH * 4) - 1)) THEN
					i_swapped_wire <= '1';
					write_select_wire <= (OTHERS => '0');
				ELSE 
					i_swapped_wire <= '0';
					write_select_wire <= (OTHERS => '0');
				END IF;
			ELSE
				write_en_wire <= '0';
			END IF;
			--used for i_lval falling edge detection
			lval_delayed <= i_lval;
			--if i_lval had a falling edge increment rowCount
			IF(lval_edge = '1') THEN
				IF(rowCount < 3) THEN
					rowCount <= rowCount + 1;
				ELSE
					rowCount <= 0;
				END IF;
			END IF;
		ELSE
			rowCount <= 0;
			pixelCount <= 0;
			write_en_wire <= '0';
			write_select_wire <= (OTHERS => '0');
			i_Swapped_wire <= '0';
		END IF;
	END IF;
END PROCESS;

i_pixel_data <= pixel_gen;

END behavioral;	


