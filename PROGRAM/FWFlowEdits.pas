//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit FWFlowEdits;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Main, StdCtrls, Grids, Menus, ExtCtrls, Clipbrd, Global, SLR6,
  Buttons;

type
  TFWFlowEdit = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    ModLabel: TLabel;
    FWFlowBox: TComboBox;
    Label3: TLabel;
    HelpButton: TBitBtn;
    ExtentOnlyWarning: TLabel;
    Panel1: TPanel;
    SaltWedgeSlopeEdit: TEdit;
    OriginLabel: TLabel;
    Label9: TLabel;
    MeanFlowEdit: TStringGrid;
    TurbEdit: TStringGrid;
    TurbLabel: TLabel;
    UseTurbiditybox: TCheckBox;
    MeanFlowLabel: TLabel;
    Label1: TLabel;
    TSwampEdit: TEdit;
    NameEdit: TEdit;
    NameLabel: TLabel;
    Label4: TLabel;
    OriginEdit: TEdit;
    Label2: TLabel;
    PPTEdit: TEdit;
    Label5: TLabel;
    ASaltSalinEdit: TEdit;
    Label6: TLabel;
    procedure ComboBox1Change(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure TurbEditExit(Sender: TObject);
    procedure TurbEditSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure TurbEditSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure FormCreate(Sender: TObject);
    procedure TurbEditDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure TurbEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure UseTurbidityboxClick(Sender: TObject);
    procedure NameEditChange(Sender: TObject);
    procedure TSwampEditExit(Sender: TObject);
    procedure FWFlowBoxChange(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
  private
    IsUpdating : Boolean;
    TFWFs: TFWFlows;
    NumFWFs, FWFShowing: Integer;
    { Private declarations }
  public
    ValStr  : String;  { [60]; }
    EditRow, EditCol : Integer;
    SaveStream: TMemoryStream;
    Procedure EditFWFlow(Var FWFs: TFWFlows; NFwFs, StartIndex: Integer);
    Procedure UpdateGrids;
    Procedure UpdateScreen();
    { Public declarations }
  end;

var
  FWFlowEdit: TFWFlowEdit;
  FSS: TSLAMM_Simulation;

implementation

uses System.UITypes;

{$R *.dfm}

procedure TFWFlowEdit.TurbEditDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  If (ARow=0) or (ACol=0) then
      with TStringGrid(Sender).Canvas do
        begin
          Font.Style := [fsbold];
//          TextRect(Rect, Rect.Left + 2, Rect.Top + 2, TStringGrid(Sender).Cells[ACol, ARow]);    Doesn't work in XE3, trying to make font bold
        end;

end;

procedure TFWFlowEdit.TurbEditExit(Sender: TObject);
Var R, C: Integer;
    V: String;
    PTSR: PTSRArray;
begin
  IF EditRow < 1 then exit;

  If (Trim(ValStr) = '~') then exit;
  R := EditRow; C := EditCol; V := ValStr;
  EditRow := -1; EditCol := -1; ValStr := '~';

  If Sender = TurbEdit then PTSR := @(TFWFs[FWFShowing].Turbidities)
                       else PTSR := @(TFWFs[FWFShowing].MeanFlow);

  If v='' then exit;

    Try
      If C=0 then PTSR^[R-1].Year := TRUNC(StrToFloat(V))
             else PTSR^[R-1].Value := StrToFloat(V);
    Except

    End;

  UpdateScreen;
end;

procedure TFWFlowEdit.TurbEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
// Paste
    Procedure PasteIntoGrid;
    var
       Grect:TGridRect;
       S,CS,F:String;
       L,R,C:Integer;
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
               C:=C+1;
               if (C<=TSGrid.ColCount-1)and (R<=TSGrid.RowCount-1) then
                   ValStr  :=Copy(CS,1,Pos(#9,CS)-1);
                   EditRow := R;
                   EditCol := C;
                   TurbEditExit(sender);
                   F:= Copy(CS,1,Pos(#9,CS)-1);
               Delete(CS,1,Pos(#9,CS));
           end;
           if (C<=TSGrid.ColCount-1)and (R<=TSGrid.RowCount-1) then
              Begin
                ValStr  := Copy(CS,1,Pos(#13,CS)-1);
                EditRow := R;
                EditCol := C+1;
                TurbEditExit(sender);
              End;
//         TSGrid.Cells[C+1,R]:=Copy(CS,1,Pos(#13,CS)-1);

           Delete(S,1,Pos(#13,S));
           if Copy(S,1,1)=#10 then
           Delete(S,1,1);
       end;
    end;

Var PTSR: PTSRArray;
    PCount : PInteger;
    i: Integer;
begin

    If ((ssCtrl in Shift) AND (Key = ord('V')))  then
      Begin
        PasteIntoGrid;
        Key := 0;
      End;

  If Sender = TurbEdit then PTSR := @(TFWFs[FWFShowing].Turbidities)
                       else PTSR := @(TFWFs[FWFShowing].MeanFlow);

  If Sender = TurbEdit then PCount := @(TFWFs[FWFShowing].NTurbidities)
                       else PCount := @(TFWFs[FWFShowing].NFLows);

  If (Key = VK_DELETE)  and (ssCtrl in Shift) then
      Begin
        IF EditRow <= 0 then exit;
        If PCount^ = 0 then exit;
        For i := EditRow-1 to PCount^-2 do
            PTSR^[i] := PTSR^[i+1];
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

procedure TFWFlowEdit.TurbEditSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  TurbEditExit(sender);

  EditRow := ARow;
  EditCol := ACol;
end;

procedure TFWFlowEdit.TurbEditSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
  If (EditRow<>ARow) or (EditCol<>ACol) Then Exit;
  ValStr  := Value;
end;

Procedure TFWFlowEdit.CancelBtnClick(Sender: TObject);
begin
  If MessageDlg('Cancel all Changes?',mtconfirmation,[mbyes,mbno],0) = MRyes then
    ModalResult := MRCancel;
end;

Procedure TFWFlowEdit.ComboBox1Change(Sender: TObject);
begin
  UpdateScreen;
end;


procedure TFWFlowEdit.EditFWFlow(Var FWFs: TFWFlows; NFwFs, StartIndex: Integer);

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

Var i: Integer;
begin
  TFWFs := FWFs;
  NumFwFs := NFwFs;
  FWFShowing := StartIndex;

  TSText := False;
  SaveStream := TMemoryStream.Create;
  GlobalTS := SaveStream;
  For i := 0 to NumFwFs-1 do
    TFWFs[i].Store(TStream(SaveStream));  {save for backup in case of cancel click}

  UpdateScreen;

  SaveStream.Seek(0, soFromBeginning); {Go to beginning of stream}
  If ShowModal = MRCancel then
    Begin
      For i := 0 to NumFwFs-1 do
        TFWFs[i].Load(VersionNum,TStream(SaveStream));
    End
    else {sort timeseries}
      Begin
        For i := 0 to NumFwFs-1 do
          Begin
            If TFWFs[i].NTurbidities>0 then QuickSortDates(TFWFs[i].Turbidities,0,TFWFs[i].NTurbidities-1);
            If TFWFs[i].NFlows>0 then QuickSortDates(TFWFs[i].MeanFLow,0,TFWFs[i].NFlows-1);
          End;

      End;
  SaveStream.Free;

end;

procedure TFWFlowEdit.FormCreate(Sender: TObject);
begin
  EditRow := -1; EditCol := -1; ValStr := '~';
end;



procedure TFWFlowEdit.FWFlowBoxChange(Sender: TObject);
begin
  FWFShowing := FwFlowBox.ItemIndex;
  UpdateScreen;
end;

procedure TFWFlowEdit.HelpButtonClick(Sender: TObject);
begin
   Application.HelpContext( 1011);  //'Freshwaterflow.html');
end;

procedure TFWFlowEdit.NameEditChange(Sender: TObject);
begin
  TFWFs[FwFshowing].Name := NameEdit.Text;
end;

procedure TFWFlowEdit.TSwampEditExit(Sender: TObject);
Var
Conv: Double;
Result: Integer;

begin
  If IsUpdating then exit;
  Val(Trim(TEdit(Sender).Text),Conv,Result);
  If Result<>0 then MessageDlg('Incorrect Numerical Format Entered',mterror,[mbOK],0)
           else begin
                   case TEdit(Sender).Name[1] of
                      'T': TFWFs[FwFshowing].TSElev := Conv;
                      'P': TFWFs[FwFshowing].FWPPT := Conv;
                      'A': TFWFs[FwFshowing].SWPPT := Conv;

{                     'M': TFWFs[FwFshowing].ManningsN := Conv;
                      'W': TFWFs[FwFshowing].FlWidth := Conv; }
                      'S': TFWFs[FwFshowing].InitSaltWedgeSlope := Conv;
                      'O': TFWFs[FwFshowing].Origin_KM  := Conv;

                    end; {case}
                end; {else}
    UpdateScreen;
end;

procedure TFWFlowEdit.UseTurbidityboxClick(Sender: TObject);
begin
  TFWFs[FwFshowing].UseTurbidities := UseTurbiditybox.Checked;
  UpdateScreen;
end;

Procedure TFWFlowEdit.UpdateScreen;
Var i: Integer;
Begin
  FwFlowBox.Items.Clear;
   For i:=0 to NumFWFs-1 do
   Begin
    FwFlowBox.Items.Add(TFWFs[i].Name);
   End;

  FwFlowBox.ItemIndex := FwFshowing;

   ExtentOnlyWarning.Visible := TFWFs[FwFshowing].ExtentOnly;
   Panel1.Visible := not TFWFs[FwFshowing].ExtentOnly;

   IsUpdating := True;
   NameEdit.Text := TFWFs[FwFshowing].Name;
   TSwampEdit.Text := FloatToStrF(TFWFs[FwFshowing].TSElev,FFGeneral,6,4);
{  ManningEdit.Text := FloatToStrF(TFWFs[FwFshowing].ManningsN,FFGeneral,6,4);
   WidthEdit.Text := FloatToStrF(TFWFs[FwFshowing].FlWidth,FFGeneral,6,4); }
   SaltWedgeSlopeEdit.Text := FloatToStrF(TFWFs[FwFshowing].InitSaltWedgeSlope,FFGeneral,6,4);
   PPTEdit.Text := FloatToStrF(TFWFs[FwFshowing].FWPPT,FFGeneral,6,4);

   ASaltSalinEdit.Text := FloatToStrF(TFWFs[FwFshowing].SWPPT ,FFGeneral,6,4);
   OriginEdit.Text := FloatToStrF(TFWFs[FwFshowing].Origin_KM   ,FFGeneral,6,4);

   UseTurbiditybox.Checked := TFWFs[FwFshowing].UseTurbidities;
   TurbLabel.Enabled := UseTurbiditybox.Checked;
   TurbEdit.Enabled := UseTurbiditybox.Checked;
   If not UseTurbiditybox.Checked then TurbEdit.Color := CLGray
                            else TurbEdit.Color := CLWindow;

   MeanFlowLabel.Enabled := True;
   MeanFlowEdit.Enabled := True;
{  ManningLabel.Enabled := True;
   ManningEdit.Enabled := True;
   WidthEdit.Enabled := True;
   WidthLabel.Enabled := True; }
   OriginLabel.Enabled := True;
   SaltWedgeSlopeEdit.Enabled := True;

   if (Pos('.xls',lowercase(FSS.SalFileN))>0) then
    begin
      Label1.Enabled := False;
      TSwampEdit.Enabled := False;
      Label2.Enabled := False;
      PPTEdit.Enabled := False;
      Label5.Enabled := False;
      ASaltSalinEdit.Enabled := False;
      Label4.Enabled := False;
      SaltWedgeSlopeEdit.Enabled := False;
      OriginLabel.Enabled := False;
      OriginEdit.Enabled := False;
      TurbLabel.Enabled := False;
      UseTurbidityBox.Enabled := False;
      TurbEdit.Enabled := False;
      TurbEdit.Font.Color := clGray;
    end
   else
    begin
      Label1.Enabled := True;
      TSwampEdit.Enabled := True;
      Label2.Enabled := True;
      PPTEdit.Enabled := True;
      Label5.Enabled := True;
      ASaltSalinEdit.Enabled := True;
      Label4.Enabled := True;
      SaltWedgeSlopeEdit.Enabled := True;
      OriginLabel.Enabled := True;
      OriginEdit.Enabled := True;
      TurbLabel.Enabled := True;
      UseTurbidityBox.Enabled := True;
      TurbEdit.Enabled := True;
      TurbEdit.Font.Color := clBlack;
    end;

   UpdateGrids;
   IsUpdating := False;

End;


procedure TFWFlowEdit.UpdateGrids;

   Procedure WriteTimeSeries(count: Integer; TS: PTSRArray; Grid: TStringGrid);
   Var i: Integer;
   Begin
    With Grid do
     Begin
      RowCount := Count+1;
      For i := 0 to RowCount-1 do
        Rows[i].Clear;
        Rows[0].Add('Year');
        Rows[0].Add('Value');
        For i:=1 to count do
           Begin
             Rows[i].Add(IntToSTr(TS^[i-1].Year));
             Rows[i].Add(FloatToStrF(TS^[i-1].Value,FFGeneral,6,4));
           End;
       End;
   End; {writetimeseries}


begin
  WriteTimeSeries(TFWFs[FwFshowing].NTurbidities,@TFWFs[FwFshowing].Turbidities,TurbEdit);
  WriteTimeSeries(TFWFs[FwFshowing].NFlows,@TFWFs[FwFshowing].MeanFlow,MeanFlowEdit);

end;

end.
