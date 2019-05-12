## @package PixelManagement
# This file pulls in data off of the GPIO's and applies logic to 
# the data to form a picture. That image is then put on a queue
# for the tensorFlow portion of the project to grab when it is ready.

# import the gpio library for the pi, print error if it can't.
import gpio_management as gm
import numpy as np
import cv2
from multiprocessing import Queue

try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print("Error importing RPi.GPIO")


##
# Outputs 1 or 0 depending on if the pin is high or low.
# @param gpio channel
# @return 1 or 0
def inputConversion(channel):
    if GPIO.input(channel):
        return 1
    else:
        return 0


##
# Main function that pulls the pixel values and stores them into a list.
# @param pizel queue, error queue
def pixelEnqueue(pixel_queue, error_queue):
    # Initialize the numpy array with the right amount of pixel data.
    pixel_list = np.zeros([240, 320])
    error_detect = 0

    # Initialize the GPIOS.
    gm.pixelReceptionInit()
    GPIO.output(gm.read_finished, GPIO.LOW)
    prev_pixel_stable = GPIO.input(gm.pixel_stable)
    # Run in a loop
    while True:
        # Reset iterators each time there is a new image
        x_iter = 0
        y_iter = 0
        # If start_of_image is high that means either there is a new image or we are currently in a valid frame
        # At this particular location it means that there is a new image ready and we are at the first pixel
        if GPIO.input(gm.start_of_image):
            # Loops to put the pixel data in the correct location
            while y_iter < 240 and GPIO.input(gm.start_of_image):
                x_iter = 0
                while x_iter < 320 and GPIO.input(gm.start_of_image):
                    # pixel_stable is a differential signal, if it has changed then the pixel data is ready to be pulled
                    # Also check to make sure we are still in a valid frame
                    if (GPIO.input(gm.pixel_stable) != prev_pixel_stable) and GPIO.input(gm.start_of_image):
                        prev_pixel_stable = GPIO.input(gm.pixel_stable)
                        # Take each GPIO input, convert them to a 1 or 0, convert that to a string
                        # Then append each '1' or '0' string to a single string
                        temp_bin_val = "" + str(inputConversion(gm.pixel_input1)) + str(
                            inputConversion(gm.pixel_input2)) + str(
                            inputConversion(gm.pixel_input3)) + str(inputConversion(gm.pixel_input4)) + str(
                            inputConversion(gm.pixel_input5)) + str(
                            inputConversion(gm.pixel_input6)) + str(inputConversion(gm.pixel_input7)) + str(
                            inputConversion(gm.pixel_input8))
                        # Take the binary string and convert it to an integer
                        pixelVal = int(temp_bin_val, 2)
                        # Take the integer and add it to the correct position in the numpy array
                        pixel_list[y_iter, x_iter] = pixelVal
                        # Once the read has finished invert the current read_finished signal
                        # It too is a differential signal
                        if GPIO.input(gm.read_finished):
                            GPIO.output(gm.read_finished, GPIO.LOW)
                        else:
                            GPIO.output(gm.read_finished, GPIO.HIGH)
                        # Increment x_iter and reset error_detect
                        x_iter += 1
                        error_detect = 0
                    else:
                        # If the pixel isn't stable increment error_detect
                        error_detect += 1
                    # If there has been 500 loops with no stable pixel then print an error for debugging
                    if error_detect > 500:
                        print("Pixel not stable for 500 loops, must have been an error")
                # Once a full row has been completed move onto the next
                y_iter += 1
            # For testing purposes, save the image rather than send it, cleanup the GPIO's then break.
            cv2.imwrite("test.png", pixel_list)
            GPIO.cleanup()
            print(pixel_list)
            break
            # Once transmission is working, pixel data can be transmitted via a shared queue
            # This will go to the image recognition code
            try:
                pixel_queue.put(img_to_send, True, 5)
            except Queue.full:
                print("Max timeout (5 seconds) exceeded")
                break



# Queue 1 will be for image communication, queue 2 will be for errors and reset commands from image recognition
if __name__ == "__main__":
    q1 = Queue()
    q2 = Queue()
    pixelEnqueue(q1, q2)
