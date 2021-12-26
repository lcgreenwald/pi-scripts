#!/bin/bash

###########################################################
# Edit the Weather API Key, Lat, Lon, etc settings for    #
* the conky weather display.                              #
# Created: 2021/11/28 by Larry Greenwald - WB0SIO         #
# Modified:                                               #
#                                                         #
###########################################################

MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
FUNCTIONS=${MYPATH}/functions
LOGO=${MYPATH}/logo.png
VERSION=$(cat ${MYPATH}/changelog | grep version= | sed 's/version=//')
AUTHOR=$(cat ${MYPATH}/changelog | grep author= | sed 's/author=//')
LASTUPDATE=$(cat ${MYPATH}/changelog | grep LastUpdate= | sed 's/LastUpdate=//')
LASTUPDATERUN=$(cat ${HOME}/.config/WB0SIO | grep LastUpdateRun= | sed 's/LastUpdateRun=//')
TODAY=$(date +%Y-%m-%d)
CONFIG=${MYPATH}/config.txt

source ${CONFIG}
WEATHER=$(yad --form --center --width 600 --height 300 --separator="|" --item-separator="|" --title="Weather config" \
  --image ${LOGO} --window-icon=${LOGO} --image-on-top --text-align=center \
  --text "Enter your API Key, Latitude and Longitude below and press Continue." \
  --field="API Key" \
  --field="Latitude":NUM \
  --field="Longitude":NUM \
  --field="Longitude Direction":CB \
  --field="Units":CB \
  "$APIKEY" "$LAT|-90..90|.0001|4" "$LON|-180..180|.0001|4" "W|E" "imperial|metric" \
  --button="Exit":1 \
  --button="Continue":2 )
  BUT=$?
  if [ ${BUT} = 252 ] || [ ${BUT} = 1 ]; then
    CLEANUP
    exit
  fi

  #update settings
  APIKEY=$(echo ${WEATHER} | awk -F "|" '{print $1}')
  LAT=$(echo ${WEATHER} | awk -F "|" '{print $2}')
  LON=$(echo ${WEATHER} | awk -F "|" '{print $3}')
  LONDIR=$(echo ${WEATHER} | awk -F "|" '{print $4}')
  UNITS=$(echo ${WEATHER} | awk -F "|" '{print $5}')

  WRB=$(grep APIKEY ${CONFIG})
  if [ -z ${WRB} ]; then
    echo "APIKEY=$APIKEY" >${CONFIG}
    echo "LAT=$LAT" >>${CONFIG}
    echo "LON=$LON" >>${CONFIG}
    echo "LONDIR=$LONDIR" >>${CONFIG}
    echo "UNITS=$UNITS" >>${CONFIG}
  else
    sudo sed -i "s/^APIKEY=.*$/APIKEY=$APIKEY/" ${CONFIG}
    sudo sed -i "s/^LAT=.*$/LAT=$LAT/" ${CONFIG}
    sudo sed -i "s/^LON=.*$/LON=$LON/" ${CONFIG}
    sudo sed -i "s/^LONDIR=.*$/LONDIR=$LONDIR/" ${CONFIG}
    sudo sed -i "s/^UNITS=.*$/UNITS=$UNITS/" ${CONFIG}
  fi
