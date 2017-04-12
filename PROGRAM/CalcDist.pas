//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txtt
// 
{modified for use in Aquatox, 1/15/97}

{*************************}
{****} UNIT CalcDist;{****}
{*************************}

interface
uses Math,RandNum;
const
   Tiny     : Double = 5.0e-15; {mach. accuracy = 1.0e-19 }
   error_value : double = -99.9;
   MaxSize     = 65520;
   MaxSingle   = MaxSize DIV (SizeOf(single));  { max element size single array }

type PSingleArray = ^TSingleArray;
     TSingleArray =  array[1..MaxSingle] of single;

     TDescriptiveStatistics = record
       N                                  : word;
       Mean, StdDev, Skewness, Kurtosis   : Double;
       Quantiles                          : array [0..20] of Double;
     end;

{The following suite of functions return a randomly selected
 value from the respective distrubtion}
function rNormal(Mean, StandardDeviation : double) : double;
function rLogNormal(GM, GSD : double) : double;
function rTriangular(Minimum, Maximum, MostLikely : double) : double;
function rUniform(Minimum, Maximum : double) : double;

function cdfNormal(y,mean,dev:double) : double;
function icdfNormal(Prob,mean,dev:double) : double;

function cdfLogNormal(x,GM,GSD: double): Double;
function icdfLogNormal (Prob,GM,GSD:double) : double;

function  icdfTriangular(y,A,B,ML:double): double;
function  cdfTriangular(X,A,B,ML : double) : Double;

function cdfUniform(X,A,B : double) : Double;
function icdfUniform(Prob,A,B : double) : double;

implementation

{---------------------------------------------------------------------------}


{GENERALIZED FUNCTIONS}



function rNormal(Mean, StandardDeviation : double) : double;
var r, v1, v2, v3, dev: double;
begin
   rnormal:=error_value;
   If standarddeviation<=0 then exit;
   repeat
      v1 := 2*RandUniform-1;
      v2 := 2*RandUniform-1;
      r := sqr(v1) + sqr(v2);
   until (r<1.0);
   if (RandUniform < 0.5) then
        v3:=v2
     else
        v3:=v1;
   dev := v3 * SQRT(( - 2 * LN(r)) / r);
   rNormal := mean + dev * StandardDeviation;
end;


function rLogNormal(GM, GSD : double) : double;
begin
   rlognormal:=error_value;
   if (GM<1) or (GSD<=1) then exit;
   rLogNormal:=exp(rNormal(ln(GM),ln(GSD)));
end;

function rTriangular(Minimum, Maximum, MostLikely : double) : double;
var temp, base, part: double;
begin
   rtriangular:=error_Value;
   if (Maximum<=Minimum) or (MostLikely<=Minimum)
                         or (MostLikely>=Maximum) then exit;

   base := Maximum - Minimum;
   part := MostLikely - Minimum;
   Temp:=RandUniform;
   if (Temp < (part/base)) then
      Temp := Minimum + Sqrt(base*part*Temp)
   else
      Temp := Maximum - Sqrt(base*(Maximum-Mostlikely)*(1-Temp));
   rTriangular := Temp;
end;


function rUniform(Minimum, Maximum : double) : double;
begin
   If (Minimum>=Maximum) then rUniform:=Error_Value
   else rUniform:=Minimum + (Maximum-Minimum)*RandUniform;
end;

{--------------------------------------------------------------------}

function cdfNormal(y,mean,dev:double) : Double;
{Using Method found in LATIN.FOR,
Algorithm 26.2.17 from Abromowitz and Stegun, Handbook of Mathematical Functions}
const
        p  : extended =  0.231641900;
        b1 : extended =  0.319381530;
        b2 : extended = -0.356563782;
        b3 : extended =  1.781477937;
        b4 : extended = -1.821255978;
        b5 : extended =  1.330274429;
var
   sd,x,y1,y2,y3,y4,y5    : extended;
   t,z,r                  : extended;
begin
   cdfNormal:=error_value;
   If dev<=0 then exit;
   sd := (y-mean)/dev;
{ check to see if the standard deviation ( sd ) is in range }
   {if sd < 0 then exit;}
   x := sd;
   r := EXP(-(x*x)/2)/2.5066282746;
{  r = frequency }
   z  := x;
   y1 := 1/(1+(p*ABS(x)));
   y2 := y1 * y1;
   y3 := y2 * y1;
   y4 := y3 * y1;
   y5 := y4 * y1;
   t  := 1 - r*(b1*y1+ b2*y2 + b3*y3 + b4*y4 + b5*y5);
   if z > 0 then
      cdfNormal := t
   else
      cdfNormal := 1 - t;
end;

function icdfNormal(prob,mean,dev:double) : double;
const
     {Method and constants taken from function
      26.2.26 (pg 933) of Abramowitz and Stegun
      Handbook of Mathematical Functions, Dover
      New York, 1965}
      
        c0 : extended = 2.515517;
        c1 : extended = 0.802853;
        c2 : extended = 0.010328;
        d1 : extended = 1.432788;
        d2 : extended = 0.189269;
        d3 : extended = 0.001308;
var
        dn,up,xp : EXTENDED;
        t1,t2,t3 : EXTENDED;
begin
   icdfnormal:=error_value;
   If dev<=0 then exit;
   if prob=1 then icdfnormal:=1e500;
   if prob=0 then icdfnormal:=-1e500;
   if (prob <= 0) OR (prob >= 1) then exit;
   if prob > 0.5 then
      xp := 1 - prob
   else
      xp := prob;
   t1 := SQRT(LN(1/SQR(xp)));
   t2 := t1 * t1;
   t3 := t2 * t1;
   up := c0  + c1*t1 + c2*t2;
   dn := 1 + d1*t1 + d2*t2 + d3*t3;
   xp := t1 - (up/dn);
   if prob <= 0.5 then
      icdfNormal := mean-xp*dev
   else
      icdfNormal := mean+xp*dev;
end;

{--------------------------------------------------------------------}

function cdfLogNormal(x,GM,GSD: double): Double;
var u,std: double;

Begin
     cdfLogNormal:=Error_Value;
     if x=0 then cdflognormal:=0;
     if (GM<1) or (GSD<=1) or (x<=0) then exit;
     u:=ln(GM); std:=ln(GSD);
     cdflognormal:=cdfnormal((ln(x)-u)/std,0,1);
End;

function icdfLogNormal(Prob,GM,GSD:double) : double;

var n,u,std: double;

Begin
     icdfLogNormal:=Error_Value;
     if (GM<1) or (GSD<=1) then exit;
     if Prob=0 then icdflognormal:=0;
     if Prob=1 then icdflognormal:=1e200;
     if (prob<=0) or (prob>=1) then exit;
     u:=ln(GM); std:=ln(GSD);
     n:=icdfnormal(prob,0,1);
     if u+std*n>1e4 then icdflognormal:=1e200 else
                         icdflognormal:=exp(u+std*n);
End;

{--------------------------------------------------------------------}

function  icdfTriangular(y,A,B,ML:double): double;
var height : double;
    leftarea, rightarea: double;

begin
    icdftriangular:=error_Value;
    if (b<=a) or (ML>=b) or (ML<=A)then exit;
    height:=2/(B-A);
    leftarea:=(ML-A)*height/2;
    rightarea:=(B-ML)*height/2;
    if y<(leftarea/(rightarea+leftarea)) then {x<ml}
       icdftriangular := a+sqrt(2*y/(height/(ML-A))) else
       icdftriangular := b-sqrt((2*y-2)/(height/(ML-B)));
end;

function cdfTriangular(X,A,B,ML : double) : Double;
var height : double;
begin
   cdftriangular:=error_value;
   if (b<=a) or (ML>=b) or (ML<=A)then exit;
   height:=2/(B-A);
   if x<ML then cdfTriangular:=0.5*(X-A)*(Height/(ML-A))*(X-A)
           else cdfTriangular:=1-0.5*(B-X)*(Height/(ML-B))*(X-B);
   if (x<a) then cdftriangular:=0;
   if (x>b) then cdftriangular:=1;
end;
{--------------------------------------------------------------------}

function cdfUniform(X,A,B : double) : Double;
begin
   If (A>=B) or (X<A-tiny) or (X>B+tiny)
     then CDFUniform:=Error_Value
     else cdfUniform := (x-a)/(b-a);
end;

function icdfUniform(Prob,A,B : double) : double;
begin
   If (A>=B) or (Prob<0) or (Prob>1) then ICDFUniform:=Error_Value
   else icdfUniform:=Prob*(b-a)+a;
end;

{--------------------------------------------------------------------}
end.
