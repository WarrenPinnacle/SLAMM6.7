unit Categories;

interface

Uses Global, Graphics, Classes, Utility;

Type
  TInundRules= Integer;

  TCategory = Class
      GISNumber : SmallInt;
      TextName  : String;
      IsOpenWater: Boolean;  // RiverineTidal..EstuarineOpenWater..OpenOcean
      IsTidal   : Boolean;  // connected to tidal water not in [DevDryLand, UndDryLand,Swamp,InlandFreshMarsh])   e.g. Mangrove,RFM,SS,EB,TF,OB, IFM, OF, OO, EW
      IsNonTidalWetland: Boolean; // subject to soil saturation -- e.g. InlandFreshMarsh, Swamp, CypressSwamp
      IsDryland : Boolean;
      IsDeveloped : Boolean;
      Color : TColor;
      AggCat: AggCategories;

      UseIFMCollapse, UseRFMCollapse: Boolean;
      UseWaveErosion: Boolean;
      ErodeModel: ErosionInputs;
      AccrModel: AccrModels;

      InundateTo: Integer;  //category
      NInundRules: Integer;
      InundRules: Array of TInundRules;

      ErodeTo: Integer;

      ElevDat   : ClassElev;  //low high bounds
      ElevationStats: packed array of TElevStats;

      SalRules : Boolean;
      SalinityRules : TSalinityRules;
      HasSalStats : Boolean;
      SalinityStats : TSalStats;

      mab: Double;   // Aboveground biomass per unit area (Dry Matter 10^3 Kg/ha) – [0 - 41]
      Rsc: Double;   // Soil carbon storage rate for specified habitat type (10^3 Kg C/ha/year) – Range [0 – 0.35]
      ECH4: Double;  // Methane emission rate (10^3 Kg CH4/ha/year) - Range [0 – 0.194]
      CSeqNotes: String; // reference

      { -------------NO LOAD OR SAVE------------------------------------------------- }
      PSS: Pointer; // pointer to TSLAMM_Simulation

      Function InundCat(PIC: Pointer): Integer;
      Function TextInundRule(NR: Integer): String;
      Constructor Create(SS: Pointer);
      Constructor Load(SS:Pointer; ReadVersionNum: Double; TS: TStream); overload;
      Procedure Store(var TS: TStream); overload;
      Destructor Destroy; override;

    End;

  PCategories = ^TCategories;
  TCategories = Class
    NCats: Integer;
    Cats : Array of TCategory;

    DevDryLand, UndDryLand, FloodDevDryLand, OpenOcean, EstuarineWater: Integer;  // categories required for flooded developed dry land, and memory optimization

    { -------------NO LOAD OR SAVE------------------------------------------------- }
    BlankCat: TCategory;
    PSS: Pointer; // pointer to TSLAMM_Simulation
    Function GetCat(Num: Integer) : TCategory;
    Constructor Create(SS: Pointer);
    Constructor Load(SS:Pointer; ReadVersionNum: Double; TS: TStream); overload;
    Procedure ClearCats;
    Procedure Store(var TS: TStream); overload;
    Destructor Destroy; override;
    Procedure SetupSLAMMDefault;
    Function  AreCalifornia: Boolean;
    Procedure SetupCADefault;
    Procedure SetCSeqDefaults(CA: Boolean);
    Procedure WriteTechSpecs;
  end;



(*
  Classic SLAMM Categories =
   ( DevDryland,  	    {0 1 U	                         Upland}
     UndDryland,	      {1 2 U	                         Upland  - default; these two will have to be distinguished using census or land use data (protection)}
     Swamp,	            {2 3 PFO, PFO1, PFO3-5, PSS           Palustrine forested broad-leaved deciduoua}
     CypressSwamp,	    {3 4 PFO2	                           Ditto, needle-leaved deciduous}
     InlandFreshMarsh,  {4 5 L2EM,PEM[1&2]["A"-"I"],R2EM      Lacustrine, Palustrine, and Riverine emergent}
     TidalFreshMarsh,	  {5 6 R1EM,PEM["K"-"U"]                Riverine tidal emergent}
     ScrubShrub,        {6 7 E2SS1, E2FO                      Estuarine intertidal scrub-shrub broad-leaved deciduous}
     RegFloodMarsh,	    {7 8 E2EM [no "P"]                    Estuarine intertidal emergent [won't distinguish high and low marsh]}
     Mangrove,	        {8 9 E2FO3, E2SS3                     Estuarine intertidal forested and scrub-shrub broad-leaved evergreeen}
     EstuarineBeach,	  {09 10 E2US2 or E2BB (PUS"K")           Estuarine intertidal unconsolidated shore sand or beach-bar}
     TidalFlat,	        {10 11 E2US3or4, E2FL, M2AB             Estuarine intertidal unconsolidated shore mud/organic or flat, Intertidal Aquatic Bed here for now}
     OceanBeach,	      {11 12 M2US2, M2BB/UB/USN               Marine intertidal unconsolidated shore sand}
     OceanFlat,	        {12 13 M2US3or4                         Marine intertidal unconsolidated shore mud or organic}
     RockyIntertidal,	  {13 14  M2RS, E2RS, L2RS                 Estuarine & Marine intertidal rocky shore}
     InlandOpenWater,   {14 15 R3-UB R2-5OW,L1-2OW,POW,PUB,R2UB
                            (L1-2,UB,AB), PAB, R2AB          Riverine, Lacustrine, and Palustrine open water}
     RiverineTidal,     {15 16 R1OW	                           Riverine tidal open water}
     EstuarineWater,    {16 17 E1, (PUB"K" no "h")              Estuarine subtidal}
     TidalCreek,	      {17 18 E2SB, E2UBN,                     Estuarine intertidal stream bed}
     OpenOcean,         {18 19 M1                               Marine subtidal  [aquatic beds and reefs can be added later]}
     IrregFloodMarsh,   {19 20 E2EM[1-5]P                       "P" Irregularly Flooded Estuarine Intertidal Emergent}
     InlandShore,       {20 22 L2UD,PUS, R[1..4]US/RS           shoreline not pre-processed using Tidal Range Elevations}
     TidalSwamp,        {21 23 PSS,PFO"K"-"V" /EM1"K"-"V"       Tidally influenced Swamp. }
     FloodDevDryLand,   {22 25 Flooded Developed Dry Land}
     FloodForest);      {23 26 Flooded Cypress Swamp }
*)


implementation

Uses SLR6, Dialogs, SysUtils;
{ TCategory }

constructor TCategory.Create(SS: Pointer);
var i: Integer;
begin
    PSS := SS;
    GISNumber := -99;
    TextName  := 'Blank';
    IsOpenWater:= False;
    IsTidal   := False;
    IsNonTidalWetland := False;
    IsDryland := False;
    IsDeveloped := False;
    Color := clWhite;
    AggCat:=  AggBlank;
    UseIFMCollapse := False; UseRFMCollapse:= False;
    UseWaveErosion:= False;
    ErodeModel:= ENone;
    AccrModel := AccrNone;
    InundateTo := -99;
    NInundRules := 0;
    InundRules := nil;
    ErodeTo := -99;
    ElevationStats := nil;
    SalRules := False;
    SalinityRules := nil;
    HasSalStats := False;
    For i := 1 to Num_Sal_Metrics do
      SalinityStats.N[i] := 0;

    With ElevDat do
         Begin
           MinUnit := Meters;
           MinElev := 0;
           MaxUnit := Meters;
           MaxElev := 0;
         End;

end;

destructor TCategory.Destroy;
begin
  InundRules := nil;
  SalinityRules := nil;
  inherited;
end;



function TCategory.InundCat(PIC: Pointer ): Integer;

Var TSS: TSLAMM_Simulation;
    PInundContext: ^TInundContext;

    {--------------------------------------------------------------------}
    Function AdjCell(Var AdjRow,AdjCol: Integer; Lee: Boolean): Boolean;

    {********************************************}
    {* Return adjacent cell to lee if Lee=True  *}
    {* AdjRow and AdjCol are inputs and outputs *}
    {* Function False if out-of-bounds          *}
    {* JClough, December 2005 (adds modularity) *}
    {* True: move opposite of offshore          *}
    {********************************************}
    Var Step: Integer;
    Begin
      If Lee then Step := -1
             else Step :=  1;

      Case PInundContext^.SubS.Direction_OffShore of
         Westerly : AdjCol := AdjCol - Step;
         Easterly : AdjCol := AdjCol + Step;
         Northerly: AdjRow := AdjRow - Step;
         Southerly: AdjRow := AdjRow + Step;
        End; {Case}

      AdjCell := (AdjRow>=0) and (AdjCol>=0) and
                 (AdjRow<TSS.Site.RunRows) and (AdjCol<TSS.Site.RunCols);
    End;
    {--------------------------------------------------------------------}
    Function OceanNearer: Boolean;  {which is nearer, ocean or estuary?}
    Var i: Integer;
        LeeR,LeeC: Integer;
        C2: CompressedCell;
    Begin
      OceanNearer := True;
      If PInundContext^.EWCat = Blank then Exit;
      LeeR := PInundContext^.CellRow; LeeC := PInundContext^.CellCol;
      With PInundContext^ do
       For i := 0 to Trunc(DistancetoOpenSaltWater/TSS.Site.RunScale)+1 do
        If AdjCell(LeeR,LeeC,False) then
          Begin
            TSS.RetA(LeeR,LeeC,C2);
            If CellWidth(@C2,EWCat) > 0 then OceanNearer := False;
          End;
    End;
    {--------------------------------------------------------------------}

    Procedure ParseCategoryRules;
    Var Res, i: Integer;

    Begin
      Res := Result;
      For i:= 0 to NInundRules-1 do
       With TSS do With PInundContext^ do
       If Res=Result then // stop checking once a primary rule has been implemented, secondary rule should be considered "else"
         Case InundRules[i] of
          1: If ProtectAll then Result := -99;
          2: If ProtectDeveloped then Result := -99;
          3: If TSS.UseFloodDevDryLand then Result := 22;   // Use Flooded Development
          4: If AdjOcean and OceanNearer Then Result := 11;
          5: If AdjWater and (Erosion2>=20) Then Result := 9;
          6: If Tropical and NearWater then Result := 8;
          7: If CellFwInfluenced then Result := 21;
          8: If Tropical then Result := 8;
          9: If AdjOcean then Result := 18;
          10: If CellFWInfluenced then Result := 5;
          11: If (CatElev >= LowerBound(19,SubS)) then Result := 19;         //6.23.2011 Potentially convert tidal fresh marsh directly to IFM or salt marsh depending on elevation relative to those classes
          12: If (CatElev >= LowerBound(7,SubS)) then Result := 7;
          13: If UseFloodForest then Result := 23;

          14: If TSS.UseFloodDevDryLand then Result := 27;   // Use Flooded Development
          15: If AdjOcean and OceanNearer Then Result := 18;
          16: If CellFwInfluenced then Result := 12; //TS
          17: If CellFwInfluenced then Result := 13; //TFM
          18: If (CatElev >= LowerBound(14,SubS)) then Result := 14;         //6.23.2011 Potentially convert tidal fresh marsh directly to IFM
          19: If (CatElev >= LowerBound(19,SubS)) then Result := 19;       // or to RFM
          20: If AdjOcean then Result := 26;
          21: If AdjEFSW then Result := 15;

         End; {case}
    End;

    {--------------------------------------------------------------------}
begin
  TSS := PSS;
  PInundContext := PIC;
  Result := InundateTo;
  If NInundRules>0 then ParseCategoryRules;
end;



Function TCategory.TextInundRule(NR: Integer): String;
Begin
  Case InundRules[NR-1] of
    1: Result := 'Do not inundate if Protect All Dry Land is selected.  ';
    2: Result := 'Do not inundate if Protect Developed Dry Land is selected.  ';
    3: Result := 'If "Use Flooded Developed" is selected then inundate to flooded developed dry land.  ';
    4: Result := 'If "AdjOcean" and ocean water is nearer than estuarine water then convert to ocean beach.  ';
    5: Result := 'If "AdjWater" with a fetch > 20 km then inundate to estuarine beach.  ';
    6: Result := 'If site is designated as tropical and cell is "NearWater" then inundate to mangrove.  ';
    7: Result := 'If the cell is "fresh water influenced" then convert to tidal swamp.  ';
    8: Result := 'If site is designated as tropical then inundate to mangrove.  ';
    9: Result := 'If "AdjOcean" then inundate to open ocean.  ';
    10: Result := 'If the cell is "fresh water influenced" then inundate to tidal fresh marsh.  ';
    11: Result := 'If the cell elevation is above than the lower bound for irregularly-flooded marsh then convert to transitional marsh.  ';
    12: Result := 'If the cell elevation is above than the lower bound for regularly-flooded marsh then convert to regularly-flooded.  ';
    13: Result := 'If "Use Flooded Forest" is selected then inundate to "flooded forest."  ';

    14: Result := 'If "Use Flooded Developed" is selected then inundate to flooded developed dry land.  ';
    15: Result := 'If "AdjOcean" and ocean water is nearer than estuarine water then convert to ocean beach.  ';
    16: Result := 'If the cell is "fresh water influenced" then convert to tidal forested/shrub.  ';
    17: Result := 'If the cell is "fresh water influenced" then inundate to tidal fresh marsh.  ';
    18: Result := 'If the cell elevation is above than the lower bound for irregularly-flooded marsh then convert to irregularly-flooded marsh. ';
    19: Result := 'If the cell elevation is above than the lower bound for regularly-flooded marsh then convert to regularly-flooded.  ';
    20: Result := 'If "AdjOcean" then inundate to open ocean.  ';
    21: Result := 'If the cell is "Adjacent to Estuarine forested/shrub wetland," then convert to that category.  ';
  End; {case}
End;



Procedure LoadElevRangesFromText(Var TCA: ClassElev);
Var UnitStr: String;

    Function Str2Unit(UStr: String): ElevUnit;
    Begin
      UStr := Lowercase(UStr);
      If Pos(UStr,'halftide')>0 then Result := HalfTide
         else If Pos(UStr,'saltbound')>0 then Result := SaltBound
         else Result := Meters;
    End;

Begin
    TSRead('MinElev',TCA.MinElev);
    TSRead('MinUnit',UnitStr,999);
    TCA.MinUnit := Str2Unit(UnitStr);

    TSRead('MaxElev',TCA.MaxElev);
    TSRead('MaxUnit',UnitStr,999);
    TCA.MaxUnit := Str2Unit(UnitStr);
End;
{-----------------------------------------------------------------------------}

Procedure SaveElevRangesToText(TCA: ClassElev);
Var UnitStr: String;

    Function Unit2Str(EU:ElevUnit): String;
    Begin
      Case EU of
        HalfTide: Result :='HalfTide';
        SaltBound: Result := 'SaltBound';
        else Result := 'Meters';
      end; {case}
    End;

Begin
    TSWrite('MinElev',TCA.MinElev);
    UnitStr := Unit2Str(TCA.MinUnit);
    TSWrite('MinUnit',UnitStr);

    TSWrite('MaxElev',TCA.MaxElev);
    UnitStr := Unit2Str(TCA.MaxUnit);
    TSWrite('MaxUnit',UnitStr);
End;




constructor TCategory.Load(SS: Pointer; ReadVersionNum: Double; TS: TStream);
Var i, AMI, ACI, EMI, GISN: Integer;
    TC: Int32;
begin
  PSS := SS;
  TSRead('GISNumber',GISN);
  GISNumber := GISN;

  TSRead('TextName',TextName,ReadVersionNum);
  TSRead('IsOpenWater',IsOpenWater);
  TSRead('IsTidal',IsTidal );
  TSRead('IsNonTidalWetland',IsNonTidalWetland);
  TSRead('IsDryland',IsDryland);

  TSRead('IsDeveloped',IsDeveloped);

  TSRead('Color',TC);
  Color := TColor(TC);

  TSRead('AggCat',ACI);
      AggCat := AggCategories(ACI);

  TSRead('UseIFMCollapse',UseIFMCollapse);
  TSRead('UseRFMCollapse',UseRFMCollapse);
  TSRead('UseWaveErosion',UseWaveErosion);

  TSRead('ErodeModel',EMI);
      ErodeModel := ErosionInputs(EMI);

  TSRead('AccrModel',AMI);
      AccrModel := AccrModels(AMI);

  TSRead('InundateTo',InundateTo);
  TSRead('NInundRules',NInundRules);

  Setlength(InundRules,NInundRules);
  For i:= 0 to NInundRules-1 do
    TSRead('InundRules[i]',InundRules[i]);

  TSRead('ErodeTo',ErodeTo);

  If TSText then LoadElevRangesFromText(ElevDat)
    else TS.Read(ElevDat, Sizeof(ElevDat));

  ElevationStats := nil;
  If TSLAMM_Simulation(SS).Init_ElevStats then
   setlength(ElevationStats,TSLAMM_Simulation(SS).NElevStats);
    For i := 0 to TSLAMM_Simulation(SS).NElevStats-1 do
     If not TSText then TS.Read(ElevationStats[i],16664);   // size prescribed for 32 & 64 bit compatibility

  TSRead('SalRules',SalRules);
  If SalRules then SalinityRules.Load(ReadVersionNum,TS);
  TSRead('HasSalStats',HasSalStats);
  If HasSalStats then If not TSText then TS.Read(SalinityStats,Sizeof(SalinityStats));

  mab := 0; Rsc := 0; ECH4 := 0; CseqNotes := '';

  If ReadVersionNum > 6.975 then
    Begin
      TSRead('mab' ,mab);
      TSRead('Rsc' ,Rsc);
      TSRead('ECH4',ECH4);
      TSRead('CSeqNotes',CSeqNotes,ReadVersionNum);
    End;
end;

procedure TCategory.Store(var TS: TStream);
Var i, AMI, ACI, EMI, GISN: Integer;
    TC: Int32;
begin
  GISN := GISNumber;
  TSWrite('GISNumber',GISN);
  TSWrite('TextName',TextName);
  TSWrite('IsOpenWater',IsOpenWater);
  TSWrite('IsTidal',IsTidal );
  TSWrite('IsNonTidalWetland',IsNonTidalWetland);
  TSWrite('IsDryland',IsDryland);

  TSWrite('IsDeveloped',IsDeveloped);

  TC := Color;
    TSWrite('Color',TC);

  ACI := ORD(AggCat);
    TSWrite('AggCat',ACI);
  TSWrite('UseIFMCollapse',UseIFMCollapse);
  TSWrite('UseRFMCollapse',UseRFMCollapse);
  TSWrite('UseWaveErosion',UseWaveErosion);

  EMI := ORD(ErodeModel);
    TSWrite('ErodeModel',EMI);
  AMI := ORD(AccrModel);
    TSWrite('AccrModel',AMI);

  TSWrite('InundateTo',InundateTo);
  TSWrite('NInundRules',NInundRules);

  For i:= 0 to NInundRules-1 do
    TSWrite('InundRules[i]',InundRules[i]);

  TSWrite('ErodeTo',ErodeTo);

  If TSText then SaveElevRangestoText(ElevDat)
    else TS.Write(ElevDat, Sizeof(ElevDat));

  If TSLAMM_Simulation(PSS).Init_ElevStats then
   For i:= 0 to TSLAMM_Simulation(PSS).NElevStats-1 do
    If not TSText then TS.Write(ElevationStats[i],16664);  // size prescribed for 32 & 64 bit compatibility

  TSWrite('SalRules',SalRules);
  If SalRules then SalinityRules.Store(TS);
  TSWrite('HasSalStats',HasSalStats);
  If HasSalStats then If not TSText then TS.Write(SalinityStats,Sizeof(SalinityStats));

  TSWrite('mab' ,mab);
  TSWrite('Rsc' ,Rsc);
  TSWrite('ECH4',ECH4);
  TSWrite('CSeqNotes',CSeqNotes);

end;

{ TCategories }

procedure TCategories.ClearCats;
Var i: integer;
begin
  For i := 0 to NCats-1 do
    Cats[i].Destroy;
  Cats := nil;
end;

constructor TCategories.Create(SS: Pointer);
begin
    PSS := SS;
    NCats:= 0;
    Cats := nil;
    BlankCat:= TCategory.Create(SS);
end;

destructor TCategories.Destroy;
Begin
  ClearCats;
  BlankCat.Destroy;
  inherited;
end;

function TCategories.GetCat(Num: Integer): TCategory;
begin
  If Num < 0     then Result := BlankCat
                 else Result := Cats[num];
end;

constructor TCategories.Load(SS: Pointer; ReadVersionNum: Double; TS: TStream);
Var i: Integer;
begin
  BlankCat:= TCategory.Create(SS);
  PSS := SS;

  TSRead('NCats',NCats);
  SetLength(Cats,NCats);
  For i := 0 to NCats-1 do
    Cats[i] := TCategory.Load(SS,ReadVersionNum,TS);

  TSRead('DevDryLand',DevDryLand);
  TSRead('UndDryLand',UndDryLand);
  TSRead('FloodDevDryLand',FloodDevDryLand);
  TSRead('OpenOcean',OpenOcean);
  TSRead('EstuarineWater',EstuarineWater);

  If ReadVersionNum < 6.975 then SetCSeqDefaults(AreCalifornia);
end;

procedure TCategories.Store(var TS: TStream);
Var i: Integer;
begin
  TSWrite('NCats',NCats);
  SetLength(Cats,NCats);
  For i := 0 to NCats-1 do
    Cats[i].Store(TS);

  TSWrite('DevDryLand',DevDryLand);
  TSWrite('UndDryLand',UndDryLand);
  TSWrite('FloodDevDryLand',FloodDevDryLand);
  TSWrite('OpenOcean',OpenOcean);
  TSWrite('EstuarineWater',EstuarineWater);
end;

procedure TCategories.SetupCADefault;
Type CAGridColorType = ARRAY[0..27] OF TColor;

Const
  CAGISNums : Array[0..27] of SMALLInt
    = (101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128);

  CATitleCat   : ARRAY[0..27] OF STRING
{0}    =('Developed Dry Land',
{1}      'Undeveloped Dry Land',
{2}      'Agriculture',
{3}      'Artificial Pond',
{4}      'Artificial Salt Pond',
{5}      'Inland Open Water',
{6}      'Inland Shore',
{7}      'Freshwater Marsh',
{8}      'Seasonal Freshwater Marsh',
{9}      'Seasonally Flooded Agriculture',
{10}      'Dunes',
{11}      'Freshwater Forested/Shrub',
{12}      'Tidal Freshwater Forested/Shrub',
{13}      'Tidal Fresh Marsh',
{14}      'Irreg.-Flooded Marsh',
{15}      'Estuarine forested/shrub wetland',
{16}      'Artificial reef',
{17}      'Invertebrate reef',
{18}      'Ocean Beach',
{19}      'Regularly-flooded Marsh',
{20}      'Rocky Intertidal',
{21}      'Tidal Flat and Salt Panne',
{22}      'Riverine (open water)',
{23}      'Riverine Tidal',
{24}      'Tidal Channel',
{25}      'Estuarine Open Water',
{26}      'Open Ocean',
{27}      'Flooded Developed');

  CADefaultGridColors: CAGridColorType
   = ($002D0398 {CldarkMaroon},    {DevDryland}   // 0
      $00002BD5, {ClMaroon} {UndDryland}          // 1
      ClBlack,  //'Agriculture',
      $00FF9797,  {Artifical Pond}
      $00FF8484,  {Artifical Salt Pond}
      $00FFA8A8,{InlandOpenWater} {gray blue}
      $00004080,{Inland Shore is Brown}
      ClLime,   {Freshwater Marsh}
      $00CA56BB,   {Seasonal Freshwater Marsh}  // pinkish
      $00484848,  // 'Seasonally Flooded Agriculture' charcoal
      $0000DDDD, // 'Dunes', darker yellow                     //10
      $00226a1d, // 'Freshwater Forested/Shrub', dark green    //11
      $0034e37d, //'Tidal Freshwater Forested/Shrub',          //12
      $00cde7a5, // 'Tidal Fresh Marsh',                       //13
      $000D5CD1, // 'Irreg.-Flooded Marsh',                    //14
      $00008888, // 'Estuarine forested/shrub wetland', olive
      clpurple, // 'Artificial reef',
      clpurple,  // 'Invertebrate reef',
      clyellow, // 'Ocean Beach',
      $00A6A600, //'Regularly-flooded Marsh',
      $00FF80FF, //'Rocky Intertidal',
      ClSilver, //'Tidal Flat and Salt Panne',
      $00ff8913, // 'Riverine (open water)',
      clnavy, // 'Riverine Tidal',
      clnavy, // 'Tidal Channel',
      Clblue, // 'Estuarine Open Water',
      clnavy, // 'Open Ocean'
      $00FF64B1 ); // Flooded Developed

Var i: integer;
begin
  ClearCats;
  NCats := 28;
  SetLength(Cats,NCats);
  For i := 0 to NCats-1 do
   Begin
      Cats[i] := TCategory.Create(PSS);
      Cats[i].GISNumber := CAGISNums[i];
      Cats[i].TextName := CATitleCat[i];
      Cats[i].Color := CADefaultGridColors[i];

      If i in [21..26] then Cats[i].IsOpenWater := True;
      If i in [12..21,23..26] then Cats[i].IsTidal := True;
      If i in [7,8,11] then Cats[i].IsNonTidalWetland := True;
      If i in [0,1,2] then  Cats[i].IsDryLand := True;
      If i in [0,27] then  Cats[i].IsDeveloped := True;

      If i in [0,1,2,10] then Cats[i].AggCat := NonTidal;
      If i in [3,5,6,7,8,9,11] then Cats[i].AggCat := FreshNonTidal;
      If i in [4,22..26] then Cats[i].AggCat := OpenWater;
      If i in [16,17,18,20..21] then Cats[i].AggCat := LowTidal;
      If i =19 then Cats[i].AggCat := SaltMarsh;
      If i in [14,15,27] then Cats[i].AggCat := Transitional;
      If i in [12,13] then Cats[i].AggCat := FreshWaterTidal;

      If i in [14,15] then Cats[i].UseIFMCollapse := True;
      If i = 19 then Cats[i].UseRFMCollapse := True;
      If i in [13,19,14] then Cats[i].UseWaveErosion := True;

      If i = 19        then Cats[i].AccrModel := RegFM;
      If i in [14,15]  then Cats[i].AccrModel := IrregFM ;
      If i in [18,21]  then Cats[i].AccrModel := BeachTF;
      If i = 13        then Cats[i].AccrModel := TidalFM;
      If i in [7,8]    then Cats[i].AccrModel := InlandM;
      If i = 12        then Cats[i].AccrModel := TSwamp;
      If i in [11]     then Cats[i].AccrModel := Swamp;

      If i in [13,14,19] then Begin Cats[i].ErodeModel := EMarsh;   Cats[i].ErodeTo := 25; End;  // erode to estuarine water
      If i in [11,12,15] then Begin Cats[i].ErodeModel := ESwamp;   Cats[i].ErodeTo := 21; End;  // erode to tidal flat
      If i = 21          then Begin Cats[i].ErodeModel := ETFlat;   Cats[i].ErodeTo := 25; End;  // erode to estuarine water
      If i = 18          then Begin Cats[i].ErodeModel := EOcBeach; Cats[i].ErodeTo := 26; End;

      With Cats[i] do
       Case i of
        0: {DevDryLand} InundateTo := 14 ; // Irreg-flood marsh
        1: {UndDryLand} InundateTo := 14 ; // Irreg-flood marsh
        2: {Agriculture} InundateTo := 14 ; // Irreg-flood marsh
        3: {Artificial Pond} InundateTo := 25;  // Estuarine Open Water
        4: {Artificial Salt Pond} InundateTo := 25;  // Estuarine Open Water
        5: {Inland Open Water} InundateTo := 25;  // Estuarine Open Water
        6: {Inland Shore} InundateTo := 25;  // Estuarine Open Water
        7: {Freshwater Marsh} InundateTo := 14 ; // Irreg-flood marsh
        8: {Seasonal Freshwater Marsh} InundateTo := 14 ; // Irreg-flood marsh
        9: {Seasonally Flooded Agriculture} InundateTo := 14 ; // Irreg-flood marsh
        10:{Dunes} InundateTo := 18;  // ocean beach
        11:{Freshwater Forested/Shrub} InundateTo := 15; //Estuarine forested/shrub
        12:{Tidal Freshwater Forested/Shrub} InundateTo := 14 ; // Irreg-flood marsh
        13:{Tidal Fresh Marsh} InundateTo := 21 ; //tidal flat
        14:{Irreg.-Flooded Marsh} InundateTo := 19; //RFM
        15:{Estuarine forested/shrub wetland} InundateTo := 19; //RFM
        16:{Artificial reef} InundateTo := 25;  // Estuarine Open Water
        17:{Invertebrate reef} InundateTo := 25;  // Estuarine Open Water
        18:{Ocean Beach} InundateTo := 26; //open ocean
        19:{Regularly-flooded Marsh} InundateTo := 21 ; //tidal flat
        20:{Rocky Intertidal} InundateTo := 25;  // Estuarine Open Water
        21:{Tidal Flat and Salt Panne} InundateTo := 25;  // Estuarine Open Water
        22:{Riverine (open water)} InundateTo := 23;  // Riverine Tidal
        23:{Riverine Tidal} InundateTo := Blank;
        24:{Tidal Channel} InundateTo := Blank ;
        25:{Estuarine Open Water} InundateTo := Blank;
        26:{Open Ocean} InundateTo := Blank ;
        27:{FloodedDeveloped} InundateTo := Blank;
      end; {case}

      Cats[i].NInundRules := 0;
      With Cats[i] do
       Case i of
        0: {DevDryland}  NInundRules := 6;
        1,2: {UndDryland} NInundRules := 4; // also ag
        9:   NInundRules := 3; // seasonal ag
        7,8: {FreshMarsh}  NInundRules := 1;
        11: {fresh forest} NInundRules := 1;
        12:{Tidal Freshwater Forested/Shrub} NInundRules := 1 ;
        13:{Tidal Fresh Marsh} NInundRules := 2 ;
        20:{Rocky Intertidal} NInundRules := 1;
      end; {case}

      With Cats[i] do SetLength(InundRules,NInundRules);

      With Cats[i] do
      Case i of
        0: Begin InundRules[0] := 1;   // devdryland
                 InundRules[1] := 2;
                 InundRules[2] := 14;
                 InundRules[3] := 15;
                 InundRules[4] := 16;  End;
        1,2,9: Begin InundRules[0] := 1;  //unddryland, agricultural, seasonal ag
                     InundRules[1] := 15;
                     InundRules[2] := 16; End;
        7,8: {InlandMarsh}  InundRules[0] := 17;
        11: {Fresh Forest}   InundRules[0] := 16;
        12: {Tidal Freshwater Forested} InundRules[0] := 17;
        13: {Tidal Fresh Marsh} Begin InundRules[0] := 18;
                                      InundRules[1] := 19; End;

        20:{Rocky Intertidal}     InundRules[0] := 20;
      end; {case}


    With Cats[i].ElevDat do
     Begin
      If not Cats[i].IsTidal then
                             Begin  {Only "correct" cells that have initial conditions below the salt boundary due to low precision DEM}
                               MinUnit := SaltBound;
                               MinElev := 1.0;
                               MaxUnit := Meters;
                               MaxElev := 3.048;  {assumes 10 foot contour}
                             End;

      if i=19 then            Begin // Regflood marsh
                               MinUnit := Meters;
                               MinElev := 0;
                               MaxUnit := HalfTide;
                               MaxElev := 1.2;
                             End;

      If i=14 then           Begin // IrregFloodMarsh
                               MinUnit := HalfTide;
                               MinElev := 0.5;
                               MaxUnit := SaltBound;
                               MaxElev := 1.0;
                             End;
      If i=15 then           Begin  // {Estuarine forested/shrub wetland}
                               MinUnit := HalfTide;
                               MinElev := 1.0;
                               MaxUnit := SaltBound;
                               MaxElev := 1.0;
                             End;
      if i = 21       then   Begin //  Tidalflat / panne
                               MinUnit := HalfTide;
                               MinElev := -1.0;
                               MaxUnit := Meters;
                               MaxElev := 0;
                             End;


      if i in [16,17,18,20] then //  {Artificial reef}  {Invertebrate reef} {Ocean Beach}  {Rocky Intertidal}
                             Begin
                               MinUnit := HalfTide;
                               MinElev := -1.0;
                               MaxUnit := SaltBound;
                               MaxElev := 1.0;
                             End;

      If i=12 then           Begin  // {Tidal Freshwater Forested/Shrub} // can persist down to very low elevation in absence of salinity
                               MinUnit := HalfTide;
                               MinElev := 0;
                               MaxUnit := SaltBound;
                               MaxElev := 1.0;
                             End;
      If i=13 then           Begin  // {Tidal Fresh Marsh} // can persist down to very low elevation in absence of salinity
                               MinUnit := HalfTide;
                               MinElev := 0;
                               MaxUnit := SaltBound;
                               MaxElev := 1.0;
                             End;


     End; {With}
   End; // For i := 0 to NCats-1

  DevDryLand := 0;
  UndDryLand := 1;
  FloodDevDryLand := 27;
  OpenOcean := 26;
  EstuarineWater := 25;  // categories required for flooded developed dry land, and memory optimization

  SetCSeqDefaults(True);
end;


{--------------------------------------------------------------------------------------------------------------------------------}


{--------------------------------------------------------------------------------------------------------------------------------}


procedure TCategories.SetupSLAMMDefault;

Type GridColorType = ARRAY[0..23] OF TColor;

Const
  GISNums : Array[0..23] of SMALLInt
    = (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,25,26);

  TitleCat   : ARRAY[0..23] OF STRING
    =('Developed Dry Land','Undeveloped Dry Land','Swamp','Cypress Swamp','Inland-Fresh Marsh',
      'Tidal-Fresh Marsh','Trans. Salt Marsh','Regularly-Flooded Marsh','Mangrove','Estuarine Beach',
      'Tidal Flat','Ocean Beach','Ocean Flat','Rocky Intertidal','Inland Open Water',
      'Riverine Tidal','Estuarine Open Water','Tidal Creek','Open Ocean','Irreg.-Flooded Marsh',
      'Inland Shore','Tidal Swamp','Flooded Developed Dry Land','Flooded Forest');

  DefaultGridColors: GridColorType
   = ($002D0398 {ClMaroon},    {DevDryland}
      $00002BD5 {ClMaroon}, {UndDryland}
      ClGreen,  {Swamp}
      $00005500, {CLWhite,  }{CypressSwamp}  {Darker Green}
      ClLime,   {InlandFreshMarsh}
      $00A4FFA4,{TidalFreshMarsh} {Lighter Green}
      ClOlive,  {TransitionSaltmarsh} {Lighter Teal}
      $00A6A600,{Regularly flooded Saltmarsh }
      ClPurple, {Mangrove}
      $00B3FFFF,{EstuarineBeach}
      ClSilver, {TidalFlat}
      ClYellow, {OceanBeach}  {Lighter Yellow}
      $000059B3,{OceanFlat}   {Light Brown}
      $00FF80FF,{RockyIntertidal} {pink}
      $00FFA8A8,{InlandOpenWater} {light blue}
      ClBlue,   {RiverineTidalOpenWater}
      ClBlue,   {EstuarineWater}
      ClBlue,   {TidalCreek}
      ClNavy,   {OpenOcean}
      $004080FF,{Irregularly Flooded Brackish Marsh is Orange}
      $00004080,{Inland Shore is Brown}
      $00003E00,{Tidal Swamp is very dark green, almost black}
      $00FF64B1, {Flood Dev Dry Land is purple}
      $0075D6FF); {FloodForest is light orange, between dry land and beach}

Var i,j: integer;
begin
  ClearCats;
  NCats := 24;
  SetLength(Cats,NCats);
  For i := 0 to NCats-1 do
   Begin
      Cats[i] := TCategory.Create(PSS);
      Cats[i].GISNumber := GISNums[i];
      Cats[i].TextName := TitleCat[i];
      Cats[i].Color := DefaultGridColors[i];
      If i in [14..18] then Cats[i].IsOpenWater := True;
      If i in [5..13,15..23] then Cats[i].IsTidal := True;
      If i in [2..4] then Cats[i].IsNonTidalWetland := True;
      If i in [0,1] then  Cats[i].IsDryLand := True;
      If i in [0,22] then  Cats[i].IsDeveloped := True;

      If i in [0,1,22] then Cats[i].AggCat := NonTidal;
      If i in [2..4,20] then Cats[i].AggCat := FreshNonTidal;
      If i in [14..18] then Cats[i].AggCat := OpenWater;
      If i in [9..13] then Cats[i].AggCat := LowTidal;
      If i =7 then Cats[i].AggCat := SaltMarsh;
      If i in [6,8,19,23] then Cats[i].AggCat := Transitional;
      If i in [5,21] then Cats[i].AggCat := FreshWaterTidal;

      If i in [6,19] then Cats[i].UseIFMCollapse := True;
      If i = 7 then Cats[i].UseRFMCollapse := True;
      If i in [5,6,7,19] then Cats[i].UseWaveErosion := True;

      If i = 7        then Cats[i].AccrModel := RegFM;
      If i in [6,19]  then Cats[i].AccrModel := IrregFM;
      If i in [9..12] then Cats[i].AccrModel := BeachTF;
      If i = 5        then Cats[i].AccrModel := TidalFM;
      If i = 4        then Cats[i].AccrModel := InlandM;
      If i = 8        then Cats[i].AccrModel := Mangrove;
      If i = 21       then Cats[i].AccrModel := TSwamp;
      If i in [2,3]   then Cats[i].AccrModel := Swamp;

      If i in [5,6,7,19] then Begin Cats[i].ErodeModel := EMarsh; Cats[i].ErodeTo := 16; End;  // erode to estuarine water
      If i in [2,3,8,21] then Begin Cats[i].ErodeModel := ESwamp; Cats[i].ErodeTo := 10; End;  // erode to tidal flat
      If i in [9,10,12]  then Begin Cats[i].ErodeModel := ETFlat; Cats[i].ErodeTo := 16; End;
      If i =11           then Begin Cats[i].ErodeModel := EOcBeach; Cats[i].ErodeTo := 18; End;
      If i = 3           then Cats[i].ErodeTo := 16;  // cypress swamp erodes to open water

      With Cats[i] do
      Case i of
        0: {DevDryland}  InundateTo := 6; //6 = transitional marsh
        1: {UndDryland}  InundateTo := 6;
        2: {Swamp}  InundateTo := 6;
        3: {CypressSwamp}  InundateTo := 16; // 16 = EstuarineWater
        4: {InlandFreshMarsh}  InundateTo := 6;
        5: {TidalFreshMarsh}  InundateTo := 10; //10 = TidalFlat
        6: {ScrubShrub}  InundateTo := 7; // 7 = RegFloodMarsh
        7: {RegFloodMarsh}  InundateTo := 10;
        8: {Mangrove}  InundateTo :=  16; // 16 = EstuarineWater
        9: {EstuarineBeach}  InundateTo := 16; // 16 = EstuarineWater
        10: {TidalFlat}  InundateTo := 16; // 16 = EstuarineWater
        11: {OceanBeach}  InundateTo := 18; // OpenOcean;
        12: {OceanFlat}  InundateTo := 18; // OpenOcean;
        13: {RockyIntertidal}  InundateTo := 16; // 16 = EstuarineWater
        14: {InlandOpenWater}  InundateTo := 16; // 16 = EstuarineWater
        15: {RiverineTidal}  InundateTo :=  16; // 16 = EstuarineWater
        16: {EstuarineWater}  InundateTo := Blank;
        17: {TidalCreek}  InundateTo := Blank;
        18: {OpenOcean}  InundateTo := Blank;
        19: {IrregFloodMarsh}  InundateTo := 7;
        20: {InlandShore}  InundateTo := 16; // 16 = EstuarineWater
        21: {TidalSwamp}  InundateTo :=  19; //  IrregFloodMarsh;
        22: {FloodDevDryLand}  InundateTo := Blank;
        23: {FloodForest}  InundateTo :=  Blank;
      end; {case}

      Cats[i].NInundRules := 0;
      With Cats[i] do
      Case i of
        0: {DevDryland}  NInundRules := 7;
        1: {UndDryland}  NInundRules := 5;
        2: {Swamp}  NInundRules := 2;
        3: {CypressSwamp}  NInundRules := 2;
        4: {InlandFreshMarsh}  NInundRules := 2;
        5: {TidalFreshMarsh}  NInundRules := 3;
        6: {ScrubShrub}  NInundRules := 1;
        7: {RegFloodMarsh}  NInundRules := 1;
        13: {RockyIntertidal}  NInundRules := 1;
        19: {IrregFloodMarsh}  NInundRules := 1;
        20: {InlandShore}  NInundRules :=1;
        21: {TidalSwamp}  NInundRules:= 2;
      end; {case}

      With Cats[i] do SetLength(InundRules,NInundRules);

      With Cats[i] do
      Case i of
        0: {DevDryland} Begin For j:=0 to 6 do InundRules[j] := j+1; End;  // 1, 2, 3, 4, 5, 6, 7
        1: {UndDryland}  Begin InundRules[0] := 1; For j:=3 to 6 do InundRules[j-2] := j+1; End;  // 1,4,5,6,7
        2: {Swamp}  Begin InundRules[0] := 7; InundRules[1] := 6; End;
        3: {CypressSwamp}  Begin InundRules[0] := 13; InundRules[1] := 6; End;
        4: {InlandFreshMarsh}  Begin InundRules[0] := 10; InundRules[1] := 6; End;
        5: {TidalFreshMarsh}  Begin InundRules[0] := 6; InundRules[1] := 11; InundRules[2] := 12; End;
        6: {TransSaltMarsh}  InundRules[0] := 8;
        7: {RegFloodMarsh}  InundRules[0] := 8;
        13: {RockyIntertidal}  InundRules[0] := 9;
        19: {IrregFloodMarsh}  InundRules[0] := 8;
        20: {InlandShore}  InundRules[0] := 9;
        21: {TidalSwamp}   Begin InundRules[0] := 10; InundRules[1] := 6; End;
      end; {case}


    With Cats[i].ElevDat do
     Begin
      If not Cats[i].IsTidal then
                             Begin  {Only "correct" cells that have initial conditions below the salt boundary due to low precision DEM}
                               MinUnit := SaltBound;
                               MinElev := 1.0;
                               MaxUnit := Meters;
                               MaxElev := 3.048;  {assumes 10 foot contour}
                             End;
      If i = 19 then         Begin // IrregFloodMarsh
                               MinUnit := HalfTide;
                               MinElev := 0.5;
                               MaxUnit := SaltBound;
                               MaxElev := 1.0;
                             End;
      If i=6 then            Begin  // ScrubShrub
                               MinUnit := HalfTide;
                               MinElev := 1.0;
                               MaxUnit := SaltBound;
                               MaxElev := 1.0;
                             End;
      if i=7 then         Begin // Regflood marsh
                               MinUnit := Meters;
                               MinElev := 0;
                               MaxUnit := HalfTide;
                               MaxElev := 1.2;
                             End;
      if i=8 then            Begin  // mangrove
                               MinUnit := Meters;
                               MinElev := 0;
                               MaxUnit := SaltBound;
                               MaxElev := 1.0;
                             End;
      if i in [20,11,9] then //         InlandShore,OceanBeach,EstuarineBeach:
                             Begin
                               MinUnit := HalfTide;
                               MinElev := -1.0;
                               MaxUnit := SaltBound;
                               MaxElev := 1.0;
                             End;
      if i in [10,12] then   Begin //  Tidalflat, OceanFlat:
                               MinUnit := HalfTide;
                               MinElev := -1.0;
                               MaxUnit := Meters;
                               MaxElev := 0;
                             End;
      If i=13 then           Begin  //  RockyIntertidal:
                               MinUnit := HalfTide;
                               MinElev := -1.0;
                               MaxUnit := SaltBound;
                               MaxElev := 1.0;
                             End;

     End; {With}
   End; // For i := 0 to NCats-1

  DevDryLand := 0;
  UndDryLand := 1;
  FloodDevDryLand := 22;
  OpenOcean := 18;
  EstuarineWater := 16;  // categories required for flooded developed dry land, and memory optimization

  SetCSeqDefaults(False);
End;


procedure TCategories.WriteTechSpecs;
Var SaveFile: TextFile;
    SaveFileN: String;
    i, IR: Integer;
    WriteStr: String;
begin
  If Not PromptForFileName(SaveFileN,'Text (*.TXT)|*.txt','.txt','Select File to Write Category Specs','',True) then Exit;
  AssignFile(SaveFile,SaveFileN);
  Rewrite(SaveFile);

  Writeln(SaveFile,'Category Name, GIS Number, OpenWater, Tidal, NonTidal Wetland, Dryland, Developed, Aggregation Category, IFM Collapse, RFM Collapse, Accretion Model, Erosion Model');
  For i := 0 to NCats-1 do
   With Cats[i] do
    Begin
     Write(SaveFile,'"'+TextName+'",');
     Write(SaveFile,IntToStr(GISNumber)+',');
     WriteStr := '';
     If IsOpenWater       then WriteStr := WriteStr + 'X'; WriteStr := WriteStr + ' ,';
     If IsTidal           then WriteStr := WriteStr + 'X'; WriteStr := WriteStr + ' ,';
     If IsNonTidalWetland then WriteStr := WriteStr + 'X'; WriteStr := WriteStr + ' ,';
     If IsDryLand         then WriteStr := WriteStr + 'X'; WriteStr := WriteStr + ' ,';
     If IsDeveloped       then WriteStr := WriteStr + 'X'; WriteStr := WriteStr + ' ,';

     Case AggCat of
        NonTidal: WriteStr := WriteStr + 'Aggregated Non Tidal';
        FreshNonTidal: WriteStr := WriteStr + 'Freshwater Non-Tidal';
        OpenWater: WriteStr := WriteStr + 'Open Water';
        LowTidal: WriteStr := WriteStr +  'Low Tidal';
        SaltMarsh: WriteStr := WriteStr +   'Saltmarsh';
        Transitional: WriteStr := WriteStr +   'Transitional';
        FreshWaterTidal: WriteStr := WriteStr + 'Freshwater Tidal';
        AggBlank: WriteStr := WriteStr + 'None';
     End; {Case}
     WriteStr := WriteStr + ',';

     If UseIFMCollapse then WriteStr := WriteStr + 'X'; WriteStr := WriteStr + ' ,';
     If UseRFMCollapse then WriteStr := WriteStr + 'X'; WriteStr := WriteStr + ' ,';

     Case AccrModel of
        RegFM: WriteStr := WriteStr + 'Reg.Flood.Marsh';
        IrregFM: WriteStr := WriteStr + 'Irreg.Flood.Marsh';
        BeachTF: WriteStr := WriteStr + 'Beach/T.Flat';
        TidalFM: WriteStr := WriteStr + 'Tidal-Fresh Marsh';
        InlandM: WriteStr := WriteStr + 'Inland Marsh';
        Mangrove: WriteStr := WriteStr + 'Mangrove';
        TSwamp: WriteStr := WriteStr + 'Tidal Swamp';
        Swamp: WriteStr := WriteStr + 'Swamp';
        AccrNone: WriteStr := WriteStr + 'None';
     End; {Case}
     WriteStr := WriteStr + ',';

     Case ErodeModel of
       EMarsh: WriteStr := WriteStr + 'Marsh Erosion';
       ESwamp: WriteStr := WriteStr + 'Swamp Erosion';
       ETFlat: WriteStr := WriteStr + 'T.Flat Erosion';
       EOcBeach: WriteStr := WriteStr + 'Ocean Beach Erosion';
       ENone: WriteStr := WriteStr + 'No Erosion';
     End; {Case}
     WriteStr := WriteStr + ',';

     Writeln(SaveFile,WriteStr);

   End; // loop through categories

  Writeln(SaveFile);
  For i := 0 to NCats-1 do
   With Cats[i] do
     Begin
      Write(SaveFile,'['+IntToStr(GISNumber)+'] ',TextName);
      If InundateTo = Blank then Write(SaveFile,': inundation model is not relevant for this category.')
        else
          Begin
            Write(SaveFile,' Inundation Model:  When it falls below its lower elevation boundary, this category generally converts to "'+GetCat(InundateTo).TextName+'."  ');
            If (NInundRules>0) then
              Write(SaveFile,'However, (1) '+TextInundRule(1));
            If (NInundRules>1) then
             for IR := 2 to NInundRules do
              Write(SaveFile,'Otherwise, ('+IntToStr(IR)+') '+TextInundRule(IR));
          End;
        Writeln(SaveFile);
     End;
  Closefile(SaveFile);
  ShowMessage('Specs saved to '+SaveFileN);

end;



Procedure TCategories.SetCSeqDefaults(CA: Boolean);
Var i: Integer;
Begin
  If CA
    then
     for i := 0 to 27 do
      With Cats[i] do
       Case i of
        0: {DevDryLand} Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        1: {UndDryLand} Begin mab := 1.6; RSC := 0.09; ECH4 := 0; CSeqNotes := 'mab: IPCC 2006 V4 Chap 6 - p6.29 & Table 6.4, for Warm Temperate - Dry Regions; Rsc:Kroodsma and Field 2006 value for non-rice annual cropland'; End;
        2: {Agriculture} Begin mab := 1.6; RSC := 0.09; ECH4 := 0; CSeqNotes := 'mab: IPCC 2006 V4 Chap 6 - p6.29 & Table 6.4, for Warm Temperate - Dry Regions; Rsc:Kroodsma and Field 2006 value for non-rice annual cropland'; End;
        3: {Artificial Pond} Begin mab := 0; RSC := 0; ECH4 := 0.1937; CSeqNotes := 'Ech4: IPCC 2013 Table 4.14'; End;
        4: {Artificial Salt Pond} Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        5: {Inland Open Water} Begin mab := 0; RSC := 0; ECH4 := 0.1937; CSeqNotes := 'Ech4: IPCC 2013 Table 4.14'; End;
        6: {Inland Shore} Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        7: {Freshwater Marsh} Begin mab := 5.5; RSC := 0.35; ECH4 := 0.1937; CSeqNotes := 'mab: Onuf 1987, Figure 31: Mean biomass of salt marsh plants in Mugu Lagoon (1977-1981); Rsc: Elgin 2012; Ech4: IPCC 2013 Table 4.14'; End;
        8: {Seasonal Freshwater Marsh} Begin mab := 5.5; RSC := 0.35; ECH4 := 0.1937; CSeqNotes := 'mab: Onuf 1987, Figure 31: Mean biomass of salt marsh plants in Mugu Lagoon (1977-1981); Rsc: Elgin 2012; Ech4: IPCC 2013 Table 4.14'; End;
        9: {Seasonally Flooded Agriculture} Begin mab := 1.6; RSC := 0.09; ECH4 := 0.1937; CSeqNotes := 'mab: IPCC 2006 V4 Chap 6 - p6.29 & Table 6.4, for Warm Temperate - Dry Regions; Rsc:Kroodsma and Field 2006 value for non-rice annual cropland; Ech4: IPCC 2013 Table 4.14'; End;
        10:{Dunes} Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        11:{Freshwater Forested/Shrub} Begin mab := 5.5; RSC := 0.35; ECH4 := 0.1937; CSeqNotes := 'mab: Onuf 1987, Figure 31: Mean biomass of salt marsh plants in Mugu Lagoon (1977-1981); Rsc: Elgin 2012; Ech4: IPCC 2013 Table 4.14'; End;
        12:{Tidal Freshwater Forested/Shrub} Begin mab := 5.5; RSC := 0.35; ECH4 := 0.1937; CSeqNotes := 'mab: Onuf 1987, Figure 31: Mean biomass of salt marsh plants in Mugu Lagoon (1977-1981); Rsc: Elgin 2012; Ech4: IPCC 2013 Table 4.14'; End;
        13:{Tidal Fresh Marsh} Begin mab := 5.5; RSC := 0.35; ECH4 := 0.1937; CSeqNotes := 'mab: Onuf 1987, Figure 31: Mean biomass of salt marsh plants in Mugu Lagoon (1977-1981); Rsc: Elgin 2012; Ech4: IPCC 2013 Table 4.14'; End;
        14:{Irreg.-Flooded Marsh} Begin mab := 3.9; RSC := 0.25; ECH4 := 0; CSeqNotes := 'Assume 70% cover of regularly flooded salt marsh; Ech4: IPCC 2013 Table 4.14 (0 for saline  conditions)'; End;
        15:{Estuarine forested/shrub wetland} Begin mab := 5.5; RSC := 0.35; ECH4 := 0; CSeqNotes := 'mab: Onuf 1987, Figure 31: Mean biomass of salt marsh plants in Mugu Lagoon (1977-1981); Rsc: Elgin 2012; Ech4: IPCC 2013 Table 4.14 (0 for saline  conditions)'; End;
        16:{Artificial reef} Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        17:{Invertebrate reef} Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        18:{Ocean Beach} Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        19:{Regularly-flooded Marsh} Begin mab := 5.5; RSC := 0.35; ECH4 := 0; CSeqNotes := 'mab: Onuf 1987, Figure 31: Mean biomass of salt marsh plants in Mugu Lagoon (1977-1981); Rsc: Elgin 2012; Ech4: IPCC 2013 Table 4.14 (0 for saline  conditions)'; End;
        20:{Rocky Intertidal} Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        21:{Tidal Flat and Salt Panne} Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        22:{Riverine (open water)} Begin mab := 0; RSC := 0; ECH4 := 0.1937; CSeqNotes := 'Ech4: IPCC 2013 Table 4.14'; End;
        23:{Riverine Tidal} Begin mab := 0; RSC := 0; ECH4 := 0.1937; CSeqNotes := 'Ech4: IPCC 2013 Table 4.14'; End;
        24:{Tidal Channel} Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        25:{Estuarine Open Water} Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        26:{Open Ocean} Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        27:{FloodedDeveloped} Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
      end {case}

    else {Not California Categories}
     for i := 0 to 23 do
      With Cats[i] do
      Case i of
        0: {DevDryland}  Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        1: {UndDryland}  Begin mab := 1.6; RSC := 0.09; ECH4 := 0; CSeqNotes := 'mab: IPCC 2006 V4 Chap 6 - p6.29 & Table 6.4, for Warm Temperate - Dry Regions; Rsc:Kroodsma and Field 2006 value for non-rice annual cropland'; End;
        2: {Swamp}       Begin mab := 5.5; RSC := 0.35; ECH4 := 0.1937; CSeqNotes := 'mab: Onuf 1987, Figure 31: Mean biomass of salt marsh plants in Mugu Lagoon (1977-1981); Rsc: Elgin 2012; Ech4: IPCC 2013 Table 4.14'; End;
        3: {CypressSwamp}  Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        4: {InlandFreshMarsh} Begin mab := 5.5; RSC := 0.35; ECH4 := 0.1937; CSeqNotes := 'mab: Onuf 1987, Figure 31: Mean biomass of salt marsh plants in Mugu Lagoon (1977-1981); Rsc: Elgin 2012; Ech4: IPCC 2013 Table 4.14'; End;
        5: {TidalFreshMarsh}  Begin mab := 5.5; RSC := 0.35; ECH4 := 0.1937; CSeqNotes := 'mab: Onuf 1987, Figure 31: Mean biomass of salt marsh plants in Mugu Lagoon (1977-1981); Rsc: Elgin 2012; Ech4: IPCC 2013 Table 4.14'; End;
        6: {ScrubShrub}       Begin mab := 3.9; RSC := 0.25; ECH4 := 0; CSeqNotes := 'Assume 70% cover of regularly flooded salt marsh; ; Ech4: IPCC 2013 Table 4.14 (0 for saline  conditions)'; End;
        7: {RegFloodMarsh}    Begin mab := 5.5; RSC := 0.35; ECH4 := 0; CSeqNotes := 'mab: Onuf 1987, Figure 31: Mean biomass of salt marsh plants in Mugu Lagoon (1977-1981); Rsc: Elgin 2012; Ech4: IPCC 2013 Table 4.14 (0 for saline  conditions)'; End;
        8: {Mangrove}         Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        9: {EstuarineBeach}   Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        10: {TidalFlat}       Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        11: {OceanBeach}      Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        12: {OceanFlat}       Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        13: {RockyIntertidal}  Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        14: {InlandOpenWater}  Begin mab := 0; RSC := 0; ECH4 := 0.1937; CSeqNotes := 'Ech4: IPCC 2013 Table 4.14'; End;
        15: {RiverineTidal}    Begin mab := 0; RSC := 0; ECH4 := 0.1937; CSeqNotes := 'Ech4: IPCC 2013 Table 4.14'; End;
        16: {EstuarineWater}   Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        17: {TidalCreek}       Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        18: {OpenOcean}        Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        19: {IrregFloodMarsh}  Begin mab := 3.9; RSC := 0.25; ECH4 := 0; CSeqNotes := 'Assume 70% cover of regularly flooded salt marsh; Ech4: IPCC 2013 Table 4.14 (0 for saline  conditions)'; End;
        20: {InlandShore}      Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        21: {TidalSwamp}       Begin mab := 5.5; RSC := 0.35; ECH4 := 0.1937; CSeqNotes := 'mab: Onuf 1987, Figure 31: Mean biomass of salt marsh plants in Mugu Lagoon (1977-1981); Rsc: Elgin 2012; Ech4: IPCC 2013 Table 4.14'; End;
        22: {FloodDevDryLand}  Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
        23: {FloodForest}      Begin mab := 0; RSC := 0; ECH4 := 0; CSeqNotes := ''; End;
      end; {case}


End;

Function TCategories.AreCalifornia: Boolean;
Begin
  Result := GetCat(10).TextName='Dunes';  // For now, use the Dunes designation to identify CA categories
End;

end.
