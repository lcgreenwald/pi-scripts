#!/bin/bash

#script for a patch system for quick fixes in Pi-Scripts
#KM4ACK 20210805
#WB0SIO 20211031

PATCHDIR=/run/user/${UID}/patch

source $PATCHDIR/avail-patch.txt

       
#####################################
#	PATCH Menu
#####################################
yad --center --list --checklist --width=750 --height=750 --separator="" \
--image ${LOGO} --column=Check --column=App --column=status --column=description --print-column=2 \
--window-icon=${LOGO} --image-on-top --text-align=center \
--text="<b>Patches</b>" --title="Pi-Scripts Install" \
false "hamlib4dot3dot1date20211105" "$hamlib4dot3dot1date20211105" "HamLib update" \
--button="Exit":1 \
--button="Check All and Continue":3 \
--button="Install Selected":2 > ${PATCH}
BUT=$?
if [ $BUT = 252 ] || [ $BUT = 1 ]; then
exit
fi

if [ $BUT = 3 ]; then

PATCHAPPS=(hamlib4dot3dot1date20211105)
for i in "${PATCHAPPS[@]}"
do
echo "$i" >> ${PATCH}
done
fi
       
