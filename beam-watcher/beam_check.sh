#!/bin/sh

user_name="Administrator"
user_pass="password"

if [ $# -ne 1 ]
then
	echo "Usage: $0 <RSS usage to restart beam.smp at - in kb>"
	echo "Example: restart beam.smp at 2gb RSS"
	echo "$0 2000000"
	exit 1
fi

beam_rss_cutoff="${1}"
# find beam child process.
beam_ids="` ps -aef|grep beam.smp|grep -v grep|awk '{print $2","$3;}'`"
for id in ${beam_ids}
do
	pid="`echo ${id} | cut -d ',' -f1`"
	ppid="`echo ${id} | cut -d ',' -f2`"
	
	if [ ${ppid} -ne 1 ]
	then
		rss="`ps v ${pid}|grep beam.smp|awk '{print $8;}'`"
		echo "Beam.smp RSS: ${rss}"
		if [ ${rss} -gt ${beam_rss_cutoff} ]
		then
			echo "Restarting beam.smp"
			curl --data 'erlang:halt().' -u ${user_name}:${user_pass} http://localhost:8091/diag/eval
		fi 
	fi
done
