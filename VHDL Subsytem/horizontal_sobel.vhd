--==============================================================================
-- Project: Pixel Processing
-- Author : Kevin Hughes
-- Date   : Monday, December 17th, 2018
-- Module : horizontal_sobel
-- Desc.  : Calculates the horizontal Sobel output of a given matrix.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--==============================================================================
-- HORIZONTAL_SOBEL Entity Block
-- I_RXCX            : 3x3 Image Matrix, minus middle row
-- O_HORIZONTAL_EDGE : Horizontal edge detection magnitude
--==============================================================================
entity HORIZONTAL_SOBEL is
port(
	I_R1C1 : in std_logic_vector(7 downto 0); I_R1C2 : in std_logic_vector(7 downto 0); I_R1C3 : in std_logic_vector(7 downto 0);
	I_R3C1 : in std_logic_vector(7 downto 0); I_R3C2 : in std_logic_vector(7 downto 0); I_R3C3 : in std_logic_vector(7 downto 0);
	O_HORIZONTAL_EDGE : out std_logic_vector(9 downto 0)
);end entity HORIZONTAL_SOBEL;

--==============================================================================
-- HORIZONTAL_SOBEL Architecture Block
--==============================================================================
architecture RTL of HORIZONTAL_SOBEL is

--Input resize signals
signal S_R1C1 : std_logic_vector(9 downto 0); signal S_R1C2 : std_logic_vector(9 downto 0); signal S_R1C3 : std_logic_vector(9 downto 0);
signal S_R3C1 : std_logic_vector(9 downto 0); signal S_R3C2 : std_logic_vector(9 downto 0); signal S_R3C3 : std_logic_vector(9 downto 0);

--Resulting convolution signal
signal CONVOLUTION : signed(9 downto 0);

begin

--Resize the input signals, multiply where appropriate
S_R1C1 <= "00" & I_R1C1; S_R1C2 <= '0' & I_R1C2 & '0'; S_R1C3 <= "00" & I_R1C3;
S_R3C1 <= "00" & I_R3C1; S_R3C2 <= '0' & I_R3C2 & '0'; S_R3C3 <= "00" & I_R3C3;

--Perform convolution operation
CONVOLUTION <= signed(S_R3C1) + signed(S_R3C2) + signed(S_R3C3)
             - signed(S_R1C1) - signed(S_R1C2) - signed(S_R1C3);

--Convert to absolute value and output 
O_HORIZONTAL_EDGE <= std_logic_vector(abs(CONVOLUTION));

end architecture RTL;
