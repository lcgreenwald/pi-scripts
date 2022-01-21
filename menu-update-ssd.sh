#!/bin/bash

# Script to create additional menu subcategories and move some items to those categories.
# Copied from km4ack pi-build/menu-update and modified 2021/08/14 wb0sio
# Added wb0sio subcategory
# 2021/08/16 wb0sio - fixed flrig typos in FLSUITE()
# 2021/08/25 wb0sio - Removed redundant menu items
# 2022/01/20 wb0sio - Converted to PiScripts menu for Pi-Scripts-SSD

REV=2022-01-20

source $HOME/.config/WB0SIO


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

cat >wb0sioconky.directory <<EOF
[Desktop Entry]
Type=Directory
Encoding=UTF-8
Name=WB0SIO-Conky-Tools
Icon=/home/pi/pi-scripts/logo.png
EOF

sudo mv wb0sio.directory /usr/share/desktop-directories/
sudo mv wb0sioconky.directory /usr/share/desktop-directories/

#MOD PiScripts.MENU FILE
cat >PiScripts.menu <<EOF
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
 "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
<Menu>
	<Name>Applications</Name>
	<Menu>
		<Name>PiScripts</Name>
		<Directory>PiScripts.directory</Directory>
		<Include>
			<Category>PiScripts</Category>
		</Include>
		<Menu>
			<Name>WB0SIO</Name>
			<Directory>wb0sio.directory</Directory>
			<Include>
				<Category>wb0sio</Category>
			</Include>
			<Menu>
				<Name>WB0SIO-Conky</Name>
				<Directory>wb0sioconky.directory</Directory>
				<Include>
					<Category>wb0sioconky</Category>
				</Include>
			</Menu>
		</Menu>
	</Menu> <!-- End PiScripts -->
</Menu>
EOF

sudo mv PiScripts.menu /usr/share/extra-xdg-menus/
}

#verify PiScripts menu is installed
if [ ! -f /usr/share/extra-xdg-menus/PiScripts.menu ]; then
	sudo apt install -y extra-xdg-menus
fi

#check to see if this script has already run
if [ "$MENU" = "$REV" ]; then
	REV=$(cat $HOME/.config/WB0SIO | sed 's/MENU=//')
	echo "menu mods already made"
	echo "Revision $REV installed"
	exit
else
	MRB=$(cat $HOME/.config/WB0SIO | grep MENU= | sed 's/MENU=.*$/MENU/')
	if [[ -z ${MRB} ]]; then
		echo "MENU=$REV" >> $HOME/.config/WB0SIO
	else
		sed -i "s/MENU=.*$/MENU=$REV/" $HOME/.config/WB0SIO
	fi
	CREATEMENU
fi



