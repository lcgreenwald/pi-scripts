#!/bin/bash

#this script used to check for apps that need updates

UPDATEFILE=/run/user/1000/bapupdate.txt

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
	Log2ram="Not Installed" >>$UPDATEFILE
else
	Log2ram="Installed" >>$UPDATEFILE
fi
#----------------------------------------------------#
#		LOCATE
#----------------------------------------------------#
if ! hash locate 2>/dev/null; then
	Locate="Not Installed" >>$UPDATEFILE
else
	Locate="Installed" >>$UPDATEFILE
fi
#----------------------------------------------------#
#		PLANK
#----------------------------------------------------#
if ! hash plank 2>/dev/null; then
	Plank="Not Installed" >>$UPDATEFILE
else
	Plank="Installed" >>$UPDATEFILE
fi
#----------------------------------------------------#
#		SAMBA
#----------------------------------------------------#
if ! hash samba 2>/dev/null; then
	Samba="Not Installed" >>$UPDATEFILE
else
	Samba="Installed" >>$UPDATEFILE
fi
#----------------------------------------------------#
#		WEBMIN
#----------------------------------------------------#
if [ ! -d /usr/share/webmin 2>/dev/null ]; then
	Webmin="Not Installed" >>$UPDATEFILE
else
	Webmin="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		3.5" DISPLAY DRIVERS
#----------------------------------------------------#
if [ ! -d ${HOME}/LCD-show 2>/dev/null ]; then
	Display="Not Installed" >>$UPDATEFILE
else
	Display="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		Cqrprop
#----------------------------------------------------#
if ! hash  cqrprop 2>/dev/null ; then
	Cqrprop="Not Installed" >>$UPDATEFILE
else
	Cqrprop="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		Disks
#----------------------------------------------------#
if ! hash  gnome-disks 2>/dev/null ; then
	Disks="Not Installed" >>$UPDATEFILE
else
	Disks="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		PiImager
#----------------------------------------------------#
if ! hash  rpi-imager 2>/dev/null ; then
	PiImager="Not Installed" >>$UPDATEFILE
else
	PiImager="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		Neofetch
#----------------------------------------------------#
if ! hash  neofetch 2>/dev/null ; then
	Neofetch="Not Installed" >>$UPDATEFILE
else
	Neofetch="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		Commander Pi
#----------------------------------------------------#
if [ ! -d ${HOME}/CommanderPi 2>/dev/null ]; then
	CommanderPi="Not Installed" >>$UPDATEFILE
else
	CommanderPi="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		Fortune
#----------------------------------------------------#
if [ ! -f /usr/share/terminfo/f/fortune 2>/dev/null ]; then
	Fortune="Not Installed" >>$UPDATEFILE
else
	Fortune="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		DeskPi
#----------------------------------------------------#
if [ ! -d ${HOME}/deskpi 2>/dev/null ]; then
	DeskPi="Not Installed" >>$UPDATEFILE
else
	DeskPi="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		Argon
#----------------------------------------------------#
if [ ! -f /etc/argononed.conf 2>/dev/null ]; then
	Argon="Not Installed" >>$UPDATEFILE
else
	Argon="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		PiSafe
#----------------------------------------------------#
if [ ! -f ${HOME}/pisafe 2>/dev/null ]; then
	PiSafe="Not Installed" >>$UPDATEFILE
else
	PiSafe="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		RPiMonitor
#----------------------------------------------------#
if ! hash rpimonitor 2>/dev/null ; then
	RPiMonitor="Not Installed" >>$UPDATEFILE
else
	RPiMonitor="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		JS8map
#----------------------------------------------------#
if [ ! -d ${HOME}/js8map 2>/dev/null ]; then
	JS8map="Not Installed" >>$UPDATEFILE
else
	JS8map="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		X715
#----------------------------------------------------#
if [ ! -d ${HOME}/x715 2>/dev/null ]; then
	X715="Not Installed" >>$UPDATEFILE
else
	X715="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		ZramSwap
#----------------------------------------------------#
if [ ! -d ${HOME}/Downloads/zram-swap 2>/dev/null ]; then
	ZramSwap="Not Installed" >>$UPDATEFILE
else
	ZramSwap="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		nmon
#----------------------------------------------------#
if ! hash nmon 2>/dev/null ; then
	nmon="Not Installed" >>$UPDATEFILE
else
	nmon="Installed" >>$UPDATEFILE
fi

#----------------------------------------------------#
#		Weather
#----------------------------------------------------#
if ! hash weather 2>/dev/null ; then
	nmon="Not Installed" >>$UPDATEFILE
else
	nmon="Installed" >>$UPDATEFILE
fi

}

CHECK
