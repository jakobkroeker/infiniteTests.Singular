#!/bin/bash
# $1 = run or not script
# $2 = binary
# $3 = input file
# $4 = keep log
# $5 = ignore overflow error
# $6 = tmelimit
# $7 = memory limit
# $8 = max num bugs
# $9 = idx 
# set memlimit e.g.:  ulimit -v 1000000 ; 
$1;
runornot=$?
    
ignoreOverflow=$5

echo "binary:   "$2
echo "testing   "$3
echo "ignoreOverflow   "$ignoreOverflow
keepLog=$4
#echo "keepLog:"$keepLog
if [ $keepLog -eq 1 ] ; then  echo "keep log " ; fi;
if [ $keepLog -eq 0 ] ; then  echo " do not keep log " ; fi;
echo "timeout:  "$6" sec"
echo "memlimit: "$7" kb"
echo "maxBugs : "$8" "
maxBugs=$(($8 + 0));
export rnd=$RANDOM
export idx=$9
echo "idx : "$idx" "

read -p "Press [Enter] key to start testing with parameters as above"
ulimit -v $7
export count=0;


filename="${3##*/}"
echo $filename

set +H

mkdir -p /tmp/testingular/input/$filename/
mkdir -p log/$filename/bugs
. log/$filename/bugs/id_$idx.count


export hid=`hostname |sed "s/[^0-9]//g"`
export idx=$((hid*100+$idx));

echo "idx="$idx
echo "count="$count
echo "started with " >> log/$filename/id_$idx.log
echo $0" "$@  >> log/$filename/id_$idx.log

while [ $count -lt $maxBugs ] ; 
do 
    $1;
    runornot=$?
    
    if [ $runornot -ne 0 ]
    then
      sleep 300;
      continue;
    fi;
    
    rm -f log/$filename/$filename.id_$idx.$count
    sleep 5
    echo "count: "$count;
    #echo 'def countstr="'$count'";' >input/$3.count; 
    echo 'string logfile = "log/'$filename'/id_'$idx'.'$count'";'  >/tmp/testingular/input/$filename/$filename.in; 

    cat input/$filename >> /tmp/testingular/input/$filename/$filename.in; 

    if [ $keepLog -eq 1 ] 
    then
        set -o pipefail; timeout -s SIGKILL $6 $2 -v -r $(od -N 6 -t uL -An /dev/urandom | tr -d " ") < /tmp/testingular/input/$filename/$filename.in 2>&1 | tee -a log/$filename/id_$idx.log;
        status=$?; echo "status="$status;echo "status"$status >> log/$filename/id_$idx.log;
    else
        set -o pipefail; timeout -s SIGKILL $6 $2 -v -r $(od -N 6 -t uL -An /dev/urandom | tr -d " ") < /tmp/testingular/input/$filename/$filename.in 2>&1 | tee log/$filename/id_$idx.log;
        status=$?; echo "status="$status;echo "status"$status >> log/$filename/id_$idx.log;
    fi;
    if [ $status -eq 253 ] || [ $status -eq 252 ]
    then
       overflow=1;
    else
       overflow=0;
    fi;
    
    if [ $status -eq 14 ] || [ $status -eq 137 ] || [ $status -eq 124 ] || [ $status -eq 0 ] || ( [ $overflow -eq 1 ] && [ $ignoreOverflow -eq 1 ] )
    then
        # export count=$(($count )); 
        echo "doNothing ";echo "doNothing ">> log/$filename/id_$idx.log;
    else 
        echo "raiseCount ";echo "raiseCount ">> log/$filename/id_$idx.log;
        mv log/$filename/id_$idx.$count log/$filename/bugs/id_$idx.$count.bug;
        export count=$(($count + 1)); 
        echo "#!/bin/bash">  log/$filename/bugs/id_$idx.count.tmp
        echo " export count="$count >>  log/$filename/bugs/id_$idx.count.tmp
        mv log/$filename/bugs/id_$idx.count.tmp log/$filename/bugs/id_$idx.count
    fi; 
done
echo "done"
echo $1" "$2" "$3" "$4" "$6" "$7" "$8" "$9
#timeout:     124
#out of mem:  14

# singular exit codes:
# overflow 253
# expoent overflow - wrong ordering 252

