#!/bin/sh
currTime=`date +%k%M`
tempTime=`date +%k%M`
if ( [ $tempTime -gt 0800 -a $tempTime -lt 2200 ] ); then 
   echo "Time is between 8 AM and 10 PM.Aborting."
   echo 0
   exit 1
else
   echo "Time is after 10 PM and before 8 AM. Running normally."
   echo 1
   exit 0
fi

