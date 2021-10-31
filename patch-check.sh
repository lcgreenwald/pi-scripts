#!/bin/bash
#####################################
#	Patch Check
#####################################

#This check first looks at the README.md file to see if the PATCH var is YES.
#If PATCH=YES, then it looks to see if the patches that are available have 
#been applied previously. If so, it skips the patch screen. If not, it gives
#the user an option to install the patch(es).

PATCHCHECK=$(curl -s https://raw.githubusercontent.com/km4ack/pi-build/dev/patch/README.md | grep PATCH= | sed 's/PATCH=//')

if [ ${PATCHCHECK} = "YES" ]; then
#Setup temp directory for BAP patches and download patches
echo "##########################################################"
echo "#Checking for available patches that haven't been applied#"
echo "##########################################################"
cd /run/user/$UID
git init pi-build
cd pi-build
git remote add -f origin https://github.com/km4ack/pi-build.git
git config core.sparseCheckout true
echo "/patch" >> .git/info/sparse-checkout
git pull origin dev

FILES=$(ls -I README.md /run/user/$UID/pi-build/patch)

#check if available patches have already been applied to BAP
for i in $FILES; do

NAME=$(grep PATCHNAME= /run/user/$UID/pi-build/patch/$i | sed 's/PATCHNAME=//')
RB=$(grep $NAME $HOME/.config/patch)
if [ -z $RB ]; then
echo "$NAME" >> /run/user/$UID/avail-patch.txt
fi
done
#end check

	if [ -f /run/user/$UID/avail-patch.txt ]; then
	rm /run/user/$UID/avail-patch.txt

cat <<EOF >${MYPATH}/patch.txt
One or more patch scripts are currently
available for Build a Pi. Full description
of each available patch can be found at
https://github.com/km4ack/pi-build/tree/dev/patch

Would you like to review/apply 
available patch scripts?
EOF

INTRO=$(yad --width=650 --height=300 --text-align=center --center --title="Build-a-Pi Patch Tool" --show-uri \
	--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" --text="Build-a-Pi Patch Tool" \
	--text-info \
	--button="Yes":1 \
	--button="No":2 <${MYPATH}/patch.txt \
	>/dev/null 2>&1)
BUT=$?

		if [ ${BUT} = 252 ]; then
		echo "Button ${BUT} pressed"
		rm ${MYPATH}/patch.txt
		rm -rf /run/user/$UID/pi-build
		exit
		elif [ ${BUT} = 1 ]; then
		echo "Button ${BUT} pressed"
		rm ${MYPATH}/patch.txt
		lxterminal -e bash $HOME/pi-build/patch-menu && exit
		elif [ ${BUT} = 2 ]; then
		echo "Button ${BUT} pressed"
		rm ${MYPATH}/patch.txt
		echo "user declined patch updates continuing with Build a Pi update"
		rm -rf /run/user/$UID/pi-build
		fi
	else
	rm -rf /run/user/$UID/pi-build	
	fi
fi
