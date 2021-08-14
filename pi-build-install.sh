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
LOGO=$MYPATH/logo.png
RB=$HOME/.config/WB0SIO
BASE=$MYPATH/base.txt
FUNCTIONS=$MYPATH/functions
TEMPCRON=$MYPATH/cron.tmp
WHO=$(whoami)
VERSION=$(cat $MYPATH/changelog | grep version= | sed 's/version=//')
export MYPATH
echo "MYPATH: $MYPATH"

FINISH(){
if [ -f "$BASE" ]; then
rm $BASE
fi
}

trap FINISH EXIT

#************
#check for display. can't run from SSH
#************
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
cd $HOME/pi-scripts
git config --global user.email "lcgreenwald@gmail.com"
git config --global user.name "lcgreenwald"
cd
if ! hash log2ram 2>/dev/null; then
	echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
	wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
fi
if ! hash rpimonitor 2>/dev/null; then
  sudo apt-get install dirmngr
  sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 2C0D3C0F
  sudo wget http://goo.gl/vewCLL -O /etc/apt/sources.list.d/rpimonitor.list
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
if ! hash xscreensaver 2>/dev/null; then
	sudo apt install -y xscreensaver streamer xdaliclock xfishtank xscreensaver-data-extra xscreensaver-gl xscreensaver-gl-extra
fi
if ! hash rpimonitor 2>/dev/null; then
	sudo apt install -y rpimonitor
fi

#####################################
#	notice to user
#####################################
cat <<EOF > $MYPATH/intro.txt
pi-build-install by wb0sio, version $VERSION.

This script updates the operating system and then
downloads and installs some required and some optional 
utility software.

It will also optionally install the latest version of 
KM4ACK's Build-a-Pi and a custom version of KM4ACK's 
HotSpot Tools.

Enjoy!  73 de WB0SIO
EOF

INTRO=$(yad --width=600 --height=400 --text-align=center --center --title="Pi Build Install"  --show-uri \
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
yad --center --list --checklist --width=650 --height=650 --separator="" \
--image $LOGO --column=Check --column=App --column=Description \
--print-column=2 --window-icon=$LOGO --image-on-top --text-align=center \
--text="<b>Base Applications</b>" --title="Pi-Scripts Install" \
false "DeskPi" "DeskPi enclosure utilities." \
false "Argon" "Argon One m.2 enclosure utilities." \
false "Log2ram" "Create a RAM based log folder to reduce SD card wear." \
false "Locate" "File search utility" \
false "Plank" "Application dock." \
false "Samba" "SMB file system" \
false "Webmin" "Web based system manager." \
false "Display" "Drivers for a 3.5 in. touch screen display" \
false "Cqrprop" "A small application that shows propagation data" \
false "Disks" "Manage Drives and Media" \
false "PiImager" "Raspberry Pi Imager" \
false "Neofetch" "Display Linux system Information In a Terminal" \
false "CommanderPi" "Easy RaspberryPi4 GUI system managment" \
false "Fortune" "Display random quotes" \
false "PiSafe" "Backup or Restore Raspberry Pi devices" \
false "JS8map" "Map to show location of JS8Call contacts" \
--button="Exit":1 \
--button="Check All and Continue":3 \
--button="Next":2 > $BASE
BUT=$?
if [ $BUT = 252 ] || [ $BUT = 1 ]; then
exit
fi

if [ $BUT = 3 ]; then
BASEAPPS=(DeskPi Argon Log2ram Locate Plank Samba Webmin Display Cqrprop Disks PiImager Neofetch CommanderPi Fortune PiSafe JS8map)
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
#	Update crontab
#####################################
crontab -l > $TEMPCRON
echo "@reboot sleep 30 && /home/pi/bin/solar.sh" >> $TEMPCRON
echo "@reboot sleep 35 && /home/pi/bin/solarimage.sh" >> $TEMPCRON
echo "@reboot sleep 40 && /home/pi/bin/writegrid.sh" >> $TEMPCRON
echo "*/10 * * * * /home/pi/bin/solar.sh" >> $TEMPCRON
echo "*/10 * * * * /home/pi/bin/solarimage.sh" >> $TEMPCRON
echo "*/3 * * * * /home/pi/bin/writegrid.sh" >> $TEMPCRON
echo "*/1 * * * * /home/pi/bin/writefreq.sh" >> $TEMPCRON
echo "00 03 * * 0  /home/pi/bin/install-updates.sh" >> $TEMPCRON
echo "00 03 * * *  /home/pi/bin/BackupDigitalModeSettings.sh" >> $TEMPCRON
crontab $TEMPCRON
rm $TEMPCRON

#####################################
#	Install Build-A-Pi
#####################################
cat <<EOF > $MYPATH/intro.txt
Now we will install Build-A-Pi.
Please select Master, Beta or Dev installation.
EOF

INTRO=$(yad --width=750 --height=275 --text-align=center --center --title="Pi Build Install"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Master":2 > /dev/null 2>&1 \
--button="Beta":3 > /dev/null 2>&1 \
--button="Dev":4 > /dev/null 2>&1 \
--button="Skip":5 > /dev/null 2>&1)
BUT=$(echo $?)

if [ $BUT = 252 ]; then
rm $MYPATH/intro.txt
exit
fi
rm $MYPATH/intro.txt

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

#************
# Edit build-a-pi to use the WB0SIO version of gpsd install.
#************
sed -i "s/km4ack\/pi-scripts\/master\/gpsinstall/lcgreenwald\/pi-scripts\/master\/gpsinstall/" $HOME/pi-build/functions/base.function

#************
# Update Pi-Build/build-a-pi to exit before the "Reboot now" pop up message.
#************
sed -i '/#reboot when done/a exit' $HOME/pi-build/build-a-pi
sed -i '/#reboot when done/a exit' $HOME/pi-build/update

# Run build-a-pi
if [ ! $BUT = 5 ]; then
  bash pi-build/build-a-pi
fi

# Load the configuration info that was set up in build-a-pi
source /home/pi/pi-build/config

#************
# Install the WB0SIO version of hotspot tools and edit build-a-pi to use that version.
#************
echo "#######################################"
echo "#  Installing the WB0SIO version of   #"
echo "#  Hotspot Tools.                     #"
echo "#######################################"
if [ -d $HOME/hotspot-tools2 ]; then
	rm -rf $HOME/hotspot-tools2
fi
git clone https://github.com/lcgreenwald/autohotspot-tools2.git $HOME/hotspot-tools2
sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" $HOME/pi-build/update
sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/autohotspot-tools2/" $HOME/pi-build/functions/base.function

#************
# Update aliases in .bashrc.
#************
sed -i "s/#alias ll='ls -l'/alias ll='ls -l'/" $HOME/.bashrc
sed -i "s/#alias la='ls -A'/alias la='ls -la'/" $HOME/.bashrc
sed -i "s/#alias l='ls -CF'/alias psgrep='ps -ef|grep -v grep|grep -i '/" $HOME/.bashrc

#************
# If pat menu is installed,
# Update callsign, password and grid info in Pat Menu.
#************
if [ -d $HOME/patmenu2 ]; then

  CONFIG=/home/pi/patmenu2/manage-pat-functions

  #set callsign
  sed -i "s/\"Call Sign\" \"\"/\"Call Sign\" \"$CALL\"/" $CONFIG
  #set password
  sed -i "s/\"Winlink Password\" \"\"/\"Winlink Password\" \"$WL2KPASS\"/" $CONFIG
  #set locator
  sed -i "s/\"Six Character Grid Square\" \"EM65TV\"/\"Six Character Grid Square\" \"$GRID\"/" $CONFIG
fi

#************
# Update swapfile parameters.
#************
sudo sed -i 's/CONF_SWAPSIZE=100/#CONF_SWAPSIZE=100/' /etc/dphys-swapfile
sudo sed -i 's/#CONF_SWAPFACTOR=2/CONF_SWAPFACTOR=1/' /etc/dphys-swapfile

#************
# Update km4ack menu items.
#************
#sudo sed -i 's/Categories=.*$/Categories=km4ack;/' /home/pi/.local/share/applications/hotspot-tools.desktop
#sudo sed -i 's/Categories=.*$/Categories=km4ack;/' /usr/share/applications/hotspot-tools.desktop
#sudo sed -i 's/Categories=.*$/Categories=km4ack;/' /usr/share/applications/dipole.desktop
#sudo sed -i 's/Categories=.*$/Categories=km4ack;/' /usr/share/applications/getcall.desktop
#sudo sed -i 's/Categories=.*$/Categories=km4ack;/' /usr/share/applications/converttemp.desktop

#************
# Update FLSuite menu items.
#************
#if [ -f /usr/local/share/applications/fldigi.desktop 2>/dev/null ]; then
#sudo sed -i 's/Categories=.*$/Categories=flsuite;/' /usr/local/share/applications/fldigi.desktop
#sudo sed -i 's/Categories=.*$/Categories=flsuite;/' /usr/local/share/applications/flarq.desktop
#sudo sed -i 's/Categories=.*$/Categories=flsuite;/' /usr/local/share/applications/flrig.desktop
#sudo sed -i 's/Categories=.*$/Categories=flsuite;/' /usr/local/share/applications/flamp.desktop
#sudo sed -i 's/Categories=.*$/Categories=flsuite;/' /usr/local/share/applications/flnet.desktop
#sudo sed -i 's/Categories=.*$/Categories=flsuite;/' /usr/local/share/applications/flmsg.desktop
#sudo sed -i 's/Categories=.*$/Categories=flsuite;/' /usr/local/share/applications/flwrap.desktop
#fi

#************
# Install WB0SIO versions of desktop, directory, conky and digi-mode files. Misc folders and sym-links.
#************
cp -f $HOME/hotspot-tools2/hstools.desktop $HOME/.local/share/applications/hotspot-tools.desktop
cp -f $MYPATH/bin/*.sh ~/bin/
cp -f $MYPATH/conky/get-grid ~/bin/conky/
cp -f $MYPATH/conky/get-freq ~/bin/conky/
cp -f $MYPATH/desktop_files/* $HOME/.local/share/applications/
cp -rf $MYPATH/local/share/* $HOME/.local/share/
cp -rf $MYPATH/xlog/* $HOME/.xlog/
cp -f $MYPATH/config/* $HOME/.config/
cp -f $MYPATH/conky/.conkyrc* $HOME/
cp -f $MYPATH/bpq32.cfg $HOME/linbpq/
cp -f $MYPATH/direwolf.conf $HOME/
sudo cp -f $MYPATH/directory_files/*.directory /usr/share/desktop-directories/
sudo cp -f $MYPATH/directory_files/hamradio.menu /usr/share/extra-xdg-menus/
if [ ! -d $HOME/.xlog 2>/dev/null ] ; then
	mkdir $HOME/.xlog
fi
if [ ! -d $HOME/bin/conky/solardata 2>/dev/null ] ; then
	mkdir $HOME/bin/conky/solardata
fi
if [ ! -d $HOME/Documents/adi_files 2>/dev/null ] ; then
	mkdir $HOME/Documents/adi_files
fi
if [ -d $HOME/.local/share/JS8Call 2>/dev/null ] ; then
	ln -s $HOME/.local/share/JS8Call/js8call_log.adi $HOME/Documents/adi_files/js8call_log.adi
fi
if [ -d $HOME/.local/share/WSJT-X 2>/dev/null ] ; then
	ln -s $HOME/.local/share/WSJT-X/wsjtx_log.adi $HOME/Documents/adi_files/wsjtx_log.adi
fi
sed -i "s/N0CALL/$CALL/" $HOME/.conkyrc

#####################################
#	Update fstab and create mount point
#####################################
sudo echo " " >> /etc/fstab
sudo echo "# <file system>    <mount point>                        <type>    <options>" >> /etc/fstab
sudo echo "honshu:public      /home/public/mounts/honshu/public    nfs       rw,sync,bg,auto,intr,soft,_netdev,retry=1" >> /etc/fstab
if [ ! -d /home/public/mounts/honshu/public 2>/dev/null ] ; then
  mkdir -p /home/public/mounts/honshu/public
fi

#************
# Update the locate database.
#************
echo "#######################################"
echo "#  Updating the locate database.      #"
echo "#  This may take a minute or two.     #"
echo "#######################################"
sudo updatedb

#************
# Update Pi-Build/.complete to show .pscomplete.
#************
echo "$MYPATH/.pscomplete" >> $HOME/pi-build/.complete

#####################################
#	END CLEANUP
#####################################
# Run solar.sh to update the solar condiions data for conky
/home/pi/bin/solar.sh
/home/pi/bin/solarimage.sh
#Remove temp files
rm $BASE > /dev/null 2>&1
sudo rm -rf $HOME/pi-build/temp > /dev/null 2>&1
sudo apt -y autoremove

#####################################
#reboot when done
#####################################
cat <<EOF > $MYPATH/intro.txt
Pi-Build-Install finished 
Reboot Required
If you close this window, you will have to reboot manually.

EOF

INTRO=$(yad --width=600 --height=300 --text-align=center --center --title="Pi Build Install"  --show-uri \
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
