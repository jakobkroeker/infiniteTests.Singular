//
version="version test.primdecGTZ.only.primdec";
category="Commutative Algebra";
info="
";

LIB "wrappers.lib";
LIB "ringutils.lib";
LIB "primdec.lib";
LIB "ehv.lib";


proc adjustAssumeLevel(ol)
{
    if (not (defined(assumeLevel) ) ) 
    {
       ol.writeX( "       def Top::assumeLevel = 3;");
       ol.writeX( " export (Top::assumeLevel);");
       def Top::assumeLevel = 3;
       export (Top::assumeLevel);
    }
    else
    {
       if (assumeLevel==0)
       { 
            assumeLevel = 3;
       }
       ol.writeX( "  assumeLevel = "+string(assumeLevel)+";");
    }
}

//proc wDecompE (I)         {    return ( Primdec::decompE(I) );     }
proc wDecomp (I)          {    return ( Primdec::convList(Primdec::decomp(I) ) );     }


proc primdecGTZEkeepKomp (I)         {    return ( primdecGTZE(I,"keep_comp") );     }
proc primdecGTZkeepKomp (I)          {    return ( primdecGTZ (I,"keep_comp") );     }

proc minAssGTZEFacSTD (I)            {    return ( minAssGTZE(I,"facstd") );         }
proc minAssGTZFacSTD  (I)            {    return ( minAssGTZ (I,"facstd") );         }

proc minAssGTZEnoFacSTD (I)          {    return ( minAssGTZE(I,"noFacstd") );       }
proc minAssGTZnoFacSTD  (I)          {    return ( minAssGTZ (I,"noFacstd") );       }

proc minAssGTZEorigNoFacSTD (I)      {    return ( minAssGTZE(I,"GTZ","noFacstd") ); }
proc minAssGTZorigNoFacSTD (I)       {    return ( minAssGTZ (I,"GTZ","noFacstd") ); }

proc minAssGTZEGTZ (I)               {    return ( minAssGTZE(I,"GTZ") );            }
proc minAssGTZGTZ  (I)               {    return ( minAssGTZ (I,"GTZ") );            }

proc primdecSYENoOptimalOrdering (I) {    return ( primdecSYE(I,0) );                }
proc primdecSYNoOptimalOrdering  (I) {    return ( primdecSY (I,0) );                }

proc minAssCharENoOptimalOrdering(I) {    return ( minAssCharE(I,0) );               }
proc minAssCharNoOptimalOrdering (I) {    return ( minAssChar (I,0) );               }

proc primdecEUsingMinAssChar  (I)    {    return ( Primdec::prim_dec_i(1,I,0) );        }
proc primdecUsingMinAssChar   (I)    
{
      if (defined(Primdec::prim_dec_i)) { return ( Primdec::prim_dec_i(0,I,0) );      }
      else { return ( Primdec::prim_dec(I,0) );      }
}


proc minAssGTZorig      (I)          {    return ( minAssGTZ(I,"GTZ") );              }


proc minAssPrimesNew  (I)           {    return ( Primdec::minAssPrimesE(I) );        }
proc minAssPrimesOrig (I)           {    return ( Primdec::minAssPrimes(I) );         }


proc minAssPrimesOldNew  (I)        {    return ( Primdec::minAssPrimesoldE(I) );    }
proc minAssPrimesOldOrig (I)        {    return ( Primdec::minAssPrimesold (I) );    }

proc minAssNew  (I)                 {    return ( Primdec::minAssE(I) );             }
proc minAssOrig (I)                 {    return ( Primdec::minAss (I) );             }


proc minAssPrimCharsetsECurrentOrd(I)    {    return ( Primdec::min_ass_prim_charsets_i(1,I,0)) ; }
proc minAssPrimCharsetsCurrentOrd (I)    {    return ( Primdec::min_ass_prim_charsets_i(0,I,0)) ; }

proc minAssPrimCharsetsEOptimalOrd (I)    {    return ( Primdec::min_ass_prim_charsets_i(1,I,1)) ; }
proc minAssPrimCharsetsOptimalOrd  (I)    {    return ( Primdec::min_ass_prim_charsets_i(0,I,1)) ; }


proc minAssPrimCharsets0New  (I)    {    return ( Primdec::min_ass_prim_charsets0_i(1,I,0)) ; }
proc minAssPrimCharsets0Orig (I)    {    return ( Primdec::min_ass_prim_charsets0_i(0,I,0)) ; }

proc minAssPrimCharsets1New   (I)   {    return ( Primdec::min_ass_prim_charsets1_i(1,I,1)) ; }
proc minAssPrimCharsets1Orig  (I)   {    return ( Primdec::min_ass_prim_charsets1_i(0,I,1)) ; }




proc testPrimdecZeroDim( numVars, maxGens, absMaxCoeff, maxMonomialDegree, maxTermsPerGen, trials )
{
    print ("testPrimdecZeroDim");
    if (defined(basering) ) {   def BAS=basering; }

    def rng = createRing("0","dp", numVars) ;
    setring rng;
    export(rng);

    list ideals;

    int trial;

    // generating only zerodimensional ideals:
    for (trial = 1; trial<=trials; trial=trial)
    {   
       setring rng;
       print ("trial: "+string(trial));
       if ( defined(j) ) { kill j; }
       basering;
       system("random");
       ideal j = randomIdeal(  random(1, maxGens) , random(1, absMaxCoeff) , random(0, maxMonomialDegree), random(1, maxTermsPerGen)  );
     
       if ( dimIdeal(j)==0 )
       {
          print(" dimIdeal(j)=0" );
          trial=trial+1;
          zerodec(j); 
       }
    }

    if (defined(BAS)) {  setring BAS; }
    return(1);
}


proc testPrimaryDecomp(list methodsPairs, ideal I, ol)
{
        if (defined(PL))  {kill PL; }
        list PL;
        int i;
              
         list perms =  permute(methodsPairs);
         
         def perm =     perms[random(1,size( perms))];
         proc foo ;
         
         i = 1;
         
         ol.writeX( "  PL["+string(i)+"] = "+perm[i][1]+"(I);");
         foo =  perm[i][2];
         PL[i] =  foo (I) ;
              
         ol.writeX( "ASSUME(0, testPrimary( PL[1] , I ) );");
         ASSUME(0, testPrimary( PL[i] , I ) );

         ol.writeX( "ASSUME(0, not hasRedundantComponents(PL[1]));");        
         ASSUME(0, not hasRedundantComponents(PL[1]));

         for (i=2;i<=size(perm);i++)
         { 
               ol.writeX( "  PL["+string(i)+"] = "+perm[i][1]+"(I);");               
               foo =  perm[i][2];
               PL[i] =  foo (I) ;
               ASSUME(0, testPrimary( PL[i] , I ) );
               ol.writeX( "ASSUME(0, primDecsAreEquivalent(PL["+string(i-1)+"],PL["+string(i)+"]));");
               ASSUME(0, primDecsAreEquivalent(  PL[i-1],  PL[i]  )   );
               ol.writeX( "ASSUME(0, not hasRedundantComponents(PL[i]));");
               ASSUME(0, not hasRedundantComponents(PL[i]));
         }
}


proc testMinAssDecomp(list methodsPairs, ideal I, ol)
{
            if (defined(ML))  {kill ML; }
            list ML;
            int i;
            def minAss1,minAss1e;          

             list perms =  permute(methodsPairs);
         
             def perm =     perms[random(1,size( perms))];
            
            i = 1;
            proc foo ;
            ol.writeX( "  ML["+string(i)+"] = "+perm[i][1]+"(I);");
            foo =  perm[i][2];
            ML[i] =  foo (I) ;

                        
         
            for (i=2;i<=size(perm);i++)
            { 
                  ol.writeX( "  ML["+string(i)+"] = "+perm[i][1]+"(I);");
                  foo =  perm[i][2];
                  ML[i] =  foo (I) ;
                  
                  ol.writeX( "ASSUME(0, minAssDecompAreEquivalent(ML["+string(i-1)+"],ML["+string(i)+"]));");
                  ASSUME(0, minAssDecompAreEquivalent(ML[i-1],ML[i]));
                        
            }

            ol.writeX( "minAss1  = minAss(I);");
                        minAss1  = minAss(I);
}

proc testPrimdec( getRng, genTable, trials, ol)
{
   list minAssMethodPairs = list( list("minAssGTZ",minAssGTZ),
                                  list("minAssGTZFacSTD",minAssGTZFacSTD),
                                  list("minAssGTZGTZ",minAssGTZGTZ)
                               );
                               
   list primdecMethodPairs = list( list("primdecGTZ",primdecGTZ),
                                  list("primdecGTZkeepKomp",primdecGTZkeepKomp),
                                  list("primdecSY",primdecSY),
                                  list("primdecSYNoOptimalOrdering",primdecSYNoOptimalOrdering)
                               );
        testPrimdec(       getRng, genTable, trials, ol, minAssMethodPairs, primdecMethodPairs       );
        
}

proc testPrimdecTimeout( getRng, genTable, trials, ol)
{
   list minAssMethodPairs = list( list("minAssGTZ",minAssGTZ),
                                  list("minAssGTZFacSTD",minAssGTZFacSTD),
                                  list("minAssGTZGTZ",minAssGTZGTZ)
                               );
                               
   list primdecMethodPairs = list( list("primdecGTZ",primdecGTZ),
                                  list("primdecGTZkeepKomp",primdecGTZkeepKomp),
                                  list("primdecSY",primdecSY)                               );
        testPrimdec(       getRng, genTable, trials, ol, minAssMethodPairs, primdecMethodPairs       );
        
}


proc testPrimdec( getRng, genTable, trials, ol , minAssMethodPairs, primdecMethodPairs)
{
    print ("// testPrimdec");


    adjustAssumeLevel(ol);
    if (defined(basering) ) {   def BAS=basering; }

    intvec op ;

    option(nowarn);
    def rng = getRng();
    setring rng;
    option(warn);
    export(rng);

    list ideals;

    int trial,i;
    list L1,L2,L3;
    list PL,ML;

    
    def wdec;

    def minAss1,minAss1e;
    
    int PDfirst;

    ideal I;
    string emptystring="";
    // while (trial<trials)
    while(1)
    {   
      kill rng;

      option(nowarn);

      def rng = getRng();
      setring rng;
      option(warn);
      ideal I;
      if (defined(minAss1)) {kill minAss1;}
      if (defined(minAss1e)) {kill minAss1e;}

      export(rng);
       //ol.writeX( "// get random ideal ");
      trial = 0;
      //while (trial<trials)
      //{

           I = genTable.idealG(  );    
           //ol.writeX( "// got random ideal ");

           if (not isZero(I) && not idealsAreEqual( ideal(1), I ) )
           {

               ol.clearX();
               ol.writeX("");
               ol.writeX("");

               ol.writeX( "////////////////////////////////////////////////////////////////////////////////////////");
               ol.writeX( "if (not defined(assumeLevel)) { def Top::assumeLevel ; } assumeLevel = "+string( assumeLevel ) + ";  " );
               ol.writeX( "//  voice = "+string( voice ) + ";" );
               ol.writeX( "system(\"random\","+string( system("random") ) + ");" );
               ol.writeX( "//random: "+ string( system("random") )  );
               ol.writeX( "LIB(\"src/tests/test.primdec.many.orig.mp\");");
               ol.writeX(  ringToStringHack (basering) );
               ol.writeX( "bigint trial = "+string(trial)+";");
               ol.writeX( "    def minAss1,minAss1e;");

               ol.writeX( "list  PL,ML;");
               
               PDfirst = random(0,1);
               if (PDfirst)
               {
                   testPrimaryDecomp(primdecMethodPairs,I,ol);
                   testMinAssDecomp(minAssMethodPairs, I,ol);
               }
               else
               {
                   testMinAssDecomp(minAssMethodPairs, I,ol);
                   testPrimaryDecomp(primdecMethodPairs,I,ol);
               }
               ol.writeX( "");
               trial++;
           }
        //}
          
    }


    if (defined(BAS)) {  setring BAS; }
    return(1);
}



// allgemein für timeout: procname(testee), parameter generator , optional result checker
// der resultchecker erhält als input die originalen parameter und das result.

proc testPrimdecTimeout( getRng, genTable, trials, procName, ol )
{
    print ("//testPrimdec");
    adjustAssumeLevel();
    if (defined(basering) ) {   def BAS=basering; }

    intvec op ;

    option(nowarn);
    def rng = getRng();
    setring rng;
    option(warn);
    export(rng);

    list ideals;

    int trial,i;
 
    ideal I;
    string emptystring="";
    // while (trial<trials)
    while(1)
    {   
      kill rng;

      option(nowarn);

      def rng = getRng();
      setring rng;
      option(warn);
      ideal I;
      if (defined(minAss1)) {kill minAss1;}
      if (defined(minAss1e)) {kill minAss1e;}

      export(rng);
       //ol.writeX( "// get random ideal ");
      trial = 0;
      //while (trial<trials)
      //{

           I = genTable.idealG(  );    
           //ol.writeX( "// got random ideal ");

           if (not isZero(I) && not idealsAreEqual( ideal(1), I ) )
           {
               ol.clearX();
               ol.writeX("");
               ol.writeX("");
               ol.writeX( "////////////////////////////////////////////////////////////////////////////////////////");
               ol.writeX( "if (not defined(assumeLevel)) { def Top::assumeLevel ; } assumeLevel = "+string( assumeLevel ) + ";  " );
               ol.writeX( "//  voice = "+string( voice ) + ";" );
               ol.writeX( "system(\"random\","+string( system("random") ) + ");" );
               ol.writeX( "//random: "+ string( system("random") )  );
               ol.writeX( "LIB(\"src/tests/test.primdec.many.orig.mp\");");
               ol.writeX(  ringToStringHack (basering) );
               ol.writeX( "printIdealInfo( I ) ;");
               printIdealInfo(I);
               ol.writeX( "bigint trial = "+string(trial)+";");

               ol.writeX( "def result= "+procName+"(I);");              
               execute("def result="+procName+"(I);");    
 
               trial++;
           }
        //}
          
    }


    if (defined(BAS)) {  setring BAS; }
    return(1);
}
