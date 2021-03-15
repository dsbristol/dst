#!/usr/bin/python
import sys
for line in sys.stdin:
  if not 'invalid user' in line:
    host = line.split(':')[0]
    print('%s\t%s' % (host, 1))
