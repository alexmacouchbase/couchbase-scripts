#!/bin/sh

if [ $# -ne 4 ]
then
     echo "Usage: $0 <ip> <user name> <password> <customer>"
	 exit 1
fi
ip=$1
user=$2
pass=$3
customer=$4
date=`date +%Y%m%d-%H%M%S`
ec2_url="https://customers.couchbase.com.s3.amazonaws.com"

echo "Grabbing Diag"
curl  --user ${user}:${pass} http://${ip}:8091/diag > ${ip}-diag

echo "Compressing"
tar -czvf ${ip}-diag-${date}.tar.gz ${ip}-diag

ls -alh ${ip}*

filename="${ip}-diag-${date}.tar.gz"
echo "Uploading ${filename} to ec2"
curl -F key=${customer}/${filename}  -F file=@${filename} ${ec2_url} 
if [ $? -eq 0 ]
then
	echo "Successfully uploaded ${filename} to: ${ec2_url}/${customer}/${filename}"
else
	echo "Upload of ${filename} failed}"
	exit 1
fi

