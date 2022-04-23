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
# Modified for WB0SIO pi-build-install.                   #
#   6-November-2020 by WB0SIO                             #
#   23-April-2022 - WB0SIO - Copied BAP functions here    #
#										instead of calling BAP.               #
###########################################################

DESK=$(printenv | grep DISPLAY)
MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOGO=${MYPATH}/logo.png
RB=${HOME}/.config/WB0SIO
BASE=${MYPATH}/base.txt
BAPBASE=${MYPATH}/bapbase.txt
ADDITIONAL=${MYPATH}/additional.txt
UTILITY=${MYPATH}/utility.txt
FLSUITE=${MYPATH}/flsuite.txt
RADIO=${MYPATH}/radio.txt
PATCH=${MYPATH}/patch.txt
FUNCTIONS=${MYPATH}/functions
BAPFUNCTIONS=${MYPATH}/BAP/functions
TEMPCRON=${MYPATH}/cron.tmp
TEMPFSTAB=${MYPATH}/fstab.tmp
CONFIG=${MYPATH}/config.txt
WHO=$(whoami)
VERSION=$(cat ${MYPATH}/changelog | grep version= | sed 's/version=//')
AUTHOR=$(cat ${MYPATH}/changelog | grep author= | sed 's/author=//')
LASTUPDATE=$(cat ${MYPATH}/changelog | grep LastUpdate= | sed 's/LastUpdate=//')
TODAY=$(date +%Y-%m-%d)

export MYPATH LOGO CONFIG
touch ${CONFIG}

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

CLEANUP(){
# Run solar.sh to update the solar condiions data for conky
/home/pi/bin/solar.sh
/home/pi/bin/solarimage.sh
#Remove temp files
rm ${BASE} > /dev/null 2>&1
rm ${BAPBASE} > /dev/null 2>&1
rm ${ADDITIONAL} > /dev/null 2>&1
rm ${UTILITY} > /dev/null 2>&1
rm ${FLSUITE} > /dev/null 2>&1
rm ${RADIO} > /dev/null 2>&1
rm ${PATCH} > /dev/null 2>&1
sudo rm -rf ${HOME}/pi-build/temp > /dev/null 2>&1
sudo apt -y autoremove
# Enter the installation date in ${HOME}/.config/WB0SIO
echo "# The date pi-build-install.sh was executed" >> ${HOME}/.config/WB0SIO
echo "InstallDate=$TODAY" >> ${HOME}/.config/WB0SIO
}  

#####################################
#check for display. can't run from SSH
#####################################
if [ -z "${DESK}" ]
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
if [ -f "${RB}" ]; then
  bash ${MYPATH}/update.sh &
  exit
fi

echo "#######################################"
echo "#  Updating repository & installing   #"
echo "#  a few needed items before we begin #"
echo "#######################################"
cd ${MYPATH}
git config --global user.email "lcgreenwald@gmail.com"
git config --global user.name "lcgreenwald"
cd
#if ! hash log2ram 2>/dev/null; then
#	echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
#	wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
#fi

if [ ! -d /usr/local/share/applications/ ]; then
	sudo mkdir -p /usr/local/share/applications/
fi

sudo apt update
sudo apt upgrade -y
sudo apt install -y bluetooth bluez-cups bluez-obexd
if ! hash yad 2>/dev/null; then
	sudo apt install -y yad
fi
if ! hash jq 2>/dev/null; then
	sudo apt install -y jq
fi

#####################################
#	notice to user
#####################################
cat <<EOF > ${MYPATH}/intro.txt
pi-build-install by $AUTHOR.
Version $VERSION.
Last version update $LASTUPDATE.
This script is installed in ${MYPATH}

This script updates the operating system and then
downloads and installs some required and some optional 
utility software.

It will also install a custom version of KM4ACK's 
Build-a-Pi.

This script takes approximately 4 hours to complete
if you choose to install everything.

Enjoy!  73 de WB0SIO
EOF

INTRO=$(yad --width=600 --height=500 --text-align=center --center --title="Pi Build Install"  --show-uri \
--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
--text-info<${MYPATH}/intro.txt \
--button="Continue":2 > /dev/null 2>&1)
BUT=$?
if [ $BUT = 252 ]; then
rm ${MYPATH}/intro.txt
exit
fi
rm ${MYPATH}/intro.txt

#####################################
#	Create autostart dir
#used to autostart conky at boot
#####################################
mkdir -p ${HOME}/.config/autostart

#####################################
#	Get User Call
#####################################
CALL() {
	INFO=$(yad --form --width=420 --text-align=center --center --title="Build-a-Pi" \
		--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
		--text="<b>version $VERSION</b>" \
		--field="Call Sign*" \
		--field="<b>* Required</b>":LBL \
		--button="Continue":2)
	BUT=$?
	if [ ${BUT} = 252 ]; then
		exit
	fi
}
CALL
CALL=$(echo ${INFO} | awk -F "|" '{print $1}')
CALL=${CALL^^}

#Verify call not empty
ATTEMPTS=0
while [ -z "$CALL" ]; do
	if [ $ATTEMPTS -eq 3 ]; then
		yad --form --width=420 --text-align=center --center --title="Build-a-Pi" --text-align=center \
			--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
			--text="<b>Empty callsign after 3 attempts. Quiting!</b>" \
			--button=gtk-ok
		exit
	fi

	yad --form --width=420 --text-align=center --center --title="Build-a-Pi" --text-align=center \
		--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
		--text="<b>Call Can't be Blank</b>" \
		--button=gtk-ok

	((ATTEMPTS = ATTEMPTS + 1))
	CALL
	CALL=$(echo ${INFO} | awk -F "|" '{print $1}')
	CALL=${CALL^^}
done

echo "CALL=$CALL" >${CONFIG}

#####################################
#	Base Apps
#####################################
yad --center --list --checklist --width=700 --height=760 --separator="" \
--image ${LOGO} --column=Check --column=App --column=Description \
--print-column=2 --window-icon=${LOGO} --image-on-top --text-align=center \
--text="<b>Base Applications</b>" --title="Pi-Scripts Install" \
false "DeskPi" "DeskPi enclosure utilities." \
false "Argon" "Argon One m.2 enclosure utilities." \
false "X715" "X715 power supply hat utilities." \
false "Log2ram" "Create a RAM based log folder to reduce SD card wear." \
false "ZramSwap" "Create a RAM based swap file to improve system response." \
false "Locate" "File search utility" \
false "Plank" "Application dock." \
false "Samba" "SMB file system" \
false "Webmin" "Web based system manager." \
false "Display" "Drivers for a 3.5 in. touch screen display" \
false "Disks" "Manage Drives and Media" \
false "PiImager" "Raspberry Pi Imager" \
false "Neofetch" "Display Linux system Information In a Terminal" \
false "CommanderPi" "Easy RaspberryPi4 GUI system managment" \
false "RPiMonitor" "Display Linux system Information in a web browser" \
false "Fortune" "Display random quotes" \
false "PiSafe" "Backup or Restore Raspberry Pi devices" \
false "nmon" "Linux performance monitor" \
false "Weather" "Display weather conditions and forecast." \
false "Piapps" "The most popular app store for Raspberry Pi computers." \
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
WEATHER=$(yad --form --center --width 600 --height 300 --separator="|" --item-separator="|" --title="Weather config" \
  --image ${LOGO} --window-icon=${LOGO} --image-on-top --text-align=center \
  --text "Enter your API Key, Latitude and Longitude below and press Continue." \
  --field="API Key" \
  --field="Latitude":NUM \
  --field="Longitude":NUM \
  --field="Longitude Direction":CB \
  --field="Units":CB \
  "" " |-90..90|.0001|4" " |-180..180|.0001|4" "W|E" "imperial|metric" \
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

  echo "APIKEY=$APIKEY" >${CONFIG}
  echo "LAT=$LAT" >>${CONFIG}
  echo "LON=$LON" >>${CONFIG}
  echo "LONDIR=$LONDIR" >>${CONFIG}
  echo "UNITS=$UNITS" >>${CONFIG}
fi


#####################################
#	Ham Apps Menu
#####################################
yad --center --list --checklist --width=700 --height=750 --separator="" \
--image ${LOGO} --column=Check --column=App --column=Description \
--print-column=2 --window-icon=${LOGO} --image-on-top --text-align=center \
--text="<b>Ham Radio Applications</b>" --title="Pi-Scripts Install" \
false "Cqrprop" "A small application that shows propagation data" \
false "JS8map" "Map to show location of JS8Call contacts" \
false "PythonGPS" "Use Python to show the grid square in conky" \
--button="Exit":1 \
--button="Check All and Continue":3 \
--button="Next":2 > ${RADIO}
BUT=$?
if [ $BUT = 252 ] || [ $BUT = 1 ]; then
CLEANUP
exit
fi

if [ $BUT = 3 ]; then

RADIOAPPS=(Cqrprop JS8map PythonGPS)
for i in "${RADIOAPPS[@]}"
do
echo "$i" >> ${RADIO}
done
fi

#####################################
#	BAP Base Apps
#####################################
yad --center --list --checklist --width=600 --height=600 --separator="" \
	--image ${LOGO} --column=Check --column=App --column=Description \
	--print-column=2 --window-icon=${LOGO} --image-on-top --text-align=center \
	--text="<b>Base Applications</b>" --title="Build-a-Pi" \
	false "HOTSPOT" "Hot Spot Generator for Portable Ops" \
	false "HSTOOLS" "Tools to Manage Hot Spot" \
	false "GPS" "GPS Software" \
	false "GPSUPDATE" "Tool to Manage GPS Devices" \
	false "ARDOP" "Modem for HF" \
	false "ARDOPGUI" "GUI for ARDOP" \
	false "HAMLIB" "Needed for Rig Control" \
	false "DIREWOLF" "Software TNC" \
	false "AX25" "Data Link Layer Protocol" \
	false "PULSE" "Pulse Audio Control Interface" \
	--button="Exit":1 \
	--button="Check All and Continue":3 \
	--button="Next":2 >${BAPBASE}
BUT=$?
if [ ${BUT} = 252 ] || [ ${BUT} = 1 ]; then
	exit
fi

if [ ${BUT} = 3 ]; then
	BAPBASEAPPS=(HOTSPOT HSTOOLS GPS ARDOP ARDOPGUI HAMLIB DIREWOLF AX25 PULSE GPSUPDATE)
	for i in "${BAPBASEAPPS[@]}"; do
		echo "$i" >>${BAPBASE}
	done
fi

#check if hotspot is chosen for install & get info if needed
HS=$(grep "HOTSPOT" ${BAPBASE})
if [ -n "$HS" ]; then
	HSINFO() {
		#unblock wifi
		sudo rfkill unblock all >/dev/null 2>&1
		#bring wifi up
		sudo ifconfig wlan0 up
		#LIST=$(sudo iw dev "wlan0" scan ap-force | egrep "^BSS|SSID:" | grep SSID: | sed 's/SSID://' | awk '{ print $1 }')
		#LIST=$(echo $LIST | sed 's/ /|/g')
		LIST=$(sudo iw dev "wlan0" scan ap-force | sed -ne 's/^.*SSID: \(..*\)/\1/p' | sort | uniq | paste -sd '|')

		HSINFO=$(yad --center --form --width=400 --height=400 --separator="|" --item-separator="|" \
			--image ${LOGO} --column=Check --column=App --column=Description \
			--window-icon=${LOGO} --image-on-top --text-align=center \
			--text="<b>HotSpot Information\r\rPlease enter the information\rbelow \
for the Hot Spot\r</b>NOTE: The last field is the password for the hotspot. You will use this password to \
connect to your Pi when it is in hotspot mode <b>This password can only contain letters and numbers</b>" \
			--title="Build-a-Pi" \
			--field="Home Wifi SSID":CB "$LIST" \
			--field="Home Wifi Password" \
			--field="Hot Spot Password" \
			--button="Exit":1 \
			--button="Continue":2 \
			--button="Refresh Wifi":3)
		BUT=$?
		if [ ${BUT} = 3 ]; then
			HSINFO #Call HSINFO function
		fi

		if [ ${BUT} = 252 ] || [ ${BUT} = 1 ]; then
			exit
		fi
		#}
		#HSINFO
		#fi
		SHACKSSID=$(echo $HSINFO | awk -F "|" '{print $1}')
		SHACKPASS=$(echo $HSINFO | awk -F "|" '{print $2}')
		HSPASS=$(echo $HSINFO | awk -F "|" '{print $3}')

		#Check password length
		if [ -n "$HS" ]; then
			COUNT=${#HSPASS}
			if [ ${COUNT} -lt 8 ]; then
				yad --center --form --width=300 --height=200 --separator="|" \
					--image ${LOGO} --window-icon=${LOGO} --image-on-top --text-align=center \
					--text="<b>Hotspot password has to be 8-63 characters</b>" --title="Build-a-Pi" \
					--button=gtk-ok
				HSINFO
			fi
		fi

	}
	HSINFO
fi

echo "SHACKSSID=$SHACKSSID" >>${CONFIG}
echo "SHACKPASS=\"$SHACKPASS\"" >>${CONFIG}
echo "HSPASS=\"$HSPASS\"" >>${CONFIG}

###################################
#CHECK IF GPS IS CHOSEN TO INSTALL#
###################################
GPSINSTALL=$(cat ${BAPBASE} | grep GPS)
if [ -n "${GPSINSTALL}" ]; then

	yad --center --height="300" --width="300" --form --separator="|" --item-separator="|" --title="GPS" \
		--image ${LOGO} --window-icon=${LOGO} --image-on-top \
		--text="\r\r\r\r\r<b><big>Connect your GPS to the pi</big></b>" \
		--button="Continue":2

	BUT=$?

	USB=$(ls /dev/serial/by-id)
	USB=$(echo "NONE $USB") #see https://github.com/km4ack/pi-build/issues/293
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

#####################################
#	FLSUITE
#####################################
yad --center --list --checklist --width=600 --height=600 --separator="" \
	--image ${LOGO} --column=Check --column=App --column=Description \
	--print-column=2 --window-icon=${LOGO} --image-on-top --text-align=center \
	--text="<b>FLDIGI Suite</b>" --title="Build-a-Pi" \
	false "FLRIG" "Rig Contol GUI" \
	false "FLDIGI" "Digital Software" \
	false "FLAMP" "File Transfer Program" \
	false "FLNET" "Net Control Software" \
	false "FLMSG" "Forms Manager" \
	false "FLWRAP" "File Encapsulation" \
	--button="Exit":1 \
	--button="Check All and Continue":3 \
	--button="Next":2 >${FLSUITE}
BUT=$?
if [ ${BUT} = 252 ] || [ ${BUT} = 1 ]; then
	exit
fi
if [ ${BUT} = 3 ]; then
	FLAPPS=(FLRIG FLDIGI FLAMP FLNET FLMSG FLWRAP)
	for i in "${FLAPPS[@]}"; do
		echo "$i" >>${FLSUITE}
	done
fi

#####################################
#	Additional (ham) Apps
#####################################
yad --center --list --checklist --width=600 --height=600 --separator="" \
	--image ${LOGO} --column=Check --column=App --column=Description \
	--print-column=2 --window-icon=${LOGO} --image-on-top --text-align=center \
	--text="<b>Ham Applications</b>" --title="Build-a-Pi" \
	false "CONKY" "System Information Display" \
	false "PI-APRS" "APRS Message Application" \
	false "CHIRP" "Program Radios" \
	false "GARIM" "File Transfer Program" \
	false "PAT" "Radio Email Application" \
	false "PAT-MENU" "Control for Pat Winlink" \
	false "JS8CALL" "Weak Signal Digital Mode Software" \
	false "M0IAX" "Tools for JS8Call Messages" \
	false "WSJTX" "Weak Signal Digital Mode Software" \
	false "PYQSO" "Logging Software" \
	false "HAMRS" "Logging Software" \
	false "EES" "KM4ACK Emergency Email Server" \
	false "QSSTV" "Slow Scan TV" \
	false "GRIDTRACKER" "Track Grids in WSJTX" \
	false "HAMCLOCK" "Clock for Ham Radio Ops" \
	false "PROPAGATION" "Propagation Prediction Software" \
	false "YAAC" "Yet Another APRS Client" \
	false "XASTIR" "APRS Client" \
	false "GPREDICT" "Satellite Tracking" \
	false "TQSL" "LOTW Software" \
	false "GRIDCALC" "Grid Calculation Software" \
	--button="Exit":1 \
	--button="Check All and Continue":3 \
	--button="Next":2 >${ADDITIONAL}
BUT=$?
if [ ${BUT} = 252 ] || [ ${BUT} = 1 ]; then
	exit
fi

if [ ${BUT} = 3 ]; then
	ADDAPPS=(CONKY PI-APRS CHIRP GARIM PAT PAT-MENU JS8CALL M0IAX WSJTX PYQSO
		HAMRS EES QSSTV GRIDTRACKER HAMCLOCK PROPAGATION YAAC XASTIR GPREDICT TQSL
		GRIDCALC)

	for i in "${ADDAPPS[@]}"; do
		echo "$i" >>${ADDITIONAL}
	done
fi

#check if hamclock is being installed
HCCHECK=$(grep "HAMCLOCK" ${ADDITIONAL})
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


PATCHECK=$(grep "PAT" ${ADDITIONAL})
if [ -n "$PATCHECK" ]; then
	INFO=$(yad --form --width=420 --text-align=center --center --title="Build-a-Pi" \
		--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
		--text="<b>version $VERSION</b>" \
		--field="Six Character Grid Square" \
		--field="Winlink Password" \
		--field="<b>Password is case sensitive</b>":LBL \
		--button="Continue":2)
	GRID=$(echo ${INFO} | awk -F "|" '{print $1}')
	GRID=${GRID^^}
	WL2KPASS=$(echo ${INFO} | awk -F "|" '{print $2}')
	echo "GRID=$GRID" >>${CONFIG}
	echo "WL2KPASS=\"$WL2KPASS\"" >>${CONFIG}
fi

#####################################
#	Utilities
#####################################
yad --center --list --checklist --width=600 --height=600 --separator="" \
	--image ${LOGO} --column=Check --column=App --column=Description \
	--print-column=2 --window-icon=${LOGO} --image-on-top --text-align=center \
	--text="<b>Utilities</b>" --title="Build-a-Pi" \
	false "DIPOLE" "Dipole Calculator" \
	false "PACKETSEARCH" "Winlink Packet Tool" \
	false "CALLSIGN" "Call sign lookup" \
	false "TEMPCONVERT" "Temperature Converter" \
	false "GPARTED" "Disk Utility Tool" \
	false "SHOWLOG" "Log file viewer" \
	false "PISTATS" "Pi3/4 Stats Monitor" \
	false "TELNET" "Telnet Protocol" \
	false "PITERM" "piQtTermTCP Terminal Program" \
	false "QTSOUND" "piQtSoundModem" \
	false "SECURITY" "File Encryption Software" \
	false "YGATE" "Yaesu APRS Software" \
	false "BPQ" "LinBPQ Software" \
	false "BATT" "Battery Test Script" \
	false "VNC" "VNC Client Application" \
	false "XYGRIB" "Grib File Viewer" \
	--button="Exit":1 \
	--button="Check All and Continue":3 \
	--button="Install Selected":2 >${UTILITY}
BUT=$?
if [ ${BUT} = 252 ] || [ ${BUT} = 1 ]; then
	exit
fi

if [ ${BUT} = 3 ]; then
	UTILAPPS=(DIPOLE PACKETSEARCH CALLSIGN TEMPCONVERT GPARTED SHOWLOG PISTATS TELNET PITERM QTSOUND SECURITY YGATE BPQ BATT VNC XYGRIB)
	for i in "${UTILAPPS[@]}"; do
		echo "$i" >>${UTILITY}
	done
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
touch ${RB}
echo "INITIAL=\"build date $DATE version $VERSION\"" >> ${RB}
source ${FUNCTIONS}/BAP/base.function
while read i; do
	$i
done <${BASE}

#####################################
#	Install FLSUITE
#####################################
source ${FUNCTIONS}/BAP/flsuite.function
#perform memory increase if needed
CHECKFL="${MYPATH}/flsuite.txt"
if [ -s "$CHECKFL" ]; then
	FLSTART
fi
touch ${RB}
while read i; do
	$i
done <${FLSUITE}

#Perform memory reset if needed
if [ -s "$CHECKFL" ]; then
	FLSTOP
fi

#####################################
#	Install ADDITIONAL Apps
#####################################
source ${FUNCTIONS}/BAP/additional.function
while read i; do
	$i
done <${ADDITIONAL}

#####################################
#	Install KM4ACK Utilites
#####################################
source ${FUNCTIONS}/BAP/utility.function
while read i; do
	$i
done <${UTILITY}

#####################################
#	Update crontab
#####################################
crontab -l > ${TEMPCRON}
echo "@reboot sleep 30 && /home/pi/bin/solar.sh" >> ${TEMPCRON}
echo "@reboot sleep 35 && /home/pi/bin/solarimage.sh" >> ${TEMPCRON}
echo "@reboot sleep 40 && /home/pi/bin/writegrid.sh" >> ${TEMPCRON}
echo "*/10 * * * * /home/pi/bin/solar.sh" >> ${TEMPCRON}
echo "*/10 * * * * /home/pi/bin/solarimage.sh" >> ${TEMPCRON}
echo "*/3 * * * * /home/pi/bin/writegrid.sh" >> ${TEMPCRON}
#echo "*/1 * * * * /home/pi/bin/writefreq.sh" >> ${TEMPCRON}
echo "00 03 * * 0  /home/pi/bin/install-updates.sh" >> ${TEMPCRON}
echo "00 03 * * *  /home/pi/bin/BackupDigitalModeSettings.sh" >> ${TEMPCRON}
crontab ${TEMPCRON}
rm ${TEMPCRON}


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
# Update swapfile parameters.
#####################################
sudo sed -i 's/CONF_SWAPSIZE=100/#CONF_SWAPSIZE=100/' /etc/dphys-swapfile
sudo sed -i 's/#CONF_SWAPFACTOR=2/CONF_SWAPFACTOR=1/' /etc/dphys-swapfile

#####################################
# Update HamRadio menu items.
#####################################
bash ${MYPATH}/menu-update.sh

#####################################
# Install WB0SIO versions of desktop, directory, conky and digi-mode files. Misc folders and sym-links.
#####################################
if [ ! -d ${HOME}/bin 2>/dev/null ] ; then
	mkdir ${HOME}/bin
fi
if [ ! -d ${HOME}/bin/conky 2>/dev/null ] ; then
	mkdir ${HOME}/bin/conky
fi
cp -f ${HOME}/hotspot-tools2/hstools.desktop ${HOME}/.local/share/applications/hotspot-tools.desktop
cp -f ${MYPATH}/bin/*.sh ${HOME}/bin/
cp -f ${MYPATH}/conky/get-grid ${HOME}/bin/conky/
cp -f ${MYPATH}/conky/get-freq ${HOME}/bin/conky/
cp -f ${MYPATH}/desktop_files/* ${HOME}/.local/share/applications/
cp -f ${MYPATH}/hrdesktop_files/* ${HOME}/.local/share/applications/
cp -rf ${MYPATH}/local/share/* ${HOME}/.local/share/
cp -rf ${MYPATH}/xlog/* ${HOME}/.xlog/
cp -f ${MYPATH}/config/* ${HOME}/.config/
cp -f ${MYPATH}/conky/.conkyrc ${HOME}/
cp -f ${MYPATH}/bpq32.cfg ${HOME}/linbpq/
cp -f ${MYPATH}/direwolf.conf ${HOME}/
if [ ! -d ${HOME}/.xlog 2>/dev/null ] ; then
	mkdir ${HOME}/.xlog
fi
if [ ! -d ${HOME}/bin/conky/solardata 2>/dev/null ] ; then
	mkdir ${HOME}/bin/conky/solardata
fi
if [ ! -d ${HOME}/Documents/adi_files 2>/dev/null ] ; then
	mkdir ${HOME}/Documents/adi_files
fi
if [ -d ${HOME}/.local/share/JS8Call 2>/dev/null ] ; then
	ln -s ${HOME}/.local/share/JS8Call/js8call_log.adi ${HOME}/Documents/adi_files/js8call_log.adi
fi
if [ -d ${HOME}/.local/share/WSJT-X 2>/dev/null ] ; then
	ln -s ${HOME}/.local/share/WSJT-X/wsjtx_log.adi ${HOME}/Documents/adi_files/wsjtx_log.adi
fi
sed -i "s/N0CALL/$CALL/" ${HOME}/.conkyrc

#####################################
#	Update fstab and create mount point
#####################################
cat /etc/fstab > ${TEMPFSTAB}
echo " " >> ${TEMPFSTAB}
echo "# <file system>    <mount point>                        <type>    <options>" >> ${TEMPFSTAB}
echo "honshu:public      /home/public/mounts/honshu/public    nfs       rw,sync,bg,auto,intr,soft,_netdev,retry=1" >> ${TEMPFSTAB}
sudo cp ${TEMPFSTAB} /etc/fstab
rm ${TEMPFSTAB}
if [ ! -d /home/public/mounts/honshu/public 2>/dev/null ] ; then
  mkdir -p /home/public/mounts/honshu/public
fi

#####################################
# Update the locate database.
#####################################
echo "#######################################"
echo "#  Updating the locate database.      #"
echo "#  This may take a minute or two.     #"
echo "#######################################"
sudo updatedb

#####################################
#	END CLEANUP
#####################################
CLEANUP

#####################################
#reboot when done
#####################################
cat <<EOF > ${MYPATH}/intro.txt
Pi-Build-Install finished 
Reboot Required
If you close this window, you will have to reboot manually.

EOF

INTRO=$(yad --width=600 --height=300 --text-align=center --center --title="Pi Build Install"  --show-uri \
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
