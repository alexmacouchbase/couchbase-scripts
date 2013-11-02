#!/bin/sh

dump_shard() {
	if [ ${count} -eq ${retry_count} ]
	then
		echo "Dump retry #${count} of ${shard} has failed - skipping and moving to next shard"
		finished="true"
		return 0
		
	fi

	shard=${file}
	${sqlite} ${shard} .dump > /${backup_location}/${shard}.sql
	if [ $? -eq 0 ]
	then
		finished="true"
		echo "Dump of ${shard}.sql finished successfully"
		return 0
	else
		((count++))
		echo "Dump retry #${count} of ${shard}"
		return 1
	fi
}

if [ $# -ne 2 ]
then
	echo "Usage: $0 <path to couchbase data bucket> <path to desired backup location> ex. $0 /opt/couchbase/var/lib/couchbase/data/default-data /tmp/ "
	exit 1
fi
user=`whoami`
if [ "${user}" = "root" ]
then
	echo "Please run as a non-root user"
	exit 1
fi

bucket_path="${1}"
bucket_name="`basename ${1} | cut -d '-' -f1`"
timestamp="`date +'%m-%d-%Y--%T'`"
backup_location="${2}${timestamp}"
dump_option="${3}"
retry_count=5

echo "Creating backup location: ${backup_location}"
mkdir -p "${backup_location}"
if [ $? -ne 0 ]
then
	echo "Failed to create backup location ${backup_location} - please check permissions"
	exit 1
fi


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
	echo "Working on: ${file}"
	count=0
	finished="false"
	while [ ${finished} = "false" ]
	do
		dump_shard
	done
done
end_time=`date +%s`
runtime=$((end_time - start_time))
converted_time=$((runtime/60))
echo "Total time for dump:(minutes) = $converted_time"

du -cksh /${backup_location}/*
