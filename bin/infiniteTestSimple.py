#!/usr/bin/python
# -*- coding: utf-8 -*-

import MySQLdb
import sys
import os
import fcntl
import time
#import multiprocessing - new in python 2.6...

import TestOptionsSimple
from TestOptionsSimple import *




if __name__ == "__main__":
#   try:
    options = TestOptionsSimple(sys.argv[1:])
    options.printout()
    strR = singularRingStrFromOptions(options)

    strGetR = singularRingProcFromOptions(options);
    print "getRing:" ,strGetR
    strGetGenTable = singularGenTableProcFromOptions(options);
    print "genTable:" ,strGetGenTable

    print "logfile prefix:" ,logfilePrefixFromOptions(options)

    #options.printCommandLineOptions()
