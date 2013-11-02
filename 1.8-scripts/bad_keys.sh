#!/bin/sh

list="`cat busted`" 

for entry in ${list}
do
	echo "${entry} state:"
	id=`echo ${entry}|cut -d "_" -f2`
	/opt/couchbase/bin/sqlite3 default "select * from vbucket_states where vbid=${id}"
done
