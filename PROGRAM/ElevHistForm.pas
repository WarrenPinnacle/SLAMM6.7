unit ElevHistForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Global, ExtCtrls, VCLTee.TeeProcs, VCLTee.TeEngine, VCLTee.Chart, VCLTee.Series, SLR6, Grids,
  copyclip, ExcelFuncs, Buttons;

type
  TElevHist = class(TForm)
    Chart1: TChart;
    Panel2: TPanel;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    CheckBox16: TCheckBox;
    CheckBox17: TCheckBox;
    CheckBox18: TCheckBox;
    CheckBox19: TCheckBox;
    CheckBox20: TCheckBox;
    CheckBox21: TCheckBox;
    CheckBox22: TCheckBox;
    CheckBox23: TCheckBox;
    CheckBox24: TCheckBox;
    CheckBox25: TCheckBox;
    CheckBox26: TCheckBox;
    CopyGraphButton1: TButton;
    SaveExcelButton1: TButton;
    HorzAxisOptPanel: TPanel;
    HorzAxisOptLabel: TLabel;
    XMinLabel: TLabel;
    AutoXMinRadioButton: TRadioButton;
    XMinRadioButton: TRadioButton;
    XMinEdit: TEdit;
    ElevHistOptPanel: TPanel;
    ElevUnitLabel: TLabel;
    ElevZeroLabel: TLabel;
    ElevBinLabel: TLabel;
    ElevUnitsBox: TComboBox;
    ElevZeroBox: TComboBox;
    ElevBinsBox: TComboBox;
    ElevHistOptLabel: TLabel;
    XMaxLabel: TLabel;
    MaxAxisOptPanel: TPanel;
    AutoXMaxRadioButton: TRadioButton;
    XMaxRadioButton: TRadioButton;
    XMaxEdit: TEdit;
    AreaLabel: TLabel;
    AreaBox: TComboBox;
    VertAxisOptPanel: TPanel;
    Label1: TLabel;
    YMinLabel: TLabel;
    Label3: TLabel;
    AutoYMinRadioButton: TRadioButton;
    YMinRadioButton: TRadioButton;
    YMinEdit: TEdit;
    MaxYOptPanel: TPanel;
    AutoYMaxRadioButton: TRadioButton;
    YMaxRadioButton: TRadioButton;
    YMaxEdit: TEdit;
    CellCountBox: TCheckBox;
    CheckBox27: TCheckBox;
    CheckBox28: TCheckBox;
    procedure BoxChange(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure CopyGraphButton1Click(Sender: TObject);
    procedure SaveExcelButton1Click(Sender: TObject);
    procedure RadioButtonClick(Sender: TObject);
    procedure XMinEditClick(Sender: TObject);
    procedure XMaxEditClick(Sender: TObject);
    procedure XEditKeyPress(Sender: TObject; var Key: Char);
    procedure XMaxRadioButtonClick(Sender: TObject);
    procedure CellCountBoxClick(Sender: TObject);

  private
    { Private declarations }
  public
    SS: TSLAMM_Simulation;
    procedure PlotElevHist;
  end;

type
  TWetlandButton = record
  chkbox:TCheckBox;
  end;

  WetlandButton = array [0..MaxCats-1] of TWetlandButton;

var
  ElevHist: TElevHist;
  cbWetland: WetlandButton;

implementation

uses Progress, SalRuleEdit,Elev_Analysis, System.UITypes;

{$R *.dfm}

procedure TElevHist.CellCountBoxClick(Sender: TObject);
begin
 PlotElevHist
end;

procedure TElevHist.CheckBoxClick(Sender: TObject);
begin
 PlotElevHist;
end;

procedure TElevHist.CopyGraphButton1Click(Sender: TObject);
//===========================================================
// Save data to bitmap
//===========================================================
begin
Application.CreateForm(TCopyClipbd, CopyClipbd);
  Try
  If CopyClipBd.Showmodal=mrcancel then exit;

 If CopyClipBd.BmpButt.Checked then Chart1.CopytoClipBoardBitmap
                                else Chart1.CopytoClipBoardMetaFile(True);

  Finally
    CopyClipbd.Free;
  End;

end;

procedure TElevHist.BoxChange(Sender: TObject);
begin
 PlotElevHist;
end;

procedure TElevHist.PlotElevHist;
Const Tiny = 1e-10;
Var  Ct : Integer;
     i, j, k, CNum, CNumArea, CNumUnit, CNumZero: Integer;
     NewSeries: TLineSeries;
     XMin, XMax: Double;
     nSeries: integer;
     NBin: integer;
     NHistAgg: integer;
     UHistogram:  Array[1..8,0..MaxCats] of array of Integer;
     NNormal: integer;

     Procedure InitNewSeries;
     Begin
       NewSeries := TLineSeries.Create(Chart1);
       NewSeries.Pointer.visible:=True;
       NewSeries.LinePen.Width := 2;
       NewSeries.Pointer.VertSize := 3;
       NewSeries.Pointer.HorizSize := 3;
       NewSeries.Pointer.Style:=psSmallDot;
     End;

     Function FTS(F: Double): String;
     Begin
       FTS := FloatToSTrF(F,ffgeneral,6,3);
     End;


Begin
  // Get the histogram to draw
  CNumArea := AreaBox.ItemIndex;
  CNumUnit := ElevUnitsBox.ItemIndex;
  CNumZero := ElevZeroBox.ItemIndex + 1;
  CNum := CNumUnit*4+CNumZero;

  // Inizialize NBin
  with ElevBinsBox do
    NBin :=strtoint(Items[ItemIndex]);
  for i := 1 to 8 do
    for Ct := 0 to SS.Categories.NCats-1 do
      SetLength(UHistogram[i,Ct], NBin);

  // Change the caption depending on the units
  if CNumUnit = 1 then
    Chart1.BottomAxis.Title.Caption := 'Elevation (m)'
  else
    Chart1.BottomAxis.Title.Caption := 'Elevation (HTU)';

  //Change caption depending on the cell count box checked
  if CheckBox27.Checked then
    Chart1.LeftAxis.Title.Caption := 'Cell Count'
  else
    Chart1.LeftAxis.Title.Caption := 'Fraction';

  Try

  // Initiaziize the number of time series
  nSeries:= 0;


  // Free the existing series
  While Chart1.SeriesCount>0 do Chart1.Series[0].Free;

  With SS do
   for Ct := 0 to SS.Categories.NCats-1 do
    With SS.Categories.GetCat(CT).ElevationStats[CNumArea] do
    begin
      // Enable/Disable buttons of wetlands present/not present in the area
      cbWetland[Ct].chkbox.Enabled := True;
      if N = 0 then
        begin
          cbWetland[Ct].chkbox.checked := False;
          cbWetland[Ct].chkbox.Enabled := False;
        end;

      // if the wetland checkbox is checked then ...
      if cbWetland[Ct].chkbox.checked = True then
        begin
          if N > 0 then
            begin
              InitNewSeries;

              // Add new series
              Chart1.AddSeries(NewSeries);

              // Add title
              Chart1.Series[nSeries].Title := SS.Categories.GetCat(CT).TextName;
              //NewSeries.Title := TitleCat[Ct];

              // and color
              Chart1.Series[nSeries].Color:= SS.Categories.GetCat(CT).Color;

              // Change the bin numbers
              NHistAgg := trunc(HistWidth/NBin);
              k := 0;
              for i := 0 to NBin-1 do
                begin
                  UHistogram[CNum,Ct,i] := 0;
                  for j := 0 to NHistAgg - 1 do
                    UHistogram[CNum,Ct,i] := UHistogram[CNum,Ct,i]+Histogram[CNum,k+j];
                  k := k+NHistAgg;
                end;

              // Define the cell count/fraction
              NNormal := N;
              if CheckBox27.Checked then NNormal := 1;

              // Add points
              for i := 0 to NBin-1 do
                begin
                  //If (i=0) or ((i=1)) then Chart1.Series[nSeries].AddXY(MinHist {0} ,0,'',clteecolor);

                  // XMin and XMax of the bin
                  XMin := Stats[CNum].Min + i*(Stats[CNum].Max - Stats[CNum].Min)/NBin;
                  XMax := XMin + (Stats[CNum].Max - Stats[CNum].Min)/NBin;

                  // Add point1
                  Chart1.Series[nSeries].AddXY(XMin+Tiny,UHistogram[CNum,Ct,i]/NNormal,'',clteecolor);
                  //NewSeries.AddXY(XMin+Tiny,Histogram[CNum,Ct,i]/N[Ct],'',clteecolor);

                  // Add point2
                  Chart1.Series[nSeries].AddXY(XMax,UHistogram[CNum,Ct,i]/NNormal,'',clteecolor);
                  //NewSeries.AddXY(XMax,Histogram[CNum,Ct,i]/N[Ct],'',clteecolor);

                   // Add point1

                  //Chart1.Series[nSeries].AddXY(XMin+Tiny,UHistogram[CNum,Ct,i],'',clteecolor);
                  //NewSeries.AddXY(XMin+Tiny,Histogram[CNum,Ct,i]/N[Ct],'',clteecolor);

                  // Add point2
                  //Chart1.Series[nSeries].AddXY(XMax,UHistogram[CNum,Ct,i],'',clteecolor);
                  //NewSeries.AddXY(XMax,Histogram[CNum,Ct,i]/N[Ct],'',clteecolor);


                  // Last bin get a zero value
                  If i=NBin-1 then Chart1.Series[nSeries].AddXY(XMax,0,'',clteecolor);
                end;

            end;

          // Consider the next time series
          inc(nSeries);

        end;

    end;


   // Set min/max bottom axis
   Chart1.BottomAxis.AutomaticMinimum := False;
   Chart1.BottomAxis.AutomaticMaximum := False;

   if nSeries>0 then
   begin
   if AutoXMinRadioButton.Checked and AutoXMaxRadioButton.Checked then
    begin
      Chart1.BottomAxis.AutomaticMinimum := True;
      Chart1.BottomAxis.AutomaticMaximum := True;
    end;

   if AutoXMinRadioButton.Checked and XMaxRadioButton.Checked then
    begin
      Chart1.BottomAxis.Minimum := 0;
      Chart1.BottomAxis.Maximum :=strtofloat(XMaxEdit.Text);
      Chart1.BottomAxis.AutomaticMinimum := True;
    end;

   if XMinRadioButton.Checked and AutoXMaxRadioButton.Checked then
    begin
      Chart1.BottomAxis.Minimum := 0;
      Chart1.BottomAxis.AutomaticMaximum := True;
      Chart1.BottomAxis.Minimum := strtofloat(XMinEdit.Text);
    end;

   if XMinRadioButton.Checked and XMaxRadioButton.Checked then
    begin
      Chart1.BottomAxis.Minimum := 0;
      if strtofloat(XMaxEdit.Text)<strtofloat(XMinEdit.Text) then
        MessageDlg( 'The maximum must be greater than the minimum.',mtWarning, [mbOK], 0)
      else
       begin
        Chart1.BottomAxis.Maximum := strtofloat(XMaxEdit.Text);
        Chart1.BottomAxis.Minimum := strtofloat(XMinEdit.Text);
       end;
    end;
    end;

    // Set min/max y axis
   Chart1.LeftAxis.AutomaticMinimum := False;
   Chart1.LeftAxis.AutomaticMaximum := False;

   if nSeries>0 then
    begin
      if AutoYMinRadioButton.Checked and AutoYMaxRadioButton.Checked then
        begin
          Chart1.LeftAxis.AutomaticMinimum := True;
          Chart1.LeftAxis.AutomaticMaximum := True;
        end;

      if AutoYMinRadioButton.Checked and YMaxRadioButton.Checked then
        begin
          Chart1.LeftAxis.Minimum := 0;
          Chart1.LeftAxis.Maximum :=strtofloat(YMaxEdit.Text);
          Chart1.LeftAxis.AutomaticMinimum := True;
        end;

      if YMinRadioButton.Checked and AutoYMaxRadioButton.Checked then
        begin
          Chart1.LeftAxis.Minimum := 0;
          Chart1.LeftAxis.AutomaticMaximum := True;
          Chart1.LeftAxis.Minimum := strtofloat(YMinEdit.Text);
        end;

      if YMinRadioButton.Checked and YMaxRadioButton.Checked then
        begin
          Chart1.LeftAxis.Minimum := 0;
          if strtofloat(YMaxEdit.Text)<strtofloat(YMinEdit.Text) then
            MessageDlg( 'The maximum must be greater than the minimum.',mtWarning, [mbOK], 0)
          else
            begin
              Chart1.LeftAxis.Maximum := strtofloat(YMaxEdit.Text);
              Chart1.LeftAxis.Minimum := strtofloat(YMinEdit.Text);
            end;
        end;
    end;

  Except
  End;

End;



procedure TElevHist.RadioButtonClick(Sender: TObject);
begin
PlotElevHist;
end;

procedure TElevHist.SaveExcelButton1Click(Sender: TObject);
//==========================================================
// Save histogram data in an Excel file
var
  TEx: TExcelOutput;
  BaseName: String;
  i,j,k: integer;
  CNumArea, CNumUnit, CNumZero, CNum: integer;
  UStr, ZeroStr: string;
  Cat: Integer;
  XMin, DBin, Tmp : double;


begin

  TEx := TExcelOutput.Create(False);

  if TEx.GetSaveName(BaseName,'Please Specify an Excel File into which to save the numerical data:') then
  begin

    // Get the histograms to save on file
    CNumArea := AreaBox.ItemIndex;
    CNumUnit := ElevUnitsBox.ItemIndex;
    CNumZero := ElevZeroBox.ItemIndex+1;
    CNum := CNumUnit*4 + CNumZero;

    // Get text from comboboxes
    Ustr := ElevUnitsBox.Text;
    ZeroStr := ElevZeroBox.Text;

    // Name of the workseet
    TEx.WS.Name := 'Units=' +UStr +', Zero=' +ZeroStr;


    // Insert column headers into sheet
    //i := 1;
    //Tex.WS.Cells.Item[i,1].Value := 'N Bin';
    //TEx.WS.Cells.Item[i,1].Font.FontStyle := 'Bold';

    j := 1;
   for Cat := 0 to SS.Categories.NCats-1 do
    With SS.Categories.GetCat(Cat).ElevationStats[CNumArea] do
      begin
        if N > 0 then
          begin
            // Inizialize row
            i := 1;

            // Insert Column Header
            TEx.WS.Cells.Item[i,j].Value := SS.Categories.GetCat(Cat).TextName;
            TEx.WS.Cells.Item[i,j].Font.FontStyle := 'Bold';
            i := i+1;


            // Added column titles
            TEx.WS.Cells.Item[i,j].Value := 'Elev. (' +UStr +',' +ZeroStr +')' ;
            TEx.WS.Cells.Item[i,j+1].Value := 'Frequency';
            i :=i+1;

            // Value of the minimum
            XMin := Stats[CNum].Min;
            TEx.WS.Cells.Item[i,j].Value := XMin;
            TEx.WS.Cells.Item[i,j+1].Value := 0;
            i := i+1;

            // BinInterval
            DBin := (Stats[CNum].Max - Stats[CNum].Min) / HistWidth;

            // Value for each bin
            for k := 0 to HistWidth-1 do
              begin
                XMin := XMin+DBin;
                TEx.WS.Cells.Item[i,j].Value := XMin;
                Tmp := Histogram[CNum,k]/N;
                TEx.WS.Cells.Item[i,j+1].Value := Tmp;
                i := i+1;
              end;

            // Value of the maximumn
            //TEx.WS.Cells.Item[i,j].Value := Stats[CNum].Max;
            //TEx.WS.Cells.Item[i,j+1].Value := 0;

            // Advance columns
            j := j+2;
          end;
      end;

    // Fit columns to content
    TEx.WS.Columns.AutoFit;

    //TEx.WS := TEx.Wbk.Sheets.Add(EmptyParam,TEx.Wbk.sheets.item[TEx.Wbk.sheets.count],1,xlWorkSheet,TEx.LCID);

    // Save and close excel spreadsheet file
    TEx.SaveAndClose;

  end;
end;


procedure TElevHist.XMaxEditClick(Sender: TObject);
begin
XMaxRadioButton.Checked := True;
end;

procedure TElevHist.XMaxRadioButtonClick(Sender: TObject);
begin
if strtofloat(XMaxEdit.Text)>0 then PlotElevHist;
end;

procedure TElevHist.XMinEditClick(Sender: TObject);
begin
XMinRadioButton.Checked := True;
end;

procedure TElevHist.XEditKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = #13 Then
    begin
      Key := #0;
      Perform(WM_NEXTDLGCTL, 0, 0);  {Move to next object in turn}
    end;
end;

end.
