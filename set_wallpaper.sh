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
SELECT(){
cat <<EOF > $MYPATH/intro.txt
Select the desired wallpaper.
1: bap-wallpaper 2: aurora 3: clouds          4: fisherman       5: islands     6: lasers        
7: mountain      8: road   9: ARRL we do that 10: ARRL Band Chart 11: When all else fails - Amateur Radio

EOF

INTRO=$(yad --width=1020 --height=150 --text-align=center --center --title="Update Wallpaper"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="1":1 > /dev/null 2>&1 \
--button="2":2 > /dev/null 2>&1 \
--button="3":3 > /dev/null 2>&1 \
--button="4":4 > /dev/null 2>&1 \
--button="5":5 > /dev/null 2>&1 \
--button="6":6 > /dev/null 2>&1 \
--button="7":7 > /dev/null 2>&1 \
--button="8":8 > /dev/null 2>&1 \
--button="9":9 > /dev/null 2>&1 \
--button="10":10 > /dev/null 2>&1 \
--button="11":11 > /dev/null 2>&1 \
--button="Exit":99 > /dev/null 2>&1)
BUT=$(echo $?)
rm $MYPATH/intro.txt

if [[ $BUT = 252 || $BUT = 99 ]]; then
exit
fi
}

APPLY(){
if [ $BUT = 1 ]; then
pcmanfm --set-wallpaper /home/pi/pi-build/bap-wallpaper.jpg --wallpaper-mode=stretch
elif [ $BUT = 2 ]; then
pcmanfm --set-wallpaper /usr/share/rpd-wallpaper/aurora.jpg --wallpaper-mode=stretch
elif [ $BUT = 3 ]; then
pcmanfm --set-wallpaper /usr/share/rpd-wallpaper/clouds.jpg --wallpaper-mode=stretch
elif [ $BUT = 4 ]; then
pcmanfm --set-wallpaper /usr/share/rpd-wallpaper/fisherman.jpg --wallpaper-mode=stretch
elif [ $BUT = 5 ]; then
pcmanfm --set-wallpaper /usr/share/rpd-wallpaper/islands.jpg --wallpaper-mode=stretch
elif [ $BUT = 6 ]; then
pcmanfm --set-wallpaper /usr/share/rpd-wallpaper/lasers.jpg --wallpaper-mode=stretch
elif [ $BUT = 7 ]; then
pcmanfm --set-wallpaper /usr/share/rpd-wallpaper/mountain.jpg --wallpaper-mode=stretch
elif [ $BUT = 8 ]; then
pcmanfm --set-wallpaper /usr/share/rpd-wallpaper/road.jpg --wallpaper-mode=stretch
elif [ $BUT = 9 ]; then
pcmanfm --set-wallpaper /home/pi/pi-scripts/wallpaper/ARRL_We_Do_That.jpg --wallpaper-mode=fit
elif [ $BUT = 10 ]; then
pcmanfm --set-wallpaper /home/pi/pi-scripts/wallpaper/Band_Chart_Image_for_ARRL_Web.jpg --wallpaper-mode=center
elif [ $BUT = 11 ]; then
pcmanfm --set-wallpaper /home/pi/pi-scripts/wallpaper/When_all_else_fails-amateur_radio.jpg --wallpaper-mode=fit
fi
}

#--wallpaper-mode=mode
#                           Set mode of desktop wallpaper, mode is:
#                            color (fill with solid color),
#                            stretch (stretch to fill entire monitor),
#                            fit (stretch to fit monitor size),
#                            center (place on center of monitor),
#                            tile (tile to fill entire monitor),
#                            crop (stretch and crop to fill monitor), or
#                            screen (stretch to fill entire screen)


while [ 1 ]
do

SELECT
APPLY

#####################################
#Quit or try amnother
#####################################
cat <<EOF > $MYPATH/intro.txt
New Wallpaper has been set. 
EOF

INTRO=$(yad --width=300 --height=100 --text-align=center --center --title="Update Wallpaper"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Choose another":0 \
--button="Exit":1)
BUT=$(echo $?)
rm $MYPATH/intro.txt


if [[ $BUT = 252 || $BUT = 1 ]]; then
exit
fi

done

#if [ $BUT = 0 ]; then
#SELECT
#APPLY
#fi

#exit
