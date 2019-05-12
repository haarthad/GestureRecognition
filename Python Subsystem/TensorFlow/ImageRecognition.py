## @package ImageRecognition
# Main file for the Image Recognition portion of the system. Calling the
# runRecognition() method as a process will start Image Recognition and gather
# images from the pixel_queue, process them, and call the appropriate gesture
# command.
#

import sys
sys.path.append("..")
from keras.models import load_model
from keras.utils import CustomObjectScope
from keras.initializers import glorot_uniform
import cv2
import numpy as np
from queue import Empty
from DeviceCommands import CalendarGrabber, TimeGrabber, SportsGrabber, \
                           Timer, WeatherGrabber
import scipy.ndimage as nd


# Defines
WHITE_COLOR = 255.0
BLACK_COLOR = 0.0
X_OF_IMAGES = 64
Y_OF_IMAGES = 64


# Methods


##
# Initializes the recognition part of the system and any variables, and loads
# the default model that was created earlier.
# @param model_path Filepath to where the image recognition model is saved
# @return Loaded image recognition model
def initRecognition(model_path):
    # Load image recognition model
    with CustomObjectScope({'GlorotUniform': glorot_uniform()}):
        loaded_model = load_model(model_path)
    print("IR - Successfully loaded model")
    return loaded_model


##
# Validates that all pixel values in the image are within valid pixel ranges,
# 0 and 255.
# @param image Image from Image Transmission
# @return 1 if there is an invalid pixel value, 0 if all pixels are valid
def validateImage(image):
    if np.all(i <= WHITE_COLOR for i in image) and \
       np.all(i >= BLACK_COLOR for i in image):
        return 0
    else:
        return 1


##
# Grabs image from queue between Image Transmission and Image Recognition,
# validates all pixel values, runs image through model to get prediction
# values, and runs the gesture command associated with the largest prediction
# value
# @param pixel_queue Queue of images from Image Transmission
# @param error_queue Queue for error code/messages between Image Recognition
#                    and Image Transmission
# @param model_path Filepath to where the image recognition model is saved
# @param commands_path Filepath to where the command scripts are located
# @returns Current status of the new_gesture flag
def processImage(pixel_queue, error_queue, model, commands_path, new_gesture):
    try:
        # Grab image from queue if any, timeout after 10 seconds
        image = pixel_queue.get(True, 10)
    except Empty:
        print("ERROR - IR - Max timeout (10 seconds) exceeded")
        return

    # Validate that all pixel values in the transferred image are within 0
    # and 255
    if validateImage(image) == 0:
        print("IR - Valid Image")
    else:
        print("ERROR - IR - Invalid Image")
        return

    # Apply sobel filter to image
    image = image.astype('int32')
    dx = nd.sobel(image, 1)
    dy = nd.sobel(image, 0)
    image = np.hypot(dx, dy)
    image *= WHITE_COLOR / np.max(image)

    # Reformat image data to work with the model
    image = cv2.resize(image, (X_OF_IMAGES, Y_OF_IMAGES))
    image = image.reshape(-1, X_OF_IMAGES, Y_OF_IMAGES, 1)
    image = image / WHITE_COLOR

    # Run image through model and get a prediction
    prediction = model.predict(image)

    # See what the model predicts with the highest percentage
    print("Percentage of gesture predicted: " + np.axam(prediction))
    predicted_gesture = np.argmax(prediction[0])

    # Call correct command for the predicted gesture
    if new_gesture:
        if predicted_gesture == 0:
            print("IR - Gesture A")
            Timer.main()
        elif predicted_gesture == 1:
            print("IR - Gesture B")
            TimeGrabber.main()
        elif predicted_gesture == 2:
            print("IR - Gesture C")
            CalendarGrabber.main(commands_path)
        elif predicted_gesture == 3:
            print("IR - Gesture G")
            SportsGrabber.main()
        elif predicted_gesture == 4:
            print("IR - Gesture V")
            WeatherGrabber.main()
        elif predicted_gesture == 5:
            print("IR - Gesture Nothing")
        else:
            print("ERROR - IR - Invalid Gesture")
        # Wait for a nothing gesture, to take in a new gesture
        new_gesture = False
    else:
        if predicted_gesture == 5:
            print("IR - Gesture Reset")
            # Now accept a new gesture command
            new_gesture = True

    # Add spacer line
    print("\r\n")

    return new_gesture


# Main logic


##
# Main method for image recognition. Loads the model and infinitely runs
# the process image method.
# @param pixel_queue Queue of images from Image Transmission
# @param error_queue Queue for error code/messages between Image Recognition
#                    and Image Transmission
# @param model_path Filepath to where the image recognition model is saved
# @param commands_path Filepath to where the command scripts are located
def runRecognition(pixel_queue, error_queue, model_path, commands_path):
    # Wait for nothing category and then accept a gesture, repeat
    new_gesture = False

    # Load default model
    image_recognition_model = initRecognition(model_path)

    # Constantly read in and process images
    while True:
        new_gesture = processImage(pixel_queue,
                                   error_queue,
                                   image_recognition_model,
                                   commands_path, new_gesture)