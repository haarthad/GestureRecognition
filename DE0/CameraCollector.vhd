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
--i_clk        : input clock (50 MHz)
--i_en         : enable collection of pixel data from the camera
--i_pixel_data : the pixel information output by the D5M at each epoch
--i_lval       : line-valid signal from the D5M
--i_fval       : frame_valid signal from the D5M
--i_finished   : pulse triggers a reset and new image collection/transfer
--***See TRDB-D5M Hardware Specification page 5 for further detail of D5M signals***
--OUTPUTS:
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;
USE work.CAMERA_PACK.all;
ENTITY CameraCollector IS
PORT(
	i_clk              : IN STD_LOGIC;
	i_en               : IN STD_LOGIC;
	i_pixel_data       : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	i_lval             : IN STD_LOGIC;
	i_fval             : IN STD_LOGIC;
	i_finished         : IN STD_LOGIC
);
END CameraCollector;

ARCHITECTURE structural OF CameraCollector IS

--=======================================
-- Declare States
--=======================================
TYPE state_type IS (AWAIT_ENABLE, RESTART, AWAIT_FRAME, AWAIT_ROW, COLLECT, AWAIT_FINISH); 
SIGNAL nstate : state_type;
SIGNAL pstate : state_type;

--=======================================
-- Declare Components
--=======================================
COMPONENT RegFile_1_4_12 IS
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
SIGNAL selectC_wire      : STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0); 
SIGNAL selectD_wire      : STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0); 
SIGNAL out_regA_wire     : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
SIGNAL out_regB_wire     : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
SIGNAL out_regC_wire     : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
SIGNAL out_regD_wire     : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
SIGNAL lval_delayed      : STD_LOGIC := '0'; 
SIGNAL lval_edge         : STD_LOGIC;

BEGIN
--========================================
-- Map Components
--========================================
----------========================================
---------- Front and Back Buffers
----------========================================
buffers: RegFile_1_4_12
PORT MAP(
	i_clk           => i_clk,
	i_write_en     => write_en_wire,
	i_write_select => write_select_wire,
	i_write_data   => i_pixel_data,
	i_selectA      => selectA_wire, 
	i_selectB      => selectB_wire,
	i_selectC      => selectC_wire,
	i_selectD      => selectD_wire,
	o_regA         => out_regA_wire,
	o_regB         => out_regB_wire,
	o_regC         => out_regB_wire,
	o_regD         => out_regB_wire
);
--========================================
-- Local Architecture
--========================================
--CLOCKL THE STATE
state_reg : PROCESS(i_clk, i_finished)
BEGIN
	IF (i_finished = '1') THEN 
      pstate <= RESTART;
   ELSIF (RISING_EDGE(i_clk)) THEN
      pstate <= nstate;
   END IF;
END PROCESS;

-- STATE MACHINE
sm : PROCESS(ALL)
BEGIN
   CASE pstate IS
   
      WHEN AWAIT_ENABLE => 
         IF (i_en = '1') THEN
            nstate <= RESTART;
         ELSE
            nstate <= AWAIT_ENABLE;
         END IF;
         
      WHEN RESTART => 
         --TODO: reset required variables
			nstate <= AWAIT_FRAME;
         
      WHEN AWAIT_FRAME =>
         IF (i_finished = '1') THEN
            nstate <= RESTART;
         ELSIF (i_fval = '1') THEN
            nstate <= AWAIT_ROW;
			ELSE
				nstate <= AWAIT_FRAME;
         END IF;
         
      WHEN AWAIT_ROW =>
         IF (i_finished = '1') THEN
            nstate <= RESTART;
         ELSIF (i_lval = '1') THEN
				--TODO: Be wary of an off by one error between
				--this state and the next
            nstate <= COLLECT;
			ELSE
				nstate <= AWAIT_ROW;
         END IF;
         
      WHEN COLLECT =>
         IF (i_finished = '1') THEN
            nstate <= RESTART;
         ELSIF (i_lval = '0') THEN
            nstate <= AWAIT_ROW;
			--TODO: ELSIF recieved all pixel wait for finish THEN
			--nstate <= AWAIT_FINISH;
			ELSE
				nstate <= COLLECT;
         END IF;
      
      WHEN AWAIT_FINISH =>
         IF (i_finished = '1') THEN
            nstate <= RESTART;
			ELSE
				nstate <= AWAIT_FINISH;
			END IF;
         
		-- Always have an others case
      WHEN OTHERS =>
         nstate <= RESTART;

   END CASE;
END PROCESS;

--iterate through regfile using the pixelCount as an index
write_select_wire <= STD_LOGIC_VECTOR(TO_UNSIGNED(pixelCount, write_select_wire'length));

--i_lval falling edge detection. lval_edge strobes high one clock period when
--i_lval toggles from high to low.
lval_delayed <= i_lval WHEN RISING_EDGE(i_clk); 
lval_edge <= lval_delayed AND NOT i_lval; 
 

END structural;
