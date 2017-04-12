//SLAMM SOURCE CODE Copyright (c) 2009 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

program SLAMM6;

uses
  Forms,
  SysUtils,
  main in 'main.pas' {MainForm},
  DrawGrid in 'DrawGrid.pas' {GridForm},
  SLAMMLegend in 'SLAMMLegend.pas' {LegendForm},
  GISOptions in 'GISOptions.pas' {GISForm},
  global in 'global.pas',
  Profile in 'Profile.pas' {ProfileForm},
  slr6 in 'slr6.pas',
  Execute in 'Execute.pas' {ExecuteOptionForm},
  GLDraw in 'GLDraw.pas' {Delphi3DForm},
  DispMode in 'OpenGL\Framework\DispMode.pas' {DotDispModeDlg},
  FileSetup in 'FileSetup.pas' {FileSetupForm},
  SalRuleEdit in 'SalRuleEdit.pas' {SalRuleForm},
  SiteEdits in 'SiteEdits.pas' {SiteEdit},
  Elev_Analysis in 'Elev_Analysis.pas' {ElevAnalysisForm},
  FFForm in 'FFForm.pas' {SalinityForm},
  ElevHistForm in 'ElevHistForm.pas' {Elevation Histograms},
  splash in 'splash.pas' {SplashForm},
  Utility in 'Utility.pas',
  Windows,
  UncertMain in 'UncertMain.pas' {UncertForm},
  uncertdefn in 'uncertdefn.pas' {,},
  SensitivityRun in 'SensitivityRun.pas',
  distedit in 'distedit.pas' {DistributionForm},
  selectinput in 'selectinput.pas' {SelInput},
  Uncert in 'Uncert.pas',
  LatinHypercubeRun in 'LatinHypercubeRun.pas',
  legend2 in 'legend2.pas' {Legend2form},
  copyclip in 'copyclip.pas' {CopyClipbd},
  progress in 'progress.pas' {ProgForm},
  stack in 'stack.pas',
  Vcl.Themes,
  Vcl.Styles,
  Infr_Form in 'Infr_Form.pas' {InfStructFileSetup},
  SalArray in 'SalArray.pas',
  ExtraMapsOptions in 'ExtraMapsOptions.pas' {ExtraMapsForm},
  SAVParams in 'SAVParams.pas' {SAVParamForm},
  FWFlowEdits in 'FWFlowEdits.pas' {FWFlowEdit},
  RoadInundLegend in 'RoadInundLegend.pas' {RoadInundLegendForm},
  CustomSLRNew in 'CustomSLRNew.pas' {CustomSLRForm},
  NYSSLR in 'NYSSLR.pas' {NYSSLRForm},
  tcollect in 'tcollect.pas',
  Binary_Files in 'Binary_Files.pas',
  BufferTStream in 'BufferTStream.pas',
  Binary_Convert in 'Binary_Convert.pas' {Binary_Conv_Form},
  SLAMMThreads in 'SLAMMThreads.pas',
  CalcDist in 'CalcDist.pas',
  AccrGraph in 'AccrGraph.pas' {AccrGraphForm},
  Infr_Data in 'Infr_Data.pas',
  SelectListUnit in 'SelectListUnit.pas' {SelectListForm},
  Categories in 'Categories.pas',
  WindRose in 'WindRose.pas' {WindForm},
  CarbonSeq in 'CarbonSeq.pas' {CarbonSeqForm};

{$R *.RES}
{$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}           // Enable 4 gigabytes of memory in 64-bit systems
Var Timecheck: TDatetime;

// {$.define FullDebugMode}
// {$.define RawStackTraces}

begin
//  ReportMemoryLeaksOnShutdown := DebugHook <> 0;  {report mem leaks}
  Application.Initialize;
  Application.Title := 'SLAMM 6.7 beta';
  Setpriorityclass(GetCurrentProcess(), BELOW_NORMAL_PRIORITY_CLASS);  // set to lower priority
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSplashForm, SplashForm);
  Application.CreateForm(TSelInput, SelInput);
  Application.CreateForm(TElevHist, ElevHist);
  Application.CreateForm(TCopyClipbd, CopyClipbd);
  Application.CreateForm(TProgForm, ProgForm);
  Application.CreateForm(TInfStructFileSetup, InfStructFileSetup);
  Application.CreateForm(TExtraMapsForm, ExtraMapsForm);
  Application.CreateForm(TExtraMapsForm, ExtraMapsForm);
  Application.CreateForm(TSAVParamForm, SAVParamForm);
  Application.CreateForm(TFWFlowEdit, FWFlowEdit);
  Application.CreateForm(TRoadInundLegendForm, RoadInundLegendForm);
  Application.CreateForm(TCustomSLRForm, CustomSLRForm);
  Application.CreateForm(TNYSSLRForm, NYSSLRForm);
  Application.CreateForm(TBinary_Conv_Form, Binary_Conv_Form);
  Application.CreateForm(TAccrGraphForm, AccrGraphForm);
  Application.CreateForm(TSelectListForm, SelectListForm);
  Application.CreateForm(TWindForm, WindForm);
  Application.CreateForm(TCarbonSeqForm, CarbonSeqForm);
  SplashForm.VersionInfo.Visible := False;
  SplashForm.Show;
  SplashForm.Update;
  TimeCheck:=Now;

  Application.CreateForm(TFileSetupForm, FileSetupForm);
  Application.CreateForm(TFWFlowEdit, FWFlowEdit);
  Application.CreateForm(TSalRuleForm, SalRuleForm);
  Application.CreateForm(TSalinityForm, SalinityForm);
  Try
    Application.CreateForm(TDotDispModeDlg, DotDispModeDlg);
  Except
    Raise;
  End;

  Application.CreateForm(TElevAnalysisForm, ElevAnalysisForm);
  Application.CreateForm(TGridForm, GridForm);
  Application.CreateForm(TFileSetupForm, FileSetupForm);
  Application.CreateForm(TSiteEditForm, SiteEditForm);
  Application.CreateForm(TLegendForm, LegendForm);
  Application.CreateForm(TLegend2Form, Legend2Form);
  Application.CreateForm(TGISForm, GISForm);
  Application.CreateForm(TProfileForm, ProfileForm);
  Application.CreateForm(TFWFlowEdit, FWFlowEdit);
  Application.CreateForm(TSalinityForm, SalinityForm);
  Application.CreateForm(TExecuteOptionForm, ExecuteOptionForm);
  Application.CreateForm(TUncertForm, UncertForm);
  Application.CreateForm(TDistributionForm, DistributionForm);
  Application.CreateForm(TSelInput, SelInput);

  Repeat Until Now-TimeCheck>2.8e-5; {Hold splash form for a minimum of 2 seconds}
  SplashForm.Hide;

  Application.Run;

  end.


