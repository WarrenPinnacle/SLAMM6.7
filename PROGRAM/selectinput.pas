unit selectinput;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, UncertDefn;

type
  TSelInput = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    ListBox1: TListBox;
    SubsiteBox: TComboBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    ParamID: Integer;
    { Public declarations }
  end;

var
  SelInput: TSelInput;


implementation

{$R *.DFM}

Uses SLR6;


procedure TSelInput.FormCreate(Sender: TObject);
Var i: Integer;
    TID: TinputDist;
begin
  ListBox1.Clear;

  TID := TInputDist.Create(1,nil,False,-1);
  For i := 1 to NUM_UNCERT_PARAMS do
    ListBox1.Items.Add(TID.NameFromIndex(i));
  TID.Free;
end;

end.
