#!/bin/bash
cd ~
git clone https://github.com/km4ack/pi-build.git $HOME/pi-build
bash $HOME/pi-build/build-a-pi
git clone https://github.com/lcgreenwald/autohotspot-tools2.git $HOME/autohotspot-tools2
cp ~/pi-scripts/bin/*.sh ~/bin/
sudo cp ~/pi-scripts/desktop_files/* /usr/share/applications/
sed -i "s/km4ack\/hotspot-tools2/lcgreenwald\/hotspot-tools2/" /pi-build/update
sudo reboot
