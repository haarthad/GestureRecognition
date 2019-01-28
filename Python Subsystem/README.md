# Python Subsystem
This folder contains the Python GPIO/Tensorflow image reception and recognition subsystem.

## Getting Started
Run the code provided below to install the required packages to run the scripts in this folder:
```
sudo apt-get install python3-pip libatlas-base-dev libqtgui4 libqt4-test python3-pyqt5 
pip3 install tqdm opencv-python tensorflow matplotlib scipy google-api-python-client oauth2client pygame weather-api
```

## Deployment
Once the packages are installed, run 'pi_main.py' to spawn the processes for GPIO, TensorFlow, and DeviceCommands. 
If you add custom images into the ImageData folder, run the 'CreateModel.py' script to create a new CNN 
TensorFlow model from the images provided in the ImageData folder. The model used in 'ImageRecognition.py' 
is located in the SavedModels folder as 'image_recognition_model.h5'.

## Authors
* Colton Agathen
* Adam Haarth
* Connor Kroll
