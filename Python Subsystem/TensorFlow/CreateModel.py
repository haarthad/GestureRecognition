## @package CreateModel
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
#

import cv2
import numpy as np
import os
from random import shuffle
from tqdm import tqdm
import tensorflow as tf
from tensorflow import keras
import matplotlib.pyplot as plt
import scipy.ndimage as nd


# Defines
TRAINING_DATA =      'ImageData/Train'
TESTING_DATA =       'ImageData/Test'
EXTRA_TESTING_DATA = 'ImageData/ExtraTest'
GESTURE_NAMES =      ['A', 'B', 'C', 'G', 'V', 'Nothing']
X_OF_IMAGES =        64
Y_OF_IMAGES =        64
NUMBER_OF_EPOCHS =   30
NUMBER_OF_GESTURES = 6
BATCH_SIZE =         50
WHITE_COLOR =        255.0


# Transformation matrices
matrix_rotate_right = cv2.getRotationMatrix2D((X_OF_IMAGES / 2, Y_OF_IMAGES / 2), 30, 1)
matrix_rotate_left =  cv2.getRotationMatrix2D((X_OF_IMAGES / 2, Y_OF_IMAGES / 2), -30, 1)
matrix_translate_top_left =  np.float32([[1, 0, -15], [0, 1,  15]])
matrix_translate_top_right = np.float32([[1, 0,  15], [0, 1,  15]])
matrix_translate_bot_left =  np.float32([[1, 0, -15], [0, 1, -15]])
matrix_translate_bot_right = np.float32([[1, 0,  15], [0, 1, -15]])


##
# Returns the appropriate "hot" label for the provided image based on the
# filename.
# @param image: TensorFlow image to assign label to.
# @return Label for the image
#
def selectLabel(image):
    # Get beginning of filename. This defines each gesture is shown in the
    # image.
    gesture = image[0]
    label = np.array([0, 0, 0, 0, 0, 0])

    # Return correct label based on which gesture the image is
    # N is for Nothing
    if gesture == 'A':
        label = np.array([1, 0, 0, 0, 0, 0])
    elif gesture == 'B':
        label = np.array([0, 1, 0, 0, 0, 0])
    elif gesture == 'C':
        label = np.array([0, 0, 1, 0, 0, 0])
    elif gesture == 'G':
        label = np.array([0, 0, 0, 1, 0, 0])
    elif gesture == 'V':
        label = np.array([0, 0, 0, 0, 1, 0])
    elif gesture == 'N':
        label = np.array([0, 0, 0, 0, 0, 1])
    return label


##
# Perform sobel, noise, rotation, and translation transformations on the
# provided image, and return an array of images that have the
# transformations applied.
# @param image: Image to be transformed
# @param path: Filepath to the image
#
def imageTransformation(image,path):
    images = []
    noisy_image = image + np.random.normal(0.0, 10.0, image.shape)

    # Force image to use int32
    image = image.astype('int32')
    # Apply sobel filter in x and y direction
    dx = nd.sobel(image, 1)
    dy = nd.sobel(image, 0)
    # Combine the two directions into one image
    sobeled_image = np.hypot(dx, dy)
    sobeled_image *= WHITE_COLOR / np.max(sobeled_image)
    # Repeat for noisy image
    dxn = nd.sobel(noisy_image, 1)
    dyn = nd.sobel(noisy_image, 0)
    sobeled_noisy_image = np.hypot(dxn, dyn)
    sobeled_noisy_image *= WHITE_COLOR / np.max(sobeled_noisy_image)

    # Apply 30/-30 degree rotation to both images
    image_rotated_right =       cv2.warpAffine(sobeled_image,
                                               matrix_rotate_right,
                                               (X_OF_IMAGES, Y_OF_IMAGES))
    noisy_image_rotated_right = cv2.warpAffine(sobeled_noisy_image,
                                               matrix_rotate_right,
                                               (X_OF_IMAGES, Y_OF_IMAGES))
    image_rotated_left =        cv2.warpAffine(sobeled_image,
                                               matrix_rotate_left,
                                               (X_OF_IMAGES, Y_OF_IMAGES))
    noisy_image_rotated_left =  cv2.warpAffine(sobeled_noisy_image,
                                               matrix_rotate_left,
                                               (X_OF_IMAGES, Y_OF_IMAGES))

    # Translate images
    image_translated_top_left = cv2.warpAffine(sobeled_image,
                                               matrix_translate_top_left,
                                               (X_OF_IMAGES,Y_OF_IMAGES))
    image_translated_top_right = cv2.warpAffine(sobeled_image,
                                                matrix_translate_top_right,
                                                (X_OF_IMAGES,Y_OF_IMAGES))
    image_translated_bot_left = cv2.warpAffine(sobeled_image,
                                               matrix_translate_bot_left,
                                               (X_OF_IMAGES,Y_OF_IMAGES))
    image_translated_bot_right = cv2.warpAffine(sobeled_image,
                                                matrix_translate_bot_right,
                                                (X_OF_IMAGES,Y_OF_IMAGES))
    noisy_image_translated_top_left = cv2.warpAffine(sobeled_image,
                                                     matrix_translate_top_left,
                                                     (X_OF_IMAGES,Y_OF_IMAGES))
    noisy_image_translated_top_right = cv2.warpAffine(sobeled_image,
                                                      matrix_translate_top_right,
                                                      (X_OF_IMAGES,Y_OF_IMAGES))
    noisy_image_translated_bot_left = cv2.warpAffine(sobeled_image,
                                                     matrix_translate_bot_left,
                                                     (X_OF_IMAGES,Y_OF_IMAGES))
    noisy_image_translated_bot_right = cv2.warpAffine(sobeled_image,
                                                      matrix_translate_bot_right,
                                                      (X_OF_IMAGES,Y_OF_IMAGES))

    # Load images into the array for training
    label = selectLabel(path)
    images.append([np.array(sobeled_image), label])
    images.append([np.array(sobeled_noisy_image), label])
    images.append([np.array(image_rotated_right), label])
    images.append([np.array(noisy_image_rotated_right), label])
    images.append([np.array(image_rotated_left), label])
    images.append([np.array(noisy_image_rotated_left), label])
    images.append([np.array(image_translated_top_left),label])
    images.append([np.array(image_translated_top_right),label])
    images.append([np.array(image_translated_bot_left),label])
    images.append([np.array(image_translated_bot_right),label])
    images.append([np.array(noisy_image_translated_top_left),label])
    images.append([np.array(noisy_image_translated_top_right),label])
    images.append([np.array(noisy_image_translated_bot_left),label])
    images.append([np.array(noisy_image_translated_bot_right),label])

    return images


##
# Reads in all training images, and returns them as TensorFlow images with
# labels attached.
# @return: Training images with labels
#
def loadTrainingData():
    train_images = []
    for i in tqdm(os.listdir(TRAINING_DATA)):
        path = os.path.join(TRAINING_DATA, i)
        image = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
        image = cv2.resize(image, (X_OF_IMAGES, Y_OF_IMAGES))
        # Apply multiple data augmentations to the image
        train_images.extend(imageTransformation(image,i))

    shuffle(train_images)
    return train_images


##
# Reads in all testing images, and returns them as TensorFlow images with
# labels attached.
# @return: Testing images with labels
#
def loadTestingData():
    test_images = []
    for i in tqdm(os.listdir(TESTING_DATA)):
        path = os.path.join(TESTING_DATA, i)
        image = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
        image = cv2.resize(image, (X_OF_IMAGES, Y_OF_IMAGES))

        # Apply sobel filter
        image = image.astype('int32')
        dx = nd.sobel(image, 1)
        dy = nd.sobel(image, 0)
        mag = np.hypot(dx, dy)
        mag *= WHITE_COLOR / np.max(mag)

        test_images.append([np.array(mag), selectLabel(i)])

    shuffle(test_images)
    return test_images


##
# Reads in all personal testing images, and returns them as TensorFlow images
# with labels attached.
# @return: Personal testing images with labels
#
def loadPersonalTestingData():
    personal_test_images = []
    for i in tqdm(os.listdir(EXTRA_TESTING_DATA)):
        path = os.path.join(EXTRA_TESTING_DATA, i)
        image = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
        image = cv2.resize(image, (X_OF_IMAGES, Y_OF_IMAGES))

        # Apply sobel filter
        image = image.astype('int32')
        dx = nd.sobel(image, 1)
        dy = nd.sobel(image, 0)
        mag = np.hypot(dx, dy)
        mag *= WHITE_COLOR / np.max(mag)

        personal_test_images.append([np.array(mag), selectLabel(i)])

    shuffle(personal_test_images)
    return personal_test_images


##
# Plots a single image with the predicted and real gesture underneath the image.
# @param i: Iteration number in array of images
# @param predictions_array: Array of gesture predictions percentages for image
# @param true_label: Correct gesture for the image provided
# @param img: Image to plot
#
def plotImage(i, predictions_array, true_label, img):
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


##
# Plots the gesture prediction percentages next to the image.
# @param i: Iteration number in array of images
# @param predictions_array: Array of gesture predictions percentages for image
# @param true_label: Correct gesture for the image provided
#
def plotValueArray(i, predictions_array, true_label):
    predictions_array, true_label = predictions_array[i], true_label[i]
    plt.grid(False)
    plt.xticks([])
    plt.yticks([])
    thisplot = plt.bar(range(NUMBER_OF_GESTURES),
                       predictions_array,
                       color="#777777")
    plt.ylim([0, 1])
    predicted_label = np.argmax(predictions_array)
 
    thisplot[predicted_label].set_color('red')
    thisplot[np.argmax(true_label)].set_color('blue')


##
# Takes in a list of images, reshapes them to work with the convolution layers,
# applies a label to each image, and changes the value to be between 0 and 1.
# @param image_list List of images
# @return Reshaped images and their labels
#
def processImages(image_list):
    # Reshape images to be passed through the convolution layers
    images = np.array([i[0] for i in image_list]) \
        .reshape(-1, X_OF_IMAGES, Y_OF_IMAGES, 1)
    labels = np.array([i[1] for i in image_list])

    # Preprocess all images so the values for each images fall between 0 and 1
    images = images / WHITE_COLOR

    return images, labels


##
# Adds layers and other configuration settings to a model
# @return Model with layers and configuration
def setupModel():
    # Set parameters and layers for the model
    model = keras.models.Sequential([
        keras.layers.InputLayer(input_shape=(X_OF_IMAGES,Y_OF_IMAGES,1)),
        # 2D convolution layer
        keras.layers.Conv2D(filters=32,
                            kernel_size=5,
                            strides=1,
                            padding='same',
                            activation='relu',
                            input_shape=(X_OF_IMAGES,Y_OF_IMAGES,1)),
        # Max pooling operation for spatial data
        keras.layers.MaxPool2D(pool_size=5,
                               padding='same'),
        keras.layers.Conv2D(filters=64,
                            kernel_size=5,
                            strides=1,
                            padding='same',
                            activation='relu'),
        keras.layers.MaxPool2D(pool_size=5,
                               padding='same'),
        keras.layers.Conv2D(filters=75,
                            kernel_size=5,
                            strides=1,
                            padding='same',
                            activation='relu'),
        keras.layers.MaxPool2D(pool_size=5,
                               padding='same'),
        # Fraction of the input units to drop, helps prevent overfitting
        keras.layers.Dropout(0.25),
        keras.layers.Flatten(input_shape=(X_OF_IMAGES,Y_OF_IMAGES)),
        # Regular densely-connected NN layer
        keras.layers.Dense(256, activation=tf.nn.relu),
        keras.layers.Dropout(0.5),
        keras.layers.Dense(NUMBER_OF_GESTURES, activation=tf.nn.softmax),
    ])

    # Compile model with the following parameters
    model.compile(optimizer='adam',
                  loss=keras.losses.categorical_crossentropy,
                  metrics=['accuracy'])

    return model


##
# Prints a 5x5 graph of images from the image_list with the predicted
# category, and the prediction values for the image for each category.
# @param model Model to predict images
# @param images Images to be predicted
# @param labels Labels for the images
# @param image_list Images to be printed
def printAccuracyGraph(model, images, labels, image_list):
    # Get category percentages for all test images
    predictions = model.predict(images)

    # Print the first 72 images, and their predicted values for each category
    # Uncomment plt.show to see the plot
    num_rows = 9
    num_cols = 8
    num_images = num_rows*num_cols
    plt.figure(figsize=(2*2*num_cols, 2*num_rows))
    for i in range(num_images):
        plt.subplot(num_rows, 2*num_cols, 2*i+1)
        plotImage(i, predictions, labels, image_list)
        plt.subplot(num_rows, 2*num_cols, 2*i+2)
        plotValueArray(i, predictions, labels)
    plt.show()


##
# Main logic of the script that reads in images, formats, creates model,
# tests model, and then saves the model.
def mainLogic():

    # Read in images and attach a label to each image
    training_image_list =      loadTrainingData()
    testing_image_list =       loadTestingData()
    extra_testing_image_list = loadPersonalTestingData()

    # Reshape images and preprocess values
    training_images, training_labels = processImages(training_image_list)
    testing_images, testing_labels = processImages(testing_image_list)
    extra_testing_images, extra_testing_labels = processImages(extra_testing_image_list)

    # Setup layers and other configuration settings for the model
    image_recognition_model = setupModel()

    # Create model based on above parameters for the training images
    image_recognition_model.fit(training_images,
                                training_labels,
                                epochs=NUMBER_OF_EPOCHS,
                                batch_size=BATCH_SIZE)

    # Calculate and print accuracy for training, test, and personal test images
    training_loss, training_accuracy = image_recognition_model.evaluate(training_images,
                                                      training_labels)
    testing_loss, testing_accuracy = image_recognition_model.evaluate(testing_images,
                                                    testing_labels)
    extra_loss, extra_accuracy = image_recognition_model.evaluate(extra_testing_images,
                                                      extra_testing_labels)

    # Print accuracy percentages for each image folder
    print('Training accuracy:', training_accuracy)
    print('Testing accuracy:', testing_accuracy)
    print('Extra testing accuracy:', extra_accuracy)

    # Print prediction values for each image in the ExtraTest folder
    printAccuracyGraph(image_recognition_model,
                       extra_testing_images,
                       extra_testing_labels,
                       extra_testing_image_list)

    # Save model
    image_recognition_model.save('./SavedModels/image_recognition_model.h5')


if __name__ == "__main__":
    mainLogic()