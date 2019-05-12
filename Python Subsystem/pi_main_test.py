## package @pi_main_test
# This file is made to test all parts of the Python Subsystem by
# mimicking images being transmitted from the FPGA to the PI, and
# then receiving that image, processing it, and calling the
# correct gesture command.

from multiprocessing import Process, Queue
from TensorFlow import ImageRecognition as ir
from GPIO import pixel_management_test as pm


##
# This method creates three processes. One that mimics the FPGA sends an image
# via the GPIO pins, one that receives the image, and one that runs the
# ImageRecognition code. There are multiple queues used to order to correctly
# test all parts.
#
def main():
    errorQueue = Queue()
    pixelQueue = Queue()
    stableQueue = Queue()
    finishedQueue = Queue()
    sendQueue = Queue(1)
    # ImageTransmission for Pi (Receiving)
    p1 = Process(target=pm.pixelEnqueue, args=(pixelQueue, stableQueue, finishedQueue, sendQueue))
    # Mimic code to the FPGA sends an image over GPIO
    p2 = Process(target=pm.picSender, args=(pixelQueue, stableQueue, finishedQueue))
    # ImageRecognition
    p3 = Process(target=ir.runRecognition,
                 args=(sendQueue,
                       errorQueue,
                       'TensorFlow/SavedModels/image_recognition_model.h5',
                       'DeviceCommands/'))
    p3.start()
    p2.start()
    p1.start()
    p1.join()
    p2.join()
    p3.join()


if __name__ == "__main__":
    main()

