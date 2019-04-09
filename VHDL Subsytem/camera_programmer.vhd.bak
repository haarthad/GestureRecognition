--==============================================================================
-- Project: Pixel Collection
-- Author : Kevin Hughes
-- Date   : Sunday, December 2nd, 2018
-- Module : camera_programmer
-- Desc.  : Programs the camera to 680px by 480px
--==============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--==============================================================================
-- CAMERA_PROGRAMMER Entity block
-- I_RST_N    : Reset
-- I_CLK50MHZ : 50[MHz] Clock
-- O_RST_N    : RST_N Camera pin
-- O_XCLK     : X_CLK Camera pin
-- O_SCLK     : S_CLK Camera pin
-- O_SDATA    : S_DATA Camera pin
-- O_PROG_DONE: Programming done flag
--==============================================================================
entity CAMERA_PROGRAMMER is port(
	I_RST_N    : in std_logic;
	I_CLK50MHZ : in std_logic;
	O_RST_N    : out std_logic;
	O_XCLK     : out std_logic;
	O_SCLK     : out std_logic;
	O_SDATA    : out std_logic;
	O_PROG_DONE: out std_logic
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
signal RST_CNT : integer range 0 to 20 := 0;

--Program message declaration
constant MESSAGE : std_logic_vector(563 downto 0) := 
"00000000000000000000000000000000011111111111100000" &
"00000000000000000000000000000000111111111111111110" & 
"00000000000111111111111111111111111111111111111111" & 
"11100000000000000000000000000000001111110000000000" &
"01111110000000111111111111111111111111111111111111" &
"11111111111000000000111111111111111111111111000000" &
"00011111100000000000000000001111100000000000000000" &
"00000000000000000000000000000000000000000000000000" &
"00000000000000000000000000000000000000000111111111" &
"11100000000000000000000000000000000000000000000000" &
"00000000000000000000000000000000000000000000111111" &
"11111000000000";

--Program message counter declaration
signal MSG_CNT   : integer range 0 to 563 := 563;
constant MSG_MAX : integer := 563;

--Message signal declarations
signal MSG_DONE : std_logic := '0';
signal MSG_DATA : std_logic := '1';

--Post-programming delay counter declaration
signal WAIT_CNT : integer range 0 to 50000 := 0;


begin

--Set Camera reset high after 10 clocks, allow programming after 20 clocks
RST_TOGGLE : process (I_RST_N, I_CLK50MHZ)
begin
	--Reset Case
	if(I_RST_N = '0') then
		O_RST_N <= '0';
		RST_CNT <=  0;
		RST_EN  <= '0';
	--Rising edge clock case
	elsif rising_edge(I_CLK50MHZ) then
		--System fully reset and set-up delay expired
		if(RST_CNT = 20) then
			O_RST_N <= '1';
			RST_CNT <= RST_CNT; 
			RST_EN  <= '1';
		--System fully reset
		elsif(RST_CNT <= 19 and RST_CNT >= 10) then
			O_RST_N <= '1';
			RST_CNT <= RST_CNT + 1;
			RST_EN  <= '0';
		--System being reset
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
PROGRAM : process (I_RST_N, I_CLK50MHZ)
begin
	--Reset case
	if(I_RST_N = '0') then
		MSG_CNT  <= MSG_MAX;
		MSG_DONE <= '0';
		MSG_DATA <= '1';
	--Falling edge clock case
	elsif rising_edge(I_CLK50MHZ) then
		--System has fully reset and set-up delay has expired
		if(RST_EN = '1') then
		
			--Message is still ongoing
			if(MSG_DONE = '0') then
			
				MSG_DATA <= MESSAGE(MSG_CNT);
			
				--Message has been transmitted
				if(MSG_CNT = 0) then
					MSG_CNT  <= MSG_MAX;
					MSG_DONE <= '1';
				--Message is still transmitting
				else
					MSG_CNT  <= MSG_CNT - 1;
					MSG_DONE <= '0';
				end if;
			
			--Message has completed transmission
			else
				MSG_CNT  <= MSG_MAX;
				MSG_DONE <= '1';
				MSG_DATA <= '1';
			end if;
			
		--Reset has not completed and delay has not expired
		else
			MSG_CNT  <= MSG_MAX;
			MSG_DONE <= '0';
			MSG_DATA <= '1';
		end if;
	end if;
end process;

--SDATA Assignment
O_SDATA <= MSG_DATA;

--Set program done
DONE_DELAY: process (I_RST_N, I_CLK50MHZ)
begin
	--Reset case
	if(I_RST_N = '0') then
		O_PROG_DONE <= '0';
		WAIT_CNT <= 0;
	--Rising edge clock case
	elsif rising_edge(I_CLK50MHZ) then
		
		--Message has completed transmission
		if(MSG_DONE = '1') then
			
			--Programming delay has passed
			if(WAIT_CNT = 50000) then
				O_PROG_DONE <= '1';
				WAIT_CNT <= WAIT_CNT;
			--Programming delay is ongoing
			else
				O_PROG_DONE <= '0';
				WAIT_CNT <= WAIT_CNT + 1;
			end if;
			
		--Message has yet to complete transmission
		else
			O_PROG_DONE <= '0';
			WAIT_CNT <= 0;
		end if;
		
	end if;
end process;

end architecture RTL;
