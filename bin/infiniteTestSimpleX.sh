#!/bin/bash
# $1 = run or not script
# $2 = binary
# $3 = input file
# $4 = keep log
# $5 = ignore overflow error
# $6 = consider timeout
# $7 = check for out of mem
# $8 = minimize
# $9 = tmelimit
# ${10} = memory limit
# ${11} = max num bugs
# ${12} = idx 
# set memlimit e.g.:  ulimit -v 1000000 ; 
$1;
runornot=$?
    
ignoreOverflow=$5

basicTimeout=$9
killTimeout=$(($basicTimeout +30))
extTimeout=$((10 * $9))
extkillTimeout=$(($extTimeout +30))

considerTimeout=$6

checkOutOfMem=$7

minimize=$8


maxMinimizeTime=$((3600*5))
#maxMinimizeTime=1

elapsedMinimizeTime=0


echo "binary:   "$2
echo "testing   "$3
echo "ignoreOverflow   "$ignoreOverflow
echo "considerTimeout  "$considerTimeout
echo "checkOutOfMem    "$checkOutOfMem
echo "minimize    "$minimize

keepLog=$4
#echo "keepLog:"$keepLog
if [ $keepLog -eq 1 ] ; then  echo "keep log " ; fi;
if [ $keepLog -eq 0 ] ; then  echo " do not keep log " ; fi;
echo "timeout:  "$9" sec"
echo "memlimit: "${10}" kb"
echo "maxBugs : "${11}" "
maxBugs=$((${11} + 0));
export rnd=$RANDOM
export idx=${12}
echo "idx : "$idx" "


ulimit -v ${10}
export count=0;

#export degSub=0;
#export termSub=0;
#export genSub=0;
#export coeffSub=0;
#export varSub=0;

declare -A arr

arr["degSub"]=0
arr["termSub"]=0
arr["genSub"]=0
arr["coeffSub"]=0
arr["varSub"]=0


declare -A arrProc

arrProc["degSub"]="minimizeMonomialDegS"
arrProc["termSub"]="minimizeTermNumberS"
arrProc["genSub"]="minimizeGensS"
arrProc["coeffSub"]="minimizeAbsMaxCoeffS"
arrProc["varSub"]="minimizeVarsS"

export randomMinimizeNum=-1


filename="${3##*/}"
echo $filename

fullinput=$3
if [ ! -e "$fullinput" ]
then
    fullinput="input/"$3
fi;

if [ ! -e "$fullinput" ]
then
    echo "input file does not exist";
    exit;
fi;


echo $fullinput

set +H

mkdir -p /tmp/testsingular/input/$filename/
mkdir -p log/$filename/bugs
if [ -e "log/$filename/bugs/id_$idx.count" ]
then
    . log/$filename/bugs/id_$idx.count
fi

for key in ${!arr[@]}; do
    echo ${key} ${arr[${key}]}
done

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


    if [ $minimize -eq 1 ]
    then
       echo "minimize"
       if [ $elapsedMinimizeTime -gt $maxMinimizeTime ]
       then
            export minPos=0;
            if [ $randomMinimizeNum -eq -1 ]
            then
              export randomMinimizeNum=$( echo $randomNum" % "${#arr[@]} | bc ) 
            fi;
            for key in ${!arr[@]}; do
                if [ $minPos -eq $randomMinimizeNum ]
                then 
                    arr[${key}]=$((${arr[${key}]}-1))   
                fi; 
                export minPos=$(($minPos + 1)); 
            done;
         
       fi;
    fi;



    echo "randomNum: " $randomNum

    rm -f log/$filename/$filename.id_$idx.$count
    sleep 3
    echo "count: "$count;
    #echo 'def countstr="'$count'";' >input/$3.count; 
    touch log/$filename/id_$idx.$count
    echo 'string logfile = "log/'$filename'/id_'$idx'.'$count'";'  >/tmp/testsingular/input/$filename/$filename.$idx.in; 

    cat $fullinput >> /tmp/testsingular/input/$filename/$filename.$idx.in;

    for key in ${!arr[@]}; do

       echo ${arrProc[${key}]}"("${arr[${key}]}");" >> /tmp/testsingular/input/$filename/$filename.$idx.in;
   done

   cat /tmp/testsingular/input/$filename/$filename.$idx.in;    

    echo " if (defined(run)) { run(); }" >> /tmp/testsingular/input/$filename/$filename.$idx.in;  

    if [ $keepLog -eq 1 ] 
    then
        #set -o pipefail; timeout -s SIGKILL $basicTimeout $2 -v -r $randomNum /tmp/testsingular/input/$filename/$filename.$idx.in 2>&1 | tee -a log/$filename/id_$idx.log;
        set -o pipefail; timeout --kill-after=5 $basicTimeout  $2  -v -r $randomNum /tmp/testsingular/input/$filename/$filename.$idx.in 2>&1 | tee -a log/$filename/id_$idx.log;
        status=$?; echo "status="$status;echo "status"$status >> log/$filename/id_$idx.log;
    else
        set -o pipefail; timeout --kill-after=5 $basicTimeout  $2 -v -r $randomNum /tmp/testsingular/input/$filename/$filename.$idx.in 2>&1 | tee log/$filename/id_$idx.log;
        status=$?; echo "status="$status;echo "status"$status >> log/$filename/id_$idx.log;
    fi;   
    echo "show output file ******************************************" 
    cat log/$filename/id_$idx.$count;
    cat log/$filename/id_$idx.$count > /tmp/testsingular/input/$filename/$filename.$idx.output;
    sync
    #echo 3 > /proc/sys/vm/drop_caches
    echo "show output file after sync+++++++++++++++++++++++++++++++++++"
    cat log/$filename/id_$idx.$count;

    # sleep 15; # wait for disc sync...
    echo "show output file after sleep ----------------------------------" 
    cat log/$filename/id_$idx.$count;
    # sleep 20;  
    diff log/$filename/id_$idx.$count /tmp/testsingular/input/$filename/$filename.$idx.output;
    diffstatus=$?;
    if [ $diffstatus -ne 0 ]
    then 
         cp /tmp/testsingular/input/$filename/$filename.$idx.output log/$filename/bugs/id_$idx.$count.lag.bug;
         cp log/$filename/id_$idx.$count log/$filename/bugs/id_$idx.$count.changedout.bug;

         # duplicate code !!
         if [ -e "log/$filename/id_$idx.$count" ]
         then 
             mv log/$filename/id_$idx.$count log/$filename/bugs/id_$idx.$count.bug;
         fi;

         export count=$(($count + 1)); 
         echo "#!/bin/bash">  log/$filename/bugs/id_$idx.count.tmp
         echo " export count="$count >>  log/$filename/bugs/id_$idx.count.tmp
          for key in ${!arr[@]}; do
             echo "arr[\""${key}"\"]="${arr[${key}]} >>log/$filename/bugs/id_$idx.count.tmp
          done

         mv log/$filename/bugs/id_$idx.count.tmp log/$filename/bugs/id_$idx.count
         continue;
    fi;
    elapsedMinimizeTime=$((${elapsedMinimizeTime} + $basicTimeout));

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

    if  ( [ $status -eq 14 ] && [ $checkOutOfMem -eq 0 ] ) || ( [ $status -eq 137 ] && [ $considerTimeout -eq 0 ] )  || ( [ $status -eq 124 ] && [ $considerTimeout -eq 0 ] ) || [ $status -eq 0 ] || ( [ $overflow -eq 1 ] && [ $ignoreOverflow -eq 1 ] )
    then
        # export count=$(($count )); 
        echo "doNothing ";echo "doNothing ">> log/$filename/id_$idx.log;
    else 

        export randomMinimizeNum=$( echo $randomNum" % "${#arr[@]} | bc ) 

        echo "randomMinimizeNum: " $randomMinimizeNum

        echo "raiseCount ";echo "raiseCount ">> log/$filename/id_$idx.log;
        echo "quit;" >> log/$filename/id_$idx.$count;

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


        if [ $minimize -eq 1 ]
        then 
            export minPos=0;

            for key in ${!arr[@]}; do
                if [ $minPos -eq $randomMinimizeNum ]
                then 
                    arr[${key}]=$((${arr[${key}]}+1))   
                fi;
                echo "arr[\""${key}"\"]="${arr[${key}]} >>log/$filename/bugs/id_$idx.count.tmp
                export minPos=$(($minPos + 1)); 
            done;

        fi;

        mv log/$filename/bugs/id_$idx.count.tmp log/$filename/bugs/id_$idx.count
    fi; 
done
echo "done"
echo $1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}" "${11}" "${12}
#timeout:     124
#out of mem:  14

# singular exit codes:
# overflow 253
# expoent overflow - wrong ordering 252

