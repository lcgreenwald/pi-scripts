#!/bin/bash
###########################################################
#                                                         #
# Script to set the wallpaper.       #
#   25-December-2020 by Larry Greenwald - WB0SIO          #
#                                                         #
###########################################################

MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOGO=$MYPATH/logo.png

if ! hash yad 2>/dev/null; then
	sudo apt install -y yad
fi

#####################################
#	notice to user
#####################################
cat <<EOF > $MYPATH/intro.txt
Select the desired wallpaper.
EOF

INTRO=$(yad --width=1020 --height=150 --text-align=center --center --title="Update Wallpaper"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="bap-wallpaper":1 > /dev/null 2>&1 \
--button="aurora":2 > /dev/null 2>&1 \
--button="clouds":3 > /dev/null 2>&1 \
--button="fisherman":4 > /dev/null 2>&1 \
--button="islands":5 > /dev/null 2>&1 \
--button="lasers":6 > /dev/null 2>&1 \
--button="mountain":7 > /dev/null 2>&1 \
--button="road":8 > /dev/null 2>&1 \
--button="Exit":99 > /dev/null 2>&1)
BUT=$(echo $?)

if [[ $BUT = 252 || $BUT = 99 ]]; then
rm $MYPATH/intro.txt
exit
fi

if [ $BUT = 1 ]; then
pcmanfm --set-wallpaper $HOME/pi-build/bap-wallpaper.jpg
elif [ $BUT = 2 ]; then
pcmanfm --set-wallpaper /usr/share/rpd-wallpaper/aurora.jpg
elif [ $BUT = 3 ]; then
pcmanfm --set-wallpaper /usr/share/rpd-wallpaper/clouds.jpg
elif [ $BUT = 4 ]; then
pcmanfm --set-wallpaper /usr/share/rpd-wallpaper/fisherman.jpg
elif [ $BUT = 5 ]; then
pcmanfm --set-wallpaper /usr/share/rpd-wallpaper/islands.jpg
elif [ $BUT = 6 ]; then
pcmanfm --set-wallpaper /usr/share/rpd-wallpaper/lasers.jpg
elif [ $BUT = 7 ]; then
pcmanfm --set-wallpaper /usr/share/rpd-wallpaper/mountain.jpg
elif [ $BUT = 8 ]; then
pcmanfm --set-wallpaper /usr/share/rpd-wallpaper/road.jpg
fi
rm $MYPATH/intro.txt

#####################################
#reboot when done
#####################################
cat <<EOF > $MYPATH/intro.txt
New Wallpaper has been set. 
EOF

INTRO=$(yad --width=300 --height=100 --text-align=center --center --title="Update Wallpaper"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Exit":1)
BUT=$(echo $?)

if [[ $BUT = 252 || $BUT=1 ]]; then
rm $MYPATH/intro.txt
exit
fi
