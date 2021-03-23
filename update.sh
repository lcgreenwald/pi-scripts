#!/bin/bash

###########################################################
#                                                         #
# #   # #       #     #      #        #####  #   #        #
# #  #  # #   # #    ##     # #      #       #  #         #
# # #   #   #   #   # #    #   #    #        # #          #
# ##    #       #  #####  #######  #         ##           #
# # #   #       #     #   #     #   #        # #          #
# #  #  #       #     #   #     #    #       #  #         #
# #   # #       #     #   #     #     #####  #   #        #
#                                                         #
###########################################################
#                                                         #
# Modified for WB0SIO pi-build-install update.            #
#   6-November-2020 by WB0SIO                             #
#                                                         #
###########################################################

MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASE=$MYPATH/base.txt
FUNCTIONS=$MYPATH/functions
LOGO=$MYPATH/logo.png
VERSION=$(grep "version=" $MYPATH/changelog | sed 's/version=//')

FINISH(){
if [ -f "$BASE" ]; then
rm $BASE
fi
}

trap FINISH EXIT

#####################################
# Create autostart dir
# used to autostart conky at boot
#####################################
if [ -d $HOME/.config/autostart ]; then
  mkdir -p $HOME/.config/autostart
fi

#************
#Check for pi-scripts updates
#************
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

#************
#Scan system for updated applications
#************
yad  --width=550 --height=150 --text-align=center --center --title="Update" \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text="<b>Version $VERSION</b>\r\r\First we need to scan the system to see what is installed. \
This should take less than a minute. Ready when you are." \
--button="Exit":1 \
--button="Start Scan":2
BUT=$?
if [ $BUT = 252 ] || [ $BUT = 1 ]; then
exit
fi

#************
#install bc if not installed
#************
if ! hash bc>/dev/null; then
sudo apt install -y bc
fi

CHECK(){
#----------------------------------------------------#
#		LOG2RAM
#----------------------------------------------------#
if ! hash log2ram 2>/dev/null; then
Log2ram="Not Installed"
else
Log2ram="Installed"
fi
#----------------------------------------------------#
#		LOCATE
#----------------------------------------------------#
if ! hash locate 2>/dev/null; then
Locate="Not Installed"
else
Locate="Installed"
fi
#----------------------------------------------------#
#		PLANK
#----------------------------------------------------#
if ! hash plank 2>/dev/null; then
Plank="Not Installed"
else
Plank="Installed"
fi
#----------------------------------------------------#
#		SAMBA
#----------------------------------------------------#
if ! hash samba 2>/dev/null; then
Samba="Not Installed"
else
Samba="Installed"
fi
#----------------------------------------------------#
#		WEBMIN
#----------------------------------------------------#
if [ ! -d /usr/share/webmin 2>/dev/null ]; then
Webmin="Not Installed"
else
Webmin="Installed"
fi

#----------------------------------------------------#
#		3.5" DISPLAY DRIVERS
#----------------------------------------------------#
if [ ! -d $HOME/LCD-show 2>/dev/null ]; then
Display="Not Installed"
else
Display="Installed"
fi

#----------------------------------------------------#
#		Cqrprop
#----------------------------------------------------#
if ! hash  cqrprop 2>/dev/null ; then
Cqrprop="Not Installed"
else
Cqrprop="Installed"
fi

#----------------------------------------------------#
#		Disks
#----------------------------------------------------#
if ! hash  gnome-disks 2>/dev/null ; then
Disks="Not Installed"
else
Disks="Installed"
fi

#----------------------------------------------------#
#		PiImager
#----------------------------------------------------#
if ! hash  rpi-imager 2>/dev/null ; then
PiImager="Not Installed"
else
PiImager="Installed"
fi

#----------------------------------------------------#
#		Neofetch
#----------------------------------------------------#
if ! hash  neofetch 2>/dev/null ; then
Neofetch="Not Installed"
else
Neofetch="Installed"
fi

#----------------------------------------------------#
#		Commander Pi
#----------------------------------------------------#
if [ ! -d $HOME/CommanderPi 2>/dev/null ]; then
CommanderPi="Not Installed"
else
CommanderPi="Installed"
fi

#----------------------------------------------------#
#		Fortune
#----------------------------------------------------#
if [ ! -f /usr/share/terminfo/f/fortune 2>/dev/null ]; then
Fortune="Not Installed"
else
Fortune="Installed"
fi

#----------------------------------------------------#
#		DeskPi
#----------------------------------------------------#
if [ ! -d $HOME/deskpi 2>/dev/null ]; then
DeskPi="Not Installed"
else
DeskPi="Installed"
fi

#----------------------------------------------------#
#		Argon
#----------------------------------------------------#
if [ ! -f /etc/argononed.conf 2>/dev/null ]; then
Argon="Not Installed"
else
Argon="Installed"
fi

}

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

#----------------------------------------------------#
#			BASE APP MENU
#----------------------------------------------------#
yad --center --list --checklist --width=600 --height=600 --separator="" \
--image $LOGO --column=Check --column=App --column=status --column=description --print-column=2 \
--window-icon=$LOGO --image-on-top --text-align=center \
--text="<big><big><b>Base Apps</b></big></big>" --title="Pi Update" \
false "DeskPi" "$DeskPi" "DeskPi enclosure utilities." \
false "Argon" "$Argon" "Argon One m.2 enclosure utilities." \
false "Log2ram" "$Log2ram" "Create a RAM based log folder to reduce SD card wear." \
false "Locate" "$Locate" "File search utility" \
false "Plank" "$Plank" "Application dock." \
false "Samba" "$Samba" "SMB file system" \
false "Webmin" "$Webmin" "Web based system manager." \
false "Display" "$Display" "Drivers for a 3.5 in. touch screen display" \
false "Cqrprop" "$Cqrprop" "A small application that shows propagation data" \
false "Disks" "$Disks" "Manage Drives and Media" \
false "PiImager" "$PiImager" "Raspberry Pi Imager" \
false "Neofetch" "$Neofetch" "Display Linux system Information In a Terminal" \
false "CommanderPi" "$CommanderPi" "Easy RaspberryPi4 GUI system managment" \
false "Fortune" "$Fortune" "Display random quotes" \
--button="Exit":1 \
--button="Check All and Continue":3 \
--button="Next":2 > $BASE
BUT=$?
if [ $BUT = 252 ] || [ $BUT = 1 ]; then
exit
fi

if [ $BUT = 3 ]; then
BASEAPPS=(DeskPi Argon Log2ram Locate Plank Samba Webmin Display Cqrprop Disks PiImager Neofetch CommanderPi Fortune)
for i in "${BASEAPPS[@]}"
do
echo "$i" >> $BASE
done
fi

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

bash $HOME/pi-build/update

#************
# Install the WB0SIO version of hotspot tools and edit build-a-pi to use that version.
#************
if [ -d $HOME/hotspot-tools2 ]; then
	rm -rf $HOME/hotspot-tools2
fi
git clone https://github.com/lcgreenwald/autohotspot-tools2.git $HOME/hotspot-tools2
sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" $HOME/pi-build/update
sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" $HOME/pi-build/functions/base.function

#************
# Update aliases in .bashrc.
#************
sed -i "s/#alias ll='ls -l'/alias ll='ls -l'/" $HOME/.bashrc
sed -i "s/#alias la='ls -A'/alias la='ls -la'/" $HOME/.bashrc
sed -i "s/#alias l='ls -CF'/alias psgrep='ps -ef|grep -v grep|grep -i '/" $HOME/.bashrc

#************
# Install WB0SIO versions of desktop, conky and digi-mode files.
#************
cp -f $HOME/hotspot-tools2/hstools.desktop $HOME/.local/share/applications/hotspot-tools.desktop
cp -f $MYPATH/bin/*.sh ~/bin/
cp -f $MYPATH/conky/get-grid ~/bin/conky/
cp -f $MYPATH/conky/get-freq ~/bin/conky/
cp -f $MYPATH/desktop_files/* $HOME/.local/share/applications/
if [ ! -d $HOME/.xlog 2>/dev/null ] ; then
	mkdir $HOME/.xlog
fi
if [ ! -d $HOME/bin/conky/solardata 2>/dev/null ] ; then
	mkdir $HOME/bin/conky/solardata
fi
cp -rf $MYPATH/xlog/* $HOME/.xlog/
cp -f $MYPATH/config/* $HOME/.config/
cp -f $MYPATH/conky/.conkyrc* $HOME/
cp -f $MYPATH/conky/gpsupdate $HOME/bin/
sed -i "s/N0CALL/$CALL/" $HOME/.conkyrc

#************
# Update the locate database.
#************
echo "#######################################"
echo "#  Updating the locate database.      #"
echo "#  This may take a minute or two.     #"
echo "#######################################"
sudo updatedb

#************
# Edit build-a-pi to use WB0SIO version of gpsd install.
#************
sed -i "s/km4ack\/pi-scripts\/master\/gpsinstall/lcgreenwald\/pi-scripts\/master\/gpsinstall/" $HOME/pi-build/functions/base.function

#####################################
#	END CLEANUP
#####################################
#Remove temp files
rm $BASE > /dev/null 2>&1
sudo rm -rf $HOME/pi-build/temp > /dev/null 2>&1
sudo apt -y autoremove

#####################################
#reboot when done
#####################################
cat <<EOF > $MYPATH/intro.txt
Pi Build Install Update finished 
A reboot may be required depending on what has been installed.
If you close this window, you will have to reboot manually.
EOF

INTRO=$(yad --width=600 --height=300 --text-align=center --center --title="Pi Build Install Update"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Reboot Now":0 \
--button="Exit":1)
BUT=$(echo $?)

if [ $BUT = 0 ]; then
rm $MYPATH/intro.txt
echo rebooting
sudo reboot
elif [ $BUT = 1 ]; then
rm $MYPATH/intro.txt
exit
fi
