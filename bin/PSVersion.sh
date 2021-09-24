#!/bin/bash
echo "Pi Scripts "
grep version ~/pi-scripts/changelog | head -1
echo " "
echo "Pi Build "
grep version ~/pi-build/changelog | head -1
sleep 10
