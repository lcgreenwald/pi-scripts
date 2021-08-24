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

REV=20210820

source $HOME/.config/WB0SIO

DESKTOP(){
# Create desktop entries
}

CREATEMENU(){
#Create menu subcategories
cd /run/user/$UID

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

#check to see if this script has already run
if [ "$MENU" = "$REV" ]; then
REV=$(cat $HOME/.config/WB0SIO | sed 's/MENU=//')
echo "menu mods already made"
echo "Revision $REV installed"
exit
else
echo "MENU=$REV" >> $HOME/.config/WB0SIO
DESKTOP
CREATEMENU
fi



