#!/bin/bash
########################
# 2021/01/03 - WB0SIO - Created from KM4ack conky/grid. Added write to file.
# 2021/01/04 - WB0SIO - Added fortune.
########################

GRID=$($HOME/bin/conky/get-grid)
GRIDCH=$(echo $GRID | grep -i JJ00)

if [ -z "$GRIDCH" ]
then
echo $GRID > $HOME/bin/conky/Grid.txt
else
echo "NO GPS" > $HOME/bin/conky/Grid.txt
fi

/usr/games/fortune | fold -s -w55 > /home/pi/bin/conky/fortune.txt
