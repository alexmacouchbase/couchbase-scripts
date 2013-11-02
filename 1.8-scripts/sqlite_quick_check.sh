#!/bin/sh

sqlite="/opt/couchbase/bin/sqlite3"
fileList="`ls *.mb`"
for file in $fileList 
do
		check=`$sqlite $file "pragma quick_check;"`
		echo "${check}"
done
