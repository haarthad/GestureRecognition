from tensorflow import keras
import numpy as np

"""
Initializes the recognition part of the system and any variables, and loads
the default model that was created earlier.
:return Loaded model
"""
def initRecognition():
    # Load image recognition model
    loaded_model = keras.models.load_model('./SavedModels/image_recognition_model.h5')
    loaded_model.summary()
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


###############################################################################
# Main logic
###############################################################################

# Load default model
image_recognition_model = initRecognition()

# Load image from Image Transmission
# Check Flag
# If flag is set, get ndarray (image data), and clear flag

image = -1 # Placeholder

# Validate that all pixel values in the transferred image are within 0 and 255
if validateImage(image)==0:
    print("Valid Image")
else:
    print("Invalid Image")



