# DELTA
Your Dandy Electronic Live Textual Assistant as designed by MSOE's own Senior Design Team Delta.

## What Does it Do?
DELTA is designed to respond to American Sign Language (ASL) letters and render an appropriate 
and timely response. Currently, it is potentially capable of:
* Displaying the current time
* Creating a 5 minute timer
* Grabbing the most recent sports scores
* Grabbing the current weather based on your IP
* Displaying upcoming calendar events

It is also expandable to any number of extra features, provided you're willing to put the time in. As
long as the gesture is static, it shouldn't have many problems.

The goal here was a device marketable as a "Google Home"/"Alexa"/whatevertheheckhomeassistant for those
that cannot speak for whatever reason.

## How Does it Do That?
DELTA works in two parts: a VHDL image capture system and a Python recognition system.

### VHDL Subsystem
The VHDL subsystem is responsible for grabbing an image through an Altera D5M camera module and 
shooting it across GPIO to an awaiting Raspberry PI. An HDL was chosen over a soft implementation
becaus of the speed benefits it provides, and realistically would make sense in a marketable device.

### Python Subsystem
The Python subsystem is responsible for responding to incoming messages on GPIO, dishing them out to
a trained TensorFlow model, and rendering a response textually based on whatever TensorFlow determines
the output to be.

## Authors
* Colton Agathen
* Michael Dougherty
* Adam Haarth
* Kevin Hughes
* Connor Kroll
* Other authors presented in subsection READMEs where applicable