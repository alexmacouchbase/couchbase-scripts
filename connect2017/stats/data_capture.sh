#!/bin/sh

if [ $# -lt 1 ]
then
    echo "Usage: $0 <start|stop> <start message>"
    exit 1
fi

collection_interval="1"
hosts=`egrep -v 'localhost|Place|Type|${cluster}' /etc//hosts |awk '{print $2}'`
query_nodes="`grep query /etc/hosts | awk '{print $2;}'`"
data_nodes="`grep data /etc/hosts | awk '{print $2;}'`"
date=`date "+%F-%T"`

option="${1}"
message="${2}-${date}"

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

    if [ ${option} == "start" ]
    then
        atop_file_name="atop-${message}-${host}.raw"
        echo "Working on ${host}"
        echo "atop saving to : ${atop_file_name}"
	    ssh -i /root/.ssh/script_rsa -o StrictHostKeyChecking=no root@${host} "nohup  atop -R -w /root/packages/logs/${atop_file_name} ${collection_interval} &" &
        if [ ${data_node} == "true" ]
        then
            data_file_name="data-${message}-${host}.cbstats"
            echo "data saving to : ${data_file_name}"
	        ssh -i /root/.ssh/script_rsa -o StrictHostKeyChecking=no root@${host} "cd /root/packages/packages-connect/stats/ ; nohup ./data_stats.sh /root/packages/logs/${data_file_name} &" &
        fi
        if [ ${query_node} == "true" ]
        then
            query_file_name="query-${message}-${host}.json"
            echo "query saving to : ${query_file_name}"
	        ssh -i /root/.ssh/script_rsa -o StrictHostKeyChecking=no root@${host} "cd /root/packages/packages-connect/stats/ ; nohup ./query_stats.sh /root/packages/logs/${query_file_name} &" &
        fi
    else
        echo "Shutting down ATOP on: ${host}"
        ssh -i /root/.ssh/script_rsa -o StrictHostKeyChecking=no root@${host} "killall atop" 
        if [ ${data_node} == "true" ]
        then
            echo "Shutting down data_stats on: ${host}"
            ssh -i /root/.ssh/script_rsa -o StrictHostKeyChecking=no root@${host} "killall data_stats.sh"
        fi
        if [ ${query_node} == "true" ]
        then
            echo "Shutting down query_stats on: ${host}"
            ssh -i /root/.ssh/script_rsa -o StrictHostKeyChecking=no root@${host} "killall query_stats.sh"
        fi
    fi
done
