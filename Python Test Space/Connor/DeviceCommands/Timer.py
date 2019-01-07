import sys, time
from pygame import mixer

def Timer():
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

# https://stackoverflow.com/questions/2936914/pygame-sounds-dont-play
    mixer.init()
    sound = mixer.Sound('Assets\Slrt.wav')
    sound.play()
    time.sleep(3)


if __name__ == "__main__":
    Timer()