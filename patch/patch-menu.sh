#!/bin/bash

#script to test a patch system for quick fixes in Pi-Scripts
#KM4ACK 20210805
#WB0SIO 20211031

#MYPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
#LOGO=${MYPATH}/logo.png
#DIR=/run/user/$UID
#PATCH=${MYPATH}/patch.txt
PATCHDIR=/run/user/${UID}/patch

source $PATCHDIR/avail-patch.txt

MENU(){
        
#####################################
#	PATCH Menu
#####################################
yad --center --list --checklist --width=700 --height=750 --separator="" \
--image ${LOGO} --column=Check --column=App --column=Description \
--print-column=2 --window-icon=${LOGO} --image-on-top --text-align=center \
--text="<b>Patches</b>" --title="Pi-Scripts Install" \
false "test-patch20211015" "$test-patch20211015" "A small test application" \
false "test-patch20211020" "$test-patch20211020" "Another small test application" \
--button="Exit":1 \
--button="Check All and Continue":3 \
--button="Install Selected":2 > ${PATCH}
BUT=$?
if [ $BUT = 252 ] || [ $BUT = 1 ]; then
exit
fi

if [ $BUT = 3 ]; then

PATCHAPPS=(test-patch20211015 test-patch20211020)
for i in "${PATCHAPPS[@]}"
do
echo "$i" >> ${PATCH}
done
fi
       
        
        

}
MENU
