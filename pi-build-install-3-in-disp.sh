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
This script downloads and installs 
the 3.5" display drivers.
EOF

INTRO=$(yad --width=550 --height=250 --text-align=center --center --title="Install Display Drivers"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Continue":2 > /dev/null 2>&1)
BUT=$?
if [ $BUT = 252 ]; then
rm $MYPATH/intro.txt
exit
fi
rm $MYPATH/intro.txt

# Install 3.5" display drivers  
cd
git clone https://github.com/MrYacha/LCD-show.git
cd LCD-show
bash LCD35-show

# done
yad --width=400 --height=200 --title="Complete" --image $LOGO \
--text-align=center --skip-taskbar --image-on-top \
--wrap --window-icon=$LOGO \
--undecorated --text="<big><big><big><b>3.5 in. display driver install finished </b></big></big></big>\r\r" \
--button="Exit":0
BUT=$(echo $?)

if [ $BUT = 0 ]; then
elif [ $BUT = 1 ]; then
exit
fi
