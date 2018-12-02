--==============================================================================
-- Project: Pixel Collection
-- Author : Kevin Hughes
-- Date   : Sunday, December 2nd, 2018
-- Module : camera_programmer
-- Desc.  : Programs the camera to 680px by 480px
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;

--==============================================================================
-- CAMERA_PROGRAMMER Entity block
-- I_RST_N    : Reset
-- I_CLK50MHZ : 50[MHz] Clock
-- O_RST_N    : RST_N Camera pin
-- O_XCLK     : X_CLK Camera pin
-- O_SCLK     : S_CLK Camera pin
-- O_SDATA    : S_DATA Camera pin
--==============================================================================
entity CAMERA_PROGRAMMER is port(
	I_RST_N    : in std_logic;
	I_CLK50MHZ : in std_logic;
	O_RST_N    : out std_logic;
	O_XCLK     : out std_logic;
	O_SCLK     : out std_logic;
	O_SDATA    : out std_logic
);end entity CAMERA_PROGRAMMER;

--==============================================================================
-- CAMERA_PROGRAMMER Architecture block
--==============================================================================
architecture RTL of CAMERA_PROGRAMMER is 

--==============================================================================
-- CLOCK_DIVIDER Component block
-- I_RST_N : Reset
-- I_CLK   : Clock to be divided
-- O_CLK   : Clock input divided
--==============================================================================
component CLOCK_DIVIDER is port(
	I_RST_N : in std_logic;
	I_CLK   : in std_logic;
	O_CLK   : out std_logic
);end component;

--Reset signal declarations
signal RST_EN  : std_logic := '0';
signal RST_CNT : integer range 0 to 10 := 0;

--Program signal declarations
--Control bits
constant START_BIT : std_logic_vector(1 downto 0) := "10"; -- Falling edge during clock cycle
constant STOP_BIT  : std_logic_vector(1 downto 0) := "01"; -- Rising edge during clock cycle
constant ACK_BIT   : std_logic_vector(1 downto 0) := "00"; -- Acknowledge, blank
constant WRITE_BIT : std_logic_vector(1 downto 0) := "00"; -- Place after address
constant READ_BIT  : std_logic_vector(1 downto 0) := "11"; -- Place after address
--Register address bits
constant REG_ROW_SIZE : std_logic_vector(13 downto 0) := "00 00 00 00 00 11 11"; -- 0x03
constant REG_COL_SIZE : std_logic_vector(13 downto 0) := "00 00 00 00 11 00 00"; -- 0x04
constant REG_ROW_SKIP : std_logic_vector(13 downto 0) := "00 11 00 00 00 11 00"; -- 0x22
constant REG_COL_SKIP : std_logic_vector(13 downto 0) := "00 11 00 00 00 11 11"; -- 0x23
--Register control bits
constant ROW_SIZE_MSB : std_logic_vector(15 downto 0) := "00 00 00 00 00 11 11 11"; -- 0x07
constant ROW_SIZE_LSB : std_logic_vector(15 downto 0) := "00 11 11 11 11 11 11 11"; -- 0x7F
constant COL_SIZE_MSB : std_logic_vector(15 downto 0) := "00 00 00 00 11 00 00 11"; -- 0x09
constant COL_SIZE_LSB : std_logic_vector(15 downto 0) := "11 11 11 11 11 11 11 11"; -- 0xFF
constant ROW_SKIP_MSB : std_logic_vector(15 downto 0) := "00 00 00 00 00 00 00 00"; -- 0x00
constant ROW_SKIP_LSB : std_logic_vector(15 downto 0) := "00 00 00 00 00 00 11 11"; -- 0x03
constant COL_SKIP_MSB : std_logic_vector(15 downto 0) := "00 00 00 00 00 00 00 00"; -- 0x00
constant COL_SKIP_LSB : std_logic_vector(15 downto 0) := "00 00 00 00 00 00 11 11"; -- 0x03

begin

--Set Camera reset high after 10 clocks, allow programming after 20 clocks
RST_TOGGLE : process (I_RST_N, I_CLK50MHZ)
begin
	if(I_RST_N = '0') then
		O_RST_N <= '0';
		RST_CNT <=  0;
		RST_EN  <= '0';
	elsif rising_edge(I_CLK50MHZ) then
		if(RST_CNT = 20) then
			O_RST_N <= '1';
			RST_CNT <= RST_CNT; 
			RST_EN  <= '1';
		elsif(RST_CNT <= 19 && RST_CNT >= 10) then
			O_RST_N <= '1';
			RST_CNT <= RST_CNT + 1;
			RST_EN  <= '0';
		else
			O_RST_N <= '0';
			RST_CNT <= RST_CNT + 1;
			RST_EN  <= '0';
		end if;
	end if;
end process;

-- Set the XCLK to 50MHz
O_XCLK <= I_CLK50MHZ;

-- Set the SCLK to 25MHz
CLK_DIV : CLOCK_DIVIDER
port map(
	I_RST_N => I_RST_N,
	I_CLK   => I_CLK50MHZ,
	O_CLK   => O_SCLK
);

-- Set SDATA
PROGRAM : process (I_CLK50MHZ)
begin
	--Rising edge clock case
	if (I_CLK50MHZ'event and I_CLK50MHZ = '1') then
	
		--System has fully reset
		if(RST_EN = '1') then
		else
		end if;
		
	--Falling edge clock case
	elsif (I_CLK50MHZ'event and I_CLK50MHZ = '0') then
	
		--System has fully reset
		if(RST_EN = '1') then
		else
		end if;

	end if;
end process;


end architecture RTL;
