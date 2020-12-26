#!/bin/bash
#this script downloads the latest solar data image
#for use in conky. It should be run by cron once
#per hour
#10DEC2020 KM4ACK
##############################
# modified 2020/12/26 - Larry Greenwald WB0SIO - Per www.hamqsl.com data is updated every 30 minutes
##############################

cd ~/bin/conky/solardata || exit 1

# Stop if one of the output files exist and is newer than 30 minutes
if [[ -r s-flux.txt && $(( $(date +%s) - $(stat -c "%Y" solarpich.gif) )) -lt 1800 ]]
then
    exit 0
fi

wget http://www.hamqsl.com/solarpich.php
mv solarpich.php solarpich.gif
wget http://www.hamqsl.com/solarmuf.php
mv solarmuf.php solarmuf.gif
wget http://www.hamqsl.com/solar101vhfpic.php
mv solar101vhfpic.php solar101vhfpic.gif
