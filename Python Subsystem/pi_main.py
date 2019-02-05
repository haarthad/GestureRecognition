from multiprocessing import Process, Queue
from TensorFlow import ImageRecognition as ir
#from GPIO import pixel_management as pm


def main():
    pixelQueue = Queue()
    errorQueue = Queue()
    #p1 = Process(target=pm.pixelEnqueue, args=(pixelQueue, errorQueue))
    p2 = Process(target=ir.runRecognition,
                 args=(pixelQueue,
                       errorQueue,
                       'TensorFlow/SavedModels/image_recognition_model.h5',
                       'DeviceCommands/'))
    #p1.start()
    p2.start()
    #p1.join()
    p2.join()


if __name__ == "__main__":
    main()
