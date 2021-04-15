#!/bin/bash
sudo apt-get install -y cmake libimlib2-dev libncurses5-dev libx11-dev libxdamage-dev libxft-dev libxinerama-dev libxml2-dev libxext-dev libcurl4-openssl-dev liblua5.3-dev
cd
git clone https://github.com/brndnmtthws/conky.git
cd conky
mkdir build
cd build
cmake ..
make
sudo make install
