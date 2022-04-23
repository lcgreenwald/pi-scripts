# pi-scripts
My Raspberry Pi Scripts and programs

# BOINC-FREE

Pi-Scripts and Build-a-Pi have never, and will never, try to force any user to run BOINC (Berkeley Open Infrastructure for Network Computing). Build-a-Pi has always been about giving the end-user a choice in the software they run. It's also the reason Build-a-Pi isn't distrubuted as a pre-built image. You have the final say in what you run on your RPi. Install as little, or as much, as you choose. While it doesn't include as many apps as some of the pre-built images, Build-a-Pi should give you a great base to work with, then you can add additional applications that may be important to you on top. Want to run BOINC? Feel free because freedom is the basis of Build-a-Pi. The power is yours and yours alone.


#To install Pi-Scripts run the following commands:

	cd
	git clone https://github.com/lcgreenwald/pi-scripts.git $HOME/pi-scripts
	bash $HOME/pi-scripts/pi-build-install.sh
  
  For an SSD install without Build-a-Pi run:
	bash $HOME/pi-scripts/pi-scripts-install-ssd.sh


# pi-build-install
This script installs or updates:

	Base Apps:
	DeskPi - DeskPi case software.
	Argon - Argon One m.2 case software.
	X715 - X715 power supply hat utilities.
	log2ram - Save logs to ram to reduce wear on your SD card.
	ZramSwap - Create a RAM based swap file to improve system response.
	locate - File find/locate program.
	samba - SMB server to share files/folders with Windows machines.
	webmin - Web based computer/configuration manager.
	3.5" display drivers.
	disks - gnome disk utility.
	pi imager - Raspberry Pi Imager
	Neofetch - Display Linux system Information In a Terminal.
	CommanderPi - Easy RaspberryPi4 GUI system managment.
	RPiMonitor - Display Linux system Information in a web browser.
	Fortune - Random quotes.
	PiSafe - Backup or Restore Raspberry Pi devices.  Creates a compressed image of SD or SSD drives.
	nmon - Linux performance monitor.
	Weather - Display weather conditions and forecast.
  Screensaver - X Screensavers
  Timeshift - Linux system backup utility.
  Piapps - The most popular app store for Raspberry Pi computers.
        
	Ham Radio Apps:
	cqrprop - Propagation prediction.
	JS8map - Map to show location of JS8Call contacts.
  PythonGPS - Use Python to show the grid square in Conky
  
  Additional customised Conky files

You may also optionally install these programs.  This portion of the install is derived from
  the KM4ACK Build-A-Pi scripts.

# Available Apps to Install

#### RTC | Real Time Clock
Software for DS3231 real-time clock (Available through update script after initial install)

#### HOTSPOT:
Hotspot is used to generate a wifi hotspot that you can connect-to with other wireless devices. This is useful in the field, so you can connect-to and contol the RPi from a wireless device.

If enabled, the hotspot will only activate _IF_ the RPi is not already connected to a wireless network.  The hotspot will either activate at bootup, _OR_ a maximum of 5 minutes AFTER you have forcefully disconnected from a wireless network. You can tune that detection delay in the settings.
The hotspot default SSID is *RpiHotspot* and the default IP address of the Pi is 10.10.10.10.
(Make sure to enable either VNC or SSH server to remotely connect to your RPi at that address!)

#### Hotspot Tools:
Hotspot tools is a collection of tools designed to make managing the hotspot easier through a GUI interface. https://youtu.be/O_eihSN_ES8
  !!! - WB0SIO - A modified version of Hotspot Tools is installed which allows you to easily edit the HotSpot IP address.

#### GPS:
This will install the needed utilities to get a GPS device configured as a time source on the RPi. Helpful when you are not connected to the Internet since the RPi doesn't have a real-time clock (RTC) and therefore will _NOT_ keep accurate time when powered-off. Confirmed to work with this GPS: https://amzn.to/2R9Muup Other GPS units may work, but have not been tested.

#### FLRIG:
Rig contol graphical interface. http://www.w1hkj.com/

#### FLDIGI:
Digital Mode Software http://www.w1hkj.com/

#### FLMSG:
Forms manager for FLDIGI http://www.w1hkj.com/

#### FLAMP:
Amateur Multicast Protocol - file transfer program http://www.w1hkj.com/

#### FLWRAP
File encapsulation & compression

#### PAT:
Winlink client for Raspberry Pi https://getpat.io/

#### PATMENU:
Menu for configuring Pat. Recommended if installing Pat. https://github.com/km4ack/patmenu

#### ARDOPC:
HF modem for Pat. Recommended if installing Pat. https://www.cantab.net/users/john.wiseman/Documents/ARDOPC.html

#### ARDOPGUI:
GUI interface for ARDOPC. Recommended if installing Pat.

#### DIREWOLF:
Software TNC. In this setup, Direwolf is used for a 2M packet connection with Pat, and can be used for APRS connection with Xastir. Recommended if installing Pat or Xastir. https://github.com/wb2osz/direwolf/tree/master/doc

#### AX25:
AX.25 tools for Direwolf & Pat. Recommended if installing Pat. 

#### HAMLIB:
Rig contol software. https://sourceforge.net/projects/hamlib/

#### PULSE:
Pulse audio. Provides a way to configure virtual sound cards. REQUIRED for AMRRON ops.
(Get involved! https://amrron.com)

#### JS8:
JS8Call digital software. https://js8call.com

#### M0IAX:
Tools for working with JS8Call. Recommended if installing JS8Call. https://github.com/m0iax/

#### WSJTX:
FT8 & WISPR software suite. https://sourceforge.net/projects/wsjt/

#### CHIRP:
Software to program radios. https://chirp.danplanet.com

#### XASTIR:
GUI interface useful when configuring APRS nodes. https://sourceforge.net/projects/xastir/

#### YAAC:
Yet Another APRS Client GUI interface useful when configuring APRS nodes. https://www.ka2ddo.org/ka2ddo/YAAC.html

#### PYQSO:
Logging software. https://github.com/ctjacobs/pyqso

#### GPREDICT:
Satellite Tracking. http://gpredict.oz9aec.net/

#### CQRLOG:
Logging Software. https://www.cqrlog.com/

#### QSSTV:
Slow-scan TV (SSTV). http://users.telenet.be/on4qz/qsstv/index.html

#### Gridtracker 
https://tagloomis.com/

#### Propagation (VOACAP)
Propagation Prediction Software. https://www.qsl.net/hz1jw/voacapl/index.html

#### Emergency Email Server (EES):
My personal EES. Requires hotspot to be installed. https://youtu.be/XC9vdAnolO0
\
To access the EES, connect to the pi's hotspot, open a web browser, and navigate to email.com\
or open a web browser and navigate to the pi's ip adderss on your local network.\
Admin credentials are admin/admin by default but can be changed in the file found at\
/var/www/html/config.php \
For more configuration options - https://youtu.be/KaEeCq50Mno

#### Call Sign Lookup
Amateur radio call-sign lookup.

#### Dipole Calculator
Calculate lengths needed for dipole legs.

#### Log Viewer
Graphic viewer to view/manage log files.

#### Gparted
Disk utility.
 
 
 
 
 
 
 
 

 

# K4CPO-FD-Logger

This script downloads and installs a version of K4CPO-FD-Logger customized for N0SUW/WB0SIO.
It also includes some page navigation updates.

Run the following command for the initial installation

	bash $HOME/pi-scripts/fd-logger-install.sh

Run the following command to update K4CPO-FD-Logger

	bash $HOME/pi-scripts/fd-logger-update.sh
	
