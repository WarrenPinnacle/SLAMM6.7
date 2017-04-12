unit UncertMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, SLR6,
  StdCtrls, ExtCtrls, UncertDefn, DistEdit, Menus, CalcDist, RandNum,
  Buttons;

type
  TUncertForm = class(TForm)
    ExecuteButton: TButton;
    AddDist: TButton;
    DistBox: TListBox;
    RemoveDist: TButton;
    EditDist: TButton;
    Panel1: TPanel;
    Label2: TLabel;
    IterEdit: TEdit;
    SeedLabel: TLabel;
    SeedEdit: TEdit;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    MainMenu1: TMainMenu;
    UseSeedBox: TRadioButton;
    UseRandomSeed: TRadioButton;
    FileMenu: TMenuItem;
    Load1: TMenuItem;
    Save1: TMenuItem;
    Close1: TMenuItem;
    Bevel1: TBevel;
    SaveAs1: TMenuItem;
    N1: TMenuItem;
    UpBtn: TBitBtn;
    DownBtn: TBitBtn;
    Label4: TLabel;
    SensPanel: TPanel;
    Label5: TLabel;
    PctVaryEdit: TEdit;
    Label6: TLabel;
    GISNumEdit: TEdit;
    HelpButton: TBitBtn;
    SEGTSlopeLabel: TLabel;
    SEGTSlopeEdit: TEdit;
    SEGTCheckbox: TCheckBox;
    ExportExcelButton: TButton;
    CopyButton: TButton;
    procedure AddDistClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditDistClick(Sender: TObject);
    procedure RemoveDistClick(Sender: TObject);
    procedure DistBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure UseSeedBoxClick(Sender: TObject);
    procedure ConvInt(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure Load1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure UpBtnClick(Sender: TObject);
    procedure DownBtnClick(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure SEGTCheckboxClick(Sender: TObject);
    procedure SEGTSlopeEditExit(Sender: TObject);
    procedure ExportExcelButtonClick(Sender: TObject);
    procedure CopyButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    Sim: TSLAMM_Simulation;
    Changed: Boolean;
    SensMode: Boolean;
    ShellPath: String;
    Procedure NewShell;
    Procedure CopyDist(Index: Integer);
    Procedure UpdateScreen;
    Procedure SaveShell;
    Procedure LoadShell;
    Procedure EditUncertSetup(TSS: TSLAMM_Simulation);
  end;

{    Const NumOutputs = 25;
          SiteToWrite = 0; }

var
  UncertForm: TUncertForm;

implementation

uses selectinput, Progress, Uncert, Main, Global, System.UITypes, Execute, Math,  Comobj, Variants, ExcelFuncs, Excel2000;

{$R *.DFM}

procedure TUncertForm.EditUncertSetup;
var i: Integer;
Begin
  Sim := TSS;
  UpdateScreen;

  With DistributionForm do
   Begin
     SubsiteBox.Clear;
     SubsiteBox.Items.Add('Pertains to ALL Subsites');
     SubsiteBox.Items.Add('G: '+Sim.Site.GlobalSite.Description);
     for i := 1 to Sim.Site.NSubSites do
       SubsiteBox.Items.Add(IntToStr(i)+': '+Sim.Site.SubSites[i-1].Description);
     SubsiteBox.ItemIndex := 0;
   End;

  ShowModal;
End;

procedure TUncertForm.ExportExcelButtonClick(Sender: TObject);
Var SaveName: String;
    TEx: TExcelOutput;
    Loop: Integer;
    DistStr, SiteStr: String;
    GV,GV25,GV975: Double;

begin
    // Create save dialog and set it options
    with SaveDialog1 do
    begin
       DefaultExt := 'xlsx' ;
       Filter := 'Excel files (*.xlsx)|*.xlsx|All files (*.*)|*.*' ;
       Options := [ofOverwritePrompt,ofPathMustExist,ofNoReadOnlyReturn,ofHideReadOnly] ;
       Title := 'Please Specify an Excel File into which to Save this Table:';
    end ;

   if not SaveDialog1.Execute then exit;

   SaveName := SaveDialog1.FileName;
   If FileExists(SaveDialog1.FileName) then If Not DeleteFile(SaveName)
     then Begin
            MessageDlg('Cannot gain exclusive access to the file to overwrite it.',mtError,[mbOK],0);
            Exit;
          End;
    TEx := TExcelOutput.Create(False);
    TEx.FileN := SaveName;

    If Not TEx.OpenFiles then
      Begin
        TEx:= nil;
        Raise ESLAMMError.Create('Error Creating Excel File');
      End;

    TEx.WS.Name := 'Uncert_Param';

    TEx.WS.Cells.Item[1,1].Value := 'Distribution Name';
    TEx.WS.Cells.Item[1,2].Value := 'Site';
    TEx.WS.Cells.Item[1,3].Value := 'Point Estimate';
    TEx.WS.Cells.Item[1,4].Value := '2.5% Draw';
    TEx.WS.Cells.Item[1,5].Value := '97.5% Draw';
    TEx.WS.Cells.Item[1,6].Value := 'Distribution Type';
    TEx.WS.Cells.Item[1,7].Value := 'Parameter 1';
    TEx.WS.Cells.Item[1,8].Value := 'Parameter 2';
    TEx.WS.Cells.Item[1,9].Value := 'Parameter 3';

    With Sim.UncertSetup do
     For Loop := 0 to NumDists-1 do
      Begin
        TEx.WS.Cells.Item[2+Loop,1].Value := DistArray[Loop].DName;
        If DistArray[Loop].SubSiteNum > Sim.Site.NSubSites then DistArray[Loop].SubSiteNum := 0;

        if DistArray[Loop].AllSubSites
          then SiteStr := 'ALL Subsites*'
          else if DistArray[Loop].SubSiteNum = 0
            then SiteStr := 'G: '+Sim.Site.GlobalSite.Description
            else SiteStr := IntToStr(DistArray[Loop].SubSiteNum)+': '+Sim.Site.SubSites[DistArray[Loop].SubSiteNum-1].Description;
        TEx.WS.Cells.Item[2+Loop,2].Value := SiteStr;

        GV := DistArray[Loop].GetValue;
        TEx.WS.Cells.Item[2+Loop,3].Value := GV;

        If DistArray[Loop].DistType <> ElevMap then
            Begin
              GV25 := Max(0,GV*DistArray[Loop].TruncICDF(0.025));
              TEx.WS.Cells.Item[2+Loop,4].Value := GV25;
              GV975 := GV*DistArray[Loop].TruncICDF(0.975);
              TEx.WS.Cells.Item[2+Loop,5].Value := GV975;
            End;

        Case DistArray[Loop].DistType of
          Triangular: DistStr := 'Triangular';
          Normal:     DistStr := 'Normal';
          LogNormal:  DistStr := 'Lognormal';
          Uniform:    DistStr := 'Uniform';
          Else        DistStr := 'Uncert. Map';
          end; {Case}
        TEx.WS.Cells.Item[2+Loop,6].Value := DistStr;

        TEx.WS.Cells.Item[2+Loop,7].Value := DistArray[Loop].Parm[1];
        TEx.WS.Cells.Item[2+Loop,8].Value := DistArray[Loop].Parm[2];
        if DistArray[Loop].DistType = Triangular then TEx.WS.Cells.Item[2+Loop,9].Value := DistArray[Loop].Parm[3]
      End;

     TEx.WS.Range['A1', 'I1'].EntireColumn.AutoFit;
     TEx.SaveAndClose;

end;


procedure TUncertForm.AddDistClick(Sender: TObject);

    Procedure AddParam(PID, SSI: Integer);
    Var j: Integer;
        NewSens: TSensParam;

    Begin
     If (PID = 2) or (PID = 5)
                then Begin
                       MessageDlg('Elevation Uncertainty is a spatial parameter, and is not relevant for sensitivity analysis.',mterror,[mbok],0);
                       Exit;
                     End;

     With Sim.UncertSetup do
      Begin
        For j := 0 to NumSens -1 do
           If SensArray[j].IDNum = PID then Exit;

        NewSens := TSensParam.Create(PID,Sim,(SSI=0),SSI-2);
        Inc(NumSens);
        SetLength(SensArray,NumSens);
        SensArray[NumSens-1] := NewSens;
        UpdateScreen;
       End; {with}
    End; {AddParam}

    Procedure AddAndEdit(PID, SSI: Integer);
    Var j: Integer;
        NewDist: TInputDist;

    Begin
     With Sim.UncertSetup do
      Begin
        For j := 0 to NumDists-1 do
           If (DistArray[j].IDNum = PID) and
              ( ((not DistArray[j].AllSubsites) and (DistArray[j].SubSiteNum=SSI)) or
                ( DistArray[j].AllSubsites and (SSI=0)) or
                (PID in [1,2,5]) )  // avoid duplicate entries   globaluncertlogic
                then Exit;

        if PID in [1,2,5] then SSI:=0;  // globaluncertlogic

        NewDist := TInputDist.Create(PID,Sim,(SSI=0),SSI-1);

        DistributionForm.PDistArr := @DistArray;
        DistributionForm.PNumDists := @NumDists;

        If not DistributionForm.EditTheDist(NewDist,Sim) then
           begin
             NewDist.Destroy;
             Exit;
           End;

        Inc(NumDists);
        SetLength(DistArray,NumDists);
        DistArray[NumDists-1] := NewDist;
        UpdateScreen;
      End;
    End;

Var Loop, SelIndex, i: Integer;

begin
  With SelInput do
   Begin
     SubSiteBox.Visible := Not SensMode;

     if Not SensMode then
       Begin
         SubsiteBox.Clear;
         SubsiteBox.Items.Add('Pertains to ALL Subsites');
         SubsiteBox.Items.Add('G: '+Sim.Site.GlobalSite.Description);
         for i := 1 to Sim.Site.NSubSites do
           SubsiteBox.Items.Add(IntToStr(i)+': '+Sim.Site.SubSites[i-1].Description);
         SubsiteBox.ItemIndex := 0;
       End;

     If ShowModal=mrcancel then exit;

     SelIndex := ListBox1.SelCount;
     If SelIndex = 0 then
          Begin
             MessageDlg('No Distribution is Selected.',mterror,[mbOK],0);
             Exit;
          End;

    For Loop:=0 to ListBox1.Items.Count-1 do
    If ListBox1.Selected[Loop] then
      If SensMode then AddParam(Loop+1,SubSiteBox.ItemIndex)
                  else AddAndEdit(Loop+1,SubSiteBox.ItemIndex);

   End;

end;

Procedure TUncertForm.UpdateScreen;
Var Loop, i: Integer;
    AddStr: String;
    SubsiteWarned: Boolean;
    GV: Double;
Begin
  SubsiteWarned := False;
  SEGTCheckBox.Visible := not SensMode;
  SEGTSlopeLabel.Visible := not SensMode;
  SEGTSlopeEdit.Visible := not SensMode;

  SensPanel.Visible := SensMode;
  ExportExcelButton.Visible := Not SensMode;
  CopyButton.Visible := Not SensMode;
  If SensMode then UncertForm.Caption := 'SLAMM Sensitivity Analysis'
              else UncertForm.Caption := 'SLAMM Uncertainty Analysis';

  If SensMode then AddDist.Caption := 'Add Parameter'
              else AddDist.Caption := 'Add Distribution';
  If SensMode then RemoveDist.Caption := 'Remove Parameter'
              else RemoveDist.Caption := 'Remove Distribution';
  EditDist.Visible := not SensMode;
  If SensMode then Label4.Caption := 'Parameter multipliers will be applied to all sub-sites equally.'
              else Label4.Caption := 'Distributions are multipliers and apply to all sub-sites equally.';

  DistBox.Items.Clear;
  If Not SensMode then DistBox.Items.Add('Distribution Name                        |Site|Point Est. [ 2.5%   ..   97.5%  ] | Type |  Parameters -->');
  If Not SensMode then DistBox.Items.Add('----------------------------------------------------------------------------------------------------------');

  If Not SensMode then
    With Sim.UncertSetup do
     For Loop := 0 to NumDists-1 do
      Begin
        AddStr := DistArray[Loop].DName;
        For i := Length(DistArray[Loop].DName) to 41 do
          AddStr := AddStr + ' ';

        If DistArray[Loop].SubSiteNum > Sim.Site.NSubSites then
          Begin
            If not SubSiteWarned then MessageDlg('Warning:  Some distribution subsite assignments exceed number of subsites in this study.'+
            '  These will be assigned to the global subsite and may need to be reassigned or deleted.',mtwarning,[mbok],0);
            DistArray[Loop].SubSiteNum := 0;
            SubsiteWarned := True;
          End;

        if DistArray[Loop].AllSubSites
          then AddStr := AddStr+ 'All'
          else if DistArray[Loop].SubSiteNum = 0
            then AddStr := AddStr+ 'G. '
            else With DistArray[Loop] do
                 Begin
                   AddStr := AddStr+IntToStr(SubSiteNum);
                   AddStr := AddStr + ' ';
                   if Length(IntToStr(SubSiteNum))=1 then AddStr := AddStr + ' ';
                 End;

        GV := DistArray[Loop].GetValue;
        If DistArray[Loop].DistType = ElevMap
          then
              AddStr := AddStr + fixfloattostr(GV,10)+',                          '
           else
            Begin
              AddStr := AddStr + fixfloattostr(GV,10)+',  [';
              TRY
                AddStr := AddStr + fixfloattostr(Max(0,GV*DistArray[Loop].TruncICDF(0.025)),8)+ ' .. ';
                AddStr := AddStr + fixfloattostr(GV*DistArray[Loop].TruncICDF(0.975),8)+'] ';
              Except
                AddStr := AddStr + 'Distribution Error] ';
              End;
            End;

        Case DistArray[Loop].DistType of
          Triangular: AddStr := AddStr + 'Tria: ';
          Normal:     AddStr := AddStr + 'Norm: ';
          LogNormal:  AddStr := AddStr + 'LogN: ';
          Uniform:    AddStr := AddStr + 'Unfm: ';
          Else        AddStr := AddStr + 'MAP:  ';

        End; {case}

        AddStr := AddStr + fixfloattostr(DistArray[Loop].Parm[1],10)+', '+fixfloattostr(DistArray[Loop].Parm[2],10);
        if DistArray[Loop].DistType = Triangular then AddStr := AddStr +', '+ fixfloattostr(DistArray[Loop].Parm[3],10);

        DistBox.Items.Add(AddStr);
      End;

  If SensMode then DistBox.Items.Add('Parameter Name                      ');
  If SensMode then DistBox.Items.Add('------------------------------------');
  If SensMode then
   With Sim.UncertSetup do
    For Loop := 0 to NumSens-1 do
     Begin
       DistBox.Items.Add(SensArray[Loop].DName);
     End;

  With Sim.UncertSetup do
    Begin
      UseSeedBox.Checked :=  UseSeed;
      UseRandomSeed.Checked := Not UseSeed;
      UseSeedBoxClick(nil);

      SeedEdit.Text := IntToStr(Seed);
      IterEdit.Text := IntToStr(Iterations);
      GISNumEdit.Text := IntToStr(GIS_Start_Num);

      PctVaryEdit.Text := IntToStr(PctToVary);

      SEGTCheckBox.Checked := UseSEGTSlope;
      SEGTSlopeEdit.Text := FloatToStrF(SEGTSlope,ffgeneral,6,6);
      SEGTSlopeEdit.Enabled := SEGTCheckBox.Checked;
      SEGTSlopeLabel.Enabled := SEGTCheckBox.Checked;
    End;
End;

Procedure TUncertForm.NewShell;
Begin
  Sim.UncertSetup.Destroy;
  Sim.UncertSetup := TSLAMM_Uncertainty.Create;
End;

procedure TUncertForm.FormCreate(Sender: TObject);
begin
//  NewShell;
  ShellPath := '';
end;


procedure TUncertForm.HelpButtonClick(Sender: TObject);
begin
   If SensMode then Application.HelpContext(1015)
               else Application.HelpContext(1014);
end;

procedure TUncertForm.EditDistClick(Sender: TObject);
Var Loop, SelectedIndex: Integer;

begin
 If SensMode then Exit;

 With Sim.UncertSetup do
  Begin
    SelectedIndex := DistBox.SelCount;
    If SelectedIndex = 0 then
        Begin
           MessageDlg('No Distribution is Selected.',mterror,[mbOK],0);
           Exit;
        End;

    DistributionForm.PDistArr := @DistArray;
    DistributionForm.PNumDists := @NumDists;
    For Loop:=2 to DistBox.Items.Count-1 do
    If DistBox.Selected[Loop] then
      DistributionForm.EditTheDist(DistArray[Loop-2],Sim);

    UpdateScreen;
  End;
End;

procedure TUncertForm.RemoveDistClick(Sender: TObject);
Var Loop,Loop2: Integer;
    SelectedIndex: Integer;
begin
    SelectedIndex := DistBox.SelCount;
    If SelectedIndex = 0 then
        Begin
           MessageDlg('No Distribution is Selected.',mterror,[mbOK],0);                                             
           Exit;
        End;

  With Sim.UncertSetup do
   For Loop:=DistBox.Items.Count-1 downto 2 do
    If DistBox.Selected[Loop] then
      Begin
        SelectedIndex:=Loop-2;
        If SensMode then
          Begin
            For Loop2 := SelectedIndex+1 to NumSens-1 do
              SensArray[Loop2-1] := SensArray[Loop2];
            Dec(NumSens);
            SetLength(SensArray,NumSens);
          End
        else
          Begin
            For Loop2 := SelectedIndex+1 to NumDists-1 do
              DistArray[Loop2-1] := DistArray[Loop2];
            Dec(NumDists);
            SetLength(DistArray,NumDists);
          End;
      End;

    UpdateScreen;
End;

procedure TUncertForm.DistBoxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   If Key=VK_DELETE then RemoveDistClick(Sender);
   If Key=VK_INSERT then AddDistClick(Sender);
   If Key=VK_RETURN then EditDistClick(Sender);
end;

procedure TUncertForm.UseSeedBoxClick(Sender: TObject);
begin
  SeedLabel.Enabled := UseSeedBox.Checked;
  SeedEdit.Enabled  := UseSeedBox.Checked;
  Sim.UncertSetup.UseSeed := UseSeedBox.Checked;
end;

procedure TUncertForm.ConvInt(Sender: TObject);
Var Conv: Double;
  Result: Integer;

begin
    Val(Trim(TEdit(Sender).Text),Conv,Result);
    With Sim.UncertSetup do
      If Result<>0 then MessageDlg('Incorrect Numerical Format Entered',mterror,[mbOK],0)
                 else begin
                        If Trunc(Conv)=0.0 then Conv:=1.0;
                        case TEdit(Sender).Name[1] of
                           'I': Iterations:=Abs(Trunc(Conv));
                           'S': Seed:=Trunc(Conv);
                           'P': PctToVary := Abs(Trunc(Conv));
                           'G': GIS_Start_Num := Abs(Trunc(Conv));
                         end; {case}
                       end;
    UpdateScreen;
end;

procedure TUncertForm.CopyButtonClick(Sender: TObject);
Var Loop, SelectedIndex: Integer;
begin
 If SensMode then Exit;

 With Sim.UncertSetup do
  Begin
    SelectedIndex := DistBox.SelCount;
    If SelectedIndex = 0 then
        Begin
           MessageDlg('No Distribution is Selected.',mterror,[mbOK],0);
           Exit;
        End;

    For Loop:=2 to DistBox.Items.Count-1 do
    If DistBox.Selected[Loop] then
       CopyDist(Loop-2);

    UpdateScreen;
  End;
end;

procedure TUncertForm.CopyDist(Index: Integer);
Var OldDist, NewDist: TInputDist;
begin
with Sim.UncertSetup do
 Begin
  OldDist := Sim.UncertSetup.DistArray[Index];

  NewDist := TInputDist.Create(OldDist.IDNum,Sim,OldDist.AllSubsites,OldDist.SubSiteNum);
  NewDist.DistType := OldDist.DistType;
  NewDist.Parm := OldDist.Parm;
  NewDist.DisplayCDF := OldDist.DisplayCDF;
  NewDist.IsSubsiteParameter := OldDist.IsSubsiteParameter;

  DistributionForm.PDistArr := @DistArray;
  DistributionForm.PNumDists := @NumDists;
  If not DistributionForm.EditTheDist(NewDist,Sim) then
     begin
       NewDist.Destroy;
       Exit;
     End;

  Inc(NumDists);
  SetLength(DistArray,NumDists);
  DistArray[NumDists-1] := NewDist;
 End;
end;

procedure TUncertForm.Close1Click(Sender: TObject);
Var MR: TModalResult;
begin
  MR := MessageDlg('Save Shell before Closing?',mtconfirmation,[mbyes,mbno,mbcancel],0);
  If MR=MRCancel then exit;
  If MR=MRYes then Save1Click(nil);

  NewShell;
  UpdateScreen;
end;

procedure TUncertForm.Save1Click(Sender: TObject);

Begin
  SaveAs1.Click
End;

Procedure TUncertForm.SaveShell;
Var  TS: TStream;
     TF: TextFile;
Begin
  GlobalFile := @TF;
  AssignFile(GlobalFile^,ShellPath);
  Rewrite(GlobalFile^);
  GlobalLN := 0;
  TSText := True;
  TSWrite('ReadVersionNum',VersionNum);

  Sim.UncertSetup.Store(TS);

  Closefile(GlobalFile^);
  TSText := False;
End;

procedure TUncertForm.SEGTCheckboxClick(Sender: TObject);
begin
  With Sim.UncertSetup do
    UseSEGTSlope := SEGTCheckBox.Checked;
  UpdateScreen;
end;

procedure TUncertForm.SEGTSlopeEditExit(Sender: TObject);
Var Conv: Double;
    Result: Integer;

begin
  Val(Trim(TEdit(Sender).Text),Conv,Result);
  With Sim.UncertSetup do
    If Result<>0 then MessageDlg('Incorrect Numerical Format Entered',mterror,[mbOK],0)
               else begin
                      SEGTSlope := Conv;
                    end;
  UpdateScreen;
end;

Procedure TUncertForm.LoadShell;
Var VersionCheck : String;  {String 10}
    ReadVersionNum: Double;
    TF: TextFile;
Begin
  Try
    GlobalFile := @TF;
    AssignFile(GlobalFile^,ShellPath);
    Reset(GlobalFile^);
    TSText := True;
  Except
    MessageDlg(Exception(ExceptObject).Message,mterror,[mbOK],0);
    NewShell;
    TSText := False;
    Exit;
  End; {Try Except}

  {Check Version #}
  TSRead('ReadVersionNum',ReadVersionNum);

  If ReadVersionNum>VersionNum
    then
       Begin
          MessageDlg('File Version ('+VersionCheck+') is Greater than Executable Version: Unreadable.',mterror,[mbOK],0);
          NewShell;
       End
    else
       Try
         Sim.UncertSetup := TSLAMM_Uncertainty.Load(ReadVersionNum, nil, Sim);
       Except
         MessageDlg(Exception(ExceptObject).Message,mterror,[mbOK],0);
         NewShell;
       End;

  CloseFile(GlobalFile^);
  UpdateScreen;
  TSText := False;

End;

procedure TUncertForm.SaveAs1Click(Sender: TObject);
begin
  SaveDialog1.Title:='Select Shell File to Save';
  SaveDialog1.Filter := 'SLAMM UncertShell file (*.txt)|*.txt';
  SaveDialog1.FileName := '';
  If not SaveDialog1.Execute then exit;
  ShellPath := ChangeFileExt(SaveDialog1.FileName, '.txt');
  SaveShell;
end;

procedure TUncertForm.Load1Click(Sender: TObject);
begin
  OpenDialog1.Title:='Select Shell File to Load';
  OpenDialog1.FileName := '';
  OpenDialog1.Filter := 'SLAMM UncertShell files (*.txt)|*.txt';
  If not OpenDialog1.Execute then exit;

  ShellPath := OpenDialog1.FileName;
  LoadShell;

end;



procedure TUncertForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
//  Var MR: TModalResult;
begin
//  CanClose := True;
//  MR := MessageDlg('Save Shell before Closing?',mtconfirmation,[mbyes,mbno,mbcancel],0);
//  If MR=MRCancel then CanClose := False;
//  If MR=MRYes then Save1Click(nil);
 {}
end;

procedure TUncertForm.UpBtnClick(Sender: TObject);
Var Distholder:TinputDist;
    SensHolder:TSensParam;
    Loop: Integer;
    SelLoop: Array of Boolean;
begin
 If SensMode
 then With Sim.UncertSetup do
  Begin
    SetLength(SelLoop,NumSens);
    For Loop := 1 to NumSens-1 do
      Begin
        SelLoop[Loop] := DistBox.Selected[Loop+2];
        If DistBox.Selected[Loop+2] then
          Begin
            SensHolder := SensArray[Loop];
            SensArray [Loop] := SensArray [Loop-1];
            SensArray [Loop-1] := SensHolder;
          End;
      End;

    UpdateScreen;

    For Loop := 1 to NumSens-1 do
      DistBox.Selected[Loop+1] := SelLoop[Loop];

    SelLoop := Nil;
  End
 else With Sim.UncertSetup do  {Uncert Mode}
  Begin
    SetLength(SelLoop,NumDists);
    For Loop := 1 to NumDists-1 do
      Begin
        SelLoop[Loop] := DistBox.Selected[Loop+2];
        If DistBox.Selected[Loop+2] then
          Begin
            DistHolder := DistArray[Loop];
            DistArray[Loop] := DistArray[Loop-1];
            DistArray[Loop-1] := DistHolder;
          End;
      End;

    UpdateScreen;

    For Loop := 1 to NumDists-1 do
      DistBox.Selected[Loop+1] := SelLoop[Loop];

    SelLoop := Nil;
  End;
end;

procedure TUncertForm.DownBtnClick(Sender: TObject);
Var Distholder:TinputDist;
    SensHolder:TSensParam;
    Loop: Integer;
    SelLoop: Array of Boolean;
begin

 If SensMode
 then With Sim.UncertSetup do
  Begin
    SetLength(SelLoop,NumSens);

    For Loop := NumSens-2 downto 0 do
      Begin
        SelLoop[Loop] := DistBox.Selected[Loop+2];
        If DistBox.Selected[Loop+2] then
          Begin
            SensHolder := SensArray[Loop];
            SensArray[Loop] := SensArray[Loop+1];
            SensArray[Loop+1] := SensHolder;
          End;
      End;
    UpdateScreen;

    For Loop := NumSens-2 downto 0 do
      DistBox.Selected[Loop+3] := SelLoop[Loop];

    SelLoop := Nil;
  End
 else With Sim.UncertSetup do
  Begin
    SetLength(SelLoop,NumDists);

    For Loop := NumDists-2 downto 0 do
      Begin
        SelLoop[Loop] := DistBox.Selected[Loop+2];
        If DistBox.Selected[Loop+2] then
          Begin
            DistHolder := DistArray[Loop];
            DistArray[Loop] := DistArray[Loop+1];
            DistArray[Loop+1] := DistHolder;
          End;
      End;
    UpdateScreen;

    For Loop := NumDists-2 downto 0 do
      DistBox.Selected[Loop+3] := SelLoop[Loop];

    SelLoop := Nil;
  End;
end;

end.

