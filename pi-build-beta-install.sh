#!/bin/bash
#install YAD & jq as needed
clear;echo;echo
echo "#######################################"
echo "#  Updating repository & installing   #"
echo "#  a few needed items before we begin #"
echo "#######################################"
###### Install log2ram 20200111 wb0sio ####
if ! hash log2ram 2>/dev/null; then
	echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
	wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
fi
sudo apt update
sudo apt upgrade -y
if ! hash yad 2>/dev/null; then
	sudo apt install -y yad
fi
if ! hash jq 2>/dev/null; then
	sudo apt install -y jq
fi
if ! hash log2ram 2>/dev/null; then
	sudo apt install -y log2ram
fi
if ! hash locate 2>/dev/null; then
	sudo apt install -y locate
fi
MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#####################################
#	notice to user
#####################################
cat <<EOF > $MYPATH/intro.txt
pi-build-install by wb0sio.
This script downloads and installs the
latest version of KM4ACK's Build-a-Pi 
and a custom version of KM4ACK's HotSpot Tools.
Do not reboot at the end of the build-a-pi script.
Wait for the pi-build-install finished dialog box.
EOF

INTRO=$(yad --width=550 --height=250 --text-align=center --center --title="Build-a-Pi"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Continue":2 > /dev/null 2>&1)
BUT=$?
if [ $BUT = 252 ]; then
rm $MYPATH/intro.txt
exit
fi
rm $MYPATH/intro.txt

# build-a-pi  
cd
git clone https://github.com/km4ack/pi-build.git $MYPATH/pi-build
cd pi-build
git checkout dev
git pull
cd
bash pi-build/build-a-pi
#************
if [ -d $HOME/hotspot-tools2 ]; then
	rm -rf $HOME/hotspot-tools2
fi
git clone https://github.com/lcgreenwald/autohotspot-tools2.git $HOME/hotspot-tools2
cp -f $HOME/hotspot-tools2/hstools.desktop $HOME/.local/share/applications/hotspot-tools.desktop
cp $MYPATH/bin/*.sh ~/bin/
cp $MYPATH/conky/get-grid ~/bin/conky/
cp $MYPATH/desktop_files/* $HOME/.local/share/applications/
cp $MYPATH/.local/share/* $HOME/.local/share/
cp $MYPATH/.config/* $HOME/.config/
sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" $MYPATH/pi-build/update
sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" $MYPATH/pi-build/functions/base.function
sed -i "s/pi-build/pi-scripts/" $HOME/.local/share/applications/setconky.desktop
sudo updatedb

#reboot when done
yad --width=400 --height=200 --title="Reboot" --image $LOGO \
--text-align=center --skip-taskbar --image-on-top \
--wrap --window-icon=$LOGO \
--undecorated --text="<big><big><big><b>Pi-Build-Install finished \rReboot Required</b></big></big></big>\r\r" \
--button="Reboot Now":0 \
--button="Exit":1
BUT=$(echo $?)

if [ $BUT = 0 ]; then
echo rebooting
sudo reboot
elif [ $BUT = 1 ]; then
exit
fi
