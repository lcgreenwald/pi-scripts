#!/bin/bash

#Script to create additional menu subcategories
#and move some items to those categories.
#Three new catagories will be created that can
#be used in .desktop files.
#flsuite - flsuite subcategory
#bap - Build a Pi subcategory
#km4ack - km4ack subcategory
###################
# Copied and modified 2021/08/14 wb0sio
# Added wb0sio subcategory
# 2021/08/16 wb0sio fixed flrig typos in FLSUITE()

REV=20210816

source $HOME/.config/WB0SIO


FLSUITE(){
##########################
#	FLSUITE 
##########################
CATEGORY=flsuite

FLPATH=/usr/local/share/applications

if [ -f $FLPATH/fldigi.desktop ]; then
echo "updating fldigi"
sudo sed -i "s/Categories.*/Categories=$CATEGORY/" $FLPATH/fldigi.desktop
fi

if [ -f $FLPATH/flamp.desktop ]; then
echo "updating flamp"
sudo sed -i "s/Categories.*/Categories=$CATEGORY/" $FLPATH/flamp.desktop
fi

if [ -f $FLPATH/flarq.desktop ]; then
echo "updating flarq"
sudo sed -i "s/Categories.*/Categories=$CATEGORY/" $FLPATH/flarq.desktop
fi

if [ -f $FLPATH/flmsg.desktop ]; then
echo "updating flmsg"
sudo sed -i "s/Categories.*/Categories=$CATEGORY/" $FLPATH/flmsg.desktop
fi

if [ -f $FLPATH/flnet.desktop ]; then
echo "updating flnet"
sudo sed -i "s/Categories.*/Categories=$CATEGORY/" $FLPATH/flnet.desktop
fi

if [ -f $FLPATH/flwrap.desktop ]; then
echo "updating flwrap"
sudo sed -i "s/Categories.*/Categories=$CATEGORY/" $FLPATH/flwrap.desktop
fi

if [ -f $FLPATH/flrig.desktop ]; then
echo "updating flrig"
sudo sed -i "s/Categories.*/Categories=$CATEGORY/" $FLPATH/flrig.desktop
fi
}

BAP(){
##########################
#	BAP 
##########################

cd /run/user/$UID

#DONATE
if [ ! -f /usr/local/share/applications/donate.desktop ]; then
	cat >donate.desktop <<EOF
[Desktop Entry]
Name=Donate
Comment=Donate to Build a Pi
Exec=xdg-open https://www.paypal.com/paypalme/km4ack
Icon=/home/pi/pi-build/logo.png
Terminal=false
Type=Application
Categories=bap
Keywords=Support
EOF

	sudo mv donate.desktop /usr/local/share/applications/
fi

#FAQ
if [ ! -f /usr/local/share/applications/faq.desktop ]; then
	cat >faq.desktop <<EOF
[Desktop Entry]
Name=FAQ
Comment=Build a Pi FAQ
Exec=xdg-open https://app.simplenote.com/publish/C3bBxN
Icon=/home/pi/pi-build/logo.png
Terminal=false
Type=Application
Categories=bap
Keywords=Support

EOF

	sudo mv faq.desktop /usr/local/share/applications/
fi

#SUPPORT
if [ ! -f /usr/local/share/applications/support.desktop ]; then
	cat >support.desktop <<EOF
[Desktop Entry]
Name=Tech Support
Comment=Build a Pi Tech Support
Exec=xdg-open https://groups.io/g/KM4ACK-Pi/topics
Icon=/home/pi/pi-build/logo.png
Terminal=false
Type=Application
Categories=bap
Keywords=Support

EOF

	sudo mv support.desktop /usr/local/share/applications/
fi

if [ ! -f /usr/local/share/applications/build-a-pi.desktop ]; then
sudo mv /usr/share/applications/build-a-pi.desktop /usr/local/share/applications/
sudo sed -i 's/Categories.*/Categories=bap/' /usr/local/share/applications/build-a-pi.desktop
sudo sed -i 's/Name.*/Name=Update-Tool/' /usr/local/share/applications/build-a-pi.desktop
fi
}

CREATEMENU(){
#Create menu subcategories
cd /run/user/$UID

cat >FLsuite.directory <<EOF
[Desktop Entry]
Type=Directory
Encoding=UTF-8
Name=flsuite
Icon=fldigi
EOF

sudo mv FLsuite.directory /usr/share/desktop-directories/

cat >km4ack.directory <<EOF
[Desktop Entry]
Type=Directory
Encoding=UTF-8
Name=KM4ACK-Tools
Icon=CQ.png
EOF

sudo mv km4ack.directory /usr/share/desktop-directories/

cat >bap.directory <<EOF
[Desktop Entry]
Type=Directory
Encoding=UTF-8
Name=Build-a-Pi
Icon=/home/pi/pi-build/logo.png
EOF

sudo mv bap.directory /usr/share/desktop-directories/

cat >wb0sio.directory <<EOF
[Desktop Entry]
Type=Directory
Encoding=UTF-8
Name=WB0SIO-Tools
Icon=/home/pi/pi-scripts/logo.png
EOF

sudo mv wb0sio.directory /usr/share/desktop-directories/

#MOD HAMRADIO.MENU FILE
cat >hamradio.menu <<EOF
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
 "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
<Menu>
  <Name>Applications</Name>
  <Menu>
    <Name>Hamradio</Name>
    <Directory>HamRadio.directory</Directory>
    <Include>
        <Category>HamRadio</Category>
    </Include>
		<Menu>
		<Name>FLSUITE</Name>
		<Directory>FLsuite.directory</Directory>
		<Include>
			<Category>flsuite</Category>
		</Include>
		</Menu>
		<Menu>
			<Name>KM4ACK</Name>
			<Directory>km4ack.directory</Directory>
			<Include>
				<Category>km4ack</Category>
			</Include>
		</Menu>
		<Menu>
			<Name>Build-a-Pi</Name>
			<Directory>bap.directory</Directory>
			<Include>
				<Category>bap</Category>
			</Include>
		</Menu>
		<Menu>
			<Name>WB0SIO</Name>
			<Directory>wb0sio.directory</Directory>
				<Include>
            <Category>wb0sio</Category>
			</Include>
		</Menu>
  </Menu> <!-- End hamradio -->
</Menu>
EOF

sudo mv hamradio.menu /usr/share/extra-xdg-menus/
}

#verify ham menu is installed
if [ ! -f /usr/share/extra-xdg-menus/hamradio.menu ]; then
sudo apt install -y extra-xdg-menus
fi

BAP

#check to see if this script has already run
if [ "$MENU" = "$REV" ]; then
REV=$(cat $HOME/.config/WB0SIO | sed 's/MENU=//')
echo "menu mods already made"
echo "Revision $REV installed"
exit
else
echo "MENU=$REV" >> $HOME/.config/WB0SIO
CREATEMENU
FLSUITE
fi



