import cv2
import numpy as np
import os
from random import shuffle
from tqdm import tqdm
import tensorflow as tf
from tensorflow import keras
import matplotlib.pyplot as plt
from PIL import Image

###############################################################################
# Defines
###############################################################################
TRAINING_DATA  = 'ImageData/Train'
TESTING_DATA   = 'ImageData/Test'
EXTRA_TESTING_DATA = 'ImageData/ExtraTest'
GESTURE_NAMES = ['A','B','C','G','V']
X_OF_IMAGES = 64
Y_OF_IMAGES = 64
NUMBER_OF_EPOCHS = 10

###############################################################################
# Methods
###############################################################################
"""
Returns the appropriate "hot" label for the provided image based on the
filename.
:param image: TensorFlow image to assign label to.
:return: Label for the image
"""
def selectLabel(image):
	# Get beginning of filename. This defines each gesture is shown in the
	# image.
	gesture = image.split('-')[0]
	label = np.array([0,0,0,0,0])

	if gesture == 'A':
		label = np.array([1,0,0,0,0])
	elif gesture == 'B':
		label = np.array([0,1,0,0,0])
	elif gesture == 'C':
		label = np.array([0,0,1,0,0])
	elif gesture == 'Point' or 'G':
		label = np.array([0,0,0,1,0])
	elif gesture == 'V':
		label = np.array([0,0,0,0,1])
	return label

"""
Reads in all training images, and returns them as TensorFlow images with
labels attached.
:return: Training images with labels
"""
def loadTrainingData():
	train_images = []
	for i in tqdm(os.listdir(TRAINING_DATA)):
		path = os.path.join(TRAINING_DATA, i)
		image = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
		image = cv2.resize(image, (X_OF_IMAGES, Y_OF_IMAGES))
		noise = image + np.random.normal(0.0,10.0, image.shape)
		label = selectLabel(i)
		train_images.append([np.array(image), label])
		train_images.append([np.array(noise), label])
	shuffle(train_images)
	return train_images

"""
Reads in all testing images, and returns them as TensorFlow images with
labels attached.
:return: Testing images with labels
"""
def loadTestingData():
	test_images = []
	for i in tqdm(os.listdir(TESTING_DATA)):
		path = os.path.join(TESTING_DATA, i)
		image = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
		image = cv2.resize(image, (X_OF_IMAGES, Y_OF_IMAGES))
		test_images.append([np.array(image), selectLabel(i)])
	shuffle(test_images)
	return test_images

"""
Reads in all personal testing images, and returns them as TensorFlow images with
labels attached.
:return: Personal testing images with labels
"""
def loadPersonalTestingData():
	personal_test_images = []
	for i in tqdm(os.listdir(EXTRA_TESTING_DATA)):
		path = os.path.join(EXTRA_TESTING_DATA, i)
		image = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
		image = cv2.resize(image, (X_OF_IMAGES, Y_OF_IMAGES))
		personal_test_images.append([np.array(image), selectLabel(i)])
	shuffle(personal_test_images)
	return personal_test_images

"""
Plots a single image with the predicted and real gesture underneath the image.
:param i: Iteration number in array of images
:param predictions_array: Array of gesture predictions percentages for image
:param true_label: Correct gesture for the image provided
:param img: Image to plot
"""
def plot_image(i, predictions_array, true_label, img):
	predictions_array = predictions_array[i]
	true_label = true_label[i]
	img = img[i]
	plt.grid(False)
	plt.xticks([])
	plt.yticks([])
	img = img[0]
	plt.imshow(img, cmap='gray')

	predicted_label = np.argmax(predictions_array)
	true_label = np.argmax(true_label)
	if predicted_label == true_label:
		color = 'blue'
	else:
		color = 'red'
  
	plt.xlabel("{} {:2.0f}% ({})".format(GESTURE_NAMES[predicted_label],
								100*np.max(predictions_array),
								GESTURE_NAMES[true_label]),
								color=color)

"""
Plots the gesture prediction percentages next to the image.
:param i: Iteration number in array of images
:param predictions_array: Array of gesture predictions percentages for image
:param true_label: Correct gesture for the image provided
"""
def plot_value_array(i, predictions_array, true_label):
	predictions_array, true_label = predictions_array[i], true_label[i]
	plt.grid(False)
	plt.xticks([])
	plt.yticks([])
	thisplot = plt.bar(range(5), predictions_array, color="#777777")
	plt.ylim([0, 1])
	predicted_label = np.argmax(predictions_array)
 
	thisplot[predicted_label].set_color('red')
	thisplot[np.argmax(true_label)].set_color('blue')
  
###############################################################################
# Main logic
###############################################################################

# Read in images and attach a label to each image
training_image_list = loadTrainingData()
testing_image_list = loadTestingData()
personal_testing_image_list = loadPersonalTestingData()

training_image_list += testing_image_list[0:500]

# Reshape images to be passed through the convolution layers
training_images = np.array([i[0] for i in training_image_list])\
					.reshape(-1,X_OF_IMAGES,Y_OF_IMAGES,1)
training_labels = np.array([i[1] for i in training_image_list])
testing_images = np.array([i[0] for i in testing_image_list])\
					.reshape(-1,X_OF_IMAGES,Y_OF_IMAGES,1)
testing_labels = np.array([i[1] for i in testing_image_list])
personal_testing_images = np.array([i[0] for i in personal_testing_image_list])\
							.reshape(-1,X_OF_IMAGES,Y_OF_IMAGES,1)
personal_testing_labels = np.array([i[1] for i in personal_testing_image_list])

# Pass all images through a Sobel filter
#map(lambda x:tf.image.sobel_edges(x), training_images)
#map(lambda x:tf.image.sobel_edges(x), testing_images)
#map(lambda x:tf.image.sobel_edges(x), personal_testing_images)

# Preprocess all images so the values for each images fall between 0 and 1
training_images = training_images / 255.0
testing_images = testing_images / 255.0
personal_testing_images = personal_testing_images / 255.0

# Set parameters and layers for the model
model = keras.Sequential([
	keras.layers.InputLayer(input_shape=[X_OF_IMAGES,Y_OF_IMAGES,1]),
	keras.layers.Conv2D(filters=32,
						kernel_size=5,
						strides=1,
						padding='same',
						activation='relu'),
	keras.layers.MaxPool2D(pool_size=5,
						   padding='same'),
	keras.layers.Conv2D(filters=50,
						kernel_size=5,
						strides=1,
						padding='same',
						activation='relu'),
	keras.layers.MaxPool2D(pool_size=5,
						   padding='same'),
	keras.layers.Conv2D(filters=80,
						kernel_size=5,
						strides=1,
						padding='same',
						activation='relu'),
	keras.layers.MaxPool2D(pool_size=5,
						   padding='same'),
	keras.layers.Dropout(0.25),
	keras.layers.Flatten(),
	keras.layers.Dense(512, activation=tf.nn.relu),
	keras.layers.Dropout(0.5),
	keras.layers.Dense(5, activation=tf.nn.softmax),
])

# Compile model with the following parameters
model.compile(optimizer=tf.train.AdamOptimizer(),
			  loss='categorical_crossentropy',
			  metrics=['accuracy'])

# Create model based on above parameters for the training images
model.fit(training_images,
		  training_labels,
		  epochs=NUMBER_OF_EPOCHS,
		  batch_size=32)

# Calculate and print accuracy for training, test, and personal test images
training_loss, training_accuracy = model.evaluate(training_images,
												  training_labels)
testing_loss, testing_accuracy = model.evaluate(testing_images,
												testing_labels)
personal_loss, personal_accuracy = model.evaluate(personal_testing_images,
												  personal_testing_labels)
print('Training accuracy:', training_accuracy)
print('Testing accuracy:', testing_accuracy)
print('Personal testing accuracy:', personal_accuracy)

# Get category percentages for all test images
predictions = model.predict(personal_testing_images)

# Print the first 25 test images, and their predicted values for each category
# Uncomment plt.show to see the plot
num_rows = 4
num_cols = 2
num_images = num_rows*num_cols
plt.figure(figsize=(2*2*num_cols, 2*num_rows))
for i in range(num_images):
	plt.subplot(num_rows, 2*num_cols, 2*i+1)
	plot_image(i, predictions, personal_testing_labels, personal_testing_image_list)
	plt.subplot(num_rows, 2*num_cols, 2*i+2)
	plot_value_array(i, predictions, personal_testing_labels)
plt.show()