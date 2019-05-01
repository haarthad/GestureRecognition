#######################################################################
# Displays a cocuntdown timer for 30 seconds and plays a tone at
# its conclusion
#######################################################################

import sys, time
import pygame

##################################################################################################
# Methods
##################################################################################################

"""
Method that prints a countdown timer to the console
	has a duration of 30s and plays a tone at the end
:param commands_path Directory storing sound bites folder
"""
def Timer(commands_path):
    sec = 30
    min = 0
    looper = True
    while looper:
        print("\r%02d:%02d" % (min, sec), flush=True, end='')
        if (min != 0) or (sec != 0):
            time.sleep(1)
            if sec == 0:
                sec = 59
                min-=1
            else:
                sec-=1
        else:
            looper = False

    print("\r\n")

	# https://stackoverflow.com/questions/2936914/pygame-sounds-dont-play
    try:
        pygame.mixer.init()
        sound = pygame.mixer.Sound(commands_path + 'Assets\Slrt.wav')
        sound.play()
        time.sleep(3)
    except pygame.error:
        print("Could not find an available audio device")

##################################################################################################
# Main logic
##################################################################################################

"""
Calls Timer(0 in the working directory
"""
def main():
    Timer("")
	
"""
Default main block
"""
if __name__ == "__main__":
    main()