--Owner: Senior Design Team Delta
--Component: CAMERA_PACK.vhd
--Description: This package contains constants that are used throughout the 
--					collection and transmission process so a single change here
--					can change the entire TopLevel.
--Author: Michael Dougherty
--Start Date: 12/11/2018
package CAMERA_PACK is
	--=======================================
	-- Declare Constants
	--=======================================
	--camera frame is 640x480
	CONSTANT PICTURE_WIDTH : INTEGER := 640; 
	--camera frame is 640x480
	CONSTANT PICTURE_HEIGHT : INTEGER := 480; 
	--the number of bits required to store 640*4 as a binary number
	CONSTANT REG_NUM_BIN : INTEGER := 12;
	--the width of a pixel
	CONSTANT PIXEL_WIDTH : INTEGER := 12;
	--the width of a greyscale pixel
	CONSTANT GREYSCALE_PIXEL_WIDTH : INTEGER := 8;
	--greysccaled camera frame is 320x240
	CONSTANT GREYSCALE_PICTURE_WIDTH : INTEGER := 320; 
	--greysccaled camera frame is 320x240
	CONSTANT GREYSCALE_PICTURE_HEIGHT : INTEGER := 240;
	--number of bits required to store 76800 (320*240) as a binary number
	CONSTANT GREYSCALE_REG_NUM_BIN : INTEGER := 17;
	--how many pixels to send from SRAM during transmission
	CONSTANT TRANSMIT_NUMBER : INTEGER :=  GREYSCALE_PICTURE_WIDTH * GREYSCALE_PICTURE_HEIGHT;
end CAMERA_PACK;
