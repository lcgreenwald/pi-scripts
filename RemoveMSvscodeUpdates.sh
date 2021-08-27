#!/bin/bash
############################
# Remove Microsoft vscode updates from Rasberry PI OS
#  From info in https://www.cyberciti.biz/linux-news/heads-up-microsoft-repo-secretly-installed-on-all-raspberry-pis-linux-os/
# Execute with sudo
# Created 2021/02/09 - Larry Greenwald WB0SIO
# Modified 2021/02/10 - Larry Greenwald WB0SIO
############################
#check if run as root
who=$(whoami)
if [ $who == "root" ]
then
echo ""
else
echo "This script must be run as root"
echo "sudo ~/pi-scripts/RemoveMSvscodeUpdates.sh"
exit
fi

echo "Would you like to put a hold on the"
read -p "raspberrypi-sys-mods package? y/n " ANS

if [ $ANS = 'y' ] || [ $ANS = 'Y' ];then
echo "A hold will be placed on the raspberrypi-sys-mods package"
echo "You can remove this hold at anytime by running"
echo "sudo apt-mark unhold raspberrypi-sys-mods"

#Hold raspberrypi-sys-mods package
apt-mark hold raspberrypi-sys-mods
fi

# Edit /etc/hosts on RPI
echo "0.0.0.0    packages.microsoft.com" >> /etc/hosts

# Disable vscode updates and
# write protect that file on Linux using the chattr command:
cp /etc/apt/sources.list.d/vscode.list /etc/apt/sources.list.d/vscode.tmp
sed -i "s/deb/#deb/" /etc/apt/sources.list.d/vscode.tmp
cp /etc/apt/sources.list.d/vscode.tmp /etc/apt/sources.list.d/vscode.list
rm /etc/apt/sources.list.d/vscode.tmp
chattr +i /etc/apt/sources.list.d/vscode.list
lsattr /etc/apt/sources.list.d/vscode.list

# Delete Microsoft’s GPG key using the rm command:
rm -vf /etc/apt/trusted.gpg.d/microsoft.gpg

# Make sure new keys cannot be installed and
# write protect that file on Linux using the chattr command:
touch /etc/apt/trusted.gpg.d/microsoft.gpg
chattr +i /etc/apt/trusted.gpg.d/microsoft.gpg
lsattr /etc/apt/trusted.gpg.d/microsoft.gpg
