#!/bin/sh
currTime=`date +%k%M`
tempTime=`date +%k%M`
if ( [ $tempTime -gt 0800 -a $tempTime -lt 2200 ] && [ $(date +%u) -lt 6 ] ); then 
   echo "Time is between 8 AM and 10 PM and Day is Mo-Fr. Aborting."
   echo 0
   exit 1
else
   echo "Time is after 10 PM and before 8 AM. Running normally."
   echo 1
   exit 0
fi

