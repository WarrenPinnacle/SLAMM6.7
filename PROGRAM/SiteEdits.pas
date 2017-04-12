//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit SiteEdits;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Main, StdCtrls, Grids, Menus, ExtCtrls, Clipbrd, Global, SLR6,
  Buttons;

// to add a parameter  1. Increment NumRowsOrig
//                     2. Add to TSGridExit and change numbering
//                     3. Add Labeling and Data output to UpdateTSGrid;
//                     4. Update numbering in UpdateTSGrid

Const NUMRowsOrig     = 29;  // original parameters
      NUMRowsLag      = 6;   // lagoonal and wave erosion parameters
      NUMRowsAccr     = 8;   // accretion model rows

type
  TSiteEditForm = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    ModLabel: TLabel;
    TSGrid: TStringGrid;
    Label1: TLabel;
    ShowWindEdits: TCheckBox;
    ShowAccr: TCheckBox;
    ExcelExport: TButton;
    SaveDialog1: TSaveDialog;
    HelpButton: TBitBtn;
    SaveButton: TButton;
    AccrGraphButton: TButton;
    WindRoseButton: TButton;
    procedure ComboBox1Change(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
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
    procedure ShowWindEditsClick(Sender: TObject);
    procedure ExcelExportClick(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure AccrGraphButtonClick(Sender: TObject);
    procedure WindRoseButtonClick(Sender: TObject);
  private
    PSim: Pointer;
    { Private declarations }
  public
    TS: TSite;
    ValStr  : String;  { [60]; }
    EditRow, EditCol : Integer;
    SaveStream: TMemoryStream;
    Procedure EditSubSites(Var PSS: TSLAMM_Simulation);
    Procedure UpdateTSGrid;
    Procedure UpdateScreen();
    { Public declarations }
  end;

var
  SiteEditForm: TSiteEditForm;

implementation

Uses Elev_Analysis, System.UITypes, AccrGraph, WindRose;

{$R *.dfm}

procedure TSiteEditForm.TSGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  If (ARow=0) or (ACol=0) then
      with TSGrid.Canvas do
        begin
          Font.Style := [fsbold];
    //      TextRect(Rect, Rect.Left + 2, Rect.Top + 2, TSGrid.Cells[ACol, ARow]);    Doesn't work in XE3, trying to make font bold
        end;

end;

procedure TSiteEditForm.TSGridExit(Sender: TObject);

Var AM, R, C: Integer;
    V: String;
    TSS: TSubSite;

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

    Function TranslateBool: Boolean;
    Begin
      v := Lowercase(v);
      If (v[1]='f') or (v[1] = '0')
        then Result := False
        else Result := True;
    End;

begin
 CancelBtn.Enabled := True;

 IF EditRow < 1 then exit;
 If EditCol < 1 then exit;

  If (Trim(ValStr) = '~') then exit;
  R := EditRow; C := EditCol; V := ValStr;
  EditRow := -1; EditCol := -1; ValStr := '~';

  If C=1 then TSS := TS.GlobalSite
         else TSS := TS.SubSites[C-2];

  If v='' then exit;
  With TSS do
    Try
      Case R of
        1: Description := V;
        2: NWI_Photo_Date := Trunc(StrToFloat(V));
        3: DEM_Date := Trunc(StrToFloat(V));
        4: Begin
             V := Lowercase(V);
             If v='' then exit;
             If V[1] = 's' then Direction_OffShore := Southerly
                else if Pos('n',V) > 0 then Direction_OffShore := Northerly
                else if Pos('w',V) > 0 then Direction_OffShore := Westerly
                else Direction_OffShore := Easterly;
           End;
        5: Historic_Trend := StrToFloat(V);
        6: Historic_Eustatic_Trend := StrToFloat(V);
        7: NAVD88MTL_Correction := StrToFloat(V);
        8: GTideRange := StrToFloat(V);
        9: SaltElev := StrToFloat(V);
        10: MarshErosion := StrToFloat(V);
        11: SwampErosion := StrToFloat(V);
        12: TFlatErosion := StrToFloat(V);
        13: FixedRegFloodAccr  := StrToFloat(V);         // Note edits here also need to be made in UncertDefn
        14: FixedIrregFloodAccr  := StrToFloat(V);
        15: FixedTideFreshAccr  := StrToFloat(V);

        16: InlandFreshAccr := StrToFloat(V);
        17: MangroveAccr := StrToFloat(V);
        18: TSwampAccr := StrToFloat(V);
        19: SwampAccr := StrToFloat(V);
        20: Fixed_TF_Beach_Sed := StrToFloat(V);
        21: IFM2RFM_Collapse := StrToFloat(V);  // 1/11/2016
        22: RFM2TF_Collapse := StrToFloat(V);

        23: Use_Wave_Erosion := TranslateBool;
        24: Use_Preprocessor := TranslateBool;

        25: InundElev[0] := StrToFloat(V);  // 30D Inundation  //12/5/2013 Marco
        26: InundElev[1] := StrToFloat(V);  // 60D Inundation
        27: InundElev[2] := StrToFloat(V);  // 90D Inundation
        28: InundElev[3] := StrToFloat(V);  // Storm Surge Test 1
        29: InundElev[4] := StrToFloat(V);  // Storm Surge Test 2
      End; {Case}

    If ShowWindEdits.Checked
     then Case R of
      30: WE_Alpha := StrToFloat(V);
      31: WE_Has_Bathymetry := TranslateBool;
      32: WE_Avg_Shallow_Depth := StrToFloat(V);
      33: Begin
            V := Lowercase(V);
            If v='' then exit;
            Case V[1] of
              'n': LagoonType := LtNone;
              't': LagoonType := LtOpenTidal;
              'o': LagoonType := LtPredOpen;
              'c': LagoonType := LtPredClosed;
              'd': LagoonType := LtDrainage;
            end; {case}
          End;
      34: ZBeachCrest := StrToFloat(V);
      35: LBeta := StrToFloat(V);
     End; {Case}

    If (R>NUMRowsOrig+NumRowsLag) or ((R>NUMRowsOrig) and Not ShowWindEdits.Checked) then
      Begin {editing accretion model parameters}
        R := R-NUMRowsOrig;
        If ShowWindEdits.Checked then R := R-NumRowsLag;  {normalize to row 1-44}
        AM := (R-1) Div NUMRowsAccr;  {Accretion model edited, 0 to 3}
        R := R-(NUMRowsAccr*AM); {normalize to row 1-NUMRowsAccr}
        AccRescaled[AM] := False;
        Case R of
          1: UseAccrModel[AM] := TranslateBool;
          2: MaxAccr[AM] := (StrToFloat(V));
          3: MinAccr[AM] := (StrToFloat(V));
          4: AccrA[AM] := (StrToFloat(V));
          5: AccrB[AM] := (StrToFloat(V));
          6: AccrC[AM] := (StrToFloat(V));
          7: AccrD[AM] := (StrToFloat(V));
          8: AccrNotes[AM] := (V);
        End; {Case}
     End; {if}

    Except
    End;

  UpdateScreen;
end;

procedure TSiteEditForm.TSGridKeyDown(Sender: TObject; var Key: Word;
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

procedure TSiteEditForm.TSGridSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
//  If ARow + 1 = TSGrid.RowCount then CanSelect := False;
  TSGridExit(nil);
end;

procedure TSiteEditForm.TSGridSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
  ValStr  := Value;
  EditRow := ARow;
  EditCol := ACol;

end;

procedure TSiteEditForm.AccrGraphButtonClick(Sender: TObject);
begin
  AccrGraphForm.ShowAccrGraphs(PSim);
end;

Procedure TSiteEditForm.CancelBtnClick(Sender: TObject);
begin
  If MessageDlg('Cancel all Changes?',mtconfirmation,[mbyes,mbno],0) = MRyes then
    ModalResult := MRCancel;
end;

Procedure TSiteEditForm.ComboBox1Change(Sender: TObject);
begin
  UpdateScreen;
end;


procedure TSiteEditForm.CostEditExit(Sender: TObject);
begin
  UpdateTSGrid;
end;

procedure TSiteEditForm.EditSubSites(var PSS: TSLAMM_Simulation);

begin
  PSS.Site.InitElevVars;
  TSText := False;
  SaveStream := TMemoryStream.Create;
  GlobalTS := SaveStream;
  PSS.Site.Store(TStream(SaveStream));  {save for backup in case of cancel click}
  TS := PSS.Site;
  PSim := PSS;

  UpdateTSGrid;

  SaveStream.Seek(0, soFromBeginning); {Go to beginning of stream}

{  If PROCESSING_BATCH then
    Begin
      ShowAccr.Checked := True;
      SaveAsExcelFile(TSGrid, 'Elev Analysis', ChangeFileExt(PSS.FileN,'.SUBSITE_PARAMETERS.XLSX'));
      SaveStream.Free;
      Exit;
    End; }

  If ShowModal = MRCancel
     then PSS.Site.Load(VersionNum,TStream(SaveStream))
     else if CancelBtn.Enabled then PSS.Changed := True;
  SaveStream.Free;

end;

procedure TSiteEditForm.ExcelExportClick(Sender: TObject);
Var SaveName: String;
Begin
      // Create save dialog and set it options
      with SaveDialog1 do
      begin
         DefaultExt := 'xlsx' ;
         Filter := 'Excel files (*.xlsx)|*.xlsx|All files (*.*)|*.*' ;
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

procedure TSiteEditForm.FormCreate(Sender: TObject);
begin
  EditRow := -1; EditCol := -1; ValStr := '~';
end;



procedure TSiteEditForm.HelpButtonClick(Sender: TObject);
begin
   Application.HelpContext(1009 );  //'EditSites.html');
end;

procedure TSiteEditForm.SaveButtonClick(Sender: TObject);
begin
MainForm.SaveSimClick(Sender);
CancelBtn.Enabled := False;
end;

procedure TSiteEditForm.ShowWindEditsClick(Sender: TObject);
begin
  UpdateTSGrid;
end;

Procedure TSiteEditForm.UpdateScreen;
Begin
  UpdateTSGrid;
End;


procedure TSiteEditForm.UpdateTSGrid;
Var nRows, i,j: Integer;

    Function BoolString(inbool: Boolean): String;
    Begin
      If inbool then result := 'True'
                else result := 'False';
    End;

    Procedure AddColumn(SubS: TSubSite);
    Var i, NextRow: Integer;
    Begin
     With SubS do with TSGrid do
      Begin
        Rows[1].Add(Description);
        Rows[2].Add(IntToStr(NWI_Photo_Date));
        Rows[3].Add(IntToStr(DEM_Date));
        Case SubS.Direction_OffShore of
           Southerly: Rows[4].Add('South');
           Northerly: Rows[4].Add('North');
           Easterly: Rows[4].Add('East');
           Westerly: Rows[4].Add('West');
           end{Case};
        Rows[5].Add(FloatToStrf(Historic_Trend,ffgeneral,8,4));
        Rows[6].Add(FloatToStrf(Historic_Eustatic_Trend,ffgeneral,8,4));
        Rows[7].Add(FloatToStrf(NAVD88MTL_Correction,ffgeneral,8,4));
        Rows[8].Add((FloatToStrf(GTideRange,ffgeneral,8,4)));
        Rows[9].Add((FloatToStrf(SaltElev,ffgeneral,8,4)));
        Rows[10].Add((FloatToStrf(MarshErosion,ffgeneral,8,4)));
        Rows[11].Add((FloatToStrf(SwampErosion,ffgeneral,8,4)));
        Rows[12].Add((FloatToStrf(TFlatErosion,ffgeneral,8,4)));
        Rows[13].Add((FloatToStrf(FixedRegFloodAccr ,ffgeneral,8,4)));
        Rows[14].Add((FloatToStrf(FixedIrregFloodAccr ,ffgeneral,8,4)));
        Rows[15].Add((FloatToStrf(FixedTideFreshAccr ,ffgeneral,8,4)));

        Rows[16].Add((FloatToStrf(InlandFreshAccr ,ffgeneral,8,4)));
        Rows[17].Add((FloatToStrf(MangroveAccr ,ffgeneral,8,4)));
        Rows[18].Add((FloatToStrf(TSwampAccr ,ffgeneral,8,4)));
        Rows[19].Add((FloatToStrf(SwampAccr ,ffgeneral,8,4)));
        Rows[20].Add((FloatToStrf(Fixed_TF_Beach_Sed,ffgeneral,8,4)));

        Rows[21].Add((FloatToStrf(IFM2RFM_Collapse,ffgeneral,8,4)));  // 1/11/2016
        Rows[22].Add(FloatToStrf(RFM2TF_Collapse,ffgeneral,8,4));

        Rows[23].Add(BoolString(Use_Wave_Erosion));

        Rows[24].Add(BoolString(Use_Preprocessor));

        Rows[25].Add(FloatToStrf(InundElev[0],ffgeneral,8,4));
        Rows[26].Add(FloatToStrf(InundElev[1],ffgeneral,8,4));
        Rows[27].Add(FloatToStrf(InundElev[2],ffgeneral,8,4));
        Rows[28].Add(FloatToStrf(InundElev[3],ffgeneral,8,4));
        Rows[29].Add(FloatToStrf(InundElev[4],ffgeneral,8,4));

        NextRow := NUMRowsOrig + 1;

        If ShowWindEdits.Checked then
          Begin
            Rows[NextRow].Add((FloatToStrf(WE_Alpha,ffgeneral,8,4)));
            Rows[NextRow+1].Add(BoolString(WE_Has_Bathymetry));
            Rows[NextRow+2].Add((FloatToStrf(WE_Avg_Shallow_Depth,ffgeneral,8,4)));
            Case LagoonType of
                LtNone: Rows[NextRow+3].Add('None');
                LtOpenTidal: Rows[NextRow+3].Add(' Open Tidal');
                LtPredOpen: Rows[NextRow+3].Add('Pred. Open');
                LtPredClosed: Rows[NextRow+3].Add('Pred. Closed');
                LtDrainage: Rows[NextRow+3].Add('Drainage Creek');
              end; {case}
            Rows[NextRow+4].Add(FloatToStrf(ZBeachCrest,ffgeneral,8,4));
            Rows[NextRow+5].Add(FloatToStrf(LBeta ,ffgeneral,8,4));
            NextRow := NextRow+NumRowsLag;
          End;

        If ShowAccr.Checked then
         For i := 0 to N_Accr_Models-1 do
          Begin
            If UseAccrModel[i] then Rows[NextRow].Add('True')
                               else Rows[NextRow].Add('False');
            Inc(NextRow);
            Rows[NextRow].Add((FloatToStrf(MaxAccr[i],ffgeneral,8,4)));
            Inc(NextRow);
            Rows[NextRow].Add((FloatToStrf(MinAccr[i],ffgeneral,8,4)));
            Inc(NextRow);
            Rows[NextRow].Add((FloatToStrf(AccrA[i],ffgeneral,8,4)));
            Inc(NextRow);
            Rows[NextRow].Add((FloatToStrf(AccrB[i],ffgeneral,8,4)));
            Inc(NextRow);
            Rows[NextRow].Add((FloatToStrf(AccrC[i],ffgeneral,8,4)));
            Inc(NextRow);
            Rows[NextRow].Add((FloatToStrf(AccrD[i],ffgeneral,8,4)));
            Inc(NextRow);

            Rows[NextRow].Add(AccrNotes[i]);
            Inc(NextRow);
          End;
      End; {with SubS}
    End;

Var NextRow: INteger;
begin
  With TSGrid do
    Begin
      If ShowWindEdits.Checked then NRows := NUMRowsOrig+NumRowsLag
                              else NRows := NUMRowsOrig;
      If ShowAccr.Checked then NRows := NRows + NUMRowsAccr * N_ACCR_MODELS;
      RowCount := NRows+1;  {plus header}
      ColCount := TS.NSubSites + 2;  {plus header and global site}

      ColWidths[0]:=205;
//      ColWidths[ColCount-1]:=130;

      For i := 0 to RowCount-1 do
        Rows[i].Clear;

      Rows[0].Add('Parameter');
      Rows[0].Add('Global');

      For i := 1 to TS.NSubSites do
        Rows[0].Add('SubSite '+IntToSTr(i));

      Rows[1].Add('Description');
      Rows[2].Add('NWI Photo Date (YYYY)');
      Rows[3].Add('DEM Date (YYYY)');
      Rows[4].Add('Direction Offshore [n,s,e,w]');
      Rows[5].Add('Historic Trend (mm/yr)');
      Rows[6].Add('Historic Eustatic Trend (mm/yr)');
      Rows[7].Add('MTL-NAVD88 (m)');
      Rows[8].Add('GT Great Diurnal Tide Range (m)');
      Rows[9].Add('Salt Elev. (m above MTL)');
      Rows[10].Add('Marsh Erosion (horz. m /yr)');
      Rows[11].Add('Swamp Erosion (horz. m /yr)');
      Rows[12].Add('T.Flat Erosion (horz. m /yr)');
      Rows[13].Add('Reg.-Flood Marsh Accr (mm/yr)');
      Rows[14].Add('Irreg.-Flood Marsh Accr (mm/yr)');
      Rows[15].Add('Tidal-Fresh Marsh Accr (mm/yr)');

      Rows[16].Add('Inland-Fresh Marsh Accr (mm/yr)');
      Rows[17].Add('Mangrove Accr (mm/yr)');
      Rows[18].Add('Tidal Swamp Accr (mm/yr)');
      Rows[19].Add('Swamp Accretion (mm/yr)');
      Rows[20].Add('Beach Sed. Rate (mm/yr)');

      Rows[21].Add('Irreg-Flood Collapse (m)');
      Rows[22].Add('Reg-Flood Collapse (m)');

      Rows[23].Add('Use Wave Erosion Model [True,False]');
      Rows[24].Add('Use Elev Pre-processor [True,False]');

      Rows[25].Add('H1 inundation (m above MTL)');
      Rows[26].Add('H2 inundation (m above MTL; H2>H1)');
      Rows[27].Add('H3 inundation (m above MTL: H3>H2)');
      Rows[28].Add('H4 inundation (m above MTL; H4>H3)');
      Rows[29].Add('H5 inundation (m above MTL; H5>H4)');

      NextRow := NUMRowsOrig + 1;

      If ShowWindEdits.Checked then
        Begin
          Rows[NextRow].Add('Wave Erosion Alpha (unitless)');
          Rows[NextRow+1].Add('Site has Bathymetry [True,False]');
          Rows[NextRow+2].Add('Average Shallow Depth (m)');
          Rows[NextRow+3].Add('Lagoon Type ("N","T","O","C","D")');
          Rows[NextRow+4].Add('Elev. Beach Crest (m above MSL)');
          Rows[NextRow+5].Add('Lagoon Beta Parameter (fraction)');
          NextRow := NextRow+NumRowsLag;
        End;

      If ShowAccr.Checked then
       For i := 0 to N_Accr_Models-1 do
        Begin
          Rows[NextRow].Add(AccrNames[i]+' Use Model [True,False]');
          Inc(NextRow);
          Rows[NextRow].Add(AccrNames[i]+' Max. Accr. (mm/year)');
          Inc(NextRow);
          Rows[NextRow].Add(AccrNames[i]+' Min. Accr. (mm/year)');
          Inc(NextRow);
          Rows[NextRow].Add(AccrNames[i]+' Elev a (mm/(year HTU^3))');
          Inc(NextRow);
          Rows[NextRow].Add(AccrNames[i]+' Elev b (mm/(year HTU^2))');
          Inc(NextRow);
          Rows[NextRow].Add(AccrNames[i]+' Elev c (mm/(year*HTU))');
          Inc(NextRow);
          Rows[NextRow].Add(AccrNames[i]+' Elev d (mm/year)');
          Inc(NextRow);
          Rows[NextRow].Add(AccrNames[i]+' Notes');
          Inc(NextRow);
        End;

      For j := 0 to TS.NSubSites do
        Begin
          If j=0 then AddColumn(TS.GlobalSite)
                 else AddColumn(TS.SubSites[j-1]);
        End;

    End; {With TSGrid}
end;

procedure TSiteEditForm.WindRoseButtonClick(Sender: TObject);
begin
  WindForm.EditWindRose(PSim);
end;

end.
