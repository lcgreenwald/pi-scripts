#!/bin/bash
#this script downloads the latest solar data image
#for use in conky. It should be run by cron once
#per hour
#10DEC2020 KM4ACK
cd ~/Downloads
wget http://www.hamqsl.com/solarpich.php
mv solarpich.php solarpich.gif
