# Python Subsystem
This folder contains the Python GPIO/Tensorflow image reception and recognition subsystem.

## Getting Started
Run the code provided below to install the required packages to run the scripts in this folder:
```
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install python3-pip libatlas-base-dev libqtgui4 libqt4-test python3-pyqt5 libjasper-dev libilmbase-dev libopenexr-dev libgstreamer1.0-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev python-rpi.gpio python3-rpi.gpio libhdf5-dev libsdl-ttf2.0-0 libsdl-mixer1.2
pip3 install tqdm opencv-python tensorflow matplotlib scipy google-api-python-client oauth2client pygame weather-api Pillow keras h5py
```

## Deployment
Once the packages are installed, run 'pi_main.py' to spawn the processes for the main GPIO and TensorFlow scripts. 
If you add custom images into the ImageData folder, run the 'CreateModel.py' script to create a new CNN 
TensorFlow model from the images provided in the ImageData folder. The model used in 'ImageRecognition.py' 
is located in the SavedModels folder as 'image_recognition_model.h5'.

## Authors
* Colton Agathen
* Adam Haarth
* Connor Kroll
