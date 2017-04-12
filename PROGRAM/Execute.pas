//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit Execute;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, SLR6, Global, Buttons, Menus, ExtraMapsOptions, NYSSLR;

type
  TExecuteOptionForm = class(TForm)
    SLRPanel: TPanel;
    Label4: TLabel;
    Panel3: TPanel;
    ProtectionPanel: TLabel;
    ProtectAllBox: TCheckBox;
    ProtectDevBox: TCheckBox;
    DontProtectBox: TCheckBox;
    Panel4: TPanel;
    RunNWI: TCheckBox;
    Panel7: TPanel;
    DikeBox: TCheckBox;
    ExecuteButton: TButton;
    SaveButton: TButton;
    Panel2: TPanel;
    Label5: TLabel;
    SaveGIS: TRadioButton;
    SaveTabular: TRadioButton;
    Panel5: TPanel;
    displaymaps: TRadioButton;
    NoMaps: TRadioButton;
    QABox: TCheckBox;
    AutoPasteMaps: TCheckBox;
    GISOptions: TButton;
    HelpButton: TBitBtn;
    ROSResize: TComboBox;
    LastYearLabel: TLabel;
    TimeStepLabel: TLabel;
    LastYearEdit: TEdit;
    TimeStepEdit: TEdit;
    SpecificYearsEdit: TEdit;
    Label2: TLabel;
    RunSpecificYearsBox: TCheckBox;
    SoilSatBox: TCheckBox;
    NoDataBlanksBox: TCheckBox;
    CancelButton: TButton;
    Panel8: TPanel;
    UncertaintySetupButton: TButton;
    UseBruunBox: TCheckBox;
    SaveToGIF: TCheckBox;
    Button1: TButton;
    RunLHCheckBox: TCheckBox;
    RunSensBox: TCheckBox;
    ExtraMapsOptButton: TButton;
    CustomButton: TButton;
    Panel1: TPanel;
    Label3: TLabel;
    UseFloodForestBox: TCheckBox;
    UseFloodDevDryLandBox: TCheckBox;
    Panel6: TPanel;
    Label8: TLabel;
    SaveAllArea: TRadioButton;
    SaveROSArea: TRadioButton;
    Panel9: TPanel;
    ConnectivityBox: TCheckBox;
    MinElevConnectBOx: TComboBox;
    EightNearConnectBox: TComboBox;
    CellSizeBox: TComboBox;
    IPCCPanel: TPanel;
    Label6: TLabel;
    Label7: TLabel;
    Label10: TLabel;
    Label1: TLabel;
    Label9: TLabel;
    A1B: TCheckBox;
    A1T: TCheckBox;
    A1F1: TCheckBox;
    A2: TCheckBox;
    B1: TCheckBox;
    B2: TCheckBox;
    Min: TCheckBox;
    Mean: TCheckBox;
    Max: TCheckBox;
    fix1: TCheckBox;
    fix15: TCheckBox;
    fix2: TCheckBox;
    CustomMeters: TCheckBox;
    CustomEdit: TEdit;
    CustomSLR: TButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    CustomSLRLabel: TLabel;
    RunRecordBox: TCheckBox;
    procedure GISOptionsClick(Sender: TObject);
    procedure A1BClick(Sender: TObject);
    procedure SaveTabularClick(Sender: TObject);
    procedure SaveAreaClick(Sender: TObject);
    procedure displaymapsClick(Sender: TObject);
    procedure TimeStepEditExit(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure ROSResizeChange(Sender: TObject);
    procedure MinElevConnectBoxChange(Sender: TObject);
    procedure EightNearConnectBoxChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpecificYearsEditChange(Sender: TObject);
    procedure SpecificYearsEditExit(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure UncertaintySetupButtonClick(Sender: TObject);
    procedure ExecuteButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure ExtraMapsOptButtonClick(Sender: TObject);
    procedure CustomButtonClick(Sender: TObject);
    procedure CellSizeBoxChange(Sender: TObject);
    procedure CustomEditExit(Sender: TObject);
    procedure CustomSLRClick(Sender: TObject);
  private
    SaveStream: TMemoryStream;
    Updating: Boolean;
    { Private declarations }
  public
    LSS: TSLAMM_Simulation;
    Function EditOptions(Var SS: TSLAMM_Simulation): Boolean;  { Public declarations }
    Procedure UpdateScreen;
  end;

var
  ExecuteOptionForm: TExecuteOptionForm;

implementation

uses GISOptions, UncertMain, System.UITypes, main, CustomSLRNew;

{$R *.dfm}

{ TExecuteOptionForm }

procedure TExecuteOptionForm.A1BClick(Sender: TObject);
begin
  If Updating then Exit;

  Min.Enabled := False;
  Max.Enabled := False;
  Mean.Enabled := False;
  if (A1B.checked) or (A1T.checked) or (A1F1.checked) or (A2.checked) or (B1.checked) or (B2.checked) then
    begin
      Min.Enabled := True;
      Max.Enabled := True;
      Mean.Enabled := True;
    end;

  LSS.IPCC_Scenarios[Scen_A1B] := A1B.checked;
  LSS.IPCC_Scenarios[Scen_A1T] := A1T.checked;
  LSS.IPCC_Scenarios[Scen_A1F1] := A1F1.checked;
  LSS.IPCC_Scenarios[Scen_A2] := A2.checked;
  LSS.IPCC_Scenarios[Scen_B1] := B1.checked;
  LSS.IPCC_Scenarios[Scen_B2] := B2.checked;
  LSS.IPCC_Estimates[Est_Min] := Min.checked;
  LSS.IPCC_Estimates[Est_Mean] := Mean.checked;
  LSS.IPCC_Estimates[Est_Max] := Max.checked;
  LSS.Fixed_Scenarios[1] := fix1.checked;
  LSS.Fixed_Scenarios[2] := fix15.checked;
  LSS.Fixed_Scenarios[3] := fix2.checked;

  // NYS SLR Scenarios - Marco
  LSS.Fixed_Scenarios[4] := NYSSLRForm.NYS_GCM_Max.checked;
  LSS.Fixed_Scenarios[5] := NYSSLRForm.NYS_1M_2100.checked;
  LSS.Fixed_Scenarios[6] := NYSSLRForm.NYS_RIM_Min.checked;
  LSS.Fixed_Scenarios[7] := NYSSLRForm.NYS_RIM_Max.checked;

   // ESVA SLR Scenarios - Marco
  LSS.Fixed_Scenarios[8] := NYSSLRForm.ESVA_Hist.checked;
  LSS.Fixed_Scenarios[9] := NYSSLRForm.ESVA_Low.checked;
  LSS.Fixed_Scenarios[10] := NYSSLRForm.ESVA_High.checked;
  LSS.Fixed_Scenarios[11] := NYSSLRForm.ESVA_Highest.checked;

  LSS.RunCustomSLR := CustomMeters.Checked;

  LSS.Prot_To_Run[ProtAll] := ProtectAllBox.checked;
  LSS.Prot_To_Run[ProtDeveloped] := ProtectDevBox.checked;
  LSS.Prot_To_Run[NoProtect] := DontProtectBox.checked;

  LSS.IncludeDikes := DikeBox.Checked;
  LSS.RunFirstYear := True; // RunNWI.Checked;
  LSS.QA_Tools := QABox.checked;
  LSS.SalinityMaps:= ExtraMapsForm.SalinityMapsBox.Checked;
  LSS.AccretionMaps:= ExtraMapsForm.AccretionMapsBox.Checked;
  LSS.DucksMaps := ExtraMapsForm.DucksMapsBox.Checked;
  LSS.SAVMaps := ExtraMapsForm.SAVMapsBox.Checked;
  LSS.ConnectMaps := ExtraMapsForm.ConnectMapsBox.Checked;
  LSS.InundMaps := ExtraMapsForm.InundMapsBox.Checked;
  LSS.RoadInundMaps := ExtraMapsForm.RoadInundMapsBox.Checked;

  //  If (Sender = PasteExtraMaps) then If LSS.ExtraMaps then AutoPasteMaps.Checked := True;

  LSS.Maps_to_MSWord     := AutoPasteMaps.Checked;
  LSS.Maps_to_GIF        := SaveToGIF.Checked;
  LSS.Complete_RunRec    := RunRecordBox.Checked;

  LSS.UseSoilSaturation  := SoilSatBox.Checked;
  LSS.LoadBlankIfNoElev  := NoDataBlanksBox.Checked;
  LSS.RunSpecificYears   := RunSpecificYearsBox.Checked;
  LSS.CheckConnectivity  := ConnectivityBox.Checked;

  LSS.UseBruun           := UseBruunBox.Checked;
  LSS.UseFloodForest     := UseFloodForestBox.Checked;
  LSS.UseFloodDevDryLand := UseFloodDevDryLandBox.Checked;
  LSS.RunUncertainty     := RunLHCheckBox.Checked;
  LSS.RunSensitivity     := RunSensBox.Checked;
  If (Sender = RunSensBox) and (RunSensBox.Checked) then LSS.RunUncertainty  := False;
  If (Sender = RunLHCheckBox) and (RunLHCheckBox.Checked) then LSS.RunSensitivity  := False;

  If Sender<>nil then
    begin
      If (TCheckBox(Sender).Name = 'RunSpecificYearsBox') or
       (TCheckBox(Sender).Name = 'RunLHCheckBox') or
       (TCheckBox(Sender).Name = 'RunSensBox') then UpdateScreen;
       CancelButton.Enabled := True;
    end;
end;

procedure TExecuteOptionForm.ExtraMapsOptButtonClick(Sender: TObject);
begin
  ExtraMapsForm.ESS := LSS;
  ExtraMapsForm.UpdateScreen;
  ExtraMapsForm.ShowModal;
end;

procedure TExecuteOptionForm.CancelButtonClick(Sender: TObject);
begin
  //If Messagedlg('Discard all Changes?',mtconfirmation,[mbyes,mbno],0) = MRyes then ModalResult := MRCancel;
  If Messagedlg('Discard all changes and return to the main menu?',mtconfirmation,[mbyes,mbno],0) = MRyes then
    ModalResult := MRCancel;
end;

procedure TExecuteOptionForm.CellSizeBoxChange(Sender: TObject);
begin
  if CellSizeBox.ItemIndex+1 <> LSS.RescaleMap then
    Begin
      LSS.RescaleMap := CellSizeBox.itemindex+1;
      {1 = 100%, 2=200% or 4 cells, 3=300% or 9 cells}
      LSS.NumMMEntries := -1;
      LSS.Connect_Arr := nil;
      LSS.Inund_Arr := nil;
      LSS.Site.ROSBounds := nil;
    End;
end;

procedure TExecuteOptionForm.CustomButtonClick(Sender: TObject);
begin
  NYSSLRForm.ESS := LSS;
  NYSSLRForm.UpdateScreen;
  NYSSLRForm.ShowModal;
end;

procedure TExecuteOptionForm.CustomEditExit(Sender: TObject);
Var EofFound: Boolean;
    i: integer;
    NewNum, Holder: String;
    CSLRValue: Double;
    TmpCSLRArray: Array[1..20] of Double;
Begin
  Holder := CustomEdit.Text;
  EofFound := False;
  LSS.N_CustomSLR := 0;
   Repeat
    NewNum:=Trim(AbbrString(Holder,','));
    if NewNum <> '' then
      Begin
        If TryStrtoFloat(NewNum, CSLRValue)=FALSE then
          MessageDlg('Warning: SLR of "'+NewNum+'" is not a number',mtWarning, [mbOK], 0)
        else
          begin
            LSS.N_CustomSLR := LSS.N_CustomSLR+1;
            TmpCSLRArray[LSS.N_CustomSLR] := CSLRValue;
          end;

        If Pos(',',Holder)= 0 then EofFound:=True
                              else Delete(Holder,1,Pos(',',Holder));
      End;
    If (Trim(Holder)='') or (Trim(NewNum)='') then EofFound := True;
   Until EofFound;

   Setlength(LSS.CustomSLRArray,LSS.N_CustomSLR);
   for i  := 0 to LSS.N_CustomSLR-1 do
     LSS.CustomSLRArray[i] := TmpCSLRArray[i+1];

   UpdateScreen;
End;

procedure TExecuteOptionForm.CustomSLRClick(Sender: TObject);
begin
  CustomSLRForm.EditCustomSLRs(LSS.TimeSerSLRs, LSS.NTimeSerSLR);
  UpdateScreen;
end;

procedure TExecuteOptionForm.displaymapsClick(Sender: TObject);
begin
  If Updating then Exit;
  LSS.Display_Screen_Maps := DisplayMaps.Checked;
  UpdateScreen;
end;

function TExecuteOptionForm.EditOptions(Var SS: TSLAMM_Simulation): Boolean;
Var MR: TModalResult;
    svFileN: String;
begin
  TSText := False;
  LSS := SS;
  SaveStream := TMemoryStream.Create;
  SS.Save(TStream(SaveStream));  {save for backup in case of cancel click}

  UpdateScreen;

  MR := ShowModal;

  SaveStream.Seek(0, soFromBeginning); {Go to beginning of stream}

  Result := True;
  If MR in [MRCancel,MRNone] then
    Begin
      svFileN := SS.FileN;
      SS.Destroy;
      SS:= TSLAMM_Simulation.Load(TStream(SaveStream));
      SS.FileN := svFileN;
      Result := False;
    End
  else SS.Changed := True;

   If MR=MRYes then
       Result := False;

  SaveStream.Free;
end;

procedure TExecuteOptionForm.ExecuteButtonClick(Sender: TObject);
var
i: IPCCScenarios;
j: IPCCEstimates;
ProtScen: ProtScenario;
k: Integer;
NSLRScenarios: integer;
NProtScenarios: integer;
RunningCustomSLR: boolean;
UncertSLR: boolean;
begin
  IterCount := 0; // 3/17/2016 debugging

  // Count the selected SLR scenarios
  NSLRScenarios := 0;
  for i := Scen_A1B to Scen_B2 do
    begin
      if LSS.IPCC_Scenarios[i] then
        begin
          for j := Est_Min to Est_Max do
            if LSS.IPCC_Estimates[j] then inc(NSLRScenarios);
        end;
    end;
  for k := 1 to 11 do           //NYS and ESVA SLR Scenarios - Marco
    if LSS.Fixed_Scenarios[k] then inc(NSLRScenarios);

  For k := 0 to LSS.NTimeSerSLR-1 do
    If TTimeSerSLR(LSS.TimeSerSLRs[k]).RunNow then Inc(NSLRScenarios);

  RunningCustomSLR:= False;
  if LSS.RunCustomSLR then
    begin
      RunningCustomSLR:= True;
      inc(NSLRScenarios);
    end;

  NProtScenarios :=0;
  for ProtScen := NoProtect to ProtAll do
    if LSS.Prot_To_Run[ProtScen] then inc(NProtScenarios);

  ModalResult:= mrNone;

  If (RunLHCheckBox.Checked) and (not LSS.SaveBinaryGIS) and (LSS.SaveGIS) then
    LSS.SaveBinaryGIS := MessageDlg('Write Compressed SLB files rather than ASC files?',mtConfirmation,[mbYes,mbNo], 0) = mrYes;

  if (NSLRScenarios>0) and (NProtScenarios>0)  then
    begin
      if (RunLHCheckBox.Checked) and ((NSLRScenarios>1) or (NProtScenarios>1)) then
        MessageDlg( 'Uncertainty runs must be set up to run one SLR scenario / Protection Scenario only.',mtWarning, [mbOK], 0)
      else if (RunSensBox.Checked) and ((NSLRScenarios>1) or (NProtScenarios>1)) then
        MessageDlg( 'Sensitivity runs must be set up to run one SLR scenario / Protection Scenario only.',mtWarning, [mbOK], 0)
      else if (RunLHCheckBox.Checked) and (NSLRScenarios=1) and (not RunningCustomSLR) then
        begin
          UncertSLR := False;
          for k:=0 to LSS.UncertSetup.NumDists-1 do
            begin
              if LSS.UncertSetup.DistArray[k].IDNum = 1 then
                begin
                  UncertSLR := True;
                  MessageDlg('You must run SLAMM under "Custom SLR" if you are selecting the "Sea Level Rise by 2100 (multiplier)" as an uncertainty distribution.',mtWarning, [mbOK], 0);
                  exit;
                end
            end;
          if not UncertSLR then ModalResult := mrOK;
        end
      else if (RunSensBox.Checked) and (NSLRScenarios=1) and (not RunningCustomSLR)  then
        begin
          UncertSLR := False;
          for k:=0 to LSS.UncertSetup.NumSens-1 do
            begin
              if LSS.UncertSetup.SensArray[k].IDNum = 1 then
                begin
                  UncertSLR := True;
                  MessageDlg('You must run SLAMM under "Custom SLR" if you are selecting the "Sea Level Rise by 2100 (multiplier)" as a sensitivity parameter.',mtWarning, [mbOK], 0);
                  exit;
                end
            end;
          if not UncertSLR then ModalResult := mrOK;
        end
      else
        ModalResult := mrOK
    end
  else
   if (NSLRScenarios = 0) and (NProtScenarios>0)  then
    MessageDlg('Warning! No SLR Scenarios to Run selected',mtWarning, [mbOK], 0)
   else if (NSLRScenarios > 0) and (NProtScenarios=0)  then
    MessageDlg('Warning! No Protection Scenarios to Run selected',mtWarning, [mbOK], 0)
   else
    MessageDlg('Warning! No SLR and Protection Scenarios to Run selected',mtWarning, [mbOK], 0);

  // Calculate total number of time steps
  if LSS.RunSpecificYears then
    LSS.NTimeSteps := 3 + CharOccurs(LSS.YearsString,',')     //TimeIter = InitCond + T0 + 1 + number of commas in comma delimited string
  else
    LSS.NTimeSteps := 1 + ((LSS.MaxYear-LSS.Site.T0) Div LSS.TimeStep)+ 1;    // initCond + T0 + other steps

  // Pass the total number of scenarios to SLAMM_Simulation
  //LSS.CountProj := TimeIter; //NSLRScenarios*TimeIter;
  //if NProtScenarios > 0 then
  //  LSS.CountProj := LSS.CountProj*NProtScenarios;
  //LSS.CountProj:= LSS.CountProj - 1;

end;

procedure TExecuteOptionForm.FormShow(Sender: TObject);
begin
  ROSResizeChange(nil);
end;

procedure TExecuteOptionForm.GISOptionsClick(Sender: TObject);
begin
  GISForm.ShowModal;
  LSS.SaveElevsGIS := GISForm.SaveElevationsBox.Checked;
  LSS.SaveElevGISMTL := GISForm.BElevMTL.Checked;
  LSS.SaveSalinityGIS := GISForm.SaveSalinity.Checked;
  LSS.SaveInundGIS := GISForm.SaveInund.Checked;

  LSS.SaveBinaryGIS := GISForm.SaveBinary.Checked;
end;

procedure TExecuteOptionForm.HelpButtonClick(Sender: TObject);
begin
    Application.HelpContext( 1005);  //'Execution.html');
end;



procedure TExecuteOptionForm.ROSResizeChange(Sender: TObject);
begin
  LSS.ROS_Resize:= ROSResize.itemindex+1;

{1: 0.25 x Output
2: 0.50 x Output
3: 1x Output
4: 2x Output
5: 3x Output
6: 4x Output}

end;

procedure TExecuteOptionForm.MinElevConnectBoxChange(Sender: TObject);
begin
  LSS.ConnectMinElev := MinElevConnectBox.Itemindex;

{0: Average elevation
1: Min Elevation
}
end;

procedure TExecuteOptionForm.EightNearConnectBoxChange(Sender: TObject);
begin
  LSS.ConnectNearEight := EightNearConnectBox.Itemindex;

{0: 4 nearest neighbors
1: 8 nearest neighbors
}
end;


procedure TExecuteOptionForm.SaveButtonClick(Sender: TObject);
begin
MainForm.SaveSimClick(Sender);
CancelButton.Enabled := False;
end;

procedure TExecuteOptionForm.SaveTabularClick(Sender: TObject);
begin
   If Updating then Exit;
   LSS.SaveGIS := SaveGIS.Checked;

end;

procedure TExecuteOptionForm.SaveAreaClick(Sender: TObject);
begin
   If Updating then Exit;
   LSS.SaveROSArea := SaveROSArea.Checked;

end;


procedure TExecuteOptionForm.SpecificYearsEditChange(Sender: TObject);
begin
  SpecificYearsEdit.Hint :=SpecificYearsEdit.Text;
end;

procedure TExecuteOptionForm.SpecificYearsEditExit(Sender: TObject);
begin
  LSS.YearsString := SpecificYearsEdit.Text;
end;

procedure TExecuteOptionForm.TimeStepEditExit(Sender: TObject);
Var
Conv: Double;
Result: Integer;

begin
    Val(Trim(TEdit(Sender).Text),Conv,Result);
    If Result<>0 then MessageDlg('Incorrect Numerical Format Entered',mterror,[mbOK],0)
                 else begin
                         case TEdit(Sender).Name[1] of
                            'T': LSS.TimeStep := Trunc(Conv);
                            'L': If (Conv <= 2100) and (Conv >1900) then LSS.MaxYear := Trunc(Conv);
//                            'C': LSS.CustomSLR := Conv;
                          end; {case}
                      end; {else}
    UpdateScreen;
end; 


procedure TExecuteOptionForm.UncertaintySetupButtonClick(Sender: TObject);
begin
  UncertForm.SensMode := RunSensBox.Checked;
  Uncertform.EditUncertSetup(LSS);

end;

procedure TExecuteOptionForm.UpdateScreen;
var
  CountTSSLR, i: integer;
  str1, str2: string;
begin
    Updating := True;
    A1B.checked := LSS.IPCC_Scenarios[Scen_A1B];
    A1T.checked := LSS.IPCC_Scenarios[Scen_A1T];
    A1F1.checked := LSS.IPCC_Scenarios[Scen_A1F1];
    A2.checked := LSS.IPCC_Scenarios[Scen_A2];
    B1.checked := LSS.IPCC_Scenarios[Scen_B1];
    B2.checked := LSS.IPCC_Scenarios[Scen_B2];
    Min.checked := LSS.IPCC_Estimates[Est_Min];
    Mean.checked := LSS.IPCC_Estimates[Est_Mean];
    Max.checked := LSS.IPCC_Estimates[Est_Max];
    fix1.checked := LSS.Fixed_Scenarios[1];
    fix15.checked := LSS.Fixed_Scenarios[2];
    fix2.checked := LSS.Fixed_Scenarios[3];


    ProtectAllBox.checked := LSS.Prot_To_Run[ProtAll];
    ProtectDevBox.checked := LSS.Prot_To_Run[ProtDeveloped];
    DontProtectBox.checked := LSS.Prot_To_Run[NoProtect];
    CustomMeters.Checked := LSS.RunCustomSLR;

    //CustomEdit.Text
    str1 :='';
    for i := 1 to LSS.N_CustomSLR do
      begin
        str2 := FloattoStr(LSS.CustomSLRArray[LSS.N_CustomSLR-i]);
        if (LSS.N_CustomSLR>1) and (i<LSS.N_CustomSLR) then str2 := ', '+str2 ;
        insert(str2,str1,0);
      end;
     CustomEdit.Text :=str1;

    RosResize.ItemIndex := LSS.ROS_Resize-1;
    CellSizeBox.ItemIndex := LSS.RescaleMap-1;
    DikeBox.Checked := LSS.IncludeDikes;

    SoilSatBox.Checked := LSS.UseSoilSaturation;
    NoDataBlanksBox.Checked := LSS.LoadBlankIfNoElev;
    RunSpecificYearsBox.Checked := LSS.RunSpecificYears;
    ConnectivityBox.Checked := LSS.CheckConnectivity;
    MinElevConnectBox.ItemIndex := LSS.ConnectMinElev;
    EightNearConnectBox.ItemIndex := LSS.ConnectNearEight;

    UseBruunBox.Checked := LSS.UseBruun;
    UseFloodForestBox.Checked := LSS.UseFloodForest;
    UseFloodDevDryLandBox.Checked := LSS.UseFloodDevDryLand;

    RunLHCheckBox.Checked  := LSS.RunUncertainty;
    RunSensBox.CHecked     := LSS.RunSensitivity;

    RunNWI.Checked := True;  //LSS.RunFirstYear;

    ROSResize.Visible := (LSS.ROSFileN <> '') or (LSS.Site.NOutputSites>0) ;

    SaveTabular.Checked := Not LSS.SaveGIS;
    SaveGIS.Checked := LSS.SaveGIS;
    GISForm.SaveElevationsBox.Checked := LSS.SaveElevsGIS;
    GISForm.BElevMTL.Checked := LSS.SaveElevGISMTL;
    GISForm.BElevNAVD88.Checked := not LSS.SaveElevGISMTL;

    GISForm.SaveSalinity.Checked := LSS.SaveSalinityGIS;
    GISForm.SaveInund.Checked := LSS.SaveInundGIS;

    GISForm.SaveBinary.Checked := LSS.SaveBinaryGIS;

    SaveAllArea.Checked := Not LSS.SaveROSArea;
    SaveROSArea.Checked := LSS.SaveROSArea;

    DisplayMaps.Checked := LSS.Display_Screen_Maps;
    QABox.Enabled := LSS.Display_Screen_Maps;
    QABox.Checked := LSS.QA_Tools;

    AutoPasteMaps.Checked := LSS.Maps_to_MSWord;
    AutoPasteMaps.Enabled := LSS.Display_Screen_Maps;

    SaveToGIF.Checked := LSS.Maps_to_GIF;
    RunRecordBox.Checked := LSS.Complete_RunRec;

    SaveToGIF.Enabled := LSS.Display_Screen_Maps;

    ExtraMapsOptButton.Enabled := LSS.Display_Screen_Maps;

    NoMaps.Checked := not LSS.Display_Screen_Maps;

    TimeStepEdit.Text := IntToStr(LSS.TimeStep);
    LastYearEdit.Text := IntToStr(LSS.MaxYear);
    SpecificYearsEdit.Text := LSS.YearsString;

    Updating := False;

    SpecificYearsEdit.Enabled := LSS.RunSpecificYears;
    TimeStepLabel.Enabled := not LSS.RunSpecificYears;
    TimeStepEdit.Enabled := not LSS.RunSpecificYears;
    LastYearLabel.Enabled := not LSS.RunSpecificYears;
    LastYearEdit.Enabled := not LSS.RunSpecificYears;

    If RunLHCheckBox.Checked then ExecuteButton.Caption := 'Run &Uncertainty' else
       If RunSensBox.Checked then ExecuteButton.Caption := 'Run &Sensitivity'
                             else ExecuteButton.Caption := '&Execute';

    CountTSSLR := 0;
    For i := 0 to LSS.NTimeSerSLR-1 do
      If TTimeSerSLR(LSS.TimeSerSLRs[i]).RunNow then Inc(CountTSSLR);
    If CountTSSLR = 0 then CustomSLRLabel.Caption := '(none selected to run)'
                      else CustomSLRLabel.Caption := '('+IntToStr(CountTSSLR)+' selected to run)'


end;




end.
