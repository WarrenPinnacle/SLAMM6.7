//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit Profile;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, VCLTee.TeeProcs, VCLTee.TeEngine, Global, StdCtrls, VCLTee.Series, Utility,
  Buttons, VCLTee.Chart;

type
  TProfileForm = class(TForm)
    Chart1: TChart;
    ShowMins: TRadioButton;
    HelpButton: TBitBtn;
    procedure AspectButtonClick(Sender: TObject);
    procedure ShowBothClick(Sender: TObject);
    procedure Chart1ClickSeries(Sender: TCustomChart; Series: TChartSeries;
      ValueIndex: Integer; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure HelpButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    MinProfile: Array of Double;  {min elevations, placed on front edge of cell}
    ReverseAspect : Boolean;
    ColorProfile: Array of TColor;
    Scale: Double;
    Procedure DrawProfile;
    { Public declarations }
  end;

var
  ProfileForm: TProfileForm;

implementation

{$R *.DFM}


procedure TProfileForm.Chart1ClickSeries(Sender: TCustomChart;
  Series: TChartSeries; ValueIndex: Integer; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   ShowMessage(Floattostrf(Series.YValue[valueindex],ffGeneral,5,2)
                            +'m above MTL')

  {}
end;

Procedure TProfileForm.DrawProfile;
Var  ProfileSeries: TPointSeries;
     ProfileSeries2: TLineSeries;
     i: Integer;
     XLoc: Double;
Begin
  Screen.Cursor := crHourGlass;

  While Chart1.SeriesCount>0 do Chart1.Series[0].Free;

  with Chart1 do
    Begin
    ProfileSeries := TPointSeries.Create(Chart1);
    ProfileSeries2 := TLineSeries.Create(Chart1);
    Chart1.Legend.Visible := False;
    Chart1.LeftAxis.AutomaticMaximum := True;
    Chart1.LeftAxis.AutomaticMinimum := True;
    Chart1.BottomAxis.AutomaticMaximum := True;
    Chart1.BottomAxis.AutomaticMinimum := True;


    ProfileSeries2.Pointer.Brush.Color := clNavy;
    ProfileSeries.pen.width := 2;
    ProfileSeries.pen.style := psdot;
    ProfileSeries.Title := 'Depths';
    //ProfileSeries.pointer.style := psdot;
    ProfileSeries2.pointer.style := pssmalldot;


    XLoc := -Scale;
    For i:=0 to Length(MinProfile)-1 do
        Begin
          if MinProfile[i] = 999 then                       // ECL 11/11/2009
             MinProfile[i] := 0;
          XLoc := XLoc + Scale;
          ProfileSeries2.AddXY(XLoc,MinProfile[i],'',ClNavy);
          ProfileSeries.linepen.Color:= ColorProfile[i];
          ProfileSeries.AddXY(XLoc,MinProfile[i],'',ColorProfile[i]);

          //ProfileSeries2.linepen.Color:= ColorProfile[i];

        End;
    AddSeries(ProfileSeries);
    AddSeries(ProfileSeries2);
  End;

  Screen.Cursor := crDefault;
End;

procedure TProfileForm.HelpButtonClick(Sender: TObject);
begin
    Application.HelpContext(1004);  //'ProfileTool.html');
end;

procedure TProfileForm.AspectButtonClick(Sender: TObject);
begin
  ReverseAspect := Not ReverseAspect;
  DrawProfile;
end;

procedure TProfileForm.ShowBothClick(Sender: TObject);
begin
  DrawProfile;
end;

end.
