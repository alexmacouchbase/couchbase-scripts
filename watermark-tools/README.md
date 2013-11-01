This is a script to automate the process of resetting high/low watermarks consistently across production Couchbase clusters.

The script is fairly simple.  You will need to deploy it on one machine in the cluster(can be any machine, does not matter.).  There are some variables that you will need to set that are specific to your cluster at the top of the script:
user_name="Administrator"
user_pass="password"
memcached_port="11210"
rest_port="8091"
bin_path="/opt/couchbase/bin"

From there, running it without parameters will bring up help.  You will need to pass in the bucket you would like this configuration to apply to as well as new high and low watermarks as basic numbers.  85% = ’85'
[root@ip-10-196-14-221 ~]# ./reset-watermarks.sh  
Usage: ./reset-watermarks.sh <bucket name> <high wat %> <low wat %>
Example: ./reset-watermarks.sh default 85 60

When you run the script( example below against a bucket named ‘radium’, changing high_wat to 80% and low_wat to 70% ) it will show you the current bucket allocation, watermarks as well as the new settings.  These are represented in bytes, megabytes and percentage.  

Lastly, the script will show you the servers in the cluster that it will apply this to and await your confirmation:
[root@ip-10-196-14-221 ~]# ./reset-watermarks.sh  radium 80 70
Current bucket allocation:	897581056b	856mb 	100%
Current high watermark:		673185792b	642mb 	75% 
Current low watermark:		538548633b	513mb 	59% 

New high watermark:		718064844b	684mb 	79% 
New low watermark:		628306739b	599mb 	69% 

Servers this will be applied to:
 	10.160.158.129
 	10.160.93.181
 	10.160.95.18
 	10.188.13.22
 	10.188.16.38
 	10.188.9.198
 	10.196.108.182
 	10.196.14.221
 	10.196.23.60
 	10.196.3.121
 	10.196.3.244
 	10.196.33.182
 	10.196.35.139
 	10.196.38.89
 	10.196.70.166
 	10.197.10.139
 	10.197.18.75
 	10.197.26.11
 	10.197.26.39
 	10.197.30.89
Do you wish to change to the newly calculated watermarks?
1) Yes
2) No
#? 1

Confirming with ‘1’ will apply this to the cluster, confirming with ‘2’ will exit the script.

If the changes are applied, the new high/low wat will be applied to each machine in the cluster and from there the script will also check the stats on the machine after applying the configuration to ensure that the change took place:
10.160.158.129 - mem_high_wat: PASSED
10.160.158.129 - mem_low_wat: PASSED
10.160.93.181 - mem_high_wat: PASSED
10.160.93.181 - mem_low_wat: PASSED
10.160.95.18 - mem_high_wat: PASSED
10.160.95.18 - mem_low_wat: PASSED
10.188.13.22 - mem_high_wat: PASSED
10.188.13.22 - mem_low_wat: PASSED
10.188.16.38 - mem_high_wat: PASSED
10.188.16.38 - mem_low_wat: PASSED
10.188.9.198 - mem_high_wat: PASSED
10.188.9.198 - mem_low_wat: PASSED
10.196.108.182 - mem_high_wat: PASSED
10.196.108.182 - mem_low_wat: PASSED
10.196.14.221 - mem_high_wat: PASSED
10.196.14.221 - mem_low_wat: PASSED
10.196.23.60 - mem_high_wat: PASSED
10.196.23.60 - mem_low_wat: PASSED
10.196.3.121 - mem_high_wat: PASSED
10.196.3.121 - mem_low_wat: PASSED
10.196.3.244 - mem_high_wat: PASSED
10.196.3.244 - mem_low_wat: PASSED
10.196.33.182 - mem_high_wat: PASSED
10.196.33.182 - mem_low_wat: PASSED
10.196.35.139 - mem_high_wat: PASSED
10.196.35.139 - mem_low_wat: PASSED
10.196.38.89 - mem_high_wat: PASSED
10.196.38.89 - mem_low_wat: PASSED
10.196.70.166 - mem_high_wat: PASSED
10.196.70.166 - mem_low_wat: PASSED
10.197.10.139 - mem_high_wat: PASSED
10.197.10.139 - mem_low_wat: PASSED
10.197.18.75 - mem_high_wat: PASSED
10.197.18.75 - mem_low_wat: PASSED
10.197.26.11 - mem_high_wat: PASSED
10.197.26.11 - mem_low_wat: PASSED
10.197.26.39 - mem_high_wat: PASSED
10.197.26.39 - mem_low_wat: PASSED
10.197.30.89 - mem_high_wat: PASSED
10.197.30.89 - mem_low_wat: PASSED


Re-running the script afterwards with the same options should show matching current/low watermarks.  Note that the script will check for current watermarks against localhost and is not representative of the settings on the entire cluster.
[root@ip-10-196-14-221 ~]# ./reset-watermarks.sh  radium 80 70
Current bucket allocation:	897581056b	856mb 	100%
Current high watermark:		718064844b	684mb 	79% 
Current low watermark:		628306739b	599mb 	69% 

New high watermark:		718064844b	684mb 	79% 
New low watermark:		628306739b	599mb 	69% 

Servers this will be applied to:
 	10.160.158.129
 	10.160.93.181
 	10.160.95.18
 	10.188.13.22
 	10.188.16.38
 	10.188.9.198
 	10.196.108.182
 	10.196.14.221
 	10.196.23.60
 	10.196.3.121
 	10.196.3.244
 	10.196.33.182
 	10.196.35.139
 	10.196.38.89
 	10.196.70.166
 	10.197.10.139
 	10.197.18.75
 	10.197.26.11
 	10.197.26.39
 	10.197.30.89
Do you wish to change to the newly calculated watermarks?
1) Yes
2) No
#? 2
Exiting script, no changes applied to cluster

I have tested this against a 3 and 20 node cluster of 1.8.1 nodes to confirm that it works as expected.  Note that while there is some error checking in the scripts – mainly around application of config – there is almost none on input handling.  Which means you can put in a nonexistent bucket for this to apply to or a 7% watermark.  Please double check the new watermark values before confirming that the script should run.
