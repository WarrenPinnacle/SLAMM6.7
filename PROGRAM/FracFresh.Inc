//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

{-----------------------------------------------------------------}

//Function TSLAMM_Simulation.FWInfluenced(Row,Col:Integer; PC:PCompressedCell): Boolean;      // does this row/col have any FWFlow polygon associated?


Function TSLAMM_Simulation.FWInfluenced(Row,Col:Integer): Boolean;
var i: Integer;
Begin
  FWInfluenced := False;
  For i := 0 to NumFWFlows - 1 do
    If FWInfluenced(Row,Col,i) then
      Begin
        FWInfluenced := True;
        Exit;
      End;
End;

Function TSLAMM_Simulation.FWInfluenced(Row,Col, FWNum:Integer): Boolean;  // is this row/col associated with the specific FWFlow polygon "FWNum"?
Begin
  Result := FwFlows[FWNum].ScalePoly.InPoly(Row,Col);
End;

{-----------------------------------------------------------------}


    {-----------------------------------------------------------------}
    Function Distance_Pt_2_Line(L: TLine; P: TPoint): Double;
    Var a,b,c: Double;
    Begin
    a := L.p1.X - L.p2.X;
    b := L.P2.Y - L.P1.Y;
    c := L.P1.Y * L.P2.X - L.P2.Y * L.P1.X;
    Distance_Pt_2_Line := (a*P.Y + b*P.X + c) / SQRT(SQR(b)+SQR(a));
    End;
    {-----------------------------------------------------------------}
    Function Distance_Pt_2_LineKM(L: TLine; P: TPoint; Scale: Double): Double;
    Begin
      Distance_PT_2_LineKM := ABS(Distance_Pt_2_Line(L,P))*Scale * 1e-3;
    End;
    {-----------------------------------------------------------------}
    Function CrossLine(P1,P2: TPoint; L: TLine): Boolean;  {Would a line connecitng the two points cross the given line?  line is assumed to be of infinite length in this case}
    Begin
      CrossLine := (Distance_Pt_2_Line(L,P1) * Distance_Pt_2_Line(L,P2)) <= 0;
    End;

   {-----------------------------------------------------------------}
    Function Distance_2ptsKM(P1,P2: TPoint; Scale: Double):Double;
    Begin  {returns distance between two cells in km}
      Distance_2ptsKM := SQRT(SQR(P2.Y-P1.Y)+SQR(P2.X-P1.X))*Scale * 1e-3;
    End;                                           {m}               {m/km}
   {-----------------------------------------------------------------}

Function TSLAMM_Simulation.RiverKM(PR,PC,FWNum: Integer; Var D2C: Double): Double;
{ Calculates river KM given a row and column on the map.
  River KM is calculated in distance from river origin }
  Const River_Influenced = 1; {km, Distance beyond which river reach influence is zero and plume effects dominate}
    Var Pt: TPoint;
        i: Integer;
        TL: TLine;
        InPlume, PlumeCross: Boolean;
        FoundDistance, ThisDistance: Double;

 Begin
      RiverKM := 0;
      FoundDistance := 1e6;
      Pt.Y := PR; Pt.X := PC;
      With FWFlows[FWNum] do
       Begin
         if midpts = nil then Exit;   // avoid crash.
         for i := 0 to numsegments -1 do
           Begin
             TL.P1 := OriginArr[i];   //
             TL.P2 := MouthArr[i];
             PlumeCross := CrossLine(Pt,MidPts[i],PlumeLine[i]);
             If (not CrossLine(Pt,MidPts[i],OriginLine[i])) and
                (not PlumeCross) then
                  Begin
                    ThisDistance := Distance_Pt_2_LineKM(TL,Pt,Site.RunScale);
                    If (ThisDistance < FoundDistance) then
                      Begin
                        RiverKM := Distance_Pt_2_LineKM(OriginLine[i],Pt,Site.RunScale) + D2Origin[i];
                        FoundDistance := ThisDistance;
                        D2C := FoundDistance*1000;
                      End;
                  End;

             If PlumeCross and (i < NumSegments-1)
              then if CrossLine(Pt,MidPts[i+1],OriginLine[i+1])
                then
                  Begin
                    ThisDistance := Distance_2PtsKM(OriginArr[i+1],Pt,Site.RunScale);
                    If (ThisDistance < FoundDistance) then
                      Begin
                        RiverKM := D2Origin[i+1];
                        FoundDistance := ThisDistance;
                        D2C := FoundDistance*1000;
                      End;
                  End;
           End;  {i loop through segments}

         If MidPts = nil then Raise ESLAMMError.Create('Cannot run a site with freshwater flows in which the river channel is not defined.');

         If CrossLine(Pt,MidPts[0],OriginLine[0]) then  {point is above river start}
           Begin
             ThisDistance := Distance_2PtsKM(Pt,OriginArr[0],Site.RunScale);
             If (ThisDistance < FoundDistance)  then
               Begin
                 FoundDistance := ThisDistance;
                 D2C := FoundDistance*1000;
                 RiverKM := 0;
               End;
           End;

         InPlume := CrossLine(Pt,MidPts[numsegments-1],PlumeLine[numsegments-1]); {if point is after river empties into estuary}
         If Not InPlume then
           Inplume := (FoundDistance > River_Influenced) and (Distance_Pt_2_LineKM(PlumeLine[numsegments-1],Pt,Site.RunScale) < 3);
                 {or river influence max has been exceeded and point is within 3km of the plume line}

         If InPlume then
           Begin
             ThisDistance := Distance_2PtsKM(Pt,MouthArr[numsegments-1],Site.RunScale);
             If (ThisDistance < FoundDistance) or (FoundDistance > River_Influenced) then
               Begin
                 RiverKM := Distance_2PtsKM(Pt,MouthArr[numsegments-1],Site.RunScale) + EstuaryLength;
                 D2C := (Result - EstuaryLength)*1000;
                 If RiverMouthIndex > (Trunc (Result / SliceIncrement) - 1) then
                    RiverMouthIndex := Trunc (Result / SliceIncrement) - 1;
               End;
           End;

       End; {with}
    End;
   {-----------------------------------------------------------------}


Function TSLAMM_Simulation.FreshWaterHeight(ThisCell: PCompressedCell; FR,FC: Integer;
                                            Var FWSal, SWSal: Double; Var Salh: Double;
                                            TideInt: Integer; Var SegSalin:Double): Double;
       { Procedure calculates the vertical fresh water depth at this cell at the given year.
         This was calcuated in update geometry using the F-Table (volume to depth) available for each river cross section area }

Var CellElev, FreshHeight: Double;
    RKM: Double;
    RSeg: Integer;
    FWNum: Integer;
    SalZ : Double;
    D2C: Double;
  //  CellCat: Integer;

Begin
  CellElev := GetMinElev(ThisCell);

  Result := 0;
  FWSal := 0;
  SWSal := 30;
  SegSalin := 0;

  Salh := -99;
  If ClassicDike and ThisCell.ProtDikes then exit;
  if (not ClassicDike) and (ThisCell.ProtDikes) and (not ThisCell.ElevDikes) then exit;

  For FWNum := 0 to NumFWFlows-1 do
   If FwInfluenced(FR,FC,FWNum) then
    With FWFlows[FWNum] do
     If Not ExtentOnly then
       Begin

         RKM := RiverKM(FR,FC,FWNum,D2C);                {calculate the river KM for this cell}
         RSeg :=  Trunc (RKM / SliceIncrement);          {calculate the river segment index for this cell}
                        {km}       {km}

         SegSalin := XS_Salinity[TideInt,RSeg]; {ppm}     {get the cross sectional salinity for the XS this cell resides in}

           Case TideInt of                                        {calculate the salt wedge height given the tide}
                1: SalZ := SaltHeight(OceanSubSite.MLLW,OceanSubSite.NewSL,RSeg,Year);
                2: SalZ := SaltHeight(0.0,OceanSubSite.NewSL,RSeg,Year);
                3: SalZ := SaltHeight(OceanSubSite.MHHW,OceanSubSite.NewSL,RSeg,Year);
                else SalZ := SaltHeight(OceanSubSite.SaltElev,OceanSubSite.NewSL,RSeg,Year);
              end; {case}                                             // optimize salinity possible here by passing arrays

         If SalZ < CellElev then SalZ := CellElev;                  // if the salt wedge height is less than the cell elevation set to cell elevation; salinity will be zero
         If TideInt = 1 then ThisCell.SalHeightMLLW := SalZ;        // save for display purposes

         If SalZ-CellElev > Salh then                          // set the salinity height to the deepest encountered in various FW flows
           Salh := SalZ-CellElev;

         FreshHeight  := WaterZ[TideInt,RSeg] - SalZ;   //assign fresh water height based on F-Tables

         If (FreshHeight) > Result {0} then
           Begin
             FWSal := ((FWSal *        Result) + (FWPPT * FreshHeight)) /  (Result+FreshHeight);
             SWSal := ((SWSal *        Result) + (SWPPT * FreshHeight)) /  (Result+FreshHeight);
                 {prev sal} {prev height}    {new sal}  {new height}     {additive heights}
             {weighted avg. fresh water salinity}

            Result := FreshHeight;  {choose largest Freshheight}
                    // Result + FreshHeight;  {additive fresh water influence}
             {m above MTL}
           End;
       End;
End;

Function TSLAMM_Simulation.CalcSalinity(RunChngwater, TimeZero: Boolean): Boolean;  {Set salinity attributes for all cells in a map}
Const Elev_Factor = 0.25;
Var SWSal, FWSal, Salh: Double;
    SalCell: CompressedCell;

    {-----------------------------------------------------------------------}
    Function CalcSalin(SWHeight, FWHeight: Double): Double;
    Begin
      If ClassicDike and SalCell.ProtDikes then Result := -999 {no water influence, omit from stats}
       else if (not ClassicDike) and (SalCell.ProtDikes) and (not SalCell.ElevDikes) then Result := -999
       else If ((SWHeight <= 0) and (FWHeight <= 0)) then Begin If GetCellCat(@SalCell) = Categories.openocean  // JSC Not estuarine water or riverine tidal  8/17/12
                                                                then Result := SWSal
                                                                else Result := -999; {no water influence, omit from stats}
                                                          End
        else If (SWHeight <= 0)
          then Result := FWSal {all fresh water;  FWSal set in FreshWaterHeight}
          else If (FWHeight <= 0)
            then Result := SWSal {all saline; SWSal set in FreshWaterHeight}
            else Result := ((SWHeight * SWSal) + (FWHeight* FWSal)) / (SWHeight+ FWHeight)
    End;
    {-----------------------------------------------------------------------}

Var CellElev, FWh: Double;
    ER, EC: Integer;

    {-----------------------------------------------------------------------}
    Procedure CellSalinity;
    Var SegSalin: Double;
        TideInt: Integer;
    Const    
        MIXINGFACTOR = 0.25;  //[0 to 1.0]
    Begin
      CellElev := GetMinElev(@SalCell);

      For TideInt := 1 to 4 do  // MLLW, MTL, MHHW, SALTELEV
        Begin
          FWh := FreshWaterHeight(@SalCell,ER,EC,FWSal,SWSal,Salh,TideInt,SegSalin);
          SalCell.Sal[TideInt] := ((1-MIXINGFACTOR) * CalcSalin(Salh,Fwh)) + (MIXINGFACTOR * SegSalin);
          If SalCell.Sal[TideInt]<0 then SalCell.Sal[TideInt]:= -999;
        End;

    End;
    {-----------------------------------------------------------------------}
(*    Procedure CSVOutput;  Debug data for Georgia Salinity Project
      Var TextOut: TextFile;
      OutN: String;
      Appending,WriteError: Boolean;
      i,RN,FWF: Integer;
      SegSalin, LMERRM, RKM: Double;
      Const CSVIter = 2;  //1 = Altamaha 2 = GA
        MIXINGFACTOR = 0.25;  //[0 to 1.0]


    Begin
      If CSVIter = 1 then OutN := 'AltSalinity'
                     else OutN := 'AllGASalinity';

      Repeat
        WriteError := False;
        Try
          Appending := FileExists('C:\newtemp\'+OutN+'.csv');
          AssignFile(TextOut,'C:\newtemp\'+OutN+'.csv');
          If Appending then Append(TextOut)
                       else Rewrite(TextOut);
        Except
          If MessageDlg('Error writing to file '+'C:\newtemp\'+OutN+'.csv'+'.  Retry?',mterror,[mbyes,mbno],0)
            = mryes then WriteError := True
                    else Exit;
        End;
      Until Not WriteError;


      For FWF := 0 to NumFWFlows - 1 do
       For RN := 0 to FWFlows[FWF].MaxRn-1 do
        //If RN MOD 10 = 0 then
          Begin
            RKM := RN * SliceIncrement;
            If (FWF > 4) then Break;
            If CSVIter = 1 then LMERRM := -1.3521*RKM + 76.995    // ALTAMAHA 2 (stand alone)
               else Case FWF of
                 0:   LMERRM := -1.094*RKM+80.1 ; //  Savannah
                 1:   Begin
                        If RKM < 30 then LMERRM := -999
                                    else LMERRM := (-0.0001089211*(Power(RKM,4)))+(0.0216*Power(RKM,3))-(1.5434*Power(RKM,2))+(45.122*RKM)-401.12;  //Ogeechee
                      End;
                 2:   LMERRM :=  -1.3596*RKM + 77.079;   // Altamaha
                 3:   LMERRM :=  -1.1715*RKM + 115.37;  // Satilla
                 else LMERRM :=  0.010023*Power(RKM,2) - 2.7007*RKM + 146.21; //Saint Mary
              end; {Case}

            If (LMERRM >= -2) and (LMERRM < 46) then
              Begin
                FWFlows[FWF].CellByRN(RN,ER,EC);
                If (ER<0) or (EC<0) or (EC >Site.RunCols-1) or (ER>Site.RunRows-1) then Continue;
                RetA(ER,EC,SalCell);
                For i := 1 to NUM_CAT_COMPRESS do
                  SalCell.MinElevs[i] := -1 - 1.76;  // Set to 1.76 below MLLW to compare to 0.88 m depth MLLW samples.  This is not saved.

                FWh := FreshWaterHeight(@SalCell,ER,EC,FWSal,SWSal,Salh,1,SegSalin);
                SalCell.Sal[1] := ((1-MIXINGFACTOR) * CalcSalin(Salh,Fwh)) + (MIXINGFACTOR * SegSalin);
                If SalCell.Sal[1]<0 then SalCell.Sal[1]:= -999;
               // CellSalinity;

          //      If SalCell.Sal[1] > -1 then
                  Writeln(TextOut,'"'+FWFlows[FWF].Name  +'",' +
                                  '"'+IntToStr(year)+'",'+
                                  '"MLLW",'+
                                  FloatToStrf(FWFlows[FWF].XS_Salinity[1,RN],ffgeneral,8,8)+','+
                                  FloatToStrf(FWFlows[FWF].WaterZ[1,RN],ffgeneral,8,8)+','+
                                  FloatToStrf(LMERRM,ffgeneral,8,8)+','+
                                  FloatToStrf(SalCell.Sal[1],ffgeneral,8,8)+','+
                                  FloatToStrf(RKM,ffgeneral,8,8)+','+
                                  FloatToStrf(FWFlows[FWF].FlowByYear(Year),ffgeneral,8,8)+','+
                                  FloatToStrf(FWFlows[FWF].SaltWedgeSlopeByYear(Year),ffgeneral,8,8)+','+
                                  FloatToStrf(FWFlows[FWF].Origin_km,ffgeneral,8,8)+','+
                                  FloatToStrf(FWFlows[FWF].SWPPT,ffgeneral,8,8)+','+
                                  FloatToStrf(Fwh,ffgeneral,8,8)+','+
                                  FloatToStrf(Salh,ffgeneral,8,8)+','+
                                  FloatToStrf(SegSalin,ffgeneral,8,8)+','+
                                  '"'+DateTimeToStr(Now())+'"');
//                                  else Begin
//                                         CellSalinity;
//                                       End;
              End;
          End;
       Closefile(Textout);
    End;  {csvoutput}  *)
    {-----------------------------------------------------------------------}
    Procedure SalinityFromExcel;
    Var ER, EC: Integer;
        CC: Integer;
        SlopeAdjustment: Double;
        CE: Double;
        Elev: Double;
        SubSite: TSubSite;
        SLAMM_RSLR, SLAMM_Q: Double;
        SalVal: TDoubleArray;
    Begin
      ProgForm.ProgressLabel.Caption:='Interpolating Salinity :';
      ProgForm.YearLabel.Caption:=IntToStr(Year);

      if TimeZero then if SalArray<> nil then SalArray.Destroy;
      if TimeZero or (SalArray=nil) then SalArray := TSalArray.ReadSalArrayFromExcel(SalFileN,Site);

      //Get the raster cell of the point closest to the river mounth for calculationg the RSLR
      ER := Trunc(Salarray.SLocs[SalArray.NSalStations -1].Y);
      EC := Trunc(salarray.SLocs[SalArray.NSalStations-1].X);
      RetA(ER,EC,SalCell);

      //Get the subsite
      SubSite := Site.GetSubSite(EC,ER,@SalCell);

      //Calculation of the RLRS
      SLAMM_RSLR := SubSite.Norm*0.01 {eustatic since simulation start} - SalCell.Uplift*(Year-Site.T0)*0.01 {local since simulation start};
      {m}             {cm}    {m/cm}                                        {cm/y}       {y}    {m/cm}

      //Extract corresponding salinity values
      SLAMM_Q := FwFlows[0].FlowbyYear(Year);  //Marco: For now calculating flowfrom the FwFlows with index=0
      SalVal := SalArray.ExtractSalinityRecord(SLAMM_RSLR,SLAMM_Q);

       FOR ER := 0 To (Site.RunRows-1) Do
        FOR EC := 0 To (Site.RunCols-1) Do
         If FwInfluenced(ER,EC,0) then  //Marco: For now calculating salinity only in the FwFlow with index=0
          Begin
            RetA(ER,EC,SalCell);

            // Get cell category
            CC := GetCellCat(@SalCell);

            // Adjustment of the slope
            SlopeAdjustment := (Site.RunScale*0.5) * SalCell.TanSlope;   {QA 11.10.2005}

            // Get minimum elevation
            CE := CatElev(@SalCell,CC);


            // If elevation is 999 (no data) do not process
            if CE = 999 then continue;

            // Then elevation in m is ...
            if CC = Blank then Elev := 0
                     else Elev := (CE+SlopeAdjustment);

            // Get the cell subsite
            SubSite := Site.GetSubSite(EC,ER,@SalCell);

            // IF elevation <= Salt Boundary then calsulate salinity otherwise skip
            if Elev<= Subsite.SaltElev then
              begin
                SalCell.Sal[1] := SalArray.GetSalinity(EC,ER,SalVal);
                SetA(ER,EC,SalCell);
              end;

            Result := ProgForm.Update2Gages(Trunc((Er)/Site.RunRows*100),0);

            If Not Result then Exit;
          End;

      If TimeZero then Result := AggrSalinityStats;
    End;
    {-----------------------------------------------------------------------}


Var AllExtentOnly: Boolean;
    FWNum: Integer;
Begin   {CalcSalinity}
 Result := True;

 if (Pos('.xls',lowercase(SalFileN))>0) then
  Begin
    SalinityFromExcel;
    Exit;
  End;

 AllExtentOnly := True;               {Exit if all fresh water flows are "extent only"}
 For FWNum := 0 to NumFWFlows-1 do
  with FWFlows[FWNum] do
   If not ExtentOnly then AllExtentOnly := False;
 If AllExtentOnly then Exit;

 If RunChngWater then Result := ChngWater(False,True);
 If Not Result then Exit;

 If NumFWFlows > 0 then
    Begin
      ProgForm.ProgressLabel.Caption:='Calculating Salinity :';

       FOR ER := 0 To (Site.RunRows-1) Do
        FOR EC := 0 To (Site.RunCols-1) Do
         If FwInfluenced(ER,EC) then
          Begin
           RetA(ER,EC,SalCell);
           CellSalinity;
           SetA(ER,EC,SalCell);
           Result := ProgForm.Update2Gages(Trunc((Er)/Site.RunRows*100),0);
           If Not Result then Exit;
          End;

      If TimeZero then Result := AggrSalinityStats;
//      CSVOutput;
    End;
End;


Function TSLAMM_Simulation.AggrSalinityStats: Boolean;
Var Sal, MinH, MaxH: Double;
    Cat, CL, CC: Integer;
    i,j, ind: Integer;
    ER, EC: Integer;
    SalCell: CompressedCell;
    Values: Array[1..NUM_SAL_METRICS,0..MaxCats] of Array of Single;
    NSalMet: integer;

Begin
  //Initialize function output
  Result := True;

  //Initialize statistical variables
  For CL := 0 to Categories.NCats-1 do
   with Categories.GetCat(CL).SalinityStats do
    Begin
      for i := 1 to NUM_SAL_METRICS do
        Begin
          N[i] := 0;
          Min[i] := 1e6;
          Max[i] := 1e-6;
          Sum[i] := 0;
          Sum_e2[i] := 0;
          Mean[i]  := 0;
          StDev[i] := 0;
          For j := 0 to SalHistWidth-1 do
            Histogram[i,j] := 0;
        End;
    End;


  //Initialize number of salinity metrics
  if (SalFileN<>'') then
    NSalMet := 1
  else
    NSalMet := NUM_SAL_METRICS;

  // Show Progress Form
  ProgForm.Show;

  //Progress form label
  ProgForm.ProgressLabel.Caption:='Aggregating Salinity Stats.:';

  FOR ER := 0 To (Site.RunRows-1) Do
   FOR EC := 0 To (Site.RunCols-1) Do
    Begin

     // Do not save data is there is no salinity file or if the cell is not defined in the flow influenced area
     If (SalFileN='') and (FwInfluenced(ER,EC)=False)  then Continue;

     RetA(ER,EC,SalCell);

     Cat := GetCellCat(@SalCell);
     If ClassicDike and SalCell.ProtDikes then Continue; {don't save Salinity stats for Diked Cells}
     if (not ClassicDike) and (SalCell.ProtDikes) and (not SalCell.ElevDikes) then Continue;

     For i := 1 to NSalMet do
       Begin
         Sal := SalCell.Sal[i];
         If Sal<>-999 then
           With Categories.GetCat(Cat).SalinityStats do
             Begin
              If Sal < 0 then Sal := 0;
              Inc(N[i]);
              If Sal < Min[i] then Min[i] := Sal;
              If Sal > Max[i] then Max[i] := Sal;
              Sum[i] := Sum[i] + Sal;
//              SumX2[i] := SumX2[i] + Sal*Sal;
              MinH := MinHist;
              MaxH := MaxHist;
              If (Sal >= MinH) and (Sal<MaxH) then
                Inc(Histogram[i,TRUNC(SalHistWidth*(Sal-MinH)/(MaxH-MinH))])  {increment appropriate bin}
             End; {with salStats}
       End; {for i Loop}

     Result := ProgForm.Update2Gages(Trunc((Er)/Site.RunRows*100),0);
     If Not Result then Exit;
    End;  {ER, EC loop}

  For i := 1 to NSalMet do
   For CC := 0 to Categories.NCats-1 do
    with Categories.GetCat(CC).SalinityStats do
       Begin
         SetLength(Values[i,CC],N[i]);
         if N[i] > 0 then
          Mean[i] := Sum[i]/N[i]
         else
          begin
            Mean[i] := 0;
            Min[i] :=0;
            Max[i] :=0;
          end;
       End;

  For i := 1 to NSalMet do
   For CC := 0 to Categories.NCats-1 do
    with Categories.GetCat(CC).SalinityStats do
      N[i] := 0;

 FOR ER := 0 To (Site.RunRows-1) Do
   FOR EC := 0 To (Site.RunCols-1) Do
    Begin  {Second Pass Statistics}

      // Do not save data is there is no salinity file or if the cell is not defined in the flow influenced area
      if (SalFileN='') and (FwInfluenced(ER,EC)=False)  then Continue;

       RetA(ER, EC, SalCell);
       If EC=0 then Begin
                      Result := ProgForm.Update2Gages(Trunc((Er)/Site.RunRows*100),0);
                      If Not Result then Exit;
                    End;

       If CLassicDike and SalCell.ProtDikes then Continue;
       if (not ClassicDike) and (SalCell.ProtDikes) and (not SalCell.ElevDikes) then Continue;

       For i := 1 to NSalMet do
         Begin
           Sal := SalCell.Sal[i];
           CC := GetCellCat(@SalCell);

           If Sal<>-999 then
            with Categories.GetCat(CC).SalinityStats do
             Begin
              If Sal < 0 then Sal := 0;
              Inc(N[i]);
              Values[i,CC,N[i]-1] := Sal;  //crashhere
              Sum_e2[i] := Sum_e2[i] + Sqr(Sal-Mean[i]);
             End; {with}
         End; {for i}

     Result := ProgForm.Update2Gages(Trunc((Er)/Site.RunRows*100),0);
     If Not Result then Exit;
    End; {for ER, EC}

  For i := 1 to NSalMet do
   For CC := 0 to Categories.NCats-1 do
    with Categories.GetCat(CC).SalinityStats do
      Begin
        if N[i]<=1 then
          begin StDev[i] := 0; P05[i]:=0; P95[i]:=0; End
        else
          begin
            // Standard deviation
            StDev[i] := sqrt(Sum_e2[i]/(N[i]-1));

            //Sort values
            QuickSort(Values[i,CC],0,N[i]-1);

            // Fifth percentile
            Ind :=Round(0.05*(n[i]+1))-1;
            if Ind<0 then Ind := 0;
            P05[i] := Values[i,CC,Ind];

            // Ninetyfifth percentile
            Ind :=Round(0.95*(n[i]+1))-1;
            If (Ind>N[i]-1) then Ind := N[i]-1;
            P95[i] := Values[i,CC,Ind];
          end;
     End; {with SalStats}

  For i := 1 to NSalMet do
   For CC := 0 to Categories.NCats-1 do
     Values[i,CC] := nil; {Deallocate dynamic arrays}

  Init_SalStats := True;

  SalStatsDerived := Now();
  ProgForm.Hide;

End; {procedure}


{*********************************************************************************************************}


Procedure TSLAMM_Simulation.ClearFlowGeometry;
Var i,j: Integer;
Begin
  For j :=0 to NumFWFlows-1 do
   With FWFlows[j] do
     Begin
      MidPts := nil;

      D2Origin := nil;

      For i := 1 to NUM_SAL_METRICS do
       Begin
        RetTime[i] := nil;
        WaterZ[i] := nil;
        XS_Salinity[i] := nil;
       End;

      OriginLine := nil;
      PlumeLine := nil;
    End;
End;

Function TSLAMM_Simulation.CalculateFlowGeometry(Yr: Integer): Boolean;

Var   ArrayLen : Integer;

   {-----------------------------------------------------------------}
   Procedure SETUP_GEOMETRY;
   var e,i,j,k: integer;
       RowVector, ColVector: Integer;
   Begin
     For e := 0 to NumFWFlows-1 do
      With FWFlows[e] do
       If Not ExtentOnly then
       Begin
        MaxRn := 0;

        If MidPts = nil then
         BEGIN

          SetLength(MidPts,NumSegments);
          SetLength(OriginLine,NumSegments);
          SetLength(PlumeLine,NumSegments);
          SetLength(D2Origin,NumSegments);

          EstuaryLength := 0;

          For i := 0 to NumSegments -1 do
            Begin
              MidPts[i].Y := (MouthArr[i].Y+OriginArr[i].Y)Div 2;
              MidPts[i].X := (MouthArr[i].X+OriginArr[i].X)Div 2;

              RowVector := MouthArr[i].Y - OriginArr[i].Y;
              ColVector := MouthArr[i].X - OriginArr[i].X;
              OriginLine[i].P1 := OriginArr[i];
              PlumeLine[i].P1 := MouthArr[i];

              If ColVector<>0
                then Begin
     {                 Slope := RowVector / ColVector; }
                       OriginLine[i].P2.Y := OriginArr[i].Y + ColVector;
                       OriginLine[i].P2.X := OriginArr[i].X - RowVector;
                       PlumeLine[i].P2.Y := MouthArr[i].Y + ColVector;
                       PlumeLine[i].P2.X := MouthArr[i].X - RowVector;
                     End
                else Begin
                       OriginLine[i].P2.Y := OriginArr[i].Y;
                       OriginLine[i].P2.X := OriginArr[i].X - 1;
                       PlumeLine[i].P2.Y := MouthArr[i].Y;
                       PlumeLine[i].P2.X := MouthArr[i].X - 1;
                     End;

              D2Origin[i] := EstuaryLength; {prior to addition}
              EstuaryLength := EstuaryLength + Distance_2ptsKM(OriginArr[i],MouthArr[i],Site.RunScale);
                {km}
           End;

          ArrayLen := TRUNC(EstuaryLength/SliceIncrement)+50; {allows for 25km plume   }

          For k := 1 to NUM_SAL_METRICS do
           Begin
             SetLength(RetTime[k],ArrayLen);
             For j := 0 to ArrayLen-1 do
               RetTime[k,j] := 0;

             SetLength(WaterZ[k],ArrayLen);
             SetLength(XS_Salinity[k],ArrayLen);
           End;

          SetLength(SubSiteArr,ArrayLen);
          SetLength(FTables,ArrayLen);
          SetLength(NumCells,ArrayLen);

          ArrayLen := Length(FTables);
         END; {MidPts = nil}

        ArrayLen := Length(FTables);
        For i := 0 to ArrayLen-1 do
          Begin
            For j := 0 to N_FTABLE-1 do
              FTables[i][j] := 0;
            NumCells[i] := 0;

            For k := 1 to NUM_SAL_METRICS do
             Begin
               WaterZ[k,i] := 0;
               XS_Salinity[k,i] := 0;
             End;

            SubsiteArr[i] := nil;
          End;

         RiverMouthIndex := 999999;

       End;
   End;

Var FWNum: Integer;

   {-----------------------------------------------------------------}
   Procedure AddLength(Max: Integer);
   Var i,j,k,ArrayLen: Integer;
   Begin
     With FWFlows[FWNum] do
       Begin
         ArrayLen := Max + 50;
         SetLength(NumCells,ArrayLen);
          For k := 1 to NUM_SAL_METRICS do
           Begin
             SetLength(RetTime[k],ArrayLen);
             SetLength(WaterZ[k],ArrayLen);
             SetLength(XS_Salinity[k],ArrayLen);
           End;

         SetLength(SubSiteArr,ArrayLen);
         SetLength(FTables,ArrayLen);

         For i := ArrayLen-50 to ArrayLen-1 do
            Begin
              For j := 0 to N_FTABLE-1 do
                FTables[i][j] := 0;
              NumCells[i] := 0;
              For k := 1 to NUM_SAL_METRICS do
               Begin
                 RetTime[k,i] := 0;
                 WaterZ[k,i] := 0;
                 SetLength(WaterZ[k],ArrayLen);
                 SetLength(XS_Salinity[k],ArrayLen);
               End;

              NumCells[i] := 0;
              SubSiteArr[i] := nil;
            End;
       End;
   End;

   {-----------------------------------------------------------------}

Var i, ER, EC, Rn: Integer;
    RKM, CellArea, CellElev, TestElev : Double;
    Cl: CompressedCell;
    D2C, SalZ, FWFlow, VolFresh, VolSalt : Double;
    AllExtentOnly: Boolean;

Begin
 Result := True;
 ProgForm.ProgressLabel.Caption:='Calculating Flow Geometry: '+IntToStr(Yr);
 ProgForm.Show;


 If NumFWFlows = 0 then Exit;

 AllExtentOnly := True;
 For FWNum := 0 to NumFWFlows-1 do
  with FWFlows[FWNum] do
   If not ExtentOnly then AllExtentOnly := False;
 If AllExtentOnly then Exit;

 SETUP_GEOMETRY;

 CellArea := Site.RunScale * Site.RunScale; {m2}

 FOR ER := 0 To (Site.RunRows-1) Do
  FOR EC := 0 To (Site.RunCols-1) Do
   For FWNum := 0 to NumFWFlows-1 do  {Loop to calculate F-Tables}
    Begin
      If EC=0 then Begin
                     Result := ProgForm.Update2Gages(Trunc((ER)/Site.RunRows*(100)),0);
                     If Not Result then Exit;
                   End;

      If FwInfluenced(ER,EC,FWNum) then
       If not FWFlows[FWNum].ExtentOnly then
       Begin

        RKM := RiverKM(ER,EC,FWNum,D2C);
        Rn := Trunc (RKM / SliceIncrement);

        With FWFlows[FWNum] do
          Begin
            TestMin := (Site.GlobalSite.MLLW-2);
            TestRange := (Site.GlobalSite.MHHW+2) - TestMin ;

            If (Rn + 1 > Length(FTables)) then
              AddLength(Rn+1);
            If Rn>MaxRn then
              Begin
                MaxRn := Rn;
                OceanSubsite := Site.GetSubsite(EC {x},ER {y});
              End;
             SubsiteArr[Rn] := Site.GetSubsite(EC {x},ER {y});
            Inc(NumCells[Rn]);
          End;

        RetA(ER, EC, Cl);

        If ((ClassicDike) and (not CL.ProtDikes)) or
           ((not ClassicDike) and (not CL.ProtDikes)) or
           ((not ClassicDike) and (CL.ElevDikes)) then
          Begin
            CellElev := GetMinElev(@Cl);

            For i := 0 to N_FTable-1 do
             with FWFlows[FWNum] do
              Begin
                TestElev := TestMin + (TestRange / (N_FTable-1))*i;
                If CellElev < TestElev then
                    FTables[Rn][i] := FTables[Rn][i] + (TestElev-CellElev) * CellArea;   {sum area under depth at this river mile}
                        {m3}                                  {m}                {m2}
              End; {with}
          End;
       End; {FwInfluenced}
    End; {loops}

   { Calculate Water Heights for each Estuary Slice }
    For FWNum := 0 to NumFWFlows-1 do
     with FWFlows[FWNum] do
      If Not ExtentOnly then
       If RetentionInitialized then
        For Rn := 0 to Length(FTables)-1 do
         For i := 1 to NUM_SAL_METRICS do
          Begin
            Case i of                                // Upgrade consider here the migration of the salt wedge as a function of flow regime?
              1: SalZ := SaltHeight(OceanSubSite.MLLW,OceanSubSite.NewSL, Rn,Year);  {elevation of salt wedge relative to MTL}
              2: SalZ := SaltHeight(0.0,OceanSubSite.NewSL, Rn,Year);
              3: SalZ := SaltHeight(OceanSubSite.MHHW,OceanSubSite.NewSL, Rn,Year);
              else SalZ := SaltHeight(OceanSubSite.SaltElev,OceanSubSite.NewSL, Rn,Year);
            end; {case}

            FWFlow := FlowByYear(Yr);
            VolFresh := FWFlow * RetTime[i,Rn];
            VolSalt := VolumeByElev(SalZ,Rn);
            if VolSalt+VolFresh > Tiny
              then XS_Salinity[i,Rn] := ((VolFresh* fwppt)+ (VolSalt*swppt)) / (VolSalt+VolFresh)  //weighted avg salinity of XSec
              else XS_Salinity[i,Rn] := 0;

            WaterZ[i,Rn] := ElevByVolume(VolSalt + VolFresh,Rn);    //water depth by river mile and tide
          End;

   {Calculate Retention Times for each Estuary Slice, "Time Zero" }
    For FWNum := 0 to NumFWFlows-1 do
     with FWFlows[FWNum] do
     If Not ExtentOnly then
      If Not RetentionInitialized then
        For Rn := 0 to MaxRn do
         For i := 1 to NUM_SAL_METRICS do
          Begin
            Case i of
              1: SalZ := SaltHeight(OceanSubSite.MLLW,OceanSubSite.NewSL, Rn,Year);  {elevation of salt wedge relative to MTL}
              2: SalZ := SaltHeight(0,OceanSubSite.NewSL, Rn,Year);
              3: SalZ := SaltHeight(OceanSubSite.MHHW,OceanSubSite.NewSL, Rn,Year);
              else SalZ := SaltHeight(OceanSubSite.SaltElev,OceanSubSite.NewSL, Rn,Year);
            end; {case}

            Try
            Case i of
              1: WaterZ[i,Rn] := SubsiteArr[Rn].MLLW;        //water depth by river mile and tide
              2: WaterZ[i,Rn] := 0;
              3: WaterZ[i,Rn] := SubsiteArr[Rn].MHHW;
              else WaterZ[i,Rn] := SubsiteArr[Rn].SaltElev;
            end; {case}
            Except
               Salz := Salz;
            End;

            VolSalt := VolumeByElev(SalZ,Rn);
            VolFresh := VolumeByElev(WaterZ[i,Rn],Rn) - VolSalt;
              {m3}

            FWFlow := FlowByYear(Yr);
            If FWFlow = 0
              then RetTime[i,Rn] := 0
              else RetTime[i,Rn] := VolFresh / FWFlow;
                       {s}            {m3}    {m3/s}

            If VolSalt+VolFresh > Tiny
              then XS_Salinity[i,Rn] := ((VolFresh* fwppt)+ (VolSalt*swppt)) / (VolSalt+VolFresh)  //weighted avg salinity of XSec
              else XS_Salinity[i,Rn] := 0;

            RetentionInitialized := True;
          End; {Retention Time loops}

   Smooth_XS_Salinity
End;

Procedure TSLAMM_Simulation.Smooth_XS_Salinity;
Var FWNum, Rn, i, Adjustments: Integer;
    MeanXS: Double;
Begin
    {smooth XS_Salinity}
    For Adjustments := 1 to 3 do
      For FWNum := 0 to NumFWFlows-1 do
       with FWFlows[FWNum] do
        If Not ExtentOnly then
         For Rn := 0 to MaxRn-1 do
          For i := 1 to NUM_SAL_METRICS do
           Begin
             If (XS_Salinity[i,Rn] > XS_Salinity[i,Rn+1]) and
                 (XS_Salinity[i,Rn] > Tiny) and (XS_Salinity[i,Rn+1]>Tiny)
               then
               Begin  {salinity increasing upstream, so average the two}
                 MeanXS := (XS_Salinity[i,Rn] + XS_Salinity[i,Rn+1]) * 0.5;
                 XS_Salinity[i,Rn] := MeanXS;
                 XS_Salinity[i,Rn+1] := MeanXS;
               End;
           End;

    {adjust XS_Salinity so there's no upstream areas more saline then downstream areas}
      For FWNum := 0 to NumFWFlows-1 do
       with FWFlows[FWNum] do
        If Not ExtentOnly then
         For Rn := MaxRn-1 downto 0 do
          For i := 1 to NUM_SAL_METRICS do
           Begin
             If (XS_Salinity[i,Rn] > XS_Salinity[i,Rn+1]) and
                 (XS_Salinity[i,Rn] > Tiny) and (XS_Salinity[i,Rn+1]>Tiny)
               then
               Begin  {salinity increasing upstream, so set upstream segment to salinity of lower}
                 XS_Salinity[i,Rn] := XS_Salinity[i,Rn+1];
               End;
           End;

End;

// SAV CODE BELOW


Function TSLAMM_Simulation.CalculateEucDistances: Boolean;
Type TPointArr = Array of TPoint;
Var ER, EC: Integer;
    Cl: CompressedCell;
    Cat: Integer;
    CellElev: Double;
    subsite:TSubsite;
    MLLWArr, MHHWArr: TPointArr;
    ThisPt: TPoint;
    NMLLW, NMHHW: Integer;
    PMLLW: TPoint;
    PMHHW: TPoint;

Const Tolerance = 0.03; {m, close enough to MLLW or MHHW to be considered part of the contour}

    Function Distance_2ptsM(P1,P2: TPoint):Double;
    Begin  {returns distance between two cells in m}
      //Distance_2ptsM := SQRT(SQR(P2.Y-P1.Y)+SQR(P2.X-P1.X))*Site.Scale;
                                                 {cells}     {m/cell}

      //Squared distance in cells unit to compare
      Distance_2ptsM := SQR(P2.Y-P1.Y)+SQR(P2.X-P1.X);

    End;

     Procedure AddToArray(Var Arr: TPointArr; Var Counter: Integer);
     Begin
       Inc(Counter);
       If Counter>Length(Arr) then SetLength(Arr,Counter+2000);
       Arr[Counter-1].X := EC;
       Arr[Counter-1].Y := ER;
     End;

     Function DistanceTo(Var Arr: TPointArr; Var Counter: Integer): Double;
     Var i: Integer;
         TestDist, Result2: Double;
         MaxDist : integer;

     Begin

       Result2:= 10000000000;
       Result := sqrt(Result2)*Site.RunScale;
       MaxDist := 100000;

       For i := 0 to Counter-1 do
         Begin
           if (Arr[i].X>(ThisPt.X-MaxDist)) and (Arr[i].X<(ThisPt.X+MaxDist))
           and (Arr[i].Y>(ThisPt.Y-MaxDist)) and (Arr[i].Y<(ThisPt.Y+MaxDist)) then
            begin
              TestDist := Distance_2ptsM(ThisPt,Arr[i]);
              if TestDist < Result2 then
                begin
                  Result2 := TestDist;
                  Result := sqrt(TestDist)*Site.RunScale;
                  MaxDist := round(sqrt(Result2))+1;
                end;
            end;
         End;
     End;

     Function DistanceTo2(Var Arr: TPointArr; Var Counter: Integer; Var P2: TPoint): Double;
     //Calculate the minum distance to some line using. Compared to DistanceTo this function
     //uses the previous cell estimation as initial minimum distance
     Var i: Integer;
         TestDist, Result2: Double;
         MaxDist : integer;

     Begin

       Result2:= Distance_2ptsM(ThisPt,P2);
       Result := sqrt(Result2)*Site.RunScale;
       MaxDist := round(sqrt(Result2))+1;

       For i := 0 to Counter-1 do
         Begin
           if (Arr[i].X>(ThisPt.X-MaxDist)) and (Arr[i].X<(ThisPt.X+MaxDist))
           and (Arr[i].Y>(ThisPt.Y-MaxDist)) and (Arr[i].Y<(ThisPt.Y+MaxDist)) then
            begin
              TestDist := Distance_2ptsM(ThisPt,Arr[i]);
              if TestDist < Result2 then
                begin
                  Result2 := TestDist;
                  Result := sqrt(TestDist)*Site.RunScale;
                  MaxDist := round(sqrt(Result2))+1;
                  P2.X := Arr[i].X;
                  P2.Y := Arr[i].Y;
                end;
            end;
         End;
     End;

     Procedure ReadyForExit;
     Begin
       MLLWArr := nil;
       MHHWArr := nil;
       ProgForm.Hide;
     End;


Begin
 Result := True;
 ProgForm.ProgressLabel.Caption:='Locating MLLW, MHHW';
 ProgForm.Show;

 SetLength(MLLWArr,1000);
 SetLength(MHHWArr,1000);
 NMLLW := 0; NMHHW := 0;

 // Identify the cells for MHHW and MLLW
 FOR ER := 0 To (Site.RunRows-1) Do
  FOR EC := 0 To (Site.RunCols-1) Do
   Begin
     If EC=0 then Begin
                    Result := ProgForm.Update2Gages(Trunc((ER)/Site.RunRows*(100)),0);
                    If Not Result then Begin ReadyForExit; Exit; End;
                  End;

     RetA(ER, EC, Cl);
     CellElev := GetMinElev(@Cl);
     SubSite := Site.GetSubSite(EC,ER,@Cl);

     If ABS(CellElev-SubSite.MHHW) < Tolerance then AddToArray(MHHWArr,NMHHW);
     If ABS(CellElev-SubSite.MLLW) < Tolerance then AddToArray(MLLWArr,NMLLW);
    End;

 //Show progress label
 ProgForm.ProgressLabel.Caption:='Calculating Euclidean Distances';
 ProgForm.Show;

 // Initialize the initial distance point
 PMLLW.X := Site.RunRows-1;
 PMLLW.Y := Site.RunCols-1;
 PMHHW.X := Site.RunRows-1;
 PMHHW.Y := Site.RunCols-1;

 //Calculate euclidea distance
 FOR ER := 0 To (Site.RunRows-1) Do
  FOR EC := 0 To (Site.RunCols-1) Do
   Begin
     If EC=0 then Begin
                    Result := ProgForm.Update2Gages(Trunc((ER)/Site.RunRows*(100)),0);
                    If Not Result then Begin ReadyForExit; Exit; End;
                  End;

     //Get cell
     RetA(ER, EC, Cl);

     //Get cell category
     Cat := GetCellCat(@Cl);

     //Get cell elevation
     CellElev := GetMinElev(@Cl);

     //Initialize distances
     Cl.D2MLLW := -9999;
     Cl.D2MHHW := -9999;

     // Calculate the minimum distance to the water lines
     If (CellElev < 8) and (Categories.GetCat(Cat).AggCat in [SaltMarsh,LowTidal,OpenWater]) then
       Begin
         ThisPt.X := EC;
         ThisPt.Y := ER;
         Cl.D2MLLW := DistanceTo2(MLLWArr,NMLLW,PMLLW);
         Cl.D2MHHW := DistanceTo2(MHHWArr,NMHHW,PMHHW);
       End;

     // Reset the cell
     SetA(ER, EC, Cl);
    End;

  ReadyForExit;

End;

Function TSLAMM_Simulation.CalculateProbSAV(ShowMsg:Boolean): Boolean;
CONST DEBUG_INFO = FALSE; // change filenames below
Var ER, EC: Integer;
    Cl: CompressedCell;
    Logit, EV: Double;
    DEM: Double;
    Subsite: TSubsite;
    MLLWFile, MHHWFile, ProbSAVFile: TextFile;

   {---------------------------------------------------------------------------}
   Procedure WriteDebugHeaders(Var InFile: TextFile; FileN: String);
   Begin
     AssignFile(InFile,FileN);
     Rewrite(InFile);
     Writeln(InFile,'ncols ',Site.RunCols);
     Writeln(InFile,'nrows ',Site.RunRows);
     Writeln(InFile,'xllcorner ',Site.LLXCorner);
     Writeln(InFile,'yllcorner ',Site.LLYCorner);
     Writeln(InFile,'cellsize ',FloatToStr(Site.RunScale));
     Writeln(InFile,'nodata_value -9999');
   End;
   {---------------------------------------------------------------------------}
   Procedure WriteDebugData;
   Begin
     Write(MLLWFile,floattostrf(Cl.D2MLLW,ffgeneral,6,6),' ');
     Write(MHHWFile,floattostrf(Cl.D2MHHW,ffgeneral,6,6),' ');
     //Write(DEMFile,floattostrf(DEM,ffgeneral,6,6),' ');
     Write(ProbSAVFile,floattostrf(Cl.ProbSAV,ffgeneral,6,6),' ');
   End;
   {---------------------------------------------------------------------------}


Begin
 Result := CalculateEucDistances;
 if Not Result then Exit;

 ProgForm.ProgressLabel.Caption:='Calculating Probability of SAV';
 ProgForm.Show; EV := 0;

 If DEBUG_INFO then  //UPGRADE integrate as optional output through interface
   Begin
     //WriteDebugHeaders(DEMFile,'SLAMMDEM.ASC');
     WriteDebugHeaders(MLLWFile, 'SLAMM_MLLW.ASC');
     WriteDebugHeaders(MHHWFile, 'SLAMM_MHHW.ASC');
     WriteDebugHeaders(ProbSAVFile, 'SLAMM_PROB_SAV.ASC');
   End;

  FOR ER := 0 To (Site.RunRows-1) Do
   Begin
   FOR EC := 0 To (Site.RunCols-1) Do
    Begin
      If EC=0 then Begin
                     Result := ProgForm.Update2Gages(Trunc((ER)/Site.RunRows*(100)),0);
                     If Not Result then Begin ProgForm.Hide; Exit; End;
                   End;
      RetA(ER, EC, Cl);
      Subsite := Site.GetSubsite(EC {x},ER {y}, @Cl);

      DEM := GetMinElev(@Cl) + CL.MTLminusNAVD;   // DEM EXPRESSED AS NAVD88
      With Cl do
        Begin
          If (d2MLLW < -9998) or (d2MHHW<-9998) or (DEM>9.0) or (D2Mouth<0)
            then ProbSAV := 0
            else
              Begin
                Try
                  With SAVParams do
                  Logit := Intcpt + (DEM*C_DEM) + (SQR(DEM)*C_DEM2) + (Power(DEM,3)*C_DEM3) + (d2MLLW*C_D2MLLW) + (d2MHHW*C_D2MHHW) + (d2mouth*C_D2M) + (d2mouth*d2mouth*C_D2M2);
//                  Logit := -23.72 + DEM*(0.4769) + DEM*DEM*(-0.1377) + d2MLLW*(-0.005855) + d2MHHW*(0.001731)+ d2mouth*(0.007291) +d2mouth*d2mouth*(-0.0000005614);
                  if Logit < -100 then ProbSAV := 0
                                  else ProbSAV := 1/(1+exp(-Logit));
                Except
                  ProbSAV := 0;
                End;
                EV := EV + SQR(Site.RunScale)*ProbSAV*1e-6;
               {km2}            {m2}       {frac}  {km2/m2}

              End;

          If DEBUG_INFO then WriteDebugData;
        End;
      SetA(ER,EC,Cl);
    End;

  If DEBUG_INFO then
      Begin
        Writeln(MLLWFile);
        Writeln(MHHWFile);
        //Writeln(DEMFile);
        Writeln(ProbSAVFile);
      End;
   End;

    If ShowMsg then ShowMessage('Expected Value '+FloatToStrF(EV,ffgeneral,5,5)+ ' sq km');
    SAV_KM := EV;

    ProgForm.Hide;

  If DEBUG_INFO then
      Begin
        closefile(MLLWFile);
        closefile(MHHWFile);
        //closefile(DEMFile);
        closefile(ProbSAVFile);
      End;
End;
