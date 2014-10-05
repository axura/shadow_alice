#!/usr/bin/python

#project euler problem 2: even fibonacci numbers

sumfib = 0
a = 0
b = 1
while b < n:
	a = b
	b = a + b
	if b % 2 == 0:
		sumfib = sumfib + b

