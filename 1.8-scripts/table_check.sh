#!/bin/bash

if [ $# -ne 1 ]
then
        echo "Usage: $0 <path to data bucket>"
        echo "ex: dataSizePerVbucket /opt/membase/var/lib/membase/data/"
        exit 1
fi
 currentDir=`pwd`
dataPath=$1
cd $1
sqlite=/opt/couchbase/bin/sqlite3
bucket="default"
        
	for number in 0 1 2 3
	do
		file=$bucket"-"$number".mb"
		echo "working on: $file"
		tables0=`$sqlite $file 'SELECT name FROM sqlite_master WHERE type = "table"'`
		for a in $tables0
		do
			sql="select count(*) from $table;"
			count=`$sqlite $file $sql`
			echo "${table} = ${count}"	
		done

	done

