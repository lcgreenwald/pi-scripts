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
pi-build-install-noradio by wb0sio.
This script downloads and installs Conky
with a basic config file.
EOF

INTRO=$(yad --width=550 --height=250 --text-align=center --center --title="Install Conky"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Continue":2 > /dev/null 2>&1)
BUT=$?
if [ $BUT = 252 ]; then
rm $MYPATH/intro.txt
exit
fi
rm $MYPATH/intro.txt

# Install Conky  
cd
if ! hash conky 2>/dev/null; then
	sudo apt install -y conky
fi
touch $HOME/Documents/mylog.txt		#conky will fail to load if this file doesn't exist
sudo apt-get install -y ruby2.5
sudo gem install gpsd_client
sudo gem install maidenhead
cp $MYPATH/conky/conky-noradio $HOME/.conkyrc
mkdir -p $HOME/bin/conky
cp $MYPATH/conky/* $HOME/bin/conky/
chmod +x $HOME/bin/conky/get-grid $HOME/bin/conky/temp-conv $HOME/bin/conky/get-freq $HOME/bin/conky/grid
#sed -i "s/N0CALL/$CALL/" $HOME/.conkyrc
#echo "@reboot sleep 20 && export DISPLAY=:0 && /usr/bin/conky" >> $TEMPCRON

#Create files needed for autostart at login
#Fix issue https://github.com/km4ack/pi-build/issues/83

cat <<EOF > $HOME/.local/share/applications/conky.desktop
[Desktop Entry]
Name=Conky
Comment=Conky
GenericName=Conky Screen Background Monitor
Exec=conky
Icon=/home/pi/pi-scripts/conky/conky-logo.png
Type=Application
Encoding=UTF-8
Terminal=false
Categories=Utility
Keywords=Radio
EOF

ln -sf $HOME/.local/share/applications/conky.desktop $HOME/.config/autostart/conky.desktop

#####Add setconky to main menu
chmod +x $HOME/pi-scripts/conky/setconky

cat <<EOF > $HOME/.local/share/applications/setconky.desktop
[Desktop Entry]
Name=Conky-Prefs
Comment=Conky-Prefs
GenericName=Change Conky Preferences
Exec=/home/pi/pi-scripts/conky/setconky
Icon=/home/pi/pi-scripts/conky/conky-logo.png
Type=Application
Encoding=UTF-8
Terminal=false
Categories=Settings;DesktopSettings;GTK;X-LXDE-Settings;
Keywords=Radio,Conky
EOF


#************
#if [ -d $HOME/hotspot-tools2 ]; then
#	rm -rf $HOME/hotspot-tools2
#fi
#git clone https://github.com/lcgreenwald/autohotspot-tools2.git $HOME/hotspot-tools2
#cp -f $HOME/hotspot-tools2/hstools.desktop $HOME/.local/share/applications/hotspot-tools.desktop
cp -f $MYPATH/bin/*.sh ~/bin/
cp -f $MYPATH/conky/get-grid ~/bin/conky/
#cp -f $MYPATH/desktop_files/* $HOME/.local/share/applications/
cp -rf $MYPATH/.local/share/* $HOME/.local/share/
#cp -rf $MYPATH/.xlog/* $HOME/.xlog/
#cp -f $MYPATH/.config/* $HOME/.config/
#sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" $HOME/pi-build/update
#sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" $HOME/pi-build/functions/base.function
#sed -i "s/pi-build/pi-scripts/" $HOME/.local/share/applications/setconky.desktop
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
