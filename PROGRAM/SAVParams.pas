//SLAMM SOURCE CODE Copyright (c) 2009 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit SAVParams;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Main, StdCtrls, Grids, Menus, ExtCtrls, Clipbrd, Global, SLR6,
  Buttons;

type
  TSAVParamForm = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    ModLabel: TLabel;
    Panel1: TPanel;
    EditA: TEdit;
    DEM: TLabel;
    Intercept: TLabel;
    EditB: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    EditC: TEdit;
    EditD: TEdit;
    Label3: TLabel;
    Label5: TLabel;
    EditE: TEdit;
    EditF: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    EditG: TEdit;
    EditH: TEdit;
    DefaultsButt: TButton;
    procedure CancelBtnClick(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure DefaultsButtClick(Sender: TObject);
  private
    IsUpdating : Boolean;
    { Private declarations }
  public
    Procedure EditSAVParams(Var SAVParams: SAVParamsRec);
    Procedure UpdateScreen();
    { Public declarations }
  end;

var
  SAVParamForm: TSAVParamForm;
  EditParams: SAVParamsRec;

implementation

uses System.UITypes;

{$R *.dfm}


Procedure TSAVParamForm.CancelBtnClick(Sender: TObject);
begin
  If MessageDlg('Cancel all Changes?',mtconfirmation,[mbyes,mbno],0) = MRyes then
    ModalResult := MRCancel;
end;



procedure TSAVParamForm.HelpButtonClick(Sender: TObject);
begin
//   Application.HelpContext( 1011);  //'Freshwaterflow.html');
end;

procedure TSAVParamForm.DefaultsButtClick(Sender: TObject);
Begin
      With EditParams do
        Begin
           Intcpt := 0;
           C_DEM := 0;
           C_DEM2 := 0;
           C_DEM3 := 0;
           C_D2MLLW :=0;
           C_D2MHHW :=0;
           C_D2M := 0;
           C_D2M2:= 0;   //default coefficients for SAV estimation -- Removed 8-20-2014 at USGS request -- JSC
        End;
      UpdateScreen;
End;

procedure TSAVParamForm.EditExit(Sender: TObject);
Var
Conv: Double;
Result: Integer;

begin
  If IsUpdating then exit;
  Val(Trim(TEdit(Sender).Text),Conv,Result);
  If Result<>0 then MessageDlg('Incorrect Numerical Format Entered',mterror,[mbOK],0)
           else With EditParams do begin
                   case TEdit(Sender).Name[5] of
                      'A': Intcpt:= Conv;
                      'B': C_DEM := Conv;
                      'C': C_DEM2 := Conv;
                      'D': C_DEM3 := Conv;
                      'E': C_D2MLLW := Conv;
                      'F': C_D2MHHW := Conv;
                      'G': C_D2M := Conv;
                      'H' : C_D2M2 := Conv;
                    end; {case}
                end; {else}
    UpdateScreen;
end;

procedure TSAVParamForm.EditSAVParams(var SAVParams: SAVParamsRec);
begin
  EditParams := SAVParams;
  UpdateScreen;
  if ShowModal = MROK then SAVParams := EditParams;
end;

Procedure TSAVParamForm.UpdateScreen;
Begin
  With EditParams do
    Begin
      EditA.Text := FloatToStrF(Intcpt,FFGeneral,6,4);
      EditB.Text := FloatToStrF(C_DEM,FFGeneral,6,4);
      EditC.Text := FloatToStrF(C_DEM2,FFGeneral,6,4);
      EditD.Text := FloatToStrF(C_DEM3,FFGeneral,6,4);
      EditE.Text := FloatToStrF(C_D2MLLW,FFGeneral,6,4);
      EditF.Text := FloatToStrF(C_D2MHHW,FFGeneral,6,4);
      EditG.Text := FloatToStrF(C_D2M,FFGeneral,6,4);
      EditH.Text := FloatToStrF(C_D2M2,FFGeneral,6,4);
    End;
End;



end.
