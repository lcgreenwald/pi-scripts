#!/bin/bash
if ! hash log2ram 2>/dev/null; then
	echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
	wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
	sudo apt update
	sudo apt upgrade -y
	sudo apt install -y log2ram
	sudo sed -i "s/SIZE=40M/SIZE=100M/" /etc/log2ram.conf
fi
