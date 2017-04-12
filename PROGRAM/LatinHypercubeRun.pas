unit LatinHypercubeRun;

interface

Uses SLR6;

Procedure UncertRun(SS: TSLAMM_Simulation);

implementation

Uses UncertDefn, CalcDist, RandNum, Global, TCollect, sysutils, dialogs, progress, Controls, forms,System.UITypes;

Const NUM_UNCERT_OUTPUTS = 27;

Procedure UncertRun(SS: TSLAMM_Simulation);
Type UResultsTypes = (DetRes,MinRes,MaxRes,StdRes,MeanRes);
Var ResLoop      : UResultsTypes;
    UResults     : Array of Array[DetRes..MeanRes] of Array of Double;
    SE0, GT0, GT1: Array of Double;
    DeltaSE : Array of Boolean;  // has the salt elevation already been changed using a distribution?
    Dist         : TInputDist;
    NumOutputFiles: Integer;
    NSLoop, DLoop: Integer;
    DrawValue    : Double;
    AllDataFileN : String;
    ErrorString  : String;
    TextOut      : TextFile;
    OutputFiles  : Array of TextFile;
    DateHolder   : String;
    FileBacked   : Array of String;
//  UserDist     : TUserDist;
    UserInterrupt: Boolean;
    IterationsDone: Integer;
   {------------------------------------------------------------------}
    Function ConflictingDistribution(InDist: Integer; CheckAllSubSites: Boolean): Boolean;
    Var ID: TInputDist;
        DLoop: Integer;
    Begin
     Result := False;
     With SS.UncertSetup do
      Begin
       ID := Distarray[InDist];
        For DLoop:=0 to NumDists-1 do
          if (DLoop <> InDist) then
            if (Distarray[DLoop].IDNum = ID.IDNum) and
               ((Distarray[DLoop].AllSubSites  = ID.AllSubSites) or (Not CheckAllSubsites)) and
               (Distarray[DLoop].SubSiteNum  = ID.SubSiteNum) then
                 Begin
                   Result := True;
                   Exit;
                 End;
      End;
    End;
   {------------------------------------------------------------------}
    Function NoCommas(InStr: String): String;
    Begin
      Result := InStr;
      While Pos(',',Result) > 0 do
        Result[Pos(',',Result)] := ':';
    End;
   {------------------------------------------------------------------}
    Function RandomInt(Top: Integer): Integer;
    {Returns a random integer from 1..Top, using Randnum.Pas}
    Begin
      RandomInt:=Trunc(RandUniform*Top)+1;
    End;
   {------------------------------------------------------------------}
    Function CalculateDraw(Interval: Integer): Double;
   {This Procedure calculates the x value of the distribution
    given the interval in [1..NumIterations]}

    Var ProbLow,ProbHigh: Double;
        Width, Where: Double; {Describe Cum Probability Interval}
        RandProb: Double;     {Random Prob within Interval}
    Begin
      ProbHigh:=1.0;
      {Current implementation does not have upper truncated distributions
       so ProbHigh = 1.0 rather than CDF(Xmax)}

      {Xmin set to zero for now.}
      {triangular and uniform already are subject to Xmin of zero through
       the entry screen}
      ProbLow:=0.0;
      If (Dist.DistType in [normal,lognormal])
         then ProbLow:=Dist.CDF(0);     // truncate to zero

      {Width is the width of the probability interval, "Where" is the upper
       bounds of the probability interval, RandProb is the random value
       within the probability interval (From LATIN.FOR)}
      Width:=(ProbHigh-ProbLow)/SS.UncertSetup.Iterations;
      Where:=(Width*Interval) + Problow;
      RandProb:=Where - Width*RandUniform;

      CalculateDraw:=Dist.ICDF(RandProb);
    End;

   {------------------------------------------------------------------}
    Procedure FillVariableDraws(indx: Integer);
   {This Procedure fills the PCollection associated with each used
    distribution with NumSteps (number of iterations) UncertDraw objects
    each which has the numbered interval and the calculated draw from
    the Function CalculateDraw}

    {In order to calculate the rank order of each parameter's draw
    (ensures non-repeatability and tells which interval to sample from),
    the Procedure calculates a random number for each draw and then ranks
    them.  Optimized Feb 10, 97, JSC}

    Var IterationLoop: Integer;
        FindSlotLoop : Integer;
        LowValue     : Double;
        LowValIndex  : Integer;
        NewDraw      : TUncertDraw;

    Begin
      Dist.Draws:= TCollection.Init(500,50);

      {insert correct number of draws with random number that will
       then be ranked to get the Latin Hypercube Interval}
      With SS.UncertSetup do
       For IterationLoop:=1 to Iterations do
        begin
          NewDraw:= TUncertDraw.Init(0,RandUniform,0);
          Dist.Draws.Insert(NewDraw);
        end;

      With SS.UncertSetup do
       For IterationLoop:=1 to Iterations do
        Begin
          LowValue:=99;
          LowValIndex:=0;
          For FindSlotLoop:=0 to Iterations-1 do
              If TUncertDraw(Dist.Draws.At(FindSlotLoop)).RandomDraw<=LowValue
                then
                  Begin
                    LowValIndex:=FindSlotLoop;
                    LowValue:=TUncertDraw(Dist.Draws.At(FindSlotLoop)).RandomDraw;
                  End;
          NewDraw:=Dist.Draws.At(LowValIndex);
          NewDraw.RandomDraw:=99;
          NewDraw.IntervalNum:=IterationLoop;
          NewDraw.Value:=CalculateDraw(IterationLoop)
        End;

    End;

   {------------------------------------------------------------------}

    Procedure Accumulate_Uncertainty_Results;
    Var OutLoop    : Integer;
        ResLp      : UResultsTypes;
        UncertVal, OutputVal: Double;

        {------------------------TOP-CREATEDISTS--------------------------}
        Procedure InitArrays;
        {Initialize the UResults Arrays}
        Var Loop, OFLoop : Integer;
            Res        : UResultsTypes;
            OVal       : Double;

        Begin
          For OFLoop := 0 to NumOutputFiles-1 do
           For Res:=MinRes to MeanRes do
             SetLength(UResults[OFLoop,Res],NUM_UNCERT_OUTPUTS);

          For OFLoop := 0 to NumOutputFiles-1 do
           For Loop :=0 to NUM_UNCERT_OUTPUTS-1 do  {for each datapoint}
             For Res := MinRes to MeanRes do
                  Begin
                    OVal :=  SS.Summary[OFLoop,SS.UncertSetup.UncSens_Row-1, Loop ];
                    If Res=MinRes then {avoid writing first set of raw data multiple times}
                      Write(OutputFiles[OFLoop],FloatToStrF(OVal,FFExponent,12,2)+', ');

                    If Res=StDRes then UResults[OFLoop,Res,Loop] := sqr(OVal)
                                  else UResults[OFLoop,Res,Loop] := OVal;
                  End;
        End;
        {---------------------BOTTOM-CREATEDISTS--------------------------}

    Var i, OFLoop: Integer;
        OutputFileN, OFString: String;

    Begin    {Accumulate_Uncertainty_Results}
      SetLength(OutputFiles,NumOutputFiles);

      If NSLoop=1 then with SS.UncertSetup do
       For OFLoop := 0 to NumOutputFiles-1 do
        Begin
          OFString := '';
          If OFLoop > 0 then OFString := '_OS'+IntToStr(OFLoop);
          If OFLoop > SS.Site.NOutputSites then OFString := '_ROS'+IntToStr(OFLoop-SS.Site.NoutputSites);

          OutputFileN := ChangeFileExt(AllDataFileN,OFString+'_alldata.csv');
          While Pos('\\',OutputFileN)>0 do
            Delete(OutputFileN,Pos('\\',OutputFileN),1);

          ASSIGNFILE(OutputFiles[OFLoop],OutputFileN);
          REWRITE(OutputFiles[OFLoop]);

          For i:=0 to NumDists-1 do
             Write(OutputFiles[OFLoop],'"Mult. '+NoCommas(Distarray[i].GetName(True))+'", ');

          For i:=0 to NUM_UNCERT_OUTPUTS-1 do
            Write(OutputFiles[OFLoop],'"'+NoCommas(SS.ColLabel[i] )+'", ');
        End;  //output file loop, file initialization

      For OFLoop := 0 to NumOutputFiles-1 do
       Begin
        Writeln(OutputFiles[OFLoop]);
        With SS.UncertSetup do
        For i:=0 to NumDists-1 do
         If DistArray[i].DistType <> ElevMap
           then Write(OutputFiles[OFLoop],FloatToStrF(TUncertDraw(Distarray[i].Draws.At(NSLoop-1)).Value,FFExponent,12,2)+', ')
           else Write(OutputFiles[OFLoop],DistArray[i].GetName(True),' , ');
       End; {OFLoop, write distributions}

      If NSLoop=1 then InitArrays else
        Begin
         For OFLoop := 0 to NumOutputFiles-1 do
          For OutLoop :=0 to NUM_UNCERT_OUTPUTS-1 do  {for each datapoint}
            Begin
              OutputVal := SS.Summary[OFLoop,SS.UncertSetup.UncSens_Row-1,OutLoop ];
              Write(OutputFiles[OFLoop],FloatToStrF(OutputVal,FFExponent,12,2)+', ');
              For ResLp:=MinRes to MeanRes do
                Begin
                  UncertVal := UResults[OFLoop,ResLp,OutLoop];
                  Case ResLp of
                    MeanRes: UResults[OFLoop,ResLp,OutLoop] := UncertVal+OutputVal;
                             {Sum data for now}
                    MinRes : If OutputVal<UncertVal then
                               UResults[OFLoop,ResLp,OutLoop] := OutputVal;
                    MaxRes : If OutputVal>UncertVal then
                               UResults[OFLoop,ResLp,OutLoop] := OutputVal;
                    StdRes : UResults[OFLoop,ResLp,OutLoop]   := UncertVal + (OutputVal*OutputVal);
                            {Sum of Squares for now}
                  End; {Case}
                End; {ResLp}
            End; {OutLoop}
        End; {else}

      {Update Text output}
      IterationsDone:=NSLoop;
      Writeln(Textout);
      Writeln(Textout,'Iteration '+IntToStr(NSLoop)+' Completed.');
      Writeln(Textout,'---------------------------------------------------------');

    End;      {Accumulate_Uncertainty_Results}
   {------------------------------------------------------------------}
    Function InitTextResults:Boolean;
    Var FileN: String;
        curdir: String;
    Begin
      CurDir := GetCurrentDir;
      Result := PromptForFileName(SS.UncertSetup.CSV_path,'CSV File (*.csv)|*.csv','.csv','Select Base Output File',SS.NWIFileN ,True);
      SetCurrentDir(CurDir);

      If Not Result then Begin UserInterrupt:=True; SS.UserStop:=True; Exit; End;

      FileN := ChangeFileExt(SS.UncertSetup.CSV_path,'_uncertlog.txt');

      While Pos('\\',FileN)>0 do
        Delete(FileN,Pos('\\',FileN),1);

      ASSIGNFILE(TextOut,FileN);
      REWRITE(TextOut);
      Writeln(Textout,'---------------------------------------------------------');
      Writeln(TextOut);
      Writeln(TextOut,'        Uncertainty Run for SLAMM                        ');
      Writeln(TextOut);
      Writeln(Textout,'---------------------------------------------------------');
      DateTimeToString(DateHolder,'mm-d-y t',Now);
      Writeln(TextOut,'        Run Starts at '+ DateHolder);
      Writeln(TextOut,'---------------------------------------------------------');
      Writeln(TextOut);
      Writeln(TextOut,'        Technical Details for Uncert Viewer              ');
      Writeln(TextOut);
      Writeln(TextOut,'~FILENAME=',ExtractFileName(SS.UncertSetup.CSV_Path));
      Writeln(TextOut,'~NUM_ITER=',SS.UncertSetup.Iterations);
      Writeln(TextOut,'~TIME_ZERO=',SS.Site.T0);
      Writeln(TextOut);
      Writeln(TextOut,'---------------------------------------------------------');
      Writeln(TextOut);
      Writeln(TextOut,'        ** DISTRIBUTIONS SUMMARY **');
      Writeln(TextOut);
      Writeln(TextOut,'     All Distributions are Multipliers');
      Writeln(TextOut);

     End;
   {-------------------------------------------------------------------}
    Procedure DistToText;
    {Summarizes the distribution for the text output}
    Begin
    With Dist do
      Begin
        Writeln(TextOut,GetName(True));
        Writeln(TextOut,'Initial Point Estimate :'+FloatToStrF(GetValue ,ffGeneral,4,4));
        Writeln(TextOut,SummarizeDist);
        Writeln(TextOut);
      End; {with}
    End; {Proc}
   {------------------------------------------------------------------}
    Procedure WriteDistSummaries;
   {------------------------------------------------------------------}
       Procedure PostProcessResults;
       { calculate stdev and mean from sum and sumsquare data }
       Var i,j : Integer;
           Sum,SumSquare: Double;
           InSqrt     : Double;
           n          : Integer;
       Begin
        For j := 0 to NumOutputFiles-1 do
         For i:=0 to NUM_UNCERT_OUTPUTS-1 do   {For every datapoint}
           Begin
              Sum       := UResults[j,MeanRes,i];
              SumSquare := UResults[j,StdRes,i];
              n:=IterationsDone;

              If n>0 then UResults[j,MeanRes,i]:=Sum/n;
              {The standard deviation is calculated using the "nonbiased" or "n-1" method.}
              If n>1 then InSqrt:= ((n*SumSquare)-(Sum*Sum)) / (n*(n-1))
                     else InSqrt:=0;
              If InSqrt>0 then UResults[j,StdRes,i] :=Sqrt(InSqrt)
                          else UResults[j,StdRes,i] :=0;
          End; {i loop}
       End; {PostProcessResults}

   {----------------- Procedure WriteDistSummaries  ---------------}
   Var OFLoop, i : Integer;

       Begin
         If IterationsDone>0 then PostProcessResults;

         For OFLoop := 0 to NumOutputFiles-1 do
           Begin
             Writeln(OutputFiles[OFLoop]);
             Writeln(OutputFiles[OFLoop]);
             Writeln(OutputFiles[OFLoop], 'Variable Name, Min, Mean, Max, Std. Dev., Deterministic');

              { Loop through outputvariables and write results to Excel }
                For i:=0 to NUM_UNCERT_OUTPUTS-1 do   {For every datapoint}
                 Begin
                  Writeln(OutputFiles[OFLoop], SS.ColLabel[i],',',UResults[OFLoop,minRes,i],',',UResults[OFLoop,meanRes,i],',',UResults[OFLoop,maxRes,i],
                                      ',',UResults[OFLoop,StdRes,i],',',UResults[OFLoop,DetRes,i]);
                 End; {For i}
           End;
       End;  {Procedure WriteDistSummaries}

   {------------------------------------------------------------------}

       Function VerifyUncertSetup: Boolean;
       Var DLoop, i, FixLoop, CountRuns: Integer;
           RunningCustomSLR: Boolean;
           IPCC_Scenario: IPCCScenarios;
           IPCC_Est     : IPCCEstimates;
           Prot_Scenario: ProtScenario;
           ErrMessage   : String;
           FoundSE      : Boolean;

       Begin
         Result := True;
         CountRuns := 0;

         With SS do
           Begin
            For IPCC_Scenario := Scen_A1B to Scen_B2 do
              For IPCC_Est := Est_Min to Est_Max do
               For Prot_Scenario := NoProtect to ProtAll do
                If IPCC_Scenarios[IPCC_Scenario] and IPCC_Estimates[IPCC_Est] and Prot_To_Run[Prot_Scenario] then
                 Inc(CountRuns);

             For Prot_Scenario := NoProtect to ProtAll do
               For FixLoop := 1 to 11 do   //NYS and ESVA SLR Scenarios added - Marco
                 If Fixed_Scenarios[FixLoop] and Prot_To_Run[Prot_Scenario] then
                  Inc(CountRuns);

             RunningCustomSLR := False;
             If RunCustomSLR then
              For i := 1 to N_CustomSLR do
                For Prot_Scenario := NoProtect to ProtAll do
                 If Prot_To_Run[Prot_Scenario] then
                  Begin
                   Inc(CountRuns);
                   RunningCustomSLR := True;
                  End;
           End;

         ErrMessage := '';
         If (CountRuns<>1) then ErrMessage := 'Uncertainty runs must be set up to run one SLR scenario / Protection Scenario only.';
         If Not RunningCustomSLR then
           For i:=0 to SS.UncertSetup.NumDists-1 do
            Begin
              Dist:=SS.UncertSetup.DistArray[i];
              If (Dist.IDNum = 1) then ErrMessage := 'You must run SLAMM under "Custom SLR" if you are selecting the "Sea Level Rise by 2100 (multiplier)" as an uncertainty distribution.';
            End;

         With SS.UncertSetup do
           For DLoop:=0 to NumDists-1 do
             If ConflictingDistribution(DLoop,True) then ErrMessage := 'Distribution '+DistArray[DLoop].GetName(True)+' conflicts with another distribution.';

         With SS.UncertSetup do
          if UseSEGTSlope then
           Begin
             FoundSE := False;
             For DLoop:=0 to NumDists-1 do
               Begin
                 Dist:=SS.UncertSetup.DistArray[DLoop];
                 If (Dist.IDNum = 7) {SE} then FoundSE := True;
                 If (Dist.IDNUM = 6) {GT} and FoundSE then
                   Begin
                     ErrMessage := 'Uncertainty setup error: When using GT to calculate salt elevations, all GT distributions must be above SE distributions in the list so they are calculated first.';
                     Break;
                   End;
               End;

           End;

         If ErrMessage <> '' then
           Begin
             Result := False;
             MessageDlg(ErrMessage,MtError,[mbok],0);
             SS.UserStop := True;
           End;
       End;

   {------------------------------------------------------------------}
   Procedure Cleanup;
   Var DLoop: Integer;
   Begin
     GT0 := nil;
     GT1 := nil;
     SE0 := nil;
     DeltaSE := nil;
     With SS.UncertSetup do
       For DLoop:=0 to NumDists-1 do
         DistArray[DLoop].PointEsts := nil;
   End;
   {------------------------------------------------------------------}


   Procedure SaveGT0GT1;
   Var i: Integer;
   Begin
      SetLength(DeltaSE,SS.Site.NSubSites+1);
      SetLength(GT0,SS.Site.NSubSites+1);
      SetLength(GT1,SS.Site.NSubSites+1);
      SetLength(SE0,SS.Site.NSubSites+1);

      For i := 0 to SS.Site.NSubSites do
        Begin
          DeltaSE[i] := False;
          If i=0
            then
              Begin
                GT0[i] := SS.Site.GlobalSite.GTideRange;
                GT1[i] :=  SS.Site.GlobalSite.GTideRange;
                SE0[i] := SS.Site.GlobalSite.SaltElev;
              End
            else
              Begin
                GT0[i] := SS.Site.Subsites[i-1].GTideRange;
                GT1[i] := SS.Site.Subsites[i-1].GTideRange;
                SE0[i] := SS.Site.Subsites[i-1].SaltElev;
              End;
        End;
    End;

   {------------------------------------------------------------------}

    Procedure RestoreRemainingSEs;
    Var i: Integer;
    Begin
      For i := 0 to SS.Site.NSubSites do
       If not DeltaSE[i] then
         Begin
           If i=0 then SS.Site.GlobalSite.SaltElev := SE0[i]
                  else SS.Site.Subsites[i-1].SaltElev := SE0[i];
         End;
    End;

  {----------------------------------------------------------------}

      Procedure RestoreVals;
      Var DLoop, i:Integer;
      Begin
       With SS.UncertSetup do
        For DLoop:=0 to NumDists-1 do
          Begin
            Dist:=DistArray[DLoop];
            If Dist.DistType <> ElevMap then
              if (Dist.AllSubSites) and (Dist.IsSubSiteParameter) then
                Begin
                  for i := 0 to SS.Site.NSubSites do
                    Begin
                      Dist.SubSiteNum := i;
                      if not ConflictingDistribution(DLoop,False) then Dist.RestoreValues;  //avoid restoring subsites superceded by subsite-specific data
                    End
                End
                  else Dist.RestoreValues;  // single subsite response (or global parameter)
         End;
        RestoreRemainingSEs;
       End;

   {------------------------------------------------------------------}
   Procedure CallSetValues;
   Var SSN: Integer;
       pD : PDouble;
       SE1 : Double;

   Begin
     SSN := Dist.SubSiteNum;
     If (Dist.IDNum = 7) and SS.UncertSetup.UseSEGTSlope
       then with Dist do
         Begin  // special salt elevation setvalues procedure
          SetLength(PointEsts,TSLAMM_Simulation(TSS).Site.NSubSites+1);
          pD := GetValuePointer(SubSiteNum);
          PointEsts[SubSiteNum] := pD^;

          SE1 := (PD^ + SS.UncertSetup.SEGTSlope*(GT1[SSN]-GT0[SSN]));
                 {SE0}                    {m}       {GT1}     {GT0}
          Writeln(TextOut,Dist.GetName(True),' calculated as a function of GT as '+FloatToStrF(SE1,ffGeneral,6,5));
          //PD^ := DrawValue * SE1;
                    {SE mult}   {calculated as fn of GT}
          PD^ := SE1 + (DrawValue-1) * PD^;     // Equivalent to: SE1_final := DrawValue*SE_initial + m(GT1-GT0)

          DeltaSE[SSN] := True;
         End
       else
         Begin  // normal setvalues procedure
           Dist.SetValues(DrawValue);
           If Dist.IDNum = 6 then
             GT1[SSN] := Dist.GetValuePointer(SSN)^;
         End;
  End;
   {------------------------------------------------------------------}
  Procedure ModifyRemainingSEs ;     //modify the SE as a function of GT even if there is no SE distribution
  Var i: Integer;
      SE1: Double;
      SSName: String;
  Begin
    For i := 0 to SS.Site.NSubSites do
     If not DeltaSE[i] then
       Begin
         If i=0 then SSName := 'Global' else SSName := IntToStr(i);
         SE1 := (SE0[i] + SS.UncertSetup.SEGTSlope*(GT1[i]-GT0[i]));
                {SE0}                     {m}       {GT1}   {GT0}
         Writeln(TextOut,'SaltElev for subsite['+SSName+'] calculated as a function of GT as '+FloatToStrF(SE1,ffGeneral,6,5));

         If i=0 then SS.Site.GlobalSite.SaltElev := SE1
                else SS.Site.Subsites[i-1].SaltElev := SE1;
       End;
  End;
  {----------------------------------------------------------------}
  {---        BEGIN MAIN Procedure LATIN HYPERCUBE RUN          ---}
  {----------------------------------------------------------------}
Var i, OFLoop, Loop,Prog: Integer;
    OVal: Double;
    ItStr: String;
    TestFileN: String;
Begin  {UncertRun}
  OutputFiles := nil;
  IterationsDone:=0;
  UncAnalysis := True;
  SS.UncertSetup.UncSens_Iter := 0;
  SS.WordInitialized := False;
  UserInterrupt:=False;
  SS.UserStop := False;

  If Not VerifyUncertSetup then exit;

  Try

  If not InitTextResults then Exit;

  AllDataFileN := SS.UncertSetup.CSV_path;
  TestFileN := ChangeFileExt(AllDataFileN,'_alldata.csv');
  While Pos('\\',TestFileN)>0 do
     Delete(TestFileN,Pos('\\',TestFileN),1);
  If FileExists(TestFileN) then
   If MessageDlg('Overwrite '+TestFileN+'?',mtconfirmation,[mbyes,mbno],0) = mrno then
     if not PromptForFileName(AllDataFileN,'CSV File (*.csv)|*.csv','.csv','Select AllData Output File',TestFileN,True)
       then Begin UserInterrupt:=True; SS.UserStop:=True; Exit; End;

  If SS.UncertSetup.UseSeed then SetSeed(SS.UncertSetup.Seed)
                            else SetSeed(-1);

  ProgForm.ModalResult := MRNone;
  ProgForm.Gauge1.Progress:=0;
  ProgForm.Show;
  ProgForm.UncertStatusLabel.Visible := True;
  ProgForm.UncertStatusLabel.Caption := 'Deterministic Run...';
  ProgForm.Update;
  For i := 1 to 2 do
    SS.UncertSetup.ZUncertMap[i] := nil;

  Try
    SS.ExecuteRun;
  Except
     Messagedlg('Model Execution Error.',mterror,[mbok],0);
     CloseFile(TextOut);
     ProgForm.Hide;
     Cleanup;
     exit;
  End;

  If SS.UserStop then
    Begin
      CloseFile(TextOut);
      ProgForm.Hide;
      Cleanup;
      exit;
    End;

  NumOutputFiles := 1+SS.Site.NOutputSites+SS.Site.MaxROS;
  SetLength(UResults,NumOutputFiles);

  For OFLoop := 0 to NumOutputFiles-1 do
    Begin
      SetLength(UResults[OFLoop,DetRes],NUM_UNCERT_OUTPUTS);
      For Loop:=0 to NUM_UNCERT_OUTPUTS-1 do  {for each datapoint}
        Begin
          OVal :=  SS.Summary[OFLoop,SS.UncertSetup.UncSens_Row-1, Loop];
          UResults[OFLoop,DetRes,Loop] := OVal;   //save deterministic results
        End;
    End;

  FileBacked := nil;

  ProgForm.UncertStatusLabel.Caption := 'Calculating Latin Hypercube Draws...';
  ProgForm.Update;

  {The below loop fills the VariableDraws and saves
   the point estimates so they can be restored after the LH run}
  For Loop:=0 to SS.UncertSetup.NumDists-1 do
     Begin
       Dist:=SS.UncertSetup.DistArray[Loop];
       If Dist.DistType <> ElevMap then FillVariableDraws(Loop);
       DistToText;
     End;

  Writeln(TextOut,'---------------------------------------------------------');

  For i := 1 to 2 do
    SS.UncertSetup.ZUncertMap[i] := nil;
  With SS.UncertSetup do
   For NSLoop:=1 to Iterations do
    Begin
      {Update Progress Dialog}
      ItStr:='Iteration '+IntToStr(NSLoop+GIS_Start_Num-1)+ ' of '+IntToStr(Iterations+GIS_Start_Num-1);
      ProgForm.UncertStatusLabel.Caption := ItStr;
      Writeln(TextOut,Itstr);
      Writeln(TextOut);

      If SS.UncertSetup.UseSEGTSlope then SaveGT0GT1;

      {Load the latin hypercube values into the simulation}
      For DLoop:=0 to NumDists-1 do
        Begin
          Dist:=DistArray[DLoop];
          With Dist do
           If DistType <> ElevMap
             then
                Begin
                  DrawValue:=TUncertDraw(Draws.At(NSLoop-1)).Value;
                  if Dist.AllSubSites and (Dist.IsSubsiteParameter) then  // set for all subsites except SLR (IDNum=1) which is set once   globaluncertlogic
                    Begin
                      for i := 0 to SS.Site.NSubSites do
                        Begin
                          Dist.SubSiteNum := i;
                          if not ConflictingDistribution(DLoop,False) then CallSetValues;  //avoid writing to subsites superceded by subsite specific data
                        End
                    End
                      else CallSetValues;  // single subsite response or global parameter (e.g. SLR)
                  Writeln(TextOut,Dist.GetName(True),' (Multiplied by) '+FloatToStrF(DrawValue,ffGeneral,6,5));
                End
             else Begin
                    SS.UncertSetup.MakeUncertMap(Dist.ZMapIndex, SS.Site.RunRows,SS.Site.RunCols,Dist.Parm[1],Dist.Parm[2]);  //write spatially autocorrelated elevation uncertainty map
                    Writeln(TextOut,Dist.GetName(True),'  RMSE '+FloatToStrF(Dist.Parm[1],ffGeneral,6,5));
                  End;
       End;

      If SS.UncertSetup.UseSEGTSlope then ModifyRemainingSEs;

       Inc(UncSens_Iter);

        {Go through run Procedure for each iteration}
        Try
          SS.ExecuteRun;
        Except
          RestoreVals;
          UserInterrupt:=True;
          SS.UserStop := True;

          DateTimeToString(DateHolder,'mm-d-y t',Now);
          Writeln(TextOut,'Execute Model Error at '+ DateHolder );
          Messagedlg('Model Execution Error.',mterror,[mbok],0);
          For i := 1 to 2 do
            SS.UncertSetup.ZUncertMap[i] := nil;
          Break; {exit distribloop}
        End;

      RestoreVals;

      Prog := Round ((NSLoop/Iterations) * 100);
        If Prog <> ProgForm.Gauge1.Progress then
          Begin
            ProgForm.Gauge1.Progress := Prog;
            ProgForm.Update;
          End;  {If Round}

      Application.ProcessMessages;
      Application.Title := 'SLAMM6 - '+IntToStr(nsloop)+' of '+IntToStr(Iterations);

      If ProgForm.ModalResult<>0 then
        Begin
          UserInterrupt:=True;
          SS.UserStop := True;
        End; {user interrupt}

      If (ProgForm.ModalResult<>0) or SS.UserStop then
         begin
            UserInterrupt:=True;
            SS.UserStop := True;
            DateTimeToString(DateHolder,'mm-d-y t',Now);
            Writeln(TextOut,'Run Terminated at '+ DateHolder );
            Break; {exit loop}
         end
         else Accumulate_Uncertainty_Results;
    End;  {NSLoop}

    Application.Title := 'SLAMM 6 beta';
    If Not UserInterrupt and not SS.UserStop then
      begin
        DateTimeToString(DateHolder,'mm-d-y t',Now);
        Writeln(TextOut,'Run Successfully Completed At '+ DateHolder );
        Writeln(TextOut,'---------------------------------------------------------');
      end;

  Except
    UncAnalysis := False;
    For i := 1 to 2 do
      SS.UncertSetup.ZUncertMap[i] := nil;
    Cleanup;

    ErrorString:=Exception(ExceptObject).Message;
    ProgForm.ModalResult:=1;
    MessageDlg('Run-Time Error During Uncertainty Iteration',mterror,[mbOK],0);
    MessageDlg(ErrorString,mterror,[mbOK],0);
    DateTimeToString(DateHolder,'mm-d-y t',Now);
      Try
        Writeln(TextOut,'Run Terminated at '+ DateHolder );
        Writeln(TextOut,'    Due to '+ErrorString);
      Except
        MessageDlg('No Data Written',mterror,[mbOK],0);
        ProgForm.ModalResult:=1;
      End;

  End; {Except}

  UncAnalysis := False;
  For i := 1 to 2 do
    SS.UncertSetup.ZUncertMap[i] := nil;

  Try

   IF IterationsDone>0 then WriteDistSummaries;

   For OFLoop := 0 to NumOutputFiles-1 do
     For ResLoop:=DetRes to MeanRes do
       Finalize(UResults[OFLoop,ResLoop]);
   Finalize(UResults);

  CloseFile(TextOut);
  If OutputFiles <> nil then
    For OFLoop := 0 to NumOutputFiles-1 do
      CloseFile(OutputFiles[OFLoop]);

  Except
    ErrorString:=Exception(ExceptObject).Message;
    MessageDlg('Run-Time Error Writing to File After Uncertainty Run',mterror,[mbOK],0);
    MessageDlg(ErrorString,mterror,[mbOK],0);
    ProgForm.ModalResult:=1;

    CloseFile(TextOut);
    If OutputFiles <> nil then
     For OFLoop := 0 to NumOutputFiles-1 do
      CloseFile(OutputFiles[OFLoop]);

  End; {Except}

  ProgForm.Hide;
End;  {LatinHyperCubeRun}



end.
