#!usr/bin/python
#example taken from http://www.cse.unsw.edu.au/~cs2041/14s2/lec/python/examples.pdf

import sys

line_count = 0
for line in sys.stdin:
    line_count += 1
print line_count," lines"

