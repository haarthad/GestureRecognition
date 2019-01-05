--Owner: Senior Design Team Delta
--Component: ImageStore
--Description: This component works within the CameraCollector component,
--					and works with the RegFile_1_4_12 to take pixels from the
--					RegFile_1_4_12 front/back buffer, convert them to greyscale,
--					and store them in SRAM. When full, it sets o_full high. This
--					component resets upon recieving the i_finished pulse.
--Author: Michael Dougherty
--Start Date: 12/13/2018

--INPUTS:
--i_clk          : input clock
--i_swapped      : a pulse indicates the font/back buffer swapped
--i_finished     : a pulse that indicates a new image can be processed and stored
--i_regA         : colored pixel A from front/back buffer
--i_regB         : colored pixel B from front/back buffer
--i_regC         : colored pixel C from front/back buffer
--i_regD         : colored pixel D from front/back buffer
--OUTPUTS:
--o_selectA      : select colored pixel A from front/back buffer
--o_selectB      : select colored pixel B from front/back buffer
--o_selectC      : select colored pixel C from front/back buffer
--o_selectD      : select colored pixel D from front/back buffer``

LIBRARY ieee;
USE ieee. std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee. std_logic_unsigned.all;
USE work.CAMERA_PACK.all;
 
ENTITY ImageStore IS

PORT( 
	i_clk          : IN STD_LOGIC;
	i_swapped      : IN STD_LOGIC;
	i_finished     : IN STD_LOGIC;
	i_regA         : IN STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	i_regB         : IN STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	i_regC         : IN STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	i_regD         : IN STD_LOGIC_VECTOR(PIXEL_WIDTH - 1 DOWNTO 0);
	o_selectA      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	o_selectB      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	o_selectC      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	o_selectD      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0)
);
END ImageStore;
 
ARCHITECTURE structural OF ImageStore IS
--========================================
-- SRAM Declaration
--========================================
TYPE reg_array IS ARRAY(0 TO ((GREYSCALE_PICTURE_WIDTH * GREYSCALE_PICTURE_HEIGHT) - 1)) OF STD_LOGIC_VECTOR((GREYSCALE_PIXEL_WIDTH - 1) DOWNTO 0);
SIGNAL regFile : reg_array;
--=======================================
-- States Declaration
--=======================================
TYPE state_type IS (RESTART, AWAIT_SWAP_FRONT, DRAIN_FRONT, AWAIT_SWAP_BACK, DRAIN_BACK); 
SIGNAL nstate : state_type := RESTART;
SIGNAL pstate : state_type := RESTART;
--========================================
-- Signal Declarations
--========================================
--the set of regX signals will be used to grab four pixels at a time
--from the pixels stored in a Bayer pattern to convert them to a single 
--greyscale pixel
SIGNAL regA           : INTEGER := 0;
SIGNAL regB           : INTEGER := 1;
SIGNAL regC           : INTEGER := 640;
SIGNAL regD           : INTEGER := 641;
SIGNAL sramIndex      : INTEGER := 0;
SIGNAL greyscalePixel : STD_LOGIC_VECTOR(GREYSCALE_PIXEL_WIDTH - 1 DOWNTO 0);
SIGNAL rowDone        : STD_LOGIC := '0';
--========================================
-- Local Architecture
--========================================
BEGIN
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
      WHEN RESTART => 
         IF (i_swapped = '1') THEN
            nstate <= DRAIN_FRONT;
         ELSE
            nstate <= RESTART;
         END IF;
         
      WHEN DRAIN_FRONT => 
			IF (i_finished = '1') THEN
				nstate <= RESTART;
			ELSIF (rowDone = '1') THEN
				nstate <= AWAIT_SWAP_BACK;
			ELSE 
				nstate <= DRAIN_FRONT;
			END IF;
         
      WHEN AWAIT_SWAP_BACK =>
			IF (i_finished = '1') THEN
            nstate <= RESTART;
         ELSIF (i_swapped = '1') THEN
            nstate <= DRAIN_BACK;
			ELSE
				nstate <= AWAIT_SWAP_BACK;
         END IF;
         
      WHEN DRAIN_BACK =>
			IF (i_finished = '1') THEN
				nstate <= RESTART;
         ELSIF (rowDone = '1') THEN
            nstate <= AWAIT_SWAP_FRONT;
			ELSE
				nstate <= DRAIN_BACK;
         END IF;
      
      WHEN AWAIT_SWAP_FRONT =>
         IF (i_finished = '1') THEN
            nstate <= RESTART;
			ELSIF (i_swapped = '1') THEN
				nstate <= DRAIN_FRONT;
			ELSE
				nstate <= AWAIT_SWAP_FRONT;
			END IF;
         
		-- Always have an others case
      WHEN OTHERS =>
         nstate <= RESTART;
   END CASE;
END PROCESS;

--grab a pixel if in COLLECT state and increment pixel count.
--also increments row count
PROCESS(i_clk, i_finished)
BEGIN
	IF(i_finished = '1') THEN
		regA      <= 0;
		regB      <= 1;
		regC      <= 640;
		regD      <= 641;
		sramIndex <= 0;
	ELSIF(RISING_EDGE(i_clk)) THEN
		IF(pstate = DRAIN_FRONT) THEN
			--grab four Bayer pattern pixels and convert them to a single greyscale pixel
			--it looks nasty, but there are just a lot of type conversions
			greyscalePixel <= STD_LOGIC_VECTOR(TO_UNSIGNED((((TO_INTEGER(UNSIGNED(i_regA)) + TO_INTEGER(UNSIGNED(i_regD)))/2)+TO_INTEGER(UNSIGNED(i_regB))+TO_INTEGER(UNSIGNED(i_regC)))/3,greyscalePixel'LENGTH));
			IF(regB < 639) THEN 
				regA <= regA + 2;
				regB <= regB + 2;
				regC <= regC + 2;
				regD <= regD + 2;
			ELSE
				rowDone <= '1';
			END IF;
		ELSIF(pstate = AWAIT_SWAP_BACK) THEN
			rowDone <= '0';
			regA      <= 1280;
			regB      <= 1281;
			regC      <= 1920;
			regD      <= 1921;
		ELSIF(pstate = DRAIN_BACK) THEN
			--grab four Bayer pattern pixels and convert them to a single greyscale pixel
			--it looks nasty, but there are just a lot of type conversions
			greyscalePixel <= STD_LOGIC_VECTOR(TO_UNSIGNED((((TO_INTEGER(UNSIGNED(i_regA)) + TO_INTEGER(UNSIGNED(i_regD)))/2)+TO_INTEGER(UNSIGNED(i_regB))+TO_INTEGER(UNSIGNED(i_regC)))/3,greyscalePixel'LENGTH));
			IF(regB < 1919) THEN 
				regA <= regA + 2;
				regB <= regB + 2;
				regC <= regC + 2;
				regD <= regD + 2;
			ELSE
				rowDone <= '1';
			END IF;
		ELSIF(pstate = AWAIT_SWAP_FRONT) THEN
			rowDone   <= '0';
			regA      <= 0;
			regB      <= 1;
			regC      <= 640;
			regD      <= 641;
		END IF;
		regFile(sramIndex) <= greyscalePixel;
	END IF;
END PROCESS;

o_selectA <= STD_LOGIC_VECTOR(TO_UNSIGNED(regA, o_selectA'LENGTH));
o_selectB <= STD_LOGIC_VECTOR(TO_UNSIGNED(regB, o_selectB'LENGTH));
o_selectC <= STD_LOGIC_VECTOR(TO_UNSIGNED(regC, o_selectC'LENGTH));
o_selectD <= STD_LOGIC_VECTOR(TO_UNSIGNED(regD, o_selectD'LENGTH));

END structural;