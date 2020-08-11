#!/bin/bash
clear;echo;echo

MYPATH=$HOME/pi-scripts
#####################################
#	notice to user
#####################################
cat <<EOF > $MYPATH/intro.txt
K4CPO-FD-Logger update by wb0sio.
This script downloads and installs the latest version
of the K4CPO-FD-Logger customized for N0SUW/WB0SIO.
EOF

INTRO=$(yad --width=550 --height=250 --text-align=center --center --title="K4CPO-FD-Logger Update"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Continue":2 > /dev/null 2>&1)
BUT=$?
if [ $BUT = 252 ]; then
rm $MYPATH/intro.txt
exit
fi
rm $MYPATH/intro.txt

cd $HOME/K4CPO-FD-Logger
git pull
sudo cp -u $HOME/K4CPO-FD-Logger/* /var/www/html/log/
cd -

cat <<EOF > $MYPATH/intro.txt
The K4CPO-FD-Logger update is complete.
EOF

INTRO=$(yad --width=550 --height=250 --text-align=center --center --title="K4CPO-FD-Logger"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Continue":2 > /dev/null 2>&1)
BUT=$?
if [ $BUT = 252 ]; then
rm $MYPATH/intro.txt
exit
fi
rm $MYPATH/intro.txt
