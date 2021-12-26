#!/bin/bash
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
wget -O - https://raw.githubusercontent.com/OpenMediaVault-Plugin-Developers/installScript/master/install | sudo bash
