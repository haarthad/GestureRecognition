# import the gpio library for the pi, print error if it can't
try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print ("Error importing RPi.GPIO")

# Assign variables to GPIO numbers to avoid magic numbers
# DOUBLE CHECK THESE PINOUT NUMBERS ARE CORRECT
# Done on top level so that they can be easily called
pixelInput1, pixelInput2, pixelInput3 = 8, 9, 7
pixelInput4, pixelInput5, pixelInput6 = 0, 2, 3
pixelInput7, pixelInput8, readyToSend = 12, 13, 14
readyToRecieve, startOfImage = 21, 22

# Initialize all of the GPIO ports
def pixelReceptionInit():
    # Pins will be refered to by the GPIO numbers as labeled on the pi
    # This is nice because GPIO numbers don't change between pi board revisions
    GPIO.setmode(GPIO.BOARD)
    # Set the GPIOS to either inputs or outputs and set them all to pull down
    channel_list = [pixelInput1,pixelInput2,pixelInput3,pixelInput4,pixelInput5,
    pixelInput6,pixelInput7,pixelInput8,readyToSend,startOfImage]
    GPIO.setup(channel_list, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(readyToRecieve, GPIO.OUT, pull_up_down=GPIO.PUD_DOWN)
    # Add an event to detect the start of the image signal
    # Later on use GPIO.event_detected(channel) to check if an image has started
    GPIO.add_event_detect(startOfImage, GPIO.RISING)
