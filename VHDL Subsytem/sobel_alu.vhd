--==============================================================================
-- Project: Pixel Processing
-- Author : Kevin Hughes
-- Date   : Monday, December 17th, 2018
-- Module : sobel_alu
-- Desc.  : Complete Sobel ALU Unit, combination of all other components
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;

--==============================================================================
-- SOBEL_ALU Entity Block
-- I_RXCX       : Sobel filter inputs
-- O_PIX_VALUE  : Sobel filter output
--==============================================================================
entity SOBEL_ALU is
port(
	I_R1C1 : in std_logic_vector(7 downto 0); I_R1C2 : in std_logic_vector(7 downto 0); I_R1C3 : in std_logic_vector(7 downto 0);
	I_R2C1 : in std_logic_vector(7 downto 0);                                           I_R2C3 : in std_logic_vector(7 downto 0);
	I_R3C1 : in std_logic_vector(7 downto 0); I_R3C2 : in std_logic_vector(7 downto 0); I_R3C3 : in std_logic_vector(7 downto 0);
	O_PIX_VALUE  : out std_logic_vector(7 downto 0)
); end entity SOBEL_ALU;

--==============================================================================
-- SOBEL_ALU Architecture Block
--==============================================================================
architecture RTL of SOBEL_ALU is

--==============================================================================
-- VERTICAL_SOBEL Component Block
-- I_RXCX            : 3x3 Image Matrix, minus middle column
-- O_VERTICAL_EDGE   : Vertical edge detection magnitude
--==============================================================================
component VERTICAL_SOBEL is
port(
	I_R1C1 : in std_logic_vector(7 downto 0); I_R1C3 : in std_logic_vector(7 downto 0);
	I_R2C1 : in std_logic_vector(7 downto 0); I_R2C3 : in std_logic_vector(7 downto 0);
	I_R3C1 : in std_logic_vector(7 downto 0); I_R3C3 : in std_logic_vector(7 downto 0);
	O_VERTICAL_EDGE : out std_logic_vector(9 downto 0)
);end component;

--==============================================================================
-- HORIZONTAL_SOBEL Component Block
-- I_RXCX            : 3x3 Image Matrix, minus middle row
-- O_HORIZONTAL_EDGE : Horizontal edge detection magnitude
--==============================================================================
component HORIZONTAL_SOBEL is
port(
	I_R1C1 : in std_logic_vector(7 downto 0); I_R1C2 : in std_logic_vector(7 downto 0); I_R1C3 : in std_logic_vector(7 downto 0);
	I_R3C1 : in std_logic_vector(7 downto 0); I_R3C2 : in std_logic_vector(7 downto 0); I_R3C3 : in std_logic_vector(7 downto 0);
	O_HORIZONTAL_EDGE : out std_logic_vector(9 downto 0)
);end component;

--==============================================================================
-- SOBEL_COMBINATION Component Block
-- I_VERTICAL_EDGE    : Vertical edge detection magnitude
-- I_HORIZONTAL_EDGE  : Horizontal edge detection magnitude
-- O_EDGE_VALUE       : Combined edge detection magnitude squared
--==============================================================================
component SOBEL_COMBINATION is
port(
	I_VERTICAL_EDGE   : in std_logic_vector(9 downto 0);
	I_HORIZONTAL_EDGE : in std_logic_vector(9 downto 0);
	O_EDGE_VALUE      : out std_logic_vector(20 downto 0)
);end component;

--==============================================================================
-- LOOKUP_TABLE Component Block
-- I_EDGE_VALUE : Combined edge detection magnitude squared
-- O_PIX_VALUE  : Combined edge detection magnitude
--==============================================================================
component LOOKUP_TABLE is
port(
	I_EDGE_VALUE : in std_logic_vector(20 downto 0);
	O_PIX_VALUE  : out std_logic_vector(7 downto 0)
);end component;

--Intercomponent signal declarations
signal S_VERTICAL_EDGE   : std_logic_vector(9 downto 0);
signal S_HORIZONTAL_EDGE : std_logic_vector(9 downto 0);
signal S_EDGE_VALUE      : std_logic_vector(20 downto 0); 

begin

--Vertical sobel port map
VS : VERTICAL_SOBEL
port map(
	I_R1C1 => I_R1C1, I_R1C3 => I_R1C3,
	I_R2C1 => I_R2C1, I_R2C3 => I_R2C3,
	I_R3C1 => I_R3C1, I_R3C3 => I_R3C3,
	O_VERTICAL_EDGE => S_VERTICAL_EDGE
);

--Horizontal sobel port map
HS : HORIZONTAL_SOBEL
port map(
	I_R1C1 => I_R1C1, I_R1C2 => I_R1C2, I_R1C3 => I_R1C3,
	I_R3C1 => I_R3C1, I_R3C2 => I_R3C2, I_R3C3 => I_R3C3,
	O_HORIZONTAL_EDGE => S_HORIZONTAL_EDGE
);

--Sobel combination port map
SC : SOBEL_COMBINATION
port map(
	I_VERTICAL_EDGE   => S_VERTICAL_EDGE,
	I_HORIZONTAL_EDGE => S_HORIZONTAL_EDGE,
	O_EDGE_VALUE => S_EDGE_VALUE
);

--Lookup table port map
LT : LOOKUP_TABLE
port map(
	I_EDGE_VALUE => S_EDGE_VALUE,
	O_PIX_VALUE  => O_PIX_VALUE
);

end architecture;