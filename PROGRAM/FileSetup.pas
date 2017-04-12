//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit FileSetup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SLR6, ExtCtrls, Buttons;

type
  TFileSetupForm = class(TForm)
    FileEdit1: TEdit;
    FileEdit2: TEdit;
    FileEdit3: TEdit;
    FileEdit4: TEdit;
    FileEdit5: TEdit;
    FileEdit6: TEdit;
    FileEdit7: TEdit;
    FileEdit8: TEdit;
    FileEdit9: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    OpenDialog1: TOpenDialog;
    CheckValidityButton: TButton;
    FN1: TLabel;
    FN2: TLabel;
    FN3: TLabel;
    FN4: TLabel;
    FN5: TLabel;
    FN6: TLabel;
    FN7: TLabel;
    FN8: TLabel;
    SalFN: TLabel;
    FN9: TLabel;
    OKButton10: TButton;
    CancelButton: TButton;
    Panel1: TPanel;
    Opt0: TRadioButton;
    Opt1: TRadioButton;
    Opt2: TRadioButton;
    countlabel: TLabel;
    CountButton: TButton;
    memlabel: TLabel;
    HelpButton: TBitBtn;
    Label18: TLabel;
    Label19: TLabel;
    SalRaster: TEdit;
    ButtonSal: TButton;
    DikeCasePanel: TPanel;
    ClassicDikeCaseRadioButton: TRadioButton;
    DikeLocationCaseRadioButton: TRadioButton;
    SaveButton: TButton;
    InfStructButton: TButton;
    Label20: TLabel;
    Label21: TLabel;
    D2MFN: TLabel;
    D2MRaster: TEdit;
    ButtonD2M: TButton;
    SAVParametersButton: TButton;
    Binary1: TButton;
    Binary2: TButton;
    Binary3: TButton;
    Binary4: TButton;
    Binary5: TButton;
    Binary6: TButton;
    Binary7: TButton;
    Binary8: TButton;
    BinarySal: TButton;
    BinaryD2M: TButton;
    Button10: TButton;
    Label22: TLabel;
    Label23: TLabel;
    SSnote: TLabel;
    SSEdit: TEdit;
    ButtonZtorm: TButton;
    BinaryZtorm: TButton;
    CANote: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure CheckValidityButtonClick(Sender: TObject);
    procedure FileEdit9Change(Sender: TObject);
    procedure CountButtonClick(Sender: TObject);
    procedure Opt0Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure DikeCaseRadioButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure InfStructButtonClick(Sender: TObject);
    procedure UpdateFileN(var PSS: TSLAMM_Simulation);
    procedure SAVParametersButtonClick(Sender: TObject);
    procedure Binary1Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    
  private
    Updating: Boolean;
    BElevFileN : String;     //temporary holders to enable cancel button
    BNWIFileN  : String;
    BSLPFileN  : String;
    BIMPFileN  : String;
    BROSFileN  : String;

    BDikFileN  : String;
    BClassicDike : Boolean;
    BStormFileN : String;
    BVDFileN   : String;
    BUpliftFileN : String;
    BSalFileN : String;     // Salinity file
    BD2MFileN : String; // D2Mouth Raster for SAV

    BOutputFileN  : String;
    BOptimizeLevel : Word;

    BNumMMEntries : Integer;
    BInit_ElevStats : Boolean;
    PSS: TSLAMM_Simulation;

    { Private declarations }
  public
    Procedure EditFileInfo(Var SS: TSLAMM_Simulation);
    Procedure UpdateScreen;
//    Function CheckFileValidity: Boolean;
    { Public declarations }
  end;

var
  FileSetupForm: TFileSetupForm;

implementation

{$R *.dfm}


uses global, main, System.UITypes, SalArray, Infr_Form, SAVParams, Binary_Files,
  Binary_Convert;


procedure TFileSetupForm.CancelButtonClick(Sender: TObject);
begin
  If MessageDlg('Cancel all Changes?',mtconfirmation,[mbyes,mbno],0) = MRyes then
    ModalResult := MRCancel;
end;

procedure TFileSetupForm.Binary1Click(Sender: TObject);
Var SIF: TSLAMMInputFile;
    TEB: TEdit;
begin
  TEB := nil;
  Case TButton(Sender).Name[7] of
    '1': TEB := FileEdit1;
    '2': TEB := FileEdit2;
    '3': TEB := FileEdit3;
    '4': TEB := FileEdit4;
    '5': TEB := FileEdit5;
    '6': TEB := FileEdit6;
    '7': TEB := FileEdit7;
    '8': TEB := FileEdit8;
    '9': TEB := FileEdit9;
    'S': TEB := SalRaster;
    'Z': TEB := SSEdit;
    'D': TEB := D2MRaster;
   End;

  SIF := TSLAMMInputFile.Create(TEB.Text);
  If SIF.ConvertToBinary then TEB.Text := SIF.ConvertedFileN;
  SIF.Destroy;

end;

procedure TFileSetupForm.Button10Click(Sender: TObject);
begin
  Binary_Conv_Form.ShowModal;
end;

procedure TFileSetupForm.Button1Click(Sender: TObject);
Var TEB: TEdit;
    Str: String;
begin
  TEB := nil;
  Case TButton(Sender).Name[7] of
    '1': TEB := FileEdit1;
    '2': TEB := FileEdit2;
    '3': TEB := FileEdit3;
    '4': TEB := FileEdit4;
    '5': TEB := FileEdit5;
    '6': TEB := FileEdit6;
    '7': TEB := FileEdit7;
    '8': TEB := FileEdit8;
    '9': TEB := FileEdit9;
    'S': TEB := SalRaster;
    'D': TEB := D2MRaster;
    'Z': TEB := SSEdit;
   End;

  Str := TEB.Text;
  OpenDialog1.InitialDir := ExtractFilePath(Str);
  If OpenDialog1.Execute then TEB.Text:=OpenDialog1.Filename;
end;

procedure TFileSetupForm.CheckValidityButtonClick(Sender: TObject);

Const ErrColor = $00A7B4FE;

Var NRows: Double;
    LabelStr: String;
    ErrMsg: String;
    SIF: TSLAMMInputFile;


     Function CheckValidity(FileN: String; StormSurge: Boolean): Boolean; overload;
     Var StormString, SLRStr, ReturnStr: String;
     Begin
        If Trim(FileN) = '' then
          Begin
             Result := False;
             LabelStr := 'File Name is Empty.';
             Exit;
          End;

        if Not FileExists(FileN) then
          Begin
            Result := False;
            LabelStr := 'Invalid Filename';
            Exit;
          End;

        LabelStr := '';

        SIF := TSLAMMInputFile.Create(FileN);
        if Not SIF.PrepareFileForReading(ErrMsg) then
          Begin
            Result := False;
            LabelStr := ErrMsg;
            SIF.Destroy;
            Exit;
          End;

        {------------------------------------}
        If NRows < 0 then
          begin
            NRows := SIF.fRow;
            If (PSS.Site.ReadRows <> SIF.fRow) or
               (PSS.Site.ReadCols <> SIF.fCol)
              then
               Begin
                 BNumMMEntries := 0;   {set count to zero as file size has changed}
                 PSS.Site.ReadRows      := SIF.fRow;
                 PSS.Site.ReadCols      := SIF.fCol;
               End;
            PSS.Site.LLXCorner := SIF.fXLLCorner;
            PSS.Site.LLYCorner := SIF.fYLLCorner;
            PSS.Site.ReadScale     := SIF.fCellSize;
            Result := True;
          end
         else
           Begin
             if PSS.Site.ReadRows <> SIF.fRow then LabelStr := 'File Num Rows is different.'
               else if PSS.Site.ReadCols <> SIF.fCol then LabelStr := 'File Num Cols. is different.'
               else if PSS.Site.LLXCorner <> SIF.fXLLCorner then LabelStr := 'File Lower Left Corner X is different.'
               else if PSS.Site.LLYCorner <> SIF.fYLLCorner then LabelStr := 'File Lower Left Corner Y is different.'
               else if PSS.Site.ReadScale     <> SIF.fCellSize then LabelStr := 'File Cell Size is different.';
             Result := LabelStr = '';
           End;

         LabelStr := 'NRows: '+IntToStr(SIF.fRow)+', NCols: ' +IntToStr(SIF.fCol)+'. '+LabelStr;

         SIF.Destroy;

         If Result and StormSurge then
           Begin
             If LastDelimiter('.',FileN) > 0
              then StormString := Copy(FileN, 0, LastDelimiter('.',FileN) - 1)
              else StormString := FileN;
             ReturnStr := Copy(StormString,Length(StormString)-2,3);
             SLRStr := Copy(StormString,Length(StormString)-5,2);
             If (ReturnStr<>'100') and (ReturnStr<>'010') then
               Begin
                 Result := False;
                 LabelStr := 'Expect 100 or 010 as last three characters of file name to denote storm return';
               End;
             If Result and (SLRStr<>'00') then
               Begin
                 Result := False;
                 LabelStr := 'Expect 00 prior to storm return characters to reflect zero SLR in base file';
               End;
           End;
     End;

     Function CheckValidity(FileN: String): Boolean; overload;
     Begin
       Result := CheckValidity(FileN,False);
     End;


//Var TSA :TSalArray;
Begin

   NRows := -1;

   FileEdit1.Color := ClWindow;
   If Not CheckValidity(BElevFileN) then FileEdit1.Color := ErrColor;
   FN1.Caption := LabelStr;

   FileEdit2.Color := ClWindow;
   If Not CheckValidity(BNWIFileN) then FileEdit2.Color := ErrColor;
   FN2.Caption := LabelStr;

   FileEdit3.Color := ClWindow;
   If Not CheckValidity(BSLPFileN) then FileEdit3.Color := ErrColor;
   FN3.Caption := LabelStr;

   FileEdit4.Color := ClWindow;
   If Trim(BDikFileN) <> '' then
     Begin
       If Not CheckValidity(BDikFileN) then FileEdit4.Color := ErrColor;
       FN4.Caption := LabelStr; // +' '+BDikFileN;
     End else FN4.Caption := 'No Dike File Selected, assuming no dikes or levees present';

   FileEdit5.Color := ClWindow;
   If Trim(BIMPFileN) <> '' then
     Begin
       If Not CheckValidity(BIMPFileN) then FileEdit5.Color := ErrColor;
       FN5.Caption := LabelStr;
     End else FN5.Caption := 'No Percent Impervious File Selected, using assigned slamm category for dev./undev. land';

   FileEdit6.Color := ClWindow;
   If Trim(BROSFileN) <> '' then
     Begin
       If Not CheckValidity(BROSFileN) then FileEdit6.Color := ErrColor;
       FN6.Caption := LabelStr;
     End else FN6.Caption := 'No Raster Output File Selected, outputs will not be summarized by raster coverage';

   FileEdit7.Color := ClWindow;
   If Trim(BVDFileN) <> '' then
     Begin
       If Not CheckValidity(BVDFileN) then FileEdit7.Color := ErrColor;
       FN7.Caption := LabelStr;
     End else FN7.Caption := 'No VDATUM Correction File Selected, using MTL-NAVD corrections in site/subsite records.';

   FileEdit8.Color := ClWindow;
   If Trim(BUpliftFileN) <> '' then
     Begin
       If Not CheckValidity(BUpliftFileN) then FileEdit8.Color := ErrColor;
       FN8.Caption := LabelStr;
     End else FN8.Caption := 'No Raster Uplift/Subsidence Map Selected, using Historic Trend to estimate land movement.';

   SalRaster.Color := ClWindow;
   If Trim(BSalFileN) <> '' then
     Begin
      if Pos('.xls',lowercase(BSalFileN))=0
       then
         Begin
           If Not CheckValidity(BSalFileN) then SalRaster.Color := ErrColor;
           SalFN.Caption := LabelStr + '  This base name is the initial condition.  For other years add the year before the file extension.';
         End
       else //XLS Salinity File
        Begin
          If Not(FileExists(BSalFileN))
          then Begin
                 SalRaster.Color := ErrColor;
                 SalFN.Caption := 'Excel Salinity File not found';
               End
          else Begin
                 PSS.ScaleCalcs;
                 TSalArray.ReadSalArrayfromExcel(BSalFileN,PSS.Site);
                 SalFN.Caption := 'Excel Salinity File Appears Readable.';
               End;
        End;
     End else SalFN.Caption := 'No Salinity Raster File Selected.  The initial condition file should be specified here.  ';

   D2MRaster.Color := ClWindow;
   If Trim(BD2MFileN) <> '' then
     Begin
       If Not CheckValidity(BD2MFileN) then D2MRaster.Color := ErrColor;
       D2MFN.Caption := LabelStr;
     End else D2MFN.Caption := 'No D2Mouth Map Selected; SAV estimates will not be calculated.';


   // Check validity of the files in the infrastructure setup form
   with InfStructFileSetup do
    begin
      DikeFileEdit.Color :=ClWindow;
      If Trim(BDikFileN) <> '' then
        Begin
          If Not CheckValidity(BDikFileN) then DikeFileEdit.Color := ErrColor;
          FN1.Caption := LabelStr;
        End
      else FN1.Caption := 'No Dike File Selected, assuming no dikes or levees present';


   SSEdit.Color := ClWindow;
   If Trim(BStormFileN) <> '' then
     Begin
       If Not CheckValidity(BStormFileN, True) then SSEdit.Color := ErrColor;
       SSNote.Caption := LabelStr;
     End else SSnote.Caption := 'No Storm Surge File Selected: Storm Levels taken from Subsite Data.  FileN should end with _00_010.ASC or _00_100.ASC';


(*      RoadFileEdit.Color :=ClWindow;
      If Trim(BRoadFileN) <> '' then
        Begin
          If Not FileExists(BRoadFileN) then
            Begin
              RoadFileEdit.Color := ErrColor;
              RoadFN.Caption := 'Cannot Find CSV Roads File Specified';
            End else RoadFN.Caption := 'CSV File Located';
        End
      else RoadFN.Caption := 'No Road File Selected, assuming no roads inundation study'; *)
     end;

   FN1.Visible := True;
   FN2.Visible := True;
   FN3.Visible := True;
   FN4.Visible := True;
   FN5.Visible := True;
   FN6.Visible := True;
   FN7.Visible := True;
   FN8.Visible := True;
   SalFN.Visible := True;
   D2MFN.Visible := False;

   InfStructFileSetup.FN1.Visible := True;
   InfStructFileSetup.RoadFN.Visible := True;

end;

procedure TFileSetupForm.DikeCaseRadioButtonClick(Sender: TObject);
begin
  If Updating then Exit;

  BClassicDike := ClassicDikeCaseRadioButton.Checked;

  UpdateScreen;
end;

procedure TFileSetupForm.CountButtonClick(Sender: TObject);
Var OldOLevel : Word;
    OldMMEntries: Integer;
    BakName1, BakName2, BakName3: String;
begin
  BakName1 := PSS.ElevFileN;
  BakName2 := PSS.NWIFileN;
  BakName3 :=PSS.SLPFileN;

  PSS.ElevFileN := BElevFileN;
  PSS.NWIFileN := BNWIFileN ;
  PSS.SLPFileN := BSLPFileN ;

  OldOLevel := PSS.OptimizeLevel;
  OldMMEntries := PSS.NumMMEntries;

  PSS.OptimizeLevel := BOptimizeLevel;

  //PSS.ClassicDike :=    BClassicDike;            // marco - maybe not necessary

  PSS.Count_MMEntries;
  BNumMMEntries := PSS.NumMMEntries;

  PSS.OptimizeLevel := OldOLevel;
  PSS.NumMMEntries := OldMMEntries;

  PSS.ElevFileN := BakName1;
  PSS.NWIFileN := BakName2;
  PSS.SLPFileN := BakName3 ;

  UpdateScreen;
end;

procedure TFileSetupForm.EditFileInfo(var SS: TSLAMM_Simulation);
begin
    PSS := SS;

    BElevFileN := PSS.ElevFileN;
    BNWIFileN  := PSS.NWIFileN;
    BSLPFileN  := PSS.SLPFileN;
    BIMPFileN  := PSS.IMPFileN;
    BROSFileN  := PSS.ROSFileN;

    BDikFileN  := PSS.DikFileN;
    BStormFileN := PSS.StormFileN;
    BClassicDike := PSS.ClassicDike;


    BVDFileN   := PSS.VDFileN;
    BUpliftFileN := PSS.UpliftFileN;
    BSalFileN := PSS.SalFileN;

//    InfStructFileSetup.BRoadFileN := PSS.RoadFileN;
    BD2MFileN := PSS.D2MFileN;

    BOutputFileN  := PSS.OutputFileN;
    BOptimizeLevel := PSS.OptimizeLevel;
    BNumMMEntries := PSS.NumMMEntries;

    BInit_ElevStats := PSS.Init_ElevStats;

    FN1.Visible := False;
    FN2.Visible := False;
    FN3.Visible := False;
    FN4.Visible := False;
    FN5.Visible := False;
    FN6.Visible := False;
    FN7.Visible := False;
    FN8.Visible := False;
    SalFN.Visible := False;
    D2MFN.Visible := False;

    FileEdit1.Color := ClWindow;
    FileEdit2.Color := ClWindow;
    FileEdit3.Color := ClWindow;
    FileEdit4.Color := ClWindow;
    FileEdit5.Color := ClWindow;
    FileEdit6.Color := ClWindow;
    FileEdit7.Color := ClWindow;
    FileEdit8.Color := ClWindow;
    SalRaster.Color := ClWindow;

    CheckValidityButtonClick(nil);

    UpdateScreen;

    If (ShowModal = MROK) then
      Begin
        UpdateFileN(PSS);
        if CancelButton.Enabled = True then SS.Changed := True;
        SS := PSS;
      End;

    MainForm.UpdateScreen;

end;

procedure TFileSetupForm.UpdateFileN(var PSS: TSLAMM_Simulation);
begin
 PSS.ElevFileN := BElevFileN;
 PSS.NWIFileN := BNWIFileN ;
 PSS.SLPFileN := BSLPFileN ;
 PSS.IMPFileN := BIMPFileN ;
 PSS.ROSFileN := BROSFileN ;

 PSS.DikFileN := BDikFileN ;
 PSS.StormFileN := BStormFileN ;
 PSS.ClassicDike := BClassicDike ;

 PSS.VDFileN := BVDFileN  ;
 PSS.UpliftFileN := BUpliftFileN;
 PSS.SalFileN := BSalFileN;

// PSS.RoadFileN := InfStructFileSetup.BRoadFileN;

 PSS.D2MFileN := BD2MFileN;
 if (trim(PSS.D2MFileN)='') then PSS.SAVMaps := False;

 PSS.OutputFileN := BOutputFileN ;
 PSS.OptimizeLevel := BOptimizeLevel;
 PSS.NumMMEntries := BNumMMEntries;

 PSS.Init_ElevStats := BInit_ElevStats;
end;

procedure TFileSetupForm.FileEdit9Change(Sender: TObject);
begin
   If Updating then Exit;

   If Sender=FileEdit1 then BElevFileN := FileEdit1.Text;
   If Sender=FileEdit2 then BNWIFileN := FileEdit2.Text;
   If Sender=FileEdit3 then BSLPFileN := FileEdit3.Text;
   If Sender=FileEdit4 then BDikFileN := FileEdit4.Text;
   If Sender=FileEdit5 then BIMPFileN := FileEdit5.Text;
   If Sender=FileEdit6 then BROSFileN := FileEdit6.Text;
   If Sender=FileEdit7 then BVDFileN  := FileEdit7.Text;
   If Sender=FileEdit8 then BUpliftFileN := FileEdit8.Text;
   If Sender=FileEdit9 then BOutputFileN := FileEdit9.Text;
   if Sender=SalRaster then BSalFileN := SalRaster.Text;
   if Sender=D2MRaster then BD2MFileN := D2MRaster.Text;
   If Sender=SSEdit    then BStormFileN := SSEdit.Text;

   if (Sender=FileEdit1) or (Sender=FileEdit2) or(Sender=FileEdit3) or(Sender=FileEdit4) or
   (Sender=FileEdit5) or(Sender=FileEdit6) or(Sender=FileEdit7) then
    BInit_ElevStats := False;

   CancelButton.Enabled := True;
end;

procedure TFileSetupForm.FormCreate(Sender: TObject);
begin
  Updating := False;
end;

procedure TFileSetupForm.HelpButtonClick(Sender: TObject);
begin
   Application.HelpContext(1007 );  //'FileSetup.html');
end;

procedure TFileSetupForm.InfStructButtonClick(Sender: TObject);
begin
InfStructFileSetup.EditFileInfo(PSS);
end;

procedure TFileSetupForm.Opt0Click(Sender: TObject);
Var OldOL: Word;
begin
  If Updating then Exit;
  OldOL := BOptimizeLevel;
  If Opt0.Checked then BOptimizeLevel := 0;
  If Opt1.Checked then BOptimizeLevel := 1;
  If Opt2.Checked then BOptimizeLevel := 2;

  If OldOL <> BOptimizeLevel then BNumMMEntries := 0;

  UpdateScreen;
end;

procedure TFileSetupForm.SaveButtonClick(Sender: TObject);
begin
UpdateFileN(PSS);
MainForm.SS := PSS;
MainForm.SaveSimClick(Sender);
CancelButton.Enabled :=  False;
end;

procedure TFileSetupForm.SAVParametersButtonClick(Sender: TObject);
begin
  SAVParamForm.EditSAVParams(PSS.SAVParams);
end;

procedure TFileSetupForm.UpdateScreen;
begin
    Updating := True;
    FileEdit1.Text := BElevFileN;
    FileEdit2.Text := BNWIFileN;
    FileEdit3.Text := BSLPFileN;
    FileEdit4.Text := BDikFileN;
    SSEdit.Text    := BStormFileN;
    FileEdit5.Text := BIMPFileN;
    FileEdit6.Text := BROSFileN;
    FileEdit7.Text := BVDFileN;
    FileEdit8.Text := BUpliftFileN;
    SalRaster.Text := BSalFileN;
    D2MRaster.Text := BD2MFileN;
    FileEdit9.Text := BOutputFileN;

    If BOptimizeLevel=0 then Opt0.Checked := True;
    If BOptimizeLevel=1 then Opt1.Checked := True;
    If BOptimizeLevel=2 then Opt2.Checked := True;

    if BClassicDike then ClassicDikeCaseRadioButton.Checked := True
                    else DikeLocationCaseRadioButton.Checked := True;

    CANote.Visible := PSS.Categories.AreCalifornia;

    If BNumMMEntries > 1
      then CountLabel.Caption := 'Cells to Track: '+FloatToStrF(BNumMMEntries,ffNumber,12,0)
      else CountLabel.Caption := 'Cells to Track: Unknown';
    If BNumMMEntries > 1
      then MemLabel.Caption := 'Memory Utilization in GB: '
            +FloatToStrF(Sizeof(CompressedCell)/1024/1024/1024*BNumMMEntries,ffgeneral,8,3)
      else MemLabel.Caption := '';
    Updating := False;

    Update;
end;

end.
