//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt

unit Uncert;

interface

Uses Classes, CalcDist, UncertDefn;

Type

SingleArray = Array of Single;

TSLAMM_Uncertainty = Class
   NumDists: Integer;
   DistArray: TDistArray;
   NumSens: Integer;
   SensArray: TSensArray;
   PctToVary: Integer;
   Seed, Iterations, GIS_Start_Num: Integer;
   UseSeed: Boolean;
   UseSEGTSlope: Boolean;
   SEGTSlope: Double;
   {No load or save below}
   ZMap, PrevZMap: Array of Single; // hold temporary  maps until spatial autocorrelation is complete
   ZUncertMap: Array[1..2] of SingleArray;  // final uncertainty  maps with appropriate RMSE and correlation
   MapDeriving, NMapIter: Integer;  // index of map being derived [1..2] and number of iterations required, columns in map
   Q_Value: Double;
   MapRows,MapCols: Integer;   // rows and cols in map
   XLS_Path, CSV_Path : String;
   UncSens_Iter, UncSens_Row: Integer;
   SensPlusLoop: Boolean;
   Function MakeUncertMap(MapNum,NR,NC: Integer; RMSE,q_val: Double): Boolean;
   Function  ThreadUncertMap(StartRow,EndRow: Integer;PRunThread: Pointer): Boolean;
   Constructor Create;
   Destructor Destroy;  override;
   Constructor Load(ReadVersionNum: Double; TS: TStream; PSS: Pointer);
   Procedure Store(Var TS: TStream);
End;

implementation

Uses SysUtils, Global, Progress, Forms, SLAMMThreads;

{ TSLAMM_Uncertainty }

constructor TSLAMM_Uncertainty.Create;
begin
  NumDists := 0;
  DistArray := nil;

  NumSens := 0;
  SensArray := nil;
  PctToVary := 15;

  Seed       := 20;
  Iterations := 20;
  GIS_Start_Num := 1;
  UseSeed    := True;

  UseSEGTSLope := True;
  SEGTSlope := 0.6596;

  UncSens_Iter := 0;
  UncSens_Row := 0;
  NMapIter := 0;
end;

destructor TSLAMM_Uncertainty.Destroy;
Begin
  Finalize(DistArray);
  Finalize(SensArray);
  Finalize(ZUncertMap);
End;


procedure TSLAMM_Uncertainty.Store(var TS: TStream);
var i: Integer;
begin
  TSWrite('NumDists',NumDists);
  For i:=0 to NumDists-1 do
    DistArray[i].Store(TS);

  TSWrite('Seed',Seed);
  TSWrite('Iterations',Iterations);
  TSWrite('GIS_Start_Num',GIS_Start_Num);

  TSWrite('UseSeed',UseSeed);

  TSWrite('UseSEGTSlope',UseSEGTSlope);
  TSWrite('SEGTSlope',SEGTSlope);

  TSWrite('NumSens',NumSens);
  TSWrite('PctToVary',PctToVary);
  For i:=0 to NumSens-1 do
    SensArray[i].Store(TS);


end;


constructor TSLAMM_Uncertainty.Load(ReadVersionNum: Double; TS: TStream; PSS: Pointer);
Var i: Integer;
    JunkBool: Boolean; JunkStr: String;
begin
  TSRead('NumDists',NumDists);
  SetLength(DistArray,NumDists);
  For i:=0 to NumDists-1 do
    DistArray[i] := TInputDist.Load(ReadVersionNum,TS,PSS);

  TSRead('Seed',Seed);
  TSRead('Iterations',Iterations);
  If ReadVersionNum > 6.315 then TSRead('GIS_Start_Num',GIS_Start_Num)
                            else GIS_Start_Num := 1;

  TSRead('UseSeed',UseSeed);

  If ReadVersionNum > 6.815 then
    Begin
      TSRead('UseSEGTSlope',UseSEGTSlope);
      TSRead('SEGTSlope',SEGTSlope);
    End
  else
    Begin
      UseSEGTSlope := True;
      SEGTSlope := 0.6596;
    End;

  If ReadVersionNum < 6.325 then
    Begin
      TSRead('SaveUncGIS',JunkBool);
      TSRead('SaveALLGIS',JunkBool);
      TSRead('GISYears',JunkStr,ReadVersionNum);
    End;

  If ReadVersionNum > 6.215
    then
      Begin
        TSRead('NumSens',NumSens);
        TSRead('PctToVary',PctToVary);
        SetLength(SensArray,NumSens);
        For i:=0 to NumSens-1 do
          SensArray[i] := TSensParam.Load(ReadVersionNum,TS,PSS);
       End
    else
      Begin
        NumSens := 0;
        SensArray := nil;
        PctToVary := 15;
      End;

  {No load or save below}
  UncSens_Iter := 0;
  UncSens_Row := 0;
  For i := 1 to 2 do
    ZUncertMap[i] := nil;
  NMapIter := 0;

end;

Const R_Val = 0.2;

Function  TSLAMM_Uncertainty.ThreadUncertMap(StartRow,EndRow: Integer;PRunThread: Pointer): Boolean;
Var ER, EC, Index: Integer;

    Function GetZ(ER,EC:Integer): Single;
    Begin
      If (ER<0) or (EC<0) or (ER>MapRows-1) or (EC>MapCols-1) then GetZ :=0
         else GetZ := PrevZMap[MapCols*(ER)+(EC)]
    End;

Begin

  Result := True;
 // Iterate until appropriate spatial variance is achieved
    For ER := StartRow to EndRow do
     For EC := 0 to MapCols-1 do
      ZMap[MapCols*(ER)+(EC)] := q_Value*( GetZ(ER-1,EC)+GetZ(ER+1,EC)+GetZ(ER,EC-1)+GetZ(ER,EC+1)) + ZUncertMap[MapDeriving][MapCols*(ER)+(EC)]*R_Val;

    TElevUncertMapThread(PRunThread).MaxChange := -9999;
     For ER := StartRow to EndRow do
      For EC := 0 to MapCols-1 do
       Begin
        Index := MapCols*(ER)+(EC);
        With TElevUncertMapThread(PRunThread) do
          If ABS(ZMap[Index]-PrevZMap[Index]) > MaxChange then MaxChange := ABS(ZMap[Index]-PrevZMap[Index]);
        PrevZMap[Index] := ZMap[Index];
       End;

    Application.ProcessMessages;

End;


Function TSLAMM_Uncertainty.MakeUncertMap(MapNum, NR, NC: Integer;  RMSE, q_Val: Double): Boolean;

Var ER, EC, CPUs: Integer;
    Index: Integer;
    Tolerance: Double;
    WasVisible: Boolean;
//    TextOut: TextFile;   // Debug text file to test correlations
//    Appending: Boolean;

       Procedure Parallel_Execute;
       Var ThreadArr3: Array [0..100] of TElevUncertMapThread;

       Var CCLoop,RowStart,RowEnd,RowsPer: Integer;
           AllDone, UStop:Boolean;
           MaxMaxChange : Single;
        Begin
          NMapIter := 0;
          MapDeriving := MapNum;
          MapCols := NC;  MapRows := NR;
          Q_Value := q_Val;

          For CCLoop := 0 to CPUs -1 do
            Begin
              RowsPer := ((NR div CPUs)+1);
              RowStart :=CCLoop * RowsPer;
              RowEnd := ((CCLoop + 1) * RowsPer) -1;
              if CCLoop = CPUs-1 then RowEnd := NR-1;
              ThreadArr3[CCLoop] := TElevUncertMapThread.Create(Self,RowStart,RowEnd,'Calculating Elevation Uncertainty Map'+'('+ IntToStr(CPUs)+' CPUs) ',CCLoop+1);
            End;

          REPEAT
            inc(NMapIter);

            repeat
              MaxMaxChange := -9999;

              Application.processmessages;
              AllDone := True;
              UStop := False;
              For CCLoop := 0 to (CPUs) -1 do
                Begin
                  If not ThreadArr3[CCLoop].ImDone then AllDone := False;
                  If ThreadArr3[CCLoop].UserStop then UStop := True;
                End;
             until AllDone; {or UStop;}

             For CCLoop := 0 to CPUs -1 do
               If ThreadArr3[CCLoop].MaxChange > MaxMaxChange then MaxMaxChange := ThreadArr3[CCLoop].MaxChange;

             If (MaxMaxChange < Tolerance) or UStop then
               For CCLoop := 0 to CPUs -1 do
                ThreadArr3[CCLoop].Converged := True;

             For CCLoop := 0 to CPUs -1 do
               ThreadArr3[CCLoop].Start;  //next iteration of makeuncertmap

             ProgForm.Gauge1.Progress := NMapIter - 100*(NMapIter Div 100);
             Application.ProcessMessages;

          UNTIL (MaxMaxChange < Tolerance) or UStop;

          For CCLoop := 0 to (CPUs) -1 do
           begin
            if ThreadArr3[CCloop].UserStop then Result := False;
            ThreadArr3[CCLoop].Free;
           end;

        End;   {Parallel_Execute}


Var  StDevCorrection, Sum_e2: Double;

begin
  CPUs := GetLogicalCPUCount;
  WasVisible := ProgForm.Visible;
  ProgForm.Visible := True;
  ProgForm.YearLabel.Visible := False;
  ProgForm.SLRLabel.Visible := False;
  ProgForm.ProtectionLabel.Visible := False;

  ProgForm.ProgressLabel.Caption   := 'Calculating Elevation Uncertainty Map ('+ IntToStr(CPUs)+' CPUs)';


  Tolerance := RMSE / 100;   {Tolerance in variability error set to 1% of RMSE}

  If (q_Val >= 0.25) or (q_Val < 0) then
    Raise ESLAMMError.Create('Spatial Correlation Q must be less than 0.25 and greater than or equal to 0');

// Appending := FileExists('C:\newtemp\ArrayOut.csv');
//  AssignFile(TextOut,'C:\newtemp\ArrayOut.csv');
//  If Appending
//        then Append(TextOut)
//        else Rewrite(TextOut);

//  Writeln(TextOut);
//  Writeln(TextOut,'Q-Val ',q_Val);

  If (Length(ZUncertMap) < NR*NC) then SetLength(ZUncertMap[MapNum], NR*NC);
  SetLength(ZMap, NR*NC);
  SetLength(PrevZMap, NR*NC);

  // Initialize with Normal Distribution

{ the RMSE is an estimator of the standard deviation based on model results.
  If it is an unbiased estimator, then it will be equal to the standard error. }
  For ER := 0 to NR-1 do
     For EC := 0 to NC-1 do
      Begin
        Index :=NC*(ER)+(EC) ;
        ZUncertMap[MapNum][Index] := rNormal(0,  RMSE);
        PrevZMap[Index] := R_Val * ZUncertMap[MapNum][Index];
      End;

  Parallel_Execute;

  Sum_e2 := 0;
  For ER := 0 to NR-1 do
   For EC := 0 to NC-1 do
    Begin
      Index := NC*(ER)+(EC);
      ZUncertMap [MapNum][Index] := ZUncertmap[MapNum][Index] + ZMap [Index];
      Sum_e2 := Sum_e2 + Sqr(ZUncertmap [MapNum][Index]);
    End;

 // Correct standard devation
  StDevCorrection := RMSE / SQRT(Sum_e2 / (NR*NC-1));
  For ER := 0 to NR-1 do
   Begin
//    Writeln(TextOut);
    For EC := 0 to NC-1 do
     Begin
       Index := NC*(ER)+(EC);
       ZUncertMap [MapNum][Index] := ZUncertmap [MapNum][Index] * StDevCorrection;
//       Writeln(TextOut,IntToStr(ER),' ',IntToStr(EC),' ',FloatToStrF(ZUncertmap [MapNum][Index],ffgeneral,5,3));
     End;
   End;

  ZMap := nil;
  PrevZMap := nil;
  ProgForm.Visible := WasVisible;
  ProgForm.YearLabel.Visible := True;
  ProgForm.SLRLabel.Visible := True;
  ProgForm.ProtectionLabel.Visible := True;

//  Closefile(TextOut)
end;


end.
