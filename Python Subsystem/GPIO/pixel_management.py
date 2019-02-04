# import the gpio library for the pi, print error if it can't.
import gpio_management as gm
import numpy as np
import PIL
from PIL import Image
import cv2
from multiprocessing import Queue
import time
try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print("Error importing RPi.GPIO")


# Outputs 1 or 0 depending on if the pin is high or low.
def inputConversion(channel):
    if GPIO.input(channel):
        return 1
    else:
        return 0


# Main function that pulls the pixel values and stores them into a list.
def pixelEnqueue(pixelQueue, errorQueue):
    # Initialize the list with the right amount of pixel data.
    # In the future this will be modified to be a list of lists.
    # The overall list will be the number of pixels, and then each sublist is 8 large.
    pixelList = np.zeros([240, 320])
    errorDetect = 0

    # Initialize the GPIOS.
    gm.pixelReceptionInit()
    # For testing purposes run in a loop.
    while True:
        xIter = 0
        yIter = 0
        if GPIO.input(gm.startOfImage):
            while yIter < 240 and GPIO.input(gm.startOfImage):
                xIter = 0
                if yIter == 0:
                    xIter = 23
                while xIter < 320 and GPIO.input(gm.startOfImage):
                    GPIO.output(gm.readFinished, GPIO.LOW)
                    if GPIO.input(gm.pixelStable) and GPIO.input(gm.startOfImage):
                        tempBinVal = "" + str(inputConversion(gm.pixelInput1)) + str(
                            inputConversion(gm.pixelInput2)) + str(
                            inputConversion(gm.pixelInput3)) + str(inputConversion(gm.pixelInput4)) + str(
                            inputConversion(gm.pixelInput5)) + str(
                            inputConversion(gm.pixelInput6)) + str(inputConversion(gm.pixelInput7)) + str(
                            inputConversion(gm.pixelInput8))
                        pixelVal = int(tempBinVal, 2)
                        pixelList[yIter, xIter] = pixelVal
                        GPIO.output(gm.readFinished, GPIO.HIGH)
                        dummy = 67.89/2.76
                        dummy = dummy/36.54
                        xIter += 1
                        errorDetect = 0
                    else:
                        errorDetect += 1
                    if errorDetect > 500:
                        print("Pixel not stable for 500 loops, must have been an error")

                yIter += 1
            cv2.imwrite("test.png", pixelList)
            GPIO.cleanup()
            print(pixelList)
            break
            try:
                pixelQueue.put(imgToSend, True, 5)
            except Queue.full:
                print("Max timeout (5 seconds) exceeded")
                break



if __name__ == "__main__":
    q1 = Queue()
    q2 = Queue()
    pixelEnqueue(q1, q2)
