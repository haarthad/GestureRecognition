--==============================================================================
-- Project: Image Collection
-- Author : Kevin Hughes
-- Date   : Thursday, November 20th, 2018
-- Module : tb_camera_programmer.vhd
-- Desc.  : Testbench for ensuring proper camera register set signal
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--==============================================================================
-- TB_CAMERA_PROGRAMMER Entity Block
--==============================================================================
entity TB_CAMERA_PROGRAMMER is 
end entity TB_CAMERA_PROGRAMMER;

--==============================================================================
--TB_CAMERA_PROGRAMMER Architecture Block
--==============================================================================
architecture BEHAVIORAL of TB_CAMERA_PROGRAMMER is

--==============================================================================
-- CAMERA_PROGRAMMER Component block
-- I_RST_N    : Reset
-- I_CLK50MHZ : 50[MHz] Clock
-- O_RST_N    : RST_N Camera pin
-- O_XCLK     : X_CLK Camera pin
-- O_SCLK     : S_CLK Camera pin
-- O_SDATA    : S_DATA Camera pin
--==============================================================================
component CAMERA_PROGRAMMER is port(
	I_RST_N    : in std_logic;
	I_CLK50MHZ : in std_logic;
	O_RST_N    : out std_logic;
	O_XCLK     : out std_logic;
	O_SCLK     : out std_logic;
	O_SDATA    : out std_logic;
	O_PROG_DONE: out std_logic
);end component CAMERA_PROGRAMMER;

--Test signal declarations
signal S_I_RST_N  : std_logic;
signal S_CLK50MHZ : std_logic := '0';
signal S_O_RST_N  : std_logic;
signal S_XCLK     : std_logic;
signal S_SCLK     : std_logic;
signal S_SDATA    : std_logic;
signal S_PROG_DONE: std_logic;

--Timing constant declaration
constant T_CLK : time := 20 ns;

begin

--Reset Assignment
S_I_RST_N <= '0', '1' after 5*T_CLK;

--Clock assignment
CLOCK: process
begin
	wait for T_CLK/2;
	S_CLK50MHZ <= not S_CLK50MHZ;
end process;

PROGRAMMER_TEST: CAMERA_PROGRAMMER
port map(
	I_RST_N    => S_I_RST_N,
	I_CLK50MHZ => S_CLK50MHZ,
	O_RST_N    => S_O_RST_N,
	O_XCLK     => S_XCLK,
	O_SCLK     => S_SCLK,
	O_SDATA    => S_SDATA,
	O_PROG_DONE=> S_PROG_DONE
);

end architecture BEHAVIORAL;