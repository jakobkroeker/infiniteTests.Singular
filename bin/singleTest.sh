#!/bin/bash
# $1 = input file
# $2 = tmelimit
# $3 = memory limit
# set memlimit e.g.:  ulimit -v 1000000 ; 
echo "testing "$1
echo "timeout: "$2" sec"
echo "memlimit: "$3" kb"
ulimit -v $3
export cont=0;
echo "cont: "$cont;
echo 'def contstr="'$cont'";' >input/$1.cont; 
echo 'string logfile = "log/'$1'.'$cont'";'  >>input/$1.cont; 
cat input/$1 >> input/$1.cont; 
set -o pipefail; timeout -s SIGKILL $2 ./singular-spielwiese < input/$1.cont 2>&1 | tee -a log/$1.log; 
status=$?; echo "status="$status;echo "status"$status >> log/$1.log
if [ $status -eq 14 ] || [ $status -eq 137 ] || [ $status -eq 124 ] || [ $status -eq 0 ] 
then
    # export cont=$(($cont )); 
    echo "doNothing ";echo "doNothing ">> log/$1.log;
else 
    echo "raiseCount ";echo "raiseCount ">> log/$1.log;
    cp log/$1.$cont log/$1.$cont.bug
    export cont=$(($cont + 1)); 
fi; 
echo $0" "$1" "$2
#timeout:     124
#out of mem:  14


