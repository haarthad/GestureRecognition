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
rows, cols = mag.shape
M = cv2.getRotationMatrix2D((cols/2, rows/2), -30, 1)
rst = cv2.warpAffine(mag, M, (cols, rows))


fig, ax = plt.subplots()
ax.imshow(rst, cmap='gray')
plt.xticks([]), plt.yticks([])
plt.show()
