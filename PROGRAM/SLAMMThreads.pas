unit SLAMMThreads;

interface

Uses SLR6, Classes, Uncert, Windows, SysUtils,   SyncObjs;

type
  TSuspendResumeThread = Class(TThread)
  private
    fResumeSignal :TEvent;
    fTerminateSignal:TEvent;
  public
    procedure Resumed; virtual;
    Function WaitForResume: Boolean;
    Procedure Start;
    constructor Create;
    destructor Destroy; override;
  end;


  trunthread = class(TSuspendResumeThread)
  private
    ProgCapt: String;
    ThreadNum, ProgNum: Integer;
    ProgRes : Boolean;
    SS: TSLAMM_Simulation;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    ProgStr: String;
    StR,EnR: Integer;
    ImDone, UserStop : Boolean;
    ErodeTask: Boolean;
    TasksDone: Boolean;
    property terminated;
    function UpdateProg(Caption: String; Num: Integer): Boolean;
    procedure UpdateProgress;
    constructor Create(SS_in: TSLAMM_Simulation; SR,ER: Integer; PS: String; TN:Integer);
    destructor Destroy; override;
  end;

  TChngWaterThread = class(trunthread)
  public
    MaxWE: Double;
    CMF: Boolean;
    constructor Create(SS_in: TSLAMM_Simulation; SR,ER: Integer; PS: String; TN:Integer; CalcFetch: Boolean);
    procedure Execute; override;
  end;

  TUpdateElevsThread = class(trunthread)
  public
    procedure Execute; override;
  end;

  TElevUncertMapThread = class(TSuspendResumeThread)
  public
    ProgStr: String;
    ThreadNum, ProgNum: Integer;
    StR,EnR: Integer;
    ImDone, UserStop : Boolean;
    SU : TSLAMM_Uncertainty;
    Converged: Boolean;
    MaxChange: Single;
    constructor Create(SU_in: TSLAMM_Uncertainty; SR,ER: Integer; PS: String; TN:Integer);
    procedure Execute; override;
  end;




{-------------------------------------------------------------------------------------------------------}

implementation

Uses Progress;

destructor trunthread.Destroy;
begin
  Terminate;
  inherited;
end;


Procedure trunthread.Execute;


Begin
  Repeat
    ImDone := False;
    UserStop := not SS.Inundate_Erode(StR,EnR,ProgStr,Self,ErodeTask);
    ImDone := True;
    WaitForResume;
   Until TasksDone or Terminated;
   ImDone := True;
End;



Function trunthread.UpdateProg(Caption: String; Num: Integer): Boolean;
Begin
  ProgCapt := Caption;
  ProgNum := Num;
  Synchronize(UpdateProgress);
  Result := ProgRes;
End;

Procedure trunthread.UpdateProgress;
Begin
   ProgForm.ProgressLabel.Caption:= ProgCapt;
   ProgRes := ProgForm.Update2Gages(ProgNum,ThreadNum);
End;

Constructor trunthread.Create(SS_in: TSLAMM_Simulation; SR,ER: Integer; PS:String; TN:Integer);
Begin
  SS := SS_in;
  ImDone := False;     // my job is done and I'm ready for another
  TasksDone := False;  // all tasks done for this job
  ErodeTask := False;
  ProgStr := PS;
  StR := SR;
  EnR := ER;
  ThreadNum := TN;
  Inherited Create;
End;

{------------------------------ TChngWaterThread ------------------------------}

constructor TChngWaterThread.Create(SS_in: TSLAMM_Simulation; SR, ER: Integer;
  PS: String; TN: Integer; CalcFetch: Boolean);
begin
   CMF := CalcFetch;
   inherited Create(SS_in,SR,ER,PS,TN);
end;

Procedure TChngWaterThread.Execute;
Begin
   UserStop := not SS.ThreadChngWater(StR,EnR,Self);
   ImDone := True;
   If WaitForResume then
     Begin
       ImDone := False;
       UserStop := not SS.CalculateMaxFetch(StR,EnR,Self,MaxWE);
       ImDone := True;
     End;
End;

{------------------------------ TUpdateElevsThread ------------------------------}

Procedure TUpdateElevsThread.Execute;
Begin
   UserStop := not SS.ThreadUpdateElevs(StR,EnR,Self);
   ImDone := True;
End;



{ TElevUncertMapThread }

constructor TElevUncertMapThread.Create(SU_in: TSLAMM_Uncertainty; SR,
  ER: Integer; PS: String; TN: Integer);
begin
  SU := SU_in;
  ImDone := False;
  Converged := False;
  ProgStr := PS;
  StR := SR;
  EnR := ER;
  ThreadNum := TN;
  inherited Create;
end;

procedure TElevUncertMapThread.Execute;
begin
  Repeat
    UserStop := not SU.ThreadUncertMap(StR,EnR,Self);
    ImDone := True;
    WaitForResume;
    ImDone := False;
   Until Converged;
   ImDone := True;
End;


{ TSuspendResumeThread }

constructor TSuspendResumeThread.Create;
begin
 fResumeSignal := TEvent.Create(nil, True, False, '');
 fTerminateSignal := TEvent.Create(nil, True, False, '');
 inherited create(False);
end;

destructor TSuspendResumeThread.Destroy;
begin
  inherited;
  fResumeSignal.Free;
  fTerminateSignal.Free;
end;


procedure TSuspendResumeThread.Start;
begin
  fResumeSignal.SetEvent;
end;

procedure TSuspendResumeThread.Resumed;
begin
  fResumeSignal.ResetEvent;
end;

Function TSuspendResumeThread.WaitForResume;
  var
    vWaitForEventHandles:array[0..1] of THandle;
    vWaitForResponse:DWORD;
  begin
    Result := False;
    vWaitForEventHandles[0] := fResumeSignal.Handle;
    vWaitForEventHandles[1] := fTerminateSignal.Handle;
    While not Terminated do
      vWaitForResponse := WaitForMultipleObjects(2, @vWaitForEventHandles[0], False, 1000);

    case vWaitForResponse of
    WAIT_OBJECT_0 + 1: Terminate;
    WAIT_FAILED: RaiseLastOSError;
    else Begin Result := True; Resumed End;
    end;
  end;

end.
