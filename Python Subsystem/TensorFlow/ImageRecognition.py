from tensorflow import keras

###############################################################################
# This method initializes the recognition part of the system. It initializes
# any variables and loads the default model that was created earlier.
###############################################################################
def initRecognition():
    # Load image recognition model
    loaded_model = keras.models.load_model('./SavedModels/image_recognition_model.h5')
    loaded_model.summary()
    return loaded_model


# Load default model
image_recognition_model = initRecognition()




