#!/bin/bash
##################################
#	AUTO-WHITELIST
##################################
source /home/pi/pi-build/config

cd ~/bin
wget https://raw.githubusercontent.com/km4ack/pi-scripts/master/auto-whitelist
cd
cp $HOME/pi-scripts/.whitelist* $HOME
sed -i "s/MYEMAIL=test@winlink.org/MYEMAIL=$CALL@arrl.net/" /home/pi/bin/auto-whitelist
sed -i "s/CALLSIGN=WB0SIO/CALLSIGN=$CALL/" /home/pi/.whitelist.txt

bash ~/bin/auto-whitelist setup
