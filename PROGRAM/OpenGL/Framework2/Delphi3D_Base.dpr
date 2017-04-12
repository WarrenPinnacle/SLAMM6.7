program Delphi3D_Base;

uses
  Forms,
  Main in 'Main.pas' {Delphi3DForm},
  DotWindow in '..\DotWindow.pas',
  GLext in '..\GLext.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDelphi3DForm, Delphi3DForm);
  Application.Run;
end.
