#!/bin/bash 
# Require http://www.core.com.pl/svn2log
svn log -v --xml | svn2log.py -s -O -L -A -H -o changelog.txt

