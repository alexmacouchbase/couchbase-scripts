#!/bin/sh
# /opt/couchbase/bin/memcached -X /opt/couchbase/lib/memcached/stdin_term_handler.so -X /opt/couchbase/lib/memcached/file_logger.so,cyclesize=104857600;sleeptime=19;filename=/opt/couchbase/var/lib/couchbase/logs/memcached.log -l 0.0.0.0:11210,0.0.0.0:11209:1000 -p 11210 -E /opt/couchbase/lib/memcached/bucket_engine.so -B binary -r -c 10000 -e admin=_admin;default_bucket_name=default;auto_create=false

echo "$@"
