unit CarbonSeq;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls, Vcl.Grids, Categories,
  Vcl.ExtCtrls, Global;

type
  TCarbonSeqForm = class(TForm)
    Panel1: TPanel;
    Label9: TLabel;
    CSEdit: TStringGrid;
    OKBtn: TButton;
    CancelBtn: TButton;
    Image1: TImage;
    Button1: TButton;
    procedure CSEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CSEditSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure CSEditSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure CancelBtnClick(Sender: TObject);
    procedure CSEditExit(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    IsUpdating : Boolean;
  public
    PCats : PCategories;
    ValStr  : String;
    EditRow, EditCol : Integer;
    SaveStream: TMemoryStream;
    Procedure EditCarbonSeqs(SS: Pointer);
    Procedure UpdateGrids;
    Procedure UpdateScreen();
  end;

var
  CarbonSeqForm: TCarbonSeqForm;

implementation

Uses Clipbrd, System.UITypes, SLR6;

{$R *.dfm}

procedure TCarbonSeqForm.Button1Click(Sender: TObject);
begin
  PCats^.SetCSeqDefaults(PCats^.AreCalifornia) ;
  UpdateScreen
end;

procedure TCarbonSeqForm.CancelBtnClick(Sender: TObject);
begin
  If MessageDlg('Cancel all Changes?',mtconfirmation,[mbyes,mbno],0) = MRyes then
    ModalResult := MRCancel;
end;

procedure TCarbonSeqForm.EditCarbonSeqs(SS: Pointer);
begin
  TSText := False;
  SaveStream := TMemoryStream.Create;
  GlobalTS := SaveStream;
  PCats^.Store(TStream(SaveStream));  {save for backup in case of cancel click}

  CSEdit.Colwidths[0] := 190;
  CSEdit.Colwidths[1] := 50;
  CSEdit.Colwidths[2] := 50;
  CSEdit.Colwidths[3] := 50;
  CSEdit.Colwidths[4] := 250;

  UpdateScreen;

  SaveStream.Seek(0, soFromBeginning); {Go to beginning of stream}
  If ShowModal = MRCancel then
    Begin
      PCats^.Free;
      PCats^ := TCategories.Load(SS,VersionNum,TStream(SaveStream));
    End
    else
      Begin
      End;
  SaveStream.Free;

end;

procedure TCarbonSeqForm.CSEditExit(Sender: TObject);
Var R, C: Integer;
    V: String;
begin
  IF EditRow < 1 then exit;
  IF EditCol < 1 then exit;

  If (Trim(ValStr) = '~') then exit;
  R := EditRow; C := EditCol; V := ValStr;
  EditRow := -1; EditCol := -1; ValStr := '~';

  Try
    With PCats^.GetCat(R-1) do
      Begin
        If C=1 then mab := StrToFloat(v);
        If C=2 then Rsc := StrToFloat(v);
        If C=3 then ECH4:= StrToFloat(v);
        If C=4 then CSeqNotes:= v;
      End;
  Except
  End;

  If v='' then exit;

  UpdateScreen;
end;

procedure TCarbonSeqForm.UpdateGrids;
Var i: Integer;
Begin

  With CSEdit do
   Begin
    RowCount := PCats^.NCats+1;
    For i := 0 to RowCount-1 do
      Rows[i].Clear;

    Rows[0].Add('Category');
    Rows[0].Add('m ab');
    Rows[0].Add('R sc');
    Rows[0].Add('E CH4');
    Rows[0].Add('Reference');

    For i:=1 to PCats^.NCats do
     With PCats^.GetCat(i-1) do
      Begin
        Rows[i].Add(TextName);
        Rows[i].Add(FloatToStrF(mab,FFGeneral,6,4));
        Rows[i].Add(FloatToStrF(rsc,FFGeneral,6,4));
        Rows[i].Add(FloatToStrF(ECH4,FFGeneral,6,4));
        Rows[i].Add(CSeqNotes);
      End;

     FixedRows := 1;
     FixedCols := 1;
   End;
End;


procedure TCarbonSeqForm.CSEditKeyDown(Sender: TObject; var Key: Word;
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
               if (C<=TSGrid.ColCount-1) and (R<=TSGrid.RowCount-1) then
                 Begin
                   ValStr  :=Copy(CS,1,Pos(#9,CS)-1);
                   EditRow := R;
                   EditCol := C;
                   CSEditExit(sender);
                   F:= Copy(CS,1,Pos(#9,CS)-1);
                 End;
               Delete(CS,1,Pos(#9,CS));
           end;

           if (C<=TSGrid.ColCount-1) and (R<=TSGrid.RowCount-1) then
              Begin
                ValStr  := Copy(CS,1,Pos(#13,CS)-1);
                EditRow := R;
                EditCol := C+1;
                CSEditExit(sender);
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
        if Clipboard.HasFormat(CF_TEXT) then ClipBoard.Clear;
        Key := 0;
      End;

end;

procedure TCarbonSeqForm.CSEditSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  CSEditExit(sender);

  EditRow := ARow;
  EditCol := ACol;
end;

procedure TCarbonSeqForm.CSEditSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
  If (EditRow<>ARow) or (EditCol<>ACol) Then Exit;
  ValStr  := Value;
end;


procedure TCarbonSeqForm.UpdateScreen;
Begin

  IsUpdating := True;
  UpdateGrids;
  IsUpdating := False;

End;


end.
