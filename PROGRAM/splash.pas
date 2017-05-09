//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//
unit Splash;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, OleCtrls, GIFImg;

type
  TSplashForm = class(TForm)
    Panel2: TPanel;
    Panel1: TPanel;
    Label1: TLabel;
    ProgramIcon: TImage;
    VersionInfo: TLabel;
    ProductName: TLabel;   // SLAMM 6.7  Change caption in ProductName here
    Label4: TLabel;
    LicenseButton: TButton;
    ExitButton: TButton;
    SourceCode: TButton;
    SourceCodePanel: TPanel;
    Label2: TLabel;
    Button1: TButton;
    InfoButton: TButton;
    Image1: TImage;
    Label3: TLabel;
    procedure FormClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure LicenseButtonClick(Sender: TObject);
    procedure SourceCodeClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure InfoButtonClick(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure ProgramIconClick(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
  end;

var
  SplashForm: TSplashForm;

implementation

USes Global, ShellAPI;

{$R *.DFM}

function ExecuteFile(const FileName, Params, DefaultDir: string;
  ShowCmd: Integer): THandle;
var
  zFileName, zParams, zDir: array[0..254] of Char;
begin
  Result := ShellExecute(Application.MainForm.Handle, nil,
    StrPCopy(zFileName, FileName), StrPCopy(zParams, Params),
    StrPCopy(zDir, DefaultDir), ShowCmd);
end;



procedure TSplashForm.LicenseButtonClick(Sender: TObject);
begin
  ExecuteFile('NOTEPAD.EXE', ExtractFilePath( Application.ExeName )+'SLAMM_License.txt','',SW_SHOW);
end;

procedure TSplashForm.ProgramIconClick(Sender: TObject);
begin
   ShellExecute(self.WindowHandle,'open','http://www.warrenpinnacle.com/prof',nil,nil,SW_SHOWNORMAL);
end;

procedure TSplashForm.SourceCodeClick(Sender: TObject);
begin
  SourceCodePanel.Visible := not SourceCodePanel.Visible;
end;

procedure TSplashForm.Button1Click(Sender: TObject);
begin
   ShellExecute(self.WindowHandle,'open','https://github.com/WarrenPinnacle/SLAMM6.7',nil,nil,SW_SHOWNORMAL);
end;

procedure TSplashForm.FormClick(Sender: TObject);
begin
  ModalResult:=MROK;
end;

procedure TSplashForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  ModalResult:=MROK;
end;

procedure TSplashForm.Image1Click(Sender: TObject);
begin
   ShellExecute(self.WindowHandle,'open','http://www.opensource.org/',nil,nil,SW_SHOWNORMAL);
end;

procedure TSplashForm.InfoButtonClick(Sender: TObject);
begin
    ExecuteFile('NOTEPAD.EXE',ExtractFilePath( Application.ExeName )+'Readme.txt','',SW_SHOW);
end;

end.
