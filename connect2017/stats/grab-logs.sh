#!/bin/sh
mkdir -p remote
hosts=`egrep -v 'Place|Type|${cluster}' /etc//hosts |awk '{print $2}'`
#> ~/.ssh/known_hosts
# Package sync
for host in ${hosts}
do
	echo "Working on: ${host}"
	rsync -avzq -e "ssh -i /root/.ssh/script_rsa -o StrictHostKeyChecking=no" root@${host}:/root/packages/logs/* remote/
done
