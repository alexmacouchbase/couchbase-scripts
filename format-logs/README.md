Simple script to take a folder of collect info's and extract from the logs:

On  per node, per bucket basis:
- Bucket ram allocation
- high/low watermark
- memory used
- Item count
- ep_value size
- curr_items_tot
- ep_num_non_resident
- Active/Replica resident %

This information can be used to then calculate out Average value size with the formula:
Average value size = ep_value_size/(curr_items_tot-ep_num_non_resident)

The script will generate a RAW csv file with timestamp:
sizing-Sat Nov  2 08:13:06 PDT 2013.csv	sizing-from-script.csv

Which from there can be formatted and the formula for Average value size added in as well.
formatted-sizing-from-script.xls

This script will currently work on collect_infos from 1.8.1->2.2x of Couchbase Server


```
MacBook-Pro:format-logs user$ ls -alh
total 485248
drwxr-xr-x  13 user  staff   442B Nov  2 08:12 .
drwxr-xr-x   8 user  staff   272B Nov  1 13:02 ..
-rwxr-xr-x   1 user  staff   3.0K Nov  1 13:02 format-logs.sh
-rw-r--r--   1 user  staff    39M Nov  1 13:02 pod4-lapp01.zip
-rw-r--r--   1 user  staff    39M Nov  1 13:02 pod4-lapp02.zip
-rw-r--r--   1 user  staff    39M Nov  1 13:02 pod4-lapp03.zip
-rw-r--r--   1 user  staff    40M Nov  1 13:02 pod4-lapp04.zip
-rw-r--r--   1 user  staff    40M Nov  1 13:02 pod4-lapp05.zip
-rw-r--r--   1 user  staff    40M Nov  1 13:02 pod4-lapp06.zip
MacBook-Pro:format-logs user$ ./format-logs.sh 
Usage: ./format-logs.sh <path to folder with collect info files>
MacBook-Pro:format-logs user$ ./format-logs.sh `pwd`
Searching /Users/user/Dropbox/work-couchbase/git/couchbase-scripts/format-logs for collect infos
Working on file: /Users/user/Dropbox/work-couchbase/git/couchbase-scripts/format-logs/pod4-lapp01.zip
Working on file: /Users/user/Dropbox/work-couchbase/git/couchbase-scripts/format-logs/pod4-lapp02.zip
Working on file: /Users/user/Dropbox/work-couchbase/git/couchbase-scripts/format-logs/pod4-lapp03.zip
Working on file: /Users/user/Dropbox/work-couchbase/git/couchbase-scripts/format-logs/pod4-lapp04.zip
Working on file: /Users/user/Dropbox/work-couchbase/git/couchbase-scripts/format-logs/pod4-lapp05.zip
Working on file: /Users/user/Dropbox/work-couchbase/git/couchbase-scripts/format-logs/pod4-lapp06.zip
Sizing data saved to: sizing-Sat Nov  2 08:13:06 PDT 2013.csv
MacBook-Pro:format-logs user$ 
```