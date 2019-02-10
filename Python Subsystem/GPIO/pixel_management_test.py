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
    while 1:
        pixelList = np.zeros([240, 320])
        yIter = 0
        finishedQueue.put('1')
        # For testing purposes run in a loop.
        while yIter < 240:
            xIter = 0
            while xIter < 320:
                stableQueue.get()
                pix = pixelQueue.get()
                pixelList[yIter, xIter] = pix
                finishedQueue.put('1')
                xIter += 1
            yIter += 1
        if sendQueue.qsize() < 4:
            sendQueue.put(pixelList, 2)
        else:
            for i in range(sendQueue.qsize()):
                sendQueue.get(False)
            sendQueue.put(pixelList, 2)


def picSender(pixelQueue, stableQueue, finishedQueue):
    sleep(1)
    while 1:
            print("Perform Gesture.")
            sleep(5)
            print("Gesture Captured")
            img = cv2.imread("pictosend.png", 0)
            i = 0
            while i < 240:
                j = 0
                while j < 320:
                    graypix = img[i,j]
                    finishedQueue.get()
                    pixelQueue.put(graypix)
                    stableQueue.put('1')
                    j += 1
                i += 1





