unit NYSSLR;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, SLR6;

type
  TNYSSLRForm = class(TForm)
    NYS_GCM_Max: TCheckBox;
    NYS_1M_2100: TCheckBox;
    NYS_RIM_Min: TCheckBox;
    NYS_RIM_Max: TCheckBox;
    OKButton: TButton;
    ESVA_Hist: TCheckBox;
    ESVA_High: TCheckBox;
    ESVA_Low: TCheckBox;
    ESVA_Highest: TCheckBox;
    procedure NYSSLRClick(Sender: TObject);
    procedure UpdateScreen;
    procedure OKButtonClick(Sender: TObject);
  private
    { Private declarations }
    Updating : boolean;
    NYS_Checked: boolean;
    NYS_Checked_old: boolean;
    ESVA_Checked: boolean;
    ESVA_Checked_old: boolean;
  public
    { Public declarations }
     ESS: TSLAMM_Simulation;
  end;

var
  NYSSLRForm: TNYSSLRForm;

implementation

{$R *.dfm}

uses Execute, System.UITypes;

procedure TNYSSLRForm.UpdateScreen;
begin
  Updating := True;

  NYS_GCM_Max.Checked := ESS.Fixed_Scenarios[4];
  NYS_1M_2100.Checked := ESS.Fixed_Scenarios[5];
  NYS_RIM_Min.Checked := ESS.Fixed_Scenarios[6];
  NYS_RIM_Max.Checked := ESS.Fixed_Scenarios[7];
  NYS_Checked_Old := NYS_Checked;

  ESVA_Hist.Checked := ESS.Fixed_Scenarios[8];
  ESVA_Low.Checked := ESS.Fixed_Scenarios[9];
  ESVA_High.Checked := ESS.Fixed_Scenarios[10];
  ESVA_Highest.Checked := ESS.Fixed_Scenarios[11];
  ESVA_Checked_Old := ESVA_Checked;

  Updating := False;
end;


procedure TNYSSLRForm.OKButtonClick(Sender: TObject);
begin
 if (NYS_Checked) and (not ESVA_Checked) then
  begin
    with ExecuteOptionForm do
      begin
        RunSpecificYearsBox.Checked := True;
        SpecificYearsEdit.Text := '2025, 2040, 2055, 2070, 2085, 2100';
        SpecificYearsEdit.Hint :=  SpecificYearsEdit.Text;
        ESS.YearsString := SpecificYearsEdit.Text;
      end;
    MessageDlg( 'Default years selected: 2025, 2040, 2055, 2070, 2085, 2100. You can modify this option in the Execute Options Form',mtWarning, [mbOK], 0);
  end
 else if (not NYS_Checked) and (ESVA_Checked) then
  begin
    with ExecuteOptionForm do
      begin
        RunSpecificYearsBox.Checked := True;
        SpecificYearsEdit.Text := '2025, 2040, 2055, 2065, 2080, 2100';
        SpecificYearsEdit.Hint :=  SpecificYearsEdit.Text;
        ESS.YearsString := SpecificYearsEdit.Text;
      end;
    MessageDlg( 'Default years selected: 2025, 2040, 2055, 2065, 2080, 2100. You can modify this option in the Execute Options Form',mtWarning, [mbOK], 0);
  end;
end;

procedure TNYSSLRForm.NYSSLRClick(Sender: TObject);
var i:integer;

begin
 if Updating then exit;

 ESS.Fixed_Scenarios[4] := NYS_GCM_Max.Checked;
 ESS.Fixed_Scenarios[5] := NYS_1M_2100.Checked;
 ESS.Fixed_Scenarios[6] := NYS_RIM_Min.Checked;
 ESS.Fixed_Scenarios[7] := NYS_RIM_Max.Checked;

 ESS.Fixed_Scenarios[8] := ESVA_Hist.Checked;
 ESS.Fixed_Scenarios[9] := ESVA_Low.Checked;
 ESS.Fixed_Scenarios[10] := ESVA_High.Checked;
 ESS.Fixed_Scenarios[11] := ESVA_Highest.Checked;

 NYS_Checked := False;
 for i := 4 to 7 do
  if ESS.Fixed_Scenarios[i] then
    NYS_Checked := True;

 ESVA_Checked := False;
 for i := 8 to 11 do
  if ESS.Fixed_Scenarios[i] then
     ESVA_Checked := True;

end;

end.
