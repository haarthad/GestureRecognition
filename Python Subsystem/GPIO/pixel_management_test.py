import numpy as np
from time import sleep
import cv2

def inputConversion(channel):
    if channel:
        return 1
    else:
        return 0

# Main function that pulls the pixel values and stores them into a list.
def pixelEnqueue(pixelQueue, stableQueue, finishedQueue, sendQueue):
    # Initialize the list with the right amount of pixel data.
    # In the future this will be modified to be a list of lists.
    # The overall list will be the number of pixels, and then each sublist is 8 large.
    finishedQueue.put('1')
    while 1:
        pixelList = np.zeros([64, 64])
        yIter = 0
        # For testing purposes run in a loop.
        while yIter < 64:
            xIter = 0
            while xIter < 64:
                stableQueue.get()
                pix = pixelQueue.get()
                pixelList[yIter, xIter] = pix
                finishedQueue.put('1')
                xIter += 1
            yIter += 1

        for i in range(sendQueue.qsize()):
            sendQueue.get(False)
        sendQueue.put(pixelList, 2)


def picSender(pixelQueue, stableQueue, finishedQueue):
    camera = cv2.VideoCapture(0)
    sleep(1)
    while 1:
            sleep(1)
            print("Perform Gesture.")
            sleep(3)
            # Get most recent image in video buffer
            # This is done due to the slow execution on the pi
            image = None
            for i in range(10):
                ret, image = camera.read()

            if image is not None:
                print("Gesture Captured")
                image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
                image = cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
                image = cv2.flip(image,0)
                image = cv2.flip(image,1)
                cv2.imshow('Image',image)
                image = cv2.resize(image,(64,64))
                i = 0
                while i < 64:
                    j = 0
                    while j < 64:
                        graypix = image[i, j]
                        finishedQueue.get()
                        pixelQueue.put(graypix)
                        stableQueue.put('1')
                        j += 1
                    i += 1





