#!/bin/bash
#this script downloads the latest solar data image
#for use in conky. It should be run by cron once
#per hour
#10DEC2020 KM4ACK
cd ~/Downloads
wget http://www.hamqsl.com/solarpich.php
mv solarpich.php solarpich.gif
wget http://www.hamqsl.com/solarmuf.php
mv solarmuf.php solarmuf.gif
wget http://www.hamqsl.com/solar101vhfpic.php
mv solar101vhfpic.php solar101vhfpic.gif
