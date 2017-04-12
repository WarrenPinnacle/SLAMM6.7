unit WindRose;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Global, SLR6, Vcl.ExtCtrls,
  Vcl.StdCtrls;

type
  TWindForm = class(TForm)
    RoseGrid: TStringGrid;
    Image1: TImage;
    OKBtn: TButton;
    CancelBtn: TButton;
    Label1: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    Label2: TLabel;
    Shape3: TShape;
    Label3: TLabel;
    Shape4: TShape;
    Label4: TLabel;
    Shape5: TShape;
    Label5: TLabel;
    Shape6: TShape;
    Label6: TLabel;
    Shape7: TShape;
    Label7: TLabel;
    NorthLabel: TLabel;
    Label8: TLabel;
    procedure RoseGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure RoseGridExit(Sender: TObject);
    procedure RoseGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure RoseGridSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure RoseGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    SS: TSLAMM_Simulation;
    ValStr  : String;
    EditRow, EditCol : Integer;
    RowMax: Double;
    procedure DrawRose;
    Procedure UpdateScreen;
    Procedure EditWindRose(PSS: TSLAMM_Simulation);
    { Public declarations }
  end;

var
  WindForm: TWindForm;
  EditRose: TWindRose;

implementation

Uses Clipbrd, Math, SLAMMLegend;

{$R *.dfm}

procedure TWindForm.DrawRose;

Var EX1,EY1,EX2,EY2, XCenter, YCenter, Rad: Integer;

   Procedure DrawArc(MinFrac,MaxFrac, DegA,DegB: Double; Clr: TColor);
   Var X1, Y1, X2, Y2: Integer;
       Rad2: Integer;
   Begin
    For Rad2 := Round(Rad*MinFrac) to Round(Rad*MaxFrac) do

    With Image1 do Begin
     Canvas.Pen.Color := Clr;
      X1 := Round (XCenter + (Rad2)*SIN(DegToRad(DegB)));
      X2 := Round (XCenter + (Rad2)*SIN(DegToRad(DegA)));
      Y1 := Round (YCenter - (Rad2)*COS(DegToRad(DegB)));
      Y2 := Round (YCenter - (Rad2)*COS(DegToRad(DegA)));
      EX1 := Round (XCenter-Rad2);
      EY1 := Round (YCenter-Rad2);
      EX2 := Round (XCenter+Rad2);
      EY2 := Round (YCenter+Rad2);

     Canvas.Arc(EX1,EY1,EX2,EY2,X1,Y1,X2,Y2);
    End; {With Image1}
   End;

Var WD,WS: Integer;
    MinP,MaxP: Double;

begin
  With Image1 do Begin
    XCenter := Round(Width/2);
    YCenter := Round(Height/2);
    Rad := Min(XCenter,YCenter);

    EX1 := XCenter-Rad;
    EY1 := YCenter-Rad;
    EX2 := XCenter+Rad;
    EY2 := YCenter+Rad;

    Canvas.Pen.Color := ClBlack;
    Canvas.Brush.Color := clWhite;
    Canvas.Ellipse(EX1,EY1,EX2,EY2);

  End;


  If RowMax > 0 then
   For WD := 1 to NWindDirections do
    Begin
     MaxP := 0;
      For WS := 1 to NWindSpeeds do
       Begin
         MinP := MaxP;
         If EditRose[WD,WS]>0 then
           Begin
             MaxP := MinP + EditRose[WD,WS] / RowMax;
             DrawArc(MinP,MaxP,WindDegrees[WD]-10,WindDegrees[WD]+10,ColorGradient(1, NWindSpeeds, WS));
           End;
       End;
    End;

End;

procedure TWindForm.EditWindRose(PSS: TSLAMM_Simulation);
begin
  EditRose := PSS.WindRose;
  SS := PSS;

  UpdateScreen;

  If WindForm.ShowModal = MROK then PSS.WindRose := EditRose;
end;

procedure TWindForm.FormCreate(Sender: TObject);
begin
  EditRow := -1; EditCol := -1; ValStr := '~';
end;

procedure TWindForm.FormResize(Sender: TObject);
begin
  Image1.Picture.Assign(nil);
  Image1.Picture.Bitmap.Height:=Image1.Height;
  Image1.Picture.Bitmap.Width:=Image1.Width;
  DrawRose;
  NorthLabel.Left := (Image1.Width Div 2)+29
end;

procedure TWindForm.RoseGridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
Var S: String;
    RectForText: TRect;
begin
  With RoseGrid do
    If (ARow=0) or (ACol=0) or (ARow=RowCount-1) or (ACol=ColCount-1) then
      with RoseGrid.Canvas do
        begin
          S := Cells[ACol, ARow];
          Canvas.Brush.Color := clBtnFace;
          Canvas.FillRect(Rect);
          Font.Style := [fsbold];
          RectForText := Rect;
          InflateRect(RectForText, -2, -2);
          Canvas.TextRect(RectForText, S);
        end;
end;

procedure TWindForm.RoseGridExit(Sender: TObject);
Var R, C: Integer;
    V: String;

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

begin
 IF EditRow < 1 then exit;
 If EditCol < 1 then exit;

 If (EditRow+1 = RoseGrid.RowCount) or (EditCol+1 = RoseGrid.ColCount) then
    Begin UpdateScreen; Exit; End;

  If (Trim(ValStr) = '~') then exit;
  R := EditRow; C := EditCol; V := ValStr;
  EditRow := -1; EditCol := -1; ValStr := '~';

  If v='' then Exit;

  Try
    EditRose[R,C] := StrToFloat(V);

  Except

  End;

  UpdateScreen;
end;

procedure TWindForm.RoseGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
// Paste
    Procedure PasteIntoGrid;
    var
       Grect:TGridRect;
       S,CS,F:String;
       L,R,C:Byte;
    begin
       GRect:=RoseGrid.Selection;
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
               if (C<=RoseGrid.ColCount-1)and (R<=RoseGrid.RowCount-1) then
                   ValStr  :=Copy(CS,1,Pos(#9,CS)-1);
                   EditRow := R;
                   EditCol := C;
                   RoseGridExit(nil);
                   F:= Copy(CS,1,Pos(#9,CS)-1);
               Delete(CS,1,Pos(#9,CS));
           end;
           if (C<=RoseGrid.ColCount-1)and (R<=RoseGrid.RowCount-1) then
              Begin
                ValStr  := Copy(CS,1,Pos(#13,CS)-1);
                EditRow := R;
                EditCol := C+1;
                RoseGridExit(nil);
              End;
//         RoseGrid.Cells[C+1,R]:=Copy(CS,1,Pos(#13,CS)-1);

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

procedure TWindForm.RoseGridSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  RoseGridExit(nil);
end;

procedure TWindForm.RoseGridSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
begin
  ValStr  := Value;
  EditRow := ARow;
  EditCol := ACol;
end;

procedure TWindForm.UpdateScreen;
Var i: Integer;
    WD,WS: Integer;
    rowindex: integer;
    RowTot, FullTot: Double;
    ColTots: Array[1..NWindSpeeds ] of Double;

begin
  With RoseGrid do
    Begin
      For i := 0 to RowCount-1 do
        Rows[i].Clear;

      Rows[0].Add('Direction');
      Rows[0].Add('< 0.5 m/s');
      Rows[0].Add('0.5-2 m/s');
      Rows[0].Add('2-4 m/s');
      Rows[0].Add('4-6 m/s');
      Rows[0].Add('6-8 m/s');
      Rows[0].Add('8-10 m/s');
      Rows[0].Add('> 10 m/s');
      Rows[0].Add('Total');

      Label1.Caption :='< 0.5 m/s';
      Label2.Caption :='0.5-2 m/s';
      Label3.Caption :='2-4 m/s';
      Label4.Caption :='4-6 m/s';
      Label5.Caption :='6-8 m/s';
      Label6.Caption :='8-10 m/s';
      Label7.Caption :='> 10 m/s';

      Shape1.Brush.Color := ColorGradient(1, NWindSpeeds, 1);
      Shape2.Brush.Color := ColorGradient(1, NWindSpeeds, 2);
      Shape3.Brush.Color := ColorGradient(1, NWindSpeeds, 3);
      Shape4.Brush.Color := ColorGradient(1, NWindSpeeds, 4);
      Shape5.Brush.Color := ColorGradient(1, NWindSpeeds, 5);
      Shape6.Brush.Color := ColorGradient(1, NWindSpeeds, 6);
      Shape7.Brush.Color := ColorGradient(1, NWindSpeeds, 7);


      RowIndex :=0;
      FullTot := 0;
      RowMax := -1;
      For WS := 1 to NWindSpeeds do
         ColTots[WS] := 0;

      For WD := 1 to NWindDirections do
        Begin
          RowTot := 0;

          Inc(RowIndex);
          Rows[RowIndex].Add(WindDirections[WD]);
          For WS := 1 to NWindSpeeds do
            Begin
              ColTots[WS] := ColTots[WS] + EditRose[WD,WS];
              RowTot := RowTot + EditRose[WD,WS];
              FullTot := FullTot + EditRose[WD,WS];
              Rows[RowIndex].Add(FloatToStrf(EditRose[WD,WS],FFGeneral,6,4));
            End;
          Rows[RowIndex].Add(FloatToStrf(RowTot,FFGeneral,6,4));
          If RowTot>RowMax then RowMax := RowTot;
        End;

      Inc(RowIndex);
      Rows[RowIndex].Add('Total');
      For WS := 1 to NWindSpeeds do
        Begin
          Rows[RowIndex].Add(FloatToStrf(ColTots[WS],FFGeneral,6,4));
        End;
       Rows[RowIndex].Add(FloatToStrf(FullTot,FFGeneral,6,4));

    End; {With RoseGrid}
   DrawRose;
end;


end.
