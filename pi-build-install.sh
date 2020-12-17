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
# Modified for WB0SIO pi-build-install.                   #
#   6-November-2020 by WB0SIO                             #
#                                                         #
###########################################################

DESK=$(printenv | grep DISPLAY)
MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOGO=$MYPATH/logo.png
RB=$HOME/.config/WB0SIO
BASE=$MYPATH/base.txt
FUNCTIONS=$MYPATH/functions
TEMPCRON=$MYPATH/cron.tmp
WHO=$(whoami)
VERSION=$(cat $MYPATH/changelog | grep version= | sed 's/version=//')
export MYPATH
echo "MYPATH: $MYPATH"

FINISH(){
if [ -f "$BASE" ]; then
rm $BASE
fi
}

trap FINISH EXIT

#************
#check for display. can't run from SSH
#************
if [ -z "$DESK" ]
then
cat <<EOF
This script cannot be run from an SSH session.
Please boot into the pi's desktop environment,
open the terminal, and run this script again
EOF
exit 0
fi

#####################################
#	Check if run before
#####################################
if [ -f "$RB" ]; then
bash $MYPATH/update.sh &
exit
fi

echo "#######################################"
echo "#  Updating repository & installing   #"
echo "#  a few needed items before we begin #"
echo "#######################################"
cd pi-scripts
git config --global user.email "lcgreenwald@gmail.com"
git config --global user.name "lcgreenwald"
cd
if ! hash log2ram 2>/dev/null; then
	echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
	wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
fi
sudo apt update
sudo apt upgrade -y
sudo apt install -y bluetooth
if ! hash yad 2>/dev/null; then
	sudo apt install -y yad
fi
if ! hash jq 2>/dev/null; then
	sudo apt install -y jq
fi

#####################################
#	notice to user
#####################################
cat <<EOF > $MYPATH/intro.txt
pi-build-install by wb0sio, version $VERSION.
This script downloads and installs the
latest version of KM4ACK's Build-a-Pi and 
a custom version of KM4ACK's HotSpot Tools.
First we will install some required and some
optional utility software.

EOF

INTRO=$(yad --width=600 --height=300 --text-align=center --center --title="Pi Build Install"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Continue":2 > /dev/null 2>&1)
BUT=$?
if [ $BUT = 252 ]; then
rm $MYPATH/intro.txt
exit
fi
rm $MYPATH/intro.txt


#####################################
#	Base Apps
#####################################
yad --center --list --checklist --width=600 --height=600 --separator="" \
--image $LOGO --column=Check --column=App --column=Description \
--print-column=2 --window-icon=$LOGO --image-on-top --text-align=center \
--text="<b>Base Applications</b>" --title="Pi-Scripts Install" \
false "Log2ram" "Create a RAM based log folder to reduce SD card wear." \
false "Locate" "File search utility" \
false "Plank" "Application dock." \
false "Samba" "SMB file system" \
false "Webmin" "Web based system manager." \
false "Display" "Drivers for a 3.5 in. touch screen display" \
false "Cqrprop" "A small application that shows propagation data" \
false "Disks" "Manage Drives and Media" \
false "PiImager" "Raspberry Pi Imager" \
false "Neofetch" "Display Linux system Information In a Terminal" \
false "CommanderPi" "Easy RaspberryPi4 GUI system managment" \
--button="Exit":1 \
--button="Check All and Continue":3 \
--button="Next":2 > $BASE
BUT=$?
if [ $BUT = 252 ] || [ $BUT = 1 ]; then
exit
fi

if [ $BUT = 3 ]; then
BASEAPPS=(Log2ram Locate Plank Samba Webmin Display Cqrprop Disks PiImager Neofetch CommanderPi)
for i in "${BASEAPPS[@]}"
do
echo "$i" >> $BASE
done
fi

#####################################
#	Install Base Apps
#####################################
touch $RB
source $FUNCTIONS/base.function
while read i ; do
$i
done < $BASE

#####################################
#	Update crontab
#####################################
crontab -l > $TEMPCRON
echo "@reboot sleep 30 && /home/pi/bin/solar.sh" >> $TEMPCRON
echo "*/10 * * * * /home/pi/bin/solar.sh" >> $TEMPCRON
echo "00 03 * * 0  /home/pi/bin/install-updates.sh" >> $TEMPCRON
crontab $TEMPCRON
rm $TEMPCRON

#####################################
#	notice to user
#Do not reboot as requested at the end of the build-a-pi script, just exit.
#Wait for the pi-build-install finished dialog box.
#####################################
cat <<EOF > $MYPATH/intro.txt
Now we will install Build-A-Pi.
Please select Master, Beta or Dev installation.
EOF

INTRO=$(yad --width=750 --height=275 --text-align=center --center --title="Build-a-Pi"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Master":2 > /dev/null 2>&1 \
--button="Beta":3 > /dev/null 2>&1 \
--button="Dev":4 > /dev/null 2>&1)
BUT=$(echo $?)

if [ $BUT = 252 ]; then
rm $MYPATH/intro.txt
exit
fi
rm $MYPATH/intro.txt


# build-a-pi  
cd
git clone https://github.com/km4ack/pi-build.git
cd pi-build
git config --global user.email "lcgreenwald@gmail.com"
git config --global user.name "lcgreenwald"
if [ $BUT = 2 ]; then
echo "Master selected."
git checkout master
git pull
elif [ $BUT = 3 ]; then
echo "Beta selected."
git checkout beta
git pull
elif [ $BUT = 4 ]; then
echo "Dev selected."
git checkout dev
git pull
fi
cd
#************
# Edit build-a-pi to use the WB0SIO version of gpsd install.
#************
sed -i "s/km4ack\/pi-scripts\/master\/gpsinstall/lcgreenwald\/pi-scripts\/master\/gpsinstall/" $HOME/pi-build/functions/base.function

#************
# Update Pi-Build/build-a-pi to exit before the "Reboot now" pop up message.
#************
sed -i '/#reboot when done/a exit' $HOME/pi-build/build-a-pi

bash pi-build/build-a-pi

source $HOME/pi-build/config

#************
# Install the WB0SIO version of hotspot tools and edit build-a-pi to use that version.
#************
echo "#######################################"
echo "#  Installing the WB0SIO version of   #"
echo "#  Hotspot Tools.                     #"
echo "#######################################"
if [ -d $HOME/hotspot-tools2 ]; then
	rm -rf $HOME/hotspot-tools2
fi
git clone https://github.com/lcgreenwald/autohotspot-tools2.git $HOME/hotspot-tools2
sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" $HOME/pi-build/update
sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" $HOME/pi-build/functions/base.function
#sed -i "s/pi-build/pi-scripts/" $HOME/.local/share/applications/setconky.desktop

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
cp -f $MYPATH/desktop_files/* $HOME/.local/share/applications/
cp -rf $MYPATH/local/share/* $HOME/.local/share/
if [ ! -d $HOME/.xlog 2>/dev/null ] ; then
	mkdir $HOME/.xlog
fi
if [ ! -d $HOME/bin/conky/solardata 2>/dev/null ] ; then
	mkdir $HOME//bin/conky/solardata
fi
cp -rf $MYPATH/xlog/* $HOME/.xlog/
cp -f $MYPATH/config/* $HOME/.config/
cp -f $MYPATH/conky/.conkyrc $HOME/.conkyrc
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
# Update Pi-Build/.complete to show .pscomplete.
#************
echo "$MYPATH/.pscomplete" >> $HOME/pi-build/.complete

#####################################
#	END CLEANUP
#####################################
# Run solar.sh to update the solar condiions data for conky
/home/pi/bin/solar.sh
#Remove temp files
rm $BASE > /dev/null 2>&1
sudo rm -rf $HOME/pi-build/temp > /dev/null 2>&1
sudo apt -y autoremove

#####################################
#reboot when done
#####################################
cat <<EOF > $MYPATH/intro.txt
Pi-Build-Install finished 
Reboot Required
If you close this window, you will have to reboot manually.

EOF

INTRO=$(yad --width=600 --height=300 --text-align=center --center --title="Pi Build Install"  --show-uri \
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
