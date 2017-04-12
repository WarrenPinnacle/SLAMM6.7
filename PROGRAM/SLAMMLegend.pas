//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//
unit SLAMMLegend;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Global, System.UITypes, SLR6;

type
  TLegendForm = class(TForm)
    Label1: TLabel;
    Shape1: TShape;
    Label2: TLabel;
    Shape2: TShape;
    Label3: TLabel;
    Shape3: TShape;
    Label4: TLabel;
    Shape4: TShape;
    Label5: TLabel;
    Shape5: TShape;
    Label6: TLabel;
    Shape6: TShape;
    Label7: TLabel;
    Shape7: TShape;
    Label8: TLabel;
    Shape8: TShape;
    Label9: TLabel;
    Shape9: TShape;
    Label10: TLabel;
    Shape10: TShape;
    Label11: TLabel;
    Shape11: TShape;
    Label12: TLabel;
    Shape12: TShape;
    Label13: TLabel;
    Shape13: TShape;
    Label14: TLabel;
    Shape14: TShape;
    Label15: TLabel;
    Shape15: TShape;
    Label16: TLabel;
    Shape16: TShape;
    Label17: TLabel;
    Shape17: TShape;
    Label18: TLabel;
    Shape18: TShape;
    Label19: TLabel;
    Shape19: TShape;
    Label20: TLabel;
    Shape20: TShape;
    Label21: TLabel;
    Shape21: TShape;
    Label22: TLabel;
    Shape22: TShape;
    Label23: TLabel;
    Shape23: TShape;
    Label24: TLabel;
    Shape24: TShape;
    Label25: TLabel;
    Shape25: TShape;
    Label26: TLabel;
    Shape26: TShape;
    TitleLabel: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button18: TButton;
    Button19: TButton;
    Button20: TButton;
    Button21: TButton;
    Button22: TButton;
    Button23: TButton;
    Button24: TButton;
    Button25: TButton;
    Button26: TButton;
    ColorDialog1: TColorDialog;
    SaveButton: TButton;
    LoadButton: TButton;
    Label27: TLabel;
    Shape27: TShape;
    Button27: TButton;
    Label28: TLabel;
    Shape28: TShape;
    Button28: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure LoadButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    Changed: Boolean;
    GMin, GMax: Double;
    PSS: TSLAMM_Simulation;
    Procedure UpdateLegend(Gradient,Elevation,Connectivity: Boolean);
  end;

var
  LegendForm: TLegendForm;

Function ColorGradient(Min, Max, Level: Double): TColor;

implementation

{$R *.DFM}
    Function ColorGradient(Min, Max, Level: Double): TColor;
    {gradient of Blue to Red}
    Var R,G,B: Integer;
        Place: Integer;
    Begin
      Result := ClBlack;
      If Max=Min then Exit;

      If Level<Min then Level := Min;
      If Level>Max then Level := Max;

      Place := Trunc(((Level-Min) / (Max-Min)) * 1023);
      G := 255;
      If Place<256
        then G := Place;
      If Place>767 then G := 1023-Place;
      If G<0 then G:=0;

      B := 0;
      If Place < 512 then B := 511-Place;
      If B<0 then B:=0;
      If B>255 then B:= 255;

      R := 0;
      If Place >511 then R := Place-511;
      If R>255 then R:= 255;

      Result := RGB(r, g, b)
    End;


procedure TLegendForm.Button1Click(Sender: TObject);
Var EditIndex: Integer;
    BName: String;
begin
  BName := TButton(Sender).Name;
  Delete(BName,1,6);
  EditIndex := StrToInt(BName);
  ColorDialog1.Color := PSS.Categories.GetCat(EditIndex-1).Color;
  if ColorDialog1.Execute
    then Begin
           PSS.Categories.GetCat(EditIndex-1).Color := ColorDialog1.Color;
           Changed := True;
         End;

  UpdateLegend(False,False,False);
end;

procedure TLegendForm.FormShow(Sender: TObject);
begin
  Changed := False;
end;

procedure TLegendForm.LoadButtonClick(Sender: TObject);
Var FileN: String;
    RVN: Double;
    i, Clr: Integer;
    TF: TextFile;
begin
  If Not PromptForFileName(FileN,'SLAMM Colors File (*.SLAMMCLR)|*.SLAMMCLR','.SLAMMCLR','Select File to Save Load from','',False)
     then Exit;

  TSText := True;
  GlobalFile := @TF;
  AssignFile(GlobalFile^,FileN);
  Reset(GlobalFile^);
  GlobalLN := 0;

  Try
    TSRead('ReadVersionNum',RVN);
    For i := 0 to PSS.Categories.NCats-1 do
     begin
      TSRead(PSS.Categories.GetCat(i).TextName,Clr);
      PSS.Categories.GetCat(i).Color := Clr;
     end;
  Except
    Closefile(GlobalFile^);
  End;

  Closefile(GlobalFile^);
  UpdateLegend(False,False,False);
  Changed := True;
end;

procedure TLegendForm.SaveButtonClick(Sender: TObject);
Var FileN: String;
    i: Integer;
    TF: TextFile;
begin
  If Not PromptForFileName(FileN,'SLAMM Colors File (*.SLAMMCLR)|*.SLAMMCLR','.SLAMMCLR','Select File to Save Colors To','',True)
     then Exit;

  TSText := True;
  GlobalFile := @TF;

  AssignFile(GlobalFile^,FileN);
  Rewrite(GlobalFile^);
  GlobalLN := 0;

  Try
    TSWrite('ReadVersionNum',VersionNum);
    For i := 0 to PSS.Categories.NCats-1 do
      TSWrite(PSS.Categories.GetCat(i).TextName,PSS.Categories.GetCat(i).Color);
  Except
    Closefile(GlobalFile^);
  End;

 Closefile(GlobalFile^);
 ShowMessage('Colors saved to '+FileN);

end;

procedure TLegendForm.UpdateLegend(Gradient, Elevation, Connectivity :Boolean);
Var ShowButtons: Boolean;
    i: Integer;
begin
  If (Not Gradient) and (Not Elevation) and (Not Connectivity) then
    Begin
      For i := 0 to PSS.Categories.NCats-1 do
        Begin
          with TLabel(FindComponent('Label' + IntToStr(i+1))) do
           Begin
            Visible := True;
            Caption := PSS.Categories.GetCat(i).TextName;
           End;
          with TShape(FindComponent('Shape' + IntToStr(i+1))) do
           Begin
            Visible := True;
            Brush.Color := PSS.Categories.GetCat(i).Color;
           End;
        End;

      For i := PSS.Categories.NCats to 25 do
        Begin
          with TLabel(FindComponent('Label' + IntToStr(i+1))) do
              Visible := False;
          with TShape(FindComponent('Shape' + IntToStr(i+1))) do
            Visible := False;
        End;
     End;

  If elevation then
    Begin
      Label1.Caption := '<-2 m';      Shape1.Brush.Color    :=  $00660000;
      Label2.Caption := '-2';         Shape2.Brush.Color    :=  $00666600;
      Label3.Caption := '-1.5';       Shape3.Brush.Color    :=  $00667700;
      Label4.Caption := '-1';         Shape4.Brush.Color    :=  $00668800;
      Label5.Caption := '-0.5';       Shape5.Brush.Color    :=  $00669900;
      Label6.Caption := '0';          Shape6.Brush.Color    :=  $0066AA00;
      Label7.Caption := '0.5';        Shape7.Brush.Color    :=  $0066BB00;
      Label8.Caption := '1';          Shape8.Brush.Color    :=  $0066CC00;
      Label9.Caption := '1.5';        Shape9.Brush.Color    :=  $0066DD00;
      Label10.Caption := '2';         Shape10.Brush.Color   :=  $0066EE00;
      Label11.Caption := '2.5';       Shape11.Brush.Color   :=  $0066FF00;
      Label12.Caption :=' 3';         Shape12.Brush.Color   :=  $0066FF11;
      Label13.Caption := '3.5';       Shape13.Brush.Color   :=  $0066FF22;
      Label14.Caption := '4';         Shape14.Brush.Color   :=  $0066FF33;
      Label15.Caption := '4.5';       Shape15.Brush.Color   :=  $0066FF44;
      Label16.Caption := '5';         Shape16.Brush.Color   :=  $0066FF55;
      Label17.Caption := '5.5';       Shape17.Brush.Color   :=  $0066FF66;
      Label18.Caption := '6';         Shape18.Brush.Color   :=  $0066FF77;
      Label19.Caption := '6.5';       Shape19.Brush.Color   :=  $0066FF88;
      Label20.Caption := '> 7 m';     Shape20.Brush.Color   :=  $0066FF99;

      Label21.Visible := False;
      Shape21.Visible := False;
      Label22.Visible := False;
      Shape22.Visible := False;
      Label23.Visible := False;
      Shape23.Visible := False;
      Label24.Visible := False;
      Shape24.Visible := False;
      Label24.Visible := False;
      Shape24.Visible := False;
      Label25.Visible := False;
      Shape25.Visible := False;
      Label26.Visible := False;
      Shape26.Visible := False;
      Label27.Visible := False;
      Shape28.Visible := False;
      Label28.Visible := False;
      Shape28.Visible := False;

    End;

  If connectivity then

(*                  2 : Cat := TidalSwamp;       {Above Salt Bound = 2  [dark green]}
                  3 : Cat := InlandOpenWater;  {Connected = 3   [grey-blue]}
                  4 : Cat := IrregFloodMarsh;  {Unconnected = 4  [orange]}
                  5 : Cat := InlandShore;      {Irrelevant = 5     [brown]}
                  7 : if Cl.ProtDikes then Cat := OceanBeach   // yellow
                  8 : tidal water *)

    Begin
      Label1.Caption := 'Above Salt Bound';  Shape1.Brush.Color := $00003E00;    {very dark green, almost black}
      Label2.Caption := 'Connected';  Shape2.Brush.Color := $00FFA8A8; {InlandOpenWater default light blue}
      Label3.Caption := 'Not Connected';  Shape3.Brush.Color := $004080FF; {Irregularly Flooded Brackish Marsh is Orange}
      Label4.Caption := 'Irrelevant Category';  Shape4.Brush.Color := $00004080; {Inland Shore is Brown}
      Label5.Caption := 'Protected by Dikes';  Shape5.Brush.Color := ClYellow;
      Label6.Caption := 'Tidal Water';  Shape6.Brush.Color := ClNavy;

      Label7.Visible := False;
      Shape7.Visible := False;
      Label8.Visible := False;
      Shape8.Visible := False;
      Label9.Visible := False;
      Shape9.Visible := False;
      Label10.Visible := False;
      Shape10.Visible := False;
      Label11.Visible := False;
      Shape11.Visible := False;
      Label12.Visible := False;
      Shape12.Visible := False;
      Label13.Visible := False;
      Shape13.Visible := False;
      Label14.Visible := False;
      Shape14.Visible := False;
      Label15.Visible := False;
      Shape15.Visible := False;
      Label16.Visible := False;
      Shape16.Visible := False;
      Label17.Visible := False;
      Shape17.Visible := False;
      Label18.Visible := False;
      Shape18.Visible := False;
      Label19.Visible := False;
      Shape19.Visible := False;
      Label20.Visible := False;
      Shape20.Visible := False;
      Label21.Visible := False;
      Shape21.Visible := False;
      Label22.Visible := False;
      Shape22.Visible := False;
      Label23.Visible := False;
      Shape23.Visible := False;
      Label24.Visible := False;
      Shape24.Visible := False;
      Label24.Visible := False;
      Shape24.Visible := False;
      Label25.Visible := False;
      Shape25.Visible := False;
      Label26.Visible := False;
      Shape26.Visible := False;
      Label27.Visible := False;
      Shape27.Visible := False;
      Label28.Visible := False;
      Shape28.Visible := False;

    End
   else  If Gradient then  //not connectivity and gradient
      Begin
        Label21.Visible := True;
        Shape21.Visible := True;

        Label1.Caption       := FloatToStrF(GMin + (1-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label2.Caption       := FloatToStrF(GMin + (2-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label3.Caption       := FloatToStrF(GMin + (3-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label4.Caption       := FloatToStrF(GMin + (4-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label5.Caption       := FloatToStrF(GMin + (5-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label6.Caption       := FloatToStrF(GMin + (6-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label7.Caption       := FloatToStrF(GMin + (7-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label8.Caption       := FloatToStrF(GMin + (8-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label9.Caption       := FloatToStrF(GMin + (9-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label10.Caption       := FloatToStrF(GMin + (10-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label11.Caption       := FloatToStrF(GMin + (11-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label12.Caption       := FloatToStrF(GMin + (12-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label13.Caption       := FloatToStrF(GMin + (13-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label14.Caption       := FloatToStrF(GMin + (14-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label15.Caption       := FloatToStrF(GMin + (15-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label16.Caption       := FloatToStrF(GMin + (16-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label17.Caption       := FloatToStrF(GMin + (17-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label18.Caption       := FloatToStrF(GMin + (18-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label19.Caption       := FloatToStrF(GMin + (19-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label20.Caption       := FloatToStrF(GMin + (20-1)/20*(GMax-GMin),FFGeneral,6,4);
        Label21.Caption       := FloatToStrF(GMin + (21-1)/20*(GMax-GMin),FFGeneral,6,4);

        Shape1.Brush.Color   := ColorGradient(1,21,1);
        Shape2.Brush.Color   := ColorGradient(1,21,2);
        Shape3.Brush.Color   := ColorGradient(1,21,3);
        Shape4.Brush.Color   := ColorGradient(1,21,4);
        Shape5.Brush.Color   := ColorGradient(1,21,5);
        Shape6.Brush.Color   := ColorGradient(1,21,6);
        Shape7.Brush.Color   := ColorGradient(1,21,7);
        Shape8.Brush.Color   := ColorGradient(1,21,8);
        Shape9.Brush.Color   := ColorGradient(1,21,9);
        Shape10.Brush.Color   := ColorGradient(1,21,10);
        Shape11.Brush.Color   := ColorGradient(1,21,11);
        Shape12.Brush.Color   := ColorGradient(1,21,12);
        Shape13.Brush.Color   := ColorGradient(1,21,13);
        Shape14.Brush.Color   := ColorGradient(1,21,14);
        Shape15.Brush.Color   := ColorGradient(1,21,15);
        Shape16.Brush.Color   := ColorGradient(1,21,16);
        Shape17.Brush.Color   := ColorGradient(1,21,17);
        Shape18.Brush.Color   := ColorGradient(1,21,18);
        Shape19.Brush.Color   := ColorGradient(1,21,19);
        Shape20.Brush.Color   := ColorGradient(1,21,20);
        Shape21.Brush.Color   := ColorGradient(1,21,21);

        Label7.Visible := True;
        Shape7.Visible := True;
        Label8.Visible := True;
        Shape8.Visible := True;
        Label9.Visible := True;
        Shape9.Visible := True;
        Label10.Visible := True;
        Shape10.Visible := True;
        Label11.Visible := True;
        Shape11.Visible := True;
        Label12.Visible := True;
        Shape12.Visible := True;
        Label13.Visible := True;
        Shape13.Visible := True;
        Label14.Visible := True;
        Shape14.Visible := True;
        Label15.Visible := True;
        Shape15.Visible := True;
        Label16.Visible := True;
        Shape16.Visible := True;
        Label17.Visible := True;
        Shape17.Visible := True;
        Label18.Visible := True;
        Shape18.Visible := True;
        Label19.Visible := True;
        Shape19.Visible := True;
        Label20.Visible := True;
        Shape20.Visible := True;
        Label21.Visible := True;
        Shape21.Visible := True;


        Label22.Visible := False;
        Shape22.Visible := False;
        Label23.Visible := False;
        Shape23.Visible := False;
        Label24.Visible := False;
        Shape24.Visible := False;
        Label24.Visible := False;
        Shape24.Visible := False;
        Label25.Visible := False;
        Shape25.Visible := False;
        Label26.Visible := False;
        Shape26.Visible := False;
        Label27.Visible := False;
        Shape27.Visible := False;
        Label28.Visible := False;
        Shape28.Visible := False;

        Height := 571;
      End;

    ShowButtons := (not Gradient) and (not Elevation) and (not Connectivity);
    Button1.Visible := ShowButtons;
    Button2.Visible := ShowButtons;
    Button3.Visible := ShowButtons;
    Button4.Visible := ShowButtons;
    Button5.Visible := ShowButtons;
    Button6.Visible := ShowButtons;
    Button7.Visible := ShowButtons;
    Button8.Visible := ShowButtons;
    Button9.Visible := ShowButtons;
    Button10.Visible := ShowButtons;
    Button11.Visible := ShowButtons;
    Button12.Visible := ShowButtons;
    Button13.Visible := ShowButtons;
    Button14.Visible := ShowButtons;
    Button15.Visible := ShowButtons;
    Button16.Visible := ShowButtons;
    Button17.Visible := ShowButtons;
    Button18.Visible := ShowButtons;
    Button19.Visible := ShowButtons;
    Button20.Visible := ShowButtons;
    Button21.Visible := ShowButtons;
    Button22.Visible := ShowButtons;
    Button23.Visible := ShowButtons;
    Button24.Visible := ShowButtons;
    Button25.Visible := ShowButtons;
    Button26.Visible := ShowButtons;
    Button27.Visible := ShowButtons;
    Button28.Visible := ShowButtons;
    SaveButton.Visible := ShowButtons;
    LoadButton.Visible := ShowButtons;

   Update;

end;

end.
