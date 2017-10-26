#!/bin/sh

if [ $# -ne 1 ]
then
    echo "Usage: $0 <tag for logs>"
    exit 1
fi

tag="${1}"
list="`ls *.raw`"
directory="processed"
mkdir -p ${directory}
for log in ${list}
do
	echo "Working on ${log}"
	basename="`basename -s .raw ${log}`"
	./atop_net.py ${log} > ${directory}/${basename}-net.csv
	processes="indexer beam memcached projector cbq-engine"
	for process in ${processes}
	do
		./atop_process.py ${log} ${process} > ${directory}/${basename}-${process}.csv
	done
done

list2="`ls *.json`"
for log in ${list2}
do
    echo "Working on ${log}"
    basename="`basename -s .json ${log}`"
    cat ${log} | awk '{ FS=","; print $1,$19;}' | sed s/:/,/g | tr ' ' ',' > ${directory}/${basename}-query.csv
done

list3="`ls *.cbstats`"
for log in ${list3}
do
    echo "Working on ${log}"
    basename="`basename -s .cbstats ${log}`"

    # CB 4.6.3ee
    cat ${log} | cut -d ',' -f1,23,24 > ${directory}/${basename}-data.csv 
done

mkdir -p raw
mv *.raw raw/
mv *.json raw/
mv *.cbstats raw/
tar -czvf ${tag}.logs.tar.gz processed raw
curl --upload-file ${tag}.logs.tar.gz http://cb-field.s3.amazonaws.com/summit/data/logs/
