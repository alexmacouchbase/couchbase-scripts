#!/bin/sh

list="`grep query /etc/hosts | awk '{print $2;}'`"
for host in ${list}
do
	curl -u Administrator:password -v http://${host}:8093/query/service -d 'statement=PREPARE userid FROM select name,mail from default where userid=$id and type="profile"'
done

# Test
# curl -u Administrator:password -v http://localhost:8093/query/service -d 'prepared="blocked_users"&$id=100010’
#curl -v http://localhost:8093/query/service -d 'statement=PREPARE airport_cities FROM    select airportname from `travel-sample` where city=$city limit 2'
#{"prepared":"airport_cities","$city":"New York"}
#{"prepared":"airport_cities","$city":"San Francisco"}
#{"prepared":"airport_cities","$city":"San Diego"}
