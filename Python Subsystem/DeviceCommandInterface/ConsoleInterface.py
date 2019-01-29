
# Bring your packages onto the path
import sys, time
sys.path.append("..")

# Now do your import

#import Timer, TimeGrabber

from DeviceCommands import Timer, TimeGrabber, WeatherGrabber, CalendarGrabber, SportsGrabber

def printUI():
    print()
    print()
    print("Welcome to your Dandy Electronic Live Textual Assistant")
    print("-------------------------------------------------------")
    print("Please input your desired command:")
    print("1) Current Time")
    print("2) 1-Minute Timer")
    print("3) Today's Weather")
    print("4) Upcoming Calendar Events")
    print("5) Recent Sports Scores")
    print("-------------------------------------------------------")
    waitForInput()

def waitForInput():
    val = input("Command: ")
    parseInput(val)

def parseInput(val):
    if val=="1":
        TimeGrabber.main()
    elif val=="2":
        Timer.main()
    elif val=="3":
        WeatherGrabber.main()
    elif val=="4":
        CalendarGrabber.main()
    elif val=="5":
        SportsGrabber.main()

    time.sleep(5)
    printUI()

if __name__ == "__main__":
    printUI()