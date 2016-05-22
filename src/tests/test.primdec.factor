/////////////////////
version="version test.primdec.factor";
category="Commutative Algebra";
info="
";


// LIB "ringutils.lib" ;

LIB "primdec.lib";
LIB "ehv.lib";
// LIB "wrappers.lib" ;
// LIB "randomIdeal.lib";
LIB "src/tests/testsingle.lib";


proc factorWrapper( poly p )
{
   return(Primdec::factor(p));
}

proc testFactorEx(list act, poly p)
{
  ASSUME(1, hasFieldCoefficient(basering) );
  ASSUME(1, not isQuotientRing(basering) ) ;
  ASSUME(1, hasGlobalOrdering(basering) ) ;
  poly keep=p;

  int i;
  def tmp;
  poly q=act[1][1]^act[2][1];
  for(i=2;i<=size(act[1]);i++)
  {
    tmp = factorWrapper(act[1][i]);
    ASSUME(0, size(tmp[1])==1);
    q=q*act[1][i]^act[2][i];
  }
  q=1/leadcoef(q)*q;
  p=1/leadcoef(p)*p;
  ASSUME(0, p-q==0);
}


proc polInputIsGood(pol)
{
    return (pol!=0);
}

// - unify these kind of testSetups, for example all take a 'gens'?
proc testPrimdecFactorEx( ringG, randomOptions, gens, trialsPerRing, finished, ol)
{
     string requiredLibEscapedStr = "LIB \"src/tests/testFactorize.lib\"; ";        
    
    string testeeName =   "factorWrapper";              
    string checkResultName = "testFactorEx";
    def serializeInput =  serializeObj;  
          
    testSingleProc( requiredLibEscapedStr, ringG, randomOptions,  gens.polyG,    serializeInput, polInputIsGood,    trialsPerRing,   testeeName,         checkResultName,   finished,  ol );
}

//	printlevel = 0 ;
//    TRACE = 0;

// testFactorWrapper("0", "dp");
// testFactorWrapper("3", "lp");
// testFactorWrapper("23","Dp");



