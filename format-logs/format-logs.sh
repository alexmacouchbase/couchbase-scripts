#!/bin/sh

usage="Usage: ${0} <path to folder with collect info files>"
if [ $# -ne 1 ]
then
	echo ${usage}
	exit 1
fi

path="${1}"
if [ -d ${path} ]
then
    echo "Searching ${path} for collect infos"
else
    echo ${usage}
    echo "Could not find folder"
    exit 1
fi


metrics="ep_max_size|high_wat|low_wat|mem_used|ep_couch_bucket|ep_value_size|ep_kv_size|curr_items_tot|ep_num_non_resident|version|vb_active_curr_items|active_perc_mem|replica_perc_mem|cmd_get|cmd_set|get_hits|get_misses|vb_active_ops_create|vb_active_ops_update|vb_replica_ops_create|vb_replica_ops_update|ep_bg_fetched|ep_bg_meta_fetched|vb_active_meta_data_memory|vb_replica_meta_data_memory"

tmpStats="stats-`date +%s`"
tmpResults="results-`date +%s`"
files="`ls ${path}/*.zip`"
outputFile="sizing-`date`.csv"

for file in ${files}
do
    echo "Working on file: ${file}"
    host=`basename ${file} | rev | cut -d"@" -f1 | cut -b5- | rev`
    echo "host: $host"
    statsFile="`unzip -l ${file} |grep stats.log|grep -v ns_server|awk '{print $4;}'`"
    echo "statsFile: $statsFile"
    unzip -p ${file} ${statsFile} > ${tmpStats}
    if [ $? -ne 0 ]
    then
        echo "Failed to unpack ${file}"
    fi
	length=`grep -n 'memcached stats checkpoint' ${tmpStats}|cut -d ':' -f1`

    head -${length} ${tmpStats} |egrep  -i "${metrics}" |egrep -v 'memcached_version|ep_version' | while IFS=":" read -r k v
    do
        case "$k" in
            *"curr_items_tot"* ) curr_items_tot=`echo $v | sed 's/^ *//g'` ;;
            *"ep_couch_bucket"* ) ep_couch_bucket=`echo $v | sed 's/^ *//g'` ;;
            *"ep_max_size"* ) ep_max_size=`echo $v | sed 's/^ *//g'` ;;
            *"ep_mem_high_wat"* ) ep_mem_high_wat=`echo $v | sed 's/^ *//g'` ;;
            *"ep_mem_low_wat"* ) ep_mem_low_wat=`echo $v | sed 's/^ *//g'` ;;
            *"ep_num_non_resident"* ) ep_num_non_resident=`echo $v | sed 's/^ *//g'` ;;
            *"mem_used"* ) mem_used=`echo $v | sed 's/^ *//g'` ;;
            *"vb_active_curr_items"* ) vb_active_curr_items=`echo $v | sed 's/^ *//g'` ;;
            *"vb_active_perc_mem"* ) vb_active_perc_mem=`echo $v | sed 's/^ *//g'` ;;
            *"vb_replica_perc_mem"* ) vb_replica_perc_mem=`echo $v | sed 's/^ *//g'` ;;
            *"ep_value_size"* ) ep_value_size=`echo $v | sed 's/^ *//g'` ;;
            *"ep_kv_size"* ) ep_kv_size=`echo $v | sed 's/^ *//g'` ;;
# cmd_get|cmd_set|get_hits|get_misses|vb_active_ops_create|vb_active_ops_update|vb_replica_ops_create|vb_replica_ops_update
            *"cmd_get"* ) cmd_get=`echo $v | sed 's/^ *//g'` ;;
            *"cmd_set"* ) cmd_set=`echo $v | sed 's/^ *//g'` ;;
            *"get_hits"* ) get_hits=`echo $v | sed 's/^ *//g'` ;;
            *"get_misses"* ) get_misses=`echo $v | sed 's/^ *//g'` ;;
            *"vb_active_ops_create"* ) vb_active_ops_create=`echo $v | sed 's/^ *//g'` ;;
            *"vb_active_ops_update"* ) vb_active_ops_update=`echo $v | sed 's/^ *//g'` ;;
            *"vb_replica_ops_create"* ) vb_replica_ops_create=`echo $v | sed 's/^ *//g'` ;;
            *"vb_replica_ops_update"* ) vb_replica_ops_update=`echo $v | sed 's/^ *//g'` ;;
            *"ep_bg_fetched"* ) ep_bg_fetched=`echo $v | sed 's/^ *//g'` ;;
            *"ep_bg_meta_fetched"* ) ep_bg_meta_fetched=`echo $v | sed 's/^ *//g'` ;;
            *"vb_active_meta_data_memory"* ) vb_active_meta_data_memory=`echo $v | sed 's/^ *//g'` ;;
            *"vb_replica_meta_data_memory"* ) vb_replica_meta_data_memory=`echo $v | sed 's/^ *//g'` ;;

            *"version"* )
                 echo \
                 "${ep_couch_bucket},\
                    ${host},\
                    ${ep_max_size},\
                    ${ep_mem_high_wat},\
                    ${ep_mem_low_wat},\
                    ${mem_used},\
                    ${vb_active_curr_items},,\
                    ${ep_value_size},,\
                    ${ep_kv_size},\
                    ${curr_items_tot}, \
                    ${ep_num_non_resident},\
                    ${vb_active_perc_mem},\
                    ${vb_replica_perc_mem}, \
                    Utilization, \
                    ${cmd_get}, \
                    ${cmd_set}, \
                    ${get_hits}, \
                    ${get_misses}, \
                    ${vb_active_ops_create}, \
                    ${vb_active_ops_update}, \
                    ${vb_replica_ops_create}, \
                    ${vb_replica_ops_update}, \
                    ${ep_bg_fetched}, \
                    ${ep_bg_meta_fetched}, \
                    ${vb_active_meta_data_memory}, \
                    ${vb_replica_meta_data_memory}" \
                >> ${tmpResults}
                echo "" >> ${tmpResults}
            ;;
        esac
    done
    > ${tmpStats}
done

echo "bucket,max_data_size,high_wat,low_wat,mem_used,item count,avg value size,ep_value_size,avg key size,ep_kv_size,curr_items_tot,ep_num_non_resident,vb_active_perc_mem,vb_replica_perc_mem,Memory Utilization, CMD Get, CMD Set, Get Hits, Get Misses, VB Active Create,VB Active Update, VB Replica Create, VB Replica Update, Disk reads, Meta Disk reads, Active Meta data memory, Replica Meta data memory, total meta data memory, percentage metadata utilization" >${outputFile}
bucketList="`cat ${tmpResults} | awk '{print $1;}' | sort | uniq`"
#new
cat ${tmpResults} |sort|uniq|sed s/' '//g >>${tmpResults}.1

for bucket in ${bucketList}
do
    echo "" >> ${outputFile}
    echo "${bucket}" >> ${outputFile}
    grep ${bucket} ${tmpResults}.1 | while read line
    do
        #echo ${line} | sed s/${bucket}//g >> ${outputFile}
        echo ${line} | grep -q "^,"
        if [ $? -ne 0 ]
        then
            echo ${line} | sed s/${bucket}//g >> ${outputFile}
        fi
    done
done

echo "" >> ${outputFile}
echo "Average value size = ep_value_size/(curr_items_tot-ep_num_non_resident)" >> ${outputFile}
echo "Average key size = ((ep_kv_size - ep_value_size - (curr_items_tot * 56)) / curr_items_tot" >> ${outputFile}
echo "Percentage meta data utilization = (vb_active_meta_data_memory + vb_replica_meta_data_memory) / ep_max_size" >> ${outputFile}
echo "Utilization = mem_used/ ep_max_size" >> ${outputFile}
echo "Sizing data saved to: ${outputFile}"

# Cleanup
rm ${tmpResults} ${tmpResults}.1 ${tmpStats}


