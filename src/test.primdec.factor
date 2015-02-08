/////////////////////
version="version test.factorize";
category="Commutative Algebra";
info="
";


//LIB "ringutils.lib" ;

LIB "primdec.lib";
LIB "ehv.lib";
//LIB "wrappers.lib" ;
LIB "randomIdeal.lib";


proc factorWrapper( poly p )
{
   return(Primdec::factor(p));
}

 
proc ptestFactorWrapper( list l, poly p )
{
   Primdec::testFactor(l, p);
}

proc testPrimdecFactor( rng, polyG, trials )
{
    print ("testFactorize");
    if (defined(basering) ) {   def BAS=basering; }

    setring rng;
    export(rng);

    int trial;
    poly pol;
    list L;
    while(1)
    {   
       dbprint(1, "trial: ", trial );
       setring rng;
       basering;
       kill pol;
       poly pol = polyG( );
       if (pol==0) { continue;}
       pol;
       L = factorWrapper(pol);
       ptestFactorWrapper(L,pol);
       trial = trial + 1;
    }

    if (defined(BAS)) {  setring BAS; }
    return(1);
}



//	printlevel = 0 ;
//    TRACE = 0;

// testFactorWrapper("0", "dp");
// testFactorWrapper("3", "lp");
// testFactorWrapper("23","Dp");



