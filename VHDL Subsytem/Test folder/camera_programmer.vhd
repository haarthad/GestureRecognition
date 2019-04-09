--==============================================================================
-- Project: Camera Programmer
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
-- I_RST_N        : Reset
-- I_CLK50MHZ     : 50[MHz] Clock
-- O_RST_N        : RST_N Camera pin
-- O_XCLK         : X_CLK Camera pin
-- IO_SCLK        : S_CLK Camera pin
-- IO_SDATA       : S_DATA Camera pin
-- O_PROG_DONE    : Programming done flag
-- O_ROW_SIZE_LED : Row size verification LED
-- O_COL_SIZE_LED : Column size verification LED
-- O_ROW_SKIP_LED : Row skip verification LED
-- O_COL_SKIP_LED : Column skip verification LED 
-- O_ACK_ERR_LED  : Acknowledgement error occurred LED
--==============================================================================
entity CAMERA_PROGRAMMER is port(
	I_RST_N        : in std_logic;
	I_CLK50MHZ     : in std_logic;
	O_RST_N        : out std_logic;
	O_XCLK         : out std_logic;
	IO_SCLK        : INOUT std_logic;
	IO_SDATA       : INOUT std_logic;
	O_PROG_DONE    : out std_logic;
	O_ROW_SIZE_LED : out std_logic;
	O_COL_SIZE_LED : out std_logic;
	O_ROW_SKIP_LED : out std_logic;
	O_COL_SKIP_LED : out std_logic;
	O_ACK_ERR_LED  : out std_logic
);end entity CAMERA_PROGRAMMER;

--==============================================================================
-- CAMERA_PROGRAMMER Architecture block
--==============================================================================
architecture RTL of CAMERA_PROGRAMMER is

--==============================================================================
-- I2C_MASTER component block
-- INPUT_CLK : Input clock speed from user logic in Hz
-- BUS_CLK   : Speed the i2c bus (scl) will run at in Hz
-- CLK       : System clock
-- RESET_N   : Active low reset
-- ENA       : Latch in command
-- ADDR      : Address of target slave
-- RW        :'0' is write, '1' is read
-- DATA_WR   : Data to write to slave
-- BUSY      : Indicates transaction in progress
-- DATA_RD   : Data read from slave
-- ACK_ERROR : Flag if improper acknowledge from slave
-- SDA       : Serial data output of i2c bus
-- SCL       : Serial clock output of i2c bus
--==============================================================================
component I2C_MASTER is
generic(
	INPUT_CLK : INTEGER := 50_000_000;
	BUS_CLK  : INTEGER := 20_000);
port(
	CLK       : IN     STD_LOGIC;                 
	RESET_N   : IN     STD_LOGIC;
	ENA       : IN     STD_LOGIC;
	ADDR      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0);
	RW        : IN     STD_LOGIC;
	DATA_WR   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0);
	BUSY      : OUT    STD_LOGIC;
	DATA_RD   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0);
	ACK_ERROR : BUFFER STD_LOGIC;
	SDA       : INOUT  STD_LOGIC;
	SCL       : INOUT  STD_LOGIC
);end component;

--I2C Control signal declarations
signal S_ENA       : std_logic;
signal S_ADDR      : std_logic_vector(6 downto 0);
signal S_RW        : std_logic;
signal S_DATA_WR   : std_logic_vector(7 downto 0);
signal S_BUSY      : std_logic;
signal S_DATA_RD   : std_logic_vector(7 downto 0);
signal S_ACK_ERROR : std_logic;

--Programmer state declarations
type PROGRAM_STATE is (START, ROW_SIZE, COL_SIZE, ROW_SKIP, COL_SKIP, DONE);
signal STATE : PROGRAM_STATE := START;
type STEP_STATE is (ADDRESS, MSB, LSB, FINISH);
signal IIC_STATE: STEP_STATE := ADDRESS;

--Programmer state variable declarations
signal PREV_BUSY   : std_logic := '0';
signal ACTION_STATE: integer range 0 to 2 := 0;

--Program value declarations
constant WRITE_BIT    : std_logic := '0';
constant READ_BIT     : std_logic := '1';
constant CAMERA_ADDR  : std_logic_vector(6 downto 0) := "1011101";  --0x5D
constant REG_ROW_SIZE : std_logic_vector(7 downto 0) := "00000011"; --0x03
constant REG_COL_SIZE : std_logic_vector(7 downto 0) := "00000100"; --0x04
constant REG_ROW_SKIP : std_logic_vector(7 downto 0) := "00100010"; --0x22
constant REG_COL_SKIP : std_logic_vector(7 downto 0) := "00100011"; --0x23
constant ROW_SIZE_MSB : std_logic_vector(7 downto 0) := "00000111"; --0x07
constant ROW_SIZE_LSB : std_logic_vector(7 downto 0) := "01111111"; --0x7F
constant COL_SIZE_MSB : std_logic_vector(7 downto 0) := "00001001"; --0x09
constant COL_SIZE_LSB : std_logic_vector(7 downto 0) := "11111111"; --0xFF
constant ROW_SKIP_MSB : std_logic_vector(7 downto 0) := "00000000"; --0x00
constant ROW_SKIP_LSB : std_logic_vector(7 downto 0) := "00000011"; --0x03
constant COL_SKIP_MSB : std_logic_vector(7 downto 0) := "00000000"; --0x00
constant COL_SKIP_LSB : std_logic_vector(7 downto 0) := "00000011"; --0x03

--Verification read bit declarations
signal ROW_SIZE_RD : std_logic_vector(15 downto 0) := "0000000000000000";
signal COL_SIZE_RD : std_logic_vector(15 downto 0) := "0000000000000000";
signal ROW_SKIP_RD : std_logic_vector(15 downto 0) := "0000000000000000";
signal COL_SKIP_RD : std_logic_vector(15 downto 0) := "0000000000000000";

begin

--Sets up I2C transmission with appropriate data
DATA_SETUP: process(I_RST_N, I_CLK50MHZ)
begin
	--Reset control signals on reset
	if(I_RST_N = '0') then
		STATE        <= START;
		PREV_BUSY    <= '0';
		ACTION_STATE <=  0 ;
		ROW_SIZE_RD  <= "0000000000000000";
		COL_SIZE_RD  <= "0000000000000000";
		ROW_SKIP_RD  <= "0000000000000000";
		COL_SKIP_RD  <= "0000000000000000";
	--Begin operation on rising edge
	elsif rising_edge(I_CLK50MHZ) then	
		
		--State of data transmission to the camera
		case STATE is
			
			--Transmission starting state
			when START =>
				STATE <= ROW_SIZE;
				
			--Send the row size to the camera
			when ROW_SIZE =>
				
				--Write data
				case IIC_STATE is
					
					when ADDRESS =>
						S_ENA     <= '1';
						S_RW      <= WRITE_BIT;
						S_DATA_WR <= REG_ROW_SIZE;                    --CHANGE: Register to change
						if(PREV_BUSY = '0' and S_BUSY = '1') then
							IIC_STATE <= MSB;
						else
							IIC_STATE <= ADDRESS;
						end if;
						
					when MSB =>
						S_ENA     <= '1';
						S_RW      <= WRITE_BIT;
						S_DATA_WR <= ROW_SIZE_MSB;                    --CHANGE: Register MSB
						if(PREV_BUSY = '0' and S_BUSY = '1') then
							IIC_STATE <= LSB;
						else
							IIC_STATE <= MSB;
						end if;
						
					when LSB =>
						S_ENA     <= '1';
						S_RW      <= WRITE_BIT;
						S_DATA_WR <= ROW_SIZE_LSB;                    --CHANGE: Register LSB
						if(PREV_BUSY = '0' and S_BUSY = '1') then
							IIC_STATE <= FINISH;
						else
							IIC_STATE <= LSB;
						end if;
						
					when FINISH =>
						S_ENA <= '0';
						if(PREV_BUSY = '1' and S_BUSY = '0') then
							IIC_STATE <= ADDRESS;
							STATE     <= COL_SIZE;                     --CHANGE: Next command
						else
							IIC_STATE <= FINISH;
							STATE     <= STATE;
						end if;
				end case;
				
			--Send the column size to the camera
			when COL_SIZE =>
				
				--Write data
				case IIC_STATE is
					
					when ADDRESS =>
						S_ENA     <= '1';
						S_RW      <= WRITE_BIT;
						S_DATA_WR <= REG_COL_SIZE;                    --CHANGE: Register to change
						if(PREV_BUSY = '0' and S_BUSY = '1') then
							IIC_STATE <= MSB;
						else
							IIC_STATE <= ADDRESS;
						end if;
						
					when MSB =>
						S_ENA     <= '1';
						S_RW      <= WRITE_BIT;
						S_DATA_WR <= COL_SIZE_MSB;                    --CHANGE: Register MSB
						if(PREV_BUSY = '0' and S_BUSY = '1') then
							IIC_STATE <= LSB;
						else
							IIC_STATE <= MSB;
						end if;
						
					when LSB =>
						S_ENA     <= '1';
						S_RW      <= WRITE_BIT;
						S_DATA_WR <= COL_SIZE_LSB;                    --CHANGE: Register LSB
						if(PREV_BUSY = '0' and S_BUSY = '1') then
							IIC_STATE <= FINISH;
						else
							IIC_STATE <= LSB;
						end if;
						
					when FINISH =>
						S_ENA <= '0';
						if(PREV_BUSY = '1' and S_BUSY = '0') then
							IIC_STATE <= ADDRESS;
							STATE     <= ROW_SKIP;                     --CHANGE: Next command
						else
							IIC_STATE <= FINISH;
							STATE     <= STATE;
						end if;
				end case;
	
			--Send the row skip amount to the camera
			when ROW_SKIP =>
				
				--Write data
				case IIC_STATE is
					
					when ADDRESS =>
						S_ENA     <= '1';
						S_RW      <= WRITE_BIT;
						S_DATA_WR <= REG_ROW_SKIP;                    --CHANGE: Register to change
						if(PREV_BUSY = '0' and S_BUSY = '1') then
							IIC_STATE <= MSB;
						else
							IIC_STATE <= ADDRESS;
						end if;
						
					when MSB =>
						S_ENA     <= '1';
						S_RW      <= WRITE_BIT;
						S_DATA_WR <= ROW_SKIP_MSB;                    --CHANGE: Register MSB
						if(PREV_BUSY = '0' and S_BUSY = '1') then
							IIC_STATE <= LSB;
						else
							IIC_STATE <= MSB;
						end if;
						
					when LSB =>
						S_ENA     <= '1';
						S_RW      <= WRITE_BIT;
						S_DATA_WR <= ROW_SKIP_LSB;                    --CHANGE: Register LSB
						if(PREV_BUSY = '0' and S_BUSY = '1') then
							IIC_STATE <= FINISH;
						else
							IIC_STATE <= LSB;
						end if;
						
					when FINISH =>
						S_ENA <= '0';
						if(PREV_BUSY = '1' and S_BUSY = '0') then
							IIC_STATE <= ADDRESS;
							STATE     <= COL_SKIP;                     --CHANGE: Next command
						else
							IIC_STATE <= FINISH;
							STATE     <= STATE;
						end if;
				end case;
			
			--Send the column skip amount to the camera
			when COL_SKIP =>
				--Write data
				case IIC_STATE is
					
					when ADDRESS =>
						S_ENA     <= '1';
						S_RW      <= WRITE_BIT;
						S_DATA_WR <= REG_COL_SKIP;                    --CHANGE: Register to change
						if(PREV_BUSY = '0' and S_BUSY = '1') then
							IIC_STATE <= MSB;
						else
							IIC_STATE <= ADDRESS;
						end if;
						
					when MSB =>
						S_ENA     <= '1';
						S_RW      <= WRITE_BIT;
						S_DATA_WR <= COL_SKIP_MSB;                    --CHANGE: Register MSB
						if(PREV_BUSY = '0' and S_BUSY = '1') then
							IIC_STATE <= LSB;
						else
							IIC_STATE <= MSB;
						end if;
						
					when LSB =>
						S_ENA     <= '1';
						S_RW      <= WRITE_BIT;
						S_DATA_WR <= COL_SKIP_LSB;                    --CHANGE: Register LSB
						if(PREV_BUSY = '0' and S_BUSY = '1') then
							IIC_STATE <= FINISH;
						else
							IIC_STATE <= LSB;
						end if;
						
					when FINISH =>
						S_ENA <= '0';
						if(PREV_BUSY = '1' and S_BUSY = '0') then
							IIC_STATE <= ADDRESS;
							STATE     <= DONE;                         --CHANGE: Next command
						else
							IIC_STATE <= FINISH;
							STATE     <= STATE;
						end if;
				end case;
			
			
			when DONE =>
				STATE <= DONE;
				
		end case;
		
		--Assign previous busy value to current busy value
		PREV_BUSY <= S_BUSY;
		
	end if;
end process;

--Acknowledgement error latch process
ACK_ERROR: process(I_RST_N, I_CLK50MHZ)
begin
	--Reset output on reset
	if(I_RST_N = '0') then
		O_ACK_ERR_LED <= '0';
	elsif rising_edge(I_CLK50MHZ) then
		if(S_ACK_ERROR = '1') then
			O_ACK_ERR_LED <= '1';
		end if;
	end if;
end process;

--I2C Master port map
IC: I2C_MASTER
port map(
	CLK       => I_CLK50MHZ,
	RESET_N   => I_RST_N,
	ENA       => S_ENA,
	ADDR      => S_ADDR,
	RW        => S_RW,
	DATA_WR   => S_DATA_WR,
	BUSY      => S_BUSY,
	DATA_RD   => S_DATA_RD,
	ACK_ERROR => S_ACK_ERROR,
	SDA       => IO_SDATA,
	SCL       => IO_SCLK
);

--Camera address assignment
S_ADDR <= CAMERA_ADDR;

--Camera reset assignment
O_RST_N <= I_RST_N;

--Pixel clock speed assignment
O_XCLK <= I_CLK50MHZ;

--Camera programmer complete assignment
O_PROG_DONE <= '1' when STATE = DONE else '0';

--Verification LED assignments
O_ROW_SIZE_LED <= '1' when ROW_SIZE_RD = (ROW_SIZE_MSB & ROW_SIZE_LSB) else '0';
O_COL_SIZE_LED <= '1' when COL_SIZE_RD = (COL_SIZE_MSB & COL_SIZE_LSB) else '0';
O_ROW_SKIP_LED <= '1' when ROW_SKIP_RD = (ROW_SKIP_MSB & ROW_SKIP_LSB) else '0';
O_COL_SKIP_LED <= '1' when COL_SKIP_RD = (COL_SKIP_MSB & COL_SKIP_LSB) else '0';

end architecture RTL;