import sys, time
import pygame

def Timer(commands_path):
    sec = 0
    min = 1
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


def main():
    Timer("")
	
if __name__ == "__main__":
    main()