#!/bin/bash
# $1 = run or not script
# $2 = binary
# $3 = input file
# $4 = keep log
# $5 = tmelimit
# $6 = memory limit
# $7 = max num bugs
# $8 = idx 
# set memlimit e.g.:  ulimit -v 1000000 ; 
$1;
runornot=$?
    
echo "binary:   "$2
echo "testing   "$3
keepLog=$4
#echo "keepLog:"$keepLog
if [ $keepLog -eq 1 ] ; then  echo "keep log " ; fi;
if [ $keepLog -eq 0 ] ; then  echo " do not keep log " ; fi;
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
        set -o pipefail; timeout -s SIGKILL $5 $2 -v < /tmp/testingular/input/$filename/$filename.in 2>&1 | tee -a log/$filename/id_$idx.log;
        status=$?; echo "status="$status;echo "status"$status >> log/$filename/id_$idx.log;
    else
        set -o pipefail; timeout -s SIGKILL $5 $2 -v < /tmp/testingular/input/$filename/$filename.in 2>&1 | tee log/$filename/id_$idx.log;
        status=$?; echo "status="$status;echo "status"$status >> log/$filename/id_$idx.log;
    fi;

    if [ $status -eq 14 ] || [ $status -eq 137 ] || [ $status -eq 124 ] || [ $status -eq 0 ] 
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
echo $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8
#timeout:     124
#out of mem:  14


