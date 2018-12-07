--Owner: Senior Design Team Delta
--Component: Camera Collector
--Description: After the camera is configured, this component monitors the
--             camera outputs and grabs image data when valid. This component
--             only grabs the data, and then passes the data along to another
--             component.
--             This component is designed for use with the TRDB-D5M
--             camera from Altera 
--Author: Michael Dougherty
--Start Date: 12/2/2018

--INPUTS:
--i_reset_l    : reset low
--i_clk        : input clock (50 MHz)
--i_en         : enable collection of pixel data from the camera
--i_pixel_data : the pixel information output by the D5M at each epoch
--i_lval       : line-valid signal from the D5M
--i_fval       : frame_valid signal from the D5M
--***See TRDB-D5M Hardware Specification page 5 for further detail of D5M signals***
--OUTPUTS:
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;
ENTITY CameraCollector IS
PORT(
	i_reset_l          : IN STD_LOGIC;
	i_clk              : IN STD_LOGIC;
	i_en               : IN STD_LOGIC;
	i_pixel_data       : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	i_lval             : IN STD_LOGIC;
	i_fval             : IN STD_LOGIC;
);
END CameraCollector;

ARCHITECTURE structural OF CameraCollector IS
--=======================================
-- Declare Constants
--=======================================
--camera frame is 640x480
CONSTANT PICTURE_WIDTH : INTEGER := 480; 
--the number of bits required to store 480*4 as a binary number
CONSTANT REG_NUM_BIN   : INTEGER := INTEGER(FLOOR(LOG2(REAL(480 * 4))+1));
--the width of a pixel
CONSTANT PIXEL_WIDTH : INTEGER := 12;
--=======================================
-- Declare Components
--=======================================
COMPONENT RegFileX IS
GENERIC(
	regNumber       : INTEGER;
	regNumberBinary : INTEGER;
	regWidth        : INTEGER
);
PORT( 
	i_clk          : IN STD_LOGIC;
	i_write_en     : IN STD_LOGIC;
	i_write_select : IN STD_LOGIC_VECTOR(regNumberBinary - 1 DOWNTO 0);
	i_selectA      : IN STD_LOGIC_VECTOR(regNumberBinary - 1 DOWNTO 0);
	i_selectB      : IN STD_LOGIC_VECTOR(regNumberBinary - 1 DOWNTO 0);
	o_regA         : OUT STD_LOGIC_VECTOR(regWidth - 1 DOWNTO 0);
	o_regB         : OUT STD_LOGIC_VECTOR(regWidth - 1 DOWNTO 0)
);
END COMPONENT;
--========================================
-- Signal Declarations
--========================================
SIGNAL pixelCount        : INTEGER := 0;
SIGNAL rowCount          : INTEGER := 0;
SIGNAL write_en_wire     : STD_LOGIC;
SIGNAL write_select_wire : STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
SIGNAL write_data_wire   : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
SIGNAL selectA_wire      : STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
SIGNAL selectB_wire      : STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0); 
SIGNAL out_regA_wire     : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
SIGNAL out_regB_wire     : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
SIGNAL lval_delayed      : STD_LOGIC := '0'; 
SIGNAL lval_edge         : STD_LOGIC;

BEGIN
--========================================
-- Map Components
--========================================
----------========================================
---------- Front and Back Buffers
----------========================================
buffers: RegFileX
GENERIC MAP(
	size => PICTURE_WIDTH
	regNumber       => PICTURE_WIDTH * 4;
	regNumberBinary => REG_NUM_BIN;
	regWidth        => PIXEL_WIDTH;
)
PORT MAP(
	iclk           => i_clk, --/
	i_write_en     => write_en_wire, --/
	i_write_select => write_select_wire, --/
	i_write_data   => i_pixel_data, --/
	i_selectA      => selectA_wire, 
	i_selectB      => selectB_wire,
	o_regA         => out_regA_wire,
	o_regB         => out_regB_wire
);
--========================================
-- Local Architecture
--========================================
PROCESS(i_clk, i_reset_l)
BEGIN
	--reset
	If (i_reset_l = '0') THEN
		pixelCount <= 0;
		rowCount <= 0;
	ELSIF (RISING_EDGE(i_clk)) THEN
		--TODO: While Fval is high, every time Lval goes low we want 
		--      to increment row count, wrapping to 0 if we would count
		--      to 4.
		--      row count is going to tell us which buffer we are in-
		--      front or back buffer
		IF(lval_edge = '1') THEN
			IF(rowCount < 3) THEN
				rowCount <= rowCount + 1;
			ELSE
				rowCount <= 0;
			END IF;
		--if the camera has finished being set up
		IF(i_en = '1') THEN
			--if start of new frame
			IF(i_lval = '1')
			--IF((i_fval AND i_lval) = '1') THEN 
			--	write_en_wire <= '1';
			--ELSE 
			--	write_en_wire <= '0';
			--END IF;
		END IF;
		pixelCount <= pixelCount + 1;
	END IF;
END PROCESS;

--iterate through regfile using the pixelCount as an index
write_select_wire <= STD_LOGIC_VECTOR(TO_UNSIGNED(pixelCount, write_select_wire'length);

--i_lval falling edge detection. lval_edge strobes high one clock period when
--i_lval toggles from high to low.
lval_delayed <= i_lval WHEN RISING_EDGE(i_clk); 
lval_edge <= lval_delayed AND NOT i_lval; 
 

END structural;
