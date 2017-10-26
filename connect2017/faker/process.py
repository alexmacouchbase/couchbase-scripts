#!/usr/bin/python
import sys
import json
import threading
import subprocess
from faker import Faker
fake = Faker()

def create( thread_id ):

    thread_end = ( thread_id * shard_size ) + start
    thread_start = thread_end - shard_size

    print "Starting thread: " + str( thread_id )
    print "Thread Start: " + str( thread_start )
    print "Thread End: " + str( thread_end )

    fileName = str( thread_id ) + ".json"
    fh = open( fileName, "a" )
    for j in range( thread_start, thread_end ):
        profile = fake.profile()
        del profile['current_location']
        profile['userid'] = j
        profile['type'] = "profile"
        fh.write( str(profile) + "\n" )
    fh.close()          




if len(sys.argv) != 4:
    print "usage: ", sys.argv[0], "<start> <end> <process_id>"
    sys.exit(1)

start = int( sys.argv[1] )
end = int( sys.argv[2] )
process_id = int( sys.argv[3] )

count = end - start
thread_count = 36
shard_size = count / thread_count

#thread end = ( threadId * shard_size) + start
#thread_start = thread_end - shard_size

create( process_id )

#threads = []
#for i in range ( 1, (thread_count + 1) ):
#    t = threading.Thread(target=create, args=(i,))
#    threads.append(t)
#    t.start()
