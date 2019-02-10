# import the gpio library for the pi, print error if it can't.
import gpio_management as gm
import numpy as np
import cv2
from multiprocessing import Queue

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
    # Initialize the numpy array with the right amount of pixel data.
    pixelList = np.zeros([240, 320])
    errorDetect = 0

    # Initialize the GPIOS.
    gm.pixelReceptionInit()
    GPIO.output(gm.readFinished, GPIO.LOW)
    prevPixelStable = GPIO.input(gm.pixelStable)
    # Run in a loop
    while True:
        # Reset iterators each time there is a new image
        xIter = 0
        yIter = 0
        # If startOfImage is high that means either there is a new image or we are currently in a valid frame
        # At this particular location it means that there is a new image ready and we are at the first pixel
        if GPIO.input(gm.startOfImage):
            # Loops to put the pixel data in the correct location
            while yIter < 240 and GPIO.input(gm.startOfImage):
                xIter = 0
                while xIter < 320 and GPIO.input(gm.startOfImage):
                    # pixelStable is a differential signal, if it has changed then the pixel data is ready to be pulled
                    # Also check to make sure we are still in a valid frame
                    if (GPIO.input(gm.pixelStable) != prevPixelStable) and GPIO.input(gm.startOfImage):
                        prevPixelStable = GPIO.input(gm.pixelStable)
                        # Take each GPIO input, convert them to a 1 or 0, convert that to a string
                        # Then append each '1' or '0' string to a single string
                        tempBinVal = "" + str(inputConversion(gm.pixelInput1)) + str(
                            inputConversion(gm.pixelInput2)) + str(
                            inputConversion(gm.pixelInput3)) + str(inputConversion(gm.pixelInput4)) + str(
                            inputConversion(gm.pixelInput5)) + str(
                            inputConversion(gm.pixelInput6)) + str(inputConversion(gm.pixelInput7)) + str(
                            inputConversion(gm.pixelInput8))
                        # Take the binary string and convert it to an integer
                        pixelVal = int(tempBinVal, 2)
                        # Take the integer and add it to the correct position in the numpy array
                        pixelList[yIter, xIter] = pixelVal
                        # Once the read has finished invert the current readFinished signal
                        # It too is a differential signal
                        if GPIO.input(gm.readFinished):
                            GPIO.output(gm.readFinished, GPIO.LOW)
                        else:
                            GPIO.output(gm.readFinished, GPIO.HIGH)
                        # Increment xIter and reset errorDetect
                        xIter += 1
                        errorDetect = 0
                    else:
                        # If the pixel isn't stable increment errorDetect
                        errorDetect += 1
                    # If there has been 500 loops with no stable pixel then print an error for debugging
                    if errorDetect > 500:
                        print("Pixel not stable for 500 loops, must have been an error")
                # Once a full row has been completed move onto the next
                yIter += 1
            # For testing purposes, save the image rather than send it, cleanup the GPIO's then break.
            cv2.imwrite("test.png", pixelList)
            GPIO.cleanup()
            print(pixelList)
            break
            # Once transmission is working, pixel data can be transmitted via a shared queue
            # This will go to the image recognition code
            try:
                pixelQueue.put(imgToSend, True, 5)
            except Queue.full:
                print("Max timeout (5 seconds) exceeded")
                break


# Queue 1 will be for image communication, queue 2 will be for errors and reset commands from image recognition
if __name__ == "__main__":
    q1 = Queue()
    q2 = Queue()
    pixelEnqueue(q1, q2)
