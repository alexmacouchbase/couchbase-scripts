#!/bin/sh

if [ $# -ne 2 ]
then
	echo "Usage $0 <file to search within collect info> <search term>"
	echo "ex: $0 couchbase.log swappiness"
	exit 1
fi

fileToSearch="${1}"
searchTerm="${2}"

echo "File to search: $fileToSearch"
echo "Search term: $searchTerm"

list=`ls *.zip`
tmpLog="log-`date +%s`"
for file in ${list}
do
	host=`basename ${file}|cut -d '-' -f1`
	echo "Host: ${host}"
	log="`unzip -q -l ${file} | grep ${fileToSearch} |awk '{print $4;}' 2>/dev/null `"
	if [ $? -eq 0 ]
	then
		unzip -p ${file} ${log} > ${tmpLog}
		grep -i "${searchTerm}" ${tmpLog}
	fi
done
rm ${tmpLog}
