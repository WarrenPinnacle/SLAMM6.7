//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//
unit FFForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Global, ExtCtrls, VCLTee.TeeProcs, VCLTee.TeEngine, VCLTee.Chart ,VCLTee.Series, SLR6, Grids,
  Buttons, System.UITypes;


type
  TSalinityForm = class(TForm)
    Chart1: TChart;
    DoneButton: TButton;
    CopyGraph: TButton;
    SalGrid: TStringGrid;
    RFBox: TCheckBox;
    IRFBox: TCheckBox;
    TSwampBox: TCheckBox;
    TFBox: TCheckBox;
    TFlatBox: TCheckBox;
    SwampBox: TCheckBox;
    FloodForestBox: TCheckBox;
    UndBox: TCheckBox;
    DevBox: TCheckBox;
    DefineSalinityRules: TButton;
    SalNumLabel: TLabel;
    ExcelExport: TButton;
    SaveDialog1: TSaveDialog;
    HelpButton: TBitBtn;
    RunSalinityAnalysis: TButton;
    RunLabelWarning: TLabel;
    SalAnalysisLabel: TLabel;
    HorzAxisOptPanel: TPanel;
    HorzAxisOptLabel: TLabel;
    XMinLabel: TLabel;
    XMaxLabel: TLabel;
    AutoXMinRadioButton: TRadioButton;
    XMinRadioButton: TRadioButton;
    XMinEdit: TEdit;
    MaxAxisOptPanel: TPanel;
    AutoXMaxRadioButton: TRadioButton;
    XMaxRadioButton: TRadioButton;
    XMaxEdit: TEdit;
    Panel1: TPanel;
    ComboBox1: TComboBox;
    SuppressZeroBox: TCheckBox;
    Label2: TLabel;
    ComboBox2: TComboBox;
    ElevHistOptLabel: TLabel;
    procedure Chart1ClickSeries(Sender: TCustomChart; Series: TChartSeries;
      ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure DoneButtonClick(Sender: TObject);
    procedure CopyGraphClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure SalGridDblClick(Sender: TObject);
    procedure FloodForestBoxClick(Sender: TObject);
    procedure DefineSalinityRulesClick(Sender: TObject);
    procedure SalGridClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SalGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ExcelExportClick(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure RunSalinityAnalysisClick(Sender: TObject);
    procedure XMinEditClick(Sender: TObject);
    procedure XMaxEditClick(Sender: TObject);
    procedure XEditKeyPress(Sender: TObject; var Key: Char);
    procedure XMaxRadioButtonClick(Sender: TObject);
    procedure RadioButtonClick(Sender: TObject);
{    procedure EstimateClick(Sender: TObject); }
  private
   WhichRow: Array[1..MaxCats] of Integer;

    { Private declarations }
  public
    MapLoaded : boolean;
    SS: TSLAMM_Simulation;
    CRow, SortCol, CCol: Integer;
    NwSLR: Double;
    SortUp: Boolean;
    Procedure ShowSalinityAnalysis;
    Procedure UpdateScreen;
    Procedure GraphSalinities;
    Procedure UpdateGrid;
    procedure UpdateGrid_File;
    Procedure UpdateRuleLabel;
    Procedure SortGrid;
    { Public declarations }
  end;

var
  SalinityForm: TSalinityForm;

implementation

uses Progress, SalRuleEdit,Elev_Analysis;


{$R *.DFM}


procedure TSalinityForm.SalGridClick(Sender: TObject);
begin
    {}
end;

procedure TSalinityForm.SalGridDblClick(Sender: TObject);
begin
  If CRow=0 then
    Begin
      If SortCol = CCol then SortUp := Not Sortup;
      SortCol := CCol;
      SortGrid;
    End;
end;

procedure TSalinityForm.SalGridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  SalGrid.MouseToCell(x,y,Ccol,Crow);
end;

Procedure TSalinityForm.SortGrid;
var
   Exchange: Boolean;
   i,j : integer;
   temp:tstringlist;
   tempcat: Integer;
begin
  temp:=tstringlist.create;
  with SalGrid do
   for i := 1 to RowCount - 2 do  {because last row has no next row}
    for j:= i+1 to rowcount-1 do {from next row to end}
     Begin
       If  SortCol in [0,2,4,7]
         then Exchange :=
               ((AnsiCompareText(Cells[SortCol, i], Cells[SortCol,j]) > 0) and SortUp) or
               ((AnsiCompareText(Cells[SortCol, i], Cells[SortCol,j]) < 0) and (Not SortUp))
         else Exchange := (SortUp and (StrToFloat(Cells[SortCol, i]) > StrToFloat(Cells[SortCol, j]))) or
                          (not SortUp and (StrToFloat(Cells[SortCol, i]) < StrToFloat(Cells[SortCol, j])));
       If Exchange then
         begin
           temp.assign(rows[j]);    tempcat := WhichRow[j];
           rows[j].assign(rows[i]); WhichRow[j] := WhichRow[i];
           rows[i].assign(temp);    WhichRow[i] := tempcat;
         end;
     End;

   temp.free;
end;

Procedure TSalinityForm.ShowSalinityAnalysis;
begin
  UpdateScreen;
  GraphSalinities;
  UpdateGrid;
  //if SS.SalFileN ='' then
  UpdateRuleLabel;
  //ShowModal;
end;

Procedure TSalinityForm.UpdateScreen;
//-----------------------------------
// Update the salinity form
//-----------------------------------
begin
  //Default ojects visibilities
  ComboBox1.Visible := True;
  SuppressZeroBox.Visible := True;
  DefineSalinityRules.Visible := True;
  SalNumLabel.Visible := True;
  RunSalinityAnalysis.Visible := True;
  RunSalinityAnalysis.Enabled :=False;
  RunLabelWarning.Visible := True;

  //Deafault checkboxes status
  RFBox.Enabled := False;
  IRFBox.Enabled := False;
  TFBox.Enabled := False;
  TSwampBox.Enabled := False;
  SwampBox.Enabled := False;
  TFlatBox.Enabled := False;
  DevBox.Enabled := False;
  UndBox.Enabled := False;
  FloodForestBox.Enabled := False;

  // If the salinity raster available
  if (trim(SS.SalFileN)<>'') and (Pos('.xls',lowercase(SS.SalFileN))=0) then
    begin
      if MapLoaded then
        begin
          RunSalinityAnalysis.Enabled :=True;
          RunLabelWarning.Visible := False;
        end;
      ComboBox1.Visible := False;
    end;

  //If no salinity file or the excel file available
   if ((trim(SS.SalFileN)='') or (Pos('.xls',lowercase(SS.SalFileN))>0)) then
    begin
      ComboBox1.Visible := False;
    end;

  if SS.Year>0 then
    begin
      RunSalinityAnalysis.Enabled :=True;
      RunLabelWarning.Visible := False;
    end;

(*    with SS.SalStats do
      begin
        if N[1,RegFloodMarsh]>0 then RFBox.Enabled := True;
        if N[1,IrregFloodMarsh]>0 then IRFBox.Enabled := True;
        if N[1,TidalFreshMarsh]>0 then TFBox.Enabled := True;
        if N[1,TidalSwamp]>0 then TSwampBox.Enabled := True;
        if N[1,Swamp]>0 then SwampBox.Enabled := True;
        if N[1,TidalFlat]>0 then TFlatBox.Enabled := True;
        if N[1,DevDryLand]>0 then DevBox.Enabled := True;
        if N[1,UndDryLand]>0 then UndBox.Enabled := True;
        if N[1,FloodForest]>0 then FloodForestBox.Enabled := True;   FIXME2
      end;                                                                  *)

end;

Procedure TSalinityForm.UpdateRuleLabel;
Begin
  If SS.SalRules.NRules = 0 then SalNumLabel.Caption := '(none defined)'
                            else SalNumLabel.Caption := IntToStr(SS.SalRules.NRules)+' rules defined';
End;


Procedure TSalinityForm.GraphSalinities;
//=============================================
// Graph the salinity plots when box is checked
//=============================================
Const Tiny = 1e-10;
Var  Ct : Integer;
     i, j, k, CNum: Integer;
     DrawCat: Boolean;
     NewSeries: TLineSeries;
     XMin, XMax: Double;
     YValue: extended;
     nSeries: integer;
     NBin: integer;
     NHistAgg: integer;
     UHistogram:  Array[1..NUM_SAL_METRICS,1..MaxCats] of array of Integer;


     Procedure InitNewSeries;
     Begin
       NewSeries := TLineSeries.Create(Chart1);
       NewSeries.Pointer.visible:=True;
       NewSeries.LinePen.Width := 2;
       NewSeries.Pointer.VertSize := 3;
       NewSeries.Pointer.HorizSize := 3;
       NewSeries.Pointer.Style:=psSmallDot;
     End;

(*     Function FTS(F: Double): String;
     Begin
       FTS := FloatToSTrF(F,ffgeneral,6,3);
     End;
*)

Begin
  // Get the histogram to draw
  if trim(SS.SalFileN)<>'' then
    CNum := 1
  else
    CNum := ComboBox1.ItemIndex + 1;

  // Inizialize NBin
  with ComboBox2 do
    NBin :=strtoint(Items[ItemIndex]);
  for i := 1 to NUM_SAL_METRICS do
    for Ct := 0 to SS.Categories.NCats-1 do
     With SS.Categories.GetCat(Ct).SalinityStats do
      SetLength(UHistogram[i,Ct], NBin);


 Try
  //Initialize the number of time series
  nSeries:= 0;

  //Free the exisiting series
  While Chart1.SeriesCount>0 do Chart1.Series[0].Free;

  With SS do
    for Ct := 0 to SS.Categories.NCats-1 do
     With SS.Categories.GetCat(Ct).SalinityStats do
    begin
      DrawCat := True;
      // CT is drawn if is one of the wetlands below and corresponding box checked
(*      DrawCat := ((CT = RegFloodMarsh) and RFBox.Checked) or
                ((CT = IrregFloodMarsh) and IRFBox.Checked) or
                ((CT = TidalFreshMarsh) and TFBox.Checked) or
                ((CT = TidalSwamp) and TSwampBox.Checked) or
                ((CT = Swamp) and SwampBox.Checked) or
                ((CT = TidalFlat) and TFlatBox.Checked) or
                ((CT = DevDryLand) and DevBox.Checked) or
                ((CT = UndDryLand) and UndBox.Checked) or
                ((CT = FloodForest) and FloodForestBox.Checked); Fixme2 *)

      if (DrawCat) and (N[CNum] >0)  then
        begin
          //Initilize a new series
          InitNewSeries;

          // Add new series
          Chart1.AddSeries(NewSeries);

          // Add title
          Chart1.Series[nSeries].Title := SS.Categories.GetCat(Ct).TextName;

          // Add color
          Chart1.Series[nSeries].Color:= SS.Categories.GetCat(Ct).Color;

          // Change the bin numbers
          NHistAgg := trunc(SalHistWidth/NBin);
          k := 0;
          for i := 0 to NBin-1 do
            begin
              UHistogram[CNum,Ct,i] := 0;
              for j := 0 to NHistAgg - 1 do
                UHistogram[CNum,Ct,i] := UHistogram[CNum,Ct,i]+ Histogram[CNum,k+j];
              k := k+NHistAgg;
            end;

          // Add a point for each bin
          for i := 0 to NBin-1 do
            begin
                begin

                  // Suppress zero count
                  if SuppressZeroBox.checked and (i=0) then continue;


                  //if (i=0) or ((i=1) and (SuppressZeroBox.Checked))
                  //    then NewSeries.AddXY(MinHist {0} ,0,'',clteecolor);

                  // XMin and XMax of the bin
                  XMin := MinHist + i*(MaxHist - MinHist)/NBin;
                  XMax := XMin + (MaxHist - MinHist)/NBin;

                  // Add points at (XMin,YValue) and (XMax,YValue)
                  YValue := UHistogram[CNum,Ct,i]/N[CNum];
                  Chart1.Series[nSeries].AddXY(XMin+Tiny,YValue,'',clteecolor);
                  Chart1.Series[nSeries].AddXY(XMax,YValue,'',clteecolor);

                  // Last bin get a zero value
                  if i=(NBin-1) then Chart1.Series[nSeries].AddXY(XMax,0,'',clteecolor);

                end;
            end; {for}

            // Consider the next series
            inc(nSeries);

        end; {if DrawCat}


    end; {ct Loop}

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


  Except
  End;

End;

procedure TSalinityForm.HelpButtonClick(Sender: TObject);
begin
   Application.HelpContext(1012);  //'Salinity.html');
end;

procedure TSalinityForm.RunSalinityAnalysisClick(Sender: TObject);
begin
  if MapLoaded then
    begin
      SS.AggrSalinityStats;
      ShowSalinityAnalysis;
    end;
end;

procedure TSalinityForm.RadioButtonClick(Sender: TObject);
begin
  GraphSalinities;
end;

procedure TSalinityForm.FloodForestBoxClick(Sender: TObject);
begin
  GraphSalinities;
end;

procedure TSalinityForm.Chart1ClickSeries(Sender: TCustomChart;
  Series: TChartSeries; ValueIndex: Integer; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ShowMessage(Series.Title+', Salinity '+ Floattostrf(Series.XValue[valueindex],ffGeneral,6,3) + ':  ' + Floattostrf(100*Series.YValue[valueindex],ffGeneral,6,3)+ '%');
end;

procedure TSalinityForm.DefineSalinityRulesClick(Sender: TObject);
begin
  SalRuleForm.SS := SS;
  SalRuleForm.EditRules(SS.SalRules);
  UpdateRuleLabel;
end;

procedure TSalinityForm.DoneButtonClick(Sender: TObject);
begin
  modalresult := mrok;
end;

procedure TSalinityForm.ExcelExportClick(Sender: TObject);
Var SaveName: String;
begin
      // Create save dialog and set it options
      with SaveDialog1 do
      begin
         DefaultExt := 'xls' ;
         Filter := 'Excel files (*.xls)|*.xls|All files (*.*)|*.*' ;
         Options := [ofOverwritePrompt,ofPathMustExist,ofNoReadOnlyReturn,ofHideReadOnly] ;
         Title := 'Please Specify an Excel File into which to Save this Table:';
      end ;

   if not SaveDialog1.Execute then exit;

   SaveName := SaveDialog1.FileName;
   If FileExists(SaveDialog1.FileName) then If Not DeleteFile(SaveName)
     then Begin
            MessageDlg('Cannot gain exclusive access to the file to overwrite it.',mtError,[mbOK],0);
            Exit;
          End;

 SaveAsExcelFile(SalGrid, 'Sal Analysis', SaveName);
end;

procedure TSalinityForm.FormCreate(Sender: TObject);
begin
  CCol := -1; CRow := -1; SortCol := -1; SortUp := True;
end;

procedure TSalinityForm.ComboBox1Change(Sender: TObject);
begin
  GraphSalinities;
end;

procedure TSalinityForm.CopyGraphClick(Sender: TObject);
begin
  Chart1.CopytoClipBoardMetaFile(True);
end;


procedure TSalinityForm.UpdateGrid;
Var nRows, i: Integer;
    catloop: Integer;
    rowindex: integer;

begin
  if trim(SS.SalFileN)<>'' then Begin UpdateGrid_File; Exit; End;

  With SalGrid do
    Begin
      NRows := 22;
      RowCount := NRows+1;  {plus header}

      ColCount := 15;

      ColWidths[0]:=205;
      ColWidths[2]:=10;

     For i := 0 to RowCount-1 do
        Rows[i].Clear;

      Rows[0].Add('SLAMM Category');
      Rows[0].Add('n cells MHHW');
      Rows[0].Add(' ');

      Rows[0].Add('5th(MLLW)');
      Rows[0].Add('mean(MLLW)');
      Rows[0].Add('95th(MLLW)');
      Rows[0].Add('5th(MTL)');
      Rows[0].Add('mean(MTL)');
      Rows[0].Add('95th(MTL)');
      Rows[0].Add('5th(MHHW)');
      Rows[0].Add('mean(MHHW)');
      Rows[0].Add('95th(MHHW)');
      Rows[0].Add('5th(30D)');
      Rows[0].Add('mean(30D)');
      Rows[0].Add('95th(30D)');

      If not SS.Init_SalStats then
        SalAnalysisLabel.Caption := 'Salinity Analysis has not been run'
      else
          Begin
 //            SalAnalysisLabel.Caption := 'Last Salinity Analysis '+ DateTimeToStr(Derived);  FIXME2
            RowIndex :=0;
            For CatLoop := 0 to SS.Categories.NCats-1 do
//              If not (CatLoop in [Blank,NotUsed,EstuarineWater,OpenOcean]) then  FIXME2
              With SS.Categories.GetCat(CatLoop).SalinityStats do
                Begin
                  Inc(RowIndex);
                  WhichRow[RowIndex] := CatLoop;
                  Rows[RowIndex].Add(SS.Categories.GetCat(CatLoop).TextName);
                  Rows[RowIndex].Add(IntToStr(N[1]));     //Changed from 3
                  Rows[RowIndex].Add(''); //notes in future editions?

                  For i := 1 to NUM_SAL_METRICS do
                    Begin
                      Rows[RowIndex].Add(FloatToStrf(p05[i],FFGeneral,6,4));
                      Rows[RowIndex].Add(FloatToStrf(mean[i],FFGeneral,6,4));
                      Rows[RowIndex].Add(FloatToStrf(p95[i],FFGeneral,6,4));
                    End;
                End;
          End;
    End; {With SalGrid}

end;


procedure TSalinityForm.UpdateGrid_File;
Var nRows, i: Integer;
    catloop: Integer;
    rowindex: integer;
    CNum: integer;

begin
  CNum := 1;

  With SalGrid do
    Begin
      NRows := 22;
      RowCount := NRows+1;  {plus header}

      ColCount := 9;

      ColWidths[0]:=205;
      ColWidths[2]:=10;

     For i := 0 to RowCount-1 do
        Rows[i].Clear;

      Rows[0].Add('SLAMM Category');
      Rows[0].Add('n cells');
      Rows[0].Add(' ');

      Rows[0].Add('5th pctile');
      Rows[0].Add('mean ');
      Rows[0].Add('95th pctile');
      Rows[0].Add('st.dev. ');
      Rows[0].Add('min ');
      Rows[0].Add('max ');

      If not SS.Init_SalStats then
        SalAnalysisLabel.Caption := 'Salinity Analysis has not been run'
      else
          Begin
//            SalAnalysisLabel.Caption := 'Last Salinity Analysis '+DateTimeToStr(Derived);  FIXME2
            RowIndex :=0;
            For CatLoop := 0 to SS.Categories.NCats-1 do
//              If not (CatLoop in [Blank,NotUsed,EstuarineWater,OpenOcean]) then  FIXME2
              With SS.Categories.GetCat(CatLoop).SalinityStats do
                Begin
                  Inc(RowIndex);
                  WhichRow[RowIndex] := CatLoop;
                  Rows[RowIndex].Add(SS.Categories.GetCat(CatLoop).TextName);
                  Rows[RowIndex].Add(IntToStr(N[CNum]));
                  Rows[RowIndex].Add(''); //notes in future editions?

                  Rows[RowIndex].Add(FloatToStrf(p05[CNum],FFGeneral,6,4));
                  Rows[RowIndex].Add(FloatToStrf(mean[CNum],FFGeneral,6,4));
                  Rows[RowIndex].Add(FloatToStrf(p95[CNum],FFGeneral,6,4));
                  Rows[RowIndex].Add(FloatToStrf(StDev[CNum],FFGeneral,6,4));
                  Rows[RowIndex].Add(FloatToStrf(min[CNum],FFGeneral,6,4));
                  Rows[RowIndex].Add(FloatToStrf(max[CNum],FFGeneral,6,4));
                End;

          End;
    End; {With SalGrid}

end;

procedure TSalinityForm.XMaxEditClick(Sender: TObject);
begin
XMaxRadioButton.Checked := True;
end;

procedure TSalinityForm.XMaxRadioButtonClick(Sender: TObject);
begin
if strtofloat(XMaxEdit.Text)>0 then GraphSalinities;
end;

procedure TSalinityForm.XMinEditClick(Sender: TObject);
begin
XMinRadioButton.Checked := True;
end;

procedure TSalinityForm.XEditKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = #13 Then
    begin
      Key := #0;
      Perform(WM_NEXTDLGCTL, 0, 0);  {Move to next object in turn}
    end;
end;


end.


