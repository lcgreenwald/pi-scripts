#!/bin/bash

#this script used to check for apps that need updates

UPDATEFILE=/run/user/${UID}/psupdate.txt

#Delete file if exist
if [ -f $UPDATEFILE ]; then
rm $UPDATEFILE
fi
#create new file
touch $UPDATEFILE

CHECK(){
#----------------------------------------------------#
#		LOG2RAM
#----------------------------------------------------#
if ! hash log2ram 2>/dev/null; then
	echo "Log2ram=Not_Installed" >>$UPDATEFILE
else
	echo "Log2ram=Installed" >>$UPDATEFILE
fi
#----------------------------------------------------#
#		LOCATE
#----------------------------------------------------#
if ! hash locate 2>/dev/null; then
	echo "Locate=Not_Installed" >>$UPDATEFILE
else
	echo "Locate=Installed" >>$UPDATEFILE
fi
#----------------------------------------------------#
#		PLANK
#----------------------------------------------------#
if ! hash plank 2>/dev/null; then
	echo "Plank=Not_Installed" >>$UPDATEFILE
else
	echo "Plank=Installed" >>$UPDATEFILE
fi
#----------------------------------------------------#
#		SAMBA
#----------------------------------------------------#
if ! hash samba 2>/dev/null; then
	echo "Samba=Not_Installed" >>$UPDATEFILE
else
	echo "Samba=Installed" >>$UPDATEFILE
fi
#----------------------------------------------------#
#		WEBMIN
#----------------------------------------------------#
if [ ! -d /usr/share/webmin 2>/dev/null ]; then
	echo "Webmin=Not_Installed" >>$UPDATEFILE
else
	echo "Webmin=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		3.5" DISPLAY DRIVERS
#----------------------------------------------------#
if [ ! -d ${HOME}/LCD-show 2>/dev/null ]; then
	echo "Display=Not_Installed" >>$UPDATEFILE
else
	echo "Display=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		Cqrprop
#----------------------------------------------------#
if ! hash  cqrprop 2>/dev/null ; then
	echo "Cqrprop=Not_Installed" >>$UPDATEFILE
else
	echo "Cqrprop=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		Disks
#----------------------------------------------------#
if ! hash  gnome-disks 2>/dev/null ; then
	echo "Disks=Not_Installed" >>$UPDATEFILE
else
	echo "Disks=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		PiImager
#----------------------------------------------------#
if ! hash  rpi-imager 2>/dev/null ; then
	echo "PiImager=Not_Installed" >>$UPDATEFILE
else
	echo "PiImager=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		Neofetch
#----------------------------------------------------#
if ! hash  neofetch 2>/dev/null ; then
	echo "Neofetch=Not_Installed" >>$UPDATEFILE
else
	echo "Neofetch=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		Commander Pi
#----------------------------------------------------#
if [ ! -d ${HOME}/CommanderPi 2>/dev/null ]; then
	echo "CommanderPi=Not_Installed" >>$UPDATEFILE
else
	echo "CommanderPi=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		Fortune
#----------------------------------------------------#
if [ ! -f /usr/share/terminfo/f/fortune 2>/dev/null ]; then
	echo "Fortune=Not_Installed" >>$UPDATEFILE
else
	echo "Fortune=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		DeskPi
#----------------------------------------------------#
if [ ! -d ${HOME}/deskpi 2>/dev/null ]; then
	echo "DeskPi=Not_Installed" >>$UPDATEFILE
else
	echo "DeskPi=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		Argon
#----------------------------------------------------#
if [ ! -f /etc/argononed.conf 2>/dev/null ]; then
	echo "Argon=Not_Installed" >>$UPDATEFILE
else
	echo "Argon=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		PiSafe
#----------------------------------------------------#
if [ ! -f ${HOME}/pisafe 2>/dev/null ]; then
	echo "PiSafe=Not_Installed" >>$UPDATEFILE
else
	echo "PiSafe=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		RPiMonitor
#----------------------------------------------------#
if ! hash rpimonitor 2>/dev/null ; then
	echo "RPiMonitor=Not_Installed" >>$UPDATEFILE
else
	echo "RPiMonitor=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		JS8map
#----------------------------------------------------#
if [ ! -d ${HOME}/js8map 2>/dev/null ]; then
	echo "JS8map=Not_Installed" >>$UPDATEFILE
else
	echo "JS8map=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		X715
#----------------------------------------------------#
if [ ! -d ${HOME}/x715 2>/dev/null ]; then
	echo "X715=Not_Installed" >>$UPDATEFILE
else
	echo "X715=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		ZramSwap
#----------------------------------------------------#
if [ ! -d ${HOME}/Downloads/zram-swap 2>/dev/null ]; then
	echo "ZramSwap=Not_Installed" >>$UPDATEFILE
else
	echo "ZramSwap=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		nmon
#----------------------------------------------------#
if ! hash nmon 2>/dev/null ; then
	echo "nmon=Not_Installed" >>$UPDATEFILE
else
	echo "nmon=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		Weather
#----------------------------------------------------#
if ! hash weather 2>/dev/null ; then
	echo "Weather=Not_Installed" >>$UPDATEFILE
else
	echo "Weather=Installed" >>$UPDATEFILE
fi


#----------------------------------------------------#
#		PythonGPS
#----------------------------------------------------#
if [ ! -f ${HOME}/bin/PyGridsquare.py 2>/dev/null ]; then
	echo "PythonGPS=Not_Installed" >>$UPDATEFILE
else
	echo "PythonGPS=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		Screensaver
#----------------------------------------------------#
if [ ! hash xscreensaver 2>/dev/null ]; then
	echo "Screensaver=Not_Installed" >>$UPDATEFILE
else
	echo "Screensaver=Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		CONKY
#----------------------------------------------------#
if [ -f ${HOME}/.conkyrc ]; then
	echo "Conky=Installed" >> $UPDATEFILE
else
	echo "Conky=Not_Installed" >> $UPDATEFILE
fi

#----------------------------------------------------#
#		GPARTED
#----------------------------------------------------#
if ! hash gparted 2>/dev/null; then
	echo "Gparted=Not_Installed" >> $UPDATEFILE
else
	echo "Gparted=Installed" >> $UPDATEFILE
fi

#----------------------------------------------------#
#		TIMESHIFT
#----------------------------------------------------#
if ! hash timeshift 2>/dev/null; then
	echo "Timeshift=Not_Installed" >> $UPDATEFILE
else
	echo "Timeshift=Installed" >> $UPDATEFILE
fi

}

CHECK
