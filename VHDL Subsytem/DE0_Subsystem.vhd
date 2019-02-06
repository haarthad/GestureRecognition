LIBRARY ieee;
USE ieee. std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee. std_logic_unsigned.all;
USE work.CAMERA_PACK.all;
 
ENTITY DE0_Subsystem IS

PORT( 
	i_rst_n       : IN STD_LOGIC;
	i_clk50mhz    : IN STD_LOGIC;
	i_clk         : IN STD_LOGIC;
	i_pixel_data  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	i_lval        : IN STD_LOGIC;
	i_fval        : IN STD_LOGIC;
	i_pixel_read  : IN STD_LOGIC;
	o_rst_n       : OUT STD_LOGIC;
	o_xclk        : OUT STD_LOGIC;
	o_sclk        : OUT STD_LOGIC;
	o_sdata       : OUT STD_LOGIC;
	o_pixel_data  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	o_valid_frame : OUT STD_LOGIC;
	o_valid_pixel : OUT STD_LOGIC;
	o_sobel_en    : OUT STD_LOGIC;
	o_finished    : OUT STD_LOGIC
);
END DE0_Subsystem;
 
ARCHITECTURE structural OF DE0_Subsystem IS
--========================================
-- Signal Declarations
--========================================
SIGNAL enable_wire : STD_LOGIC;
--=======================================
-- Declare Components
--=======================================
COMPONENT CameraCollectorTransmitter IS
PORT( 
	i_clk              : IN STD_LOGIC;
	i_en               : IN STD_LOGIC;
	i_pixel_data       : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	i_lval             : IN STD_LOGIC;
	i_fval             : IN STD_LOGIC;
	i_pixel_read       : IN STD_LOGIC;
	o_pixel_data       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	o_valid_frame      : OUT STD_LOGIC;
	o_valid_pixel      : OUT STD_LOGIC;
	o_sobel_en         : OUT STD_LOGIC;
	o_finished         : OUT STD_LOGIC
); 
END COMPONENT;
COMPONENT camera_programmer IS
PORT(
	I_RST_N     : IN STD_LOGIC;
	I_CLK50MHZ  : IN STD_LOGIC;
	O_RST_N     : OUT STD_LOGIC;
	O_XCLK      : OUT STD_LOGIC;
	O_SCLK      : OUT STD_LOGIC;
	O_SDATA     : OUT STD_LOGIC;
	O_PROG_DONE : OUT STD_LOGIC
);
END COMPONENT;
--========================================
-- Local Architecture
--========================================
BEGIN
--========================================
-- Map Components
--========================================
----------========================================
---------- CameraCollectorTransmitter
----------========================================
CameraCT: CameraCollectorTransmitter
PORT MAP(
	i_clk          => i_clk,
	i_en           => enable_wire,
	i_pixel_data   => i_pixel_data,
	i_lval         => i_lval,
	i_fval         => i_fval,
	i_pixel_read   => i_pixel_read,
	o_pixel_data   => o_pixel_data,
	o_valid_frame  => o_valid_frame,
	o_valid_pixel  => o_valid_pixel,
	o_sobel_en     => o_sobel_en,
	o_finished     => o_finished
);
CameraP: camera_programmer
PORT MAP(
	I_RST_N     => i_rst_n,
	I_CLK50MHZ  => i_clk50mhz,
	O_RST_N     => o_rst_n,
	O_XCLK      => o_xclk,
	O_SCLK      => o_sclk,
	O_SDATA     => o_sdata,
	O_PROG_DONE => enable_wire
);
END structural;