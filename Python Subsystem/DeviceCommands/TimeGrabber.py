##################################################################################################
# Script that displays current time as a digital clock
##################################################################################################

import sys, time

##################################################################################################
# Methods
##################################################################################################

"""
Uses datetime to grab the current time
https://stackoverflow.com/questions/37515587/run-a-basic-digital-clock-in-the-python-shell
"""
def displayClock():
            from datetime import datetime
            now = datetime.now()
            print("\r%s/%s/%s %s:%s:%s\r\n" % (now.month, now.day, now.year, now.hour, now.minute, now.second), flush=True, end='')
            time.sleep(1)

##################################################################################################
# Main logic
##################################################################################################
			
"""
Simply calls displayClock()
"""
def main():
	displayClock()
			
"""
Default main block
"""
if __name__ == "__main__":
    main()