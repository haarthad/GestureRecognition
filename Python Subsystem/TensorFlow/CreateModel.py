import cv2
import numpy as np
import os
from random import shuffle
from tqdm import tqdm
import tensorflow as tf
from tensorflow import keras
import matplotlib.pyplot as plt
import scipy.ndimage as nd

###############################################################################
# Defines
###############################################################################
TRAINING_DATA =      'ImageData/Train'
TESTING_DATA =       'ImageData/Test'
EXTRA_TESTING_DATA = 'ImageData/ExtraTest'
GESTURE_NAMES =      ['A', 'B', 'C', 'G', 'V', 'Nothing']
X_OF_IMAGES =        64
Y_OF_IMAGES =        64
NUMBER_OF_EPOCHS =   30
NUMBER_OF_GESTURES = 6
BATCH_SIZE =         50

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
    gesture = image[0]
    label = np.array([0, 0, 0, 0, 0, 0])

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
        noise = image + np.random.normal(0.0, 10.0, image.shape)

        #Force image to use int32
        image = image.astype('int32')
        #Apply sobel filter in x and y direction
        dx = nd.sobel(image, 1)
        dy = nd.sobel(image, 0)
        #Combine the two directions into one image
        mag = np.hypot(dx, dy)
        mag *= 255.0 / np.max(mag)
        #Repeat for noisy image
        dxn = nd.sobel(noise, 1)
        dyn = nd.sobel(noise, 0)
        magn = np.hypot(dxn, dyn)
        magn *= 255.0 / np.max(magn)

        # Apply 30/-30 degree rotation to both images
        rows, cols = mag.shape
        M = cv2.getRotationMatrix2D((cols / 2, rows / 2), 30, 1)
        rst = cv2.warpAffine(mag, M, (cols, rows))
        rowsn, colsn = magn.shape
        M = cv2.getRotationMatrix2D((colsn / 2, rowsn / 2), 30, 1)
        rstn = cv2.warpAffine(magn, M, (colsn, rowsn))
        rows, cols = mag.shape
        M = cv2.getRotationMatrix2D((cols / 2, rows / 2), -30, 1)
        orst = cv2.warpAffine(mag, M, (cols, rows))
        rowsn, colsn = magn.shape
        M = cv2.getRotationMatrix2D((colsn / 2, rowsn / 2), -30, 1)
        orstn = cv2.warpAffine(magn, M, (colsn, rowsn))

        # Load images into the array for training
        label = selectLabel(i)
        train_images.append([np.array(mag), label])
        train_images.append([np.array(magn), label])
        train_images.append([np.array(rst), label])
        train_images.append([np.array(rstn), label])
        train_images.append([np.array(orst), label])
        train_images.append([np.array(orstn), label])
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

        image = image.astype('int32')
        dx = nd.sobel(image, 1)
        dy = nd.sobel(image, 0)
        mag = np.hypot(dx, dy)
        mag *= 255.0 / np.max(mag)

        test_images.append([np.array(mag), selectLabel(i)])
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

        image = image.astype('int32')
        dx = nd.sobel(image, 1)
        dy = nd.sobel(image, 0)
        mag = np.hypot(dx, dy)
        mag *= 255.0 / np.max(mag)

        personal_test_images.append([np.array(mag), selectLabel(i)])
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
    thisplot = plt.bar(range(NUMBER_OF_GESTURES),
                       predictions_array,
                       color="#777777")
    plt.ylim([0, 1])
    predicted_label = np.argmax(predictions_array)
 
    thisplot[predicted_label].set_color('red')
    thisplot[np.argmax(true_label)].set_color('blue')


"""
Takes in a list of images, reshapes them to work with the convolution layers,
applies a label to each image, and changes the value to be between 0 and 1.
:param List of images
:return Reshaped images and their labels
"""
def process_images(image_list):
    # Reshape images to be passed through the convolution layers
    images = np.array([i[0] for i in image_list]) \
        .reshape(-1, X_OF_IMAGES, Y_OF_IMAGES, 1)
    labels = np.array([i[1] for i in image_list])

    # Preprocess all images so the values for each images fall between 0 and 1
    images = images / 255.0

    return images, labels

"""
Adds layers and other configuration settings to a model
:return Model with layers and configuration
"""
def setup_model():
    # Set parameters and layers for the model
    model = keras.models.Sequential([
        keras.layers.InputLayer(input_shape=(X_OF_IMAGES,Y_OF_IMAGES,1)),
        keras.layers.Conv2D(filters=32,
                            kernel_size=5,
                            strides=1,
                            padding='same',
                            activation='relu',
                            input_shape=(X_OF_IMAGES,Y_OF_IMAGES,1)),
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
        keras.layers.Flatten(input_shape=(64,64)),
        keras.layers.Dense(128, activation=tf.nn.relu),
        keras.layers.Dropout(0.5),
        keras.layers.Dense(NUMBER_OF_GESTURES, activation=tf.nn.softmax),
    ])

    # Compile model with the following parameters
    model.compile(optimizer='adam',
                  loss=keras.losses.categorical_crossentropy,
                  metrics=['accuracy'])

    return model

"""
Prints a 5x5 graph of images from the image_list with the predicted
category, and the prediction values for the image for each category.
:param model Model to predict images
:param images Images to be predicted
:param labels Labels for the images
:param image_list Images to be printed
"""
def print_accuracy_graph(model, images, labels, image_list):
    # Get category percentages for all test images
    predictions = model.predict(images)

    # Print the first 25 images, and their predicted values for each category
    # Uncomment plt.show to see the plot
    num_rows = 9
    num_cols = 8
    num_images = num_rows*num_cols
    plt.figure(figsize=(2*2*num_cols, 2*num_rows))
    for i in range(num_images):
        plt.subplot(num_rows, 2*num_cols, 2*i+1)
        plot_image(i, predictions, labels, image_list)
        plt.subplot(num_rows, 2*num_cols, 2*i+2)
        plot_value_array(i, predictions, labels)
    plt.show()


###############################################################################
# Main logic
###############################################################################

# Read in images and attach a label to each image
training_image_list =      loadTrainingData()
testing_image_list =       loadTestingData()
extra_testing_image_list = loadPersonalTestingData()

# Reshape images and preprocess values
training_images, training_labels = process_images(training_image_list)
testing_images, testing_labels = process_images(testing_image_list)
extra_testing_images, extra_testing_labels = process_images(extra_testing_image_list)

# Setup layers and other configuration settings for the model
image_recognition_model = setup_model()

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
personal_loss, personal_accuracy = image_recognition_model.evaluate(extra_testing_images,
                                                  extra_testing_labels)

# Print accuracy percentages for each image folder
print('Training accuracy:', training_accuracy)
print('Testing accuracy:', testing_accuracy)
print('Personal testing accuracy:', personal_accuracy)

# Print prediction values for each image in the ExtraTest folder
print_accuracy_graph(image_recognition_model,
                     extra_testing_images,
                     extra_testing_labels,
                     extra_testing_image_list)

# Save model
image_recognition_model.save('./SavedModels/image_recognition_model.h5')