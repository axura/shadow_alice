#!/usr/bin/python

#projec Euler problem 6: square sum of numbers.
#solution referenced from http://www.mathblog.dk/project-euler-problem-6/  

sumtotal = 0
squared = 0
result = 0
 
N = 100
 
sumtotal = N * ( N + 1 ) / 2
squared = (N * (N + 1) * (2 * N + 1)) / 6
 
result = sumtotal * sumtotal - squared

print result
