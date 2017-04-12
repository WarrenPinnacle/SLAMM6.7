unit Infr_Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtCtrls, System.Math,
  Types, ExcelFuncs, Utility, global, SLR6, Infr_Data;

Type
  TInfStructFileSetup = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    FN1: TLabel;
    Label11: TLabel;
    DikeFileEdit: TEdit;
    DikeBrowseButton: TButton;
    DikeCasePanel: TPanel;
    ClassicDikeCaseRadioButton: TRadioButton;
    DikeLocationCaseRadioButton: TRadioButton;
    Panel2: TPanel;
    Label2: TLabel;
    Label12: TLabel;
    RoadFN: TLabel;
    RoadFileEdit: TEdit;
    RoadBrowseButton: TButton;
    CheckValidityButton: TButton;
    OKButton10: TButton;
    CancelButton: TButton;
    HelpButton: TBitBtn;
    SaveButton: TButton;
    OpenDialog2: TOpenDialog;
    Panel3: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    DevFN: TLabel;
    Edit1: TEdit;
    Button3: TButton;
    Panel4: TPanel;
    Label6: TLabel;
    Label7: TLabel;
    RestorFN: TLabel;
    Edit2: TEdit;
    Button4: TButton;
    Panel5: TPanel;
    RoadElevCheckBox: TCheckBox;
    procedure CheckValidityButtonClick(Sender: TObject);
    procedure DikeFileEditChange(Sender: TObject);
    procedure DikeBrowseButtonClick(Sender: TObject);
    procedure DikeCaseRadioButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    //procedure QuickSortPoints(Arr: DPointArray; iLo, iHI: Integer);
    procedure RoadElevCheckBoxClick(Sender: TObject);
    //procedure Button5Click(Sender: TObject);
  private
    ISS: TSLAMM_Simulation;
    Updating: Boolean;
    BClassicDike : Boolean;
    BUseRoadElev : Boolean;
    { Private declarations }
  public
    BDikFileN  : String;
    BOldRoadFileN : String;
    Procedure EditFileInfo(var SS: TSLAMM_Simulation);
    Procedure UpdateScreen;
    //procedure LineSegmentLengthPerCell(var SS: TSLAMM_Simulation; HeadPoint, TailPoint: DPoint);
    //function LineEqFromTwoPoints(HeadPoint, TailPoint: DPoint):DLine;
    //function GetBoundaryCoordinates(SS: TSLAMM_Simulation; HeadPoint, TailPoint: DPoint): DBoundary;
    //function LineEqForRowsOrCols(SS: TSLAMM_Simulation; Row, Col: Integer): DLine;
    //function TwoLinesIntersection(Line1, Line2 : DLine): DPoint;
    { Public declarations }
  end;

Var
    InfStructFileSetup: TInfStructFileSetup;


implementation

{$R *.dfm}

uses main, System.UITypes, FileSetup;

procedure TInfStructFileSetup.EditFileInfo(var SS: TSLAMM_Simulation);
begin
    ISS := SS;

    BDikFileN  := SS.DikFileN;
    BClassicDike := SS.ClassicDike;

    BOldRoadFileN :=SS.OldRoadFileN;

    FN1.Visible := False;
    RoadFN.Visible := False;

    DikeFileEdit.Color := ClWindow;
    RoadFileEdit.Color := ClWindow;

    CheckValidityButtonClick(nil);

    UpdateScreen;

    If ShowModal = MROK then
      Begin
        SS.DikFileN := BDikFileN ;
        SS.ClassicDike := BClassicDike ;

        SS.OldRoadFileN :=BOldRoadFileN;

        SS.Changed := True;
      End;

    MainForm.UpdateScreen;

end;

procedure TInfStructFileSetup.DikeFileEditChange(Sender: TObject);
begin
   If Updating then Exit;
   If Sender=DikeFileEdit then BDikFileN := DikeFileEdit.Text;
   If Sender=RoadFileEdit then BOldRoadFileN := RoadFileEdit.Text;

   CancelButton.Enabled := True;
end;

procedure TInfStructFileSetup.SaveButtonClick(Sender: TObject);
begin
MainForm.SaveSimClick(Sender);
CancelButton.Enabled :=  False;
end;

procedure TInfStructFileSetup.DikeBrowseButtonClick(Sender: TObject);
Var TEB: TEdit;
    Str: String;
begin
  TEB := nil;
  Case TButton(Sender).Name[1] of
    'D': Begin
           OpenDialog2.Filter := 'asc or txt file (*.txt, *.asc)|*.txt;*.asc|any file (*.*)|*.*';
           TEB := DikeFileEdit;
         End;
    'R': Begin
           OpenDialog2.Filter := 'csv file (*.csv)|*.csv|any file (*.*)|*.*';
           TEB := RoadFileEdit;
         End;
   End;

  Str := TEB.Text;
  OpenDialog2.InitialDir := ExtractFilePath(Str);
  If OpenDialog2.Execute then TEB.Text:=OpenDialog2.Filename;
end;

  (*procedure TInfStructFileSetup.Button5Click(Sender: TObject);
  var
  HeadPoint, TailPoint: DPoint;
  begin
  HeadPoint.X := strtofloat(Edit3.Text)*ISS.Site.Scale+ISS.Site.LLXCorner;
  HeadPoint.Y := strtofloat(Edit4.Text)*ISS.Site.Scale+ISS.Site.LLYCorner;

  TailPoint.X := strtofloat(Edit5.Text)*ISS.Site.Scale+ISS.Site.LLXCorner;;
  TailPoint.Y := strtofloat(Edit6.Text)*ISS.Site.Scale+ISS.Site.LLYCorner;

  LineSegmentLengthPerCell(ISS, HeadPoint, TailPoint);


  end;  *)

procedure TInfStructFileSetup.CancelButtonClick(Sender: TObject);
begin
  If MessageDlg('Cancel all Changes?',mtconfirmation,[mbyes,mbno],0) = MRyes then
    ModalResult := MRCancel;
end;

procedure TInfStructFileSetup.CheckValidityButtonClick(Sender: TObject);
begin
FileSetupForm.CheckValidityButtonClick(Sender);
end;

procedure TInfStructFileSetup.DikeCaseRadioButtonClick(Sender: TObject);
begin
  If Updating then Exit;

  BClassicDike := ClassicDikeCaseRadioButton.Checked;

  UpdateScreen;
end;

procedure TInfStructFileSetup.UpdateScreen;
begin
    Updating := True;
    DikeFileEdit.Text := BDikFileN;
    RoadFileEdit.Text := BOldRoadFileN;

    Updating := False;

    Update;
end;

//-----------------------------------------------------------------------------------------------------------
// ROAD MODULE FUNCTIONS AND PROCEDURES
//----------------------------------------------------------------------------------------------------------
{procedure TInfStructFileSetup.LineSegmentLengthPerCell(var SS: TSLAMM_Simulation; HeadPoint, TailPoint: DPoint);
var
  CellsBound: DBoundary;
  i : integer;
  RoadLine, TmpLine: DLine;
  IntPoint, MidPoint: DPoint;
  IntPtArr : DPointArray;
  NIntPt : integer;
  Dist, Tmp : double;
  Row, Col : integer;
 // Cell : CompressedCell;

begin
  // Set local SLAMM object
  ISS := MainForm.SS;

  // Determine the boundaries in rows and columns that include the line segment
  CellsBound := GetBoundaryCoordinates(ISS,HeadPoint,TailPoint);

  // Set Intersection Point Array length
  if (CellsBound.RowMax-CellsBound.RowMin>CellsBound.ColMax-CellsBound.ColMin) then
    NIntPt := (CellsBound.RowMax-CellsBound.RowMin)*2   //Marco: maybe this dimension can be optimized
  else
    NIntPt := (CellsBound.ColMax-CellsBound.ColMin)*2;
  NIntPt := NIntPt+2;
  setlength(IntPtArr,NIntPt);

  //Add head and tail of the line segment in the point array
  IntPtArr[0].X := HeadPoint.X;
  IntPtArr[0].Y := HeadPoint.Y;
  IntPtArr[1].X := TailPoint.X;
  IntPtArr[1].Y := TailPoint.Y;

  //Determine line equation of the line segment
  RoadLine := LineEqFromTwoPoints(HeadPoint,TailPoint);

  // Calculate all the intersections with vertical cells boundaries within the line segment
  NIntPt := 2;
  for i := (CellsBound.ColMin+1) to (CellsBound.ColMax-1) do
   begin
    TmpLine := LineEqForRowsOrCols(ISS,0,i); //Get vertical line equation x-i*scale =0
    IntPoint := TwoLinesIntersection(RoadLine, TmpLine); // Intersection point calculation
    IntPtArr[NIntPt] := IntPoint;
    NIntPt := NIntPt +1;
   end;

  // Calculate all the intersections with horizontal cells boundaries with the line segment
  for i := (CellsBound.RowMin+1) to (CellsBound.RowMax-1) do
   begin
    TmpLine := LineEqForRowsOrCols(ISS,i,0); //Get vertical line equation y-i*scale =0
    IntPoint := TwoLinesIntersection(RoadLine, TmpLine); // Intersection point calculation
    IntPtArr[NIntPt] := IntPoint;
    NIntPt := NIntPt+1;
   end;

  // Sort the intersection points. If the line is vertical sort for increasing Y, otherwise for increasing X
  if RoadLine.b=0 then
    begin
      Tmp := IntPtArr[0].X;
      for i := 0 to NIntPt-1 do
        IntPtArr[i].X := IntPtArr[i].Y;
      QuickSortPoints(IntPtArr,0,NIntPt-1);
      for i := 0 to NIntPt-1 do
        begin
          IntPtArr[i].Y := IntPtArr[i].X;
          IntPtArr[i].X := Tmp;
        end;
    end
  else
    QuickSortPoints(IntPtArr,0,NIntPt-1);



  // Calculate length between intersection point and the cell it belongs to
  for i := 1 to NIntPt-1 do
    begin
      //Length
      Dist := sqrt(sqr(IntPtArr[i].X-IntPtArr[i-1].X)+sqr(IntPtArr[i].Y-IntPtArr[i-1].Y));

      //MidPoint calculation
      MidPoint.X := (IntPtArr[i].X+IntPtArr[i-1].X)/2;
      MidPoint.Y := (IntPtArr[i].Y+IntPtArr[i-1].Y)/2;

      //Midpoint in Site scale units
      MidPoint.X := (MidPoint.X-SS.Site.LLXCorner)/SS.Site.RunScale;
      MidPoint.Y := (MidPoint.Y-SS.Site.LLYCorner)/SS.Site.RunScale;

      // Grid cell the line segment belongs to
      Row := floor(MidPoint.Y);
      Col := floor(MidPoint.X);

      //Get the cell
      //ISS.RetA(Row,Col,Cell);

      // Set the road length within the cell
      //Cell.RoadLength := Cell.RoadLength+Dist;

      // Set the the new value
      //ISS.SetA(Row,Col,Cell);
    end;

  // Set the general SLAMM simulation
  MainForm.SS := ISS;
end;
}
{
function TInfStructFileSetup.LineEqFromTwoPoints(HeadPoint, TailPoint: DPoint):DLine;
begin
  if (CompareValue(HeadPoint.X,TailPoint.X,0.0001) = EqualsValue) then
    begin
     Result.a := 1;
     Result.b := 0;
     Result.c := -HeadPoint.X;
    end
  else if (CompareValue(HeadPoint.Y,TailPoint.Y,0.0001) = EqualsValue) then
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
}
{
function TInfStructFileSetup.GetBoundaryCoordinates(SS: TSLAMM_Simulation; HeadPoint, TailPoint: DPoint): DBoundary;
  var
   Tmp1, Tmp2: Double;
  begin
    // Max and Min Rows Calculation
    Tmp1 := TailPoint.Y-SS.Site.LLYCorner;  // If it is not already in raster coordinates
    Tmp2 := HeadPoint.Y-SS.Site.LLYCorner;
    Tmp1 := Tmp1/SS.Site.RunScale;
    Tmp2 := Tmp2/SS.Site.RunScale;
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
    Tmp1 := TailPoint.X-SS.Site.LLXCorner;  // If it is not already in raster coordinates
    Tmp2 := HeadPoint.X-SS.Site.LLXCorner;
    Tmp1 := Tmp1/SS.Site.RunScale;
    Tmp2 := Tmp2/SS.Site.RunScale;
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
}
{
function TInfStructFileSetup.LineEqForRowsOrCols(SS: TSLAMM_Simulation; Row, Col: Integer): DLine;
begin
  if Col>0 then
    begin
      Result.a := 1;
      Result.b := 0;
      Result.c := -(Col*SS.Site.RunScale+SS.Site.LLXCorner) ;
    end
  else if Row>0 then
    begin
      Result.a := 0;
      Result.b := 1;
      Result.c := -(Row*SS.Site.RunScale+SS.Site.LLYCorner);
    end;

end;
}
{
function TInfStructFileSetup.TwoLinesIntersection(Line1, Line2 : DLine): DPoint;
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
}
{
procedure TInfStructFileSetup.QuickSortPoints(Arr: DPointArray; iLo, iHI: Integer);
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
}
procedure TInfStructFileSetup.RoadElevCheckBoxClick(Sender: TObject);
begin
  If Updating then Exit;

  BUseRoadElev := RoadElevCheckBox.Checked;

  UpdateScreen;
end;




end.
