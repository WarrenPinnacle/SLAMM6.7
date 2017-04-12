//AQUATOX SOURCE CODE copyright (c) 2009 - 2012 Eco Modeling
//Code Use and Redistribution is Subject to Licensing, SEE AQUATOX_License.txt
// 
{Date of Current Revision - January 1, 1994}

UNIT RandNum;

{This unit will supply client programs with streams of pseudo-random
 numbers, for use in Monte-Carlo simulation experiments, for example.
 A number of statistical distributions are supported: uniform (0-1),
 normal, lognormal, exponential, Poisson, triangular, and binomial.
 The generators must be initialized with a series of three "seed"
 numbers for the uniform generator. The seed numbers are generated,
 prior to calling any of the generators, by a call to Procedure SetSeed.
 To generate different streams of numbers each time the unit is used,
 call SetSeed with parameter RanSeed <0.  To generate the same random
 number sequences each time, set RanSeed = {Chosen Seed}



  INTERFACE





    PROCEDURE SetSeed (RanSeed:LongInt);
                       {Generates seed numbers for the
                       uniform random number generator. If
                       RanSeed <0 , then randomized seeds are
                       supplied. Otherwise, fixed seeds are
                       generated using the Integer supplied
                       as the seed.  This is useful when the same
                       random number sequences are to be
                       repeated.}


    FUNCTION RandUniform : double; {Returns a random number,
                                    uniformly distributed between 0
                                    and 1.}

    FUNCTION RandNormal : double; {Returns a normally distributed
                                   random number.}

    FUNCTION ExpDev : double; {Returns an exponentially distributed
                               random number.}

    FUNCTION Poisson (xbar : double) : double; {Returns a floating
                                                point number which
                                                has a Poisson distribution
                                                with mean "xbar".}

    FUNCTION Triang (mean, minimum, maximum : double) : double;
                        {Returns a random number chosen from a
                         triangular distribution}

    FUNCTION Binomial (Prob : double; Ntrials : Integer) : double;
                        {Returns a random number chosen from
                         a binomial distribution with Ntrials trials,
                         each with probability Prob.}

    FUNCTION RandLogNormal : double; {Returns a random number chosen from
                                       a lognormal distribution.}



  IMPLEMENTATION

    TYPE
      seedtype = LongInt;

    VAR
      gliset                        : integer;
      glgset, gloldm, glg           : double;
      s1, s2                        : seedtype;



    PROCEDURE Fseed(RanSeed: Integer); {Provides seed number for the random number
                                generators which are repeatable. Given the same
                                RanSeed, The same sequence will be repeated over and over}
      BEGIN
        s1 := RanSeed;
        s2 := 100;

      END;


    PROCEDURE Seed; {Provides "randomly selected" seed number for
                      the uniform random number generator UNIFORM.}
      BEGIN
        randomize;
        s1 := 1 + random (32361);  {Uses Turbo's "random" generator}
        s2 := 1 + random (31725);
      END;

    PROCEDURE SetSeed (RanSeed : LongInt);
       BEGIN
         if (ranseed<0) then
           seed
         else
           fseed(RanSeed);
       END;


    FUNCTION RandUniform : double; {Uniform random number}
    {This random number generator produces uniformly distributed
     random deviates between 0 and 1. This generator is described
     in the article, "Efficient and Portable Random Number Generators",
     by Pierre L'Ecuyer, Communications of the ACM(1988), 31(6):742. This
     generator combines two linear congruential generators to form a
     portable uniform generator with a period exceeding 2 E+18.
     This generator requires computers with 32 bit word length}

      VAR
        z, k : LongInt;

      BEGIN
        k := s1 div 53668;
        s1 := 40014 * (s1 - k * 53668) - k * 12211;
        if s1 < 0 then s1 := s1 + 2147483563;

        k := s2 div 52774;
        s2 := 40692 * (s2 - k * 52774) - k * 3791;
        if s2 < 0 then s2 := s2 + 2147483399;

        z := s1 - s2;
        if z < 1 then z := z + 2147483562;

        Randuniform := z * 4.656613E-10;

      END; {End Function UNIFORM}



      FUNCTION Expdev : double;

        BEGIN
         expdev := -ln(RandUniform);
        END;


    FUNCTION RandNormal : double;
    {Returns a normally distributed deviate with zero mean
     and unit variance using UNIFORM as the source of uniform
     deviates}

    (* Programs using NORMAL must declare the variables
      VAR
        gliset: integer;
        glgset: double;
        in the main routine and must intialize gliset to
        gliset := 0;
     These are defined in the beginning of the Implementation
     section. GLISET is initialized to 0 in the initialization
     section at the end of the unit.
    *)

      VAR
        fac,r,v1,v2: double;

      BEGIN {Begin Function Normal}

        IF  (gliset = 0)  THEN BEGIN
          REPEAT
            v1 := 2.0*RandUniform-1.0;
            v2 := 2.0*RandUniform-1.0;
            r := sqr(v1)+sqr(v2);
          UNTIL (r < 1.0);
          fac := sqrt(-2.0*ln(r)/r);
          glgset := v1*fac;
          Randnormal := v2*fac;
          gliset := 1
          END
        ELSE BEGIN
          Randnormal := glgset;
          gliset := 0
        END

      END; {End Function NORMAL}


    FUNCTION Poisson (xbar : double) : double;
    {Returns as floating point number an integer value that is a
     random deviate drawn from a Poisson distribution of mean XBAR
     using UNIFORM as a source of uniform random deviates}

     (* Programs using POISSON must declare the variables
       VAR
          gloldm, glg : double;
          in the main program and should intialize gloldm to
          gloldm := -1.0;
          These are declared at the beginning of the Implementation
          section. GLOLDM is initialized to -1.0 at the end of the
          unit.
      *)

       VAR
          em, t : double;

       BEGIN {Start Function Poisson}

          IF (xbar <> gloldm) THEN BEGIN
             gloldm := xbar;
             glg := exp(-xbar)
          END;

          em := -1.0;
          t := 1.0;

          REPEAT
            em := em+1.0;
            t := t*RandUniform;
          UNTIL (t <= glg);

          poisson := em;

       END; {End Function Poisson}


    FUNCTION binomial (Prob: double; Ntrials: integer) : double;
    {Returns as a floating point number an integer value that is a
     random deviate drawn from a binomial distribution of Ntrials trials
     each of probability Prob, using UNIFORM as a source of uniform
     deviates. Uses Inverse Transform of binomial distribution function.}

       VAR
         x : integer;
         s, a, r : double;
         u, q : double;

       BEGIN {Start Function Binomial}
         x := 0;  {Counter. Final value = binomial}

         q := 1.0 - prob;
         s := prob/q;
         a := (ntrials + 1) * s;
         r := exp(ntrials * ln(q));
         u := RandUniform;

         while (u > r) do begin
           u := u - r;
           x := x + 1;
           r := r * ((a/x) - s);
         end; {End WHILE loop}

         binomial := x;

       END; {End Function Binomial}


    FUNCTION Triang (mean, minimum, maximum : double) : double;

      VAR
         rv : double;

      BEGIN
         rv := RandUniform;
         IF rv > (mean-minimum)/(maximum-minimum) then
           Triang := maximum - sqrt((maximum-minimum)*(maximum-mean) *
           (1.0 - rv))
         ELSE
           Triang := minimum + sqrt((maximum-minimum) *
                         (mean-minimum) * rv);
      END {Triang};


    FUNCTION RandLogNormal : double;

      BEGIN
        RandLogNormal := Exp(Randnormal);
      END; {LogNormal}


    BEGIN {Initialization and termination code go here}
       gliset := 0;
       gloldm := -1.0;
       seed;
    END.
