# -*- coding: utf-8 -*-
import getopt
import argparse
import sys

# todo: introduce random minpoly parameter
# logfile name from options : partly done
# singular should print full ring data in logfile monitor file; also full genParam data in logfile and monitor file
# prog which generates same example for two systems
# proc which runs same examples for two or more systems
# proc which compares result from examples which were ran by two systems
## stores a unique .bug file in case the result differ
# translate Singular ring to M2 and vice versa
# translate M2 ideal to Singular and vice versa
# same for Maple and Magma
# collect statistic for a test with same ring and random options. x-axis: singular commit id, y-axis: error rate (error per number of random examples)
## do this i a way that it is required only once grep the log file to count the number of examples and number of bugs, e.g. by renaming the logfile
## after collecting statistics and writing statistics to another file or a database
# OPTIONAL: write experiment parameters into a log file in a way that the experiment could be restarted.
# write a script which takes a log file and extract the used experiment parameters and restart the test.
# store *.bug files in a separate subfolder
#
# SINGULAR -v should also show the git commit id
# gui: select all running tests and stop them
# gui: rebuild tested Singular 
## gui: select all running tests and stop them
## gui: check coverage of experiment parameters
#bachelor thesis: student should define a useful automated process, e.g. a bug moved to 'fixed' if fixed or get tag 'reported' (and corresponding link)
#bachelor: it should be possible to view all bugs for a certain function or for a certain template
#
# eventually do not include the test parameters in the bug file name but write them inside the file in a way that 

# a gui to control the random parameters and run the tests


# char_7__minpoly__npars_1__nvars_620__dp__maxCoeff_333__degree_101-100__maxTerms_2__maxGens_5__redSB_redTail__id_0
#
# transforms ordering string like "(dp(3),lp(1))" to '_dp_3_lp_1_'

# offtopic
# test all bugs: 
#bugs=$(ls log/test.quotient.ZZ.in/*.bug ); for bug in $bugs; do ./singular-spielwiese -q <  $bug; done;


# it is slower, but divide the test into 'writing a single test input' and checking it then

# vary call depth for tests
# random prime characteristic?

# filter setting files or default settings
# same settings sets for bash script, for python script and for gui
# - but how to do this for random mp ?
# or how to use random char?
# how to generate random ordering?
# preconfigs for - rings, -ideals, and opts 

# autotry parameters:  time or memory usage per example should not be too big
# mv input to old_templates
# mv scripts to bin/

# coverage criteria - per test class?
## random char
## random minpoly
## random block ordering
## all supported orderings


def simplifyOrdStr(ordstr):
  tmp = ordstr
  tmp= tmp.replace('(','_')
  tmp= tmp.replace(')','_')
  tmp= tmp.replace(',','_')
  tmp= tmp.replace('___','_')
  tmp= tmp.replace('__','_')
  tmp= tmp.strip('_')
  return tmp

def countDifferentOrdBlocks(ordstr):
  ABC="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  simpleord = simplifyOrdStr(ordstr)
  s =simpleord.split('_')
  L = set([])
  for entry in s:
    if len(entry)>0 and entry[0] in ABC and not entry=="C":
      L.add(entry)
  return len(L)
# check if we have at least two 
def isBlockOrd(ordstr):
  simpleord = simplifyOrdStr(ordstr)
  if (len(simpleord)>4):
    #if not isMixed(ordstr):
      return True
  return False

def isMixed(ordstr):
  ABC="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  simpleord = simplifyOrdStr(ordstr)
  l = countDifferentOrdBlocks(ordstr(
  if l<=1:
    return False
  return True
  
  

def logfilePrefixFromOptions(opts):
  
  lPrefix = "char_" + str(opts.char_m)

  if (not None == opts.minPoly_m) and (not "0"==opts.minPoly_m):
    lPrefix = lPrefix + "__minpoly" 

  
  if opts.numPars_m>0:
    lPrefix = lPrefix  +"__npars_" +  str(opts.numPars_m)

  lPrefix = lPrefix + "__nvars_" +  str(opts.numVars_m)
  
  #tmp = opts.ordstr_m
  #tmp = simplifyOrdStr(tmp)
  
  if isMixed(opts.ordstr_m):
    lPrefix = lPrefix + "__mixed"
  elif isBlockOrd(opts.ordstr_m):
    lPrefix = lPrefix + "__block"
  lPrefix = lPrefix + "__" +simplifyOrdStr(opts.ordstr_m)

  #############################
  lPrefix = lPrefix + "__maxCoeff_" + str(opts.maxAbsCoeff_m) 
  lPrefix = lPrefix + "__deg_" + str(opts.minDegree_m )   
  lPrefix = lPrefix + "_to_" + str(opts.maxDegree_m )   
  lPrefix = lPrefix + "__maxTerms_" + str(opts.maxTerms_m)     
  lPrefix = lPrefix + "__maxGens_" + str(opts.maxGens_m )


  if  opts.bFractions_m:
    lPrefix = lPrefix + "__fractionsOn"


  if (len(opts.optionFlags_m)>0):
    lPrefix = lPrefix + "_"
    for of in opts.optionFlags_m:
      lPrefix = lPrefix + "_"+of
  
  lPrefix = lPrefix + "__id_"+opts.logId_m
  
  return lPrefix


def guessParNameFromMinpoly(strMP):
  s = "".join (strMP.split('-'))
  s = "".join (s.split('+'))
  s = "".join (s.split('*'))
  s = "".join (s.split('^'))
  s = "".join (s.split('/'))
  s = "".join (s.split('%'))
  s = "".join (s.split('!'))
  for i in range(0,10):
    s = s.replace(str(i),' ')
    #print "s",s
  l = s.split(' ')
  for entry in l:
    entry = entry.strip()
    if len(entry)>0:
      return entry
  assert Fail, "failed to guess parameter name"

def singularGenTableFromOptions(opts):
  s = ""
  s = s + " def genParams = defaultRandomConstructionParams();\n\n"

  s = s + " genParams.absMaxCoeff       =        " + str(opts.maxAbsCoeff_m)  + ";\n"
  s = s + " genParams.minVarFactorsPerMonomial = " + str(opts.maxDegree_m )   + ";\n"
  s = s + " genParams.maxVarFactorsPerMonomial = " + str(opts.minDegree_m )   + ";\n"
  s = s + " genParams.maxTermsPerGen    =        " + str(opts.maxTerms_m)     + ";\n"
  s = s + " genParams.maxGens           =        " + str(opts.maxGens_m )     + ";\n"
  if not opts.bFractions_m:
    s = s + " genParams.bFractionsOn = 0;\n"
  s = s + " def genTable = createRandomGeneratorsByParams( genParams  );\n"
  return s

def singularGenTableProcFromOptions(opts):
  s = singularGenTableFromOptions(opts);
  return "proc getGenTable()\n{\n"+s+"\n return (genTable);\n} ";

def singularRingProcFromOptions(opts):
  s = singularRingStrFromOptions(opts)
  return "proc getRing()\n{\n"+s+"\n return (rng);\n} ";

# see also argparse module as alternative to getopt
def singularRingStrFromOptions(opts):
   abc = "abcdefghijklmnopqrstuvwxyz"
   xabc = [a+b for a in abc for b in abc]

   xabc.remove("if")
   xabc.remove("or")

   s = " ring rng = "
   parstr= ""
   numpars = opts.numPars_m

   if (not None == opts.minPoly_m) and (not "0"==opts.minPoly_m):
      assert numpars==1
      parstr = guessParNameFromMinpoly(opts.minPoly_m)
      numpars = 0    
      try:
        if len(parstr)==1:
          abc.replace(parstr,'')
        if len(parstr)==2:
          xabc.remove(parstr)
      except ValueError:       
        pass

   numvars = opts.numVars_m
   if numpars<len(abc):
      if numpars>0:
        parstr =",".join( abc[i] for i in range(0,numpars ) )
      numpars = 0
   if (numpars+numvars)< len(xabc):
      if numpars>0:
        parstr =",".join(xabc[i] for i in range(0,numpars ) )
      varstr=",".join(xabc[i]for i in range(numpars,numpars+numvars ) )
      numvars = 0
   else:
      if numpars>0:
        parstr = "a(1)..a("+str(numpars)+")"
      if numvars>0:
        varstr = "x(1)..x("+str(numvars)+")"
   
   pseudochar = None
   singularRing = ""
   if type(opts.extDeg_m)==int:
      if opts.extDeg_m>1:
        assert type(opts.char_m)==int
        pseudochar = str(opts.char_m**opts.extDeg_m)
   if None== pseudochar:
    pseudochar= str(opts.char_m)
  # char:
   s = s+"("+pseudochar
  
   if len(parstr)>0:
     #print "len(parstr)>0",parstr
     s = s + ","+parstr
   s = s+")"+",("
   s = s+varstr
   s = s+"),"
   if not opts.ordstr_m[0]=="(":
     s = s + "("+opts.ordstr_m + ")"
   else:
     s = s +opts.ordstr_m 
   s = s + ";\n"
   if (not None == opts.minPoly_m) and (not "0"==opts.minPoly_m) and not "implicit"==opts.minPoly_m:
    s = s+ "minpoly = "+ opts.minPoly_m+ ";\n";

   for opt in opts.optionFlags_m:
     s = s + "option("+opt+");\n"

   return s


#def genTableFromOptions(opts):


class TestOptions:
    """
    TestOptions doc : \n \
    \t -v verbose and debug \n \
    \t -t test\n \
    \t -f only filter\n \
    \t -rootdir= set root directory \n \
    """
    args_m  = []
    
    def __init__(self, args):
        self.test_m=False
        #self.lockfile_m = self.dataDir_m + "/admin/updatefcdb.py.lck" # kann man nicht nach parseArgs-Aufruf verschieben, da ein ein angegebenes lockfile  staerker als ein aus dataDir abgeleitetes lockfile binden soll
        self.bFractions_m = False
        self.optionFlags_m = ["redSB","redTail"]
        
        self.verbose_m = False
        #self.test_m = False

        self.numVars_m = 3;
        self.numPars_m = None;
        self.minPoly_m = None;

        self.char_m = 0
        self.ordstr_m = "dp"
        self.extDeg_m = None
        self.ringstr = None;
        self.maxAbsCoeff_m = 50;
        self.minDegree_m = 0;
        self.maxDegree_m = 3;
        self.maxTerms_m = 3;
        self.maxGens_m = 3;
        self.bFractions_m = False;

        self.Singular_bin = "Singular"

        self.timeout_m = 50 # in sec.
        self.memlimit_m = 1000000 # in kByte
        # print "parse Args"

        self.logId_m = "0" # in kByte

        self.parseArgs(args)
        
        if None==self.numPars_m:
          self.numPars_m = 0 
        self.args_m = args
        self.updateDir= "/dev/null"
        #self.incomingDir_m  = self.dataDir_m + "/incoming/"
        #self.processedDir_m = self.dataDir_m + "/processed/"
        #self.rejectedDir_m  = self.dataDir_m + "/rejected/"
        #self.testDir_m      = self.dataDir_m + "/test/"
        
        #self.logFile_m  = self.rootDir_m + "/log/"+"updatedb.log"
        #self.printout()
        self.check()
        
    def printCommandLineOptions(self):
    # parse command line options
        i=0
        for arg in self.args_m: 
            i=i+1
            
            print "[",i,"]",arg
            
        return

    def check(self):
      if not self.ringstr == None:
          assert self.char_m == "integer" or type(self.char_m) == int
      if not None == self.extDeg_m  and not "implicit"==self.extDeg_m:
          assert type(self.extDeg_m) == int
          if self.extDeg_m>1:
            assert self.numPars_m == 1

      assert(self.minDegree_m) >= 0
      assert(self.maxDegree_m) >= 0 and (self.maxDegree_m) >= (self.minDegree_m) 
      assert(self.maxGens_m)  >= 0
      assert(self.maxTerms_m) >= 0
      assert(self.numVars_m) > 0
      assert(self.numPars_m) >= 0
      if type(self.extDeg_m)==int:
        assert (self.extDeg_m) > 0
        if self.extDeg_m>1:
          assert type(self.char_m)==int and self.char_m>0


    def parseArgs(self, args):
        "parseArgs doc"
        try:
            opts, args = getopt.getopt(args, "htlugtrmq", [
                                                          "help",
                                                          "test",
                                                          "timeout=",
                                                          "memlimit=",
                                                          "Singular=",
                                                          "options=",
                                                          "datadir=",
                                                          "maxterms=",
                                                          "maxgens=",
                                                          "mindeg=",
                                                          "maxdeg=",
                                                          "maxcoeff=",
                                                          "fractions=", 
                                                          "numvars=",
                                                          "numpars=",
                                                          "char=",
                                                          "extdeg=",
                                                          "ordstr=", 
                                                          "minpoly=",
                                                          "logid="
                                                        ]
                                      )
        except getopt.error, msg:
            print msg
            print "for help use --help"
            sys.exit(2)
    # process options
        tmpLockFile = None
        for opt, arg in opts:
            if opt=="h" or opt=="-h" or opt=="--help":
                print  "__doc__",self.__doc__

            elif opt == "-l" or opt == "l" or opt == "mindeg" or opt == "--mindeg":
                #print "arg:",arg
                #print "minimal variables in monomial (minimalMonomial degree in ordinary rings):",arg
                self.minDegree_m = int(arg)

            elif opt == "-u" or opt == "u" or opt == "--maxdeg" or opt == "--maxdegr":
                #print "maximal number of variables in  a monomial (maximal monomial degree in ordinary rings):",arg
                self.maxDegree_m = int(arg)

            elif  opt == "m" or opt == "m" or opt == "maxterms" or opt == "--maxterms":
               # print "terms per generator:",arg
                self.maxTerms_m = int(arg)

            elif  opt == "g" or opt == "g" or opt == "maxgens" or opt == "--maxgens":
                #print "number of maximal ideal generatorx:",arg
                self.maxGens_m = int(arg)

            elif  opt == "c" or opt == "c" or opt == "maxcoeff" or opt == "--maxcoeff":
                #print " absolute value of maximal coeff:",arg
                self.maxAbsCoeff_m = int(arg)

            elif   opt == "ordstr" or opt == "--ordstr":
                self.ordstr_m = arg

            elif   opt == "char" or opt == "--char":
                #print " characteristic:",arg
                try:
                  self.char_m = int(arg)
                except ValueError:
                  assert arg=="integer"
                  self.char_m = arg

            elif   opt == "numvars" or opt == "--numvars":
              self.numVars_m = int(arg)

            elif   opt == "numpars" or opt == "--numpars":
              self.numPars_m = int(arg)

            elif   opt == "minpoly" or opt == "--minpoly":
              if None==self.extDeg_m:
                self.extDeg_m="implicit"
              else:
                assert False," do not set both minpoly and extdeg"
              if None==self.numPars_m:  
                self.numPars_m = 1
              self.minPoly_m =arg

            elif   opt == "extdeg" or opt == "--extdeg":     
              self.extDeg_m = int(arg)     
              assert self.extDeg_m  >0

              if self.extDeg_m>1:
                if None==self.numPars_m:  
                  self.numPars_m = 1
                else:
                  assert self.numPars_m == 1

              if self.minPoly_m == None:
                self.minPoly_m ="implicit"
              else:
                assert False," do not set both minpoly and extdeg"


            elif   opt == "options" or opt == "--options":          
              self.optionFlags_m = arg.split(',')      
       
            elif  opt=="--lockfile":
                #print "lockfile=",arg
                tmpLockFile = arg
                self.lockfile_m = arg

            elif opt == "-t" or opt == "t" or opt == "test" or opt == "--test":
                print "only Testing  ",arg
                self.test_m=True

            elif opt == "--fractions" or opt == "fractions":
                #print "fractions  ",arg
                if arg=="On" or arg=="on" or arg=="Yes" or arg=="yes" or   arg=="Y" or arg=="y"  or arg=="True" or arg=="true":
                  self.bFractions_m = True
                elif arg=="Off" or arg=="off" or arg=="No" or arg=="no" or   arg=="n" or arg=="n"  or arg=="False" or arg=="false":
                  self.bFractions_m = False
                else:
                  assert False,"can't parse 'fractions' parameter (expected 'true/false' or 'yes/no# or 'on/off' ) "
            elif opt == "--timeout" or opt == "timeout":
              self.timeout_m=int(arg)
            elif opt == "--memlimit" or opt == "memlimit":
              self.memlimit_m = int(arg)
            elif opt == "--Singular" or opt == "Singular" or "--singular" or opt == "singular":
              self.Singular_bin = arg
            elif opt == "--logid" or opt == "logid":
              if "Random"==arg or "random"==arg or "rnd"==arg:
                self.logid="random"
              else:
                self.logid=arg     
            elif opt == "-v" or opt == "v":
                print "verbose mode  ",arg
                self.verbose_m = True

            elif opt == "-q" or opt == "q":
                print "singular quiet mode  ",arg
                self.quietSingular_m = True

            else:
              assert False, "unrecognized or unhandled option: "+opt
        # ein angegebenes lockfile bindet staerker als ein aus dataDir abgeleitetes lockfile
        if (tmpLockFile):
            self.lockfile_m = tmpLockFile


    def printout(self):
        print "printout TestOptions: "
        print "-----------"
        #print "lockfile_m    =", self.lockfile_m
        #print "datadir_m     =", self.dataDir_m
        print "test_m        = ",    self.test_m
        print "verbose       = ",    self.verbose_m
        #print "logFile_m = ",  self.logFile_m  
        print ""
        print "char    = ", self.char_m
        print "numpars = ", self.numPars_m
        print "numvars = ", self.numVars_m
        print "ordstr  = ", self.ordstr_m
        print "extension degree = ", self.extDeg_m
        print "minpoly      =     ", self.minPoly_m
        print "option flags =   ", self.optionFlags_m
        print ""
        print "maxAbsCoeff = ", self.maxAbsCoeff_m
        print "minDegree   = ", self.minDegree_m
        print "maxDegree   = ", self.maxDegree_m
        print "maxTerms    = ", self.maxTerms_m
        print "maxGens     = ", self.maxGens_m
        print "fractions =   ", self.bFractions_m
        print ""
        print "timeout =   ", self.timeout_m
        print "memlimit =   ", self.memlimit_m

        print ""
        print "Singular binary", self.Singular_bin
        print ""
        print "log id", self.logId_m


        print "-----------"


