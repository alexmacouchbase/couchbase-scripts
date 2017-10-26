#!/bin/sh

if [ $# -ne 1 ]
then
    echo "Usage: $0 <stats file to save to>"
    exit 1
fi

stats_file="${1}"
for i in `seq 1 1000`
do
	date="`date +"%H:%M:%S"`"
	# 4.x
    stats="`/opt/couchbase/bin/cbstats localhost:11210 dcpagg |tr  '\n' ' ' | tr -s ' ' ','`"
	#stats="`/opt/couchbase/bin/cbstats localhost:11210 dcpagg -u Administrator -p password |tr  '\n' ' ' | tr -s ' ' ','`"
	echo "${date},${stats}" >> ${stats_file}
	sleep 1
done
