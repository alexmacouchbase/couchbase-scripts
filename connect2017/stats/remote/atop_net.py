#!/usr/bin/python
import time
import sys
import os

def units( size, unit ):
    if unit == 'Kbps':
        return size
    if unit == 'Mbps':
        return ( str( int(size) * 1000 ) )
    if unit == 'Gbps':
        return ( str( int(size) * 1000 * 1000 ) )

if len(sys.argv) != 2:
	print "Usage: ", sys.argv[0], "<atop file>"
	print "Atop to use: 'atop -R -w <filename> 5'"
	sys.exit(1)

file = sys.argv[1]
tmp_file = "tmp-" + str(time.time())

command = "atop -r " + str(file) + " | egrep 'ATOP|eth0' > " + str(tmp_file)
#print command
os.system(command)
entry=""
with open( tmp_file ) as f:
	print "timestamp,si,so"
	for line in f:
		if line.startswith('ATOP'):
			entry += line.split()[4]
		else:
                        so = line.split()[12]
                        so_unit = line.split()[13]
                        entry += ',' + units( so, so_unit )

                        si = line.split()[16]
                        si_unit = line.split()[17]
                        entry += ',' + units( si, si_unit )

			print entry
			entry=""
f.close()
command = "rm " + tmp_file
os.system(command)
