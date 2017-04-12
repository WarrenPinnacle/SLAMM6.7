//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit Elev_Analysis;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Main, StdCtrls, Grids, Menus, ExtCtrls, Clipbrd, Global, SLR6,
  Buttons;

type
  TElevAnalysisForm = class(TForm)
    Button3: TButton;
    Button4: TButton;
    ModLabel: TLabel;
    TSGrid: TStringGrid;
    Label1: TLabel;
    ElevAnalysisLabel: TLabel;
    ElevAnalysis: TButton;
    HTULabel: TLabel;
    ExcelExport: TButton;
    SaveDialog1: TSaveDialog;
    HelpButton: TBitBtn;
    RunElevWarning: TLabel;
    Label2: TLabel;
    HistFormButton: TButton;
    Label3: TLabel;
    Label4: TLabel;
    ElevUnitsBox: TComboBox;
    ElevZeroBox: TComboBox;
    ElevAreasBox: TComboBox;
    ElevAll: TButton;
    Label5: TLabel;
    procedure ComboBox1Change(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure TSGridExit(Sender: TObject);
    procedure TSGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure TSGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure FormCreate(Sender: TObject);
    procedure CostEditExit(Sender: TObject);
    procedure TSGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure TSGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ElevAnalysisClick(Sender: TObject);
    procedure ExcelExportClick(Sender: TObject);
    procedure TSGridDblClick(Sender: TObject);
    procedure TSGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure HelpButtonClick(Sender: TObject);
    procedure MetersBoxClick(Sender: TObject);
    procedure HistFormButtonClick(Sender: TObject);
    procedure ElevUnixBoxChange(Sender: TObject);
    procedure ElevZeroBoxChange(Sender: TObject);
    procedure ElevAreasBoxChange(Sender: TObject);
    
  private
 //   DontUpdate : Boolean;
    SS: TSLAMM_Simulation;
    SortUp: Boolean;
    SortCol: Integer;
    WhichRow: Array[1..MaxCats] of Integer;
    Ccol, Crow: Integer;


    { Private declarations }
  public
    MapLoaded: Boolean;
    ValStr  : String;
    EditRow, EditCol : Integer;
    AreasSelected: array [0..10] of boolean;
    SaveStream: TMemoryStream;
    Procedure ElevationAnalysis(Var PSS: TSLAMM_Simulation);
    Procedure UpdateTSGrid;
    procedure UpdateElevAreasList;
    Procedure SortTSGrid;
    Procedure UpdateScreen();
    { Public declarations }
  end;

var
  ElevAnalysisForm: TElevAnalysisForm;

Function SaveAsExcelFile(AGrid: TStringGrid; ASheetName, AFileName: string): Boolean;

implementation

Uses Comobj, ElevHistForm, System.UITypes, VCLTee.TeEngine;

{$R *.dfm}





procedure TElevAnalysisForm.TSGridDblClick(Sender: TObject);

begin
  If CRow=0 then
    Begin
      If SortCol = CCol then SortUp := Not Sortup;
      SortCol := CCol;
      SortTSGrid;
    End;

end;

procedure TElevAnalysisForm.TSGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  If (ARow=0) or (ACol=0) then
      with TSGrid.Canvas do
        begin
          Font.Style := [fsbold];
        end;

end;

procedure TElevAnalysisForm.TSGridExit(Sender: TObject);
Var R, C: Integer;
    V: String;
    EditCat: Integer;

    Function RemovePct(Str: String):String;
    Var P: Integer;
    Begin
      Result := Str;
      P := Pos('%',Result);
      While P>0 Do
        Begin
          Delete(Result,P,1);
          P := Pos('%',Result);
        End;
    End;

Var UType: ElevUnit;
begin
 IF EditRow < 1 then exit;
 If EditCol < 1 then exit;

  If (Trim(ValStr) = '~') then exit;
  R := EditRow; C := EditCol; V := ValStr;
  EditRow := -1; EditCol := -1; ValStr := '~';

  EditCat := WhichRow[R];
  If v='' then Exit;

  Try
   Case C of
     1: SS.Categories.GetCat(EditCat).ElevDat.MinElev := StrToFloat(V);
     3: SS.Categories.GetCat(EditCat).ElevDat.MaxElev := StrToFloat(V);
     2,4: Begin
           V := Lowercase(V);
           If V[1]='h' then UType := HalfTide
           else if V[1]='s' then Utype := SaltBound
           else UType := Meters;
           If C=2 then SS.Categories.GetCat(EditCat).ElevDat.MinUnit := UType
                  else SS.Categories.GetCat(EditCat).ElevDat.MaxUnit := UType;
          End;
    End; {Case}

  Except

  End;

  UpdateScreen;
end;

procedure TElevAnalysisForm.TSGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
// Paste
    Procedure PasteIntoGrid;
    var
       Grect:TGridRect;
       S,CS,F:String;
       L,R,C:Byte;
    begin
       GRect:=TSGrid.Selection;
       L:=GRect.Left; R:=GRect.Top;
       S:=ClipBoard.AsText;
       R:=R-1 ;
       while Pos(#13,S)>0 do
       begin
           R:=R+1;
           C:=L-1;
           CS:= Copy(S,1,Pos(#13,S));
           while Pos(#9,CS)>0 do
           begin
               C:=C+1;
               if (C<=TSGrid.ColCount-1)and (R<=TSGrid.RowCount-1) then
                   ValStr  :=Copy(CS,1,Pos(#9,CS)-1);
                   EditRow := R;
                   EditCol := C;
                   TSGridExit(nil);
                   F:= Copy(CS,1,Pos(#9,CS)-1);
               Delete(CS,1,Pos(#9,CS));
           end;
           if (C<=TSGrid.ColCount-1)and (R<=TSGrid.RowCount-1) then
              Begin
                ValStr  := Copy(CS,1,Pos(#13,CS)-1);
                EditRow := R;
                EditCol := C+1;
                TSGridExit(nil);
              End;
//         TSGrid.Cells[C+1,R]:=Copy(CS,1,Pos(#13,CS)-1);

           Delete(S,1,Pos(#13,S));
           if Copy(S,1,1)=#10 then
           Delete(S,1,1);
       end;
    end;

begin

    If ((ssCtrl in Shift) AND (Key = ord('V')))  then
      Begin
        PasteIntoGrid;
        Key := 0;
      End;

end;

procedure TElevAnalysisForm.TSGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  TSGrid.MouseToCell(x,y,Ccol,Crow);
end;

procedure TElevAnalysisForm.TSGridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
//  If ARow + 1 = TSGrid.RowCount then CanSelect := False;
  TSGridExit(nil);
end;

procedure TElevAnalysisForm.TSGridSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
  ValStr  := Value;
  EditRow := ARow;
  EditCol := ACol;

end;

procedure TElevAnalysisForm.ElevAnalysisClick(Sender: TObject);
begin
  Enabled := False;  //not allow double clicks or other shenanigans
  Try
    if MapLoaded then
      begin
        SS.Calc_Elev_Stats(TButton(Sender).Name = 'ElevAnalysis');  // OneArea is true unless ElevAll pressed
      end;
  Finally
    Enabled := True;
    UpdateScreen;
  End;
end;


Procedure TElevAnalysisForm.Button4Click(Sender: TObject);
begin
  If MessageDlg('Cancel all Changes?',mtconfirmation,[mbyes,mbno],0) = MRyes then
    ModalResult := MRCancel;
end;

Procedure TElevAnalysisForm.ComboBox1Change(Sender: TObject);
begin
  UpdateScreen;
end;


procedure TElevAnalysisForm.CostEditExit(Sender: TObject);
begin
  UpdateTSGrid;
end;

procedure TElevAnalysisForm.ElevationAnalysis(var PSS: TSLAMM_Simulation);
Var TS: TStream;
    i: Integer;
begin
  TSText := False;

  SaveStream := TMemoryStream.Create;
  GlobalTS := SaveStream;

  TS := TStream(SaveStream);

  PSS.Site.Store(TS);  {save for backup in case of cancel click}
  For i := 0 to PSS.Categories.NCats-1 do
    TS.Write(PSS.Categories.GetCat(i).ElevDat,Sizeof(ClassElev));

  SS := PSS;

  UpdateElevAreasList;     //Update the elevation areas list
  UpdateScreen;

  SaveStream.Seek(0, soFromBeginning); {Go to beginning of stream}
  If ShowModal = MRCancel then
    Begin
      PSS.Site.Load(VersionNum,TStream(SaveStream));
      For i := 0 to PSS.Categories.NCats-1 do
        TStream(SaveStream).Read(PSS.Categories.GetCat(i).ElevDat,Sizeof(ClassElev));
    End;
  SaveStream.Free;
end;



procedure TElevAnalysisForm.ElevUnixBoxChange(Sender: TObject);
begin
  UpdateTSGrid;
end;

procedure TElevAnalysisForm.ElevZeroBoxChange(Sender: TObject);
begin
 UpdateTSGrid;
end;

procedure TElevAnalysisForm.ElevAreasBoxChange(Sender: TObject);
begin
  UpdateTSGrid;
end;

function SaveAsExcelFile(AGrid: TStringGrid; ASheetName, AFileName: string): Boolean;

      function RefToCell(ARow, ACol: Integer): string;
      Var FirstACol: Integer;
      begin
        FirstACol := (ACol-1) div 26;
        ACol := ACol - (FirstACol * 26);
        If (FirstACol = 0) then Result := Chr(Ord('A') + ACol - 1) + IntToStr(ARow)
                           else Result := Chr(Ord('A') + FirstACol - 1) + Chr(Ord('A') + ACol - 1) + IntToStr(ARow);
      end;

const
  xlWBATWorksheet = -4167;
var
  XLApp, Sheet, Data: OLEVariant;
  i, j: Integer;
begin
  For i:= 25 to 27 do
    RefToCell(1,i);

  // Prepare Data
  Data := VarArrayCreate([1, AGrid.RowCount, 1, AGrid.ColCount], varVariant);
  for i := 0 to AGrid.ColCount - 1 do
    for j := 0 to AGrid.RowCount - 1 do
      Data[j + 1, i + 1] := AGrid.Cells[i, j];
  // Create Excel-OLE Object
  Result := False;
  XLApp := CreateOleObject('Excel.Application');
  try
    // Hide Excel
    XLApp.Visible := False;
    // Add new Workbook
    XLApp.Workbooks.Add(xlWBatWorkSheet);
    Sheet := XLApp.Workbooks[1].WorkSheets[1];
    Sheet.Name := ASheetName;
    // Fill up the sheet
    Sheet.Range[RefToCell(1, 1), RefToCell(AGrid.RowCount,
      AGrid.ColCount)].Value := Data;
    // Save Excel Worksheet
    try
      XLApp.Workbooks[1].SaveAs(AFileName);
      Result := True;
    except
      // Error ?
    end;
  finally
    // Quit Excel
    if (not VarIsEmpty(XLApp)) {and (not PROCESSING_BATCH)} then
    begin
      If MessageDlg('Data Saved to '+AFileName+'.  View now?',mtconfirmation,[mbyes,mbno],0)
        = mrYes then
        Begin
          XLApp.Visible := True;
        End
      else
        Begin
          XLApp.DisplayAlerts := False;
          XLApp.Quit;
          XLAPP := Unassigned;
          Sheet := Unassigned;
        End;
    end;
  end;
end;

procedure TElevAnalysisForm.ExcelExportClick(Sender: TObject);

Var SaveName: String;
Begin
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

 SaveAsExcelFile(TSGrid, 'Elev Analysis', SaveName);
end;

procedure TElevAnalysisForm.FormCreate(Sender: TObject);
begin
  EditRow := -1; EditCol := -1; ValStr := '~';
  CCol := -1; CRow := -1; SortCol := -1; SortUp := True;
end;


procedure TElevAnalysisForm.HelpButtonClick(Sender: TObject);
begin
   Application.HelpContext(1010 );  //'ElevAnalysis.html');
end;


procedure TElevAnalysisForm.HistFormButtonClick(Sender: TObject);
//===============================================================
// Open the Histogram graphs
//===============================================================
var
    nSeries: integer;
    i : integer;
    Cat: Integer;
    S: string;
begin
  // Assign data to the graph form
  ElevHist.SS := SS;

  // Assign captions/uncheck/visibility to the checkboxes
 for Cat := 0 to SS.Categories.NCats-1 do
    begin
      cbWetland[Cat].chkbox := TCheckBox(ElevHist.FindComponent('CheckBox' + IntToStr(Cat+1)));
      cbWetland[Cat].chkbox.checked := False;
      cbWetland[Cat].chkbox.Caption := SS.Categories.GetCat(Cat).TextName;
      cbWetland[Cat].chkbox.Enabled := True;
      if SS.Categories.GetCat(Cat).ElevationStats[0].N = 0 then
       cbWetland[Cat].chkbox.Enabled := False;
    end;
  For Cat := SS.Categories.NCats to 27 do
    Begin
      cbWetland[Cat].chkbox := TCheckBox(ElevHist.FindComponent('CheckBox' + IntToStr(Cat+1)));
      cbWetland[Cat].chkbox.Visible := False;
    End;

  // Clear existing series
  nSeries := ElevHist.Chart1.SeriesCount;
  for i := 0 to nSeries - 1 do
    ElevHist.Chart1.Series[i].Clear;

  //Clear, populate and initialize the area box
  ElevHist.AreaBox.Items.Clear;
  for i := 0 to length(SS.Categories.GetCat(0).ElevationStats)-1 do
    begin
     S := ElevAreasBox.Items.Strings[i];
     if i=0 then
       ElevHist.AreaBox.Items.Text := S
     else
        ElevHist.AreaBox.Items.Add(S);
    end;
  ElevHist.AreaBox.ItemIndex := ElevAreasBox.ItemIndex;

  // Show the graph form
  ElevHist.PlotElevHist;
  ElevHist.showmodal;

end;

procedure TElevAnalysisForm.MetersBoxClick(Sender: TObject);
begin
  UpdateTSGrid;
end;


procedure TElevAnalysisForm.SortTSGrid;
var
   Exchange: Boolean;
   i,j : integer;
   temp:tstringlist;
   tempcat: Integer;
begin
  temp:=tstringlist.create;
  with TSGrid do
   for i := 1 to RowCount - 2 do  {because last row has no next row}
    for j:= i+1 to rowcount-1 do {from next row to end}
     Begin
       If (Trim(Cells[SortCol,i]) = '') or   //1/12/2011 prevent crash
          (Trim(Cells[SortCol,j]) = '')
         then Exchange := False
         else
           Begin
             If  SortCol in [0,2,7,4]
               then Exchange :=
                     ((AnsiCompareText(Cells[SortCol, i], Cells[SortCol,j]) > 0) and SortUp) or
                     ((AnsiCompareText(Cells[SortCol, i], Cells[SortCol,j]) < 0) and (Not SortUp))
               else Exchange := (SortUp and (StrToFloat(Cells[SortCol, i]) > StrToFloat(Cells[SortCol, j]))) or
                                (not SortUp and (StrToFloat(Cells[SortCol, i]) < StrToFloat(Cells[SortCol, j])));
            End;
       If Exchange then
         begin
           temp.assign(rows[j]);    tempcat := WhichRow[j];
           rows[j].assign(rows[i]); WhichRow[j] := WhichRow[i];
           rows[i].assign(temp);    WhichRow[i] := tempcat;
         end;
     End;

   temp.free;
end;

Procedure TElevAnalysisForm.UpdateScreen;
Begin

  RunElevWarning.Visible := Not MapLoaded;
  ElevAnalysis.Enabled := MapLoaded;
  ElevAll.Enabled := MapLoaded;

  // Update the table
  UpdateTSGrid;
End;


procedure TElevAnalysisForm.UpdateTSGrid;
Var nRows, i: Integer;

    Function UnitStr(InUnit: ElevUnit): String;
    Begin
      Case InUnit of
        HalfTide: Result := 'HTU';
        SaltBound: Result := 'Salt Elev.';
        else Result := 'Meters';
      End; {case}
    End;

Var catloop: Integer;
    rowindex: integer;
    MaxHTU, MinHTU, HT: Double;
    Ustr    : String;

    CNumUnit, CNumZero, CNum, CNumArea: integer;
begin
  SS.Site.InitElevVars;  {ensure half tide range is properly accounted for by setting MHHW}

  With TSGrid do
    Begin
      NRows := 22+4;
      RowCount := NRows+1;  {plus header}

      ColCount := 16;  //added fraction of cells above minimum elevation column
      //ColCount := 17;  //added error in percentile estimate (half the bin size)
      ColWidths[0]:=205;
      ColWidths[7]:=10;

      ColWidths[15] := 85;

      For i := 0 to RowCount-1 do
        Rows[i].Clear;

      //Area to show
      CNumArea := ElevAreasBox.ItemIndex;

      // Elevation units
      CNumUnit := ElevUnitsBox.ItemIndex;

      // Elevation zero
      CNumZero := ElevZeroBox.ItemIndex + 1;

      //Statistical object selected
      CNum := CNumUnit*4+CNumZero;

      // Change the caption depending on the units
      if CNumUnit = 1 then
        UStr := '(m)'
      else
        UStr := '(HTU)';

      //If MetersBox.Checked then UStr := '(m)' else UStr := '(HTU)';

      Rows[0].Add('SLAMM Category');
      Rows[0].Add('Min Elev.');
      Rows[0].Add('Min Unit');
      Rows[0].Add('Max Elev.');
      Rows[0].Add('Max Unit');
      Rows[0].Add('Min '+Ustr);
      Rows[0].Add('Max '+Ustr);
      Rows[0].Add(' ');

      Rows[0].Add('n cells');
      Rows[0].Add('5th Pct.'+UStr);
      Rows[0].Add('95th Pct.'+UStr);
      Rows[0].Add('mean '+UStr);
      Rows[0].Add('st.dev. '+UStr);
      Rows[0].Add('min '+UStr);
      Rows[0].Add('max '+UStr);
      Rows[0].Add('%<Min Elev'); // Add fraction of cells below min wetland elevation
      //Rows[0].Add('Pct. Err. (1/2 bin size)'+UStr);

      RowIndex :=0;
      for CatLoop := 0 to SS.Categories.NCats-1 do
       With SS.Categories.GetCat(CatLoop).ElevDat do
        If SS.Categories.GetCat(CatLoop).InundateTo <> Blank then
          Begin
          Inc(RowIndex);
          WhichRow[RowIndex] := CatLoop;
          Rows[RowIndex].Add(SS.Categories.GetCat(CatLoop).TextName);
          Rows[RowIndex].Add(FloatToStrf(MinElev,FFGeneral,6,4));
          Rows[RowIndex].Add(UnitStr(MinUnit));
          Rows[RowIndex].Add(FloatToStrf(MaxElev,FFGeneral,6,4));
          Rows[RowIndex].Add(UnitStr(MaxUnit));

          // Get global site wetland max and min elevations
          HT := SS.Site.GlobalSite.GTideRange/2;
          HTULabel.Caption := '"HTU" = Half Tide Units approx '+FloatToStrf(HT,FFGeneral,6,4) +' meters (based on "Global" Site Record)';

          MinHTU := SS.LowerBound(CatLoop,SS.Site.GlobalSite);
          MaxHTU := SS.UpperBound(CatLoop,SS.Site.GlobalSite);

          if HT<1e-6 then
            Begin
              MinHTU := 0;
              MaxHTU := 0;
            End
          else
            Begin
              // Adjust min and max wetland elevations to the selected unit and zero
              if CNum = 1 then   {HTU, MTL}
                Begin
                  MinHTU := MinHTU/HT;
                  MaxHTU := MaxHTU/HT;
                End;

              if CNum = 2 then  {HTU, MHHW}
                begin
                  MinHTU := MinHTU/HT - 1;
                  MaxHTU := MaxHTU/HT - 1;
                end;

              if CNum = 3 then  {HTU, MLLW}
                begin
                  MinHTU := MinHTU/HT + 1;
                  MaxHTU := MaxHTU/HT + 1;
                end;

              if CNum = 4 then  {HTU, NAVD88}
                begin
                  MinHTU := (MinHTU + SS.Site.GlobalSite.NAVD88MTL_correction)/HT;
                  MaxHTU := (MaxHTU + SS.Site.GlobalSite.NAVD88MTL_correction)/HT;
                end;

              if CNum = 6 then {m, MHHW}
                begin
                  MinHTU := MinHTU - HT;
                  MaxHTU := MaxHTU - HT;
                end;

              if CNum = 7 then {m, MLLW}
                begin
                  MinHTU := MinHTU + HT;
                  MaxHTU := MaxHTU + HT;
                end;

              if CNum = 8 then {m, NAVD88}
                begin
                  MinHTU := MinHTU + SS.Site.GlobalSite.NAVD88MTL_correction;
                  MaxHTU := MaxHTU + SS.Site.GlobalSite.NAVD88MTL_correction;
                end;
          End;

          Rows[RowIndex].Add(FloatToStrf(MinHTU,FFGeneral,6,4));
          Rows[RowIndex].Add(FloatToStrf(MaxHTU,FFGeneral,6,4));

          Rows[RowIndex].Add(''); //notes in future editions?

          If (not SS.Init_ElevStats) then
            begin
              ElevAnalysisLabel.Caption := 'Elevation Analysis has not been run';
              HistFormButton.Enabled := False;
            end
          else with SS.Categories.GetCat(CatLoop).ElevationStats[CNumArea] do
            Begin
              ElevAnalysisLabel.Caption := '';
{              If Derived < 1000
                then ElevAnalysisLabel.Caption := 'Elev. Analysis Not Run for this portion of the site'
                else ElevAnalysisLabel.Caption := 'Last Elevation Analysis '+DateTimeToStr(Derived);    }

              HistFormButton.Enabled := True;

              Rows[RowIndex].Add(IntToStr(N));

              //If MetersBox.Checked then indx := 2 else indx := 1;

              Rows[RowIndex].Add(FloatToStrf(Stats[CNum].p05,FFGeneral,6,4));
              Rows[RowIndex].Add(FloatToStrf(Stats[CNum].p95,FFGeneral,6,4));
              Rows[RowIndex].Add(FloatToStrf(Stats[CNum].Mean,FFGeneral,6,4));
              Rows[RowIndex].Add(FloatToStrf(Stats[CNum].StDev,FFGeneral,6,4));
              Rows[RowIndex].Add(FloatToStrf(Stats[CNum].Min,FFGeneral,6,4));
              Rows[RowIndex].Add(FloatToStrf(Stats[CNum].Max,FFGeneral,6,4));
              Rows[RowIndex].Add(FloatToStrf(pLowerMin,FFGeneral,6,4));    //Add the new fraction<MinElev value
              //Rows[RowIndex].Add(FloatToStrf((Stats[CNum].Max[CatLoop]-Stats[CNum].Min[CatLoop])/HistWidth/2,FFGeneral,6,4));
            End
        End;
    End; {With TSGrid}

    If SortCol > -1 then SortTSGrid;
end;

procedure TElevAnalysisForm.UpdateElevAreasList;
var
  i: integer;
  S: string;
begin
  ElevAreasBox.Items.Clear;

  ElevAreasBox.Items.Text := 'Entire Study Area';

  ElevAreasBox.Items.Add('Global Input Subsite');

  for i := 1 to SS.Site.NSubSites do
    begin
      S := SS.Site.SubSites[i-1].Description;
      ElevAreasBox.Items.Add(S);
    end;

  If (SS.Site.MaxROS=0) and (SS.NElevStats > 2+ SS.Site.NSubSites+SS.Site.NOutputSites)  //MaxROS is not loaded and saved
    then SS.Site.MaxROS :=SS.NElevStats-2-SS.Site.NOutputSites- SS.Site.NSubSites;

  for i := 1 to SS.Site.MaxROS do
    begin
      S := 'Output raster '+inttostr(i);
      ElevAreasBox.Items.Add(S);
    end;

  for i := 1 to SS.Site.NOutputSites do
    begin
      S := trim(SS.Site.OutputSites[i-1].Description);
      if S='' then
        SS.Site.OutputSites[i-1].Description := 'Output Site '+inttostr(i);
      S := SS.Site.OutputSites[i-1].Description;
      ElevAreasBox.Items.Add(S);
    end;

  ElevAreasBox.ItemIndex := 0;

end;

end.
