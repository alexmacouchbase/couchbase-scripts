#!/bin/sh

function cluster_status( $serverIp ) {
	# Get stats
	tmpFile="/tmp/stats"
	> $tmpFile

	for bucket in $bucketList
	do
		/opt/couchbase/bin/cbstats $serverIp:11211 all $bucket | egrep "ep_queue_size|ep_flusher_todo|ep_tap_rebalance_count" >> $tmpFile
	done	

	# grab dwq stats
	ep_queue_size="`egrep ep_queue_size $tmpFile`"
	
	# grab tap conns
	
	# check if dwq > a million per node or if tap conns for rebalance still live - if so, return 1, if not, return 0	

}

function list_servers( $serverIp $userName $password ) {
	server_list="`/opt/couchbase/bin/couchbase-cli server-list -c $serverIp:8091 -u $userName -p $password |cut -d ':' -f1|cut -d ' ' -f2`"
	return $server_list
}

function list_buckets( $serverIp $userName $password ) {
	bucket_list="`/opt/couchbase/bin/couchbase-cli bucket-list -c $serverIp:8091 |grep -v '^ '`"
	return $bucket_list

}

function rebalance( $nodesToAdd $nodesToRemove ) {
	/opt/couchbase/bin/couchbase-cli rebalance -c $serverIp --server-add=$nodesToAdd --server-remove=$nodesToRemove -u $userName -p $password 
	if [ $? -eq 0 ]
	then
		return 0
	else
		return 1
	fi
}


if [ $# -ne 5 ]
then
	echo "Usage: $0 <ip of node in cluster to connect to> <username> <password> <comma seperated list of servers to add> <comma seperated list of servers to revmoe>"
	echo "Example: $0 10.4.2.3 Administrator password 10.4.2.4,10.4.2.5,10.4.2.6 10.4.2.10,10.4.2.11,10.4.2.12"
	echo "Example: connecting to cluster node 10.4.2.3 with user name Administrator and password password.  Adding nodes 10.4.2.4, 10.4.2.5, 10.4.2.6 and removing nodes 10.4.2.10, 10.4.2.11, 10.4.2.12"
	exit 1
fi

serverIp=$1
userName=$2
password=$3
nodesToAdd=$4
nodesToRemove=$5

serverList=list_servers()
bucketList=list_buckets()

while ( rebalance() -ne 0 ) do
	rebalance()
	if ( cluster_status) -eq 1 ) 
	then
		sleep 300
	fi
done

