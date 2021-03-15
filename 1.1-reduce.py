#!/usr/bin/python
import sys
last_host = None
last_count = 0
count = 0
host = None
for line in sys.stdin:
    host, count = line.split('\t')
    count = int(count)
    if last_host == host:
        last_count += count
    else:
        if last_host:
            print ('%s\t%s' % (last_host, last_count))
        last_host = host
        last_count = count
if last_host == host:
    print ('%s\t%s' % (last_host, last_count))
