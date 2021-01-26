#!/bin/bash
##################################
#	Install QRZLookup by m0iax
# Call sign lookup for JS8Call
# 2021/01/26 wb0sio
##################################

pip3 install xmltodict
pip3 install requests

git clone https://github.com/m0iax/QRZLookup.git
chmod a+x QRZLookup/QRZLookup.py
