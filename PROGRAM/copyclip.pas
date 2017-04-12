//AQUATOX SOURCE CODE copyright (c) 2009 - 2012 Eco Modeling
//Code Use and Redistribution is Subject to Licensing, SEE AQUATOX_License.txt
// 
unit copyclip;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TCopyClipbd = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    BmpButt: TRadioButton;
    RadioButton2: TRadioButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CopyClipbd: TCopyClipbd;

implementation

{$R *.DFM}

end.
