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
LOGO=$MYPATH/logo.png
#####################################
#	notice to user
#####################################
cat <<EOF > $MYPATH/intro.txt
TrustedSQL Install by wb0sio.
This script downloads, compiles and installs
the latest version of TrustedQSL.
EOF

INTRO=$(yad --width=550 --height=250 --text-align=center --center --title="TQSL Install"  --show-uri \
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
sudo apt install -y cmake g++ libexpat1-dev libssl-dev libdb++-dev libcurl4-openssl-dev libwxgtk3.0-dev
git clone https://git.code.sf.net/p/trustedqsl/tqsl ~/trustedqsl-tqsl
cd ~/trustedqsl-tqsl
cmake .
make
sudo make install
sudo cp /home/pi/trustedqsl-tqsl/apps/tqsl.desktop /usr/share/applications/
