--==============================================================================
-- Project: Image Processing
-- Author : Kevin Hughes
-- Date   : Thursday, November 20th, 2018
-- Module : tb_sobel_controller.vhd
-- Desc.  : Testbench for controlling pixel data from memory to Sobel ALU
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use work.CAMERA_PACK.all;

--==============================================================================
-- TB_SOBEL_CONTROLLER Entity Block
--==============================================================================
entity TB_SOBEL_CONTROLLER is
end entity TB_SOBEL_CONTROLLER;

--==============================================================================
-- TB_SOBEL_CONTROLLER Architecture Block
--==============================================================================
architecture BEHAVIORAL of TB_SOBEL_CONTROLLER is

--==============================================================================
-- SOBEL_CONTROLLER Component Block
-- I_RST      : Reset
-- I_CLK      : 50[MHz] clock
-- I_SOBEL_EN : Begin passing pixels to Sobel ALU
-- O_DONE     : Pixel passing complete
-- O_RXCX     : Pixel addresses
--==============================================================================
component SOBEL_CONTROLLER is
port(
	I_RST      : in std_logic;
	I_CLK      : in std_logic;
	I_SOBEL_EN : in std_logic;
	O_DONE: out std_logic;
	O_R1C1: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0); O_R1C2: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0); O_R1C3: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0);
	O_R2C1: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0);                                                                   O_R2C3: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0);
	O_R3C1: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0); O_R3C2: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0); O_R3C3: out std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0)
);end component;

--Test signal declarations
signal S_RST : std_logic;
signal S_CLK : std_logic := '0';
signal S_EN  : std_logic;
signal S_DONE: std_logic;
signal S_R1C1: std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0);signal S_R1C2: std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0);signal S_R1C3: std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0);
signal S_R2C1: std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0);                                                                    signal S_R2C3: std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0);
signal S_R3C1: std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0);signal S_R3C2: std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0);signal S_R3C3: std_logic_vector(GREYSCALE_REG_NUM_BIN - 1 downto 0);

--Timing constant declaration
constant T_CLK : time := 20 ns;

begin

--Reset assignment
S_RST <= '0', '1' after 5*T_CLK;

--Clock assignment
CLOCK: process
begin
	wait for T_CLK/2;
	S_CLK <= not S_CLK;
end process;

--Enable assignment
S_EN <= '0', '1' after 10*T_CLK, '0' after 20*T_CLK;

--SOBEL_CONTROLLER declarations
TEST : SOBEL_CONTROLLER
port map(
	I_RST      => S_RST,
	I_CLK      => S_CLK,
	I_SOBEL_EN => S_EN,
	O_DONE     => S_DONE,
	O_R1C1 => S_R1C1, O_R1C2 => S_R1C2, O_R1C3 => S_R1C3,
	O_R2C1 => S_R2C1,                   O_R2C3 => S_R2C3,
	O_R3C1 => S_R3C1, O_R3C2 => S_R3C2, O_R3C3 => S_R3C3
);

end architecture BEHAVIORAL;