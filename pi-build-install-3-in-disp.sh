#!/bin/bash
MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export MYPATH
LOGO=$MYPATH/logo.png
$MYPATH/base-install.sh
#####################################
#	notice to user
#####################################
cat <<EOF > $MYPATH/intro.txt
pi-build-install-3-in-display by wb0sio.
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
sudo chmod -R 755 LCD-show
#cd LCD-show
#sudo ./LCD35-show

cat <<EOF > $HOME/.local/share/applications/LCD35-show.desktop
[Desktop Entry]
Name=LCD35-show
Comment=LCD35-show
GenericName=Enable 3.5" Display
Exec=/home/pi/pi-scripts/lcd35.sh
Icon=/home/pi/pi-scripts/conky/conky-logo.png
Type=Application
Encoding=UTF-8
Terminal=false
Categories=Settings;DesktopSettings;
Keywords=Display
EOF

cat <<EOF > $HOME/.local/share/applications/LCD-hdmi.desktop
[Desktop Entry]
Name=LCD-hdmi
Comment=LCD-hdmi
GenericName=Enable HDMI Display
Exec=/home/pi/pi-scripts/hdmi.sh
Icon=/home/pi/pi-scripts/conky/conky-logo.png
Type=Application
Encoding=UTF-8
Terminal=false
Categories=Settings;DesktopSettings;
Keywords=Display
EOF


# done
yad --width=400 --height=200 --title="Complete" --image $LOGO \
--text-align=center --skip-taskbar --image-on-top \
--wrap --window-icon=$LOGO \
--undecorated --text="<big><big><big><b>3.5 in. display driver install finished \r Select the desired display in \r the Preferences menu. </b></big></big></big>\r\r" \
--button="Exit":0
BUT=$(echo $?)

if [ $BUT = 0 ]; then
exit
elif [ $BUT = 1 ]; then
exit
fi
