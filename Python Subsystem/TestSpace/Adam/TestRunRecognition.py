## @package TestRunRecognition
# This file tests the main method for the Image Recognition portion of the
# system, runRecognition(), and in turn tests all the methods in the
# ImageRecognition.py script.
#

import sys
sys.path.append("../..")
from multiprocessing import Process, Queue
import cv2
import numpy as np
import scipy.ndimage as nd
import random
from TensorFlow import ImageRecognition as ir


##
# Very basic implementation of what ImageTransmission is doing on the Pi side.
# @param pixel_queue Queue of images
# @param error_queue Holds error messages that go between ImageTransmission
#                    and ImageRecognition
# @param images Preloaded images to be put on pixel queue
def basicQueue(pixel_queue,error_queue,images):
    while True:
        pixel_queue.put(random.choice(images), True, 5)


##
# Pre loads specific images for this test.
# @return Returns an image from each gesture that has a sobel filter applied to
#         it
def loadImages():
    images = []
    sobel_images = []

    # Load image from each gesture
    images.append(cv2.imread("../../TensorFlow/ImageData/ExtraTest/A (1).jpg",
                             cv2.IMREAD_GRAYSCALE))
    images.append(cv2.imread("../../TensorFlow/ImageData/ExtraTest/B (1).jpg",
                             cv2.IMREAD_GRAYSCALE))
    images.append(cv2.imread("../../TensorFlow/ImageData/ExtraTest/C (1).jpg",
                             cv2.IMREAD_GRAYSCALE))
    images.append(cv2.imread("../../TensorFlow/ImageData/ExtraTest/G (1).jpg",
                             cv2.IMREAD_GRAYSCALE))
    images.append(cv2.imread("../../TensorFlow/ImageData/ExtraTest/V (1).jpg",
                             cv2.IMREAD_GRAYSCALE))
    images.append(cv2.imread("../../TensorFlow/ImageData/ExtraTest/N (1).jpg",
                             cv2.IMREAD_GRAYSCALE))

    # Apply sobel filter to all images
    for image in images:
        image = image.astype('int32')
        dx = nd.sobel(image, 1)
        dy = nd.sobel(image, 0)
        sobeled_image = np.hypot(dx, dy)
        sobeled_image *= 255.0 / np.max(sobeled_image)
        sobel_images.append(sobeled_image)

    return sobel_images

###############################################################################
# Main logic
###############################################################################


if __name__ == "__main__":

    # Preload images
    images = loadImages()

    # Start up a process for places images into the pixel queue, and a process
    # for image recognition.
    while True:
        pixelQueue = Queue()
        errorQueue = Queue()
        p1 = Process(target=basicQueue,
                     args=(pixelQueue, errorQueue, images))
        p2 = Process(target=ir.runRecognition,
                     args=(pixelQueue, errorQueue,
                     '../../TensorFlow/SavedModels/image_recognition_model.h5',
                     '../../DeviceCommands/'))
        p1.start()
        p2.start()
        p1.join()
        p2.join()