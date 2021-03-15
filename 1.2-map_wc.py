#!/usr/bin/env python
 
import sys
import re

# read the input from stdin
for line in sys.stdin:
    # trim any leading and trailing spaces
    line = line.strip()
    line = re.sub(r'[^\w\s]','',line)

    # split the line into individual words
    words = line.split()
    # for each word in words, output key-value pair
    for word in words:
        # outputs the result to stdout
        # MapReduce Streaming API will take this output 
        # and feed as the input to the Reduce step
 
        # tab-delimited 
        # word count is always one
        print ('%s\t%s' % (word, 1))
