# pi-scripts
My Raspberry Pi Scripts and programs

# pi-build-install
This script installs or updates:

km4ack build-a-pi
	Optionally select Current, Master, Beta or Dev
          Current will execute git pull for the current branch. Current is only available in Update.
          Master, Beta or Dev will change to the requested branch and execute git pull. 

km4ack hotspot tools customized to allow editing the hotspot IP address

Additional customised Conky files

You may also optionally install:

	DeskPi - DeskPi case software
	Argon - Argon One m.2 case software
	X715 - X715 power supply hat utilities
	log2ram - Save logs to ram to reduce wear on your SD card.
        ZramSwap - Create a RAM based swap file to improve system response.
	locate - File find/locate program
	samba - SMB server to share files/folders with Windows machines
	webmin - Web based computer/configuration manager
	cqrprop - Propagation prediction 
	3.5" display drivers
	disks - gnome disk utility
	pi imager - Raspberry Pi Imager
	Neofetch - Display Linux system Information In a Terminal
	CommanderPi - Easy RaspberryPi4 GUI system managment
	RPiMonitor - Display Linux system Information in a web browser
	Fortune - Random quotes
	PiSafe - Backup or Restore Raspberry Pi devices.  Creates a compressed image of SD or SSD drives.
	JS8map - Map to show location of JS8Call contacts

Run the following commands

	cd
	git clone https://github.com/lcgreenwald/pi-scripts.git $HOME/pi-scripts
	bash $HOME/pi-scripts/pi-build-install.sh


# K4CPO-FD-Logger

This script downloads and installs a version of K4CPO-FD-Logger customized for N0SUW/WB0SIO.

Run the following command for the initial installation

	bash $HOME/pi-scripts/fd-logger-install.sh

Run the following command to update K4CPO-FD-Logger

	bash $HOME/pi-scripts/fd-logger-update.sh
	
