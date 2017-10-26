#!/usr/bin/python
import time
import sys
import os


def units( entry ):
    last = entry[-1]
    if last == '%':
        return entry[:-1]
    if  last == 'K':
        return entry[:-1]
    if last == 'M':
        return str( int( float( entry[:-1] ) * 1000 ) )
    if last == 'G':
        return str( int( float( entry[:-1] ) * 1000 * 1000 ) )

if len(sys.argv) != 3:
	print "Usage: ", sys.argv[0], "<atop file> <process to parse>"
	print "Atop to use: 'atop -R -w <filename> 5'"
	sys.exit(1)

file = sys.argv[1]
process = sys.argv[2]
tmp_file = "tmp-" + str(time.time())

command = "atop -p -r " + str(file) + " | egrep 'ATOP|" + str(process) + "' > " + str(tmp_file)
#print command
os.system(command)
entry=""
with open( tmp_file ) as f:
	print "timestamp,RSIZE,RDDSK,WRDSK,CPU,CMD"
	for line in f:
		if line.startswith('ATOP'):
			entry += line.split()[4]
		else:
			entry += ',' + units( line.split()[3] )      # resident set size
			entry += ',' + units( line.split()[5] )      # Reads from disk
			entry += ',' + units( line.split()[6] )      # Writes to disk
			entry +=  ',' + units( line.split()[9] )     # CPU %
                        entry += ',' + line.split()[10]              # CMD
			print entry
			entry=""
f.close()
command = "rm " + tmp_file
os.system(command)
