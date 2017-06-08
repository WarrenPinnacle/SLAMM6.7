//SLAMM SOURCE CODE Copyright (c) 2009-2012 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit GLOBAL;

INTERFACE

USES   SysUtils, Windows, Messages, Classes, Graphics, Math, Dialogs;

Const  VersionNum: Double = 6.99;   //used for file reading and writing   6.985 threshold
       VersStr  = '6.7.0 beta';
       BuildStr = '6.7.0238';

Const  Feet_Per_Meter = 3.28084;

Const USE_DATAELEV = TRUE; {Use an array that displays elevations above 8 meters}

CONST  MTL =  0.0;         {use mean tidal level as datum}
       ELEV_CUTOFF = 8.0;  {elev not to model when addtl optimize is turned on, in meters above MTL}

Const Tiny = 1e-10;
      Output_MaxC = 60;
      MaxRoadArray = 10;
      MaxCats = 30;

VAR DRIVE_EXTERNALLY : Boolean = FALSE;
    Large_Raster_Edit : Boolean = False;
    IterCount: Integer = 0;
//    PROCESSING_BATCH: BOOLEAN = False;

TYPE
  OutputArray    = Array of Array of Array[0..Output_maxc] OF double;  {Output [0..NumSites+1,0..NumRows-1,Columns]}
  str_vector     = Array[0..Output_maxc] of string; {[25];}
  str_vector1    = Array of string; {[25];}
  file_name_type = String;
  RoadArray  = Array[0..MaxRoadArray] of Double;

  TLine = packed record p1,p2: Tpoint end;
  WaveDirection = (Easterly,Westerly,Southerly,Northerly);

  ElevUnit = (HalfTide, SaltBound, Meters);

  ClassElev = packed Record
      MinUnit : ElevUnit;
      MinElev : Double;
      MaxUnit : ElevUnit;
      MaxElev : Double;
    End; {Record}


   ElevCategory =
    ( LessThanMLLW,
      MLLWtoMLW,
      MLWtoMTL,
      MTLtoMHW,
      MHWtoMHWS,
      GreaterThanMHWS);

AccrModels = (RegFM,IrregFM,BeachTF,TidalFM,InlandM,Mangrove,TSwamp,Swamp,AccrNone);
               {0}   {1}      {2}      {3}
ErosionInputs = (EMarsh, ESwamp, ETFlat, EOcBeach, ENone);
AggCategories = (NonTidal,FreshNonTidal,OpenWater,LowTidal,SaltMarsh,Transitional,FreshWaterTidal,AggBlank);

(* Const  FirstCategory = DevDryLand;
       LastCategory  = FloodForest;

Type TClassElevArray = Array[FirstCategory..LastCategory] of ClassElev;

Procedure LoadElevRangesFromText(Var TCA: TClassElevArray);
Procedure SaveElevRangesToText(TCA: TClassElevArray);  *)
Function TranslateInundNum(InundIn: Integer): Integer;

Type
 TPointArray  = Array of TPoint;
// PPointArray = ^TPointArray;

 TPolygon  = Class
               TPoints: TPointArray;
               NumPts: Integer;
               svMinRow,svMaxRow,svMinCol,svMaxCol: Integer;  //no save
               Function InPoly(Row,Col: Integer): Boolean;
               Function MinRow: Integer;
               Function MaxRow: Integer;
               Function MinCol: Integer;
               Function MaxCol: Integer;
               Constructor Create;
               Constructor Load(ReadVersionNum: Double; TS: TStream; ReadHeader: Boolean);
               Procedure Store;
               Function CopyPolygon: TPolygon;
               Destructor Destroy; override;
             End;

 TRectangle = Packed Record
    X1,Y1,X2,Y2   : Integer;  {rectangular location within primary map}
  End;


 POutputSite2 = ^TOutputSite2;
 TOutputSite2 = Packed Record
    UsePolygon: Boolean;
    SaveRec: TRectangle;
    SavePoly: TPolygon;
    ScaleRec: TRectangle;
    ScalePoly: TPolygon;
    Description   : String;
  End;

Const NWindDirections = 16;
      NWindSpeeds = 7;

Const WindDirections : Array[1..16] of String = ('E','ENE','NE','NNE','N','NNW','NW','WNW','W','WSW','SW','SSW','S','SSE','SE','ESE');
Const WindDegrees : Array[1..16] of Integer =   ( 90, 68,   45,   22,  0  ,338  ,315, 292 ,270, 248, 225, 202  , 180,158, 135 , 112 );

Type TWindRose = Array[1..NWindDirections,1..NWindSpeeds] of Double;

Type TLagoonType = (LtNone, LtOpenTidal, LtPredOpen, LtPredClosed, LtDrainage);

Const N_ACCR_MODELS = 4;
      AccrNames : Array[0..N_ACCR_MODELS-1] of String = ('Reg Flood','Irreg Flood','T.Flat','Tidal Fresh');  //1-23-11

Type
 TUseAccrVar =  Array[0..N_ACCR_MODELS-1] of Boolean;
 TAccrVar =  Array[0..N_ACCR_MODELS-1] of Double;
 TAccrNotes = Array[0..N_ACCR_MODELS-1] of String;
  {0 = Reg Flood, 1 = Irreg Flood, 2 = Tidal Flat, 3 = veg Tidal Flat}


 TSubSite = Class
    SavePoly: TPolygon;
    ScalePoly: TPolygon;
    Description   : String;
    NWI_Photo_Date: Integer;
    DEM_date  : Integer;
    Direction_OffShore  : WaveDirection; { S, E, W, N }
    Historic_trend,          { (mm/yr) assumed to include subsidence   }
    Historic_Eustatic_trend, { (mm/year over same time period as historic trend, default to 1.7 from 1900-2000, OR set to same as historic trend if running a RSLR scenario)}
    NAVD88MTL_correction,    { m, MTL-NAVD88 in meters                 }
    GTideRange,              { m, Great Diurnal Tide Range, GT         }
    SaltElev  : double;      { m above MTL, was Mean High Water Spring }

    InundElev : array[0..4] of double; {inundation elevations: 0:H1, 1:H2, 2:H3, 3:H4, 4:H5}

    MarshErosion,
    SwampErosion,
    TFlatErosion  : Double;  {horizontal erosion meters / year}
    FixedRegFloodAccr,          {accretion rates, mm / year}
    FixedIrregFloodAccr,        {accretion rates, mm / year}
    FixedTideFreshAccr: Double; {accretion rates, mm / year}
    InlandFreshAccr,            {New 5/20/2011 }
    MangroveAccr,               {New 5/20/2011 }
    TSwampAccr, SwampAccr : Double;   {New 5/20/2011 }

    IFM2RFM_Collapse, RFM2TF_Collapse: Double; {meters, New 1/11/2016}

    Fixed_TF_Beach_Sed: Double;  {Sedimentation for non-wetlands, m /year}

    Use_Preprocessor: Boolean;  {whether to use elev. pre-processor, i.e. TRUE using poor vertical resolution data FALSE if using LiDAR}

    USE_Wave_Erosion: Boolean;
    WE_Alpha: Double;
    WE_Has_Bathymetry: Boolean;
    WE_Avg_Shallow_Depth: Double;   // relative to MTL

    LagoonType: TLagoonType;
    ZBeachCrest: Double; // relative to MSL
    LBeta      : Double; // Lagoon Beta, fraction

    {Accretion Submodel Parameters}   {0 = Reg Flood, 1 = Irreg Flood, 2 = Tidal Flat, 3 = veg Tidal Flat}
    UseAccrModel: TUseAccrVar;  {boolean}
    MaxAccr : TAccrVar; {mm/year}
    MinAccr : TAccrVar; {mm/year}
    AccrA   : TAccrVar; {mm/(year*HTU^3}
    AccrB   : TAccrVar; {mm/(year*HTU^2}
    AccrC   : TAccrVar; {mm/(year*HTU}
    AccrD   : TAccrVar; {mm/year}
    AccRescaled : TUseAccrVar; {boolean}
    RAccrA   : TAccrVar; {mm/(year*HTU^3}  //rescaled accretion values
    RAccrB   : TAccrVar; {mm/(year*HTU^2}  //rescaled accretion values
    RAccrC   : TAccrVar; {mm/(year*HTU}    //rescaled accretion values
    RAccrD   : TAccrVar; {mm/year}         //rescaled accretion values

    AccrNotes: TAccrNotes;



    {Calculations below here}
    MHHW,
    MLLW,
    Norm      : Double;  { Global SLR since model start (NWI_Photo_Date), cm }
    SLRise,              { Rise of SL in m in current time-step  }
    OldSL,               { Rise of SLR in m in previous time-step (since NWI_Photo_Date)}
    NewSL    : Double;   { Eustatic SLR since the NWI_Photo_Date, m  }
    T0SLR    : Double;   { Eustatic SLR at T0 if relevant (if this subsite NWI_Photo_Date less than others}
    DeltaT   : Integer;

    Constructor Create;
    Constructor CreateWith(TSS: TSubSite);
    Destructor Destroy;  override;
  End;

  TSite = Class
    ReadRows, ReadCols  : Integer;  { Native number of rows & columns in inputs }
    LLXCorner,                { SW corner of site        }
    LLYCorner           : Double;
    ReadScale, RunScale : double;   { width & height of square cell cells }

    GlobalSite    : TSubSite; { site data used if no "subsites" or no "subsites" meet boundary }
    NSubSites,NOutputSites  : Integer;
    MaxROS        : Integer;  { ROS = raster output sites }
    SubSites      : Array of TSubSite;
    OutputSites  : Array of TOutputSite2;
    ROSBounds     : Array of TRectangle;  {no load or save -- read from rasters}

    RunRows, RunCols    : Integer;  { Number of rows & columns to run }
    TopRowHeight, RightColWidth : Integer;  {Height and Width of top and right column if scaling is implemented}

    Constructor Create;
    Constructor Load(ReadVersionNum: Double; TS: TStream);
    Procedure Store(Var TS: TStream);
    Procedure LoadSubSite(ReadVersionNum: Double; TS: TStream; Var SS: TSubSite);
    Procedure StoreSubSite(Var TS: TStream; Var SS: TSubSite);
    Procedure AddSubSite;
    Procedure AddOutputSite;
    Procedure DelSubSite(Index: Integer);    {indexed to zero}
    Procedure DelOutputSite(Index: Integer); {indexed to zero}
    Function GetSubSite(X {Col},Y {Row}:Integer): TSubSite;  {Subsite with highest number gets dominance} overload;
    Function GetSubSite(X,Y:Integer; PC: pointer): TSubSite;  {Subsite with highest number gets dominance} overload;
    Function GetSubSiteNum(X,Y:Integer): Integer; overload;
    Function GetSubSiteNum(X,Y:Integer; PC: pointer): Integer; overload;
    Function InOutSite(X {Col},Y {Row}:Integer; SiteNum: Integer): Boolean;
    Function T0 : Integer; {Latest NWI_Photo_Date}
    Function TideOc(X,Y: Integer): Double;
    Procedure InitElevVars;
    Destructor Destroy; override;
  End;

Type StatRecord = Packed Record
    Min, Max, Sum, SumX2, Sum_e2, Mean, Stdev, p05, p95 : Double;
End; {Record}

Const HistWidth = 500 {100};  {used for calculating salinity histograms, n.b. affects STORE/LOAD}
  SalHistWidth = 100;

Type TElevStats = Packed Record
    N: Int64;
    Stats: Packed Array[1..8] of StatRecord;
    pLowerMin:  Double;
    pHigherMax: Double;
    Histogram : Packed Array[1..8,0..(HistWidth-1)] of Integer;   //1/5:HTU/m-MTL, 2/6:HTU/m-MLLW, 3/7:HTU/m-MHHW, 4/8:HTU/m-NAVD88
    Values: Packed Array[1..8] of Packed Array of Single;
  End; {Record}

 TSalinityRule = class
    FromCat, ToCat: Integer;  // category identification number
    SalinityLevel: Double;
    GreaterThan: Boolean;
    SalinityTide: Integer; { 1 = MLLW, 2 = MTL, 3 = MHHW, 4 = Monthly High }
    Descript: String;
    Constructor Load(ReadVersionNum: Double; TS: TStream);
    Procedure Store(Var TS: TStream);
    Constructor Create;
 End;

 TSalinityRules = class
   NRules: Integer;
   Rules : Array of TSalinityRule;
   Constructor Create;
   Constructor Load(ReadVersionNum: Double; TS: TStream);
   Procedure Store(Var TS: TStream);
 End;

Type ElevGridColorType = ARRAY[ElevCategory] OF TColor;

Const


  CLOpenWater = $00A74D00;
  CLLowTidal = $0000FFFF;
  CLSaltMarsh = $000000A8;
  CLTransitional = $0000FF55;
  CLFreshTidal = $00007326;
  ClFreshNonTidal = $00BEFFD2;
  ClUpland = $00B2B2B2;

  ElevationColors: ElevGridColorType
   = ($006644EE, {lowest elevation within tide range <MLLW}
      $006655EE,
      $006666EE,
      $006677EE,
      $006688EE,
      $006699EE {highest elevation around MHWS + 2}  );

Type
  IPCCScenarios  = (Scen_A1B,Scen_A1T,Scen_A1F1,Scen_A2,Scen_B1,Scen_B2);
  IPCCEstimates  = (Est_Min,Est_Mean,Est_Max);
  ProtScenario   = (NoProtect, ProtDeveloped, ProtAll);
  ESlammError    = Exception;

Const DiskUnit = 642190;

Const NUM_SAL_METRICS = 4;  {MLLW, MTL, MHW, 30D}

Type TSalStats = packed record
   N: Array[1..NUM_SAL_METRICS] of Integer;
   Min, Max, Sum, Sum_e2, Mean, Stdev, p05, p95: Array[1..NUM_SAL_METRICS] of Double;
   Histogram : Array[1..NUM_SAL_METRICS,0..(SalHistWidth-1)] of Integer;
//   Derived: TDateTime;
 End;

Const SliceIncrement = 0.1; {km}  {slice increment for estuary width accounting}

Type

  TDoubleArray = Array of Double;
  PDoubleArray = ^TDoubleArray;

  TSRecord = Record
               Year: Integer;
               Value: Double;
             End;

  PTSRArray = ^TSRArray;
  TSRArray  =  Array of TSRecord;

Const N_FTABLE = 60;
Type  TFTable  = Array[0..N_FTABLE-1] of Double; {Array of volume at depth relationships}

  TFWFlow     = Class
                   Name: String;
                   ExtentOnly   : Boolean;
                   UseTurbidities: Boolean;
                   SWPPT,FWPPT: Double;  // salinity of fresh water and salt water sources
                   Origin_km   : Double;  //origin of salt wedge, extent of freshwater flow in SLAMM river km

                   NTurbidities: Integer;
                   Turbidities: TSRArray;

                   NFlows: Integer;
                   MeanFlow: TSRArray;
                   ManningsN: Double;    // not currently used
                   FlWidth : Double;     // not currently used
                   InitSaltWedgeSlope: Double; {slope of the salt wedge, m/m}

                   TSElev  : Double; {Max. TS elev in meters above MTL}
                   {---------------- Calculations Below ---------------------}

                   RetTime: Array [1..NUM_SAL_METRICS] of Array of Single;  {Retention Time at MLLW, MTL, MHHW}

                   WaterZ: Array [1..NUM_SAL_METRICS] of Array of Single;   {Depth of Water at MLLW, MTL, MHHW}
                   XS_Salinity: Array [1..NUM_SAL_METRICS] of Array of Single;  {Weighted avg salinity of cross section (segment Rn) at MLLW, MTL, MHHW}

                   SubsiteArr: Array of TSubSite;
                   FTables: Array of TFTable;
                   D2Origin: Array of Single;
                   NumCells: Array of Integer;
                   SavePoly: TPolygon;
                   ScalePoly: TPolygon;
                   SW_Z_Mouth, SW_Z_Data: Double;

                   OriginArr, MouthArr: TPointArray;
                   NumSegments: Integer;

                   {CALCULATION VARS BELOW, No Loading or Saving Reqd.}
                   Plume, Vect: PDoubleArray;
                   EstuaryLength : Double;
                   RiverMouthIndex: Integer;
                   OriginLine, PlumeLine: Array of Tline;     // origin is perpendicular to line crossing start point, plume is pependicular to line crossing end point.
                   Midpts       : TPointArray;
                   MaxRn        : Integer;
                   TestMin, TestRange: Double; {range for F-Tables}

                   OceanSubsite : TSubsite;
                   RetentionInitialized: Boolean;

                   Constructor Create;
                   Function SaltWedgeSlopeByYear(Yr: Integer): Double;
                   Function FlowByYear(Yr: Integer): Double;
                   Function TurbidityByYear(Yr: Integer): Double;
                   Function ElevByVolume(VolWat: Double; RSeg: Integer): Double;
                   Procedure CellByRN(RSeg: Integer; Var OutR, OutC: Integer);
                   Function VolumeByElev(Elev: Double; RSeg: Integer): Double;
                   Function SaltHeight(TideHeight,SLR: Double; RSeg, Yr: Integer): Double;  {elevation of salt wedge relative to MTL}

                   Procedure Store(Var TS: TStream);
                   Constructor Load(ReadVersionNum : Double; TS: TStream);
                   Destructor Destroy;  override;
                 End; {TFWFlow}

  TFWFlows   = Array of TFWFlow;

  TTimeSerSLR = Class
                   Name: String;
                   BaseYear: Integer;
                   NYears: Integer;
                   RunNow: Boolean;
                   SLRArr: TSRArray;

                   Constructor Create;
                   Procedure Store(Var TS: TStream);
                   Constructor Load(ReadVersionNum : Double; TS: TStream);
                   Destructor Destroy;  override;
                 End; {TTimeSerSLR}
  TTimeSerSLRs = Array of TTimeSerSLR;
  PTimeSerSLRs = ^TTimeSerSLRs;



CONST NUM_CAT_COMPRESS = 3;       {Upgrade, Make Editable?}
TYPE
  PCompressedCell = ^CompressedCell;
  CompressedCell = packed RECORD
             Cats      : Array[1..NUM_CAT_COMPRESS] of Integer;  // categories
             MinElevs  : Array[1..NUM_CAT_COMPRESS] of Single;
             Widths    : Array[1..NUM_CAT_COMPRESS] of single;
             TanSlope  : Single;

             ProtDikes : Boolean; {is protected by dikes?}
             ElevDikes : Boolean;  //consider optimizing memory by combining two booleans into a byte

             MaxFetch  : Single;

             Sal       : Array[1..NUM_SAL_METRICS] of Single;
             SalHeightMLLW : single; {meters}
             Uplift    : single; {mm/year}
             ErosionLoss, BTFErosionLoss: Single;
             MTLminusNAVD: single; {mtl minus navd88 for output/utility purposes}
             D2MLLW, D2MHHW, ProbSAV, D2Mouth : Single;  // Added D2Mouth - Marco
             ImpCoeff : Integer;
             SubsiteIndex: SmallInt;   // save subsite index to speed execution

             Pw, WPErosion: Single;  // wave power aggregated over whole year, wave power erosion m/y
           End;

Const
  BLOCKSIZE = 10000;  {cells in one contiguous memory location}

Type
  DikeInfoRec = Packed Record
                  UpRow,UpCol: Integer;
                  Dist_Origin: Double;
                End;

  TDikeInfoArr = Array of DikeInfoRec;


  PMSArray2 = ^MSArray2;
  MSArray2 = Array[0..(BLOCKSIZE-1)] of CompressedCell;

  MSArray  = Array of PMSArray2;
{  MSFile  = FILE OF Cell_Rec; }


Const

  LabelProtect: Array[NoProtect..ProtAll] of String =
            ('No Protect','Protect Developed','Protect All');

  LabelIPCC : Array[Scen_A1B..Scen_B2] of String =
              ('Scenario A1B','Scenario A1T','Scenario A1F1','Scenario A2','Scenario B1','Scenario B2');

  LabelIPCCEst : Array[Est_Min..Est_Max] of String =
              ('Minimum','Mean','Maximum');

  LabelFixed: Array[1..11] of String {[31]} = ('1 meter','1.5 meter','2 meter','NYS GCM Max','NYS 1M by 2100','NYS RIM Min','NYS RIM Max','ESVA Historic', 'ESVA Low', 'ESVA High', 'ESVA Highest');

Var  MinHist: Double = 0;  //salinity min
     MaxHist: Double = 35.0;  //salinity max


Type FractalRecord = Record
       NBox,
       MinFDRow,
       MinFDCol,
       MaxFDRow,
       MaxFDCol: Array[0..1] of Integer;
       FractalP,
       FractalD: Array[0..1] of Double;
       ShoreProtect: Double;
     End; {FractalRecord}

Procedure QuickSort(Var Arr: Array of Single; iLo, iHi: Integer);
Function CopyFile(Src,Dst: String): Boolean;

Var
   {Sensitivity Analysis Vars}
   SensAnalysis        : Boolean;
   UncAnalysis         : Boolean;      // Is there an uncertainty analysis running now?

   GlobalTS: TStream;
   ShowAccrUpdateWarning : Boolean;

   TSText: Boolean;
   GlobalFile: ^TextFile;
   GlobalLN: Integer;

Procedure TSWrite(nm: String; i: Integer); overload;
Procedure TSWrite(nm: String; i: Double); overload;
Procedure TSWrite(nm: String; i: Boolean); overload;
Procedure TSWrite(nm: String; i: String); overload;

Procedure TSRead(nm: String; var i: Integer); overload;
Procedure TSRead(nm: String; var i: Double); overload;
Procedure TSRead(nm: String; var i: Boolean); overload;
Procedure TSRead(nm: String; var i: String; RVN: Double); overload;

Function LinearInterpolate(OldVal,NewVal,OldTime,NewTime,InterpTime: Double; Extrapolate: Boolean): Double;

Function IntInString(I: Integer; Str: String): Boolean;
Function StringListValid(Str: String): Boolean;
Function AbbrString(InStr: String; DelimChar: Char):String;
Function GetLogicalCpuCount: Integer;
Function CharOccurs(const str: string; c: char): integer;

Implementation


    function GetLogicalCpuCount: Integer;
    var SystemInfo: _SYSTEM_INFO;
    begin
        GetSystemInfo(SystemInfo);
        Result := SystemInfo.dwNumberOfProcessors;         //Parallel programming
    end;

    Function CharOccurs(const str: string; c: char): integer;
    // Returns the number of times a character occurs in a string
    // Ernesto De Spirito, http://www.delphi3000.com/articles/article_2615.asp
    var
      p: PChar;
    begin
      Result := 0;
      p := PChar(Pointer(str));
      while p <> nil do
        begin
          p := StrScan(p, c);
          if p <> nil then
            begin
              inc(Result);
              inc(p);
            end;
        end;
    end;


    Function AbbrString(InStr: String; DelimChar: Char):String;  // J.Guzman, modified by JSC
    {Abridges a String to what appears before the DELIMCHAR }
    Var jj : integer;

    Begin
      jj := Pos(DelimChar,InStr);
      if jj = 0 then AbbrString := InStr
                else AbbrString := Copy(InStr,1,jj-1);
    End; {AbbrString}

   Function CheckName(Nm: String):String;
   Var NameStr, InStr: String;

   Begin
     Inc(GlobalLN);
     Readln(GlobalFile^,InStr);
     NameStr := AbbrString(InStr,':');

     If NameStr <> Nm then Raise ESLAMMError.Create('Text Read Name Mismatch, Line '+IntToStr(GlobalLN)+
         ' Expecting Variable "'+Nm+'"; read variable "'+NameStr+'"');

     If Length(NameStr) >= Length(InStr)
       then Raise ESLAMMError.Create('No ":" or blank after ":", Reading Variable "'+Nm+'"  Line '+IntToStr(GlobalLN));

     Delete(InStr,1,Length(NameStr)+1);
     Result := InStr;
   End;

   Procedure TSWrite(nm: String;i: Integer); overload;
   Begin
     If TSText
       then Writeln(GlobalFile^,nm,':',i)
       else GlobalTS.Write(i,Sizeof(i));
   End;

   Procedure TSWrite(nm: String;i: Double); overload;
   Begin
     If TSText
       then Writeln(GlobalFile^,nm,':',i)
       else GlobalTS.Write(i,Sizeof(i));
   End;

   Procedure TSWrite(nm: String;i: Boolean); overload;
   Begin
     If TSText
       then Writeln(GlobalFile^,nm,':',i)
       else GlobalTS.Write(i,Sizeof(i));
   End;

   Procedure TSWrite(nm: String;i: String); overload;
   Var SS: Integer;
   Begin
     If TSText
       then Writeln(GlobalFile^,nm,':',i)
       else
         Begin
           SS := Length(i);
           GlobalTS.Write(SS,Sizeof(Integer));
           If SS>0 then GlobalTS.Write(Pointer(i)^,SS*Sizeof(Char));
         End;
   End;

   Procedure TSRead(nm: String;Var i: Integer); overload;
   Begin
     If TSText
       then Try
              i := StrToInt(CheckName(nm));
            Except
              MessageDlg(Exception(ExceptObject).Message,mterror,[mbOK],0);
              Raise ESLAMMError.Create('Integer Conversion Error, Line '+IntToStr(GlobalLN));
            End
       else GlobalTS.Read(i,Sizeof(i));
   End;

   Procedure TSRead(nm: String;Var i: Double); overload;
   Begin
     If TSText
       then Try
              i := StrToFloat(CheckName(nm));
            Except
              Raise ESLAMMError.Create('Integer Conversion Error, Line '+IntToStr(GlobalLN));
            End
       else GlobalTS.Read(i,Sizeof(i));
   End;

   Procedure TSRead(nm: String;Var i: Boolean); overload;
   Begin
     If TSText
       then Try
              i := Pos('TRUE',Uppercase(CheckName(nm)))>0;
            Except
              Raise ESLAMMError.Create('Integer Conversion Error, Line '+IntToStr(GlobalLN));
            End
       else GlobalTS.Read(i,Sizeof(i));
   End;

   Procedure TSRead(nm: String;Var i: String; RVN: Double); overload;
   Var SS: Integer;  {String Size}
       Temp: AnsiString;
   Begin
     If TSText
       then i := CheckName(nm)
       else Begin
              GlobalTS.Read(SS,Sizeof(Integer));
              If SS > 9999 then Raise ESLAMMError.Create('ReadStr Error reading "'+nm+'", Input File Corrupted');
              Setlength(i,SS);
              if RVN < 6.495
                then
                  Begin
                   SetLength(Temp, SS);              // <<-- Use temporary AnsiString
                   GlobalTS.Read(Pointer(Temp)^, SS * SizeOf(AnsiChar));  // <<-- Specify buffer size in bytes
                   i := string(Temp);                // <<-- Widen string to Unicode
                  End
                else
                  If SS>0 then GlobalTS.Read(Pointer(i)^,SS*SizeOf(Char));
            End;
   End;

{--------------------------------------------------------------------}
  Function LinearInterpolate(OldVal,NewVal,OldTime,NewTime,InterpTime: Double; Extrapolate: Boolean): Double;
  {Interpolates to InterpTime between two points, OldPoint and NewPoint}
  Begin
    If not Extrapolate
     then If (InterpTime>NewTime) or (InterpTime<OldTime)                      {Test Input for interpolation}
       then Raise ESLAMMERROR.Create('Interpolation Timestamp Error');

    LinearInterpolate := OldVal + ((NewVal-OldVal)/(NewTime-OldTime)) * (InterpTime-OldTime);
                         { y1 }   {             Slope  (dy/dx)      }   {    Delta X       }
  End;
{--------------------------------------------------------------------}
  Procedure QuickSort(Var Arr: Array of Single; iLo, iHi: Integer);
  Var
    Lo, Hi : Integer;
    T, Mid : Double;
  Begin
    Lo := iLo;
    Hi := iHi;
    Mid := Arr[(Lo + Hi) div 2];
    repeat
      while Arr[Lo] < Mid do Inc(Lo);
      while Arr[Hi] > Mid do Dec(Hi);
      if Lo <= Hi then
      begin
        T := Arr[Lo];
        Arr[Lo] := Arr[Hi];
        Arr[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then QuickSort(Arr, iLo, Hi);
    if Lo < iHi then QuickSort(Arr, Lo, iHi);
  End;
{--------------------------------------------------------------------}


Constructor TFWFlow.Create;
Var i: Integer;
Begin
  Name := 'New Flow';
  ExtentOnly := False;
  UseTurbidities := False;
  FWPPT := 0;
  SWPPT := 30;
  Origin_km := 0;
  NTurbidities := 1;
  SetLength(Turbidities,10);
  Turbidities[0].Year := 2000;
  Turbidities[0].Value := 0;

  NFlows := 0;
  MeanFLow := Nil;
  ManningsN := 0;
  FLWidth := 0;
  InitSaltWedgeSlope:= 0;

  SavePoly := tpolygon.create;
  ScalePoly := nil;
  OriginArr := nil;
  MouthArr := nil;
  Plume := nil;
  Vect := nil;

  NumSegments := 0;

  MidPts := nil;

  D2Origin := nil;

  For i := 1 to 3 do
   Begin
    RetTime[i] := nil;
    WaterZ[i] := nil;
    XS_Salinity[i] := nil;
   End;

  OriginLine := nil;
  PlumeLine := nil;
  MaxRn := 0;
  TestMin := 0; TestRange := 0;

  OceanSubsite := nil;
  SubsiteArr := nil;
  RetentionInitialized := False;

  inherited;
End;


{*************************************************************************
 * FUNCTION:   CCW (CounterClockWise)
 *
 * PURPOSE
 * Determines, given three points, if when travelling from the first to
 * the second to the third, we travel in a counterclockwise direction.
 *
 * RETURN VALUE
 * (int) 1 if the movement is in a counterclockwise direction, -1 if not.
 *************************************************************************}


function CCW(Var p0,p1,p2:TPoint): Integer;
var
  dx1, dx2: LongInt;
  dy1, dy2: LongInt;
begin
  dx1 := p1.x - p0.x ;
  dx2 := p2.x - p0.x ;
  dy1 := p1.y - p0.y ;
  dy2 := p2.y - p0.y ;

  {* This is basically a slope comparison: we don't do divisions because
   * of divide by zero possibilities with pure horizontal and pure
   * vertical lines.  *}

  if((dx1 * dy2) > (dy1 * dx2))then
    Result := 1
  else
    Result := -1;
end;


{*************************************************************************
 * FUNCTION:   Intersect
 *
 * PURPOSE
 * Given two line segments, determine if they intersect.
 *
 * RETURN VALUE
 * TRUE if they intersect, FALSE if not.
 *************************************************************************}


function Intersect(Var p1,p2,p3,p4: TPoint): Boolean;
begin
  Result := (((CCW(p1, p2, p3) * CCW(p1, p2, p4)) <= 0)and
            (( CCW(p3, p4, p1) * CCW(p3, p4, p2)  <= 0))) ;
end;



Constructor TPolygon.Create;
Begin
  NumPts := 0;
  svMinRow := -9999;
  svMaxRow := -9999;
  svMinCol := -9999;
  svMaxCol := -9999;
  TPoints := nil;
End;

Constructor TPolygon.Load(ReadVersionNum: Double; TS: TStream; ReadHeader: Boolean);
Var i: Integer;
Begin
  If ReadHeader then
    Begin
      TSRead('Poly.NumPts',NumPts);
      SetLength(TPoints,NumPts);
    End;

  For i := 1 to NumPts do
    Begin
      TSRead('TPoints[i-1].x',TPoints[i-1].x);
      TSRead('TPoints[i-1].y',TPoints[i-1].y);
    End;

  svMinRow := -9999;
  svMaxRow := -9999;
  svMinCol := -9999;
  svMaxCol := -9999;
End;

Procedure TPolygon.Store;
Var i: Integer;
Begin
  TSWrite('Poly.NumPts',NumPts);
  For i := 1 to NumPts do
    Begin
      TSWrite('TPoints[i-1].x',TPoints[i-1].x);
      TSWrite('TPoints[i-1].y',TPoints[i-1].y);
    End;
End;

Function TPolygon.CopyPolygon:TPolygon;
Var i: Integer;
Begin
  Result := TPolygon.Create;
  Result.NumPts := NumPts;
  SetLength(Result.TPoints,NumPts);
  For i := 1 to NumPts do
    Begin
      Result.TPoints[i-1].X := TPoints[i-1].X;
      Result.TPoints[i-1].Y := TPoints[i-1].Y;
    End;

End;



Destructor TPolygon.Destroy;
Begin
  TPoints := nil;
  inherited;
End;

Function TPolygon.MinRow: Integer;
Var i,MR: Integer;
Begin
  If svMinRow <> -9999
    then MinRow := svMinRow
    else
      Begin
        MR := High(Integer);
        For i := 0 to NumPts-1 do
          If TPoints[i].y < MR then MR := TPoints[i].y;
        MinRow := MR;
        svMinRow := MR;
      End;
End;

Function TPolygon.MaxRow: Integer;
Var i,MR: Integer;
Begin
  If svMaxRow <> -9999
    then MaxRow := svMaxRow
    else
      Begin
        MR := Low(Integer);
        For i := 0 to NumPts-1 do
          If TPoints[i].y > MR then MR := TPoints[i].y;
        MaxRow := MR;
        svMaxRow := MR;
      End;
End;

Function TPolygon.MinCol: Integer;
Var i,MC: Integer;
Begin
  If svMinCol <> -9999
    then MinCol := svMinCol
    else
      Begin
        MC := High(Integer);
        For i := 0 to NumPts-1 do
          If TPoints[i].x < MC then MC := TPoints[i].x;
        MinCol := MC;
        svMinCol := MC;
      End;
End;

Function TPolygon.MaxCol: Integer;
Var i,MC: Integer;
Begin
  If svMaxCol <> -9999
    then MaxCol := svMaxCol
    else
      Begin
        MC := Low(Integer);
        For i := 0 to NumPts-1 do
          If TPoints[i].x > MC then MC := TPoints[i].x;
        MaxCol := MC;
        svMaxCol := MC;
      End;
End;


Function TPolygon.InPoly(Row,Col: Integer):Boolean;
Var ThisP: TPoint;

{*************************************************************************
 * FUNCTION:   G_PtInPolygon
 *
 * PURPOSE
 * This routine determines if the point passed is in the polygon. It uses
 * the classical polygon hit-testing algorithm: a horizontal ray starting
 * at the point is extended infinitely rightwards and the number of
 * polygon edges that intersect the ray are counted. If the number is odd,
 * the point is inside the polygon.
 *
 *************************************************************************}

    {*************************************************************************
     * FUNCTION:   PtInPolyRect
     *
     * PURPOSE
     * This routine determines if a point is within the smallest rectangle
     * that encloses a polygon.  Optimized 9/25/2012 JSC
     *
     *************************************************************************}

{    function PtInPolyRect(ptTest: TPoint; var prbound: TRect): Boolean;
    var
      pt: TPoint;
      i: Word;
    begin
       prbound := Rect(MinCol, MinRow, MaxCol, MaxRow);
       Result := PtInRect(prbound,ptTest);
    end; }

    function PtInPolyRect: Boolean;
    begin
       Result := (Row>=MinRow) and (Row<=MaxRow) and
                 (Col>=MinCol) and (Col<=MaxCol);
    end;

    Function G_PtInPolygon:Boolean;
    var
      i: Integer;
      pt2: TPoint;
      wnumintsct: Word;
    begin
      Result := False;
      if not PtInPolyRect then Exit;

      wnumintsct := 0;
      pt2 := ThisP;
      pt2.x := MaxCol+50;

      // Now go through each of the lines in the polygon and see if it intersects
      for i := 0 to High(TPoints)-1 do
        if(Intersect(ThisP,pt2,TPoints[i],TPoints[i+1]))then
          Inc(wnumintsct);
      // And the last line
      if(Intersect(ThisP, pt2, TPoints[High(TPoints)],TPoints[0]))then
         Inc(wnumintsct);
      // If wnumintsct is odd then the point is inside the polygon
      Result := Odd(wnumintsct);
    end;

Begin
  InPoly := False;
  If TPoints = nil then Exit;     
  If Length(TPoints) > NumPts then SetLength(TPoints,NumPts);
  ThisP.X := Col; ThisP.Y := Row;
  InPoly := G_PtInPolygon;
End;



Constructor TFWFlow.Load(ReadVersionNum : Double; TS: TStream);
var i: integer;
    Junk: Double;

    Directionality: Double;  // throw away BI Migration
    MigrRate : Double;     // throw away BI Migration

Begin

  If (ReadVersionNum > 6.865) and (ReadVersionNum < 6.875)
     Then
       Begin
          TSRead('Name',Name,ReadVersionNum);
          TSRead('Directionality',Directionality);
          TSRead('MigrRate',MigrRate);
          SavePoly := TPolygon.Create;
          SavePoly.Load(ReadVersionNum, TS, True);

          Exit;
       End;

  TSRead('Name',Name,ReadVersionNum);
  If ReadVersionNum < 6.025 then TSRead('Junk',Junk);
  SavePoly := TPolygon.Create;

  If ReadVersionNum < 6.375 then
    Begin
      TSRead('Poly.NumPts',SavePoly.NumPts);
      SetLength(SavePoly.TPoints,SavePoly.NumPts);
    End;

  If ReadVersionNum > 6.025 then
    Begin
      TSRead('UseTurbidities',UseTurbidities);

      if ReadVersionNum > 6.265 then
        Begin
          TSRead('SWPPT',SWPPT);
          TSRead('FWPPT',FWPPT);
          If ReadVersionNum > 6.305
            then TSRead('Origin_KM',Origin_KM)
            else Begin
                   TSRead('SWedge_Z',Origin_KM);
                   Origin_KM := 0;
                 End;
        End
      else
        Begin
          TSRead('SalPPT',FWPPT);   //SalPPT was the old variable name for fresh water ppt
          SWPPT := 30;
          Origin_KM := 0;
        End;

      TSRead('NTurbidities',NTurbidities);
      SetLength(Turbidities,NTurbidities);
      For i := 0 to NTurbidities-1 do
        Begin
          TSRead('Turbidities[i].Year',Turbidities[i].Year);
          TSRead('Turbidities[i].Value',Turbidities[i].Value);
        End;
      TSRead('NFlows',NFlows);
      SetLength(MeanFlow,NFlows);
      For i := 0 to NFlows-1 do
        Begin
          TSRead('MeanFlow[i].Year',MeanFlow[i].Year);
          TSRead('MeanFlow[i].Value',MeanFlow[i].Value);
        End;
      TSRead('ManningsN',ManningsN);
      TSRead('FlWidth',FlWidth);
      TSRead('SaltWedgeSlope',InitSaltWedgeSlope);
    End
  else  {readversionNum <= 6.025}
      Begin
        UseTurbidities := True;
        FWPPT := 0;
        SWPPT := 30;
        Origin_KM := 0;
        NTurbidities := 1;
        SetLength(Turbidities,NTurbidities);
        TSRead('Turbidities[0].Value',Turbidities[0].Value);
        Turbidities[0].Year := 2000;
        NFlows := 0;
        MeanFlow := Nil;
        ManningsN := 0;
        FlWidth := 0;
        InitSaltWedgeSlope := 1e-5;
      End;

  If ReadVersionNum > 6.205
     then TSRead('ExtentOnly',ExtentOnly)
     else ExtentOnly := False;

  TSRead('TSElev',TSElev);

  SavePoly.Load(ReadVersionNum, TS, ReadVersionNum>6.375);

  TSRead('NumSegments',NumSegments);
  SetLength(OriginArr,NumSegments);
  SetLength(MouthArr,NumSegments);

  For i := 1 to NumSegments do
    Begin
      TSRead('OriginArr[i-1].x',OriginArr[i-1].x);
      TSRead('OriginArr[i-1].y',OriginArr[i-1].y);
      TSRead('MouthArr[i-1].x',MouthArr[i-1].x);
      TSRead('MouthArr[i-1].y',MouthArr[i-1].y);
    End;

  TSRead('SW_Z_Data',SW_Z_Data);
  TSRead('SW_Z_Mouth',SW_Z_Mouth);

  If ReadVersionNum < 6.025 then
    Begin
      TSRead('Junk',Junk {Salt_Brack});     {Frac Fresh Bounds}
      TSRead('Junk',Junk {Brack_TFresh});
      TSRead('Junk',Junk {TFresh_TSwamp});
    End;

  Plume := nil;
  Vect := nil;
  MidPts := nil;

  D2Origin := nil;
  For i := 1 to 3 do
   Begin
    RetTime[i] := nil;
    WaterZ[i] := nil;
    XS_Salinity[i] := nil;
   End;

  OriginLine := nil;
  PlumeLine := nil;
  MaxRn := 0;
  TestMin := 0; TestRange := 0;

  OceanSubsite := nil;
  RetentionInitialized := False;
End;


function TFWFlow.SaltHeight(TideHeight, SLR: Double; RSeg, Yr: Integer): Double;
Var MRn: Double;
    OR2: Double;
begin
  OR2 := ORIGIN_KM;
  If OR2 < 0.05 then OR2 := MaxRn * SliceIncrement;

  OR2 := OR2 - ((TideHeight+SLR)* 4.82);  // JSC 7/27/2012  Relationship of 4.82 km on salt wedge origin per meter of tide height derived from GA data.
                    {m}     {m}
  Mrn := (OR2/SliceIncrement);
          {km}    {km/n}

  SaltHeight := TideHeight -(Mrn - RSeg) * SliceIncrement  * 1000 * SaltWedgeSlopeByYear(Yr) ;
  {m to mtl}      {m}        {n}   {n}        {km}          {m/km}      {m/m}
end;

Procedure TFWFlow.Store;
var i: integer;
Begin
  TSWrite('Name',Name);

  TSWrite('UseTurbidities',UseTurbidities);
  TSWrite('SWPPT',SWPPT);
  TSWrite('FWPPT',FWPPT);
  TSWrite('Origin_KM',Origin_KM);

  TSWrite('NTurbidities',NTurbidities);
  For i := 0 to NTurbidities-1 do
    Begin
      TSWrite('Turbidities[i].Year',Turbidities[i].Year);
      TSWrite('Turbidities[i].Value',Turbidities[i].Value);
    End;
  TSWrite('NFlows',NFlows);
  For i := 0 to NFlows-1 do
    Begin
      TSWrite('MeanFlow[i].Year',MeanFlow[i].Year);
      TSWrite('MeanFlow[i].Value',MeanFlow[i].Value);
    End;
  TSWrite('ManningsN',ManningsN);
  TSWrite('FlWidth',FlWidth);

  TSWrite('SaltWedgeSlope',InitSaltWedgeSlope);

  TSWrite('ExtentOnly',ExtentOnly);
  TSWrite('TSElev',TSElev);

  SavePoly.Store;

  TSWrite('NumSegments',NumSegments);
  For i := 1 to NumSegments do
    Begin
      TSWrite('OriginArr[i-1].x',OriginArr[i-1].x);
      TSWrite('OriginArr[i-1].y',OriginArr[i-1].y);
      TSWrite('MouthArr[i-1].x',MouthArr[i-1].x);
      TSWrite('MouthArr[i-1].y',MouthArr[i-1].y);
    End;

  TSWrite('SW_Z_Data',SW_Z_Data);
  TSWrite('SW_Z_Mouth',SW_Z_Mouth);

End;


function TFWFlow.SaltWedgeSlopeByYear(Yr: Integer): Double;
Var DeltaFlow: Double;
Begin
  DeltaFlow := FlowByYear(Yr) - FlowByYear(0);        {cfs}
  SaltWedgeSlopeByYear := InitSaltWedgeSlope + DeltaFlow * 2.8E-7;
               {relationship of 2.8E-7 in slope per CFS derived from four GA rivers}

End;


function TFWFlow.FlowByYear(Yr: Integer): Double;

Var PReadArr : PTSRArray;
    PCount : PInteger;
    i: Integer;
    Found: Boolean;
begin
  Result := 0; {not used}

  PCount := @NFlows;
  PReadArr := @MeanFlow;

  If PCount^ = 0 then Raise ESLAMMError.Create('Flow Time-Series Data Missing.');

  Found := False;
  If (PCount^=1) or (Yr < PReadArr^[0].Year)
    then Begin
           Result := PReadArr^[0].Value;
           Found := True;
         End
    else For i := 0 to PCount^-1 do
      If (Yr=PReadArr^[i].Year)
        then Begin
               Result := PReadArr^[i].Value;
               Found := True;
               Break;
             End
        else if (Yr < PReadArr^[i].Year)
           then Begin
                  Result := LinearInterpolate(PReadArr^[i-1].Value,PReadArr^[i].Value,
                                              PReadArr^[i-1].Year,PReadArr^[i].Year,Yr,False);
                  Found := True;
                  Break;
                End;

  If Not Found then Result := PReadArr^[PCount^-1].Value;  {year greater than all data, choose last point}
end;



function TFWFlow.TurbidityByYear(Yr: Integer): Double;

Var PReadArr : PTSRArray;
    PCount : PInteger;
    i: Integer;
    Found: Boolean;
begin
  Result := 1.0;
  If not UseTurbidities then  Exit;

  PReadArr := @Turbidities;
  PCount := @NTurbidities;

  If PCount^ = 0 then Raise ESLAMMError.Create('Turbidity Time-Series Data Missing.');

  Found := False;
  If (PCount^=1) or (Yr < PReadArr^[0].Year)
    then Begin
           Result := PReadArr^[0].Value;
           Found := True;
         End
    else For i := 0 to PCount^-1 do
      If (Yr=PReadArr^[i].Year)
        then Begin
               Result := PReadArr^[i].Value;
               Found := True;
               Break;
             End
        else if (Yr < PReadArr^[i].Year)
           then Begin
                  Result := LinearInterpolate(PReadArr^[i-1].Value,PReadArr^[i].Value,
                                              PReadArr^[i-1].Year,PReadArr^[i].Year,Yr,False);
                  Found := True;
                  Break;
                End;

  If Not Found then Result := PReadArr^[PCount^-1].Value;  {year greater than all data, choose last point}
end;


Destructor TFWFlow.Destroy;
Var i: Integer;
Begin
  FTables := nil;
  SubsiteArr := nil;
  For i := 1 to 3 do
   Begin
    RetTime[i] := nil;
    WaterZ[i] := nil;
    XS_Salinity[i] := nil;
   End;

  NumCells := nil;
  D2Origin := nil;

  Plume := nil;
  Vect := nil;
  MidPts := nil;
  OriginLine := nil;
  PlumeLine := nil;

  inherited;
End;


Procedure TFWFlow.CellByRN(RSeg: Integer; Var OutR, OutC: Integer);
Var i: Integer;
    Distance: Double;
    Found:Boolean;
    FracLine: Double;
Begin
  Distance := RSeg*SliceIncrement;
  Found := False;
  for i := 1 to numsegments -1 do
   If Distance <= D2Origin[i] then
     Begin
       FracLine := (Distance - D2Origin[i-1])/(D2Origin[i]-D2Origin[i-1]);  // fraction along line of RSeg
       OutC := OriginArr[i-1].X + Round((MouthArr[i-1].X-OriginArr[i-1].X)*FracLine);
       OutR := OriginArr[i-1].Y + Round((MouthArr[i-1].Y-OriginArr[i-1].Y)*FracLine);
       Found := True;
       Break;
     End;

     If Not Found then   //extrapolate into plume
       Begin
         FracLine := (Distance - D2Origin[numsegments-1])/(EstuaryLength - D2Origin[numsegments-1]);  // fraction along line of RSeg
         OutC := OriginArr[numsegments-1].X + Round((MouthArr[numsegments-1].X-OriginArr[numsegments-1].X)*FracLine);
         OutR := OriginArr[numsegments-1].Y + Round((MouthArr[numsegments-1].Y-OriginArr[numsegments-1].Y)*FracLine);
       End;

End;


function TFWFlow.ElevByVolume(VolWat: Double; RSeg: Integer): Double;
Var MinElev,MaxElev, MinVol, MaxVol: Double;
    i: Integer;
begin
  Result := 0; {not used}
  If FTables[RSeg][0] > VolWat  {water is all below test interval, assign lowest elevation tested}
       then Result := TestMin
       else If FTables[RSeg][N_FTable-1] < VolWat
         then Result := TestMin + TestRange {water does not fit in all tested regions, assign highest elev tested}
         else For i := 1 to N_FTable-1 do
           if FTables[RSeg][i] > VolWat then
             Begin
               MinElev :=  TestMin + (TestRange / (N_FTable-1))*(i-1);
               MaxElev :=  TestMin + (TestRange / (N_FTable-1))*i;
               MinVol := FTables[RSeg][i-1];
               MaxVol := FTables[RSeg][i];
               Result := LinearInterpolate(MinElev,MaxElev,MinVol,MaxVol,VolWat,False);
               Break;
             End; {if}
end;

function TFWFlow.VolumeByElev(Elev: Double; RSeg: Integer): Double;
Var FTHeight: Double;
    MinElev,MaxElev, MinVol, MaxVol: Double;
    i: Integer;
begin
  Result := 0; {not used}
  If (Elev<TestMin)
    then Result := FTables[RSeg][0]  {elev below minimum in table, assign lowest volume}
    else if (Elev>TestMin+TestRange)
      then Result := FTables[RSeg][N_FTable-1] {elev above maximum in table, assign highest volume}
      else For i := 1 to N_FTable-1 do
        Begin
          FTHeight := TestMin + (TestRange / (N_FTable-1))*i;
          If Elev<FTHeight then
            Begin
               MinElev :=  TestMin + (TestRange / (N_FTable-1))*(i-1);
               MaxElev :=  FTHeight;
               MinVol := FTables[RSeg][i-1];
               MaxVol := FTables[RSeg][i];
               Result := LinearInterpolate(MinVol,MaxVol,MinElev,MaxElev,Elev,False);
               Break;
            End;
        End;
end;



{-----------------------------------------------------------------}

Constructor TSite.Create;
Begin
  SubSites := nil;
  OutputSites := Nil;
  ROSBounds := Nil;
  GlobalSite := TSubSite.Create;
End;

Destructor TSite.Destroy;
Var i: Integer;
Begin
  For i := 0 to NSubSites-1 do
    If SubSites[i]<>nil then SubSites[i].Destroy;

  If GlobalSite<>nil then GlobalSite.Destroy;

  SubSites := nil;
  For i := 0 to NOutputSites-1 do
   With OutputSites[i] do
    Begin
      if ScalePoly <> SavePoly then OutputSites[i].ScalePoly.Free;
      ScalePoly := nil;
      SavePoly.Free;
      SavePoly := nil;
    End;


  OutputSites := Nil;
  ROSBounds := Nil;

  inherited;
End;


Procedure TSite.LoadSubSite(ReadVersionNum: Double; TS: TStream; Var SS: TSubSite);

Var i, LT: Integer;
    OffshoreText: String;
    OffshoreChar: Char;
    Junk: Double;

Begin
 SS := TSubSite.Create;

 With SS do
  Begin
    SavePoly.Load(ReadVersionNum, TS,True);

     TSRead('Description',Description,ReadVersionNum);
     If Length(Description) > 100 then Description := '';  //fix copy and paste errors resulting in descriptions with too many characters.

      TSRead('NWI_Photo_Date',NWI_Photo_Date);
      TSRead('DEM_date',DEM_date);

      If TSText then
          Begin
            TSRead('Direction_Offshore',OffShoreText,ReadVersionNum);
            OffshoreText := Uppercase(OffShoreText);
            OffShoreChar := OffShoreText[1];
            Case OffShoreChar of
              'N' : Direction_OffShore := Northerly;
              'S' : Direction_OffShore := Southerly;
              'E' : Direction_OffShore := Easterly;
              else  Direction_OffShore := Westerly;
            End; {Case}
          End
        else TS.Read(Direction_OffShore, Sizeof(Direction_Offshore));

      TSRead('Historic_trend',Historic_trend);
      if ReadVersionNum > 6.675 then
        TSRead('Historic_Eustatic_trend',Historic_Eustatic_trend)
      else
        Historic_Eustatic_trend := 1.7; //mm/yr

      TSRead('NAVD88MTL_correction',NAVD88MTL_correction);
      TSRead('GTideRange',GTideRange);
      TSRead('SaltElev',SaltElev);

      //Inundation Elevation
      if ReadVersionNum > 6.885 then
        begin
          TSRead('30D Inundation', InundElev[0]);
          TSRead('60D Inundation', InundElev[1]);
          TSRead('90D Inundation', InundElev[2]);
          TSRead('Storm Inundation 1', InundElev[3]);
          TSRead('Storm Inundation 2', InundElev[4]);
        end
      else if (ReadVersionNum > 6.665) and (ReadVersionNum < 6.885) then
        begin
          if ReadVersionNum < 6.745 then
            TSRead('30D Inundation', InundElev[0])
          else if ReadVersionNum < 6.765 then
            InundElev[0] := SaltElev
          else
            TSRead('30D Inundation', InundElev[0]);

          TSRead('60D Inundation', InundElev[1]);
          TSRead('90D Inundation', InundElev[2]);
          TSRead('Storm Inundation', InundElev[3]);
          InundElev[4] := InundElev[3] + 1 ;
        end
      else
        begin
          InundElev[0] := SaltElev ;
          InundElev[1] := SaltElev * 1.2 ;          // Default, Arbitratry 120% of salt elevation
          InundElev[2] := SaltElev * 1.4 ;          // Default, Arbitratry 140% of salt elevation
          InundElev[3] := (GTideRange / 2) + 1.0 ;  // Default 1 m of storm surge at MHHW
          InundElev[4] := InundElev[3] + 1;
        end;

      TSRead('MarshErosion',MarshErosion);
      TSRead('SwampErosion',SwampErosion);
      TSRead('TFlatErosion',TFlatErosion);
      TSRead('FixedRegFloodAccr',FixedRegFloodAccr);
      TSRead('FixedIrregFloodAccr',FixedIrregFloodAccr);
      TSRead('FixedTideFreshAccr',FixedTideFreshAccr);

      IF ReadVersionNum > 6.245 then
        Begin
          TSRead('InlandFreshAccr',InlandFreshAccr);
          TSRead('MangroveAccr',MangroveAccr);
          TSRead('TSwampAccr', TSwampAccr);
          TSRead('SwampAccr',SwampAccr);
        End
      Else
        Begin
          InlandFreshAccr := FixedTideFreshAccr;
          MangroveAccr := 7.0; {default}
          TSwampAccr := 1.1 ;  {default}
          SwampAccr := 0.3 ;   {default}
        End;

      If ReadVersionNum > 6.915 then
        Begin
          TSRead('IFM2RFM_Collapse', IFM2RFM_Collapse);
          TSRead('RFM2TF_Collapse',RFM2TF_Collapse);
        End
      Else
        Begin
          RFM2TF_Collapse := 0;
          IFM2RFM_Collapse := 0;
        End;

      TSRead('Fixed_TF_Beach_Sed',Fixed_TF_Beach_Sed);
(*    If ReadVersionNum < 6.255
        then Begin
               TSRead('Freq_BigStorm',Freq_BigStormInt);
               Freq_BigStorm := Freq_BigStormInt;            Read SLAMM6
             End
        else TSRead('Freq_BigStorm',Freq_BigStorm);  *)


      TSRead('Use_Preprocessor',Use_Preprocessor);

      TSRead('USE_Wave_Erosion',USE_Wave_Erosion);    // new to 6.7
      TSRead('WE_Alpha',WE_Alpha);                    // new to 6.7
      TSRead('WE_Has_Bathymetry',WE_Has_Bathymetry);  // new to 6.7
      TSRead('WE_Avg_Shallow_Depth',WE_Avg_Shallow_Depth);  // new to 6.7

      If ReadVersionNum > 6.965 then
       Begin
         TSRead('LagoonType',LT);                        // new to 6.7
         LagoonType := TLagoonType(LT);
         TSRead('ZBeachCrest',ZBeachCrest);              // new to 6.7
         TSRead('LBeta',LBeta);                          // new to 6.7
       End
         else {pre 6.97}
           Begin
             LagoonType := LtNone;
             ZBeachCrest := 0;
             LBeta := 0;
           End;

(*      TSRead('OW_Max_Width_Overwash',OW_Max_Width_Overwash);
      TSRead('OW_Beach_to_Ocean',OW_Beach_to_Ocean);
      TSRead('OW_Dryland_to_Beach',OW_Dryland_to_Beach);
      TSRead('OW_Est_to_Beach',OW_Est_to_Beach);
      TSRead('OW_Marsh_Pct_Loss',OW_Marsh_Pct_Loss);
      TSRead('OW_Mang_Pct_Loss',OW_Mang_Pct_Loss);   Read SLAMM6  *)

      For i := 0 to N_ACCR_MODELS-1 do
       If ReadVersionNum < 6.025
        then
          Begin
            UseAccrModel[i] := False;  {boolean}
            MaxAccr[i] := 0;  {mm/year}
            MinAccr[i] := 0; {mm/year}
            AccrA[i] := 0; {unitless}
            AccrB[i] := 0; {unitless}
            AccrC[i] := 0; {unitless}
            AccrD[i] := 0; {unitless}
(*          DistEffectMax[i] := 0; {meters}
            Dmin[i] := 1; {unitless scaling factor, set to 1.0 to ignore distance factor}
            SalinityTMax[i] := 0; {ppt}
            STMaxZone[i] := 0; {ppt}
            SNonTMax[i] := 1; {unitless multiplier, set to one to ignore salinity} *)

            AccrNotes[i] := '';
          End
        else
          Begin
            TSRead('UseAccrModel[i]',UseAccrModel[i]);
            TSRead('MaxAccr[i]',MaxAccr[i]);
            TSRead('MinAccr[i]',MinAccr[i]);
            TSRead('AccrA[i]',AccrA[i]);
            TSRead('AccrB[i]',AccrB[i]);
            If ReadVersionNum > 6.035
              then TSRead('AccrC[i]',AccrC[i])
              else AccrC[i] := 0;
            if ReadVersionNum > 6.735
              then TSRead('AccrD[i]',AccrD[i])
              else Begin
                     AccrD[i] := 0;
                     TSRead('DistEffectMax[i]',Junk);
                     TSRead('Dmin[i]',Junk);
                     TSRead('SalinityTMax[i]',Junk);
                     TSRead('STMaxZone[i]',Junk);
                     TSRead('SNonTMax[i]',Junk);
                     if UseAccrModel[i] and Not ShowAccrUpdateWarning then
                       Begin
                         ShowMessage('IMPORTANT WARNING.  Accretion feedback parameters in SLAMM 6.5+ have changed.  Your old accretion parameters will not work. '+
                                     'To fix this, use the Old2New tab in SLAMM6_Accretion_Release_6.5.xlsx.');
                         ShowAccrUpdateWarning := True;
                       End;
                   End;

            TSRead('AccrNotes[i]',AccrNotes[i],ReadVersionNum);
          End;
  End;
End;

Procedure TSite.StoreSubSite(Var TS: TStream; Var SS: TSubSite);
Var i: Integer;
Begin
 With SS do
  Begin
    SavePoly.Store;

      TSWrite('Description',Description);
//    TSWrite('Depth',Depth);
      TSWrite('NWI_Photo_Date',NWI_Photo_Date);
      TSWrite('DEM_date',DEM_date);

      If TSText then
          Begin
            Case Direction_OffShore of
              Northerly : TSWrite('Direction_Offshore','Northerly');
              Southerly : TSWrite('Direction_Offshore','Southerly');
              Easterly : TSWrite('Direction_Offshore','Easterly');
              else  TSWrite('Direction_Offshore','Westerly');
            End; {Case}
          End
        else TS.Write(Direction_OffShore, Sizeof(Direction_Offshore));

      TSWrite('Historic_trend',Historic_trend);
      TSWrite('Historic_Eustatic_trend',Historic_Eustatic_trend);
      TSWrite('NAVD88MTL_correction',NAVD88MTL_correction);
      TSWrite('GTideRange',GTideRange);
      TSWrite('SaltElev',SaltElev);

//    TSWrite('30D Inundation', InundElev[0]);    // 9/30/2013 no inundelev[0] redundant with salt elev
      TSWrite('30D Inundation', InundElev[0]);    // 12/5/2013 To add 4 different elevations
      TSWrite('60D Inundation', InundElev[1]);
      TSWrite('90D Inundation', InundElev[2]);
      TSWrite('Storm Inundation 1', InundElev[3]);
      TSWrite('Storm Inundation 2', InundElev[4]);

      TSWrite('MarshErosion',MarshErosion);
      TSWrite('SwampErosion',SwampErosion);
      TSWrite('TFlatErosion',TFlatErosion);
      TSWrite('FixedRegFloodAccr',FixedRegFloodAccr);
      TSWrite('FixedIrregFloodAccr',FixedIrregFloodAccr);
      TSWrite('FixedTideFreshAccr',FixedTideFreshAccr);

      TSWrite('InlandFreshAccr',InlandFreshAccr);  // New 5/20/2011
      TSWrite('MangroveAccr',MangroveAccr);
      TSWrite('TSwampAccr', TSwampAccr);
      TSWrite('SwampAccr',SwampAccr);

      TSWrite('IFM2RFM_Collapse', IFM2RFM_Collapse);
      TSWrite('RFM2TF_Collapse',RFM2TF_Collapse);

      TSWrite('Fixed_TF_Beach_Sed',Fixed_TF_Beach_Sed);

      TSWrite('Use_Preprocessor',Use_Preprocessor);

      TSWrite('USE_Wave_Erosion',USE_Wave_Erosion);    // new to 6.7
      TSWrite('WE_Alpha',WE_Alpha);                    // new to 6.7
      TSWrite('WE_Has_Bathymetry',WE_Has_Bathymetry);  // new to 6.7
      TSWrite('WE_Avg_Shallow_Depth',WE_Avg_Shallow_Depth);  // new to 6.7

      TSWrite('LagoonType',ORD(LagoonType));           // new to 6.7
      TSWrite('ZBeachCrest',ZBeachCrest);              // new to 6.7
      TSWrite('LBeta',LBeta);                          // new to 6.7

      For i := 0 to N_ACCR_MODELS-1 do
        Begin
          TSWrite('UseAccrModel[i]',UseAccrModel[i]);
          TSWrite('MaxAccr[i]',MaxAccr[i]);
          TSWrite('MinAccr[i]',MinAccr[i]);
          TSWrite('AccrA[i]',AccrA[i]);
          TSWrite('AccrB[i]',AccrB[i]);
          TSWrite('AccrC[i]',AccrC[i]);
          TSWrite('AccrD[i]',AccrD[i]);

(*        TSWrite('DistEffectMax[i]',DistEffectMax[i]);
          TSWrite('Dmin[i]',Dmin[i]);
          TSWrite('SalinityTMax[i]',SalinityTMax[i]);
          TSWrite('STMaxZone[i]',STMaxZone[i]);
          TSWrite('SNonTMax[i]',SNonTMax[i]); *)

          TSWrite('AccrNotes[i]',AccrNotes[i]);
        End;

  End;
End;

Constructor TSite.Load(ReadVersionNum: Double; TS: TStream);
Var  i: Integer;
Begin
  TSRead('Rows',ReadRows);
  TSRead('Cols',ReadCols);
  TSRead('LLXCorner',LLXCorner);
  TSRead('LLYCorner',LLYCorner);
  TSRead('Scale',ReadScale);

  TSRead('NSubSites',NSubSites);
  SetLength(SubSites,NSubSites);
  ShowAccrUpdateWarning := False;
  For i := 0 to NSubSites-1 do
      LoadSubSite(ReadVersionNum,TS,Subsites[i]);

  TSRead('NOutputSites',NOutputSites);

  SetLength(OutputSites,NOutputSites);
  For i := 0 to NOutputSites-1 do
     With OutputSites[i] do
      Begin
        UsePolygon := False;
        If ReadVersionNum > 6.355 then TSRead('UsePolygon',UsePolygon);
        If UsePolygon then SavePoly := TPolygon.Load(ReadVersionNum, TS,True);
        TSRead('X1',SaveRec.X1);
        TSRead('Y1',SaveRec.Y1);
        TSRead('X2',SaveRec.X2);
        TSRead('Y2',SaveRec.Y2);
        TSRead('Description',Description,ReadVersionNum);
      End;

  LoadSubSite(ReadVersionNum,TS,GlobalSite);
End;


Procedure TSite.Store(Var TS: TStream);
Var  i: Integer;
Begin
  TSWrite('Rows',ReadRows);
  TSWrite('Cols',ReadCols);
  TSWrite('LLXCorner',LLXCorner);
  TSWrite('LLYCorner',LLYCorner);
  TSWrite('Scale',ReadScale);

  TSWrite('NSubSites',NSubSites);
{  SetLength(SubSites,NSubSites); }
  For i := 0 to NSubSites-1 do
      StoreSubSite(TS,Subsites[i]);

  TSWrite('NOutputSites',NOutputSites);
  For i := 0 to NOutputSites-1 do
     With OutputSites[i] do
      Begin
        TSWrite('UsePolygon',UsePolygon);
        If UsePolygon then SavePoly.Store;
        TSWrite('X1',SaveRec.X1);
        TSWrite('Y1',SaveRec.Y1);
        TSWrite('X2',SaveRec.X2);
        TSWrite('Y2',SaveRec.Y2);
        TSWrite('Description',Description);
      End;

  StoreSubSite(TS,GlobalSite);
End;

Function TSite.InOutSite(X {Col},Y {Row}:Integer; SiteNum: Integer): Boolean;  {Is this x,y in the output site?}
Begin
   With OutputSites[SiteNum-1] do
     If UsePolygon
       then Result := ScalePoly.InPoly(Y,X)
       else With ScaleRec do Result := (X>= Min(X1,X2)) and (X<=Max(X1,X2)) and (Y>=Min(Y1,Y2)) and (Y<=Max(Y1,Y2));
End;

Function TSite.GetSubSiteNum(X,Y:Integer; PC: pointer): Integer;

Begin
  if PCompressedCell(PC).SubsiteIndex <> -9999 then
    Result := PCompressedCell(PC).SubsiteIndex
  else
    Begin
      Result := GetSubSiteNum(X,Y);
      PCompressedCell(PC).SubsiteIndex := Result;     //subsite index assigned
    End;
End;

Function TSite.GetSubSiteNum(X,Y:Integer): Integer;
Var i: Integer;
Begin
  Result := 0;
  For i:=NSubSites downto 1  do
   With SubSites[i-1] do
    If ScalePoly.InPoly(y,x) then   //computationally costly
      Begin
        Result := i;
        Exit;
      End;
End;

Function TSite.GetSubSite(X,Y:Integer; PC: pointer): TSubSite;  {Subsite with highest number gets dominance}
Var i: Integer;
Begin
  i := GetSubSiteNum(X,Y,PC);
  IF i=0 then Result := GlobalSite
         else Result := SubSites[i-1];
End;

Function TSite.GetSubSite(X,Y:Integer): TSubSite;  {Subsite with highest number gets dominance}
Var i: Integer;
Begin
  i := GetSubSiteNum(X,Y);
  IF i=0 then Result := GlobalSite
         else Result := SubSites[i-1];

End;



Function TSite.T0: Integer; {Latest NWI_Photo_Date}
Var i, Latest: Integer;
Begin
  Latest := GlobalSite.NWI_Photo_Date;
  For i:=0 to NSubSites-1 do
   If SubSites[i].NWI_Photo_Date > Latest then
     Latest := SubSites[i].NWI_Photo_Date;

  Result := Latest;
End;

Function TSite.TideOc(X,Y: Integer): Double;
Begin
  TideOc := GetSubSite(X,Y).GTideRange;
End;


{**************************************************}
{    Set site constants for elev. ranges           }
{         R. A. Park    3/16/88                    }
{ MOD JSC, Change Ranges based on LIDAR, 2006-2007 }
{**************************************************}
Procedure TSite.InitElevVars;

  Procedure SetSubSiteRanges(Var SS: TSubSite);
  Begin
   With SS do
     Begin
       MLLW := MTL - GTideRange/2.0;    {Mean Lower Low Water}
       MHHW := GTideRange/2.0;          {Mean Higher High Water}
     End;
  End;

Var i: Integer;
Begin
  SetSubSiteRanges(GlobalSite);
  For i := 0 to NSubSites-1 do
    SetSubSiteRanges(SubSites[i]);

End;


Procedure TSite.AddOutputSite;
Begin
  Inc(NOutputSites);
  If NOutputsites > Length(OutputSites) then
    SetLength(OutputSites,NOutputsites+5);

  With OutputSites[NOutputsites-1] do
    Begin
      Description := 'OutputSite '+IntToStr(NOutputSites);
      SavePoly := nil;
      ScalePoly := nil;
      UsePolygon := False; //Upgrade allow for user drawn polygon outputs sites eventually
      SaveRec.X1 := -99;
      SaveRec.Y1 := -99;
      SaveRec.X2 := -99;
      SaveRec.Y2 := -99;
    End;

End;


Procedure TSite.AddSubSite;
Begin
  Inc(NSubSites);
  If NSubsites > Length(SubSites) then
    SetLength(SubSites,NSubsites+5);

  SubSites[NSubsites-1] := TSubSite.Createwith(GlobalSite);
  With SubSites[NSubsites-1] do
    Begin
      Description := 'SubSite '+IntToStr(NSubSites);
      SavePoly.NumPts := 0;
      SavePoly.TPoints := nil;
    End;

End;

Procedure TSite.DelSubSite(Index: Integer); {indexed to zero}
Var i: Integer;
Begin
  SubSites[Index].Description := 'Baleeted';
  SubSites[Index].Destroy;
  For i:= Index to NSubSites-2 do
     SubSites[i] := SubSites[i+1];
  Dec(NSubSites);
End;

Procedure TSite.DelOutputSite(Index: Integer); {indexed to zero}
Var i: Integer;
Begin
  OutputSites[Index].Description := 'Baleeted';
  For i:= Index to NOutputSites-2 do
     OutputSites[i] := OutputSites[i+1];
  Dec(NOutputSites);
End;


Function CopyFile(Src,Dst: String): Boolean;
{Copy a file from the source to the destination paths indicated,
 Copied out of Delphi Help under BlockRead}

        procedure CardinalsToI64(var I: Int64; const LowPart, HighPart: Cardinal);
        begin
          TULargeInteger(I).LowPart := LowPart;
          TULargeInteger(I).HighPart := HighPart;
        end;

Var Source,Dest: File;
    NumRead,NumWritten: Integer;
    TotalNumWritten: Int64;
    Buf: array[1..32768] of Char;

Begin
  CopyFile:=True;
  TotalNumWritten:=0;
     Try
         AssignFile(Source,Src);
         AssignFile(Dest,Dst);
         Reset(Source,1);

         Rewrite(Dest,1);
         Repeat
           Blockread(Source,Buf,Sizeof(Buf),NumRead);
           Blockwrite(Dest,Buf,NumRead,NumWritten);
           TotalNumWritten:=TotalNumWritten+NumWritten;
         Until (NumRead=0) or (NumWritten<>NumRead);
         System.CloseFile(Source);
         System.CloseFile(Dest);
      Except
         Raise ESLAMMERROR.Create('File Copy Error:  '+src+'  to  '+dst);
         CopyFile:=False;
      end; {try}
End;

{ TSubSite }

constructor TSubSite.Create;
Var i: Integer;
begin
  SavePoly := TPolygon.Create;
  ScalePoly := nil;

  USE_Wave_Erosion := False;
  WE_Alpha := 0;
  WE_Has_Bathymetry:= False;
  WE_Avg_Shallow_Depth := 1.0;
  LagoonType := LtNone;
  ZBeachCrest := 0;
  LBeta := 0;

  For i := 0 to N_ACCR_MODELS-1 do
     Begin
       UseAccrModel[i] := False;  {boolean}
       MaxAccr[i] := 0;  {mm/year}
       MinAccr[i] := 0; {mm/year}
       AccrA[i] := 0; {unitless}
       AccrB[i] := 0; {unitless}
       AccrC[i] := 0; {unitless}
       AccrD[i] := 0; {unitless}
       AccRescaled[i] := False;
       RAccrA[i] := 0; {unitless}
       RAccrB[i] := 0; {unitless}
       RAccrC[i] := 0; {unitless}
       RAccrD[i] := 0; {unitless}

(*     DistEffectMax[i] := 0; {meters}
       Dmin[i] := 1; {unitless scaling factor, set to 1.0 to ignore distance factor}
       SalinityTMax[i] := 0; {ppt}
       STMaxZone[i] := 0; {ppt}
       SNonTMax[i] := 1; {unitless multiplier, set to one to ignore salinity} *)

       AccrNotes[i] := '';
     End;
end;

constructor TSubSite.CreateWith(TSS: TSubSite);
begin
    SavePoly := TPolygon.Create;
    ScalePoly := nil;
    Description    := TSS.Description;
    NWI_Photo_Date := TSS.NWI_Photo_Date;
    DEM_date       := TSS.DEM_date;
    Direction_OffShore   := TSS.Direction_OffShore;
    Historic_trend       := TSS.Historic_trend;
    Historic_Eustatic_trend := TSS.Historic_Eustatic_trend;
    NAVD88MTL_correction := TSS.NAVD88MTL_correction;
    GTideRange  := TSS.GTideRange;
    SaltElev    := TSS.SaltElev;
    InundElev := TSS.InundElev;

    MarshErosion := TSS.MarshErosion;
    SwampErosion := TSS.SwampErosion;
    TFlatErosion   := TSS.TFlatErosion;
    FixedRegFloodAccr := TSS.FixedRegFloodAccr;
    FixedIrregFloodAccr := TSS.FixedIrregFloodAccr;
    FixedTideFreshAccr := TSS.FixedTideFreshAccr;

    InlandFreshAccr:= TSS.InlandFreshAccr;
    MangroveAccr:= TSS.MangroveAccr;
    TSwampAccr:= TSS.TSwampAccr;
    SwampAccr:= TSS.SwampAccr;

    IFM2RFM_Collapse := TSS.IFM2RFM_Collapse;
    RFM2TF_Collapse  := TSS.RFM2TF_Collapse;

    Fixed_TF_Beach_Sed := TSS.Fixed_TF_Beach_Sed;

    Use_Preprocessor := TSS.Use_Preprocessor;

    USE_Wave_Erosion := TSS.USE_Wave_Erosion;
    WE_Alpha := TSS.WE_Alpha;
    WE_Has_Bathymetry := TSS.WE_Has_Bathymetry;
    WE_Avg_Shallow_Depth := TSS.WE_Avg_Shallow_Depth;

    LagoonType := TSS.LagoonType;
    ZBeachCrest := TSS.ZBeachCrest;
    LBeta  := TSS.LBeta ;


    UseAccrModel := TSS.UseAccrModel;
    MaxAccr := TSS.MaxAccr;
    MinAccr := TSS.MinAccr;
    AccrA := TSS.AccrA;
    AccrB := TSS.AccrB;
    AccrC := TSS.AccrC;
    AccrD := TSS.AccrD;
    AccRescaled := TSS.AccRescaled;
    RAccrA := TSS.RAccrA;
    RAccrB := TSS.RAccrB;
    RAccrC := TSS.RAccrC;
    RAccrD := TSS.RAccrD;

(*    DistEffectMax := TSS.DistEffectMax;
    Dmin := TSS.Dmin;
    SalinityTMax := TSS.SalinityTMax;
    STMaxZone := TSS.STMaxZone;
    SNonTMax := TSS.SNonTMax;  *)

    AccrNotes := TSS.AccrNotes;
end;

destructor TSubSite.Destroy;
begin
   if (ScalePoly <> SavePoly) then ScalePoly.Free;
   ScalePoly := nil;
   If SavePoly<>nil then SavePoly.Free;
   SavePoly := nil;
end;


Constructor TSalinityRule.Create;
Begin
  FromCat := -99; // Blank;
  ToCat := -99; //Blank;
  SalinityLevel := 30;
  GreaterThan := True;
  SalinityTide := 3;
  Descript := '';
End;


Constructor TSalinityRule.Load(ReadVersionNum: Double; TS: TStream);
Begin
  TSRead('FromCat',FromCat);      // pre 6.955 text file reading may balk
  TSRead('ToCat',ToCat);
  TSRead('SalinityLevel',SalinityLevel);
  If ReadVersionNum > 6.075
    then TSRead('GreaterThan',GreaterThan)
    else GreaterThan := True;
  TSRead('SalinityTide',SalinityTide);
  TSRead('Descript',Descript,ReadVersionNum);
End;

Procedure TSalinityRule.Store(Var TS: TStream);
Begin
  TSWrite('FromCat',FromCat);
  TSWrite('ToCat',ToCat);
  TSWrite('SalinityLevel',SalinityLevel);
  TSWrite('GreaterThan',GreaterThan);
  TSWrite('SalinityTide',SalinityTide);
  TSWrite('Descript',Descript);

End;



Constructor TSalinityRules.Create;
Begin
   NRules := 0;
   Rules := nil;

End;

Constructor TSalinityRules.Load(ReadVersionNum: Double; TS: TStream);
Var i: Integer;
Begin
  TSRead('NRules',NRules);
  SetLength(Rules,NRules);
  For i := 0 to NRules-1 do
    Rules[i] := TSalinityRule.Load(ReadVersionNum, TS);

End;

Procedure TSalinityRules.Store(Var TS: TStream);
Var i: Integer;
Begin
  TSWrite('NRules',NRules);
  For i := 0 to NRules-1 do
    Rules[i].Store(TS);
End;


Function IntInString(I: Integer; Str: String): Boolean;
Var NumberFound, EofFound: Boolean;
    Holder: String;
    Number: Integer;
Begin
  EofFound := False;
  NumberFound := False;
   Repeat
    Holder:=Trim(AbbrString(Str,','));
    if Holder <> '' then
      Begin
    Number := StrToInt(Holder);
    If Number = I then NumberFound:=True;
    If Pos(',',Str)= 0 then EofFound:=True
                             else Delete(Str,1,Pos(',',Str));
      End;
    If Trim(Str)='' then EofFound := True;
   Until EofFound or Numberfound;

   Result:=NumberFound;
End;

Function StringListValid(Str: String): Boolean;
Var EofFound: Boolean;
    Holder: String;
    Number: Integer;
Begin
   EofFound := False;
   Repeat
    Holder:=Trim(AbbrString(Str,','));
    if Holder <> '' then
      Begin
        Number := StrToInt(Holder);
        If Pos(',',Str)= 0 then EofFound:=True
                           else Delete(Str,1,Pos(',',Str));
      End;
    If Trim(Str)='' then EofFound := True;
   Until EofFound;

   Result:=EofFound;
End;


Function TranslateInundNum(InundIn: Integer): Integer;   // Translate into alternative integer output for rasters
Begin
    If InundIn = 8 then Result := 0    //Open water
    else If InundIn=30 then Result := 1       // H1 Elev 30 d inundation
    else If InundIn=60 then Result := 2       // H2 Elev 60 d inundation
    else If InundIn=90 then Result := 3       // H3 Elev 90 d inundation
    else If InundIn=120 then Result := 4      // H4 Elev Storm inundation 1
    else If InundIn=150 then Result := 5      // H5 Elev Storm inundation 2
    else If InundIn = 2 then Result := 6      // Above Storm elevation
    else If InundIn = 4 then Result := 7      // Below Storm elevation but not connected
    else If InundIn=7 then Result := 8        // Protected by dikes
    else If InundIn=10 then Result := 10      // Overtopped Dike Location
    else If InundIn =9 then Result := -99    // // no data/blank
    else Result := 11;
End;




Constructor TTimeSerSLR.Create;
Begin
  Name := 'New SLR Scenario';
  NYears := 0;
  RunNow := True;
  BaseYear := 1990;
  SetLength(SLRArr,5);
End;


Procedure TTimeSerSLR.Store(Var TS: TStream);
var i: integer;

Begin
  TSWrite('Name',Name);
  TSWrite('BaseYear',BaseYear);

  TSWrite('NYears',NYears);
  TSWrite('RunNow',RunNow);

  For i := 0 to NYears-1 do
    Begin
      TSWrite('SLRArr[i].Year',SLRArr[i].Year);
      TSWrite('SLRArr[i].Value',SLRArr[i].Value);
    End;

End;

Constructor TTimeSerSLR.Load(ReadVersionNum : Double; TS: TStream);
var i: integer;
Begin
  TSRead('Name',Name,ReadVersionNum);
  TSRead('BaseYear',BaseYear);

  TSRead('NYears',NYears);
  TSRead('RunNow',RunNow);

  SetLength(SLRArr,NYears);
  For i := 0 to NYears-1 do
    Begin
      TSRead('SLRArr[i].Year',SLRArr[i].Year);
      TSRead('SLRArr[i].Value',SLRArr[i].Value);
    End;

End;

Destructor TTimeSerSLR.Destroy;
Begin
  SLRArr := nil;
  inherited;
End;





end.
