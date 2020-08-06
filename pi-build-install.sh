#!/bin/bash
echo "pi-build-install by wb0sio."
echo "Do not reboot at the end of the build-a-pi script."
echo "This script will automatically reboot upon completion."
cd ~
git clone https://github.com/km4ack/pi-build.git $HOME/pi-build
bash $HOME/pi-build/build-a-pi
git clone https://github.com/lcgreenwald/autohotspot-tools2.git $HOME/autohotspot-tools2
git clone https://github.com/lcgreenwald/K4CPO-FD-Logger.git
sudo apt-get install -y php7.3 mariadb-server phpmyadmin
cd K4CPO-FD-Logger
rm adif_log.txt
nano setup
bash setup
sudo mkdir /var/www/html/log
sudo chmod 777 /var/www/html/log
sudo cp * /var/www/html/log/
sudo nano /var/www/html/log/constants.php
cp ~/pi-scripts/bin/*.sh ~/bin/
sudo cp ~/pi-scripts/desktop_files/* /usr/share/applications/
sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/hotspot-tools2/" /pi-build/update
sudo reboot
