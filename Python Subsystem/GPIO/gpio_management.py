## @package gpio_management
# This file does the setup for all of the GPIO's that will be used.

# import the gpio library for the pi, print error if it can't
try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print("Error importing RPi.GPIO")

# Assign variables to GPIO numbers to avoid magic numbers
# DOUBLE CHECK THESE PINOUT NUMBERS ARE CORRECT
# Done on top level so that they can be easily called
pixel_input1, pixel_input2, pixel_input3 = 8, 10, 12
pixel_input4, pixel_input5, pixel_input6 = 16, 18, 22
pixel_input7, pixel_input8, read_finished = 24, 26, 32
start_of_image, pixel_stable = 36, 38

##
# Initialize all of the GPIO ports
def pixelReceptionInit():
    # Pins will be refered to by the GPIO numbers as labeled on the pi
    # This is nice because GPIO numbers don't change between pi board revisions
    GPIO.setmode(GPIO.BOARD)
    # Set the GPIOS to either inputs or outputs and set them all to pull down
    # This can be done with a channel list but doing that hides errors and warnings.
    GPIO.setup(pixel_input1, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixel_input2, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixel_input3, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixel_input4, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixel_input5, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixel_input6, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixel_input7, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixel_input8, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(start_of_image, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(pixel_stable, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

    GPIO.setup(read_finished, GPIO.OUT, initial=GPIO.LOW)

