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
AVAILPATCH=$PATCHDIR/avail-patch.txt

if [ ${PATCHCHECK} = "YES" ]; then
  mkdir $PATCHDIR
  cd $PATCHDIR
  #Delete file if exist
  if [ -f $AVAILPATCH ]; then
    rm $AVAILPATCH
  fi
  #create new file
  touch $AVAILPATCH

  wget https://raw.githubusercontent.com/lcgreenwald/pi-scripts/dev/patch/patch.function
  wget https://raw.githubusercontent.com/lcgreenwald/pi-scripts/dev/patch/patch-list
  wget https://raw.githubusercontent.com/lcgreenwald/pi-scripts/dev/patch/patch-menu.sh

  FILES=$(cat "patch-list")
  #check if available patches have already been applied to Pi-Scripts
  for i in $FILES; do
    RB=$(grep $i $HOME/.config/patch)
    if [ -z $RB ]; then
      echo "$i=Not_Installed" >> $AVAILPATCH
    else
      echo "$i=Installed" >> $AVAILPATCH
    fi # $RB
  done  # $FILES
  #end check
  
  # check to see if all patches have been installed
  PATCHESINSTALLED=$(grep "Not_Installed" $AVAILPATCH)
  if [[ -z ${PATCHESINSTALLED} ]]; then
    echo "No available patches found"
  else
    echo "Available patches found"
    bash $PATCHDIR/patch-menu.sh 
  fi
  

fi  # patch check
