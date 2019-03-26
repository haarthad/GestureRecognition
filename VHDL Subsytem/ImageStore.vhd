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
--i_selectSram   : select which greyscale pixel stored in SRAM to output
--OUTPUTS:
--o_selectA      : select colored pixel A from front/back buffer
--o_selectB      : select colored pixel B from front/back buffer
--o_selectC      : select colored pixel C from front/back buffer
--o_selectD      : select colored pixel D from front/back buffer
--o_sram         : greyscale pixel stored in SRAM selected by i_selectSram

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
	i_selectSram   : IN STD_LOGIC_VECTOR(GREYSCALE_REG_NUM_BIN - 1 DOWNTO 0);
	o_selectA      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	o_selectB      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	o_selectC      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	o_selectD      : OUT STD_LOGIC_VECTOR(REG_NUM_BIN - 1 DOWNTO 0);
	o_sram         : OUT STD_LOGIC_VECTOR(GREYSCALE_PIXEL_WIDTH - 1 DOWNTO 0)
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
SIGNAL regA              : INTEGER := 0;
SIGNAL regB              : INTEGER := 1;
SIGNAL regC              : INTEGER := 640;
SIGNAL regD              : INTEGER := 641;
SIGNAL sramIndex         : INTEGER := 0;
SIGNAL sramIndex_delayed : INTEGER := 0;
SIGNAL greyscalePixel    : STD_LOGIC_VECTOR(GREYSCALE_PIXEL_WIDTH - 1 DOWNTO 0);
SIGNAL rowDone           : STD_LOGIC := '0';
SIGNAL greyscaleTemp     : STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL i_regA_math       : STD_LOGIC_VECTOR(PIXEL_WIDTH + 1 DOWNTO 0);
SIGNAL i_regB_math       : STD_LOGIC_VECTOR(PIXEL_WIDTH + 1 DOWNTO 0);
SIGNAL i_regC_math       : STD_LOGIC_VECTOR(PIXEL_WIDTH + 1 DOWNTO 0);
SIGNAL i_regD_math       : STD_LOGIC_VECTOR(PIXEL_WIDTH + 1 DOWNTO 0);
SIGNAL greyscaleTemp1    : STD_LOGIC_VECTOR(13 DOWNTO 0);
SIGNAL greyscaleTemp2    : STD_LOGIC_VECTOR(13 DOWNTO 0);
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

PROCESS(i_clk, i_finished)
BEGIN
	IF(i_finished = '1') THEN
		regA      <= 0;
		regB      <= 1;
		regC      <= PICTURE_WIDTH;
		regD      <= PICTURE_WIDTH + 1;
		sramIndex <= 0;
	ELSIF(FALLING_EDGE(i_clk)) THEN
		IF(pstate = DRAIN_FRONT) THEN
			--grab four Bayer pattern pixels and convert them to a single greyscale pixel
			--it looks nasty, but there are just a lot of type conversions
			greyscaleTemp <= greyscaleTemp1(11 DOWNTO 0);
			IF(sramIndex < (TRANSMIT_NUMBER - 1)) THEN
				IF(regB <= PICTURE_WIDTH - 1) THEN 
					sramIndex <= sramIndex + 1;
				ELSE
					sramIndex <= sramIndex;
				END IF;
			ELSE
				sramIndex <= sramIndex;
			END IF;
			IF(regB < PICTURE_WIDTH - 1) THEN 
				regA <= regA + 2;
				regB <= regB + 2;
				regC <= regC + 2;
				regD <= regD + 2;
			ELSE
				rowDone <= '1';
			END IF;
		ELSIF(pstate = AWAIT_SWAP_BACK) THEN
			rowDone <= '0';
			regA      <= PICTURE_WIDTH * 2;
			regB      <= (PICTURE_WIDTH * 2) + 1;
			regC      <= (PICTURE_WIDTH * 3);
			regD      <= (PICTURE_WIDTH * 3) + 1;
			sramIndex <= sramIndex;
		ELSIF(pstate = DRAIN_BACK) THEN
			--grab four Bayer pattern pixels and convert them to a single greyscale pixel
			--it looks nasty, but there are just a lot of type conversions
			greyscaleTemp <= greyscaleTemp2(11 DOWNTO 0);
			IF(sramIndex < (TRANSMIT_NUMBER - 1)) THEN
				IF(regB <= (PICTURE_WIDTH * 3) - 1) THEN 
					sramIndex <= sramIndex + 1;
				ELSE
					sramIndex <= sramIndex;
				END IF;
			ELSE 
				sramIndex <= sramIndex;
			END IF;
			IF(regB < (PICTURE_WIDTH * 3) - 1) THEN 
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
			regC      <= PICTURE_WIDTH;
			regD      <= PICTURE_WIDTH + 1;
			sramIndex <= sramIndex;
		END IF;
		sramIndex_delayed <= sramIndex;
		regFile(sramIndex_delayed) <= greyscalePixel;
		o_sram <=  regFile(TO_INTEGER(UNSIGNED(i_selectSram)));
	END IF;
END PROCESS;

greyscalePixel <= greyscaleTemp(9 downto 2);--(11 DOWNTO 4);

o_selectA <= STD_LOGIC_VECTOR(TO_UNSIGNED(regA, o_selectA'LENGTH));
o_selectB <= STD_LOGIC_VECTOR(TO_UNSIGNED(regB, o_selectB'LENGTH));
o_selectC <= STD_LOGIC_VECTOR(TO_UNSIGNED(regC, o_selectC'LENGTH));
o_selectD <= STD_LOGIC_VECTOR(TO_UNSIGNED(regD, o_selectD'LENGTH));

i_regA_math <= "00" & i_regA;
i_regB_math <= "00" & i_regB;
i_regC_math <= "00" & i_regC;
i_regD_math <= "00" & i_regD;

greyscaleTemp1 <= STD_LOGIC_VECTOR(UNSIGNED((((UNSIGNED(i_regA_math) + UNSIGNED(i_regD_math))/2)+UNSIGNED(i_regB_math)+UNSIGNED(i_regC_math))/3));
greyscaleTemp2 <= STD_LOGIC_VECTOR(UNSIGNED((((UNSIGNED(i_regA_math) + UNSIGNED(i_regD_math))/2)+UNSIGNED(i_regB_math)+UNSIGNED(i_regC_math))/3));

END structural;