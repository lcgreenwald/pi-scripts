#!/bin/bash
##################################
#	FLLOG
##################################

#Determine latest FLLOG
LOGTAR=$(curl -s http://www.w1hkj.com/files/fllog/ | grep .tar.gz | sed 's/<li><a\ href="//' | sed 's/">\ fllog.*$//' | tail -1)
LOGPKG=$(echo $LOGTAR | sed 's/.tar.gz//')

#Download latest FLLOG
cd $HOME/Downloads
wget --tries 2 --connect-timeout=60 http://www.w1hkj.com/files/fllog/$LOGTAR
tar -zxvf $LOGTAR
rm *.gz

#Build FLLOG
cd $LOGPKG
./configure --prefix=/usr/local --enable-static
make
sudo make install
sudo ldconfig

