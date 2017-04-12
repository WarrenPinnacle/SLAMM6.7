unit DistEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, OleCtrls, StdCtrls, Buttons,
  CalcDist, DB, VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart, UncertDefn;

type
  TDistributionForm = class(TForm)
    Label2: TLabel;
    TriButton: TRadioButton;
    UniButton: TRadioButton;
    panel2: TPanel;
    NormButton: TRadioButton;
    LogNormButton: TRadioButton;
    Panel3: TPanel;
    ProbButton: TRadioButton;
    CumuButton: TRadioButton;
    Panel4: TPanel;
    Label3: TLabel;
    p1label: TLabel;
    p2label: TLabel;
    p3label: TLabel;
    Parm1Edit: TEdit;
    Parm2Edit: TEdit;
    Parm3Edit: TEdit;
    p4label: TLabel;
    Parm4Edit: TEdit;
    ErrorPanel: TPanel;
    zz: TPanel;
    Label5: TLabel;
    Label4: TLabel;
    Chart1: TChart;
    Series1: TAreaSeries;
    CancelBtn: TButton;
    OKBtn: TButton;
    NameUnits: TEdit;
    Label1: TLabel;
    PointEstimateLabel: TLabel;
    PointEst: TLabel;
    Button1: TButton;
    Button2: TButton;
    unitx: TLabel;
    UnitXEdit: TEdit;
    Memo1: TMemo;
    Button3: TButton;
    YLabel: TLabel;
    UnitYEdit: TEdit;
    ElevUncertButton: TRadioButton;
    OpenDialog1: TOpenDialog;
    IsMultLabel: TLabel;
    IterLabel: TLabel;
    ElevLegendPanel: TPanel;
    Label8: TLabel;
    ElevMin: TLabel;
    ElevMax: TLabel;
    ImagePanel: TPanel;
    Image1: TImage;
    ErrorLabel: TLabel;
    NotMultLabel: TLabel;
    SubsiteBox: TComboBox;
    procedure VerifyNumber(Sender: TObject);
    procedure RetHandleClick(Sender: TObject);
    procedure Parm4EditKeyPress(Sender: TObject; var Key: Char);
    procedure TriButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ProbButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NameUnitsChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UserFileButtClick(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Button3Click(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure SubsiteBoxExit(Sender: TObject);
    procedure Chart1ClickSeries(Sender: TCustomChart; Series: TChartSeries;
      ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
  private
    procedure updatescreen;
    { Private declarations }
  public
    PNumDists: PInteger;
    PDistArr: PDistArray;
    TheDist: TInputDist;
    Changed: Boolean;
    LastParm1,LastParm2: Double;
    Interval: Double;
    ZMap     : Integer;  //index of z uncert map
    Function EditTheDist(Var InDist: TInputDist; TSS: Pointer): Boolean;
    Procedure DrawElevUncert;

    { Public declarations }
  end;

var
  DistributionForm: TDistributionForm;
  TempDist: TInputDist;

implementation

uses selectinput, SLR6, SLAMMLegend, System.UITypes;

{$R *.DFM}

Function TDistributionForm.EditTheDist(Var InDist: TInputDist; TSS: Pointer): Boolean;
Var Distholder: TInputDist;
    PSS: TSLAMM_Simulation;

Begin
  TheDist := InDist;
  If InDist.DistType = ElevMap then
  ZMap := InDist.ZMapIndex;

  EditTheDist := False;
  PSS := TSS;

{COPY TO TEMP}
  With InDist do
    TempDist := TInputDist.Create(IDNum,TSS,AllSubsites,SubSiteNum);

  With TempDist do
    Begin
      DName := InDist.DName;
      DistType := InDist.DistType;
      Parm := InDist.Parm;
      DisplayCDF := InDist.DisplayCDF;

//      UserFileN := InDist.UserFileN;
    End;

{SHOW SCREEN}
  UpdateScreen;
  If ShowModal = MRCancel then
    Begin
      PSS.UncertSetup.ZUncertMap[ZMap] := nil;
      TempDist.Destroy;
      Exit;
    End;

  {COPY FROM TEMP}
  DistHolder := InDist;
  InDist := TempDist;
  DistHolder.Destroy;
  EditTheDist := True;
  PSS.UncertSetup.ZUncertMap[ZMap] := nil;
End;

procedure TDistributionForm.UpdateScreen;
Var Loop: Integer;
    GV, LastVal,TempVal,Val : Double;
    Xmin,Xmax,XVal: Double;
{   Big: Double; }
    NumValues: Integer;
    GraphError: Boolean;
    NewSeries: TChartSeries;
//    UserDist : TUserDist;


Begin
 With TempDist do
  begin
//    UserFileButt.Visible := DistType = USER;
//    UserFileLabel.Visible := DistType = USER;
//    If DistType = User then UserFileLabel.Caption := USERFILEN;

    SubsiteBox.Enabled := IsSubsiteParameter  {(IDNum in [1,2,5])}  ;  // SLR always pertains to all subsites, elevation maps do for now  globaluncertlogic
    if AllSubSites then SubsiteBox.ItemIndex := 0
                   else SubsiteBox.ItemIndex := SubSiteNum+1;

    NameUnits.Text:=DName;
    Case DistType of
      Triangular: begin
                    TriButton.Checked:=True;
                    P1Label.Caption:='Most Likely';
                    P2Label.Caption:='Minimum';
                    P3Label.Caption:='Maximum';
                    P4Label.Caption:='<unused>';
                  end;
      Normal    : begin
                    NormButton.Checked:=True;
                    P1Label.Caption:='Mean';
                    P2Label.Caption:='Std. Deviation';
                    P3Label.Caption:='<unused>';
                    P4Label.Caption:='<unused>';
                  end;
      LogNormal : begin
                    LogNormButton.Checked:=True;
                    P1Label.Caption:='Mean';
                    P2Label.Caption:='Std. Deviation';
                    P3Label.Caption:='<unused>';
                    P4Label.Caption:='<unused>';
                  end;
      Uniform   : begin
                    UniButton.Checked:=True;
                    P1Label.Caption:='Minimum';
                    P2Label.Caption:='Maximum';
                    P3Label.Caption:='<unused>';
                    P4Label.Caption:='<unused>';
                  end;
       ElevMap : begin
                    ElevUncertButton.Checked := True;
                    P1Label.Caption:='R.M.S.E.';
                    P2Label.Caption:='Spatial A.C.';
                    P3Label.Caption:='<unused>';
                    P4Label.Caption:='<unused>';
                   end;

    End;

    P1Label.Visible:=True;
    Parm1Edit.Visible:=True;
    P2Label.Visible:=True;
    Parm2Edit.Visible:=True;
    P3Label.Visible:=True;
    Parm3Edit.Visible:=True;
    P4Label.Visible:=True;
    Parm4Edit.Visible:=True;

    If not (DistType=Triangular) then
                  begin
                    P3Label.Visible:=False;
                    Parm3Edit.Visible:=False;
                  end
             else begin
                    P3Label.Visible:=True;
                    Parm3Edit.Visible:=True;
                  end;

    P4Label.Visible:=False;
    Parm4Edit.Visible:=False;

    TriButton.Enabled := DistType <> ElevMap;
    UniButton.Enabled := DistType <> ElevMap;
    NormButton.Enabled := DistType <> ElevMap;
    LogNormButton.Enabled := DistType <> ElevMap;

    ElevUncertButton.Enabled := DistType = ElevMap;
    ElevLegendPanel.Visible := DistType=ElevMap;

    If DistType=ElevMap then
      Begin
        P3Label.Visible:=False;
        Parm3Edit.Visible:=False;
        P4Label.Visible:=False;
        Parm4Edit.Visible:=False;
      End;


(*    If DistType=USER then
      Begin
        P1Label.Visible:=False;
        Parm1Edit.Visible:=False;
        P2Label.Visible:=False;
        Parm2Edit.Visible:=False;
        P3Label.Visible:=False;
        Parm3Edit.Visible:=False;
        P4Label.Visible:=False;
        Parm4Edit.Visible:=False;
      End;  *)

     begin
       Panel2.Enabled := true;
       Panel2.Color := clBtnFace;
       Panel3.Enabled := true;
       Panel3.Color := clBtnFace;
       Panel4.Enabled := true;
       Panel4.Color := clBtnFace;
       Chart1.Color := clWhite;
     end;

    CumuButton.Checked:=DisplayCDF;

    Parm1Edit.Text:=' '+FloatToStrF(Parm[1],ffGeneral,15,4);
    Parm2Edit.Text:=' '+FloatToStrF(Parm[2],ffGeneral,15,4);
    Parm3Edit.Text:=' '+FloatToStrF(Parm[3],ffGeneral,15,4);
    Parm4Edit.Text:=' '+FloatToStrF(Parm[4],ffGeneral,15,4);

  TRY
    Xmin:=0; XMax:=1;

  If DistType = ElevMap
   then DrawElevUncert
   Else
    Begin
       IterLabel.Visible := False;
       ImagePanel.Visible := False;
       PointEstimateLabel.Visible := True;
       PointEst.Visible := True;
       IsMultLabel.Visible := True;
       NotMultLabel.Visible := False;
         ErrorLabel.Visible := False;


       With Chart1 do
        begin
          BringToFront;
          NumValues:=100;

          While Chart1.SeriesCount>0 do Chart1.Series[0].Free;

          Case DistType of
            Triangular:
                    begin
                      XMin:=Parm[2];
                      XMax:=Parm[3];
                    end;
            Uniform:
                    begin
                      XMin:=Parm[1];
                      XMax:=Parm[2];
                    end;
            Normal,LogNormal:
                    begin
                      XMin:=icdf(0.01);
                      XMax:=icdf(0.99);
                    end;
           end; {case}

          If (XMin < 0) {and (DistNum > 1)} then XMin:=0;

          Interval := (XMax-XMin)/NumValues;
          XVal:=(((XMax-XMin)/NumValues)*-1)+XMin;
          If XVal<0 then XVal := 1e-10;

          LastVal:=0;
          Case Disttype of
               Normal,LogNormal: LastVal:=Trunccdf(XVal);
          End; {Case}
          If not DisplayCDF then LastVal:=LastVal*100;

          If LastVal=Error_Value then LastVal:=0;
    {     Big:=0; }

          NewSeries := TAreaSeries.Create(Chart1);
          NewSeries.SeriesColor := ClNavy;

          GraphError:=False;
          For Loop:=0 to NumValues do
            begin
              XVal:=(((XMax-XMin)/NumValues)*loop)+XMin;

              Val := TruncCDF(XVal);

              If not DisplayCDF then Val:=Val*100;
              TempVal:=Val;
              If (Not (Val=Error_value)) and (not DisplayCDF) then Val:=Val-LastVal;
              LastVal:=TempVal;

             // If not DisplayCDF then Val:=Val/(((XMax-XMin)/NumValues));

              If Val=error_value
                then GraphError:=True
                else If (DistType=Uniform) and (not DisplayCDF)
                   then NewSeries.AddXY(XVal,1/NumValues*100,'',clteecolor)
                   else NewSeries.AddXY(XVal,Val,'',clteecolor);

            end;

       ErrorPanel.Visible:=GraphError;
       If GraphError then ErrorPanel.BringToFront else ImagePanel.BringToFront;
       Chart1.LeftAxis.LabelStyle := talValue;

       Title.Text.Clear;

       AddSeries(NewSeries);

      End; {With Chart1}

   End; {Draw Chart not elev map}

   Memo1.Lines.Clear;

  If DistType = ElevMap then Memo1.Lines.Add(NameUnits.Text)
                        else Memo1.Lines.Add(NameUnits.Text + ':  '+
                            'Point Estimate ='+FloatToStrF(GetValue,ffGeneral,15,4)+';');

   Memo1.Lines.Add(SummarizeDist);

   GV := GetValue;
    If DistType = ElevMap
      then PointEst.Caption := FloatToStrF(GV,ffGeneral,15,4)
      else PointEst.Caption := FloatToStrF(GV,ffGeneral,15,4) + '  [' +
             FloatToStrF(GV*TruncICDF(0.025),ffGeneral,4,2) + ' .. '+
             FloatToStrF(GV*TruncICDF(0.975),ffGeneral,4,2) +']';

   Memo1.Perform(EM_LINESCROLL, 0, -1);

  EXCEPT
   ErrorPanel.Visible:=True;
   ErrorPanel.BringToFront;
  End;

//  If UserDist <> nil then UserDist.Free;
  End;{with TempDist^}
  update;
End;


procedure TDistributionForm.VerifyNumber(Sender: TObject);
{ Convert Text Edit into Number, raise error if wrong number,
  assign number to correct variable and update screen}
Var
Conv: Double;
Result: Integer;

begin
    If Lowercase(Trim(TEdit(Sender).Text)) = 'auto' then exit;
    Val(Trim(TEdit(Sender).Text),Conv,Result);
    If Result<>0 then MessageDlg('Incorrect Numerical Format Entered',mterror,[mbOK],0)
                 else begin
                        case TEdit(Sender).Name[5] of
                           '1': TempDist.Parm[1]:=Conv;
                           '2': TempDist.Parm[2]:=Conv;
                           '3': TempDist.Parm[3]:=Conv;
                           '4': TempDist.Parm[4]:=Conv;
                           'X': Chart1.BottomAxis.Increment := Abs(conv);
                           'Y': Chart1.LeftAxis.Increment := Abs(conv);
                         end; {case}
                         Changed:=True;
                       end;
    UpdateScreen;
end;

procedure TDistributionForm.RetHandleClick(Sender: TObject);
begin
  UpdateScreen;
end;

procedure TDistributionForm.SubsiteBoxExit(Sender: TObject);
begin
  TempDist.AllSubSites := (SubSiteBox.ItemIndex = 0);
  TempDist.SubSiteNum  := SubSiteBox.ItemIndex - 1;
  UpdateScreen;
end;

procedure TDistributionForm.Parm4EditKeyPress(Sender: TObject;
  var Key: Char);
begin
   If (Key=#13) then VerifyNumber(sender);
end;

procedure TDistributionForm.ProbButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Changed:=True;
  If ProbButton.Checked then TempDist.DisplayCDF:=False
                        else TempDist.DisplayCDF:=True;
  UpdateScreen;
end;

procedure TDistributionForm.TriButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Changed:=True;
  With TempDist do
    If      TriButton.Checked  then DistType:=Triangular
    else if NormButton.Checked then DistType:=Normal
    else if UniButton.Checked  then DistType:=Uniform
    else if LogNormButton.Checked then DistType := LogNormal
         else                       DistType:=ElevMap;
  UpdateScreen;
end;

procedure TDistributionForm.NameUnitsChange(Sender: TObject);
begin
  TempDist.DName := NameUnits.Text;
end;

procedure TDistributionForm.OKBtnClick(Sender: TObject);
begin
  OKBtn.SetFocus;
end;

procedure TDistributionForm.Button1Click(Sender: TObject);
begin
  Chart1.CopyToClipboardMetafile(True);
end;

procedure TDistributionForm.Button2Click(Sender: TObject);
begin
  UpdateScreen;
end;

procedure TDistributionForm.Button3Click(Sender: TObject);
begin
  LastParm1 := -99; LastParm2 := -99;
  UpdateScreen;
end;

procedure TDistributionForm.Chart1ClickSeries(Sender: TCustomChart;
  Series: TChartSeries; ValueIndex: Integer; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If TempDist.DisplayCDF
    then ShowMessage(Floattostrf(100*Series.YValue[valueindex],ffGeneral,3,1)
                               +'% , '+ Floattostrf(Series.XValue[valueindex],ffGeneral,4,2))
    else ShowMessage('Probability a draw is within '+Floattostrf(Interval/2,ffGeneral,4,2)+' of '+Floattostrf(Series.XValue[valueindex],ffGeneral,5,2)+': '+
                      Floattostrf(Series.YValue[valueindex],ffGeneral,3,1) +'%.'  );

end;

procedure TDistributionForm.DrawElevUncert;
Var PSS: TSLAMM_Simulation;
    row,col: Integer;
    TC: TColor;
begin
  ImagePanel.Visible := True;
  ImagePanel.BringToFront;

  If (TempDist.Parm[1] = LastParm1) and
     (TempDist.Parm[2] = LastParm2) then exit;   // avoid excessive calculation if nothing has changed

  LastParm1 := TempDist.Parm[1];
  LastParm2 := TempDist.Parm[2];

  PSS := TempDist.TSS;

  PointEstimateLabel.Visible := False;
  PointEst.Visible := False;
  IsMultLabel.Visible := False;
  NotMultLabel.Visible := True;

  With TempDist do
   If (Parm[2] < 0) or (Parm[2]>0.249999) then
    Begin
      ErrorPanel.Visible:=True;
      ErrorPanel.BringToFront;
      Label5.Caption := 'Spatial Autocorrelation must be zero or greater and less than 0.25';
      Exit;
    End;

  ErrorPanel.Visible:=False;

  Screen.Cursor := crHourglass;
  PSS.UncertSetup.MakeUncertMap(ZMap,Image1.Height,Image1.Width,TempDist.Parm[1],TempDist.Parm[2]);

  IterLabel.Visible := True;
  IterLabel.Caption := 'Iterations to Make Map: '+IntToStr(PSS.UncertSetup.NMapIter);

  Image1.Picture.Bitmap.PixelFormat := pf24bit;
  ImagePanel.Visible := True;
  Image1.Picture.Bitmap.Height:=Image1.Height;
  Image1.Picture.Bitmap.Width:=Image1.Width;
  Image1.Canvas.Pen.Style := PSSolid;
  ImagePanel.BringToFront;

  With TempDist do
    Begin
      ElevMin.Caption := 'Min (blue) = '+FloatToStrF(-Parm[1]*1.5,ffGeneral,4,4);
      ElevMax.Caption := 'Max (red) = '+FloatToStrF(Parm[1]*1.5,ffGeneral,4,4);
    End;

  With TempDist do
  For col := 0 to Image1.Width-1 do
   For row := 0 to Image1.Height-1 do
    Begin
      TC := ColorGradient(-Parm[1]*1.5,Parm[1]*1.5,PSS.UncertSetup.ZUncertMap[ZMap][Image1.Width*(row)+(col)]);
      Image1.Canvas.Pixels[col+1,row+1] := TC;
    End;

  Screen.Cursor := crDefault;

end;

procedure TDistributionForm.FormCreate(Sender: TObject);
begin
  LastParm1 := -99; LastParm2 := -99;
  Chart1.LeftAxis.Increment := 0.1;
  ZMap := 1;
end;

procedure TDistributionForm.Image1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
Var ErrEst: Double;
    PSS: TSLAMM_Simulation;
begin
  PSS := TempDist.TSS;
  If Length(PSS.UncertSetup.ZUncertMap[ZMap]) > Image1.Width*(y-1)+(x-1) then
    ErrEst := PSS.UncertSetup.ZUncertMap[ZMap][Image1.Width*(y-1)+(x-1)] else ErrEst := -9999;
  ErrorLabel.Visible := (ErrEst > -9998.9);
  ErrorLabel.Caption := 'Vertical Error Est. at '+FloatToStrF(ErrEst,ffGeneral,4,4) + 'm'
end;

procedure TDistributionForm.UserFileButtClick(Sender: TObject);
begin
  OpenDialog1.Title:='Select Input File in which parameter is located';
  If not OpenDialog1.Execute then exit;
//  TempDist.UserFileN := OpenDialog1.FileName;
  UpdateScreen;
end;

end.
