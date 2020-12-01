#!/bin/bash
sudo apt install -y scons gpsd-clients python-gps chrony python-gi-cairo asciidoctor libncurses5-dev python-dev pps-tools
cd $HOME/Downloads
wget http://download-mirror.savannah.gnu.org/releases/gpsd/gpsd-3.21.tar.xz
tar -xf gpsd-3.21.tar.xz
cd gpsd-3.21
scons && scons check && sudo scons udev-install
