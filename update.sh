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
#   23-April-2022 - WB0SIO - Copied BAP functions here    #
#										instead of calling BAP.               #
###########################################################

MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASE=${MYPATH}/base.txt
RADIO=${MYPATH}/radio.txt
BAPBASE=${MYPATH}/bapbase.txt
ADDITIONAL=${MYPATH}/additional.txt
UTILITY=${MYPATH}/utility.txt
FLSUITE=${MYPATH}/flsuite.txt
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
if [ -f "${BAPBASE}" ]; then
	rm ${BAPBASE}
fi
if [ -f "${ADDITIONAL}" ]; then
	rm ${ADDITIONAL}
fi
if [ -f "${UTILITY}" ]; then
	rm ${UTILITY}
fi
if [ -f "${FLSUITE}" ]; then
	rm ${FLSUITE}
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
rm ${BAPBASE} > /dev/null 2>&1
rm ${ADDITIONAL} > /dev/null 2>&1
rm ${UTILITY} > /dev/null 2>&1
rm ${FLSUITE} > /dev/null 2>&1
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
#Run the BAP app check script
#####################################
bash $MYPATH/BAPapp-check.sh

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
false "Screensaver" "X Screensaver and misc screen savers." \
--button="Exit":1 \
--button="Check All and Continue":3 \
--button="Next":2 > ${BASE}
BUT=$?
if [ $BUT = 252 ] || [ $BUT = 1 ]; then
CLEANUP
exit
fi

if [ $BUT = 3 ]; then
BASEAPPS=(DeskPi Argon X715 Log2ram ZramSwap Locate Plank Samba Webmin Display Cqrprop Disks PiImager Neofetch CommanderPi RPiMonitor Fortune PiSafe JS8map nmon Weather Piapps Screensaver)
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
--button="Next":2 > ${RADIO}
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


#####################################
#	Get User Call
#####################################
CALL() {
	source ${MYPATH}/config
	INFO=$(yad --form --width=420 --text-align=center --center --title="Build-a-Pi" \
		--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
		--text="<b>version ${VERSION}</b>" \
		--field="Call Sign*" "${CALL}" \
		--field="<b>* Required</b>":LBL \
		--button="Continue":2)
	BUT=$?
	if [ ${BUT} = 252 ]; then
		exit
	fi
}
CALL
CALL=$(echo $INFO | awk -F "|" '{print $1}')
CALL=${CALL^^}

echo "CALL=${CALL}" >${CONFIG}

#Verify call not empty
if [ -z "${CALL}" ]; then
	yad --form --width=420 --text-align=center --center --title="Build-a-Pi" --text-align=center \
		--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
		--text="<b>Call Can't be Blank</b>" \
		--button=gtk-ok
	CALL
fi

#----------------------------------------------------#
#			BAP BASE APP MENU
#----------------------------------------------------#
source $UPDATEFILE
yad --center --list --checklist --width=600 --height=600 --separator="" \
	--image ${LOGO} --column=Check --column=App --column=status --column=description --print-column=2 \
	--window-icon=${LOGO} --image-on-top --text-align=center \
	--text="<big><big><b>Base Apps</b></big></big>" --title="Update" \
	false "HAMLIB" "$RIG" "Rig Control" \
	false "HOTSPOT" "$HOTSPOT" "Hot Spot Generator for Portable Ops" \
	false "HSTOOLS" "$HSTOOLS" "Tools to Manage HotSpot" \
	false "GPS" "${GPS}" "GPS Software" \
	false "GPSUPDATE" "${GPSUPDATE}" "Tool to Manage GPS Devices" \
	false "ARDOP" "$ARDOP" "Mode for HF" \
	false "ARDOPGUI" "$ARDOPGUI" "GUI for ARDOP" \
	false "DIREWOLF" "$DIRE" "Software TNC" \
	false "AX25" "$AX25" "Data Link Layer Protocol" \
	false "PULSE" "$PULSE" "Sound server" \
	--button="Exit":1 \
	--button="Next":2 >${BAPBASE}
BUT=$?
if [ ${BUT} = 1 ] || [ ${BUT} = 252 ]; then
	exit
fi

#############################################################
#check if hotspot is chosen for install & get info if needed#
#############################################################
HS=$(cat ${BAPBASE} | grep HOTSPOT)
if [ -n "$HS" ]; then
	HSINFO() {
		#unblock wifi
		sudo rfkill unblock all >/dev/null 2>&1
		#bring wifi up
		sudo ifconfig wlan0 up
		#LIST=$(sudo iw dev "wlan0" scan ap-force | egrep "^BSS|SSID:" | grep SSID: | sed 's/SSID://' | awk '{ print $1 }')
		#LIST=$(echo $LIST | sed 's/ /|/g')
		#Thanks to https://github.com/kuperman for fixing wifi space issue with line below.
		LIST=$(sudo iw dev "wlan0" scan ap-force | sed -ne 's/^.*SSID: \(..*\)/\1/p' | sort | uniq | paste -sd '|')

		HSINFO=$(yad --center --form --width=400 --height=400 --separator="|" --item-separator="|" \
			--image ${LOGO} --column=Check --column=App --column=Description \
			--window-icon=${LOGO} --image-on-top --text-align=center \
			--text="<b>HotSpot Information\r\rPlease enter the information\rbelow \
for the Hot Spot\r</b>NOTE: The last field is the password for the hotspot. You will use this password to \
connect to your Pi when it is in hotspot mode <b>This password can only contain letters and numbers</b>" \
			--title="Build-a-Pi" \
			--field="Home Wifi SSID":CB "${LIST}" \
			--field="Home Wifi Password" \
			--field="Hot Spot Password" \
			--button="Exit":1 \
			--button="Continue":2 \
			--button="Refresh Wifi":3)
		#} 					THIS IS WHERE ORIGINAL FUNCTION STOPPED################
		#HSINFO					SEE COMMENT PREVIOUS LINE
		BUT=$?
		if [ ${BUT} = 3 ]; then
			HSINFO #Call HSINFO function
		fi

		if [ ${BUT} = 252 ] || [ ${BUT} = 1 ]; then
			exit
		fi
	} #THIS IS NEW FUNCTION END FOR TESTING####################

	HSINFO
fi
SHACKSSID=$(echo $HSINFO | awk -F "|" '{print $1}')
SHACKPASS=$(echo $HSINFO | awk -F "|" '{print $2}')
HSPASS=$(echo $HSINFO | awk -F "|" '{print $3}')

#Check password length
if [ -n "$HS" ]; then
	COUNT=${#HSPASS}
	if [ $COUNT -lt 8 ]; then
		yad --center --form --width=300 --height=200 --separator="|" \
			--image ${LOGO} --column=Check --column=App --column=Description \
			--window-icon=${LOGO} --image-on-top --text-align=center \
			--text="<b>Hotspot password has to be 8-63 characters</b>" --title="Build-a-Pi" \
			--button=gtk-ok
		HSINFO
	fi
fi

echo "SHACKSSID=${SHACKSSID}" >>${CONFIG}
echo "SHACKPASS=${SHACKPASS}" >>${CONFIG}
echo "HSPASS=${HSPASS}" >>${CONFIG}

###################################
#CHECK IF GPS IS CHOSEN TO INSTALL#
###################################
GPSINSTALL=$(cat ${BAPBASE} | grep GPS)
if [ -n "${GPSINSTALL}" ]; then

	yad --center --height="300" --width="300" --form --separator="|" --item-separator="|" --title="GPS" \
		--image ${LOGO} --window-icon=${LOGO} --image-on-top \
		--text="\r\r\r\r\r<b><big>Connect your GPS to the pi</big></b>" \
		--button="Exit":1 \
		--button="Continue":2

	BUT=$?
	if [ ${BUT} = 1 ] || [ ${BUT} = 252 ]; then
		exit
	fi

	USB=$(ls /dev/serial/by-id)
	USB=$(echo $USB | sed "s/\s/|/g")

	GPS=$(yad --center --height="600" --width="300" --form --separator="|" --item-separator="|" --title="GPS" \
		--image ${LOGO} --window-icon=${LOGO} --image-on-top \
		--text="Choose Your GPS" \
		--field="GPS":CB "$USB")
	BUT=$?
	if [ ${BUT} = 252 ] || [ ${BUT} = 1 ]; then
		echo exiting
		exit
	fi

	GPS=$(echo ${GPS} | awk -F "|" '{print $1}')
	GPS=/dev/serial/by-id/${GPS}
	echo "GPS=${GPS}" >>${CONFIG}
fi

#----------------------------------------------------#
#		FLSUITE APP MENU
#----------------------------------------------------#
source $BAPUPDATEFILE
yad --center --list --checklist --width=600 --height=600 --separator="" \
	--image ${LOGO} --column=Check --column=App --column=status --column=description --print-column=2 \
	--window-icon=${LOGO} --image-on-top --text-align=center \
	--text="<big><big><b>FLDIGI Suite</b></big></big>" --title="Update" \
	false "FLRIG" "${FLRIG}" "Rig Control GUI" \
	false "FLDIGI" "${FLDIGI}" "Digital Software" \
	false "FLAMP" "${FLAMP}" "File Transfer Program" \
	false "FLNET" "${FLNET}" "Net Control Software" \
	false "FLMSG" "${FLMSG}" "Form Manager" \
	false "FLWRAP" "${FLWRAP}" "File Encapsulation" \
	--button="Exit":1 \
	--button="Next":2 >${FLSUITE}
BUT=$?
if [ ${BUT} = 1 ] || [ ${BUT} = 252 ]; then
	exit
fi
#----------------------------------------------------#
#		HAM APP MENU
#----------------------------------------------------#
source $BAPUPDATEFILE
yad --center --list --checklist --width=600 --height=600 --separator="" \
	--image ${LOGO} --column=Check --column=App --column=status --column=description --print-column=2 \
	--window-icon=${LOGO} --image-on-top --text-align=center \
	--text="<big><big><b>HAM Apps</b></big></big>" --title="Update" \
	false "PAT" "$PAT" "Radio Email Application" \
	false "PAT-MENU" "$PATMENU" "Control for Pat Winlink" \
	false "CHIRP" "$CHIRP" "Program Radios" \
	false "GARIM" "$GARIM" "File Transfer Program " \
	false "M0IAX" "$M0IAX" "Tools for JS8Call messages" \
	false "CONKY" "$CONKY" "System Information Display" \
	false "WSJTX" "$FT8" "Weak signal digital mode software" \
	false "JS8CALL" "$JS8" "Weak signal digital mode software" \
	false "XASTIR" "$XASTIR" "APRS Client" \
	false "YAAC" "$YAAC" "Yet Another APRS Client" \
	false "PI-APRS" "$PIAPRS" "APRS Messaging Client" \
	false "PYQSO" "$PYQSO" "Logging Software" \
	false "HAMRS" "$HAMRS" "Logging Software" \
	false "QSSTV" "$QSSTV" "Slow scan TV" \
	false "GRIDTRACKER" "$GRIDTRACK" "Track grids in WSJTX" \
	false "HAMCLOCK" "$HAMCLOCK" "Clock for Ham Radio Ops" \
	false "PROPAGATION" "$PROP" "Propagation prediction" \
	false "EES" "$EES" "KM4ACK Emergency Email Server" \
	false "GPREDICT" "$GPREDICT" "Satellite Tracking" \
	false "TQSL" "$TQSL" "LOTW Software" \
	false "GRIDCALC" "$GRIDCALC" "Grid Calculation Software" \
	--button="Exit":1 \
	--button="Next":2 >${ADDITIONAL}
BUT=$?
if [ ${BUT} = 1 ] || [ ${BUT} = 252 ]; then
	exit
fi

#check if hamclock is being installed
HCCHECK=$(cat ${ADDITIONAL} | grep HAMCLOCK)
if [ -n "$HCCHECK" ]; then

	HC=$(yad --form --width=420 --text-align=center --center --title="Build-a-Pi" \
		--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
		--text="<b>version $VERSION</b>" \
		--field="Ham Clock Size":CB "SMALL|LARGE" \
		--button="Continue":2)
	HC=$(echo $HC | awk -F "|" '{print $1}')
	sed -i 's/HAMCLOCK//' ${ADDITIONAL}
	echo $HC >>${ADDITIONAL}
fi


PATCHECK=$(cat ${ADDITIONAL} | grep PAT)
if [ -n "$PATCHECK" ]; then
	INFO=$(yad --form --width=420 --text-align=center --center --title="Build-a-Pi" \
		--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
		--text="<b>version $VERSION</b>" \
		--field="Six Character Grid Square" "$GRID" \
		--field="Winlink Password" \
		--field="<b>Password is case sensitive</b>":LBL \
		--button="Continue":2)
	GRID=$(echo $INFO | awk -F "|" '{print $1}')
	GRID=${GRID^^}
	WL2KPASS=$(echo $INFO | awk -F "|" '{print $2}')
	echo "GRID=$GRID" >>${CONFIG}
	echo "WL2KPASS=\"$WL2KPASS\"" >>${CONFIG}

fi

#----------------------------------------------------#
#		UTILITIES MENU
#----------------------------------------------------#
source $BAPUPDATEFILE
yad --center --list --checklist --width=600 --height=600 --separator="" \
	--image ${LOGO} --column=Check --column=App --column=status --column=description --print-column=2 \
	--window-icon=${LOGO} --image-on-top --text-align=center \
	--text="<big><big><b>UTILITIES</b></big></big>" --title="Update" \
	false "DIPOLE" "$DIPOLE" "Dipole Calculator" \
	false "PACKETSEARCH" "$PACKETSEARCH" "Winlink Packet Tool" \
	false "CALLSIGN" "${CALLSIGN}" "Call Sign Lookup Utility" \
	false "TEMPCONVERT" "$TEMPCONVERT" "Temperature Converter" \
	false "GPARTED" "$GPARTED" "Disk Utility Application" \
	false "RTC" "$RTC" "Real Time Clock" \
	false "SHOWLOG" "$SHOWLOG" "Log File Viewer" \
	false "PISTATS" "$PISTATS" "Pi3/4 Stats Monitor" \
	false "TELNET" "$TEL" "Telnet Protocol" \
	false "PITERM" "$PITERM" "PiQTermTCP Terminal Program" \
	false "QTSOUND" "$QTSOUND" "PiQtSoundModem" \
	false "SECURITY" "$SECURITY" "File Encryption Software" \
	false "YGATE" "$YGATE" "Yaesu APRS Software" \
	false "BPQ" "$BPQ" "LinBPQ Software" \
	false "BATT" "$BATT" "Battery Test Script" \
	false "VNC" "$VNC" "VNC Viewer Application" \
	false "XYGRIB" "$XYGRIB" "Grib file viewer" \
	--button="Exit":1 \
	--button="Install/Update Selected":2 >${UTILITY}
BUT=$?
if [ ${BUT} = 1 ] || [ ${BUT} = 252 ]; then
	exit
fi

#check and exit if nothing selected
CKBASE=$(cat ${BASE})
CKRADIO=$(cat ${RADIO})
CKBAPBASE=$(cat ${BAPBASE})
CKFL=$(cat ${FLSUITE})
CKADD=$(cat ${ADDITIONAL})
CKUTIL=$(cat ${UTILITY})
if [ -z "$CKBASE" ] && [ -z "$CKRADIO" ] && [ -z "$CKBAPBASE" ] && [ -z "$CKFL" ] && [ -z "$CKADD" ] && [ -z "$CKUTIL" ]; then
	CLEANUP >/dev/null 2>&1
	yad --width=550 --height=250 --text-align=center --center --title="Update" \
		--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
		--text="\r\r\r\r<b>Nothing selected for install/update</b>" \
		--button="CLOSE":1
	exit
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
#	Install BAP Base Apps
#####################################
touch ${HOME}/.config/KM4ACK
echo "UPDATE=\"ran $DATE Version $VERSION\"" >> ${HOME}/.config/KM4ACK
while read i; do
	source ${FUNCTIONS}/BAP/base.function
	$i
done <${BAPBASE}

#####################################
#	Install FLSUITE
#####################################
source ${FUNCTIONS}/BAP/flsuite.function
#perform memory increase if needed
CHECKFL=$(cat ${MYPATH}/flsuite.txt)
if [ -n "$CHECKFL" ]; then
	FLSTART
fi

touch ${HOME}/.config/KM4ACK
while read i; do
	source ${FUNCTIONS}/flsuite.function
	$i
done <${FLSUITE}

source ${FUNCTIONS}/BAP/flsuite.function
if [ -n "$CHECKFL" ]; then
	FLSTOP
fi

#####################################
#	Install ADDITIONAL (Radio) Apps
#####################################
while read i; do
	source ${FUNCTIONS}/BAP/additional.function
	$i
done <${ADDITIONAL}

#####################################
#	Install KM4ACK Utilites
#####################################
while read i; do
	source ${FUNCTIONS}/BAP/utility.function
	$i
done <${UTILITY}

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
