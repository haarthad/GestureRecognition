from multiprocessing import Process, Queue
from TensorFlow import ImageRecognition as ir
from GPIO import pixel_management_test as pm


def main():
    errorQueue = Queue()
    pixelQueue = Queue()
    stableQueue = Queue()
    finishedQueue = Queue()
    sendQueue = Queue(5)
    p1 = Process(target=pixelEnqueue, args=(pixelQueue, stableQueue, finishedQueue, sendQueue))
    p2 = Process(target=picSender, args=(pixelQueue, stableQueue, finishedQueue))
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

