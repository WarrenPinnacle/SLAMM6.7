
unit ChangVar;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TChangeVarForm = class(TForm)
    Label5: TLabel;
    EntryList: TListBox;
    Button1: TButton;
    Button2: TButton;
    procedure EntryListDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ChangeVarForm: TChangeVarForm;

implementation

{$R *.DFM}

procedure TChangeVarForm.EntryListDblClick(Sender: TObject);
begin
  ModalResult:=MrOK;
end;

end.
 