program Delphi3D_Base;

uses
  Forms,
  GLDraw in '..\GLDraw.pas' {Delphi3DForm},
  DispMode in 'DispMode.pas' {DotDispModeDlg},
  DotWindow in '..\DotWindow.pas',
  DotTmpWin in '..\DotTmpWin.pas' {DotTempWindow},
  GL in '..\GL.pas',
  GLext in '..\GLext.pas',
  DotUtils in '..\DotUtils.pas',
  GLU in '..\GLU.pas',
  DotMath in '..\DotMath.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDotDispModeDlg, DotDispModeDlg);
  Application.CreateForm(TDotTempWindow, DotTempWindow);
  Application.Run;
end.
