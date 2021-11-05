#!/bin/bash
#####################################
#	Patch Installed Check
#####################################

#This check first looks at the README.md file to see if the PATCH var is YES.
#If PATCH=YES, then it looks to see if the patches that are available have 
#been applied previously. If so, it skips the patch screen. If not, it gives
#the user an option to install the patch(es).

PATCHDIR=/run/user/${UID}/patch
PATCHCHECK=$(curl -s https://raw.githubusercontent.com/lcgreenwald/pi-scripts/dev/patch/README.md | grep PATCH= | sed 's/PATCH=//')

if [ ${PATCHCHECK} = "YES" ]; then
  mkdir $PATCHDIR
  cd $PATCHDIR

  curl -s https://raw.githubusercontent.com/lcgreenwald/pi-scripts/dev/patch/patch.function
  curl -s https://raw.githubusercontent.com/lcgreenwald/pi-scripts/dev/patch/patch-list
  curl -s https://raw.githubusercontent.com/lcgreenwald/pi-scripts/dev/patch/patch-menu.sh

  FILES=cat patch-list
  #check if available patches have already been applied to Pi-Scripts
  for i in $FILES; do
    RB=$(grep $i $HOME/.config/patch)
    if [ -z $RB ]; then
      echo "$1=Not_Installed" >> $PATCHDIR/avail-patch.txt
    else
      echo "$i=Installed" >> $PATCHDIR/avail-patch.txt
    fi # $RB
  done  # $FILES
  #end check
  
  # check to see if all patches have been installed
  PATCHESINSTALLED=$(grep "Not_Installed" $PATCHDIR/avail-patch.txt)
  if [ ${PATCHESINSTALLED} = "Not_Installed" ]; then
    echo "Available patches found"
    bash $PATCHDIR/patch-menu.sh 
  fi
  
#####################################
#	Clean Up
#####################################
##  rm -rf $PATCHDIR

fi  # patch check
