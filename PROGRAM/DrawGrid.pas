//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit DrawGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Math,
  StdCtrls, ExtCtrls, jpeg, ComCtrls, System.Types, GLOBAL, UTILITY, ImgList, ToolWin, Profile,
  Progress, ClipBrd, ShellAPI, SLR6, GLDraw, {Gauges,} Buttons, Binary_Files,
  GISReadWrite, Infr_Data, Data.DB, dbf, Vcl.Samples.Gauges;

CONST
  PixelCountMax = 32768;

TYPE
  pRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = ARRAY[0..PixelCountMax-1] OF TRGBTriple;
  InfLoc = Record
             Ind: Byte;
             Loc: Integer;
           End;

  TLocs = Array of InfLoc;  // keep track of which infrastructure data is where

type
  TGridForm = class(TForm)
    ScrollBox1: TScrollBox;
    Image1: TImage;
    Memo1: TMemo;
    RunPanel: TPanel;
    ProgressLabel: TLabel;
    Button1: TButton;
    YearLabel: TLabel;
    SLRLabel: TLabel;
    ProtectionLabel: TLabel;
    xlabel2: TLabel;
    ylabel2: TLabel;
    DepthLabel: TLabel;
    CategoryLabel: TLabel;
    PageControl1: TPageControl;
    SubsiteEditSheet: TTabSheet;
    AttribPanel: TPanel;
    EstNameCapt: TLabel;
    BoundaryWarning: TLabel;
    PointWarning: TLabel;
    Label1: TLabel;
    ShowSel: TRadioButton;
    ShowCells: TRadioButton;
    EditBox: TComboBox;
    DeleteEst: TButton;
    AddEst: TButton;
    DefineBound: TButton;
    DefineVector: TButton;
    NameEdit: TEdit;
    Panel2: TPanel;
    ShowAll: TRadioButton;
    Panel3: TPanel;
    Panel1: TPanel;
    Panel4: TPanel;
    Zoombox2: TComboBox;
    SubsiteParmButt: TButton;
    FWFlowButton: TButton;
    helpFileAttrib: TBitBtn;
    FWExtentOnly: TCheckBox;
    CopyClip1: TButton;
    SaveSim1: TButton;
    AnalysisSheet: TTabSheet;
    Panel11: TPanel;
    MapTitle: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    DotSizeLabel: TLabel;
    SalAnalysis2: TButton;
    DotSizeBox: TComboBox;
    HelpButton: TBitBtn;
    ShowDikes: TCheckBox;
    GraphBox: TComboBox;
    ROSPanel: TPanel;
    ROSLabel: TLabel;
    ROSButton: TButton;
    ElevationButton: TButton;
    NextStepButton: TButton;
    StopPausingButton: TButton;
    ZoomBox: TComboBox;
    HaltButton: TButton;
    ViewLegButt: TButton;
    ToolPanel: TPanel;
    StatLabel: TLabel;
    ToolBox1: TComboBox;
    PanCheckBox: TCheckBox;
    CopyClip2: TButton;
    SaveSim2: TButton;
    TabSheet1: TTabSheet;
    Panel12: TPanel;
    PenWidthLabel: TLabel;
    MapTitle2: TLabel;
    Label5: TLabel;
    DrawCellsButt: TButton;
    FillCellsButt: TButton;
    PenWidthBox: TComboBox;
    ShowDikes2: TCheckBox;
    CategoryBox: TComboBox;
    FillDikesBox: TCheckBox;
    FillNoDikesBox: TCheckBox;
    CheckBox2: TCheckBox;
    PolyCells: TButton;
    SaveSim3: TButton;
    FillDryLandButton: TButton;
    DoneDrawingButton: TButton;
    ZoomBox3: TComboBox;
    BitBtn3: TBitBtn;
    Panel5: TPanel;
    CopyClip3: TButton;
    Panel6: TPanel;
    WPCUtilitiesSheet: TTabSheet;
    Panel7: TPanel;
    SaveSubsitesButton: TButton;
    Button4: TButton;
    SaveInundationRaster: TButton;
    SaveWetlandRaster: TButton;
    SaveElevationRaster: TButton;
    SaveAs1: TButton;
    SaveAs2: TButton;
    SaveAs3: TButton;
    Mang2TransButton: TButton;
    DrawDikeSquare: TButton;
    Button2: TButton;
    InputBox: TComboBox;
    ImportShp: TButton;
    OpenDialog1: TOpenDialog;
    SVOGISReadWrite1: TSVOGISReadWrite;
    CalcInundation: TButton;
    InfDotSizeLabel: TLabel;
    InfDotSizeBox: TComboBox;
    SVOGISReadWrite2: TSVOGISReadWrite;
    SaveDialog1: TSaveDialog;
    OmitT030: TButton;
    LoadSHPButton: TButton;
    ExtractDataShpButton: TButton;
    Gauge1: TGauge;
    ErodePanel: TPanel;
    EditAlpha: TButton;
    CalcWaveErosion: TButton;
    EditWinds: TButton;
    procedure ViewLegButtClick(Sender: TObject);
    procedure HaltButtonClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HideMapButtonClick(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CopyMapToClipboard(Sender: TObject);
    procedure Memo1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ShowDikesClick(Sender: TObject);
    procedure ZoomBoxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AddEstClick(Sender: TObject);
    procedure DeleteEstClick(Sender: TObject);
    procedure DefineBoundClick(Sender: TObject);
    procedure DefineVectorClick(Sender: TObject);
    procedure EditBoxChange(Sender: TObject);
    procedure NameEditChange(Sender: TObject);
    procedure NameEditExit(Sender: TObject);
    procedure ShowCellsClick(Sender: TObject);
    procedure ShowSelClick(Sender: TObject);
    procedure DrawCellsButtClick(Sender: TObject);
    procedure FillCellsButtClick(Sender: TObject);
    procedure DefEstClick(Sender: TObject);
    procedure SubsiteParmButtClick(Sender: TObject);
    procedure ROSButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FillDikesBoxClick(Sender: TObject);
    procedure TabChangeClick(Sender: TObject);
    procedure ElevationButtonClick(Sender: TObject);
    procedure FWFlowButtonClick(Sender: TObject);
    procedure GraphBoxChange(Sender: TObject);
    procedure NextStepButtonClick(Sender: TObject);
    procedure FillNoDikesBoxClick(Sender: TObject);
    procedure helpFileAttribClick(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure FWExtentOnlyClick(Sender: TObject);
    procedure PolyCellsClick(Sender: TObject);
    procedure DoneDrawingButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure MapSaveSimulationButtonClick(Sender: TObject);
    procedure FillDryLandButtonClick(Sender: TObject);
    procedure MangtoTransButtonClick(Sender: TObject);
    procedure MarshBordersButtonClick(Sender: TObject);
    procedure SalAnalysis2Click(Sender: TObject);
    procedure SaveSubsiteRasterClick(Sender: TObject);
    procedure SaveWetlandRasterClick(Sender: TObject);
    procedure SaveElevationRasterClick(Sender: TObject);
    procedure SaveInundationButtonClick(Sender: TObject);
    procedure StopPausingButtonClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure PanCheckBoxClick(Sender: TObject);
    procedure ScrollBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DrawDikeSquareClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ImportShpClick(Sender: TObject);
    procedure CalcInundationClick(Sender: TObject);
    procedure SVOGISReadWrite1Progress(Sender: TObject; Stage: TProgressStage;
      PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string);
    procedure OmitT030Click(Sender: TObject);
    procedure LoadSHPButtonClick(Sender: TObject);
    procedure ExtractDataShpButtonClick(Sender: TObject);
    function Get_UncertResults_Param(var BaseFileName, BaseExt, BaseDir: string; var NumIter, N_GISYears, TimeZero: integer; var GISYrArray: array of integer): Boolean;
    procedure EditWindsClick(Sender: TObject);
    procedure EditAlphaClick(Sender: TObject);
    procedure CalcWaveErosionClick(Sender: TObject);
  private
    { Private declarations }
    EditIndex,aX,aY,zX,zY,wd,ht : integer;
    Row: pRGBTripleArray;
    Bitstream: TMemoryStream;
    Updating, FillDikes, FillNoDikes: Boolean;
    SRow, SCol, ERow, ECol: Integer;
    FLastDown: TPoint;
    Procedure Graph3D;
  public
    DontDraw: Boolean;
    SaveBtStream: Boolean;
    SS: TSLAMM_Simulation;
    SlpFileN: String;
    DrawingRect : Boolean;
    DefiningBoundary, DefiningVector,GettingDikeElevs: Boolean;
    DikeX1,DikeX2,DikeY1,DikeY2: Integer;
    PolyingCells, DrawingCells, FillingCells, FillCategory: Boolean;
    DikesChanged, NWIChanged: Boolean;
    IsVisible: Boolean;
    LastRow, Rows, Cols, MapNR,MapNC: Integer;
    ZoomFactor: Double;
    FILLCAT : Integer;
    GridScale: Double;
    ThisSite: TSite;
    NextOriginX, NextOriginY: Integer;
    ROSShowing: Integer;
    DisposeWhenClosed: Boolean;
    DrawingTopLayer: Boolean;
    PolyPoints: TPointArray;
    DotSizeBoxIndex, NumPolyPts: Integer;
    ShowRoadOld: boolean;
    PointLocs: TLocs;
    RoadLocs : TLocs;
    RoadIndex, PointIndex: Integer;
    Function CellClass(CellX,CellY: Integer): Integer;
    Function GetBoundaryCoordinates(HeadPoint, TailPoint: DPoint): DBoundary;
    Procedure LineSegmentLengthPerCell(HeadPoint, TailPoint: DPoint; PIntPtArr: PPointArray; PNIntPt: PInteger);
    Procedure DrawBound(Var TPoly: TPolygon);
    procedure ImportRoadClick;
    Procedure ShowRoadInundation;
    //function ShowDikesOrConnect(ShowConnect:Boolean): Boolean;
    function CalculateConnect: Boolean;
    function CalculateInundFreq(var SS: TSLAMM_Simulation): Boolean;
    Function ZF_From_Screen: Double;
    procedure ShowRunPanel;
    Function CategoryFromComboBox: Integer;
    Procedure FillCategoryBox;
    Procedure UpdateEditBox;
    Procedure ShowEditItems;
    Procedure ShowDikeStats;
    Procedure ClearRoadLocs;
    Procedure DrawCell(Cl: PCompressedCell; ER,EC, DrawRow, DrawCol: Integer; Cat: Integer; Diked,IsROS,Optim: Boolean; GBII: Integer);
    Procedure EditAttributes(NR,NC: Integer; TSS: TSLAMM_Simulation);
    Procedure DrawArrow(P1,P2: TPoint);
    Procedure DrawVector;
    Procedure DrawBoundary(IsEst: Boolean);
{    Procedure DrawSubsites; }
    Procedure DrawOutputsites;
    Procedure DrawPointInf;
    Procedure HighlightCells;
    Function DrawEntireMap(OutSite: Integer; ShowProg, ROS: Boolean): Boolean;
    Function ShowMap(NR,NC: Integer; Var Site: TSite; TSS: TSLAMM_Simulation): Boolean;
    Function ZF(i: Integer): Integer;
    Function GetMinElev(Cl: PCompressedCell; ER,EC: Integer): Double;
    Procedure SaveBitstream;
    Procedure LoadBitstream;
    Procedure SaveMapToGIF(Var FileN: String);
    Procedure ChangeCellType(CL: PCompressedCell; OldCat,NewCat: Integer);

    { Public declarations }
  end;

var
  GridForm: TGridForm;


implementation

uses Variants, SLAMMLegend, Legend2, RoadInundLegend, SiteEdits, Elev_Analysis, FWFlowEdits, System.Generics.Collections, System.UITypes, Uncert, GIFImg, main, FFForm, Stack, TeCanvas,
      Infr_Form, GISShape, DataFields, DynamicArrayUnit, SelectListUnit, Dbf_Fields, Dbf_Common, StrUtils, Categories,
  WindRose;

{$R *.DFM}

Var DMMTShapeList : TSVOShapeList;

FUNCTION TGridForm.CellClass(CellX,CellY: Integer): Integer;
Var Cl: CompressedCell;
Begin
  SS.RetA(CellY, CellX,Cl);
  Result := GetCellCat(@Cl);
End;


procedure TGridForm.ClearRoadLocs;
Var i: Integer;
Begin
  For i := 0 to Image1.Picture.Width*Image1.Picture.Height -1 do
    RoadLocs[i].Loc := -1;
End;

procedure TGridForm.SalAnalysis2Click(Sender: TObject);
begin
  SalinityForm.MapLoaded := True;
  SalinityForm.SS := SS;
  Salinityform.ShowSalinityAnalysis;
  ProgForm.Cleanup;
  Salinityform.Showmodal;
end;



Procedure TGridForm.SaveBitStream;
begin
  if Not SaveBtStream then Exit;
  if Bitstream <> nil then
     Bitstream.free;
  BitStream := TMemoryStream.Create;
  Image1.Picture.Bitmap.SaveToStream(BitStream);
end;

Procedure TGridForm.LoadBitStream;
Begin
  if Not SaveBtStream then Exit;
  If (Bitstream=nil) then Exit;
  BitStream.Position := 0;
  Image1.Picture.Bitmap.LoadFromStream(BitStream);
End;


{----------------------------------------------------------------------------------------------------}

Function TGridForm.GetMinElev(Cl: PCompressedCell; ER,EC: Integer): Double;
Var MnElev: Double;
    i: Integer;
    MinCat: Integer;
Begin
  if Large_Raster_Edit then
    Begin  GetMinElev := (SS.DataElev[(SS.Site.RunCols*ER)+EC] / 1000)-10; Exit;  End;  // Use_DataElev relevant for all classes in Large_Raster_Edit mode

  MnElev := 9999999;
  MinCat := -99;
  For i := 1 to NUM_CAT_COMPRESS do
    If (CL.MinElevs[i]<MnElev) and (Cl.Widths[i] > 0) then
      Begin
        MnElev := CL.Minelevs[i];
        MinCat := CL.Cats[i];
      End;
  GetMinElev := MnElev;

  If USE_DATAELEV and (SS.OptimizeLevel > 1) then
//   if MinCat in [DevDryLand, UndDryLand] then   Use_DataElev only relevant for these classes in optimization mode
     if MnElev = ELEV_CUTOFF then
        GetMinElev := (SS.DataElev[(SS.Site.RunCols*ER)+EC] / 1000)-10;

End;

{----------------------------------------------------------------------------------------------------}

Function TGridForm.ZF(i: Integer): Integer;
Begin
  ZF := Trunc(i*ZoomFactor);
End;

Function ElevCol(Height: Double): TColor;
Begin
    if Height < -2 then                          result:= $00660000 else
    if (Height >= -2) and (Height < -1.5) then   result:= $00666600 else
    if (Height >= -1.5) and (Height < -1.0) then result:= $00667700 else
    if (Height >= -1) and (Height < -0.5) then   result:= $00668800 else
    if (Height >= -0.5) and (Height < 0) then    result:= $00669900 else
    if (Height >= 0) and (Height < 0.5) then     result:= $0066AA00 else
    if (Height >= 0.5) and (Height < 1) then     result:= $0066BB00 else
    if (Height >= 1) and (Height < 1.5) then     result:= $0066CC00 else
    if (Height >= 1.5) and (Height < 2) then     result:= $0066DD00 else
    if (Height >= 2) and (Height < 2.5) then     result:= $0066EE00 else
    if (Height >= 2.5) and (Height < 3) then     result:= $0066FF00 else
    if (Height >= 3) and (Height < 3.5) then     result:= $0066FF11 else
    if (Height >= 3.5) and (Height < 4) then     result:= $0066FF22 else
    if (Height >= 4) and (Height < 4.5) then     result:= $0066FF33 else
    if (Height >= 4.5) and (Height < 5) then     result:= $0066FF44 else
    if (Height >= 5) and (Height < 5.5) then     result:= $0066FF55 else
    if (Height >= 5.5) and (Height < 6) then     result:= $0066FF66 else
    if (Height >= 6) and (Height < 6.5) then     result:= $0066FF77 else
    if (Height >= 6.5) and (Height < 7) then     result:= $0066FF88
    else {if Height > 7  then }                  result:= $0066FF99;

    If height = 999 then result := clWhite;
End;

{----------------------------------------------------------------------------------------------------}

Procedure TGridForm.DrawCell(Cl: PCompressedCell; ER,EC, DrawRow, DrawCol: Integer; Cat: Integer; Diked,IsROS,Optim: Boolean; GBII: Integer);
Var ColorNeutral: Boolean;
Const TRGBWhite: TRGBTriple = (rgbtBlue:255;rgbtGreen:255;rgbtRed:255;);

    // Neutral Colors
    Function NeutralColors(watercol: TColor): TColor;
    Var TC: TCategory;
    Begin
       TC :=SS.Categories.GetCat(Cat);
       If Cat= Blank then Result := clWhite else
       If TC.IsDeveloped then Result := $00004200 else
       If TC.IsOpenWater then Result := watercol
                         else Result := $00006400;
    End;

    // Salinity colors
    Function SalColor(lev: integer): Tcolor;
    var
      sal: double;
    begin
      LegendForm.GMin := 0;
      LegendForm.GMax := 30;
      Sal := Cl.Sal[lev];
      //If Sal<0 then Result := NeutralColors(clblack)
      If Sal<0 then Result := NeutralColors(ClBlue)        //  Marco - Modified for road maps
              // else If Sal=30 then Result := SS.GridColors[OpenOcean]
               else Result := ColorGradient(0,30,Sal);
    end;

    // Subsidence colors
    Function SubsidenceColor(ER,EC: integer): Tcolor;
    var
      Subsd: double;
      TSub : TSubSite;

    begin
      LegendForm.GMin := -5;
      LegendForm.GMax := 15;

      TSub := ThisSite.GetSubSite(EC,ER,Cl);
      If (SS.UpliftFileN='') then Subsd := TSub.Historic_Trend - TSub.Historic_Eustatic_trend {estimate based on historic local gauge and historic eustatic trend over the same period}
                             else Subsd := -(Cl.Uplift * 10);  {cm/year  *  mm/cm}

      If Subsd<-5 then Subsd := -5 ;
      If Subsd>15 then Subsd := 15 ;

      Result := ColorGradient(-5,15,Subsd);
    end;

    // MTL NAVD Colors
    Function MTLNAVDColor(ER,EC: integer): Tcolor;
    begin
      LegendForm.GMin := SS.MinMTL;
      LegendForm.GMax := SS.MaxMTL;
      Result := ColorGradient(SS.MinMTL,SS.MaxMTL,Cl.MTLminusNAVD);
    end;

    // SAV Colors
    Function SAVColor: Tcolor;
    begin
      LegendForm.GMin := 0;
      LegendForm.GMax := 1;

      If CL.ProbSAV<Tiny then Result := NeutralColors(clBlack)
                         else Result := ColorGradient(0,1,Cl.ProbSAV);
    end;

    // TRGB Colors
    Function TRGBColor(TCd: TColor): TRGBTriple;
    Begin
      Result.rgbtRed := Byte(TCd);
      Result.rgbtGreen := Byte(TCd shr 8);
      Result.rgbtBlue := Byte(TCd shr 16);
    End;

    // Accretion Colors
    Function AccrColor(ER,EC: integer): Tcolor;
    var
      TurbFactor, accr: double;
      nfw, fw: Integer;
      TSub : TSubSite;

    Const ACCRMIN = 0; ACCRMAX = 10.0;

    begin
      LegendForm.GMin := ACCRMIN;
      LegendForm.GMax := ACCRMAX;

      TSub := ThisSite.GetSubSite(EC,ER,Cl);

      accr := 0;

      Case SS.Categories.GetCat(Cat).AccrModel of
          RegFM:      accr := SS.DynamicAccretion(CL,Cat,TSub,0);
          IrregFM:    accr := SS.DynamicAccretion(CL,Cat,TSub,1);
          BeachTF:    accr := SS.DynamicAccretion(CL,Cat,TSub,2);
          TidalFM:    accr := SS.DynamicAccretion(CL,Cat,TSub,3);
          InlandM:    accr := TSub.InlandFreshAccr;
          TSwamp:     accr := TSub.TSwampAccr;
          Swamp:      accr := TSub.SwampAccr;
          Mangrove :  accr := TSub.MangroveAccr;
       End; {Case}

      {Add Turbidity Factor}
      TurbFactor := 1.0;
      nfw := 0;
      With SS do
      If Accr> 0 then
        For fw := 0 to NumFWFlows -1 do
         If FWInfluenced(ER,EC,fw) then
           If FWFlows[fw].UseTurbidities then
             Begin
               inc(nfw);
               If nfw=1 then TurbFactor :=  FWFlows[fw].TurbidityByYear(Year)
                        else TurbFactor := (FWFlows[fw].TurbidityByYear(Year) + (TurbFactor * (nfw-1))) / nfw   // calcuate average turbfactor
             End;

      If Accr=0 then Result := NeutralColors(clNavy)
                else Result := ColorGradient(ACCRMIN,ACCRMAX,accr* TurbFactor);
    end;

    // Elevation Colors
    Function ElevColor(ER,EC: integer): Tcolor;
    var
      elev: double;
     // depth: double;
    begin

      elev:= Getminelev(Cl, ER, EC);

(*    depth := -elev;
      IF depth > 30 then Depth := 30;
      If Depth < -2 then Result := NeutralColors
                    else Result := ColorGradient(-2,30,28-depth);
      Exit;  {Gradient Depth Code} *)

      Result := ElevCol(Elev);

    end;

      function  RoadInundFreqCol(InundFreq: byte): TColor;
      begin
        Result := ClWhite; //Below MTL and connected   InundFreq = 0
        if InundFreq = 255 then Result:= $0000FFFF;{Beach} {yellow}  // diked / not initialized
        if InundFreq > 0 then Result := $00A6A600; {Regularly Flooded Saltmarsh}
        if InundFreq > 30 then Result:= $004080FF;{Irregularly Flooded Brackish Marsh is Orange}
        if InundFreq > 60 then Result:= $00FFA8A8;{InlandOpenWater} {light blue}
        if InundFreq > 90 then Result:= $00A4FFA4;{TidalFreshMarsh} {Lighter Green}
        if InundFreq > 120 then Result := $002D0398; {ClMaroon}    {DevDryland}
        if InundFreq > 150 then Result := $002D0398; {ClMaroon}    {DevDryland}
      end;
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
           255 = not inundated
}

    //Connectivity Colors
    Function ConnectColor(ER,EC: integer): TRGBTriple;
    begin
       case SS.Connect_Arr[(SS.Site.RunCols*ER)+EC] of
                    2 : Result := TRGBColor($00003E00);  {Above Salt Bound = 2  [TSwamp dark green]}
                    3 : Result := TRGBColor($00FFA8A8);  {Connected = 3   [IOW grey-blue]}
                    30: Result := TRGBColor($00FFA8A8);  // same as above
                    4 : Result := TRGBColor($004080FF);  {Unconnected = 4  [IFM orange]}
                    //5 : Result := SS.GridColors2[InlandShore];      {Irrelevant = 5     [brown]}
                    7 : Result := TRGBColor(ClYellow);   // yellow
                    8 : Result := TRGBColor(ClNavy);     {Tidal Water = 8 [navy]}
                    10 : Result := TRGBColor(ClRed);
                    else Result := TRGBColor(ClWhite);
       end;
    end;

    //Inundation Colors
    Function InundColor(ER,EC: integer): TRGBTriple;
    begin
     case SS.Inund_Arr[(SS.Site.RunCols*ER)+EC] of
                  2 : Result := TRGBColor($002D0398);   {DevDryland}       // Above Inundation Elevation
                  30 : Result := TRGBColor($00A6A600);    // H1 Inundation
                  60 : Result := TRGBColor($004080FF);  // H2 Inundation
                  90 : Result := TRGBColor($00FFA8A8);  // H3 Inundation
                  120 : Result := TRGBColor($00003E00);      // H4 Inundation
                  150 : Result := TRGBColor(ClLime);               // H5 Inundation
                  4 : Result := TRGBColor($002D0398);        // Unconnected
                  7 : Result := TRGBColor(ClYellow);        // Diked
                  8 : Result := TRGBColor(ClNavy);        {Tidal Water = 8 [navy]}
                  //10 : Result := SS.GridColors2[OceanBeach];      //Overtopped Dike marco
                  else
                    Result := TRGBColor(ClWhite) ;
     end;
    end;

Const
  CLOpenWater = $00A74D00;
  CLLowTidal = $0000FFFF;
  CLSaltMarsh = $000000A8;
  CLTransitional = $0000FF55;
  CLFreshTidal = $00007326;
  ClFreshNonTidal = $00BEFFD2;
  ClUpland = $00B2B2B2;

    Function AlternativeColors(AC: AggCategories): TColor;
    Begin
      Case AC of
        NonTidal: result := ClUpland;
        FreshNonTidal: result := ClFreshNonTidal;
        OpenWater:  result := CLOpenWater;
        LowTidal: result := CLLowTidal;
        SaltMarsh: result :=  CLSaltMarsh;
        Transitional: result :=  CLTransitional;
        FreshWaterTidal: result := CLFreshTidal;
        else result := ClWhite;
      end; // case
    End;

    Function WaveErosionColor(ER,EC: integer): Tcolor;
    Var EL: Single;
    begin
      ColorNeutral := False;
      LegendForm.GMin := 0;
      LegendForm.GMax := SS.Max_WErode;  {m/y}
      EL := Cl.WPErosion;

      If EL>0 then Result := ColorGradient(0,SS.Max_WErode,EL)
              else Begin
                     Result := NeutralColors(clnavy);
                     ColorNeutral  := True;
                    End;
    end;


    // Erosion Colors
    Function ErosionColor(BTF: Boolean; ER,EC: integer): Tcolor;
    Var EL: Single;
    begin
      ColorNeutral := False;
      LegendForm.GMin := 0;
      LegendForm.GMax := GridScale;
      If BTF then EL := Cl.BTFErosionLoss
             else EL := Cl.ErosionLoss;

      If EL>0 then Result := ColorGradient(0,GridScale,EL)
              else Begin
                     Result := NeutralColors(clnavy);
                     ColorNeutral  := True;
                    End;
    end;


    Procedure DrawPixel(Xd,Yd: Integer; RGBT: TRGBTriple);
    Var IC: Integer;
    Begin
      Try
        if Yd<>LastRow then
          Begin
            Row := Image1.Picture.Bitmap.Scanline[Yd];
            LastRow := Yd;
          End;
        If Row = nil then
          Begin
            Image1.Picture.Bitmap.Canvas.Pixels[Xd,Yd] := clred
          End
                     else Row[Xd] := RGBT;
      Except
        Try
          IC := IterCount;
          Row := Image1.Picture.Bitmap.Scanline[Yd];
          LastRow := Yd;
          Row[Xd] := RGBT;
        Except
          Raise ESLAMMERROR.Create('Draw Pixel Error.');
        End;
      End;
    End;

Var X,Y: Integer;
    TC: TRGBTriple;

    Procedure DrawBigDots;
    Begin
     DrawPixel(X,Y,TC); //Size 1, 1 dot
     If (X+1 < Image1.Width)
      and (Y+1 < Image1.Height) then
       Begin
        DrawPixel(X+1,Y,TC);
        DrawPixel(X,Y+1,TC);
        DrawPixel(X+1,Y+1,TC);  //Size 2, 4 dots

        If (DotSizeBoxIndex>1)  // size 3, 9 dots
         and (X-1 > 0 )
          and (Y-1 > 0) then
           Begin
            DrawPixel(X-1,Y,TC);
            DrawPixel(X,Y-1,TC);
            DrawPixel(X-1,Y-1,TC);
            DrawPixel(X-1,Y+1,TC);
            DrawPixel(X+1,Y-1,TC);

            If (DotSizeBoxIndex>2)  // size 4, 16 dots
            and(X+2 < Image1.Width)
             and (Y+2 < Image1.Height) then
              Begin
               DrawPixel(X+2,Y-1,TC);
               DrawPixel(X+2,Y,TC);
               DrawPixel(X+2,Y+1,TC);
               DrawPixel(X+2,Y+2,TC);

               DrawPixel(X-1,Y+2,TC);
               DrawPixel(X,Y+2,TC);
               DrawPixel(X+1,Y+2,TC);

               If (DotSizeBoxIndex>3) //Size 5, 25 dots
                and (X-2 > 0)
                 and (Y-2 > 0) then
                  Begin
                    DrawPixel(X-2,Y-2,TC);

                    DrawPixel(X-2,Y-1,TC);
                    DrawPixel(X-2,Y  ,TC);
                    DrawPixel(X-2,Y+1,TC);
                    DrawPixel(X-2,Y+2,TC);

                    DrawPixel(X-1,Y-2,TC);
                    DrawPixel(X,  Y-2,TC);
                    DrawPixel(X+1,Y-2,TC);
                    DrawPixel(X+2,Y-2,TC);
                  End;  //itemindex > 3
              End;  //itemindex > 2
           End;  //itemindex > 1
       End;
    End;  //drawbigdots

Begin    {Drawcell}

  If Optim then if ((Cat=-99) and not IsROS) then exit;  //optimization for drawing blank cells
  If (ZoomFactor = 0.5) then
    Begin
      If (DrawRow Mod 2 > 0) then exit;
      If (DrawCol Mod 2 > 0) then exit;
    End;
  If (ZoomFactor = 0.25) then
    Begin
      If (DrawRow Mod 4 > 0) then exit;
      If (DrawCol Mod 4 > 0) then exit;
    End;
  If (ZoomFactor = 0.125) then
    Begin
      If (DrawRow Mod 8 > 0) then exit;
      If (DrawCol Mod 8 > 0) then exit;
    End;

  X :=1+TRUNC(DrawCol*ZoomFactor);
  Y :=1+TRUNC(DrawRow*ZoomFactor);
  ColorNeutral := True;

  TC := TRGBWhite;
  If IsROS then TC := TRGBWhite {ROS color for now}
     else If Diked then
       Begin
         TC := TRGBColor(ClYellow); {dike color for now}
         if SS.Connect_Arr <> nil then
          if SS.Connect_Arr[(SS.Site.RunCols*ER)+EC] = 10 then
            TC := TRGBColor(CLRed);  //overtopped dike
       End
     else Case GBII of
            1: TC := TRGBColor(ElevColor(ER,EC));
            2: TC := TRGBColor(SalColor(1));
            3: TC := TRGBColor(SalColor(2));
            4: TC := TRGBColor(SalColor(3));
            5: TC := TRGBColor(SalColor(4));
            6: TC := TRGBColor(AccrColor(ER,EC));
            7: TC := TRGBColor(SubsidenceColor(ER,EC));
            8: TC := TRGBColor(MTLNAVDColor(ER,EC));
            9: TC := TRGBColor(WaveErosionColor(ER,EC));
            10: TC := TRGBColor(ErosionColor(False,ER,EC));
            11: TC := TRGBColor(ErosionColor(True,ER,EC));
            12: TC := TRGBColor(AlternativeColors(SS.Categories.GetCat(Cat).AggCat));
            13: TC := ConnectColor(ER, EC);
            14: TC := InundColor(ER,EC);
            15: TC := TRGBColor(SAVColor);
            else
              if GBII>99 then
                 TC := TRGBColor(RoadInundFreqCol(GBII-100)) //Roads
              else
                TC := TRGBColor(SS.Categories.GetCat(Cat).Color);    // Standard SLAMM Map
           End; {Case}

  If (Not DrawingTopLayer) or (Diked) then DrawPixel(X,Y,TC);

  If (GBII in [9..11]) {erosion color}
   and (not colorneutral) and drawingtoplayer and (DotSizeBoxIndex > 0) then
      DrawBigDots;

  //Road Inundation
{  if (GBII>99) or (ShowRoadOld) then
    begin
      DotSizeBoxIndex := 3;  //fixme road size fixed at 3
      DrawBigDots;
    end; }

  If ZoomFactor > 1 then {200%}
    Begin
      DrawPixel(X+1,Y,TC);
      DrawPixel(X,Y+1,TC);
      DrawPixel(X+1,Y+1,TC);
    End;
   If ZoomFactor > 2 then {300%}
    Begin
      DrawPixel(X+2,Y,TC);
      DrawPixel(X,Y+2,TC);
      DrawPixel(X+2,Y+2,TC);
      DrawPixel(X+2,Y+1,TC);
      DrawPixel(X+1,Y+2,TC);
    End;
  if ZoomFactor > 3 then {400%}
    begin
      DrawPixel(X+3,Y,TC);
      DrawPixel(X,Y+3,TC);
      DrawPixel(X+3,Y+3,TC);
      DrawPixel(X+3,Y+1,TC);
      DrawPixel(X+3,Y+2,TC);
      DrawPixel(X+1,Y+3,TC);
      DrawPixel(X+2,Y+3,TC);
    end;
End;

procedure TGridForm.DrawDikeSquareClick(Sender: TObject);
begin
  SaveBitStream;
  DefiningBoundary := True;
  GettingDikeElevs := True;
  DikeX1 := -99;
  DikeY1 := -99;
  DikeX2 := -99;
  DikeY2 := -99;

end;

{----------------------------------------------------------------------------------------------------}

Function TGridForm.DrawEntireMap(OutSite: Integer; ShowProg, ROS: Boolean): Boolean;
Var GBII, DrawRow,DrawCol, ER,EC: Integer;
    PCL: CompressedCell;
    DD, DoubleDraw, SLabel,YLabel,PLabel: Boolean;
    Catg : Integer;
Begin
  Result := True;
  LastRow := -9999;  // initialize 3/14/16
  Bitstream := nil;  // initialize 3/16/16

  GraphBox.Enabled := False;
  ZoomBox.Enabled := False;
  ZoomBox2.Enabled := False;
  ZoomBox3.Enabled := False;

  If ShowProg then Begin
                     SLabel := ProgForm.SLRLabel.Visible;
                     YLabel := ProgForm.YearLabel.Visible;
                     PLabel := ProgForm.ProtectionLabel.Visible;
                     ProgForm.YearLabel.Visible       := False;
                     ProgForm.SLRLabel.Visible        := False;
                     ProgForm.ProtectionLabel.Visible := False;
                     ProgForm.ProgressLabel.Caption   := 'Drawing Map';
                     ProgForm.HaltButton.Visible := True;
                     ProgForm.Visible := True;
                     If Visible then ShowRunPanel;  // avoid updating PL2 for GridForm2 that will be destroyed
                   End;

  If (OutSite>0) or ROS then
    Case SS.ROS_Resize of
      1: ZoomFactor := 0.25;
      2: ZoomFactor := 0.50;
      3: ZoomFactor := 1.0;
      4: ZoomFactor := 2.0;
      5: ZoomFactor := 3.0;
      6: ZoomFactor := 4.0;
    End;

  TRY

  Rows := TRUNC(MapNR * ZoomFactor);  Cols := TRUNC(MapNC * ZoomFactor);

  Scrollbox1.VertScrollBar.Range:=Trunc(MapNR*ZoomFactor)+2;
  Scrollbox1.HorzScrollBar.Range:=Trunc(MapNC*ZoomFactor)+2;

  Image1.Picture.Bitmap.Free;
  Image1.Picture.Bitmap := TBitmap.Create;
  Image1.Picture.Bitmap.PixelFormat := pf24bit;  // Do this first

  Try

  Image1.Height:=TRUNC(MapNR*ZoomFactor)+2;
  Image1.Width:=TRUNC(MapNC*ZoomFactor)+2;
  Image1.Picture.Bitmap.Height:=TRUNC(MapNR*ZoomFactor)+2;
  Image1.Picture.Bitmap.Width:=TRUNC(MapNC*ZoomFactor)+2;
  Image1.Canvas.Pen.Style := PSSolid;
  Image1.Canvas.Pen.Mode := pmCopy;
  Image1.Canvas.Brush.Color := ClWhite;
  Image1.Canvas.Pen.Color := ClWhite;
  Image1.Canvas.Rectangle(0, 0, TRUNC(MapNC*ZoomFactor)+2, TRUNC(MapNR*ZoomFactor)+2);
  Image1.Invalidate;

  Except
    ShowMessage('This map is too large to show in that dimension.');
    Image1.Invalidate;
    LastRow := -9999;
    Image1.Visible := True;
    GraphBox.Enabled := True;
    ZoomBox.Enabled := True;
    ZoomBox2.Enabled := True;
    ZoomBox3.Enabled := True;
    RunPanel.Visible := False;
    Exit;
  End;

  With SS do
   If OutSite=0 then
    Begin
      SRow := 0;
      ERow := MapNR-1;
      SCol := 0;
      ECol := MapNC-1;
    End
   else If ROS then with Site.ROSBounds[OutSite-1] do
    Begin
      SRow := TRUNC(Y1);
      ERow := TRUNC(Y2);
      SCol := TRUNC(X1);
      ECol := TRUNC(X2);
    End
   else with Site.OutputSites[OutSite-1] do
    Begin
      If UsePolygon then with ScalePoly do
        Begin
          SRow := MinRow;
          ERow := MaxRow;
          SCol := MinCol;
          ECol := MaxCol;
        End
      else with ScaleRec do
        Begin
          SRow := Min(Y1,Y2);
          ERow := Max(Y1,Y2);
          SCol := Min(X1,X2);
          ECol := Max(X1,X2);
        End;
    End;

  // Get the map to draw
  GBII := GraphBox.ItemIndex;

  // Set the dot size
  DotSizeBoxIndex := DotSizeBox.ItemIndex;

  // Set the doubledraw boolean variable
  DoubleDraw := (GBII in [9..11]) and (DotSizeBoxIndex > 0);  {erosion maps require double draw}

  // Image not visible for now
  Image1.Visible := False;

  For DD := False to DoubleDraw do
   For ER:=SRow to ERow do
    Begin
     For EC:=SCol to ECol do
      Begin
        DrawingTopLayer := DD;

        DrawRow := ER-SRow;
        DrawCol := EC-SCol;

        If (ZoomFactor = 0.5) then
          Begin
            If (DrawRow Mod 2 > 0) then Continue;   // 11/11/2013 fixed to use DrawRow instead of ER to match Drawcell logic
            If (DrawCol Mod 2 > 0) then Continue;
          End;
        If (ZoomFactor = 0.25) then
          Begin
            If (DrawRow Mod 4 > 0) then Continue;
            If (DrawCol Mod 4 > 0) then Continue;
          End;
        If (ZoomFactor = 0.125) then
          Begin
            If (DrawRow Mod 8 > 0) then Continue;
            If (DrawCol Mod 8 > 0) then Continue;
          End;

        SS.RetA(ER,EC,PCl);
        CatG := GetCellCat(@PCl);

        If (Not ROS) and (OutSite<1) then DrawCell(@PCL,ER, EC, DrawRow,DrawCol,CatG,False,False,true,GBII)
        else
          With SS do
           If ROS and (ROSArray <> nil)
             then
               If (ROSArray[(Site.RunCols*ER)+EC] <> OutSite)
                 then DrawCell(@PCL,ER, EC,DrawRow,DrawCol,-99,False,False,true,GBII)
                 else DrawCell(@PCL,ER, EC,DrawRow,DrawCol,CatG,False,False,true,GBII)
             else with SS.Site.OutputSites[OutSite-1] do
               If UsePolygon then
                Begin
                         If ScalePoly.InPoly(ER,EC) then DrawCell(@PCL,ER, EC,DrawRow,DrawCol,CatG,False,False,true,GBII)
                                                    else DrawCell(@PCL,ER, EC,DrawRow,DrawCol,-99,False,False,true,GBII);
                        End
                  else DrawCell(@PCL,ER, EC,DrawRow,DrawCol,CatG,False,False,true,GBII);
      End;  {EC Loop}

     If SS.UserStop then Break;       //something in here is causing the bitmap corruption  trap where ER=3
     If ShowProg then Result := ProgForm.Update2Gages(Trunc((ER-SRow+1)/(ERow-SRow+1)*(100)),0);
     If Not Result then Break;
     Application.Processmessages;
    End
  //end;
  Finally

  Image1.Invalidate;
  LastRow := -9999;
  Image1.Visible := True;
  GraphBox.Enabled := True;
  ZoomBox.Enabled := True;
  ZoomBox2.Enabled := True;
  ZoomBox3.Enabled := True;

   if (outsite = 0) and (not ROS) then
     SaveBitstream;

  If ShowProg then With ProgForm do
                   Begin
                     SLRLabel.Visible := SLabel;
                     YearLabel.Visible := YLabel;
                     ProtectionLabel.Visible := PLabel;
                   End;

  End;
End;

{----------------------------------------------------------------------------------------------------}

Function TGridForm.ShowMap(NR,NC: Integer; Var Site: TSite; TSS: TSLAMM_Simulation): Boolean;
Var MR: TModalResult;
Begin
  SS := TSS;
  DrawingRect := False;

  ToolBox1.ItemIndex := 1;

  MapNR := NR;
  MapNC := NC;

       SRow := 0;
       ERow := MapNR-1;
       SCol := 0;
       ECol := MapNC-1;

  GridScale := Site.RunScale;
  ThisSite := Site;
  SS.UserStop:=False;

  ROSPanel.Visible := Site.MaxROS > 0;
  ROSShowing := 0;

  ProgForm.Show;
  SaveBtStream := False;
  Result := DrawEntireMap(0,True,False);
  If Not Result then Exit;

  If not SS.QA_Tools then Show;
  SS.UserStop:=False;

  If SS.QA_Tools then
    Begin
      MapTitle.Visible := True;
      MapTitle.Caption:= 'Unprocessed Elevations (NWI Map Date)';
      RunPanel.Visible := False;
      hide;
      MR := ShowModal;
      IF (MR=2) then if MessageDlg('Stop Simulation Execution And Return to Main Menu? ',mtconfirmation,[mbyes,mbno],0) = mryes then
                MR := MRAbort;   // Disambiguation of X key

      If MR = MRAbort then Begin SS.UserStop:=True; exit; End;
      If MR = MRIgnore then SS.QA_Tools := False;
      MapTitle.Visible := False; Show; IsVisible := True;
    end;
End;

{----------------------------------------------------------------------------------------------------}


Procedure TGridForm.ShowRoadInundation;
var
  j, i, ER, EC, CanvasX, CanvasY: integer;
  ProcCell: CompressedCell;
  GBII: integer;
begin
  DrawingTopLayer := False;
  Image1.Visible := False;
  LoadBitStream;

  SetLength(RoadLocs,(Image1.Picture.Width)*(Image1.Picture.Height));
  For i := 0 to Image1.Picture.Width*Image1.Picture.Height -1 do
    RoadLocs[i].Loc := -1;

  GBII := 100;

  If SS.NRoadInf>0 then
    for j:=0 to SS.NRoadInf-1 do
     If (RoadIndex = -1) or (j=RoadIndex) then
      With SS.RoadsInf[j] do
       for i := 0 to NRoads-1 do
        begin
          ER := RoadData[i].Row;
          EC := RoadData[i].Col;
          SS.RetA(ER,EC,ProcCell);
          DrawCell(@ProcCell,ER,EC,ER,EC,GetCellCat(@ProcCell),False,False,False,100+RoadData[i].InundFreq[SS.TStepIter]);

          CanvasX :={1+}TRUNC(EC*ZoomFactor);
          CanvasY :={1+}TRUNC(ER*ZoomFactor);
          RoadLocs[CanvasX+(CanvasY*Image1.Picture.Width)].Loc := i ;
          RoadLocs[CanvasX+(CanvasY*Image1.Picture.Width)].Ind := j ;
        end;

  Image1.Visible := True;
  LastRow := -9999;

  Screen.Cursor := crDefault;
end;

procedure TGridForm.ShowRunPanel;
begin
  RunPanel.Top := 0;
  RunPanel.Visible := True;
  RunPanel.BringToFront;

  ProgForm.PL2 := Pointer(ProgressLabel);  // this should not be updated for GridForm2 that will be destroyed
  ProgForm.G2 := Pointer(Gauge1);
  ProgForm.f2 := Pointer(Self);
  ProgForm.YL2 := Pointer(YearLabel);
  ProgForm.SLR2 := Pointer(SLRLabel);
  ProgForm.Prot2 := Pointer(ProtectionLabel);
  Update;

end;

procedure TGridForm.StopPausingButtonClick(Sender: TObject);
begin

end;

{----------------------------------------------------------------------------------------------------}

procedure TGridForm.EditAlphaClick(Sender: TObject);
Var ER, EC: Integer;
    CL: CompressedCell;
    Subsite : TSubsite;
begin
   SiteEditForm.TS := SS.Site;
   SiteEditForm.ShowWindEdits.Checked := True;
   SiteEditForm.EditSubSites(SS);

   SS.ScaleCalcs;
   for ER :=0 to MapNR- 1 do
    begin
      ProgForm.Update2Gages(Trunc(100*(ER/(MapNR-1))),0);
      for EC:=0 to MapNC-1 do
        begin
          // Get the cell
          SS.RetA(ER,EC,CL);
          If CL.Pw>0 then
            Begin
              SubSite := SS.Site.GetSubSite(EC,ER,@CL);
              CL.WPErosion := CL.Pw*SubSite.WE_Alpha;
              SS.SetA(ER,EC,CL);
            End;
        End;
     End;
   GraphBoxChange(nil);
end;

Procedure TGridForm.EditAttributes(NR,NC: Integer; TSS: TSLAMM_Simulation);
Begin
  SS := TSS;
  GridScale := TSS.Site.RunScale;

  RunPanel.Visible := False;

  ROSPanel.Visible := TSS.Site.MaxROS > 0;
  ROSShowing := 0;


  MapNR := NR;
  MapNC := NC;

       SRow := 0;
       ERow := MapNR-1;
       SCol := 0;
       ECol := MapNC-1;

  SS.UserStop:=False;

  ProgForm.Show;
  SaveBtStream := True;
  If Not DrawEntireMap(0,True,False) then Exit;
  SS.UserStop:=False;

  ProgForm.Hide;
  RunPanel.Visible := False;

  EditIndex := 0;
  UpdateEditBox;

  SS.ScaleCalcs;
  ShowEditItems;
  DefEstClick(nil);

  ZoomBox.Visible := True;
  ZoomBox2.Visible := True;
  ZoomBox3.Visible := True;

  // Form caption with the loaded project name
  Caption :='SLAMM Map -- '+SS.FileN;

  ShowModal;

  if Bitstream <> nil then
    FreeAndNil(BitStream);
End;

{----------------------------------------------------------------------------------------------------}

{ Input Subsites  InputBox.ItemIndex = 0
Output Subsites    InputBox.ItemIndex = 1
Fresh-Water Flows   InputBox.ItemIndex = 2
Roads Layer          InputBox.ItemIndex = 3
Infrastructure Layer  InputBox.ItemIndex = 4 }

Procedure TGridForm.UpdateEditBox;
Var i: Integer;
Begin
  EditBox.Items.Clear;

  With SS do
  If (InputBox.ItemIndex = 2)
    then
      For i := 0 to NumFWFlows-1 do
        EditBox.Items.Add(FWFlows[i].Name)
    else if (InputBox.ItemIndex = 0)
      then
        For i := 0 to Site.NSubSites-1 do
          EditBox.Items.Add(Site.SubSites[i].Description)
      else if (InputBox.ItemIndex = 1)
        then
          For i := 0 to Site.NOutputSites-1 do
            EditBox.Items.Add(Site.OutputSites[i].Description)
        else if (inputBox.ItemIndex=4)
          then
            For i := 0 to NPointInf-1 do
              EditBox.Items.Add(PointInf[i].IDName)
          else if (inputBox.ItemIndex=3)
            then
              For i := 0 to NRoadInf-1 do
                EditBox.Items.Add(RoadsInf[i].IDName);


  EditBox.ItemIndex := EditIndex;
  Updating := True;
  NameEdit.Text := EditBox.Text;

  ImportShp.Visible := (InputBox.ItemIndex > 2 );  {3 or 4}
  CalcInundation.Visible := ((InputBox.ItemIndex = 4) and (SS.NPointInf>0)) or
                            ((InputBox.ItemIndex = 3) and (SS.NRoadInf>0));
//  OmitT030.Visible := CalcInundation.Visible;

  Updating := False;
End;

procedure TGridForm.ViewLegButtClick(Sender: TObject);
Var ConnectLegend: Boolean;
    GBII: Integer;
begin
  GBII := GraphBox.ItemIndex;
  If GBII = 12 then Begin Legend2Form.ShowModal; Exit; End;   //alternative category legend


  If GBII = 14 then Begin RoadInundLegendForm.ShowModal; Exit; End;

  ConnectLegend := (GBII = 13);

  LegendForm.PSS := SS;
  LegendForm.UpdateLegend(GBII>1,GBII=1,ConnectLegend);
  LegendForm.Showmodal;
  If LegendForm.Changed then
    Begin
//      SS.AssignGridColors2;
      If MessageDlg('Colors Changed, Redraw Entire Map?',mtconfirmation,[mbyes,mbno],0)=mryes
        then
          Begin
            DrawEntireMap(0,true,false);
            ProgForm.Hide;
            RunPanel.Visible := False;
          End;
    End;

  TButton(Sender).Caption:='Legend';
end;

procedure TGridForm.HaltButtonClick(Sender: TObject);
begin
  If MessageDlg('Stop Simulation Execution?',mtconfirmation,[mbyes,mbno],0)=MrYes then
  begin
    ModalResult := MRAbort;            // empty these out
    BitStream := nil;
  end;
end;

procedure TGridForm.HelpButtonClick(Sender: TObject);
begin
  Application.HelpContext(1002);   //Othertools.html
end;

procedure TGridForm.helpFileAttribClick(Sender: TObject);
begin
  Application.HelpContext(1002);  //Othertools.html
end;

procedure TGridForm.FormResize(Sender: TObject);
begin
    ScrollBox1.Height:=ClientHeight-Scrollbox1.Top;
    ScrollBox1.Width:=ClientWidth+2;
end;

procedure TGridForm.FormShow(Sender: TObject);
begin



  DisposeWhenClosed := False;

  //AttribPanel.Top := 0;
  MapTitle2.Caption:='';

  SalAnalysis2.Visible := False;
  // Show the salinity analysis button only if a salinity raster is loaded  or fresh water flows have been defined
  if (trim(SS.SalFileN)<>'') or (SS.NumFWFlows>0) then
    SalAnalysis2.Visible := True;

  DrawingRect := False;
  DefiningBoundary := False;
  GettingDikeElevs := False;
  DefiningVector := False;
  PolyingCells := False;
  DrawingCells:= False;
  FillingCells:= False;
  FillCategory:= False;

  If ZoomFactor = 0.125 then ZoomBox.ItemIndex := 0 else
  If ZoomFactor = 0.25 then ZoomBox.ItemIndex := 1 else
  If ZoomFactor = 0.5 then ZoomBox.ItemIndex := 2 else
  If ZoomFactor = 1 then ZoomBox.ItemIndex := 3 else
  If ZoomFactor = 2 then ZoomBox.ItemIndex := 4 else
  If ZoomFactor = 3 then ZoomBox.ItemIndex := 5;

  ZoomBox2.ItemIndex := ZoomBox.ItemIndex;
  ZoomBox3.ItemIndex := ZoomBox.ItemIndex;

  FormResize(Sender);

  FillCategoryBox;
end;

procedure TGridForm.FWExtentOnlyClick(Sender: TObject);
begin
  If (InputBox.ItemIndex = 2) then
    Begin
      If SS.NumFWFlows = 0 then AddEstClick(nil);
      With SS.FWFlows[EditIndex] do
        ExtentOnly := FWExtentOnly.Checked;
    End;


end;

procedure TGridForm.FWFlowButtonClick(Sender: TObject);
begin
  If SS.NumFWFlows = 0 then Exit;
  SS.ScaleCalcs;
  FWFlowEdit.EditFWFlow(SS.FWFlows,SS.NumFwFlows,EditIndex);
  ShowEditItems;
end;

procedure TGridForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  IsVisible:=False;
  LegendForm.Hide;
  ViewLegButt.Caption:='Legend';
  DrawingCells := False;
  PolyingCells := False;
  FillingCells := False;
  PointLocs := nil;
  RoadLocs := nil;
  //ShowElevs.checked := False;

  If DisposeWhenClosed then
    Begin
      SS.DisposeMem;
      SS.ClearFlowGeometry;
    End;
end;

procedure TGridForm.HideMapButtonClick(Sender: TObject);
begin
  IsVisible :=False;
  LegendForm.Hide;
  ViewLegButt.Caption:='Legend';
  Hide;
end;


{----------------------------------------------------------------------------------------------------}




procedure TGridForm.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var Cl: CompressedCell;
//    SvCrs: TCursor;
    MapX, MapY: Integer;
    Cat: Integer;

      {----------------------------------------------------------------------------------------------------}

     Procedure FillPolyCells;
     Var XMin, XMax, YMin, YMax, Xl, Yl, Pl: Integer;
         TempPoly: TPolygon;
         OldCat : Integer;

     Begin
       LoadBitStream;

       XMax := -999999;
       XMin :=  999999;
       YMax := -999999;
       YMin :=  999999;

       If NumPolyPts < 3 then exit;

       For Pl := 0 to NumPolyPts-1 do
         Begin
           If PolyPoints[Pl].X > XMax then XMax := PolyPoints[Pl].X;
           If PolyPoints[Pl].Y > YMax then YMax := PolyPoints[Pl].Y;
           If PolyPoints[Pl].X < XMin then XMin := PolyPoints[Pl].X;
           If PolyPoints[Pl].Y < YMin then YMin := PolyPoints[Pl].Y;
         End;

       TempPoly := TPolygon.Create;
       TempPoly.TPoints := PolyPoints;
       TempPoly.NumPts := NumPolyPts;

       For Xl := XMin to XMax do
         For Yl := YMin to YMax do
           If TempPoly.InPoly(Yl,Xl) then
             Begin
               SS.RetA(Yl,Xl,Cl);

               OldCat := GetCellCat(@Cl);
               If FillDikes
                  then
                    Begin
                      Cl.ProtDikes := True;
                      DrawCell(@CL,Yl,Xl,Yl,Xl,0,True,False,False,0);     { draw dikes }
                      DikesChanged := True;
                      SS.Init_ElevStats := False;
                    End
                  else
                 If FillNoDikes
                  then
                    Begin
                      Cl.ProtDikes := False;
                      DrawCell(@CL,Yl,Xl, Yl,Xl,OldCat,False,False,False,0);  {remove yellow color}
                      DikesChanged := True;
                      SS.Init_ElevStats := False;
                    End
                  else
                    Begin
                      ChangeCellType(@Cl,OldCat,CategoryFromComboBox);
                      DrawCell(@CL,Yl,Xl,Yl,Xl,CategoryFromComboBox,False,False,False,0);
                      NWIChanged := True;
                      SS.Init_ElevStats := False;
                    End;

               SS.SetA(Yl,Xl,Cl);
               Image1.Invalidate;
               LastRow := -9999;
             End;

       TempPoly.Destroy;
       SaveBitStream;
       ShowEditItems;
     End;

      {----------------------------------------------------------------------------------------------------}

     Procedure XORPen;
     Begin
        aX := X;
        aY := Y;
        zX := X;
        zY := Y;
        Image1.Canvas.MoveTo(aX,aY);
        Image1.Canvas.Pen.Color := clWhite;
        Image1.Canvas.Pen.Mode := pmXor;
        Image1.Canvas.Brush.Style := bsClear;
        Image1.Canvas.Pen.Width := 1;
        Image1.Canvas.Pen.Style := psSolid;
     End;

      {----------------------------------------------------------------------------------------------------}

     Procedure Fill(FX,FY: Integer; Cat: Integer);

        function MP(ax,ay:integer): TPoint;
        begin
          result.x:= ax;
          result.y:= ay;
        end;

     var
      Stack: TPointStack;
      TP: TPoint;

     Begin
       LoadBitStream;

       SS.RetA(FY,FX,Cl);
       If CellWidth(@CL,CAT) > 0.1 then Exit;

       With SS do
         Begin
           stack:= TPointStack.Init;
           stack.push(MP(fx,fy));

           repeat
             TP:= stack.pop;
             if tp.x > -99 then
                begin
                   FX:= TP.x;
                   FY:= TP.y;

                   IF (FY<0) or (FX<0) or (FX>=Site.RunCols) or (FY>=Site.RunRows) then continue;
                   RetA(FY,FX,Cl);
                   If FillDikes and (CL.ProtDikes) then Continue;        {If filling dikes, exit if Already Protected by Dikes}
                   If FillNoDikes and Not (CL.ProtDikes) then Continue;  {If filling "no dikes", exit if no dikes}
                   If (Not FillNoDikes) then
                     If CellWidth(@CL,FILLCAT) = 0 then Continue;        {Exit if you left the bounds of the FILLCAT}

                   If FillDikes then
                     begin
                        Cl.ProtDikes := True;
                        DikesChanged := True;
                     end
                   else
                   If FillNoDikes then
                     begin
                        Cl.ProtDikes := False;
                        DikesChanged := True;
                        SS.Init_ElevStats := False;
                     end
                   else
                     begin
                       NWIChanged := True;
                       SS.Init_ElevStats := False;
                       ChangeCellType(@Cl,FillCat,Cat);
                     end;


                   if FillDikes then
                     DrawCell(@Cl,FY,FX,FY,FX,Cat,True,False,False,0) {Draw Yellow}
                   else if FillNoDikes then
                     DrawCell(@Cl,FY,FX,FY,FX,GetCellCat(@CL),False,False,False,0)
                   else
                     DrawCell(@Cl,FY,FX,FY,FX,Cat,False,False,False,0);

                   SetA(FY,FX,Cl);
                   Stack.Push(MP(FX+1,FY));
                   Stack.Push(MP(FX-1,FY));
                   Stack.Push(MP(FX,FY+1));
                   Stack.Push(MP(FX,FY-1));
                   if Checkbox2.Checked then
                   begin
                     Stack.Push(MP(FX+1,FY+1));
                     Stack.Push(MP(FX-1,FY-1));
                     Stack.Push(MP(FX-1,FY+1));
                     Stack.Push(MP(FX+1,FY-1));
                   end;
                end;
           until TP.x = -99;

           Image1.Invalidate;
           LastRow := -9999;
           stack.destroy;
         End;
       SaveBitStream;
     End;

      {----------------------------------------------------------------------------------------------------}

Var i,j: Integer;
    oldcat: Integer;
    CE: double;
begin     {Image1MouseDown}

 if (PanCheckBox.Checked) and (not DrawingCells) and (not PolyingCells)
    and (not FillingCells) and (not DefiningBoundary) and (not DefiningVector) then
  begin
    FLastDown := Mouse.CursorPos;
    Screen.Cursor := -21
   end
 else
  begin
   If RunPanel.Visible then exit;

   If DrawingCells then
    Begin
      If (SSRight in Shift) or (SSDouble in Shift) then
        Begin
          DoneDrawingButtonClick(sender);
          Exit;
        End;

      MapX :=Trunc(X/ZoomFactor);
      MapY :=Trunc(Y/ZoomFactor);
      If (MapX>=SS.Site.RunCols) or (MapY>=SS.Site.RunRows) then exit;

      If (MapX<0) or (MapY<0) then Exit;

      MapX := MapX - (PenWidthBox.ItemIndex div 2);
      If MapX <0 then MapX := 0;
      MapY := MapY - (PenWidthBox.ItemIndex div 2);
      If MapY <0 then MapY := 0;

      With SS do
        For i := 0 to PenWidthBox.ItemIndex do
          For j := 0 to PenWidthBox.ItemIndex do
            Begin
              If (MapX+i>=Site.RunCols) or (MapY+j>=Site.RunRows) then exit;
              RetA(MapY+i,MapX+j,Cl);
              OldCat := GetCellCat(@Cl);

              If (not Large_Raster_Edit) and (OldCat = -99) and (SS.OptimizeLevel > 0) then
                Begin
                  MessageDlg('Cannot Edit Blank Cells when any memory optimization is selected.  Change options in File-Setup.',
                            mterror,[mbok],0);
                  Exit;
                End;

//              LoadBitstream;
              If FillDikes then
                Begin
                  Cl.ProtDikes := True;
                  DrawCell(@CL,MapY+i,MapX+j,MapY+i,MapX+j,0,True,False,False,0);     {draw dikes yellow}
                  DikesChanged := True;
                End
              else If FillNoDikes then
                Begin
                  Cl.ProtDikes := False;
                  DrawCell(@CL,MapY+i,MapX+j,MapY+i,MapX+j,OldCat,False,False,False,0);  {remove yellow color}
                  DikesChanged := True;
                End
              else
                Begin
                  // Get elevation category
                  CE := CatElev(@CL,OldCat);
                  ChangeCellType(@Cl,OldCat,CategoryFromComboBox);

                  // Set the elevation again
                  SetCatElev(@CL,CategoryFromComboBox,CE);

                  DrawCell(@CL,MapY+i,MapX+j,MapY+i,MapX+j,CategoryFromComboBox,False,False,False,0);
                  NWIChanged := True;
                  SS.Init_ElevStats := False;
                End;

              Image1.Invalidate;
              LastRow := -9999;
              // SaveBitstream;

              SetA(MapY+i,MapX+j,Cl);
            End;

      Exit;
    End;    {DRAWINGCELLS}

    If FillingCells then with SS do
      Begin
        If (SSRight in Shift) or (SSDouble in Shift) then
          Begin
            FillingCells := False;
            MapTitle.Caption:='';
            Exit;
          End;

        Screen.Cursor := crHourglass;

        MapX :=Trunc(X/ZoomFactor);
        MapY :=Trunc(Y/ZoomFactor);
        If (MapX<0) or (MapY<0) then Exit;
        If (MapX>=Site.RunCols) or (MapY>=Site.RunRows) then exit;

        RetA(MapY,MapX,Cl);
        FILLCAT := GetCellCat(@Cl);

        If (not Large_Raster_Edit) and (FillCat = -99) and (SS.OptimizeLevel > 0) then
          Begin
            MessageDlg('Cannot Fill Blanks when any memory optimization is selected.  Change options in File-Setup.',
                        mterror,[mbok],0);
            Screen.Cursor := crdefault;
            Exit;
          End;

        Cat := CategoryFromComboBox;

        Fill(MapX,MapY, Cat);

        Screen.Cursor := crdefault;
        Exit;
      End;    {FILLINGCELLS}

    If DefiningBoundary and PolyingCells then
      Begin
        MapX :=Trunc(X/ZoomFactor);
        MapY :=Trunc(Y/ZoomFactor);

        XORPen;
        Inc(NumPolyPts);
        If NumPolyPts >Length(PolyPoints) then SetLength(PolyPoints,NumPolyPts+100);
        PolyPoints[NumPolyPts-1].X := MapX;
        PolyPoints[NumPolyPts-1].Y := MapY;

        If (SSRight in Shift) or (SSDouble in Shift) then
          Begin
            DefiningBoundary := False;
            Image1.Canvas.MoveTo(aX,aY);
            Image1.Canvas.LineTo(zX,zY);

            FillPolyCells;
            PolyingCells := False;
            DoneDrawingButtonClick(nil);
          End;

        Exit;
      End;      {POLYINGCELLS}

    If DefiningBoundary then With SS do
      Begin
        MapX :=Trunc(X/ZoomFactor);
        MapY :=Trunc(Y/ZoomFactor);

        if GettingDikeElevs then
          Begin
            If (DikeX1<0) and (DikeY1<0) then
              Begin
                XORPen;
                DikeX1 := MapX;
                DikeY1 := MapY;
              End
            Else
              Begin
                Definingboundary := False;
                DikeX2 := MapX;
                DikeY2 := MapY;
                ShowDikeStats;
              End;
            Exit;
          End;

        If (SSRight in Shift) or (SSDouble in Shift) then
          Begin
            DefiningBoundary := False;
            Image1.Canvas.MoveTo(aX,aY);
            Image1.Canvas.LineTo(zX,zY);
            ShowEditItems;
          End;

        If (InputBox.ItemIndex = 2) then
          With FWFlows[EditIndex].SavePoly do
            Begin
              XORPen;
              Inc(NumPts);
              If NumPts>Length(TPoints) then SetLength(TPoints,NumPts+100);
              TPoints[NumPts-1].X := MapX;
              TPoints[NumPts-1].Y := MapY;
            End;

        IF (InputBox.ItemIndex = 1) then
          With Site.OutputSites[EditIndex] do with SaveRec do //Upgrade allow for polygon inputs eventually
            Begin
              If (X1<0) and (Y1<0) then
                Begin
                  XORPen;
                  X1 := MapX;
                  Y1 := MapY;
                End
              Else
                Begin
                  Definingboundary := False;
                  X2 := MapX;
                  Y2 := MapY;
                  ShowEditItems;
                End;
            End;


        IF (InputBox.ItemIndex = 0) then
          With Site.SubSites[EditIndex].SavePoly do
            Begin
              XORPen;
              Inc(NumPts);
              If NumPts>Length(TPoints) then SetLength(TPoints,NumPts+100);
              TPoints[NumPts-1].X := MapX;
              TPoints[NumPts-1].Y := MapY;
            End;
          Exit;
      End; {defining boundary}

    If DefiningVector then With SS do With FWFlows[EditIndex] do
      Begin
        MapX :=Trunc(X/ZoomFactor);
        MapY :=Trunc(Y/ZoomFactor);

        Image1.Canvas.MoveTo(X-1,Y-1);
        Image1.Canvas.LineTo(X-1,Y+1);
        Image1.Canvas.LineTo(X+1,Y+1);
        Image1.Canvas.LineTo(X+1,Y-1);

        If (SSRight in Shift) or (SSDouble in Shift) then
          Begin
            DefiningVector := False;
            Image1.Canvas.MoveTo(aX,aY);
            Image1.Canvas.LineTo(zX,zY);
            ShowEditItems;
            Exit;
          End;

        With FWFlows[EditIndex] do
          Begin
            XORPen;

            If NextOriginX > 0 then
              Begin
                Inc(NumSegments);
                If NumSegments>Length(OriginArr) then
                  Begin
                    SetLength(OriginArr,NumSegments+20);
                    SetLength(MouthArr,NumSegments+20);
                  End;

                MouthArr[NumSegments-1].X := MapX;
                MouthArr[NumSegments-1].Y := MapY;
                OriginArr[NumSegments-1].X := NextOriginX;
                OriginArr[NumSegments-1].Y := NextOriginY;
              End;

            NextOriginX := MapX;
            NextOriginY := MapY;
          End;
        Exit;
      End;  {defining vector}

    if (Button = mbLeft) and (ToolBox1.ItemIndex >-1) and (ToolBox1.ItemIndex<2) then
      begin
        DrawingRect := TRUE;
        XORPen;
      end;
   end;
end;


{----------------------------------------------------------------------------------------------------}


procedure TGridForm.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var MapX,MapY,lngth: Integer;
    Cl: CompressedCell;
    OldCat: Integer;
    pt: TPoint;
    PSS: TSubSite;
    RSeg : Integer;
    DirStr, DBFName  : String;
    D2C,RKM  : Double;
    HasSpecificElevs: Boolean;
    PPR: ^PointRec;
    PRR: ^LineRec;

    {----------------------------------------------------------------------------------------------------}
    Procedure PanMap;
    begin
      if (not (ssLeft in Shift)) or (FLastDown.X<0) Then exit;
      pt := Mouse.CursorPos;
      Scrollbox1.VertScrollBar.Position :=
      Scrollbox1.VertScrollBar.Position + FLastDown.Y - pt.Y;
      Scrollbox1.HorzScrollBar.POsition :=
      Scrollbox1.HorzScrollBar.Position + FLastDown.X - pt.X;
      FLastDown:= pt;
    end;
    {----------------------------------------------------------------------------------------------------}
    Procedure DrawCells;
    Var i,j: Integer;
    Begin
      If (SSRight in Shift) or (SSDouble in Shift) then
        Begin  DrawingCells := False; MapTitle.Caption:=''; Exit;  End;

      If SSLeft in Shift then with SS do
        Begin
          MapX :=Trunc(X/ZoomFactor);
          MapY :=Trunc(Y/ZoomFactor);
          If (MapX>=Site.RunCols) or (MapY>=Site.RunRows) then exit;
          If (MapX<0) or (MapY < 0) then exit;

          MapX := MapX - (PenWidthBox.ItemIndex div 2);
          If MapX <0 then MapX := 0;
          MapY := MapY - (PenWidthBox.ItemIndex div 2);
          If MapY <0 then MapY := 0;

          For i := 0 to PenWidthBox.ItemIndex do
           For j := 0 to PenWidthBox.ItemIndex do
             Begin
              If (MapX+i>=Site.RunCols) or (MapY+j>=Site.RunRows) then exit;
              RetA(MapY+i,MapX+j,Cl);
              OldCat := GetCellCat(@Cl);

              If (not Large_Raster_Edit) and (OldCat = -99) and (SS.OptimizeLevel > 0) then
                  Begin
                    MessageDlg('Cannot Edit Blank Cells when any memory optimization is selected.  Change options in File-Setup.',
                                mterror,[mbok],0);
                    Exit;
                  End;

              If FillDikes
                then
                  Begin
                    Cl.ProtDikes := True;
                    DrawCell(@CL,MapY+i,MapX+j,MapY+i,MapX+j,0,True,False,False,0);     {draw dikes yellow}
                    DikesChanged := True;
                  End
                else
               If FillNoDikes
                then
                  Begin
                    Cl.ProtDikes := False;
                    DrawCell(@CL,MapY+i,MapX+j,MapY+i,MapX+j,OldCat,False,False,False,0);  {remove yellow color}
                    DikesChanged := True;
                  End
                else
                  Begin
                    ChangeCellType(@CL,OldCat,CategoryFromComboBox);
                    DrawCell(@CL,MapY+i,MapX+j,MapY+i,MapX+j,CategoryFromComboBox,False,False,False,0);
                    NWIChanged := True;
                    SS.Init_ElevStats := False;
                  End;

              Image1.Invalidate;
              LastRow := -9999;
//            SaveBitStream;

              SetA(MapY+i,MapX+j,Cl);
            End;
          exit;
        End;
    End;  {DrawCells}
    {----------------------------------------------------------------------------------------------------}
    Procedure DrawLine;
    Begin
      Image1.Canvas.MoveTo(aX,aY);
      Image1.Canvas.LineTo(zX,zY);
      ZX := X; ZY := Y;
      Image1.Canvas.MoveTo(aX,aY);
      Image1.Canvas.LineTo(zX,zY);
    End;

    {----------------------------------------------------------------------------------------------------}
    Procedure DrawDikeRect;
    Begin
      Begin
        If (Dikex1 = -99) then Exit;

        Image1.Canvas.MoveTo(aX,aY);
        Image1.Canvas.LineTo(zX,aY);
        Image1.Canvas.LineTo(zX,zY);
        Image1.Canvas.LineTo(aX,zy);
        Image1.Canvas.LineTo(aX,aY);

        ZX := X; ZY := Y;
        Image1.Canvas.MoveTo(aX,aY);
        Image1.Canvas.LineTo(zX,aY);
        Image1.Canvas.LineTo(zX,zY);
        Image1.Canvas.LineTo(aX,zy);
        Image1.Canvas.LineTo(aX,aY);
      End;
    End;
    {----------------------------------------------------------------------------------------------------}
    Procedure DrawRect;
    Begin
     with SS.Site.OutputSites[EditIndex] do with SaveRec do
      Begin
        If (x1 = -99) then Exit;

        Image1.Canvas.MoveTo(aX,aY);
        Image1.Canvas.LineTo(zX,aY);
        Image1.Canvas.LineTo(zX,zY);
        Image1.Canvas.LineTo(aX,zy);
        Image1.Canvas.LineTo(aX,aY);

        ZX := X; ZY := Y;
        Image1.Canvas.MoveTo(aX,aY);
        Image1.Canvas.LineTo(zX,aY);
        Image1.Canvas.LineTo(zX,zY);
        Image1.Canvas.LineTo(aX,zy);
        Image1.Canvas.LineTo(aX,aY);
      End;
    End;
    {----------------------------------------------------------------------------------------------------}
    Procedure DrawCellinfoBox;
    Var CatLoop: Integer;
        i: Integer;
        SSVal: Double;
    Begin
      with SS do
        Begin
          Memo1.Visible := True;

          If (PPR<> nil) or (PRR<>nil)  then Memo1.Height := 100
                       else If (ToolBox1.ItemIndex=2) then Memo1.Height := 150
                                                      else Memo1.Height := 320;

          {LOCATE MEMO BOX}
          pt.x := x-ScrollBox1.HorzScrollBar.Position+5;
          pt.y := y-ScrollBox1.VertScrollBar.Position+5;
          If (pt.y + memo1.height) > ScrollBox1.Height then
             pt.y := pt.y - memo1.height;
          If (pt.x + memo1.width) > ScrollBox1.width then
             pt.x := pt.x - memo1.width;

          If (Memo1.Top = pt.y) and (Memo1.Left=pt.x) then exit;

          Memo1.Top := pt.y;
          Memo1.Left := pt.x;
          {/ LOCATE MEMO BOX}

          If PPR<>nil then  // point infrastructure input
            Begin
              Memo1.Lines.Clear;
              Memo1.Lines.Add('Infrastructure Location');
              If HasSpecificElevs then Memo1.Lines.Add('Elev: '+FloatToStrF(PPR^.Elev,ffgeneral,4,4));
              Memo1.Lines.Add('Col: '+IntToStr(PPR^.Col)+'    Row '+IntToStr(PPR^.Row));
              Memo1.Lines.Add('Input Name: ' +DBFName);
              Memo1.Lines.Add('DBF Index: '+IntToStr(PPR^.ShpIndex));
              Memo1.Lines.Add('InundFreq: '+InundText(PPR^.InundFreq[0]));
              Update;
              Exit;
            End;

          If PRR<>nil then
            Begin
              Memo1.Lines.Clear;
              Memo1.Lines.Add('Road Location');
              If HasSpecificElevs then Memo1.Lines.Add('Elev: '+FloatToStrF(PRR^.Elev,ffgeneral,4,4));
              Memo1.Lines.Add('MapX: '+IntToStr(MapX)+'  MapY '+IntToStr(MapY));
              Memo1.Lines.Add('Col: '+IntToStr(PRR^.Col)+'    Row '+IntToStr(PRR^.Row));
              Memo1.Lines.Add('Input Name: ' +DBFName);
              Memo1.Lines.Add('DBF Index: '+IntToStr(PRR^.ShpIndex));
              If (PRR^.RoadClass > -99) then Memo1.Lines.Add('RoadClass: '+IntToStr(PRR^.RoadClass));
              Memo1.Lines.Add('InundFreq: '+InundText(PRR^.InundFreq[0]));
              Update;
              Exit;
            End;

          If (ToolBox1.ItemIndex=2) then
            Begin
              PSS := Site.GetSubSite(MapX,MapY,@Cl);

              {WRITE ON MEMO BOX}
              Memo1.Lines.Clear;
              For CatLoop := 1 to NUM_CAT_COMPRESS do
                If Cl.Widths[CatLoop] > 0 then
                  Memo1.Lines.Add('Width '+SS.Categories.GetCat(Cl.Cats[CatLoop]).TextName+' '+FloatToStrF(Cl.Widths[CatLoop],ffgeneral,4,4)+'m');

              For CatLoop := 1 to NUM_CAT_COMPRESS do
                If Cl.Widths[CatLoop] > 0  then
                   Memo1.Lines.Add('MinElev '+SS.Categories.GetCat(Cl.Cats[CatLoop]).TextName+' '+FloatToStrF(Cl.MinElevs[CatLoop],ffgeneral,4,4)+'m');
     //        Memo1.Lines.Add('Tanslope '+FloatToStrF(CL.TanSlope,ffgeneral,4,4)+' m/m');

              Memo1.Lines.Add('-------------------');
              If (CL.Pw > 0) then
                   Memo1.Lines.Add('Wave Power '+FloatToStrF(Cl.Pw,ffgeneral,4,4)+' W/m');
              If (CL.WPErosion > 0) then
                   Memo1.Lines.Add('Wave Erosion Rate '+FloatToStrF(Cl.WPErosion,ffgeneral,4,4)+' m/yr');
              If (CL.Pw > 0) then
                   Memo1.Lines.Add('-------------------');

              With SS do
                Begin
                  If UseSSRaster[1] then
                    Begin
                      SSVal := WordToFloat(SSRasters[1,1,(Site.RunCols*MapY)+MapX]);
                      If SSVal < -9.99 then Memo1.Lines.Add('Storm 1: NO DATA')
                                       else Memo1.Lines.Add('Storm 1: ' + FloatToStrF (SSVal ,ffgeneral,4,4));
                    End;

                  If UseSSRaster[2] then
                    Begin
                      SSVal := WordToFloat(SSRasters[2,1,(Site.RunCols*MapY)+MapX]);
                      If SSVal < -9.99 then Memo1.Lines.Add('Storm 2: NO DATA')
                                       else Memo1.Lines.Add('Storm 2: ' + FloatToStrF (SSVal ,ffgeneral,4,4));
                    End;
                End; // with SS

              If SS.NumFWFlows>0 then
                Begin
                  Memo1.Lines.Add('Sal. MLLW (ppt)  '+FloatToStrF(CL.Sal[1],ffgeneral,4,4));
    //            Memo1.Lines.Add('Sal. MTL (ppt)  '+FloatToStrF(CL.Sal[2],ffgeneral,4,4));
                  Memo1.Lines.Add('Sal. MHHW (ppt)  '+FloatToStrF(CL.Sal[3],ffgeneral,4,4));
                  Memo1.Lines.Add('Sal. 30D (ppt)  '+FloatToStrF(CL.Sal[4],ffgeneral,4,4));
                End;

              If (CL.ProtDikes) and (CL.ElevDikes) then Memo1.Lines.Add('DIKE ELEVATION '+FloatToStrF(getMinElev(@Cl,MapY,MapX) + (Site.RunScale*0.5)*Cl.TanSlope,ffgeneral,4,4));
              If CL.MaxFetch>=0 then Memo1.Lines.Add('Max Fetch '+FloatToStrF(Cl.MaxFetch,ffgeneral,4,4)+' km');

              For CatLoop := 1 to NUM_CAT_COMPRESS do
               If Cl.Widths[CatLoop] > 0 then
                 Case SS.Categories.GetCat(Cl.Cats[CatLoop]).AccrModel of
                   RegFM: Memo1.Lines.Add('Reg. Flood Accr '+ FloatToStrF(SS.DynamicAccretion(@CL,Cl.Cats[CatLoop],PSS,0),ffgeneral,4,4)+' mm/yr');
                   IrregFM: Memo1.Lines.Add('Irreg. Flood Accr '+ FloatToStrF(SS.DynamicAccretion(@CL,Cl.Cats[CatLoop],PSS,1),ffgeneral,4,4)+' mm/yr');
                   BeachTF: Memo1.Lines.Add('Beach/Flat Accr '+ FloatToStrF(SS.DynamicAccretion(@CL,Cl.Cats[CatLoop],PSS,2),ffgeneral,4,4)+' mm/yr');
                   TidalFM: Memo1.Lines.Add('T.Fresh Accr '+ FloatToStrF(SS.DynamicAccretion(@CL,Cl.Cats[CatLoop],PSS,3),ffgeneral,4,4)+' mm/yr');
                   InlandM: Memo1.Lines.Add('Fresh Accr '+ FloatToStrF(PSS.InlandFreshAccr,ffgeneral,4,4)+' mm/yr');
                   Mangrove: Memo1.Lines.Add('Mangrove Accr '+ FloatToStrF(PSS.MangroveAccr,ffgeneral,4,4)+' mm/yr');
                   TSwamp: Memo1.Lines.Add('Tidal Swamp Accr '+ FloatToStrF(PSS.TSwampAccr,ffgeneral,4,4)+' mm/yr');
                   Swamp: Memo1.Lines.Add('Swamp Accr '+ FloatToStrF(PSS.SwampAccr,ffgeneral,4,4)+' mm/yr');
                 End; {case}

               If SS.UpliftFileN <> '' then
                   Memo1.Lines.Add('Uplift '+ FloatToStrF(CL.Uplift,ffgeneral,4,4)+' cm/yr');

               If CL.ErosionLoss > 0 then
                   Memo1.Lines.Add('Marsh or Swamp Erosion Loss '+ FloatToStrF(CL.ErosionLoss,ffgeneral,4,4)+' m');
               If CL.BTFErosionLoss > 0 then
                   Memo1.Lines.Add('Beach or T.Flat Erosion '+ FloatToStrF(CL.BTFErosionLoss,ffgeneral,4,4)+' m');

               Memo1.Lines.Add('MTL-NAVD88 '+ FloatToStrF(CL.MTLminusNAVD ,ffgeneral,4,4)+' m');

               IF Cl.D2MLLW > -9998 then
                  Memo1.Lines.Add('D2MLLW '+ FloatToStrF(CL.D2MLLW ,ffgeneral,4,4)+' m');

               IF Cl.D2MHHW > -9998 then
                  Memo1.Lines.Add('D2MHHW '+ FloatToStrF(CL.D2MHHW ,ffgeneral,4,4)+' m');

               IF Cl.ProbSAV > -9998 then
                  Memo1.Lines.Add('ProbSAV '+ FloatToStrF(CL.ProbSAV ,ffgeneral,4,4)+' frac');

//               If Cl.RoadIndex >=0 then
//                  Memo1.Lines.Add('RoadIndex '+ IntToStr(Cl.RoadIndex));

              {WRITE ON MEMO BOX}
            End; {=2}

          If (ToolBox1.ItemIndex=3) then
            Begin
              PSS := Site.GetSubSite(MapX,MapY);
              With PSS do
                Begin
                  Memo1.Lines.Clear;
                  If PSS = Site.GlobalSite then Memo1.Lines.Add('** GLOBAL SITE ** ')
                                           else Memo1.Lines.Add('-- subsite --');
                  Memo1.Lines.Add('Desc: '+Description);
                  Memo1.Lines.Add('NWI Date: '+IntToSTr(NWI_Photo_Date));
                  Memo1.Lines.Add('DEM Date: '+IntToSTr(DEM_Date));
                  Case Direction_OffShore of
                     Southerly: DirStr := 'Southerly';
                     Northerly: DirStr := 'Northerly';
                     Easterly: DirStr := 'Easterly';
                     Westerly: DirStr := 'Westerly';
                   end{Case};
                  Memo1.Lines.Add('DirOffShore: '+DirStr);
                  Memo1.Lines.Add('MTL-NAVD88 (m): '+FloatToSTrF(NAVD88MTL_correction,ffgeneral,6,4));
                  Memo1.Lines.Add('GT Tide Range: '+FloatToSTrF(GTideRange,ffgeneral,6,4));
                  Memo1.Lines.Add('Salt Elev. (m): '+FloatToSTrF(SaltElev,ffgeneral,6,4));

                  If SS.UpliftFileN = '' then
                    Memo1.Lines.Add('Hist.trend (mm/yr): '+FloatToSTrF(Historic_trend,ffgeneral,6,4));

                  If UseAccrModel[0]
                    then Memo1.Lines.Add('Reg Flood -- DYNAMIC ACCR. MODEL')
                    else Memo1.Lines.Add('RegFloodAccrete (mm/yr): '+FloatToSTrF(FixedRegFloodAccr ,ffgeneral,6,4));
                  If UseAccrModel[1]
                    then Memo1.Lines.Add('Irreg Flood -- DYNAMIC ACCR. MODEL')
                    else Memo1.Lines.Add('IrregFloodAccrete (mm/yr): '+FloatToSTrF(FixedIrregFloodAccr ,ffgeneral,6,4));
                  Memo1.Lines.Add('Beach_Sed (mm/yr): '+FloatToStrF(Fixed_TF_Beach_Sed,ffgeneral,8,4));
                  If UseAccrModel[2]
                    then Memo1.Lines.Add('T.Flat -- DYNAMIC ACCR. MODEL');
                  If UseAccrModel[3]
                    then Memo1.Lines.Add('Tidal Fresh -- DYNAMIC ACCR. MODEL')
                    else Memo1.Lines.Add('Tidal Fresh Accrete (mm/yr): '+FloatToSTrF(FixedTideFreshAccr ,ffgeneral,6,4));

                  Memo1.Lines.Add('Inland Fresh Accrete (mm/yr): '+FloatToSTrF(InlandFreshAccr ,ffgeneral,6,4));
                  Memo1.Lines.Add('Mangrove Accrete (mm/yr): '+FloatToSTrF(MangroveAccr ,ffgeneral,6,4));
                  Memo1.Lines.Add('Swamp Accrete (mm/yr): '+FloatToSTrF(SwampAccr ,ffgeneral,6,4));
                  Memo1.Lines.Add('TSwamp Accrete (mm/yr): '+FloatToSTrF(TSwampAccr ,ffgeneral,6,4));

                  Memo1.Lines.Add('MarshErosion (m/yr): '+FloatToStrF(MarshErosion,ffgeneral,8,4));
                  Memo1.Lines.Add('SwampErosion (m/yr): '+FloatToStrF(SwampErosion,ffgeneral,8,4));
                  Memo1.Lines.Add('TFlatErosion (m/yr): '+FloatToStrF(TFlatErosion,ffgeneral,8,4));
                  If Use_Preprocessor then Memo1.Lines.Add('** ELEV. PREPROCESSOR USED **');
                End; {With PSS}
            End; {=3}

          If (ToolBox1.ItemIndex=4) then
            Begin
              {WRITE ON MEMO BOX}
              Memo1.Lines.Clear;
              Memo1.Lines.Add('');;

              If not FWInfluenced(MapY, MapX)
                then Memo1.Lines.Add('No Freshwater Influence')
                else
                  For i := 0 to (NumFWFlows-1) do
                   if FWInfluenced(MapY, MapX,i) then
                    With FWFlows[i] do
                    Begin
                      Memo1.Lines.Add('FWFlow Name '+Name);
                      If ExtentOnly then Memo1.Lines.Add('  Freshwater Extent Defined Only')
                      else If Length(NumCells) = 0
                        then Memo1.Lines.Add('  Salinity Not Initialized')
                        else
                          Begin
                            RKM := RiverKM(MapY,MapX,i,D2C);

                            Memo1.Lines.Add('RiverKM '+FloatToStrF(RKM,ffgeneral,8,4));
                            RSeg :=  Trunc (RKM / SliceIncrement);          {calculate the river segment index for this cell}
                            Memo1.Lines.Add('RSeg '+IntToStr(RSeg));
                            Memo1.Lines.Add('RetTime MLLW '+FloatToStrF(RetTime[1,RSeg],ffgeneral,8,4));
                            Memo1.Lines.Add('WaterZ MLLW '+FloatToStrF(WaterZ[1,RSeg],ffgeneral,8,4));
                            Memo1.Lines.Add('SaltWedge Z MLLW '+FloatToStrF(CL.SalHeightMLLW,ffgeneral,4,4));

    //                      Memo1.Lines.Add('SaltWedge Z MTL '+FloatToStrF(SaltHeight(0,RSeg),ffgeneral,4,4));
                            Memo1.Lines.Add('-- Vol Below MLLW '+FloatToStrF(VolumeByElev(-1.025,RSeg),ffgeneral,4,4));
                            Memo1.Lines.Add('-- SegSalin MLLW '+FloatToStrF(XS_Salinity[1,RSeg],ffgeneral,4,4));
    //                      Memo1.Lines.Add('RetTime MLLW '+FloatToStrF(RetTime[1,RSeg],ffgeneral,8,4));
    //                      Memo1.Lines.Add('WaterZ MLLW '+FloatToStrF(WaterZ[1,RSeg],ffgeneral,8,4));

                            Memo1.Lines.Add('Seg N Cells '+IntToStr(NumCells[RSeg]));
                            Memo1.Lines.Add('');
                          End;
                    End;

              {WRITE ON MEMO BOX}
            End; {=4}


          DepthLabel.Caption := 'Elev: '+FloatToStrF(GetMinElev(@Cl,MapY,MapX) ,ffgeneral,8,4) ;
          CategoryLabel.Caption := SS.Categories.GetCat(GetCellCat(@Cl)).TextName;
          XLabel2.Caption := 'X '+IntToStr(MapX);
          YLabel2.Caption := 'Y '+IntToStr(MapY);
          update;
          Exit;
        End;  {With SS}
    End;  {DrawCellinfoBox; }
    {----------------------------------------------------------------------------------------------------}
    Procedure DrawRect2;
    Begin
      with SS do
         begin
          Image1.Canvas.Rectangle(aX,aY,zX,zY);
          zX := X;
          zY := Y;
          If ToolBox1.ItemIndex=0 then   {profile tool selected}
              If ABS(zX-aX) > ABS(zY-aY)
                then zY := aY+2
                else zX := aX+2;
          Image1.Canvas.Rectangle(aX,aY,zX,zY);
          wd := abs(zX-aX);  // Width of rect - for status bar
          ht := abs(zY-aY);  // Height of rect

          Lngth := Round(Max(wd,ht)*ThisSite.RunScale/ZoomFactor);
          If ToolBox1.ItemIndex =0 then StatLabel.Caption := 'length '+IntToStr(Lngth)+'M'
                                   else StatLabel.Caption := '';
        end;
    End;
    {----------------------------------------------------------------------------------------------------}
    Procedure TestPointLocs(X2,Y2: Integer);
    Var indx, i2, arrindex: Integer;
    Begin
     arrindex := X2+(Y2*Image1.Picture.Width);
     if (ArrIndex>-1) and (ArrIndex<Length(PointLocs)) then
       If PointLocs[arrindex].Loc > -1 then
         Begin
           indx := PointLocs[X2+(Y2*Image1.Picture.Width)].Ind;
           i2   := PointLocs[X2+(Y2*Image1.Picture.Width)].Loc;
           PPR := @SS.PointInf[Indx].InfPointData[i2];
           DBFName := ExtractFileName(TInfrastructure(SS.PointInf[Indx]).InputFName);
           HasSpecificElevs := SS.PointInf[Indx].HasSpecificElevs;
         End;
    End;
    {----------------------------------------------------------------------------------------------------}
    Procedure TestRoadLocs(X2,Y2: Integer);
    Var indx, i2, arrindex: Integer;
    Begin
     arrindex := X2+(Y2*Image1.Picture.Width);
     if (ArrIndex>-1) and (ArrIndex<Length(RoadLocs)) then
       If RoadLocs[arrindex].Loc > -1 then
         Begin
           indx := RoadLocs[X2+(Y2*Image1.Picture.Width)].Ind;
           i2   := RoadLocs[X2+(Y2*Image1.Picture.Width)].Loc;
           PRR := @SS.RoadsInf[Indx].RoadData[i2];
           DBFName := ExtractFileName(TInfrastructure(SS.RoadsInf[Indx]).InputFName);
           HasSpecificElevs := SS.RoadsInf[Indx].HasSpecificElevs;
         End;
    End;
    {----------------------------------------------------------------------------------------------------}


Var Page0: Boolean;
    rt,ct: Integer;
begin  {Image1MouseMove}

  MapX :=Trunc(X/ZoomFactor);    // Get MapX and MapY from screen coordinates
  MapY :=Trunc(Y/ZoomFactor);

  PPR := nil;
  PRR := nil;
  If (InputBox.ItemIndex = 4)  // point infrastructure
   then
     Begin
       TestPointLocs(X,Y);

       If PPR=nil then
        For rt := -1 to 1 do
         For ct := -1 to 1 do
           Begin
             TestPointLocs(X+CT,Y+RT);
             If PPR<>nil then break;
           End;

     If PPR = nil then Memo1.Visible := False
                  else DrawCellInfoBox;
    End;

  If (InputBox.ItemIndex = 3)  // road infrastructure
   then
     Begin
       TestRoadLocs(X,Y);
       If PRR = nil then Memo1.Visible := False
                    else DrawCellInfoBox;
    End;


  If (MapX>=SS.Site.RunCols) or (MapY>=SS.Site.RunRows) then exit;
  If (MapX<0) or (MapY<0) then Exit;
  If SS=nil then Exit;

  SS.RetA(MapY,MapX,Cl);   // Get the cell and display the X, Y, Elevation, and Category
  XLabel2.Caption := 'X '+IntToStr(MapX);
  YLabel2.Caption := 'Y '+IntToStr(MapY);
  DepthLabel.Caption := 'Elev: '+FloatToStrF(GetMinElev(@Cl,MapY,MapX) ,ffgeneral,8,4) ;
  CategoryLabel.Caption := SS.Categories.GetCat(GetCellCat(@Cl)).TextName;

  Page0 := PageControl1.ActivePageIndex=0;
  if not (ToolBox1.Visible) or (Toolbox1.ItemIndex in [2..4]) then Memo1.Visible := False;

  if DefiningBoundary and GettingDikeElevs then Begin DrawDikeRect; Exit; End;

  // Handle the appropriate action for the selected tool
  if PanCheckBox.Checked and (not DrawingCells) and (not PolyingCells)
                         and (not FillingCells) and (not DefiningBoundary) and (not DefiningVector)
    then PanMap
    else If not (ToolPanel.Visible or PageControl1.Pages[0].TabVisible) then exit
      else if DrawingCells then DrawCells
      else if DefiningBoundary and ((not Page0) or (not (InputBox.ItemIndex = 1))) then
        Begin
          if Page0 then
            Begin
              if ((InputBox.ItemIndex = 0)) then if (SS.Site.SubSites[EditIndex].SavePoly.NumPts = 0) then exit;
              If ((InputBox.ItemIndex = 2)) then if (SS.FWFlows[EditIndex].SavePoly.NumPts = 0) then Exit;
            End;
          if PolyingCells and (NumPolyPts = 0) then Exit;
          DrawLine;
        End
      else If ((InputBox.ItemIndex = 2)) and DefiningVector and (NextOriginX >= 0) then DrawLine
      else If (InputBox.ItemIndex = 1) and DefiningBoundary then DrawRect
      else If not ToolPanel.Visible then exit
      else If (ToolBox1.ItemIndex in [2..4]) then DrawCellInfoBox
      else if DrawingRect then DrawRect2;
end;  {Image1MouseMove}

{----------------------------------------------------------------------------------------------------}


Procedure TGridForm.Graph3D;
Var  // MapSurface: TSurface;
    Subs: TSubsite;
    GridX, GridY: Integer;
    ix,iy: Integer;
    Cl:CompressedCell;
    ZMx, ZMn : Double;
    MapZn, XMn, XMx, YMn, YMx: Integer;
    Elev: Double;
    Catg: Integer;

Begin
Try
  Application.CreateForm(TDelphi3dForm,Delphi3dForm);
Except
  Raise ESLAMMError.Create('Error, video card may not support OpenGL.');
  Exit;
End;
//  Application.CreateForm(TDotDispModeDlg,DotDispModeDlg);

  GridX := Abs(aX-zX);
  GridY := Abs(aY-zY);
  Zmx := -999999;
  Zmn := 999999;
  Xmn := Min(aX,zX);
  Ymn := Min(aY,zY);
  XMx := Max(aX,zX);
  YMx := Max(aY,zY);

  If (GridX=0) or (GridY=0) then exit;

  // Set the camera transform:
  with delphi3dform do  {glDraw}
  begin

  SetupForm;

  NX := XMx - XMn + 1;
  NY := YMx - YMn + 1;
  SetLength(MapZs,NX*NY);
  SetLength(MapColors,NX*NY);
  Subs := SS.Site.GetSubSite((Xmn+Xmx) Div 2,(Ymn+Ymx) Div 2);
  SS.Site.InitElevVars;
  With SS do
   Begin
    MHWSz := (Subs.SaltElev)/site.Runscale;           // ECL salt elevation
    MHHWz := (Subs.MHHW)/site.Runscale;
    MLLWz := (Subs.MLLW)/site.Runscale;
   End;  {Upgrade, adjust by subsite?}

  MapZn := -1;
  With SS do
  For ix := XMn to XMx do
    For iy := Ymn to YMx do
      Begin
        RetA(iY,iX,CL);                           // grabbing cell from nwi array
        CatG := GetCellCat(@Cl);                 //  grabbing dominant category of cell
        Elev := GetMinElev(@Cl,iY,iX);              // '' '' ' category elevation
        If Elev > ZMx then ZMx := Elev/site.Runscale;   // seeting max elevation
        If Elev < ZMn then ZMn := Elev/site.Runscale;   // setting min elev

        Inc(MapZn);
        if elev = 999
          then MapZs[MapZn] := Elev                   // creating elevaiton array
          else MapZs[MapZn] := Elev/Site.Runscale;
        MapColors[MapZn] :=  SS.Categories.GetCat(GetCellCat(@Cl)).Color;  // creating color array
      End;

   ShowModal;

  end;

  delphi3dform.Free;
//  DotDispModeDlg.Free;
End;

procedure TGridForm.GraphBoxChange(Sender: TObject);
Var DotSizeShown: Boolean;
begin
//  If MessageDlg('Redraw Entire Map?',mtconfirmation,[mbyes,mbno],0)=mrno then Exit;

  // Zoom Factor
  ZoomFactor := ZF_From_Screen;

  // ShowRoadOld
  ShowRoadOld := False;

  ErodePanel.Visible := GraphBox.ItemIndex = 9;

  //Legend  Captions
  Case GraphBox.ItemIndex of
    0: LegendForm.TitleLabel.Caption := 'SLAMM Categories';
    1: LegendForm.TitleLabel.Caption := 'Elevations, relative to MTL';
    2..5:  LegendForm.TitleLabel.Caption := 'Salinity, ppt';
    6:   LegendForm.TitleLabel.Caption := 'Accretion, mm/year';
    7:   LegendForm.TitleLabel.Caption := 'Subsidence, mm/year';
    8:   LegendForm.TitleLabel.Caption := 'MTL Corr, m';
    9:   LegendForm.TitleLabel.Caption := 'Wave Erosion Rate (m/y)';
    10:   LegendForm.TitleLabel.Caption := 'Marsh/Swamp Erosion per cel, m';
    11:   LegendForm.TitleLabel.Caption := 'Beach/T.Flat Erosion per cel, m';
    13:   LegendForm.TitleLabel.Caption := 'Connectivity';
    14:   LegendForm.TitleLabel.Caption := 'Inundation Frequency';
    15:   LegendForm.TitleLabel.Caption := 'SAV probability';
   End; {Case}

  // Setting initial conditions in graphbox
  DrawingTopLayer := False;
  DotSizeShown := GraphBox.ItemIndex in [9..11];
  DotSizeBox.Visible := DotSizeShown;
  DotSizeLabel.Visible := DotSizeShown;

  // If show connectivity and not yet calculated ...
  if (GraphBox.ItemIndex = 13) and (not SS.ConnectCheck) then
      SS.ConnectCheck := CalculateConnect;

  //If show inundation frequency and not yet calculated ...
  if (GraphBox.ItemIndex = 14) and (not SS.InundFreqCheck)  then
    begin
      ProgForm.YearLabel.Visible       := False;
      SS.InundFreqCheck := CalculateInundFreq(SS);
      //Hide Prgress Form
      ProgForm.Hide;
      RunPanel.Visible := False;
    end;

  //If show SAV Map and not yet calculated
  if (GraphBox.ItemIndex = 15) and (not SS.SAVProbCheck) then
    SS.SAVProbCheck := SS.CalculateProbSAV(True);
  //Draw the entire map
  DrawEntireMap(0,true,false);
  ProgForm.Hide;
  RunPanel.Visible := False;

  // If show the dikes
  if ShowDikes.Checked then ShowDikesClick(nil);

end;

{----------------------------------------------------------------------------------------------------}

procedure TGridForm.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var
    i, ArrL, xmin,xmax,ymin,ymax, CellX, CellY, ScrAX, ScrAY, ScrZX, ScrZY: Integer;
    Cl:CompressedCell;
begin
  if PanCheckBox.Checked and (not DrawingCells) and (not PolyingCells)
        and (not FillingCells) and (not DefiningBoundary) and (not DefiningVector)  then
    Screen.Cursor := -2
  else
  begin

  If DrawingCells then SaveBitStream;
  If RunPanel.Visible then exit;

with SS do
 Begin
  If Not DrawingRect then Exit;

  DrawingRect := FALSE;
  zX := X;
  zY := Y;

  ScrAX := ax;
  ScrAY := ay;
  ScrzX := zx;
  Scrzy := zy;

  aX := Trunc(ax/ZoomFactor);
  aY := Trunc(aY/ZoomFactor);
  zX := Trunc(zX/ZoomFactor);
  zY := Trunc(zY/ZoomFactor);

  If  ToolBox1.ItemIndex=1 then
    Begin
     Graph3D;
     Image1.Canvas.Rectangle(ScraX,ScraY,ScrzX,ScrzY);
     Image1.Canvas.Pen.Style := psSolid;
     exit;
    End;

  If ABS(zX-aX) > ABS(zY-aY)
     then zY := aY
     else zX := aX;

  wd := abs(zX-aX);  // Width
  ht := abs(zY-aY);  // Height
  ArrL := Max(Wd,ht)+1;

  With ProfileForm do
    Begin
      MinProfile := nil;
      ColorProfile := nil;
      SetLength(MinProfile,ArrL);
      SetLength(ColorProfile,ArrL);
    End;

    Xmin := Min(aX,zX);
    Ymin := Min(aY,zY);
    XMax := Max(aX,zX);
    YMax := Max(aY,zY);

    i:=0;
    For CellX := XMin to XMax do
      For CellY := Ymin to YMax do
        Begin
          RetA(CellY,CellX,CL);

          ProfileForm.MinProfile[i]:=GetMinElev(@Cl,CellY,CelLX);
          ProfileForm.ColorProfile[i]:= SS.Categories.GetCat(GetCellCat(@Cl)).Color;
          inc(i);
        End;

  ProfileForm.ReverseAspect := False;
  ProfileForm.Scale := GridScale;
  ProfileForm.DrawProfile;
  ProfileForm.ShowModal;

  If ToolBox1.ItemIndex=0 then
     If ABS(ScrzX-ScraX) > ABS(ScrzY-ScraY)
        then ScrzY := ScraY+2
        else ScrzX := ScraX+2;
  Image1.Canvas.Rectangle(ScraX,ScraY,ScrzX,ScrzY);
  Image1.Canvas.Pen.Style := psSolid;
 End;

  end;
end;

//-----------------------------------------------------------------------------------------------------------
// ROAD MODULE FUNCTIONS AND PROCEDURES
//----------------------------------------------------------------------------------------------------------

function TGridForm.GetBoundaryCoordinates(HeadPoint, TailPoint: DPoint): DBoundary;
  var
   Tmp1, Tmp2: Double;
  begin
    // Max and Min Rows Calculation
    Tmp1 := TailPoint.Y;
    Tmp2 := HeadPoint.Y;

    if Tmp1>Tmp2  then
      begin
        Result.RowMax := ceil(Tmp1);
        Result.RowMin := floor(Tmp2);
      end
    else
      begin
        Result.RowMax := ceil(Tmp2);
        Result.RowMin := floor(Tmp1);
      end;

    // Max and Min Columns Calculation
    Tmp1 := TailPoint.X;
    Tmp2 := HeadPoint.X;
    if Tmp1>Tmp2  then
      begin
        Result.ColMax := ceil(Tmp1);
        Result.ColMin := floor(Tmp2);
      end
    else
      begin
        Result.ColMax := ceil(Tmp2);
        Result.ColMin := floor(Tmp1);
      end;
end;


procedure TGridForm.LineSegmentLengthPerCell(HeadPoint, TailPoint: DPoint; PIntPtArr: PPointArray; PNIntPt: PInteger);
var
  CellsBound: DBoundary;
  i : integer;
  RoadLine, TmpLine: DLine;
  IntPoint: DPoint;
  Tmp : double;

          {------------------------------------------------------------------------------------------------}
          function LineEqFromTwoPoints(HeadPoint, TailPoint: DPoint):DLine;
          begin
            //if (CompareValue(HeadPoint.X,TailPoint.X,0.0001) = EqualsValue) then
            if HeadPoint.X = TailPoint.X then
              begin
               Result.a := 1;
               Result.b := 0;
               Result.c := -HeadPoint.X;
              end
            //else if (CompareValue(HeadPoint.Y,TailPoint.Y,0.0001) = EqualsValue) then
            else if HeadPoint.Y = TailPoint.Y then
              begin
                Result.a := 0;
                Result.b := 1;
                Result.c := -TailPoint.Y;
              end
            else
              begin
                Result.a := TailPoint.Y - HeadPoint.Y;
                Result.b := -(TailPoint.X - HeadPoint.X);
                Result.c := - Result.a*HeadPoint.X-Result.b*HeadPoint.Y;
              end;
          end;
          {------------------------------------------------------------------------------------------------}
            function HorizontalLineEq( Row: Integer): DLine;
            begin
              Result.a := 0;
              Result.b := 1;
              Result.c := -(Row);  //*ISS.Header.dY+(ISS.Header.YllCenter-ISS.Header.dY/2));
            end;

            function VerticalLineEq(Col: Integer): DLine;
            begin
              Result.a := 1;
              Result.b := 0;
              Result.c := -(Col); // *ISS.Header.dX+(ISS.Header.XllCenter-ISS.Header.dX/2));
            end;
          {------------------------------------------------------------------------------------------------}
            function TwoLinesIntersection(Line1, Line2 : DLine): DPoint;
            var
              Det, Num: double;

              function Det2by2(a1, b1, a2, b2: double): double;
              begin
               Result := a1*b2-a2*b1;
              end;
            begin
              Det := Det2by2(Line1.a, Line1.b, Line2.a, Line2.b);

              if Det=0 then
                begin
                  MessageDlg( 'The lines are parallel. There is no intersection.',mtWarning, [mbOK], 0);
                  exit;
                end
              else
                begin
                  Num := Det2by2(-Line1.c, Line1.b, -Line2.c, Line2.b);
                  Result.X :=Num/Det;

                  Num := Det2by2(Line1.a, -Line1.c, Line2.a, -Line2.c);
                  Result.Y := Num/Det;
                end;

            end;
          {------------------------------------------------------------------------------------------------}
            procedure QuickSortPoints(Arr: DPointArray; iLo, iHI: Integer);
            Var
              Lo, Hi : Integer;
              Mid : Double;
              Tmp : DPoint;
            begin
              Lo := iLo;
              Hi := iHi;
              Mid := Arr[(Lo + Hi) div 2].X;
                repeat
                  while Arr[Lo].X < Mid do Inc(Lo);
                  while Arr[Hi].X > Mid do Dec(Hi);
                  if Lo <= Hi then
                    begin
                      Tmp := Arr[Lo];
                      Arr[Lo] := Arr[Hi];
                      Arr[Hi] := Tmp;
                      Inc(Lo);
                      Dec(Hi);
                    end;
                until Lo > Hi;
                if Hi > iLo then QuickSortPoints(Arr, iLo, Hi);
                if Lo < iHi then QuickSortPoints(Arr, Lo, iHi);
            end;
          {------------------------------------------------------------------------------------------------}

begin  // Begin LineSegmentLengthPerCell

  // Determine the boundaries in rows and columns that include the line segment
  CellsBound := GetBoundaryCoordinates(HeadPoint,TailPoint);

  // Set Intersection Point Array length
  if (CellsBound.RowMax-CellsBound.RowMin>CellsBound.ColMax-CellsBound.ColMin) then
    PNIntPt^ := (CellsBound.RowMax-CellsBound.RowMin+1)*2   //Marco: maybe this dimension can be optimized
  else
    PNIntPt^ := (CellsBound.ColMax-CellsBound.ColMin+1)*2;
  PNIntPt^ := PNIntPt^+2;
  setlength(PIntPtArr^,PNIntPt^);

  //Add head and tail of the line segment in the point array
  PIntPtArr^[0].X := HeadPoint.X;
  PIntPtArr^[0].Y := HeadPoint.Y;
  PIntPtArr^[1].X := TailPoint.X;
  PIntPtArr^[1].Y := TailPoint.Y;

  //Determine line equation of the line segment
  RoadLine := LineEqFromTwoPoints(HeadPoint,TailPoint);

  // Calculate all the intersections with vertical cells boundaries within the line segment
  PNIntPt^ := 2;

  for i := (CellsBound.ColMin+1) to (CellsBound.ColMax-1) do
   begin
    TmpLine := VerticalLineEq(i); //Get vertical line equation x-i*scale =0
    IntPoint := TwoLinesIntersection(RoadLine, TmpLine); // Intersection point calculation
    PIntPtArr^[PNIntPt^] := IntPoint;
    PNIntPt^ := PNIntPt^ +1;
   end;

  // Calculate all the intersections with horizontal cells boundaries with the line segment
  for i := (CellsBound.RowMin+1) to (CellsBound.RowMax-1) do
   begin
    TmpLine := HorizontalLineEq(i); //Get vertical line equation y-i*scale =0
    IntPoint := TwoLinesIntersection(RoadLine, TmpLine); // Intersection point calculation
    PIntPtArr^[PNIntPt^] := IntPoint;
    PNIntPt^ := PNIntPt^+1;
   end;

  // Sort the intersection points. If the line is vertical sort for increasing Y, otherwise for increasing X
  if RoadLine.b=0 then
    begin
      Tmp := PIntPtArr^[0].X;
      for i := 0 to PNIntPt^-1 do
        PIntPtArr^[i].X := PIntPtArr^[i].Y;
      QuickSortPoints(PIntPtArr^,0,PNIntPt^-1);
      for i := 0 to PNIntPt^-1 do
        begin
          PIntPtArr^[i].Y := PIntPtArr^[i].X;
          PIntPtArr^[i].X := Tmp;
        end;
    end
  else
    QuickSortPoints(PIntPtArr^,0,PNIntPt^-1);

end;

function LineEqFromTwoPoints(HeadPoint, TailPoint: DPoint):DLine;
begin
  //if (CompareValue(HeadPoint.X,TailPoint.X,0.0001) = EqualsValue) then
  if HeadPoint.X = TailPoint.X then
    begin
     Result.a := 1;
     Result.b := 0;
     Result.c := -HeadPoint.X;
    end
  //else if (CompareValue(HeadPoint.Y,TailPoint.Y,0.0001) = EqualsValue) then
  else if HeadPoint.Y = TailPoint.Y then
    begin
      Result.a := 0;
      Result.b := 1;
      Result.c := -TailPoint.Y;
    end
  else
    begin
      Result.a := TailPoint.Y - HeadPoint.Y;
      Result.b := -(TailPoint.X - HeadPoint.X);
      Result.c := - Result.a*HeadPoint.X-Result.b*HeadPoint.Y;
    end;
end;

{-----------------------------------------------------------------------}{-----------------------------------------------------------------------}

procedure TGridForm.ImportRoadClick;
var
  RdIndex: Integer;
  i, j, k, m : Integer;
  StudyXMin, StudyXMax, StudyYMin, StudyYMax: Double;
  StudyX1, StudyY1, StudyX2, StudyY2: Double;
  CellX, CellY : Integer;
  ShapeList : TSVOShapeList;
  TRI: TRoadInfrastructure;
  LineShape : TSVOLineShape;
  ReadElevs: TModalResult;
  DataPoints: TSVOShapePointArray;
  NIntPt : Integer;
  IntPtArr: DPointArray;
  HeadPoint, TailPoint: DPoint;
  Dist: Double;
  DBFFileN: String;
  InitFields: Integer;
  TempFieldDefs: TDbfFieldDefs;
  RoadClassIndex, RoadClassNum: Integer;

        {-----------------------------------------------------------------------}

        Procedure ReadDBFHeader;
        Var  DBF1: TDBF;
             K: Integer;
        Begin
          RoadClassIndex := -1;  //initialize;
          If not FileExists(DBFFileN) then
            Begin
              MessageDlg('Error:  DBF File '+DBFFileN+' does not exist',mterror,[mbok],0);
              Exit;
            End;

          DBF1 := TDBF.Create(nil);
          DBF1.TableName := DBFFileN;

          DBF1.Open;
          DBF1.Active := True;

          TempFieldDefs := TDBFFieldDefs.Create(DBF1);
          TempFieldDefs.Assign (Dbf1.DbfFieldDefs);
          InitFields := TempFieldDefs.Count;
          DBF1.Close;
          DBF1.Free;

          SelectListForm.ComboBox1.Clear;
          If TempFieldDefs.Count =0 then exit;

          For k:=0 to TempFieldDefs.Count-1 do
            With TempFieldDefs.Items[k] do
              SelectListForm.Combobox1.Items.Add(String(FieldName));

          If SelectListForm.ShowModal = mrcancel then exit;
          RoadClassIndex := SelectListForm.Combobox1.ItemIndex;

        End;

        {-----------------------------------------------------------------------}

        Procedure  WriteNewDBF(NewDBFName: String);
        Var  DBFOld, DBFNew: TDBF;
             n, k: Integer;
        Begin
          If not FileExists(DBFFileN) then exit;
          DBFNew := TDBF.Create(nil);
          DBFNew.TableName := NewDBFName;
          DBFNew.CreateTableEx(TempFieldDefs);

          DBFOld := TDBF.Create(nil);
          DBFOld.TableName := DBFFileN;
          DBFOld.Active := True;
          DBFOld.DisableControls;

          DBFNew.Active := True;
          DBFNew.First;
          DBFNew.DisableControls;

          ProgForm.Setup('Creating DBF File','','','',False);

          For n := 0 to TRI.NRoads-1 do
           With SS.Site do
            Begin
              ProgForm.Update2Gages(Trunc(100*(n/(TRI.NRoads-1))),0);
              DBFOld.RecNo := TRI.RoadData[n].ShpIndex+1;  // 1/21/2016 RecNo is not zero indexed
              DBFNew.Append;
              For k := 0 to DbfOld.FieldCount-1 do
                DBFNew.Fields[k].Value := DBFOld.Fields[k].value;
              DBFNew.Post
           End;

          ProgForm.Cleanup;

          DBFNew.Free;
          DBFOld.Free;
        End;

        {-----------------------------------------------------------------------}

        Procedure OutputSegments;
        Var OutLineShape: TSVOLineShape;
            OutShapeList: TSVOShapeList;
            OutDPoints  : TSVOShapePointArray;
            n: Integer;
            DbP         : TDoublePoint;
        Begin
          OutShapeList := TSVOShapeList.Create;

          ProgForm.Setup('Creating Shape File','','','',False);

          For n := 0 to TRI.NRoads-1 do
           With SS.Site do
            Begin
              ProgForm.Update2Gages(Trunc(100*(n/(TRI.NRoads-1))),0);

              OutDPoints := TSVOShapePointArray.Create(2);

              DbP.X := (TRI.RoadData[n].X1 * RunScale) + StudyXMin;
              DbP.Y := -(RunScale*(TRI.RoadData[n].Y1-RunRows)) + StudyYMin;
              OutDPoints[0] := DbP;

              DbP.X := (TRI.RoadData[n].X2 * RunScale) + StudyXMin;
              DbP.Y := -(RunScale*(TRI.RoadData[n].Y2-RunRows)) + StudyYMin;
              OutDPoints[1] := DbP;

              OutLineShape := TSVOLineShape.Create(OutShapeList,OutDPoints);
           End;

          TRI.InputFName := '';
          ProgForm.Cleanup;
          Repeat
            If not SaveDialog1.Execute(self.Handle) then Exit;
            If (SaveDialog1.FileName = OpenDialog1.Filename) then MessageDlg('Cannot Overwrite Original Shapefile.',mterror,[mbok],0);
          Until (SaveDialog1.FileName <> OpenDialog1.Filename);

          SVOGISReadWrite2.FileType := sftShapeFile;
          SVOGISReadWrite2.ShapeList := OutShapeList;

          Application.ProcessMessages;
          SVOGISReadWrite2.ExportFileName := SaveDialog1.Filename;

          ProgForm.Setup('Writing Shape File','','','',False);
          Application.ProcessMessages;
          SVOGISReadWrite2.WriteFile;
          ProgForm.Cleanup;
          Application.ProcessMessages;
          WriteNewDBF(ChangeFileExt(SaveDialog1.FileName,'.dbf'));

          With TRI do
           If FileExists(ChangeFileExt(OpenDialog1.Filename,'.prj')) then
             CopyFile(ChangeFileExt(OpenDialog1.Filename,'.prj'),ChangeFileExt(SaveDialog1.FileName,'.prj'));
          With TRI do
           If FileExists(ChangeFileExt(OpenDialog1.Filename,'.qpj')) then
             CopyFile(ChangeFileExt(OpenDialog1.Filename,'.qpj'),ChangeFileExt(SaveDialog1.FileName,'.qpj'));

          TRI.InputFName := SaveDialog1.Filename;
        End;

        {-----------------------------------------------------------------------}

Var {Conv: Double; Rslt,}
    ErrNum, RoadClassI: Integer;
    RoadVar: Variant;

                {-----------------------------------------------------------------------}
                Procedure GetRoadClassNum;   //  OPTIMIZE IF POSSIBLE
                Begin
                      RoadClassNum := -999;
                      If RoadClassIndex > -1 then
                        Begin
                          ShapeList.DataFields.RecordNum := i;
                          Try
                           RoadVar := (ShapeList.DataFields.Items[RoadClassIndex].Value);
                          If (RoadVar<>Null)  then
                            Begin
                              RoadClassNum := RoadVar;
//                              RoadClassStr := RoadVar;
//                              Val(Trim(RoadClassStr),Conv,Rslt);
//                              If Rslt = 0 then RoadClassNum := Round(Conv);
                            End;
                          Except
                            RoadClassNum := -999;
                          End;
                        End;
                End;
                {-----------------------------------------------------------------------}

begin       {ImportRoadClick}
  RoadClassI := -999;
  RdIndex := EditBox.ItemIndex;
  If SS.NRoadInf = 0
    then AddEstClick(nil)
    else with SS.RoadsInf[RdIndex] do
      if NRoads > 0 then
        Begin
          Application.NormalizeTopMosts;
          If MessageDlg('Overwrite Roads Data '+IDName+'?',mtConfirmation,[mbOK,mbCancel],0) = mrcancel then exit;
          SS.RoadsInf[RdIndex].Free;
          ClearRoadLocs;
          SS.RoadsInf[RdIndex] := TRoadInfrastructure.Create(SS);
        End;

  RdIndex := EditBox.ItemIndex;
  TRI := SS.RoadsInf[EditBox.ItemIndex];

  IF Not OpenDialog1.Execute Then Exit;

  If LowerCase(ExtractFileExt(OpenDialog1.FileName)) = '.csv' then       // HANDLE CSV Files and Exit
    Begin
      ReadElevs := MessageDlg('Read Elevations from CSV file?',mtConfirmation,[mbYes,mbNo,mbCancel],0);
      If ReadElevs=mrcancel then Exit;
      TRI.HasSpecificElevs := (ReadElevs=MRYes);
      TRI.ReadRoadCSVFile(OpenDialog1.FileName);
      If TRI.HasSpecificElevs then TRI.Overwrite_Elevs;
      ShowEditItems;
      Exit;
    End;

  { ------  Load Shape File --------}
  SVOGISReadWrite1.FileType := sftShapeFile;
  ShapeList := TSVOShapeList.Create;
  SVOGISReadWrite1.ShapeList := ShapeList;
  SVOGISReadWrite1.ImportFileName := OpenDialog1.Filename;

  DBFFileN := ChangeFileExt(OpenDialog1.Filename,'.dbf');
  ReadDBFHeader;

  ProgForm.Setup('Reading Shape File','','','',False);

  ErrNum := SVOGISReadWrite1.ReadFile;
  If ErrNum > 0 then
      Begin
        MessageDlg('Error Reading shape file '+ OpenDialog1.Filename,mterror,[mbOK],0);
        ShapeList.Free;
        Exit;
      End;

  OpenDialog1.InitialDir := ExtractFileDir(OpenDialog1.FileName);  // set directory for next time
  If TRI.IDName = 'New Roads Layer' then TRI.IDName := ExtractFileName(OpenDialog1.FileName);

  With SS.Site do
    Begin
      StudyXMin := LLXCorner;              // projection units
      StudyXMax := LLXCorner + RunCols*RunScale;
      StudyYMin := LLYCorner;
      StudyYMax := LLYCorner + RunRows*RunScale;
    End;

  SetLength(TRI.RoadData,ShapeList.Count);  // minimum size
  TRI.NRoads := 0;
  TRI.InputFName := OpenDialog1.Filename;
  TRI.HasSpecificElevs := False; // don't automatically import elevations


  For i := 0 to ShapeList.Count-1 do    // i lines
    Begin
      LineShape := TSVOLineShape(ShapeList.Items[i]);

      If LineShape.ShapeType <> STLine then
         Begin
           MessageDlg('Error, Infrastructure ShapeFile must be a "Line" shapefile',mterror,[mbOK],0);
           ShapeList.Free;
           Exit;
         End;

      ProgForm.Update2Gages(Trunc(100*(i/(ShapeList.Count-1))),0);

      For j := 0 to LineShape.PartsList.Count-1 do  // j parts to each line
       For k := 0 to LineShape.PartsList.Items[j].Count-2 do // k points in each part
         Begin
           DataPoints := LineShape.PartsList.Items[j];

           With SS.Site do  // transform from projection units to a floating point on the SLAMM scale [0..NRow-1, 0..NCol-1]
             Begin
               StudyX1 := (DataPoints[k].X - StudyXMin) / RunScale;
               StudyY1 := RunRows-(DataPoints[k].Y - StudyYMin) / RunScale;
               StudyX2 := (DataPoints[k+1].X - StudyXMin) / RunScale;
               StudyY2 := RunRows-(DataPoints[k+1].Y - StudyYMin) / RunScale;
             End;

           If ((StudyX1>0) and (StudyY1>0) and (StudyX1<SS.Site.RunCols) and (StudyY1<SS.Site.RunRows)) or
              ((StudyY2>0) and (StudyY2>0) and (StudyX2<SS.Site.RunCols) and (StudyY2<SS.Site.RunRows))      // at least part of this segment is relevant
              then
                Begin

                  HeadPoint.X := StudyX1; HeadPoint.Y := StudyY1;
                  TailPoint.X := StudyX2; TailPoint.Y := StudyY2;

                  LineSegmentLengthPerCell(HeadPoint, TailPoint,@IntPtArr,@NIntPt);  // return all of the individual road segments clipped to the raster cells

                  // Calculate length between intersection point and the cell it belongs to
                  for m := 1 to NIntPt-1 do
                    begin
                      //Length
                      Dist := sqrt(sqr(IntPtArr[m].X-IntPtArr[m-1].X)+sqr(IntPtArr[m].Y-IntPtArr[m-1].Y));

                      //MidPoint calculation
                      CellX := floor((IntPtArr[m].X+IntPtArr[m-1].X)/2);
                      CellY := floor((IntPtArr[m].Y+IntPtArr[m-1].Y)/2);

                      If (i<>RoadClassI) then
                        Begin
                          GetRoadClassNum;
                          RoadClassI := i;
                        End;

                      //Update RoadData
                      If ((CellX>=0) and (CellY>=0) and (CellX<SS.Site.RunCols) and (CellY<SS.Site.RunRows)) then
                      If CellClass(CellX,CellY) <> -99 then
                        begin
                          inc(TRI.NRoads);

                          If TRI.NRoads > length(TRI.RoadData) then SetLength(TRI.RoadData,Trunc(TRI.NRoads*1.5));

                          With TRI.RoadData[TRI.NRoads-1] do
                            Begin
                              ShpIndex := i;  // index in original shape file dbf
                              Row := CellY;
                              Col := CellX;

                              X1 := IntPtArr[m-1].X;
                              Y1 := IntPtArr[m-1].Y;

                              X2 := IntPtArr[m].X;
                              Y2 := IntPtArr[m].Y;
                              LineLength := Dist;

                              SetLength(InundFreq,1);  // minimum length;
                              RoadClass := RoadClassNum;
                              elev := -999;
                            End;  // with
                        end; // CellX and CellY in raster box
                  end;   // m loop
                End; // if part of the line is in the raster
         End; // j & k loop
    End; // i loop

  ProgForm.Cleanup;
  If TRI.NRoads=0 then MessageDlg('Error, No Roads in Infrastructure ShapeFile within Map.  ShapeFiles must have the same projection as project rasters.',mterror,[mbOK],0);
  ShowEditItems;
  UpdateEditBox;

  SVOGISReadWrite1.Active := False;
  SVOGISReadWrite1.Shapelist.Destroy;

  If TRI.NRoads>0 then OutputSegments;
end;


{-----------------------------------------------------------------------}{-----------------------------------------------------------------------}

procedure TGridForm.ImportShpClick(Sender: TObject);
var
  ErrNum, InfIndex: Integer;
  i : Integer;
  StudyXMin, StudyXMax, StudyYMin, StudyYMax: Double;
  StudyX, StudyY: Integer;
  FloatX, FloatY: Double;
  ShapeList : TSVOShapeList;
  TPI: TPointInfrastructure;
  Cl: CompressedCell;
  PointShape : TSVOPointShape;

  DBFFileN: String;
  InitFields: Integer;
  TempFieldDefs: TDbfFieldDefs;

        {-----------------------------------------------------------------------}

        Procedure ReadDBFHeader;
        Var  DBF1: TDBF;
        Begin
          If not FileExists(DBFFileN) then
            Begin
              MessageDlg('Error:  DBF File '+DBFFileN+' does not exist',mterror,[mbok],0);
              Exit;
            End;

          DBF1 := TDBF.Create(nil);
          DBF1.TableName := DBFFileN;

          DBF1.Open;
          DBF1.Active := True;

          TempFieldDefs := TDBFFieldDefs.Create(DBF1);
          TempFieldDefs.Assign (Dbf1.DbfFieldDefs);
          InitFields := TempFieldDefs.Count;
          DBF1.Close;
          DBF1.Free;
        End;

        {-----------------------------------------------------------------------}

        Procedure  WriteNewDBF(NewDBFName: String);
        Var  DBFOld, DBFNew: TDBF;
             n, k: Integer;
        Begin
          If not FileExists(DBFFileN) then exit;
          DBFNew := TDBF.Create(nil);
          DBFNew.TableName := NewDBFName;
          DBFNew.CreateTableEx(TempFieldDefs);

          DBFOld := TDBF.Create(nil);
          DBFOld.TableName := DBFFileN;
          DBFOld.Active := True;
          DBFOld.DisableControls;

          DBFNew.Active := True;
          DBFNew.First;
          DBFNew.DisableControls;

          ProgForm.Setup('Creating DBF File','','','',False);

          For n := 0 to TPI.NPoints-1 do
           With SS.Site do
            Begin
              ProgForm.Update2Gages(Trunc(100*((n+1)/(TPI.NPoints))),0);
              DBFOld.RecNo := TPI.InfPointData[n].ShpIndex + 1;          // 1/21/2016 RecNo is not zero indexed
              DBFNew.Append;
              For k := 0 to DbfOld.FieldCount-1 do
                DBFNew.Fields[k].Value := DBFOld.Fields[k].value;
              DBFNew.Post
           End;

          ProgForm.Cleanup;

          DBFNew.Free;
          DBFOld.Free;
        End;

        {-----------------------------------------------------------------------}

        Procedure OutputPoints;
        Var OutPointShape: TSVOPointShape;
            OutShapeList: TSVOShapeList;
            OutPoint     : TDoublePoint;
            n: Integer;
        Begin
          OutShapeList := TSVOShapeList.Create;

          ProgForm.Setup('Creating Shape File','','','',False);

          For n := 0 to TPI.NPoints-1 do
           With SS.Site do
            Begin
              ProgForm.Update2Gages(Trunc(100*((n+1)/(TPI.NPoints))),0);

              OutPoint.X := (TPI.InfPointData[n].X * RunScale) + StudyXMin;
              OutPoint.Y := -(RunScale*(TPI.InfPointData[n].Y-RunRows)) + StudyYMin;

              OutPointShape := TSVOPointShape.Create(OutShapeList);
              OutPointShape.SetShape(OutPoint);
           End;

          TPI.InputFName := '';
          ProgForm.Cleanup;
          Repeat
            Application.NormalizeTopMosts;
            If not SaveDialog1.Execute then Exit;
            If (SaveDialog1.FileName = OpenDialog1.Filename) then MessageDlg('Cannot Overwrite Original Shapefile.',mterror,[mbok],0);
          Until (SaveDialog1.FileName <> OpenDialog1.Filename);

          SVOGISReadWrite2.FileType := sftShapeFile;
          SVOGISReadWrite2.ShapeList := OutShapeList;

          Application.ProcessMessages;
          SVOGISReadWrite2.ExportFileName := SaveDialog1.Filename;

          ProgForm.Setup('Writing Shape File','','','',False);
          Application.ProcessMessages;
          SVOGISReadWrite2.WriteFile;
          ProgForm.Cleanup;
          Application.ProcessMessages;

          WriteNewDBF(ChangeFileExt(SaveDialog1.FileName,'.dbf'));

          With TPI do
           If FileExists(ChangeFileExt(OpenDialog1.Filename,'.prj')) then
             CopyFile(ChangeFileExt(OpenDialog1.Filename,'.prj'),ChangeFileExt(SaveDialog1.FileName,'.prj'));
          With TPI do
           If FileExists(ChangeFileExt(OpenDialog1.Filename,'.qpj')) then
             CopyFile(ChangeFileExt(OpenDialog1.Filename,'.qpj'),ChangeFileExt(SaveDialog1.FileName,'.qpj'));

          TPI.InputFName := SaveDialog1.Filename;
        End;

        {-----------------------------------------------------------------------}


begin
  If (InputBox.ItemIndex = 3) then Begin ImportRoadClick; Exit; End;

  InfIndex := EditBox.ItemIndex;
  If SS.NPointInf = 0
    then AddEstClick(nil)
    else with SS.PointInf[InfIndex] do
      if NPoints > 0 then
        Begin
          Application.NormalizeTopMosts;
          If MessageDlg('Overwrite internal SLAMM Infrastructure Data "'+IDName+'?"',mtConfirmation,[mbOK,mbCancel],0) = mrcancel then exit;
          SS.PointInf[InfIndex].Free;
          SS.PointInf[InfIndex] := TPointInfrastructure.Create(SS);
        End;

  InfIndex := EditBox.ItemIndex;
  TPI := SS.PointInf[EditBox.ItemIndex];

  IF Not OpenDialog1.Execute THEN Exit;

  IF OpenDialog1.FilterIndex = 1 Then SVOGISReadWrite1.FileType := sftShapeFile;
  IF OpenDialog1.FilterIndex = 2 Then
    Begin
      MessageDlg('Error, Infrastructure ShapeFile must be a "*.shp" shapefile',mterror,[mbOK],0);
      Exit;
    End;

    ShapeList := TSVOShapeList.Create;
    SVOGISReadWrite1.ShapeList := ShapeList;
    SVOGISReadWrite1.ImportFileName := OpenDialog1.Filename;

    DBFFileN := ChangeFileExt(OpenDialog1.Filename,'.dbf');
    ReadDBFHeader;

    ProgForm.Setup('Reading Shape File','','','',False);

    ErrNum := SVOGISReadWrite1.ReadFile;
    If ErrNum > 0 then
        Begin
          MessageDlg('Error Reading shape file '+ OpenDialog1.Filename,mterror,[mbOK],0);
          SVOGISReadWrite1.Active := False;
          SVOGISReadWrite1.Shapelist.Destroy;
          Exit;
        End;

    OpenDialog1.InitialDir := ExtractFileDir(OpenDialog1.FileName);  // set directory for next time
    If TPI.IDName = 'New Infr. Layer' then TPI.IDName := ExtractFileName(OpenDialog1.FileName);

  With SS.Site do
    Begin
      StudyXMin := LLXCorner;              // projection units
      StudyXMax := LLXCorner + RunCols*RunScale;
      StudyYMin := LLYCorner;
      StudyYMax := LLYCorner + RunRows*RunScale;
    End;

  SetLength(TPI.InfPointData,ShapeList.Count);  // minimum size
  TPI.NPoints := 0;
  TPI.InputFName := OpenDialog1.Filename;


  For i := 0 to ShapeList.Count-1 do
    Begin
      PointShape := TSVOPointShape(ShapeList.Items[i]);

      If PointShape.ShapeType <> STPoint then
         Begin
           MessageDlg('Error, Infrastructure ShapeFile must be a "point" shapefile',mterror,[mbOK],0);
           ShapeList.Free;
           Exit;
         End;

      With SS.Site do
        Begin                // transform from projection units to the SLAMM scale [0..NRow-1, 0..NCol-1]
          StudyX := Trunc((PointShape.Data.X - StudyXMin) / RunScale);
          StudyY := Trunc(RunRows-((PointShape.Data.Y - StudyYMin) / RunScale));

          FloatX := (PointShape.Data.X - StudyXMin) / RunScale;
          FloatY := RunRows-((PointShape.Data.Y - StudyYMin) / RunScale);
        End;

      If (StudyX>0) and (StudyY>0) and (StudyX<SS.Site.RunCols) and (StudyY<SS.Site.RunRows) then
        If CellClass(StudyX,StudyY) <> -99 then
          Begin
            Inc(TPI.NPoints);
            TPI.InfPointData[TPI.NPoints-1].ShpIndex := i;  // index in shape file dbf
            TPI.InfPointData[TPI.NPoints-1].Row := StudyY;
            TPI.InfPointData[TPI.NPoints-1].Col := StudyX;

            TPI.InfPointData[TPI.NPoints-1].X := FloatX;
            TPI.InfPointData[TPI.NPoints-1].Y := FloatY;

            SS.RetA(StudyY,StudyX,Cl);
            TPI.InfPointData[TPI.NPoints-1].Elev := -999;
            SetLength(TPI.InfPointData[TPI.NPoints-1].InundFreq,1);
            TPI.InfPointData[TPI.NPoints-1].InundFreq[0] := 0;

            TPI.InfPointData[TPI.NPoints-1].InfPointClass := -999;
          End;
    End;

  If TPI.NPoints=0 then MessageDlg('Error, No Points in Infrastructure ShapeFile within Map.  Please check Projection.',mterror,[mbOK],0);

  ShowEditItems;
  UpdateEditBox;

  SVOGISReadWrite1.Active := False;
  SVOGISReadWrite1.Shapelist.Destroy;

  If (TPI.NPoints>0) then OutputPoints;

end;

{----------------------------------------------------------------------------------------------------}

procedure TGridForm.FillDikesBoxClick(Sender: TObject);
begin

  FillDikes:= FillDikesBox.Checked;

  If FillDikes then FillNoDikes := False;
  If FillDikes then FillNoDikesBox.Checked := False;

  CategoryBox.Enabled := Not FillDikes and Not FillNoDikes;

end;

procedure TGridForm.FillDryLandButtonClick(Sender: TObject);
var
 ER, EC: integer;
 CL: Compressedcell;
 DevDryLand, UndDryLand, CC: Integer;
 CE: double;


begin

  If MessageDlg('Are you sure you want to fill blanks cells as dry land?',mtconfirmation,[mbyes,mbno],0)=Mrno then Exit;

  DevDryLand := -99; UndDryLand := -99;
  For CC:= SS.Categories.NCats-1 downto 0 do
   With SS.Categories.GetCat(cc) do
    Begin
      If IsDryland and (not IsDeveloped) then UndDryLand := CC;
      If IsDryland and IsDeveloped then DevDryLand := CC;
    End;

  If (DevDryLand = -99) and (UndDryLand = -99) then
    Begin
      MessageDlg('No dry land categories (IsDryLand) found.',mterror,[mbok],0);
      Exit;
    End;

  ProgForm.Setup('Filling Dry Land','','','',False);
  with SS do
   for ER :=0 to MapNR- 1 do
    begin
      ProgForm.Update2Gages(Trunc(100*(ER/MapNR-1)),0);
      for EC:=0 to MapNC-1 do
        begin

        // Get the cell
        RetA(ER,EC,CL);

        // Get cell category
        CC := GetCellCat(@CL);

        // Get elevation
        CE := CatElev(@CL,CC);

        if (CE <> NO_DATA ) and (CC=-99) and (CE <> 999) {and (ROSArray[(Site.Cols*ER)+EC] >0)} then
          begin
            // How to change the categories
            SetCellWidth(@CL,-99,0);  {loss first to minimize data loss due to compression}

            //Set cell coverage to Dry Land
            if (CL.ImpCoeff> 25) and (DevDryLand<>-99) then
              begin
                SetCellWidth(@CL,devdryland,gridscale);
                SetCatElev(@CL,devdryland,CE);
              end
            else
              begin
                SetCellWidth(@CL,unddryland,gridscale);
                SetCatElev(@CL,unddryland,CE);
              end;

            // Set cell
            SetA(ER,EC,CL);

            //DrawCell(@CL,ER,EC,blank,False,False,False);
            NWIChanged := True;
            SS.Init_ElevStats := False;
          end;
        end;
    end;

    ProgForm.Cleanup;

    if NWIChanged=True then
      Begin
        DrawEntireMap(0,True,False);
        ProgForm.Hide;
        RunPanel.Visible := False;
      End;

{*   if GridForm.NWIChanged then
    begin
      if PromptforFileName(pName,'ASC Files (*.ASC)|*.ASC','','Save your grid file','',True) then
      begin
        pName := ChangeFileExt(pName,'.ASC');
        SS.SaveRaster(pName,2 );
        SS.NWIFileN := pName;
      end;
    end;
*}
    //GridForm.NWIChanged := False;

    //MainForm.SaveSimClick(Sender);

      // Change the NWI raster
      // Redraw on the fly (inside if) or at the end

end;

{-----------------------------------------------------------------------}{-----------------------------------------------------------------------}

procedure TGridForm.MangtoTransButtonClick(Sender: TObject);
var
 ER, EC: integer;
 CL: Compressedcell;
 CC, Mangrove, ScrubShrub: Integer;

begin
  If SS.Categories.AreCalifornia then
    Begin
      MessageDlg('Not relevant to California categories',mtconfirmation,[MBOK],0);
      Exit;
    End;

  Mangrove := 8; ScrubShrub := 6;  // traditional SLAMM categories

  If MessageDlg('Are you sure you want to convert Mangroves to Transitional Marsh',mtconfirmation,[mbyes,mbno],0)=Mrno then Exit;

  ProgForm.Setup('Converting Mangroves','','','',False);

  with SS do
   for ER :=0 to MapNR- 1 do
    begin
      //Gauge update
      ProgForm.Update2Gages(Trunc(100*(ER/MapNR-1)),0);

      for EC:=0 to MapNC-1 do
        begin
          // Get the cell
          RetA(ER,EC,CL);

          // Get cell category
          CC := GetCellCat(@CL);

          if (CC=Mangrove) then
            begin
              ChangeCellType(@CL,Mangrove,ScrubShrub);

              // Set cell
              SetA(ER,EC,CL);

              //Wetland layer changed
              NWIChanged := True;
              SS.Init_ElevStats := False;
            end;
        end;
    end;

    ProgForm.Cleanup;

    if NWIChanged=True then
      DrawEntireMap(0,True,False)
    else
      MessageDlg('No Mangroves found.', mtInformation, [mbOk], 0, mbOk);

   ProgForm.Hide;
   RunPanel.Visible := False;
end;

procedure TGridForm.MarshBordersButtonClick(Sender: TObject);

var
 IrregFloodMarsh, RegFloodMarsh, ER, EC: integer;
 CL: Compressedcell;
 CC: Integer;
 CE: double;
 Subsite : TSubsite;
// MinElev, MaxElev : double;

begin
  If SS.Categories.AreCalifornia then
    Begin
      IrregFloodMarsh := 14;
      RegFloodMarsh := 19; // CA SLAMM categories
    End
  else
    Begin
      IrregFloodMarsh := 19;
      RegFloodMarsh := 7;  // classic SLAMM categories
    End;

  If MessageDlg('Are you sure you want to define marsh boundaries using tide information?',mtconfirmation,[mbyes,mbno],0)=Mrno then Exit;

  ProgForm.Setup('Defining marsh boundaries','','','',False);
  with SS do
   for ER :=0 to MapNR- 1 do
    begin
      //Gauge update
      ProgForm.Update2Gages(Trunc(100*(ER/MapNR-1)),0);

      for EC:=0 to MapNC-1 do
        begin
          //Get the cell
          RetA(ER,EC,CL);

          //Get cell category
          CC := GetCellCat(@CL);

          // Get elevation
          CE := CatElev(@CL,CC);

          // Irregularly to Regularly if MinElevIrr<LowerBoundElev
          if (CC=IrregFloodMarsh) and (CE <> NO_DATA) and (CE <> 999) then
            begin
              SubSite := Site.GetSubSite(EC,ER,@CL);
              if CE<Lowerbound(CC,Subsite) then
                ChangeCellType(@CL,CC,RegFloodMarsh);

              // Set cell
              SetA(ER,EC,CL);

              //Wetland layer changed
              NWIChanged := True;
              SS.Init_ElevStats := False;
            end;

          // Regularly to Irregularly if MaxElevReg>UpperBoundElev
          if (CC=RegFloodMarsh) and (CE <> NO_DATA ) and (CE <> 999) then
            begin
              SubSite := Site.GetSubSite(EC,ER,@CL);
              if CE>Upperbound(CC,Subsite) then
                ChangeCellType(@CL,CC,IrregFloodMarsh);

              // Set cell
              SetA(ER,EC,CL);

              //Wetland layer changed
              NWIChanged := True;
              SS.Init_ElevStats := False;
            end;

        end;
    end;

    ProgForm.Cleanup;

    if NWIChanged=True then
      DrawEntireMap(0,True,False);

    ProgForm.Hide;
    RunPanel.Visible := False;
end;



procedure TGridForm.FillNoDikesBoxClick(Sender: TObject);
begin

  FillNoDikes:= FillNoDikesBox.Checked;

  If FillNoDikes then FillDikes := False;
  If FillNoDikes then FillDikesBox.Checked := False;

  CategoryBox.Enabled := Not FillDikes and Not FillNoDikes;

end;

Procedure TGridForm.FillCategoryBox;
Var i: Integer;
Begin
  CategoryBox.Items.Clear;
  For i:= 0 to SS.Categories.NCats-1 do
    CategoryBox.Items.Add(SS.Categories.GetCat(i).TextName);
  CategoryBox.Items.Add('Blank');

End;

function TGridForm.CategoryFromComboBox: Integer;
begin
  If CategoryBox.ItemIndex = SS.Categories.NCats then Result := -99
                                            else Result := CategoryBox.ItemIndex;
end;

procedure TGridForm.ChangeCellType(CL: PCompressedCell; OldCat,NewCat: Integer);
Var i:integer;
begin
  FOR i := 1 to NUM_CAT_COMPRESS DO
    If Cl.Cats[i] = OldCat then
      Begin
        Cl.Cats[i] := NewCat;
        Break;
      End;
end;

Procedure TGridForm.SaveMapToGIF(Var FileN: String);
var SaveGIF : TGIFImage;
    FN: String;
    FIter:Integer;

begin
  ProgForm.ProgressLabel.Caption   := 'Saving to GIF';
  ProgForm.Update;
  SaveGIF := TGIFImage.Create;
  try
    SaveGIF.Assign(Image1.Picture.Bitmap);
    FN := FileN + '.gif';
    FIter := 0;
    While FileExists(FN) do
      Begin
        Inc(FIter);
        FN := FileN+IntToStr(FIter)+'.gif';
      End;

    FileN := FN;
    SaveGIF.SaveToFile(FN);
  except
    SaveGIF.Free;
    Raise ESLAMMError.Create('Cannot save GIF file to '+FN);
  end;

  SaveGIF.Free;
end;



procedure TGridForm.SaveSubsiteRasterClick(Sender: TObject);
var
  pName: String;
begin
    if PromptforFileName(pName,'ASC Files (*.ASC)|*.ASC','','Save your grid file','',True) then
      begin
        pName := ChangeFileExt(pName,'.ASC');
        SS.SaveRaster(pName,4 );
      end;
end;

procedure TGridForm.SaveWetlandRasterClick(Sender: TObject);
var
  pName: String;
begin
    if PromptforFileName(pName,'ASC Files (*.ASC)|*.ASC','','Save your grid file','',True) then
      begin
        pName := ChangeFileExt(pName,'.ASC');
        SS.SaveRaster(pName,2);
      end;
end;

procedure TGridForm.SaveElevationRasterClick(Sender: TObject);
var
  pName: String;
begin
    if PromptforFileName(pName,'ASC Files (*.ASC)|*.ASC','','Save your grid file','',True) then
      begin
        pName := ChangeFileExt(pName,'.ASC');
        SS.SaveRaster(pName,3);
      end;
end;

procedure TGridForm.SaveInundationButtonClick(Sender: TObject);
var
  pName: String;
begin
  //If inundation frequency not yet calculated ...
  if not SS.InundFreqCheck then
    begin
      ProgForm.YearLabel.Visible       := False;
      SS.InundFreqCheck := CalculateInundFreq(SS);
      //Hide Prgress Form
      ProgForm.Hide;
      RunPanel.Visible := False;
    end;

    // Save the raster
    if PromptforFileName(pName,'ASC Files (*.ASC)|*.ASC','','Save your grid file','',True) then
      begin
        pName := ChangeFileExt(pName,'.ASC');
        SS.SaveRaster(pName,5 );
      end;
end;

procedure TGridForm.ScrollBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   DepthLabel.Caption := '';
   xlabel2.Caption := '';
   ylabel2.Caption := '';
   CategoryLabel.Caption := '';
   Memo1.Visible := False;
end;

procedure TGridForm.CopyMapToClipboard(Sender: TObject);
Begin
  ClipBoard.Assign(Image1.Picture);
end;

procedure TGridForm.Memo1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  If (X<>0) or (Y<>0) then memo1.visible := False;
end;


procedure TGridForm.CalcInundationClick(Sender: TObject);
Var InfIndex: Integer;
begin
 GraphBox.ItemIndex := 2;
 DrawEntireMap(0,False,False);
 //RoadIndex := -1; // show all roads
 //ShowRoadInundation;

 If InputBox.ItemIndex = 4 then //infrastructure
   Begin
      InfIndex := EditBox.ItemIndex;
      If SS.NPointInf = 0 then exit
        else if SS.PointInf[InfIndex].NPoints <= 0 then exit;

      SS.TStepIter := 0;
      With SS.PointInf[InfIndex] do
       Begin
        CalcAllPointInfInundation;
        RunPanel.Hide;
        PointIndex := EditBox.ItemIndex;
        If ShowAll.Checked then PointIndex := -1;
        DrawPointInf;
       End;
   End;

 If InputBox.ItemIndex = 3 then  //roads
   Begin
      InfIndex := EditBox.ItemIndex;
      If SS.NRoadInf = 0 then exit
        else if SS.RoadsInf[InfIndex].NRoads <= 0 then exit;

      SS.TStepIter := 0;
      With SS.RoadsInf[InfIndex] do
       Begin
        // If HasSpecificElevs then Overwrite_Elevs;
        CalcAllRoadsInundation;
        RunPanel.Hide;
        RoadIndex := EditBox.ItemIndex;
        If ShowAll.Checked then RoadIndex := -1;
        ShowRoadInundation;
       End;
   End;



end;

function TGridForm.CalculateConnect: Boolean;
begin
  Result := True;

  //Show Progress Form
  If visible then ShowRunPanel;  // only when visible form to avoid PL2 crash
  ProgForm.YearLabel.Visible       := False;
  ProgForm.SLRLabel.Visible        := False;
  ProgForm.ProtectionLabel.Visible := False;
  ProgForm.ProgressLabel.Caption   := 'Checking Connectivity';

  //Calculate Connectivity
  Result := SS.Calc_Inund_Connectivity(@SS.Connect_Arr,True,-1);
  if SS.DikeLogInit then CloseFile(SS.DikeLog);

  //Hide Prgress Form
  ProgForm.Hide;
  RunPanel.Visible := False;

  //If interrupted then free the connectivity array
  if (not Result) then
    begin
      SS.Connect_Arr := nil;
      Exit;
    end;
end;

function TGridForm.CalculateInundFreq(var SS: TSLAMM_Simulation): Boolean;
begin
  Result := True;

  //Show Progress Form
  If visible then ShowRunPanel;
  ProgForm.SLRLabel.Visible        := False;
  ProgForm.ProtectionLabel.Visible := False;
  ProgForm.ProgressLabel.Caption   := 'Calculating Inundation Frequency';

  //Calculate Connectivity
  Result := SS.Calc_Inund_Freq;

  //If interrupted then free the connectivity array
  if (not Result) then SS.Inund_Arr := nil;
end;


procedure TGridForm.CalcWaveErosionClick(Sender: TObject);
Var i,j: Integer;
begin
  Screen.Cursor := crHourglass;

  With SS do
    Begin
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
    End;

  RunPanel.Visible := True;
  SS.ChngWater(True,False);
  GraphBoxChange(nil);

  Screen.Cursor := crDefault;
end;

procedure TGridForm.ShowDikesClick(Sender: TObject);
var
  ER, EC: integer;
  ReadCell: CompressedCell;
Begin
  If DontDraw then Exit;
  DontDraw := True;

  If Sender=ShowDikes2 then ShowDikes.Checked := ShowDikes2.Checked
                       else ShowDikes2.Checked := ShowDikes.Checked;
  DontDraw := False;
  DrawingTopLayer := False;
  Image1.Visible := False;
  LoadBitStream;

  Screen.Cursor := crHourglass;
  //Draw only the cells that are diked
  for ER := 0 to SS.Site.RunRows-1 do
    for EC := 0 to SS.Site.RunCols-1 do
      begin
        SS.RetA(ER,EC,ReadCell);
        if ReadCell.ProtDikes then
          DrawCell(@ReadCell, ER, EC, ER, EC, GetCellCat(@ReadCell), ShowDikes.Checked, False, True, GraphBox.ItemIndex);
      end;
  Image1.Visible := True;
  SaveBitStream;
  Screen.Cursor := crDefault;
End;

Function TGridForm.ZF_From_Screen: Double;
Begin
  Result := 1.0;
  Case ZoomBox.ItemIndex of
    0: Result := 0.125;
    1: Result := 0.25;
    2: Result := 0.5;
    3: Result := 1.0;
    4: Result := 2.0;
    5: Result := 3.0;
  End; {Case}
End;

procedure TGridForm.ZoomBoxChange(Sender: TObject);
Var ZF: Double;
    TCB: TComboBox;
begin
  If Sender = nil then Sender := ZoomBox;

  TCB := TComboBox(Sender);
  Zoombox.ItemIndex := TCB.ItemIndex;
  Zoombox2.ItemIndex := TCB.ItemIndex;
  Zoombox3.ItemIndex := TCB.ItemIndex;

  ZF := ZF_From_Screen;
  IF ZF <> ZoomFactor then
   If MessageDlg('Redraw Entire Map?',mtconfirmation,[mbyes,mbno],0)=mryes then
    Begin
      ZoomFactor := ZF;

      //DontDraw := True;
      //If Showdikes.checked  then Showdikes.checked := false;
      //If Showdikes2.checked  then Showdikes2.checked := false;
      //DontDraw := False;

      ShowRoadOld := False;

      BitStream.Free;
      BitStream := nil;

      DrawEntireMap(0,True,False);

      // If show the dikes
      if ShowDikes.Checked then ShowDikesClick(nil);

      ProgForm.Hide;
      RunPanel.Visible := False;

      // Show input or putput sites
      if PageControl1.Pages[0].TabVisible then ShowEditItems;
    End;
end;

procedure TGridForm.FormCreate(Sender: TObject);
begin
  DMMTShapeList := nil;
  LastRow := -9999;
  SS := nil;
  SlpFileN := '';
  ZoomFactor := 1.0;
  ZoomBox2.ItemIndex := 3;
  GraphBox.ItemIndex := 0;
  ZoomBox.ItemIndex := 3;

  Image1.Picture.Bitmap.PixelFormat := pf24bit;
  DefiningBoundary := False;
  DefiningVector := False;
  DrawingCells := False;
  FillingCells := False;
  DikesChanged := False;
  NWIChanged := False;
  Updating := False;

  DepthLabel.Caption := '';
  xlabel2.Caption := '';
  ylabel2.Caption := '';
  CategoryLabel.Caption := '';

  // Scroll Image
  ScrollBox1.DoubleBuffered := True;
end;

function ExecuteFile(const FileName, Params, DefaultDir: String;
  ShowCmd: Integer): THandle;
var
  zFileName, zParams, zDir: array[0..254] of Char;
begin
  Result := ShellExecute(Application.MainForm.Handle, nil,
    StrPCopy(zFileName, FileName), StrPCopy(zParams, Params),
    StrPCopy(zDir, DefaultDir), ShowCmd);
end;




procedure TGridForm.AddEstClick(Sender: TObject);
Begin With SS do
 Begin
  If (InputBox.ItemIndex = 2) then
    Begin
      Inc(NumFWFlows);
      If NumFWFlows > Length(FWFlows) then
        SetLength(FWFlows,NumFWFlows+5);
      FWFlows[NumFWFlows-1] := TFWFlow.Create;
      EditIndex := NumFWFlows-1;
    End;

  If (InputBox.ItemIndex = 4) then
    Begin
      Inc(NPointInf);
      If NPointInf > Length(PointInf) then
        SetLength(PointInf,NPointInf+5);
      PointInf[NPointInf-1] := TPointInfrastructure.Create(SS);
      EditIndex := NPointInf-1;
    End;

  If (InputBox.ItemIndex = 3) then
    Begin
      Inc(NRoadInf);
      If NRoadInf > Length(RoadsInf) then
        SetLength(RoadsInf,NRoadInf+5);
      RoadsInf[NRoadInf-1] := TRoadInfrastructure.Create(SS);
      EditIndex := NRoadInf-1;
    End;


  If (InputBox.ItemIndex = 0) then
    Begin
      Site.AddSubSite;
      EditIndex := Site.NSubSites-1;
//      ExecuteFile('NOTEPAD.EXE',Site.SubSites[EditIndex].FileN,'',SW_SHOW);
    End;

  If (InputBox.ItemIndex = 1) then
    Begin
      Site.AddOutputSite;
      EditIndex := Site.NOutputSites-1;
    End;


  // Elevation analysis needs to be rerun
  If InputBox.ItemIndex < 2 then SS.Init_ElevStats := False;

  UpdateEditBox;
  ShowEditItems;
 End;
End;

procedure TGridForm.Button1Click(Sender: TObject);
begin
  If MessageDlg('Stop Process in Progress?',mtconfirmation,[mbyes,mbno],0)=Mrno then Exit;
  ProgForm.SimHalted := True;
  ProgressLabel.Caption := 'Halting Process in Progress';
end;

procedure TGridForm.Button2Click(Sender: TObject);
var ISLEFT, ISRIGHT: Boolean;
begin
  With SS do
    Begin
      ISLEFT := False;                   // Louisiana Only
      ISRIGHT:= False;
      ISLEFT := (Pos('left',Lowercase(FileN)) > 0) or
                (Pos('left',Lowercase(Descrip)) > 0);
      ISRIGHT :=(Pos('right',Lowercase(FileN)) > 0) or
                (Pos('right',Lowercase(Descrip)) > 0);
      If Not (IsLeft or IsRight) then
        Begin
          MessageDlg('You must first specify "left" or "right" in filename or description',mtinformation,[mbok],0);
          Exit;
        End;

      Site.AddOutputSite;
      With Site.OutputSites[Site.NOutputSites-1] do
        Begin
          SaveRec.X1 := 0;
          SaveRec.X2 := Site.RunCols-1;
          SaveRec.Y1 := 0;
          SaveRec.Y2 := Site.RunRows-1;
          If IsRight then SaveRec.X1 := SaveRec.X1+201;
          If IsLeft then SaveRec.X2 := SaveRec.X2-200;
          If IsLeft then Description := 'Left No Buffer'
                    else Description := 'Right No Buffer';
          MessageDlg('Added Subsite '+Description,mtinformation,[mbok],0);
        End;

    End;
end;

procedure TGridForm.Button3Click(Sender: TObject);
// Combine dikes - classic and with elevation using the uplift file
var
 ER, EC: integer;
 CL: Compressedcell;

begin
  If MessageDlg('Are you sure you want to combine dikes using the uplift file?',mtconfirmation,[mbyes,mbno],0)=Mrno then Exit;

  ProgForm.Setup('Combining dikes','','','',False);

  with SS do
    for ER :=0 to MapNR- 1 do
      for EC:=0 to MapNC-1 do
        begin

          // Get the cell
          RetA(ER,EC,CL);

          // Update the protection from dike using the uplift file
          if CL.Uplift > 0 then
            begin

              CL.ProtDikes := True;
              CL.ElevDikes := False;

              // Set the new cell
              SetA(ER,EC,CL);

              // Dike changed
              DikesChanged := True;
            end;
        end;

    ProgForm.Cleanup;

end;



procedure TGridForm.MapSaveSimulationButtonClick(Sender: TObject);
var
  pName: String;
begin
  if GridForm.DikesChanged then
    if PromptforFileName(pName,'ASC Files (*.ASC)|*.ASC','','Save your dike grid file','',True) then
      begin
        pName := ChangeFileExt(pName,'.ASC');
        SS.SaveRaster(pName,1 );
        SS.DikFileN := pName;
        GridForm.DikesChanged := False;
      end
    else
      SS.Init_ElevStats := False;


  if GridForm.NWIChanged then
    if PromptforFileName(pName,'ASC Files (*.ASC)|*.ASC','','Save your wetland grid file','',True) then
      begin
        pName := ChangeFileExt(pName,'.ASC');
        SS.SaveRaster(pName,2 );
        SS.NWIFileN := pName;
        GridForm.NWIChanged := False;
      end
    else
      SS.Init_ElevStats := False;

  if (Sender=SaveAs1) or (Sender=SaveAs2)or (Sender=SaveAs3) then
    begin
      MainForm.SaveAsClick(Sender);

      // Form caption with the loaded project name
      Caption :='SLAMM Map -- '+SS.FileN;
    end
  else
    MainForm.SaveSimClick(Sender);

end;

procedure TGridForm.TabChangeClick(Sender: TObject);
begin

  DrawingCells := False;
  FillingCells := False;
  PolyingCells := False;
  DefiningBoundary := False;
  DefiningVector := False;

  PanCheckBox.Checked := False;
  if (PageControl1.ActivePageIndex <> 1) then
     PanCheckBox.Checked := True;


    //SS.executerun.CALC_ELEV_STATS;
end;



procedure TGridForm.PanCheckBoxClick(Sender: TObject);
begin
  Toolbox1.Enabled := not PanCheckBox.Checked;

end;

procedure TGridForm.PolyCellsClick(Sender: TObject);
begin
  If (not Large_Raster_Edit) and (SS.OptimizeLevel > 1) then
    Begin
      MessageDlg('Cannot Edit Maps when maximum memory optimization is selected.  Change options in File-Setup.',
                  mterror,[mbok],0);
      Exit;
    End;

  SS.Connect_Arr := nil;
  SS.Inund_Arr := nil;
  PenWidthBox.Enabled := False;
  DrawingCells := False;

  FillDikesBox.Enabled := True;
  FillNoDikesBox.Enabled := True;

 if Large_Raster_Edit then
    Begin
      FillDikesBox.Enabled := False;
      FillDikesBox.Checked := False;
      FillNoDikesBox.Enabled := False;
      FillNoDikesBox.Checked := False;
      {  MessageDlg('Dike Editing not yet enabled as part of Large Raster Edits.',
                  mterror,[mbok],0); }
    End;

  FillingCells := False;
  MapTitle2.Caption := 'Draw a Polygon to fill';
  MapTitle2.Visible := True;
  DoneDrawingButton.Visible := True;

  CategoryBox.Enabled := Not (FillDikes or FillNoDikes);
  PolyPoints := nil; {free memory for dynamic array}
  SetLength(PolyPoints,100);
  NumPolyPts := 0;
  DefiningBoundary := True;
  PolyingCells := True;
end;

procedure TGridForm.DeleteEstClick(Sender: TObject);
Var i: Integer;
Begin
 DefiningBoundary := False;

With SS do
 Begin
  If (InputBox.ItemIndex = 2) then
    Begin
      If NumFWFlows = 0 then Exit;

      If MessageDlg('Delete Estuary "'+FWFlows[EditIndex].Name+'" ?',mtconfirmation,[mbyes,mbno],0)
        = mrno then exit;

      FWFlows[EditIndex].Destroy;
      For i:= EditIndex to NumFWFlows-2 do
        FWFlows[i] := FWFlows[i+1];

      Dec(NumFWFlows);
    End;

  If (InputBox.ItemIndex = 4) then
    Begin
      If NPointInf = 0 then Exit;

      If MessageDlg('Delete Infrastructure Layer "'+PointInf[EditIndex].IDName+'" ?',mtconfirmation,[mbyes,mbno],0)
        = mrno then exit;

      PointInf[EditIndex].Destroy;
      For i:= EditIndex to NPointInf-2 do
        PointInf[i] := PointInf[i+1];

      Dec(NPointInf);
    End;

  If (InputBox.ItemIndex = 3) then
    Begin
      If NRoadInf = 0 then Exit;

      If MessageDlg('Delete Roads Layer "'+RoadsInf[EditIndex].IDName+'" ?',mtconfirmation,[mbyes,mbno],0)
        = mrno then exit;

      RoadsInf[EditIndex].Destroy;
      For i:= EditIndex to NRoadInf-2 do
        RoadsInf[i] := RoadsInf[i+1];

      Dec(NRoadInf);
    End;

  If (InputBox.ItemIndex = 2) then
    Begin
      If NumFWFlows = 0 then Exit;

      If MessageDlg('Delete Estuary "'+FWFlows[EditIndex].Name+'" ?',mtconfirmation,[mbyes,mbno],0)
        = mrno then exit;

      FWFlows[EditIndex].Destroy;
      For i:= EditIndex to NumFWFlows-2 do
        FWFlows[i] := FWFlows[i+1];

      Dec(NumFWFlows);
    End;



  IF (InputBox.ItemIndex = 0) then
    Begin
      If Site.NSubSites = 0 then Exit;
      If MessageDlg('Delete Subsite "'+Site.SubSites[EditIndex].Description+'" ?',mtconfirmation,[mbyes,mbno],0)
        = mrno then exit;
      Site.DelSubSite(EditIndex);
    End;

  IF (InputBox.ItemIndex = 1) then
    Begin
      If Site.NOutputSites = 0 then Exit;
      If MessageDlg('Delete Output site "'+Site.OutputSites[EditIndex].Description+'" ?',mtconfirmation,[mbyes,mbno],0)
        = mrno then exit;

      Site.DelOutputSite(EditIndex);
    End;

  EditIndex := 0;

  //Elelvation analysis needs to be rerun
  Init_ElevStats := False;

  UpdateEditBox;
  ShowEditItems;
 End;
End;



procedure TGridForm.DoneDrawingButtonClick(Sender: TObject);
begin
  DrawingCells := False;
  FillDikesBox.Enabled := False;
  FillNoDikesBox.Enabled := False;
  FillingCells := False;
  MapTitle2.Caption := '';
  MapTitle2.Visible := False;
  DoneDrawingButton.Visible := False;
  SaveSim3.Enabled := True;
  CategoryBox.Enabled := False;
  DefiningBoundary := False;
  PolyingCells := False;
  PenWidthBox.Enabled := False;
end;

Procedure TGridForm.DrawArrow(P1,P2: TPoint);
Var HeadLength :  INTEGER;
    xbase      :  INTEGER;
    xLineDelta      :  INTEGER;
    xLineUnitDelta  :  Double;
    xNormalDelta    :  INTEGER;
    xNormalUnitDelta:  Double;
    ybase           :  INTEGER;
    yLineDelta      :  INTEGER;
    yLineUnitDelta  :  Double;
    yNormalDelta    :  INTEGER;
    yNormalUnitDelta:  Double;
    i: Integer;
Begin
 For i := 0 to 1 do
  Begin
    If i=0 then Image1.Canvas.Pen.Width := 4
           else Image1.Canvas.Pen.Width := 2;

    Image1.Canvas.Pen.Style := PSSolid;
    Image1.Canvas.Pen.Mode := pmCopy;

    If i=0 then Image1.Canvas.Pen.Color := ClBlack
           else Image1.Canvas.Pen.Color := ClWhite;

    Image1.Canvas.MoveTo(Trunc(p1.X*Zoomfactor),Trunc(P1.Y*Zoomfactor));
    Image1.Canvas.LineTo(Trunc(p2.X*Zoomfactor),Trunc(P2.Y*Zoomfactor));

    xLineDelta := p2.X - p1.X;
    yLineDelta := P2.Y - P1.Y;

    xLineUnitDelta := xLineDelta / SQRT( SQR(xLineDelta) + SQR(yLineDelta) );
    yLineUnitDelta := yLineDelta / SQRt( SQR(xLineDelta) + SQR(yLineDelta) );

    // (xBase,yBase) is where arrow line is perpendicular to base of triangle.
    HeadLength := 12; // pixels

    xBase := p2.X - ROUND(HeadLength * xLineUnitDelta);
    yBase := P2.Y - ROUND(HeadLength * yLineUnitDelta);

    xNormalDelta :=  yLineDelta;
    yNormalDelta := -xLineDelta;
    xNormalUnitDelta := xNormalDelta / SQRT( SQR(xNormalDelta) + SQR(yNormalDelta) );
    yNormalUnitDelta := yNormalDelta / SQRt( SQR(xNormalDelta) + SQR(yNormalDelta) );

    // Draw the arrow tip
    Image1.Canvas.Polygon([Point(ZF(p2.X),ZF(P2.Y)),
                           Point(ZF(xBase + ROUND(HeadLength*xNormalUnitDelta)),
                                 ZF(yBase + ROUND(HeadLength*yNormalUnitDelta))),
                           Point(ZF(xBase - ROUND(HeadLength*xNormalUnitDelta)),
                                 ZF(yBase - ROUND(HeadLength*yNormalUnitDelta))) ]);
  End;
  Image1.Canvas.Pen.Width := 1;

End;

Procedure TGridForm.DrawVector;
Var i,j: Integer;
Begin
 With SS do
  Begin
    If ShowAll.Checked then
     For j := 0 to NumFWFlows-1 do
      With FWFlows[j] do
       For i := 0 to NumSegments - 1 do
         DrawArrow(OriginArr[i],MouthArr[i]);

    With FWFlows[EditIndex] do
     {Draw Origin, Mouth}
     If NumSegments =  0  then PointWarning.Visible := True
      Else
       Begin
         PointWarning.Visible := False;
         For i := 0 to NumSegments - 1 do
           DrawArrow(OriginArr[i],MouthArr[i]);
       End;
  End;
End;

Procedure TGridForm.DrawBound(Var TPoly: TPolygon);
Var i: Integer;
Begin
 With TPoly do
  Begin
    IF NumPts = 0 then Exit;
    Image1.Canvas.MoveTo(ZF(TPoints[0].X),ZF(TPoints[0].Y));
    For i := 2 to NumPts do
      Image1.Canvas.LineTo(Trunc((TPoints[i-1].X)*Zoomfactor),Trunc((TPoints[i-1].Y)*Zoomfactor));
    Image1.Canvas.LineTo(Trunc((TPoints[0].X)*Zoomfactor),Trunc((TPoints[0].Y)*Zoomfactor));
  End;
End;

Procedure TGridForm.DrawPointInf;
Var indx, i, CanvasX, CanvasY,MSize: Integer;
  TPI: TPointInfrastructure;

   Function InundColor(InundFreq:byte): TColor;
   Begin
      Result := clwhite;                        //InundFreq = 0;
      if InundFreq > 0 then Result := $00002BD5; //Red for 0-30 day inundation
      if InundFreq > 30 then Result:= $004080FF; {Orange for 30-60 day inundation}
      if InundFreq > 60 then Result:= $0000FFFF; {yellow}
      if InundFreq > 90 then Result:= ClGreen;  {Green, not inundated}
   End;

Begin
  SetLength(PointLocs,Image1.Picture.Width*Image1.Picture.Height);
  For i := 0 to Image1.Picture.Width*Image1.Picture.Height -1 do
    PointLocs[i].Loc := -1;

  with SS do
   For indx := 0 to NPointInf -1 do
    If ShowAll.Checked or (ShowSel.Checked and (indx = EditBox.ItemIndex)) then
      Begin

        MSize := 5;  // circle size
        Image1.Canvas.Pen.Style := PSSolid;
        Image1.Canvas.Pen.Color := clblack;
        Image1.Canvas.Brush.Style := BSSolid;
        Image1.Canvas.Brush.Color := ClWhite;

        TPI := SS.PointInf[Indx];
        For i := 0 to TPI.NPoints-1 do
         With TPI.InfPointData[i] do
          Begin
            CanvasX :={1+}TRUNC(Col*ZoomFactor);
            CanvasY :={1+}TRUNC(Row*ZoomFactor);

            If Not ShowAll.Checked then
              Begin
                If (Length(InundFreq) > 0) then
                  Image1.Canvas.Brush.Color := InundColor(InundFreq[SS.TStepIter]);
              End
                else
                  Begin
                    If indx=EditBox.ItemIndex then Image1.Canvas.Brush.Color := clYellow
                                              else Image1.Canvas.Brush.Color := clGreen;
                  End;

            Image1.Canvas.Ellipse(CanvasX - MSize, Canvasy - MSize, Canvasx + MSize + 1, Canvasy + MSize + 1); {Circle}
            PointLocs[CanvasX+(CanvasY*Image1.Picture.Width)].Loc := i ;
            PointLocs[CanvasX+(CanvasY*Image1.Picture.Width)].Ind := indx ;
          End;
      End;

End;


Procedure TGridForm.DrawOutputsites;

  Procedure DrawRec(Var TS: TOutputsite2);
  Begin
   With TS.SaveRec do
    Begin
      IF (X1<-50) or (X2<-50) then Exit;
      Image1.Canvas.MoveTo(ZF(X1),ZF(Y1));
      Image1.Canvas.LineTo(ZF(X1),ZF(Y2));
      Image1.Canvas.LineTo(ZF(X2),ZF(Y2));
      Image1.Canvas.LineTo(ZF(X2),ZF(Y1));
      Image1.Canvas.LineTo(ZF(X1),ZF(Y1));
    End;
  End;

  Procedure DrawOS(Var TS: TOutputsite2);
  Begin
    If TS.UsePolygon then DrawBound(TS.SavePoly)
                     else DrawRec(TS);

  End;

Var j: Integer;
Begin
  Image1.Canvas.Pen.Width := 2;
  Image1.Canvas.Pen.Style := PSSolid;
  Image1.Canvas.Pen.Mode := pmCopy;
  Image1.Canvas.Pen.Color := clWhite;

  If ShowAll.Checked then
   For j := 0 to SS.Site.NOutputSites-1 do
    DrawOS(SS.Site.OutputSites[j]);

  If ShowAll.Checked then Image1.Canvas.Pen.Color := clYellow;
  DrawOS(SS.Site.OutputSites[EditIndex]);
End;

Procedure TGridForm.DrawBoundary(IsEst: Boolean);

Var j: Integer;
Begin
  Image1.Canvas.Pen.Width := 2;
  Image1.Canvas.Pen.Style := PSSolid;
  Image1.Canvas.Pen.Mode := pmCopy;
  Image1.Canvas.Pen.Color := clWhite;

  With SS do
  If ShowAll.Checked then
    If IsEst then
      Begin
         For j := 0 to NumFWFlows-1 do
           DrawBound(FWFlows[j].SavePoly);
      End
    else
      Begin
         For j := 0 to Site.NSubSites-1 do
           DrawBound(Site.Subsites[j].SavePoly);
      End;

  If ShowAll.Checked then Image1.Canvas.Pen.Color := clYellow;

  If IsEst then DrawBound(SS.FWFlows[EditIndex].SavePoly)
           else DrawBound(SS.Site.Subsites[EditIndex].SavePoly);
End;

Procedure TGridForm.HighlightCells;
Var R, C: Integer;
    SC: tcursor;
Begin
  With SS.FWFlows[EditIndex].ScalePoly do
    If (NumPts = 0) or (TPoints = nil) then exit;

  Image1.Canvas.Pen.Style := PSSolid;
  Image1.Canvas.Pen.Mode := pmCopy;

  SC := Screen.Cursor;
  Screen.Cursor := crHourglass;
  With SS do
  With FWFlows[EditIndex].ScalePoly do
   For R:=0 to MapNR-1 do
    For C:=0 to MapNC-1 do
      Begin
        If (ZoomFactor = 0.5)  and (R Mod 2 > 0) then Continue;
        If (ZoomFactor = 0.5)  and (C Mod 2 > 0) then Continue;
        If (ZoomFactor = 0.25)  and (R Mod 4 > 0) then Continue;
        If (ZoomFactor = 0.25)  and (C Mod 4 > 0) then Continue;
        If (ZoomFactor = 0.125)  and (R Mod 8 > 0) then Continue;
        If (ZoomFactor = 0.125)  and (C Mod 8 > 0) then Continue;

        If InPoly(R,C) then
          Image1.Canvas.Pixels[Trunc(C*Zoomfactor),Trunc(R*Zoomfactor)] := clolive;  //optimize?
      End;
  Screen.Cursor := SC;
End;


procedure TGridForm.ShowDikeStats;
Var EC, ER, n: Integer;
    PCL: CompressedCell;
    DikeElev,Sum, Min, Min2, Max: Double;

    Procedure Swap(Var A,B: Integer);
    Var tmp: Integer;
    Begin
      tmp :=A; A:=B; B:=tmp;
    End;

Begin
  if DikeX1 > DikeX2 then Swap(DikeX1,DikeX2);
  if DikeY1 > DikeY2 then Swap(DikeY1,DikeY2);

  Min := 9999;
  Min2 := 9999;
  Sum := 0;
  DikeElev := 0;
  n := 0;
  Max := -9999;
  for EC := DikeX1 to DikeX2 do
    for ER := DikeY1 to DikeY2 do
      Begin
        SS.RetA(ER,EC,PCl);
        If PCl.ElevDikes and PCL.ProtDikes then
          Begin
            DikeElev := getMinElev(@PCl,ER,EC) + (SS.Site.RunScale*0.5)*PCl.TanSlope;
            inc(n);
            if DikeElev<Min then Begin Min2 := Min; Min := DikeElev; End
              else if DikeElev<Min2 then Min2 := DikeElev;
            if DikeElev > Max then Max := DikeElev;
            Sum := Sum + DikeElev;
          End;
      End;

  if n=0 then ShowMessage('No Elevation Dikes Found');
  if n=1 then ShowMessage('One Elevation Dike Found with Elev '+FloatToStrF(DikeElev,ffgeneral,4,4));
  if n>1 then ShowMessage(IntToStr(n)+' Dikes; Average Elev '+FloatToStrF(Sum/n,ffgeneral,4,4)
                          +'; Min Elev '+FloatToStrF(Min,ffgeneral,4,4)
                          +'; 2nd Lowest Elev '+FloatToStrF(Min2,ffgeneral,4,4)
                          +'; Max Elev '+FloatToStrF(Max,ffgeneral,4,4));

  LoadBitStream;
End;

procedure TGridForm.ShowEditItems;
Begin
  SS.ScaleCalcs;
  FWExtentOnly.Visible := False;
  LoadBitStream;

  With SS do
   If (InputBox.ItemIndex = 2) then
    Begin
      If NumFWFlows<1 then exit;
      With FWFlows[EditIndex] do
        Begin
          Updating := True;
          NameEdit.Text := Name;
          Updating := False;

          FWExtentOnly.Visible := True;
          FWExtentOnly.Checked := ExtentOnly;

          {Draw Boundary}
          BoundaryWarning.Visible := False;
          If ScalePoly.TPoints = nil then BoundaryWarning.Visible := True
                                     Else if ScalePoly.NumPts < 2 then BoundaryWarning.Visible := True;

          If ShowSel.Checked or ShowAll.Checked
             then DrawBoundary(True)
             else HighlightCells;

          DrawVector;
        End;
    End;

  If (InputBox.ItemIndex = 0) then With SS do
    Begin
      If Site.NSubSites <1 then exit;
      With Site.Subsites[EditIndex] do
        Begin
          Updating := True;
          NameEdit.Text := Description;
          Updating := False;
          BoundaryWarning.Visible := False;
          If SavePoly.TPoints = nil then BoundaryWarning.Visible := True
                                    Else if SavePoly.NumPts < 2 then BoundaryWarning.Visible := True;
          DrawBoundary(False);
        End;
    End;

  If (InputBox.ItemIndex = 1) then with SS do
    Begin
      If Site.NOutputSites <1 then exit;
      With Site.OutputSites[EditIndex] do
        Begin
          Updating := True;
          NameEdit.Text := Description;
          Updating := False;
          With SaveRec do
            BoundaryWarning.Visible := (X1 < -50) or (Y1<-50);
          DrawOutputSites;
        End;
    End;

  If InputBox.ItemIndex in [3,4] then
    Begin
      Updating := True;
      NameEdit.Text := EditBox.Text;
      Updating := False;
    End;

  If InputBox.ItemIndex = 3 then
    ShowRoadInundation;

  If InputBox.ItemIndex = 4 then
    DrawPointInf;

End;

procedure TGridForm.DefineBoundClick(Sender: TObject);
begin
  PolyingCells := False;

  If (InputBox.ItemIndex = 2) then with SS do
   Begin
     If NumFWFlows = 0 then AddEstClick(nil);
     With FWFlows[EditIndex].SavePoly do
      Begin
        If TPoints <> nil then
          Begin
            if MessageDlg('Redefine Boundary?',mtconfirmation,[mbyes,mbno],0)=mrno then exit;
            TPoints := nil; {free memory for dynamic array}
          End;

        SetLength(TPoints,100);
        NumPts := 0;
      End;
   End;

  If (InputBox.ItemIndex = 0) then with SS do
   Begin
    If Site.NSubSites = 0 then AddEstClick(nil);
     With Site.SubSites[EditIndex].SavePoly do
      Begin

        If TPoints <> nil then
          Begin
            if MessageDlg('Redefine Sub-site?',mtconfirmation,[mbyes,mbno],0)=mrno then exit;
            TPoints := nil; {free memory for dynamic array}
{            X1 := -99; Y1 := -99; }
          End;
        SetLength(TPoints,100);
        NumPts := 0;

      End;
   End;

  If (InputBox.ItemIndex = 1) then with SS do
   Begin
    If Site.NOutputSites = 0 then AddEstClick(nil);
     With Site.OutputSites[EditIndex] do With Saverec do
      Begin
        If (X1>=0) or (Y1>=0) then
          Begin
            if MessageDlg('Redefine Output-site?',mtconfirmation,[mbyes,mbno],0)=mrno then exit;
            X1 := -99; Y1 := -99;
            UsePolygon := False;
          End;
      End;
   End;

  ShowEditItems;
  DefiningBoundary := True;
end;

procedure TGridForm.DefineVectorClick(Sender: TObject);
begin
 PolyingCells := False;

  With SS do With FWFlows[EditIndex] do
    Begin
      If OriginArr <> nil then
        Begin
          if MessageDlg('Redefine estuary path?',mtconfirmation,[mbyes,mbno],0)=mrno then exit;
          OriginArr := nil; {free memory for dynamic array}
          MouthArr  := nil;
        End;

      SetLength(OriginArr,20);
      SetLength(MouthArr,20);

      NumSegments := 0;

      NextOriginX := -99;
      NextOriginY := -99;

      ShowEditItems;
      DefiningVector := True;
    End;
end;




procedure TGridForm.EditBoxChange(Sender: TObject);
begin
  EditIndex := EditBox.ItemIndex;
  ShowEditItems;
end;

procedure TGridForm.EditWindsClick(Sender: TObject);
begin
  WindForm.EditWindRose(SS);
end;

procedure TGridForm.ElevationButtonClick(Sender: TObject);
begin
  ElevAnalysisForm.MapLoaded := True;
  ElevAnalysisForm.ElevationAnalysis(SS);
  SS.ScaleCalcs;
end;


procedure TGridForm.NameEditChange(Sender: TObject);
begin
 With SS do
   Begin
      If Updating then exit;
      If (InputBox.ItemIndex = 2) then
        Begin
          If NumFWFlows = 0 then AddEstClick(nil);
          With FWFlows[EditIndex] do
            Name := NameEdit.Text;
        End;

      If (InputBox.ItemIndex = 1) then
        Begin
          If Site.NOutputSites = 0 then AddEstClick(nil);
          With Site.OutputSites[EditIndex] do
            Description := NameEdit.Text;
        End;

      If (InputBox.ItemIndex = 0) then
        Begin
          If Site.NSubSites = 0 then AddEstClick(nil);
          With Site.SubSites[EditIndex] do
            Description := NameEdit.Text;
        End;

      If (InputBox.ItemIndex = 3) then
        Begin
          If NRoadInf = 0 then AddEstClick(nil);
          With RoadsInf[EditIndex] do
            IDName := NameEdit.Text;
        End;

      If (InputBox.ItemIndex = 4) then
        Begin
          If NPointInf = 0 then AddEstClick(nil);
          With PointInf[EditIndex] do
            IDName := NameEdit.Text;
        End;

   End;

end;

procedure TGridForm.NameEditExit(Sender: TObject);
begin
  UpdateEditBox;
end;

procedure TGridForm.NextStepButtonClick(Sender: TObject);
begin
  ShowRunPanel;
end;

procedure TGridForm.OmitT030Click(Sender: TObject);
begin
  {}
end;

procedure TGridForm.ROSButtonClick(Sender: TObject);
Var ER, EC {, GBII} : Integer;
    ROS: Byte;
    SvCrs: TCursor;
    Cl: CompressedCell;

{    MinElv: Single;  }
begin
  Inc(ROSShowing);
  If ROSShowing > ThisSite.MaxROS then ROSShowing :=0;
  If ROSShowing = 0 then ROSLabel.Caption := 'Raster Output Shown = none'
                    else ROSLabel.Caption := 'Raster Output Shown = '+ IntToStr(ROSShowing);

  if SS.ROSArray=nil then Exit;
  Image1.Visible := False;

  SvCrs := Screen.Cursor;
  Screen.Cursor := crHourglass;
  GridForm.Image1.Canvas.Pen.Mode := pmcopy;
//  GBII := GraphBox.ItemIndex;

  With SS do
   For ER :=0 to MapNR- 1 do
    For EC:=0 to MapNC-1 do
      Begin
        RetA(ER,EC,CL);
        ROS := ROSArray[(Site.RunCols*ER)+EC];
        If (ROS > 0)
          then
            Begin
              If ROS = ROSShowing
                then DrawCell(@CL,ER,EC,ER,EC,-99,False,True,False,0)  {Draw ROS as white}
                else DrawCell(@CL,ER,EC,ER,EC,GetCellCat(@Cl),False,False,False,0); {Draw Category}
            End;
      End;
  Screen.Cursor := SvCrs;
  Image1.Visible := True;
  SaveBitStream;
  ProgForm.Hide;
  RunPanel.Visible := False;

end;


procedure TGridForm.ShowCellsClick(Sender: TObject);
begin
  ShowEditItems;
end;

procedure TGridForm.ShowSelClick(Sender: TObject);
begin
  ShowEditItems;
end;

procedure TGridForm.DrawCellsButtClick(Sender: TObject);
begin
  If (not Large_Raster_Edit) and (SS.OptimizeLevel > 1) then
    Begin
      MessageDlg('Cannot Edit Maps when maximum memory optimization is selected.  Change options in File-Setup.',
                  mterror,[mbok],0);
      Exit;
    End;

  SS.Connect_Arr := nil;
  SS.Inund_Arr := nil;


  PenWidthBox.Enabled := True;
  PenWidthBox.ItemIndex := 1;
  DrawingCells := True;
  FillDikesBox.Enabled := True;
  FillNoDikesBox.Enabled := True;

 if Large_Raster_Edit then
    Begin
      FillDikesBox.Enabled := False;
      FillDikesBox.Checked := False;
      FillNoDikesBox.Enabled := False;
      FillNoDikesBox.Checked := False;
      {  MessageDlg('Dike Editing not yet enabled as part of Large Raster Edits.',
                  mterror,[mbok],0); }
    End;

  FillingCells := False;
  MapTitle2.Caption := 'Drawing Cells, Click to Draw';
  MapTitle2.Visible := True;
  DoneDrawingButton.Visible := True;

  FillDikes := FillDikesBox.Checked;
  FillNoDikes := FillNoDikesBox.Checked;

  CategoryBox.Enabled := Not (FillDikes or FillNoDikes);
end;

procedure TGridForm.FillCellsButtClick(Sender: TObject);
begin
  If (not Large_Raster_Edit) and (SS.OptimizeLevel > 1) then
    Begin
      MessageDlg('Cannot Edit Maps when maximum memory optimization is selected.  Change options in File-Setup.',
                  mterror,[mbok],0);
      Exit;
    End;

  SS.Connect_Arr := nil;
  SS.Inund_Arr := nil;

  FillingCells := True;
  DrawingCells := False;
  MapTitle2.Caption := 'Filling Cells, Click on Map';
  MapTitle2.Visible := True;
  DoneDrawingButton.Visible := True;

  FillDikesBox.Enabled := True;
  FillNoDikesBox.Enabled := True;

 if Large_Raster_Edit then
    Begin
      FillDikesBox.Enabled := False;
      FillDikesBox.Checked := False;
      FillNoDikesBox.Enabled := False;
      FillNoDikesBox.Checked := False;
      {  MessageDlg('Dike Editing not yet enabled as part of Large Raster Edits.',
                  mterror,[mbok],0); }
    End;

  FillDikes := FillDikesBox.Checked;
  FillNoDikes := FillNoDikesBox.Checked;

  CategoryBox.Enabled := Not (FillDikes or FillNoDikes);
end;

procedure TGridForm.DefEstClick(Sender: TObject);
begin

  If (InputBox.ItemIndex = 2) then EstNameCapt.Caption := 'Est. Name'
                              else EstNameCapt.Caption := 'Sub-site:';
  DefineVector.Visible := (InputBox.ItemIndex = 2);
  PointWarning.Visible := (InputBox.ItemIndex = 2);
  FWExtentOnly.Visible := (InputBox.ItemIndex = 2);
  ShowCells.Visible    := (InputBox.ItemIndex = 2);
  SubsiteParmButt.Visible := (InputBox.ItemIndex = 0);
  FWFlowButton.Visible := (InputBox.ItemIndex = 2);

  EditIndex := 0;
  UpdateEditBox;
  ShowEditItems;

end;

procedure TGridForm.SubsiteParmButtClick(Sender: TObject);
begin
    SiteEditForm.EditSubSites(SS);
    SS.ScaleCalcs;
end;

procedure TGridForm.SVOGISReadWrite1Progress(Sender: TObject;
  Stage: TProgressStage; PercentDone: Byte; RedrawNow: Boolean; const R: TRect;
  const Msg: string);
begin
  If ProgForm<> nil then ProgForm.Update2Gages(PercentDone,0);
end;

procedure TGridForm.LoadSHPButtonClick(Sender: TObject);
Var
  DMTPolyShape: TSVOPolygonShape;
  DataPoints: TSVOShapePointArray;
  i,j,k, ErrNum: Integer;
  StudyXMin, StudyXMax, StudyYMin, StudyYMax, Rnscale: Double;
  RnRows: Integer;

  Function StudyX(indx: Integer): Double;
  Begin
    StudyX := (DataPoints[k].X - StudyXMin) / RnScale;
  End;

  Function StudyY(indx: Integer): Double;
  Begin
    StudyY := RnRows-1-(DataPoints[k].Y - StudyYMin) / RnScale;
  End;



begin
  IF Not OpenDialog1.Execute THEN Exit;

  IF OpenDialog1.FilterIndex = 1 Then SVOGISReadWrite1.FileType := sftShapeFile;
  IF OpenDialog1.FilterIndex = 2 Then
    Begin
      MessageDlg('Error, areas to process for the DMT must be a "*.shp" shapefile',mterror,[mbOK],0);
      Exit;
    End;

    DMMTShapeList := TSVOShapeList.Create;
    SVOGISReadWrite1.ShapeList := DMMTShapeList;
    SVOGISReadWrite1.ImportFileName := OpenDialog1.Filename;

    ProgForm.Setup('Reading Shape File','','','',False);

    ErrNum := SVOGISReadWrite1.ReadFile;
    If ErrNum > 0 then
        Begin
          MessageDlg('Error Reading shape file '+ OpenDialog1.Filename,mterror,[mbOK],0);
          SVOGISReadWrite1.Active := False;
          SVOGISReadWrite1.Shapelist.Destroy;
          Exit;
        End;

    OpenDialog1.InitialDir := ExtractFileDir(OpenDialog1.FileName);  // set directory for next time

  With SS.Site do
    Begin
      RnScale := RunScale;
      RnRows := RunRows;
      StudyXMin := LLXCorner;              // projection units
      StudyXMax := LLXCorner + RunCols*RunScale;
      StudyYMin := LLYCorner;
      StudyYMax := LLYCorner + RunRows*RunScale;
    End;

  For i := 0 to DMMTShapeList.Count-1 do
    Begin
      DMTPolyShape :=  TSVOPolygonShape(DMMTShapeList.Items[i]);

      If DMTPolyShape.ShapeType <> STPolygon then
         Begin
           MessageDlg('Error, Infrastructure ShapeFile must be a "polygon" shapefile',mterror,[mbOK],0);
           DMMTShapeList.Free;
           Exit;
         End;

      For j := 0 to DMTPolyShape .PartsList.Count-1 do  // j polygons for each record
       For k := 0 to DMTPolyShape.PartsList.Items[j].Count-1 do // k points per polygons
         With SS.Site do  // transform from projection units to a floating point on the SLAMM scale [0..NRow-1, 0..NCol-1]
           Begin
             DataPoints := DMTPolyShape.PartsList.Items[j];
             If k=0 then Image1.Canvas.MoveTo(Round(StudyX(k)*Zoomfactor),Round(StudyY(k)*ZoomFactor))
                    else Image1.Canvas.LineTo(Round(StudyX(k)*Zoomfactor),Round(StudyY(k)*ZoomFactor));
             If k= DMTPolyShape.PartsList.Items[j].Count-1 then Image1.Canvas.LineTo(Round(StudyX(0)*Zoomfactor),Round(StudyY(0)*ZoomFactor))
           End;


    End; // i loop

  ProgForm.Cleanup;
  ExtractDataShpButton.Enabled := True;
  {}
end;

Const   NWetland=24;
        NDUcksWetland=7;
        TotNWetland=NWetland+NDucksWetland+3;  // Land categories plus 3 ("OW interface," "Edge Density," & "marsh width")

Function TGridForm.Get_UncertResults_Param(var BaseFileName, BaseExt, BaseDir: string; var NumIter, N_GISYears, TimeZero: integer; var GISYrArray: array of integer): Boolean;
//===============================================================================
// Get Uncertainty Parameters from the log file. MP: Provided by JSC. I supressed the memo window
//------------------------------------------------------------------------------
// BaseFileName : Base file name
// BaseDir : Base folder
// NumIter= number of uncertainty runs
// TimeZero= Years of the initial observed wetland coverage
// N_GISYears: Number of timestep predictions
// GISYrArray: Years of predictions
//===============================================================================
Var UncertLog: String;
    UncertFile: TextFile;
    ReadStr: String;
    YearLoop: Integer;

    Function AfterEquals(InStr: String): String;
    Var ps: Integer;
    Begin
      Result := '';
      ps := Pos('=',InStr);
      If ps = 0 then ShowMessage('No = char found in "'+instr+'"')
                else Result := Trim(RightStr(ReadStr,Length(ReadStr)-ps));
    End;

begin
  Result := False;
  If not PromptForFileName(UncertLog,'uncert logs|*uncertlog*.txt','','Select Uncertainty Log to Import From','',False) then exit;
  AssignFile(UncertFile,UncertLog);
  Reset(UncertFile);

  Try

  Repeat
    Readln(UncertFile,ReadStr);
    If ReadStr='' then ReadStr := '-';  // avoid crash when evaluating ReadStr[1];
  Until eof(UncertFile) or (ReadStr[1]='~');

  If eof(UncertFile)
     then ShowMessage('Technical Details for Uncert Viewer Not Found')
     else
       Begin
         BaseDir :=  ExtractFilePath(UncertLog);
         //Memo1.Lines.Add('BaseDir= '+BaseDir);

         BaseFileName := ChangeFileExt(AfterEquals(ReadStr),'');
         //Memo1.Lines.Add('BaseFileName= '+BaseFileName);

         Readln(UncertFile,ReadStr);
         NumIter := StrToInt(AfterEquals(ReadStr));
         //Memo1.Lines.Add('NumIter= '+IntToStr(NumIter));

         Readln(UncertFile,ReadStr);
         TimeZero := StrToInt(AfterEquals(ReadStr));
         //Memo1.Lines.Add('TimeZero= '+IntToStr(TimeZero));

         BaseExt := '';
         N_GISYears := 0;
         For YearLoop := TimeZero to 2100 do
           If (FileExists(BaseDir+'1_'+BaseFileName+', '+IntToStr(YearLoop)+',_GIS.ASC') or
               FileExists(BaseDir+'1_'+BaseFileName+', '+IntToStr(YearLoop)+',_GIS.SLB'))
             Then Begin
                    GISYrArray[N_GISYears] := YearLoop;
                    Inc(N_GISYears);
                    If BaseExt = '' then if (FileExists(BaseDir+'0_'+BaseFileName+', '+IntToStr(YearLoop)+',_GIS.ASC'))
                                             then BaseExt := '.ASC' else BaseExt := '.SLB';
                  End;

         //Memo1.Lines.Add('N_GISYears= '+IntToStr(N_GISYears));
         //For YearLoop := 1 to N_GISYears do
            //Memo1.Lines.Add('GISYrArray['+IntToStr(YearLoop)+'] = '+IntToStr(GISYrArray[YearLoop]));

       End;

   Result := True;

  Finally

  CloseFile(UncertFile);

  End; // Try Finally

end;




procedure TGridForm.ExtractDataShpButtonClick(Sender: TObject);
//----------------------------------------------------------------
// Process the data
//-----------------------------------------------------------------




Type
  CellPolyRec = Record
    nshapes: Byte;
    ShapeIndexes: Array of Integer;
  End; // cellpolyrec

  TUncResArray = array of array of Single;

Type WetlandArray= array [1..TotNWetland] of integer;
     PWetlandArray= ^WetlandArray;
     OWArray = array of integer;


var
  NumIter, c, i, j, z, k, er, ec, shp : integer;
  SaveFileN, BaseFileName, BaseExt, BaseDir, FileName, lengthfileN, LengthStr: string;
  WriteLength: Boolean;
  LengthFile: textfile;
  GISYrArray: Array[0..100] of Integer;
  WetlandCells: array of array of WetlandArray;   // year, site, array
  MarshLengths: Array of Double;
  TimeZero : Integer;
  N_GISYears: Integer;
  CellPolys: Array of CellPolyRec;
  FlatIndex: LongInt;
  NonFrag, EdgeDens, Perimeter, ShapeX, ShapeY, MWid, WetlandArea: Double;
  DMTPolyShape: TSVOPolygonShape;
  SIF: TSLAMMInputFile;
  ReadOK: Boolean;
  Num: Single;
  outfile: TextFile;
  MWI : Byte;  // marsh to open-water interfaces
  NPerimeter: Byte; // perimeter of marsh interface
  CatMap : Array of Byte;


    procedure Ducks_Wetland_Aggregate(PWetArray: PWetlandArray);
    //=================================================================================
    // Calcualate cell coverage for Ducks categories
    //==================================================================================
    begin
      {Non Tidal}            PWetArray^[NWetland+1] := PWetArray^[1] + PWetArray^[2] + PWetArray^[23];
      {Freshwater Non Tidal} PWetArray^[NWetland+2] := PWetArray^[3] + PWetArray^[4]+PWetArray^[5] + PWetArray^[21];
      {Open Water}           PWetArray^[NWetland+3] := PWetArray^[15] + PWetArray^[16] + PWetArray^[17] + PWetArray^[18] + PWetArray^[19];
      {Low Tidal }           PWetArray^[NWetland+4] := PWetArray^[10] + PWetArray^[11] + PWetArray^[12] + PWetArray^[13] + PWetArray^[14] ;  // no flooded developed
      {Salt Marsh}           PWetArray^[NWetland+5] := PWetArray^[8];
      {Transitional}         PWetArray^[NWetland+6] := PWetArray^[7] + PWetArray^[9] + PWetArray^[20] + PWetArray^[24];  // includes flooded forest
      {Freshwater Tidal}     PWetArray^[NWetland+7] := PWetArray^[6] + PWetArray^[22];
    end;
    //=================================================================================
    Procedure CheckCellAdj(R,C: Integer);
    Var FIndx: LongInt;
    Begin
      With SS.Site do
        If (R<0) or (C<0) or (R>=RunRows) or (C>=RunCols) then Exit;

      FIndx := (SS.Site.RunCols*R)+C;
      If (CatMap[FIndx] in [11,13,15..19]) then Inc(MWI);  // marsh interfacing with open water or T-Flat

      If not (CatMap[FIndx] in [8,9,20,6]) then Inc(NPerimeter); {not mangrove, regfloodmarsh, irregfloodmarsh, or tidalfreshmarsh}
    End;
    //=================================================================================


begin
  If DMMTShapeList = nil then exit;

  If Not Get_UncertResults_Param(BaseFileName,BaseExt, BaseDir,NumIter,N_GISYears,TimeZero,GISYrArray) then exit;

  If Not PromptForFileName(SaveFileN,'csv files|*.csv','.csv','Select Output CSV File','',True) then exit;
  AssignFile(Outfile,SaveFileN);
  Rewrite(OutFile);

  WriteLength := PromptForFileName(LengthFileN,'csv files|*.csv','.csv','Select (Optional) Length CSV File','',False);
  If WriteLength then
    Begin
      AssignFile(LengthFile,LengthFileN);
      Reset(LengthFile);
      SetLength(MarshLengths,DMMTShapeList.Count);
      Readln(LengthFile);  // assume a header line in CSV for now
      For i := 0 to DMMTShapeList.Count-1 do
        Begin
          Readln(LengthFile, LengthStr);
          Delete(LengthStr,1,Pos(',',LengthStr)); // delete ID for now, input sequentially in order of shapefile
          MarshLengths[i] := StrToFloat(LengthStr);
        End;
      Closefile(LengthFile);
    End;  // if writelength, could be read from shapefile too but more programming work

  // Make visible progress bar and messages
  ProgForm.Setup('Locating cells in shapefiles','','','',False);

   // Store which cells belong to which polygons
    With SS.Site do Setlength(CellPolys,RunRows*RunCols);
    for ER := 0 to SS.Site.RunRows-1 do
      for EC := 0 to SS.Site.RunCols-1 do
        begin
          ProgForm.Update2Gages(Trunc(100*(ER/SS.Site.RunRows)),0);
          FlatIndex := (SS.Site.RunCols*ER)+EC;
          CellPolys[FlatIndex].nshapes := 0;
          CellPolys[FlatIndex].ShapeIndexes := nil;

          With SS.Site do
            Begin
              ShapeX  := ((EC+0.5) * RunScale) + LLXCorner;
              ShapeY  := -(RunScale*(ER+0.5-RunRows)) + LLYCorner;
            End;

          For i := 0 to DMMTShapeList.Count-1 do
            Begin
              DMTPolyShape :=  TSVOPolygonShape(DMMTShapeList.Items[i]);
              If DMTPolyShape.PointInPolygon(ShapeX,ShapeY) then
               with CellPolys[FlatIndex] do
                Begin
                  Inc(nshapes);
                  If Length(shapeindexes)< nshapes
                     then SetLength(shapeindexes,nshapes*2);
                  ShapeIndexes[nshapes-1] := i;
                End;
            End;
        End;

  SetLength(WetlandCells,N_GISYears);
  With SS.Site do SetLength(CatMap,RunRows * RunCols);

  ProgForm.Setup('Processing Uncert/SLAMM Run Data','','','',False);
  for j := 1 to NumIter do     // Process for uncertainty scenarios, not the deterministic prefixed with "0"
   begin
   for i := 0 to N_GISYears-1 do   //Processing for every year
    begin
      SetLength(WetlandCells[i],DMMTShapeList.Count);

      For shp := 0 to DMMTShapeList.Count-1 do
        // Initialize wetland cell coverage
        for k := 1 to TotNWetland do
          WetlandCells[i,shp,k] :=0;

          // Show progress bar on screen
          ProgForm.Update2Gages(Trunc(100*(j*(N_GISYears+1)+i+1)/(NumIter*(N_GISYears+1))),0);

          // create file name
          FileName := BaseDir+IntToStr(j)+'_'+BaseFileName+', '+IntToStr(GISYrArray[i])+',_GIS'+BaseExt;
          SIF := TSLAMMInputFile.Create(FileName);
          ReadOK := SIF.PrepareFileForReading;
          If Not ReadOK then
              Begin
                SIF.Free;  SIF := nil;
                MessageDlg('Error Reading File '+FileName,mterror,[mbok],0);
                Exit;
              End;

          for ER := 0 to SS.Site.RunRows-1 do
           for EC := 0 to SS.Site.RunCols-1 do
             Begin
               SIF.GetNextNumber(Num);
               FlatIndex := (SS.Site.RunCols*ER)+EC;
               If Num>0 then CatMap[FlatIndex] := Trunc(Num)
                        else CatMap[FlatIndex] := 0;
             End; // ER, EC

          for ER := 0 to SS.Site.RunRows-1 do
           for EC := 0 to SS.Site.RunCols-1 do
             Begin
               FlatIndex := (SS.Site.RunCols*ER)+EC;
               With CellPolys[FlatIndex] do
               If (CatMap[FlatIndex]>0) and (nshapes > 0) then
                 Begin
                   MWI := 0;
                   NPerimeter := 0;
                   If CatMap[FlatIndex] in [8,9,20,6] then {mangrove, regfloodmarsh, irregfloodmarsh, tidalfreshmarsh}  {perimiter for marsh to open water interface}
                     Begin
                       CheckCellAdj(ER-1,EC);
                       CheckCellAdj(ER+1,EC);
                       CheckCellAdj(ER,EC-1);
                       CheckCellAdj(ER,EC+1);
                     End;

                   For shp := 0 to nshapes-1 do
                     Begin
                       Inc(WetlandCells[i,ShapeIndexes[shp],CatMap[FlatIndex]]);
                       WetlandCells[i,ShapeIndexes[shp],TotNWetland] := WetlandCells[i,ShapeIndexes[shp],TotNWetland] + MWI;  // marsh water interface count
                       WetlandCells[i,ShapeIndexes[shp],TotNWetland-1] := WetlandCells[i,ShapeIndexes[shp],TotNWetland-1] + NPerimeter; // marsh perimter count
                     End;

                 End; // nshapes > 0 and cat>0
             End; // ER, EC


      For shp := 0 to DMMTShapeList.Count-1 do
        Ducks_Wetland_Aggregate(@WetlandCells[i,shp]);

    End;  //i to NGIS_Years

   for shp := 0 to DMMTShapeList.Count-1 do
    for i := 0 to N_GISYears-1 do
     Begin
       Write(outfile,IntToStr(GISYrArray[i])+',');
       Write(outfile,'Site '+IntToStr(shp+1)+',');
       Write(outfile,'Iteration '+IntToStr(j)+',');
       Write(outfile,'N A,N A,N A'); // protection and SLR unknown for now
       For c:=1 to NWetland do
         Write(Outfile,',',floattostrf(WetlandCells[i,shp,c]*Sqr(SS.Site.RunScale)/10000,ffgeneral,8,4)); // ha
       Write(Outfile,',-9999'); // Marsh to Open W
       For c:=NWetland+1 to NWetland+NDucksWetland do
         Write(Outfile,',',floattostrf(WetlandCells[i,shp,c]*Sqr(SS.Site.RunScale)/10000,ffgeneral,8,4)); // ha

       Write(Outfile,',',floattostrf(WetlandCells[i,shp,TotNWetland]*SS.Site.RunScale,ffgeneral,8,4)); // Marsh to OW interface in meters
                                               {count}                          {m}

       Perimeter := WetlandCells[i,shp,TotNWetland-1]*SS.Site.RunScale; // Marsh Perimeter in meters
                               {count}                          {m}
       WetlandArea := 0;
       z := 8;  WetlandArea := WetlandArea + WetlandCells[i,shp,z]*Sqr(SS.Site.RunScale);  //r.f.m
       z := 9;  WetlandArea := WetlandArea + WetlandCells[i,shp,z]*Sqr(SS.Site.RunScale);  //mangrove
       z := 20; WetlandArea := WetlandArea + WetlandCells[i,shp,z]*Sqr(SS.Site.RunScale);  //i.f.m
       z := 6;  WetlandArea := WetlandArea + WetlandCells[i,shp,z]*Sqr(SS.Site.RunScale);  //t.fresh
       z := 7;  WetlandArea := WetlandArea + WetlandCells[i,shp,z]*Sqr(SS.Site.RunScale);  //transitional
                                 {m2}              {count}                    {m2}

       If WetlandArea < Tiny then Begin Perimeter := 1; WetlandArea := 1; End; // maximum result of 0.8 m/m2 with 5 meter cell size (4/cell size)
       EdgeDens := Perimeter / WetlandArea;
                      {m}        {m2}
       NonFrag  := WetlandArea / 10000 * (4/5-EdgeDens)/(4/5-2*SQRT(PI/WetlandArea));
                      {m2}      {m2/ha}   { unitless normalized non frag density }
       Write(Outfile,',',floattostrf(NonFrag,ffgeneral,8,4));  // Non Fragmented Density (edge density in ha)
                                       {ha}
       If WriteLength then
        Begin
          If MarshLengths[shp] < tiny then MWid := 0 else
            MWid := (WetlandCells[i,shp,NWetland+5]+WetlandCells[i,shp,NWetland+6]) *Sqr(SS.Site.RunScale)/MarshLengths[shp];
             {m}           {n saltmarsh cells}         {n transitional cells}                    {m2}            {m}
          Write(Outfile,',',floattostrf(MWid,ffgeneral,8,4));
        End;

       Writeln(OutFile);
     End;   //i to NGIS_Years

   End; // j to N_Iter

   Closefile(OutFile);
   Progform.Cleanup;
   CatMap := nil;
   for i := 0 to N_GISYears-1 do   //Processing for every year
      WetlandCells[i] := nil;
   WetlandCells := nil;   //possibly still memory leaks here

End;

end.
