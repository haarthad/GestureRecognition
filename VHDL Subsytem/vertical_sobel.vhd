--==============================================================================
-- Project: Pixel Processing
-- Author : Kevin Hughes
-- Date   : Monday, December 17th, 2018
-- Module : verical_sobel
-- Desc.  : Calculates the vertical Sobel output of a given matrix.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--==============================================================================
-- VERTICAL_SOBEL Entity Block
-- I_RXCX            : 3x3 Image Matrix, minus middle column
-- O_VERTICAL_EDGE   : Vertical edge detection magnitude
--==============================================================================
entity VERTICAL_SOBEL is
port(
	I_R1C1 : in std_logic_vector(7 downto 0); I_R1C3 : in std_logic_vector(7 downto 0);
	I_R2C1 : in std_logic_vector(7 downto 0); I_R2C3 : in std_logic_vector(7 downto 0);
	I_R3C1 : in std_logic_vector(7 downto 0); I_R3C3 : in std_logic_vector(7 downto 0);
	O_VERTICAL_EDGE : out std_logic_vector(9 downto 0)
);end entity VERTICAL_SOBEL;

--==============================================================================
-- VERTICAL_SOBEL Architecture Block
--==============================================================================
architecture RTL of VERTICAL_SOBEL is

--Input resize signals
signal S_R1C1 : std_logic_vector(9 downto 0); signal S_R1C3 : std_logic_vector(9 downto 0);
signal S_R2C1 : std_logic_vector(9 downto 0); signal S_R2C3 : std_logic_vector(9 downto 0);
signal S_R3C1 : std_logic_vector(9 downto 0); signal S_R3C3 : std_logic_vector(9 downto 0);

--Resulting convolution signal
signal CONVOLUTION : signed(9 downto 0);

begin

--Resize the input signals, multiply where appropriate
S_R1C1 <= "00" & I_R1C1;       S_R1C3 <= "00" & I_R1C3;
S_R2C1 <= '0'  & I_R2C1 & '0'; S_R2C3 <= '0'  & I_R2C3 & '0';
S_R3C1 <= "00" & I_R3C1;       S_R3C3 <= "00" & I_R3C3;

--Perform convolution operation
CONVOLUTION <= signed(S_R1C3) + signed(S_R2C3) + signed(S_R3C3) 
				-  signed(S_R1C1) - signed(S_R2C1) - signed(S_R3C1);

--Perform convolution operation
O_VERTICAL_EDGE <= std_logic_vector(abs(CONVOLUTION));

end architecture RTL;
