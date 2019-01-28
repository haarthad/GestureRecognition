from multiprocessing import Process, Queue
import pixel_management as pm
import Therecognitionstuff as Pr


def main():
    pixelQueue = Queue.Queue()
    errorQueue = Queue.Queue()
    p1 = Process(target=pm.pixelEnqueue, args=(pixelQueue, errorQueue,))
    p2 = Process(target=Pr.StarterFunction, args=(pixelQueue, errorQueue,))
    p1.start()
    p2.start()
    p1.join()
    p2.join()


if __name__ == "__main__":
    main()
