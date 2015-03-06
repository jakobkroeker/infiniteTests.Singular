version="version test.primdecGTZ.only.primdec";
category="Commutative Algebra";
info="
";

LIB "primdec.lib";LIB "ringutils.lib";LIB "wrappers.lib";LIB "ehv.lib";


proc adjustAssumeLevel()
{
    if (not (defined(assumeLevel) ) ) 
    {
       def Top::assumeLevel = 3;
       export (Top::assumeLevel);
    }
    else
    {
       if (assumeLevel==0)
       { 
          assumeLevel = 3;
       }
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


proc testPrimdec( getRng, genTable, trials, logfile )
{
    print ("testPrimdec");
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
          def minAss1,minAss1e;
      export(rng);
       //dbprint(1, "// get random ideal ");
       I = genTable.idealG(  );    
       //dbprint(1, "// got random ideal ");

       if (not isZero(I) && not idealsAreEqual( ideal(1), I ) )
       {

           write(":w "+logfile,emptystring);
           monitor(logfile,"io");
           write(":w "+logfile,emptystring); // empty logfile twice  - otherwise it seems not to work
           dbprint(1, "////////////////////////////////////////////////////////////////////////////////////////");
           dbprint(1, "def assumeLevel = "+string( assumeLevel ) + ";" );
           dbprint(1, "//  voice = "+string( voice ) + ";" );
           dbprint(1, "system(\"random\","+string( system("random") ) + ");" );
           dbprint(1, "//random: "+ string( system("random") )  );
           dbprint(1, "LIB(\"bugs/test.primdec.many.orig\");");
           dbprint(1, "intvec op = "+string( option(get) )+";");
           dbprint(1, "ring rng = "+string(basering)+";");
           dbprint(1, "minpoly = "+string(minpoly)+";");
           dbprint(1, "ideal I = "+string(I)+";");
           dbprint(1, "bigint trial = "+string(trial)+";");
           dbprint(1, "    def minAss1,minAss1e;");

             dbprint(1, "list  PL,ML;");
             if (defined(PL)) {kill PL;}
             if (defined(ML)) {kill ML;}
             list PL,ML;
             
             dbprint(1, "  PL[size(PL)+1] =list(\"primdecGTZ (I)\",primdecGTZ (I));");
                           PL[size(PL)+1] = list("primdecGTZ (I)",primdecGTZ (I)) ;

             dbprint(1, "  PL[size(PL)+1] = list(\"primdecGTZkeepKomp (I)\",primdecGTZkeepKomp (I));");
                             PL[size(PL)+1] = list("primdecGTZkeepKomp (I)",primdecGTZkeepKomp (I)) ;
             

             dbprint(1, "  PL[size(PL)+1] = list(\"primdecSY (I)\",primdecSY (I));");
                           PL[size(PL)+1] = list("primdecSY (I)",primdecSY (I)) ;

             dbprint(1, "  PL[size(PL)+1] = list(\"primdecSYNoOptimalOrdering (I)\",primdecSYNoOptimalOrdering (I));");
                           PL[size(PL)+1] = list("primdecSYNoOptimalOrdering (I)",primdecSYNoOptimalOrdering (I)) ;

             dbprint(1, "ASSUME(0, testPrimary( PL[1][2] , I ) );");
            ASSUME(0, testPrimary( PL[1][2] , I ) );
            for (i=1;i<size(PL);i++)
            { 
                dbprint(1, "ASSUME(0, primDecsAreEquivalent(PL["+string(i)+"][2],PL["+string(i+1)+"][2]));");
                        ASSUME(0, primDecsAreEquivalent(  PL[i][2],  PL[i+1][2]  )   );
            }


            dbprint(1, "ML[size(ML)+1] =list(\"minAssGTZ (I)\",minAssGTZ (I));");
                        ML[size(ML)+1] = list("minAssGTZ (I)",minAssGTZ (I)) ;
 

            dbprint(1, "ML[size(ML)+1] = list(\"minAssGTZFacSTD (I)\",minAssGTZFacSTD (I));");
                        ML[size(ML)+1] = list("minAssGTZFacSTD (I)",minAssGTZFacSTD (I)) ;

            dbprint(1, "ML[size(ML)+1] =list(\"minAssGTZGTZ (I)\",minAssGTZGTZ (I));");
                        ML[size(ML)+1] = list("minAssGTZGTZ (I)",minAssGTZGTZ (I)) ;



            for (i=1;i<size(ML);i++)
            { 
                dbprint(1, "ASSUME(0, minAssDecompAreEquivalent(ML["+string(i)+"][2],ML["+string(i+1)+"][2]));");
                        ASSUME(0, minAssDecompAreEquivalent(ML[i][2],ML[i+1][2]));
            }


         
            dbprint(1, "minAss1  = minAss(I);");
                        minAss1  = minAss(I);


            trial++;
       }
      
    }


    if (defined(BAS)) {  setring BAS; }
    return(1);
}



