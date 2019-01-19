from scipy import ndimage
import cv2
from PIL import Image
import matplotlib.pyplot as plt
fig = plt.figure()
ax1 = fig.add_subplot(111)
img = cv2.imread("img.jpg")
rst = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
#result = ndimage.sobel(img)
#cv2.imwrite('oh_god.png', result)
ax1.imshow(rst)
plt.show()

