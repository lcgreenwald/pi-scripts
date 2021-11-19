#!/bin/bash
##############################
# Python GPS setup
# created: 2021-11-19 Larry Greenwald
# Based on code by Kevin KD9EFV posted in https://groups.io/g/KM4ACK-Pi/topic/86954136#6311
# Modified:
#
##############################

##############################
# Update PIP
##############################
/usr/bin/python3 -m pip install --upgrade pip

##############################
# Install maidenhead and gpsdclient for python
##############################
sudo pip3 install gpsdclient
sudo pip3 install maidenhead

##############################
# to_maiden.py is defined with three inputs, (lat, lon, precision) however 
# calling mh.to_maiden(lat, lon) with all three throws a too many arguments error, limiting precision
# to three pair (AA11bb).
# This edit defaults the return to six pair precision. (AA11bb22CC33)
# 
##############################
sudo sed -i "s/precision: int = 3/precision: int = 6/" /usr/local/lib/python3.7/dist-packages/maidenhead/to_maiden.py
