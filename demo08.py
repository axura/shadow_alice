#!/usr/bin/python

#Project Euler problem 3: finding the largest prime number of factor a large value

numm = 600851475143
newnumm = numm
largestFact = 0
counter = 2

while counter * counter <= newnumm :
	if newnumm % counter == 0 :
		newnumm = newnumm / counter
		largestFact = counter
	else :
		counter++

if newnumm > largestFact : 
	largestFact = newnumm

