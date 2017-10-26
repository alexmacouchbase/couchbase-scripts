#!/bin/sh

if [ $# -ne 1 ]
then
    echo "Usage: $0 <projector.maxCpuPercent>"
    exit 1
fi

percentage="${1}"
indexer="`grep index /etc//hosts | head -1 | awk '{print $3;}'`"

curl ${indexer}:9102/settings -u Administrator:password -X POST -d "{\"projector.maxCpuPercent\":${percentage}}"
