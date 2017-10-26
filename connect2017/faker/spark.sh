#!/bin/sh

load()
{
	start=$1
	stop=$2
    echo "Working on section: ${start} - ${stop}"
	for i in `seq 1 36`
	do
		echo "Starting: $i"
		./process.py ${start} ${stop} $i &
	done
}


name=`hostname | cut -d '.' -f1`
if [ "${name}" = "cb1" ]
then
    load 1 10000000
elif [ "${name}" = "cb2" ]
then
    load 10000000 20000000
elif [ "${name}" = "cb3" ]
then
    load 20000000 30000000
elif [ "${name}" = "cb4" ]
then
    load 30000000 40000000
elif [ "${name}" = "cb5" ]
then
    load 40000000 50000000
elif [ "${name}" = "cb6" ]
then
    load 50000000 60000000
elif [ "${name}" = "cb7" ]
then
    load 60000000 70000000
elif [ "${name}" = "cb8" ]
then
    load 70000000 80000000
elif [ "${name}" = "cb9" ]
then
    load 80000000 90000000
elif [ "${name}" = "cb10" ]
then
    load 90000000 100000000
fi
