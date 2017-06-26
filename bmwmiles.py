#!/usr/bin/env python
# 
# This depends on: https://github.com/edent/BMW-i-Remote
# This may also be helpful in your credentials.json... 
# "auth_basic": "blF2NkNxdHhKdVhXUDc0eGYzQ0p3VUVQOjF6REh4NnVuNGNEanliTEVOTjNreWZ1bVgya0VZaWdXUGNRcGR2RFJwSUJrN3JPSg==",
# 
import bmw
import json
from dateutil import parser
import sys

# Connect to the server
c = bmw.ConnectedDrive()

#	Get the VIN
vehicle_json = c.call("/user/vehicles/")
vin = vehicle_json["vehicles"][0]["vin"]

#	Vehicle Status
status_url  = "/user/vehicles/"+vin+"/status"
status_json = c.call(status_url)["vehicleStatus"]
mileage          = status_json["mileage"] * bmw.KM_TO_MILES
print "{:,.0f}".format(round(mileage,2))
