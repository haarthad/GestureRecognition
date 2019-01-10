# Import TensorFlow and tf.keras
import tensorflow as tf
from tensorflow import keras

# Load default model
model = initRecognition()

###############################################################################
# This method initializes teh recognition part of the system. It initializes
# any variables and loads the default model that was created earlier.
###############################################################################
def initRecognition():
    # Load saved model
    return keras.models.load_model('default_model.h5')
