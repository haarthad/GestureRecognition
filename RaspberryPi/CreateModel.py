import cv2
import numpy as np
import os
from random import shuffle
from tqdm import tqdm
import tensorflow as tf
import matplotlib.pyplot as plt
%matplotlib inline
from keras.models import Sequential
from keras.layers import *
from keras.optimizers import *

###############################################################################
# Defines
###############################################################################
train_data  = '/ImageData/Train'
test_data   = '/ImageData/Test'
X_OF_IMAGES = 64
Y_OF_IMAGES = 64

###############################################################################
# Main logic
###############################################################################
training_images = trainData()
testing_images = testData()

train_image_data = np.array([i[0] for i in training_images])
                   .reshape(-1,X_OF_IMAGES,Y_OF_IMAGES,1)
train_labels     = np.array([i[1] for i in training_images])

test_image_data = np.array([i[0] for i in testing_images])
                  .reshape(-1,X_OF_IMAGES,Y_OF_IMAGES,1)
test_labels     = np.array([i[1] for i in testing_images])

model = keras.Sequential([
	keras.layers.Flatten(input_shape=(X_OF_IMAGES,Y_OF_IMAGES)),
	keras.layers.Dense(128, activation=tf.nn.relu),
	keras.layers.Dense(10, activation=tf.nn.softmax)
])

model.compile(optimizer=tf.train.AdamOptimizer(),
			  loss='sparse_categorical_crossentropy',
			  metrics=['accuracy'])
			  
model.fit(train_image_data,train_labels,epochs=50)

###############################################################################
# Methods
###############################################################################
def assignHotLabel(image):
	label = image.split('-')[0]
	if label == 'A':
		hot_label = np.array([1,0,0,0,0,0])
	else if label == 'B':
		hot_label = np.array([0,1,0,0,0,0])
	else if label == 'C':
		hot_label = np.array([0,0,1,0,0,0])
	else if label == 'Five':
		hot_label = np.array([0,0,0,1,0,0])
	else if label == 'Point':
		hot_label = np.array([0,0,0,0,1,0])
	else if label == 'V':
		hot_label = np.array([0,0,0,0,0,1])
	return hot_label
	
def trainData():
	train_images = []
	for i in tqdm(os.listdir(train_data)):
		path = os.path.join(train_data, i)
		image = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
		image = cv2.resize(image, (X_OF_IMAGES, Y_OF_IMAGES))
		train_images.append([np.array(image), one_hot_label(i)])
	shuffle(train_images)
	return train_images
	
def testData():
	test_images = []
	for i in tqdm(os.listdir(test_data)):
		path = os.path.join(test_data, i)
		image = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
		image = cv2.resize(image, (X_OF_IMAGES, Y_OF_IMAGES))
		test_images.append([np.array(image), one_hot_label(i)])
	shuffle(test_images)
	return test_images