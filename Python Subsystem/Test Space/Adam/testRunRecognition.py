from multiprocessing import Process, Queue
import cv2
import numpy as np
import scipy.ndimage as nd
import random
from TensorFlow import ImageRecognition as ir


def basicQueue(pixel_queue,error_queue,images):
    while True:
        pixel_queue.put(random.choice(images), True, 5)


def loadImages():
    images = []
    sobel_images = []

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

images = loadImages()

while True:
    pixelQueue = Queue(3)
    errorQueue = Queue(3)
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
