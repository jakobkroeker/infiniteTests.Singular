#!/bin/bash
# $1 binary
# $2 = input file
# $3 = ring
# $4 = genTable
# $5 = tmelimit
# $6 = memory limit
# $7 = max num bugs
# $8 = idx 
# set memlimit e.g.:  ulimit -v 1000000 ; 
echo "binary:   "$1
echo "testing   "$2
export ring=$3
export ring=$(basename $ring)
echo "ring:     " $ring
export genTable=$4
export genTable=$(basename $genTable)
echo "genTable: " $genTable
echo "timeout:  "$5" sec"
echo "memlimit: "$6" kb"
echo "maxBugs : "$7" "
maxBugs=$(($7 + 0));
export rnd=$RANDOM
export idx=$8
echo "idx : "$idx" "
#exit
read -p "Press [Enter] key to start testing with parameters as above"
ulimit -v $6
export cont=0;
mkdir -p /tmp/testingular/input/$2/
mkdir -p log/$2/bugs

echo "started with " >> log/$2/$ring.$genTable.log
echo $0" "$@  >> log/$2/$ring.$genTable.log

while [ $cont -lt $maxBugs ] ; 
do 
    rm -f log/$2/$2.$ring.$genTable.id_$idx.$cont
    sleep 5
    echo "cont: "$cont;
    #echo 'def contstr="'$cont'";' >input/$2.cont; 
    echo 'string logfile = "log/'$2'/'$ring'.'$genTable'.id_'$idx'.'$cont'";'  >/tmp/testingular/input/$2/$2.$ring.$genTable.in; 

    echo 'LIB("randomsetup/ring/'$ring'");'  >>/tmp/testingular/input/$2/$2.$ring.$genTable.in; 
    echo 'LIB("randomsetup/genTable/'$genTable'");'  >>/tmp/testingular/input/$2/$2.$ring.$genTable.in; 
    #echo 'ring rng = getRing();'  >>/tmp/testingular/input/$2/$2.$ring.$genTable.in; 
    #echo 'def gens = getGenTable();'  >>/tmp/testingular/input/$2/$2.$ring.$genTable.in; 
    cat input/$2 >> /tmp/testingular/input/$2/$2.$ring.$genTable.in; 
    #echo "input" ; echo /tmp/testingular/input/$2/$2.$ring.$genTable.in;
    #read -p "Press [Enter] key to start testing with parameters as above"

    set -o pipefail; timeout -s SIGKILL $5 $1 -v < /tmp/testingular/input/$2/$2.$ring.$genTable.in 2>&1 | tee -a log/$2/$ring.$genTable.log;
    status=$?; echo "status="$status;echo "status"$status >> log/$2/$ring.$genTable.log
    if [ $status -eq 14 ] || [ $status -eq 137 ] || [ $status -eq 124 ] || [ $status -eq 0 ] 
    then
        # export cont=$(($cont )); 
        echo "doNothing ";echo "doNothing ">> log/$2/$ring.$genTable.log;
    else 
        echo "raiseCount ";echo "raiseCount ">> log/$2/$ring.$genTable.log;
        #mv log/$2/$ring.$genTable.id_$idx.$cont log/$2/$ring.$genTable.id_$idx.$rnd.$cont.bug;
        mv log/$2/$ring.$genTable.id_$idx.$cont log/$2/bugs/$ring.$genTable.id_$idx.$cont.bug;
        export cont=$(($cont + 1)); 
    fi; 
done
echo $1" "$2" "$ring" "$genTable" "$5" "$6" "$7" "$8 
#timeout:     124
#out of mem:  14


