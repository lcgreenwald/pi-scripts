#!/bin/bash

#script to test a patch system for quick fixes in BAP
#KM4ACK 20210805
#WB0SIO 20211031

MYPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
LOGO=${MYPATH}/logo.png
DIR=/run/user/$UID

TEMP=/run/user/$UID/patch.txt
MENU(){
ls -I README.md $DIR/pi-build/patch > $TEMP

INFO=$(PARSER='OFS="\n" {print $1}'
MYTEMP=/run/user/$UID/patch1.txt
tail -10 $TEMP | awk "$PARSER" | \
yad --title="Build a Pi Patch Tool" --width=500 --height=500 \
    --image $LOGO --window-icon=$LOGO --image-on-top --multiple \
    --center --list --text="Select a Patch to Apply" \
    --column "Patch" \
    --button="Exit":1 \
    --button="Apply Patch":2)
BUT=$?


PATCH=$(echo ${INFO} | awk -F "|" '{print $1}')

#cleanup and exit upon user request
if [ ${BUT} = 1 ] || [ ${BUT} = 252 ];then
echo "cleanup and exit Build a Pi patch tool"
rm -rf $TEMP $DIR/pi-build
#send user back to BAP update tool
${MYPATH}/update && exit
fi


#check to verify that a patch has been selected
#Thank Ken, NB6S for catching this bug!
if [ -z $INFO ]; then
	yad --form --width=500 --text-align=center --center --title="Build-a-Pi Patch Tool" --text-align=center \
		--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
		--text="<b>Please select a patch\rand try again.</b>" \
		--button=gtk-close
MENU
fi

#verify patch has not been applied already
PATCHNAME=$(grep PATCHNAME= $DIR/pi-build/patch/${PATCH} | sed 's/PATCHNAME=//')
PATCHCHECK=$(grep ${PATCHNAME} $HOME/.config/patch)

if [ -z $PATCHCHECK ]; then
#apply patch & give user notice that patch has been applied
echo "applying $PATCH"
bash ${DIR}/pi-build/patch/${PATCH}

	yad --form --width=500 --text-align=center --center --title="Build-a-Pi Patch Tool" --text-align=center \
		--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
		--text="<b>${PATCH}</b> patch has been applied" \
		--button=gtk-close



#rm -rf $TEMP $DIR/pi-build
MENU
else
	yad --form --width=500 --text-align=center --center --title="Build-a-Pi Patch Tool" --text-align=center \
		--image ${LOGO} --window-icon=${LOGO} --image-on-top --separator="|" --item-separator="|" \
		--text="<b>$PATCH</b> was applied previously\rNo need to apply again." \
		--button=gtk-close
#rm -rf $TEMP $DIR/pi-build
MENU
exit
fi
}
MENU

