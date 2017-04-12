unit SalArray;

interface

USES   SysUtils, Windows, Messages, Classes, Graphics, System.Math, Types, Dialogs, Global;

TYPE

  DPoint = Record
    X,Y: Double;
  End;
  DLine = packed record p1,p2: Dpoint end;

  SalRec = Record
    RSLR: double;
    Q: Double;
  End;

TSalArray = Class
  NSalRecs, NSalStations: Integer;
  SLocs : Array of DPoint;   //Salinity locations in row and col format but not integers
  OriginLines, PlumeLines: Array of DLine;
  MidPoints: Array of DPoint;
  PTS: TSite;
  SalRecs : Array of SalRec;
  SalPts : Array of Array of Double;
  Constructor ReadSalArrayfromExcel(FileN: String; St: TSite);
  Function SLAMMProjtoXY(X,Y: Double): DPoint;
  Function GetSalinity(X,Y: Integer; SalVal: TDoubleArray):Double;   
  Function ExtractSalinityRecord(SLAMM_RSLR, SLAMM_Q: Double): TDoubleArray;
  Destructor Destroy;  override;
 End; {Class}

implementation

Uses ExcelFuncs;

     {-------------------------------------------------------------}

Constructor TSalArray.ReadSalArrayfromExcel(FileN: String; St: TSite);
Var EO: TExcelOutput;
    Readstr: String;
    RRow,RCol: Integer;
    XLoc,YLoc: Double;

    Procedure SetOriginPlumeMidline(index:Integer);
    Var  RowVector,ColVector: Double;
    Begin
      RowVector := SLocs[Index+1].Y - SLocs[Index].Y;
      ColVector := SLocs[Index+1].X - SLocs[Index].X;
      OriginLines[index].P1 := SLocs[Index];
      PlumeLines[Index].P1 := SLocs[Index+1];

      If ColVector<>0
        then Begin
               OriginLines[index].P2.Y := SLocs[Index].Y + ColVector;
               OriginLines[index].P2.X := SLocs[Index].X - RowVector;
               PlumeLines[Index].P2.Y := SLocs[Index+1].Y + ColVector;
               PlumeLines[Index].P2.X := SLocs[Index+1].X - RowVector;
             End
        else Begin
               OriginLines[index].P2.Y := SLocs[Index].Y;
               OriginLines[index].P2.X := SLocs[Index].X - 1;
               PlumeLines[Index].P2.Y := SLocs[Index+1].Y;
               PlumeLines[Index].P2.X := SLocs[Index+1].X - 1;
             End;

      MidPoints[Index].x := (SLocs[Index].X + SLocs[Index+1].X)/2;
      MidPoints[Index].y := (SLocs[Index].y + SLocs[Index+1].y)/2;

    End;


Begin
  PTS := St;
  EO  := TExcelOutput.OpenFile(False,FileN);
  ReadStr := EO.WS.Cells.Item[2,1].value2;
  Try
    NSalStations := StrToInt(ReadStr);
  Except
    raise ESLAMMError.Create('Incorrect Excel Format.  First Sheet A2 must be an integer representing # of stations with Salinity.');
    EO.Close(True);
  End;

  SetLength(SLocs,NSalStations);
  SetLength(OriginLines, NSalStations-1);
  SetLength(PlumeLines, NSalStations-1);
  SetLength(MidPoints, NSalStations-1);

  For RRow := 1 to NSalStations  do
  Try
    ReadStr := EO.WS.Cells.Item[3+RRow,2].value2;
    XLoc := StrToFloat(ReadStr);
    ReadStr := EO.WS.Cells.Item[3+RRow,3].value2;
    YLoc := StrToFloat(ReadStr);
    SLocs[RRow-1] := SLAMMProjtoXY(XLoc,YLoc);

    if RRow>1 then SetOriginPlumeMidLine(RRow-2);

  Except
    raise ESLAMMError.Create('Error Reading Salinity Station '+IntToStr(RRow));
    EO.Close(True);
  End;

  EO.ChangeTab(2);
  RRow:= 1;
  NSalRecs := 0;
  SetLength(SalRecs,10); SetLength(SalPts,10);

  Try
    Repeat
      if NSalRecs+1 > Length(SalRecs) then
        Begin
          SetLength(SalRecs,NSalRecs+40);
          SetLength(SalPts,NSalRecs+40);
        End;

      RCol:= 1;
      RRow := RRow+1;
      ReadStr := EO.WS.Cells.Item[RRow,RCol].value2;
      if Trim(ReadStr) <> '' then
        Begin
          SalRecs[NSalRecs].RSLR := StrToFloat(ReadStr);

          Inc(RCol);
          ReadStr := EO.WS.Cells.Item[RRow,RCol].value2;
          SalRecs[NSalRecs].Q := StrToFloat(ReadStr);

          SetLength(SalPts[NSalRecs],NSalStations);
          for RCol := 3 to 3 + (NSalStations-1) do
            Begin
              ReadStr := EO.WS.Cells.Item[RRow,RCol].value2;
              SalPts[NSalRecs,RCol-3] := StrToFloat(ReadStr);
            End;

          NSalRecs := NSalRecs + 1;
        End;

    Until Trim(ReadStr) = '';

  Except
    raise ESLAMMError.Create('Error Reading Sheet 2 data at Row'+IntToStr(RRow)+', Col'+IntToStr(RCol));
    EO.Close(True);
  End;

  EO.Close(True);

End;

     {-------------------------------------------------------------}

Function TSalArray.SLAMMProjtoXY(X,Y: Double): DPoint;
Var DeltaX,DeltaY: Double;
Begin
  DeltaX := (X - PTS.LLXCorner)/PTS.RunScale;
  DeltaY := (Y - PTS.LLYCorner)/PTS.RunScale;
  Result.X := DeltaX;
  Result.Y := PTS.RunRows - DeltaY;
End;

     {-------------------------------------------------------------}

Function TSalArray.GetSalinity(X,Y: Integer; SalVal: TDoubleArray): Double;
Var NearLine, SS: Integer;
    MinDistance: Double;
    BestDistance: Double;
    WeightFirst:  Double;
    D2OriginLine, D2PlumeLine: Double;
    DL: DLine;
    Pt: DPoint;

    {-------------------------------------------------------------}
    Function Distance_Pt_2_Line(L: DLine; P: DPoint): Double;
    Var a,b,c: Double;
    Begin
      a := L.p1.X - L.p2.X;
      b := L.P2.Y - L.P1.Y;
      c := L.P1.Y * L.P2.X - L.P2.Y * L.P1.X;
      Distance_Pt_2_Line := (a*P.Y + b*P.X + c) / SQRT(SQR(b)+SQR(a));
    End;
     {-------------------------------------------------------------}
    Function ABSDistance_Pt_2_Line(L: DLine; P: DPoint): Double;
    Begin
      Result := ABS(Distance_Pt_2_Line(L,P));
    End;
     {-------------------------------------------------------------}
    Function Distance_2pts(P1,P2: DPoint):Double;
    Begin  {returns distance between two cells in km}
      Distance_2pts := SQRT(SQR(P2.Y-P1.Y)+SQR(P2.X-P1.X));
    End;
     {-------------------------------------------------------------}
    Function CrossSegment(P1,P2: DPoint; L: DLine): Boolean;  {Would a line connecting the two points cross the given line?
    line is assumed to be of infinite length in this case}
    Begin
      CrossSegment := (Distance_Pt_2_Line(L,P1) * Distance_Pt_2_Line(L,P2)) <= 0;
    End;
     {-------------------------------------------------------------}




Begin
  Result := -9999;
  Pt.X := X; Pt.Y := Y;
  NearLine := -1;  BestDistance := 1e99;
  for SS := 0 to NSalStations - 2 do
   if not (CrossSegment(Pt,MidPoints[SS],OriginLines[SS]) or
           CrossSegment(Pt,MidPoints[SS], PlumeLines[SS])) then
    Begin
      DL.p1 := SLocs[SS];
      DL.p2 := SLocs[SS+1];
      MinDistance := ABSDistance_Pt_2_Line(DL,Pt);
      if MinDistance < BestDistance then
        Begin
          BestDistance := MinDistance;
          NearLine := SS;
        End;
    End;

    if NearLine > -1 then
      Begin
        D2OriginLine := ABSDistance_Pt_2_Line(OriginLines[NearLine],Pt);
        D2PlumeLine := ABSDistance_Pt_2_Line(PlumeLines[NearLine],Pt);
        WeightFirst := D2PlumeLine / (D2OriginLine + D2PlumeLine);
        Result := (SalVal[NearLine]*WeightFirst) + (SalVal[NearLine+1]*(1-WeightFirst));
      End
    else {not within a line segment, assign to nearest point}
      Begin
        BestDistance := 1e99;
        for SS := 0 to NSalStations - 1 do
          Begin
            MinDistance := Distance_2pts(SLocs[SS],Pt);
            If MinDistance<BestDistance then
              Begin
                BestDistance := MinDistance;
                Result := SalVal[SS];
              End;
          End;
      End;

End;

     {-------------------------------------------------------------}
Function TSalArray.ExtractSalinityRecord(SLAMM_RSLR, SLAMM_Q: double) : TDoubleArray;
var
  Row, Col : Integer;
  MinRSLR, MaxRSLR : double;
  MinRow, MaxRow : integer;
  QCompare : boolean;
begin
  setlength(Result,NSalStations);
  MinRSLR := -1e99;
  MaxRSLR := 1e99;
  MinRow := -9999;
  MaxRow := -9999;
  QCompare := False;
  for Row := 0 to NSalRecs-1 do
    begin
      if (CompareValue(SLAMM_Q,SalRecs[Row].Q,0.001) = EqualsValue)  then
        begin
          QCompare := True;
          if (SalRecs[Row].RSLR<=SLAMM_RSLR) and (SalRecs[Row].RSLR>MinRSLR) then
            begin
              MinRSLR := SalRecs[Row].RSLR;
              MinRow:= Row;
            end;
          if (SalRecs[Row].RSLR>=SLAMM_RSLR) and (SalRecs[Row].RSLR<MaxRSLR) then
            begin
              MaxRSLR := SalRecs[Row].RSLR;
              MaxRow:= Row;
            end;
        end;
    end;
  if not QCompare then raise ESLAMMError.Create('Salinity Excel flows and SLAMM freshwater mean flow do not match.');

  if (MinRow=-9999) or (MaxRow=-9999) then raise ESLAMMError.Create('SLR less than Excel min or exceeds Excel max');

  for Col := 0 to NSalStations-1 do
    begin
      if MaxRow<>MinRow then
        Result[Col] := ((SalPts[MaxRow,Col]-SalPts[MinRow,Col])*SLAMM_RSLR+SalPts[MinRow,Col]*MaxRSLR-SalPts[MaxRow,Col]*MinRSLR)/(MaxRSLR-MinRSLR)
      else
        Result[Col] := SalPts[MaxRow,Col];
     end;
end;


Destructor TSalArray.Destroy;
Var i: Integer;
Begin
  SLocs := nil;
  SalRecs := Nil;
  for i := 0 to Length(SalPts)-1 do
    SalPts[i] := nil;
  SalPts := nil;
End;
     {-------------------------------------------------------------}



end.
