# import the gpio library for the pi, print error if it can't.
import gpio_management as gm
import numpy as np
import scipy.misc as smp
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
def pixelEnqueue(pixelQueue):
    # Initialize the list with the right amount of pixel data.
    # In the future this will be modified to be a list of lists.
    # The overall list will be the number of pixels, and then each sublist is 8 large.
    pixelList = np.zeros(640, 480, 3)

    # Initialize the GPIOS.
    gm.pixelReceptionInit()
    # For testing purposes run in a loop.
    while True:
        xIter = 0
        yIter = 0
        # If its the start of an image set the ready to receive to low to block the FPGA from moving on.
        if GPIO.event_detected(gm.startOfImage):
            GPIO.output(gm.readyToRecieve, GPIO.LOW)
            while yIter < 238:
                xIter = 0
                # Set up a loop the size of the data we will be taking in.
                while xIter < 318:
                    # Now we are ready to receive pixels so set that pin high
                    GPIO.output(gm.readyToRecieve, GPIO.HIGH)
                    # Once high wait for 1 second for the pixel to be sent
                    sentDetect = GPIO.wait_for_edge(gm.pixelSent, timeout=1000)
                    if sentDetect is None:
                        print("Timeout Occurred: FPGA didn't send data within 1 second of receiving ready signal.")
                    else:
                        # Collect data from the GPIOS and put it into a list.
                        # While collecting data tell the FPGA to not change the values.
                        GPIO.output(gm.readyToRecieve, GPIO.LOW)
                        # Take in all data and convert it to a string containing a binary number, assuming msb is input1
                        tempBinVal = ""+str(inputConversion(gm.pixelInput1))+str(inputConversion(gm.pixelInput2))+str(
                            inputConversion(gm.pixelInput3))+str(inputConversion(gm.pixelInput4))+str(inputConversion(gm.pixelInput5))+str(
                            inputConversion(gm.pixelInput6))+str(inputConversion(gm.pixelInput7))+str(inputConversion(gm.pixelInput8))
                        # Convert binary string to integer then store in list
                        pixelVal = int(tempBinVal, 2)
                        pixelList[xIter, yIter] = [pixelVal, pixelVal, pixelVal]
                        # Increment the iterator and then move on
                        xIter += 1
                yIter += 1
        imgToSend = smp.toimage(pixelList)
        try:
            pixelQueue.put(imgToSend, True, 5)
        except Queue.full:
            print("Max timeout (5 seconds) exceeded")
            break

