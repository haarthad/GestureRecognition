--Owner: Senior Design Team Delta
--Component: DE0_Subsystem_Test
--Description: Test version of the DE0_Subsystem which
--					does not gather pixels from the camera but instead
--					sends all black pixels to the camera with a white
--					vertical strip of pixels. This is the toplevel of the DE0_Subsystem. 
--             This interfaces to the physical DE0 Nano SoC pins and is responsible 
--             for routing signals from the camera and to/from the Raspberry Pi to/from 
--             the components concerned with those signals. 
--INPUTS
--i_rst_n        : an active-low global reset signal 
--i_clk50mhz     : the 50MHz input clock
--i_clk          : the input clock which drives the DE0_Subsystem
--i_pixel_data   : pixel data coing from the camera
--i_lval         : lval signal coming from the camera
--i_fval         : fval signal coming from teh camera
--i_pixel_read   : i_pixel_read signal coming from the Raspberry Pi
--io_sclk        : serial clock used for I2C communication with camera
--io_sdata       : I2C data fro communication with camera
--o_rst_n        : active low reset signal for the camera
--o_xclk         : output clock which drives the camera
--o_pixel_data   : pixel data output to the Raspberry Pi
--o_valid_frame  : valid frame signal output to the Raspberry Pi
--o_valid_pixel  : valid pixel signal output to the Raspberry Pi. Toggles when valid.
--o_sobel_en     : test signal
--o_edgeTest     : test signal
--O_ROW_SIZE_LED : test LED signal
--O_COL_SIZE_LED : test LED signal
--O_ROW_SKIP_LED : test LED signal
--O_COL_SKIP_LED : test LED signal
--O_ACK_ERR_LED  : test LED signal

LIBRARY ieee;
USE ieee. std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee. std_logic_unsigned.all;
USE work.CAMERA_PACK.all;
 
ENTITY DE0_Subsystem_Test IS

PORT( 
	i_rst_n        : IN STD_LOGIC;
	i_clk50mhz     : IN STD_LOGIC;
	i_clk          : IN STD_LOGIC;
	i_pixel_data   : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	i_lval         : IN STD_LOGIC;
	i_fval         : IN STD_LOGIC;
	i_pixel_read   : IN STD_LOGIC;
	o_rst_n        : OUT STD_LOGIC;
	o_xclk         : OUT STD_LOGIC;
	io_sclk        : INOUT STD_LOGIC;
	io_sdata       : INOUT STD_LOGIC;
	o_pixel_data   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	o_valid_frame  : OUT STD_LOGIC;
	o_valid_pixel  : OUT STD_LOGIC;
	o_sobel_en     : OUT STD_LOGIC;
	o_edgeTest     : OUT STD_LOGIC;
	O_ROW_SIZE_LED : OUT STD_LOGIC;
	O_COL_SIZE_LED : OUT STD_LOGIC;
	O_ROW_SKIP_LED : OUT STD_LOGIC;
	O_COL_SKIP_LED : OUT STD_LOGIC;
	O_ACK_ERR_LED  : OUT STD_LOGIC
);
END DE0_Subsystem_Test;
 
ARCHITECTURE structural OF DE0_Subsystem_Test IS
--========================================
-- Signal Declarations
--========================================
SIGNAL enable_wire  : STD_LOGIC;
SIGNAL test_wire    : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL test_pix_cnt : INTEGER := 0;
SIGNAL i_clkTap : STD_LOGIC;
SIGNAL sobelWaste : STD_LOGIC;
--=======================================
-- Declare Components
--=======================================
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
	o_valid_pixel      : OUT STD_LOGIC;
	o_sobel_en         : OUT STD_LOGIC;
	o_edgeTest         : OUT STD_LOGIC
); 
END COMPONENT;
COMPONENT CAMERA_PROGRAMMER IS
PORT(
	I_RST_N        : IN STD_LOGIC;
	I_CLK50MHZ     : IN STD_LOGIC;
	O_RST_N        : OUT STD_LOGIC;
	O_XCLK         : OUT STD_LOGIC;
	IO_SCLK        : INOUT STD_LOGIC;
	IO_SDATA       : INOUT STD_LOGIC;
	O_PROG_DONE    : OUT STD_LOGIC;
	O_ROW_SIZE_LED : OUT STD_LOGIC;
	O_COL_SIZE_LED : OUT STD_LOGIC;
	O_ROW_SKIP_LED : OUT STD_LOGIC;
	O_COL_SKIP_LED : OUT STD_LOGIC;
	O_ACK_ERR_LED  : OUT STD_LOGIC
);
END COMPONENT;
--========================================
-- Local Architecture
--========================================
BEGIN
--========================================
-- Map Components
--========================================
----------========================================
---------- CameraCollectorTransmitter
----------========================================
CameraCT: CameraCollectorTransmitter
PORT MAP(
	i_clk          => i_clkTap,
	i_en           => enable_wire,
	i_pixel_data   => test_wire,
	i_lval         => i_lval,
	i_fval         => i_fval,
	i_pixel_read   => i_pixel_read,
	o_pixel_data   => o_pixel_data,
	o_valid_frame  => o_valid_frame,
	o_valid_pixel  => o_valid_pixel,
	o_sobel_en     => sobelWaste,
	o_edgeTest     => o_edgeTest
);
CameraP: camera_programmer
PORT MAP(
	I_RST_N        => i_rst_n,
	I_CLK50MHZ     => i_clk50mhz,
	O_RST_N        => o_rst_n,
	O_XCLK         => o_xclk,
	IO_SCLK        => io_sclk,
	IO_SDATA       => io_sdata,
	O_PROG_DONE    => enable_wire,
	O_ROW_SIZE_LED => O_ROW_SIZE_LED,
	O_COL_SIZE_LED => O_COL_SIZE_LED,
	O_ROW_SKIP_LED => O_ROW_SKIP_LED,
	O_COL_SKIP_LED => O_COL_SKIP_LED,
	O_ACK_ERR_LED  => O_ACK_ERR_LED
);

--generate horizontal strip test pixel data
PROCESS(i_clk)
BEGIN
	IF(RISING_EDGE(i_clk)) THEN
		IF(i_fval = '1') THEN
			IF(i_lval = '1') THEN
				IF(test_pix_cnt < 1280) THEN
					test_wire <= "000000000000";
					test_pix_cnt <= test_pix_cnt + 1;
				ELSIF(test_pix_cnt < 2560) THEN
					test_wire <= "111111111111";
					test_pix_cnt <= test_pix_cnt + 1;
				ELSE
					test_wire <= "000000000000";
					test_pix_cnt <= test_pix_cnt;
				END IF;
			ELSE
				test_pix_cnt <= test_pix_cnt;
				test_wire <= test_wire;
			END IF;
		ELSE
			test_wire <= "000000000000";
			test_pix_cnt <= 0;
		END IF;
	END IF;
END PROCESS;

--generate vertical strip test pixel data
--PROCESS(i_clk)
--BEGIN
--	IF(RISING_EDGE(i_clk)) THEN
--		IF(i_fval = '1') THEN
--			IF(i_lval = '1') THEN
--				IF(test_pix_cnt < 9) THEN
--					test_wire <= "111111111111";
--				ELSE
--					test_wire <= "000000000000";
--				END IF;
--				test_pix_cnt <= test_pix_cnt + 1;
--			ELSE
--				test_pix_cnt <= 0;
--				test_wire <= "111111111111";
--			END IF;
--		ELSE
--			test_wire <= "111111111111"; --YOU CHANGED THIS from all 0's in case there was delay with correctly setting the first pixel in a row
--			test_pix_cnt <= 0;
--		END IF;
--	END IF;
--END PROCESS;

i_clkTap <= i_clk;
o_sobel_en <= i_clkTap;
END structural;