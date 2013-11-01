A short script to check the resident memory usage of beam.smp and cleanly restart the process if it goes over a certain size – specified in kb.

```
[root@localhost ~]# ./beam_check.sh 800000
Beam.smp RSS: 793236
[root@localhost ~]# ./beam_check.sh 800000
Beam.smp RSS: 902236
Restarting beam.smp
curl: (52) Empty reply from server
[root@localhost ~]# ./beam_check.sh 800000
Beam.smp RSS: 129632
```
In the above example, I have set the script to watch for beam going over 800mb of ram usage.  When beam hits 902mb RSS on the second run of the script, the process is restarted and the curl: (52) Empty reply – is the expected response.  On the 3rd run we see that beam is now down at 129mb RSS.

Username and password for the Couchbase admin are required, Ive put these in at the top of the script and you can change these out for your environment.

Please run the script manually on one machine to verify it functions as expected in your environment, from there, you can put it in cron on a 5 minute schedule.  
```
*/5  * * * * <path>/beam_check.sh <2x standard beam RSS>
```