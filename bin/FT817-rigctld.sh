#!/bin/bash
# Set up rigctld for the Yaesu FT-817
# Bluetooth
#rigctld -m 120 -r /dev/rfcomm0 -s 38400
# USB cable
rigctld -m 120 -r /dev/ttyUSB0 -s 38400
#rigctld -m 120 -r /dev/ttyUSB1 -s 38400
