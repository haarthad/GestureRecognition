## @package WeatherGrabber
# Grabs your current weather based on IP
#

import sys
import requests, json

##
# Gets your current location via IP
# https://stackoverflow.com/questions/24678308/how-to-find-location-with-ip-address-in-python
# @return: latlon Array containing latitude/longitude
#
def getLoc():
    send_url = 'http://ipinfo.io/json'
    r = requests.get(send_url)
    j = json.loads(r.content.decode('utf-8'))
    loc = j['loc']
    latlon = [x.strip() for x in loc.split(',')]
    return latlon

##
# Makes a query out to openweathermap using to determine weather in your location
#
def main():
    latlon = getLoc()
    base_url = 'http://api.openweathermap.org/data/2.5/weather?'
    payload = {
    'lat': latlon[0],
    'lon': latlon[1],
    'units': 'imperial',
    'APPID': '655d0c8eef3680920a2033c87abb0472'
    }
    r = requests.get(base_url, params=payload)  # gets json output
    data = r.json()
    temp = data["main"]["temp"]
    desc = data["weather"][0]["description"]
    print(temp,"F", desc)

##
# Default main block
#
if __name__ == "__main__":
    main()