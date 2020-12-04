# pi-scripts
My Raspberry Pi Scripts and programs

# pi-build-install
This script installs:

km4ack build-a-pi

km4ack hotspot tools customized to allow editing the hotspot IP address

You may also optionally install:

	log2ram - Save logs to ram to reduce wear on your SD card.
	locate - File find/locate program
	samba - SMB server to share files/folders with Windows machines
	webmin - Web based computer/configuration mamager
	cqrprop - Propagation prediction 
	3.5" display drivers
	disks - gnome disk utility
	pi imager - Raspberry Pi Imager

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
	
