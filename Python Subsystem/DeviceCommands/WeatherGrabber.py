import sys
import requests, json
from weather import Weather, Unit

#https://stackoverflow.com/questions/24678308/how-to-find-location-with-ip-address-in-python
def getLoc():
    send_url = 'http://ipinfo.io/json'
    r = requests.get(send_url)
    j = json.loads(r.content)
    loc = j['loc']
    latlon = [x.strip() for x in loc.split(',')]
    return latlon

#weather API documentation : https://pypi.org/project/weather-api/
def getWeatherString():
    weather = Weather(Unit.FAHRENHEIT)
    latlon = getLoc();
    lookup = weather.lookup_by_latlng(latlon[0], latlon[1])
    condition = lookup.condition
    print(condition.text + ',' + condition.temp + "F")

def main():
	getWeatherString()
	
if __name__ == "__main__":
    main()