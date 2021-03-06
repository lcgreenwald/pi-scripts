#!/bin/bash
############
# Update build-a-pi base.function to install the latest version of HamLib
# Created: 2020/12/29 - Larry Greenwald - WB0SIO
# Modified:
# 
############

# Get the current and latest version numbers
OLDRIG=$(cat $HOME/pi-build/functions/base.function | grep -o hamlib-[0-9].[0-9] | grep -o [0-9].[0-9] | head -n 1)
NEWRIG=$(curl -s https://sourceforge.net/projects/hamlib/files/latest/download | \
grep -o https://downloads.sourceforge.net/project/hamlib/hamlib/[0-9].[0-9] | \
head -n 1 | awk -F "/" '{print $7}') 

# Update pi-build/functions/base.function to install the latest version.
sed -i "s/hamlib\/$OLDRIG\/hamlib/hamlib\/$NEWRIG\/hamlib/" $HOME/pi-build/functions/base.function
sed -i "s/hamlib-$OLDRIG/hamlib-$NEWRIG/" $HOME/pi-build/functions/base.function
