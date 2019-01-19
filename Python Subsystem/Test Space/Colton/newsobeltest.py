import scipy.ndimage as nd
import numpy as np
import matplotlib.pyplot as plt
import cv2

im = nd.imread('img.jpg', True)
im = im.astype('int32')
dx = nd.sobel(im, 1)
dy = nd.sobel(im, 0)
mag = np.hypot(dx, dy)
mag *= 255.0/np.max(mag)

fig, ax = plt.subplots()
ax.imshow(mag, cmap='gray')
plt.xticks([]), plt.yticks([])
plt.show()
