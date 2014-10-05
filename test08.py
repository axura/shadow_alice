#!/usr/bin/python

#testing break and continue functions
x = 0
while x <= 10:
	if x % 4 == 0:
		print "divisible by 4"
		x += 1
	elif x % 3 == 0:
		print "divisible by 3"
		continue
	elif x > 8:
		break
	else:
		x += 1

