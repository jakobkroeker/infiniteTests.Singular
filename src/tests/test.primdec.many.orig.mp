//
version="version test.primdecGTZ.only.primdec";
category="Commutative Algebra";
info="
";

LIB "wrappers.lib";
LIB "ringutils.lib";
LIB "primdec.lib";
LIB "ehv.lib";


proc adjustAssumeLevel()
{
    if (not (defined(assumeLevel) ) ) 
    {
       dbprint(1, "       def Top::assumeLevel = 3;");
       dbprint(1, " export (Top::assumeLevel);");
       def Top::assumeLevel = 3;
       export (Top::assumeLevel);
    }
    else
    {
       if (assumeLevel==0)
       { 
            assumeLevel = 3;
       }
       dbprint(1, "  assumeLevel = "+string(assumeLevel)+";");
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


proc testPrimaryDecomp(ideal I)
{
        if (defined(PL))  {kill PL; }
        list PL;
        int i;
        
        list methodsPairs = list( list("primdecGTZ",primdecGTZ),
                                  list("primdecGTZkeepKomp",primdecGTZkeepKomp),
                                  list("primdecSY",primdecSY),
                                  list("primdecSYNoOptimalOrdering",primdecSYNoOptimalOrdering)
                               );
         list perms =  permute(methodsPairs);
         
         def perm =     perms[random(1,size( perms))];
         proc foo ;
         
         i = 1;
         
         dbprint(1, "  PL["+string(i)+"] = "+perm[i][1]+"(I);");
         foo =  perm[i][2];
         PL[i] =  foo (I) ;
              
         dbprint(1, "ASSUME(0, testPrimary( PL[1] , I ) );");
         ASSUME(0, testPrimary( PL[i] , I ) );

         dbprint(1, "ASSUME(0, not hasRedundantComponents(PL[1]));");        
         ASSUME(0, not hasRedundantComponents(PL[1]));

         for (i=2;i<=size(perm);i++)
         { 
               dbprint(1, "  PL["+string(i)+"] = "+perm[i][1]+"(I);");               
               foo =  perm[i][2];
               PL[i] =  foo (I) ;
               ASSUME(0, testPrimary( PL[i] , I ) );
               dbprint(1, "ASSUME(0, primDecsAreEquivalent(PL["+string(i-1)+"],PL["+string(i)+"]));");
               ASSUME(0, primDecsAreEquivalent(  PL[i-1],  PL[i]  )   );
               dbprint(1, "ASSUME(0, not hasRedundantComponents(PL[i]));");
               ASSUME(0, not hasRedundantComponents(PL[i]));
         }
}


proc testMinAssDecomp(ideal I)
{
            if (defined(ML))  {kill ML; }
            list ML;
            int i;
            def minAss1,minAss1e;
            list methodsPairs = list( list("minAssGTZ",minAssGTZ),
                                  list("minAssGTZFacSTD",minAssGTZFacSTD),
                                  list("minAssGTZGTZ",minAssGTZGTZ)
                               );

             list perms =  permute(methodsPairs);
         
             def perm =     perms[random(1,size( perms))];
            
            i = 1;
            proc foo ;
            dbprint(1, "  ML["+string(i)+"] = "+perm[i][1]+"(I);");
            foo =  perm[i][2];
            ML[i] =  foo (I) ;

                        
         
            for (i=2;i<=size(perm);i++)
            { 
                  dbprint(1, "  ML["+string(i)+"] = "+perm[i][1]+"(I);");
                  foo =  perm[i][2];
                  ML[i] =  foo (I) ;
                  
                  dbprint(1, "ASSUME(0, minAssDecompAreEquivalent(ML["+string(i-1)+"],ML["+string(i)+"]));");
                  ASSUME(0, minAssDecompAreEquivalent(ML[i-1],ML[i]));
                        
            }

            dbprint(1, "minAss1  = minAss(I);");
                        minAss1  = minAss(I);
}


proc testPrimdec( getRng, genTable, trials, logfile )
{
    print ("// testPrimdec");

    link l=":w "+logfile;

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
       //dbprint(1, "// get random ideal ");
      trial = 0;
      //while (trial<trials)
      //{

           I = genTable.idealG(  );    
           //dbprint(1, "// got random ideal ");

           if (not isZero(I) && not idealsAreEqual( ideal(1), I ) )
           {

               monitor ("") ;
               l=":w "+logfile;
               open(l);
               write(l,"");
               // write(":w "+logfile,emptystring);
               write(l,"");

               close(l);        
               monitor(logfile,"io");

               dbprint(1, "////////////////////////////////////////////////////////////////////////////////////////");
               dbprint(1, "if (not defined(assumeLevel)) { def Top::assumeLevel ; } assumeLevel = "+string( assumeLevel ) + ";  " );
               dbprint(1, "//  voice = "+string( voice ) + ";" );
               dbprint(1, "system(\"random\","+string( system("random") ) + ");" );
               dbprint(1, "//random: "+ string( system("random") )  );
               dbprint(1, "LIB(\"src/tests/test.primdec.many.orig.mp\");");
               dbprint(1, "intvec op = "+string( option(get) )+";");
               dbprint(1, "ring rng = "+string(basering)+";");
               dbprint(1, "minpoly = "+string(minpoly)+";");
               dbprint(1, "ideal I = "+string(I)+";");
               dbprint(1, "bigint trial = "+string(trial)+";");
               dbprint(1, "    def minAss1,minAss1e;");

               dbprint(1, "list  PL,ML;");
               
               PDfirst = random(0,1);
               if (PDfirst)
               {
                   testPrimaryDecomp(I);
                   testMinAssDecomp(I);
               }
               else
               {

                   testMinAssDecomp(I);
                   testPrimaryDecomp(I);
               }
     

                trial++;

                monitor ("") ;
           }
        //}
          
    }


    if (defined(BAS)) {  setring BAS; }
    return(1);
}


