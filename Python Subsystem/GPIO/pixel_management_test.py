## @package pixel_management_test
# This file replicates what the vhdl side of the project would do.
# It pulls in images from a webcam and enqueus the pixel data for 
# Pixel_management to pick up. 

import numpy as np
from time import sleep
import cv2


##
# Converts gpio channel to a 1 or 0
# @param gpio channel
# @return 1 or 0
def inputConversion(channel):
    if channel:
        return 1
    else:
        return 0


##
# Main function that pulls the pixel values and stores them into a list.
# @param pixel queue, stable queue, finished queue, send queue
def pixelEnqueue(pixel_queue, stable_queue, finished_queue, send_queue):
    # Initialize the list with the right amount of pixel data.
    # In the future this will be modified to be a list of lists.
    # The overall list will be the number of pixels, and then each sublist is 8 large.
    finished_queue.put('1')
    while 1:
        pixel_list = np.zeros([64, 64])
        y_iter = 0
        # For testing purposes run in a loop.
        while y_iter < 64:
            x_iter = 0
            while x_iter < 64:
                stable_queue.get()
                pix = pixel_queue.get()
                pixel_list[y_iter, x_iter] = pix
                finished_queue.put('1')
                x_iter += 1
            y_iter += 1

        for i in range(send_queue.qsize()):
            send_queue.get(False)
        send_queue.put(pixel_list, 2)


##
# This function pulls in images from a webcam and and sends the data into a queue
# along with some logic to let the function it is communicating with know what pixel it is on.
# @param pixel queue, stable queue, finished queue
def picSender(pixel_queue, stable_queue, finished_queue):
    camera = cv2.VideoCapture(0)
    sleep(1)
    while 1:
            print("Perform Gesture.")
            sleep(2)
            # Get most recent image in video buffer
            # This is done due to the slow execution on the pi
            image = None
            for i in range(20):
                ret, image = camera.read()

            if image is not None:
                print("Gesture Captured")
                image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
                image = cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
                image = cv2.flip(image,0)
                image = cv2.flip(image,1)
                cv2.imshow('Image',image)
                cv2.waitKey(1)
                image = cv2.resize(image,(64,64))
                i = 0
                while i < 64:
                    j = 0
                    while j < 64:
                        graypix = image[i, j]
                        finished_queue.get()
                        pixel_queue.put(graypix)
                        stable_queue.put('1')
                        j += 1
                    i += 1





