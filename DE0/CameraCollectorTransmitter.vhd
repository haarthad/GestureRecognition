--Owner: Senior Design Team Delta
--Component: Camera Collector and Transmitter
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
--i_pixel_read : from the transmission pins, signalling a pixel has been recieved
--o_pixel_data : the greyscale pixel output to the transmission pins
--o_valid_frame: signals that frame is being transmitted
--o_valid_pixel: signals that pixel on transmission pins is valid
--i_finished   : pulse triggers a reset and new image collection/transfer
--***See TRDB-D5M Hardware Specification page 5 for further detail of D5M signals***
--OUTPUTS:
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;
USE work.CAMERA_PACK.all;
ENTITY CameraCollectorTransmitter IS
PORT(
	i_clk              : IN STD_LOGIC;
	i_en               : IN STD_LOGIC;
	i_pixel_data       : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	i_lval             : IN STD_LOGIC;
	i_fval             : IN STD_LOGIC;
	--i_finished       : IN STD_LOGIC;
	i_pixel_read       : IN STD_LOGIC;
	o_pixel_data       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	o_valid_frame      : OUT STD_LOGIC;
	o_valid_pixel      : OUT STD_LOGIC
);
END CameraCollectorTransmitter;

ARCHITECTURE structural OF CameraCollectorTransmitter IS

--=======================================
-- Declare States
--=======================================
TYPE state_type IS (AWAIT_ENABLE, RESTART, AWAIT_FRAME, COLLECT, AWAIT_FINISH); 
SIGNAL nstate : state_type := AWAIT_ENABLE;
SIGNAL pstate : state_type := AWAIT_ENABLE;

--=======================================
-- Declare Components
--=======================================
COMPONENT RegFile_1_4_12 IS
PORT( 
	i_clk          : IN STD_LOGIC; --\/
	i_write_en     : IN STD_LOGIC; --\/
	i_write_select : IN STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0); --\/
	i_write_data   : IN STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0); --\/
	i_selectA      : IN STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0); --\/
	i_selectB      : IN STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0); --\/
	i_selectC      : IN STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0); --\/
	i_selectD      : IN STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0); --\/
	o_regA         : OUT STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0); --\/
	o_regB         : OUT STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0); --\/
	o_regC         : OUT STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0); --\/
	o_regD         : OUT STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0) --\/
); 
END COMPONENT;
COMPONENT ImageStore IS
PORT( 
	i_clk          : IN STD_LOGIC;
	i_swapped      : IN STD_LOGIC;
	i_finished     : IN STD_LOGIC;
	i_regA         : IN STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0); --\/
	i_regB         : IN STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0); --\/
	i_regC         : IN STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0); --\/
	i_regD         : IN STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0); --\/
	i_selectSram   : IN STD_LOGIC_VECTOR(GREYSCALE_REG_NUM_BIN -1 DOWNTO 0);
	o_selectA      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0); --\/
	o_selectB      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0); --\/
	o_selectC      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0); --\/
	o_selectD      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);  --\/
	o_sram         : OUT STD_LOGIC_VECTOR(GREYSCALE_PIXEL_WIDTH - 1 DOWNTO 0)
);
END COMPONENT;
--========================================
-- Signal Declarations
--========================================
SIGNAL pixelCount        : INTEGER := 0; --\/
SIGNAL rowCount          : INTEGER := 0; --\/
SIGNAL write_en_wire     : STD_LOGIC; --\/
SIGNAL write_select_wire : STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0); --\/
SIGNAL write_data_wire   : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0); --\/
SIGNAL selectA_wire      : STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0) := (OTHERS => '0'); --\/
SIGNAL selectB_wire      : STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0) := (OTHERS => '0'); --\/
SIGNAL selectC_wire      : STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0) := (OTHERS => '0'); --\/
SIGNAL selectD_wire      : STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0) := (OTHERS => '0'); --\/
SIGNAL out_regA_wire     : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0) := (OTHERS => '0'); --\/
SIGNAL out_regB_wire     : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0) := (OTHERS => '0'); --\/
SIGNAL out_regC_wire     : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0) := (OTHERS => '0'); --\/
SIGNAL out_regD_wire     : STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0) := (OTHERS => '0'); --\/
SIGNAL lval_delayed      : STD_LOGIC := '0'; --\/
SIGNAL lval_edge         : STD_LOGIC; --\/
SIGNAL i_swapped_wire    : STD_LOGIC; --\/
SIGNAL i_finished        : STD_LOGIC; --\/
SIGNAL send_count        : INTEGER := 0;
SIGNAL transmit_delay    : INTEGER := 0;
SIGNAL selectSram_wire   : STD_LOGIC_VECTOR(GREYSCALE_REG_NUM_BIN-1 DOWNTO 0); --\/
SIGNAL sram_wire         : STD_LOGIC_VECTOR(GREYSCALE_PIXEL_WIDTH - 1 DOWNTO 0); --\/

BEGIN
--========================================
-- Map Components
--========================================
----------========================================
---------- Front/Back Buffer
----------========================================
buffers: RegFile_1_4_12
PORT MAP(
	i_clk          => i_clk,
	i_write_en     => write_en_wire,
	i_write_select => write_select_wire,
	i_write_data   => i_pixel_data,
	i_selectA      => selectA_wire, 
	i_selectB      => selectB_wire,
	i_selectC      => selectC_wire,
	i_selectD      => selectD_wire,
	o_regA         => out_regA_wire,
	o_regB         => out_regB_wire,
	o_regC         => out_regC_wire,
	o_regD         => out_regD_wire
);
----------========================================
---------- ImageStore
----------========================================
store: ImageStore
PORT MAP(
	i_clk        => i_clk,
	i_swapped    => i_swapped_wire,
	i_finished   => i_finished,
	i_regA       => out_regA_wire,
	i_regB       => out_regB_wire,
	i_regC       => out_regC_wire,
	i_regD       => out_regD_wire,
	i_selectSram => selectSram_wire,
	o_selectA    => selectA_wire,
	o_selectB    => selectB_wire,
	o_selectC    => selectC_wire,
	o_selectD    => selectD_wire,
	o_sram       => sram_wire
);
--========================================
-- Local Architecture
--========================================
--CLOCK THE STATE
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
			nstate <= AWAIT_FRAME;
         
      WHEN AWAIT_FRAME =>
         IF (i_finished = '1') THEN
            nstate <= RESTART;
         ELSIF (i_fval = '1') THEN
            nstate <= COLLECT;
			ELSE
				nstate <= AWAIT_FRAME;
         END IF;
         
      WHEN COLLECT =>
         IF (i_finished = '1') THEN
            nstate <= RESTART;
			ELSIF (pixelCount = 307200) THEN
				nstate <= AWAIT_FINISH;
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

--grab a pixel if in COLLECT state and increment pixel count.
--also increments row count
collectPixel : PROCESS(i_clk, i_finished)
BEGIN
	IF(i_finished = '1') THEN
		pixelCount   <= 0;
		rowCount     <= 0;
		write_select_wire <= (OTHERS => '0');
	ELSIF(RISING_EDGE(i_clk)) THEN
		IF(pstate = COLLECT) THEN
			IF(i_lval = '1') THEN
				write_en_wire <= '1';
				pixelCount    <= pixelCount + 1;
				--increment the write address of the front/back buffer
				IF(UNSIGNED(write_select_wire) < ((PICTURE_WIDTH * 4) - 1)) THEN
					write_select_wire <= STD_LOGIC_VECTOR(UNSIGNED(write_select_wire) + 1 );
					IF(UNSIGNED(write_select_wire) = ((PICTURE_WIDTH * 2) - 1)) THEN
						i_swapped_wire <= '1';
					ELSIF(UNSIGNED(write_select_wire) = ((PICTURE_WIDTH * 4) - 1)) THEN
						i_swapped_wire <= '1';
					ELSE
						i_swapped_wire <= '0';
					END IF;
				ELSE
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
		END IF;
	END IF;
END PROCESS;

-------****WORKING HERE****-------
--transmit greyscale pixels if in AWAIT_FINISH state
transmit : PROCESS(i_clk, i_finished)
BEGIN
	IF(i_finished = '1') THEN
	
	ELSIF(RISING_EDGE(i_clk)) THEN
		IF(pstate = AWAIT_FINISH) THEN
			o_valid_frame <= '1';
			IF(transmit_delay = 0) THEN
				o_pixel_data <= sram_wire;
				transmit_delay <= transmit_delay + 1;

			ELSIF(transmit_delay = 1) THEN
				o_valid_pixel <= '1';
				transmit_delay <= transmit_delay + 1;
			
			ELSIF(transmit_delay < TRANSMIT_DELAY_MAX) THEN
				IF(i_pixel_read = '1') THEN
					o_valid_pixel <= '0';
					transmit_delay <= 0;
					send_count <= send_count + 1;
				ELSE
					o_valid_pixel <= '1';
					transmit_delay <= transmit_delay + 1;
					send_count <= send_count;
				END IF;
			ELSE
				
			END IF;
		ELSE
			o_valid_frame <= '0';
		END IF;
	END IF;
END PROCESS;

selectSram_wire <= STD_LOGIC_VECTOR(TO_UNSIGNED(send_count, selectSram_wire'LENGTH));

i_finished <= '1' WHEN send_count = (TRANSMIT_NUMBER - 1) ELSE
				  '1' WHEN transmit_delay = TRANSMIT_DELAY_MAX ELSE
	           '0';


--i_lval falling edge detection. lval_edge strobes high one clock period when
--i_lval toggles from high to low. This works because of the process rowCounting.
lval_edge <= lval_delayed AND NOT i_lval; 

--look at rowCount to see which buffer we are using. If rowCount is 0 or 1, we are in front buffer,
--if rowCount is 2 or 3, we are in back buffer.

END structural;
