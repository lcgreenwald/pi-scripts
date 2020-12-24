#!/bin/bash
###########################################################
#                                                         #
# Script to set the default HDMI screen resolution.       #
#   24-December-2020 by Larry Greenwald - WB0SIO          #
#                                                         #
###########################################################

MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOGO=$MYPATH/logo.png
MODE=$(cat /boot/config.txt | grep "hdmi_mode")

if ! hash yad 2>/dev/null; then
	sudo apt install -y yad
fi

#####################################
#	notice to user
#####################################
cat <<EOF > $MYPATH/intro.txt
Select the desired default screen resloution.
EOF

INTRO=$(yad --width=750 --height=275 --text-align=center --center --title="Update Resolution"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="1920x1080":1 > /dev/null 2>&1 \
--button="1600x1200":2 > /dev/null 2>&1 \
--button="1280x1024":3 > /dev/null 2>&1 \
--button="1024x768":4 > /dev/null 2>&1 \
--button="Exit":5 > /dev/null 2>&1)
BUT=$(echo $?)

if [ $BUT = 252 || $BUT = 5 ]; then
rm $MYPATH/intro.txt
exit
fi

sudo sed -i "s/#hdmi_force_hotplug/hdmi_force_hotplug/" /boot/config.txt
sudo sed -i "s/#hdmi_group*/hdmi_group=2/" /boot/config.txt

if [ $BUT = 1 ]; then
echo "1920x1080 selected."
sudo sed -i "s/$MODE/hdmi_mode=82/" /boot/config.txt
elif [ $BUT = 2 ]; then
echo "1600x1200 selected."
sudo sed -i "s/$MODE/hdmi_mode=51/" /boot/config.txt
elif [ $BUT = 3 ]; then
echo "1280x1024 selected."
sudo sed -i "s/$MODE/hdmi_mode=35/" /boot/config.txt
elif [ $BUT = 4 ]; then
echo "1024x768 selected."
sudo sed -i "s/$MODE/hdmi_mode=16/" /boot/config.txt
fi
rm $MYPATH/intro.txt

#####################################
#reboot when done
#####################################
cat <<EOF > $MYPATH/intro.txt
Default resolution has been set. 
Reboot Required to make the change take effect.
If you close this window, you will have to reboot manually.

EOF

INTRO=$(yad --width=600 --height=300 --text-align=center --center --title="Update Resolution"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Reboot Now":0 \
--button="Exit":1)
BUT=$(echo $?)

if [ $BUT = 0 ]; then
rm $MYPATH/intro.txt
echo rebooting
sudo reboot
elif [ $BUT = 1 ]; then
rm $MYPATH/intro.txt
exit
fi
