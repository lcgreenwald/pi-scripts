#!/bin/bash
#install YAD & jq as needed
clear;echo;echo
echo "#######################################"
echo "#  Updating repository & installing   #"
echo "#  a few needed items before we begin #"
echo "#######################################"
sudo apt-get update
sudo apt-get upgrade -y
	if ! hash yad 2>/dev/null; then
	sudo apt install -y yad
	fi
	if ! hash jq 2>/dev/null; then
	sudo apt install -y jq
	fi
MYPATH=$HOME/pi-scripts
#####################################
#	notice to user
#####################################
cat <<EOF > $MYPATH/intro.txt
pi-build-install by wb0sio.
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

#git clone https://github.com/km4ack/pi-build.git
# build-a-pi beta 
cd
git clone https://github.com/km4ack/pi-build.git
cd pi-build
git checkout dev
bash build-a-pi
cd
#************
if [ -d $HOME/hotspot-tools2 ]; then
	mv $HOME/hotspot-tools2 $HOME/hotspot-tools2.km4ack
fi
git clone https://github.com/lcgreenwald/autohotspot-tools2.git $HOME/hotspot-tools2
sudo cp -f ~/hotspot-tools2/hstools.desktop /usr/share/applications/hotspot-tools.desktop
git clone https://github.com/lcgreenwald/K4CPO-FD-Logger.git
sudo apt-get install -y php7.3 mariadb-server phpmyadmin
cd K4CPO-FD-Logger
bash setup
sudo mkdir /var/www/html/log
sudo chmod 777 /var/www/html/log
sudo cp * /var/www/html/log/
cp ~/pi-scripts/bin/*.sh ~/bin/
sudo cp ~/pi-scripts/desktop_files/* /usr/share/applications/
sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/hotspot-tools2/" $HOME/pi-build/update

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
