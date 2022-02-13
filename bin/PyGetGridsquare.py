#!/usr/bin/python3

#PyGetGridsquare.py 
#Last updated 8 Feb 2022
#Kevin - KD9EFV


from gps3 import gps3
import maidenhead as mh
import sys
import os.path
import time

# Write  GridSquare to usable location
def write_info(data, fix):
#    print(data + " " + str(fix))
    file1 = open("/run/user/1000/gridinfo.txt","w")
    file1.write(str(data))
    file1.close()

# Sanity Check for gpsd device setup
# if there isn't a device listed in
# the file then no need to continue
def check_device():
    with open('/etc/default/gpsd') as temp_f:
        datafile = temp_f.readlines()
    for line in datafile:
        if not 'DEVICES' in line:
            continue
        if not '/dev/' in line:
                write_info("GPSD_CONF",0)
                sys.exit("GPSD DEVICES= NOT CONFIGURED")
    return True # The string is found

# Sanity Check for GPSD Installed
if not os.path.isfile('/etc/default/gpsd'):
        write_info("GPSD_ERR",0)
        sys.exit("GPSD Not Installed")

# Sanity Check for a device set in GPSD
# if check_device() == 'False':
#    write_info("GPSD_ERR",0)
#    sys.exit("GPSD DEVICES= not set in /etc/default/gpsd")
check_device()

t_end = time.time() + 5
gps_socket = gps3.GPSDSocket()
data_stream = gps3.DataStream()
gps_socket.connect()
gps_socket.watch()
throwaway = gps3.DataStream()
tries = 0
for new_data in gps_socket:
    if not time.time() < t_end:
        write_info("GPS_ERR",0)
        sys.exit("NO GPS DATA")
    if new_data:
        data_stream.unpack(new_data)
        usb_dev = data_stream.TPV['device']
        alt = data_stream.TPV['alt']
        lat = data_stream.TPV['lat']
        lon = data_stream.TPV['lon']
        mode = data_stream.TPV['mode']
        if tries == 5:
            write_info('*NO DEVICE*', 0)
            sys.exit()
        if mode == 'n/a':
            mode = 0
            gridsquare = "NO GPS"
        if mode == 3:
            gridsquare = mh.to_maiden(lat, lon)
            print(gridsquare)
        elif mode == 1:
            gridsquare = "NO FIX"
        elif mode == 2:
            gridsquare = "2D FIX"
        if mode != 0:
            write_info(gridsquare, mode)
            break
        tries = tries + 1

