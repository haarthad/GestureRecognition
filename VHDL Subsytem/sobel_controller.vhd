--==============================================================================
-- Project: Pixel Processing
-- Author : Kevin Hughes
-- Date   : Monday, December 17th, 2018
-- Module : sobel_controller
-- Desc.  : Sends pixels through the Sobel ALU and lookup table accordingly.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.CAMERA_PACK.all;

--==============================================================================
-- SOBEL_CONTROLLER Entity Block
-- I_RST      : Reset
-- I_CLK      : 50[MHz] clock
-- I_SOBEL_EN : Begin passing pixels to Sobel ALU
-- O_DONE     : Pixel passing complete
-- O_RXCX     : Pixel addresses
--==============================================================================
entity SOBEL_CONTROLLER is
port(
	I_RST      : in std_logic;
	I_CLK      : in std_logic;
	I_SOBEL_EN : in std_logic;
	O_DONE: out std_logic;
	O_R1C1: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0); O_R1C2: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0); O_R1C3: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0);
	O_R2C1: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0);                                                                   O_R2C3: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0);
	O_R3C1: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0); O_R3C2: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0); O_R3C3: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0)
);end entity SOBEL_CONTROLLER;

--==============================================================================
-- SOBEL_CONTROLLER Architecture Block
--==============================================================================
architecture RTL of SOBEL_CONTROLLER is

--Transmission state signal declarations
signal TRANSMIT: std_logic := '0';
signal START   : std_logic := '1';
signal DONE    : std_logic := '0';

--Memory index signal declarations
signal X_INDEX: integer range 0 to GREYSCALE_PICTURE_WIDTH  := 0;
signal Y_INDEX: integer range 0 to GREYSCALE_PICTURE_HEIGHT := 0;
constant ROW1_RESET : integer := 0;
constant ROW2_RESET : integer := GREYSCALE_PICTURE_WIDTH;
constant ROW3_RESET : integer := GREYSCALE_PICTURE_WIDTH * 2;
signal ROW1COL1: integer range 0 to TRANSMIT_NUMBER := ROW1_RESET; signal ROW1COL2: integer range 0 to TRANSMIT_NUMBER := ROW1_RESET + 1; signal ROW1COL3: integer range 0 to TRANSMIT_NUMBER := ROW1_RESET + 2;
signal ROW2COL1: integer range 0 to TRANSMIT_NUMBER := ROW2_RESET;                                                                        signal ROW2COL3: integer range 0 to TRANSMIT_NUMBER := ROw2_RESET + 2;
signal ROW3COL1: integer range 0 to TRANSMIT_NUMBER := ROW3_RESET; signal ROW3COL2: integer range 0 to TRANSMIT_NUMBER := ROW3_RESET + 1; signal ROW3COL3: integer range 0 to TRANSMIT_NUMBER := ROW3_RESET + 2;

begin

--Sobel filter matrix updater
ADDR_UPDATE: process(I_RST, I_CLK)
begin
	if(I_RST = '0') then
		TRANSMIT <= '0';
		X_INDEX  <= 0;
		Y_INDEX  <= 0;
		ROW1COL1 <= ROW1_RESET; ROW1COL2 <= ROW1_RESET + 1; ROW1COL3 <= ROW1_RESET + 2;
		ROW2COL1 <= ROW2_RESET;                             ROW2COL3 <= ROW2_RESET + 2;
		ROW3COL1 <= ROW3_RESET; ROW3COL2 <= ROW3_RESET + 1; ROW3COL3 <= ROW3_RESET + 2;
		START    <= '0';
		DONE     <= '0';
	elsif rising_edge(I_CLK) then
		--Transmit detection
		if(I_SOBEL_EN = '1') then
			TRANSMIT <= '1';
		end if;
		
		--Currently transmitting pixels
		if(TRANSMIT = '1') then
			--Check if first pixel is being transmitted
			if(START = '1') then
				X_INDEX  <= 0;
				Y_INDEX  <= 0;
				ROW1COL1 <= ROW1_RESET; ROW1COL2 <= ROW1_RESET + 1; ROW1COL3 <= ROW1_RESET + 2;
				ROW2COL1 <= ROW2_RESET;                             ROW2COL3 <= ROW2_RESET + 2;
				ROW3COL1 <= ROW3_RESET; ROW3COL2 <= ROW3_RESET + 1; ROW3COL3 <= ROW3_RESET + 2;
				START    <= '0';
				DONE     <= '0';
			--If not, adjust the indexes accordingly
			else
				--End of horizontal reached
				if(X_INDEX + 2 >= GREYSCALE_PICTURE_WIDTH - 1) then
					--End of vertical reached
					if(Y_INDEX + 2 >= GREYSCALE_PICTURE_HEIGHT - 1) then
						TRANSMIT <= '0';
						X_INDEX  <= 0;
						Y_INDEX  <= 0;
						ROW1COL1 <= ROW1_RESET; ROW1COL2 <= ROW1_RESET + 1; ROW1COL3 <= ROW1_RESET + 2;
						ROW2COL1 <= ROW2_RESET;                             ROW2COL3 <= ROW2_RESET + 2;
						ROW3COL1 <= ROW3_RESET; ROW3COL2 <= ROW3_RESET + 1; ROW3COL3 <= ROW3_RESET + 2;
						START    <= '0';
						DONE     <= '1';
					--End of vertical not yet reached
					else
						X_INDEX  <= 0;
						Y_INDEX  <= Y_INDEX + 1;
						ROW1COL1 <= ROW1COL1 + 3; ROW1COL2 <= ROW1COL2 + 3; ROW1COL3 <= ROW1COL3 + 3;
						ROW2COL1 <= ROW2COL1 + 3;                           ROW2COL3 <= ROW2COL3 + 3;
						ROW3COL1 <= ROW3COL1 + 3; ROW3COL2 <= ROW3COL2 + 3; ROW3COL3 <= ROW3COL3 + 3;
						START    <= '0';
						DONE     <= '0';
					end if;
				--End of horizontal not yet reached
				else
					X_INDEX  <= X_INDEX + 1;
					Y_INDEX  <= Y_INDEX;
					ROW1COL1 <= ROW1COL1 + 1; ROW1COL2 <= ROW1COL2 + 1; ROW1COL3 <= ROW1COL3 + 1;
					ROW2COL1 <= ROW2COL1 + 1;                           ROW2COL3 <= ROW2COL3 + 1;
					ROW3COL1 <= ROW3COL1 + 1; ROW3COL2 <= ROW3COL2 + 1; ROW3COL3 <= ROW3COL3 + 1;
					START    <= '0';
					DONE     <= '0';
				end if;
			end if;
		--Transmission not in progress
		else
			 X_INDEX  <= 0;
		    Y_INDEX  <= 0;
			 ROW1COL1 <= ROW1_RESET; ROW1COL2 <= ROW1_RESET + 1; ROW1COL3 <= ROW1_RESET + 2;
			 ROW2COL1 <= ROW2_RESET;                             ROW2COL3 <= ROW2_RESET + 2;
			 ROW3COL1 <= ROW3_RESET; ROW3COL2 <= ROW3_RESET + 1; ROW3COL3 <= ROW3_RESET + 2;
		    START    <= '1';
		    DONE     <= '0';
		end if;
	end if;
end process;

--Address output assignments 
O_R1C1 <= std_logic_vector(to_unsigned(ROW1COL1, O_R1C1'length)); O_R1C2 <= std_logic_vector(to_unsigned(ROW1COL2, O_R1C2'length)); O_R1C3 <= std_logic_vector(to_unsigned(ROW1COL3, O_R1C3'length));
O_R2C1 <= std_logic_vector(to_unsigned(ROW2COL1, O_R2C1'length));                                                                   O_R2C3 <= std_logic_vector(to_unsigned(ROW2COL3, O_R2C3'length));
O_R3C1 <= std_logic_vector(to_unsigned(ROW3COL1, O_R3C1'length)); O_R3C2 <= std_logic_vector(to_unsigned(ROW3COL2, O_R3C2'length)); O_R3C3 <= std_logic_vector(to_unsigned(ROW3COL3, O_R3C3'length));

--Done output assignment
O_DONE <= DONE;

end architecture RTL;