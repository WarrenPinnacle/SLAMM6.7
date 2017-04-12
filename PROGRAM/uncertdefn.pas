unit uncertdefn;

interface

uses Classes, SysUtils, Dialogs, TCollect;

CONST NUM_UNCERT_PARAMS = 51;
      PRE_ACCR          = 27;

Type

  TDistType     = (Triangular,Uniform,Normal,LogNormal,ElevMap);

  TInputDist = Class(TObject)
      DName: String;                 {Text associated with distribution}
      Notes: String;                {User Notes}
      IDNum: Integer;               {ID Number}

      AllSubSites: Boolean;         {all subsites?  Or just one subsite }
      SubSiteNum: Integer;          {Subsite number if AllSubSites is False, 0 is global, 1 is first array position (subsite #1)}

      DistType: TDistType;          {type of distribution, triangle, uniform, norm, lognorm}
      Parm: Array[1..4] of Double;  {Parameters that describe the distribution}

      {No Load and Save Below}
      TSS           : Pointer;      {Pointer to TSLAMMSimulation}
      DisplayCDF    : Boolean;      {Is distribution displayed as CDF? }
      Draws         : TCollection;    {Stores the all the variable draws for this distribution, doesn't need saving}
      PointEsts     : Array of Double;
      IsSubSiteParameter: Boolean;    {Applies as a multiplier to subsites.  If False is Global e.g. SLR}

      Function CDF(XVal:Double): Double;
      Function TruncCDF(XVal:Double): Double;
      Function ICDF(prob:Double): Double;
      Function TruncICDF(prob:Double): Double;  // ICDF of a truncated Normal or LogNormal Dist
      Function GetName( IncludeSS: Boolean): String;
      Function NameFromIndex(Indx: Integer): String;
      Function ZMapIndex: Integer;
      Constructor Create(IDN: Integer; PSlammSim: Pointer; AllSubs: Boolean; SSN: Integer);
      Procedure Store(Var St: TStream);
      Function GetValuePointer(SSN: Integer):PDouble;
      Function GetValue: Double;
      Procedure SetValues(Multiplier: Double);
      Procedure RestoreValues;
      Constructor Load (ReadVersionNum: Double; St: TStream; PSlammSim: Pointer);
      Function SummarizeDist: String;
  End;

  TSensParam = Class(TInputDist)
      Procedure RestoreValues;
      Procedure SetValues(Multiplier: Double);
    End;

  TDistArray = Array of TInputDist;
  PDistArray = ^TDistArray;

  TSensArray = Array of TSensParam;
  PSensArray = ^TSensArray;


  TUncertDraw =  Class(TObject)
    Value: Double;
    RandomDraw: Double;
    IntervalNum: Longint;
    Constructor Init(Val,RD:Double;Int:LongInt);
  end;

//  Function PromptForFile(Var Fl: String): Boolean;
  Function FixFloattoStr(F: Double;L: Integer): String;

implementation

Uses Global, SLR6, SiteEdits, CalcDist;

Function FixFloattoStr(F: Double;L: Integer): String;
Var SubStr : String;
    Loop: Integer;
Begin
  SubStr := FloatToStrF(F,ffGeneral,L-2,3);
  If Pos('.',SubStr)=0 then SubStr := SubStr+'.';
  If Length(SubStr)>=L then SubStr := FloatToStrF(F,ffExponent,L-5,1);
  If Pos('.',SubStr)=0 then SubStr := SubStr+'.';
  If Length(SubStr)>=L then SubStr := FloatToStrF(F,ffExponent,L-6,1);
  If Length(SubStr)>=L then
    Begin
       Raise EConvertError.Create('Error, FixFloat too Large');
    End;
  For Loop := Length(SubStr)+1 to L do
    SubStr := ' '+SubStr;
  FixFloatToStr := SubStr;
End;

(* Function PromptForFile(Var Fl:String): Boolean;
Var OpenDialog1: TOpenDialog;
Begin
  OpenDialog1 := TOpenDialog.Create(nil);
  OpenDialog1.Title:='Cannot find '+Fl;
  OpenDialog1.InitialDir := ExtractFilePath(Fl);
  OpenDialog1.FileName := ExtractFileName(Fl);
  OpenDialog1.Filter := '';
  PromptForFile := OpenDialog1.Execute;

  Fl := OpenDialog1.FileName;
  OpenDialog1.Free;

End; *)

Function TinputDist.NameFromIndex(Indx: Integer): String;    // Called as part of create

Var uncertaccr, AccrNum, AN2: Integer;

Begin
  uncertaccr := NumRowsAccr - 2;  //delete "use" boolean and notes string

  IsSubsiteParameter := (Indx>2) and (Indx<>5);

  Case indx of
    1: Result := 'SLR by 2100 (mult.)';  // SLR.  Note if another global (non subsite) uncert variable is added then logic needs to be updated.  Search on globaluncertlogic and IsSubSite
    2: Result := 'DEM Uncertainty (RMSE in m)';  // elev uncert map;
    3: Result := 'Historic trend (mult.)';  {if no uplift, subsidence map is included}
    4: Result := 'NAVD88 - MTL (mult.)';
    5: Result := 'NAVD88 Uncert Map (RMSE in m)'; // elev uncert map  New 2/22/11
    6: Result := 'GT Great Diurnal Tide Range (m)';      // NOTE SE, GT Logic needs to change if this IDNumber changes
    7: Result := 'Salt Elev. (mult.)';                   // NOTE SE, GT Logic needs to change if this IDNumber changes
    8: Result := 'Marsh Erosion (mult.))';
    9: Result := 'Swamp Erosion (mult.)';
    10: Result := 'T.Flat Erosion (mult.)';
    11: Result := 'Reg. Flood Marsh Accr (mult.)';
    12: Result := 'Irreg. Flood Marsh Accr (mult.)';
    13: Result := 'Tidal Fresh Marsh Accr (mult.)';

    14: Result := 'Inland-Fresh Marsh Accr (mult.)';   //new 5-20-11
    15: Result := 'Mangrove Accr (mult.)';
    16: Result := 'Tidal Swamp Accr (mult.)';
    17: Result := 'Swamp Accretion (mult.)';

    18: Result := 'Beach Sed. Rate (mult.)';
    19: Result := 'Wave Erosion Alpha';
    20: Result := 'Wave Erosion Avg. Shallow Depth (m)';
    21: Result := 'Elev. Beach Crest (m)';
    22: Result := 'Lagoon Beta (frac)';
    23: Result := '';
    24: Result := '';
    25: Result := '';
    26: Result := 'Irreg. Flood Marsh Collapse (mult.)';  // 1/11/2016
    27: Result := 'Reg. Flood Marsh Collapse (mult.)';
  End;

  If indx>PRE_ACCR then
    Begin
      AccrNum := (indx-PRE_ACCR-1) div uncertaccr;
      AN2 := (indx-PRE_ACCR-1) mod uncertaccr;
      Case AN2 of
          0: Result :=AccrNames[AccrNum]+' Max. Accr. (mult.)';
          1: Result :=AccrNames[AccrNum]+' Min. Accr. (mult.)';
          2: Result :=AccrNames[AccrNum]+' Elev a coeff. (mult.)';
          3: Result :=AccrNames[AccrNum]+' Elev b coeff. (mult.)';
          4: Result :=AccrNames[AccrNum]+' Elev c coeff. (mult.)';
          5: Result :=AccrNames[AccrNum]+' Elev d coeff. (mult.)';

(*        5: Result :=AccrNames[AccrNum]+' D.Effect Max (mult.)';
          6: Result :=AccrNames[AccrNum]+' D min. (mult.)';
          7: Result :=AccrNames[AccrNum]+' Salinity Turb. Max (mult.)';
          8: Result :=AccrNames[AccrNum]+' Turb. Max Zone (mult.)';
          9: Result :=AccrNames[AccrNum]+' S. Non T.Max (mult.)';  *)
        End; {case}
    End;

{   Min Elev Threshholds
    Max Elev Threshholds }

End;



Function TinputDist.TruncICDF(Prob:Double): Double;    // norm and lognorm distributions left truncated to zero
Var NewProb: Double;
    ProbMin: Double;
Begin
  If DistType in [Triangular,Uniform]
    then NewProb := Prob //already limited to max of zero through interface.
    else
      Begin
        ProbMin := CDF(0);
        NewProb := ProbMin + Prob * (1-ProbMin);
      End;
  TruncICDF := ICDF(NewProb);
End;


Function TinputDist.ICDF(Prob:Double): Double;
Var Res: Double;
Begin
 Res := Error_Value;
    Case Disttype of
      Normal       : Res:=ICdfNormal(Prob,Parm[1],Parm[2]);
      Triangular   : Res:=ICdfTriangular(Prob,Parm[2],Parm[3],Parm[1]);
      LogNormal    : Res:=ICdfLogNormal(Prob,exp(Parm[1]),exp(Parm[2]));
      Uniform      : Res:=ICdfuniform(Prob,Parm[1],Parm[2]);

    end;
 If Res = Error_Value then Raise ESLAMMError.Create('Distribution Error!  ICDF Called with Invalid Parameters.');
 ICDF:=Res;
End;

{------------------------------------------------------------------}

Function TinputDist.TruncCDF(XVal:Double): Double;    // norm and lognorm distributions left truncated to zero
Var CDFZero: Double;
    CDFXval: Double;
Begin
  CDFXval := CDF(XVal);
  If (DistType in [Triangular,Uniform])
    then Result := CDFXVal
    else
      Begin
        CDFZero := CDF(0);
        TruncCDF := (CDFXval - CDFZero) * (1/(1-CDFZero))
      End;
End;


Function TinputDist.CDF(XVal:Double): Double;
Var Res: Double;
Begin
 Res := Error_Value;
     Case Disttype of
           Triangular: Res:=cdfTriangular(XVal,Parm[2],Parm[3],Parm[1]);
           Normal:     Res:=cdfNormal(XVal,Parm[1],Parm[2]);
           LogNormal:  Res:=cdfLogNormal(XVal,exp(Parm[1]),exp(Parm[2]));
           Uniform:    Res:=cdfuniform(XVal,Parm[1],Parm[2]);
      end;
 If Res = Error_Value then Raise ESLAMMError.Create('Distribution Error!  CDF Called with Invalid Parameters.');
 CDF:=Res;
End;

{------------------------------------------------------------------}


constructor Tinputdist.Create;
begin

  IDNum := IDN;
  DName := NameFromIndex(IDN);

  AllSubSites := AllSubs or (IDN=1);  //SLR (IDN=1) always pertains to all subsites
  SubSiteNum := SSN;
  If SubSiteNum < 0 then SubSiteNum := 0;

  TSS := PSlammSim;

  DistType:=Normal;
  Parm[1] := 1.0;
  Parm[2] := Parm[1]*0.4;
  Parm[3] := 1.3 * Parm[1];
  Parm[4] := 0;

  If (IDNum = 2) or (IDNum = 5) then
    Begin
      DistType := ElevMap;
      Parm[1] := 0.12;
      Parm[2] := 0.245;
      Parm[3] := 0;
      Parm[4] := 0;
    End;

  DisplayCDF := False;
  Draws:=nil;
end;

Constructor TInputDist.Load(ReadVersionNum: Double; St: TStream; PSlammSim: Pointer);
Var DTN: Integer;
Begin
  TSS := PSlammSim;

  TSRead('DistName',DName,ReadVersionNum);
  TSRead('Notes',Notes,ReadVersionNum);
  TSRead('IDNum',IDNum);
  If (ReadVersionNum < 6.225) and (IDNum > 4) then Inc(IDNum);
  If (ReadVersionNum < 6.245) and (IDNum > 13) then IDNum := IDNum + 4;

  If (ReadVersionNum < 6.915) and (IDNum > 25) then IDNum := IDNum + 2;  // 1/11/2016 add room for marsh collapse

  If ReadVersionNum > 6.815 then
    Begin
      TSRead('AllSubSites',AllSubSites);
      TSRead('SubsiteNum',SubSiteNum);
      If SubSiteNum<0 then SubSiteNum := 0;
    End
  else
    Begin
      AllSubSites := True;
      SubSiteNum := 0;
    End;

  IsSubsiteParameter := (IDNum>2) and (IDNum<>5);

  TSRead('DistType',DTN);
  DistType := TDistType(DTN);
  TSRead('Parm(1)',Parm[1]);
  TSRead('Parm(2)',Parm[2]);
  TSRead('Parm(3)',Parm[3]);
  TSRead('Parm(4)',Parm[4]);
  TSRead('DisplayCDF',DisplayCDF);

//  UserFileN := '';
//  If DistType = USER then
//    TSRead(UserFileN,Sizeof(UserFileN));
End;

Procedure TInputDist.Store(Var St: TStream);
Begin
  TSWrite('DistName',DName);
  TSWrite('Notes',Notes);
  TSWrite('IDNum',IDNum);

  TSWrite('AllSubSites',AllSubSites);
  TSWrite('SubsiteNum',SubSiteNum);

  TSWrite('DistType',ORD(DistType));
  TSWrite('Parm(1)',Parm[1]);
  TSWrite('Parm(2)',Parm[2]);
  TSWrite('Parm(3)',Parm[3]);
  TSWrite('Parm(4)',Parm[4]);
  TSWrite('DisplayCDF',DisplayCDF);

//  If DistType = USER then
//    TSWrite(UserFileN,Sizeof(UserFileN));

End;

function TInputDist.SummarizeDist: String;

    Var ParmLoop: Integer;
        ParmInfo: Array[0..4] of String;
        Answer: String;

 Begin
    Case DistType of
      Triangular: begin
                    ParmInfo[0]:='Triangular';
                    ParmInfo[1]:='Most Likely';
                    ParmInfo[2]:='Minimum';
                    ParmInfo[3]:='Maximum';
                    ParmInfo[4]:='<unused>';
                  end;
      Normal    : begin
                    ParmInfo[0]:='Normal';
                    ParmInfo[1]:='Mean';
                    ParmInfo[2]:='Std. Deviation';
                    ParmInfo[3]:='<unused>';
                    ParmInfo[4]:='<unused>';
                  end;
      LogNormal : begin
                    ParmInfo[0]:='LogNormal';
                    ParmInfo[1]:='Mean';
                    ParmInfo[2]:='Std. Deviation';
                    ParmInfo[3]:='<unused>';
                    ParmInfo[4]:='<unused>';
                  end;
      Uniform   : begin
                    ParmInfo[0]:='Uniform';
                    ParmInfo[1]:='Minimum';
                    ParmInfo[2]:='Maximum';
                    ParmInfo[3]:='<unused>';
                    ParmInfo[4]:='<unused>';
                 end;
      ElevMap : begin
                    ParmInfo[0]:='Elev. Map';
                    ParmInfo[1]:='R.M.S.E.';
                    ParmInfo[2]:='P. Val.';
                    ParmInfo[3]:='<unused>';
                    ParmInfo[4]:='<unused>';
                 end;
    End; {case}
    Answer := ParmInfo[0]+' Distribution: ';
    If DistType=ElevMap then Answer := 'Elev. Map: ';
    For ParmLoop:=1 to 4 do
       If ParmInfo[ParmLoop] <> '<unused>' then
          Answer := Answer + ParmInfo[ParmLoop]+'='+FloatToStrF(Parm[ParmLoop],ffGeneral,4,4)+'; ';

   Answer[Length(Answer)-1] := '.';
   SummarizeDist := Answer;

end;

function TInputDist.ZMapIndex: Integer;
begin
  If IDNum = 2 then ZMapIndex := 1     //elevation data uncert
               else ZMapIndex := 2;    //NAVD data uncert

end;

Function TInputDist.GetValuePointer(SSN: Integer):PDouble;

Var SS: TSLAMM_Simulation;
    pS: TSubsite;
    AccrNum, AN2: Integer;
    UncertAccr: Integer;
Begin
  uncertaccr := NumRowsAccr - 2;  //delete "use" boolean and notes string

  Result := nil;
  SS := TSS;
  If (IDNum in [1,2,5])
    then pS := nil
    else Begin
           If SSN <= 0 then pS := SS.Site.GlobalSite
                       else pS := SS.Site.SubSites[SSN-1];
         End;

  Case IDNum of
    1: If (Length(SS.CustomSLRArray) > 0) then Result := @SS.CustomSLRArray[0]
                                          else Result := nil;   // SLR.  Note if another global (non subsite) uncert variable is added then logic needs to be updated.  Search on globaluncertlogic and IsSubSite
    2: Result := @Parm[1];  // 'DEM Uncertainty (RMSE in m)';
    3: Result := @pS.Historic_Trend; // 'Historic trend (mm/yr)';  {if no uplift, subsidence map is included}
    4: Result := @pS.NAVD88MTL_correction; // 'NAVD88 - MTL (m)';
    5: Result := @Parm[1];  // 'DEM Uncertainty (RMSE in m)';
    6: Result := @pS.GTideRange; // 'GT Great Diurnal Tide Range (m)';
    7: Result := @pS.SaltElev; // 'Salt Elev. (m above MTL)';
    8: Result := @pS.MarshErosion; // 'Marsh Erosion (horz. m /yr)';
    9: Result := @pS.SwampErosion; // 'Swamp Erosion (horz. m /yr)';
    10: Result := @pS.TFlatErosion; // 'T.Flat Erosion (horz. m /yr)';
    11: Result := @pS.FixedRegFloodAccr; // 'Reg. Flood Marsh Accr (mm/yr)';
    12: Result := @pS.FixedIrregFloodAccr; // 'Irreg. Flood Marsh Accr (mm/yr)';
    13: Result := @pS.FixedTideFreshAccr; // 'Tidal Fresh Marsh Accr (mm/yr)';

    14: Result := @pS.InlandFreshAccr;
    15: Result := @pS.MangroveAccr;
    16: Result := @pS.TSwampAccr;
    17: Result := @pS.SwampAccr;
    18: Result := @pS.Fixed_TF_Beach_Sed; // 'Beach Sed. Rate (mm/yr)';
    19: Result := @pS.WE_Alpha; // Wave erosion Alpha
    20: Result := @pS.WE_Avg_Shallow_Depth; // 'Wave Erosion Avg. Shallow Depth (m)';
    21: Result := @pS.ZBeachCrest; // 'height BeachCrest';
    22: Result := @pS.LBeta; // 'Lagoon Beta';
    23: Result := nil;
    24: Result := nil;
    25: Result := nil;
    26: Result := @pS.IFM2RFM_Collapse; // 'Irreg. Flood Marsh Collapse (mult.)';  // 1/11/2016
    27: Result := @pS.RFM2TF_Collapse; // 'Reg. Flood Marsh Collapse (mult.)';
  End;

  If IDNum>PRE_ACCR then
    Begin
      AccrNum := (IDNum-PRE_ACCR-1) div uncertaccr;
      AN2 := (IDNum-PRE_ACCR-1) mod uncertaccr;
      Case AN2 of
          0: Result := @PS.MaxAccr[AccrNum];
          1: Result := @PS.MinAccr[AccrNum]; // ' Min. Accr. (mm/year)';
          2: Result := @PS.AccrA[AccrNum]; // ' Elev a coeff. (cubic)  mm/(year HTU^3)';
          3: Result := @PS.AccrB[AccrNum]; // ' Elev b coeff. (square) mm/(year HTU^2)';
          4: Result := @PS.AccrC[AccrNum]; // ' Elev c coeff. (linear) mm/(year HTU)';
          5: Result := @PS.AccrC[AccrNum]; // ' Elev d coeff. (intercept)  mm/year';
        End; {case}
    End;

End;

function TInputDist.GetName(IncludeSS: Boolean): String;
begin
  Result := DName;
  if IncludeSS then
     if AllSubSites
          then Result := Result+ ' (All Subsites*)'
          else If SubSiteNum = 0
            then Result := Result+ ' (Global Subsite) '
            else Result := Result+ ' (Subsite '+IntToStr(SubSiteNum)+')';
end;

Function TInputDist.GetValue: Double;
Var pD: PDouble;
    SSN: Integer;
Begin
  if AllSubSites then SSN := 0    // assign to global for now, just used for text output in interface
                 else SSN := SubSiteNum;

  pD := GetValuePointer(SSN);
  Result := PD^;
End;

Procedure TInputDist.SetValues(Multiplier: Double);  // needs to be called multiple times for AllSubSites once no superceding subsite specific distribution has been located
Var pD: PDouble;
begin
  SetLength(PointEsts,TSLAMM_Simulation(TSS).Site.NSubSites+1);

  If SubSiteNum<0 then SubSiteNum := 0;
  If not IsSubSiteParameter then SubSiteNum := 0;  // global

  pD := GetValuePointer(SubSiteNum);
  PointEsts[SubSiteNum] := pD^;
  pD^ := PD^ * Multiplier;
End;

procedure TInputDist.RestoreValues;  // needs to be called multiple times for AllSubSites once no superceding subsite specific distribution has been located
Var pD: PDouble;
begin
  If not IsSubSiteParameter then SubSiteNum := 0; // global

  pD := GetValuePointer(SubSiteNum);
  pD^ := PointEsts[SubSiteNum];
end;


Constructor TUncertDraw.Init(Val,RD:Double;Int:LongInt);
Begin
  Value:=Val;
  IntervalNum:=Int;
  RandomDraw:=Rd;
End;

{      num: Integer;
      Arr: Array of Double; }
(*
Constructor TUserDist.LoadFromFile(FileN: String);

   procedure L_HSort (Left,Right : Integer);         { Lo-Hi QuickSort }
    var Lower,Upper,Middle : Integer;
        Pivot,T            : Double;
    begin
      Lower := Left; Upper := Right; Middle := (Left+Right) div 2;
      Pivot := Arr[Middle];
      repeat
        while Arr[Lower] < Pivot do
          Inc(Lower);
        while Pivot < Arr[Upper] do
          Dec(Upper);
        if Lower <= Upper then
          begin
            T := Arr[Lower]; Arr[Lower] := Arr[Upper];
            Arr[Upper] := T; Inc (Lower); Dec (Upper)
          end;
      until Lower > Upper;
      if Left < Upper then L_HSort (Left, Upper);
      if Lower < Right then L_HSort (Lower, Right)
    end;

Var val: Variant;
    Row: Integer;
    NewVal: Boolean;

Begin
With xlsrdfrm do
Begin

  XLSRead1.FileName := FileN;
  XLSRead1.OpenFile;
  Num := 0;
  SetLength(Arr,5000);

  Row:=0;
  Repeat
    NewVal := XLSRead1.Seek(0,0,Row,Val);

    If NewVal then
      Begin
        Inc(Num);
        If Num>Length(Arr) then SetLength(Arr,Length(Arr)+50);
        Arr[Num-1] := Val;
      End;
    Inc(Row)

  Until Not NewVal;

  L_HSort(0,num-1);

  XLSRead1.CloseFile;

End;
End;

Function TUserDist.CDF(x:Double): Double;
Const Error_Value = -99.9;
Var Index: Integer;
Begin
  CDF := Error_Value;
  If (x<arr[0]) or (x>arr[Num-1]) then exit;

  Index := -1;
  Repeat
    Inc(Index)
  Until Arr[Index] >= x;

  CDF := (Index / Num) + (0.5/Num);
End;

Function TUserDist.ICDF(prob:Double): Double;
Begin
  ICDF := Arr[TRUNC(prob*num)];
End;

*)



{ TSensParam }

Procedure TSensParam.SetValues(Multiplier: Double);
Var top, i: Integer;
    pD: PDouble;

begin
  SetLength(PointEsts,TSLAMM_Simulation(TSS).Site.NSubSites+1);
  If not IsSubsiteParameter then top := 0   // global
                            else top := TSLAMM_Simulation(TSS).Site.NSubSites;
  For i := 0 to top do
    Begin
      pD := GetValuePointer(i);
      PointEsts[i] := pD^;
      pD^ := PD^ * Multiplier;
    End;
End;

procedure TSensParam.RestoreValues;
Var top, i: Integer;
    pD: PDouble;

begin
  If not IsSubsiteParameter then top := 0  // global
                            else top := TSLAMM_Simulation(TSS).Site.NSubSites;
  For i := 0 to top do
    Begin
      pD := GetValuePointer(i);
      pD^ := PointEsts[i];
    End;

end;


end.
