//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, SLR6, StdCtrls, ExtCtrls, Global, ComCtrls, Variants, GIFImg, Menus,
  Buttons;

type
  TMainForm = class(TForm)
    ExecuteButton: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SimNameEdit: TEdit;
    Panel1: TPanel;
    Label2: TLabel;
    DescripEdit: TEdit;
    Panel6: TPanel;
    Label9: TLabel;
    SalinityButton: TButton;
    ZoomBox: TComboBox;
    Label11: TLabel;
    LoadSimulation: TButton;
    SaveSim: TButton;
    SaveAs: TButton;
    NewButton: TButton;
    FileSetup: TButton;
    Label1: TLabel;
    SetMap: TButton;
    SiteParms: TButton;
    Panel2: TPanel;
    Image1: TImage;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Close1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    Exit1: TMenuItem;
    N12: TMenuItem;
    RF1: TMenuItem;
    RF2: TMenuItem;
    RF3: TMenuItem;
    RF4: TMenuItem;
    RF5: TMenuItem;
    Help1: TMenuItem;
    Contents1: TMenuItem;
    N8: TMenuItem;
    About1: TMenuItem;
    RF6: TMenuItem;
    RF7: TMenuItem;
    RF8: TMenuItem;
    RF9: TMenuItem;
    N1: TMenuItem;
    SalAnalysis: TButton;
    HelpButton: TBitBtn;
    ElevationButton: TButton;
    ModifiedLabel: TLabel;
    LargeRasterButton: TButton;
    CarbonSeq: TButton;
    procedure ExecuteButtonClick(Sender: TObject);
    procedure SetMapClick(Sender: TObject);
    procedure SalinityButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LoadSimulationClick(Sender: TObject);
    procedure SaveAsClick(Sender: TObject);
    procedure SaveSimClick(Sender: TObject);
    procedure NewButtonClick(Sender: TObject);
    procedure SimNameEditChange(Sender: TObject);
    procedure DescripEditChange(Sender: TObject);
    procedure ZoomBoxChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FileSetupClick(Sender: TObject);
    procedure SiteParmsClick(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure RecentlyUsedClick(Sender: TObject);
    procedure SalAnalysisClick(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SaveDialog1TypeChange(Sender: TObject);
    procedure Contents1Click(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure ElevationButtonClick(Sender: TObject);
    procedure LargeRasterButtonClick(Sender: TObject);
    procedure CarbonSeqClick(Sender: TObject);
  private
     SaveCancel: Boolean;
     Procedure UpdateRecentlyUsed;
     Procedure WriteIniFileData;
     Procedure ReadIniFileData;
    { Private declarations }
  public
    SS: TSLAMM_Simulation;
    incomingfile: String;
    Function Check_Save_and_Cancel(ActionGerund: String): Boolean;
    Procedure UpdateScreen;
    Procedure AcceptFiles(Var msg:TMessage); message WM_Dropfiles;
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  IniMax      : Boolean;
  IniTop, IniLeft, IniHeight, IniWidth : Integer;


implementation

uses GISOptions, Execute, IniFiles, Progress, FileSetup, SiteEdits, Math,
  FWFlowEdits, DrawGrid, FFForm, ElevHistForm, splash,CommDlg,Dlgs, ShellAPI, LatinHypercubeRun,
  Elev_Analysis, SensitivityRun, System.UITypes,  HTMLHelpViewer, ExtraMapsOptions,
  CarbonSeq;

{$R *.DFM}

Const NumFilesSaved=9;
Var  RecentFiles : Array[1..NumFilesSaved] of String;
     FileMenus   : Array[1..NumFilesSaved] of TMenuItem;


procedure TMainForm.CarbonSeqClick(Sender: TObject);
begin
  CarbonSeqForm.PCats := @SS.Categories;
  CarbonSeqForm.EditCarbonSeqs(SS);
  UpdateScreen; {}
end;

Function TMainForm.Check_Save_and_Cancel(ActionGerund: String): Boolean;
{Upon Opening New Study, Closing the program, etc. (specified in ActionGerund)
 This proecdure ensures user does not wish to save current study first}


 Var MR : TModalResult;
     NullObj: Tobject;
     FN: String;

 Begin

   UpdateScreen;
   NullObj:=Nil;
   Check_Save_and_Cancel:=False;
   FN := ExtractFileName(SS.FileN);
   If FN = '' then FN := 'current simulation';

   If SS<>nil then if SS.Changed then
      Begin
         Mr := MessageDlg('Save '+FN + ' before '+ActionGerund+'?',mtConfirmation,[mbYes,mbNo,mbCancel],0);
         if (Mr=mrYes) then
           Begin
            If SS<>nil then
              {Pass back any changes to the graphs in the output window}
              Save1Click(NullObj);
              If SaveCancel then Check_Save_and_Cancel:=True;
           End;
         if Mr=mrCancel then Check_Save_and_Cancel:=True;
      End;
   UpdateScreen;
 End;


procedure TMainForm.Close1Click(Sender: TObject);
begin
  If SS= nil then exit;
  If SS<> nil then if Check_Save_and_Cancel('closing')  then Exit;
  SS.Destroy;
  SS := nil;
  UpdateScreen;
end;

procedure TMainForm.Contents1Click(Sender: TObject);
begin
  Application.HelpContext(1001);
end;

procedure TMainForm.DescripEditChange(Sender: TObject);
begin
  If SS=nil then exit;
  If SS.Descrip <> DescripEdit.Text then SS.Changed := True;
  SS.Descrip := DescripEdit.Text;
end;

Procedure TMainForm.UpdateScreen;
Begin
  If SS=nil then
    Begin
      SimNameEdit.Text := '';
      DescripEdit.Text := '';
      ZoomBox.ItemIndex := 3;
      Panel2.Visible := True;
      SalinityButton.Enabled := False;
      SalAnalysis.Enabled := False;
      ModifiedLabel.Visible := False;

{$IFDEF Win32}
      Mainform.Caption := 'SLAMM v6.7 beta, June 2017, 32-bit';
{$ENDIF}
{$IFDEF Win64}          // Delphi and fpc of 32 Bit Windows
      Mainform.Caption := 'SLAMM v6.7 beta, June 2017, 64-bit';
{$ENDIF}

    End
   else with SS do
    Begin
      Panel2.Visible := False;
      If InitZoomFactor = 0.125 then ZoomBox.ItemIndex := 0 else
      If InitZoomFactor = 0.25 then ZoomBox.ItemIndex := 1 else
      If InitZoomFactor = 0.5 then ZoomBox.ItemIndex := 2 else
      If InitZoomFactor = 1 then ZoomBox.ItemIndex := 3 else
      If InitZoomFactor = 2 then ZoomBox.ItemIndex := 4 else
      If InitZoomFactor = 3 then ZoomBox.ItemIndex := 5;
      SimNameEdit.Text := SimName;
      DescripEdit.Text := Descrip;
      ModifiedLabel.Visible := Changed;

      Mainform.Caption := 'SLAMM v6.7 beta -- '+FileN;

      // Update of the fresh water flows module
      if (NumFwFlows>0) and ((trim(SS.SalFileN)='') or (pos('.xls',lowercase(SalFileN))>0)) then
        SalinityButton.Enabled := True
      else
        SalinityButton.Enabled := False;

      // Update of the salinity module
      if ((NumFwFlows>0) and (trim(SS.SalFileN)='')) or (trim(SS.SalFileN)<>'') then
        SalAnalysis.Enabled := True
      else
        SalAnalysis.Enabled := False;

      if Init_SalStats=True then
        SalAnalysis.Enabled := True;
    End;

End;




procedure TMainForm.About1Click(Sender: TObject);
begin
   SplashForm.LicenseButton.Visible := True;
   SplashForm.ExitButton.Visible := True;
   SplashForm.SourceCode.Visible := True;
   SplashForm.VersionInfo.Caption:='(Build Number '+Trim(BuildStr)+')';
   SplashForm.VersionInfo.Visible := True;
   Splashform.ShowModal;
end;



procedure TMainForm.NewButtonClick(Sender: TObject);
Var CA: Boolean;
begin
 if SS <> nil then if Check_Save_and_Cancel('creating a new file')  then Exit;

 CA := MessageDlg('Use California Categories?  (As opposed to "Classic" SLAMM Categories)',mtconfirmation,[mbyes,mbno],0) = MRYes;

 SS := TSLAMM_Simulation.Create(CA);

 UpdateScreen;
end;

procedure TMainForm.Open1Click(Sender: TObject);
begin
  LoadSimulationClick(nil);
end;

procedure TMainForm.LargeRasterButtonClick(Sender: TObject);
Var SaveRescale: Integer;
begin
 Large_Raster_Edit := True;

 SaveRescale := SS.RescaleMap;
 SS.RescaleMap := 1;

 SS.ScaleCalcs;
 SS.IncludeDikes := True;
 SS.Changed := True;
 SS.SetMapAttributes;
 SS.DisposeMem;
 Large_Raster_Edit := False;

 SS.RescaleMap := SaveRescale;

 UpdateScreen;  {}
end;

procedure TMainForm.LoadSimulationClick(Sender: TObject);


Begin
  if SS <> nil then if Check_Save_and_Cancel('loading a new file')  then Exit;

  OpenDialog1.Title:='Select SLAMM6 File to Load';
  OpenDialog1.FileName := '';
  OpenDialog1.Filter :=  'SLAMM6 files (*.SLAMM6)|*.SLAMM6|Text Parameters (*.txt)|*.txt';

  If not OpenDialog1.Execute then exit;

  if SS <> nil then SS.Destroy;
  Try
    SS := TSLAMM_Simulation.Load(OpenDialog1.FileName);
  Except
    SS := nil;
  End;

  WriteIniFileData;

  UpdateScreen;
  SS.NElevStats := 0;
end;


procedure TMainForm.New1Click(Sender: TObject);
begin
  NewButtonClick(nil);
end;

procedure TMainForm.ElevationButtonClick(Sender: TObject);
Var SaveRescale: Integer;
begin
  SaveRescale := SS.RescaleMap;
  SS.RescaleMap := 1;

  SS.ScaleCalcs;
  Large_Raster_Edit := False;

  ElevAnalysisForm.MapLoaded := False;
  SS.Site.InitElevVars;
  ElevAnalysisForm.ElevationAnalysis(SS);

  SS.RescaleMap := SaveRescale;
end;

procedure TMainForm.ExecuteButtonClick(Sender: TObject);
var
  i: IPCCScenarios;
begin
  Large_Raster_Edit := False;

  If SS=nil then exit;

  if (SS.ClassicDike=False) or (SS.NRoadInf > 0) then
    begin
      ExecuteOptionForm.ConnectivityBox.Checked := True;
      ExecuteOptionForm.ConnectivityBox.Enabled := False;
      SS.CheckConnectivity := True;
    end;



  with ExecuteOptionForm do
    begin

      // Disable the output area save selection if there is no output raster
      SaveAllArea.Enabled := True;
      SaveROSArea.Enabled := True;
      Label8.Enabled := True;

      (* HCRT Modification - Marco
      if (trim(SS.ROSFileN)='') then
        begin
          SaveAllArea.Checked := True;
          SaveAllArea.Enabled := False;
          SaveROSArea.Enabled := False;
          Label8.Enabled := False;
          SS.SaveROSArea := False;
        end;
       *)

      //Enable disable min/max slr scenarios
      Min.Enabled := False;
      Max.Enabled := False;
      Mean.Enabled := False;
      for i := Scen_A1B to Scen_B2 do
        begin
          if SS.IPCC_Scenarios[i] = True then
            begin
              Min.Enabled := True;
              Max.Enabled := True;
              Mean.Enabled := True;
              break;
            end;
        end;
    end;


  If ExecuteOptionForm.EditOptions(SS) then
    Begin
      Gridform.GraphBox.ItemIndex := 0;

      With SS do
        if NumMMEntries < 1 then
          Count_MMEntries;

      If SS.RunUncertainty then UncertRun(SS)
         else if SS.RunSensitivity then SensRun(SS)
         else SS.ExecuteRun;

      ProgForm.Cleanup;
      ProgForm.UncertStatusLabel.Visible := False;

      If not (SS.RunUncertainty or SS.RunSensitivity) then  // separate logs exist for uncertainty & sensitivity runs.
        Try
          Append(SS.RunRecordFile);
          Writeln(SS.RunRecordFile);
          If SS.UserStop then Writeln(SS.RunRecordFile,'USER STOP OR PROGRAM ERROR AT '+DateTimeToStr(Now()))
                         else Writeln(SS.RunRecordFile,'Simulations Completed at '+DateTimeToStr(Now()));

          Writeln(SS.RunRecordFile);
          Writeln(SS.RunRecordFile,' -----------------   END OF RUN RECORD LOG  ----------------------');
          Closefile(SS.RunRecordFile);
        Except
          MessageDlg('Error appending to Run-Record File '+SS.RunRecordFileName,mterror,[mbOK],0);
        End;

      If SS.UserStop
        then GridForm.Hide
        else MessageDLG('Your simulations have been completed.', mtinformation, [mbok],0);
    End;

  If GridForm.Visible then GridForm.DisposeWhenClosed := True
                      else SS.DisposeMem;
  ProgForm.Hide;                    
  UpdateScreen;
end;


procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.Save1Click(Sender: TObject);
begin
 SaveSimClick(nil);
end;

procedure TMainForm.SaveAs1Click(Sender: TObject);
begin
  SaveAsClick(nil);
end;



procedure TMainForm.SaveAsClick(Sender: TObject);
Var ext: String;
begin
  If SS= nil then exit;

  ext := lowercase(ExtractFileExt(SS.FileN));
  If  (ext = '.txt') then SaveDialog1.FilterIndex := 2
                     else SaveDialog1.FilterIndex := 1;
  SaveDialog1.InitialDir  := ExtractFilePath(SS.FileN);

  SaveCancel := True;
  SaveDialog1.Title:='Select SLAMM6 File to Save';
  SaveDialog1.Filter := 'SLAMM6 files (*.SLAMM6)|*.SLAMM6|Text Parameters (*.txt)|*.txt';
  SaveDialog1.FileName := SS.FileN;
  If not SaveDialog1.Execute then exit;

  SS.FileN := SaveDialog1.FileName;
  ext := lowercase(ExtractFileExt(SaveDialog1.FileName));
  If  (ext <> '.txt') and (ext <> '.slamm6') then
    Begin
      If SaveDialog1.FilterIndex = 1 then SS.FileN := ChangeFileExt(SaveDialog1.FileName, '.SLAMM6');
      If SaveDialog1.FilterIndex = 2 then SS.FileN := ChangeFileExt(SaveDialog1.FileName, '.txt');
    End;

  SS.Save(SS.FileN);
  SaveCancel := False;
  WriteIniFileData;

  UpdateScreen;
end;

procedure TMainForm.SaveDialog1TypeChange(Sender: TObject);
var buf:array [0..MAX_PATH] of char;S:String;od:TSaveDialog;H:THandle;
begin
  // get a pointer to the dialog
  od := (Sender as TSaveDialog);
  // Send the message to the dialogs parent so it can handle it the normal way
  H := GetParent(od.Handle);
  // get the currently entered filename
  SendMessage(H, CDM_GETSPEC, MAX_PATH,integer(@buf));
  S := buf;
  // change the extension to the correct one
  case od.FilterIndex of
    1:
      S := ChangeFileExt(S,'.SLAMM6');
    2:
      S := ChangeFileExt(S,'.txt');
  end;
  // finally, change the currently selected filename in the dialog
  SendMessage(H,CDM_SETCONTROLTEXT,edt1,integer(PChar(S)));
end;

procedure TMainForm.SaveSimClick(Sender: TObject);
begin
  SaveCancel := True;
  If SS<>nil then
    If SS.Filen <> '' then Begin
                             SS.Save(SS.FileN);
                             SaveCancel := False;
                             WriteIniFileData;
                           End
                      else SaveAsClick(nil);
   UpdateScreen;
end;

procedure TMainForm.SetMapClick(Sender: TObject);
Var SaveRescale: Integer;
begin
  SaveRescale := SS.RescaleMap;
  SS.RescaleMap := 1;
  SS.ScaleCalcs;

  Large_Raster_Edit := False;

  With SS do
   If NumMMEntries < 1 then
      Count_MMEntries;

 SS.IncludeDikes := True;
 SS.Changed := True;
 SS.SetMapAttributes;
 SS.DisposeMem;

 SS.RescaleMap := SaveRescale;
 UpdateScreen;
end;



procedure TMainForm.SimNameEditChange(Sender: TObject);
begin
  If SS=nil then Exit;
  If SS.SimName <> SimNameEdit.Text then SS.Changed := True;
  SS.SimName := SimNameEdit.Text;

end;

procedure TMainForm.SiteParmsClick(Sender: TObject);
begin
  SiteEditForm.EditSubSites(SS);  {}
end;

procedure TMainForm.SalAnalysisClick(Sender: TObject);
Var SaveRescale: Integer;
begin
  SaveRescale := SS.RescaleMap;
  SS.RescaleMap := 1;
  SS.ScaleCalcs;

  SalinityForm.MapLoaded := False;
  SS.CalibrateSalinity;
  SS.RescaleMap := SaveRescale;
end;

procedure TMainForm.SalinityButtonClick(Sender: TObject);
begin
  If SS.NumFwFlows > 0 then
    begin
      FWFlowEdits.FSS := SS;
      FWFlowEdit.EditFWFlow(SS.FwFlows,SS.NumFwFlows,0);
    end
  else
    begin
      MessageDlg('You must first define freshwater flows after loading the map',mterror,[mbok],0);
      Exit;
    End;
end;

procedure TMainForm.ZoomBoxChange(Sender: TObject);
begin
  With SS do
     Case ZoomBox.ItemIndex of
       0: InitZoomFactor := 0.125;
       1: InitZoomFactor := 0.25;
       2: InitZoomFactor := 0.5;
       3: InitZoomFactor := 1.0;
       4: InitZoomFactor := 2.0;
       5: InitZoomFactor := 3.0;
     End;
end;




procedure TMainForm.FileSetupClick(Sender: TObject);
begin
  FileSetupForm.EditFileInfo(SS);{}
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
  If SS=nil then exit;

  if Check_Save_and_Cancel('quitting') then CanClose := False;
end;

procedure TMainForm.FormCreate(Sender: TObject);
Var Program_Dir: String;
begin
  DragAcceptFiles( Handle, True );

  IncomingFile := ParamStr(1);
  ZoomBox.ItemIndex := 3;  {100%}
  SS := nil;
  Panel2.BringToFront;
  ReadIniFileData;
  UpdateScreen;

  UncAnalysis := False;
  SensAnalysis := False;  // no uncertainty or sensitivity enabled at this time

  Program_Dir:=ExtractFilePath(Application.ExeName);
  Application.Helpfile := Program_Dir+'SLAMM6.CHM';

{  ReportMemoryLeaksOnShutdown := DebugHook <> 0; }
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  WriteIniFileData;
  If SS <> nil then SS.Destroy;
{  System.runFinalization(); {force garbage collection
  System.gc();                                        }
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  DRIVE_EXTERNALLY := False;
  inherited;

  If IncomingFile <> '' then
    Begin
      if SS <> nil then SS.Destroy;
      Try
        SS := TSLAMM_Simulation.Load(IncomingFile);

        If DRIVE_EXTERNALLY then
          Begin
            SS.ExecuteRun;
            Halt;
          End;

      Except
        SS := nil;
      End;
      WriteIniFileData;
      UpdateScreen;
    End;

end;

procedure TMainForm.HelpButtonClick(Sender: TObject);
begin
  Application.HelpContext(1013);  //ExpandedOpening.html
end;

Function CompressFileN(FN,DR:String): String;
Var TFile: String;
    Index,Loop,CopyUp: Integer;
Begin
  Result := '';
  If DR='' then Exit;
   Begin
      if Length(DR) > 2 then TFile := DR[1]+DR[2]+Dr[3] //first three characters
                        else TFile := DR;
      Index := Length(DR);
      CopyUp := Length(DR)+1;
      While (Index>Length(Dr)-25) and (Index>3) do
        Begin
          If (DR[Index]='\') or (Index=4) then CopyUp := Index;
          Dec(Index);
        End;
      If CopyUp > 4 then TFile := TFile+'...';
      For Loop := CopyUp to Length(DR) do
        TFile := TFile+DR[Loop];
      If (TFile[Length(TFile)]<>'\') then TFile := TFile + '\';
      TFile := TFile + FN;
    End;
  CompressFileN := TFile;
End;


Procedure TMainForm.UpdateRecentlyUsed;
Var FileInList, SavedItems: Integer;
    Loop: Integer;
    CName: String;

Begin
  If SS=nil then exit;

  SavedItems := 0;
  For Loop := 1 to NumFilesSaved do
   If FileMenus[Loop].Visible then SavedItems := Loop;

  FileInList := 0;
  For Loop := 1 to SavedItems do
    If LowerCase(SS.FileN) = LowerCase(RecentFiles[Loop])
      Then FileInList := Loop;

  If FileInList=1 then exit;
  If FileInList>1 then  {move the file down to first position and move up other files}
    Begin
      For Loop := FileInList-1 downto 1 do
        Begin
          FileMenus[Loop+1].Caption := FileMenus[Loop].Caption;
          RecentFiles[Loop+1] := RecentFiles[Loop];
          CName := FileMenus[Loop+1].Caption;
          CName[2] := IntToStr(Loop+1)[1];
          FileMenus[Loop+1].Caption := CName;
        End;
      RecentFiles[1] := SS.FileN;
      FileMenus[1].Caption := '&1: '+CompressFileN(ExtractFileName(SS.FileN),ExtractFilePath(SS.FileN));
      FileMenus[1].Visible := True;
      Update;
      Exit;
    End;

  For Loop := SavedItems downto 1 do
   If Loop<NumFilesSaved then
     Begin
       FileMenus[Loop+1].Caption := FileMenus[Loop].Caption;
       RecentFiles[Loop+1] := RecentFiles[Loop];
     End;

  For Loop := SavedItems+1 downto 1 do
   If Loop<=NumFilesSaved then
    Begin
      FileMenus[Loop].Visible := True;
      CName := FileMenus[Loop].Caption;
      CName[2] := IntToStr(Loop)[1];
      FileMenus[Loop].Caption := CName;
    End;

  RecentFiles[1] := SS.FileN;
  FileMenus[1].Caption := '&1: '+CompressFileN(ExtractFileName(SS.FileN),ExtractFilePath(SS.FileN));
  FileMenus[1].Visible := True;
  Update;

End;


Procedure TMainForm.ReadIniFileData;
Var INI: TIniFile;
    Loop: Integer;
    Program_Dir, CName: String;

Begin
  For Loop := 1 to NumFilesSaved do
    Begin
      CName := 'RF'+IntToStr(Loop);
      FileMenus[Loop] := TMenuItem(FindComponent(CName));
    End;

  Program_Dir:=ExtractFilePath(Application.ExeName);
  INI := TIniFile.Create(Program_Dir+'SLAMM6.INI');

  {Recent File Data}

  For Loop:=1 to NumFilesSaved do
    Begin
      RecentFiles[Loop]:=INI.ReadString('RecentFiles','File'+IntToStr(Loop),'');
      FileMenus[Loop].Visible := RecentFiles[Loop]<>'';
      If FileMenus[Loop].Visible
        then FileMenus[Loop].Caption := '&'+IntToStr(Loop)+': '+CompressFileN(ExtractFileName(RecentFiles[Loop]),ExtractFileDir(RecentFiles[Loop]))
    End;

  {Window Location Data}

  IniMax    := Ini.ReadBool('WindowState','Maximized',True);
  IniTop    := Ini.ReadInteger('WindowState','Top',25);
  IniLeft   := Ini.ReadInteger('WindowState','Left',25);
  IniHeight := Ini.ReadInteger('WindowState','Height',545);
  IniWidth  := Ini.ReadInteger('WindowState','Width',642);

  INI.Free;

  UpdateRecentlyUsed;

End;




Procedure TMainForm.WriteIniFileData;
Var INI: TIniFile;
    Loop: Integer;
    SavedItems: Integer;
    Program_Dir, StrToWrite: String;

Begin
  UpdateRecentlyUsed;

  Program_Dir:=ExtractFilePath(Application.ExeName);
  INI := TIniFile.Create(Program_Dir+'SLAMM6.INI');

  {Recent File Data}

  SavedItems := 0;
  For Loop := 1 to NumFilesSaved do
    If FileMenus[Loop].Visible then SavedItems := Loop;
  For Loop:=1 to NumFilesSaved do
    Begin
      If Loop>SavedItems then StrToWrite:=''
                         else StrToWrite:= RecentFiles[Loop];
      INI.WriteString('RecentFiles','File'+IntToStr(Loop),StrToWrite);
    End;

  {Window Location Data}

  Ini.WriteBool('WindowState','Maximized',(WindowState=WSMaximized));
  If WindowState=WSMaximized
    then
      begin {write default screen pos}
        Ini.WriteInteger('WindowState','Top',25);
        Ini.WriteInteger('WindowState','Left',25);
        Ini.WriteInteger('WindowState','Height',545);
        Ini.WriteInteger('WindowState','Width',642);
      end
    else
      Begin
        Ini.WriteInteger('WindowState','Top',Top);
        Ini.WriteInteger('WindowState','Left',Left);
        Ini.WriteInteger('WindowState','Height',Height);
        Ini.WriteInteger('WindowState','Width',Width);
      End;

  INI.Free;
End;


procedure TMainForm.RecentlyUsedClick(Sender: TObject);
Var FileIndex, Loop : Integer;
    Str: String;
    LoadSuccess: Boolean;
begin
  FileIndex := StrToInt(TMenuItem(Sender).Name[3]);

  if SS<>nil then if Check_Save_and_Cancel('Opening New Simulation') then exit;

  LoadSuccess := FileExists(RecentFiles[FileIndex]);
  If Not LoadSuccess then ShowMessage('File Not Found: '+RecentFiles[FileIndex]);
  If LoadSuccess then
    Begin
      if SS <> nil then SS.Destroy;
      Try
        SS := TSLAMM_Simulation.Load(RecentFiles[FileIndex]);
      Except
        SS := nil;
        ShowMessage('File not loaded successfully.');
      End;
      LoadSuccess := SS<>nil;
    End;

  If Not LoadSuccess then
    Begin
      For Loop := FileIndex to NumFilesSaved-1 do
        Begin
          Str := FileMenus[Loop+1].Caption;
          If Str <> '' then Str[2] := PRED(Str[2]);
          FileMenus[Loop].Caption := Str;
          FileMenus[Loop].Visible := FileMenus[Loop+1].Visible;
          RecentFiles[Loop]       := RecentFiles[Loop+1];
        End;

      FileMenus[NumFilesSaved].Caption := '';
      FileMenus[NumFilesSaved].Visible := False;
      RecentFiles[NumFilesSaved]       := '';
    End;

  WriteIniFileData;
  UpdateScreen;

end;

Procedure TMainForm.AcceptFiles(Var msg:TMessage);
const cnMaxFileNameLen = 255;
var
  i,
  nCount     : integer;
  acFileName : array [0..cnMaxFileNameLen] of char;
//  pName: String;
begin
  nCount := DragQueryFile( msg.WParam, $FFFFFFFF, acFileName, cnMaxFileNameLen );   // find out how many files we're accepting

  If nCount > 1 then
    Begin
      MessageDLG('Only one file may be dragged to SLAMM at one time.', mtinformation, [mbok],0);
      exit;
    End;  {OMIT IF PROCESS_BATCH }

  for i := 0 to nCount-1 do   // query Windows one at a time for the file name
  begin
    DragQueryFile( msg.WParam, i, acFileName, cnMaxFileNameLen );
    if SS <> nil then if Check_Save_and_Cancel('loading a new file')  then Exit;

    if SS <> nil then SS.Destroy;
    Try
      SS := TSLAMM_Simulation.Load( acFileName);

(*      {-------------------------------------}
      PROCESSING_BATCH := True;

      SS.RescaleMap := 1;
      SS.ScaleCalcs;

      pName := ChangeFileExt(SS.FileN,'.SUBSITE_RASTER.ASC');
      SS.SaveRaster(pName,4 );

//      SiteEditForm.EditSubSites(SS);  { Export to Excel}
      {------------------------------------} *)

    Except
      SS := nil;
    End;  end;

  DragFinish( msg.WParam );
  UpdateScreen;

end;




end.
