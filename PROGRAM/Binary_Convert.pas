unit Binary_Convert;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ShellAPI, Binary_Files ;

type
  TBinary_Conv_Form = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    Procedure AcceptFiles2(var msg: TMessage); message WM_DROPFILES;
    { Public declarations }
  end;

var
  Binary_Conv_Form: TBinary_Conv_Form;

implementation

{$R *.dfm}

Procedure TBinary_Conv_Form.AcceptFiles2(var msg: TMessage);
const cnMaxFileNameLen = 255;
var
  SIF : TSLAMMInputFile;
  i,
  nCount     : integer;
  IsSLB : Boolean;
  ResultStr: String;
  acFileName : array [0..cnMaxFileNameLen] of char;
begin
  nCount := DragQueryFile( msg.WParam, $FFFFFFFF, acFileName, cnMaxFileNameLen );   // find out how many files we're accepting
  Memo1.Clear;

  for i := 0 to nCount-1 do   // query Windows one at a time for the file name
  begin
    DragQueryFile( msg.WParam, i, acFileName, cnMaxFileNameLen );
    SIF := TSLAMMInputFile.Create(acFileName);

    IsSLB := (POS('SLB',ExtractFileExt(acFileName))>0);
    If IsSLB then SIF.ConvertToAscii(ResultStr)
             else if SIF.ConvertToBinary then ResultStr := 'Successfully Converted '+acfilename
                                         else ResultStr := 'ERROR Converting '+acfilename;
    Memo1.Lines.Add(ResultStr);
    Update;

  end;

  DragFinish( msg.WParam );

end;


procedure TBinary_Conv_Form.FormCreate(Sender: TObject);
begin
   DragAcceptFiles( Handle, True );
end;

end.
