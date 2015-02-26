#!/bin/bash
# $1 = binary
# $2 = input file
# $3 = keep log
# $4 = tmelimit
# $5 = memory limit
# $6 = max num bugs
# $7 = idx 
# set memlimit e.g.:  ulimit -v 1000000 ; 
echo "binary:   "$1
echo "testing   "$2
keepLog=$3
#echo "keepLog:"$keepLog
if [ $keepLog -eq 1 ] ; then  echo "keep log " ; fi;
if [ $keepLog -eq 0 ] ; then  echo " do not keep log " ; fi;
echo "timeout:  "$4" sec"
echo "memlimit: "$5" kb"
echo "maxBugs : "$6" "
maxBugs=$(($6 + 0));
export rnd=$RANDOM
export idx=$7
echo "idx : "$idx" "

#exit
read -p "Press [Enter] key to start testing with parameters as above"
ulimit -v $5
export cont=0;

filename="${2##*/}"
echo $filename



mkdir -p /tmp/testingular/input/$filename/
mkdir -p log/$filename/bugs

echo "started with " >> log/$filename/id_$idx.log
echo $0" "$@  >> log/$filename/id_$idx.log

while [ $cont -lt $maxBugs ] ; 
do 
    rm -f log/$filename/$filename.id_$idx.$cont
    sleep 5
    echo "cont: "$cont;
    #echo 'def contstr="'$cont'";' >input/$2.cont; 
    echo 'string logfile = "log/'$filename'/id_'$idx'.'$cont'";'  >/tmp/testingular/input/$filename/$filename.in; 

    cat input/$filename >> /tmp/testingular/input/$filename/$filename.in; 

    if [ $keepLog -eq 1 ] 
    then
        set -o pipefail; timeout -s SIGKILL $4 $1 -v < /tmp/testingular/input/$filename/$filename.in 2>&1 | tee -a log/$filename/id_$idx.log;
        status=$?; echo "status="$status;echo "status"$status >> log/$filename/id_$idx.log;
    else
        set -o pipefail; timeout -s SIGKILL $4 $1 -v < /tmp/testingular/input/$filename/$filename.in 2>&1 | tee log/$filename/id_$idx.log;
        status=$?; echo "status="$status;echo "status"$status >> log/$filename/id_$idx.log;
    fi;

    if [ $status -eq 14 ] || [ $status -eq 137 ] || [ $status -eq 124 ] || [ $status -eq 0 ] 
    then
        # export cont=$(($cont )); 
        echo "doNothing ";echo "doNothing ">> log/$filename/id_$idx.log;
    else 
        echo "raiseCount ";echo "raiseCount ">> log/$filename/id_$idx.log;
        mv log/$filename/id_$idx.$cont log/$filename/bugs/id_$idx.$cont.bug;
        export cont=$(($cont + 1)); 
    fi; 
done
echo $1" "$2" "$3" "$4" "$5" "$6" "$7
#timeout:     124
#out of mem:  14


