#install YAD, jq, log2ram, locate and samba as needed
clear;echo;echo
echo "#######################################"
echo "#  Updating repository & installing   #"
echo "#  a few needed items before we begin #"
echo "#######################################"
if ! hash log2ram 2>/dev/null; then
	echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
	wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
fi
sudo apt update
sudo apt upgrade -y
if ! hash yad 2>/dev/null; then
	sudo apt install -y yad
fi
if ! hash jq 2>/dev/null; then
	sudo apt install -y jq
fi
if ! hash log2ram 2>/dev/null; then
	sudo apt install -y log2ram
fi
if ! hash locate 2>/dev/null; then
	sudo apt install -y locate
fi
if ! hash samba 2>/dev/null; then
	sudo apt install -y samba samba-common-bin smbclient cifs-utils
	sudo sed -i "s/WORKGROUP/WB0SIO/" /etc/samba/smb.conf
	sudo mkdir /home/public
	sudo chmod 777 /home/public
	cat <<EOF > $MYPATH/samba_share.txt
[public]
	path = /home/public
	read only = no
	public = yes
	writable = yes
EOF
	sudo chmod 666 /etc/samba/smb.conf  
	sudo cat $MYPATH/samba_share.txt >> /etc/samba/smb.conf
	sudo chmod 644 /etc/samba/smb.conf
	rm $MYPATH/samba_share.txt
fi
