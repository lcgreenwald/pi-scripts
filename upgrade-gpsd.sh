#!/bin/bash
apt install -y scons
cd $HOME/Downloads
wget http://download-mirror.savannah.gnu.org/releases/gpsd/gpsd-3.21.tar.xz
tar -xf gpsd-3.21.tar.xz
cd gpsd-3.21
scons && scons check && scons udev-install
