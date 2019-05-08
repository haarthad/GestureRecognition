## @package CalendarGrabber
# Script that logs into google calendar through google apis and pulls the next 10 events from the 
# user specified via credential files
#

from __future__ import print_function
import datetime
from googleapiclient.discovery import build
from httplib2 import Http
from oauth2client import file, client, tools
import logging

# If modifying these scopes, delete the file token.json.
SCOPES = 'https://www.googleapis.com/auth/calendar.readonly'

##
# Pulls data from the specified user's calendar
# @param commands_path: Path to token file
#
def main(commands_path):
    """Shows basic usage of the Google Calendar API.
    Prints the start and name of the next 10 events on the user's calendar.
    """

    # Ignore discovery cache warnings as we are using a version
    # of oauth2client >= 4.0.0
    logging.getLogger('googleapiclient.discovery_cache').setLevel(logging.ERROR)
    # Ignore URL request prints
    logging.getLogger('googleapiclient.discovery').setLevel(logging.ERROR)

    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    store = file.Storage(commands_path + 'token.json')
    creds = store.get()
    if not creds or creds.invalid:
        flow = client.flow_from_clientsecrets(commands_path + 'credentials.json', SCOPES)
        creds = tools.run_flow(flow, store)
    service = build('calendar', 'v3', http=creds.authorize(Http()))

    # Call the Calendar API
    now = datetime.datetime.utcnow().isoformat() + 'Z' # 'Z' indicates UTC time
    print('Getting the upcoming 10 events')
    events_result = service.events().list(calendarId='primary', timeMin=now,
                                        maxResults=10, singleEvents=True,
                                        orderBy='startTime').execute()
    events = events_result.get('items', [])
    if not events:
        print('No upcoming events found.')
    for event in events:
        startInfo = event['start'].get('dateTime', event['start'].get('date'))
        endInfo = event['end'].get('dateTime', event['end'].get('date'))
        # divvy up info based on delimiting charater
        day = startInfo.split('T')[0]
        # determine starttime/endtime based on json positioning
        if 'T' in startInfo:
            startTime = (startInfo.split('T')[1]).split('-')[0]
            endTime = (endInfo.split('T')[1]).split('-')[0]
            # print in nice format for case where startime/endtime are found
            print(day, event['summary'], startTime, '-', endTime)
        # else print a standard format w/o starttime/endtime in the event that they are not found
        else:
            print(day, event['summary'])

##
# default main block
#
if __name__ == '__main__':
    main("")
