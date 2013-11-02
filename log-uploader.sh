#!/bin/sh


hostName="`hostname`"
timeStamp="`date +%m-%d-%y`"
fileName="${hostName}-${timeStamp}.zip"
storagePath="/root/"

echo "${storagePath}${fileName}"
/opt/couchbase/bin/cbcollect_info ${storagePath}${fileName}
if [ $? -eq 0 ]
then
	echo "Cbcollect info run successfully."
else
	echo "Collect info errored out - quittting"
	exit 1
fi

echo "Uploading ${fileName} to s3"
curl --upload-file ${storagePath}${fileName} http://s3.amazonaws.com/customers.couchbase.com/apple/
if [ $? -eq 0 ]
then
	echo "Cb collectinfo: ${fileName} uploaded successfully"
else
	echo "Upload failed"
	exit 1
fi
