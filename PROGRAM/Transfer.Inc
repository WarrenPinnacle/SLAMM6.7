//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

{--------------------------------------------------------------------------------------------}

Function TSLAMM_Simulation.DynamicAccretion(Cell:PCompressedCell; Cat: Integer; SS: TSubsite; ModelNum: Integer): Double;  {calculated accr, mm/year}
Var AElev: Double;
    Elev, ElevMax, ElevMin: Double;
    LowerHalf: Boolean;

// JSC QA/QC 9/27/2013

Begin

  If not SS.UseAccrModel[ModelNum] then
    Begin
      Case ModelNum of 0: Result := SS.FixedRegFloodAccr;
                       1: Result := SS.FixedIrregFloodAccr;
                       2: Result := SS.Fixed_TF_Beach_Sed;
                     else Result := SS.FixedTideFreshAccr;
      end; {case}
      exit; {function}
    End;

  if SS.MHHW<tiny then
    Begin Result := SS.MinAccr[ModelNum];   //3/7/2014 avoid divide by zero in zero tide-range subsites
          exit;
    End;

  // Rescale Accretion rates if not done yet
  if not SS.AccRescaled[ModelNum] then
    RescaleAccretion(SS,Cat,ModelNum);

  //Retrieve the elevation of the cell in m
  ElevMin := LowerBound(Cat,SS);
  ElevMax := UpperBound(Cat,SS);
  Elev := CatElev(Cell,Cat);
  If Elev<ElevMin then Elev := ElevMin;
  If Elev>ElevMax then Elev := ElevMax;

  LowerHalf := (Elev<((ElevMax+ElevMin)/2));

  //Convert elevation to HTU
  Elev := Elev/SS.MHHW;

  With SS do
    Begin
      //Elevation Effects
      AElev := ThirdOrdPoly(SS.RAccrA[ModelNum],SS.RAccrB[ModelNum],SS.RAccrC[ModelNum],SS.RAccrD[ModelNum],Elev);;
    End;  {with SS}

  // TNC_VA RFM Accretion Curves
  //If (ModelNum=0) {Reg Flood Marsh} and (AElev < 2.0) {mm/year} then AElev := 2.0; // minimum for RFM

  //TNC_VA IFM Accretion Curves
  //If (ModelNum=1) {irreg flood marsh} and (AElev<2.0) and LowerHalf {lower tidal frame boundary}
  //        then AElev := 2.0; // minimum for IFM lower boundary

  //No negative elev changes for now
  If Aelev < 0 then AElev := 0;

  // Calculate accretion rate
  Result := AElev;
End;

Function TSLAMM_Simulation.ThirdOrdPoly(a,b,c,d,X:Double): Double;
//***************************************************************
// Return the value of a third order polynomial
//***************************************************************
Begin
  Result := a*X*X*X + b*X*X + c*X + d;
End;

procedure TSLAMM_Simulation.RescaleAccretion(SS: TSubsite; Cat: Integer; ModelNum: Integer);
//****************************************************************************
// Rescale the accretion coeffcients to the Min/Max input accretion parameters
//****************************************************************************
Type
  T2DimVec = array [0..1] of double;  // 2-dimensional vector

var
  i : integer;
  RootElev : T2DimVec;
  MinElev, MaxElev: double;
  MinAcc, MaxAcc, TmpAcc: double;
  RescalF: double;


  Function SecondOrdPolyRoots(a,b,c:Double): T2DimVec;
  //***************************************************
  // Return the roots of a second order polynomial
  //***************************************************
  Var
    Delta: double;
  begin
    Result[0] := NaN;
    Result[1] := NaN;

    If a = 0 then
      //a=0
      begin
        if b = 0 then
          exit   //b=0
        else
          Result[0] := -c/b;  //b<>0
      end
    else
      // a<>0
      begin
        Delta := b*b - 4*a*c;
        if Delta <0 then
          //Delta<0
          exit
        else
          //Delta>=0
          begin
            Result[0] := (-b-sqrt(Delta))/(2*a);
            Result[1] := (-b+sqrt(Delta))/(2*a);
          end;
      end;
  end;

begin
  // Initialize the rescaled accretion values
  SS.RAccrA[ModelNum] := SS.AccrA[ModelNum];
  SS.RAccrB[ModelNum] := SS.AccrB[ModelNum];
  SS.RAccrC[ModelNum] := SS.AccrC[ModelNum];
  SS.RAccrD[ModelNum] := SS.AccrD[ModelNum];   // fix 3/25/2014

  if (SS.MaxAccr[ModelNum]<>0) and (SS.MinAccr[ModelNum]<>0) then //If both are set zero use the polynomial without rescale
    begin
      //Calculate min and max elevations in HTU
      MinElev := LowerBound(Cat,SS)/SS.MHHW;
      MaxElev := UpperBound(Cat,SS)/SS.MHHW;

      //Calculate the roots of the second order polynomial, to determine Max and Mins
      RootElev := SecondOrdPolyRoots(3*SS.AccrA[ModelNum],2*SS.AccrB[ModelNum],SS.AccrC[ModelNum]);

      //Calculate max and min accretions in the interval
      MinAcc := ThirdOrdPoly(SS.AccrA[ModelNum],SS.AccrB[ModelNum],SS.AccrC[ModelNum],SS.AccrD[ModelNum],MinElev);
      MaxAcc := ThirdOrdPoly(SS.AccrA[ModelNum],SS.AccrB[ModelNum],SS.AccrC[ModelNum],SS.AccrD[ModelNum],MaxElev);
      if MinAcc>MaxAcc then
        begin
          TmpAcc := MinAcc;
          MinAcc := MaxAcc;
          MaxAcc := TmpAcc;
        end;

      for i := 0 to 1 do
        begin
          if not (IsNaN(RootElev[i])) then
            if (RootElev[i]>=MinElev) and (RootElev[i]<=MaxElev) then
              begin
                TmpAcc := ThirdOrdPoly(SS.AccrA[ModelNum],SS.AccrB[ModelNum],SS.AccrC[ModelNum],SS.AccrD[ModelNum],RootElev[i]);
                if TmpAcc>MaxAcc then MaxAcc := TmpAcc;
                if TmpAcc<MinAcc then MinAcc := TmpAcc;
              end;
        end;

      //Rescale the coefficients a b c
      SS.RAccrA[ModelNum] := SS.AccrA[ModelNum];
      SS.RAccrB[ModelNum] := SS.AccrB[ModelNum];
      SS.RAccrC[ModelNum] := SS.AccrC[ModelNum];
      RescalF := 1;           //case (a=0 and b=0 and c=0)
      if MaxAcc<>MinAcc then //cases (a<>0 or b<>0 or c<>0)
        RescalF := (SS.MaxAccr[ModelNum]-SS.MinAccr[ModelNum])/(MaxAcc-MinAcc);

      SS.RAccrA[ModelNum] := RescalF*SS.AccrA[ModelNum];
      SS.RAccrB[ModelNum] := RescalF*SS.AccrB[ModelNum];
      SS.RAccrC[ModelNum] := RescalF*SS.AccrC[ModelNum];

      //Rescale d coefficent
      SS.RAccrD[ModelNum] := 0;
      RescalF := 1;
      if MaxAcc<>MinAcc then
        //cases (a<>0 or b<>0 or c<>0)
        begin
          RescalF := (SS.AccrD[ModelNum]-MinAcc)/(MaxAcc-MinAcc);
          SS.RAccrD[ModelNum] := RescalF*(SS.MaxAccr[ModelNum]-SS.MinAccr[ModelNum])+SS.MinAccr[ModelNum];
        end
      else if MaxAcc<>0 then
        //case a=0 and b=0 and c=0 and d<>0
        SS.RAccrD[ModelNum] := SS.MaxAccr[ModelNum]
      else
        //case a=0 and b=0 and c=0 and d=0
        SS.RAccrD[ModelNum] := 0;
    end;

  //Subsite accretion rates have been rescaled once for all
  SS.AccRescaled[ModelNum] := True;

end;


{--------------------------------------------------------------------------------------------}

Procedure TSLAMM_Simulation.EustaticSLChange(VAR Site: TSite; VAR Year: Integer; IsT0: Boolean);
// Eustatic SL Change that is later adjusted for local factors when adjusting cell elevations

Var IPCCYearIndex: 1..4;
    DT: Integer;

        {--------------------------------------------------------------------------------}
        Function ReturnNorm(Year:Integer): Double;
        Const IPCCResults : Array[Est_Min..Est_Max,1..4,Scen_A1B..Scen_B2] of Double =
              (((28    ,27.5  ,30    ,26    ,27     ,28.5 ),  {MIN,  2025, Scen}
                (63    ,66    ,64    ,58    ,52     ,56   ),  {MIN,  2050, Scen}
                (100   ,125   ,94    ,103   ,76     ,85   ),  {MIN,  2075, Scen}
                (129   ,182   ,111   ,155   ,92     ,114  )), {MIN,  2100, Scen}
                ((76   ,81.5  ,75.5  ,74.5  ,75.5   ,79   ),  {MEAN, 2025, Scen}
                (167   ,175   ,172   ,157   ,150    ,160  ),  {MEAN, 2050, Scen}
                (278.5 ,278   ,323   ,277   ,232.5  ,255  ),  {MEAN, 2075, Scen}
                (387   ,367   ,491   ,424   ,310    ,358  )), {MEAN, 2100, Scen}
                ((128  ,128.5 ,137   ,126.5 ,128    ,134  ),  {MAX,  2025, Scen}
                (284   ,291   ,299   ,269   ,259    ,277  ),  {MAX,  2050, Scen}
                (484.5 ,553   ,491   ,478   ,412.5  ,451  ),  {MAX,  2075, Scen}
                (694   ,859   ,671   ,743   ,567    ,646  )));{MAX,  2100, Scen}

         Const FixedResults : Array [1..4,1..7] of Double =             //After 3 is NYS Scenarios
                ((184.4,276.7, 368.9,  127,   129.4,  127,    254),     {2025, Scen}
                 (409.2,613.8, 818.4,  304.8, 431.0,  482.6,  736.6),   {2050, Scen, 2055 for NYS}
                 (698.1,1047.2,1396.3, 584.2, 806.6,  1041.4, 1397),    {2075, Scen, 2085 for NYS}
                 (1000, 1500,  2000.0, 717.6, 1000.0, 1327.2, 1720.9)); {2100, Scen}

         Const ESVA_SLR_A_Coeff: Array [1..4] of Double =
                (0,	0.00271,	0.00871,	0.0156);      //Quadratic coefficient for ESVA SLR
              {--------------------------------------------------------------------}
              Function Norm_Data_Year(Year:Integer):Double;
              Var Nrm: Double;
              Begin
                If Year > 2100 then Raise ESLAMMERROR.Create('SLAMM Predictions do not extend beyond 2100.');
                Case Year of
                  2050: IPCCYearIndex := 2;
                  2075: IPCCYearIndex := 3;
                  2100: IPCCYearIndex := 4;
                  else  IPCCYearIndex := 1;
                End; {Case}

                If Running_Fixed then
                  begin
                    if FixedScen < 8 then
                      begin
                        //NYS SLR Scenarios
                        if (FixedScen>3) then
                          begin
                            Case Year of
                              2055: IPCCYearIndex := 2;
                              2085: IPCCYearIndex := 3;
                              2100: IPCCYearIndex := 4;
                              else  IPCCYearIndex := 1;
                            End;
                          end;
                        Nrm := FixedResults[IPCCYearIndex,FixedScen] * 0.1;
                      end
                    else
                      //ESVA SLR Scenarios
                      begin                                      {linear coeff+subsidence}
                        Nrm := (ESVA_SLR_A_Coeff[FixedScen-7]*(Year-1992)+0.17)*(Year-1992);
                      end;  // (  {cm/yr^2}*yr  +  cm/yr  +  cm/yr  )  *  yr  =  cm
                  end

                else
                  Nrm := IPCCResults[IPCCSLEst,IPCCYearIndex,IPCCSLRate] * 0.1;
                      {cm}        {mm}                               {cm/mm}

                Norm_Data_Year := Nrm;

              End; {Norm_Data_Year}
              {--------------------------------------------------------------------}

        Var UpperYear, LowerYear: Integer;
            UpperNorm, LowerNorm, ScenBy2100: Double;
            LYi, UYi, i: Integer;

        Begin {ReturnNorm}
          LYi := -1;
          If Running_TSSLR then
           with TimeSerSLRs[TSSLRindex-1] do
            Begin
             For i := 0 to NYears -1 do
                 If (SLRArr[i].Year  < Year ) then LYi := i;

             UYi := LYi + 1;
             If (LYi<0) then Begin LowerNorm := 0; LowerYear := BaseYear; End
                        else Begin LowerNorm := SLRArr[LYi].Value;
                                   LowerYear := SLRArr[LYi].Year;
                             End;

             If (UYi=NYears) then Raise ESLAMMError.Create('Running Year '+IntToStr(Year)+' that is beyond the time series in "'+Name+'"')
                             else Begin UpperNorm := SLRArr[UYi].Value;
                                        UpperYear := SLRArr[UYi].Year;
                                  End;
              If UpperYear = LowerYear then Raise ESLAMMError.Create('Duplicate Year '+IntToStr(LowerYear)+' in the time series in "'+Name+'"');

              ReturnNorm := 100*  LinearInterpolate(LowerNorm,UpperNorm,LowerYear,UpperYear,Year,False);
               {cm}        {cm/m}                     {m}        {m}
              Exit;
            End;



          If Running_Custom then
            Begin
              Running_Fixed := False;
              IPCCSLRate := Scen_A1B;
              IPCCSLEst := Est_Max; {scale up custom from A1B-Max scenario}
            End;

          If ( (Year>2000) and (
          (((Year Mod 25) = 0) and (Running_Fixed=False)) or     //No Fixed Scenario
          (((Year Mod 25) = 0) and (Running_Fixed=True) and (FixedScen<4)) or   //Fixed Scenarios
          ((Running_Fixed=True) and (FixedScen>3) and (FixedScen<8) and ((Year=2025) or (Year=2055) or (Year=2085) or (Year=2100))) )) or //NYS Fixed Scenarios
          ((Year>1992)and (Running_Fixed=True) and (FixedScen>7)) then //ESVA Fixed Scenarios
            ReturnNorm := Norm_Data_Year(Year)
          else
            Begin
              LowerYear := (Year Div 25) * 25;
              UpperYear := (Year Div 25) * 25 + 25;

              // NYS SLR Scenarios - Marco
              if (Running_Fixed) and (FixedScen>3) and (FixedScen<8)  then
                begin
                  if LowerYear = 2025 then UpperYear := 2055;

                  if LowerYear = 2050 then
                    if Year<2055 then
                      begin
                        LowerYear := 2025;
                        UpperYear := 2055;
                      end
                    else
                      begin
                        LowerYear := 2055;
                        UpperYear := 2085;
                      end;
                  if LowerYear = 2075 then
                    if Year<2085 then
                      begin
                        LowerYear := 2055;
                        UpperYear := 2085;
                      end
                    else
                      LowerYear := 2085;
                end;

              If LowerYear > 2000 then
                LowerNorm := Norm_Data_Year(LowerYear)
              else
                Begin
                  LowerYear := 1990;  {linearly interpolate to zero at start date}
                  if (Running_Fixed) and (FixedScen>3) and (FixedScen<8)  then LowerYear:=2002; //NYS SLR Scenarios Marco
                  LowerNorm := 0;
                End;
              If (UpperYear < 2025) then UpperYear := 2025;
              UpperNorm := Norm_Data_Year(UpperYear);
              ReturnNorm := LinearInterpolate(LowerNorm,UpperNorm,LowerYear,UpperYear,Year,False);
            End;

          If (Running_Custom) then
            Begin
              If Current_Custom_SLR<0 then Current_Custom_SLR := 0;
              ScenBy2100 := Norm_Data_Year(2100);   // First Get A1B-Max Prediction for 2100
              Result := Result * (Current_Custom_SLR * 100) / ScenBy2100;  {i.e. if SLR by 2100 is 50% Scen by 2100 then all dates are scaled by 50%}
               {cm}      {cm}       {m}                {cm}     {cm}
            End;
        End;  {ReturnNorm}
        {--------------------------------------------------------------------------------}
        Procedure GetNextYearFromString;
        Var Number, MinNum, MaxNum: Integer;
            Holder, InputNums: String;
            EOFFound : Boolean;
        Begin
          MinNum := 99999;  MaxNum := -99999;
          InputNums := YearsString;
          EOFFound:=False;

          Repeat
            Holder := AbbrString(InputNums,',');
              Try Number := StrToInt(Holder);
              Except Raise ESLAMMError.Create('Invalid Numeric Input in Specific Years String "'+YearsString+'"   Must be comma separated integers.');
              End;
            If Number > MaxNum then MaxNum := Number;
            If (Number > Year) and (Number < MinNum) then MinNum := Number;

            If Pos(',',InputNums)= 0 then EofFound:=True
                                     else Delete(InputNums,1,Pos(',',InputNums));
            If Trim(InputNums)='' then EofFound := True;
          Until EofFound;

          If MinNum = 99999 then MinNum := Year;

          DT := MinNum - Year;
          Year := MinNum;
          MaxYear := MaxNum;

          If (Year>2100) then Begin DT := DT - (Year-2100); Year := 2100; End;
        End;
        {--------------------------------------------------------------------------------}

        Procedure CalcDT; {calculate Delta T when the model is run beyond T0}
        Begin
          If Runspecificyears
            then GetNextYearFromString
          else
            Begin
              If Year < 2025 then
                DT := 2025 - Year
              else
                DT := TimeStep;

              If TimeStep < 25 then
                If Year < 2020 then
                  DT := 2020 - Year
                else
                  DT := TimeStep;

              If TimeStep < 15 then
                If Year < 2010 then
                  DT := 2010 - Year
                else
                  DT := TimeStep;

              Year := Year + DT;

              If (Year>2100) then
                Begin
                  DT := DT - (Year-2100);
                  Year := 2100;
                End;
            End;

        End;
        {--------------------------------------------------------------------------------}

Var i: Integer;
    TSS: TSubSite;
    YearZero: Integer;
    SubSiteAdj: Double;


Begin   // EustaticSLChange
  If IsT0 then DT := 0
          Else CalcDT;

  For i:=0 to Site.NSubSites do
    Begin
      If i=0 then TSS := Site.GlobalSite
             else TSS := Site.SubSites[i-1];
      With TSS do
        Begin
          OldSL := NewSL;
          If Not IsT0 then DeltaT := DT
                      else DeltaT := Year - NWI_Photo_Date;

          If Year = NWI_Photo_Date then
            Norm := 0
          else
            Begin
              YearZero := 1990;
              if (Running_Fixed) and (FixedScen>3) then
                begin
                 if (FixedScen<8) then YearZero :=2002   //NYS SLR Scenarios
                                  else YearZero :=1992   //ESVA SLR Scenarios
                end;
              if (Running_TSSLR) then YearZero := TimeSerSLRs[TSSLRindex-1].BaseYear;

              If Year > YearZero then
                Begin
                  Norm := ReturnNorm(Year);  // eustatic SLR from base year to current date
                  {IPCC predictions start date is 1990 (yearzero), so adjust predictions to the NWI date which serves as the start of our simulation}
                  If (NWI_Photo_Date < YearZero) then
                    Norm := Norm + (YearZero - NWI_Photo_Date) * Historic_Eustatic_trend   *  0.1
                    { cm      cm    (   yr                )   mm/yr   cm/mm }
                  else if (NWI_Photo_Date > YearZero) then
                    Norm := Norm - ReturnNorm(NWI_Photo_Date); // eustatic SLR as of NWI photo date
                        { cm      cm  - cm }
                End
              Else {Year <= YearZero}  {Uses Subsite Historic Eustatic SLR For SLR Pre YearZero }
                Begin
                  Norm := (Year - NWI_Photo_Date) * Historic_Eustatic_trend * 0.1
                  { cm     (   yr                )   mm/yr  cm/mm }
                End;
            End;

          NewSL := Norm *0.01;  {NewSL is Eustatic SLR since simulation start}
          { m       cm   }

          SLRise := NewSL - OldSL;   {Eustatic SLR this time-step}
           {m}       {m}     {m}

(*          {CASCO CODE}
          SubsiteAdj := ((Historic_trend - Historic_Eustatic_trend) * (year-YearZero)) / 1000;   {/CASCO CODE}
            {m}             {mm/year}              {mm/year}               {years}      {mm to m}

          If NewSL + Site.GlobalSite.MHHW + SubSiteAdj > OVERTOPHEIGHT[i] then  {/CASCO OVERTOP CODE}
            Begin
              TSS.GTideRange := Site.GlobalSite.GTideRange;
              TSS.SaltElev := Site.GlobalSite.SaltElev;
              Site.InitElevVars;                                  // Set mhhw mllw etc. don't change drainage and water type for now
            End
          else  // not overtopped
            If i=4 //phippsburg is subsite 4
              then
                begin
                  TSS.GTideRange := 2*(Site.GlobalSite.MHHW*0.344576+(NewSL - 0.066)*(0.344576-1)+0.841829);          //adjust phippsburg tidal range here
                  TSS.SaltElev := Site.GlobalSite.SaltElev*0.344576+(NewSL - 0.066)*(0.344576-1)+0.841829;
                  Site.InitElevVars;                                  // Set mhhw mllw etc
                end;
           {/CASCO CODE} *)


          If IsT0 then T0SLR := SLRise;  { Eustatic SLR at T0 if relevant (if this subsite NWI_Photo_Date less than others}

        End;
    End;
End;

Function TSLAMM_Simulation.UpdateElevations: Boolean;  {update cell elevations for entire map based on SLR, uplift, subsidence, accretion}

       Procedure Parallel_UpdateElev;
       Var ThreadArr3: Array [0..100] of TUpdateElevsThread;

       Var CCLoop,RowStart,RowEnd,RowsPer: Integer;
           AllDone, UStop:Boolean;
        Begin
          For CCLoop := 0 to CPUs -1 do
            Begin
              RowsPer := ((Site.RunRows div CPUs)+1);
              RowStart :=CCLoop * RowsPer;
              RowEnd := ((CCLoop + 1) * RowsPer) -1;
              if CCLoop = CPUs-1 then RowEnd := Site.RunRows-1;
              ThreadArr3[CCLoop] := TUpdateElevsThread.Create(Self,RowStart,RowEnd,'Updating Elevations '+'('+ IntToStr(CPUs)+' CPUs) ',CCLoop+1);
            End;

          repeat
            Application.processmessages;
            AllDone := True;
            UStop := False;
            For CCLoop := 0 to CPUs -1 do
              Begin
                If not ThreadArr3[CCLoop].ImDone then AllDone := False;
                If ThreadArr3[CCLoop].UserStop then UStop := True;
              End;
           until AllDone {or UStop};

          For CCLoop := 0 to CPUs -1 do
           begin
            if ThreadArr3[CCloop].UserStop then Result := False;
            ThreadArr3[CCLoop].Free;
           end;
        End;   {Parallel_Execute}

begin
  Result := True;
  if (CPUs > 1)
    then Parallel_UpdateElev
    else Result := ThreadUpdateElevs(0,Site.RunRows-1,nil);
end;


Function TSLAMM_Simulation.ThreadUpdateElevs(StartRow,EndRow: Integer; PRunThread: Pointer):Boolean;

Var ER, EC, i, fw, nfw: Integer;
    ECl: CompressedCell;
    Subsite: TSubsite;
    ThisCat: Integer;
    Accretion, ThisElev, TurbFactor: Double;
    CellSet {, HighBI }: Boolean;
    TUET: TUpdateElevsThread;

(*    Function IsCellHighLand(Cell: PCompressedCell): Boolean;
    var
      Cat: Integer;
    Begin
      //Initialize return variable
      Result := False;

      // Get Category information
      Cat := GetCellCat(Cell);

      //Set high lands to EOW  defined as  [all categories except for RFM, tidal flat, ocean flat, any open water]
      if not (Cat in [TidalFlat, OceanFlat, Mangrove, RegFloodMarsh, RiverineTidal..OpenOcean, Blank]) then
        Result := True;
    End; *)

Begin
 Result := True;

FOR ER := StartRow To EndRow Do
 FOR EC := 0 To (Site.RunCols-1) Do
  Begin
    If EC=0 then
       Begin
         if PRunThread<>nil
         then begin
               TUET := PRunThread;
               if TUET.Terminated
                 then Result := False
                 else Result := TUET.UpdateProg('Updating Elevations '+ '('+ IntToStr(CPUs)+' CPUs) ',Trunc((ER-StartRow)/(EndRow-StartRow+1)*100));
              end
         else Begin
                Result := ProgForm.Update2Gages(Trunc((Er)/Site.RunRows*100),0);
                ProgForm.ProgressLabel.Caption:='Updating Elevations';
              End;
         If Not Result then Exit;
       End;


    RetA(ER, EC, ECl);
    Subsite := Site.GetSubSite(EC {x},ER {y},@ECl);

    CellSet:= False;

    For i := 1 to NUM_CAT_COMPRESS do
     If ECL.MinElevs[i] < 998 then  {no data}
      Begin
        ThisCat := ECl.Cats[i];
        If ThisCat <> Blank then
          Begin
            CellSet := True;
            ThisElev := ECL.MinElevs[i] - SubSite.SLRise;     {MTL has moved so all elevs relative to MTL have changed.  Adjust for eustatic changes first}
                             {m}          {m per Delta T}

            with Subsite do
              ThisElev := ThisElev + ECl.Uplift * DeltaT * 0.01;   {account for uplift or subsidence}
               {m}         {m}          {cm/yr}    {yr}   {cm/m}

            Accretion := 0;
            If (Not IncludeDikes) or (Not ECl.ProtDikes) then with Subsite do      {calculate cell-specific accretion for non diked cells}
              Case Categories.GetCat(ThisCat).AccrModel of
                RegFM     : Accretion := DeltaT * DynamicAccretion(@ECL,ThisCat,SubSite,0) * 0.001;
                IrregFM   : Accretion := DeltaT * DynamicAccretion(@ECL,ThisCat,SubSite,1) * 0.001;
                BeachTF   : Accretion := DeltaT * DynamicAccretion(@ECL,ThisCat,SubSite,2) * 0.001;
                TidalFM   : Accretion := DeltaT * DynamicAccretion(@ECL,ThisCat,SubSite,3) * 0.001;
                InlandM   : Accretion := DeltaT * InlandFreshAccr  * 0.001;
                Mangrove  : Accretion := DeltaT * MangroveAccr     * 0.001;
                TSwamp    : Accretion := DeltaT * TSwampAccr       * 0.001;
                Swamp     : Accretion := DeltaT * SwampAccr        * 0.001;
                             {m}         {yr}        {mm/yr}        {mm/m}
              End; {Case}

            {Add Turbidity Factor}
            TurbFactor := 1.0;
            nfw := 0;
            If Accretion > 0 then
              For fw := 0 to NumFWFlows -1 do
               If FWInfluenced(ER,EC,fw) then
                 If FWFlows[fw].UseTurbidities then
                   Begin
                     inc(nfw);
                     If nfw=1 then TurbFactor :=  FWFlows[fw].TurbidityByYear(Year)
                              else TurbFactor := (FWFlows[fw].TurbidityByYear(Year) + (TurbFactor * (nfw-1))) / nfw   // calcuate average turbfactor
                   End;

            ThisElev := ThisElev + Accretion* TurbFactor;          {account for accretion}
            ECL.Minelevs[i] := ThisElev;
          End; {if}
      End; {for i}

    If CellSet then SetA(ER,EC,ECL)
  End; {For ER, EC}
End;


{--------------------------------------------------------------------------------------------}

{-------------------------------------------}
{      Transfer percentages of Classes      }
{         R. A. Park    2/21-29/88          }
{        JSC Modified,  1998, 2005-2007     }
{-------------------------------------------}

PROCEDURE TSLAMM_Simulation.TRANSFER(Cell: PCompressedCell;
                                     EachRow,EachCol: Integer; ErodeStep: Boolean);
Var CC: Integer;
    Diked: Boolean;

VAR
  WetlandType: Integer;  {Set in TestNear}
  WaterTable : double;    {Set in TestNear}
  DistancetoWater: double;       {Set in TestNear}
  AdjMaxFetch: Double;
  AdjSalt, NearSalt : Boolean;
  ERODING      : Boolean;

  SubSite      : TSubsite;
  InundContext: TInundContext;
  FracLost : PctArray;

    {--------------------------------------------------------------------}
    Function AdjCell(Var AdjRow,AdjCol: Integer; Lee: Boolean): Boolean;

    {********************************************}
    {* Return adjacent cell to lee if Lee=True  *}
    {* AdjRow and AdjCol are inputs and outputs *}
    {* Function False if out-of-bounds          *}
    {* True: move opposite of offshore          *}
    {********************************************}
    Var Step: Integer;
    Begin
      If Lee then Step := -1
             else Step :=  1;

      Case SubSite.Direction_OffShore of
         Westerly : AdjCol := AdjCol - Step;
         Easterly : AdjCol := AdjCol + Step;
         Northerly: AdjRow := AdjRow - Step;
         Southerly: AdjRow := AdjRow + Step;
        End; {Case}

      AdjCell := (AdjRow>=0) and (AdjCol>=0) and
                 (AdjRow<Site.RunRows) and (AdjCol<Site.RunCols);
    End;
    {--------------------------------------------------------------------}


    {*******************************************}
    {            convert Classes                }
    {         R. A. Park    2/21/88             }
    {*******************************************}
    Procedure Convert(Cell: PCompressedCell; FromCat, ToCat: Integer; LowBound: Single);
    {converts a cell from category to category based on FracLost[FromCategory]}
    Var Transferred: double;
        SetElev, FromMinElev, ToCatElev: Single;
    Begin


      If FracLost[FromCat] = -9999
        then Raise ESlammError.Create('FRACLOST Initialization Problem, Category '+IntToStr(FromCat));

     With Cell^ DO
      Begin
        If FracLost[FromCat] > 1.0 Then FracLost[FromCat] := 1.0;
        If FracLost[FromCat] < 0.0 Then FracLost[FromCat] := 0.0;

        If CellWidth(Cell,FromCat) < 0.001
          Then Transferred := 0.0  {to avoid "pass through" of small amts.}
          Else Transferred := FracLost[FromCat] * CellWidth(Cell,FromCat);

        IF Transferred > 0.0 Then
          Begin
            If ToCat = Blank then
              Begin
                Raise ESlammError.Create('Convert to Blank Category Error, Category Setup for number '+IntToStr(FromCat));
              End;

            FromMinElev := CatElev(Cell,FromCat);
            SetCellWidth(Cell,FromCat,CellWidth(Cell,FromCat) - Transferred);  {loss first to minimize data loss due to compression}
            SetCellWidth(Cell,ToCat,  CellWidth(Cell,ToCat)   + Transferred);

            ToCatElev := CatElev(Cell,ToCat);
            If (ToCatElev >= 999)  or (ToCatElev > FromMinElev)  // the category didn't exist in this cell previously
              then Begin
                     SetElev := FromMinElev;

                     If Not TimeZero then
                       Begin
                         If Categories.GetCat(FromCat).UseRFMCollapse            // 1/12/2016   MARSH COLLAPSE
                           Then SetElev := SetElev - Subsite.RFM2TF_Collapse;
                         If Categories.GetCat(FromCat).UseIFMCollapse            // 1/12/2016   MARSH COLLAPSE
                           Then SetElev := SetElev - Subsite.IFM2RFM_Collapse;
                       End;

                     SetCatElev(Cell,ToCat,SetElev);  {Set the elevation of the category being transferred to if it did not exist or was errant}
                   End;

            If LowBound <> -99 then
              if CellWidth(Cell,ToCat) > 0  {If "to cat" wasn't set because it is too small, don't nudge up "from cat"}
                 then SetCatElev(Cell,FromCat,LowBound);
          End; {Trans > 0}
      End; {With Cell}
    End; {Convert}

{********************************************}
{       Calculate Frac Lost using LowBound,  }
{             Minelev and Cell Slope         }
{         J Clough  December 2005            }
{********************************************}
Procedure CalcFracLostBySlope(Cell: PCompressedCell; Cat: Integer; LowBound: Double);
Var Wid: Single;
    MinElev: Single;
Begin
 FracLost[Cat] := 0;
 If ERODING Then Exit;

 MinElev := CatElev(Cell,Cat);
 if (MinElev>=LowBound) then Exit;  //JSC 1/10/2012

 Wid := CellWidth(Cell,Cat);
 If Wid < Tiny then Exit;   {avoid potential divide by zero}

 With Cell^ do
  If TanSlope = 0 then FracLost[Cat] := 1
     else If TanSlope < 0 then FracLost[Cat] := 0
     else FracLost[Cat] := ((LowBound - MinElev) / TanSlope) / Wid;
  {frac. of cat to conv.}      {m}        {m}     {unitless}    {m}

  If FracLost[Cat] < 0 then FracLost[Cat] := 0; {2-22-06}
End;

{*******************************************}
{         represent migration of            }
{         water table near shoreline        }
{         R. A. Park    9/27/91             }
{         J.Clough December 2005            }
{*******************************************}
Procedure Saturate(Cell: PCompressedCell; Slot,ToCat: Integer);
Begin
    IF ERODING Then Exit;
    CalcFracLostBySlope(Cell,Cell.Cats[Slot],WaterTable);
    Convert(Cell,Cell.Cats[Slot],ToCat,WaterTable);
End; {Saturate}




{*******************************************}
{         Incorporate Salinity in Wetland   }
{         fate                              }
{         J.Clough November 2009            }
{*******************************************}

Procedure ConvertCellbySalinity(Cell: PCompressedCell);
Var Cat: Integer;
    nrules, i, j, convnum: Integer;
    TSR: TSalinityRule;
    CellSal: Double;
    //NumSalMetrics: integer;
Begin
 //If Cell.Sal[NUM_SAL_METRICS] < -1 then exit;   //not initialized for salinity, probably "extent only"

 FOR i := 1 to NUM_CAT_COMPRESS DO
   If (Cell.Widths[i] > 0) and
      (Cell.Cats[i] <> Blank) then
     Begin
       Cat := Cell.Cats[i];
       nrules := 0;
       If Categories.GetCat(Cat).SalRules then nrules := Categories.GetCat(Cat).SalinityRules.NRules;
       for j  := 0 to nrules-1 do
         Begin
           TSR := Categories.GetCat(Cat).SalinityRules.Rules[j];    // Handle case of multiple salinity rules
           If TSR <> nil then
             Begin
               // If salinity of the 1st salinity metrics is not null but the one of 4th metrics is null then there must be a raster
               if Cell.Sal[NUM_SAL_METRICS]<-1 then
                TSR.SalinityTide := 1;

               // Get the salinity value
               CellSal := Cell.Sal[TSR.SalinityTide];

               For convnum:= 1 to 2 do
                if TSR <> nil then
               // Apply the conversion rule, go through two steps if required
                 if (TSR.GreaterThan and (CellSal > TSR.SalinityLevel)) or
                    ((Not TSR.GreaterThan) and (CellSal < TSR.SalinityLevel)) then
                   begin
                     FracLost[Cat] := 1.0;
                     Convert(Cell,Cat,TSR.ToCat,-99);
                     Cat := TSR.ToCat;                     // Allow for second category change
                     TSR := Categories.GetCat(Cat).SalinityRules.Rules[0];     // Allow for second category change
                   end;
             End; {TSR <>nil}
         End;
     End;
End; {procedure}

Procedure SoilSaturation(Cl: PCompressedCell; slot: Integer);
Var LocalSLRise: Double;
Begin
     LocalSLRise := SubSite.SLRise - Cell.Uplift * SubSite.DeltaT * 0.01;
      {m}                  {m}           {cm/yr}          {yr}     {cm/m}

    If (Year>2000) and (UseSoilSaturation) then {no saturation prior to 2001}
           Begin
              {Watertable holds minelev of nearest wetland or water from "testnear," must be adjusted}
              WaterTable := WaterTable + (LocalSLRise / 0.91) * Exp(-0.776 - 0.0012 * DistancetoWater);
                 {m}           {m}                  {m / m}      {          m                  }
              If (NearSalt And (Cell.MinElevs[Slot] < WaterTable)) and (WetlandType > 0)
                           And (Cell.MinElevs[Slot] < 10) Then  //10/7/2009 avoid perched water table, no saturation above 10m
                {Nearsalt procedure sets "wetlandtype" variable}
                Saturate(Cell, slot, WetlandType);
           End;

End;


PROCEDURE Inundate(Cl: PCompressedCell);  {inundation of cells below lower boundary}
Var i, FromCat, ToCat: Integer;
    CatElev, LowBound: Double;
BEGIN
  For i := 1 to NUM_CAT_COMPRESS do
    If (Cl.Widths[i] > tiny) and (Cl.Cats[i] <> Blank) then
      Begin
        FromCat := Cl.Cats[i];
        LowBound := LowerBound(FromCat,SubSite);
        CatElev := CL.MinElevs[i];
        If (LowBound > CatElev) then   { Inundation Model }
        CalcFracLostBySlope(Cell,FromCat,LowBound);
        If FracLost[FromCat] > 0 then
          Begin
            {Pass inundation context data record for inundation rules parsing}
            InundContext.SubS := SubSite;
            InundContext.CatElev := CatElev;
            InundContext.EWCat := Categories.EstuarineWater;
            InundContext.CellRow := EachRow;
            InundContext.CellCol := EachCol;

            ToCat := Categories.GetCat(FromCat).InundCat(@InundContext);
            If ToCat <> Blank then Convert(Cell,FromCat,ToCat,LowBound);
          End;

        With Categories.GetCat(FromCat) do
          If IsDryLand and Not IsDeveloped then SoilSaturation(Cl,i);
      End;
END; {INUNDATE}


(********************************)
(* obtain qual. est. of erosion *)
(********************************)
Procedure FetchThreshold;

BEGIN
 With InundContext do
   Erosion2 := AdjMaxFetch;  // 6/21/2017  no more "Erosion" enumerated type, replacing with relevant fetch in km to improve code readability
END; {Erosion}

{********************************************}
{  Take into account width of category being }
{  Eroded,  JClough December 2005            }
{*******************************************}
Function Frac_To_Erode(Cell: PCompressedCell; ErodePerYear: Double; Clss:Integer): Double;
Var TotErosion: Double;
    WidthErodedOS: Double; {Width Eroded in Off Shore direction}
    AdjRow,AdjCol: Integer;
    EdgeFound: Boolean;
    CatWidth, ErosionLossMeters: Double;

    {-------------------------------------------------------------------------------------------------}
    Procedure AddToWidth;
    Var AC: CompressedCell; {Adjacent Offshore Cell}
    Begin
       RetA(AdjRow,AdjCol,AC);

       If CellWidth(@AC,Clss)>0.01 {1cm}
         then WidthErodedOS := WidthErodedOS + CellWidth(@AC,Clss)
         else EdgeFound := True;

       If EdgeFound and not((GetBit(MostlyWater,AdjRow,AdjCol)) or (GetCellCat(@AC) = Categories.EstuarineWater)) then WidthErodedOS := 1e6;  {not adjacent to water, no erosion, modified 6/16/2019}
       WidthErodedOS := WidthErodedOS + (0.01 * ErodeMatrix[Site.RunCols*(AdjRow)+(AdjCol)]);  // account for erosion that already occurred here this time step
         {m}                  {m}       {m/cm}      {cm}
    End;
    {-------------------------------------------------------------------------------------------------}

Begin
  Frac_To_Erode := 0;
  IF NOT ERODING Then Exit;
  If ErodePerYear <=0 then exit;
  If SubSite.DeltaT<=0 then exit;

  TotErosion := ErodePerYear * SubSite.DeltaT;  {total horizontal erosion in time-step}
  {m / dT}        {m / yr}             {y / dt}

  WidthErodedOS := 0;

  AdjRow := EachRow;
  AdjCol := EachCol;
  EdgeFound := False;
  Repeat
    If AdjCell(AdjRow,AdjCol,False) then AddToWidth    {look off-shore and add width}
                                    else EdgeFound := True;  {off the map}
    If WidthErodedOS > TotErosion then Exit;           {No erosion for this cell, enough erosion took place on off-shore side of cell}
  Until EdgeFound;

  CatWidth := CellWidth(Cell,Clss);
  Frac_To_Erode  := (TotErosion - WidthErodedOS)/ CatWidth;
   {frac / dT}          {m/dT}            {m/dT}      {m}

  If Result > 1 then ErosionLossMeters := CatWidth
                else ErosionLossMeters := TotErosion - WidthErodedOS;

  If Categories.GetCat(Clss).ErodeModel in [ETFlat,EOcBeach]
    then Cell.BTFErosionLoss := Cell.BTFErosionLoss + ErosionLossMeters
    else Cell.ErosionLoss := Cell.ErosionLoss + ErosionLossMeters;

  If ErosionLossMeters > (ErodeMatrix[Site.RunCols*(EachRow)+(EachCol)]*100) then        {Keep track of the erosion at this cell in this time-step thus far}
        {m}                 {cm}                                       {cm/m}
    ErodeMatrix[Site.RunCols*(EachRow)+(EachCol)] := Trunc(ErosionLossMeters*100);       {JSC Track cell erosion in cm for more accuracy 6/13/2019}
       {cm}

End;

{*******************************************}
{       compute erosion                     }
{     Original Code   R. A. Park 3/4/88     }
{ IF BRUUN USED, Ocean Beach Only & Optional
  Recession = 100 * SLRise (Bruun '62, '86) }
{*******************************************}

Procedure Erode(Cl: PCompressedCell);

Var Cat: Integer;
    {------------------------------------------------------------------------}
    Procedure Bruun;
    Var Recession: double;
        ErosionThisCell: Double;
        LocalSLRise: Double;
        BeachWidth: Double;
    Begin
      LocalSLRise := SubSite.SLRise - Cl.Uplift * SubSite.DeltaT * 0.01;
        {m}                  {m}         {cm/yr}          {yr}     {cm/m}

      Recession := 100.0 * LocalSLRise;

      ErosionThisCell := Recession - DistancetoWater;
         {m}                {m}       {m from front edge to open ocean}

      If ErosionThisCell <= 0 then Exit;

      BeachWidth := CellWidth(Cl,Cat);
      If ErosionThisCell > BeachWidth then ErosionThisCell := BeachWidth;
           {m}                 {m}

      FracLost[Cat] := ErosionThisCell/BeachWidth;
      Convert(Cl,Cat,Categories.GetCat(Cat).ErodeTo,-99);
      SetCatElev(Cell,Categories.GetCat(Cat).ErodeTo,0);  // set open water to MTL for now
      Cl.BTFErosionLoss := Cl.BTFErosionLoss + ErosionThisCell;
    End;
    {------------------------------------------------------------------------}
    Procedure WaveErosion;
    Var ERate: Double;

    Begin
      ERate := Cl.WPErosion;
      If ERate<=0 then Exit;

      FracLost[Cat] := Frac_To_Erode(Cell, ERate, Cat);
      Convert(Cell,Cat,Categories.GetCat(Cat).Erodeto,-99);
      SetCatElev(Cell,Categories.GetCat(Cat).Erodeto,0);  {Set the elevation of the category being transferred to to MTL}
    End;
    {------------------------------------------------------------------------}

Var i: Integer;
    EModel: ErosionInputs;
    ERate: Double;
    TC: TCategory;
Begin
  For i := 1 to NUM_CAT_COMPRESS do
    If (Cl.Widths[i] > tiny) and (Cl.Cats[i] <> Blank) then
      Begin
        Cat := Cl.Cats[i];
        TC := Categories.GetCat(Cat);

        If TC.UseWaveErosion and SubSite.USE_Wave_Erosion
          then WaveErosion
          else
            Begin
              EModel := Categories.GetCat(Cat).ErodeModel;
              If (EModel = EOcBeach) and UseBruun then Bruun

                else If (EModel = EOcBeach) or (EModel = ETFLat) then
                    Begin // non bruun beach and tidal flat model
                      ERate := SubSite.TFlatErosion;
                      FracLost[Cat] := Frac_To_Erode(Cell, ERate, Cat);
                      Convert(Cell,Cat,Categories.GetCat(Cat).Erodeto,-99);
                      SetCatElev(Cell,Categories.GetCat(Cat).Erodeto,0);  {Set the elevation of the category being transferred to to MTL}
                    End

                else if (EModel = EMarsh) then with InundContext do
                  Begin   //classic marsh erosion, but with editable fetch limit 6/21/2017
                    If (Erosion2 >= Subsite.MarshErodeFetch ) {9km fetch} AND (AdjOcean OR AdjWater) Then
                      Begin
                        ERate := SubSite.MarshErosion;
                        FracLost[Cat] := Frac_To_Erode(Cell,ERate,Cat);
                        Convert(Cell,Cat,Categories.GetCat(Cat).Erodeto,-99);
                        SetCatElev(Cell,Categories.GetCat(Cat).Erodeto,0);  {Set the elevation of the category being transferred to to MTL}
                      End;
                  End
                else if (EModel = ESwamp) then with InundContext do
                  Begin   //classic swamp erosion
                    If (Erosion2 >= 9) {9km fetch} AND (AdjOcean OR AdjWater) Then // 4/17/2009    9km fetch for swamp erosion
                      Begin
                        ERate := SubSite.SwampErosion;
                        FracLost[Cat] := Frac_To_Erode(Cell,ERate,Cat);
                        Convert(Cell,Cat,Categories.GetCat(Cat).Erodeto,-99);
                        SetCatElev(Cell,Categories.GetCat(Cat).Erodeto,0);  {Set the elevation of the category being transferred to to MTL}
                      End;
                  End;
            End;
      End;
End;






(********************************************************************************)
(* is exposed water, water, or saltwater adjacent?  i.e. within 500 m off-shore *)
(********************************************************************************)
PROCEDURE TestAdjacent(Cell: PCompressedCell; Row, Col: Integer);

  Procedure Adj1(Iter, NewRow, NewCol: Integer);
  Var MostWater: Boolean;
       C2: CompressedCell;

  BEGIN
   With InundContext do
    Begin
      If Not AdjOcean then AdjOcean := GetBit(ExposedWater, NewRow, NewCol);
      If Not AdjEFSW then  AdjEFSW  := GetBit(HasEFSW, NewRow, NewCol);
      MostWater := GetBit(MostlyWater, NewRow, NewCol);
      If Not AdjWater   then AdjWater   := MostWater;
      If Not AdjSalt    then AdjSalt    := GetBit(SaltWater,   NewRow, NewCol);
//      ClearPathToOCean := ClearPathToOcean and (MostWater or AdjOcean);

      If (Iter < 3) then  //make function of cell-size and maybe erosion rate ?
        Begin
          If OptimizeLevel < 2
            then
              begin
                RetA(NewRow, NewCol, C2);
                If (C2.MaxFetch > AdjMaxFetch) then AdjMaxFetch := C2.MaxFetch;   {Two immediately adjacent cells are tested}
              end
          else If (MaxFetchArr[(Site.RunCols*NewRow)+NewCol]*0.001 > AdjMaxFetch) then
                                             {m}             {km/m}     {km}
            Begin
               AdjMaxFetch := MaxFetchArr[(Site.RunCols*NewRow)+NewCol]*0.001;
                  {km}           {m}                                    {km/m}
            End;
        End;
    End;
  END; {Adj}

Var I, J: Integer;
    AdjRow, AdjCol: Integer;
BEGIN {testadjacent}
  AdjMaxFetch := Cell.MaxFetch;
  If OptimizeLevel > 1 then AdjMaxFetch := MaxFetchArr[(Site.RunCols*Row)+EachCol] * 0.001;

  With InundContext do
    Begin
      AdjOcean := False;
      AdjWater := False;
      AdjSalt  := False;
      AdjEFSW  := False;
    End;

  J := Round(500.0/Site.RunScale);
  AdjRow := Row; AdjCol := Col;
  Adj1(0,AdjRow, AdjCol); {test cell itself}

  For I := 1 to J Do   {test 500 m adjacent}
    If AdjCell(AdjRow,AdjCol,False) then Adj1(I, AdjRow, AdjCol);

END; {TestAdjacent}


PROCEDURE TestNear(Cell: PCompressedCell;VAR NearWater, NearSalt: Boolean);
(************************************************************)
(* is shoreline near?                                       *)
(* What is the nearest wetland, for saturation?}            *)
(* What is the precise distance from the cell to the water? *)
(* Clough, December 2005                                    *)
(************************************************************)

Var I, J: LongInt;
    PrevWetland: Integer;
    WetlandWidth: Double;

  {------------------------------------------------}
  Procedure Adj(Row, Col, I: Integer);
  Var Cat: Integer;
      C2: CompressedCell;

    {----------------------------------------------}
    Procedure FindNearestWetland;  {Take elevation of nearest 500 m width wetland for water table estimation}
    CONST MIN_WIDTH_WETLAND = 500; {m}
    Begin
     If (WetLandType = Blank) then
       Begin
         RetA(Row, Col, C2);
         Cat := GetCellCat(@C2);

         If Categories.GetCat(Cat).IsNonTidalWetland then  // Subject to soil saturation spreading
           Begin
             If Cat = PrevWetland
               then WetlandWidth := WetlandWidth + Site.RunScale
               else WetlandWidth := 0;

             PrevWetland := Cat;

             If WetlandWidth > MIN_WIDTH_WETLAND then
              If (CatElev(@C2,Cat)<10) then  // Avoid perched water tables
                begin
                  WetlandType := Cat;
                  WaterTable := CatElev(@C2,Cat);
                end;
           End;
       End;
     End;
    {----------------------------------------------}

  Begin
    With Cell^ Do
     Begin
       FindNearestWetland;

       If Not NearWater Then
        begin
          NearWater := GetBit(MostlyWater, Row, Col);
          //Distance to open water cells
          If NearWater Then
               InundContext.DistancetoOpenSaltWater := I * Site.RunScale; {distance from cell to open salt water, (Cell-width precision)}
        end;

       //Distance to salt water
       If Not NearSalt Then
         Begin
           NearSalt := GetBit(SaltWater, Row, Col);
           If NearSalt Then
               DistancetoWater := I * Site.RunScale; {distance from cell to salt water, (Cell-width precision)}
         End; {not nearsalt}
     End; {with}
  End; {Adj}
  {------------------------------------------------}
Var AdjRow,AdjCol: Integer;
BEGIN
  WaterTable := 0;
  WetLandType := Blank;
  If not IsDryLand(Cell) then WetLandType := -5; {avoid unnecessary calculations of water table above}
  NearWater := False; NearSalt := False; {initialize}

  J := Round(6000.0/Site.RunScale);
  AdjRow := EachRow; AdjCol := EachCol;
  Adj(AdjRow, AdjCol, 0); {test cell itself}
  For I := 1 to J Do   {test 6km adjacent}
    If AdjCell(AdjRow,AdjCol,False) then Adj(AdjRow, AdjCol, I);

END; {TestNear}

PROCEDURE TestLee(Cell: PCompressedCell; VAR NearWater: Boolean);
(************************)
(* is shoreline to lee? *)
(************************)
Var I, J: LongInt;

  {------------------------------------------------}
  Procedure Adj(Row, Col, I: Integer);
  Begin
    If Not NearWater Then
        NearWater := GetBit(MostlyWater, Row, Col);
  End; {Adj}
  {------------------------------------------------}
Var AdjRow,AdjCol: Integer;
BEGIN
  J := Round(6000.0/Site.RunScale);
  AdjRow := EachRow; AdjCol := EachCol;
  Adj(AdjRow, AdjCol, 0); {test cell itself}
  For I := 1 to J Do   {test 6km adjacent to lee}
    If AdjCell(AdjRow,AdjCol,True) then Adj(AdjRow, AdjCol, I);

END; {TestLee}

{-------------------------------------------}
{      Transfer percentages of Classes      }
{             MAIN PROCEDURE                }
{        JSC Modified,  1998, 2005-2007     }
{-------------------------------------------}

Var i: Integer;
    Connected_to_Water: boolean;

Begin  {TRANSFER}
 FOR CC := 0 TO MaxCats DO
    FracLost[CC] := -9999;   {ensure correct initialization}

 ERODING := ErodeStep;
 InundContext.CellFWInfluenced := FWInfluenced(EachRow,EachCol);
 SubSite := Site.GetSubSite(EachCol{x},EachRow{y},Cell);  {Set subsite based on cell being evaluated}

 with Cell^ Do With subsite do
  Begin
   If CellWidth(Cell,Blank) = 0.0 Then    {otherwise skip}
    Begin

     TestAdjacent(Cell, EachRow, EachCol);   {examine adjacent cells}
     FetchThreshold; {Get qualitative estimate of erosion for this cell based on cell specific maxfetch}

     Diked := IncludeDikes and ((ClassicDike and Cell.ProtDikes) or
                                ((not ClassicDike) and Cell.ProtDikes and (not Cell.ElevDikes)));

     // Check if the cell is connected to water
     If (CellWidth(Cell,Categories.OpenOcean) + CellWidth(Cell,Categories.EstuarineWater))/Site.RunScale < 1.0 THEN
      BEGIN {if not all water}
         Connected_to_Water := true;  // assume connected if not checked
         if (checkconnectivity) then Connected_to_water := (Connect_Arr[(Site.RunCols*EachRow)+EachCol] in [3,8,10,30]);

         With InundContext do
           Begin
             TestNear(Cell,NearWater, NearSalt);  {set watertable and wetlandtype}
             If Not NearWater then TestLee(Cell,NearWater);
           End;

         If Connected_To_Water then
           If Eroding then Erode(Cell)
                      else Inundate(Cell);

       if ERODING then
         // Convert cell by salinity if
         // (a) is influenced by fresh water flows and salinity is defined OR
         // (b) there is a salinity raster and salinity is defined in the cell
         if (InundContext.CellFWInfluenced and (Cell.Sal[NUM_SAL_METRICS]>-1)) or ((trim(SalFileN) <> '') and (Cell.Sal[1]>-1)) then ConvertCellbySalinity(Cell);
                                   //check salinity at 30D level                                 //check sal[1] used by SalFile algorithm
       If USE_DATAELEV and (OptimizeLevel>1)
          then If DataElev[(Site.RunCols*EachRow)+EachCol] > Round(SLRise*0.001)
                  then DataElev[(Site.RunCols*EachRow)+EachCol] := DataElev[(Site.RunCols*EachRow)+EachCol] - Round(SLRise*0.001)
                                     {mm}                                   {mm}                             {mm/delta t}
                  else DataElev[(Site.RunCols*EachRow)+EachCol] := 0;

      END; {not all water}
    END;  {not blank}

    If ERODING then
      Begin
       EnterCriticalSection(CriticalSection);
         //Output sites summary
         for i := 0 to Site.NOutputSites do
          begin
            if ((i=0) and (In_Area_to_Save(EachCol,EachRow, not SaveROSArea))) or ((i>0) and (Site.InOutSite(EachCol,EachRow,i))) then
              begin
                //NWI Category summary
                for CC := 0 to Categories.NCats-1 do
                  CatSums[i,CC] := CatSums[i,CC] + (CellWidth(Cell,CC) * Site.RunScale);
                      {m2}                {m2}             {m}              {m}

              end;
          end;

          //Raster Outputs Summary
          if ROSArray<>nil then
            begin
              for i := 1 to Site.MaxROS do
                begin
                  if (i=ROSArray[(Site.RunCols*EachRow)+EachCol]) then
                    begin
                      //NWI Summary
                      for CC := 0 to Categories.NCats-1 do
                        CatSums[i+Site.NOutputSites,CC] := CatSums[i+Site.NOutputSites,CC] + (CellWidth(Cell,CC) * Site.RunScale);
                                           {m2}                                {m2}                       {m}         {m}
                    end;
                end;
            end;

        LeaveCriticalSection(CriticalSection)
      End; {Eroding}
  End; {WITH Cell}

End; {TRANSFER}



{*******************************************}
{        Change attributes for water        }
{         R. A. Park    3/18/88             }
{  Changed to process entire map prior to   }
{  call of Transfer for each cell. Off-Shore}
{  direction should have no effect          }
{                                           }
{  Multi Threaded 1/31/2014, J Clough       }
{                                           }
{*******************************************}

function TSLAMM_Simulation.ChngWater(CalcMF, CalcGeometry: Boolean): Boolean;

       Procedure Parallel_Execute;
       Var ThreadArr2: Array [0..100] of TChngWaterThread;

       Var CCLoop,RowStart,RowEnd,RowsPer: Integer;
           AllDone, UStop:Boolean;
        Begin
          For CCLoop := 0 to CPUs -1 do
            Begin
              RowsPer := ((Site.RunRows div CPUs)+1);
              RowStart :=CCLoop * RowsPer;
              RowEnd := ((CCLoop + 1) * RowsPer) -1;
              if CCLoop = CPUs-1 then RowEnd := Site.RunRows-1;
              ThreadArr2[CCLoop] := TChngWaterThread.Create(Self,RowStart,RowEnd,'Updating Water Attributes '+'('+ IntToStr(CPUs)+' CPUs) ',CCLoop+1,CalcMF);
            End;

          repeat
            Application.processmessages;
            AllDone := True;
            UStop := False;
            For CCLoop := 0 to CPUs -1 do
              Begin
                If not ThreadArr2[CCLoop].ImDone then AllDone := False;
                If ThreadArr2[CCLoop].UserStop then UStop := True;
              End;
           until AllDone {or UStop};

          if Result and CalcMF then          //Calculate Max Fetch
            Begin
              For CCLoop := 0 to CPUs-1 do
                ThreadArr2[CCLoop].Start;  //Calculate Max Fetch Task

              repeat
                Application.processmessages;
                AllDone := True;
                UStop := False;
                For CCLoop := 0 to CPUs -1 do
                  Begin
                    If not ThreadArr2[CCLoop].ImDone then AllDone := False;
                    If ThreadArr2[CCLoop].UserStop then UStop := True;
                  End;
               until AllDone {or UStop};
            End;

          Max_WErode := 0;
          For CCLoop := 0 to CPUs -1 do
           begin
            If ThreadArr2[CCloop].MaxWE >Max_WErode then Max_WErode := ThreadArr2[CCloop].MaxWE;
            if ThreadArr2[CCloop].UserStop then Result := False;
            ThreadArr2[CCloop].Terminate;
            ThreadArr2[CCLoop].Free;
           end;
        End;   {Parallel_Execute}

begin
  Result := True;
  if (CPUs > 1)
    then Parallel_Execute
    else Begin
           Result := ThreadChngWater(0,Site.RunRows-1,nil);
           if Result and CalcMF then Begin Max_WErode := 0; Result := CalculateMaxFetch(0,Site.RunRows-1,nil,Max_WErode); End;;
        End;

  If Result and CalcGeometry then Result := CalculateFlowGeometry(Year);
end;

{---------------------------------------------------------------}

Function TSLAMM_Simulation.ThreadChngWater(StartRow,EndRow: Integer; PRunThread: Pointer):Boolean;

{This procedure sets the current cell's water attribute settings
   ExposedWater (50% open ocean)
   MostlyWater  (90% water)
   SaltWater    (>10% salt characteristics)
   WaterTFlat   (90% water and TFlat }
Var ER, EC: Integer;
    Cat, i: Integer;
    Acc: Double;
    CWC: CompressedCell;
    SubSite: TSubSite;
    TCWT: TChngWaterThread;
    WidthOpenWater, WidthTidal, WidthEFSW: Double;

Begin
  Result := True;

 FOR ER := StartRow To EndRow Do
  FOR EC := 0 To (Site.RunCols-1) Do
   Begin
     If EC=0 then
       Begin
         if PRunThread<>nil
         then begin
               TCWT := PRunThread;
               if TCWT.Terminated
                 then Result := False
                 else Result := TCWT.UpdateProg('Updating Water Attributes '+ '('+ IntToStr(CPUs)+' CPUs) ',Trunc((ER-StartRow)/(EndRow-StartRow+1)*100));
              end
         else Begin
                Result := ProgForm.Update2Gages(Trunc((Er)/Site.RunRows*100),0);
                ProgForm.ProgressLabel.Caption:='Updating Water Attributes (Chngwater)';
              End;
         If Not Result then Exit;
       End;

    BMatrix[Site.RunCols*(ER)+(EC)]:=0;
    ErodeMatrix[Site.RunCols*(ER)+(EC)]:=0;

    RetA(ER, EC, CWC);
    Subsite := Site.GetSubSite(EC {x},ER {y},@CWC);

    With CWC Do With subsite do
      Begin
        If (CellWidth(@CWC,Categories.OpenOcean)/Site.RunScale > 0.5)
            Then SetBit(ExposedWater,ER,EC,True)
            Else SetBit(ExposedWater,ER,EC,False);

        WidthOpenWater := 0; WidthTidal := 0;  WidthEFSW := 0;
        For i:=1 to NUM_CAT_COMPRESS do
          Begin
            If Categories.GetCat(CWC.CATS[i]).IsOpenWater then WidthOpenWater := WidthOpenWater + Widths[i];
            If Categories.GetCat(CWC.CATS[i]).IsTidal then WidthTidal := WidthTidal + Widths[i];
            If CWC.CATS[i] = 14 then WidthEFSW := WidthEFSW + Widths[i];   // hard-wired to CAL EFSW category

          End;

        IF (WidthOpenWater/Site.RunScale) > 0.9
            Then SetBit(MostlyWater,ER,EC,TRUE)
            Else SetBit(MostlyWater,ER,EC,FALSE);

        IF (WidthEFSW/Site.RunScale) > 0.01
            Then SetBit(HasEFSW,ER,EC,TRUE)
            Else SetBit(HasEFSW,ER,EC,FALSE);

        If (WidthTidal/Site.RunScale) > 0.1
           Then SetBit(Saltwater,ER,EC,TRUE) {saltwetlands occur or salt water}
           Else SetBit(Saltwater,ER,EC,FALSE);

(*        IF ((CellWidth(@CWC,DevDryland) + CellWidth(@CWC,UndDryland))/Site.RunScale < 0.1)
           Then SetBit(AllWetland,ER,EC,True)
           Else SetBit(AllWetland,ER,EC,False); *)

        { ADD ACCRETION TO "DATA ELEVATION" USED IN SALINITY CALCULATIONS }
        Acc := 0;
        Cat :=  GetCellCat(@CWC);
        If (Not IncludeDikes) or (Not CWC.ProtDikes) then with Subsite do      {calculate cell-specific accretion for non diked cells}
          Case Categories.GetCat(Cat).AccrModel of
            RegFM     : ACC := DeltaT * DynamicAccretion(@CWC,Cat,SubSite,0);
            IrregFM   : ACC := DeltaT * DynamicAccretion(@CWC,Cat,SubSite,1);
            BeachTF   : ACC := DeltaT * DynamicAccretion(@CWC,Cat,SubSite,2);
            TidalFM   : ACC := DeltaT * DynamicAccretion(@CWC,Cat,SubSite,3);
            InlandM   : ACC := DeltaT * InlandFreshAccr;
            Mangrove  : ACC := DeltaT * MangroveAccr;
            TSwamp    : ACC := DeltaT * TSwampAccr;
            Swamp     : ACC := DeltaT * SwampAccr;
                        {mm}    {yr}      {mm/yr}
          End   //Case
        else;

        If USE_DATAELEV and (OptimizeLevel>1) and (Acc > 0)
           then DataElev[(Site.RunCols*ER)+EC] :=  Min(DataElev[(Site.RunCols*ER)+EC] +  Round(Acc), 65535);
                 {mm}                                    {mm}                                {mm}    {max elev (word)}
      End; {with}
   End;
End; {ChngWater}



{*******************************************}
{ Added Calculation of MaxFetch as cell     }
{ attribute     J.Clough 12/2005            }
{*******************************************}


Function TSLAMM_Simulation.CalculateMaxFetch(StartRow,EndRow: Integer;PRunThread: Pointer; Var LMaxEw: Double): Boolean;
CONST HIGH_FETCH = 20.1;  {maximum relevant fetch ... infinite}
Var ER, EC: Integer;
    ThisFetch: Double;
    CurrX, CurrY: Integer;  // previous cell being checked for fetch
    OverOcean: Boolean;

    MaxFetchIndex, FetchIndex, CompassPoints: Integer;
    MFC: CompressedCell;
    MarshElev, MarshWidth: Double;
    SubS: TSubSite;
    FetchDepths: Array of Double;
    PowerArray: Array [1..NWindDirections] of Double;  // keep track of what wind direction is contributing


        {---------------------------------------------------------------------}
        Function ValidCell(C,R: Integer): Boolean;
        Begin
          ValidCell := (R>=0) and (C>=0) and (R<Site.RunRows) and (C<Site.RunCols);
        End;
        {---------------------------------------------------------------------}
        Function CheckCell(C,R:Integer): Boolean;
        Var C2: CompressedCell;
        Begin
          If Not ValidCell(C,R)
            Then Begin
                   CheckCell := False;
                   If GetBit(ExposedWater,CurrY,CurrX) then
                     Begin
                       MFC.MaxFetch := HIGH_FETCH;
                       ThisFetch := HIGH_FETCH;
                       {out of bounds in the ocean, assume maximum fetch is infinite}
                     End;
                 End
            Else Begin
                   If GetBit(ExposedWater,R,C) then OverOcean := True;
                   CheckCell := GetBit(MostlyWater,R,C);

                   If (Not Result) and OverOcean then
                    {If blank after passing through ocean, assume max fetch is infinite}
                     Begin
                       RetA(R, C, C2);
                       If CellWidth(@C2,Blank) > 0 then
                         Begin
                           MFC.MaxFetch := HIGH_FETCH;
                           ThisFetch := HIGH_FETCH;
                           {out of bounds in the ocean, assume maximum fetch is infinite}
                         End;
                     End;

                    If Result then
                     If (SubS.USE_Wave_Erosion) and (Subs.WE_Has_Bathymetry) then
                      Begin
                        Inc(FetchIndex);
                        If FetchIndex < MaxFetchIndex-1 then
                          Begin
                            RetA(R, C, C2);
                            FetchDepths[Fetchindex] := GetMinElev(@C2);
                          End;
                      End;
                 End;
        End;

    {---------------------------------------------------------------------}
    Procedure CalculateWavePower;
    Var AvgDepthMTL, AvgDepth, QTU: Double;
        i: Integer;
        WD, WS, Tides: Integer;
        WaterLevel: Double;
        WindSpeed, Fetch, NWD, NDF, A1, B1, NWE, WE, {WEH,} A2, B2, NDWF, WF, WP, G, F, WLen, WCel, WNum, WGC, Pw, Pi_W : Double;
        TotalPower: Double; // Whr
        TotIP: Double; // combined incident power for two possible face exposures

        Procedure CalcTotIP;
        Const  Deg45 = 0.7073883;
               Deg225= 0.923955699;
               Deg675= 0.383235147;
        Begin
          TotIP := 0;
          Case WD of
              1,5,9,13: TotIP := 1.0;  // North south east west, incident power is 1.0
               {----}
              3: Begin  // northeast
                   If CheckCell(EC+1,ER) then TotIP := TotIP + Deg45;   // if x+1 has water
                   If CheckCell(EC,ER-1) then TotIP := TotIP + Deg45;   // if y-1 has water
                 End;
              7: Begin  // northwest
                   If CheckCell(EC-1,ER) then TotIP := TotIP + Deg45;   // if x-1 has water
                   If CheckCell(EC,ER-1) then TotIP := TotIP + Deg45;   // if y-1 has water
                 End;
              15: Begin  // southeast
                   If CheckCell(EC+1,ER) then TotIP := TotIP + Deg45;   // if x+1 has water
                   If CheckCell(EC,ER+1) then TotIP := TotIP + Deg45;   // if y+1 has water
                 End;
              11: Begin  // southwest
                   If CheckCell(EC-1,ER) then TotIP := TotIP + Deg45;   // if x-1 has water
                   If CheckCell(EC,ER+1) then TotIP := TotIP + Deg45;   // if y+1 has water
                 End;
               {----}
              2: Begin  // ENE
                   If CheckCell(EC+1,ER) then TotIP := TotIP + Deg225;   // if x+1 has water  (east)
                   If CheckCell(EC,ER-1) then TotIP := TotIP + Deg675;   // if y-1 has water
                 End;
              8: Begin  // WNW
                   If CheckCell(EC-1,ER) then TotIP := TotIP + Deg225;   // if x-1 has water  (west)
                   If CheckCell(EC,ER-1) then TotIP := TotIP + Deg675;   // if y-1 has water
                 End;
              16: Begin  // ESE
                   If CheckCell(EC+1,ER) then TotIP := TotIP + Deg225;   // if x+1 has water  (east)
                   If CheckCell(EC,ER+1) then TotIP := TotIP + Deg675;   // if y+1 has water
                 End;
              10: Begin  // WSW
                   If CheckCell(EC-1,ER) then TotIP := TotIP + Deg225;   // if x-1 has water  (west)
                   If CheckCell(EC,ER+1) then TotIP := TotIP + Deg675;   // if y+1 has water
                 End;
               {----}
              4: Begin  // NNE
                   If CheckCell(EC+1,ER) then TotIP := TotIP + Deg675;   // if x+1 has water  (east)
                   If CheckCell(EC,ER-1) then TotIP := TotIP + Deg225;   // if y-1 has water
                 End;
              6: Begin  // NNW
                   If CheckCell(EC-1,ER) then TotIP := TotIP + Deg675;   // if x-1 has water  (west)
                   If CheckCell(EC,ER-1) then TotIP := TotIP + Deg225;   // if y-1 has water
                 End;
              14: Begin  // SSE
                   If CheckCell(EC+1,ER) then TotIP := TotIP + Deg675;   // if x+1 has water  (east)
                   If CheckCell(EC,ER+1) then TotIP := TotIP + Deg225;   // if y+1 has water
                 End;
              12: Begin  // SSW
                   If CheckCell(EC-1,ER) then TotIP := TotIP + Deg675;   // if x-1 has water  (west)
                   If CheckCell(EC,ER+1) then TotIP := TotIP + Deg225;   // if y+1 has water
                 End;
          End; {Case}
        End;


    Const GA = 9.81;  // gravity acceleration 9.81 m/s2
          WDens = 1025; // water density kg/m3
    Begin
      WD := CompassPoints;
      CalcTotIP;

      AvgDepthMTL := 0;
      If SubS.WE_Has_Bathymetry
       then
         Begin
           If FetchIndex>2 then
             Begin
               For i:= 0 to Trunc(FetchIndex/3) do  // average first third only;
                 AvgDepthMTL := AvgDepthMTL - FetchDepths[i]; // convert negative elevation relative to MTL to positive
               AvgDepthMTL := (AvgDepthMTL / Trunc(FetchIndex/3)) // calculate average of first third of fetch
             End;
         End
       else AvgDepthMTL := SubS.WE_Avg_Shallow_Depth;  // no bathymetry, use entered meters below MTL

      QTU := SubS.GTideRange/4;    // quarter tide range
      TotalPower := 0;

      For WS := 1 to NWindSpeeds do
       If (WindRose[WD,WS] > 0) then   // fetch > 0 and wind > 0
        For Tides := 1 to 5 do
         Begin
           WaterLevel := (Tides-3) * QTU;  // meters relative to MTL   [MLLW, midpoint, MTL, midpoint, MHHW]
           AvgDepth := AvgDepthMTL + WaterLevel;

           If AvgDepth > 0 then
             Begin
               WindSpeed := 0;
               Case WS of
                 1: WindSpeed := 0.25; {m/s}
                 2: WindSpeed := 1.25;
                 3: WindSpeed := 3;
                 4: WindSpeed := 5;
                 5: WindSpeed := 7;
                 6: WindSpeed := 9;
                 7: WindSpeed := 11; {m/s}
               End; {case}

               Fetch := ThisFetch * 1000; {m}
               NWD := GA*AvgDepth/SQR(WindSpeed);  // non dimensional water depth gdU^2
               NDF := GA *Fetch/SQR(WindSpeed);    // non dimensional fetch
               A1 := 0.493*Power(NWD,0.75);
               B1 := 3.13E-3*Power(NDF,0.57);
               NWE := 3.63*0.001*Power((TANH(A1)*TANH(B1/(TANH(A1)))),1.74);  //Nondimensional wave energy
               WE  := WDens*GA*NWE*Power(WindSpeed,4)/SQR(GA);
//             WEH := SQRT(WE*16/(GA*WDens));    // Wave effective height in m

               If WaterLevel <= MarshElev then   // only calculate if tidal height less than the level of the marsh
                 Begin
                   A2 := 0.33*Power(NWD,1.01);
                   B2 := 5.215*0.0001*Power(NDF,0.73);
                   NDWF := 0.133*Power((TANH(A2)*TANH(B2/(TANH(A2)))),-0.37); // Non dimensional Wave frequency
                   WF := NDWF*GA/WindSpeed;
                   WP := 1/WF;
                   G := AvgDepth*(SQR(2*PI/WP))/GA;
                   F := G+(1/(1+0.6522*G+0.4622*SQR(G)+0.0864*Power(G,4)+0.0675*Power(G,5)));
                   WLen := WP*SQRT(GA*AvgDepth/F);
                   WCel := WLen/WP;
                   WNum := 2*PI/WLen;
                   WGC :=  0.5*WCel*(1+2*WNum*AvgDepth/SINH(2*WNum*AvgDepth));  // Wave group celerity  // 1/2
                   Pw := WGC*WE;  // W/m

                   Pi_W := Pw * TotIP * WindRose[WD,WS] / 500;  // incident power in (W/m)*(hr/yr)  (5 water levels)
                                       {unitless frac. of year }
                   TotalPower := TotalPower + Pi_W;
                    {W/m}                     {W/m}

                   PowerArray[WD] := PowerArray[WD] + Pi_W;
                 End;
             End; // AvgDepth > 0
         End;  // Windspeeds and Tides Loop

      MFC.Pw := MFC.Pw + TotalPower;  // mean annual wave power density in W/m  for the cell
    End;
    {---------------------------------------------------------------------}
    Procedure CheckFetch(DX,DY:Integer; Incr: Double);
    Var ClearPath: Boolean;

    Begin
      ThisFetch := 0;
      CurrX := EC;
      CurrY := ER;
      ClearPath := True;
      OverOcean := False;

      Repeat
        If Abs(DX)>1 then {check intermediate cells too}
           ClearPath := CheckCell(CurrX+(DX DIV 2),CurrY) and CheckCell(CurrX+DX,CurrY);
        If Abs(DY)>1 then {check intermediate cells too}
           ClearPath := CheckCell(CurrX,CurrY+(DY DIV 2)) and CheckCell(CurrX,CurrY+DY);

        If ClearPath then ClearPath:=CheckCell(CurrX+DX,CurrY+DY);
        If ClearPath then
          Begin
            ThisFetch := ThisFetch + Incr  * Site.RunScale * 0.001;
             {km}          {km}     {cells}      {m/cell}   {m/km}
            CurrX := CurrX + DX;
            CurrY := CurrY + DY;
          End;

      Until Not ClearPath;

      If (ThisFetch>0.1) and (SubS.USE_Wave_Erosion) and WaveErosionCat(@MFC,MarshElev,MarshWidth) then CalculateWavePower;

      If ThisFetch > MFC.MaxFetch then MFC.MaxFetch := ThisFetch;
    End;
    {---------------------------------------------------------------------}
    Function MiddleOfWater(C,R: Integer): Boolean;
    Var W1,W2,W3,W4 : Boolean;
    Begin
      MiddleOfWater := False;
      If not GetBit(MostlyWater,R,C) then Exit;  {cell itself must be water}
      If ValidCell(C,R+1) and ValidCell(C,R-1) and
        ValidCell(C+1,R) and ValidCell(C-1,R) then
          Begin                                 {and four surrounding cells}
            W1 := GetBit(MostlyWater,R-1,C);
            W2 := GetBit(MostlyWater,R+1,C);
            W3 := GetBit(MostlyWater,R,C-1);
            W4 := GetBit(MostlyWater,R,C+1);
            MiddleOfWater := W1 and W2 and W3 and W4;
          End;
    End;
    {---------------------------------------------------------------------}
    Procedure DistributeWPErosion(EX,EY: Integer; ToDistrib: Double);  // todistrib, quantity of "extra" erosion to distribute in meters
    Var FracThisWD: Double;

         Procedure Distribute(DX,DY:Integer; DFrac: Double);
         Var DCell : CompressedCell;
             DElev,DWidth: Double;
         Begin
           If Not ValidCell(EX-DX,EY-DY) then exit; // off the map
           RetA(EY-DY,EX-DX,DCell);
           If WaveErosionCat(@DCell,DElev,DWidth) then
             Begin
               DCell.WPErosion := DCell.WPErosion + ToDistrib * FracThisWD * DFrac;
                     {m/y}                            {m/y}
               SetA(EY-DY,EX-DX,DCell);
             End;

         End;

    Var CP: Integer;
    Begin
       FOR CP :=  1 to NWindDirections do
        If PowerArray[CP] > 0 then
         Begin
          FracThisWD := PowerArray[CP] / MFC.Pw;  // fraction of erosoin from this wind direction
            Case CP of
              1: Distribute(1,0,1);             // E     90
              2: Begin Distribute(0,-1,0.293);  // E-NE  67.5    0.293 is weighted average based on wave angle, but conserving total volume eroded  (SIN(22.5)/(SIN(22.5)+COS(22.5))
                       Distribute(1,0,0.707);
                 End;
              3: Begin Distribute(0,-1,0.5);   // NE    45
                       Distribute(1,0,0.5);
                 End;
              4: Begin Distribute(0,-1,0.707);  // N-NE  22.5
                       Distribute(1,0,0.293);
                 End;

              5: Distribute(0,-1,1);           // N     0
              6: Begin Distribute(0,-1,0.707);  // N-NW  337.5
                       Distribute(-1,0,0.293);
                 End;
              7: Begin Distribute(0,-1,0.5);   // NW    315
                       Distribute(-1,0,0.5);
                 End;
              8: Begin Distribute(0,-1,0.293);  // W-NW  292.5
                       Distribute(-1,0,0.707);
                 End;

              9: Distribute(-1,0,1);           // W     270
             10: Begin Distribute(0,1,0.293);  // W-SW  247.5
                       Distribute(-1,0,0.707);
                 End;
             11: Begin Distribute(0,1,0.5);   // SW    225
                       Distribute(-1,0,0.5);
                 End;
             12: Begin Distribute(0,1,0.707);  // S-SW  202.5
                       Distribute(-1,0,0.293);
                 End;

             13: Distribute(0,1,1);           // S     180
             14: Begin Distribute(0,1,0.707);  // S-SE  157.5
                       Distribute(1,0,0.15);
                 End;
             15: Begin Distribute(0,1,0.5);   // SE    135
                       Distribute(1,0,0.5);
                 End;
             16: Begin Distribute(0,1,0.293);  // E-SE  112.5
                       Distribute(1,0,0.707);
                 End;
            End; {Case}
         End; {If PowerArray > 0}

    End;
    {---------------------------------------------------------------------}

Var  TCWT: TChngWaterThread;
     WD: Integer;
     ErosionBeyondCell: Double;

Begin    // CalculateMaxFetch
 Result := True;

 FetchDepths := nil;
 FOR ER := StartRow To EndRow Do
  FOR EC := 0 To (Site.RunCols-1) Do
   Begin
     If EC=0 then
       Begin
         if PRunThread<>nil
         then begin
                TCWT := PRunThread;
                if TCWT.Terminated
                  then Result := False
                  else Result := TCWT.UpdateProg('Calculating Max Fetch '+'('+ IntToStr(CPUs)+' CPUs) ',Trunc((ER-StartRow)/(EndRow-StartRow+1)*100))
              end
         else Begin
                Result := ProgForm.Update2Gages(Trunc((Er)/Site.RunRows*100),0);
                ProgForm.ProgressLabel.Caption:='Calculating Max Fetch';
              End;
         If Not Result then Exit;
       End;

    If not MiddleOfWater(EC,ER) then
      Begin
        RetA(ER, EC, MFC);
        MFC.MaxFetch := 0;
        MFC.Pw := 0;
        MFC.WPErosion := 0;
        SubS := Site.GetSubSite(EC {x},ER {y},@MFC);
        If SubS.USE_Wave_Erosion then
          Begin
            FetchIndex := -1;
            If (SubS.WE_Has_Bathymetry) and (FetchDepths = nil) then SetLength(FetchDepths,Round(7000/Site.RunScale)); // record a maximum of 7km of depths

            For WD := 1 to NWindDirections do
             PowerArray[WD] := 0;  // initialize Wind Direction Array
          End;

        FOR CompassPoints := 1 to NWindDirections do
            Case CompassPoints of
              1: CheckFetch(1,0,1);          // E     90
              2: CheckFetch(2,-1,2.236);     // E-NE  67.5
              3: CheckFetch(1,-1,1.412);     // NE    45
              4: CheckFetch(1,-2,2.236);     // N-NE  22.5
              5: CheckFetch(0,-1,1);         // N     0
              6: CheckFetch(-1,-2,2.236);    // N-NW  337.5
              7: CheckFetch(-1,-1,1.412);    // NW    315
              8: CheckFetch(-2,-1,2.236);    // W-NW  292.5
              9: CheckFetch(-1,0,1);         // W     270
              10: CheckFetch(-2,1,2.236);     // W-SW  247.5
              11: CheckFetch(-1,1,1.412);     // SW    225
              12: CheckFetch(-1,2,2.236);     // S-SW  202.5
              13: CheckFetch(0,1,1);          // S     180
              14: CheckFetch(1,2,2.236);      // S-SE  157.5
              15: CheckFetch(1,1,1.412);      // SE    135
              16: CheckFetch(2,1,2.236);      // E-SE  112.5
            End; {Case}

        If OptimizeLevel>1 then
          If MFC.MaxFetch > 65.5 then MaxFetchArr[(Site.RunCols*ER)+EC] := 65500
                                 else MaxFetchArr[(Site.RunCols*ER)+EC] := Round(MFC.MaxFetch*1000);
        MFC.WPErosion := MFC.Pw * SubS.WE_Alpha;
        SetA(ER, EC, MFC);
        If MFC.WPErosion > LMaxEw then LMaxEW := MFC.WPErosion;  // pass back maximum erosion rate for scaling

        ErosionBeyondCell := MFC.WPErosion * SubS.DeltaT - MarshWidth;
          {m / time step}        {m/y}       {y/time step}  {meters in cell}
        If ErosionBeyondCell > 0 then DistributeWPErosion(EC,ER,ErosionBeyondCell);
      End
     Else // middle of water
       Begin
         RetA(ER, EC, MFC);
         If MFC.Pw > 0 then
           Begin
             MFC.PW := 0;
             MFC.WPErosion := 0;
             SetA(ER,EC, MFC);
           End;
       End;

   End; {for EC}

   FetchDepths := nil;

End; {CalculateMaxFetch}

