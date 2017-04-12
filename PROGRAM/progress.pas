//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit Progress;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, {Gauges,} Global, Vcl.Samples.Gauges, Vcl.ComCtrls;

type
  TProgForm = class(TForm)
    ProgressLabel: TLabel;
    YearLabel: TLabel;
    SLRLabel: TLabel;
    ProtectionLabel: TLabel;
    HaltButton: TButton;
    UncertStatusLabel: TLabel;
    Gauge1: TGauge;
    procedure HaltButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    LastUpdate: TDateTime;
    { Private declarations }
  public
    G2,PL2,F2, YL2, SLR2, Prot2: Pointer;
    SimHalted: Boolean;
    CPUs: Integer;
    ThreadProg: Array[1..100] of Integer;
    Function Update2Gages(Level, TN: Integer):Boolean;
    Procedure Cleanup;
    Procedure Setup(ProgCap,YLC,SLRLC,PLC: String; ShowHalt: Boolean);
    { Public declarations }
  end;

var
  ProgForm: TProgForm;

implementation

uses System.UITypes;

{$R *.DFM}

procedure TProgForm.HaltButtonClick(Sender: TObject);
begin
  If MessageDlg('Stop Process in Progress?',mtconfirmation,[mbyes,mbno],0)=Mrno then Exit;
  SimHalted := True;
  ProgressLabel.Caption := 'Halting Process in Progress';
end;

procedure TProgForm.Cleanup;
begin
   PL2 := nil;
   YL2 := nil;
   SLR2 := nil;
   Prot2 := nil;
   Hide;
end;

procedure TProgForm.FormCreate(Sender: TObject);
var i: Integer;
begin
  G2 := nil;
  PL2 := nil;
  F2 := nil;
  YL2 := nil;
  SLR2 := nil;
  Prot2 := nil;
  SimHalted := False;
  for i := 1 to 100 do
    ThreadProg[i] := 100;
  LastUpdate := Now();

end;

procedure TProgForm.FormHide(Sender: TObject);
begin
  HaltButton.Visible := HaltButton.Visible;     // temporary code to catch when form hidden
end;

Function TProgForm.Update2Gages(Level,TN:Integer):Boolean;
Var Level2, i: Integer;
Begin
  Result := Not SimHalted;
  SimHalted := False;

  Try

  if TN>0 then
    Begin
      ThreadProg[TN] := Level;
      if Now()-LastUpdate < 5e-6 then exit;  //only update every half-second

      Level2 := ThreadProg[1];
      for i := 2 to CPUs do
        if ThreadProg[i]<Level2 then Level2 := ThreadProg[i];    //display minimum thread progress
      Level := Level2;
    End;

  If Gauge1.Progress <> Level then
    Begin
      Gauge1.Progress := Level;      //bitmap corrupted here?
      Paint;
      Update;
      Application.Processmessages;
    End;

  Except
    Update;

  End
End;


procedure TProgForm.FormPaint(Sender: TObject);
begin
  If PL2 <> nil then
    TLabel(PL2).Caption := ProgressLabel.Caption;
  If YL2 <> nil then
    TLabel(YL2).Caption := YearLabel.Caption;
  If SLR2 <> nil then
    TLabel(SLR2).Caption := SLRLabel.Caption;
  If Prot2 <> nil then
    TLabel(Prot2).Caption := ProtectionLabel.Caption;
  If PL2 <> nil then
    TLabel(PL2).Visible := ProgressLabel.Visible;
  If YL2 <> nil then
    TLabel(YL2).Visible := YearLabel.Visible;
  If SLR2 <> nil then
    TLabel(SLR2).Visible := SLRLabel.Visible;
  If Prot2 <> nil then
    TLabel(Prot2).Visible := ProtectionLabel.Visible;

  If G2 <> nil then
    TGauge(G2).Progress := Gauge1.Progress;
  If F2 <> nil then
    TForm(F2).Update;
end;

procedure TProgForm.Setup(ProgCap, YLC, SLRLC, PLC: String; ShowHalt: Boolean);
begin
  HaltButton.Visible := ShowHalt;
  ProgressLabel.Caption := ProgCap;
  YearLabel.Caption := YLC;
  SLRLabel.Caption := SLRLC;
  ProtectionLabel.Caption := PLC;
  Gauge1.Progress := 0;
  Update;
  Show;
end;

end.
