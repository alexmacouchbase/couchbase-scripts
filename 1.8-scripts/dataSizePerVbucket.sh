#!/bin/bash

if [ $# -ne 1 ]
then
        echo "Usage: $0 <path to data bucket>"
        echo "ex: dataSizePerVbucket /opt/membase/var/lib/membase/data/"
        exit 1
fi
sqlite=/opt/couchbase/bin/sqlite3
currentDir=`pwd`
dataPath=$1
cd $1

for i in `ls -1 | grep data`
do
        #to remove the '-data'
        len=${#i}
        bucketNameLength=`expr $len - 5`
        bucket=${i:0:$bucketNameLength}
        
        echo $bucket
	for number in 0 1 2 3
	do
		file=$bucket"-"$number".mb"
		echo $file
		tables0=`$sqlite $i/$file 'SELECT name FROM sqlite_master WHERE type = "table"'`
		totalSize=0
		totalKeySize=0
		for a in $tables0
		do
			temp=${#a}		
			vbid=${a:3:$temp}
			table=$a
			
			sql="SELECT sum(length(v)) FROM $table"
			valueSize=`$sqlite $i/$file "$sql"`
			totalSize=$(($totalSize + $valueSize))
			
			sql="SELECT sum(length(k)) FROM $table"
			keySize=`$sqlite $i/$file "$sql"`
			totalKeySize=$(($totalKeySize + $keySize))

			sql="SELECT count(*) FROM $table"
			numKeys=`$sqlite $i/$file "$sql"`
				
			sql2="SELECT state from vbucket_states where vbid = "$vbid""
			state=`$sqlite $i/$bucket "$sql2"`
		
			echo "Table "$table" is "$state" with "$numKeys" keys and a value size of "$valueSize" and a key size of "$keySize
		done
		echo "Total Size:"$totalSize
		echo "Total Size:"$totalKeySize
	done

done