//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit GISOptions;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls ;

type
  TGISForm = class(TForm)
    Panel1: TPanel;
    WriteEachYear: TRadioButton;
    ChooseYears: TRadioButton;
    Edit1: TEdit;
    Label1: TLabel;
    OKButton: TButton;
    Panel2: TPanel;
    SaveElevationsBox: TCheckBox;
    Panel3: TPanel;
    SaveSalinity: TCheckBox;
    Panel4: TPanel;
    SaveBinary: TCheckBox;
    BElevMTL: TRadioButton;
    BElevNAVD88: TRadioButton;
    Panel5: TPanel;
    SaveInund: TCheckBox;
    procedure OKButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    Function OutputYear(Yr: Integer):Boolean;
    { Public declarations }
  end;

var
  GISForm: TGISForm;

implementation

Uses Global;

{$R *.DFM}


Function TGISForm.OutputYear(Yr: Integer):Boolean;
Var InputNums : String;

Begin
  InputNums := Edit1.Text;

  If WriteEachYear.Checked or (Trim(InputNums)='')
    then OutputYear:=True
    else OutputYear := IntInString(Yr,InputNums);

End;

procedure TGISForm.OKButtonClick(Sender: TObject);
Var InputNums  : String;
    EofFound           : Boolean;
begin
  if (BElevNAVD88.Checked) and (SaveElevationsBox.Checked) then
      MessageDlg( 'If you want to use NAVD88 datum for elevations then subsidence or uplift should not be included in the SLR Curves',mtWarning, [mbOK], 0);

  EOFFound:=False;
  InputNums := Edit1.Text;

  If WriteEachYear.Checked
    then ModalResult := mrok
    else If StringListValid(InputNums) then ModalResult := mrok;

end;

end.
