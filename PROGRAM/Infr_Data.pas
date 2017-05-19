unit Infr_Data;

interface

uses global, graphics, Classes, DBF, DB;

type
   DPoint = packed Record
    X,Y: Double;
  End;

  DPointArray = array of DPoint;
  PPointArray = ^DPointArray;

  DLine = packed record
    a, b, c : double; // ax+by+c =0
  end;

  DBoundary = packed Record
    RowMin, RowMax, ColMin, ColMax : integer;
  end;

   //--------------------------------------------
//Definitions for line data
//--------------------------------------------
type
  //InfTDoubleArray = array of double;

  LineRec = packed Record          //Road record - Cell and length with that cell
    Row, Col, ShpIndex, RoadClass : integer;
    X1, X2, Y1, Y2: double;    // send back to shp dbf; nosave for now
    Elev: double;
    Omit: Boolean;                   // omitted, TZero 30-Day
    LineLength : double;
    InundFreq: array of byte;  // one byte [0..255] for each time-step run; nosave
    OutSites: TBits;           // Is the road in the output sites-- compressed array of booleans,  nosave  // 7/7/2016
  end;


  TLineData = Array of LineRec;  // Collection of all the road data

Function InundText(I_F: Integer): String;
{
InundFreq  0  = below open water
           30 = inundated every 30 days
           60 = inundated every 60 days
           90 = inundated every 90 days
           120 = inundated by storm 1
           150 = inundated by storm 2
           252 = Irrelevant
           253 = Blank or Diked
           254 = Open Water
           255 = not inundated   }


// --------------------------------------------
//       Definitions for the point data
// --------------------------------------------
type

  //PointRecord
  PointRec = packed Record
    Row, Col, ShpIndex : integer;    // Coordinates of the point
    X,Y : double;                    // send back to shp dbf; nosave for now
    Elev: double;                    // Elevation
    Omit: Boolean;                   // omitted by user for some reason
    InfPointClass: Integer;          // Infrastructure Type
    InundFreq: array of byte;        // Frequency of Inundation  nosave
  end;

  TPointData = Array of PointRec;  // Collection of all the road data

  TInfrastructure = class
    InputFName : string;            // filename of CSV input or shapefile
    IDName     : String;            // user given name
    HasSpecificElevs : Boolean;     // whether to update elevations using data in *.shp or *.csv

    {  ---- no save below ---- }
    PSS: Pointer;                   // pointer back to TSLAMM_Simulation                                // nosave
    ProjRunStrArr: array of string; // Array of strings describing time-steps run for CSV output header  // nosave
    OutputFName : string;           // output file name, nosave
    Fields: Array of TField;
    ElevField: TField;
    Function CheckValid: Boolean;
    constructor Create(SS: Pointer);
    Destructor Destroy;  override;
    Constructor Load(ReadVersionNum: Double; TS: TStream; SS: Pointer);
    Procedure Save(var TS: TStream); overload;
    function CalculateCellInundation(Row, Col: Integer): Byte;
    Function UpdateInundFreq: Boolean;
    Procedure AddDBFFields(FirstWrite:Boolean; CountTS: Integer; Var DBF1: TDBF; Var WriteElevs: Boolean);
    Procedure CreateOutputDBF;
  end;

 TRoadInfrastructure = class(TInfrastructure)
    NRoadCl: Integer; // number of road classes
    NRoads   : Integer;
    RoadData : TLineData;           // array of road records
    RoadClasses : array of integer; //Integer representation of Road Classes present -- retain?    nosave
    RoadsLoaded, RoadsChanged: Boolean;
    Function CheckValid: Boolean;
    constructor Create(SS: Pointer);
    Procedure LoadData(ReadVersionNum: Double; TS: TStream; SS: Pointer);
    Constructor Load(ReadVersionNum: Double; TS: TStream; SS: Pointer);
    Procedure SaveData(var TS: TStream);
    Procedure Save(var TS: TStream); overload;
    Destructor Destroy;  override;
    procedure ReadRoadCSVFile(FN: string);
//  Procedure SetRoadIndices;
    Procedure Overwrite_Elevs;
    Procedure InitializeRoadVars;
    function CalcAllRoadsInundation: Boolean;
    procedure UpdateRoadSums(CountProj: integer; var RoadOutSum: Array of RoadArray; NOutSites: Integer);
    procedure WriteRoadDBF(FirstWrite: Boolean; CountTS: integer);

{    procedure Write2CSVFile(FileN: String; CountProj: integer); }
End;

 TPointInfrastructure = class(TInfrastructure)
    NPoints      : Integer;
    InfPointData : TPointData;      // array of point records
    Function CheckValid: Boolean;
    Constructor Load(ReadVersionNum: Double; TS: TStream; SS: Pointer);
    Procedure Save(var TS: TStream); overload;
    constructor Create(SS: Pointer);
    Destructor Destroy;  override;
    Procedure InitializePointVars;
    function CalcAllPointInfInundation: Boolean;
    procedure WritePointDBF(FirstWrite: Boolean; CountTS: integer);
End;

//--------------------------
// Definitions of road/infrasturcture data
//--------------------------


implementation

Uses SLR6, DrawGrid, SysUtils, Utility, ExcelFuncs, Forms, Controls, Dialogs, System.UITypes, Dbf_Fields, Dbf_Common, Progress;

Function InundText(I_F: Integer): String;
Begin
  Case I_F of
    0  : Result := 'not initialized';
    30 : Result := 'every 30 days';
    60 : Result := 'every 60 days';
    90 : Result := 'every 90 days';
    120 : Result := 'storm';
    150 : Result := 'large storm';
    252 : Result := 'irrelevant';
    253 : Result := 'Blank or Diked';
    254 : Result := 'Open Water';
    255 : Result := 'not inundated'
    else  Result := 'unknown';
  end; {case}
End;



Procedure TRoadInfrastructure.ReadRoadCSVFile(FN: string);
var
  TFile: Textfile;
  i, k,  RoadDataRow: integer;
  S: ANSIString;
  C: ANSIChar;
  ReadStr: String;
  SS: TSLAMM_Simulation;

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

begin
  MessageDlg('CSV File import Disabled',mterror,[mbok],0);
  Exit;

  SS := PSS;

  Assign(TFile,FN);
  Reset(TFile);

  TRY
  // Read first row to get the total number of rows
  ReadLn(TFile,ReadStr);
  Delete(ReadStr,Pos('total rows:,',LowerCase(ReadStr)),12);
  NRoads:=StrToInt(ReadStr);

  //Read how many road classes are present
  ReadLn(TFile,ReadStr);
  Delete(ReadStr,Pos('total road classes:,',LowerCase(ReadStr)),20);
  NRoadCl:=StrToInt(ReadStr);

  //Set the length of present road classes
  setlength(RoadClasses,NRoadCl);
  setlength(ProjRunStrArr,1);  // minimum to initialize, reset at start of model run

  //Set the length of the road data array
  setlength(RoadData,NRoads);

(*  //Set the length of the classes present
  for i := 0 to NRoads-1 do
    setlength(RoadData[i].LineLength,NRoadCl); *)

  //Set the length of InundFreq
  for i := 0 to NRoads-1 do
    Begin
      setlength(RoadData[i].InundFreq,1);  // minimum to initialize, reset at start of model run
      RoadData[i].InundFreq[0] := 255;  // initial value
    End;

  // Read the specific road classes present
  S:='';
  Repeat
  Read(TFile,C);
  If (C<>',') then S := S + C;
  Until ((S<>'') and (C=','));
  for i := 0 to NRoadCl-1 do
    RoadClasses[i] := trunc(GetNextCSVNumber(TFile));
  ReadLn(TFile);

  // Read the data header line
  ReadLn(TFile);

  //Read the data
  RoadDataRow :=0;
  while not eof(TFile) do
    begin
      RoadData[RoadDataRow].Row := trunc(GetNextCSVNumber(TFile));
      RoadData[RoadDataRow].Col := trunc(GetNextCSVNumber(TFile));
      RoadData[RoadDataRow].Elev := GetNextCSVNumber(TFile);  // even if user chooses not to read elevs...

      RoadData[RoadDataRow].LineLength := 0;
      for k := 0 to NRoadCl-1 do
        RoadData[RoadDataRow].LineLength := RoadData[RoadDataRow].LineLength+ GetNextCSVNumber(TFile);
      ReadLn(TFile);

{      with RoadData[RoadDataRow] do
        begin
          SS.RetA(Row,Col,ReadCell);            // Get the cell attributes
          ReadCell.RoadIndex := RoadDataRow;    // Assign the road index to the cell -- each set of roads starts 100,000 beyond the first
          SS.SetA(Row,Col,ReadCell);            // Set the cell value
        end; }

       RoadDataRow := RoadDataRow +1;        // Update the row to read
    end;

   FINALLY
      Closefile(TFile);  // jsc 9/30/2013
   END;

   RoadsLoaded := True;
   RoadsChanged := False;
end;

function TPointInfrastructure.CheckValid: Boolean;
begin
  Result := True;
  If NPoints = 0 then
    Begin
      MessageDlg('Error, Points Layer "'+IDName +'" has no attached roads data.',mterror,[mbok],0);
      Result := False;
      Exit;
    End;

  Result := inherited;
end;

constructor TPointInfrastructure.Create(SS: Pointer);
begin
  IDName := 'New Infr. Layer';
  HasSpecificElevs := False;
  infpointdata := nil;
  inherited Create(SS);
  Fields:= nil;
  ElevField:= nil;

end;

destructor TPointInfrastructure.Destroy;
begin
  infpointdata := nil;
  inherited;
end;

procedure TPointInfrastructure.InitializePointVars;
Var SS: TSLAMM_Simulation;
    i: Integer;
begin
  SS := PSS;

  setlength(ProjRunStrArr,SS.NTimeSteps);   // Set length of projection runs string array
  for i := 0 to NPoints-1 do
    Begin                //Set the length of InundFreq
       setlength(InfPointData[i].InundFreq,SS.NTimeSteps);
       InfPointData[i].omit := False;
    End;
end;

constructor TPointInfrastructure.Load(ReadVersionNum: Double; TS: TStream; SS: Pointer);
Var i: Integer;
begin
  TSRead('NPoints',NPoints);
  SetLength(InfPointData,NPoints);
  For i := 0 to NPoints-1 do
   With InfPointData[i] do
    Begin
      TSRead('Row',Row);
      If ReadVersionNum < 6.985 then
        Begin
          Inc(Row);  //5/15/2017 fix horizontal offset problem
        End;
      TSRead('Col',Col);
      TSRead('ShpIndex',ShpIndex);
      TSRead('Elev',Elev);
      If ReadVersionNum > 6.905
        then TSRead('Omit',Omit)
        else Omit := False;
      TSRead('InfPointClass',InfPointClass);
      SetLength(InundFreq,1) ;  // minimum length
      InundFreq[0] := 255;     // initial value
    End;

  inherited;
end;


procedure TPointInfrastructure.Save(var TS: TStream);
Var i: Integer;
begin
  TSWrite('NPoints',NPoints);
  For i := 0 to NPoints-1 do
   With InfPointData[i] do
    Begin
      TSWrite('Row',Row);
      TSWrite('Col',Col);
      TSWrite('ShpIndex',ShpIndex);
      TSWrite('Elev',Elev);
      TSWrite('Omit',Omit);
      TSWrite('InfPointClass',InfPointClass);
    End;

  inherited;
end;



function TInfrastructure.CalculateCellInundation(Row, Col: Integer): Byte;
//--------------------------------------------------------------------------------
// Calculate inundation frequency of the cell and assign it to InundFreq paramater
//--------------------------------------------------------------------------------
Var SS: TSLAMM_Simulation;
    ArrByte: Byte;
begin
  SS := PSS;
  //Assign Inundation Frequency values
  Result := 255;
  ArrByte := SS.Inund_Arr[(SS.Site.RunCols*Row)+Col];
  if ArrByte in [0,30,60,90,120,150] then
    Result := ArrByte
  else if ArrByte=8 then
    Result := 30 //Below MTL and connected assigned to 30 d inundation
  else if ArrByte=7 then
    Result :=253 //Blank or diked
  else if ArrByte=5 then
    Result :=252;  // irrelevant
end;


function TInfrastructure.UpdateInundFreq:Boolean;
Var SS: TSLAMM_Simulation;
Begin
  Result := True;
  SS := PSS;
  //If inundation frequency not yet calculated ...
  if not SS.InundFreqCheck  then
    begin
      Result := SS.Calc_Inund_Freq;
      If Not Result then SS.Inund_Arr := nil;
      SS.InundFreqCheck := Result;
    end;
End;


function TInfrastructure.CheckValid: Boolean;
Var dbfname: String;
begin
  Result := True;
  dbfname := ChangeFileExt(InputFName,'.dbf');

  While Not FileExists(dbfname) do
    Begin
      if not PromptForFileName(dbfname,'dbf files (*.dbf)|*.dbf','.dbf',ExtractFileName(dbfname)+' does not exist, please locate this dbf file.',
                               ExtractFilePath(dbfname),false)
        then
          Begin
            MessageDlg('Error, Data File for Infrastructure Layer "'+IDName +'" does not exist. ('+InputFName+')',mterror,[mbok],0);
            Result := False;
            Exit;
          End;
      InputFName := dbfname;
    End;
end;

constructor TInfrastructure.Create(SS: Pointer);
begin
  PSS := SS;
  SetLength(ProjRunStrArr,1);  // minimum array size
end;

destructor TInfrastructure.Destroy;
begin
  ProjRunStrArr := nil;
  inherited;
end;

constructor TInfrastructure.Load(ReadVersionNum: Double; TS: TStream; SS: Pointer);
begin
  PSS := SS;
  TSRead('InputFName',InputFName,ReadVersionNum);
  TSRead('IDName',IDName,ReadVersionNum);

  HasSpecificElevs := False;
 If ReadVersionNum > 6.895 then TSRead('HasElevs',HasSpecificElevs)
                           else  HasSpecificElevs := True;

  SetLength(ProjRunStrArr,1);  // minimum array size
end;

procedure TInfrastructure.Save(var TS: TStream);
begin
  TSWrite('InputFName',InputFName);
  TSWrite('IDName',IDName);
  TSWrite('HasElevs',HasSpecificElevs)
end;

function TRoadInfrastructure.CheckValid: Boolean;
begin
  Result := True;
  If NRoads = 0 then
    Begin
      MessageDlg('Error, Roads Layer "'+IDName +'" has no attached roads data.',mterror,[mbok],0);
      Result := False;
      Exit;
    End;

  result := inherited;
end;

constructor TRoadInfrastructure.Create(SS: Pointer);
begin
  IDName := 'New Roads Layer';
  inherited Create(SS);  // inherited
  RoadsLoaded := False;
  RoadsChanged := False;
end;

procedure TInfrastructure.CreateOutputDBF;
Var  SS: TSLAMM_Simulation;

   Procedure CopyExt(Ext:String);
   Begin
     If FileExists(ChangeFileExt(InputFName,Ext)) then
       CopyFile(ChangeFileExt(InputFName,Ext),ChangeFileExt(OutputFName,Ext));
   End;

begin
  SS := PSS;
  With SS do
    If (RunUncertainty or RunSensitivity) then exit; // no infrastructure output for uncertainty / sensitivity at this time

  OutputFName := ChangeFileExt(InputFName,'');
  OutputFName := OutputFName + '_'+SS.RunTime+ '.dbf';
  CopyFile(ChangeFileExt(InputFName,'.dbf'),OutputFName);

      With SS do
      If not (RunUncertainty or RunSensitivity) then  // separate logs exist for uncertainty & sensitivity runs.
      Try
        Append(RunRecordFile);
        SummarizeFileInfo('Output DBF Written',OutputFName);
        Closefile(RunRecordFile);
      Except
        MessageDlg('Error appending to Run-Record File '+RunRecordFileName,mterror,[mbOK],0);
      End;

  CopyExt('.shp');
  CopyExt('.shx');
  CopyExt('.prj');
  CopyExt('.qpj');
end;

destructor TRoadInfrastructure.Destroy;
Var i: Integer;
begin
  for i := 0 to NRoads-1 do
    Begin
      RoadData[i].InundFreq := nil;
      RoadData[i].OutSites.Free;
    End;

  RoadClasses := nil;
  RoadData := nil;
end;

function TRoadInfrastructure.CalcAllRoadsInundation: Boolean;
//-----------------------------------------------
// Calculate Inundation frequencies for all roads
//-----------------------------------------------
var
  inund: Byte;
  i: integer;
  SS: TSLAMM_Simulation;
begin
  SS := PSS;
  Result := UpdateInundFreq;

  ProjRunStrArr[SS.TStepIter] := SS.ShortProjRun;
  If Result then
   for i := 0 to NRoads-1 do
    Begin
      inund := CalculateCellInundation(RoadData[i].Row, RoadData[i].Col);
      RoadData[i].InundFreq[SS.TStepIter] := inund;
      If SS.TimeZero and (inund=30) then RoadData[i].Omit := True;
    End;

end;

function TPointInfrastructure.CalcAllPointInfInundation: Boolean;
//---------------------------------------------------------
// Calculate inundation frequencies for all point elements
//---------------------------------------------------------
var
  i: integer;
  inund: Byte;
  SS: TSLAMM_Simulation;
begin
  SS := PSS;
  Result := UpdateInundFreq;
  If not Result then Exit;

  ProjRunStrArr[SS.TStepIter] := SS.ShortProjRun;  // 7/7/2016
  for i := 0 to NPoints-1 do
    Begin
      inund := CalculateCellInundation(InfPointData[i].Row, InfPointData[i].Col);
      InfPointData[i].InundFreq[SS.TStepIter] := inund;
      If SS.TimeZero and (inund=30) then
          InfPointData[i].Omit := True;
    End;

  Result := True;
end;

procedure TRoadInfrastructure.SaveData(var TS: TStream);
Var i: Integer;
Begin

  Try
    ProgForm.ProgressLabel.Caption := 'Saving Roads';
    ProgForm.Show;

    TSWrite('NRoads',NRoads);
    For i := 0 to NRoads-1 do
     With RoadData[i] do
      Begin
        ProgForm.Update2Gages(Trunc(100*i/(NRoads-1)),0);
        TSWrite('Row',Row);
        TSWrite('Col',Col);
        TSWrite('ShpIndex',ShpIndex);
        TSWrite('RoadClass',RoadClass);
        TSWrite('Elev',Elev);
        TSWrite('Omit',Omit);
        TSWrite('LineLength',LineLength);
      End;

  Finally
    ProgForm.Cleanup;
  End;
  RoadsChanged := False;
End;

procedure TRoadInfrastructure.Save(var TS: TStream);
Var i: Integer;
begin
  TSWrite('NRoadCl',NRoadCl);
  For i := 0 to NRoadCl-1 do
    TSWrite('Roadclasses[i]',Roadclasses[i]);

  SaveData(TS); // option -- no longer save as part of SLAMM6 file?

  inherited;
end;

{ procedure TRoadInfrastructure.SetRoadIndices;  // set cellrec-road indexes
Var i: Integer;
    ReadCell: CompressedCell;

begin
  For i := 0 to NRoads-1 do
    With RoadData[i] do
     With TSLAMM_Simulation(PSS) do
        Begin
          RetA(Row,Col,ReadCell);                  // Get the cell attributes
          ReadCell.RoadIndex := i;                 // Assign the road index to the cell
          SetA(Row,Col,ReadCell);                  // Set the cell value
        End;
end; }

procedure TRoadInfrastructure.InitializeRoadVars;
Var SS: TSLAMM_Simulation;
    i, iOS, rOS, RoadRow, RoadCol: Integer;
begin
  SS := PSS;

  setlength(ProjRunStrArr,SS.NTimeSteps);   // Set length of projection runs string array
  for i := 0 to NRoads-1 do                   //Set the length of InundFreq
    Begin
      setlength(RoadData[i].InundFreq,SS.NTimeSteps);
      RoadData[i].Omit := False;
      RoadData[i].Outsites := TBits.Create;
      RoadData[i].Outsites.Size := SS.Site.NOutputSites+SS.Site.MaxROS+1;

      RoadRow := RoadData[i].Row;
      RoadCol := RoadData[i].Col;
      With SS do
       Begin
        RoadData[i].OutSites[0] := In_Area_to_Save(RoadCol,RoadRow,not SS.SaveROSArea);
        for iOS := 1 to Site.NOutputSites do
            RoadData[i].Outsites[iOS] := ((Site.InOutSite(RoadCol,RoadRow,iOS)));  // assign roads to output sites
        if ROSArray<>nil then
          for rOS := 1 to Site.MaxROS do
            RoadData[i].Outsites[rOS+Site.NOutputSites] := (rOS=ROSArray[(Site.RunCols*RoadRow)+RoadCol]); // assign road objects to ROS sites
       End;  // with SS
    End;
end;

procedure TRoadInfrastructure.LoadData(ReadVersionNum: Double; TS: TStream; SS:Pointer);
Var i: Integer;
begin
  Try
   TSRead('NRoads',NRoads);

   ProgForm.Setup('Reading Roads','','','',False);

   SetLength(RoadData,NRoads);
   For i := 0 to NRoads-1 do
   With RoadData[i] do
    Begin
       ProgForm.Update2Gages(Trunc(100*i/(NRoads-1)),0);
      TSRead('Row',Row);
      If ReadVersionNum < 6.955 then
        Begin
          Inc(Row);  //5/15/2017 fix horizontal offset problem
        End;

      TSRead('Col',Col);
      TSRead('ShpIndex',ShpIndex);
      TSRead('RoadClass',RoadClass);
      TSRead('Elev',Elev);
      If ReadVersionNum > 6.905
        then TSRead('Omit',Omit)
        else Omit := False;
      TSRead('LineLength',LineLength);

      setlength(InundFreq,1);  // minimum to initialize, reset at start of a model run
      InundFreq[0] := 255;     // initial value
    End;

   RoadsLoaded := True;
   RoadsChanged := False;


  Finally
   ProgForm.Cleanup;
  End;
End;


constructor TRoadInfrastructure.Load(ReadVersionNum: Double; TS: TStream; SS:Pointer);
Var i: Integer;
begin
  TSRead('NRoadCl',NRoadCl);
  SetLength(Roadclasses,NRoadCl);
  For i := 0 to NRoadCl-1 do
    TSRead('Roadclasses[i]',Roadclasses[i]);

  RoadData := nil;
  LoadData(ReadVersionNum,TS,SS);  // option -- no longer save as part of SLAMM6 file?

  inherited;
end;

procedure TRoadInfrastructure.Overwrite_Elevs;
var   CC: Integer;
      NAVDCorr: Double;
      ReadCell: CompressedCell;
      i: Integer;
      SS: TSLAMM_Simulation;
Begin
  If HasSpecificElevs then
    MessageDlg('Overwriting elevations disabled',mterror,[mbok],0);

  Exit;

(*
  SS := PSS;

  If HasSpecificElevs then
   For i := 0 to NRoads-1 do
    With RoadData[i] do
      Begin
        SS.RetA(Row,Col,ReadCell);            // Get the cell attributes
        CC := GetCellCat(@ReadCell);          // Get cell category
        NAVDCorr := ReadCell.MTLminusNAVD;
        if Elev > -999 then   //handle no-data
            SetCatElev(@ReadCell,CC, Elev-NAVDCorr); //Set elevation -- Road Inputs required in NAVD88 format Correct to MTL basis
        SS.SetA(Row,Col,ReadCell);            // Set the cell value
      End;           *)
end;

Procedure TRoadInfrastructure.UpdateRoadSums(CountProj: integer; var RoadOutSum: Array of RoadArray; NOutSites: Integer);
//=================================================================================
// Update of the numerical data of road inundation for a given output
// 0 := 'km roads';
// 1 := 'km roads H1';  value: 30
// 2 := 'km roads H2';  value: 60
// 3 := 'km roads H3';  value: 90
// 3 := 'km roads H3';  value: 90
// 4 := 'km roads H4';  value: 120
// 5 := 'km roads H5';  value: 150
// 6 := 'km roads >H5'; value: 255
// 7 := 'below OW & connected'; value: 0
// 8 := 'open water'; value:254
// 9 := 'blank or diked'; value:253
// 10 := 'irrelevant'; value:252
//=================================================================================

var
  RdIndex, Oi: integer;
begin

 For Oi := 0 to NOutSites-1 do
  For RdIndex := 0 to NRoads - 1 do
   If (RoadData[RdIndex].LineLength>0) and (RoadData[RdIndex].OutSites[Oi]) then
    begin
      // Total km of roads
      RoadOutSum[Oi,0] := RoadOutSum[Oi,0] + RoadData[RdIndex].LineLength/1000;

      //H1 elev inundation (e.g. 30 d)
      if RoadData[RdIndex].InundFreq[CountProj]=30 then
        RoadOutSum[Oi,1] := RoadOutSum[Oi,1] + RoadData[RdIndex].LineLength/1000

      //H2 elev inundation  (e.g. 60 d)
      else if RoadData[RdIndex].InundFreq[CountProj]=60 then
        RoadOutSum[Oi,2] := RoadOutSum[Oi,2] + RoadData[RdIndex].LineLength/1000

      //H3 elev inundation (e.g. 90 d)
      else if RoadData[RdIndex].InundFreq[CountProj]=90 then
        RoadOutSum[Oi,3] := RoadOutSum[Oi,3] + RoadData[RdIndex].LineLength/1000

      //H4 elev inundation (e.g. storm 1)
      else if RoadData[RdIndex].InundFreq[CountProj]=120 then
        RoadOutSum[Oi,4] := RoadOutSum[Oi,4] + RoadData[RdIndex].LineLength/1000

      //H5 elev inundation (e.g. storm 2)
      else if RoadData[RdIndex].InundFreq[CountProj]=150 then
        RoadOutSum[Oi,5] := RoadOutSum[Oi,5] + RoadData[RdIndex].LineLength/1000

      //>H5 elev inundation
      else if RoadData[RdIndex].InundFreq[CountProj]=255 then
        RoadOutSum[Oi,6] := RoadOutSum[Oi,6] + RoadData[RdIndex].LineLength/1000

      //Below open water and connected
      else if RoadData[RdIndex].InundFreq[CountProj]=0 then
        RoadOutSum[Oi,7] := RoadOutSum[Oi,7] + RoadData[RdIndex].LineLength/1000

      //Open water
      else if RoadData[RdIndex].InundFreq[CountProj]=254 then
        RoadOutSum[Oi,8] := RoadOutSum[Oi,8] + RoadData[RdIndex].LineLength/1000

      //Blank or diked
      else if RoadData[RdIndex].InundFreq[CountProj]=253 then
        RoadOutSum[Oi,9] := RoadOutSum[Oi,9] + RoadData[RdIndex].LineLength/1000

      //Irrelevant
      else
        RoadOutSum[Oi,10] := RoadOutSum[Oi,10] + RoadData[RdIndex].LineLength/1000;
    end;
end;



procedure TRoadInfrastructure.WriteRoadDbf(FirstWrite: Boolean; CountTS: integer);
var i,k: Integer;
    DBF1: TDBF;
    Appending, WriteElevs: Boolean;

begin
  With TSLAMM_Simulation(PSS) do
    If (RunUncertainty or RunSensitivity) then exit; // no infrastructure output for uncertainty / sensitivity at this time

  AddDBFFields(FirstWrite,CountTS, DBF1,WriteElevs);

  Appending := DBF1.RecordCount = 0;
  DBF1.First;
  for i := 0 to NRoads-1 do
    Begin
      If Appending then DBF1.Append
                   else DBF1.Edit;
      If writeelevs then ElevField.AsFloat := RoadData[i].Elev;
      For k := 1 to CountTS-1  do  // 3/2/2016 don't output initial condition
       with RoadData[i] do
         Begin
           If Omit then Fields[k].AsInteger := -99
                   else Fields[k].AsInteger := InundFreq[k];
         End;
      DBF1.Post;
      DBF1.Next;
    End;

   fields := nil;
   elevfield := nil;
   DBF1.Close;
end;

procedure TPointInfrastructure.WritePointDBF(FirstWrite: Boolean; CountTS: integer);
var i,k: Integer;
    DBF1: TDBF;
    Appending, WriteElevs: Boolean;

begin
  With TSLAMM_Simulation(PSS) do
    If (RunUncertainty or RunSensitivity) then exit; // no infrastructure output for uncertainty / sensitivity at this time

  AddDBFFields(FirstWrite,CountTS, DBF1,WriteElevs);

  Appending := DBF1.RecordCount = 0;
  DBF1.First;
  for i := 0 to NPoints-1 do
    Begin
      If Appending then DBF1.Append
                   else DBF1.Edit;
      If writeelevs then ElevField.AsFloat := InfPointData[i].Elev;
      For k := 1 to CountTS-1  do    // 3/2/2016 don't output initial condition
       with InfPointData[i] do
         Begin
           If Omit then Fields[k].AsInteger := -99
                   else Fields[k].AsInteger := InundFreq[k];
         End;
      DBF1.Post;
      DBF1.Next;
    End;

   fields := nil;
   ElevField := nil;
   DBF1.Close;
end;

Procedure TInfrastructure.AddDBFFields(FirstWrite: Boolean; CountTS: Integer; Var DBF1: TDBF; Var WriteElevs: Boolean);
Var TempFieldDefs: TDbfFieldDefs;
    k, initfields: Integer;
    NewFieldDef: TDbfFieldDef;

Begin

  If not FileExists(OutputFName) then
    Begin
      MessageDlg('Error:  DBF File '+OutputFName+' does not exist',mterror,[mbok],0);
      Exit;
    End;

  WriteElevs := False; // FirstWrite and HasSpecificElevs;

  DBF1 := TDBF.Create(nil);
  DBF1.TableName := OutputFName;

  DBF1.Open;
  DBF1.Active := True;

  TempFieldDefs := TDBFFieldDefs.Create(DBF1);
  TempFieldDefs.Assign (Dbf1.DbfFieldDefs);
  InitFields := TempFieldDefs.Count;

  If WriteElevs then
    Begin
      NewFieldDef := TempFieldDefs.AddFieldDef;
      With NewFieldDef do
         begin
          FieldName := 'Elev MTL';
          NativeFieldType := 'N';
          Size := 6;
          Precision := 3;
        end;
    End;

  SetLength(Fields,CountTS);
  for k := 1 to CountTS-1  do   // 3/2/2016 don't output initial condition
    Begin
      NewFieldDef := TempFieldDefs.AddFieldDef;
        With NewFieldDef do
           begin
            FieldName := Ansistring(ProjRunStrArr[k]);
            NativeFieldType := 'N';
            Size := 3;
            Precision := 0;
          end;
    End;

   DBF1.Active := False;;
   DBF1.RestructureTable(TempFieldDefs, True);
   DBF1.Active := True;

 // point to fields
  ElevField := nil;
  if writeelevs then
    Begin
      ElevField := DBF1.Fields[InitFields];
      Inc(InitFields);
    End;
  for k := 1 to CountTS-1  do   // 3/2/2016 don't output initial condition
    Fields[k] := DBF1.Fields[InitFields+k-1];
End;

end.

