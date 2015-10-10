#!/bin/sh

usage="Usage: ${0} <path to folder with collect info files>"
if [ $# -ne 1 ]
then
    echo ${usage}
	exit 1
fi
path="${1}"
if [ -d ${path} ]
then
    echo "Searching ${path} for collect infos"
else
    echo ${usage}
    echo "Could not find folder"
    exit 1
fi

tmpLog="log-`date+%s`"
files="`ls ${path}/*.zip`"

for file in ${files}
do
	echo "Working on file: ${file}"
	host=`basename ${file}|cut -d '.' -f1`
	echo "Host: $host"
	logFile="`unzip -l ${file}|grep couchbase.log|awk '{print $4;}'`"
	echo "Log file: $logFile"
	unzip -p ${file} ${logFile} > ${tmpLog}
	if [ $? -ne 0 ]
	then
		echo "Failed to unpack ${file}"
	fi
	highExtensions="`grep [0-9]*\.couch\.[0-9]*$ ${tmpLog} |egrep -v '_users|replicator|master|geocouch'|awk '{print $9;}'|awk -F '.' '{print $3 "." $1;}'|sort -n|tail -10`"
	echo "Highest extensions found:"
	for kv in ${highExtensions}
	do
		vbucketId="`echo ${kv}|cut -d '.' -f2`"
		vbucketExtension="`echo ${kv}|cut -d '.' -f1`"
		vbucketFile="`grep ${vbucketId}\.couch\.${vbucketExtension}$ ${tmpLog}|head -1`"
		if [ ${vbucketExtension} -ge 50000 ]
		then
			echo "WARNING\tVbucket Extension: ${vbucketExtension} approaching limit of 65536"
		fi
		echo "${vbucketExtension}\t${vbucketFile}"
	done
done
