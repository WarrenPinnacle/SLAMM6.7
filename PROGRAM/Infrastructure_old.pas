//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit Infrastructure_old;

interface

(* 1.  ElevFileN := '';
   2. NWIFileN  := '';
   3. SLPFileN  := '';
   4. IMPFileN  := '';
  ROSFileN  := '';
  DikFileN  := '';
  VDFileN   := '';
  UpliftFileN := '';

  OutputFileN  := '';
 *)

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SLR6, ExtCtrls, Buttons;

type
  TFileSetupForm = class(TForm)
    FileEdit6: TEdit;
    FileEdit7: TEdit;
    FileEdit8: TEdit;
    FileEdit9: TEdit;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    OpenDialog1: TOpenDialog;
    CheckValidityButton: TButton;
    FN6: TLabel;
    FN7: TLabel;
    FN8: TLabel;
    SalFN: TLabel;
    FN9: TLabel;
    OKButton10: TButton;
    CancelButton: TButton;
    HelpButton: TBitBtn;
    Label18: TLabel;
    Label19: TLabel;
    SalRaster: TEdit;
    ButtonSal: TButton;
    SaveButton: TButton;
    Panel1: TPanel;
    Label6: TLabel;
    FN4: TLabel;
    FileEdit4: TEdit;
    Button4: TButton;
    DikeCasePanel: TPanel;
    ClassicDikeCaseRadioButton: TRadioButton;
    DikeLocationCaseRadioButton: TRadioButton;
    Label13: TLabel;
    Panel2: TPanel;
    Label4: TLabel;
    Label14: TLabel;
    FN5: TLabel;
    FileEdit5: TEdit;
    Button5: TButton;
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
    
  private
    Updating: Boolean;
    BElevFileN : String;     //temporary holders to enable cancel button
    BNWIFileN  : String;
    BSLPFileN  : String;
    BIMPFileN  : String;
    BROSFileN  : String;

    BDikFileN  : String;
    BClassicDike : Boolean;

    BVDFileN   : String;
    BUpliftFileN : String;
    BSalFileN : String;     // Salinity file
    BOutputFileN  : String;
    BOptimizeLevel : Word;

    BNumMMEntries : Integer;
    PSS: TSLAMM_Simulation;
    { Private declarations }
  public
    Procedure EditFileInfo(Var SS: TSLAMM_Simulation);
    Procedure UpdateScreen;
    { Public declarations }
  end;

var
  FileSetupForm: TFileSetupForm;

implementation

{$R *.dfm}

uses global, main, System.UITypes;


procedure TFileSetupForm.CancelButtonClick(Sender: TObject);
begin
  If MessageDlg('Cancel all Changes?',mtconfirmation,[mbyes,mbno],0) = MRyes then
    ModalResult := MRCancel;
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
   End;

  Str := TEB.Text;
  OpenDialog1.InitialDir := ExtractFilePath(Str);
  If OpenDialog1.Execute then TEB.Text:=OpenDialog1.Filename;
end;

procedure TFileSetupForm.CheckValidityButtonClick(Sender: TObject);

Const ErrColor = $00A7B4FE;

Var NRows: Double;
    ReadRow, ReadCol: Integer;
    ReadXLL, ReadYLL, ReadCellSize: Double;
    LabelStr: String;



     Function CheckValidity(FileN: String): Boolean;
     Var ReadFile : Textfile;
         ReadStr: String;
     Begin
        If Trim(FileN) = '' then
          Begin
             Result := False;
             LabelStr := 'File Name is Empty.';
             Exit;
          End;

        LabelStr := '';
        Assignfile(ReadFile,FileN);
        Try
          Reset(ReadFile);
        Except
          Result := False;
          LabelStr := 'Invalid Filename';
          Exit;
        End;

        Repeat ReadLn(ReadFile,ReadStr)       {Get rid of header lines if any}
          Until eof(ReadFile) or (Pos('ncols',LowerCase(ReadStr))>0);

        If Pos('ncols',LowerCase(ReadStr))=0 then
          Begin
            LabelStr :=  'File does not include "ncols" identifier.';
            Result := False;
            CloseFile(ReadFile);
            Exit;
          End;

        Delete(ReadStr,Pos('ncols',LowerCase(ReadStr)),5);
        ReadCol:=StrToInt(ReadStr);

        {------------------------------------}
        ReadLn(ReadFile,ReadStr);
        Delete(ReadStr,Pos('nrows',LowerCase(ReadStr)),5);
        ReadRow:=StrToInt(ReadStr);
        {------------------------------------}
        ReadLn(ReadFile,ReadStr);
        Delete(ReadStr,Pos('xllcorner',LowerCase(ReadStr)),9);
        ReadXLL:=Round(StrToFloat(ReadStr));
        {------------------------------------}
        ReadLn(ReadFile,ReadStr);
        Delete(ReadStr,Pos('yllcorner',LowerCase(ReadStr)),9);
        ReadYLL:=Round(StrToFloat(ReadStr));
        {------------------------------------}
        ReadLn(ReadFile,ReadStr);
        Delete(ReadStr,Pos('cellsize',LowerCase(ReadStr)),8);
        ReadCellSize:=StrToFloat(ReadStr);
        {------------------------------------}
        If NRows < 0 then
          begin
            NRows := ReadRow;
            If (PSS.Site.Rows <> ReadRow) or
               (PSS.Site.Cols <> ReadCol)
              then
               Begin
                 BNumMMEntries := 0;   {set count to zero as file size has changed}
                 PSS.Site.Rows      := ReadRow;
                 PSS.Site.Cols      := ReadCol;
               End;
            PSS.Site.LLXCorner := ReadXLL;
            PSS.Site.LLYCorner := ReadYLL;
            PSS.Site.Scale     := ReadCellSize;
            Result := True;
          end
         else
           Begin
             if PSS.Site.Rows <> ReadRow then LabelStr := 'File Num Rows is different.'
               else if PSS.Site.Cols <> ReadCol then LabelStr := 'File Num Cols. is different.'
               else if PSS.Site.LLXCorner <> ReadXLL then LabelStr := 'File Lower Left Corner X is different.'
               else if PSS.Site.LLYCorner <> ReadYLL then LabelStr := 'File Lower Left Corner Y is different.'
               else if PSS.Site.Scale     <> ReadCellSize then LabelStr := 'File Cell Size is different.';
             Result := LabelStr = '';
           End;

         LabelStr := 'NRows: '+IntToStr(ReadRow)+', NCols: ' +IntToStr(ReadCol)+'. '+LabelStr;
         CloseFile(ReadFile);
     End;

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
       FN4.Caption := LabelStr;
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
       If Not CheckValidity(BSalFileN) then SalRaster.Color := ErrColor;
       SalFN.Caption := LabelStr + '  This base name should be the initial condition.  For other years place the year before the file extension.';
     End else SalFN.Caption := 'No Salinity Raster File Selected.  The initial condition file should be specified here.  ';

     FN1.Visible := True;
     FN2.Visible := True;
     FN3.Visible := True;
     FN4.Visible := True;
     FN5.Visible := True;
     FN6.Visible := True;
     FN7.Visible := True;
     FN8.Visible := True;
     SalFN.Visible := True;
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

    BElevFileN := SS.ElevFileN;
    BNWIFileN  := SS.NWIFileN;
    BSLPFileN  := SS.SLPFileN;
    BIMPFileN  := SS.IMPFileN;
    BROSFileN  := SS.ROSFileN;

    BDikFileN  := SS.DikFileN;
    BClassicDike := SS.ClassicDike;

    BVDFileN   := SS.VDFileN;
    BUpliftFileN := SS.UpliftFileN;
    BSalFileN := SS.SalFileN;
    BOutputFileN  := SS.OutputFileN;
    BOptimizeLevel := SS.OptimizeLevel;
    BNumMMEntries := SS.NumMMEntries;

    FN1.Visible := False;
    FN2.Visible := False;
    FN3.Visible := False;
    FN4.Visible := False;
    FN5.Visible := False;
    FN6.Visible := False;
    FN7.Visible := False;
    FN8.Visible := False;
    SalFN.Visible := False;

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

    If ShowModal = MROK then
      Begin
        SS.ElevFileN := BElevFileN;
        SS.NWIFileN := BNWIFileN ;
        SS.SLPFileN := BSLPFileN ;
        SS.IMPFileN := BIMPFileN ;
        SS.ROSFileN := BROSFileN ;

        SS.DikFileN := BDikFileN ;
        SS.ClassicDike := BClassicDike ;

        SS.VDFileN := BVDFileN  ;
        SS.UpliftFileN := BUpliftFileN;
        SS.SalFileN := BSalFileN;
        SS.OutputFileN := BOutputFileN ;
        SS.OptimizeLevel := BOptimizeLevel;
        SS.NumMMEntries := BNumMMEntries;
        SS.Changed := True;
      End;

    MainForm.UpdateScreen;

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
   If Sender=FileEdit7 then BVDFileN := FileEdit7.Text;
   If Sender=FileEdit8 then BUpliftFileN := FileEdit8.Text;
   If Sender=FileEdit9 then BOutputFileN := FileEdit9.Text;
   if Sender=SalRaster then BSalFileN := SalRaster.Text;

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
MainForm.SaveSimClick(Sender);
CancelButton.Enabled :=  False;
end;

procedure TFileSetupForm.UpdateScreen;
begin
    Updating := True;
    FileEdit1.Text := BElevFileN;
    FileEdit2.Text := BNWIFileN;
    FileEdit3.Text := BSLPFileN;
    FileEdit4.Text := BDikFileN;
    FileEdit5.Text := BIMPFileN;
    FileEdit6.Text := BROSFileN;
    FileEdit7.Text := BVDFileN;
    FileEdit8.Text := BUpliftFileN;
    SalRaster.Text := BSalFileN;
    FileEdit9.Text := BOutputFileN;

    If BOptimizeLevel=0 then Opt0.Checked := True;
    If BOptimizeLevel=1 then Opt1.Checked := True;
    If BOptimizeLevel=2 then Opt2.Checked := True;

    if BClassicDike then ClassicDikeCaseRadioButton.Checked := True
                    else DikeLocationCaseRadioButton.Checked := True;

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
