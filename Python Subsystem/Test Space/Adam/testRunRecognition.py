from multiprocessing import Queue
import cv2
import numpy as np
import scipy.ndimage as nd
from TensorFlow import ImageRecognition as ir

images = []
image_a = cv2.imread("../../TensorFlow/ImageData/ExtraTest/A (1).jpg", cv2.IMREAD_GRAYSCALE)
image_b = cv2.imread("../../TensorFlow/ImageData/ExtraTest/B (1).jpg", cv2.IMREAD_GRAYSCALE)
image_c = cv2.imread("../../TensorFlow/ImageData/ExtraTest/C (1).jpg", cv2.IMREAD_GRAYSCALE)
image_g = cv2.imread("../../TensorFlow/ImageData/ExtraTest/G (1).jpg", cv2.IMREAD_GRAYSCALE)
image_v = cv2.imread("../../TensorFlow/ImageData/ExtraTest/V (1).jpg", cv2.IMREAD_GRAYSCALE)
image_n = cv2.imread("../../TensorFlow/ImageData/ExtraTest/N (1).jpg", cv2.IMREAD_GRAYSCALE)

sobel_images = []
for image in images:
    image = image.astype('int32')
    dx = nd.sobel(image, 1)
    dy = nd.sobel(image, 0)
    mag = np.hypot(dx, dy)
    mag *= 255.0 / np.max(mag)
    sobel_images.append(mag)

error_queue = Queue()
pixel_queue = Queue()
pixel_queue.put(image_a, True, 10)

ir.runRecognition(pixel_queue, error_queue, '../../TensorFlow/SavedModels/image_recognition_model.h5')
