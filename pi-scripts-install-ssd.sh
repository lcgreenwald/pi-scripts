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
#                                                         #
###########################################################

DESK=$(printenv | grep DISPLAY)
MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOGO=${MYPATH}/logo.png
RB=${HOME}/.config/WB0SIO
BASE=${MYPATH}/base.txt
RADIO=${MYPATH}/radio.txt
PATCH=${MYPATH}/patch.txt
FUNCTIONS=${MYPATH}/functions
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
}

trap FINISH EXIT

CLEANUP(){
# Run solar.sh to update the solar condiions data for conky
/home/pi/bin/solar.sh
/home/pi/bin/solarimage.sh
#Remove temp files
rm ${BASE} > /dev/null 2>&1
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

It will also optionally install the latest version of 
KM4ACK's Build-a-Pi and a custom version of KM4ACK's 
HotSpot Tools.

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
#	Base Apps
#####################################
yad --center --list --checklist --width=700 --height=750 --separator="" \
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
false "Conky" "System Information Display" \
false "Gparted" "Disk Utility Tool" \
false "Samba" "SMB file system" \
false "Webmin" "Web based system manager." \
false "Screensaver" "X Screensavers" \
false "Disks" "Manage Drives and Media" \
false "PiImager" "Raspberry Pi Imager" \
false "Neofetch" "Display Linux system Information In a Terminal" \
false "CommanderPi" "Easy RaspberryPi4 GUI system managment" \
false "RPiMonitor" "Display Linux system Information in a web browser" \
false "Fortune" "Display random quotes" \
false "PiSafe" "Backup or Restore Raspberry Pi devices" \
false "Weather" "Display weather conditions and forecast." \
--button="Exit":1 \
--button="Check All and Continue":3 \
--button="Next":2 > ${BASE}
BUT=$?
if [ $BUT = 252 ] || [ $BUT = 1 ]; then
CLEANUP
exit
fi

if [ $BUT = 3 ]; then

BASEAPPS=(DeskPi Argon X715 Log2ram ZramSwap Locate Plank Samba Webmin Screensaver Cqrprop Disks PiImager Neofetch CommanderPi RPiMonitor Fortune PiSafe Weather Conky Gparted)
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
#	Install Base Apps
#####################################
source ${FUNCTIONS}/base.function
while read i ; do
$i
done < ${BASE}

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
# Update swapfile parameters.
#####################################
sudo sed -i 's/CONF_SWAPSIZE=100/#CONF_SWAPSIZE=100/' /etc/dphys-swapfile
sudo sed -i 's/#CONF_SWAPFACTOR=2/CONF_SWAPFACTOR=1/' /etc/dphys-swapfile

#####################################
# Update HamRadio menu items.
#####################################
bash ${MYPATH}/menu-update-ssd.sh

#####################################
# Install WB0SIO versions of desktop, directory, conky and digi-mode files. Misc folders and sym-links.
#####################################
if [ ! -d ${HOME}/bin 2>/dev/null ] ; then
	mkdir ${HOME}/bin
fi
if [ ! -d ${HOME}/bin/conky 2>/dev/null ] ; then
	mkdir ${HOME}/bin/conky
fi
#cp -f ${HOME}/hotspot-tools2/hstools.desktop ${HOME}/.local/share/applications/hotspot-tools.desktop
cp -f ${MYPATH}/bin/*.sh ${HOME}/bin/
#cp -f ${MYPATH}/conky/get-grid ${HOME}/bin/conky/
#cp -f ${MYPATH}/conky/get-freq ${HOME}/bin/conky/
cp -f ${MYPATH}/desktop_files/* ${HOME}/.local/share/applications/
sed -i 's/update.sh/update-ssd.sh/' ${HOME}/.local/share/applications/psupdate.desktop
cp -rf ${MYPATH}/local/share/* ${HOME}/.local/share/
#cp -rf ${MYPATH}/xlog/* ${HOME}/.xlog/
cp -f ${MYPATH}/config/* ${HOME}/.config/
cp -f ${MYPATH}/conky/conky-noradio-ssd ${HOME}/.conkyrc
if [ ! -d ${HOME}/bin/conky/solardata 2>/dev/null ] ; then
	mkdir ${HOME}/bin/conky/solardata
fi

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
# Update Pi-Build/.complete to show .pscomplete.
#####################################
#echo "${MYPATH}/.pscomplete" >> ${HOME}/pi-build/.complete

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
