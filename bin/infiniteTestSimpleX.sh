#!/bin/bash
# $1 = run or not script
# $2 = binary
# $3 = input file
# $4 = keep log
# $5 = ignore overflow error
# $6 = consider timeout
# $7 = check for out of mem
# $8 = tmelimit
# $9 = memory limit
# ${10} = max num bugs
# ${11} = idx 
# set memlimit e.g.:  ulimit -v 1000000 ; 
$1;
runornot=$?
    
ignoreOverflow=$5

basicTimeout=$8
killTimeout=$(($basicTimeout +30))
extTimeout=$((3 * $8))
extkillTimeout=$(($extTimeout +30))

considerTimeout=$6

checkOutOfMem=$7

echo "binary:   "$2
echo "testing   "$3
echo "ignoreOverflow   "$ignoreOverflow
echo "considerTimeout  "$considerTimeout
echo "checkOutOfMem    "$checkOutOfMem

keepLog=$4
#echo "keepLog:"$keepLog
if [ $keepLog -eq 1 ] ; then  echo "keep log " ; fi;
if [ $keepLog -eq 0 ] ; then  echo " do not keep log " ; fi;
echo "timeout:  "$8" sec"
echo "memlimit: "$9" kb"
echo "maxBugs : "${10}" "
maxBugs=$((${10} + 0));
export rnd=$RANDOM
export idx=${11}
echo "idx : "$idx" "


ulimit -v $9
export count=0;


filename="${3##*/}"
echo $filename

set +H

mkdir -p /tmp/testsingular/input/$filename/
mkdir -p log/$filename/bugs
if [ -e "log/$filename/bugs/id_$idx.count" ]
then
    . log/$filename/bugs/id_$idx.count
fi


export hid=`hostname |sed "s/[^0-9]//g"`

if [ -z "$hid" ]
then 
    hid="0";
fi;

echo "hid="$hid

export idx=$(($hid*100+${idx}));

echo "idx="$idx
echo "count="$count
echo "started with " >> log/$filename/id_$idx.log

read -p "Press [Enter] key to start testing with parameters as above"


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
    export randomNum=$(od -N 6 -t uL -An /dev/urandom | tr -d " ") 
    export randomNum=$( echo $randomNum" % 2^30" | bc ) # have to cut random num (on 32 bit machine only?)
    echo $randomNum
    rm -f log/$filename/$filename.id_$idx.$count
    sleep 3
    echo "count: "$count;
    #echo 'def countstr="'$count'";' >input/$3.count; 
    touch log/$filename/id_$idx.$count
    echo 'string logfile = "log/'$filename'/id_'$idx'.'$count'";'  >/tmp/testsingular/input/$filename/$filename.in; 

    cat input/$filename >> /tmp/testsingular/input/$filename/$filename.in; 

    if [ $keepLog -eq 1 ] 
    then
        #set -o pipefail; timeout -s SIGKILL $basicTimeout $2 -v -r $randomNum /tmp/testsingular/input/$filename/$filename.in 2>&1 | tee -a log/$filename/id_$idx.log;
        set -o pipefail; timeout --kill-after=5 $basicTimeout  $2  -v -r $randomNum /tmp/testsingular/input/$filename/$filename.in 2>&1 | tee -a log/$filename/id_$idx.log;
        status=$?; echo "status="$status;echo "status"$status >> log/$filename/id_$idx.log;
    else
        set -o pipefail; timeout --kill-after=5 $basicTimeout  $2 -v -r $randomNum /tmp/testsingular/input/$filename/$filename.in 2>&1 | tee log/$filename/id_$idx.log;
        status=$?; echo "status="$status;echo "status"$status >> log/$filename/id_$idx.log;
    fi;   
    echo "show output file" 
    cat log/$filename/id_$idx.$count;
    sync
    #echo 3 > /proc/sys/vm/drop_caches
    echo "show output file after sync" 
    cat log/$filename/id_$idx.$count;

    sleep 30; # wait for disc sync...
    echo "show output file after sleep" 
    cat log/$filename/id_$idx.$count;
    sleep 10;  
    if [ $status -eq 253 ] || [ $status -eq 252 ]
    then
       overflow=1;
    else
       overflow=0;
    fi;

    if ( [ $status -eq 137 ] && [ $considerTimeout -eq 1 ] )  || ( [ $status -eq 124 ] && [ $considerTimeout -eq 1 ]  )
    then
        echo "quit;" >> log/$filename/id_$idx.$count;

        sleep 2;
        set -o pipefail; timeout --kill-after=5 $extTimeout  $2 -v -r $randomNum log/$filename/id_$idx.$count 2>&1 | tee log/$filename/id_$idx.log;
        status=$?; echo "status="$status;echo "status"$status >> log/$filename/id_$idx.log;
    fi; 

    if [ ( $status -eq 14 ] [ $checkOutOfMem -eq 0 ] ) || ( [ $status -eq 137 ] && [ $considerTimeout -eq 0 ] )  || ( [ $status -eq 124 ] && [ $considerTimeout -eq 0 ] ) || [ $status -eq 0 ] || ( [ $overflow -eq 1 ] && [ $ignoreOverflow -eq 1 ] )
    then
        # export count=$(($count )); 
        echo "doNothing ";echo "doNothing ">> log/$filename/id_$idx.log;
    else 
        echo "raiseCount ";echo "raiseCount ">> log/$filename/id_$idx.log;
        if [ $status -eq 14 ]
        then 
            mv log/$filename/id_$idx.$count log/$filename/bugs/id_$idx.$count.outofmem.bug;
        fi;

        if [ $status -eq 137 ] || [ $status -eq 124 ]
        then 
            mv log/$filename/id_$idx.$count log/$filename/bugs/id_$idx.$count.timeout.bug;
        fi;

        if [ $overflow -eq 1 ]
        then 
            mv log/$filename/id_$idx.$count log/$filename/bugs/id_$idx.$count.overflow.bug;
        fi;


        if [ -e "log/$filename/id_$idx.$count" ]
        then 
            mv log/$filename/id_$idx.$count log/$filename/bugs/id_$idx.$count.bug;
        fi;

        export count=$(($count + 1)); 
        echo "#!/bin/bash">  log/$filename/bugs/id_$idx.count.tmp
        echo " export count="$count >>  log/$filename/bugs/id_$idx.count.tmp
        mv log/$filename/bugs/id_$idx.count.tmp log/$filename/bugs/id_$idx.count
    fi; 
done
echo "done"
echo $1" "$2" "$3" "$4" "$5" "$6" "$8" "$9" "${10}" "${11}
#timeout:     124
#out of mem:  14

# singular exit codes:
# overflow 253
# expoent overflow - wrong ordering 252

