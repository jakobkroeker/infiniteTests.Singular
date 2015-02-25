#!/bin/bash
# $1 = binary
# $2 = input file
# $3 = tmelimit
# $4 = memory limit
# $5 = max num bugs
# $6 = idx 
# set memlimit e.g.:  ulimit -v 1000000 ; 
echo "binary:   "$1
echo "testing   "$2
echo "timeout:  "$3" sec"
echo "memlimit: "$4" kb"
echo "maxBugs : "$5" "
maxBugs=$(($5 + 0));
export rnd=$RANDOM
export idx=$6
echo "idx : "$idx" "
#exit
read -p "Press [Enter] key to start testing with parameters as above"
ulimit -v $4
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

    set -o pipefail; timeout -s SIGKILL $3 $1 -v < /tmp/testingular/input/$filename/$filename.in 2>&1 | tee -a log/$filename/id_$idx.log;
    status=$?; echo "status="$status;echo "status"$status >> log/$filename/id_$idx.log;
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
echo $1" "$2"  "$3" "$4" "$5" "$6
#timeout:     124
#out of mem:  14


