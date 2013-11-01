#!/bin/sh
user_name="Administrator"
user_pass="password"
memcached_port="11210"
rest_port="8091"
bin_path="/opt/couchbase/bin"


function bytesToMb() {
	mb=`echo "scale=4; ${1}/1024/1024"|bc|cut -d . -f1`
	echo ${mb}
}
function percentage() {
	percent=`echo "scale=4; (${1}/${2})*100"|bc|cut -d . -f1`
	echo ${percent}
}
function verify() {
	serverIp=${1}
	bucketName=${2}
	metric=${3}
	newValue=${4}
	serverValue=`${bin_path}/cbstats ${serverIp}:${memcached_port} all -b ${bucket_name}|egrep ${metric}|sed 's/ //g'|cut -d ':' -f2`
	if [ ${newValue} -eq ${serverValue} ]
	then
		echo "${serverIp} - ${metric}: PASSED"
	else
		echo "${serverIp} - ${metric}: FAILED"
	fi
}


# Grab inputs
usage="Usage: ${0} <bucket name> <high wat %> <low wat %>\nExample: ${0} default 85 60"
if [ $# -ne 3 ]
then
	echo -e ${usage}
	exit 1
fi

bucket_name="${1}"
high_wat_pct="${2}"
low_wat_pct="${3}"

# grab server list
server_list="`${bin_path}/couchbase-cli server-list --cluster=localhost:${rest_port} -u ${user_name} -p ${user_pass}|cut -d ' ' -f2|cut -d ':' -f1`"

# Check bucket allocation
server_stats="`${bin_path}/cbstats localhost:${memcached_port} all -b ${bucket_name}|egrep 'max_data_size|low_wat|high_wat' | sed 's/ //g'`"
for stat in ${server_stats}
do
	case "${stat}" in
 		*"ep_max_data_size"* ) bucket_allocation="`echo ${stat}|cut -d ':' -f2`" ;;
        *"ep_mem_high_wat"* ) current_high_wat="`echo ${stat}|cut -d ':' -f2`" ;;
        *"ep_mem_low_wat"* ) current_low_wat="`echo ${stat}|cut -d ':' -f2`" ;;
	esac
done

printf "Current bucket allocation:\t%sb\t%smb \t100%%\n" ${bucket_allocation}  $(bytesToMb $bucket_allocation)
printf "Current high watermark:\t\t%sb\t%smb \t%s%% \n" ${current_high_wat} $(bytesToMb $current_high_wat) $(percentage $current_high_wat $bucket_allocation)
printf "Current low watermark:\t\t%sb\t%smb \t%s%% \n"	${current_low_wat} $(bytesToMb $current_low_wat) $(percentage $current_low_wat $bucket_allocation)
printf "\n"

# do math to calculate new high/low wat
new_high_wat=`echo "scale=4; .${high_wat_pct} * ${bucket_allocation}" | bc | cut -d . -f1`
new_low_wat=`echo "scale=4; .${low_wat_pct} * ${bucket_allocation}" | bc | cut -d . -f1`
printf "New high watermark:\t\t%sb\t%smb \t%s%% \n" ${new_high_wat} $(bytesToMb $new_high_wat) $(percentage $new_high_wat $bucket_allocation)
printf "New low watermark:\t\t%sb\t%smb \t%s%% \n"	${new_low_wat} $(bytesToMb $new_low_wat) $(percentage $new_low_wat $bucket_allocation)

printf "\nServers this will be applied to:\n"
for server in ${server_list}
do
	printf "\t%s\n" ${server}
done

# apply new high/low wat
echo "Do you wish to change to the newly calculated watermarks?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) 
			for server in ${server_list}
			do
				${bin_path}/cbflushctl ${server}:${memcached_port} set mem_high_wat ${new_high_wat} ${bucket_name} &> /dev/null 
					if [ $? -ne 0 ]; then echo "FAILED setting high_wat on ${server}"; fi
				${bin_path}/cbflushctl ${server}:${memcached_port} set mem_low_wat ${new_low_wat} ${bucket_name} &> /dev/null 
					if [ $? -ne 0 ]; then echo "FAILED setting low_wat on ${server}"; fi
						
				# Verify on each machine
				verify ${server} ${bucket_name} mem_high_wat ${new_high_wat}
				verify ${server} ${bucket_name} mem_low_wat ${new_low_wat}
			done
			break
		;;
        No ) 
			echo "Exiting script, no changes applied to cluster"
			exit 1
		;;
    esac
done






