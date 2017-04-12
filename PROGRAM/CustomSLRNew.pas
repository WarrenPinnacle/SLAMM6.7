unit CustomSLRNew;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls, Vcl.Grids,
  Vcl.ExtCtrls, Global;

type
  TCustomSLRForm = class(TForm)
    Label3: TLabel;
    Panel1: TPanel;
    Label9: TLabel;
    SLRLabel: TLabel;
    NameLabel: TLabel;
    SLREdit: TStringGrid;
    NameEdit: TEdit;
    OKBtn: TButton;
    CancelBtn: TButton;
    SLRBox: TComboBox;
    NewButton: TButton;
    DelButt: TButton;
    YearLabel: TLabel;
    BaseYearEdit: TEdit;
    RunNowBox: TCheckBox;
    SaveButton: TButton;
    LoadButton: TButton;
    procedure SLREditExit(Sender: TObject);
    procedure SLREditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SLREditSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure SLREditSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure CancelBtnClick(Sender: TObject);
    procedure SLRBoxChange(Sender: TObject);
    procedure NameEditChange(Sender: TObject);
    procedure BaseYearEditExit(Sender: TObject);
    procedure NewButtonClick(Sender: TObject);
    procedure DelButtClick(Sender: TObject);
    procedure RunNowBoxClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure LoadButtonClick(Sender: TObject);
  private
    IsUpdating : Boolean;
    TSSLRs: PTimeSerSLRs;
    NumTSSLRs, TSSLRshowing: Integer;
  public
    ValStr  : String;  { [60]; }
    EditRow, EditCol : Integer;
    SaveStream: TMemoryStream;
    Procedure EditCustomSLRs(Var InSLRs: TTimeSerSLRs; Var NSs: Integer);
    Procedure UpdateGrids;
    Procedure UpdateScreen();
  end;

var
  CustomSLRForm: TCustomSLRForm;

implementation

Uses Clipbrd, System.UITypes;

{$R *.dfm}

procedure TCustomSLRForm.BaseYearEditExit(Sender: TObject);
Var
Conv: Double;
Result: Integer;

begin
  If IsUpdating then exit;
  Val(Trim(TEdit(Sender).Text),Conv,Result);
  If Result<>0 then MessageDlg('Incorrect Numerical Format Entered',mterror,[mbOK],0)
               else TSSLRs^[TSSLRshowing].BaseYear := Trunc(Conv);
  UpdateScreen;
end;

procedure TCustomSLRForm.CancelBtnClick(Sender: TObject);
begin
  If MessageDlg('Cancel all Changes?',mtconfirmation,[mbyes,mbno],0) = MRyes then
    ModalResult := MRCancel;
end;

procedure TCustomSLRForm.DelButtClick(Sender: TObject);
Var i: Integer;
begin
  If NumTSSLRs=0 then exit;
  If MessageDlg('Delete Scenario '+SLRBox.Text+'?',mtconfirmation,[mbyes,mbno],0) = mrno then exit;

  For i := TSSLRshowing to NumTSSLRs-2 do
    TSSLRs^[i] := TSSLRs^[i+1];

  Dec(NumTSSLRs);
  TSSLRshowing := NumTSSLRs-1;
  UpdateScreen;
end;

procedure TCustomSLRForm.EditCustomSLRs(var InSLRs: TTimeSerSLRs; Var NSs: Integer);

  {----------------------------------------------------------------}
  Procedure QuickSortDates(Var PArr: TSRArray; iLo, iHi: Integer);
  Var
    Lo, Hi : Integer;
    Mid : Double;
    T: TSRecord;
  Begin
    Lo := iLo;
    Hi := iHi;
    Mid := PArr[(Lo + Hi) div 2].Year;
    repeat
      while PArr[Lo].Year < Mid do Inc(Lo);
      while PArr[Hi].Year > Mid do Dec(Hi);
      if Lo <= Hi then
      begin
        T := PArr[Lo];
        PArr[Lo] := PArr[Hi];
        PArr[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then QuickSortDates(PArr, iLo, Hi);
    if Lo < iHi then QuickSortDates(PArr, Lo, iHi);
  End;
  {----------------------------------------------------------------}

Var i: Integer;
begin
  TSSLRs := @InSLRs;
  NumTSSLRs := NSs;
  TSSLRshowing := 0; // StartIndex;

  TSText := False;
  SaveStream := TMemoryStream.Create;
  GlobalTS := SaveStream;
  For i := 0 to NSs-1 do
    TSSLRs^[i].Store(TStream(SaveStream));  {save for backup in case of cancel click}

  UpdateScreen;

  SaveStream.Seek(0, soFromBeginning); {Go to beginning of stream}
  If ShowModal = MRCancel then
    Begin
      For i := 0 to NumTSSLRs-1 do
        If TSSLRs^[i]=nil then
          TSSLRs^[i].Free;

      SetLength(TSSLRs^,NSs);
      For i := 0 to NSs-1 do
        TSSLRs^[i] := TTimeSerSLR.Load(VersionNum,TStream(SaveStream));
    End
    else {sort timeseries}
      Begin
        For i := 0 to NumTSSLRs-1 do
          Begin
            If TSSLRs^[i].NYears>0 then QuickSortDates(TSSLRs^[i].SLRArr,0,TSSLRs^[i].NYears-1);
          End;
        NSs := NumTSSLRs;
      End;
  SaveStream.Free;

end;

procedure TCustomSLRForm.LoadButtonClick(Sender: TObject);
Var FileN: String;
    RVN: Double;
    i: Integer;
    TF: TextFile;
begin
  If Not PromptForFileName(FileN,'SLAMM SLR Scenarios File (*.SLAMMSLR)|*.SLAMMSLR','.SLAMMSLR','Select File to Load SLR Scenarios From','',False)
     then Exit;

  TSText := True;
  GlobalFile := @TF;
  AssignFile(GlobalFile^,FileN);
  Reset(GlobalFile^);
  GlobalLN := 0;

  For i := 0 to NumTSSLRs-1 do
    If TSSLRs^[i]=nil then
      TSSLRs^[i].Free;

  Try
    TSRead('ReadVersionNum',RVN);
    TSRead('NTimeSerSLR',NumTSSLRs);
    SetLength(TSSLRs^,NumTSSLRs);
    For i := 0 to NumTSSLRs-1 do
       TSSLRs^[i] := TTimeSerSLR.Load(VersionNum,TStream(SaveStream));

  Except
    Closefile(GlobalFile^);
  End;

  Closefile(GlobalFile^);
  UpdateScreen;
end;

procedure TCustomSLRForm.NameEditChange(Sender: TObject);
begin
  If IsUpdating then Exit;
  TSSLRs^[TSSLRshowing].Name := NameEdit.Text;
  UpdateScreen;
end;

procedure TCustomSLRForm.NewButtonClick(Sender: TObject);
Var CS: Boolean;
begin
  Inc(NumTSSLRs);

  If NumTSSLRs>Length(TSSLRs^) then SetLength(TSSLRs^,NumTSSLRs+5);
  TSSLRs^[NumTSSLRs-1] := TTimeSerSLR.Create;
  TSSLRshowing := NumTSSLRs-1;
  SLREditSelectCell(nil,0,1,CS);
  UpdateScreen;
end;

procedure TCustomSLRForm.RunNowBoxClick(Sender: TObject);
begin
  If IsUpdating then Exit;
  TSSLRs^[TSSLRshowing].RunNow := RunNowBox.Checked;
  UpdateScreen;
end;

procedure TCustomSLRForm.SaveButtonClick(Sender: TObject);
Var FileN: String;
    i: Integer;
    TF: TextFile;
begin
  If Not PromptForFileName(FileN,'SLAMM SLR Scenarios File (*.SLAMMSLR)|*.SLAMMSLR','.SLAMMSLR','Select File to Save SLR Scenarios To','',True)
     then Exit;

  TSText := True;
  GlobalFile := @TF;

  AssignFile(GlobalFile^,FileN);
  Rewrite(GlobalFile^);
  GlobalLN := 0;

  Try
    TSWrite('ReadVersionNum',VersionNum);
    TSWrite('NTimeSerSLR',NumTSSLRs);

    For i := 0 to NumTSSLRs-1 do
      TSSLRs^[i].Store(TStream(SaveStream));

  Except
    Closefile(GlobalFile^);
  End;

 Closefile(GlobalFile^);
 ShowMessage('SLR Scenarios saved to '+FileN);

end;
procedure TCustomSLRForm.SLRBoxChange(Sender: TObject);
begin
  If IsUpdating then Exit;
  TSSLRshowing := SLRBox.ItemIndex;
  UpdateScreen;
end;

procedure TCustomSLRForm.SLREditExit(Sender: TObject);
Var R, C: Integer;
    V: String;
    PTSR: PTSRArray;
begin
  IF EditRow < 1 then exit;

  If (Trim(ValStr) = '~') then exit;
  R := EditRow; C := EditCol; V := ValStr;
  EditRow := -1; EditCol := -1; ValStr := '~';

  PTSR := @(TSSLRs^[TSSLRshowing].SLRArr);
  If Length(PTSR^) = 0 then SetLength(PTSR^,5);
  If (TSSLRs^[TSSLRshowing].NYears)=0 then Inc(TSSLRs^[TSSLRshowing].NYears);

  If v='' then exit;

    Try
      If C=0 then PTSR^[R-1].Year := TRUNC(StrToFloat(V))
             else PTSR^[R-1].Value := StrToFloat(V);
    Except

    End;

  UpdateScreen;
end;

procedure TCustomSLRForm.SLREditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
// Paste
Var PTSR: PTSRArray;
    PCount : PInteger;

    Procedure PasteIntoGrid;
    var
       Grect:TGridRect;
       S,CS,F:String;
       L,R,C, i:Integer;
       TSGrid: TStringGrid;
    begin
       TSGrid := TStringGrid(Sender);
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

             If R>PCount^ then
              Begin
                Inc(PCount^);
                If (PCount^ > Length(PTSR^)) then
                Begin
                    SetLength(PTSR^,PCount^+5);
                    For i := PCount^ to PCount^+5 do
                      Begin
                        PTSR^[i-1].Year := 0;
                        PTSR^[i-1].Value := 0;
                      End;
                End;
              End;

               C:=C+1;
               if (C<=TSGrid.ColCount-1) {and (R<=TSGrid.RowCount-1)} then
                 Begin
                   ValStr  :=Copy(CS,1,Pos(#9,CS)-1);
                   EditRow := R;
                   EditCol := C;
                   SLREditExit(sender);
                   F:= Copy(CS,1,Pos(#9,CS)-1);
                 End;
               Delete(CS,1,Pos(#9,CS));
           end;

           if (C<=TSGrid.ColCount-1) {and (R<=TSGrid.RowCount-1)} then
              Begin
                ValStr  := Copy(CS,1,Pos(#13,CS)-1);
                EditRow := R;
                EditCol := C+1;
                SLREditExit(sender);
              End;
//         TSGrid.Cells[C+1,R]:=Copy(CS,1,Pos(#13,CS)-1);

           Delete(S,1,Pos(#13,S));
           if Copy(S,1,1)=#10 then
           Delete(S,1,1);
       end;
    end;

Var    i: Integer;
begin

  PTSR := @(TSSLRs^[TSSLRshowing].SLRArr);
  PCount := @(TSSLRs^[TSSLRshowing].NYears);

    If ((ssCtrl in Shift) AND (Key = ord('V')))  then
      Begin
        PasteIntoGrid;
        if Clipboard.HasFormat(CF_TEXT) then ClipBoard.Clear;
        Key := 0;
      End;


  If (Key = VK_DELETE)  and (ssCtrl in Shift) then
      Begin
        IF EditRow <= 0 then exit;
        If PCount^ = 0 then exit;
        For i := EditRow-1 to PCount^-2 do
            PTSR^[i] := PTSR^[i+1];
        PTSR^[PCount^-1].Year := 0;
        PTSR^[PCount^-1].Value := 0;

        Dec(PCount^);
        UpdateScreen;
      End;

  If (Key = VK_INSERT)  and (ssCtrl in Shift) then
      Begin
        IF EditRow <= 0 then EditRow := 1;
        If (PCount^+1 > Length(PTSR^)) then
          Begin
            SetLength(PTSR^,PCount^+5);
            For i := PCount^+1 to PCount^+5 do
              Begin
                PTSR^[i-1].Year := 0;
                PTSR^[i-1].Value := 0;
              End;
          End;

        If PCount^ > 0 then
          For i := PCount^-1 downto EditRow-1 do
            PTSR^[i+1] := PTSR^[i];

         PTSR^[EditRow-1].Year := 0;
         PTSR^[EditRow-1].Value := 0;

        Inc(PCount^);

        UpdateScreen;
      End;

end;

procedure TCustomSLRForm.SLREditSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  SLREditExit(sender);

  EditRow := ARow;
  EditCol := ACol;
end;

procedure TCustomSLRForm.SLREditSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
  If (EditRow<>ARow) or (EditCol<>ACol) Then Exit;
  ValStr  := Value;
end;

procedure TCustomSLRForm.UpdateGrids;

   Procedure WriteTimeSeries(count: Integer; TS: PTSRArray; Grid: TStringGrid);
   Var i: Integer;
   Begin
    With Grid do
     Begin
      RowCount := Count+1;
      For i := 0 to RowCount-1 do
        Rows[i].Clear;
        Rows[0].Add('Year');
        Rows[0].Add('SLR (m)');
        For i:=1 to count do
           Begin
             Rows[i].Add(IntToSTr(TS^[i-1].Year));
             Rows[i].Add(FloatToStrF(TS^[i-1].Value,FFGeneral,6,4));
           End;
        If count = 0 then
          Begin
            RowCount := 2; Rows[1].Clear;
          End;
        FixedRows := 1;
     End;
   End; {writetimeseries}


begin
  WriteTimeSeries(TSSLRs^[TSSLRshowing].NYears,@TSSLRs^[TSSLRshowing].SLRArr,SLREdit);

end;

procedure TCustomSLRForm.UpdateScreen;
Var i: Integer;
Begin
  SLRBox.Items.Clear;
   For i:=0 to NumTSSLRs-1 do
   Begin
    SLRBox.Items.Add(TSSLRs^[i].Name);
   End;

  SLRBox.ItemIndex := TSSLRshowing;


  IsUpdating := True;
  If NumTSSLRs > 0 then
   With TSSLRs^[TSSLRshowing] do
     Begin
       NameEdit.Text := Name;
       RunNowBox.Checked := RunNow;
       NameLabel.Enabled := RunNow;
       YearLabel.Enabled := RunNow;
       SLRLabel.Enabled := RunNow;

       BaseYearEdit.Text := IntToStr(TSSLRs^[TSSLRshowing].BaseYear);
       UpdateGrids;
       Panel1.Visible := True;
     End
   else Panel1.Visible := False;
   IsUpdating := False;

End;


end.
