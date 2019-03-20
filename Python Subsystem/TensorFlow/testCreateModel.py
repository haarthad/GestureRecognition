###############################################################################
# This file creates a CNN model, saved in the SavedModels folder, with training
# images found in the ImageData/Training folder. It runs the images through
# a complex TensorFlow model consisting of Convolution layers and Neural
# Network layers to reach a high prediction accuracy of 94-97%. The model
# works best with using a simple solid white or black background.
#
# Ideas the follow article were used for loading in images from a folder,
# creating a CNN model, and other miscellaneous methods:
# https://blog.francium.tech/build-your-own-image-classifier-with-tensorflow-
# and-keras-dc147a15e38e
#
# Ideas from TensorFlow's basic classification were preprocessing the data,
# setting up model layers and configurations, and different ways to plot the
# images:
# https://www.tensorflow.org/tutorials/keras/basic_classification
#
# Images in the training and test folder were gathered from the Jochen Triesch
# Static Hand Posture Database and the Sebastien Marcel Static Hand Posture
# Database based at http://www.idiap.ch/resource/gestures/
###############################################################################

import cv2
import numpy as np
import os
from random import shuffle
from tqdm import tqdm
import tensorflow as tf
from tensorflow import keras
import matplotlib.pyplot as plt
import scipy.ndimage as nd
from keras.applications import MobileNet
from keras.applications.mobilenet import preprocess_input
from keras.preprocessing.image import ImageDataGenerator
from keras.models import Model
from keras.layers import Dense,GlobalAveragePooling2D

###############################################################################
# Defines
###############################################################################
TRAINING_DATA =      'ImageData/Train'
TESTING_DATA =       'ImageData/Test'
EXTRA_TESTING_DATA = 'ImageData/ExtraTest'
GESTURE_NAMES =      ['A', 'B', 'C', 'G', 'V', 'Random', 'Nothing']
X_OF_IMAGES =        64
Y_OF_IMAGES =        64
NUMBER_OF_EPOCHS =   20
NUMBER_OF_GESTURES = 6
BATCH_SIZE =         50
WHITE_COLOR =        255.0

###############################################################################
# Methods
###############################################################################

"""
Perform sobel, noise, rotation, and translation transformations on the
provided image, and return an array of images that have the
transformations applied.
:param image: Image to be transformed
:param path: Filepath to the image
"""
def sobelTransform(image):
    sobel_image = cv2.Sobel(image, cv2.CV_64F, 0, 1, ksize=5)
    return sobel_image

"""
Adds layers and other configuration settings to a model
:return Model with layers and configuration
"""
def setupModel():
#    base_model = MobileNet(weights='imagenet',
#                           include_top=False)  # imports the mobilenet model and discards the last 1000 neuron layer.
#
#    x = base_model.output
#    x = GlobalAveragePooling2D()(x)
#    x = Dense(1024, activation='relu')(
#        x)  # we add dense layers so that the model can learn more complex functions and classify for better results.
#    x = Dense(1024, activation='relu')(x)  # dense layer 2
#    x = Dense(512, activation='relu')(x)  # dense layer 3
#    preds = Dense(7, activation='softmax')(x)  # final layer with softmax activation

#    model = Model(inputs=base_model.input, outputs=preds)

#    for layer in model.layers[:20]:
#        layer.trainable = False
#    for layer in model.layers[20:]:
#        layer.trainable = True

    # Set parameters and layers for the model
    model = keras.models.Sequential([
        #keras.layers.InputLayer(input_shape=(X_OF_IMAGES, Y_OF_IMAGES, 1)),
        # 2D convolution layer
        keras.layers.Conv2D(filters=32,
                            kernel_size=5,
                            strides=1,
                            padding='same',
                            activation='relu',
                            input_shape=(X_OF_IMAGES, Y_OF_IMAGES,3)),
        # Max pooling operation for spatial data
        keras.layers.MaxPool2D(pool_size=5,
                               padding='same'),
        keras.layers.Dropout(0.5),
        keras.layers.Conv2D(filters=64,
                            kernel_size=5,
                            strides=1,
                            padding='same',
                            activation='relu'),
        keras.layers.MaxPool2D(pool_size=5,
                               padding='same'),
        keras.layers.Dropout(0.5),
        keras.layers.Conv2D(filters=75,
                            kernel_size=5,
                            strides=1,
                            padding='same',
                            activation='relu'),
        keras.layers.MaxPool2D(pool_size=5,
                               padding='same'),
        keras.layers.Dropout(0.5),
        # Fraction of the input units to drop, helps prevent overfitting
        keras.layers.Flatten(),
        keras.layers.Dropout(0.5),
        # Regular densely-connected NN layer
        keras.layers.Dense(256, activation=tf.nn.relu),
        keras.layers.Dense(NUMBER_OF_GESTURES, activation=tf.nn.softmax),
    ])

    # Compile model with the following parameters
    model.compile(optimizer='adam',
                  loss='categorical_crossentropy',
                  metrics=['accuracy'])

    model.summary()

    return model

###############################################################################
# Main logic
###############################################################################

# Setup layers and other configuration settings for the model
image_recognition_model = setupModel()

train_datagen=ImageDataGenerator(preprocessing_function=sobelTransform,
                                 rescale=1./255,
                                 rotation_range=30,
                                 width_shift_range=0.2,
                                 height_shift_range=0.2,
                                 zoom_range=0.3,
                                 validation_split=0.1) #included in our dependencies

test_datagen=ImageDataGenerator(preprocessing_function=sobelTransform,
                                rescale=1./255)

train_generator=train_datagen.flow_from_directory('ImageData/Train',
                                                 target_size=(64,64),
                                                 color_mode='rgb',
                                                 batch_size=64,
                                                 class_mode='categorical',
                                                 shuffle=True,
                                                 seed=34)

test_generator=test_datagen.flow_from_directory('ImageData/Test',
                                                 target_size=(64,64),
                                                 color_mode='rgb',
                                                 batch_size=1,
                                                 class_mode='categorical',
                                                 shuffle=True,
                                                 seed=32)

print(train_generator.n)

image_recognition_model.fit_generator(generator=train_generator,
                                      steps_per_epoch=train_generator.n//train_generator.batch_size,
                                      epochs=10,
                                      validation_data=test_generator,
                                      validation_steps=test_generator.n//test_generator.batch_size)

image_recognition_model.evaluate_generator(generator=test_generator,
                                           steps=test_generator.n)

# Save model
image_recognition_model.save('./SavedModels/image_recognition_model.h5')