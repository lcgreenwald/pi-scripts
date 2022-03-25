#!/bin/bash

###########################################################
#                                                         #
# #   # #       #     #      #        #####  #   #        #
# #  #  # #   # #    ##     # #      #       #  #         #
# # #   #   #   #   # #    #   #    #        # #          #
# ##    #       #  #####  #######  #         ##           #
# # #   #       #     #   #     #   #        # #          #
# #  #  #       #     #   #     #    #       #  #         #
# #   # #       #     #   #     #     #####  #   #        #
#                                                         #
###########################################################
#                                                         #
# Modified for WB0SIO pi-build-install update.            #
#   6-November-2020 by WB0SIO                             #
#                                                         #
###########################################################

MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASE=${MYPATH}/base.txt
RADIO=${MYPATH}/radio.txt
PATCH=${MYPATH}/patch.txt
FUNCTIONS=${MYPATH}/functions
LOGO=${MYPATH}/logo.png
VERSION=$(cat ${MYPATH}/changelog | grep version= | sed 's/version=//')
AUTHOR=$(cat ${MYPATH}/changelog | grep author= | sed 's/author=//')
LASTUPDATE=$(cat ${MYPATH}/changelog | grep LastUpdate= | sed 's/LastUpdate=//')
LASTUPDATERUN=$(cat ${HOME}/.config/WB0SIO | grep LastUpdateRun= | sed 's/LastUpdateRun=//')
TODAY=$(date +%Y-%m-%d)
CONFIG=${MYPATH}/config.txt
UPDATEFILE=/run/user/${UID}/psupdate.txt
PATCHDIR=/run/user/${UID}/patch
AVAILPATCH=$PATCHDIR/avail-patch.txt

export MYPATH LOGO CONFIG PATCH PATCHDIR AVAILPATCH

FINISH(){
if [ -f "${BASE}" ]; then
	rm ${BASE}
fi
if [ -f "${RADIO}" ]; then
	rm ${RADIO}
fi
}

trap FINISH EXIT

#####################################
# Cleanup function
#####################################
CLEANUP(){
#Remove temp files
rm ${BASE} > /dev/null 2>&1
rm ${RADIO} > /dev/null 2>&1
rm ${PATCH} > /dev/null 2>&1
rm ${UPDATEFILE} > /dev/null 2>&1
rm -rf $PATCHDIR > /dev/null 2>&1
sudo rm -rf ${HOME}/pi-build/temp > /dev/null 2>&1
sudo apt -y autoremove
# Update the LastUpdateRun date in ${HOME}/.config/WB0SIO
if [[ $LASTUPDATERUN == "" ]] ; then
  echo "# The date update.sh was last executed" >> ${HOME}/.config/WB0SIO
  echo "LastUpdateRun=$TODAY" >> ${HOME}/.config/WB0SIO
else
  sed -i "s/LastUpdateRun=.*$/LastUpdateRun=$TODAY/" ${HOME}/.config/WB0SIO
fi
}


#####################################
# Create autostart dir
# used to autostart programs at boot
#####################################
if [ -d ${HOME}/.config/autostart ]; then
  mkdir -p ${HOME}/.config/autostart
fi

#####################################
#Check for pi-scripts updates
#####################################
echo "Checking for Pi Scripts updates"
CURRENT=$(head -1 ${MYPATH}/changelog | sed s'/version=//')

LATEST=$(curl -s https://raw.githubusercontent.com/lcgreenwald/pi-scripts/master/changelog | tac | tac | head -1 | sed 's/version=//')

if (( $(echo "$LATEST $CURRENT" | awk '{print ($1 > $2)}') ))
then
cat <<EOF > ${MYPATH}/updateps.txt
Pi Scripts update available. Current version is $CURRENT and
the lateest version is $LATEST. Would you like to update?

Change log - https://github.com/lcgreenwald/pi-scripts/blob/master/changelog
EOF
BAP=$(yad --width=650 --height=250 --text-align=center --center --title="Build-a-Pi"  --show-uri \
--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
--text-info<${MYPATH}/updateps.txt \
--button="Yes":2 \
--button="No":3)
BUT=$?
echo $BUT
##########
	if [ $BUT = 252 ]; then 
  CLEANUP
	exit
	elif [ $BUT = 2 ]; then
	echo "Updating Pi Scripts to $LATEST"
	mv ${MYPATH}/config ${HOME}/Documents/config.bap
	rm -rf ${MYPATH}
	cd ~
	git clone https://github.com/lcgreenwald/pi-scripts.git
	mv ${HOME}/Documents/config.bap ${MYPATH}/config

cat <<EOF > ${MYPATH}/updateps.txt
Pi Scripts has been updated to $LATEST. Please restart Pi Scripts.
EOF
	BAP=$(yad --width=650 --height=250 --text-align=center --center --title="Build-a-Pi"  --show-uri \
	--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
	--text-info<${MYPATH}/updateps.txt \
	--button="OK":2)
	BUT=$?
	exit 0
	fi
##########
fi
rm ${MYPATH}/updateps.txt >> /dev/null 2>&1
rm ${MYPATH}/complete.txt >> /dev/null 2>&1
clear

#####################################
#Scan system for updated applications
#####################################
yad  --width=550 --height=150 --text-align=center --center --title="Update" \
--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
--text="<b>Version ${VERSION}</b>\r\r\First we need to scan the system to see what is installed. \
This should take less than a minute. Ready when you are." \
--button="Exit":1 \
--button="Start Scan":2
BUT=$?
if [ $BUT = 252 ] || [ $BUT = 1 ]; then
CLEANUP
exit
fi

#####################################
#install bc if not installed
#####################################
if ! hash bc>/dev/null; then
sudo apt install -y bc
fi

#####################################
#	Run the patch check script
#####################################
bash $MYPATH/patch-installed-check.sh
#####################################

#####################################
#Run the app check script
#####################################
bash $MYPATH/app-check.sh

#####################################
#Load the program installation/update status
#####################################
source $UPDATEFILE

#----------------------------------------------------#
#			BASE APP MENU
#----------------------------------------------------#
yad --center --list --checklist --width=750 --height=750 --separator="" \
--image ${LOGO} --column=Check --column=App --column=status --column=description --print-column=2 \
--window-icon=${LOGO} --image-on-top --text-align=center \
--text="<big><big><b>Base Apps</b></big></big>" --title="Pi Update" \
false "DeskPi" "$DeskPi" "DeskPi enclosure utilities." \
false "Argon" "$Argon" "Argon One m.2 enclosure utilities." \
false "X715" "$X715" "X715 power supply hat utilities." \
false "Log2ram" "$Log2ram" "Create a RAM based log folder to reduce SD card wear." \
false "ZramSwap" "$ZramSwap" "Create a RAM based swap file to improve system response." \
false "Locate" "$Locate" "File search utility" \
false "Plank" "$Plank" "Application dock." \
false "Samba" "$Samba" "SMB file system" \
false "Webmin" "$Webmin" "Web based system manager." \
false "Display" "$Display" "Drivers for a 3.5 in. touch screen display" \
false "Disks" "$Disks" "Manage Drives and Media" \
false "PiImager" "$PiImager" "Raspberry Pi Imager" \
false "Neofetch" "$Neofetch" "Display Linux system Information In a Terminal" \
false "CommanderPi" "$CommanderPi" "Easy RaspberryPi4 GUI system managment" \
false "RPiMonitor" "$RPiMonitor" "Display Linux system Information in a web browser" \
false "Fortune" "$Fortune" "Display random quotes" \
false "PiSafe" "$PiSafe" "Backup or Restore Raspberry Pi devices" \
false "nmon" "$nmon" "Linux performance monitor" \
false "Weather" "$Weather" "Display weather conditions and forecast." \
false "Piapps" "$Piapps" "The most popular app store for Raspberry Pi computers." \
--button="Exit":1 \
--button="Check All and Continue":3 \
--button="Next":2 > ${BASE}
BUT=$?
if [ $BUT = 252 ] || [ $BUT = 1 ]; then
CLEANUP
exit
fi

if [ $BUT = 3 ]; then
BASEAPPS=(DeskPi Argon X715 Log2ram ZramSwap Locate Plank Samba Webmin Display Cqrprop Disks PiImager Neofetch CommanderPi RPiMonitor Fortune PiSafe JS8map nmon Weather Piapps)
for i in "${BASEAPPS[@]}"
do
echo "$i" >> ${BASE}
done
fi

#check if Weather is chosen for install & get info if needed
Weather=$(grep "Weather" ${BASE})
if [ -n "$Weather" ]; then
source ${MYPATH}/config.txt
WEATHER=$(yad --form --center --width 600 --height 300 --separator="|" --item-separator="|" --title="Weather config" \
  --image ${LOGO} --window-icon=${LOGO} --image-on-top --text-align=center \
  --text "Enter your API Key, Latitude and Longitude below and press Continue." \
  --field="API Key" \
  --field="Latitude":NUM \
  --field="Longitude":NUM \
  --field="Longitude Direction":CB \
  --field="Units":CB \
  "$APIKEY" "$LAT|-90..90|.0001|4" "$LON|-180..180|.0001|4" "W|E" "imperial|metric" \
  --button="Exit":1 \
  --button="Continue":2 )
  BUT=$?
  if [ ${BUT} = 252 ] || [ ${BUT} = 1 ]; then
    CLEANUP
    exit
  fi

  #update settings
  APIKEY=$(echo ${WEATHER} | awk -F "|" '{print $1}')
  LAT=$(echo ${WEATHER} | awk -F "|" '{print $2}')
  LON=$(echo ${WEATHER} | awk -F "|" '{print $3}')
  LONDIR=$(echo ${WEATHER} | awk -F "|" '{print $4}')
  UNITS=$(echo ${WEATHER} | awk -F "|" '{print $5}')

  WRB=$(grep APIKEY ${CONFIG})
  if [ -z ${WRB} ]; then
    echo "APIKEY=$APIKEY" >${CONFIG}
    echo "LAT=$LAT" >>${CONFIG}
    echo "LON=$LON" >>${CONFIG}
    echo "LONDIR=$LONDIR" >>${CONFIG}
    echo "UNITS=$UNITS" >>${CONFIG}
  else
    sudo sed -i "s/^APIKEY=.*$/APIKEY=$APIKEY/" ${CONFIG}
    sudo sed -i "s/^LAT=.*$/LAT=$LAT/" ${CONFIG}
    sudo sed -i "s/^LON=.*$/LON=$LON/" ${CONFIG}
    sudo sed -i "s/^LONDIR=.*$/LONDIR=$LONDIR/" ${CONFIG}
    sudo sed -i "s/^UNITS=.*$/UNITS=$UNITS/" ${CONFIG}
  fi
fi

#####################################
#	Ham Apps Menu
#####################################
yad --center --list --checklist --width=750 --height=750 --separator="" \
--image ${LOGO} --column=Check --column=App --column=status --column=description --print-column=2 \
--window-icon=${LOGO} --image-on-top --text-align=center \
--text="<b>Ham Radio Applications</b>" --title="Pi-Scripts Install" \
false "Cqrprop" "$Cqrprop" "A small application that shows propagation data" \
false "JS8map" "$JS8map" "Map to show location of JS8Call contacts" \
false "PythonGPS" "$PythonGPS" "Use Python to show the grid square in conky" \
--button="Exit":1 \
--button="Check All and Continue":3 \
--button="Install Selected":2 > ${RADIO}
BUT=$?
if [ $BUT = 252 ] || [ $BUT = 1 ]; then
CLEANUP
exit
fi

if [ $BUT = 3 ]; then

RADIOAPPS=(Cqrprop JS8map)
for i in "${RADIOAPPS[@]}"
do
echo "$i" >> ${RADIO}
done
fi

#update/upgrade the system
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt -y full-upgrade

#touch ${RB}
#touch ${HOME}/.config/WB0SIO
#####################################
#	Install Patches
#####################################
# check to see if all patches have been installed
PATCHESINSTALLED=$(grep "Not_Installed" $AVAILPATCH)
if [[ -z ${PATCHESINSTALLED} ]]; then
  echo "No available patches found"
else
  echo "Available patches found"
  source ${PATCHDIR}/patch.function
  while read i ; do
    $i
  done < ${PATCH}
fi

#####################################
#	Install Base Apps
#####################################
source ${FUNCTIONS}/base.function
while read i ; do
$i
done < ${BASE}

#####################################
#	Install Radio Apps
#####################################
source ${FUNCTIONS}/radio.function
while read i ; do
$i
done < ${RADIO}


#####################################
#	Update Build-A-Pi
#####################################
cat <<EOF > $MYPATH/intro.txt
Now we will optionally update Build-A-Pi.
Please select Current, Master, Beta or Dev installation.
Or you may skip installing Build-A-Pi now and
install it separately later.
EOF

INTRO=$(yad --width=750 --height=275 --text-align=center --center --title="Pi Build Install Update"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Current":6 > /dev/null 2>&1 \
--button="Master":2 > /dev/null 2>&1 \
--button="Beta":3 > /dev/null 2>&1 \
--button="Dev":4 > /dev/null 2>&1 \
--button="Skip":5 > /dev/null 2>&1)
BUT=$(echo $?)

if [ $BUT = 252 ]; then
  rm $MYPATH/intro.txt  
  CLEANUP
  exit
fi
rm $MYPATH/intro.txt

if [ ! $BUT = 5 ]; then
  cd
  if [ -d ${HOME}/pi-build ]; then
    git clone https://github.com/km4ack/pi-build.git
  fi
  cd pi-build
  git config --global user.email "lcgreenwald@gmail.com"
  git config --global user.name "lcgreenwald"
  if [ $BUT = 2 ]; then
    echo "Master selected."
    git checkout master
    git stash
    git pull
  elif [ $BUT = 3 ]; then
    echo "Beta selected."
    git checkout beta
    git stash
    git pull
  elif [ $BUT = 4 ]; then
    echo "Dev selected."
    git checkout dev
    git stash
    git pull
  elif [ $BUT = 6 ]; then
    echo "Current version selected."
    git stash
    git pull
  fi
  cd
  bash $HOME/pi-build/update
fi

#####################################
# Install the WB0SIO version of hotspot tools and edit build-a-pi to use that version.
#####################################
if [ -d ${HOME}/hotspot-tools2 ]; then
  AUTHOR=$(grep "author=" ${HOME}/hotspot-tools2/changelog | sed 's/author=//')
	if [[ ! $AUTHOR == 'wb0sio' ]]; then
		rm -rf ${HOME}/hotspot-tools2
	  git clone https://github.com/lcgreenwald/autohotspot-tools2.git ${HOME}/hotspot-tools2
	  sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" ${HOME}/pi-build/update
	  sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" ${HOME}/pi-build/functions/base.function
  fi
fi

#####################################
# Update aliases in .bashrc.
#####################################
sed -i "s/#alias ll='ls -l'/alias ll='ls -l'/" ${HOME}/.bashrc
sed -i "s/#alias la='ls -A'/alias la='ls -la'/" ${HOME}/.bashrc
sed -i "s/#alias l='ls -CF'/alias psgrep='ps -ef|grep -v grep|grep -i '/" ${HOME}/.bashrc

#####################################
# If pat menu is installed,
# Update callsign, password and grid info in Pat Menu.
#####################################
if [ -d ${HOME}/patmenu2 ]; then

  CONFIG=/home/pi/patmenu2/manage-pat-functions

  #set callsign
  sed -i "s/\"Call Sign\" \"\"/\"Call Sign\" \"$CALL\"/" $CONFIG
  #set password
  sed -i "s/\"Winlink Password\" \"\"/\"Winlink Password\" \"$WL2KPASS\"/" $CONFIG
  #set locator
  sed -i "s/\"Six Character Grid Square\" \"EM65TV\"/\"Six Character Grid Square\" \"$GRID\"/" $CONFIG
fi

#####################################
# Update HamRadio menu items.
#####################################
bash ${MYPATH}/menu-update.sh

#####################################
# Install WB0SIO versions of desktop, conky and digi-mode files.
#####################################
cp -f ${HOME}/hotspot-tools2/hstools.desktop ${HOME}/.local/share/applications/hotspot-tools.desktop
cp -f ${MYPATH}/bin/*.sh ${HOME}/bin/
cp -f ${MYPATH}/conky/get-grid ${HOME}/bin/conky/
cp -f ${MYPATH}/conky/get-freq ${HOME}/bin/conky/
cp -f ${MYPATH}/desktop_files/* ${HOME}/.local/share/applications/
cp -f ${MYPATH}/hrdesktop_files/* ${HOME}/.local/share/applications/
if [ ! -d ${HOME}/.xlog 2>/dev/null ] ; then
	mkdir ${HOME}/.xlog
fi
if [ ! -d ${HOME}/bin/conky/solardata 2>/dev/null ] ; then
	mkdir ${HOME}/bin/conky/solardata
fi
cp -rf ${MYPATH}/xlog/* ${HOME}/.xlog/
cp -f ${MYPATH}/config/* ${HOME}/.config/
sed -i "s/N0CALL/$CALL/" ${HOME}/.conkyrc

#####################################
# Update the locate database.
#####################################
echo "#######################################"
echo "#  Updating the locate database.      #"
echo "#  This may take a minute or two.     #"
echo "#######################################"
sudo updatedb

#####################################
# Edit build-a-pi to use WB0SIO version of gpsd install.
#####################################
sed -i "s/km4ack\/pi-scripts\/master\/gpsinstall/lcgreenwald\/pi-scripts\/master\/gpsinstall/" ${HOME}/pi-build/functions/base.function

#####################################
#	END CLEANUP
#####################################
CLEANUP

#####################################
#reboot when done
#####################################
cat <<EOF > ${MYPATH}/intro.txt
Pi Build Install Update finished 
A reboot may be required depending on what has been installed.
If you close this window, you will have to reboot manually.
EOF

INTRO=$(yad --width=650 --height=300 --text-align=center --center --title="Pi Build Install Update"  --show-uri \
--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
--text-info<${MYPATH}/intro.txt \
--button="Reboot Now":0 \
--button="Exit":1)
BUT=$(echo $?)

if [ $BUT = 0 ]; then
rm ${MYPATH}/intro.txt
echo rebooting
sudo reboot
elif [ $BUT = 1 ]; then
rm ${MYPATH}/intro.txt
exit
fi
