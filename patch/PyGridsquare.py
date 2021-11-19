#!/usr/bin/env python3

from gpsdclient import GPSDClient
import maidenhead as mh

client = GPSDClient(host="127.0.0.1")

for result in client.dict_stream(convert_datetime=True):
    if result["class"] == "TPV":
        lat = result.get("lat", "n/a")
        lon = result.get("lon", "n/a")
        gridsquare = mh.to_maiden(lat, lon)
        print(gridsquare)
        break
