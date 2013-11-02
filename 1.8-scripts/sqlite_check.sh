#!/bin/sh

sqlite="/opt/couchbase/bin/sqlite3"
fileList="`ls *.mb`"
for file in $fileList 
do
	tables=`$sqlite $file .tables`
	for table in $tables
	do
		count=`$sqlite $file "pragma quick_check;"`
		if [ ${count} -ne 0 ]
		then
			echo -e "$file\t$table\t$count"
		fi
	done	

done
