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


metrics="max_data_size|high_wat|low_wat|mem_used|ep_dbname|ep_value_size|curr_items_tot|ep_num_non_resident|version|vb_active_curr_items|active_perc_mem|replica_perc_mem"
tmpStats="stats-`date +%s`"
tmpResults="results-`date +%s`"
files="`ls ${path}/*.zip`"
outputFile="sizing-`date`.csv"

for file in ${files}
do
    echo "Working on file: ${file}"
    host=`basename ${file}|cut -d '.' -f1`
    statsFile="`unzip -l ${file} |grep stats.log|grep -v ns_server|awk '{print $4;}'`"
    #clean windows files with col -b
    unzip -p ${file} ${statsFile} | col -b > ${tmpStats}
    if [ $? -ne 0 ]
    then
        echo "Failed to unpack ${file}"
    fi

    head -10000 ${tmpStats} |egrep  -i "${metrics}" |grep -v ep_version | while IFS=":" read -r k v
    do
        case "$k" in
            *"curr_items_tot"* ) curr_items_tot=`echo $v|sed 's/^ *//g'` ;;
            *"ep_dbname"* ) ep_dbname=`echo $v| tr '/' ' ' | tr '\\' ' ' | awk '{ print $NF }'` ;;
            *"ep_max_data_size"* ) ep_max_data_size=`echo $v|sed 's/^ *//g'` ;;
            *"ep_mem_high_wat"* ) ep_mem_high_wat=`echo $v|sed 's/^ *//g'` ;;
            *"ep_mem_low_wat"* ) ep_mem_low_wat=`echo $v|sed 's/^ *//g'` ;;
            *"ep_num_non_resident"* ) ep_num_non_resident=`echo $v|sed 's/^ *//g'` ;;
            *"mem_used"* ) mem_used=`echo $v|sed 's/^ *//g'` ;;
            *"vb_active_curr_items"* ) vb_active_curr_items=`echo $v|sed 's/^ *//g'` ;;
            *"vb_active_perc_mem"* ) vb_active_perc_mem=`echo $v|sed 's/^ *//g'` ;;
            *"vb_replica_perc_mem"* ) vb_replica_perc_mem=`echo $v|sed 's/^ *//g'` ;;
            *"ep_value_size"* ) ep_value_size=`echo $v|sed 's/^ *//g'` ;;
		    *"version"* ) 
                 echo \
                 "${ep_dbname},\
                    ${host},\
                    ${ep_max_data_size},\
                    ${ep_mem_high_wat},\
                    ${ep_mem_low_wat},\
                    ${mem_used},\
                    ${vb_active_curr_items},,\
                    ${ep_value_size},\
                    ${curr_items_tot}, \
                    ${ep_num_non_resident},\
                    ${vb_active_perc_mem},\
                    ${vb_replica_perc_mem}" \
                >> ${tmpResults}
			;;
	    esac
    done 
    > ${tmpStats}
done 

echo ",max_data_size,high_wat,low_wat,mem_used,item count,avg value size,ep_value_size,curr_items_tot,ep_num_non_resident,vb_active_perc_mem,vb_replica_perc_mem" >${outputFile}
bucketList="`cat ${tmpResults}|awk '{print $1;}' |sort|uniq`"
for bucket in ${bucketList}
do
    echo "${bucket}" >> ${outputFile}
    grep ${bucket} ${tmpResults} | while read line
    do
        echo ${line} | sed s/${bucket}//g >> ${outputFile}
    done
done
echo "Average value size = ep_value_size/(curr_items_tot-ep_num_non_resident)" >> ${outputFile}
echo "Sizing data saved to: ${outputFile}"
rm ${tmpStats} ${tmpResults}