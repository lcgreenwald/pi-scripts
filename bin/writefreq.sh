#!/bin/bash

#get freq of radio to display in conky
#optional parameter: VFOA VFOB
#20191217 km4ack
#20200428 modified
#20201022 wb0sio - edited to use rigctl to read the rig frequency.

MAIN () {

FREQ=$(rigctl -m2 f)
FREQCH=$(echo "$FREQ" | grep error)

if [ -z "$FREQCH" ]
then
echo ${FREQ:0:-3}/1000 | bc -l | xargs printf "%.3f ${FREQ: -3}" > /home/pi/bin/conky/Freq.txt
else
MAIN "$1"
fi

}

MAIN