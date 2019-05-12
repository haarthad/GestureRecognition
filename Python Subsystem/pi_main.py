## package @pi_main
# This file creates all the processes for the Python Subsystem,
# including GPIO and TensorFlow. This is the only script that
# needs to be run on the Pi.
#

from multiprocessing import Process, Queue
from TensorFlow import ImageRecognition as ir
from GPIO import pixel_management as pm


##
# This method creates communication queues for use between
# ImageTransmission and ImageRecognition, and creates
# for a separate process for ImageTransmission and ImageRecognition.
#
def main():
    pixel_queue = Queue()
    error_queue = Queue()
    p1 = Process(target=pm.pixelEnqueue, args=(pixel_queue, error_queue))
    p2 = Process(target=ir.runRecognition,
                 args=(pixel_queue,
                       error_queue,
                       'TensorFlow/SavedModels/image_recognition_model.h5',
                       'DeviceCommands/'))
    p1.start()
    p2.start()
    p1.join()
    p2.join()


if __name__ == "__main__":
    main()
