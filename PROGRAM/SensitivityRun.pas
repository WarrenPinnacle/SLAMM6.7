//SLAMM SOURCE CODE Copyright (c) 2011 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit SensitivityRun;

interface

Uses SLR6;

Procedure SensRun(SS: TSLAMM_Simulation);

implementation

Uses System.UITypes, CalcDist, RandNum, Global, TCollect, sysutils, dialogs, progress, Controls, forms, ExcelFuncs, Excel2000, UncertDefn;

Const NUM_SENS_OUTPUTS = 27;

Procedure SensRun(SS: TSLAMM_Simulation);
Const NUM_SENS_OUTPUTS = 27;
Var
    NegTest, UserInterrupt: Boolean;
    StepNum, NumTests, WriteRow: Integer;
    TextOut      : TextFile;
    NegStr,DateHolder   : String;
    TestVal      : Double;
    SensParam    : TSensParam;
    TEx          : Array of TExcelOutput;
    FileBacked   : Array of String;
    PMax, PMin   : Double;
    NumOutputFiles: Integer;
//    xlspath      : String;


    {--------------------------------------------------------------}
    Procedure WriteOutputs(OutF, Row: Integer);
    Var i, WriteCol : Integer;
        WWS: _Worksheet;
        OutVal: Double;
    Begin
       Begin
        WriteCol := 0;
        WWS := TEx[OutF].WS;
        For i:=0 to NUM_SENS_OUTPUTS-1 do
         Begin
           Inc(WriteCol);
           OutVal :=  SS.Summary[OutF,SS.UncertSetup.UncSens_Row-1, i];
           WWS.Cells.Item[Row+1,WriteCol+2].Value := OutVal;
           If OutF=0 then Write(Textout,', '+FloatToStrF(OutVal,ffgeneral,8,4));
         End;
       End;
    End;
    {--------------------------------------------------------------}
    Procedure CreateExcel;
    Var {TCF: TCellFormat; }
        OFLoop : Integer;
 //       i,j,ColN: Integer;
        OFString: String;
    Begin
      SetLength(TEx,NumOutputFiles);

      For OFLoop := 0 to NumOutputFiles-1 do
       Begin
          OFString := '';
          If OFLoop > 0 then OFString := '_OS'+IntToStr(OFLoop);
          If OFLoop > SS.Site.NOutputSites then OFString := '_ROS'+IntToStr(OFLoop-SS.Site.NoutputSites);

          TEx[OFLoop] := TExcelOutput.Create(True);
          If Not TEx[OFLoop].OpenFiles then
            Begin
              TEx[OFLoop] := nil;
              Raise ESLAMMError.Create('Error Creating Excel Files for Sensitivity Output');
            End;

          TEx[OFLoop].FileN := ChangeFileExt(SS.UncertSetup.xls_path,OFString+'.xls');

          TEx[OFLoop].WS.Name := 'Sensitivity';
          With SS.UncertSetup do
            TEx[OFLoop].WS.Cells.Item[1,1].Value := IntToStr(PctToVary)+'% Sensitivity Test';
          TEx[OFLoop].WS.Cells.Item[1,2].Value := 'Parameter Value';
          TEx[OFLoop].WS.Cells.Item[2,1].Value := 'Base Case';
          TEx[OFLoop].WS.Cells.Item[2,2].Value := 'N A';
       End;

    End;

   {------------------------------------------------------------------}
   Procedure WriteParamNames;
   Var OFLoop, i,ColN: Integer;
//        OFString: String;
   Begin
      For OFLoop := 0 to NumOutputFiles-1 do
        Begin

          If OFLoop = 0 then Write(TextOut,'Output Columns --->');
          ColN := 0;
          For i:=0 to NUM_SENS_OUTPUTS-1 do
             Begin
               Inc(ColN);
               TEx[OFLoop].WS.Cells.Item[1,ColN+2].Value := (SS.ColLabel[i]);
               If OFLoop = 0 then Write(TextOut,', "',SS.ColLabel[i]+'"');
               TEx[OFLoop].WS.Cells.Item[3,ColN+2].Value := '''';
             End;

           If OFLoop = 0 then Begin Writeln(Textout); Writeln(Textout); End;
           WriteRow := 2;
           TEx[OFLoop].WS.Cells.Item[WriteRow+1,1].Value := 'Test Parameter';
        End;
    End;
   {------------------------------------------------------------------}

    Function InitTextResults: Boolean;
    Var FileN: String;
        curdir: String;
    Begin
      CurDir := GetCurrentDir;
      Result := PromptForFileName(SS.UncertSetup.xls_path,'XLS File (*.xls)|*.xls','.xls','Select Base Output File',SS.NWIFileN ,True);
      SetCurrentDir(CurDir);

      If Not Result then Begin UserInterrupt:=True; SS.UserStop:=True; Exit; End;

      FileN := ChangeFileExt(SS.UncertSetup.xls_path,'_sensitivitylog.txt');

      While Pos('\\',FileN)>0 do
        Delete(FileN,Pos('\\',FileN),1);

      ASSIGNFILE(TextOut,FileN);
      REWRITE(TextOut);
      Writeln(Textout,'---------------------------------------------------------');
      Writeln(TextOut);
      Writeln(TextOut,'            Sensitivity Test for SLAMM 6 Model ');
      Writeln(TextOut);
      Writeln(Textout,'---------------------------------------------------------');
      DateTimeToString(DateHolder,'mm-d-y t',Now);
      Writeln(TextOut,'        Run Starts at '+ DateHolder);
      Writeln(TextOut,'---------------------------------------------------------');
      Writeln(TextOut);
      Writeln(TextOut);
    End;
   {------------------------------------------------------------------}
   Procedure CountNumTests;
//   var i: Integer;
   Begin
     NumTests := SS.UncertSetup.NumSens * 2;
   End;
   {------------------------------------------------------------------}

   Procedure Write_Sensitivity_Results;
   Var WWS: _Worksheet;
       OFLoop: Integer;
    Begin
     For OFLoop := 0 to NumOutputFiles-1 do
      Begin
       WWS := TEx[OFLoop].WS ;
       IF OFLoop = 0 then Inc(WriteRow);
       WWS.Cells.Item[WriteRow+1,2].Value := TestVal;
       WWS.Cells.Item[WriteRow+1,1].Value := SensParam.DName  + ' '+NegStr;
       IF OFLoop = 0 then Write(TextOut,'"'+SensParam.DName+ ' '+NegStr+'"');
       IF OFLoop = 0 then Write(TextOut,' Multiplied by '+FloatToStrF(TestVal,ffgeneral,8,4)+'       > ');
       WriteOutputs(OFLoop,WriteRow);

       TEx[OFLoop].Save;  {Save Excel file after each iteration}
       End;

      {Update Text output}
       Writeln(Textout);
       Writeln(Textout,'Was Testing '+SensParam.DName+ ' At Value '+FloatToStrF(TestVal,ffgeneral,8,4));

       Writeln(Textout,'Iteration '+IntToStr(StepNum)+' Completed.  Excel File Updated.');
       Writeln(Textout,'---------------------------------------------------------');

    End;      {Write_Sensitivity_Results}
   {------------------------------------------------------------------}
   Procedure CalcSensParameters;
   Var VaryAmt: Double;
   Begin
     VaryAmt := (SS.UncertSetup.PctToVary / 100);
     PMax := 1 + VaryAmt;
     PMin := 1 - VaryAmt;
   End;
   {------------------------------------------------------------------}

       Function VerifySensSetup: Boolean;
       Var i, Loop, FixLoop, CountRuns: Integer;
           RunningCustomSLR: Boolean;
           IPCC_Scenario: IPCCScenarios;
           IPCC_Est     : IPCCEstimates;
           Prot_Scenario: ProtScenario;
           ErrMessage   : String;

       Begin
         Result := True;
         CountRuns := 0;

         With SS do
           Begin
             For IPCC_Scenario := Scen_A1B to Scen_B2 do
              For IPCC_Est := Est_Min to Est_Max do
               For Prot_Scenario := NoProtect to ProtAll do
                If IPCC_Scenarios[IPCC_Scenario] and IPCC_Estimates[IPCC_Est] and Prot_To_Run[Prot_Scenario] then
                 Inc(CountRuns);

             For Prot_Scenario := NoProtect to ProtAll do
               For FixLoop := 1 to 11 do    //NYS and ESVA SLR Scenarios added - MArco
                 If Fixed_Scenarios[FixLoop] and Prot_To_Run[Prot_Scenario] then
                  Inc(CountRuns);

             RunningCustomSLR := False;
             If RunCustomSLR then
              For i := 1 to N_CustomSLR do
               For Prot_Scenario := NoProtect to ProtAll do
                 If Prot_To_Run[Prot_Scenario] then
                  Begin
                   Inc(CountRuns);
                   RunningCustomSLR := True;
                  End;
           End;

         ErrMessage := '';
         If (CountRuns<>1) then ErrMessage := 'Sensitivity runs must be set up to run one SLR scenario / Protection Scenario only.';
         If Not RunningCustomSLR then
           Begin
              For Loop:=0 to SS.UncertSetup.NumSens-1 do
                 Begin
                   SensParam:=SS.UncertSetup.SensArray[Loop];
                   If (SensParam.IDNum = 1) then ErrMessage := 'You must run SLAMM under "Custom SLR" if you are selecting "Custom SLR" as a sensitivity parameter.';
                 End;
           End;

         If ErrMessage <> '' then
           Begin
             Result := False;
             MessageDlg(ErrMessage,MtError,[mbok],0);
             SS.UserStop := True;
           End;
       End;

   {------------------------------------------------------------------}

      Procedure RestoreVals;
      Begin
        If SensParam.DistType <> ElevMap then SensParam.RestoreValues;
      End;

   {------------------------------------------------------------------}
   Procedure CloseTExs;
   Var OFLoop: Integer;
   Begin
    Try
     If TEx <> nil then
      For OFLoop := 0 to NumOutputFiles-1 do
        Begin
          TEx[OFLoop].WS.Range['A1', 'A1'].EntireColumn.AutoFit;
          TEx[OFLoop].SaveAndClose;
        End;
    Finally
     TEx := nil;
    End;
   End;

  {----------------------------------------------------------------}
  {---        BEGIN MAIN Procedure SensitivityRun               ---}
  {----------------------------------------------------------------}

Var // VaryAmount, StoreStep: Double;
    ErrorString: String;
//    IterationHolder: String;
    i, j: Integer;
    OFLoop : Integer;
//    DLoop, OFLoop, Loop,Prog: Integer;
    ItStr: String;

Begin     {SensRun}
//  IterationsDone:=0;
  SensAnalysis := True;
  SS.UncertSetup.UncSens_Iter := 0;
  SS.WordInitialized := False;
  UserInterrupt:=False;
  SS.UserStop := False;

//  If Not VerifySensSetup then exit;          {Marco: already checked when clicking execute button}

  Try


  If not InitTextResults then Exit;

  CountNumTests;

  ProgForm.ModalResult := MRNone;
  ProgForm.Gauge1.Progress :=0;
  ProgForm.Show;
  ProgForm.UncertStatusLabel.Visible := True;
  ProgForm.UncertStatusLabel.Caption := 'Deterministic Run...';
  ProgForm.Update;
  For i := 1 to 2 do
    SS.UncertSetup.ZUncertMap[i] := nil;

  Try
    SS.ExecuteRun;
    NumOutputFiles := 1+SS.Site.NOutputSites+SS.Site.MaxROS;
    CreateExcel;
    WriteParamNames;

    For OFLoop := 0 to NumOutputFiles-1 do
      WriteOutputs(OFLoop,1);
      
    Writeln(Textout);
    Writeln(Textout,'Deterministic Iteration Completed.  Excel File Updated.');
    Writeln(Textout,'---------------------------------------------------------');

  Except
     Messagedlg('Model Execution Error.',mterror,[mbok],0);
     CloseFile(TextOut);
     ProgForm.Hide;
     exit;
  End;

  FileBacked := nil;

//  IterationsDone:=0;
  UserInterrupt:=False;

  For i := 1 to 2 do
    SS.UncertSetup.ZUncertMap[i] := nil;

  With SS.UncertSetup do
  For i := 0 to NumSens - 1 do
   For NegTest := False to True do
    Begin
      SensParam := SensArray[i];
      CalcSensParameters;
      Inc(StepNum);
      Inc(UncSens_Iter);

      {Update Progress Dialog}
      ItStr:='Iteration '+IntToStr(StepNum)+ ' of '+IntToStr(NumTests);
      ProgForm.UncertStatusLabel.Caption := ItStr;

      DateTimeToString(DateHolder,'mm-d-y t',Now);
      ItStr:='Iteration '+IntToStr(StepNum)+ ' of '+IntToStr(NumTests) + ' Starts at '+DateHolder;
      Writeln(TextOut,Itstr);
      Writeln(TextOut);

      If NegTest then NegStr := '-' else NegStr := '+';
      If NegTest then TestVal := PMin
                 else TestVal := PMax;
      SensPlusLoop := Not NegTest;

      SensParam.SetValues(TestVal);

        {Go through run Procedure for each iteration}
        Try

          SS.ExecuteRun;
        Except
          RestoreVals;
          UserInterrupt:=True;
          DateTimeToString(DateHolder,'mm-d-y t',Now);
          Writeln(TextOut,'Execute Model Error at '+ DateHolder );
          Messagedlg('Model Execution Error.',mterror,[mbok],0);
          For j := 1 to 2 do
            SS.UncertSetup.ZUncertMap[j] := nil;
          Break; {exit distribloop}
        End;

      RestoreVals;

      Application.ProcessMessages;
      Application.Title := 'SLAMM6 - '+IntToStr(StepNum)+' of '+IntToStr(NumTests);

      If SS.UserStop then UserInterrupt:=True;

      If (ProgForm.ModalResult<>0) or UserInterrupt then
         begin
            UserInterrupt:=True;
            DateTimeToString(DateHolder,'mm-d-y t',Now);
            Writeln(TextOut,'Run Terminated at '+ DateHolder );
            Break; {exit loop}
         end
         else Write_Sensitivity_Results;
    End;  {Nested For Do Loops (i, negtest)}

    Application.Title := 'SLAMM 6 beta';
    If Not UserInterrupt then
      begin
        DateTimeToString(DateHolder,'mm-d-y t',Now);
        Writeln(TextOut,'Run Successfully Completed At '+ DateHolder );
        Writeln(TextOut,'---------------------------------------------------------');
      end;

  Except
    SensAnalysis := False;
    For i := 1 to 2 do
      SS.UncertSetup.ZUncertMap[i] := nil;

    ErrorString:=Exception(ExceptObject).Message;
    ProgForm.ModalResult:=1;
    MessageDlg('Run-Time Error During Sensitivity Iteration',mterror,[mbOK],0);
    MessageDlg(ErrorString,mterror,[mbOK],0);
    DateTimeToString(DateHolder,'mm-d-y t',Now);
      Try
        Writeln(TextOut,'Run Terminated at '+ DateHolder );
        Writeln(TextOut,'    Due to '+ErrorString);
        CloseTExs;

      Except
        MessageDlg('No Data Written',mterror,[mbOK],0);
        ProgForm.ModalResult:=1;
      End;

  End; {Except}

  SensAnalysis := False;

  For i := 1 to 2 do
    SS.UncertSetup.ZUncertMap[i] := nil;

  Try

  CloseFile(TextOut);

  Except
    ErrorString:=Exception(ExceptObject).Message;
    MessageDlg('Run-Time Error Writing to File After Sensitivity Run',mterror,[mbOK],0);
    MessageDlg(ErrorString,mterror,[mbOK],0);
    ProgForm.ModalResult:=1;
    CloseTExs;
    CloseFile(TextOut);

  End; {Except}

  ProgForm.Hide;
  CloseTExs;

End;  {SensRun}



end.
