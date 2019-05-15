--==============================================================================
-- Project: Pixel Processing
-- Author : Kevin Hughes
-- Date   : Monday, December 17th, 2018
-- Module : sobel_combination
-- Desc.  : Combines a horizontal and vertical sobel value.
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--==============================================================================
-- SOBEL_COMBINATION Entity Block
-- I_VERTICAL_EDGE    : Vertical edge detection magnitude
-- I_HORIZONTAL_EDGE  : Horizontal edge detection magnitude
-- O_EDGE_VALUE       : Combined edge detection magnitude squared
--==============================================================================
entity SOBEL_COMBINATION is
port(
	I_VERTICAL_EDGE   : in std_logic_vector(9 downto 0);
	I_HORIZONTAL_EDGE : in std_logic_vector(9 downto 0);
	O_EDGE_VALUE      : out std_logic_vector(20 downto 0)
);end entity SOBEL_COMBINATION;

--==============================================================================
-- SOBEL_COMBINATION Architecture Block
--==============================================================================
architecture RTL of SOBEL_COMBINATION is

signal VERTICAL_SQUARED   : unsigned(20 downto 0);
signal HORIZONTAL_SQUARED : unsigned(20 downto 0);

begin

VERTICAL_SQUARED   <=  '0' & (unsigned(I_VERTICAL_EDGE)   * unsigned(I_VERTICAL_EDGE));
HORIZONTAL_SQUARED <=  '0' & (unsigned(I_HORIZONTAL_EDGE) * unsigned(I_HORIZONTAL_EDGE));

O_EDGE_VALUE <= std_logic_vector(VERTICAL_SQUARED + HORIZONTAL_SQUARED);

end architecture RTL;