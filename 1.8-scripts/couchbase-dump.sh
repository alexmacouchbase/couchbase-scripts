#!/bin/sh

dump_shard() {
	if [ ${count} -eq 5 ]
	then
		finished="true"
		return 0
	fi

	shard=${file}
	${sqlite} ${shard} .dump > /tmp/${shard}
	if [ $? -eq 0 ]
	then
		finished="true"
		echo "dump_shard()->count: ${count}"
		return 0
	else
		((count++))
		echo "dump_shard()->count: ${count}"
		return 1
	fi
}

if [ $# -ne 1 ]
then
	echo "Usage: $0 <path to couchbase data bucket> ex. $0 /opt/couchbase/var/lib/couchbase/data/default-data"
	exit 1
fi
user=`whoami`
if [ "${user}" = "root" ]
then
	echo "Please run as a non-root user"
#	exit 1
fi

bucket_path="${1}"
bucket_name="`basename ${1} | cut -d '-' -f1`"

if [ -d /opt/couchbase ]
then
	version="couchbase"	
else
	version="membase"
fi

sqlite="/opt/${version}/bin/sqlite3"

cd ${bucket_path}/
data_files="`ls *.mb`"
data_files="${bucket_name} ${data_files}"

start_time=`date +%s`

for file in ${data_files}
do
	echo "File name: ${file}"
	count=0
	finished="false"
	while [ ${finished} = "false" ]
	do
		echo "${file} ${count}"
		dump_shard
	done
done

end_time=`date +%s`
runtime=$((end_time - start_time))
converted_time=$((runtime/60))
echo "runtime = $runtime"
echo "converted time = $converted_time"
