//SLAMM SOURCE CODE copyright (c) 2009 - 2016, 2010 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

(*****************************************************)
(*                                                   *)
(*    SLAMM - SEA LEVEL AFFECTING MARSHES MODEL      *)
(*               Version 6 BETA                      *)
(*                                                   *)
(*  Jonathan S. Clough,                              *)
(*  Warren Pinnacle Consulting, Inc.                 *)
(*                                                   *)
(*  Richard A. Park   Eco Modeling                   *)
(*                                                   *)
(*  Version 3 by Park, Manjit Trehan, and Jae Lee    *)
(*                                                   *)
(*****************************************************)

Unit SLR6;

interface

Uses

  shLwApi, SysUtils, Utility, Windows, Messages, Classes, Graphics, Controls, Global, Uncert, Infr_Data, Categories,
  Forms, Dialogs, StdCtrls, Math, Progress, GISOptions, OLECtrls, ComObj, stack, SalArray, System.SyncObjs;

CONST
  SaltWater   : BYTE = 1;
  ExposedWater: BYTE = 2;
  MostlyWater : BYTE = 4;
  HasEFSW  : BYTE = 8;

  Small = 0.1;  {sq m}

  Blank = -99;

TYPE

  MapDisk    = ARRAY OF Integer;
  MapWord    = Array of Word;
  MapBoolean = ARRAY of BYTE;
  PMapBoolean = ^MapBoolean;
  PctArray   = ARRAY[0..MaxCats] OF double;

TYPE SAVParamsRec=Record
    Intcpt, C_DEM, C_DEM2, C_DEM3, C_D2MLLW, C_D2MHHW, C_D2M, C_D2M2: Double;  //coefficients for SAV estimation
  End;  // SAVPARAMSREC

//   Logit := -23.72 + DEM*(0.4769) + DEM*DEM*(-0.1377) +                       d2MLLW*(-0.005855) + d2MHHW*(0.001731)+ d2mouth*(0.007291) + d2mouth*d2mouth*(-0.0000005614);
//   Logit := Int    + (DEM*C_DEM) + (SQR*DEM*C_DEM2) + (Power(DEM,3)*C_DEM3) + (d2MLLW*C_D2MLLW) + (d2MHHW*C_D2MHHW) + d2mouth*(C2_D2M)   + d2mouth*d2mouth*(C2_D2M2);


TYPE

 TSLAMM_Simulation = Class

     {-------------------------------------------------------------}
     FileN, SimName, Descrip    : String;

     Categories          : TCategories;

     Site                : TSite;
     FWFlows             : TFWFlows;
     NumFwFlows          : Integer;
     SalRules            : TSalinityRules;
     WindRose            : TWindRose;

     NRoadInf            : Integer;
     RoadsInf            : Array of TRoadInfrastructure;

     NPointInf           : Integer;
     PointInf            : Array of TPointInfrastructure;

     NTimeSerSLR         : Integer;
     TimeSerSLRs         : TTimeSerSLRs;

     TimeStep            : Integer;
     MaxYear             : Integer;
     RunSpecificYears    : Boolean;
     YearsString         : String;
     RunUncertainty      : Boolean;
     RunSensitivity      : Boolean;
     UncertSetup         : TSLAMM_Uncertainty;

     Fixed_Scenarios     : Array[1..11] of Boolean;  //NYS and ESVA SLR Scenarios Added - Marco

     IPCC_Scenarios      : Array[IPCCScenarios] of Boolean;
     IPCC_Estimates      : Array[IPCCEstimates] of Boolean;
     RunCustomSLR        : Boolean;
     N_CustomSLR         : Integer;
     CustomSLRArray      : Array of Double;
     Current_Custom_SLR  : Double;
     Prot_To_Run         : Array[ProtScenario] of Boolean;

     Make_Data_File      : Boolean;
     Display_Screen_Maps : Boolean;
     QA_Tools            : Boolean;
     RunFirstYear        : Boolean;
     Maps_to_MSWord      : Boolean;
     Maps_to_GIF         : Boolean;
     Complete_RunRec     : Boolean;
     SalinityMaps        : Boolean;
     AccretionMaps       : Boolean;
     DucksMaps           : Boolean;
     SAVMaps             : Boolean;
     ConnectMaps         : Boolean;
     InundMaps           : Boolean;
     RoadInundMaps       : Boolean;
     SaveGIS             : Boolean;
     SaveROSArea      :Boolean;
     SaveElevsGIS, SaveSalinityGIS, SaveInundGIS   : Boolean;
     SaveElevGISMTL : Boolean;
     SaveBinaryGIS       : Boolean;
     BatchMode           : Boolean;

     CheckConnectivity   : Boolean;
     ConnectMinElev: integer; //Minimum or average elevation for connectivity algorithm
     ConnectNearEight: integer; //8 or 4 neighbors to calculate connectivity paths

     CellSizeMult        : Integer;  {1 = 100%, 2 = 200%, 3 = 300% (9-cells at one time)}

     UseSoilSaturation   : Boolean;
     LoadBlankIfNoElev   : Boolean;

     UseBruun            : Boolean;
     InitZoomFactor      : Double;

     UseFloodForest      : Boolean;
     UseFloodDevDryLand  : Boolean;

     SaveMapsToDisk      : Boolean;
     MakeNewDiskMap      : Boolean;
     IncludeDikes        : Boolean;

     ClassicDike         : Boolean;

//   ElevRanges          : TClassElevArray;

     Init_ElevStats      : Boolean;  {have elevation stats been initialized?}
     NElevStats          : integer;  {size of ElevationStats within categories}
     ElevStatsDerived    : Array of TDateTime;

//   GridColors          : GridColorType;
     ElevGridColors      : ElevGridColorType;

     {-- File Name Management}
     BatchFileN          : String;
     ElevFileN, NWIFileN, SLPFileN, OutputFileN, {main files}
     IMPFileN,  ROSFileN, DikFileN, VDFileN, UpliftFileN, SalFileN, OldRoadFileN, D2MFileN : String;
     StormFileN : String;  // 6.93 addition

     OptimizeLevel : Word;  {0 = no optimization, 1 = blank spaces not tracked, 2 = black, ocean, high dry land}
     NumMMEntries: Integer;
     SAVParams : SAVParamsRec;

     SalArray      : TSalArray;
     SalStatsDerived  : TDateTime;
     Init_SalStats : Boolean;

     Tropical: Boolean;

     {-------------------------------------------------------------}
     {NO LOAD OR SAVE BELOW}

     { Relevant to Current Simulation Run, no load save Reqd. }
//       GridColors2          : GridColor2Type;

       Changed    : Boolean;
       TStepIter  : Integer;  // timestep iterations run for output summary
       NTimeSteps : Integer;  // Total number of SLAMM timesteps to be run
       ScenIter   : Integer;  // index of current SLR scenario being run
       RunTime    : String;   // string describing run time for file naming and run file

       CellHa     : double;   // hectares in a single cell
       Hectares   : double;  // total hectares in simulation

       Year: INTEGER;       // year being run
       TimeZero: Boolean;   // Running Time Zero Now?

       RunRecordFileName: String;
       RunRecordFile: TextFile;
       Max_WErode : Double; // maximum wave erosion calculated


       ProtectDeveloped,    {TRUE if developed areas are to be protected}
       ProtectAll: Boolean; {TRUE if all dry lands are to be protected}
       Running_Fixed: Boolean;
       Running_Custom: Boolean;
       Running_TSSLR: Boolean;  {Running time-series SLR}
       IPCCSLRate: IPCCScenarios;
       IPCCSLEst: IPCCEstimates;
       FixedScen, TSSLRIndex: Integer;
       ProjRunString,ShortProjRun: String;

       MaxMTL, MinMTL    : single;   // max and min of MTL_Correction for screen draw purposes

       Map               : MSArray;    {Collection of all cells in RAM }
       MapHandle         : THandle;
       BackupFN          : String;
       DikeInfo          : TDikeInfoArr;
       WordApp, WordDoc  : Variant;
       WordInitialized   : Boolean;
       NumRows           : Integer;
       Summary           : OutputArray; {Output [0..NumSites+1,0..NumRows-1,0..MaxColumns]}
       ColLabel          : str_vector;
       FileStarted       : Boolean;      { batch CSV file Started? }
       RowLabel          : str_vector1;

       BMatrix : MapBoolean;
       ErodeMatrix: MapWord;        {Matrix of Erosion that has already occured at a given cell coordinate  in cm increments}
       MapMatrix: MapDisk;
       DataElev : Array of Word;    {Elevations  0..65535 in mm starting at - 10 meters  so range of -10.000m to 55.535 meters with 1mm precision}
       MaxFetchArr : Array of Word; {Max Fetch   0..65535 in m}
       ROSArray : Array of Byte;    {Raster Output Site Relevant for Each Cell  0..255}

       UseSSRaster: Array [1..2] of Boolean;     {Use SS Raster for [1,2] 10 yr, 100 yr }
       SS_Raster_SLR: Array [1..2] of Boolean;   {Time series SS Rasters? for [1,2] 10 yr, 100 yr }
       SSFilen : Array [1..2] of String;         {File Names for the two storm-surge rasters [1,2] 10 yr, 100 yr }
       SS_SLR : Array [1..2,1..2] of Double;     {SLR associated with each of the raster maps in meters}
       SSRasters : Array[1..2,1..2] of Array of Word;  {rasters themselves, [1,2] 10 yr, 100 yr; [1,2] SLR1, SLR2  Elevations 0..65535 in mm starting at - 10 meters  so range of -10.000m to 55.535 meters with 1mm precision}

       CatSums : Array of PctArray;  // Modify in CRITICAL SECTION
       RoadSums : Array of RoadArray;

       BlankCell: CompressedCell;
       UndDryCell, DevDryCell, OceanCell, EOWCell : CompressedCell;
//     FRs : Array of FractalRecord;

       UserStop            : Boolean;
       SAV_KM              : Double;

       ROS_Resize, RescaleMap : Integer;      //  rescalemap 1 = 100% 2 = 200% 3=300%

       DikeLogInit: Boolean;
       DikeLog: TextFile;

       SAVProbCheck : Boolean;     {has SAV prob been calculated?}
       ConnectCheck: Boolean;      {has connectivity been  calculated?}
       Connect_Arr : MapBoolean;                  // Unchecked = 1
                                                   // Above Salt Bound = 2
                                                   // Checked & Connected = 3
                                                   // Checked & Unconnected = 4
                                                   // {Irrelevant = 5 (not used anymore) }
                                                   // Diked = 7
                                                   // Tidal Water = 8 [navy]
                                                   // Blank = 9
                                                   // Overtopped Dike = 10

       Inund_Arr : MapBoolean;                      // 30,60,90,120,150 = H1,H2,H3,H4,H5 inundation

       InundFreqCheck : Boolean; {has cell inundation been calculated?}
       RoadInundCheck : Boolean; {has road inundation been calculated?}

       CPUs : Integer;

       CriticalSection: TRTLCriticalSection;

     {NO LOAD OR SAVE ABOVE}
     {-------------------------------------------------------------}
     Constructor Create(California: Boolean);
     Constructor Load(FN: string); overload;
     Procedure Save(FN: string); overload;
     Constructor Load(TS: TStream); overload;
     Procedure Save(var TS: TStream); overload;
     Destructor Destroy; override;
     {-------------------------------------------------------------}

     //Function Calc_Connectivity(testR,testC: Integer) :Boolean;
     Function Calc_Inund_Connectivity(PArr: PMapBoolean; ClearArr: Boolean; ElevType: Integer): Boolean;  //ElevType -1= SaltElev, 0 = H1, 1 = H2, 2 =H3, 3=H4, 4:H5
     function Calc_Inund_Freq: Boolean;
     Function CalcSSRaster(Ri: Integer; PTA: Pointer): Boolean;

     Procedure ScaleCalcs;  // if editing the map, set rescalemap to 1
     Function ScaledX(X: Integer): Integer;  // scales x based on rescalemap option
     Function ScaledY(Y: Integer): Integer;

     Procedure ZeroSums;  // Zero out roadsums and catsums
     Procedure Count_MMEntries;
     Function CheckForAnnualMaps: Boolean;
     Function Inundate_Erode(StartRow,EndRow: Integer;ProgStr:String; PRunThread: Pointer; ErodeLoop: Boolean ): Boolean;
//   Function Migrate_Barrier_Islands: Boolean;
     Procedure ExecuteRun;
     Procedure Calc_Elev_Stats(OneArea: Boolean);  {run elev analysis and copy results into ELEVStats}
     Function  MakeFileName:String;
     Function Save_GIS_Files: Boolean;
     Function In_Area_to_Save(X {Col},Y {Row}:Integer; SaveAll:boolean): Boolean;
     Procedure Save_CSV_File;
     Function CopyMapsToMSWord: Boolean;
     Function MakeDataFile(CountOnly: Boolean; YearDikeFName, YearSalFName: String): Boolean;
     Function ReadStormSurge(RIi,SLRi: Integer): Boolean;
     Procedure SaveRaster(FileN: String; rasterType: Integer);
     PROCEDURE SetMapAttributes;
     Procedure CalibrateSalinity;
//   Procedure Calc_Fractal(Var Site:TSite);
     Function RunOneYear(IsT0: Boolean): Boolean;
//   Procedure FractalNos(ER,EC: Integer; Var Cell:CompressedCell; Var FSite: TSite);
     Function ValidateOutputSites: Boolean;
//     Procedure AssignGridColors2;
     Procedure  WriteRunRecordFile;
     Procedure SummarizeFileInfo(Desc,FN: String);
     Function ISOpenWater(Cl: PCompressedCell): Boolean;
     Function IsSalineWater(Cl: PCompressedCell): Boolean;
     Function ISDryLand(Cl: PCompressedCell): Boolean;
     Function WaveErosionCat(Cl: PCompressedCell; Var MinElev, MrshWid: Double): Boolean;

     {TRANSFER.INC: PROCEDURES THAT HANDLE SLR, INUNDATION, EROSION, OVERWASH in TRANSFER.INC}
     Function DynamicAccretion(Cell:PCompressedCell; Cat: Integer; SS: TSubsite; ModelNum: Integer): Double;  {calculated accr, mm/year}
     Procedure RescaleAccretion(SS: TSubsite; Cat: Integer; ModelNum: Integer);
     Function ThirdOrdPoly(a,b,c,d,X:Double): Double;

     Procedure EustaticSLChange(VAR Site: TSite; VAR Year: Integer; IsT0: Boolean);
     Procedure TRANSFER(Cell: PCompressedCell; EachRow,EachCol: Integer; ErodeStep: Boolean);
     Function UpdateElevations: Boolean;  {update cell elevations for entire map based on SLR, uplift, subsidence, accretion}
     Function ThreadUpdateElevs(StartRow,EndRow: Integer;PRunThread: Pointer):Boolean;

     Function ChngWater(CalcMF, CalcGeometry: Boolean):Boolean;
     Function ThreadChngWater(StartRow,EndRow: Integer;PRunThread: Pointer):Boolean;
     Function CalculateMaxFetch(StartRow,EndRow: Integer;PRunThread: Pointer; Var LMaxEw: Double): Boolean;

     {END TRANSFER.INC}

     {INITX.INC: PROCEDURES RUN EARLY IN SLAMM SIMULATION, OR ELEV BOUNDARIES FUNCS CONTAINED IN INITX.INC}
//     Procedure SetDefaultCategoryVariables;
     Function PreprocessWetlands:Boolean; {Elevation Processor for low quality elevation data}
     FUNCTION LowerBound(Cat: Integer; Var SS: TSubSite): Double; {lower bound for category in M above MTL}
     FUNCTION UpperBound(Cat: Integer; Var SS: TSubSite): Double; {lower bound for category in M above MTL}
     {End INITX.INC}

     {SUMFRAC.INC:  Procedures that handle writing of output}
     PROCEDURE CSV_file_save(datary:   OutputArray; rowlabel: str_vector1;
                        collabel: str_vector; numrow:   integer; numcol:   integer; fnm: String);
     Procedure Summarize(VAR Map: MSArray; VAR Tropical: Boolean; VAR Summary: OutputArray; Year: Integer);

     {PROCEDURES THAT HANDLE MEMORY MAP HANDLING CONTAINED IN MSVARRAY.INC}
     Procedure RetA(Row, Col: WORD; Var Cell: CompressedCell);
     Procedure SetA(Row, Col: WORD; Var Cell: CompressedCell);
     Procedure MakeMem(Cell: CompressedCell);
     PROCEDURE RetMem(VAR F: MSArray; Row, Col: WORD; Var Cell: CompressedCell);
     Procedure SetMem(VAR F: MSArray; Row, Col: WORD; Var Cell: CompressedCell);
     Procedure DisposeMem;
     Procedure LoadFile(VAR H: THandle; filen: String);
     Function MakeFile(VAR H: THandle; Rows, Cols: WORD; filen: String; Cell: CompressedCell): Boolean;
     Procedure RetFile(VAR H: THandle; Row, Col: Int64; VAR Cell: CompressedCell);
     Procedure SetFile(Row, Col: Int64; VAR Cell: CompressedCell);
     Procedure DisposeFile(VAR H: THandle; Delete_file: BOOLEAN; FileN: String);
     FUNCTION GetBit(N: BYTE; Row, Col: INTEGER): BOOLEAN;
     Procedure SetBit(N: BYTE; Row, Col: INTEGER; SetTrue: BOOLEAN);
     Function RetCellMatrix(Row, Col: Int64; Var Cell: CompressedCell):Boolean;  {returns optimized cell based on matrix, not map}
     {END OF MSVARRAY.INC}

     {PROCEDURES THAT HANDLE ESTUARY PROCESSING CONTAINED IN FRACFRESH.INC}
     Function  FWInfluenced(Row,Col,FWNum:Integer): Boolean; overload;
     Function  FWInfluenced(Row,Col:Integer): Boolean; overload;
     Function  RiverKM(PR,PC,FWNum: Integer; Var D2C: Double): Double;
     Function CalcSalinity(RunChngwater, TimeZero: Boolean):Boolean;  {Set tidal salinities for all cells}
     Function AggrSalinityStats: Boolean;
     Function FreshWaterHeight(ThisCell: PCompressedCell; FR,FC: Integer;
                               Var FWSal, SWSal: Double; Var Salh: Double;
                               TideInt: Integer; Var SegSalin:Double): Double;
     Function CalculateFlowGeometry(Yr: Integer): Boolean;
     Procedure Smooth_XS_Salinity;
     Procedure ClearFlowGeometry;
     Function CalculateEucDistances: Boolean;
     Function ThreadCalcEucDistances(StartRow,EndRow: Integer;PRunThread: Pointer):Boolean;

     Function CalculateProbSAV(ShowMsg:Boolean): Boolean;
end;

     {END OF FRACFRESH.INC}


function SetFilePointerEx(hFile: THandle; lDistanceToMove: Int64;
  lpNewFilePointer: Pointer; dwMoveMethod: DWORD): DWORD; stdcall;
{$EXTERNALSYM SetFilePointerEx}


Type
  TInundContext = Record
   {data to pass to make inundation decisoin}
    DistanceToOpenSaltWater: Double;
    SubS: TSubSite;
    AdjEFSW, AdjOcean, AdjWater, NearWater, CellFwInfluenced: Boolean;
    Erosion2: Double;  // Cell Max Fetch in km
    EWCat: Integer;
    CellRow, CellCol: Integer;
    CatElev : Double;
  End;


Procedure InitCell(C: PCompressedCell);

implementation

Uses DrawGrid, FFForm, ElevHistForm, Variants, System.UITypes, ExtraMapsOptions, Binary_Files, Elev_Analysis, SLAMMThreads, Infr_Form ;



CONST
  WaveLabel: ARRAY[WaveDirection] OF STRING[5] = ('east','west','south','north');
  MenuSelect : ARRAY[1..8] OF STRING[10]
             = ('UnConsol.','Consolid.','UnProt','Bulkhead',
                'Levee','LowDike','HighDike','HardDike');


{$I MSVArray.Inc  }
{$I FracFresh.Inc }
{$I Initx.Inc     }
{$I Transfer.Inc  }
{$I SumFrac.Inc   }
{$I ReadWrite.Inc }
//  Fractal.Inc

{-----------------------------------------------------------------------------------}

(**********************************)
(*   get data and initialize run  *)
(**********************************)

Procedure InitCell(C: PCompressedCell);
Var i: Integer;
Begin
  FOR i := 1 to NUM_CAT_COMPRESS DO
    Begin
      C.Minelevs[i] := 999;
      C.Widths  [i] := 0;
      C.Cats    [i] := Blank;
    End;

  C.TanSlope  := 0.0;

  C.ProtDikes := False;
  C.ElevDikes := False;
  C.MaxFetch := -1.0;  {Set in ChngWater prior to each time-step}
  C.SalHeightMLLW := -99;
  For i := 1 to NUM_SAL_METRICS do
    C.Sal[i] := -999;

  C.Uplift := 0;
  C.ErosionLoss := 0;
  C.BTFErosionLoss := 0;

  C.MTLminusNAVD := -9999;

  C.D2MLLW := -9999;
  C.D2MHHW := -9999;
  C.ProbSAV := -9999;
  C.D2Mouth := -9999;

   C.SubSiteIndex := -9999;
//   C.ImpCoeff := -9999;
   C.Prot_Num := 0;

  C.Pw := -9999;
  C.WPErosion := 0;
End;


{-----------------------------------------------------------------------------------}


Function TSLAMM_Simulation.MakeFileName: String;
Var FName: String;
    UncertIter: Integer;
BEGIN { MakeFileName }
  // To be optimal, first check whether outputfileN has a directory specified (search for ":"?}
  // If not, we should prepend the directory of the SLAMM6 file to the MakeFileNane (don't touch outputfilen variable)

  If OutputFileN <> '' then FName := StringReplace(OutputFileN,'.','_',[rfReplaceAll,rfIgnoreCase])
                       else FName := ChangeFileExt(ElevFileN,'')+'_OUT';

  If UncAnalysis then With UncertSetup do
    Begin
      if UncSens_Iter=0 then UncertIter := 0
                        else UncertIter := GIS_Start_Num + UncSens_Iter -1;

      FName := ExtractFilePath(CSV_Path)+IntToStr(UncertIter)+'_'+ExtractFileName(CSV_Path);
    End;

  If SensAnalysis then With UncertSetup do FName := xls_path;

  If Year>0 then FName := FName + ', '+IntToStr(Year)+','
            else FName := FName + ', Initial Condition ';

  If (Not UncAnalysis) and (Not SensAnalysis) and (Year>0) then
    Begin
      If Running_TSSLR then FName := FName +' '+ TimeSerSLRs[TSSLRindex-1].Name + ' ' else
       If Running_Fixed then FName := FName + ' '+ LabelFixed[FixedScen]+' '
         Else If Running_Custom then FName := FName + ' '+ FloatToStrF(Current_Custom_SLR ,ffgeneral,4,2)+ ' meters '
         Else FName := FName + ' '+ LabelIPCC[IPCCSLRate]+' '+LabelIPCCEst[IPCCSLEst]+' ';

      IF ProtectAll THEN
        FName := FName + 'Protect All Dry Land'
      ELSE IF ProtectDeveloped THEN
        FName := FName + 'Protect Developed Dry Land'
      ELSE
        FName := FName + '';

      IF Not IncludeDikes then FName := FName +' No Dikes';
    End;

  If (SensAnalysis) and (UncertSetup.UncSens_Iter>0) {i.e. not deterministic} then
    Begin
      FName := FName + 'Sens'+IntToStr(UncertSetup.UncSens_Iter) + '_'+IntToStr(UncertSetup.PctToVary);
      If UncertSetup.SensPlusLoop then FName := FName + '_Pos'
                                  else FName := FName + '_Neg';
    End;

  MakeFileName := FName;
END;



{ MakeFileName }


{-----------------------------------------------------------------------------------}

Procedure TSLAMM_Simulation.SaveRaster(FileN: String; rasterType: Integer);
{raster Type 1 = Dikes, 2 = NWI,     3 = Elevations, 4 = Raster-subsites
             5 = Inund, 6 = D2MLLW   7 = D2MHHW }

Var CatInt, RowLoop,ColLoop : Integer;
    Current_Cell            : CompressedCell;
    Elev, SlopeAdjustment, GT   : Double;
    TOD                     : TOpenDialog;
    SSIndex, InundOut : integer;
    SOF: TSLAMMOutputFile;
    LastNumber:Boolean;
Begin


  If FileN = ''
    then Begin
            TOD := TOpenDialog.Create(nil);
            TOD.Title:='Select File to Save Raster Output';
            TOD.Filter := '';
            If Not TOD.Execute then
              Begin
                MessageDlg('File Not Saved.',mterror,[mbok],0);
                TOD.Free;
                Exit;
              End;
            FileN := TOD.FileName;
            TOD.Free;
         End;

  If FileExists(FileN) then MessageDlg('Please Backup Original File Before Continuing',mtwarning,[mbok],0);

  With Site do
    SOF := TSLAMMOutputFile.Create(RunCols,RunRows,LLXCorner,LLYCorner,runscale,FileN);
  SOF.WriteHeader(False);


  ProgForm.Show;
  ProgForm.ProgressLabel.Caption := 'Saving Raster File';
  ProgForm.HaltButton.Visible := True;

  {Write EACH CELL}
     For RowLoop := 0 { (Site.RunRows Div 2) -1 } to Site.RunRows-1 do  //commented out slices in half
      Begin
       For ColLoop:= 0 to Site.RunCols-1 do
         Begin
            If ColLoop=1 then If Not ProgForm.Update2Gages(Trunc((RowLoop)/Site.RunRows*(100)),0) then Break;  {break out of loop and close file on user exit}
            LastNumber := (RowLoop=Site.RunRows-1) and (ColLoop=Site.RunCols-1);
            If (rasterType < 4) or (rastertype > 5) then RetA( RowLoop, ColLoop, Current_Cell);
            case rasterType of
              1:
                Begin
                  if ClassicDike then
                    Begin
                      If CellWidth(@Current_Cell,Blank) > 0  { This code writes dikes }
                        then CatInt := -99
                        else If Current_Cell.ProtDikes
                          then CatInt := 1
                          else CatInt := 0;
                      SOF.WriteNextNumber(CatInt,LastNumber);
                    End
                   else
                    Begin
                      If CellWidth(@Current_Cell,Blank) > 0  { This code writes dikes }
                        then SOF.WriteNextNumber(-99,LastNumber)
                        else
                          Begin  //not blank
                            If not Current_Cell.ProtDikes
                              then SOF.WriteNextNumber(0,LastNumber)
                              else If Current_Cell.ElevDikes
                                        then SOF.WriteNextNumber(GetMinElev(@Current_Cell),LastNumber)
                                        else SOF.WriteNextNumber(-5,LastNumber);
                          End;
                    End;
                End;
              2: //WETLAND RASTER
                Begin
                   CatInt := GetCellCat(@Current_Cell);
                   If (CatInt <0) or (CatInt > Categories.NCats-1)
                     then SOF.WriteNextNumber(-99,LastNumber)      {No Data }
                     else SOF.WriteNextNumber(Categories.GetCat(CatInt).GISNumber,LastNumber);  {THIS CODE WRITES NWI }
                end;
              3: //ELEVATION RASTER                  // 2/11/09  overwrite elevation file
                Begin
                  Elev := GetMinElev(@Current_Cell);
                  If (Elev > 998) then
                    SOF.WriteNextNumber(WRITE_NO_DATA,LastNumber)  // no data val for elevation
                  else
                    Begin
                      SlopeAdjustment := (Site.RunScale*0.5) * Current_Cell.TanSlope;    {QA 11.10.2005}
                      Elev := Elev + SlopeAdjustment;     {Convert to mean elevation}
                      SOF.WriteNextNumber(Elev,LastNumber);;
                   end;
                end;
              4: //INPUT SUBSITE RASTER
                begin
                 SSIndex := Site.GetSubSiteNum(ColLoop,RowLoop);
                 if SSIndex = 0 then GT := Site.GlobalSite.GTideRange
                                else GT := Site.SubSites[SSIndex-1].GTideRange;
                 SOF.WriteNextNumber(GT,LastNumber);

                end;
              5: //INUNDATION RASTER
                begin
                    InundOut := TranslateInundNum(Inund_Arr[(Site.RunCols*RowLoop)+ColLoop]);
                    SOF.WriteNextNumber(InundOut,LastNumber);
                end;
              6: //MLLW
                begin
                    SOF.WriteNextNumber(Current_Cell.D2MLLW,LastNumber);
                end;

              7: //MHHW
                begin
                    SOF.WriteNextNumber(Current_Cell.D2MHHW,LastNumber);
                end;

            end; {case}
          End; {ColLoop}
        End;

  SOF.Destroy;
  ProgForm.Cleanup;

End;


Function TSLAMM_Simulation.Calc_Inund_Connectivity(PArr: PMapBoolean; ClearArr: Boolean; ElevType: Integer): Boolean;  //ElevType -1= SaltElev, 0 = H1, 1 = H2, 2 =H3, 3=H4, 4:H5
//PArr^  Pointer to Connect_Arr or InundArr
//              : Array of byte;      // Unchecked = 1
                                      // Above Inundation Elevation = 2
                                      // Checked & Connected = 3
                                      // Checked & Unconnected = 4
                                      // Currently Being Checked = 6
                                      // Diked = 7
                                      // Tidal Water = 8 [navy]
                                      // Blank = 9
                                      // Overtopped Dike = 10  Currently Disabled  {overtopped at H1, writes to log file,}
                                      // 30,60,90,120,150 = H1,H2,H3,H4,H5 inundation

var  Cl: CompressedCell;
     Stack, Stack2: TPointStack;

   {--------------------------------------------------------------------------------------------------------}
   function BelowInundElev(Cl: PCompressedCell; EC,ER, ElevType: integer): Boolean;
    var subsite: TSubSite;
        CellElev: double;
    begin
       // Input subsite
       SubSite := Site.GetSubSite(EC,ER,Cl);

       // Get cell elevation
       CellElev := getMinElev(Cl);        //Minimum Elevation
       if ConnectMinElev=0 then
        CellElev := CellElev + (Site.RunScale*0.5)*Cl.TanSlope; //Use average elevation in MTL

       // Check if cell elevation is below the reference elevation
       if ElevType=-1 then
        result := CellElev < SubSite.SaltElev
       else
        result := CellElev < SubSite.InundElev[ElevType];
    end;
   {--------------------------------------------------------------------------------------------------------}
   PROCEDURE CONNECT_CHECK(fx,fy: Integer);    // using a stack fill, check an entire area for connectivity
    Var TP: TPoint;     //for my b.h.
        currentnum, fillResult: byte;
//        subsite: TSubSite;
//        CellElev: double;

      function MP(ax,ay:integer): TPoint;
        begin
          result.x:= ax;
          result.y:= ay;
        end;

    begin
       //Initialize as unconnected
       FillResult := 4;

       //Add the point to the stack
       stack.push(MP(fx,fy));
       stack2.push(MP(fx,fy));

       repeat
         //Get and removing the point from the top of the stack
         TP:= stack.pop;      // TPoint

         if tp.x > -99 then
            begin

               //Get point coordinates
               fx:= TP.x;
               fy:= TP.y;

               //The fill algorithm has left the map, no connectivity here
               if (fy<0) or (fx<0) or (fx>=Site.RunCols) or (fy>=Site.RunRows) then continue;

               //The fill algorithm has found a high area, a diked area, or an area already checked.  No need to continue the search here
               currentnum := PArr^[(Site.RunCols*TP.Y)+TP.X];
               if CurrentNum = 8 then Begin
                                        FillResult := 3;  // We found tidal water so after we've located the whole group we'll mark these as connected
                                        continue;
                                      end;

               If CurrentNum <> 1 then continue;
               //1 "unchecked" remain. Get the cell
               RetA(FY,FX,Cl);

               //Diked areas not relevant to connectivity algorithm
               if ClassicDike and CL.ProtDikes then Continue;    //ClassicDike is checked in file setup

               if (not ClassicDike) and (CL.ProtDikes) and (not CL.ElevDikes) then Continue; //ClassicDike is not checked in file setup, but an old-school dike is in this cell

               //If it is open water than
               if IsSalineWater(@CL) then
                begin
                  FillResult := 3; {checked & Connected.  We found water so after we've located the whole group we'll mark these as connected}
                  PArr^[(Site.RunCols*TP.Y)+TP.X] := 8;  // mark this as open water
                  Continue;
                end;

               //If the cell is above test elevation
               if not BelowInundElev(@CL, FX, FY, ElevType) then
                 begin
                   PArr^[(Site.RunCols*TP.Y)+TP.X] := 2;
                   if (CL.ProtDikes) and (Cl.ElevDikes) then PArr^[(Site.RunCols*TP.Y)+TP.X] := 7;  // mark this as yellow for now
                   Continue;   {Exit if you left the low lying area}
                 end;

               //If the cell is blank
               if GetCellCat(@Cl) = blank then
                 begin
                   PArr^[(Site.RunCols*TP.Y)+TP.X] := 9;
                   Continue;
                 end;

               // Add the cell on top of the stack 2 to be marked later because is lower than the test elevation
               Stack2.Push(MP(fx,fy));
               PArr^[(Site.RunCols*TP.Y)+TP.X] := 6; {in process of being checked}

               // Add the nearest neighbors to the first stack to check them
               Stack.Push(MP(FX+1,FY));
               Stack.Push(MP(FX-1,FY));
               Stack.Push(MP(FX,FY+1));
               Stack.Push(MP(FX,FY-1));

               (*   Removed eight sided search for all cases - 10/18/2013 - VersionNum: 6.75
               if (ClassicDike) and (RoadFileN='') then
               *)

               //Get subsite
               //SubSite := Site.GetSubSite(FX,FY,@Cl);

               // Get cell elevation
               //CellElev := getMinElev(@Cl);        //Minimum Elevation
               //if ConnectMinElev=0 then
               // CellElev := CellElev + (Site.Scale*0.5)*Cl.TanSlope; //Use average elevation

               if (ConnectNearEight=1) then //or (CellElev<(Subsite.GTideRange)/4) then
                begin
                  Stack.Push(MP(FX+1,FY+1));
                  Stack.Push(MP(FX-1,FY+1));
                  Stack.Push(MP(FX+1,FY-1));
                  Stack.Push(MP(FX-1,FY-1));  {eight sided search}
                end;

            end;

       until TP.x = -99;  //until stack is empty

       //Mark all the cells in Stack 2 with FillResult:  it is either checked and unconnected, 4 or connected 3
       Repeat
          TP := Stack2.Pop;
          If tp.x > -99 then
           if PArr^[(Site.RunCols*TP.Y)+TP.X] <> 8 then        {Keep tidal water marked as such for mapping}
              Begin
                PArr^[(Site.RunCols*TP.Y)+TP.X] := FillResult;   {utilizing a one dimensional dynamic array for two dimensional data}

(*                If (not UncAnalysis) and (not SensAnalysis) and (ElevType = 0) then   Dike Logging and marking as "10" currently disabled
                                                                                        Note, if reenabled, may need to change Calc_Inund_Freq code below
                  Begin
                    if FillResult = 3 then   //connected
                      Begin
                        RetA(TP.Y,TP.X,Cl);  //get the cell to see if there is a dike
                        if (CL.ProtDikes) and (Cl.ElevDikes) then //dike is being marked as connected -- apparently overtopped
                          Begin
                            if not DikeLogInit then  //initialize file if required
                              Begin
                                Assignfile(DikeLog,MakeFileName+'_DikeLog.txt');
                                Rewrite(DikeLog);
                                DikeLogInit := True;
                              End;
                            PArr^[(Site.RunCols*TP.Y)+TP.X] := 10;  // overtopped dike
                            SubSite := Site.GetSubSite(TP.X,TP.Y,@Cl);
                            Writeln(DikeLog,'Overtopped X,',TP.X,'; Y,',TP.Y,'; Year, ',Year,'; Elev, ',
                                   floattostrf(getMinElev(@Cl)+(Site.RunScale*0.5)*Cl.TanSlope,ffgeneral,4,4),'; H0,',floattostrf(SubSite.H0,ffgeneral,4,4));
                          End;
                      End;
                  End;  // Dike Logging  *)
              End;

       Until TP.X = -99;
    End;  // connect_check
   {--------------------------------------------------------------------------------------------------------}

var er,ec: integer;
    cellcat: Integer;
begin {Calc_Inund_Connectivity}
  //Initialize return variable
  Result := True;

  //Initialize stacks
  stack  := TPointStack.init;
  stack2 := TPointStack.init;      // result stack

  //Initialize PArr^
  if PArr^ = nil then
    setlength(PArr^,site.Runrows*site.Runcols);

  // Initialize presearch, every cell marked as "unchecked"
  If ClearArr then
   for ER:=0 to Site.RunRows-1 do
     for EC:=0 to Site.RunCols-1 do
       PArr^[(Site.RunCols*ER)+EC]:= 1;

  ProgForm.ProgressLabel.Caption:='Checking Connectivity :';
  ProgForm.HaltButton.Visible := True;
  //ProgForm.Show;

  for ER:=0 to Site.RunRows-1 do
    for EC:=0 to Site.RunCols-1 do
    begin
      If EC=0 then Result := ProgForm.Update2Gages(Trunc(ER/Site.RunRows*100),0);
      If Not Result then Begin stack.destroy; stack2.destroy; Exit; End;    // user exit

      if PArr^[(Site.RunCols*ER)+EC]= 1 then
      begin
        // Get Cell
        RetA(ER,EC,Cl);

       // Get cell category
       cellcat := GetCellCat(@Cl);

       //Diked under "Classic" Dike model, don't check.
       if ClassicDike and CL.ProtDikes then
        PArr^[(Site.RunCols*ER)+EC]:= 7

       //Not exclusively ClassicDike map but this cell is protected by "classic dike" designation, don't check
       else if (not ClassicDike) and (CL.ProtDikes) and (not CL.ElevDikes) then
        PArr^[(Site.RunCols*ER)+EC]:= 7

       //Blank, don't check
       else if cellcat = blank then
        PArr^[(Site.RunCols*ER)+EC]:= 9

       // If Open Water
       else if IsSalineWater(@Cl) then
        PArr^[(Site.RunCols*ER)+EC]:= 8  // 5/21/2012, show tidal water as navy on maps

       //Above test elevation
       else if not BelowInundElev(@CL, EC, ER, ElevType) then
         begin
           PArr^[(Site.RunCols*ER)+EC]:= 2;
           if (CL.ProtDikes) and (Cl.ElevDikes) then PArr^[(Site.RunCols*ER)+EC] := 7;  // mark this diked cell above the inundation boundary as yellow
         end

       // Check if the cell is connected
       else
        Connect_Check(EC,ER);
      end;
    end;

  stack.destroy;
  stack2.destroy;

  //ProgForm.Hide;
end;   {Calc_Inund_Connectivity}

Type ByteArray = Array of Byte;
     PByteArray= ^ByteArray;

Function TSLAMM_Simulation.CalcSSRaster(Ri: Integer; PTA: Pointer): Boolean;  // calculate storm surge heights using raster inputs
Var ER, EC: Integer;
    Cl: CompressedCell;
    Val1, Val2, SLR, StormElev, CellElev: Double;
    RunRow, RunCol: Integer;
    FlatArrIndex: LongInt;
    TmpArray: PByteArray;
Begin
 TmpArray := PTA;
 Result := True;
 With Site.GlobalSite do
   SLR := (NewSL - T0SLR); // SLR since T0 in m

 ProgForm.ProgressLabel.Caption:='Calculating Storm Surge';
 ProgForm.HaltButton.Visible := True;
 ProgForm.Show;

 for ER:=0 to Site.RunRows-1 do
  for EC:=0 to Site.RunCols-1 do
   begin
     RetA(ER,EC,Cl);

     If EC=0 then Result := ProgForm.Update2Gages(Trunc(ER/Site.RunRows*100),0);
     If Not Result then Exit;  // user exit

     // Get cell elevation
     CellElev := getMinElev(@Cl);        //Minimum Elevation
     if ConnectMinElev=0 then
       CellElev := CellElev + (Site.RunScale*0.5)*Cl.TanSlope; //Use average elevation in MTL

    If (CellElev < 20) and (not IsOpenWater(@Cl)) // throw out open water, no data (elev 999), and elevations above 20 m
     Then
      Begin
        if RescaleMap = 1
          then FlatArrIndex := (Site.ReadCols*ER)+EC
          else
            Begin
              RunRow := (ER + (RescaleMap - Site.TopRowHeight)) DIV RescaleMap;
              RunCol := EC DIV RescaleMap;
              FlatArrIndex := (Site.RunCols*RunRow)+RunCol;
            End;

         If (SLR<1e-6) or (not SS_Raster_SLR[Ri])
            then
              Begin
                StormElev := WordToFloat(SSRasters[Ri,1,FlatArrIndex]);  // MTL t0 datum
              End
            else
              Begin
                StormElev := -10;  // default if both cells have no-data -- no effect
                Val1 := WordToFloat(SSRasters[Ri,1,FlatArrIndex]);
                Val2 := WordToFloat(SSRasters[Ri,2,FlatArrIndex]);
                If (Val2<-9.99) and (Val1>-9.99) then StormElev := Val1-SS_SLR[Ri,1];  // if one map has no data then use other data, convert to MTL T0 Datum
                If (Val1<-9.99) and (Val2>-9.99) then StormElev := Val2-SS_SLR[Ri,2];  // if one map has no data then use other data, convert to MTL T0 Datum
                If (Val1>-9.99) and (Val2>-9.99) then
                    StormElev := LinearInterpolate(Val1,Val2,SS_SLR[Ri,1],SS_SLR[Ri,2],SLR,True)-SLR; // interpolate or extrapolate from SLR data, then convert to MTL T0 Datum
                 {mtl t0 datum}                   {mtl datum}                             {convert to mtl t0 datum}
              End;

         If CellElev<StormElev {and not open water}   then
           if Ri=2 then TmpArray^[FlatArrIndex] := 150
                   else TmpArray^[FlatArrIndex] := 120;
      End;
   end;

End;


function TSLAMM_Simulation.Calc_Inund_Freq: Boolean;
var
  TmpArray: array of byte;
  i : integer;
begin
  Result := True;

  // Set TmpArray
  setlength(TmpArray,site.Runrows*site.Runcols);
  Inund_Arr := nil; // initialize;

  If UseSSRaster[2]
    then Result := CalcSSRaster(2,@TmpArray)
    else
      Begin
        //H5 Inundation  // Storm-surge 2
        Result := Calc_Inund_Connectivity(@Inund_Arr,True,4);
        for i := 0 to length(TmpArray)-1 do
          begin
            TmpArray[i] := Inund_Arr[i];
            if Inund_Arr[i]=3 then TmpArray[i] := 150;
            If Inund_Arr[i] = 3 then Inund_Arr[i] := 1;   // only check these cells for connectivity at lower elevation
          end;
      End;
  If not Result then Exit;

  If UseSSRaster[1]
    then Result := CalcSSRaster(1,@TmpArray)
    else
      Begin
        //H4 Inundation
        Result := Calc_Inund_Connectivity(@Inund_Arr,(Inund_Arr=nil),3);
        for i := 0 to length(TmpArray)-1 do
          begin
            if Inund_Arr[i] = 3 then TmpArray[i] := 120;
            If TmpArray[i] < 120 then TmpArray[i] := Inund_Arr[i];  // overwrite all TmpArray except top 2 flood calculations
            If Inund_Arr[i] = 3 then Inund_Arr[i] := 1;    // only check these cells for connectivity at lower elevation
          end;
      End;
  If not Result then Exit;

  //H3 Inundation
  Result := Calc_Inund_Connectivity(@Inund_Arr,(Inund_Arr=nil),2);
  for i := 0 to length(TmpArray)-1 do
    Begin
      if Inund_Arr[i]=3 then TmpArray[i] := 90;
      If TmpArray[i] < 90 then TmpArray[i] := Inund_Arr[i];  // overwrite all TmpArray except top 3 flood calculations
      If Inund_Arr[i] = 3 then Inund_Arr[i] := 1;            // note may need to add "10" if dike overtopping logging enabled
    End;
  If not Result then Exit;

  //H2 Inundation
  Result := Calc_Inund_Connectivity(@Inund_Arr,False,1);
  for i := 0 to length(TmpArray)-1 do
    Begin
      if (Inund_Arr[i]=3) then TmpArray[i] := 60;
      If Inund_Arr[i] = 3 then Inund_Arr[i] := 1;            // note may need to add "10" if dike overtopping logging enabled
    End;
  If not Result then Exit;

  //H1 Inundation
  Result := Calc_Inund_Connectivity(@Inund_Arr,False,0);
  for i := 0 to length(TmpArray)-1 do
    begin
      if Inund_Arr[i] = 3 then TmpArray[i] := 30;
      Inund_Arr[i] := TmpArray[i]; //Reassign Inund_Arr
    end;

  //free TmpArray memory
  TmpArray :=nil;
end;

{-----------------------------------------------------------------------------------}

Function TSLAMM_Simulation.Save_GIS_Files: Boolean;

Type PLoopType =(TWater,TDryland,TSwamp,TFreshWet,
                 TSaltmarsh, TTidalFlat,TBeach);

Var SOF                      : TSLAMMOutputFile;
    FN, RootName,DescString  : String;
    RowLoop,ColLoop  : Integer;
    Current_Cell             : CompressedCell;
    CatInt                   : Integer;
    WritingElevs, WritingSalin, WritingInund  : Boolean;
    WriteLoop                : Integer;
    SRow, ERow, SCol, ECol   : Integer;
    LLXOut, LLYOut , MinElev : Double;
    SalOut, ElevOut, SlopeAdjustment : Double;
    InundOut : Integer;
    LastNum, CellIn          : Boolean;
    Subsite : TSubsite;

BEGIN
 Result := True;

 WritingElevs := SaveElevsGIS; {and not (UncAnalysis or SensAnalysis);}
 WritingSalin := SaveSalinityGIS; {and not (UncAnalysis or SensAnalysis);}
 WritingInund := SaveInundGIS; {and not (UncAnalysis or SensAnalysis);}

 For WriteLoop := 1 to 4 do
    BEGIN
     If (WriteLoop = 2) and not WritingElevs then Continue;
     If (WriteLoop = 3) and not WritingSalin then Continue;
     If (WriteLoop = 4) and not WritingInund then Continue;

     RootName := MakeFileName;

     ProgForm.ProgressLabel.Caption:='Writing GIS Output :';
     ProgForm.HaltButton.Visible := True;
     ProgForm.Show;

     DescString := '';
     If (WriteLoop=2) then
      begin
        DescString := '_ELEVS';
        //Add datum information to the file name
        if SaveElevGISMTL then
          DescString := DescString+'_MTL'
        else
          DescString := DescString+'_NAVD88';
      end;

     If (WriteLoop=3) then DescString := '_SALINITY_30D_HIGH';// '_SALINITY_30D_HIGH';
     If (WriteLoop=4) then DescString := '_Inund_Freq';// '_SALINITY_30D_HIGH';

     SRow := 0;
     ERow := Site.RunRows-1;
     SCol := 0;
     ECol := Site.RunCols-1;
     LLXOut := Site.LLXCorner;
     LLYOut := Site.LLYCorner;

    (*  OUTPUT DOMINANT CATEGORY FOR READING INTO GIS  *)

     If SaveBinaryGIS then FN := RootName+DescString +'_GIS.SLB'
                      else FN := RootName+DescString +'_GIS.ASC';
     SOF := TSLAMMOutputFile.Create(ECol-SCol+1,ERow-SRow+1,LLXOut,LLYOut,Site.RunScale,FN);
     If not SOF.WriteHeader(False) then Begin
                                          Result := False;
                                          Exit;
                                        End;

     LastNum := False;
     {READ EACH CELL}
     For RowLoop := SRow to ERow do
      Begin
        For ColLoop:= SCol to ECol do
         With Current_Cell do
          Begin
            If ColLoop=ECol then
              Begin
                Result := ProgForm.Update2Gages(Trunc((RowLoop-SRow+1)/(ERow-SRow+1)*(100)),0);
                If Not Result then Begin SOF.Free; Exit;  End;  //close file and exit;
                LastNum := RowLoop = ERow;
              End;

            RetA(RowLoop, ColLoop, Current_Cell);

            //Which area to save?
            CellIn := In_Area_to_Save(ColLoop, RowLoop, not SaveROSArea);

            Case WriteLoop of
              1: //write SLAMM Codes not Elevations
                Begin
                  CatInt := WRITE_NO_DATA;
                  if CellIn then
                    begin
                      CatInt:=Categories.GetCat(GetCellCat(@Current_Cell)).GISNumber;  // fix 3/2/2017
                    end;
                  Result := SOF.WriteNextNumber(CatInt,LastNum);
                End;

              2: // write elevations
                Begin
                  MinElev := GetMinElev(@Current_Cell);
                  If (MinElev = 999) or (not CellIn) then
                    Result := SOF.WriteNextNumber(WRITE_NO_DATA,LastNum)  // no data val for elevation
                  else
                    Begin
                      SlopeAdjustment := (Site.RunScale*0.5) * Current_Cell.TanSlope;    {QA 11.10.2005}
                      ElevOut := MinElev + SlopeAdjustment;     {Convert to mean elevation}

                      //Correct elelvation if desired datum is NAVD88
                      if (not SaveElevGISMTL) then
                        begin
                          // Calculate SLR from beginning of simulation
                          Subsite := Site.GetSubSite(ColLoop,RowLoop,@Current_Cell);

                          // New elevation
                          ElevOut := ElevOut+Current_Cell.MTLMinusNAVD+Subsite.NewSL;
                                    {current elev MTL + inital MTL-NAVD88 + eustatic SLR from start}
                        end;

                      // Assign Elevation
                      Result := SOF.WriteNextNumber(ElevOut,LastNum);
                    End;
                  End;

                  3: // write salinity
                    Begin
                      SalOut := WRITE_NO_DATA;
                      if CellIn then
                        SalOut := Current_Cell.Sal[4];  //THIS CODE WRITES SALINITY AT 30D Inundation level
                      Result := SOF.WriteNextNumber(SalOut,LastNum);
                    End;

                  4: // write inundation frequency
                    Begin
                      InundOut := WRITE_NO_DATA;
                      if CellIn then
                        InundOut := TranslateInundNum(Inund_Arr[(Site.RunCols*RowLoop)+ColLoop]);
                      Result := SOF.WriteNextNumber(InundOut,LastNum);
                    End;

                End; // case


            If Not Result then Begin ShowMessage('Write GIS Error writing to '+FN); SOF.Free; Exit;  End;  //close file and exit;
          End;
        SOF.CR;  // add carriage return
      End;

      If not (RunUncertainty or RunSensitivity) then  // separate logs exist for uncertainty & sensitivity runs.
      Try
        Append(RunRecordFile);
        SummarizeFileInfo('Spatial Data Written',SOF.FileN);
        Closefile(RunRecordFile);
      Except
        MessageDlg('Error appending to Run-Record File '+RunRecordFileName,mterror,[mbOK],0);
      End;

     SOF.Free
   END;

 // ProgForm.Hide;
END;

Function TSLAMM_Simulation. In_Area_to_Save(X {Col},Y {Row}:Integer; SaveAll:boolean): Boolean;
//*********************************************************************
// This function calculates if the cell is in the saving area
//*********************************************************************
Begin
    //Initialize result
    Result := False;

    if SaveAll or (ROSArray=nil) then   //JSC 10/10/2014, if save ROS only is selected but no ROS file exists, then save everything.
      Result := True
    else
      //Save last output site area
      //if Site.InOutSite(X,Y,Site.NOutputSites) then
      //  Result := True;

      //Save all ROS area
      if (ROSArray[Site.RunCols*Y+X]>0) then
        Result:= True;
End;

Function TSLAMM_Simulation.IsSalineWater(Cl: PCompressedCell): Boolean;
var i: Integer; IOW: Boolean;
begin
  Result := False;
  IOW := IsOpenWater(Cl);
  If IOW then
    For i := 1 to NUM_CAT_COMPRESS DO
      If Categories.GetCat(Cl.Cats[i]).IsTidal then if CL.Widths[i] > Tiny then Result := True;
end;



Function TSLAMM_Simulation.IsOpenWater(Cl: PCompressedCell): Boolean;
var i: Integer;
begin
  Result := False;
  For i := 1 to NUM_CAT_COMPRESS DO
    If Categories.GetCat(Cl.Cats[i]).IsOpenWater then if CL.Widths[i] > Tiny then Result := True;
end;

Function TSLAMM_Simulation.IsDryLand(Cl: PCompressedCell): Boolean;
var i: Integer;
begin
  Result := False;
  For i := 1 to NUM_CAT_COMPRESS DO
    If Categories.GetCat(Cl.Cats[i]).IsDryLand then if CL.Widths[i] > Tiny then Result := True;
end;

Function TSLAMM_Simulation.WaveErosionCat(Cl: PCompressedCell; Var MinElev, MrshWid: Double): Boolean;
var i: Integer;
begin
  MrshWid := 0;
  MinElev := 999;
  Result := False;
  For i := 1 to NUM_CAT_COMPRESS DO
    If Categories.GetCat(Cl.Cats[i]).UseWaveErosion then if CL.Widths[i] > Tiny then
      Begin
        Result := True;
        If (Cl.Minelevs[i]<MinElev) then MinElev := Cl.MinElevs[i];
        MrshWid := MrshWid + CL.Widths[i];
      End;
end;


{-----------------------------------------------------------------------------------}
PROCEDURE TSLAMM_Simulation.Save_CSV_File;
Var FName: String;
BEGIN
  If BatchMode then FName := BatchFileN
               else FName := MakeFileName + '.CSV';
  CSV_File_Save(Summary,RowLabel,ColLabel,TStepIter+1,Categories.NCats+1,FName);

  UncertSetup.UncSens_Row := TStepIter + 1;
END;

{-----------------------------------------------------------------------------------}
Procedure TSLAMM_Simulation.Count_MMEntries;
Begin
  ScaleCalcs;
  MakeDataFile(True,'','');
End;


Function TSLAMM_Simulation.ScaledX(X: Integer): Integer;
   Begin
     ScaledX := X DIV RescaleMap;
   End;

Function TSLAMM_Simulation.ScaledY(Y: Integer): Integer;
   Begin
     ScaledY := (Y + (RescaleMap - Site.TopRowHeight)) DIV RescaleMap;
   End;

{-----------------------------------------------------------------------------------}

Procedure TSLAMM_Simulation.ScaleCalcs;


   Procedure ScaledPoly(InPoly: TPolygon; Var OutPoly: TPolygon);
   Var i: Integer;
   Begin
     If (OutPoly <> nil) and (OutPoly <> InPoly) then OutPoly.Free;
     OutPoly := InPoly.CopyPolygon;
     for i := 0 to OutPoly.NumPts-1 do
      With OutPoly.TPoints[i] do
       Begin
         X := ScaledX(X);
         Y := ScaledY(Y);
       End;
   End;

   Function ScaledRec(InRec: TRectangle):TRectangle;
   Begin
     Result.X1 := ScaledX(InRec.X1);
     Result.X2 := ScaledX(InRec.X2);
     Result.Y1 := ScaledY(InRec.Y1);
     Result.Y2 := ScaledY(InRec.Y2);
   End;

Var i: Integer;
Begin
  with Site do
  if (RescaleMap = 1)
   then
     Begin
       RunScale := ReadScale;
       RunRows := ReadRows;
       RunCols := ReadCols;
       TopRowHeight :=1; RightColWidth := 1;  // N A
       For i := 0 to NOutputSites-1 do
         Begin
           if (OutputSites[i].ScalePoly <> OutputSites[i].SavePoly) and (OutputSites[i].ScalePoly<>nil) then OutputSites[i].ScalePoly.Free;
           OutputSites[i].ScalePoly := OutputSites[i].SavePoly;
           OutputSites[i].ScaleRec := OutputSites[i].SaveRec;
         End;
       For i := 0 to NumFwFlows-1 do
         Begin
           ScaledPoly(FWFlows[i].SavePoly,FWFlows[i].ScalePoly);
         {  if (FWFlows[i].ScalePoly <> FWFlows[i].SavePoly) and (FWFlows[i].ScalePoly<>nil) then FWFlows[i].ScalePoly.Free;
           FWFlows[i].ScalePoly := FWFlows[i].SavePoly;  }
         End;
       For i := 0 to NSubSites-1 do
         Begin
           if (Subsites[i].ScalePoly <> Subsites[i].SavePoly) and (Subsites[i].ScalePoly<>nil) then Subsites[i].ScalePoly.Free;
           SubSites[i].ScalePoly := SubSites[i].SavePoly;
         End;
     End
   else
     Begin
       RunScale := ReadScale*RescaleMap;  //cell size
       RunRows := (ReadRows + (RescaleMap-1)) div RescaleMap; //round up
       RunCols := (ReadCols + (RescaleMap-1)) div RescaleMap; //round up
       TopRowHeight  := ReadRows MOD RescaleMap;  //maintain LLCorner
       if TopRowHeight = 0 then TopRowHeight := RescaleMap;
       RightColWidth := ReadCols MOD RescaleMap;
       if RightColWidth = 0 then RightColWidth := RescaleMap;

       For i := 0 to NOutputSites-1 do
        with OutputSites[i] do
         Begin
           If UsePolygon and (SavePoly<>nil) then ScaledPoly(SavePoly,ScalePoly);
           ScaleRec := ScaledRec(SaveRec);
         End;
       For i := 0 to NumFwFlows-1 do
           ScaledPoly(FWFlows[i].SavePoly,FWFlows[i].ScalePoly);
       For i := 0 to NSubSites-1 do
           ScaledPoly(Subsites[i].SavePoly,Subsites[i].ScalePoly);

     End;
End;

{-----------------------------------------------------------------------------------}

Function TSLAMM_Simulation.CheckForAnnualMaps: Boolean;
Var NewDikFName, DikFExt: String;
    NewSalFName, SalFExt: String;
    i: integer;
    buttonSelected, SLReturn, MinSL, MaxSL, SLR_inch : Integer;  // index for min and max SL in arrays
    SLR_M: Double;


    Function ReplaceSLR(RIi,SLRi: Integer): Boolean;
    Var FileExt, NewFileN, BaseFileN, ReturnStr, SLRStr: String;
        j: Integer;
    Begin
       Result := True;
       BaseFileN := SSfileN[RIi];
       FileExt := ExtractFileExt(BaseFileN);
       If LastDelimiter('.',BaseFileN) > 0
         then BaseFileN := Copy(BaseFileN, 0, LastDelimiter('.',BaseFileN) - 1)
         else BaseFileN := BaseFileN;
       ReturnStr := Copy(BaseFileN,Length(BaseFileN)-2,3);
       SLRStr := Copy(BaseFileN,Length(BaseFileN)-5,2);
       BaseFileN := Copy(BaseFileN,0,Length(BaseFileN)-6);

       j := 0;
       Repeat
         inc(j);
         SLR_Inch := StrToInt(SLRStr) + 6;
         SLR_m := 0.0254 * SLR_Inch;

         SLRStr := IntToStr(SLR_Inch);
         If Length(SLRStr) = 1 then SLRStr := '0'+SLRStr;
         NewFileN := BaseFileN + SLRStr + '_'+ ReturnStr+FileExt;
       Until (j=2) or FileExists(NewFileN);

       If FileExists(NewFileN)
         then
           Begin
             SS_Raster_SLR[RIi] := True;
             SSFileN[RIi] := NewFileN;
             Result := ReadStormSurge(RIi,SLRi);
             SS_SLR[RIi,SLRi] := SLR_m;
           End
         else
           If (SLRi=2) and (SS_SLR[RIi,SLRi]<0) then SS_Raster_SLR[RIi] := False;
    End;

begin
  Result := True;
  if IncludeDikes=True then
   begin
    NewDikFName := DikFileN;
    DikFExt := ExtractFileExt(DikFileN);
    Delete(NewDikFName,Length(NewDikFName)-Length(DikFExt)+1,Length(DikFExt));    // delete to before the period in the extension eg "test.asc" becomes "test"
    NewDikFName := NewDikFName + IntToStr(Year) + DikFExt;                        // add the year and extension so "test.asc" becomes "test2000.asc"
    if not FileExists(NewDikFName) then NewDikFName:='';
   end;

  if Pos('.xls',lowercase(SalFileN))=0 then
    Begin
      NewSalFName := SalFileN;
      SalFExt := ExtractFileExt(SalFileN);
      Delete(NewSalFName,Length(NewSalFName)-Length(SalFExt)+1,Length(SalFExt));    // delete to before the period in the extension eg "test.asc" becomes "test"
      NewSalFName := NewSalFName + IntToStr(Year) + SalFExt;                        // add the year and extension so "test.asc" becomes "test2000.asc"
      if not FileExists(NewSalFName) then
        begin
          NewSalFName:='';
          if trim(SalFileN)<>'' then
            begin
              buttonSelected := MessageDlg('Warning! Are you sure you want to run this SLAMM simulation with a constant salinity raster?',mtWarning, [mbYes, mbNO], 0);
              if buttonSelected = mrNO then ProgForm.SimHalted := True;
            end;
        end;
    End;

  if (NewDikFName<>'') or (NewSalFName<>'') then
    begin
      Result := MakeDataFile(False,NewDikFName,NewSalFName);
      If NewSalFName<>'' then
        for i := 0 to NumFwFlows-1 do  // Retention Time Must Be Recalculated.
          FWFLows[i].RetentionInitialized := False;
    end;

  If Result then With Site.GlobalSite do
   If (NewSL - T0SLR) > 0 then  //SLR Since
    For SLReturn := 1 to 2 do
     if UseSSRaster[SLReturn] and SS_Raster_SLR[SLReturn] then
       Begin
         If SS_SLR[SLReturn,1] < SS_SLR[SLReturn,2] then Begin MinSL := 1; MaxSL := 2; End
                                                    else Begin MinSL := 2; MaxSL := 1; End;

         If (NewSL - T0SLR) > SS_SLR[SLReturn,MaxSL] then
           Result := ReplaceSLR(SLReturn,MinSL);  // replace the minimum SLR Scenario

         If (NewSL - T0SLR) > SS_SLR[SLReturn,MinSL] then // Map didn't go far enough.. replace the maximum SLR Scenario too
           Result := ReplaceSLR(SLReturn,MaxSL);
       End;

End;

{-----------------------------------------------------------------------------------}

    {---------------------------------------------------------------------------------------------------}
    Function GetNextNumber(var RF: TSLAMMInputFile; ER,EC: Integer):single;
    Begin
        If Not RF.GetNextNumber(Result) then
          Begin  // Error Handling
            Raise ESLAMMError.Create('Error Reading '+RF.FileN+ ' File.  Row:'+IntToStr(ER+1)+
                  '; Col:'+IntToStr(EC+1)+'.');
          End;
    End;
    {---------------------------------------------------------------------------------------------------}
    Procedure PrepareFileForReading(Var FN: String; Var FExists: Boolean; Var TFile:TSLAMMInputFile);
    Begin
      FExists := (FN <> '');
      If FExists then if not FileExists(FN) then
        Begin
          ProgForm.Hide;
          Raise ESLAMMError.Create('File Setup Error, Cannot find file "'+FN+'"');
        End;

      If FExists then
        Begin
          TFile := TSLAMMInputFile.Create(FN);
          If Not TFile.PrepareFileForReading then
             Raise ESLAMMError.Create('Error Reading Headers for "'+FN+'"');

        End;
     End;
    {---------------------------------------------------------------------------------------------------}


Function TSLAMM_Simulation.ReadStormSurge(RIi,SLRi: Integer):Boolean;
Var StormFile: TSLAMMInputFile;
    SFExists: Boolean;
    Storm_Num: Double;
    ER, EC: Integer;
    Cl: CompressedCell;

Begin
  Result := True;
  With ProgForm do
    Setup('Reading Storm File '+ ExtractFileName(SSFileN[RIi]),YearLabel.Caption,SLRLabel.Caption,ProtectionLabel.Caption, True );
    PrepareFileForReading(SSFileN[RIi],SFExists, StormFile);
    Storm_Num := -10;

    If (Length(SSRasters[RIi,SLRi]) < Site.RunRows*Site.RunCols) then SetLength(SSRasters[RIi,SLRi], Site.RunRows*Site.RunCols);

    for ER:=0 to Site.ReadRows-1 do
     for EC:=0 to Site.RunCols-1 do
      begin
        If EC=0 then Result := ProgForm.Update2Gages(Trunc(ER/Site.RunRows*100),0);
        If not Result then Exit;
        If SFExists then Storm_Num := GetNextNumber(StormFile, ER, EC);

        RetA(ER,EC,Cl);
        If (Storm_Num > -9.99) and (Cl.MTLminusNAVD > -9998) then Storm_Num := Storm_Num - Cl.MTLminusNAVD;      // convert to MTL basis
        SSRasters[RIi,SLRi,(Site.ReadCols*ER)+EC] := FloatToWord(Storm_Num);
      End;

End;

Function TSLAMM_Simulation.MakeDataFile(CountOnly: Boolean; YearDikeFName, YearSalFName: String): Boolean;
Var DikOnly: Boolean;
    SalOnly: Boolean;
    UpliftFile, NWIFile,SLPFile,ElevFile,DikFile,SalFile,IMPFile,ROSFile,VDFile, D2MFile, StormFile1, StormFile2: TSLAMMInputFile;
    ElevFExists, SLPFExists, NWIFExists, DIKFExists,ROSFExists,IMPFExists,SalFExists,D2MFExists,UpliftFExists,VDFExists, SFExists1, SFExists2 : Boolean;

    i,ER,EC: Integer;
    AddToMap: Boolean;
    Neg_Num: Integer;
    LandMovement: Double;
    PROT_Number, PCT_IMP, NWI_Number, ROS_Number: Integer;
    Sal_Number: single;
    Elev_Number, Slope_Number, Dik_Number, Storm_Num1, Storm_Num2: double;  {elevation in meters, slope in degrees, storm elevation in meters}
    TotalWidth, SlopeAdjustment: double;
    ReadCat: Integer;
    Hist_Adj, DEM_to_NWI_m: Double; {correction in meters}
    ncells: Integer;
    VDNumber,D2MNumber, MTL_Correction, Lagoon_Correction: Double;

    NAveraged  : Array of Integer;
    CellstoAvg : Array of Array of CompressedCell;
    FlatArrIndex: LongInt;
    ReadCell, TemplateCell: CompressedCell;
    SubSite: TSubSite;
    NWI_Date: Integer;
    LF: Integer;


    {---------------------------------------------------------------------------------------------------}
    Procedure SaveCellToBin(Col:Integer);
    Var SaveCol: Integer;
    Begin
      SaveCol := Col Div RescaleMap;
      CellstoAvg[SaveCol,NAveraged[SaveCol]] := ReadCell;
      Inc(NAveraged[SaveCol]);
    End;

    Procedure AverageCells(AvgRow: Integer);
    Var j,k: Integer;
        NCellsAvg, SaveRow : Integer;
        AvgCell: PCompressedCell;
        WidthPerCell, CurrentWidth, CurrentElev, NewElev: Single;
        ThisCat: Integer;

    Begin
     NCellsAvg := RescaleMap*RescaleMap;
     WidthPerCell := Site.RunScale / NCellsAvg;
     SaveRow := (AvgRow- Site.TopRowHeight) Div RescaleMap; // zero indexed

      for j := 0 to Site.RunCols-1 do
       Begin
         for k := 0 to NCellsAvg-1 do
          if (k>NAveraged[j]-1)
           then SetCellWidth(@ReadCell,Blank,Site.RunScale*(NCellsAvg-NAveraged[j])/NCellsAvg)  // all other cells are blank
           else
             Begin
               AvgCell := @(CellstoAvg[j][k]);
               if k=0
                 then Begin
                        ReadCell := AvgCell^;   // first cell read
                        ReadCell.Widths[1] := WidthPerCell;
                      End
                 else
                   Begin
                     ThisCat := GetCellCat(AvgCell);
                     CurrentWidth := CellWidth(@ReadCell,ThisCat);
  {cat}              SetCellWidth(@ReadCell,ThisCat,CurrentWidth+WidthPerCell);
                     NewElev := CatElev(AvgCell,ThisCat);

                     If CurrentWidth > 0  //averaging of cell elevs
                       then
                         Begin
                           CurrentElev := CatElev(@ReadCell,ThisCat);
                           if (CurrentElev > 998.9)  // don't average in no-data
                             then SetCatElev(@ReadCell,ThisCat, NewElev)
                             else if (NewElev < 998.9) then  //screen out no-data
  {avg elev}                    SetCatElev(@ReadCell,ThisCat, ((NewElev*WidthPerCell) + (CurrentElev*CurrentWidth)) /(WidthPerCell+CurrentWidth));  // weighted avg.
                         End
  {elev}               else SetCatElev(@ReadCell,ThisCat, NewElev);

  {avg slope}        ReadCell.TanSlope := ((ReadCell.TanSlope * k) + (AvgCell.TanSlope))/(k+1);  // running weighted average

                     If AvgCell.ProtDikes then ReadCell.ProtDikes := True;
                     If AvgCell.ElevDikes then ReadCell.ElevDikes := True;

  {avg salin}        ReadCell.Sal[1] := ((ReadCell.Sal[1] * k) + (AvgCell.Sal[1]))/(k+1);  // running weighted average
//   {avg Imperv}       ReadCell.ImpCoeff := Round( ((ReadCell.ImpCoeff * k) + (AvgCell.ImpCoeff))/(k+1) );  // running weighted average  FIXME
  {avg MTL }         ReadCell.MTLminusNAVD := ((ReadCell.MTLminusNAVD * k) + (AvgCell.MTLminusNAVD))/(k+1);  // running weighted average
  {avg uplift }      ReadCell.Uplift := ((ReadCell.Uplift * k) + (AvgCell.Uplift))/(k+1);  // running weighted average
  {avg D2Mouth }     ReadCell.D2Mouth := ((ReadCell.D2Mouth * k) + (AvgCell.D2Mouth))/(k+1);  // running weighted average

                   End;
             End;

         Inc(NCells);
         MapMatrix[(Site.RunCols*SaveRow)+j] := NCells-1;
         SetA(SaveRow,j,ReadCell);
       End;
    End;

    {---------------------------------------------------------------------------------------------------}
    Procedure ReadDikeOrSalinityOnly;
          Begin
            // Read the cell attributes
            RetA(ER,EC,ReadCell);

            // Update dike value
            if DikOnly then
              begin
                //ReadCell.ProtDikes := (TRUNC(Dik_Number) <> NO_DATA) and ((DIK_Number >0) or (DIK_Number=-5));
                ReadCell.ProtDikes := (TRUNC(Dik_Number) <> NO_DATA) and (Dik_Number <> 0);
                if (not ClassicDike) then
                  ReadCell.ElevDikes := (TRUNC(DIK_Number) <> NO_DATA) and (DIK_Number > 0);
              end;

            // Update salinity value
            if SalOnly then
              ReadCell.Sal[1] := Sal_Number;

            // Set cell attributes
            SetA(ER,EC,ReadCell);    // FIXME annual reading of dikes or salinity not enabled for scaled cell sizes yet
          End;
    {---------------------------------------------------------------------------------------------------}
    Function GetNextCSVNumber(var RF: Textfile):double;
    Var S: ANSIString;
        C: ANSIChar;
    Begin
      S:='';
        Repeat
          Read(RF,C);
          If (C<>',') and (ord(C)>32) then S := S + C;
        Until ((S<>'') and (C=',')) or eoln(rf);
        Result := StrToFloat(String(S));
    End;

    {---------------------------------------------------------------------------------------------------}
    Procedure PrepareStormFiles;
    Var SLRFileN,FileExt,StormString, ReturnStr,SLRStr: String;

    Begin
       FileExt := ExtractFileExt(StormFileN);
       If LastDelimiter('.',StormFileN) > 0
         then StormString := Copy(StormFileN, 0, LastDelimiter('.',StormFileN) - 1)
         else StormString := StormFileN;
       ReturnStr := Copy(StormString,Length(StormString)-2,3);
       SLRStr := Copy(StormString,Length(StormString)-5,2);

       If ReturnStr = '010'
        then
         Begin
           SSFileN[1] := StormFileN;
           SSFileN[2] := Copy(StormString,0,Length(StormString)-3)+'100';
           SSFileN[2] := ChangeFileExt(SSFileN[2],FileExt);
         End
        else
         Begin
           SSFileN[2] := StormFileN;
           SSFileN[1] := Copy(StormString,0,Length(StormString)-3)+'010';
           SSFileN[1] := ChangeFileExt(SSFileN[2],FileExt);
         End;

       PrepareFileForReading(SSFileN[1],SFExists1, StormFile1);
       PrepareFileForReading(SSFileN[2],SFExists2, StormFile2);

       UseSSRaster[1] := SFExists1;
       UseSSRaster[2] := SFExists2;

       SS_SLR[1,1] := 0;   // initialize as 0M SLR for 10 yr storm
       SS_SLR[1,2] := -1;  // initialize as empty
       SS_SLR[2,1] := 0;   // initialize as 0M SLR for 100 yr storm
       SS_SLR[2,2] := -1;  // initialize as empty

       SLRFileN := Copy(StormString,0,Length(StormString)-6)+'12_010';
       SLRFileN := ChangeFileExt(SLRFileN,FileExt);
       SS_Raster_SLR[1] := FileExists(SLRFileN);                // are we using SLR data?   Look for 12" data file as signal for now

       SLRFileN := Copy(StormString,0,Length(StormString)-6)+'12_100';
       SLRFileN := ChangeFileExt(SLRFileN,FileExt);
       SS_Raster_SLR[2] := FileExists(SLRFileN);                // are we using SLR data?  Look for 12" data file as signal for now

    End;
    {---------------------------------------------------------------------------------------------------}


Var RunRow, RunCol, ScaleER, ScaleEC, j: Integer;
    GISLookup  : Array [0..255] of SmallInt;


Begin  {MakeDataFile}
  For j := 0 to 255 do
    GisLookup[j] := -99;
  For j := 0 to Categories.NCats-1 do
    GISLookup[Categories.GetCat(j).GISNumber] := j;

  Result := True;
  DikOnly := YearDikeFName <> '';
  SalOnly := YearSalFName <> '';

  if CountOnly and ((optimizelevel = 0) or (RescaleMap>1)) then  // no optimization when rescaling map
    begin
      NumMMEntries := Site.Runrows * Site.Runcols;
      exit;
    end;

  if RescaleMap > 1 then
    Begin
      SetLength(NAveraged,Site.RunCols);
      SetLength(CellsToAvg,Site.RunCols);
      for i := 0 to Site.RunCols-1 do
        SetLength(CellsToAvg[i],RescaleMap*RescaleMap);  // 4 or 9 cells to average;
    End;

  TotalWidth := Site.RunScale;
  Site.MaxROS := 0;  {Default to zero raster output subsites}
  Site.ROSBounds := nil; {empty dynamic array}
  MaxMTL := -9999;
  MinMTL := 9999;

  If BatchMode then ProgForm.Caption := 'Simulating '+Site.GlobalSite.Description;
  If (Not DikOnly) and (Not SalOnly) then ProgForm.YearLabel.Visible:=False;
  ProgForm.SLRLabel.Visible:=False;
  ProgForm.ProtectionLabel.Visible:=False;
  ProgForm.Show;
  ProgForm.Update;

  InitCell(@TemplateCell);

  If (Not CountOnly) and (Not DikOnly) and (Not SalOnly) then
    Begin
      If Not SaveMapsToDisk
          Then
             Try
               If not Large_Raster_Edit then MakeMem(TemplateCell);
             Except
               If Map<>nil then
                 Begin
                   LF := Length(Map);
                   For i := 0 to LF-1 do
                     Dispose(Map[i]);
                   Map := nil;
                 End;
               Map := nil;
(*               If MessageDlg('Error creating map in memory, write map to disk instead?',mtconfirmation,[mbyes,mbno],0) = mryes
                 then Begin
                        SaveMapsToDisk := True;
                        MakeFile(MapHandle,Site.RunRows,Site.Cols,S60FileN,TemplateCell);
                      End
                 else *)
                      Begin
                        ProgForm.Cleanup;
                        Raise ESLAMMError.Create('Error creating map in memory, map exceeds size of memory in system.');
                      End;
             End;
      ProgForm.Show;
      ProgForm.Update;

    End;

  ProgForm.ProgressLabel.Caption:='Reading Site Characteristics';
  If CountOnly then ProgForm.ProgressLabel.Caption:='Counting Cells to Track';
  ProgForm.HaltButton.Visible := True;

  // Prepare the (annual) dike files to read if they exist
  If DikOnly then
    begin
      ProgForm.YearLabel.Caption:=IntToStr(Year);
      ProgForm.ProgressLabel.Caption:='Reading Dike File '+ExtractFileName(YearDikeFName);
      PrepareFileForReading(YearDikeFName,DikFExists,DikFile);     //open annual dike file
    end
  else PrepareFileForReading(DikFileN,DikFExists,DikFile);       // 3.11.2010 always load dike file for pre-processor under "no-dikes" conditions

  SFExists1 := False; SFExists2 := False;
  If StormFileN <> '' then PrepareStormFiles;

  SalFExists := False;
  if Pos('.xls',lowercase(SalFileN))=0 then
    Begin
      //Prepare the (annual) salinity file(s) to read if they exist
      if SalOnly then
        begin
          ProgForm.YearLabel.Caption:=IntToStr(Year);
          ProgForm.ProgressLabel.Caption:='Reading Salinity File '+ExtractFileName(YearSalFName);
          PrepareFileForReading(YearSalFName,SalFExists,SalFile);   //open annual salinity file
        end
      else PrepareFileForReading(SalFileN,SalFExists,SalFile);
    End;

  // Prepare files to read when is not only a dike and not salinity map only
  if (not DikOnly) and (not SalOnly) then
     Begin
        PrepareFileForReading(ROSFileN,ROSFExists,ROSFile);
        If ROSFExists
           then Begin
                  //NRosArray := Site.RunRows*Site.Cols;
                  //if (Length(ROSArray) < NRosArray) then SetLength(ROSArray, NRosArray);
                  if (Length(ROSArray) < Site.RunRows*Site.RunCols) then SetLength(ROSArray, Site.RunRows*Site.RunCols);
                  For i := 0 to Site.RunRows*Site.RunCols -1 do
                    ROSArray[i] := 0;
                End
           else ROSArray := nil;
        PrepareFileForReading(IMPFileN,IMPFExists,IMPFile);
        PrepareFileForReading(NWIFileN,NWIFExists,NWIFile);
          If Not NWIFExists then Raise ESlammError.Create('Must include SLAMM Code (NWI) Data File');
        PrepareFileForReading(ElevFileN,ElevFExists,ElevFile);
        If Not ElevFExists then Raise ESlammError.Create('Must include Elevation Data File');
        PrepareFileForReading(SLPFileN,SLPFExists,SLPFile);
          If Not SLPFExists then Raise ESlammError.Create('Must include Slope Data File');
        PrepareFileForReading(UpliftFileN,UpliftFExists,UpliftFile);
        PrepareFileForReading(D2MFileN,D2MFExists,D2MFile);
        PrepareFileForReading(VDFileN,VDFExists,VDFile);

     End;

  // If either CountOnly or DikOnly or SalOnly is false
  if not (CountOnly or DikOnly or SalOnly ) then
    begin
      if (Length(MapMatrix) < Site.RunRows*Site.RunCols) then SetLength(MapMatrix, Site.RunRows*Site.RunCols);
      if (Large_Raster_Edit or (USE_DATAELEV and (OptimizeLevel>1))) and (Length(DataElev) < Site.RunRows*Site.RunCols) then SetLength(DataElev, Site.RunRows*Site.RunCols);
      if SFExists1 and (Length(SSRasters[1,1]) < Site.RunRows*Site.RunCols) then SetLength(SSRasters[1,1], Site.RunRows*Site.RunCols);
      if SFExists2 and (Length(SSRasters[2,1]) < Site.RunRows*Site.RunCols) then SetLength(SSRasters[2,1], Site.RunRows*Site.RunCols);

      if (OptimizeLevel>1) and (Length(MaxFetchArr) < Site.RunRows*Site.RunCols) then SetLength(MaxFetchArr, Site.RunRows*Site.RunCols);
      if (OptimizeLevel>1) then
        for i := 0 to Site.RunRows*Site.RunCols -1 do
         MaxFetchArr[i] := 0;
    end;

  NCells:=0;

  for ER:=0 to Site.ReadRows-1 do
    begin

      if RescaleMap > 1 then with Site do   // Rescale Only.  clear number of cells before collecting for averaging
       if (ER = 0) or
        ((((ER+1)-TopRowHeight) mod RescaleMap) =1)  then
          for i := 0 to Site.RunCols-1 do
            NAveraged[i] := 0;

      // Progress bar
      Result := ProgForm.Update2Gages(Trunc((Er)/Site.ReadRows*100),0);
      If not Result then Exit;

      for EC:=0 to Site.ReadCols-1 do
      begin
        if RescaleMap = 1
          then FlatArrIndex := (Site.ReadCols*ER)+EC
          else
            Begin
              RunRow := (ER + (RescaleMap - Site.TopRowHeight)) DIV RescaleMap;
              RunCol := EC DIV RescaleMap;
              FlatArrIndex := (Site.RunCols*RunRow)+RunCol;
            End;

        InitCell(@ReadCell);
        If RescaleMap = 1 then SubSite := Site.GetSubSite(EC,ER,@ReadCell)
                          else Begin
                                 SubSite := Site.GetSubSite(ScaledX(EC),ScaledY(ER),@ReadCell);
                                 ReadCell.SubSiteIndex := -9999;  // don't save for now
                               End;

        //Dike data
        DIK_Number:=0;
        If DikFExists then DIK_Number := GetNextNumber(DIKFile, ER, EC);      //Trunc(GetNextNumber(DIKFile))

        Storm_Num1 := -10;
        If SFExists1 then Storm_Num1 := GetNextNumber(StormFile1, ER, EC);
        Storm_Num2 := -10;
        If SFExists2 then Storm_Num2 := GetNextNumber(StormFile2, ER, EC);


        //Salinity Data
        Sal_Number :=0;
        if SalFExists then Sal_Number := GetNextNumber(SalFile, ER, EC);

        If DikOnly or SalOnly then          // If only salinity or dike are being updated mid-run
          Begin
            ReadDikeOrSalinityOnly;
            Continue;  // continue to the next cell
          End;

        //Raster Output Sites Data
        if (ROSFileN <> '')
          then
            begin
              ROS_Number := Trunc(GetNextNumber(ROSFile, ER, EC));
              if ROS_Number <> NO_DATA then ROS_Number := ROS_Number;
              if ROS_Number = NO_DATA then ROS_Number := 0;

            end
        else ROS_Number := 0;

        //NWI Date
        NWI_Date := Subsite.NWI_Photo_Date;

        //Elevation Number
        Elev_Number := GetNextNumber(ElevFile, ER, EC);


//      Elev_Number := Round(Elev_Number/1.5)*1.5;  // round to nearest 1.5 meters to simulate 5 foot contours

        //Slope Number
        Slope_Number := GetNextNumber(SlpFile, ER, EC);

        //NWI data
        NWI_Number := Trunc(GetNextNumber(NWIFile, ER, EC));

        if NWI_Number = 0 then NWI_Number:= 24;

        //Czech Sparse - Wertheim fill
        //  IF (ROS_Number=2) and (Elev_Number=NO_DATA) and ((NWI_Number=24) or (NWI_Number=NO_DATA)) then
        //    NWI_Number:=2;

        //  HCRT - Change to Inland Open Water for water behind dikes using
        // (1) Change all water to Inland Open Water
        // (2) Use the SLAMM interface fill function to fill all the connected water back to Estuarine Open Water
        //if NWI_Number = 17 then NWI_Number:= 15;
        //if NWI_Number = 19 then
        //  NWI_Number := 17;

        //  GCPLCC Project - Change to Inland Open Water using input subsite
        //if (Site.GetSubSiteNum(EC,ER)=1) and (NWI_Number = 5) then
        //  NWI_Number := 6;


        //Fill dryland
        //if (Elev_Number <> Site.NoElevData ) and (NWI_Number=24) and (Elev_Number <> 999) then
        //  NWI_Number := 2;

        //NYSERDA Project change Tidal Fresh Marsh to Transitional Marsh
        //if NWI_Number=6 then NWI_Number := 7;
        //if NWI_Number=9 then NWI_Number := 6;

{        If ((NWI_Number < 1) or (NWI_Number>26)) and (NWI_Number<>NO_DATA) then
          Raise ESlammError.Create('SLAMM6 Does not understand NWI Class Number '+IntToStr(NWI_Number)+' Within Data File "'+NWIFileN); }

        //Read Impervious file if it exists
        if IMPFExists then
          begin
            PROT_Number := Trunc(GetNextNumber(IMPFile, ER, EC));
            // PCT_IMP := Trunc(GetNextNumber(IMPFile, ER, EC));
            // ReadCell.ImpCoeff := PCT_IMP;

            ReadCell.PROT_Num := PROT_Number;

            //IF (PCT_IMP >=0) and CAT.ISDRYLAND (NWI_Number = 1) or (NWI_Number = 2) then          // fixme make this general for all dry land based on categories.pas
            //  If PCT_IMP > {0} {33 } 25 {15} {50} then NWI_Number := 1 else NWI_Number := 2;  // fixme make this general for developed dry land.

            //Czech Sparse - Wertheim fill
            //IF (PCT_IMP >=25) and (ROS_Number=2) and (Elev_Number=NO_DATA) and (NWI_Number=2)  then
            //  NWI_Number:=1;
          end;

        //MTL Correction
        MTL_correction:= SubSite.NAVD88MTL_correction;
        If VDFExists then
          begin
            VDNumber:= GetNextNumber(VDFile, ER, EC);
            if TRUNC(VDNumber) <> NO_DATA then
              MTL_Correction:= VDNumber;
          end;


(*       If (Site.GetSubSiteNum(EC,ER)=4) and (TRUNC(elev_number) = NO_DATA)  then
          Begin
            Elev_Number := 0.488;  // CASCO, fill phippsburg water elevs based on Route 216, TR 122 Phippsburg.docx
          End;
                    *)

(*        //  Casco Bay IFM Fill
        If (Site.GetSubSiteNum(EC,ER) in [1,2,4]) and (NWI_Number in [12,7]) then
          Begin
            NWI_Number := 20;
          End; *)

 (*       If (Site.GetSubSiteNum(EC,ER)=2) and (NWI_Number = 20)and (TRUNC(elev_number) = NO_DATA)  then
          Begin
            Elev_Number := 2.5;
            MTL_Correction := 0;
          End;          *)


        Lagoon_correction := 0;
        If SubSite.LagoonType <> LtNone then
            Lagoon_Correction := SubSite.LBeta * SubSite.ZBeachCrest;

        // Distance 2 Mouth Number
        D2MNumber := -9999;
        If D2MFExists then
          begin
            D2MNumber:= GetNextNumber(D2MFile, ER, EC);
            if TRUNC(D2MNumber) <> NO_DATA then
              ReadCell.D2mouth:= D2MNumber;
          end;

        For i := 1 to 2 do
          If RunUncertainty and (UncertSetup.ZUncertMap[i] <> nil) and (UncertSetup.UncSens_Iter > 0) then
            If (TRUNC(elev_Number) <> NO_DATA) then
              Elev_Number := Elev_Number + UncertSetup.ZUncertMap[i][FlatArrIndex];

        If (NWI_Number = NO_DATA) then NWI_Number := ORD(Blank)+1;

         //Dike attribute
         ReadCell.ProtDikes := (TRUNC(DIK_Number) <> NO_DATA) and ((DIK_Number > 0) or (DIK_Number=-5));
         // ReadCell.ProtDikes := (TRUNC(Dik_Number) <> NO_DATA) and (Dik_Number <> 0);
         if (not ClassicDike) then
          begin
           ReadCell.ElevDikes := (TRUNC(DIK_Number) <> NO_DATA) and (DIK_Number > 0);
           if ((NWI_Number in [15..19]) or (NWI_Number=NO_DATA)) and (ReadCell.ElevDikes) then  //inland open water, estuarine open water, open ocean, riverine tidal, tidal creek
            NWI_Number := 1;
          end;

         //Make all developed diked
         //if NWI_Number =1 then ReadCell.ProtDikes := True;

         // HCRT Modification to add diked areas in input subsites
         //if ((Site.GetSubSiteNum(EC,ER) = 19) or (Site.GetSubSiteNum(EC,ER) = 20)) then
         //  begin
         //   ReadCell.ProtDikes := True;
         //   GridForm.DikesChanged := True;
         //  end;


         //code open water as inland open water behind dikes (TNC-Walsh)
         //if (Site.GetSubSite(EC,ER) = Site.SubSites[9]) and (NWI_Number in [16..19]) then
         //begin
         //   NWI_number := 15;
          //end;

         // Assign the salinity value
         if SalFExists then ReadCell.Sal[1] := Sal_Number;


         // MTL to NAVD88 correction
         ReadCell.MTLminusNAVD := MTL_correction;
         If MTL_Correction > MaxMTL then MaxMTL := MTL_Correction;
         If MTL_Correction < MinMTL then MinMTL := MTL_Correction;

         // Uplift correction
         If UpliftFExists then ReadCell.Uplift := GetNextNumber(UpliftFile, ER, EC)
                          else ReadCell.Uplift := 0;


         ReadCell.ErosionLoss := 0;
         ReadCell.BTFErosionLoss := 0;

         //Assign land cover category
         If (NWI_Number >=0) and (NWI_Number <=255) then
           ReadCat := GISLookup[Word(NWI_Number)] else ReadCat := blank;

         If (TRUNC(elev_number) = NO_DATA) and LoadBlankIfNoElev then
           if (not (NWI_Number in [17,19])) then Readcat:= blank;  //not open ocean or estuarine water

         SetCellWidth(@ReadCell,ReadCat,TotalWidth);

         //Assign the subsidence rate
         If (not UpliftFExists) or (TRUNC(ReadCell.Uplift) = NO_DATA) then  //no cell by cell uplift available
           with Subsite do
             Begin
               Hist_Adj := Historic_trend - Historic_Eustatic_trend; { mm/yr global historic trend, subtracted from the local historic trend to remove
                                                  double counting when forecasting. http://www.grida.no/climate/ipcc_tar/wg1/424.htm }
                                                 { 1.7 from 1900-2000 based on IPCC 2007a }

               Readcell.Uplift := - Hist_Adj * 0.1;
                  {cm/yr}           {mm/yr}  {cm/mm}
               {projected SLR} {Years of the model run beyond 1990} {Historic local trend - local adjustment if req.}
             End;

         //Set cell slope
         If (TRUNC(Slope_Number) <> NO_DATA) then
           ReadCell.TanSlope:=ABS(Tan(DegToRad(Slope_Number)));  //6/17/19  negative slopes are unexpected and do not work in equations

         //Dike elevation adjustments
         if (not ClassicDike) and (ReadCell.ElevDikes)  //elevation will be set to dike height.
            then Elev_Number := DIK_Number - MTL_Correction;  //Dike elevations provided with respect to NAVD88 and adjusted to MTL

         If SFExists1 then if (Storm_Num1 > -9.99) and (not CountOnly) then
           Begin
             Storm_Num1 := Storm_Num1 - MTL_Correction; // convert to MTL Basis
             SSRasters[1,1,FlatArrIndex] :=  FloatToWord(Storm_Num1);
           End;

         If SFExists2 then if (Storm_Num2 > -9.99) and (not CountOnly) then
           Begin
             If Storm_Num2 > -9.99 then Storm_Num2 := Storm_Num2 - MTL_Correction; // convert to MTL Basis
             SSRasters[2,1,FlatArrIndex] :=  FloatToWord(Storm_Num2);
           End;

         //Assign elevations to the cells
         If (TRUNC(Elev_Number) <> NO_DATA) then
          Begin
            //Elevation adjustments for cells that are not dikes
            if (not ReadCell.ElevDikes) then
              begin
                //(1) Refer to MTL
                Elev_Number := (Elev_Number - MTL_Correction - Lagoon_Correction) ; {Set Elevation so that MT = 0.0}
                  {meters}        {meters}       {meters}         {meters}

                //(2) Consider uplift for the years between DEM and NWI
                LandMovement := -(ReadCell.Uplift * 10);
                  {mm/year}          {cm/year  *  mm/cm}

                With subsite do
                  DEM_to_NWI_m := (NWI_Date - DEM_Date)* (LandMovement) * 0.001 ;
                    {meters}      {       years       }      {mm/yr}    {m / mm}

                  Elev_Number := Elev_Number - DEM_to_NWI_m;  { calculate elevations at NWI photo date }
                    {meters}       {meters}      {meters}

                  //(3) Slope correction
                  SlopeAdjustment := (Site.ReadScale*0.5) * ReadCell.TanSlope;    {QA 11.10.2005}
                  Elev_Number := Elev_Number - SlopeAdjustment;
              end;

            // Set elevation
            SetCatElev(@ReadCell,ReadCat,Elev_Number);

            If not CountOnly then
              IF Large_Raster_Edit or (USE_DATAELEV and (OptimizeLevel>1)) then
                DataElev[FlatArrIndex] := FloatToWord(Elev_Number);

          End;  //  If (TRUNC(Elev_Number) <> NO_DATA) then

         if ROSFExists then ROSArray[FlatArrIndex] := ROS_Number;

             With Site do  { Assign min and max boundaries for ROS "Raster Output Sites" }
               Begin
                 If MaxROS < ROS_Number then
                   Begin
                     If ROS_Number > Length(ROSBounds) then SetLength(ROSBounds,ROS_Number+2);

                     For i := MaxROS+1 to ROS_Number do
                       Begin
                         ROSBounds[i-1].X1 := 99999;   {min}
                         ROSBounds[i-1].Y1 := 99999;   {min}
                         ROSBounds[i-1].X2 := -99999;  {max}
                         ROSBounds[i-1].Y2 := -99999;  {max}
                       End;
                     MaxROS := ROS_Number;
                   End;

                 If ROS_Number>0 then with ROSBounds[ROS_Number-1] do
                   Begin
                     ScaleEC := ScaledX(EC);
                     ScaleER := ScaledY(ER);
                     If X1> ScaleEC then X1 := ScaleEC;
                     If Y1>ScaleER then Y1 := ScaleER;
                     If X2<ScaleEC then X2 := ScaleEC;
                     If Y2<ScaleER then Y2 := ScaleER;
                    End;
               End;


        AddToMap :=  (OptimizeLevel=0) or (RescaleMap > 1) or ((NWI_Number<>NO_DATA) and (NWI_Number<>ORD(Blank)+1));
        Neg_Num := -99;
        With Categories do
          IF (OptimizeLevel>1) and (RescaleMap = 1) and
                ( ( NWI_Number = ORD(OpenOcean)+1 ) or
                  ( NWI_Number = ORD(EstuarineWater)+1 ) or
                  (( NWI_Number = ORD(DevDryLand) +1) and (CatElev(@ReadCell,ReadCat) > ELEV_CUTOFF ))or
                  (( NWI_Number = ORD(UndDryLand) +1) and (CatElev(@ReadCell,ReadCat) > ELEV_CUTOFF )) )  then
          Begin
            Neg_Num := -NWI_Number;
            AddToMap := False;
          End;

        If AddToMap and (RescaleMap = 1) then Inc(NCells);

        If Not CountOnly then
          Begin
            if (RescaleMap = 1) then  // otherwise MapMatrix set in AvgCells
             Begin
              If AddToMap
                then MapMatrix[FlatArrIndex] := NCells-1
                else MapMatrix[FlatArrIndex] := Neg_Num;
             End;

            if Large_Raster_Edit
              then MapMatrix[FlatArrIndex] := NWI_Number
              else If ((Not SaveMapsToDisk) or (MakeNewDiskMap)) then
                if RescaleMap = 1 then SetA(ER,EC,ReadCell)    // Set the new values of the cell
                                  else SaveCellToBin(EC);      // Rescale Only.  collect cells in appropriate bins for averaging

          End;
      End;  {EC Loop}

      if RescaleMap > 1 then with Site do   // Rescale Only.  clear number of cells before collecting for averaging
       if ((((ER+1)-TopRowHeight) mod RescaleMap) =0)  then
         AverageCells(ER)

  end; {For ER loops}

  If NTimeSteps=0 then NTimeSteps := 1;  //minimum for map drawing
  for j:=0 to NRoadInf-1 do
    Begin
      RoadsInf[j].InitializeRoadVars;
      RoadsInf[j].Overwrite_Elevs;  // If ReadElevs, overwrite map elevs
    End;

  for j:=0 to NPointInf-1 do
      PointInf[j].InitializePointVars;


  If DikOnly then
    Begin
      DikFile.Destroy;
      //Exit;
    End;

  if SalOnly then
     Begin
      SalFile.Destroy;
      //Exit;
    End;

  if DikOnly or SalOnly then Exit;

  If RunUncertainty and (OptimizeLevel>1)
    then
      Begin
        If (UncertSetup.UncSens_Iter = 0) then NumMMEntries := TRUNC(NCells*1.10);  // buffer by 10% in case elevation uncertainty push more cells down into the tracked zone.
           {set MMentries based on deterministic run}
      End
    else NumMMEntries := NCells;  // non uncertainty code

  InitCell(@BlankCell);
  SetCellWidth(@BlankCell,Blank,Site.RunScale);

  InitCell(@OceanCell);
  SetCellWidth(@OceanCell,Categories.OpenOcean,Site.RunScale);
  SetCatElev(@OceanCell,Categories.OpenOcean,- Site.GlobalSite.SaltElev);

  InitCell(@EOWCell);
  SetCellWidth(@EOWCell,Categories.EstuarineWater,Site.RunScale);
  SetCatElev(@EOWCell,Categories.EstuarineWater,- Site.GlobalSite.SaltElev);

  InitCell(@UndDryCell);
  SetCellWidth(@UndDryCell,Categories.UndDryLand,Site.RunScale);
  SetCatElev(@UndDryCell,Categories.UndDryLand,Elev_Cutoff);

  InitCell(@DevDryCell);
  SetCellWidth(@DevDryCell,Categories.DevDryLand,Site.RunScale);
  SetCatElev(@DevDryCell,Categories.DevDryLand,Elev_Cutoff);

  If CountOnly then ProgForm.Hide;

  NWIFile.Destroy;

  SLPFile.Destroy;
  ElevFile.Destroy;

  If DikFExists then DikFile.Destroy;
  if SalFExists then SalFile.Destroy;
  If IMPFExists then IMPFile.Destroy;
  If ROSFExists then ROSFile.Destroy;

  if RescaleMap > 1 then    // Rescale Only.  Free memory used for averaging bins
    Begin
      NAveraged := nil;
      for i := 0 to Site.RunCols-1 do
        CellsToAvg[i] := nil;
      CellsToAvg := nil;
    End;

  DisposeFile(MapHandle,False,'');
End;

{-----------------------------------------------------------------------------------}

Function TSLAMM_Simulation.CopyMapsToMSWord : Boolean;

      {-------------------------------------------------------------------------}
      Procedure CopyCurrentMap(GF: TGridForm; Desc: String; Attempt: Integer; ROS: Boolean);
      var
        GIFFileN, Descrip2 : String;
        Range: Variant;
        NumPars: Integer;

              Procedure AddandSelect;
              Begin
                WordDoc.Paragraphs.Add;
                NumPars := WordDoc.Paragraphs.Count;
                Range := WordDoc.Range(
                    WordDoc.Paragraphs.Item(NumPars).Range.Start,
                    WordDoc.Paragraphs.Item(NumPars).Range.End);
              End;

      Begin
         Descrip2 := ExtractFileName(MakeFileName) + Desc;

         Try

         If Maps_to_GIF and (Not ROS) then
           Begin
             GIFFileN := ExtractFilePath(MakeFileName)+ Descrip2;
             GF.SaveMaptoGIF(GIFFileN);

             If not (RunUncertainty or RunSensitivity) then  // separate logs exist for uncertainty & sensitivity runs.
             Try
               Append(RunRecordFile);
               SummarizeFileInfo('GIF Written',GIFFileN);
               Closefile(RunRecordFile);
             Except
               MessageDlg('Error appending to Run-Record File '+RunRecordFileName,mterror,[mbOK],0);
             End;
           End;

         If Not Maps_to_MSWord then Exit;

         ProgForm.ProgressLabel.Caption := 'Copying to MSWord (Using Clipboard)';
         ProgForm.Update;
         GF.CopyMapToClipboard(nil);

         If not WordInitialized then
            Begin
              try
                WordApp := GetActiveOLEObject('Word.Application');
              except
                WordApp := CreateOLEObject('Word.Application');
              end;
              WordApp.Visible := True;
              WordApp.Documents.Add;
              WordDoc := WordApp.Documents.Item(1);
              WordDoc.Paragraphs.Add;
              WordInitialized := True;
            End;

         NumPars := WordDoc.Paragraphs.Count;
         WordDoc.Paragraphs.Add;
         WordDoc.Paragraphs.Add;

         Range := WordDoc.Range(
         WordDoc.Paragraphs.Item(NumPars + 2).Range.Start,
         WordDoc.Paragraphs.Item(NumPars + 2).Range.End);
         Range.Paste;

{        WordDoc.Paragraphs.Add; }  {TEST}                  // resize document within word, look into VB for answer on MSWord side
         AddAndSelect;
         Range.Text := Descrip2;
         AddAndSelect;
         Range.Text := DateTimeToStr(Now()) + '  ~';

         Except
           If Maps_to_GIF then Raise
           else
            If Attempt<4
             then Begin
                    SysUtils.Sleep(5000);
                    CopyCurrentMap(GF,Desc,Attempt+1,ROS);
                  End
             else If MessageDlg('Runtime Error copying map to Microsoft Word for year '+IntToStr(Year)+
                                '.  Retry writing map to Word?',mterror,[mbyes,mbno],0)= mryes
                     then
                       Begin
                         If Attempt > 4 then
                           Begin
                             If MessageDlg('Cannot contact old word document in multiple attempts.  Open New Word document?',mterror,[mbyes,mbno],0)= mryes
                               then WordInitialized := False;
                           End;
                         CopyCurrentMap(GF,Desc,Attempt+1,ROS);
                       End;
         End;
      End;
      {-------------------------------------------------------------------------}

Var i: Integer;
    gridform2: TGridForm;  // must be invisible to avoid PL2 crash

      Procedure PrepareGridForm2(X1,X2,Y1,Y2: Integer; Desc: String; ROS: boolean);
      Var j, jmax: Integer;
          DescLabel: String;
      Begin
           With GridForm2 do
             Begin

               DrawingRect := False;
               RunPanel.Top := 0;
               RunPanel.Visible := True;
               //ShowRunPanel;
               ZoomBox.Visible := False;
               ToolBox1.ItemIndex := 1;

               MapNR := ABS(Y1-Y2)+1;
               MapNC := ABS(X1-X2)+1;
               GridScale := Site.RunScale;
               SS := Self;
               ThisSite := Site;
               UserStop:=False;
               GridForm2.SlpFileN := SlpFileN;
               SaveBtStream := False;
               Result := DrawEntireMap(i,True,ROS);
               If Not Result then Exit;

               CopyCurrentMap(GridForm2,' '+Desc,1,ROS);

{               GraphBox.Items =
                 0 SLAMM Map
                 1 Elevations
                 2 Salinity MLLW
                 3 Salinity MTL
                 4 Salinity MHHW
                 5 Salinity 30D hi
                 6 Accretion
                 7 Subsidence
                 8 MTL NAVD88
                 9 Marsh Erosion
                 10 Beach Erosion
                 11 Simplified Categ
                 12 Probability SAV }

               // Salinity Maps
               If SalinityMaps then
                 begin

                  jmax := 5;
                  if trim(SalFileN)<>'' then jmax := 2;
                  For j := 2 to jmax do
                    If (NumFwFlows > 0) or ((j<2) or (j>5)) then
                      Begin
                        GridForm2.GraphBox.ItemIndex := j;
                        Result := DrawEntireMap(i,True,ROS);
                        If Not Result then Exit;
                        DescLabel := GridForm.GraphBox.Items[j];
                        if j=2 then DescLabel := 'Salinity';
                        CopyCurrentMap(GridForm2,DescLabel+' '+Desc,1,ROS);
                      End;
                 end;

              //Accretion Maps
              if AccretionMaps then
                begin
                  GridForm2.GraphBox.ItemIndex := 6;
                  Result := DrawEntireMap(i,True,ROS);
                  If Not Result then Exit;
                  CopyCurrentMap(GridForm2,GridForm2.GraphBox.Items[6]+' '+Desc,1,ROS);
                end;

               //Ducks Maps
               If DucksMaps then
                   Begin
                     GridForm2.GraphBox.ItemIndex := 11;
                     Result := DrawEntireMap(i,True,ROS);
                     If Not Result then Exit;
                     CopyCurrentMap(GridForm2,GridForm2.GraphBox.Items[11]+' '+Desc,1,ROS);
                   End;

                //Connectivity Maps
                if ConnectMaps then
                  Begin
                    GridForm2.GraphBox.ItemIndex := 12;
                     Result := DrawEntireMap(i,True,ROS);
                     If Not Result then Exit;
                     CopyCurrentMap(GridForm2,GridForm2.GraphBox.Items[12]+' '+Desc,1,ROS);
                   End;

                //Inundation Maps
                if InundMaps then
                  Begin
                    GridForm2.GraphBox.ItemIndex := 13;
                     Result := DrawEntireMap(i,True,ROS);
                     If Not Result then Exit;
                     CopyCurrentMap(GridForm2,GridForm2.GraphBox.Items[13]+' '+Desc,1,ROS);
                   End;

(*                // Road Inundation Maps
                if RoadInundMaps then
                 Begin
                    GridForm2.GraphBox.ItemIndex := 2;
                     Result := DrawEntireMap(i,True,ROS);
                     RoadInundationUnit.ShowRoadInundation(Self, GridForm2, True);
                     If Not Result then Exit;
                     CopyCurrentMap(GridForm2,'Road Inundation Map '+Desc,1);
                   End; *)

                //SAV Maps
                if SAVMaps then
                  Begin
                    GridForm2.GraphBox.ItemIndex := 14;
                     Result := GridForm2.DrawEntireMap(i,True,ROS);
                     If Not Result then Exit;
                     CopyCurrentMap(GridForm2,GridForm2.GraphBox.Items[14]+' '+Desc,1,ROS);
                   End;



             End;

      End;

Var k, kmax: Integer;
    DescLabel: String;
Begin       // PROCEDURE CopyMapsToMSWord
   Result := True;
   GridForm.SaveBtStream := False;

(*If  UncAnalysis then    //code would limit saving of files to word/GIF to GIS year setup
   Begin
     If Not UncertSetup.SaveUncGIS then Exit;
     If Not UncertSetup.SaveALLGIS then
       if not IntInString(Year,UncertSetup.GISYears) then Exit;
   End; *)

  If GridForm.GraphBox.ItemIndex <> 0 then
    Begin
      GridForm.GraphBox.ItemIndex := 0;
      Result := GridForm.DrawEntireMap(0,True,False);
      If Not Result then Exit;
      GridForm.RunPanel.Visible := True;
    End;
  CopyCurrentMap(GridForm,'',1,False);

  If SalinityMaps then
    begin
    // Salinity
        kmax := 5;
        if trim(SalFileN)<>'' then kmax := 2;

        For k := 2 to kmax do
          If (NumFwFlows > 0) or ((k<2) or (k>5)) then
          Begin
            GridForm.GraphBox.ItemIndex := k;
            Result := GridForm.DrawEntireMap(0,True,False);
            If Not Result then Exit;
            GridForm.RunPanel.Visible := True;
            DescLabel := GridForm.GraphBox.Items[k];
            if k=2 then DescLabel := 'Salinity';
            CopyCurrentMap(GridForm,DescLabel,1,False);
          End;
      end;

    if AccretionMaps then
      begin
        // Accretion
        GridForm.GraphBox.ItemIndex := 6;
        Result := GridForm.DrawEntireMap(0,True,False);
        If Not Result then Exit;
        GridForm.RunPanel.Visible := True;
        CopyCurrentMap(GridForm,GridForm.GraphBox.Items[6],1,False);
      end;

    If DucksMaps then
      Begin
        GridForm.GraphBox.ItemIndex := 11;
        Result := GridForm.DrawEntireMap(0,True,False);
        If Not Result then Exit;
        GridForm.RunPanel.Visible := True;
        CopyCurrentMap(GridForm,GridForm.GraphBox.Items[11],1,False);
      End;

    If ConnectMaps then
      Begin
        GridForm.GraphBox.ItemIndex := 12;
        Result := GridForm.DrawEntireMap(0,True,False);
        If Not Result then Exit;
        GridForm.RunPanel.Visible := True;
        CopyCurrentMap(GridForm,GridForm.GraphBox.Items[12],1,False);
      End;

    If InundMaps then
      Begin
        GridForm.GraphBox.ItemIndex := 13;
        Result := GridForm.DrawEntireMap(0,True,False);
        If Not Result then Exit;
        GridForm.RunPanel.Visible := True;
        CopyCurrentMap(GridForm,GridForm.GraphBox.Items[13],1,False);
      End;

    If RoadInundMaps then
      Begin
        GridForm.GraphBox.ItemIndex := 2;
        Result := GridForm.DrawEntireMap(0,True,False);
        GridForm.RoadIndex := -1; // show all roads
        GridForm.ShowRoadInundation;
        If Not Result then Exit;
        GridForm.RunPanel.Visible := True;
        CopyCurrentMap(GridForm,'Road Inundation Map',1,False);
      End;

    If SAVMaps then
      Begin
        GridForm.GraphBox.ItemIndex := 14;
        Result := GridForm.DrawEntireMap(0,True,False);
        If Not Result then Exit;
        GridForm.RunPanel.Visible := True;
        CopyCurrentMap(GridForm,GridForm.GraphBox.Items[14],1,False);
      End;

    If DucksMaps or (GridForm.GraphBox.ItemIndex <> 0) then
      Begin
        GridForm.GraphBox.ItemIndex := 0;
        Result := GridForm.DrawEntireMap(0,True,False);
        If Not Result then Exit;
        GridForm.RunPanel.Visible := True;
      End;

   Result := ValidateOutputSites;
   If Not Result then Exit;

   For i := 1 to Site.NOutputSites do  {These are output sites, ROS handled below}
      with Site.OutputSites[i-1] do
         Begin
           If i=1 then Application.CreateForm(TGridForm,GridForm2);
           GridForm2.SaveBtStream := False;
           If UsePolygon then with ScalePoly do PrepareGridForm2(MinCol,MaxCol,MinRow,MaxRow,Description, FALSE)
                         else with ScaleRec do  PrepareGridForm2(X1,X2,Y1,Y2,Description, FALSE);
           If i=Site.NOutputSites then GridForm2.Free;
         End;

   For i := 1 to Site.MaxROS do
    with Site.RosBounds[i-1] do
       Begin
         If i=1 then Application.CreateForm(TGridForm,GridForm2);
         GridForm2.SaveBtStream := False;
         PrepareGridForm2(X1,X2,Y1,Y2,'ROS '+IntToStr(i),TRUE);
         If i=Site.MaxROS then GridForm2.Free;
       End;
End;

{-----------------------------------------------------------------------------------}

Function TSLAMM_Simulation.ValidateOutputSites: Boolean;
var i,j: Integer;
Begin
   Result := True;
   For i := 1 to Site.NOutputSites do
    with Site.OutputSites[i-1] do
     If UsePolygon
      then with ScalePoly do
       Begin
         Result := NumPts>1;
         If Not result then
           Begin
             MessageDlg('Boundary of polygon output site '+inttostr(i)+' not properly defined.',mterror,[mbok],0);
             Exit;
           End;

         For j := 1 to NumPts do with TPoints[j-1] do
           Begin
             if X<0 then X := 0; If X>Site.RunCols-1 then X := Site.RunCols-1;
             if Y<0 then Y := 0; If Y>Site.RunRows-1 then Y := Site.RunRows-1;
           End;
       End
      else with ScaleRec do
       Begin
         Result := (X1>0) or (X2>0) or (Y1>0) or (Y2>0);
         If Not result then
           Begin
             MessageDlg('Boundary of output site '+inttostr(i)+' not properly defined.',mterror,[mbok],0);
             Exit;
           End;

         if X1<0 then X1 := 0; If X1>Site.RunCols-1 then X1 := Site.RunCols-1;
         if X2<0 then X2 := 0; If X2>Site.RunCols-1 then X2 := Site.RunCols-1;
         if Y1<0 then Y1 := 0; If Y1>Site.RunRows-1 then Y1 := Site.RunRows-1;
         if Y2<0 then Y2 := 0; If Y2>Site.RunRows-1 then Y2 := Site.RunRows-1;
       End;

End;

{------------------------------------------------------------------------------}


PROCEDURE TSLAMM_Simulation.SetMapAttributes;
Var i, NPage: integer;
Begin
  GridForm.Hide;
  GridForm.ZoomFactor := InitZoomFactor;

  Connect_Arr := nil;
  Inund_Arr := nil;

//  ReadSite;

  If Not MakeDataFile(False,'','') then Begin ProgForm.Hide; Exit; End;

  Site.InitElevVars;

  with Gridform do
    begin
      GraphBox.ItemIndex := 0;
      ThisSite := Site;
      SS := Self;

      // Set the initial tab to the first sheet
      PageControl1.ActivePageIndex := 1;
//      PanCheckBox.Checked := True;

      // Set some buttons to unchecked
      ShowDikes.Checked := False;

      //Connectivity not calculated yet
      ConnectCheck := False;

      //Cell Inundation not calculated yet
      InundFreqCheck := False;

      // Add SAV map if the d2m file is available
      SAVProbCheck := False;
      GraphBox.Items.Delete(14);  //Delete SAV maps options from the gridform.graphbox
      if trim(D2MFileN)<>'' then
        GraphBox.Items.Add('Probability SAV');


      //Add road maps item if the road file is available
      RoadInundCheck := False;

      // Make execution buttons invisible
      HaltButton.Visible := False;
      NextStepButton.Visible := False;
      StopPausingButton.Visible := False;

      // Make all pages visible
      NPage := PageControl1.PageCount;
{$IFDEF DEBUG}
      for i := 0 to NPage-1 do  //  include last page (WPC utilities).
{$ELSE}
      PageControl1.Pages[NPage-1].TabVisible := False;
      for i := 0 to NPage-2 do  //  remove last page for release (WPC utilities).
{$ENDIF}
      PageControl1.Pages[i].TabVisible := True;

      //Set Active page to Analysis tool
      PageControl1.ActivePageIndex := 1;

      //Set Caption of Page zero
      PageControl1.Pages[0].Caption := 'Edit Input or Output Subsites';


      EditAttributes(Site.ReadRows,Site.ReadCols, Self);

      If DikesChanged then
        If MessageDlg('Save edits to Dike Raster?  (OVERWRITE)',mtconfirmation,[mbyes,mbno],0) = mryes then
          SaveRaster( DikFileN,1 )
        else
          Init_ElevStats := False;

      If NWIChanged then
        If MessageDlg('Save edits to NWI Raster?  (OVERWRITE)',mtconfirmation,[mbyes,mbno],0) = mryes then
          SaveRaster( NWIFileN,2 )
        else
          Init_ElevStats := False;

      DikesChanged := False;
      NWIChanged := False;
    end;

  ProgForm.Cleanup;

End;


{------------------------------------------------------------------------------}

PROCEDURE TSLAMM_Simulation.CalibrateSalinity;
Begin
   If (NumFwFlows < 1) and (trim(SalFileN)='') then
    Begin
      MessageDlg('You must first define Freshwater Flows ("Set Map Attributes") before Calibrating Salinity.',mterror,[mbok],0);
      Exit;
    End;

   If (Init_SalStats=False) and ((trim(SalFileN)='') or (pos('.xls',lowercase(SalFileN))>0)) then
    Begin
      MessageDlg('Salinity statistics must be calculated by running the model to the start of time-zero.',mterror,[mbok],0);
      // Exit;
    End;

   If (Init_SalStats=False) and ((trim(SalFileN)<>'') and (pos('.xls',lowercase(SalFileN))=0)) then
    Begin
      MessageDlg('Initially, salinity statistics can be run only after loading the map.',mterror,[mbok],0);
      Exit;
    End;

  SalinityForm.SS := Self;
  Salinityform.ShowSalinityAnalysis;
  Salinityform.Showmodal;
  ProgForm.Cleanup;
End;


function MemoryUsed: int64;
var
    st: TMemoryManagerState;
    sb: TSmallBlockTypeState;
begin
    GetMemoryManagerState(st);
    result := st.TotalAllocatedMediumBlockSize + st.TotalAllocatedLargeBlockSize;
    for sb in st.SmallBlockTypeStates do begin
        result := result + sb.UseableBlockSize * sb.AllocatedBlockCount;
    end;
end;

Procedure TSLAMM_Simulation.Calc_Elev_Stats(OneArea: Boolean);
//============================================
// Calculation of elevation statistics for all input and output sites, or one area if boolean is true
//============================================
Var
    NewMemUsed, InitMemUsed: int64;
    SlopeAdjustment: Double; {elev stat code}
    PctInd, Ind,ER,EC, i, j, k: Integer;
    CC: Integer;
    StatCell: CompressedCell;
    SubSite: TSubSite;
    CE: Double;
    ElevLevel: array[1..8] of Double;   // 1..4 are stats in HTU 5..8 are meters  1&5 -- MTL Datum 2&6 MLLW 3&7 MHHW 4&8 NAVD88 datum
    MinWetElev, MaxWetElev: Double;
    InpSSIdx, ROSIdx: Integer;
    LCN, NStatAreas, AreaIdx, loopstart, loopend: integer;
    NStatAreasCell : integer;
    CellInAreas : array of Integer;   // holds the relevant input subsite, ROS, and output subsites if relevant
                                      // [0] is whole area [1] is input subsite [2] is ROS and [3..3+N] is output subsite number

Begin      {Map must be loaded for this calculation}

  //Initialize the array of statistical record areas where elevation analysis is performed
  NStatAreas := 1 + (1+ Site.NSubSites)+Site.MaxROS+Site.NOutputSites;  //Entire study area + global site + input sites + raster output sites + output sites

  if NStatAreas <> NElevStats then
   For i := 0 to Categories.NCats-1 do
    With Categories.GetCat(i) do
     setlength(ElevationStats,NStatAreas);

  SetLength(ElevStatsDerived,NStatAreas);

  NElevStats := NStatAreas;

  //Initialize array with areas to be accounted for in each cell
  CellInAreas := nil;
  NStatAreasCell := 3+Site.NOutputSites; // entire area + input subsite + raster output subsite + all output subsites
  setlength(CellInAreas,NStatAreasCell); // entire study site + 1 input site + 1 raster output site + multiple output sites

  if OneArea then Begin
                    LoopStart := ElevAnalysisForm.ElevAreasBox.ItemIndex;
                    LoopEnd := ElevAnalysisForm.ElevAreasBox.ItemIndex;
                  End
             else Begin
                    LoopStart := 0;
                    LoopEnd := NStatAreas-1;
                  End;

  // Initialize statistical indicators
  for AreaIdx := LoopStart to LoopEnd do
   for CC := 0 to Categories.NCats-1 do
    With Categories.GetCat(CC) do
      begin
        for Ind := 1 to 8 do
          begin
            With ElevationStats[AreaIdx].Stats[ind] do
            begin
              ElevationStats[AreaIdx].N := 0;
              Min := 1e6;
              Max := 1e-6;
              Sum := 0;
              SumX2 := 0;
              Sum_e2 := 0;
              Mean := 0;
              StDev := 0;
            end;
            for j := 0 to HistWidth-1 do
              ElevationStats[AreaIdx].Histogram[ind,j] := 0;
          end;
        ElevationStats[AreaIdx].pLowerMin := 0;
        ElevationStats[AreaIdx].pHigherMax := 0;
      end;

  // Show Progress Form
  ProgForm.Show;
  ProgForm.HaltButton.Visible := False;
  // Progress bar message
  ProgForm.ProgressLabel.Caption := 'Calculating Elevation Stats.';

  // Collecting data for each row and column
  FOR ER := 0 To (Site.ReadRows-1) Do
    FOR EC := 0 To (Site.ReadCols-1) Do
      Begin  {First Pass Statistics}

        // Updating the progress bar
        If EC=0 then ProgForm.Update2Gages(Trunc(ER/Site.ReadRows*(100)),0);  //ADD USERSTOP

        //Initialize the vector for the statistical areas for each cell
        CellInAreas[0] := 0;
        for i := 1 to NStatAreasCell-1 do
          CellInAreas[i] := -99;

        // Get the information of the cell
        RetA(ER, EC, StatCell);

        // If cell is diked do not include it in the elevation statistics
        If ClassicDike and StatCell.ProtDikes then Continue;
        if (not ClassicDike) and (StatCell.ProtDikes) and (not StatCell.ElevDikes) then Continue;

        // If the subsite has preprocessed data do not include the cell in the elevation statistics
        SubSite := Site.GetSubSite(EC,ER,@StatCell);
        If SubSite.Use_PreProcessor then Continue;

        // If the GT=0 do not include in the elevation statisitcs
        if subsite.MHHW=0 then Continue;

        // Get Input subsite Index
        InpSSIdx := Site.GetSubSiteNum(EC,ER);
        CellInAreas[1] := InpSSIdx+1;

        // Get Outptut raster index
        ROSIdx := 0;
        if ROSArray<>nil then
          ROSIdx := ROSArray[Site.ReadCols*ER+EC];
        if ROSIdx>0 then
          CellInAreas[2] := 1+Site.NSubSites+ROSIdx;

        // Get output site index
        for i := 1 to Site.NOutputSites do
          begin
            if Site.InOutSite(EC,ER,i) then
              CellInAreas[2+i] := 1+Site.NSubSites+Site.MaxROS+i;
           end;

        // Get cell category
        CC := GetCellCat(@StatCell);

        // If cell cat -99 (no data) do not process
        if CC = -99 then continue;

        // Get min cell elevation
        CE := CatElev(@StatCell,CC);

        // If elevation category is 999 (no data) do not process
        if CE = 999 then continue;

        // Adjustment of the slope
        SlopeAdjustment := (Site.ReadScale*0.5) * StatCell.TanSlope;   {QA 11.10.2005}

        // Then elevation in m is ...
        if CC = Blank then ElevLevel[5] := 0
                      else ElevLevel[5] := (CE+SlopeAdjustment);

        ElevLevel[6] := ElevLevel[5] - subsite.MHHW;
        ElevLevel[7] := ElevLevel[5] - subsite.MLLW;
        ElevLevel[8] := ElevLevel[5] + StatCell.MTLminusNAVD;      // Elev Relative to NAVD88
        //ElevLevel[8] := ElevLevel[5] - subsite.SaltElev;


        // Elevations in HTU
        ElevLevel[1] := ElevLevel[5] / subsite.MHHW;
        ElevLevel[2] := ElevLevel[6] / subsite.MHHW;
        ElevLevel[3] := ElevLevel[7] / subsite.MHHW;
        ElevLevel[4] := ElevLevel[8] / subsite.MHHW;

        // Get wetland min elevations
        MinWetElev := LowerBound(CC,SubSite);

        // Get wetland max elevations
        MaxWetElev := UpperBound(CC,SubSite);

        // Update the statistics
      With Categories.GetCat(CC) do
       for AreaIdx := LoopStart to LoopEnd do
         for i :=0 to NStatAreasCell-1 do
          begin
            if CellInAreas[i]<>-99 then
              begin
                k := CellInAreas[i];
                if (k=AreaIdx) then
                  with ElevationStats[AreaIdx] do
                    begin
                      // Increment the category by one
                      Inc(N);

                      // Update minimum, maximum, sum, squared sum
                      for ind := 1 to 8 do
                        begin
                          With Stats[ind] do
                            begin
                              If ElevLevel[ind] < Min then Min := ElevLevel[ind];
                              If ElevLevel[ind] > Max then Max := ElevLevel[ind];
                              Sum := Sum + ElevLevel[ind];
                              SumX2 := SumX2 + ElevLevel[ind]*ElevLevel[ind];
                            end
                        end;

                      // Update minimum wetlad elevation
                      if ElevLevel[5]<MinWetElev then
                        pLowerMin := pLowerMin+1;

                      // Update max wetlad elevation
                     if ElevLevel[5]>MaxWetElev then
                        pHigherMax := pHigherMax+1;
                    end;
              end;
         end;
      End;

  InitMemUsed := MemoryUsed;
  NewMemUsed := 0;
  for AreaIdx := LoopStart to LoopEnd do
   for CC := 0 to Categories.NCats-1  do
    With Categories.GetCat(CC).ElevationStats[AreaIdx] do
     for ind := 1 to 8 do
      NewMemUsed := NewMemUsed + N*4;

  If NewMemUsed > 1073741824 then
   If MessageDlg ('This procedure will temporarily require an additional '+FloatToStrF(NewMemUsed/1073741824,ffgeneral,4,2) +' GB of Memory on top of the '
                  + FloatToStrF(InitMemUsed/1073741824,ffgeneral,4,2) +' already allocated.  '+
                  'Your computer can freeze (allocating virtual memory) if insufficient memory is available.  Continue? ',mtconfirmation,[mbok,mbcancel],0) = MRCancel then
     Begin
        //Deallocate dynamic arrays
        for AreaIdx := LoopStart to LoopEnd do
         for CC := 0 to Categories.NCats-1  do
          With Categories.GetCat(CC).ElevationStats[AreaIdx] do
           for ind := 1 to 8 do
            Values[ind] := nil;
        ProgForm.Hide;
        Exit;
    End;

  for AreaIdx := LoopStart to LoopEnd do
    begin
     for CC := 0 to Categories.NCats-1 do
      With Categories.GetCat(CC).ElevationStats[AreaIdx] do
         begin
            for ind := 1 to 8 do
              begin
                //Inizialize value arrays
                SetLength(Values[ind],N);
                NewMemUsed := MemoryUsed;

                // Calculating the mean for each category
                With Stats[ind] do
                  If N > 0 then
                    Mean := Sum/N
                  else
                    Mean := 0;
              end;

            //Fraction of cells below min elevation
            If N > 0 then
              begin
                pLowerMin := 100*pLowerMin/N;
                pHigherMax := 100*pHigherMax/N;
              end
            else
              begin
                pLowerMin := 0;
                pHigherMax := 0;
              end;

            // Reinizialize the number of cells in a particualr wetland type
            N := 0;
         end;
    end;

  ProgForm.ProgressLabel.Caption := 'Calculating Elev. Stats. 2nd Pass';
  ProgForm.HaltButton.Visible := False;

  // Second pass once the dimensions for Values and Val_M are obtained
  for ER := 0 to (Site.ReadRows-1) Do
    for EC := 0 to (Site.ReadCols-1) Do
      begin  {Second Pass Statistics}

        // Progress bar updates
        If EC=0 then ProgForm.Update2Gages(Trunc(ER/Site.ReadRows*(100)),0);  //ADD USERSTOP

         //Initialize to zero the areas for the cell
        CellInAreas[0] := 0;
        for i := 1 to NStatAreasCell-1 do
          CellInAreas[i] := -99;

        // Get the information of the cell
        RetA(ER, EC, StatCell);

        // If cell is diked do not include it in the elevation statistics
        If ClassicDike and StatCell.ProtDikes then Continue;
        if (not ClassicDike) and (StatCell.ProtDikes) and (not StatCell.ElevDikes) then Continue;

        // If the subsite has preprocessed data do not include the cell in the elevation statistics
        SubSite := Site.GetSubSite(EC,ER,@StatCell);
        If SubSite.Use_PreProcessor then Continue;

        // If the GT=0 do not include in the elevation statisitcs
        if subsite.MHHW=0 then Continue;

        // Get Input subsite Index
        InpSSIdx := Site.GetSubSiteNum(EC,ER);
        CellInAreas[1] := InpSSIdx+1;

        // Get Outptut raster index
        ROSIdx := 0;
        if ROSArray<>nil then
          ROSIdx := ROSArray[Site.ReadCols*ER+EC];
        if ROSIdx>0 then
          CellInAreas[2] := 1+Site.NSubSites+ROSIdx;

        for i := 1 to Site.NOutputSites do
          begin
            if Site.InOutSite(EC,ER,i) then
              CellInAreas[2+i] := 1+Site.NSubSites+Site.MaxROS+i;
           end;

        // Get cell category
        CC := GetCellCat(@StatCell);

        // If cell cat -99 (no data) do not process
        if CC = -99 then continue;

        // Get min cell elevation
        CE := CatElev(@StatCell,CC);

        // If elevation category is 999 (no data) do not process
        if CE = 999 then continue;

        // Adjustment of the slope
        SlopeAdjustment := (Site.ReadScale*0.5) * StatCell.TanSlope;   {QA 11.10.2005}

        // Then elevation in m is ...
        if CC = Blank then
          ElevLevel[5] := 0
        else
          ElevLevel[5] := (CE+SlopeAdjustment);

        ElevLevel[6] := ElevLevel[5] - subsite.MHHW;
        ElevLevel[7] := ElevLevel[5] - subsite.MLLW;
        ElevLevel[8] := ElevLevel[5] + StatCell.MTLminusNAVD;
        //ElevLevel[8] := ElevLevel[5] - subsite.SaltElev;

        // Elevations in HTU
        ElevLevel[1] := ElevLevel[5] / subsite.MHHW;
        ElevLevel[2] := ElevLevel[6] / subsite.MHHW;
        ElevLevel[3] := ElevLevel[7] / subsite.MHHW;
        ElevLevel[4] := ElevLevel[8] / subsite.MHHW;

        // Update the statistics
       for AreaIdx := LoopStart to LoopEnd do
        for i :=0 to NStatAreasCell-1 do
          begin
            if CellInAreas[i]<>-99 then
              begin
                k := CellInAreas[i];
                if (k=AreaIdx) then
                  with Categories.GetCat(CC).ElevationStats[k] do
                  begin
                    // Increment the category by one
                    Inc(N);

                    for ind := 1 to 8 do
                      begin
                        // Storing elevation values
                        Values[ind,N-1] := ElevLevel[ind];

                        With Stats[ind] do
                          begin
                            // Updating standard deviations
                            Sum_e2 := Sum_e2 + Sqr(ElevLevel[ind]-Mean);

                            //Update the elevation histogram
                            If (ElevLevel[ind] >= Min) and (ElevLevel[ind]<Max) then
                              Inc(Histogram[ind,TRUNC(HistWidth*(ElevLevel[ind]-Min)/(Max-Min))]);  {increment appropriate bin}
                          end;
                      end;
                  end;
              end;
          end;
      end;  // er, ec, second pass statistics

  ProgForm.ProgressLabel.Caption := 'Calculating Elev. Stats.: Percentiles';
  ProgForm.HaltButton.Visible := False;

  LCN := Categories.NCats;
  for AreaIdx := LoopStart to LoopEnd do
    begin
     for CC := 0 to Categories.NCats-1 do
       With Categories.GetCat(CC).ElevationStats[AreaIdx] do
          for ind := 1 to 8 do
            begin
              ProgForm.Update2Gages(Trunc((((AreaIdx-LoopStart)*LCN)+ORD(CC))/((LoopEnd-LoopStart+1)*LCN)*100),0);
              with Stats[ind] do
              begin
                if N<=1 then
                  begin
                    StDev := 0;
                    P05:=0;
                    P95:=0;
                  end
                else
                  begin
                    // Calculate standard deviation
                    StDev := sqrt(Sum_e2/(N-1));

                    // Sorting values
                    QuickSort(Values[ind],0,N-1);

                    // Calculate 5th percentile
                    PctInd :=Round((N+1)*0.05)-1;
                    If PctInd<0 then PctInd := 0;
                    P05 := Values[ind,PctInd];

                    // Calculate 95th percentile
                    PctInd :=Round((N+1)*0.95)-1;
                    If (PctInd>N-1) then PctInd := N-1;
                    P95 := Values[ind,PctInd];
                  end;
              end;  // with Stats
            end; // for ind


      //Deallocate dynamic arrays
      for CC := 0 to Categories.NCats-1 do
        for ind := 1 to 8 do
          begin
            Categories.GetCat(CC).ElevationStats[AreaIdx].Values[ind] := nil;
            ElevStatsDerived[AreaIdx] := Now();
          end;

    end;  {AreaIDX Loop}

   //Statistical Analysis has been run
   Init_ElevStats := True;
   ProgForm.Hide;

End;


Function TSLAMM_Simulation.Inundate_Erode(StartRow,EndRow: Integer; ProgStr:String; PRunThread: Pointer; ErodeLoop: Boolean): Boolean;
Var ER,EC: Integer;
    ProcCell: CompressedCell;
    AddStr : String;

Begin
  ProgForm.HaltButton.Visible := True;
  Result := True;
   FOR ER := StartRow To EndRow Do
    FOR EC := 0 To (Site.RunCols-1) Do
     Begin
       if PRunThread = nil then  // not parallel processing
        if ProgStr <> '' then
         if (EC=0) then
           begin
             ProgForm.ProgressLabel.Caption:=ProgStr+AddStr;
             Result := ProgForm.Update2Gages(Trunc((Er)/Site.RunRows*100),0);
             If Not Result then Exit;
           end;

       RetA(ER, EC, ProcCell);
       Transfer(@ProcCell, ER, EC, ERODELOOP);
       SetA(ER, EC, ProcCell);

      If PRunThread = nil then   // not parallel processing
        If Display_Screen_Maps then
         If Gridform.IsVisible then
             Gridform.DrawCell(@ProcCell,ER,EC,ER,EC,GetCellCat(@ProcCell),False,False,True,0);
     End;

End;



FUNCTION TSLAMM_Simulation.RunOneYear(IsT0: Boolean): Boolean;
Var ProgStr : String;

    {------------------------------------------------------------}
    {Calc Fractal Dimension and Shoreline Protection Potential}
(*       Procedure Calc_FractalNos;
       Var i, EC,ER: Integer;
           ProcCell: CompressedCell;
       Begin
         For i := 0 to Site.NOutputSites  do  {No ROS for now}
           FRs[i].ShoreProtect := 0;


         Result := ChngWater(False,False);

         ProgForm.ProgressLabel.Caption:='Calculating Fractal Dimension';
         ProgForm.Update;

         If Result then
          For ER := 0 to (Site.Rows-1) Do
           FOR EC := 0 To (Site.Cols-1) Do
            Begin
              If EC=1 then
                Begin
                  Result := ProgForm.Update2Gages(Trunc((Er)/Site.Rows*100));
                  If Not Result then Exit;
                End;
              RetA(ER,EC,ProcCell);
              FractalNos(ER,EC,ProcCell,Site);  {collect info for fractal dimension of init.cond}
            End; {For Do Loops}
       End;                   *)

    {------------------------------------------------------------}
    Var ThreadArr: Array [0..100] of trunthread;
       Procedure Parallel_Execute;  // inundate and erode
       Var CCLoop,RowStart,RowEnd,RowsPer: Integer;
           AllCPUsDone, UStop : Boolean;
           PS:String;
           AllTasksDone, ErodeIter: Boolean;
           TaskIter : Integer;
       Const TaskSplit = 100;

          {------------------------------------------------------------}
          Procedure CalcRSRE(TI: Integer);  // Calculate Row Start and Row End for each task; TI = Task Iteration
          Begin
              If (TI = 0) then
                  Begin
                    RowStart := 0;
                    RowEnd := Site.RunRows - (TaskSplit-1)*RowsPer -1;
                  End
                else
                  Begin
                    RowStart := Site.RunRows-(TaskSplit-TI)*RowsPer;
                    RowEnd := RowStart + RowsPer -1;
                  End;
          End;
          {------------------------------------------------------------}
          Procedure RefreshThread(Tindx: Integer);  // Update the row start, the row end before restarting; Tindx = thread index
          Begin
              CalcRSRE(TaskIter);
              ThreadArr[Tindx].StR := RowStart;
              ThreadArr[Tindx].EnR := RowEnd;
              ThreadArr[Tindx].ErodeTask := ErodeIter;
              ThreadArr[Tindx].ImDone := False;
          End;
          {------------------------------------------------------------}

       Begin // Parallel_Execute for inund erode
          ProgForm.ProgressLabel.Caption := ProgStr+'Inund. Erode';

          RowsPer := (Site.RunRows div TaskSplit);  // rows per CPU-task
          ErodeIter := False;  // inundate then erode

          For CCLoop := 0 to CPUs -1 do
            Begin
              CalcRSRE(CCLoop);
              PS := ProgStr;
              ThreadArr[CCLoop] := trunthread.Create(Self,RowStart,RowEnd,PS,CCLoop+1);
            End;

          TaskIter := CPUs-1;
          AllTasksDone := False;
          UStop := False;

          repeat
            Application.processmessages;
            AllCPUsDone := True;  // ALL CPUs have completed their tasks assumed true until proven wrong
            For CCLoop := 0 to CPUs -1 do
              Begin
                If not ThreadArr[CCLoop].ImDone then AllCPUsDone := False;  //everyone is not done

                If ThreadArr[CCLoop].ImDone  then
                  Begin
                    If TaskIter < TaskSplit then Inc(TaskIter);
                    If TaskIter = TaskSplit then // all 100 tasks (or whatever tasksplit is) are done
                        Begin
                          If ErodeIter then AllTasksDone := True
                                       else Begin
                                              ErodeIter := True;  // inundation is done now on to erosion
                                              TaskIter := 0;      // start on first of TaskSplit tasks
                                            End;
                        End; // iterations = tasksplit

                    If AllTasksDone then ThreadArr[CCLoop].TasksDone := True  // signal thread to terminate once restarted
                                    else RefreshThread(CCLoop);  //update the row start and end before restarting

                    ThreadArr[CCLoop].Start();  // set event to restart thread
                  End;

                If ThreadArr[CCLoop].UserStop then UStop := True;
              End;

            If not UStop then
              Begin
                If not ErodeIter
                   then UStop := not ProgForm.Update2Gages(Trunc(((TaskIter+1-CPUs)/(TaskSplit-CPUs))*50),0)   //update progress
                   else UStop := not ProgForm.Update2Gages(50+Trunc(((TaskIter+1)/TaskSplit)*50),0);
                If UStop then AllTasksDone := True;
              End; // not ustop

           until (AllCPUsDone and AllTasksDone) {or UStop};

           If UStop then Result := False;
           For CCLoop := 0 to CPUs -1 do
            begin
              if ThreadArr[CCloop].UserStop then Result := False;
              ThreadArr[CCLoop].Free;
            end;

           Application.processmessages;  // test 3/16/2016
           If Display_Screen_Maps then
            If Gridform.IsVisible then
             If Result then
               Begin
                 Inc(IterCount);
                 If IterCount = 22 then
                   Begin
                     IterCount := IterCount + 100 ;
                   End;
                 Result := GridForm.DrawEntireMap(0,True,False);
               End;

           ProgForm.SLRLabel.Visible   := True;
        End;
      {------------------------------------------------------------}

      procedure UpdateProjRunString;
      begin

        if Year <= 0  then
          Begin
            ProjRunString := 'Initial_Inundation';
            ShortProjRun := 'T0';
          End
        else
          begin
            ShortProjRun := 'S'+IntToStr(ScenIter)+'_';
            ShortProjRun := ShortProjRun+IntToStr(Year);

            ProjRunString := IntToStr(Year)+'_';

            If Running_TSSLR then ProjRunString := ProjRunString +' '+ TimeSerSLRs[TSSLRindex-1].Name + ' '
            else if
              Running_Fixed then ProjRunString := ProjRunString + '_'+ LabelFixed[FixedScen]
            else if
              Running_Custom then ProjRunString := ProjRunString + '_'+ FloatToStrF(Current_Custom_SLR ,ffgeneral,4,2)+ 'm'
            else
              ProjRunString := ProjRunString + '_'+ LabelIPCC[IPCCSLRate]+'_'+LabelIPCCEst[IPCCSLEst];

            if ProtectAll then
              Begin
                ProjRunString := ProjRunString + '_PADL';
                ShortProjRun := ShortProjRun + '_PA';
              End
            else if ProtectDeveloped then
              Begin
                ProjRunString := ProjRunString + '_PDDL';
                ProjRunString := ProjRunString + '_PD';
              End;

            if Not IncludeDikes then
              Begin
                ProjRunString := ProjRunString +'_ND';
                ShortProjRun := ShortProjRun + '_ND';
              End;
          end;
      end;


Var ErodeLoop: Boolean;
    j: Integer;
Begin  {RunOneYear}
  Result := True;

  If Not IsT0 then
    Begin
      ProgStr := 'Running Yearly Scenario : ';
      ProgForm.YearLabel.Visible:=True;
      TimeZero := False;
    End
  else
    Begin
      ProgStr := 'Running Time Zero : ';
      ProgForm.YearLabel.Visible:=False;
      TimeZero := True;
    End;

  if CPUs > 1 then ProgStr := ProgStr + '('+ IntToStr(CPUs)+' CPUs) ';

  ProgForm.ProgressLabel.Caption:=ProgStr;
  ProgForm.Show;
  EustaticSLChange(Site, Year, IsT0);  // Updates the "Year" Variable and Local SL Variables

  //Update Projection Run String
  UpdateProjRunString;

  // Check for annual update maps if it is not time zero, e.g. yearly salinity or dike updates
  if (not IsT0) then Result := CheckForAnnualMaps;
  If Not Result then Exit;

  ProgForm.YearLabel.Caption:=IntToStr(Year);
  Result := UpdateElevations;
  If Not Result then Exit;

  Result := ChngWater(True,Not IsT0);
  If not Result then Exit;

  //Inundation
  InundFreqCheck := False;
  if InundMaps or (SaveGIS and SaveInundGIS) or (NPointInf>0) or (NRoadInf>0) then
    begin
     Result := Calc_Inund_Freq;
     InundFreqCheck:= Result;
    end;
  If not Result then Exit;

  // Check Connectivity
  ConnectCheck := False;
  if CheckConnectivity or ConnectMaps then
    begin
      Result := Calc_Inund_Connectivity(@Connect_Arr,True,-1);
      ConnectCheck := Result;
    end
  else Connect_Arr := nil;

  If not Result then Exit;

  SAVProbCheck := False;
  if (trim(D2MFileN)<>'') then
    begin
      Result := CalculateProbSAV(False);
      SAVProbCheck := Result;
    end;
  If Not Result then Exit;

  // Calculate  frequency of road inundation if road data exists
  RoadInundCheck := False;
  If NRoadInf>0 then
    for j:=0 to NRoadInf-1 do
      begin
        Result := RoadsInf[j].CalcAllRoadsInundation;
//      if Result then RoadsInf[j].SummarizeRoadInundation(Year, IsT0);
        RoadInundCheck := Result;
      end;

  If NPointInf>0 then
   for j:=0 to NPointInf-1 do
     Result := PointInf[j].CalcAllPointInfInundation;

  If Not Result then Exit;

  if (not isT0) then
    if (trim(SalFileN)='')  // if no salinity file specified
     or (Pos('.xls',lowercase(SalFileN))>0) then // or excel salinity file specified
         Result := CalcSalinity(false,false);  // then not using raster salinity file so try to calc salinity

  if not Result then Exit;

  GridForm.Image1.Canvas.Pen.Mode := pmcopy;
  GridForm.ShowRunPanel;

  if (CPUs > 1)
    then Parallel_Execute
    else For ErodeLoop := False to True do
      If Result then Result := Inundate_Erode(0,Site.RunRows-1,ProgStr,nil,ErodeLoop);
   If Not Result then Exit;

   If (NumFwFlows > 0) or (CPUs < 2) then Result := GridForm.DrawEntireMap(0,True,False);

{  Calc_FractalNos;
   If Not Result then Exit;   11/18/2013, suppress Fractal Numbers for Now, if later enabled, fixe redundant Check Waters}

   If NRoadInf>0 then
     for j:=0 to NRoadInf-1 do
       RoadsInf[j].UpdateRoadSums(TStepIter,RoadSums,Site.NOutputSites+Site.MaxROS+1);
       // no subsites yet for Road Infrastructure
   Summarize(Map,Tropical,Summary,Year);  {write array for tabular output for first year}

   // PROGFORM.Hide;
 End; {Run One Year}


{------------------------------------------------------------------------------}
Procedure TSLAMM_Simulation.ZeroSums;
Var i,j: Integer; CC: Integer;
Begin

  For i := 0 to Site.NOutputSites+Site.MaxROS do
    Begin
      For j := 0 to MaxRoadArray do
        Roadsums[i,j] := 0;

      For CC := 0 to Categories.NCats-1 do
        CatSums[i,CC] := 0;
    End;
End;
{------------------------------------------------------------------------------}


Procedure TSLAMM_Simulation.ExecuteRun;
Var Prot_Scenario: ProtScenario;
    IPCC_Scenario: IPCCScenarios;
    IPCC_Est     : IPCCEstimates;
    SaveStream: TMemoryStream;


          {==============================================================================}
          Procedure InitSubSite(PSS: TSubSite);
          Begin
           With PSS do
            Begin
              Norm := 0;
              NewSL := 0.0;
              T0SLR := 0.0;
              OldSL := 0.0;
              SLRise := 0.0;
              DeltaT := 0;
            End;
          End;
          {==============================================================================}

    {----------------------------------------------------------------------------------------}
    Function InitYearSLAM: Boolean;
    Var
      i,j,k: integer;
      CC: Integer;
      ER,EC: Integer;

    {==============================================================================}

    Var MR: TModalResult;
        ProcCell: CompressedCell;

    BEGIN  {InitYearSLAM}
      Result := True;

      Year := 0;  {Output as Init Cond}
      IF SaveGIS Then If GISForm.OutputYear(Year) THEN Result := Save_GIS_Files;
      If Not Result then Exit;  //user cancel button

      Year := Site.T0;  {latest NWI Photo Date for all Subsites}

      CatSums := nil;
      SetLength(CatSums, Site.NOutputSites+1+Site.MaxROS );

      RoadSums := nil;
      SetLength(RoadSums, Site.NOutputSites+1+Site.MaxROS );

      Summary := nil;
      IF RunSpecificYears
        then NumRows := 3 + CharOccurs(YearsString,',')    //numrows = 3 + number of commas in comma delimited string
        else NumRows := (4+( (MaxYear-2000) Div TimeStep));

//    SetLength(FRs,Site.NOutputSites+1); {Fractal Numbers Data}
      SetLength(Summary,Site.NOutputSites+1+Site.MaxROS);

      ZeroSums;

      For i := 0 to Site.NOutputSites+Site.MaxROS  do  // zero summary
       for CC := 0 to Categories.NCats-1 do
        Begin
          SetLength(Summary[i],NumRows);
          For j := 0 to NumRows-1 do
           For k := 0 to Output_MaxC do
            Summary[i,j,k] := 0;
        End;


      SetLength(RowLabel,(Site.NOutputSites+1+Site.MaxROS)*NumRows);
      For i := 1 to Length(RowLabel) do
        RowLabel[i-1] := '';

      CellHa := Site.RunScale * Site.RunScale * 0.0001;
                                        {/ 10000 }

      ProtectDeveloped :=(Prot_Scenario>NoProtect);     //use global loop variable
      ProtectAll :=(Prot_Scenario>ProtDeveloped);

      InitSubSite(Site.GlobalSite);
      For i := 0 to Site.NSubSites-1 do
        InitSubSite(Site.SubSites[i]);

      TStepIter := 0;

      For i := 0 to Site.NOutputSites+Site.MaxROS  do
       for CC := 0 to Categories.NCats-1 do
         CatSums[i,CC] := 0;

      ColLabel[0] := 'SLR (eustatic)';
      FOR CC := 1 to Categories.NCats do
        ColLabel[CC] := Categories.GetCat(CC-1).TextName;
      ColLabel[Categories.NCats+1] := 'SAV (sq.km)';

      ColLabel[Categories.NCats+2] := 'Aggregated Non Tidal';
      ColLabel[Categories.NCats+3] := 'Freshwater Non-Tidal';
      ColLabel[Categories.NCats+4] := 'Open Water';
      ColLabel[Categories.NCats+5] := 'Low Tidal';
      ColLabel[Categories.NCats+6] := 'Saltmarsh';
      ColLabel[Categories.NCats+7] := 'Transitional';
      ColLabel[Categories.NCats+8] := 'Freshwater Tidal';
      ColLabel[Categories.NCats+9] := 'GHG (10^3 Kg)';

      if NRoadInf > 0 then
        Begin
          ColLabel[Categories.NCats+10] := 'total road length (km)';
          ColLabel[Categories.NCats+11] := 'inundated roads elev<H1 (km)';
          ColLabel[Categories.NCats+12] := 'inundated roads elev<H2 (km)';
          ColLabel[Categories.NCats+13] := 'inundated roads elev<H3 (km)';
          ColLabel[Categories.NCats+14] := 'inundated roads elev<H4 (km)';
          ColLabel[Categories.NCats+15] := 'inundated roads elev<H5 (km)';
          ColLabel[Categories.NCats+16] := 'inundated roads elev>H5 (km)';
          ColLabel[Categories.NCats+17] := 'km roads below MTL and connected';
          ColLabel[Categories.NCats+18] := 'km roads open water';
          ColLabel[Categories.NCats+19] := 'km roads blank/diked';
          ColLabel[Categories.NCats+20] := 'km roads irrelevant';
        End;

      Result := ProgForm.Update2Gages(0,0);
      If Not Result then Exit;

      ProgForm.YearLabel.Visible:=True;
      ProgForm.YearLabel.Caption:=IntToStr(Year);
      ProgForm.Show;

      GridForm.Image1.Canvas.Pen.Mode := pmcopy;

(*    Result :=  ChngWater(False,False); {update water attributes for the entire map, just for initial conditions summary}
      If Not Result then Exit;  *)

      FOR ER := 0 To (Site.RunRows-1) Do
       FOR EC := 0 To (Site.RunCols-1) Do
        Begin  {Set CatSums Initial Condition}
          //Get Cell
          RetA(ER, EC, ProcCell);

          //Output sites summary
          for i := 0 to Site.NOutputSites do
            begin
              if ((i=0) and (In_Area_to_Save(EC,ER, not SaveROSArea))) or ((i>0) and (Site.InOutSite(EC,ER,i))) then
                begin
                  //NWI Summary
                  for CC := 0 to Categories.NCats-1 do
                    CatSums[i,CC] := CatSums[i,CC] + (CellWidth(@ProcCell,CC) * Site.RunScale);
                      {m2}                {m2}             {m}                    {m}

                end;
            end;  // for i:=0

          //Raster outputs summary
          if ROSArray<>nil then
            begin
              for i := 1 to Site.MaxROS do
                if (i=ROSArray[(Site.RunCols*ER)+EC]) then
                  begin
                    //NWI Summary
                    for CC := 0 to Categories.NCats-1 do
                      CatSums[i+Site.NOutputSites,CC] := CatSums[i+Site.NOutputSites,CC] + (CellWidth(@ProcCell,CC) * Site.RunScale);
                                         {m2}                                {m2}                       {m}         {m}
                  end;
            end; // ROSArray<>nil

//        FractalNos(ER,EC,ProcCell,Site);  {collect info for fractal dimension of init.cond}
          If (EC mod 400) =0 then
            begin
              ProgForm.ProgressLabel.Caption:='Collecting Init. Cond Data';
              ProgForm.ProgressLabel.Visible := True;
              ProgForm.HaltButton.Visible := True;
              Result := ProgForm.Update2Gages(Trunc((Er)/Site.RunRows*100),0);
              If Not Result then Exit;
            end;

        End;  // For ER For EC

      If NRoadInf>0 then
        for j:=0 to NRoadInf-1 do
          RoadsInf[j].UpdateRoadSums(TStepIter,RoadSums,Site.NOutputSites+Site.MaxROS+1);
          // no subsites yet for Road Infrastructure

      ProgForm.ProgressLabel.Caption:='Running First Year';

//    CALC_ELEV_STATS;

      Summarize(Map,Tropical,Summary,0);
               {Show initial conditions and define Tropical and AreaWater}

      Inc(TStepIter);  // time zero gets iter 1
      ZeroSums;

      {If RunFirstYear Then} Result := RunOneYear(True);
      If Not Result then Exit;   // If user cancels during "run one year"

      IF SaveGIS Then If GISForm.OutputYear(Year) THEN Result := Save_GIS_Files;
      If Not Result then Exit;

      If GridForm.Visible then
       With GridForm do
        Begin
          SS := Self;
          {IF RunFirstYear then }
            Begin
              If QA_Tools then  {display map after "time zero" run}
                 Begin
                   hide; MapTitle.Visible := True;
                   MapTitle.Caption:= 'Map at Year '+IntToStr(Year);
                   UserStop := False;
                   RunPanel.Visible := False;
                   MR := ShowModal;

                   IF (MR=2) then if MessageDlg('Stop Simulation Execution And Return to Main Menu? ',mtconfirmation,[mbyes,mbno],0) = mryes then
                     MR := MRAbort;   // Disambiguation of X key

                   If MR = MRAbort then Begin Result := False; UserStop := True; exit; End;
                   If MR = MRIgnore then QA_Tools := False;
                   Show; Update; MapTitle.Visible := False; IsVisible := True;
                 end;

              If Maps_to_MSWord or Maps_to_GIF then Result := CopyMapsToMSWord;

              If Not Result then Exit;
              ShowRunPanel;

             End; {runfirstyear}

          Result := RunFirstYear;
        End;

    END; {InitYearSLAM}
    {------------------------------------------------------------}
    {------------------------------------------------------------}
    {------------------------------------------------------------}
    Function CheckValidSLAMM: Boolean;
    Var j: Integer;
        NoPoly: Boolean;
    Begin
      Result := ValidateOutputSites;
      If Not Result then Exit;

      For j := 0 to NumFwFlows-1 do
        Begin
          NoPoly := False;
            If FWFlows[j].ScalePoly = nil then NoPoly := True
             else If FWFlows[j].ScalePoly.NumPts < 3 then NoPoly := True;

          If NoPoly then
            Begin
              MessageDlg('Error, Migrating Island "'+FWFlows[j].Name +'" extent is not defined.',mterror,[mbok],0);
              Result := False;
              Exit;
            End;

          If (FWFlows[j].ExtentOnly = False) and (FWFlows[j].NumSegments = 0) then
            Begin
              MessageDlg('Error, Fresh water flow "'+FWFlows[j].Name +'" origin, mouth is not defined.',mterror,[mbok],0);
              Result := False;
              Exit;
            End;
        End;

    End;
    {-------------------------------------------------------------------------------------------}

     Procedure SaveSubSites;
     Begin
       TSText := False;
       SaveStream := TMemoryStream.Create;
       GlobalTS := SaveStream;
       Site.Store(TStream(SaveStream));  {save for backup if subsites are changed mid run (e.g. casco code) }
     End;

     Procedure RestoreSubSites;
     Begin
       TSText := False;
       GlobalTS := SaveStream;
       SaveStream.Seek(0, soFromBeginning); {Go to beginning of stream}
       Site.Load(VersionNum,TStream(SaveStream));
       SaveStream.Free;
     End;
    {-------------------------------------------------------------------------------------------}


  Function ExecuteSLAMM(ProtScen:ProtScenario;
                          IPCCScen: IPCCScenarios;IPCCEst: IPCCEstimates; FixNum: Integer; TSSLRi: Integer): Boolean;
                           {Execute a single iteration of SLAMM}
   Var  i,j : Integer;
        MR: TModalResult;
        Catg: TCategory;
   BEGIN
     SaveSubsites;
     DikeLogInit := False;
     Inc(ScenIter);

     ScaleCalcs;
     Result := CheckValidSLAMM;
     If Not Result then Begin UserStop := True; RestoreSubSites; Exit; End;

     if (SalRules.NRules > 0)  then  // 8/15/22 JSC Copy SalRules to Category as required
       Begin
         for i := 0 to Categories.NCats-1 do
           Begin
             if Categories.Cats[i].SalinityRules = nil then
               Begin
                 Categories.Cats[i].SalinityRules.Free;
                 Categories.Cats[i].SalinityRules := nil;
               End;
              Categories.Cats[i].HasSalRules := False;
            End;
         for i := 1 to SalRules.NRules do
           Begin
             Catg := Categories.Cats[SalRules.Rules[i-1].FromCat];
             if Categories.Cats[i].SalinityRules = nil then Catg.SalinityRules := TSalinityRules.Create;
             inc(CatG.SalinityRules.NRules);
             if (Length(CatG.SalinityRules.Rules) < CatG.SalinityRules.NRules) then setlength(CatG.SalinityRules.Rules,CatG.SalinityRules.NRules+2);
             CatG.HasSalRules := True;
             CatG.SalinityRules.Rules[CatG.SalinityRules.NRules-1] := SalRules.Rules[i-1];
           End;
       End;

     //Delete SAV maps options from the gridform.graphbox
     GridForm.GraphBox.Items.Delete(14);
     if trim(D2MFileN)<>'' then
      GridForm.GraphBox.Items.Add('Probability SAV');

     //Set the map to the standard SLAMM map
     Gridform.GraphBox.ItemIndex := 0;

     // Set all the map checkboxes to false
     GridForm.DontDraw := True;
     GridForm.ShowDikes.Checked := False;
     GridForm.ShowRoadOld := False;
     GridForm.DontDraw := False;

(*     For i := 0 to NumFwFlows-1 do
       FWFLows[i].RetentionInitialized := False; *)

    Result := MakeDataFile(False,'','');
     If Not Result then Begin UserStop := True; RestoreSubSites; Exit; End;

    Site.InitElevVars;

    If Display_Screen_Maps then
       With GridForm do
        Begin
          PageControl1.ActivePageIndex := 1;
          PageControl1.Pages[0].TabVisible := FALSE;
          PageControl1.Pages[2].TabVisible := FALSE;

          // Make WPC Utilities Page visible when executing
{$IFDEF DEBUG}
       PageControl1.Pages[3].TabVisible := True; //  include last page (WPC utilities).
{$ELSE}
      PageControl1.Pages[3].TabVisible := False;
{$ENDIF}

          PageControl1.Pages[0].Caption := 'Analysis Tools';

          HaltButton.Visible := True;
          NextStepButton.Visible := True;
          StopPausingButton.Visible := True;

          Image1.Height:=Site.RunRows+2;
          Image1.Width:=Site.RunCols+2;
          Image1.Picture.Bitmap.PixelFormat := pf24bit;  // Do this first

          ZoomFactor := InitZoomFactor;

          IsVisible:=True;

          Running_Fixed := (FixNum>0) and (FixNum<4);
          Running_Custom := (FixNum>3);

          TSSLRIndex := TSSLRi;
          FixedScen := FixNum;
          IPCCSLRate:= IPCCScen;
          IPCCSLEst:= IPCCEst;
          ProtectDeveloped :=(Prot_Scenario>NoProtect);
          ProtectAll :=(Prot_Scenario>ProtDeveloped);

          GridForm.Caption := 'SLAMM 6 Map -- '+ExtractFileName(FileN);
          RunPanel.Visible := False;

          Result := ShowMap(Site.RunRows,Site.RunCols,Site,Self);
          If (Not Result) or (UserStop) then Begin Result := False; UserStop:=True; RestoreSubSites; Exit; End;

          Year := 0;
          ShowRunPanel;
        End;

    Result := PreProcessWetlands;
    If Not Result then Begin UserStop := True; RestoreSubSites; Exit; End;

    Year :=  Site.GlobalSite.NWI_Photo_Date;
    InitSubSite(Site.GlobalSite);
    For i := 0 to Site.NSubSites-1 do
      InitSubSite(Site.SubSites[i]);

    If (Length(BMatrix) < Site.RunRows * Site.RunCols) then
        Begin
          BMatrix := nil;
          SetLength (BMatrix,Site.RunRows * Site.RunCols);
        End;
     For i:=0 to (Site.RunRows-1) do
       For j:=0 to (Site.RunCols-1) do
         BMatrix[Site.RunCols*(i)+(j)]:=0;

    If (Length(ErodeMatrix) < Site.RunRows * Site.RunCols) then
        Begin
          ErodeMatrix := nil;
          SetLength (ErodeMatrix,Site.RunRows * Site.RunCols);
        End;

    If (trim(SalFileN)='')  // no salinity file specified
     or (Pos('.xls',lowercase(SalFileN))>0) // or excel salinity file specified
       then Result := CalcSalinity(true,true)  //not using raster salinity file so try to calc salinity
       else Result := True;

    If Not Result then Begin UserStop := True; Exit;RestoreSubSites; End;

    // Connectivity and Inundation Maps for initial conditions
    InundFreqCheck := False;
    if InundMaps or (SaveGIS and SaveInundGIS) or (NRoadInf>0) or (NPointInf>0) then
      begin
        Result := Calc_Inund_Freq;
        InundFreqCheck := Result;
      end
        else Inund_Arr := nil;
    If Not Result then Begin UserStop := True;RestoreSubSites; Exit; End;

    ConnectCheck := False;
    if CheckConnectivity or ConnectMaps then
      begin
        Result := Calc_Inund_Connectivity(@Connect_Arr,True,-1);
        ConnectCheck := Result;
      end
    else
      Connect_Arr := nil;
    If Not Result then Begin UserStop := True; RestoreSubSites;Exit; End;

    // SAV Map for initial conditions
    SAV_KM  := -9999;
    SAVProbCheck := False;
    if (trim(D2MFileN)<>'') then
      begin
        Result := CalculateProbSAV(False);
        SAVProbCheck := Result;
      end;
    If Not Result then Begin UserStop := True; RestoreSubSites;Exit; End;

    // Calculate  frequency of road inundation if relevant
    RoadInundCheck := False;
    If NRoadInf>0 then
      Begin
        for j:=0 to NRoadInf-1 do
          RoadInundCheck := RoadsInf[j].CalcAllRoadsInundation;
        Result := RoadInundCheck;
        If Not Result then Begin UserStop := True;RestoreSubSites; Exit; End;
      End;
    If NPointInf>0 then
     for j:=0 to NPointInf-1 do
      Begin
        Result := PointInf[j].CalcAllPointInfInundation;
        If Not Result then Begin UserStop := True; RestoreSubSites;Exit; End;
      End;

    If GridForm.Visible then  {display map after pre-processor and salinity calculation}
     With GridForm do
      Begin
        SS := Self;
        If QA_Tools then
           Begin ProgForm.YearLabel.Visible:=True;
                 ProgForm.YearLabel.Caption:= 'Init.Cond';
                 ProgForm.Show;

                 hide; MapTitle.Visible := True;
                 MapTitle.Caption:= 'NWI Processed Elevations Over NED';
                 UserStop := False;
                 RunPanel.Visible := False;
                 MR := ShowModal;

                 IF (MR=2) then if MessageDlg('Stop Simulation Execution And Return to Main Menu? ',mtconfirmation,[mbyes,mbno],0) = mryes then
                     MR := MRAbort;   // Disambiguation of X key

                 If MR = MRAbort then Begin Result := False; UserStop:=True; RestoreSubSites;exit; End;
                 If MR = MRIgnore then QA_Tools := False;
                 Show; Update; MapTitle.Visible := False; IsVisible := True;
           end;

        Year := 0;  // label maps as initial condition

        If Maps_to_MSWord or Maps_to_GIF then Result := CopyMapsToMSWord; // 12/15/09 Wait for pre-processing & Salinity Calcs

        If Not Result then Begin UserStop := True; RestoreSubSites;Exit; End;

        Year :=  Site.GlobalSite.NWI_Photo_Date;  // return to current date

        ShowRunPanel;

      End; // IF GRID FORM VISIBLE

    ProgForm.YearLabel.Visible       :=False;
    ProgForm.SLRLabel.Visible        := True;
    ProgForm.ProtectionLabel.Visible := True;

    Running_Fixed := (FixNum>0) and (FixNum<12);  //NYS SLR Scenarios - changed to 12 from 4 - Marco
    Running_Custom := (FixNum>11);     //NYS SLR Scenarios - changed to 11 from 3 - Marco
    TSSLRIndex := TSSLRi;
    Running_TSSLR := TSSLRi > 0;
    FixedScen := FixNum;
    IPCCSLRate:= IPCCScen;
    IPCCSLEst:= IPCCEst;

    If Running_Fixed
      then ProgForm.SLRLabel.Caption  := LabelFixed[FixNum]
      else if Running_Custom then ProgForm.SLRLabel.Caption  := FloatToStrF(Current_Custom_SLR ,ffgeneral,4,2)+ ' meters '
      else if Running_TSSLR then ProgForm.SLRLabel.Caption := TimeSerSLRs[TSSLRindex-1].Name
      else ProgForm.SLRLabel.Caption  := LabelIPCC[IPCCScen]+' '+LabelIPCCEst[IPCCEst];

    ProgForm.ProtectionLabel.Caption := LabelProtect[ProtScen];
    ProgForm.Show;

    Result := InitYearSLAM;  {RUN FIRST YEAR HERE}

    If Not Result then
      Begin
        UserStop:=True;  RestoreSubSites;
        Exit;
      End;

    If (Year<MaxYear) and not (RunSpecificYears and (IntToStr(Year) = Trim(YearsString))) then  //10/6/2014 JSC Allow for time-zero-only runs
      REPEAT  {Run additional Year}
        Inc(TStepIter);

        ZeroSums;

        Result := RunOneYear(False);
        If Not Result then Begin UserStop:=True; RestoreSubSites;Exit; End;

        IF SaveGIS Then If GISForm.OutputYear(Year) THEN Result := Save_GIS_Files;
        If Not Result then Begin UserStop:=True; RestoreSubSites;Exit; End;

      If GridForm.Visible then
      With GridForm do
       Begin
         SS := Self;
         If QA_Tools then  {display map after each step of the simulation}
               Begin hide; MapTitle.Visible := True;
                     MapTitle.Caption:= 'Map at Year '+IntToStr(Year);
                     UserStop := False;
                     RunPanel.Visible := False;
                     MR := ShowModal;

                     IF (MR=2) then if MessageDlg('Stop Simulation Execution And Return to Main Menu? ',mtconfirmation,[mbyes,mbno],0) = mryes then
                       MR := MRAbort;   // Disambiguation of X key

                     If MR = MRAbort then Begin Result := False; UserStop:=True; RestoreSubSites;exit; End;
                     If MR = MRIgnore then QA_Tools := False;
                     Show; Update; MapTitle.Visible := False; IsVisible := True;
               end;
         ShowRunPanel;

         If Maps_to_MSWord or Maps_to_GIF then Result := CopyMapsToMSWord;
         If Not Result then Begin UserStop := True; RestoreSubSites;Exit; End;
       End;

      UNTIL Year >= MaxYear;

    Save_CSV_File;

    For j:=0 to NRoadInf-1 do
      RoadsInf[j].WriteRoadDBF(ScenIter=1,TStepIter+1);  // zero index for T-zero
    For j:=0 to NPointInf-1 do
      PointInf[j].WritePointDBF(ScenIter=1,TStepIter+1);  // zero index for T-zero

{   If (not Display_Screen_Maps) and (not Gridform.IsVisible) then }
    DisposeFile(MapHandle,FALSE,BackupFN);

    if DikeLogInit then Closefile(DikeLog);

  { SetLength(Map,0); {deallocate memory}
    ProgForm.Hide;
    Gridform.RunPanel.Visible := False;
    RestoreSubSites;

  END; {EXECUTESLAMM }

    {------------------------------------------------------------}

Var i, FixLoop, ndbfs: Integer;

BEGIN {ExecuteRun}
 CPUs := GetLogicalCPUCount;
 UserStop := True;

 ScenIter := 0;
 WriteRunRecordFile;

 If (not UncAnalysis) and (not SensAnalysis) then
   If (NRoadInf>0) or (NPointInf>0) then ProgForm.Setup('Creating Infrastructure Output DBFs','','','',false);
 Application.ProcessMessages;
 ndbfs := NRoadInf+NPointInf;
 For i := 0 to NRoadInf-1 do
   Begin
     with RoadsInf[i] do
       If CheckValid then CreateOutputDBF else Exit;
     ProgForm.Update2Gages(Trunc((i+1)/ndbfs*100),0);
   End;
 For i := 0 to NPointInf-1 do
   Begin
    With PointInf[i] do
      If CheckValid then CreateOutputDBF else Exit;
    ProgForm.Update2Gages(Trunc((i+1+NRoadInf)/ndbfs*100),0);
   End;

 UserStop := False;
 If (not UncAnalysis) and (not SensAnalysis) then WordInitialized := False;
    Begin           { Loop through Scenarios and Protection Scenarios }
       For IPCC_Scenario := Scen_A1B to Scen_B2 do
        For IPCC_Est := Est_Min to Est_Max do
         For Prot_Scenario := NoProtect to ProtAll do
          If IPCC_Scenarios[IPCC_Scenario] and IPCC_Estimates[IPCC_Est] and Prot_To_Run[Prot_Scenario] then
           If Not ExecuteSLAMM(Prot_Scenario,IPCC_Scenario,IPCC_Est,0,0) then Exit;

       IPCC_Est := Est_Min;
       IPCC_Scenario := Scen_A1B;
       For Prot_Scenario := NoProtect to ProtAll do
         For FixLoop := 1 to 11 do         //Added the NYS and ESVA Scenarios - Marco
           If Fixed_Scenarios[FixLoop] and Prot_To_Run[Prot_Scenario] then
             If Not ExecuteSLAMM(Prot_Scenario,IPCC_Scenario,IPCC_Est,FixLoop,0) then Exit;

       If RunCustomSLR then
         for i := 0 to N_CustomSLR-1 do
          begin
            Current_Custom_SLR := CustomSLRArray[i];
            For Prot_Scenario := NoProtect to ProtAll do
              If Prot_To_Run[Prot_Scenario] then
                If Not ExecuteSLAMM(Prot_Scenario ,IPCC_Scenario,IPCC_Est,9999{flag for custom},0) then Exit;
          end;

       For i := 0 to NTimeSerSLR-1 do
         If TTimeSerSLR(TimeSerSLRs[i]).RunNow then
           For Prot_Scenario := NoProtect to ProtAll do
             If Prot_To_Run[Prot_Scenario] then
               If Not ExecuteSLAMM(Prot_Scenario ,IPCC_Scenario,IPCC_Est,0, i+1) then Exit;
    End;  {Loop through Scenarios}


    ProgForm.Cleanup;
End;

Constructor TSLAMM_Simulation.Create(California: Boolean);
Var ND, NS, i: Integer;
begin
  inherited Create;

  For ND := 1 to NWindDirections do
    For NS := 1 to NWindSpeeds do
      WindRose[ND,NS] := 0;

  Categories := TCategories.Create(Self);
  If California then Categories.SetupCADefault
                else Categories.SetupSLAMMDefault;

  Changed := True;
  FileN := '';
  SimName := '';
  Descrip := '';
  Site    := TSite.Create;
  TimeStep := 25;
  MaxYear := 2100;
  RunSpecificYears := False;
  YearsString := '';
  NumMMEntries := 0;
  TStepIter := 0;
  Max_WErode := 0;
  ScenIter := 0;
  NTimeSteps := 1; // minimum
  With SAVParams do
    Begin
     Intcpt := 0;
     C_DEM := 0;
     C_DEM2 := 0;
     C_DEM3 := 0;
     C_D2MLLW :=0;
     C_D2MHHW :=0;
     C_D2M := 0;
     C_D2M2:= 0;   //default coefficients for SAV estimation -- Removed 8-20-2014 at USGS request -- JSC
    End;
//   Logit := -23.72 + DEM*(0.4769) + DEM*DEM*(-0.1377) +                        d2MLLW*(-0.005855) + d2MHHW*(0.001731)+ d2mouth*(0.007291) + d2mouth*d2mouth*(-0.0000005614);
//   Logit := Int    + (DEM*C_DEM) + (SQR*DEM*C_DEM2) + (Power(DEM,3)*C_DEM3) + (d2MLLW*C_D2MLLW) + (d2MHHW*C_D2MHHW) + d2mouth*(C2_D2M)   + d2mouth*d2mouth*(C2_D2M2);

  UncertSetup := TSLAMM_Uncertainty.Create;
  Fillchar(Fixed_Scenarios,Sizeof(Fixed_Scenarios),0);
  Fillchar(IPCC_Scenarios,Sizeof(IPCC_Scenarios),0);
  Fillchar(IPCC_Estimates,Sizeof(IPCC_Estimates),0);
  Fillchar(Prot_To_Run,Sizeof(Prot_To_Run),0);

  IPCC_Estimates[Est_Max] := True;
  IPCC_Scenarios[Scen_A1B] := True;
  Prot_To_Run[NoProtect] := True;

  RunCustomSLR := False;

  N_CustomSLR := 0;
  CustomSLRArray := nil;
  Current_Custom_SLR := 0;

  Make_Data_File      := False;
  Display_Screen_Maps := True;
  QA_Tools            := True;
  RunFirstYear        := True;
  Maps_to_MSWord      := False;
  Maps_to_GIF         := False;
  Complete_RunRec     := True;
  BatchMode           := False;
  SaveGIS             := False;
  SaveROSArea      := False;
  SaveElevSGIS        := False;
  SaveElevGISMTL := False;
  SaveSalinityGIS     := False;
  SaveBinaryGIS       := False;

  BatchFileN          := '';
  InitZoomFactor      := 1.0;

  SaveMapsToDisk      := False;
  MakeNewDiskMap      := True;

  FWFlows            := nil;
  NumFwFlows        := 0;
  SalRules          := TSalinityRules.Create;

  TimeSerSLRs       := nil;
  NTimeSerSLR       := 0;

  NRoadInf :=0; NPointInf := 0;
  RoadsInf := nil;
  PointInf := nil;

  IncludeDikes        := True;
  OptimizeLevel       := 1;
  ClassicDike         := True;

  NElevStats          := 0;

  ElevGridColors      := ElevationColors;

   {-- File Name Management}
  ProjRunString:= '';
  ElevFileN := '';
  NWIFileN  := '';

  OutputFileN  := '';

  SLPFileN  := '';
  IMPFileN  := '';
  ROSFileN  := '';
  DikFileN  := '';
  StormFileN := '';
  D2MFileN  := '';
  VDFileN   := '';
  UpliftFileN := '';
  OldRoadFileN := '';
  D2MFileN := '';
  Init_ElevStats := False;
  SAVProbCheck := False;
  ConnectCheck := False;
  InundFreqCheck := False;
  RoadInundCheck := False;
  Init_SalStats := False;
  Tropical := False;
  CheckConnectivity := false;
  UseSoilSaturation:= true;
  LoadBlankIfNoElev := true;

   {-------------------------------------------------------------}
  {NO LOAD OR SAVE BELOW}
   SalArray          := nil;
   Map               := nil;
   BackupFN          := '';
   DikeInfo          := nil;
   WordApp           := null;
   WordDoc           := null;
   WordInitialized   := False;

   Connect_arr:= nil;
   Inund_Arr := nil;

  NumRows := 0;
//  ZeroSums;

  For i := 1 to 2 do
   Begin
    UseSSRaster[i] := False;
    SS_Raster_SLR[i] := False;
    SSFilen [i] := '';
    SS_SLR [i,1] := 0;
    SS_SLR [i,2] := 0;
    SSRasters [i,1] := nil;
    SSRasters [i,2] := nil;
   end;

  Fillchar(ColLabel,Sizeof(ColLabel),0);
  Fillchar(RowLabel,Sizeof(RowLabel),0);
  FileStarted       := False;
  BMatrix := nil;
  ErodeMatrix := nil;
  MapMatrix := nil;
  DataElev := nil;
  MaxFetchArr := nil;
  RosArray := nil;
  SAV_KM  := -9999;
  dikelogInit := False;
  CatSums := nil;
  ROS_Resize := 3;  // 100%
  RescaleMap := 1; // 100%
  RoadSums := nil;
//  FRs := nil;
  InitializeCriticalSection(CriticalSection);
end;

{------------------------------------------------------------------------------}

constructor TSLAMM_Simulation.Load(FN: string);
Var  TS: TFileStream;
     TF: TextFile;
begin
  FileN := FN;
  TSText := lowercase(ExtractFileExt(FN)) = '.txt';

  GlobalFile := @TF;
  TS := nil;
  Try
    If TSText
      then
        Begin
           AssignFile(GlobalFile^,FileN);
           Reset(GlobalFile^);
           GlobalLN := 0;
        End
      else TS:=TFileStream.Create(FileN,fmOpenRead);
  Except
    MessageDlg(Exception(ExceptObject).Message,mterror,[mbOK],0);
    Exit;
  End; {Try Except}

  Try
    SetCurrentDir(ExtractFilePath(FileN));
    Load(TS);
  Except
    On E : Exception do
      Begin
       If TS <> nil then TS.Free;
       If TSText then Closefile(GlobalFile^);
       ShowMessage('Load Simulation Error: '+E.Message);
      End;
  End;

  If TSText then Closefile(GlobalFile^)
            else TS.Free;

  Changed := False;
  SalArray := nil;
  InitializeCriticalSection(CriticalSection);
end;

Constructor TSLAMM_Simulation.Load(TS: TStream);
Var  ReadVersionNum: Double;
     OLevel, i, ND, NS: Integer;
//     OldElevBuffer: Array of Byte;
     AddtlOptimize:Boolean;
     GISEachYear: Boolean;
     GISYrs: String;
     OldCustomSLR, CheckSum : Double;
     SLR_By_2100: Double; //no longer used
     ExtraMaps : boolean; // no longer used

Begin
  GlobalTS := TS;

  TSRead('ReadVersionNum',ReadVersionNum);

  If ReadVersionNum > VersionNum then
    Raise ESLAMMError.Create('File Version Number (' +  FloatToStrF(ReadVersionNum,ffgeneral,6,6)
     + ') is Greater than Executable Version Number ('+ FloatToStrF(VersionNum    ,ffgeneral,6,6)
     + ').  Please update your version of SLAMM.');

  If ReadVersionNum < 6.965 then
    Raise ESLAMMError.Create('Cannot yet read SLAMM 6.6 files or before (Pre California Version: file-version numbers prior to 6.97.)');

  Init_ElevStats := False;
  If ReadVersionNum > 6.965 then TSRead('Init_ElevStats',Init_ElevStats);

  NElevStats := 0;
  if ReadVersionNum > 6.965 then TSRead('NElevStats',NElevStats);
  Categories := TCategories.Load(Self,ReadVersionNum,TS);

  TSRead('SimName',SimName,ReadVersionNum);
  TSRead('Descrip',Descrip,ReadVersionNum);

  Site := TSite.Load(ReadVersionNum,TS);

  For ND := 1 to NWindDirections do
    For NS := 1 to NWindSpeeds do
      TSRead('WindRose['+InttoStr(ND)+','+InttoStr(NS)+']',WindRose[ND,NS]);

  TSRead('NumFwFlows',NumFwFlows);
  SetLength(FWFlows,NumFwFlows);
  For i := 0 to NumFwFlows -1 do
    FWFlows[i] := TFwFlow.Load(ReadVersionNum,TS);

  If (ReadVersionNum > 6.865) and (ReadVersionNum < 6.875) and (NumFwFlows>0)
     Then
       Begin
          MessageDlg('Barrier-Island Migration is not Enabled in this Version',mtwarning,[mbok],0);
          For i := 0 to NumFwFlows -1 do
            FWFlows[i].Free;
          NumFwFlows := 0;
       End;


  if ReadVersionNum > 6.045 then
    SalRules := TSalinityRules.Load(ReadVersionNum,TS)
  else
    SalRules := TSalinityRules.Create;

  If ReadVersionNum < 6.885 then
    Begin
      NRoadInf := 0;
      RoadsInf := nil;
      NPointInf := 0;
      PointInf := nil;
     End
  else  // > 6.885
    Begin
      TSRead('NRoadInf',NRoadInf);
      SetLength(RoadsInf,NRoadInf);
      For i:=0 to NRoadInf-1 do
        RoadsInf[i] := TRoadInfrastructure.Load(ReadVersionNum,TS,Self);

      TSRead('NPointInf',NPointInf);
      SetLength(PointInf,NPointInf);
      For i:=0 to NPointInf-1 do
        PointInf[i] := TPointInfrastructure.Load(ReadVersionNum,TS,Self);
    End;


  If ReadVersionNum < 6.935 then
    Begin
      NTimeSerSLR := 0;
      TimeSerSLRs := nil;
     End
  else  // > 6.885
    Begin
      TSRead('NTimeSerSLR',NTimeSerSLR);
      SetLength(TimeSerSLRs,NTimeSerSLR);
      For i:=0 to NTimeSerSLR-1 do
        TimeSerSLRs[i] := TTimeSerSLR.Load(ReadVersionNum,TS);
    End;

  TSRead('TimeStep',TimeStep);
  TSRead('MaxYear',MaxYear);
  If ReadVersionNum < 6.085
    then
      Begin
        RunSpecificYears := False;
        YearsString := '';
      End
    else
      Begin
        TSRead('RunSpecificYears',RunSpecificYears);
        TSRead('YearsString',YearsString,ReadVersionNum);
      End;

  If ReadVersionNum > 6.195 then TSRead('RunUncertainty',RunUncertainty)
                            else RunUncertainty := False;

  If ReadVersionNum > 6.215 then TSRead('RunSensitivity',RunSensitivity)
                            else RunSensitivity := False;


  If TSText then
    Begin
      TSRead('Scen_A1B',IPCC_Scenarios[Scen_A1B]);
      TSRead('Scen_A1T',IPCC_Scenarios[Scen_A1T]);
      TSRead('Scen_A1F1',IPCC_Scenarios[Scen_A1F1]);
      TSRead('Scen_A2',IPCC_Scenarios[Scen_A2]);
      TSRead('Scen_B1',IPCC_Scenarios[Scen_B1]);
      TSRead('Scen_B2',IPCC_Scenarios[Scen_B2]);

      TSRead('Est_Min',IPCC_Estimates[Est_Min]);
      TSRead('Est_Mean',IPCC_Estimates[Est_Mean]);
      TSRead('Est_Max',IPCC_Estimates[Est_Max]);

      TSRead('Fix1.0M',Fixed_Scenarios[1]);
      TSRead('Fix1.5M',Fixed_Scenarios[2]);
      TSRead('Fix2.0M',Fixed_Scenarios[3]);

      // NYS and ESVA SLR Scenarios - Marco
      for i := 4 to 11 do
        Fixed_Scenarios[i] := False;

      if ReadVersionNum>6.675 then
        begin
          TSRead('NYS_GCM_Max',Fixed_Scenarios[4]);
          TSRead('NYS_1M_2100',Fixed_Scenarios[5]);
          TSRead('NYS_RIM_Min',Fixed_Scenarios[6]);
          TSRead('NYS_RIM_Max',Fixed_Scenarios[7]);
        end;
      if ReadVersionNum>6.845 then
        begin
          TSRead('ESVA_Hist',Fixed_Scenarios[8]);
          TSRead('ESVA_Low',Fixed_Scenarios[9]);
          TSRead('ESVA_High',Fixed_Scenarios[10]);
          TSRead('ESVA_Highest',Fixed_Scenarios[11]);
        end;

      TSRead('Prot_To_Run[NoProtect]',Prot_To_Run[NoProtect]);
      TSRead('Prot_To_Run[ProtDeveloped]',Prot_To_Run[ProtDeveloped]);
      TSRead('Prot_To_Run[ProtAll]',Prot_To_Run[ProtAll]);
    End
  else
    Begin
      if ReadVersionNum < 6.845 then
        Begin
          if ReadVersionNum < 6.675 then
            begin
              TS.Read(Fixed_Scenarios,3);
              for i := 4 to 11 do
                Fixed_Scenarios[i] := False;
            end
          else
            begin
              TS.Read(Fixed_Scenarios,7);
              for i := 8 to 11 do
                Fixed_Scenarios[i] := False;
            end;
        End
          else TS.Read(Fixed_Scenarios,Sizeof(Fixed_Scenarios));

      TS.Read(IPCC_Scenarios,Sizeof(IPCC_Scenarios));
      TS.Read(IPCC_Estimates,Sizeof(IPCC_Estimates));
      TS.Read(Prot_To_Run,Sizeof(Prot_To_Run));
    End;


  N_CustomSLR := 0;
  CustomSLRArray := nil;
  Current_Custom_SLR := 0;
  if ReadVersionNum>6.075 then
    begin
      TSRead('RunCustomSLR',RunCustomSLR);
      if ReadVersionNum>6.835 then
        Begin
          TSRead('N_CustomSLR',N_CustomSLR);
          SetLength(CustomSLRArray,N_CustomSLR);
          For i := 0 to N_CustomSLR -1 do
            TSRead('CustomSLRArray[i]',CustomSLRArray[i]);
        End
      else
        begin
          TSRead('CustomSLR',OldCustomSLR);
          N_CustomSLR := 1;
          SetLength(CustomSLRArray,1);
          CustomSLRArray[0] := OldCustomSLR;
        end;
    end;

  TSRead('Make_Data_File',Make_Data_File);
  TSRead('Display_Screen_Maps',Display_Screen_Maps);
  TSRead('QA_Tools',QA_Tools);
  TSRead('RunFirstYear',RunFirstYear);
  TSRead('Maps_to_MSWord',Maps_to_MSWord);

  If ReadVersionNum > 6.275 then TSRead('Maps_to_GIF',Maps_to_GIF)
                            else Maps_to_GIF := False;

  If ReadVersionNum > 6.945 then TSRead('Complete_RunRec',Complete_RunRec)
                            else Complete_RunRec := True;

  //If ReadVersionNum > 6.055 then TSRead('ExtraMaps',ExtraMaps)
  //                          else ExtraMaps := False;


  SalinityMaps := False;
  AccretionMaps :=False;
  If ReadVersionNum > 6.615 then
    begin
      TSRead('SalinityMaps',SalinityMaps);
      TSRead('AccretionMaps',AccretionMaps);
    end
  else if (ReadVersionNum > 6.055) and (ReadVersionNum < 6.615) then
    begin
      TSRead('ExtraMaps',ExtraMaps);
      SalinityMaps := ExtraMaps;
      AccretionMaps :=ExtraMaps;
    end;

  If ReadVersionNum > 6.285 then TSRead('DucksMaps',DucksMaps)
                            else DucksMaps := False;


  SAVMaps := False;
  ConnectMaps := False;
  If ReadVersionNum > 6.635 then
    begin
      TSRead('SAVMaps',SAVMaps);
      TSRead('ConnectMaps',ConnectMaps);
    end;
  InundMaps := False;
  If ReadVersionNum > 6.645 then
    begin
      TSRead('InundMaps',InundMaps);
    end;

  RoadInundMaps := False;
  If ReadVersionNum > 6.655 then
    begin
      TSRead('RoadInundMaps',RoadInundMaps);
    end;

  TSRead('SaveGIS',SaveGIS);

  If ReadVersionNum > 6.235 then
      TSRead('SaveElevsGIS',SaveElevsGIS) else SaveElevsGIS := False;

  SaveElevGISMTL := True;
  if ReadVersionNum > 6.865 then
    TSRead('SaveElevGISMTL',SaveElevGISMTL);

  If ReadVersionNum > 6.365 then
      TSRead('SaveSalinityGIS',SaveSalinityGIS) else SaveSalinityGIS := False;

  If ReadVersionNum > 6.935 then
      TSRead('SaveInundGIS',SaveInundGIS) else SaveInundGIS := False;

  If ReadVersionNum > 6.825 then
      TSRead('SaveBinaryGIS',SaveBinaryGIS) else SaveBinaryGIS := False;

  SaveROSArea := False;
  If (ReadVersionNum > 6.685) then
    begin
      if ReadVersionNum < 6.715 then
        TSRead('SaveOutputArea',SaveROSArea)
      else
        TSRead('SaveROSArea',SaveROSArea);
    end;

  TSRead('BatchMode',BatchMode);


  CheckConnectivity := False;
  ConnectMinElev := 1;
  ConnectNearEight := 1;
  UseSoilSaturation := True;
  LoadBlankIfNoElev := True;
  If ReadVersionNum > 6.085 then
    Begin
      TSRead('CheckConnectivity',CheckConnectivity);
      if ReadVersionNum > 6.775 then
        begin
          TSRead('ConnectMinElev', ConnectMinElev);
          TSRead('ConnectNearEight', ConnectNearEight);
        end;
      TSRead('UseSoilSaturation',UseSoilSaturation);
      TSRead('LoadBlankIfNoElev',LoadBlankIfNoElev);
    End;

  If ReadVersionNum < 6.095
      then UseBruun := True
      else TSRead('UseBruun',UseBruun);

  UseFloodForest := False;
  if ReadVersionNum > 6.705 then
    TSRead('UseFloodForest',UseFloodForest);

  UseFloodDevDryLand := False;
  if ReadVersionNum > 6.725 then
    TSRead('UseFloodDevDryLand',UseFloodDevDryLand);

  If ReadVersionNum<6.195 then
    TSRead('SLR_BY_2100',SLR_BY_2100);

  TSRead('InitZoomFactor',InitZoomFactor);

  TSRead('SaveMapsToDisk',SaveMapsToDisk);
  TSRead('MakeNewDiskMap',MakeNewDiskMap);
  TSRead('IncludeDikes',IncludeDikes);

  OptimizeLevel := 1;
  NumMMEntries := 0;
  If ReadVersionNum < 6.005 then
    Begin
      TSRead('AddtlOptimize',AddtlOptimize);
      If AddtlOptimize then OptimizeLevel := 2;
    End;

  ClassicDike := True;
  if ReadVersionNum > 6.345 then
    Begin
      TSRead('ClassicDike',ClassicDike);
    end;

(*  If Not TSText then  {elevranges not saved to text}
   If ReadVersionNum > 6.025 then TS.Read(ElevRanges,Sizeof(ElevRanges))
    else Begin
           TS.Read(ElevRanges,414);
           SetDefaultCategoryVariables;
         End;  Read SLAMM6 files *)

{  If TSText then LoadElevRangesfromText(ElevRanges); }

(*  If Not TSText then  {elevstats not saved to text}
    if ReadVersionNum < 6.295 then
      begin
        SetLength(OldElevBuffer,35265);
        if ReadVersionNum > 6.025 then
          begin
            If (ReadVersionNum > 6.195) then
              TS.Read(Pointer(OldElevBuffer)^,35264)
            else
              TS.Read(Pointer(OldElevBuffer)^,2192);
          end
        else if ReadVersionNum < 6.015 then
          TS.Read(Pointer(OldElevBuffer)^,2216)
        else
          TS.Read(Pointer(OldElevBuffer)^,1928);
        OldElevBuffer := nil;
        NElevStats := 0;
      end
    else if ReadVersionNum < 6.695 then
      begin
        SetLength(OldElevBuffer,98704);
        TS.Read(Pointer(OldElevBuffer)^,98704);
        OldElevBuffer := nil;
        NElevStats := 0;
      end
    else
      begin  // CURRENT ELEV STATS CODE WITH ARRAY
        TS.Read(NElevStats,Sizeof(NElevStats));
        SetLength(ElevationStats,NElevStats);

        if ReadVersionNum < 6.855 then
            SetLength(OldElevBuffer,100576);

        for i := 0 to NElevStats-1 do
          if ReadVersionNum > 6.855 then
            TS.Read(ElevationStats[i],Sizeof(TElevStats))
          else if ReadVersionNum > 6.835
            then TS.Read(Pointer(OldElevBuffer)^,100576)
            else TS.Read(Pointer(OldElevBuffer)^,100368);
      end;

  if ReadVersionNum < 6.855 then
    Begin
        NElevStats := 0;
        OldElevBuffer := nil;
        ElevationStats := nil;
    End;  *)

(*  If Not TSText then  {gridcolors not saved to text}
    Begin
      If ReadVersionNum > 6.025 then
        TS.Read(GridColors,Sizeof(GridColors))
      else
        Begin
          TS.Read(GridColors,96);
          GridColors[FloodDevDryLand] := $00B7CFB1; {FloodDevDryLand is grey-green}
          GridColors[FloodForest] := $0075D6FF; {FloodForest is light orange, between dry land and beach}
        End;
      GridColors[FloodDevDryLand] := $00FF64B1; //Added to change Flooded Dev Dry Land color as purple
    End;
  If TSText then  GridColors := DefaultGridColors;  Read SLAMM6 files *)
//  NElevStats := 0;

  {-- File Name Management}
  TSRead('BatchFileN',BatchFileN,ReadVersionNum);
  TSRead('ElevFileN',ElevFileN,ReadVersionNum);
  TSRead('NWIFileN',NWIFileN,ReadVersionNum);
  TSRead('OutputFileN',OutputFileN,ReadVersionNum);
  TSRead('SLPFileN',SLPFileN,ReadVersionNum);

  TSRead('IMPFileN',IMPFileN,ReadVersionNum);
  TSRead('ROSFileN',ROSFileN,ReadVersionNum);
  TSRead('DikFileN',DikFileN,ReadVersionNum);
  If ReadVersionNum > 6.925 then TSRead('StormFileN',StormFileN,ReadVersionNum)
                            else StormFileN := '';

  TSRead('VDFileN',VDFileN,ReadVersionNum); {8/26/2009}
  TSRead('UpliftFileN',UpliftFileN,ReadVersionNum);

  SalFileN := '';
  if ReadVersionNum >  6.335 then
      TSRead('SalFileN',SalFileN,ReadVersionNum);

  OldRoadFileN := '';
  if ReadVersionNum >  6.615 then  // increased from 6.545 when integrating Roads & SAV Branches
       TSRead('RoadFileN',OldRoadFileN,ReadVersionNum);

  D2MFileN := '';
  if ReadVersionNum > 6.625 then
      TSRead('D2MFileN',D2MFileN,ReadVersionNum);

  if ReadVersionNum > 6.00 then
    begin
      if TSText then
        begin
          TSRead('OptimizeLevel',OLevel);
          OptimizeLevel := Olevel;
        end
      else
        TS.Read(OptimizeLevel,Sizeof(OptimizeLevel));
      TSRead('NumMMEntries',NumMMEntries);
    end;

  if (ReadVersionNum > 6.625) and (not TSText)
   then TS.Read(SAVParams,Sizeof(SAVParams))
   else
      With SAVParams do
        Begin
          Intcpt := 0;
          C_DEM := 0;
          C_DEM2 := 0;
          C_DEM3 := 0;
          C_D2MLLW :=0;
          C_D2MHHW :=0;
          C_D2M := 0;
          C_D2M2:= 0;   //default coefficients for SAV estimation -- Removed 8-20-2014 at USGS request -- JSC
        End;

{  Init_ElevStats := False;
  If ReadVersionNum > 6.965 then TSRead('Init_ElevStats',Init_ElevStats);  // Read SLAMM6 files}

(*  If ReadVersionNum > 6.015 then
    If Not TSText then
      TSRead('Init_ElevStats',Init_ElevStats);
  If ReadVersionNum < 6.835 then Init_ElevStats := False; *)

  Init_SalStats := False;
(*  If Not TSText then  {SalStats not saved to text}
    If ReadVersionNum > 6.035
      then
        Begin
          If ReadVersionNum < 6.305 then
            TS.Read(SalStats,36504)    // size of the old record
          else if (ReadVersionNum < 6.615) and (ReadVersionNum > 6.305)   then
            TS.Read(SalStats,48672)
          else if ReadVersionNum < 6.905 then
            TS.Read(SalStats,48680)
          else
            TS.Read(SalStats,Sizeof(SalStats));  //size of the current record derived from sizeof function

          TSRead('Init_SalStats',Init_SalStats);
        End; *)

  Tropical := False;

  If ReadVersionNum > 6.065
    then Begin
           TSRead('GISEachYear',GISEachYear);
           TSRead('GISYears',GISYrs,ReadVersionNum);
           GISForm.WriteEachYear.Checked := GISEachYear;
           GISForm.ChooseYears.Checked := not GISEachYear;

           GISForm.Edit1.Text := GISYrs;
         End
    else GISForm.WriteEachYear.Checked := True;

  If ReadVersionNum > 6.199 then UncertSetup := TSLAMM_Uncertainty.Load(ReadVersionNum, TS, Self)
                            else UncertSetup := TSLAMM_Uncertainty.Create;

  If TSText then TSRead('ExecuteImmediately',DRIVE_EXTERNALLY);

  If (ReadVersionNum > 6.755) then TSRead('ROS_Resize',ROS_Resize)
                              else ROS_Resize := 3;  // 100%

  If (ReadVersionNum > 6.795) then TSRead('RescaleMap',RescaleMap)
                              else RescaleMap := 1;  // 100%

  if (ReadVersionNum > 6.661) then
    Begin
      TSRead('CheckSum',CheckSum);
      if CheckSum <> ReadVersionNum then ShowMessage('CheckSum does not match, simulation read is corrupted or programming error.');
    End;


  Changed := False;

  {-------------------------------------------------------------}
  {NO LOAD OR SAVE BELOW}

   Map               := nil;
   BackupFN          := '';
   DikeInfo          := nil;
   WordApp           := null;
   WordDoc           := null;
   WordInitialized   := False;
   SAVProbCheck := False;
   ConnectCheck := False;
   InundFreqCheck := False;
   RoadInundCheck := False;

   Connect_arr:= nil;
   Inund_Arr := nil;

  NumRows := 0;
//  ZeroSums;
  For i := 1 to 2 do
   Begin
    UseSSRaster[i] := False;
    SS_Raster_SLR[i] := False;
    SSFilen [i] := '';
    SS_SLR [i,1] := 0;
    SS_SLR [i,2] := 0;
    SSRasters [i,1] := nil;
    SSRasters [i,2] := nil;
   end;

  Fillchar(ColLabel,Sizeof(ColLabel),0);
  Fillchar(RowLabel,Sizeof(RowLabel),0);
  FileStarted       := False;
  BMatrix := nil;
  ErodeMatrix := nil;
  dikelogInit := False;
  MapMatrix := nil;
  DataElev := nil;
  MaxFetchArr := nil;
  RosArray := nil;
  CatSums := nil;
  RoadSums := nil;
  SAV_KM  := -9999;
//  FRs := nil;
  SalArray := nil;
  InitializeCriticalSection(CriticalSection);

end;

{------------------------------------------------------------------------------}

procedure TSLAMM_Simulation.Save(FN: string);
Var  TS: TFileStream;
     TF: TextFile;
begin
  FileN := FN;

  TSText := lowercase(ExtractFileExt(FN)) = '.txt';

  GlobalFile := @TF;
  TS := nil;
   Try
     If TSText
       then
         Begin
           AssignFile(GlobalFile^,FileN);
           Rewrite(GlobalFile^);
           GlobalLN := 0;
         End
       else TS:=TFileStream.Create(FileN,fmCreate);
    Except
      MessageDlg(Exception(ExceptObject).Message,mterror,[mbOK],0);
      Exit;
    End; {Try Except}

  Save(TStream(TS));

  If TSText then Closefile(GlobalFile^)
            else TS.Free;
End;

Procedure TSLAMM_Simulation.Save(var TS:TStream);
Var  OLevel, i, ND, NS: Integer;
     GISEachYear: Boolean;
     GISYears: String;

Begin
  GlobalTS := TS;

  TSWrite('ReadVersionNum',VersionNum);

  TSWrite('Init_ElevStats',Init_ElevStats);
  If Not Init_ElevStats then NElevStats := 0;

  TSWrite('NElevStats',NElevStats);
  Categories.Store(TS);
  TSWrite('SimName',SimName);
  TSWrite('Descrip',Descrip);

  Site.Store(TStream(TS));

  For ND := 1 to NWindDirections do
    For NS := 1 to NWindSpeeds do
      TSWrite('WindRose['+InttoStr(ND)+','+InttoStr(NS)+']',WindRose[ND,NS]);

  TSWrite('NumFwFlows',NumFwFlows);
  For i := 0 to NumFwFlows-1 do
    FWFlows[i].Store(TStream(TS));

  SalRules.Store(TS);

  TSWrite('NRoadInf',NRoadInf);
  For i:=0 to NRoadInf-1 do
    RoadsInf[i].Save(TS);

  TSWrite('NPointInf',NPointInf);
  For i:=0 to NPointInf-1 do
    PointInf[i].Save(TS);

  TSWrite('NTimeSerSLR',NTimeSerSLR);
  For i:=0 to NTimeSerSLR-1 do
    TimeSerSLRs[i].Store(TS);

  TSWrite('TimeStep',TimeStep);
  TSWrite('MaxYear',MaxYear);
  TSWrite('RunSpecificYears',RunSpecificYears);
  TSWrite('YearsString',YearsString);
  TSWrite('RunUncertainty',RunUncertainty);
  TSWrite('RunSensitivity',RunSensitivity);

  If TSText then
    Begin
      TSWrite('Scen_A1B',IPCC_Scenarios[Scen_A1B]);
      TSWrite('Scen_A1T',IPCC_Scenarios[Scen_A1T]);
      TSWrite('Scen_A1F1',IPCC_Scenarios[Scen_A1F1]);
      TSWrite('Scen_A2',IPCC_Scenarios[Scen_A2]);
      TSWrite('Scen_B1',IPCC_Scenarios[Scen_B1]);
      TSWrite('Scen_B2',IPCC_Scenarios[Scen_B2]);

      TSWrite('Est_Min',IPCC_Estimates[Est_Min]);
      TSWrite('Est_Mean',IPCC_Estimates[Est_Mean]);
      TSWrite('Est_Max',IPCC_Estimates[Est_Max]);

      TSWrite('Fix1.0M',Fixed_Scenarios[1]);
      TSWrite('Fix1.5M',Fixed_Scenarios[2]);
      TSWrite('Fix2.0M',Fixed_Scenarios[3]);

      //NYS SLR Scenarios - Marco
      TSWrite('NYS_GCM_Max',Fixed_Scenarios[4]);
      TSWrite('NYS_1M_2100',Fixed_Scenarios[5]);
      TSWrite('NYS_RIM_Min',Fixed_Scenarios[6]);
      TSWrite('NYS_RIM_Max',Fixed_Scenarios[7]);

      //ESVA SLR Scenarios - Marco
      TSWrite('ESVA_Hist',Fixed_Scenarios[8]);
      TSWrite('ESVA_Low',Fixed_Scenarios[9]);
      TSWrite('ESVA_High',Fixed_Scenarios[10]);
      TSWrite('ESVA_Highest',Fixed_Scenarios[11]);

      TSWrite('Prot_To_Run[NoProtect]',Prot_To_Run[NoProtect]);
      TSWrite('Prot_To_Run[ProtDeveloped]',Prot_To_Run[ProtDeveloped]);
      TSWrite('Prot_To_Run[ProtAll]',Prot_To_Run[ProtAll]);
    End
  else
    Begin
      TS.Write(Fixed_Scenarios,Sizeof(Fixed_Scenarios));
      TS.Write(IPCC_Scenarios,Sizeof(IPCC_Scenarios));
      TS.Write(IPCC_Estimates,Sizeof(IPCC_Estimates));
      TS.Write(Prot_To_Run,Sizeof(Prot_To_Run));
    End;

  TSWrite('RunCustomSLR',RunCustomSLR);
  TSWrite('N_CustomSLR',N_CustomSLR);
  For i := 0 to N_CustomSLR -1 do
    TSWrite('CustomSLRArray[i]',CustomSLRArray[i]);

  TSWrite('Make_Data_File',Make_Data_File);
  TSWrite('Display_Screen_Maps',Display_Screen_Maps);
  TSWrite('QA_Tools',QA_Tools);
  TSWrite('RunFirstYear',RunFirstYear);
  TSWrite('Maps_to_MSWord',Maps_to_MSWord);
  TSWrite('Maps_to_GIF',Maps_to_GIF);
  TSWrite('Complete_RunRec',Complete_RunRec);

  //TSWrite('ExtraMaps',ExtraMaps);
  TSWrite('SalinityMaps',SalinityMaps);
  TSWrite('AccretionMaps',AccretionMaps);
  TSWrite('DucksMaps',DucksMaps);
  TSWrite('SAVMaps', SAVMaps);
  TSWrite('ConnectMaps', ConnectMaps);
  TSWrite('InundMaps', InundMaps);
  TSWrite('RoadInundMaps', InundMaps);

  TSWrite('SaveGIS',SaveGIS);
  TSWrite('SaveElevsGIS',SaveElevsGIS);
  TSWrite('SaveElevGISMTL',SaveElevGISMTL);
  TSWrite('SaveSalinityGIS',SaveSalinityGIS);
  TSWrite('SaveInundGIS',SaveInundGIS);

  TSWrite('SaveBinaryGIS',SaveBinaryGIS);

  TSWrite('SaveROSArea',SaveROSArea);

  TSWrite('BatchMode',BatchMode);

  TSWrite('CheckConnectivity',CheckConnectivity);
  TSWrite('ConnectMinElev', ConnectMinElev);
  TSWrite('ConnectNearEight', ConnectNearEight);
  TSWrite('UseSoilSaturation',UseSoilSaturation);
  TSWrite('LoadBlankIfNoElev',LoadBlankIfNoElev);

  TSWrite('UseBruun',UseBruun);

  TSWrite('UseFloodForest',UseFloodForest);
  TSWrite('UseFloodDevDryLand',UseFloodDevDryLand);
  
  TSWrite('InitZoomFactor',InitZoomFactor);

  TSWrite('SaveMapsToDisk',SaveMapsToDisk);
  TSWrite('MakeNewDiskMap',MakeNewDiskMap);
  TSWrite('IncludeDikes',IncludeDikes);
  TSWrite('ClassicDike',ClassicDike);

(*  If Not TSText
    then TS.Write(ElevRanges,Sizeof(ElevRanges))
    else SaveElevRangesToText(ElevRanges);

  If Not TSText then  {elevstats not saved to text}
    Begin
      if Init_ElevStats=False then NElevStats:=0;
      TS.Write(NElevStats,Sizeof(NElevStats));
      for i := 0 to NElevStats-1 do
          TS.Write(ElevationStats[i],Sizeof(TElevStats))
    End;

  If Not TSText then  {grid colors not saved to text}
    TS.Write(GridColors,Sizeof(GridColors)); *)

  {-- File Name Management}
  TSWrite('BatchFileN',BatchFileN);
  TSWrite('ElevFileN',ElevFileN);
  TSWrite('NWIFileN',NWIFileN);
  TSWrite('OutputFileN',OutputFileN);
  TSWrite('SLPFileN',SLPFileN);

  TSWrite('IMPFileN',IMPFileN);
  
  TSWrite('ROSFileN',ROSFileN);

  TSWrite('DikFileN',DikFileN);
  TSWrite('StormFileN',StormFileN);  // 6.93 addition

  TSWrite('VDFileN',VDFileN);
  TSWrite('UpliftFileN',UpliftFileN);

  TSWrite('SalFileN',SalFileN);  //new to 6.34

  TSWrite('RoadFileN',OldRoadFileN);
  TSWrite('D2MFileN',D2MFileN);

  If TSText
    then Begin
           OLevel := OptimizeLevel;
           TSWrite('OptimizeLevel',OLevel);
         End
       else TS.Write(OptimizeLevel,Sizeof(OptimizeLevel));
  TSWrite('NumMMEntries',NumMMEntries);
  If Not TSText then TS.Write(SAVParams,Sizeof(SAVParams));

//  TSWrite('Init_ElevStats',Init_ElevStats);

(*  If Not TSText then  {Elev & Sal Stats not saved to text}
    Begin
      TSWrite('Init_ElevStats',Init_ElevStats);
{      TS.Write(SalStats,Sizeof(SalStats)); }
      TSWrite('Init_SalStats',Init_SalStats);
    End; *)

 //  TSWrite(Init_SalStats)

  GISEachYear := GISForm.WriteEachYear.Checked ;
  GISYears    := GISForm.Edit1.Text;
  TSWrite('GISEachYear',GISEachYear);
  TSWrite('GISYears',GISYears);

  UncertSetup.Store(TS);

  If TSText then TSWrite('ExecuteImmediately',FALSE);  {default is not to start simulations automatically}
  TSWrite('ROS_Resize',ROS_Resize);  // new to 6.76
  TSWrite('RescaleMap',RescaleMap);  // new to 6.80

  TSWrite('CheckSum', VersionNum);  // new to version 6.67, check to ensure file is not corrupted

  Changed := False;

end;

{------------------------------------------------------------------------------}

Destructor TSLAMM_Simulation.Destroy;
Var i: Integer;
Begin
  Wordapp := null;
  Worddoc := null;
  If Site<>nil then Site.Free;
  BMatrix := nil;
  MapMatrix:= nil;
  If SalArray<>nil then SalArray.Destroy;

  UncertSetup.Free;
  SalRules.Free;

  For i := 0 to NRoadInf-1 do
    RoadsInf[i].Free;

  For i := 0 to NPointInf-1 do
    PointInf[i].Free;

  RoadsInf := Nil;
  PointInf := Nil;

  DisposeMem;

  inherited;
End;

{-----------------------------------------------------------------------------------}

(*Procedure TSLAMM_Simulation.AssignGridColors2;
Var Cat: Integer;
Begin
  for Cat := 0 to Categories.NCats-1 do
    Begin
      GridColors2[Cat].rgbtRed := Byte(GridColors[Cat]);
      GridColors2[Cat].rgbtGreen := Byte(GridColors[Cat] shr 8);
      GridColors2[Cat].rgbtBlue := Byte(GridColors[Cat] shr 16);
    End;
End;    *)

Procedure TSLAMM_Simulation.SummarizeFileInfo(Desc,FN: String);

    function RelToAbs(const RelPath, BasePath: string): string;
    var
      Dst: array[0..MAX_PATH-1] of char;
    begin
      PathCanonicalize(@Dst[0], PChar(IncludeTrailingBackslash(BasePath) + RelPath));
      result := Dst;
    end;

    function GetFileModDate(filename : string) : TDateTime;
    var
      F : TSearchRec;
    begin
      FindFirst(filename,faAnyFile,F);
      Result := F.TimeStamp;  //FileDateToDatetime(F.Time);
      Sysutils.FindClose(F);
    end;

Var FDateStr, FN2: String;
Begin
  If Not FileExists(FN) then Exit;

  FDateStr := DateTimeToStr(GetFileModDate(FN));
  FN2 := FN;
  if ANSIPos(':',FN2)=0 then FN2 := RelToAbs(FN,GetCurrentDir);

  Writeln(RunRecordFile,'"'+Desc+':" '+FN2+'     ('+FDateStr+')');

End;



Procedure TSLAMM_Simulation.WriteRunRecordFile;
Var TS: TStream;
Begin
   If RunUncertainty or RunSensitivity then exit; // separate logs exist for uncertainty & sensitivity runs.

   Try

   RunTime := FormatDateTime('yyyy-M-dd_(hh.nn.ss)',now());  //'yyyy-M-dd-(httnn/ms/s)'
   RunRecordFileName := ChangeFileExt(FileN,'');
   RunRecordFileName := RunRecordFileName + '_'+ RunTime+'.txt';

   Assignfile(RunRecordFile,RunRecordFileName);
   Rewrite(RunRecordFile);

   Writeln(RunRecordFile,'SLAMM '+VersStr+' Run at '+DateTimeToStr(Now()));
   Writeln(RunRecordFile,'SLAMM File Version '+FloattostrF(VersionNum,fffixed,3,2)+ ' Build '+BuildStr);
   SummarizeFileInfo('SLAMM6 File Name',FileN);

   Writeln(RunRecordFile);
   Writeln(RunRecordFile,'EXTERNAL DATA SUMMARY');
   SummarizeFileInfo('DEM File',ElevFileN);
   SummarizeFileInfo('SLAMM Categories',NWIFileN);
   SummarizeFileInfo('SLOPE File',SLPFileN);
   SummarizeFileInfo('DIKE File',DikFileN);
   SummarizeFileInfo('Pct. Impervious',IMPFileN);
   SummarizeFileInfo('Raster Output Sites',ROSFileN);
   SummarizeFileInfo('VDATUM',VDFileN);
   SummarizeFileInfo('Uplift/Subsidence',UpliftFileN);
   SummarizeFileInfo('Salinity',SalFileN);
   SummarizeFileInfo('Storm Surge',StormFileN);
   SummarizeFileInfo('Distance to Mouth',D2MFileN);

   Writeln(RunRecordFile);

   If Complete_RunRec then
     Begin
       Writeln(RunRecordFile,'---------------- ALL SLAMM PARAMETERS SHOWN BELOW.  CLIP BELOW THIS LINE TO READ INTO SLAMM AS TXT FILE  ---------------- ');
       TSText := True;
       GlobalLN := 0;
       GlobalFile := @RunRecordFile;
       TS := nil;
       Save(TS);
       Writeln(RunRecordFile);

     End;
   Writeln(RunRecordFile,'---------------- END OF PRE-MODEL-RUN LOG FILE  ---------------- ');

   CloseFile(RunRecordFile);

    Except
      MessageDlg('Error writing Run-Record File '+RunRecordFileName,mterror,[mbOK],0);
      MessageDlg(Exception(ExceptObject).Message,mterror,[mbOK],0);
      Exit;
      CloseFile(RunRecordFile);
    End; {Try Except}


End;

End.


