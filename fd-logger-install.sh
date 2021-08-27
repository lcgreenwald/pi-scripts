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
K4CPO-FD-Logger Install by wb0sio.
This script downloads and installs a version of 
the K4CPO-FD-Logger customized for N0SUW/WB0SIO.
Select Build/Clear DataBase when the web browser opens.
EOF

INTRO=$(yad --width=560 --height=250 --text-align=center --center --title="K4CPO-FD-Logger"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Continue":2 > /dev/null 2>&1)
BUT=$?
if [ $BUT = 252 ]; then
rm $MYPATH/intro.txt
exit
fi
rm $MYPATH/intro.txt

cd
git clone https://github.com/lcgreenwald/K4CPO-FD-Logger.git
sudo apt-get install -y php7.3 mariadb-server phpmyadmin
cd ${HOME}/K4CPO-FD-Logger
bash setup
sudo mkdir /var/www/html/log
sudo chmod 777 /var/www/html/log
sudo cp * /var/www/html/log/
cd
# Create desktop entry

# K4CPO-FD-Logger
	cat <<EOF > ${HOME}/.local/share/applications/K4CPO-FD-Logger.desktop
[Desktop Entry]
Version=1.0
Name=K4CPO-FD-Logger
Comment=K4CPO Field Day logger
Exec=chromium-browser http://localhost/log
Icon=/usr/share/icons/PiXflat/16x16/apps/launch.png
Terminal=false
X-MultipleArgs=false
Type=Application
Categories=HamRadio;wb0sio;
StartupNotify=true
NoDisplay=false
EOF
	
chromium-browser http://localhost/log?setup
