#!/bin/bash

#this script used to check for apps that need updates

BAPUPDATEFILE=/run/user/$UID/bapupdate.txt

#Delete file if exist
if [ -f $BAPUPDATEFILE ]; then
rm $BAPUPDATEFILE
fi
#create new file
touch $BAPUPDATEFILE

BAPCHECK() {
	#----------------------------------------------------#
	#		Hotspot
	#----------------------------------------------------#
	HOTSPOT="/usr/bin/autohotspotN"
	if [ ! -f "$HOTSPOT" ]; then
		echo "HOTSPOT=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "HOTSPOT=Installed" >> $BAPUPDATEFILE
	fi

	#remove duplicate HST check

	#----------------------------------------------------#
	#		AX25
	#----------------------------------------------------#
	if [ ! -d /etc/ax25 ]; then
		echo "AX25=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "AX25=Installed" >> $BAPUPDATEFILE
	fi
	#----------------------------------------------------#
	#		GPS
	#----------------------------------------------------#
	if ! hash gpsd 2>/dev/null; then
		echo "GPS=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "GPS=Installed" >> $BAPUPDATEFILE
	fi
	#----------------------------------------------------#
	#		PULSE
	#----------------------------------------------------#
	if ! hash pavucontrol 2>/dev/null; then
		echo "PULSE=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "PULSE=Installed" >> $BAPUPDATEFILE
	fi
	#----------------------------------------------------#
	#		ARDOP
	#----------------------------------------------------#
	if [ -f ${HOME}/ardop/piardopc ]; then
		echo "ARDOP=Installed" >> $BAPUPDATEFILE
	else
		echo "ARDOP=Not_Installed" >> $BAPUPDATEFILE
	fi
	#----------------------------------------------------#
	#		ARDOP GUI
	#----------------------------------------------------#
	if [ -f ${HOME}/ardop/piARDOP_GUI ]; then
		echo "ARDOPGUI=Installed" >> $BAPUPDATEFILE
	else
		echo "ARDOPGUI=Not_Installed" >> $BAPUPDATEFILE
	fi
	#----------------------------------------------------#
	#		JS8Call
	#----------------------------------------------------#
	if ! hash js8call 2>/dev/null; then
		echo "JS8=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "JS8=Installed" >> $BAPUPDATEFILE
	fi
	#----------------------------------------------------#
	#		WSJTX
	#----------------------------------------------------#
	if ! hash wsjtx 2>/dev/null; then
		echo "FT8=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "FT8=Installed" >> $BAPUPDATEFILE
	fi
	#----------------------------------------------------#
	#		CONKY
	#----------------------------------------------------#
	if [ -f ${HOME}/.conkyrc ]; then
		echo "CONKY=Installed" >> $BAPUPDATEFILE
	else
		echo "CONKY=Not_Installed" >> $BAPUPDATEFILE
	fi
	#----------------------------------------------------#
	#		M0IAX
	#----------------------------------------------------#
	if [ -f /usr/local/bin/JS8CallUtils_v2 ]; then
		echo "M0IAX=Installed" >> $BAPUPDATEFILE
	else
		echo "M0IAX=Not_Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		RIG CONTROL - HAMLIB
	#----------------------------------------------------#
	if ! hash rigctl 2>/dev/null; then
		echo "RIG=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "Checking Rig Control"
		RIG=$(rigctl --version | grep Hamlib | sed s/"rigctl(d),\ Hamlib\ "//)
		NEWRIG=$(curl -s https://sourceforge.net/projects/hamlib/files/latest/download |
			grep -o https://downloads.sourceforge.net/project/hamlib/hamlib/[0-9].[0-9] |
			head -n 1 | awk -F "/" '{print $7}')

		if (($(echo "${NEWRIG} ${RIG}" | awk '{print ($1 > $2)}'))); then
			echo "RIG=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "RIG=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi

	#----------------------------------------------------#
	#			FLDIGI
	#----------------------------------------------------#
	echo "Checking FLDIGI"
	if ! hash fldigi 2>/dev/null; then
		echo "FLDIGI=Not_Installed" >> $BAPUPDATEFILE
	else
		FLDIGI=$(fldigi --version | awk 'FNR == 1 {print $2}')
		NEWFLDIGI=$(curl -s https://sourceforge.net/projects/fldigi/files/fldigi/ |
			grep .tar.gz | head -1 | awk -F "-" '{print $2}' | awk -F ".tar" '{print $1}')

		if (($(echo "${NEWFLDIGI} ${FLDIGI}" | awk '{print ($1 > $2)}'))); then
			echo "FLDIGI=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "FLDIGI=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi

	#----------------------------------------------------#
	#			FLWRAP
	#----------------------------------------------------#
	echo "Checking FLWRAP"
	if ! hash flwrap 2>/dev/null; then
		echo "FLWRAP=Not_Installed" >> $BAPUPDATEFILE
	else
		FLWRAP=$(flwrap --version | awk 'FNR == 1 {print $2}')
		NEWFLWRAP=$(curl -s http://www.w1hkj.com/files/flwrap/ | grep .tar.gz | sed 's/<li><a\ href="//' |
			sed 's/">\ flwrap.*$//' | sed 's/flwrap-//' | sed 's/.tar.gz//')

		if (($(echo "${NEWFLWRAP} ${FLWRAP}" | awk '{print ($1 > $2)}'))); then
			echo "FLWRAP=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "FLWRAP=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi

	#----------------------------------------------------#
	#			FLRIG
	#----------------------------------------------------#
	echo "Checking FLRIG"
	if ! hash flrig 2>/dev/null; then
		echo "FLRIG=Not_Installed" >> $BAPUPDATEFILE
	else
		FLRIG=$(flrig --version | awk 'FNR == 1 {print $2}')
		NEWFLRIG=$(curl -s https://sourceforge.net/projects/fldigi/files/flrig/ |
			grep .tar.gz | head -1 | awk -F "-" '{print $2}' | awk -F ".tar.gz" '{print $1}')

		if (($(echo "${NEWFLRIG} ${FLRIG}" | awk '{print ($1 > $2)}'))); then
			echo "FLRIG=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "FLRIG=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi
	#----------------------------------------------------#
	#			FLAMP
	#----------------------------------------------------#
	echo "Checking FLAMP"
	if ! hash flamp 2>/dev/null; then
		echo "FLAMP=Not_Installed" >> $BAPUPDATEFILE
	else
		FLAMP=$(flamp --version | awk 'FNR == 1 {print $2}')
		NEWFLAMP=$(curl -s https://sourceforge.net/projects/fldigi/files/flamp/ |
			grep .tar.gz | head -1 | awk -F "-" '{print $2}' | awk -F ".tar.gz" '{print $1}')

		if (($(echo "${NEWFLAMP} ${FLAMP}" | awk '{print ($1 > $2)}'))); then
			echo "FLAMP=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "FLAMP=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi
	#----------------------------------------------------#
	#			FLMSG
	#----------------------------------------------------#
	echo "Checking FLMSG"
	if ! hash flmsg 2>/dev/null; then
		echo "FLMSG=Not_Installed" >> $BAPUPDATEFILE
	else
		FLMSG=$(flmsg --version | awk 'FNR == 1 {print $2}')
		NEWFLMSG=$(curl -s https://sourceforge.net/projects/fldigi/files/flmsg/ |
			grep .tar.gz | head -1 | awk -F "-" '{print $2}' | awk -F ".tar.gz" '{print $1}')

		if (($(echo "${NEWFLMSG} ${FLMSG}" | awk '{print ($1 > $2)}'))); then
			echo "FLMSG=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "FLMSG=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi
	#----------------------------------------------------#
	#			FLNET
	#----------------------------------------------------#
	echo "Checking FLNET"
	if ! hash flnet 2>/dev/null; then
		echo "FLNET=Not_Installed" >> $BAPUPDATEFILE
	else
		FLNET=$(flnet --version | awk 'FNR == 1 {print $2}')
		NEWFLNET=$(curl -s https://sourceforge.net/projects/fldigi/files/flnet/ |
			grep .tar.gz | head -1 | awk -F "-" '{print $2}' | awk -F ".tar" '{print $1}')

		if (($(echo "${NEWFLNET} ${FLNET}" | awk '{print ($1 > $2)}'))); then
			echo "FLNET=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "FLNET=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi
	#----------------------------------------------------#
	#		Pat Winlink
	#----------------------------------------------------#
	echo "Checking Pat Winlink"
	if ! hash pat 2>/dev/null; then
		echo "PAT=Not_Installed" >> $BAPUPDATEFILE
	else
		PAT=$(pat version | awk '{print $2}' | sed 's/v//' | sed 's/0\.//')
		NEWPATV=$(curl -s https://github.com/la5nta/pat/releases | grep armhf | head -1 | sed 's/.*pat_/pat_/' | sed 's/<\/a>.*$//')
		NEWPAT=$(echo ${NEWPATV} | sed 's/pat_//' | sed 's/_linux_armhf.deb//' | sed 's/0\.//')
		VERTEST=$(echo "${NEWPAT}>${PAT}" | bc)

		if [ "$VERTEST" = 1 ]; then
			echo "PAT=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "PAT=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi
	#----------------------------------------------------#
	#		CHRIP
	#----------------------------------------------------#
	echo "Checking Chirp"
	if ! hash chirpw 2>/dev/null; then
		echo "CHIRP=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "CHIRP=Installed" >> $BAPUPDATEFILE
	fi
	OLDCODE(){
	#old code left for reference
	if ! hash chirpw 2>/dev/null; then
		echo "CHIRP=Not_Installed" >> $BAPUPDATEFILE
	else
		CP=$(chirpw --version)
		CHIRP=$(echo ${CP} | awk '{ print $2 }' | sed 's/daily-//')
		NEWCHIRP=$(curl -s https://trac.chirp.danplanet.com/chirp_daily/LATEST/ |
			grep .tar.gz | awk -F 'chirp-daily-' '{print $2}' | head -c 8)

		if (($(echo "${NEWCHIRP} ${CHIRP}" | awk '{print ($1 > $2)}'))); then
			echo "CHIRP=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "CHIRP=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi
	}
	#----------------------------------------------------#
	#		DIREWOLF
	#----------------------------------------------------#
	echo "Checking Direwolf"
	if ! hash direwolf 2>/dev/null; then
		echo "DIRE=Not_Installed" >> $BAPUPDATEFILE
	else
		DIRE=$(direwolf -S -t 0 | head -1 | sed 's/Dire\ Wolf\ version\ //')
		wget -P /tmp/ https://raw.githubusercontent.com/wb2osz/direwolf/master/CHANGES.md >/dev/null 2>&1
		NEWDIRE=$(cat /tmp/CHANGES.md | head -5 | tail -1 | awk '{ print $3 }')

		if (($(echo "${NEWDIRE} ${DIRE}" | awk '{print ($1 > $2)}'))); then
			echo "DIRE=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "DIRE=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi
	#----------------------------------------------------#
	#		Pat Menu
	#----------------------------------------------------#
	echo "Checking Pat Menu"
	if [ ! -d ${HOME}/patmenu2 ]; then
		echo "PATMENU=Not_Installed" >> $BAPUPDATEFILE
	else
		cd ${HOME}/patmenu2/ || ! echo "Failure"
		wget -O ${HOME}/patmenu2/latest https://raw.githubusercontent.com/km4ack/patmenu2/master/changelog >/dev/null 2>&1
		LATEST=$(cat ${HOME}/patmenu2/latest | grep '^release' | sed 's/release=//')
		CURRENT=$(cat ${HOME}/patmenu2/changelog | grep '^release' | sed 's/release=//')
		rm ${HOME}/patmenu2/latest >/dev/null 2>&1
		if (($(echo "${LATEST} ${CURRENT}" | awk '{print ($1 > $2)}'))); then
			echo "PATMENU=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "PATMENU=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi

	#----------------------------------------------------#
	#		Hot Spot Tools
	#----------------------------------------------------#
	if [ ! -d ${HOME}/hotspot-tools2 ]; then
		echo "HSTOOLS=Not_Installed" >> $BAPUPDATEFILE
	else
		CURRENT=$(cat ${HOME}/hotspot-tools2/changelog | grep version= | sed 's/version=//')
		LATEST=$(curl -s https://raw.githubusercontent.com/km4ack/hotspot-tools2/master/changelog | grep version= | sed 's/version=//')
		if (($(echo "${LATEST} ${CURRENT}" | awk '{print ($1 > $2)}'))); then
			echo "HSTOOLS=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "HSTOOLS=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi

	#----------------------------------------------------#
	#			GARIM
	#----------------------------------------------------#
	echo "Checking GARIM"
	if ! hash garim 2>/dev/null; then
		echo "GARIM=Not_Installed" >> $BAPUPDATEFILE
	else
		GARIM=$(garim --version | head -n1 | awk -F ' ' '{print $2}')
		NEWGARIM=$(curl -s https://www.whitemesa.net/garim/garim.html | grep -m 1 \
			"armv7l.tar.gz" | awk -F '-' '{print $2}')
		if (($(echo "${NEWGARIM} ${GARIM}" | awk '{print ($1 > $2)}'))); then
			echo "GARIM=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "GARIM=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi

	#----------------------------------------------------#
	#		XASTIR
	#----------------------------------------------------#
	echo "Checking Xastir"
	if ! hash xastir 2>/dev/null; then
	echo "XASTIR=Not_Installed" >> $BAPUPDATEFILE
	else
	LATESTXAS=$(curl -s https://github.com/Xastir/Xastir | grep Release- | head -1 | sed 's/.*Release-//;s/">//')
	CURRENTXAS=$(xastir -V | sed 's/Xastir V//;s/(.*//;/^\s*$/d')

		if (($(echo "${LATESTXAS} ${CURRENTXAS}" | awk '{print ($1 > $2)}'))); then
			echo "XASTIR=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "XASTIR=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi

	#----------------------------------------------------#
	#		YAAC
	#----------------------------------------------------#
	YAAC="${HOME}/YAAC"
	echo "Checking YAAC for updates"
	if [ ! -d "$YAAC" ]; then
		echo "YAAC=Not_Installed" >> $BAPUPDATEFILE
	else

		CURYAAC=$(java -jar ${HOME}/YAAC/YAAC.jar -version | grep beta | sed 's/.*beta//;s/(.*//')
		wget -q https://sourceforge.net/projects/yetanotheraprsc/files/YAACBuildLabel.txt -O /run/user/${UID}/latestyaac.txt
		LATESTYAAC=$(cat /run/user/${UID}/latestyaac.txt | sed 's/1.0-beta//;s/(.*//')
		if (($(echo "${LATESTYAAC} ${CURYAAC}" | awk '{print ($1 > $2)}'))); then
			echo "YAAC=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "YAAC=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi

	#----------------------------------------------------#
	#		PYQSO
	#----------------------------------------------------#
	if ! hash pyqso 2>/dev/null; then
		echo "PYQSO=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "PYQSO=Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		QSSTV
	#----------------------------------------------------#
	if ! hash qsstv 2>/dev/null; then
		echo "QSSTV=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "QSSTV=Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		GRIDTRACKER
	#----------------------------------------------------#
	GT="${HOME}/GridTracker"
	if [ ! -d "$GT" ]; then
		echo "GRIDTRACK=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "GRIDTRACK=Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		PROPAGATION
	#----------------------------------------------------#
	if ! hash voacapl 2>/dev/null; then
		echo "PROP=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "PROP=Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		CQRLOG
	#----------------------------------------------------#
	if ! hash cqrlog 2>/dev/null; then
		echo "CQRLOG=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "CQRLOG=Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		EES
	#----------------------------------------------------#
	if [ -f /var/www/html/email.php ]; then
		echo "EES=Installed" >> $BAPUPDATEFILE
	else
		echo "EES=Not_Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		Pi-APRS
	#----------------------------------------------------#
	if [ -d ${HOME}/Pi-APRS ]; then
		echo "PIAPRS=Installed" >> $BAPUPDATEFILE
	else
		echo "PIAPRS=Not_Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		Temp Convert
	#----------------------------------------------------#
	if [ -f ${HOME}/bin/converttemp ]; then
		echo "TEMPCONVERT=Installed" >> $BAPUPDATEFILE
	else
		echo "TEMPCONVERT=Not_Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		GPARTED
	#----------------------------------------------------#
	if ! hash gparted 2>/dev/null; then
		echo "GPARTED=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "GPARTED=Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		DIPOLE CALCULATOR
	#----------------------------------------------------#
	if [ -f ${HOME}/bin/dipole ]; then
		echo "DIPOLE=Installed" >> $BAPUPDATEFILE
	else
		echo "DIPOLE=Not_Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		SHOWLOG | Log file viewer
	#----------------------------------------------------#
	if [ -f ${HOME}/bin/showlog ]; then
		echo "SHOWLOG=Installed" >> $BAPUPDATEFILE
	else
		echo "SHOWLOG=Not_Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		Call Sign Lookup GETCALL
	#----------------------------------------------------#
	if [ -f ${HOME}/bin/getcall ]; then
		echo "CALLSIGN=Installed" >> $BAPUPDATEFILE
	else
		echo "CALLSIGN=Not_Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		HamClock
	#----------------------------------------------------#
	HAMCLOCK=$(ls /usr/local/bin | grep hamclock)
	if [ -n "$HAMCLOCK" ]; then
		echo "HAMCLOCK=Installed" >> $BAPUPDATEFILE
	else
		echo "HAMCLOCK=Not_Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		Real Time Clock
	#----------------------------------------------------#
	echo "RTC=Unknown" >> $BAPUPDATEFILE

	#----------------------------------------------------#
	#		Gpredict
	#----------------------------------------------------#
	if ! hash gpredict 2>/dev/null; then
		echo "GPREDICT=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "GPREDICT=Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		TQSL
	#----------------------------------------------------#
	if ! hash tqsl 2>/dev/null; then
		echo "TQSL=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "TQSL=Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		PISTATS
	#----------------------------------------------------#
	if ! hash pistats 2>/dev/null; then
		echo "PISTATS=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "PISTATS=Installed" >> $BAPUPDATEFILE
	fi

	#----------------------------------------------------#
	#		XLOG CHECK
	#----------------------------------------------------#
	if ! hash xlog 2>/dev/null; then
		echo "XLOG=Not_Installed" >> $BAPUPDATEFILE
	else

		XLOGCUR=$(xlog -version | sed 's/xlog\ version\ //')

		XLOGLATEST=$(curl -s https://download.savannah.nongnu.org/releases/xlog/ |
			grep "2.[0-9].[0-9][0-9].tar" | sort | tail -1 | sed 's/.*xlog/xlog/' | sed 's/.sig.*$//' |
			sed 's/xlog-//' | sed 's/.tar.gz//')

		if (($(echo "${XLOGLATEST} ${XLOGCUR}" | awk '{print ($1 > $2)}'))); then
			echo "XLOG=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "XLOG=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi

	#----------------------------------------------------#
	#		JTDX
	#----------------------------------------------------#
	if ! hash jtdx 2>/dev/null; then
		echo "JTDX=Not_Installed" >> $BAPUPDATEFILE
	else
		echo "JTDX=Installed" >> $BAPUPDATEFILE
	fi

}

#----------------------------------------------------#
#		TELNET
#----------------------------------------------------#
if ! hash telnet 2>/dev/null; then
	echo "TEL=Not_Installed" >> $BAPUPDATEFILE
else
	echo "TEL=Installed" >> $BAPUPDATEFILE
fi

#----------------------------------------------------#
#		piQtTermTCP
#----------------------------------------------------#
if [ -f /usr/local/bin/piQtTermTCP ]; then
	echo "PITERM=Installed" >> $BAPUPDATEFILE
else
	echo "PITERM=Not_Installed" >> $BAPUPDATEFILE
fi

#----------------------------------------------------#
#		Security Tools
#----------------------------------------------------#
if [ -f /usr/local/bin/securefile ]; then
	echo "SECURITY=Installed" >> $BAPUPDATEFILE
else
	echo "SECURITY=Not_Installed" >> $BAPUPDATEFILE
fi

#----------------------------------------------------#
#		YGATE
#----------------------------------------------------#
YGATE="${HOME}/bin/ygate.py"
if [ ! -f "$YGATE" ]; then
	echo "YGATE=Not_Installed" >> $BAPUPDATEFILE
else
	echo "YGATE=Installed" >> $BAPUPDATEFILE
fi

#----------------------------------------------------#
#		BPQ
#----------------------------------------------------#
BPQ="${HOME}/linbpq/linbpq"
if [ ! -f "$BPQ" ]; then
	echo "BPQ=Not_Installed" >> $BAPUPDATEFILE
else
	echo "BPQ=Installed" >> $BAPUPDATEFILE
fi

#----------------------------------------------------#
#		Battery Test Script :: BATT
#----------------------------------------------------#
BATT="${HOME}/bin/batt-test"
if [ ! -f "$BATT" ]; then
	echo "BATT=Not_Installed" >> $BAPUPDATEFILE
else
	echo "BATT=Installed" >> $BAPUPDATEFILE
fi

#----------------------------------------------------#
#		VNC Viewer
#----------------------------------------------------#
if ! hash vncviewer 2>/dev/null; then
	echo "VNC=Not_Installed" >> $BAPUPDATEFILE
else
	echo "VNC=Installed" >> $BAPUPDATEFILE
fi

#----------------------------------------------------#
#		XYGRIB Viewer
#----------------------------------------------------#
if [ -f /usr/bin/XyGrib ]; then
	echo "XYGRIB=Installed" >> $BAPUPDATEFILE
else
	echo "XYGRIB=Not_Installed" >> $BAPUPDATEFILE
fi

#----------------------------------------------------#
#		GPS UPDATE TOOL
#----------------------------------------------------#
echo "Checking GPS Update Tool"
if [ ! -f ${HOME}/bin/gpsupdate ]; then
	echo "GPSUPDATE=Not_Installed" >> $BAPUPDATEFILE
else
	GPSUPDATE=$(grep VERSION= ${HOME}/bin/gpsupdate | sed 's/VERSION=//')
	NEWGPSUPDATE=$(curl -s https://raw.githubusercontent.com/km4ack/pi-scripts/master/gpsupdate | grep VERSION= | sed 's/VERSION=//')
	if (($(echo "${NEWGPSUPDATE} ${GPSUPDATE}" | awk '{print ($1 > $2)}'))); then
		echo "GPSUPDATE=NEEDS-UPDATE" >> $BAPUPDATEFILE
	else
		echo "GPSUPDATE=is_latest_version" >> $BAPUPDATEFILE
	fi
fi

#----------------------------------------------------#
#		Grid Calc
#----------------------------------------------------#
echo "Checking Grid Calc"
if [ ! -f $HOME/bin/grid-calc ]; then
	echo "GRIDCALC=Not_Installed" >> $BAPUPDATEFILE
else
	CURRENT=$(grep VERSION $HOME/bin/grid-calc | head -1 | sed 's/VERSION=//')
	LATEST=$(curl -s https://raw.githubusercontent.com/km4ack/pi-scripts/master/grid-calc | grep VERSION | head -1 | sed 's/VERSION=//')
		if (($(echo "${LATEST} ${CURRENT}" | awk '{print ($1 > $2)}'))); then
		echo "GRIDCALC=NEEDS-UPDATE" >> $BAPUPDATEFILE
	else
		echo "GRIDCALC=is_latest_version" >> $BAPUPDATEFILE
	fi
fi

#----------------------------------------------------#
#		HAMRS
#----------------------------------------------------#
if [ ! -f /usr/local/bin/hamrs ]; then
	echo "HAMRS=Not_Installed" >> $BAPUPDATEFILE
else
echo "HAMRS=Installed" >> $BAPUPDATEFILE
fi

#----------------------------------------------------#
#			PacketSearch
#----------------------------------------------------#
echo "Checking Packet Search"
	if [ ! -f $HOME/bin/packetsearch ]; then
		echo "PACKETSEARCH=Not_Installed" >> $BAPUPDATEFILE
	else
		PACKETSEARCH=$(grep VERSION $HOME/bin/packetsearch | sed 's/VERSION=//')
		NEWPACKETSEARCH=$(curl -s https://raw.githubusercontent.com/km4ack/pi-scripts/master/packetsearch | grep VERSION | sed 's/VERSION=//')

		if (($(echo "${NEWFLNET} ${FLNET}" | awk '{print ($1 > $2)}'))); then
			echo "PACKETSEARCH=NEEDS-UPDATE" >> $BAPUPDATEFILE
		else
			echo "PACKETSEARCH=is_latest_version" >> $BAPUPDATEFILE
		fi
	fi

	#----------------------------------------------------#
	#		piQtSoundModem
	#----------------------------------------------------#
	if [ -f /usr/local/bin/piQtSoundModem ]; then
		echo "QTSOUND=Installed" >> $BAPUPDATEFILE
	else
		echo "QTSOUND=Not_Installed" >> $BAPUPDATEFILE
	fi

BAPCHECK
