import sys, time

# https://stackoverflow.com/questions/37515587/run-a-basic-digital-clock-in-the-python-shell
def displayClock():
        while True:
            from datetime import datetime
            now = datetime.now()
            print("\r%s/%s/%s %s:%s:%s" % (now.month, now.day, now.year, now.hour, now.minute, now.second), flush=True, end='')
            time.sleep(1)


if __name__ == "__main__":
    displayClock()