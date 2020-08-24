#!/bin/bash
#install YAD & jq as needed
clear;echo;echo
echo "#######################################"
echo "#  Updating repository & installing   #"
echo "#  a few needed items before we begin #"
echo "#######################################"
sudo apt-get update
sudo apt-get upgrade -y
MYPATH=$HOME/pi-scripts
#####################################
#	notice to user
#####################################
cat <<EOF > $MYPATH/intro.txt
pi-build-update by wb0sio.
This script downloads the latest version of 
KM4ACK's Build-a-Pi and a custom version of 
KM4ACK's HotSpot Tools.
EOF

INTRO=$(yad --width=550 --height=250 --text-align=center --center --title="Build-a-Pi Update"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Continue":2 > /dev/null 2>&1)
BUT=$?
if [ $BUT = 252 ]; then
rm $MYPATH/intro.txt
exit
fi
rm $MYPATH/intro.txt

cd pi-build
git pull
cd
#************
if [ -d $HOME/hotspot-tools2 ]; then
	cd $HOME/hotspot-tools2
	git pull
else
    git clone https://github.com/lcgreenwald/autohotspot-tools2.git $HOME/hotspot-tools2
    sudo cp -f ~/hotspot-tools2/hstools.desktop /usr/share/applications/hotspot-tools.desktop
fi
sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" $HOME/pi-build/update
sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" $HOME/pi-build/functions/base.function
sed -i "s/pi-build/pi-scripts/" $HOME/.local/share/applications/setconky.desktop

#Notify when done
yad --width=400 --height=200 --title="Updates" --image $LOGO \
--text-align=center --skip-taskbar --image-on-top \
--wrap --window-icon=$LOGO \
--undecorated --text="<big><big><big><b>Pi-Build-update finished </b></big></big></big>\r\r" \
--button="OK":0 \
BUT=$(echo $?)

if [ $BUT = 0 ]; then
	exit
else
	exit
fi
