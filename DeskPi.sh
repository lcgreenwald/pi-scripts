#!/bin/bash

MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOGO=$MYPATH/logo.png


#####################################
#	notice to user
#####################################
cat <<EOF > $MYPATH/intro.txt
This script downloads and installs the
DeskPi Pro power button and fan control.
It reboots auromatically.

EOF

INTRO=$(yad --width=600 --height=300 --text-align=center --center --title="Pi Build Install"  --show-uri \
--image $LOGO --window-icon=$LOGO --image-on-top --separator="|" --item-separator="|" \
--text-info<$MYPATH/intro.txt \
--button="Exit":1 \
--button="Continue":2 > /dev/null 2>&1)
BUT=$?
if [ $BUT = 252 ] || [ $BUT = 1 ]; then
rm $MYPATH/intro.txt
exit
fi
rm $MYPATH/intro.txt

#curl -sSL https://raw.githubusercontent.com/DeskPi-Team/deskpi/master/install.sh | sudo bash

cd ~
git clone https://github.com/DeskPi-Team/deskpi.git
cd ~/deskpi/
chmod +x install.sh
sudo ./install.sh
cd ~
