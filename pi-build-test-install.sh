#!/bin/bash
MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export MYPATH
LOGO=$MYPATH/logo.png
$MYPATH/base-install.sh
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
Please select Master, Beta or Dev installation.
EOF

INTRO=$(yad --width=550 --height=250 --text-align=center --center --title="Build-a-Pi"  --show-uri \
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
if [ $BUT = 2 ]; then
echo "Master selected."
elif [ $BUT = 3 ]; then
echo "Beta selected."
git checkout beta
git pull
elif [ $BUT = 3 ]; then
echo "Dev selected."
git checkout dev
git pull
fi
cd
bash pi-build/build-a-pi
#************
if [ -d $HOME/hotspot-tools2 ]; then
	rm -rf $HOME/hotspot-tools2
fi
git clone https://github.com/lcgreenwald/autohotspot-tools2.git $HOME/hotspot-tools2
cp -f $HOME/hotspot-tools2/hstools.desktop $HOME/.local/share/applications/hotspot-tools.desktop
cp -f $MYPATH/bin/*.sh ~/bin/
cp -f $MYPATH/conky/get-grid ~/bin/conky/
cp -f $MYPATH/desktop_files/* $HOME/.local/share/applications/
cp -rf $MYPATH/.local/share/* $HOME/.local/share/
mkdir $HOME/.xlog/
cp -rf $MYPATH/.xlog/* $HOME/.xlog/
cp -f $MYPATH/.config/* $HOME/.config/
sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" $HOME/pi-build/update
sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" $HOME/pi-build/functions/base.function
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
