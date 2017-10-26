#!/bin/sh


for id in `seq 1 55000` 
do
	echo "{\"statement\":\"select name,mail from test where userid=${id} and type='profile';\"}"
done

# select LoginDt from test where UserId=0 and Type="u";
# select BlockedUserId from test where UserId=100005 and Type="usb";
# select Handle from test where UserId=100005 and Type="u";
# select Views.ViewdByUserId from test where UserId=10005 and Type="pvd";


# Commmand line options 
# cbc-n1qlback -U couchbase://<server>/<bucket> -t <threadcount> -f <n1qlback file>

# Format for file
# {"statement":"select id,rs from `default` use keys['00000000000695788288']"}
# {"statement":"select id,rs from `default` use keys['00000000000814711087']"}
# {"statement":"select id,rs from `default` use keys['00000000000700791564']"}
# {"statement":"select id,rs from `default` use keys['00000000000985487543']"}
# {"statement":"select id,rs from `default` use keys['00000000000802134175']"}

# Monitoring active queries
# SELECT * FROM system:active_requests;
