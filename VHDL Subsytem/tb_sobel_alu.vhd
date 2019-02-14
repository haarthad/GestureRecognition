--==============================================================================
-- Project: Image Processing
-- Author : Kevin Hughes
-- Date   : Thursday, November 20th, 2018
-- Module : tb_sobel_controller.vhd
-- Desc.  : Testbench for the Sobel ALU
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--==============================================================================
-- TB_SOBEL_ALU Entity Block
--==============================================================================
entity TB_SOBEL_ALU is
end entity TB_SOBEL_ALU;

--==============================================================================
-- TB_SOBEL_ALU Architecture Block
--==============================================================================
architecture BEHAVIORAL of TB_SOBEL_ALU is

--==============================================================================
-- SOBEL_ALU Component Block
-- I_RXCX       : Sobel filter inputs
-- O_PIX_VALUE  : Sobel filter output
--==============================================================================
component SOBEL_ALU is
port(
	I_R1C1 : in std_logic_vector(7 downto 0); I_R1C2 : in std_logic_vector(7 downto 0); I_R1C3 : in std_logic_vector(7 downto 0);
	I_R2C1 : in std_logic_vector(7 downto 0);                                           I_R2C3 : in std_logic_vector(7 downto 0);
	I_R3C1 : in std_logic_vector(7 downto 0); I_R3C2 : in std_logic_vector(7 downto 0); I_R3C3 : in std_logic_vector(7 downto 0);
	O_PIX_VALUE  : out std_logic_vector(7 downto 0)
);end component;

--Test signal declarations
signal S_R1C1: std_logic_vector(7 downto 0);signal S_R1C2: std_logic_vector(7 downto 0);signal S_R1C3: std_logic_vector(7 downto 0);
signal S_R2C1: std_logic_vector(7 downto 0);                                            signal S_R2C3: std_logic_vector(7 downto 0);
signal S_R3C1: std_logic_vector(7 downto 0);signal S_R3C2: std_logic_vector(7 downto 0);signal S_R3C3: std_logic_vector(7 downto 0);
signal S_PIX_VALUE : std_logic_vector(7 downto 0);

begin

--Matrix assignment
S_R1C1 <= std_logic_vector(to_unsigned(5, S_R1C1'length)); S_R1C2 <= std_logic_vector(to_unsigned(15, S_R1C1'length));S_R1C3 <= std_logic_vector(to_unsigned(20, S_R1C1'length));
S_R2C1 <= std_logic_vector(to_unsigned(3, S_R1C1'length));                                                            S_R2C3 <= std_logic_vector(to_unsigned(25, S_R1C1'length));
S_R3C1 <= std_logic_vector(to_unsigned(4, S_R1C1'length)); S_R3C2 <= std_logic_vector(to_unsigned(7, S_R1C1'length)); S_R3C3 <= std_logic_vector(to_unsigned(37, S_R1C1'length));

--Sobel ALU port map
TEST : SOBEL_ALU
port map(
	I_R1C1 => S_R1C1, I_R1C2 => S_R1C2, I_R1C3 => S_R1C3,
	I_R2C1 => S_R2C1,                   I_R2C3 => S_R2C3,
	I_R3C1 => S_R3C1, I_R3C2 => S_R3C2, I_R3C3 => S_R3C3,
	O_PIX_VALUE => S_PIX_VALUE
);

end architecture BEHAVIORAL;