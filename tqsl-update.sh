#!/bin/bash
clear;echo;echo

MYPATH=$HOME/pi-scripts
#####################################
#	notice to user
#####################################
cat <<EOF > $MYPATH/intro.txt
TrustedSQL Install by wb0sio.
This script downloads, compiles and installs
the latest version of TrustedQSL.
EOF

INTRO=$(yad --width=550 --height=250 --text-align=center --center --title="TQSL Install"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Continue":2 > /dev/null 2>&1)
BUT=$?
if [ $BUT = 252 ]; then
rm $MYPATH/intro.txt
exit
fi
rm $MYPATH/intro.txt

cd ~/trustedqsl-tqsl
git pull
cmake .
make
sudo make install

cat <<EOF > $MYPATH/intro.txt
The TrustedSQL update is complete.
EOF

INTRO=$(yad --width=550 --height=250 --text-align=center --center --title="TQSL Install"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Continue":2 > /dev/null 2>&1)
BUT=$?
if [ $BUT = 252 ]; then
rm $MYPATH/intro.txt
exit
fi
rm $MYPATH/intro.txt
