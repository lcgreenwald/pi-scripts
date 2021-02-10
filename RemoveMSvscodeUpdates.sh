#!/bin/bash
############################
# Remove Microsoft vscode updates from Rasberry PI OS
#  From info in https://www.cyberciti.biz/linux-news/heads-up-microsoft-repo-secretly-installed-on-all-raspberry-pis-linux-os/
# Execute with sudo
# Created 2021/02/09 - Larry Greenwald
#
############################
#check if run as root
who=$(whoami)
if [ $who == "root" ]
then
echo ""
else
echo "Script should be run as root"
echo "sudo RemoveMSvscodeUpdates.sh"
exit
fi

# Edit /etc/hosts on RPI
echo "0.0.0.0 packages.microsoft.com" >> /etc/hosts

# Disable vscode updates and
# write protect that file on Linux using the chattr command:
sed -i "s/deb/#deb/" /etc/apt/sources.list.d/vscode.list
chattr +i /etc/apt/sources.list.d/vscode.list

# Put Debian package on hold so that it will not install further updates:
apt-mark hold raspberrypi-sys-mods

# Delete Microsoft’s GPG key using the rm command:
rm -vf /etc/apt/trusted.gpg.d/microsoft.gpg

# Make sure new keys cannot be installed and
# write protect that file on Linux using the chattr command:
touch /etc/apt/trusted.gpg.d/microsoft.gpg
chattr +i /etc/apt/trusted.gpg.d/microsoft.gpg
lsattr /etc/apt/trusted.gpg.d/microsoft.gpg
