//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit SalRuleEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Main, StdCtrls, Grids, Menus, ExtCtrls, Clipbrd, Global, SLR6,
  Buttons, System.UITypes;

type
  TSalRuleForm = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    ModLabel: TLabel;
    NameLabel: TLabel;
    NotesEdit: TEdit;
    PPTEdit: TEdit;
    RuleBox: TComboBox;
    Label3: TLabel;
    NewButton: TButton;
    Label1: TLabel;
    FromBox: TComboBox;
    Label4: TLabel;
    ToBox: TComboBox;
    Label5: TLabel;
    TideBox: TComboBox;
    GreaterThanBox: TComboBox;
    Label2: TLabel;
    DelButt: TButton;
    HelpButton: TBitBtn;
    procedure ComboBox1Change(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure NotesEditChange(Sender: TObject);
    procedure TSwampEditExit(Sender: TObject);
    procedure RuleBoxChange(Sender: TObject);
    procedure NewButtonClick(Sender: TObject);
    procedure FromBoxChange(Sender: TObject);
    procedure ToBoxChange(Sender: TObject);
    procedure TideBoxChange(Sender: TObject);
    procedure GreaterThanBoxChange(Sender: TObject);
    procedure DelButtClick(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
  private
    IsUpdating: Boolean;
    SalRules: TSalinityRules;
    NumRules, RuleShowing: Integer;
    { Private declarations }
  public
    SaveStream: TMemoryStream;
    SS: TSLAMM_Simulation;
    Procedure EditRules(Var SRs: TSalinityRules);
    Procedure UpdateScreen();
    { Public declarations }
  end;

var
  SalRuleForm: TSalRuleForm;

implementation

uses FFForm;

{$R *.dfm}


procedure TSalRuleForm.NewButtonClick(Sender: TObject);
begin
  Inc(NumRules);
  Inc(SalRules.NRules);

  If NumRules>Length(SalRules.Rules) then SetLength(SalRules.Rules,NumRules+5);
  SalRules.Rules[NumRules-1] := TSalinityRule.Create;
  RuleShowing := NumRules-1;
  UpdateScreen;
end;

Procedure TSalRuleForm.CancelBtnClick(Sender: TObject);
begin
  If MessageDlg('Cancel all Changes?',mtconfirmation,[mbyes,mbno],0) = MRyes then
    ModalResult := MRCancel;
end;

Procedure TSalRuleForm.ComboBox1Change(Sender: TObject);
begin
  UpdateScreen;
end;


procedure TSalRuleForm.DelButtClick(Sender: TObject);
Var i: Integer;
begin
  If NumRules=0 then exit;
  If MessageDlg('Delete Rule '+RuleBox.Text+'?',mtconfirmation,[mbyes,mbno],0) = mrno then exit;

  For i := RuleShowing to NumRules-2 do
    SalRules.Rules[i] := SalRules.Rules[i+1];

  Dec(NumRules);
  Dec(SalRules.NRules);
  RuleShowing := NumRules-1;
  UpdateScreen;
end;

procedure TSalRuleForm.EditRules(Var SRs: TSalinityRules);
Var CatLoop: Integer;

begin
  SalRules := SRs;
  NumRules := SRs.NRules;
  RuleShowing := 0;

  TSText := False;
  SaveStream := TMemoryStream.Create;
  GlobalTS := SaveStream;
  SRs.Store(TStream(SaveStream));  {save for backup in case of cancel click}

  FromBox.Items.Clear;
  ToBox.Items.Clear;

  For CatLoop := 0 to SS.Categories.NCats-1 do
    Begin
      FromBox.Items.Add(SS.Categories.GetCat(CatLoop).TextName);
      ToBox.Items.Add(SS.Categories.GetCat(CatLoop).TextName);
    End;

  UpdateScreen;

  SaveStream.Seek(0, soFromBeginning); {Go to beginning of stream}
  If ShowModal = MRCancel then
    Begin
      SRs.Load(VersionNum,TStream(SaveStream));
    End;
  SaveStream.Free;

end;

procedure TSalRuleForm.FromBoxChange(Sender: TObject);
begin
  If IsUpdating then Exit;
  SalRules.Rules[Ruleshowing].FromCat := FromBox.ItemIndex;
end;

procedure TSalRuleForm.GreaterThanBoxChange(Sender: TObject);
begin
  If IsUpdating then Exit;
  SalRules.Rules[Ruleshowing].GreaterThan := GreaterThanBox.ItemIndex = 0;
end;

procedure TSalRuleForm.HelpButtonClick(Sender: TObject);
begin
   Application.HelpContext(1008 );  //'SalinityRules.html');
end;

procedure TSalRuleForm.RuleBoxChange(Sender: TObject);
begin
  RuleShowing := RuleBox.ItemIndex;
  UpdateScreen;
end;

procedure TSalRuleForm.NotesEditChange(Sender: TObject);
begin
  SalRules.Rules[Ruleshowing].Descript := NotesEdit.Text;
end;

procedure TSalRuleForm.TideBoxChange(Sender: TObject);
begin
  If IsUpdating then Exit;
  SalRules.Rules[Ruleshowing].SalinityTide := TideBox.ItemIndex+1;
end;

procedure TSalRuleForm.ToBoxChange(Sender: TObject);
begin
  If IsUpdating then Exit;
  SalRules.Rules[Ruleshowing].ToCat := ToBox.ItemIndex;
end;

procedure TSalRuleForm.TSwampEditExit(Sender: TObject);
Var
Conv: Double;
Result: Integer;

begin
  If IsUpdating then exit;
  Val(Trim(TEdit(Sender).Text),Conv,Result);
  If Result<>0 then MessageDlg('Incorrect Numerical Format Entered',mterror,[mbOK],0)
           else begin
                   case TEdit(Sender).Name[1] of
                      'P': SalRules.Rules[Ruleshowing].SalinityLevel := Conv;
                    end; {case}
                end; {else}
    UpdateScreen;
end;


Procedure TSalRuleForm.UpdateScreen;
Var i: Integer;
Begin
  RuleBox.Items.Clear;
  For i:=0 to NumRules-1 do
   With SalRules.Rules[i] do
    RuleBox.Items.Add(SS.Categories.GetCat(FromCat).TextName+' to '+SS.Categories.GetCat(ToCat).TextName);

  If RuleBox.Items.Count = 0 then
    Begin
      NotesEdit.Enabled := false;
      PPTEdit.Enabled := false;
      RuleBox.Enabled := false;
      FromBox.Enabled := false;
      ToBox.Enabled := false;
      exit;
    End;

  NotesEdit.Enabled := true;
  PPTEdit.Enabled := true;
  RuleBox.Enabled := true;
  FromBox.Enabled := true;
  ToBox.Enabled := true;
  RuleBox.ItemIndex := RuleShowing;

  Label5.Visible := true;
  TideBox.Visible := true;
  if trim(SS.SalFileN)<>'' then
    begin
      Label5.Visible := false;
      TideBox.Visible := false;
      TideBox.ItemIndex := 0;
    end;

  With SalRules.Rules[Ruleshowing] do
   begin
     IsUpdating := True;
     FromBox.ItemIndex := ORD(FromCat);
     PPTEdit.Text := FloatToSTrF(SalinityLevel,FFGeneral,6,4);
     ToBox.ItemIndex := ORD(ToCat);

     if TideBox.Visible=True then
      TideBox.ItemIndex := SalinityTide - 1
     else
      SalinityTide := 1;    //Added for handling the raster case with exisiting rules

     if GreaterThan then GreaterThanBox.ItemIndex := 0
                    else GreaterThanBox.ItemIndex := 1;
     NotesEdit.Text := Descript;
     IsUpdating := False;
   end;

End;


end.
