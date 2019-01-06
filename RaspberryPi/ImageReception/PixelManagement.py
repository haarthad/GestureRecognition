# import the gpio library for the pi, print error if it can't.
import GPIOManagement as GM
try:
    import RPi.GPIO as GPIO
except RuntimeError:
    print ("Error importing RPi.GPIO")

# Outputs 1 or 0 depending on if the pin is high or low.
def inputConversion(channel):
    if GPIO.input(channel):
        return 1
    else:
        return 0

# Main function that pulls the pixel values and stores them into a list.
def main():
    # Initialize the list with the right amount of pixel data.
    # In the future this will be modified to be a list of lists.
    # The overall list will be the number of pixels, and then each sublist is 8 large.
    pixelList = [None] * 304486
    iterator = 0
    # Initialize the GPIOS.
    GM.pixelReceptionInit()
    # For testing purposes run in a loop.
    while True:
        # If its the start of an image set the ready to receive to low to block the FPGA from moving on.
        if GPIO.event_detected(GM.startOfImage):
            GPIO.output(GM.readyToRecieve,GPIO.LOW)
            # Set up a loop the size of the data we will be taking in.
            while iterator < 304486:
                # Now we are ready to receive pixels so set that pin high
                GPIO.output(GM.readyToRecieve,GPIO.HIGH)
                # Once high wait for 1 second for the pixel to be sent
                sentDetect = GPIO.wait_for_edge(GM.pixelSent, timeout=1000)
                if sentDetect is None:
                    print("Timeout Occurred: FPGA didn't send data within 1 second of receiving ready signal.")
                else:
                    # Collect data from the GPIOS and put it into a list.
                    # While collecting data tell the FPGA to not change the values.
                    GPIO.output(GM.readyToRecieve,GPIO.LOW)
                    # Take in all data and convert it to a string containing a binary number, assuming msb is input1
                    tempBinVal = ""+str(inputConversion(GM.pixelInput1))+str(inputConversion(GM.pixelInput2))+str(
                    inputConversion(GM.pixelInput3))+str(inputConversion(GM.pixelInput4))+str(inputConversion(GM.pixelInput5))+str(
                    inputConversion(GM.pixelInput6))+str(inputConversion(GM.pixelInput7))+str(inputConversion(GM.pixelInput8))
                    # Convert binary string to integer then store in list
                    pixelList[iterator]=int(tempBinVal,2)
                    # Increment the iterator and then move on
                    iterator++

# Main name check
if __name__ == "__main__":
    main()

