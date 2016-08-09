#!/bin/sh
host="localhost"
user="Administrator"
password="password"
bucket="default"
list="`ls *.json`"
path="`pwd`"

for i in ${list}
do
	collectionName=`echo ${i}|cut -d '.' -f1`
	/opt/couchbase/bin/cbbackupmgr json \
		--host http://${host}:8091 \
		--username ${user} \
		--password ${password} \
		--bucket=${bucket} \
		--dataset file:///${path}/${collectionName}.json  \
		--format list \
		--generate-key ${collectionName}::%_id%;
done
