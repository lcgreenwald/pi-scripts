#!/bin/bash

##############################
# Full credit to Alex Fleak (KD0YTE) for the idea for this script. 
# as it is based on his original work posted on the BAP forum
# https://groups.io/g/KM4ACK-Pi/topic/adding_solar_flux_and_a_index/78788335?p=,,,20,0,0,0::recentpostdate%2Fsticky,,,20,2,0,78788335
# and updated by G.A.(Jerry) Minor N5RKE
# modified 2020/12/16 - Larry Greenwald WB0SIO - Added muf
#          2020/12/26 - Larry Greenwald WB0SIO - Per www.hamqsl.com data is updated every 30 minutes
##############################

cd ~/bin/conky/solardata || exit 1

# Stop if one of the output files exist and is newer than 30 minutes
if [[ -r s-flux.txt && $(( $(date +%s) - $(stat -c "%Y" s-flux.txt) )) -lt 1800 ]]
then
    exit 0
fi

wget -N --quiet http://www.hamqsl.com/solarrss.php

sed -n -r -e 's!^.*<solarflux>(.*)</solarflux>.*$!\1!p' solarrss.php > s-flux.txt
sed -n -r -e 's!^.*<aindex>(.*)</aindex>.*$!\1!p' solarrss.php > a-index.txt
sed -n -r -e 's!^.*<kindex>(.*)</kindex>.*$!\1!p' solarrss.php > k-index.txt
sed -n -r -e 's!^.*<sunspots>(.*)</sunspots>.*$!\1!p' solarrss.php > sunspots.txt
sed -n -r -e 's!^.*<muf>(.*)</muf>.*$!\1!p' solarrss.php > muf.txt
sed -n -r -e 's!^.*<band name="80m-40m" time="day">(.*)</band>.*$!\1!p' solarrss.php > band80-40day.txt
sed -n -r -e 's!^.*<band name="30m-20m" time="day">(.*)</band>.*$!\1!p' solarrss.php > band30-20day.txt
sed -n -r -e 's!^.*<band name="17m-15m" time="day">(.*)</band>.*$!\1!p' solarrss.php > band17-15day.txt
sed -n -r -e 's!^.*<band name="12m-10m" time="day">(.*)</band>.*$!\1!p' solarrss.php > band12-10day.txt
sed -n -r -e 's!^.*<band name="80m-40m" time="night">(.*)</band>.*$!\1!p' solarrss.php > band80-40night.txt
sed -n -r -e 's!^.*<band name="30m-20m" time="night">(.*)</band>.*$!\1!p' solarrss.php > band30-20night.txt
sed -n -r -e 's!^.*<band name="17m-15m" time="night">(.*)</band>.*$!\1!p' solarrss.php > band17-15night.txt
sed -n -r -e 's!^.*<band name="12m-10m" time="night">(.*)</band>.*$!\1!p' solarrss.php > band12-10night.txt

rm solarrss.php
cd
