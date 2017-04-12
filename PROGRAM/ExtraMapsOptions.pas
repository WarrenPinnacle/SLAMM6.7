unit ExtraMapsOptions;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls, SLR6;

type
  TExtraMapsForm = class(TForm)
    SalinityMapsBox: TCheckBox;
    DucksMapsBox: TCheckBox;
    Button1: TButton;
    AccretionMapsBox: TCheckBox;
    SAVMapsBox: TCheckBox;
    ConnectMapsBox: TCheckBox;
    SAVWarningLabel: TLabel;
    InundMapsBox: TCheckBox;
    RoadInundMapsBox: TCheckBox;
    RoadInundWarningLabel: TLabel;
    procedure ExtraMapsBoxClick(Sender: TObject);
    procedure UpdateScreen;
  private
    { Private declarations }
    Updating : boolean;
  public
    { Public declarations }
    ESS: TSLAMM_Simulation;
  end;

var
  ExtraMapsForm: TExtraMapsForm;



implementation

uses
Execute;

{$R *.dfm}



procedure TExtraMapsForm.ExtraMapsBoxClick(Sender: TObject);
begin
  if Updating then exit;

  ESS.SalinityMaps:= SalinityMapsBox.Checked;
  ESS.AccretionMaps:= AccretionMapsBox.Checked;
  ESS.DucksMaps := DucksMapsBox.Checked;
  ESS.SAVMaps := SAVMapsBox.Checked;
  ESS.ConnectMaps := ConnectMapsBox.Checked;
  ESS.InundMaps := InundMapsBox.Checked;
  ESS.RoadInundMaps := RoadInundMapsBox.Checked

end;

procedure TExtraMapsForm.UpdateScreen;
begin
  Updating := True;

  SalinityMapsBox.Checked := ESS.SalinityMaps;
  SalinityMapsBox.Enabled := ESS.Display_Screen_Maps;
  If SalinityMapsBox.Checked and (not ExecuteOptionForm.SaveToGIF.Checked) then ExecuteOptionForm.AutoPasteMaps.Checked:= True;

  AccretionMapsBox.Checked := ESS.AccretionMaps;
  AccretionMapsBox.Enabled := ESS.Display_Screen_Maps;
  If AccretionMapsBox.Checked and (not ExecuteOptionForm.SaveToGIF.Checked) then ExecuteOptionForm.AutoPasteMaps.Checked:= True;

  DucksMapsBox.Checked := ESS.DucksMaps;
  DucksMapsBox.Enabled := ESS.Display_Screen_Maps;
  If DucksMapsBox.Checked and (not ExecuteOptionForm.SaveToGIF.Checked) then ExecuteOptionForm.AutoPasteMaps.Checked:= True;

  SAVWarningLabel.Visible := False;
  SAVMapsBox.Enabled := True;
  SAVMapsBox.Checked := ESS.SAVMaps;
  SAVMapsBox.Enabled := ESS.Display_Screen_Maps;
  if (Trim(ESS.D2MFileN)='') then
    begin
      SAVMapsBox.Enabled := False;
      SAVMapsBox.Checked := False;
      ESS.SAVMaps := False;
      SAVWarningLabel.Visible := True;
    end;
  If SAVMapsBox.Checked and (not ExecuteOptionForm.SaveToGIF.Checked) then ExecuteOptionForm.AutoPasteMaps.Checked:= True;

  ConnectMapsBox.Checked := ESS.ConnectMaps;
  ConnectMapsBox.Enabled := ESS.Display_Screen_Maps;
  If ConnectMapsBox.Checked and (not ExecuteOptionForm.SaveToGIF.Checked) then ExecuteOptionForm.AutoPasteMaps.Checked:= True;

  InundMapsBox.Checked := ESS.InundMaps;
  InundMapsBox.Enabled := ESS.Display_Screen_Maps;
  If InundMapsBox.Checked and (not ExecuteOptionForm.SaveToGIF.Checked) then ExecuteOptionForm.AutoPasteMaps.Checked:= True;

  RoadInundWarningLabel.Visible := False;
  RoadInundMapsBox.Enabled := True;
  RoadInundMapsBox.Checked := ESS.RoadInundMaps;
  RoadInundMapsBox.Enabled := ESS.Display_Screen_Maps;

  if (ESS.NRoadInf=0) then
    begin
      RoadInundMapsBox.Enabled:= False;
      RoadInundMapsBox.Checked := False;
      ESS.RoadInundMaps := False;
      RoadInundWarningLabel.Visible := True;
    end;
  If RoadInundMapsBox.Checked and (not ExecuteOptionForm.SaveToGIF.Checked) then ExecuteOptionForm.AutoPasteMaps.Checked:= True;

  Updating := False;
end;

end.
