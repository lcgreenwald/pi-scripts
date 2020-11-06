#!/bin/bash

DESK=$(printenv | grep DISPLAY)
MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOGO=$MYPATH/logo.png
RB=$( ls $HOME/.config | grep WB0SIO)
BASE=$MYPATH/base.txt
#CONFIG=$MYPATH/installapps
FUNCTIONS=$MYPATH/functions
TEMPCRON=$MYPATH/cron.tmp
DIR=$MYPATH/temp
WHO=$(whoami)
VERSION=$(cat $MYPATH/changelog | grep version= | sed 's/version=//')
export MYPATH
echo "MYPATH: $MYPATH"

FINISH(){
if [ -f "$BASE" ]; then
#rm $BASE
echo "cat $BASE"
fi
}

trap FINISH EXIT

#check for display. can't run from SSH
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
latest version of KM4ACK's Build-a-Pi 
and a custom version of KM4ACK's HotSpot Tools.
First we will install some required and some
optional utility software.

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

if [ $BUT = 3 ]; then
BASEAPPS=(Log2Ram Locate Plank Samba Webmin 3inDisplay)
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
#	notice to user
#####################################
cat <<EOF > $MYPATH/intro.txt
Now we install Build-A-Pi.
Do not reboot as requested at the end of the build-a-pi script.
Wait for the pi-build-install finished dialog box.
Please select Master, Beta or Dev installation.
EOF

INTRO=$(yad --width=550 --height=275 --text-align=center --center --title="Build-a-Pi"  --show-uri \
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
bash pi-build/build-a-pi

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
cp -rf $MYPATH/xlog/* $HOME/.xlog/
cp -f $MYPATH/config/* $HOME/.config/
cp -f $MYPATH/conky/.conkyrc $HOME/.conkyrc
sed -i "s/pi-build/pi-scripts/" $HOME/.local/share/applications/setconky.desktop
sudo updatedb

#####################################
#	END CLEANUP
#####################################
#Remove temp files
rm $BASE > /dev/null 2>&1
rm -rf $DIR > /dev/null 2>&1
sudo apt -y autoremove

#reboot when done
yad --width=400 --height=200 --title="Reboot" --image $LOGO \
--text-align=center --skip-taskbar --image-on-top \
--wrap --window-icon=$LOGO \
--undecorated --text="<big><big><big><b>Pi-Build-Install finished \rReboot Required\rIf you close this window, you will have to reboot manually.</b></big></big></big>\r\r" \
--button="Reboot Now":0 \
--button="Exit":1
BUT=$(echo $?)

if [ $BUT = 0 ]; then
echo rebooting
sudo reboot
elif [ $BUT = 1 ]; then
exit
fi
