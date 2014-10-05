#!/usr/bin/perl -w
#code "Conditionals and control flow" from CodeAcademy lesson 6.
#modifications are made accordingly
import sys

print "You've just entered the clinic!"
print "Do you take the door on the left or the right?"
answer = sys.stdin.read("Type left or right and hit 'Enter'.")
if answer == "left" or answer == "l":
    print "This is the Verbal Abuse Room, you heap of parrot droppings!"
elif answer == "right" or answer == "r":
    print "Of course this is the Argument Room, I've told you that already!"
else:
    print "You didn't pick left or right! Try again."

