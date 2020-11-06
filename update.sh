#!/bin/bash

###########################################################
#                                                    	    #
#	#   #	#       #     #      #        #####  #   #   	    #
#	#  #	# #   # #    ##     # #      #       #  #    	    #
#	# #		#   #   #   # #    #   #    #        # #         	#
#	##		#       #  #####  #######  #         ##          	#
#	# #		#       #     #   #     #   #        # #         	#
#	#  #	#       #     #   #     #    #       #  #        	#
#	#   #	#       #     #   #     #     #####  #   #       	#
#                                                        	#
###########################################################
#                                                        	#
#	Modified for WB0SIO pi-build-install update.  					#
#   6-November-2020 by WB0SIO                            	#
#                                                        	#
###########################################################

MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASE=$MYPATH/base.txt
FUNCTIONS=$MYPATH/functions
#CONFIG=$MYPATH/installapps
LOGO=$MYPATH/logo.png
TEMPCRON=$MYPATH/cron.tmp
VERSION=$(grep "version=" $MYPATH/changelog | sed 's/version=//')

FINISH(){
if [ -f "$BASE" ]; then
rm $BASE
fi
}

trap FINISH EXIT

#remove temp dir if exist
#fix issue 108 https://github.com/lcgreenwald/pi-scripts/issues/108
#Thanks to N5RKS for finding the bug
if [ -d $HOME/pi-build/temp ]; then
rm -rf $HOME/pi-build/temp
fi


#####################################
#	Create autostart dir
#used to autostart conky at boot
#####################################
mkdir -p $HOME/.config/autostart


#Check for pi-scripts updates
echo "Checking for Pi Scripts updates"
CURRENT=$(head -1 $MYPATH/changelog | sed s'/version=//')

LATEST=$(curl -s https://raw.githubusercontent.com/lcgreenwald/pi-scripts/master/changelog | tac | tac | head -1 | sed 's/version=//')

if (( $(echo "$LATEST $CURRENT" | awk '{print ($1 > $2)}') ))
then
cat <<EOF > $MYPATH/updatebap.txt
Pi Scripts update available. Current version is $CURRENT and
the lateest version is $LATEST. Would you like to update?

Change log - https://github.com/lcgreenwald/pi-scripts/blob/master/changelog
EOF
BAP=$(yad --width=650 --height=250 --text-align=center --center --title="Build-a-Pi"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/updatebap.txt \
--button="Yes":2 \
--button="No":3)
BUT=$?
echo $BUT
##########
	if [ $BUT = 252 ]; then 
	exit
	elif [ $BUT = 2 ]; then
	echo "Updating Pi Scripts to $LATEST"
	mv $MYPATH/config $HOME/Documents/config.bap
	rm -rf $MYPATH
	cd ~
	git clone https://github.com/lcgreenwald/pi-scripts.git
	mv $HOME/Documents/config.bap $MYPATH/config

cat <<EOF > $MYPATH/updatebap.txt
Pi Scripts has been updated to $LATEST. Please restart Pi Scripts.
EOF
	BAP=$(yad --width=650 --height=250 --text-align=center --center --title="Build-a-Pi"  --show-uri \
	--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
	--text-info<$MYPATH/updatebap.txt \
	--button="OK":2)
	BUT=$?
	exit 0
	fi
##########
fi
rm $MYPATH/updatebap.txt >> /dev/null 2>&1
rm $MYPATH/complete.txt >> /dev/null 2>&1
clear


#Scan system for updated applications
yad  --width=550 --height=250 --text-align=center --center --title="Update" \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text="<b>Version $VERSION</b>\r\r\r\rFirst we need to scan the system to see what is installed, \
then check for updates on the web. This should take less than a minute. Ready when you are." \
--button="Exit":1 \
--button="Start Scan":2
BUT=$?
if [ $BUT = 252 ] || [ $BUT = 1 ]; then
exit
fi

#install bc if not installed
if ! hash bc>/dev/null; then
sudo apt install -y bc
fi

CHECK(){
#----------------------------------------------------#
#		LOG2RAM
#----------------------------------------------------#
if ! hash log2ram 2>/dev/null; then
LOG2RAM="Not Installed"
else
LOG2RAM="Installed"
fi
#----------------------------------------------------#
#		LOCATE
#----------------------------------------------------#
if ! hash locate 2>/dev/null; then
LOCATE="Not Installed"
else
LOCATE="Installed"
fi
#----------------------------------------------------#
#		PLANK
#----------------------------------------------------#
if ! hash plank 2>/dev/null; then
PLANK="Not Installed"
else
PLANK="Installed"
fi
#----------------------------------------------------#
#		SAMBA
#----------------------------------------------------#
if ! hash samba 2>/dev/null; then
SAMBA="Not Installed"
else
SAMBA="Installed"
fi
#----------------------------------------------------#
#		WEBMIN
#----------------------------------------------------#
if ! hash webmin 2>/dev/null; then
WEBMIN="Not Installed"
else
WEBMIN="Installed"
fi

#----------------------------------------------------#
#		3.5" DISPLAY DRIVERS
#----------------------------------------------------#
if [ ! -d $HOME/LCD-show 2>/dev/null ]; then
3inDisplay="Not Installed"
else
3inDisplay="Installed"
fi

CHECK
####################################################################
####################################################################
####################################################################
####################################################################
####################################################################
####################################################################
####################################################################
####################################################################
####################################################################

#####################################
#	Base Apps
#####################################
yad --center --list --checklist --width=600 --height=600 --separator="" \
--image $LOGO --column=Check --column=App --column=Description \
--print-column=2 --window-icon=$LOGO --image-on-top --text-align=center \
--text="<b>Base Applications</b>" --title="Pi-Scripts Install" \
false "Log2Ram" "Create a RAM based log folder to reduce SD card wear." \
false "Locate" "File search utility" \
false "Plank" "Application dock." \
false "Samba" "SMB file system" \
false "Webmin" "Web based system manager." \
false "3inDisplay" "Drivers for a 3.5 in. touch screen display" \
--button="Exit":1 \
--button="Check All and Continue":3 \
--button="Next":2 > $BASE
BUT=$?
if [ $BUT = 252 ] || [ $BUT = 1 ]; then
exit
fi





#check and exit if nothing selected
CKBASE=$(cat $BASE)
if [ -z "$CKBASE" ]; then
rm $BASE  > /dev/null 2>&1
yad  --width=550 --height=250 --text-align=center --center --title="Update" \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text="\r\r\r\r<b>Nothing selected for install/update</b>" \
--button="CLOSE":1
exit
fi


#backup crontab 
crontab -l > $TEMPCRON
echo "@reboot sleep 10 && export DISPLAY=:0 && $MYPATH/.complete" >> $TEMPCRON
#update/upgrade the system
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt -y full-upgrade

#####################################
#	Install Base Apps
#####################################
touch $HOME/.config/WB0SIO
while read i ; do
source $FUNCTIONS/base.function
$i
done < $BASE


#####################################
#	END CLEANUP
#####################################
#Remove temp files
rm $BASE $ADDITIONAL $UTILITY $FLSUITE > /dev/null 2>&1


#restore crontab
crontab $TEMPCRON
rm $TEMPCRON
#reboot when done
yad --width=400 --height=200 --title="Reboot" --image $LOGO \
--text-align=center --skip-taskbar --image-on-top \
--wrap --center --window-icon=$LOGO \
--undecorated --text="<big><big><big><b>Update Finished \rReboot Required</b></big></big></big>\r\r" \
--button="Reboot Now":0 \
--button="Exit":1
BUT=$(echo $?)

if [ $BUT = 0 ]; then
echo rebooting
sudo reboot
elif [ $BUT = 1 ]; then
exit
fi



















