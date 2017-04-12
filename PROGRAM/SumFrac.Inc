//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

(*********************************)
(*   summarize cell categories   *)
(*********************************)
(*****************************)
(*  create CSV file          *)
(*****************************)
PROCEDURE TSLAMM_Simulation.                    //called at end of simulation
          CSV_file_save(datary:   OutputArray;
                        rowlabel: str_vector1;
                        collabel: str_vector;
                        numrow:   integer;
                        numcol:   integer;
                        fnm: String);

VAR
  F: text;
  SLLabel: String;
  Var m,n: Integer;
  WriteError: Boolean;
  SecondaryFileName: String;

     {=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
     Function ProtLabel: String;
     Begin
       With UncertSetup do
        If SensAnalysis and (UncSens_Iter>0)
          then
            Begin
              Result := '"'+ IntToStr(UncSens_Iter);
            End
          else
            IF ProtectAll
                THEN Result := '"Protect All Dry'
                ELSE IF ProtectDeveloped
                        THEN Result := '"Protect Developed Dry'
                        ELSE Result := '"Protect None';

        If Not IncludeDikes then Result := Result + ' No Dikes';

        Result := Result + '",';
     End;
     {=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
     Procedure WriteSecondaryFile;  // Jan 8, 2010 write secondary CSV output to Industrial Economics Specs
     Var Appending: Boolean;
         RunDate: TDateTime;
         isites, irows,j: integer;
     Begin
        If OutputFileN <> '' then SecondaryFileName := OutputFileN + '.CSV'    // wrong directory?
                             else SecondaryFileName := ElevFileN + '_OUT.CSV';

        Repeat
          WriteError := False;
          Appending := False;
        Try
          Appending := FileExists(SecondaryFileName);
          AssignFile(F,SecondaryFileName);
          If Appending
                then Append(F)
                else Rewrite(F);
        Except
          If MessageDlg('Error writing to file '+SecondaryFileName+'.  Retry?',mterror,[mbyes,mbno],0)
            = mryes then WriteError := True
                    else Exit;
        End;
        Until Not WriteError;

        If Not Appending then
          Writeln(F,'"Site Desc.","Scenario","Parameters","Year","Protection","GIS Num","Hectares","SLAMMText","SLR (eustatic)","RunDate"');

        RunDate := Now();

        If Running_TSSLR then SLLabel := '"Time Ser. SLR","'+TimeSerSLRs[TSSLRindex-1].Name+'"' else
        If Running_Fixed then SLLabel := '"Fixed","'+LabelFixed[FixedScen]+'"' else
        If Running_Custom then SLLabel := '"Custom","'+FloatToStrF(Current_Custom_SLR ,ffgeneral,4,2)+ ' meters '+'"'
                         else SLLabel := '"'+LabelIPCC[IPCCSLRate]+'","'+LabelIPCCEst[IPCCSLEst]+'"';

        For isites := 0 to Site.NOutputSites + Site.MaxROS do
         FOR irows := 0 TO numrow-1 DO
          FOR j := 1 TO numcol+20 DO
           if (NRoadInf > 0) or (j < NumCol + 7 + 2) then  // suppress roads data
             BEGIN
                If isites=0 then Write(F,'"',Site.GlobalSite.Description,'",')
                            else If (isites <= Site.NOutputSites)
                              then Write(F,'"',Site.OutputSites[isites-1].Description,'",')
                              else Write(F,'"Raster ',IntToStr(Isites-Site.NOutputSites),'",');
                Write(F,SLLabel,',');
                Write(F,'"',rowlabel[irows],'",');  {write year}
                Write(F,ProtLabel);  {write protection}
                If j<Categories.NCats then Write(F,Categories.GetCat(j-1).GISNumber,',')  {GIS Number}
                        else Write(F,'NA,');

                Write(F,datary[isites,irows,j]:n:m,','); {Hectares}
                Write(F,'"',collabel[j],'",'); {Slamm Text}
                Write(F,datary[isites,irows,0]:n:m,',');  {Eustatic SLR}
                Writeln(F,DateTimeToStr(RunDate));
             End;

        CloseFile(F);

        If not (RunUncertainty or RunSensitivity) then  // separate logs exist for uncertainty & sensitivity runs.
        Try
          Append(RunRecordFile);
          SummarizeFileInfo(SLLabel+' appended to Master CSV',fnm);
          Writeln(RunRecordFile);
          Closefile(RunRecordFile);
        Except
          MessageDlg('Error appending to Run-Record File '+RunRecordFileName,mterror,[mbOK],0);
        End;

     End;
     {=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

Var
  isites, irows,j: integer;

BEGIN
  n:=10;
  m:=4;
  AssignFile(F,fnm);

  Repeat
    WriteError := False;
  Try
    If BatchMode and FileStarted then Append(F)
                                 else Rewrite(F);
  Except
    If MessageDlg('Error writing to file '+fnm+'.  Retry?',mterror,[mbyes,mbno],0)
      = mryes then WriteError := True
              else Exit;
  End;

  Until Not WriteError;

  If Running_TSSLR then SLLabel :=  TimeSerSLRs[TSSLRindex-1].Name else
  If Running_Fixed  then SLLabel := LabelFixed[FixedScen] else
  If Running_Custom then SLLabel := FloatToStrF(Current_Custom_SLR ,ffgeneral,4,2)+ ' meters '
                    else SLLabel := LabelIPCC[IPCCSLRate]+' '+LabelIPCCEst[IPCCSLEst];

  If Not BatchMode then
    Begin
      Write(F,'"','Sea Level Scenario: ',SLLabel);
      Write(F,ProtLabel);

      Writeln(F);
      WriteLn(F,'"Total Ha:",',Round(Hectares):n);
      Writeln(F);
    End;

  If Not (BatchMode and FileStarted) then
    Begin
      Write(F,'"Date","Site Desc.","Scenario","Parameters","Protection",');
      FOR J := 0 TO numcol+20 DO               {write col headers}
        write(F,'"',collabel[j],'",');

      Writeln(F);
    End;

  FileStarted := True;

  For isites := 0 to Site.NOutputSites + Site.MaxROS do
   FOR irows := 0 TO numrow-1 DO
    BEGIN
      Write(F,'"',rowlabel[irows],'",');

      If isites=0 then Write(F,'"',Site.GlobalSite.Description,'",')
                  else If (isites <= Site.NOutputSites)
                    then Write(F,'"',Site.OutputSites[isites-1].Description,'",')
                    else Write(F,'"Raster ',IntToStr(Isites-Site.NOutputSites),'",');

      If Running_TSSLR then Write(F,'"Time Ser. SLR","',TimeSerSLRs[TSSLRindex-1].Name ,'",') else
      If Running_Fixed  then Write(F,'"Fixed","',LabelFixed[FixedScen],'",') else
      If Running_Custom then Write(F,'"Custom","',FloatToStrF(Current_Custom_SLR ,ffgeneral,4,2)+ ' meters ','",')
                        else Write(F,'"',LabelIPCC[IPCCSLRate],'","',LabelIPCCEst[IPCCSLEst],'",');

      Write(F,ProtLabel);

      FOR j := 0 TO numcol+20 DO
       if (NRoadInf > 0) or (j < NumCol + 7 + 2) then  // suppress roads data
         Write(F,datary[isites,irows,j]:n:m,',');

      Writeln(F);
    END;

  CloseFile(F);

  If not (RunUncertainty or RunSensitivity) then  // separate logs exist for uncertainty & sensitivity runs.
  Try
    Append(RunRecordFile);
    SummarizeFileInfo(SLLabel+' Results',fnm);
    Closefile(RunRecordFile);
  Except
    MessageDlg('Error appending to Run-Record File '+RunRecordFileName,mterror,[mbOK],0);
  End;

  WriteSecondaryFile;

END;



PROCEDURE TSLAMM_Simulation.Summarize(VAR Map: MSArray;
                    VAR Tropical: Boolean; VAR Summary: OutputArray; Year: Integer);

//called each time step.  Create the data in the summary array that is written above
VAR
  NumCells: double;
  CC: Integer;
  i,j: Integer;
  AggC : AggCategories;
  k1, k2: double;
  DTime: Integer;
  California: Boolean;

BEGIN
//  Calc_Fractal(Site);

  NumCells := (Site.RunRows) * (Site.RunCols);

  Hectares := NumCells * Site.RunScale * Site.RunScale / 10000;    {total hectares}
    {ha}          {n}          {m}          {m}   {m2/ha}

  California := Categories.AreCalifornia;

  If Not California then
   if ((CatSums[0,8] / 10000) / Hectares  > 0.005) THEN Tropical := TRUE
      {      ha mangrove   }  {ha overall}         ELSE Tropical := FALSE;

  For i := 0 to Site.NOutputSites + Site.MaxROS do
    Begin
       RowLabel[TStepIter] := IntToStr(Year);
       Summary [i,TStepIter,0] := Site.GlobalSite.NewSL;

       // initialize aggregated categories
       For j := 1 to 7 do
          Summary[i,TStepIter,Categories.NCats+1+j] := 0;

       //Initialize carbon sequestration
       if (TSTepIter >1) then
          Summary[i,TStepIter,Categories.NCats+1+7+1] := Summary[i,TStepIter-1,Categories.NCats+1+7+1]
       else
          Summary[i,TStepIter,Categories.NCats+1+7+1] := 0;


       FOR CC := 0 TO Categories.NCats-1 DO                   // write SLAMM categories to array in HA
         Begin
           //SLAMM Categories
           Summary[i,TStepIter,cc+1] := CatSums[i,cc] / 10000;
                               {ha}             {m2}          {m2/ha}

           //Aggregated categories
           AggC := Categories.GetCat(CC).AggCat;
           If AggC <> AggBlank then
              Summary[i,TStepIter,Categories.NCats+2+ORD(AggC)] := Summary[i,TStepIter,Categories.NCats+2+ORD(AggC)] + ( CatSums[i,cc] / 10000);
                                                          {ha}                                             {m2}         {m2/ha}
           if TStepIter>1 then
            begin
              //Carbon sequestration
              k1 := (44/12)*0.47*Categories.GetCat(CC).mab;
              k2 := (44/12)*Categories.GetCat(CC).Rsc - 21*Categories.GetCat(CC).ECH4;
              if (k1<>0) or (k2<>0) then
               begin
                DTime := Year - StrtoInt(RowLabel[TStepIter-1]);
                Summary[i,TStepIter,Categories.NCats+1+7+1] := Summary[i,TStepIter,Categories.NCats+1+7+1] + k1*Summary[i,TStepIter,ORD(cc)+1] + (k2*DTime-k1)*Summary[i,TStepIter-1,ORD(cc)+1];
               end
            end
         End;

       If i=0 then
        Summary[i,TStepIter,Categories.NCats+1] := SAV_KM
       else
        Summary[i,TStepIter,Categories.NCats+1] := -9999;


{      if i<=NOutputSites // no ROS AFractalD or ShoreProt
          Summary[i,TStepIter,Categories.NCats+2] :+ FRs[i].FractalD[0];
           Summary[i,TStepIter,Categories.NCats+3] := FRs[i].FractalD[1];
           Summary[i,TStepIter,Categories.NCats+4] := FRs[i].ShoreProtect;
         End;                                                               }

        //roads output
        if NRoadInf > 0 then
         If i=0 then
          For j := 0 to MaxRoadArray do
           Summary[i,TStepIter,Categories.NCats+9+j+1] := RoadSums[i,j] ;
                          {km}             {km}

     End;

 {  Summary[Count,ORD(Blank)+3] := HaGained ;
    Summary[Count,ORD(Blank)+4] := HaLost ; }

END; {Summarize}





