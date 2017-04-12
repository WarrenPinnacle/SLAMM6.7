unit SelectListUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TSelectListForm = class(TForm)
    Bevel1: TBevel;
    Label1: TLabel;
    OKBtn: TButton;
    CancelBtn: TButton;
    ComboBox1: TComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SelectListForm: TSelectListForm;

implementation

{$R *.dfm}

end.
