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
	stats="`curl http://localhost:8093/admin/stats`"
	echo "${date},${stats}" >> ${stats_file}
	sleep 1
done

# Command line to parse stats file with
# cat statsfile | awk '{ FS=","; print $1,$19;}' | sed s/:/,/g | tr ' ' ','

# Reference URLs
# http://localhost:8093/admin/vitals
# http://localhost:8093/admin/active_requests
# http://localhost:8093/admin/completed_requests
# http://localhost:8093/admin/prepareds
# http://localhost:8093/admin/prepareds/<statement id>
# http://localhost:8093/admin/settings

