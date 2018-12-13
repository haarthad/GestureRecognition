package CAMERA_PACK is
	--=======================================
	-- Declare Constants
	--=======================================
	--camera frame is 640x480
	CONSTANT PICTURE_WIDTH : INTEGER := 640; 
	--the number of bits required to store 640*4 as a binary number
	CONSTANT REG_NUM_BIN   : INTEGER := 12;
	--the width of a pixel
	CONSTANT PIXEL_WIDTH : INTEGER := 12;
end CAMERA_PACK;