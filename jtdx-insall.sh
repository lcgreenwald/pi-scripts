#!/bin/bash
##################################
#	JTDX
##################################
#This code is left in place but no option is given during inital
#run or update because the jtdx website is down.
#see https://github.com/km4ack/pi-build/issues/153
#14OCT2020 KM4ACK


cd $HOME
#curl won't work here. Returns "forbidden" Use wget instead
wget -qO jtdx.txt https://www.jtdx.tech/en/
VER=$(grep r_armhf.deb jtdx.txt | awk '{print $2}' | sed 's/"//g' | sed 's/href=\/downloads\/Linux\///')
rm jtdx.txt

wget https://www.jtdx.tech/downloads/Linux/$VER

sudo dpkg -i $VER
sudo apt-get --fix-broken -y install
sudo dpkg -i $VER
rm $VER

