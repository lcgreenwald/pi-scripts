#!/bin/bash

#script to install GPS Dongle for Raspberry Pi 
#km4ack 20190911
#Last Edit km4ack 20191014
# Modified: 2020/12/29 WB0SIO - added 'allow' to chrony.conf

#check if running as root
IAM=$(whoami)
if [ $IAM = "root" ]
then
echo 
else
echo "Please run this script as root"
exit 0
fi

#install needed packages
echo "installing a few needed packages"
apt install -y scons gpsd-clients python-gps chrony python-gi-cairo asciidoctor libncurses5-dev python-dev pps-tools
wget --tries 2 --connect-timeout=60 http://download-mirror.savannah.gnu.org/releases/gpsd/gpsd-3.23.1.tar.xz
tar -xf gpsd-3.23.1.tar.xz
cd gpsd-3.23.1
scons && scons check && scons udev-install

#backup gpsd file
mv /etc/default/gpsd /etc/default/gpsd.org

#download gpsd file
wget --tries 2 --connect-timeout=60 https://raw.githubusercontent.com/km4ack/pi-scripts/master/gpsd -P /etc/default/

echo "refclock SHM 0 offset 0.5 delay 0.2 refid NMEA" >> /etc/chrony/chrony.conf

echo " " >> /etc/chrony/chrony.conf
echo "# Allow this computer to be a time server." >> /etc/chrony/chrony.conf
echo "allow" >> /etc/chrony/chrony.conf

echo "";echo "";echo ""
echo "#############################################################################################"
echo "#instructions at https://raw.githubusercontent.com/km4ack/pi-scripts/master/gps-instruction #"
echo "#############################################################################################"
echo "Reboot is needed to complete"

