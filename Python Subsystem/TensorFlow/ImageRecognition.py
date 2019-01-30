from tensorflow import keras
import numpy as np
from queue import Empty
from DeviceCommands import CalendarGrabber, TimeGrabber, SportsGrabber, Timer, WeatherGrabber

###############################################################################
# Methods
###############################################################################

"""
Initializes the recognition part of the system and any variables, and loads
the default model that was created earlier.
:return Loaded model
"""
def initRecognition():
    # Load image recognition model
    loaded_model = keras.models.load_model('TensorFlow/SavedModels/'
                                           'image_recognition_model.h5')
    print("IR - Successfully loaded model")
    return loaded_model

"""
Validates that all pixel values in the image are within valid pixel ranges,
0 and 255.
:param image Image from Image Transmission
:return 1 if there is an invalid pixel value, 0 if all pixels are valid
"""
def validateImage(image):
    for x in np.nditer(image):
        if x >255.0 or x < 0.0:
            return 1
    return 0


"""
Grabs image from queue between Image Transmission and Image Recognition,
validates all pixel values, runs image through model to get prediction
values, and runs the gesture command associated with the largest prediction 
value
"""
def processImage(pixel_queue, error_queue, model):
    try:
        # Grab image from queue if any, timeout after 5 seconds
        image = pixel_queue.get(True, 5)
    except Empty:
        print("ERROR - IR - Max timeout (5 seconds) exceeded")
        return

    # Validate that all pixel values in the transferred image are within 0
    # and 255
    if validateImage(image) == 0:
        print("IR - Valid Image")
    else:
        print("ERROR - IR - Invalid Image")
        return

    # Run image through model and get a prediction
    prediction = model.predict(image)

    # See what the model predicts with the highest percentage
    predicted_gesture = np.argmax(prediction[0])

    # Call correct command for the predicted gesture
    if predicted_gesture == 0:
        print("IR - Gesture A")
        Timer.main()
    elif predicted_gesture == 1:
        print("IR - Gesture B")
        TimeGrabber.main()
    elif predicted_gesture == 2:
        print("IR - Gesture C")
        CalendarGrabber.main()
    elif predicted_gesture == 3:
        print("IR - Gesture G")
        SportsGrabber.main()
    elif predicted_gesture == 4:
        print("IR - Gesture V")
    elif predicted_gesture == 5:
        WeatherGrabber.main()
        print("IR - Gesture Nothing")
    else:
        print("ERROR - IR - Invalid Gesture")


###############################################################################
# Main logic
###############################################################################

def runRecognition(pixel_queue, error_queue):
    # Load default model
    image_recognition_model = initRecognition()

    # Constantly read in and process images
    while True:
        processImage(pixel_queue,error_queue,image_recognition_model)








