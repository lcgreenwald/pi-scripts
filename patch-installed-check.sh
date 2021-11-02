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

  FILES=cat patch-list
  #check if available patches have already been applied to BAP
  for i in $FILES; do
    RB=$(grep $i $HOME/.config/patch)
    if [ -z $RB ]; then
      echo "$1=Not_Installed" >> $PATCHDIR/avail-patch.txt
    else
      echo "$i=Installed" >> $PATCHDIR/avail-patch.txt
    fi # $RB
  done  # $FILES
  #end check

  if [ -f $PATCHDIR/avail-patch.txt ]; then
    
  
  fi  #

#####################################
#	Clean Up
#####################################
##  rm -rf $PATCHDIR

fi  # patch check
