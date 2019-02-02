# import the gpio library for the pi, print error if it can't
try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print("Error importing RPi.GPIO")

# Assign variables to GPIO numbers to avoid magic numbers
# DOUBLE CHECK THESE PINOUT NUMBERS ARE CORRECT
# Done on top level so that they can be easily called
pixelInput1, pixelInput2, pixelInput3 = 8, 10, 12
pixelInput4, pixelInput5, pixelInput6 = 16, 18, 22
pixelInput7, pixelInput8, validFrame = 24, 26, 32
readFinished, startOfImage, pixelStable = 36, 38, 40


# Initialize all of the GPIO ports
def pixelReceptionInit():
    # Pins will be refered to by the GPIO numbers as labeled on the pi
    # This is nice because GPIO numbers don't change between pi board revisions
    GPIO.setmode(GPIO.BOARD)
    # Set the GPIOS to either inputs or outputs and set them all to pull down

    GPIO.setup(pixelInput1, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixelInput2, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixelInput3, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixelInput4, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixelInput5, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixelInput6, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixelInput7, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixelInput8, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(startOfImage, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(validFrame, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixelStable, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

    GPIO.setup(readFinished, GPIO.OUT, initial=GPIO.LOW)
    # Add an event to detect the start of the image signal
    # Later on use GPIO.event_detected(channel) to check if an image has started
    GPIO.add_event_detect(startOfImage, GPIO.RISING)
