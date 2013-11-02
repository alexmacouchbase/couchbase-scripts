#!/bin/sh

backup_head="/allbackup/"
sqlite3="/opt/couchbase/bin/sqlite3"
sqlite_shards="default-0.mb default-1.mb default-2.mb default-3.mb"

if [ $# -ne 2 ]
then
	echo "Usage: $0 <date> <key name to find>"
	exit 1
fi


date="${1}"
key="${2}"

# Check for valid date
if [ -d ${backup_head}/Node-01/${date} ]
then
	echo "Backup date found"
else
	echo "Backup date not found in ${backup_head}"
	echo "Usage: $0 <date> <key name to find>"
	exit 1
fi

# Do not run this as root
running_user=`whoami`
echo "Running script as: ${running_user}"
node_list="`ls ${backup_head}`"

for node in ${node_list}
do
	for shard in ${sqlite_shards}
	do
		echo "Searching in ${node}->${shard}"
		tables="`${sqlite3} ${backup_head}/${node}/${date}/${shard} .tables`"
		for table in ${tables}
		do
			${sqlite3} ${backup_head}/${node}/${date}/${shard} "select k from ${table} where k like '${key}';" | grep ${key}
			if [ $? -eq 0 ]
			then
				echo "Key found: ${backup_head}/${node}/${date}/${shard} ${table}"
				${sqlite3} ${backup_head}/${node}/${date}/${shard} "select k,v from ${table} where k like '${key}';"
				exit 0
			fi
														
		done
	done	
done

