#!/bin/sh

if [ $# -lt 1 ]
then
    echo "Usage: $0 clear"
    exit 1
fi

collection_interval="1"
hosts=`egrep -v 'localhost|Place|Type|${cluster}' /etc//hosts |awk '{print $2}'`
query_nodes="`grep query /etc/hosts | awk '{print $2;}'`"
data_nodes="`grep data /etc/hosts | awk '{print $2;}'`"


# Package sync
for host in ${hosts}
do
    query_node="false"
    echo ${query_nodes} | grep -q ${host}
    if [ $? -eq 0 ]
    then
        query_node="true"
    fi

    data_node="false"
    echo ${data_nodes} | grep -q ${host}
    if [ $? -eq 0 ]
    then
        data_node="true"
    fi

    echo "Clearing logs from: ${host}"
    ssh -i /root/.ssh/script_rsa -o StrictHostKeyChecking=no root@${host} "rm -f /root/packages/logs/*.raw" &
    if [ ${data_node} == "true" ]
    then
        echo "Clearing data logs"
        ssh -i /root/.ssh/script_rsa -o StrictHostKeyChecking=no root@${host} "rm -f /root/packages/logs/data* " &
    fi
    if [ ${query_node} == "true" ]
    then
        echo "Clearing query logs"
        ssh -i /root/.ssh/script_rsa -o StrictHostKeyChecking=no root@${host} "rm -f /root/packages/logs/query* " &
    fi
done
