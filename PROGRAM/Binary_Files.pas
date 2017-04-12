unit Binary_Files;

interface

Uses
  SysUtils,Utility, Windows, Messages, Classes, Graphics, Controls, Global, Uncert, Progress,
  Forms, Dialogs, StdCtrls, Math, OLECtrls, ComObj, System.SyncObjs, System.UITypes, BufferTStream;

CONST NO_DATA:Integer = -9999;
      WRITE_NO_DATA: Integer = -99;  // save bytes
      SLBVersion: Double = 1.0;

Type

  TSLAMMFile = Class
    FileN, ConvertedFileN: String;
    IsText: Boolean;
    FNoDat: Integer;  // reading of ASCII file
    TxtFile: Text;
    fRow,fCol: Integer;
    fXLLCorner,fYLLCorner,fCellSize: Double;
  End;

  TSLAMMInputFile=Class(TSLAMMFile)
    ReadStream: TReadOnlyCachedFileStream;

    ReadVersion: Double;
    IsRepeat: Boolean;
    RepeatNum: Single;
    IterToRead: Word;

    Function GetNextNumber(Var Num: Single): Boolean;

    Function PrepareFileForReading:Boolean; overload;
    Function PrepareFileForReading(ErrMsg:String):Boolean; Overload;

    Function ConvertToBinary: Boolean;
    Function ConvertToASCII(Var OutMsg: String): Boolean;
    Constructor Create(FN: String);
    Destructor Destroy;  override;
  End;

Const BufferSize = 65534; // size of block to read and store in memory prior to compression

Type TSLAMMOutputFile = Class(TSLAMMFile)
    WriteStream: TWriteCachedFileStream;

    ChainDone, InChain, ReadingRepeat : Boolean;  // utility vars for compression of binary file writing
    Numwritten, ChainSize: Word;
    NumList : Array of single;

    Function WriteHeader(Prompt: Boolean): Boolean;  overload;
    Function WriteHeader(Prompt: Boolean; ErrMsg: String): Boolean; overload;
    Procedure CR;            // carriage return, if relevant (text output)
    Function WriteNextNumber(Num: Single; LastNumber: Boolean): Boolean;
    Constructor Create(nc,nr: Integer; xll,yll,sz: Double; FN: String);  //use "SLB" extension to signify binary output
    Destructor Destroy;  override;
End;




implementation



constructor TSLAMMInputFile.Create(FN: String);
begin
  FileN := FN;
  IsText := not (POS('SLB',ExtractFileExt(FN))>0);  // '.SLB signifies SLAMM Binary File
  IterToRead := 0;
  ReadStream := nil;
end;

destructor TSLAMMInputFile.Destroy;
begin
  if IsText then CloseFile(TxtFile)
            else ReadStream.Free;

  inherited;
end;

function TSLAMMInputFile.GetNextNumber(Var Num: Single): Boolean;

Var S: ANSIString;
    C: ANSIChar;
Begin
  Result := True;
  Try
    if IsText then
      Begin
        S:='';
        Repeat
          Read(TxtFile,C);
          If (C<>' ') and (ord(C)>32) then
              S := S + C;
        Until ((S<>'') and (C=' ')) or eof(TxtFile);
        Num:=StrToFloat(String(S));
        if Num = FNoDat then NUM := NO_DATA;  // converting -99 to -9999 potentia
      End
    else  // IsBinary
      Begin
        if IterToRead =0 then
          Begin
            ReadStream.Read(IsRepeat,Sizeof(IsRepeat));   // read whether this is a repeating value
            ReadStream.Read(IterToRead,Sizeof(IterToRead));  // read how many characters to repeat (or not repeat)
            ReadStream.Read(Num,Sizeof(Num));
            if isRepeat then RepeatNum := Num;   //save for re-reading
            Dec(IterToRead);
          End
        else // IterToRead > 1, repeat either a read or a unique value read
          Begin
            if isRepeat then Num := RepeatNum                    // repeated value
                        else ReadStream.Read(Num,Sizeof(Num)); // unique value in a chain of unique values
            Dec(IterToRead);
          End;
      End;
  Except
    Result := False;
  End;

End;

Function TSLAMMInputFile.PrepareFileForReading:Boolean;
Var Msg: String;
Begin
  Result := PrepareFileForReading(Msg);
  if Not Result then ShowMessage(Msg);
End;



function TSLAMMInputFile.PrepareFileForReading(ErrMsg:String): Boolean;
Var ReadStr: String;
begin
  Result := True;
  Try
    if IsText then
      Begin
        Assign(TxtFile,FileN);
        Reset(TxtFile);

        ReadLn(TxtFile,ReadStr);
        If Pos('ncols',LowerCase(ReadStr))=0 then
          Begin
             ErrMsg := 'Data File "'+FileN+'" Does Not Include "ncols" identifier';
             Result := False;
             Exit;
          End;

        Delete(ReadStr,Pos('ncols',LowerCase(ReadStr)),5);
        fCol:=StrToInt(ReadStr);
       {------------------------------------}
        ReadLn(TxtFile,ReadStr);
        Delete(ReadStr,Pos('nrows',LowerCase(ReadStr)),5);
        fRow:=StrToInt(ReadStr);
        {------------------------------------}
        ReadLn(TxtFile,ReadStr);
        Delete(ReadStr,Pos('xllcorner',LowerCase(ReadStr)),9);
        fXLLCorner:=Round(StrToFloat(ReadStr));
        {------------------------------------}
        ReadLn(TxtFile,ReadStr);
        Delete(ReadStr,Pos('yllcorner',LowerCase(ReadStr)),9);
        fYLLCorner:=Round(StrToFloat(ReadStr));
        {------------------------------------}
        ReadLn(TxtFile,ReadStr);
        Delete(ReadStr,Pos('cellsize',LowerCase(ReadStr)),8);
        fCellSize:=StrToFloat(ReadStr);
        {------------------------------------}
        ReadLn(TxtFile,ReadStr);       {Parse through header lines if any}
        If Pos('nodata_value',LowerCase(ReadStr))=0 then
         Begin
             ErrMsg := 'Data File "'+FileN+'" Does Not Include "nodata_value" identifier';
             Result := False;
             Exit;
          End;

        Delete(ReadStr,Pos('nodata_value',LowerCase(ReadStr)),12);
        FNoDat:=StrToInt(ReadStr);
      End
    else // Binary
      Begin
        ReadStream := TReadOnlyCachedFileStream.Create(FileN,48*1024);
        ReadStream.Read(ReadVersion,sizeof(ReadVersion));
        if (ReadVersion < 0.999) or (ReadVersion > 9.999) then
          Begin
            ErrMsg := 'Error Reading Version Number for data File "'+FileN+'"';
            Result := False;
            Exit;
          End;

        ReadStream.Read(fCol,sizeof(fCol));
        ReadStream.Read(fRow,sizeof(fRow));
        ReadStream.Read(fXLLCorner,sizeof(fXLLCorner));
        ReadStream.Read(fYLLCorner,sizeof(fYLLCorner));
        ReadStream.Read(fcellsize,sizeof(fcellsize));
        IterToRead := 0;
      End;
  Except
    ErrMsg := 'Error Reading Headers for data File "'+FileN+'"';
    Result := False;
  End;
end;


function TSLAMMInputFile.ConvertToASCII(Var OutMsg: String): Boolean;
Var ER,EC: Integer;
    ReadNum: Single;
    SOF: TSLAMMOutputFile;
begin
  OutMsg := '';
  Result := (POS('SLB',ExtractFileExt(FileN))>0);
  if Not Result then OutMsg:= FileN + ' cannot be converted -- Must be an SLB file';
  if Not Result then Exit;

  Result := PrepareFileForReading(OutMsg);
  if Not Result then Exit;

  TRY

  SOF := TSLAMMOutputFile.Create(fcol,frow,fxllcorner,fyllcorner,fcellsize,ChangeFileExt(FileN,'.ASC'));

  Result := SOF.WriteHeader(True,OutMsg);
  ConvertedFileN := SOF.FileN;
  if Not Result then Exit;

  ProgForm.Setup('Converting File to ASCII','','','',True);

  for ER:=0 to fRow-1 do
   Begin
    for EC:=0 to fCol-1 do
     begin
      If EC=0 then Result := ProgForm.Update2Gages(Trunc(ER/fRow*100),0);
      If Not Result then Exit;

      If Not GetNextNumber(ReadNum)
        then
          Begin
            OutMsg :=  'Error Reading '+FileN+ ' File.  Row:'+IntToStr(ER+1)+'; Col:'+IntToStr(EC+1)+'.';
            Result := False;
            ProgForm.Cleanup;
            SOF.Free;
            Exit;
          End;

      if ReadNum = No_Data then ReadNum := Write_No_Data;  // convert to -99 to save space

      IF Not SOF.WriteNextNumber(ReadNum,(EC=fcol-1) and (ER=frow-1))
        then
          Begin
            OutMsg :=  'Error Writing '+SOF.FileN+ ' File.  Row:'+IntToStr(ER+1)+'; Col:'+IntToStr(EC+1)+'.';
            Result := False;
            ProgForm.Cleanup;
            SOF.Free;
            Exit;
          End;

     end;
    SOF.CR;  // carriage return
   End;

  ProgForm.Cleanup;
  OutMsg :=  'Successfully Converted '+FileN+' to '+SOF.FileN;
  SOF.Free;

  EXCEPT
    If OutMsg = '' then OutMsg :=  'Error Converting '+FileN;
    Result := False;
    ProgForm.Cleanup;
    SOF.Free;
  END;

end;

function TSLAMMInputFile.ConvertToBinary: Boolean;
Const ProcSize = 65534;

Var ER,EC: Integer;
    SOF: TSLAMMOutputFile;
    ReadNum: Single;

Begin
  Result := not (POS('SLB',ExtractFileExt(FileN))>0);
  if Not Result then Exit;

  Result := PrepareFileForReading;
  if Not Result then Exit;

  TRY

  SOF := TSLAMMOutputFile.Create(fcol,frow,fxllcorner,fyllcorner,fcellsize,ChangeFileExt(FileN,'.SLB'));
  Result := SOF.WriteHeader(True);
  ConvertedFileN := SOF.FileN;

  if Not Result then Exit;


  ProgForm.YearLabel.Visible:=False;
  ProgForm.ProgressLabel.Caption := 'Converting File to Binary';
  ProgForm.Show;

  for ER:=0 to fRow-1 do
   for EC:=0 to fCol-1 do
    begin
      If EC=0 then Result := ProgForm.Update2Gages(Trunc(ER/fRow*100),0);
      If Not GetNextNumber(ReadNum)
        then
          Begin
            ShowMessage('Error Reading '+FileN+ ' File.  Row:'+IntToStr(ER+1)+'; Col:'+IntToStr(EC+1)+'.');
            Result := False;
            Exit;
          End;
      SOF.WriteNextNumber(ReadNum,(EC=fcol-1) and (ER=frow-1))
    end;  // ER, EC Loops

  ProgForm.Cleanup;
  SOF.Destroy;

  IterToRead := 0;

  EXCEPT
    Result := False;
    ProgForm.Cleanup;
  END;

end;

{ TSLAMMOutputFile }

Constructor TSLAMMOutputFile.Create(nc,nr: Integer; xll,yll,sz: Double; FN: String);
begin
  fCol := nc;
  fRow := nr;
  fXLLCorner := xll;
  fYLLCorner := yll;
  fcellsize := sz;
  FileN := FN;

  IsText := not (POS('SLB',ExtractFileExt(FN))>0);  // '.SLB signifies SLAMM Binary File

  WriteStream := Nil;
  Numwritten := 0;
  NumList := nil;
end;

destructor TSLAMMOutputFile.Destroy;
begin
  inherited;
  if IsText then CloseFile(TxtFile)
            else WriteStream.Free;
  WriteStream := nil;
  NumList := nil;
end;

function TSLAMMOutputFile.WriteHeader(Prompt: Boolean): Boolean;
Var ErrMsg: String;
begin
  Result := WriteHeader(Prompt,ErrMsg);
  If Not Result then ShowMessage(ErrMsg);
end;

function TSLAMMOutputFile.WriteHeader(Prompt: Boolean; ErrMsg: String): Boolean;
Var FileNPrompt: Boolean;
begin
  Result := True;
  ErrMsg := '';
  If Prompt then
   If FileExists(FileN) then
    If MessageDlg('Overwrite '+FileN+'?',mtconfirmation,[mbyes,mbno],0) = mrno then
      Begin
        if IsText then FileNPrompt := PromptForFileName(FileN,'ASCII RASTER File (*.ASC)|*.asc','.asc','Select ASCII File name',FileN,True)
                  else FileNPrompt := PromptForFileName(FileN,'SLAMM Binary File (*.slb)|*.slb','.slb','Select Binary File',FileN,True);

        if Not FileNPrompt then Begin ErrMsg := 'No Alternative Filename Chosen'; Result:=False; Exit; End;
      End;

  TRY

  if IsText then
    Begin
      AssignFile(TxtFile,FileN);
      Rewrite(TxtFile);
      Writeln(TxtFile,'ncols ',fCol);
      Writeln(TxtFile,'nrows ',fRow);
      Writeln(TxtFile,'xllcorner ',fXLLCorner);
      Writeln(TxtFile,'yllcorner ',fYLLCorner);
      Writeln(TxtFile,'cellsize ',FloatToStr(fcellsize));
      Writeln(TxtFile,'nodata_value ',IntToStr(WRITE_NO_DATA));
    End
  else // is Binary
    Begin
      WriteStream := TWriteCachedFileStream.Create(FileN,fmCreate);
      WriteStream.Write(SLBVersion,sizeof(SLBVersion));
      WriteStream.Write(fCol,sizeof(fCol));
      WriteStream.Write(fRow,sizeof(fRow));
      WriteStream.Write(fXLLCorner,sizeof(fXLLCorner));
      WriteStream.Write(fYLLCorner,sizeof(fYLLCorner));
      WriteStream.Write(fcellsize,sizeof(fcellsize));
    End;

  Except
    Result := False;
    ErrMsg := 'Error writing header for '+FileN;
    WriteStream := nil;
  END;
end;

Procedure TSLAMMOutputFile.CR;
begin
  if IsText then Writeln(TxtFile);
end;

function TSLAMMOutputFile.WriteNextNumber(Num: Single; LastNumber: Boolean): Boolean;

    {--------------------------------------------------------------------------------------}

    Procedure WriteBuffer;
    Var j,k: Integer;
    Begin
      inChain := False; ChainSize:=0; ChainDone := False;
      ReadingRepeat := False;

      for j := 0 to numwritten do
        Begin  // write the cells to the binary file;
          if Not InChain
            then
              Begin
                if j=numwritten then ReadingRepeat := False
                                else ReadingRepeat := NumList[j] = NumList[j+1];
                ChainSize := 0;
                InChain := True;
              End;   //not inchain

          if j=numwritten
            then ChainDone := True
            else
              Begin
                If (ReadingRepeat) then ChainDone := NumList[j] <> NumList[j+1]
                                   else Begin
                                          ChainDone := NumList[j] = NumList[j+1];
                                          if (j<numwritten-1) then ChainDone := ChainDone or (NumList[j+1] = NumList[j+2]);
                                        End;
              End;  //inchain

          Inc(ChainSize);

          if ChainDone then
            Begin
              WriteStream.Write(ReadingRepeat,Sizeof(ReadingRepeat));   // read whether this is a repeating value
              WriteStream.Write(ChainSize,Sizeof(ChainSize));  // read how many characters to repeat (or not repeat)

              if ReadingRepeat
                then
                  WriteStream.Write(NumList[j-1],Sizeof(NumList[j-1]))
                else
                  for k  := ChainSize-1 downto 0 do
                   WriteStream.Write(NumList[j-k],Sizeof(NumList[j-k]));
            End;

          if ChainDone then Begin
                              ChainDone := False;
                              InChain := False;
                            End;
        End; //for j := 0 to numwritten do
    End; //WriteBuffer

    {--------------------------------------------------------------------------------------}

begin // TSLAMMOutputFile.WriteNextNumber
  Result := True;
  if IsText then
    Begin
      If ABS(NUM-Round(NUM)) < 1e-8   // within 1e-8 of an integer so write an integer
        then Write(TxtFile,IntToStr(Round(Num)),' ')
        else Write(TxtFile,floattostrf(Num,ffgeneral,6,6),' ');
      Exit;
    End;

  if NumList = nil then SetLength(NumList,BufferSize+1);
  NumList[NumWritten] := num;  // add read number to the array in memory

  If (numwritten=BufferSize) or LastNumber then WriteBuffer;
  If (numwritten=BufferSize) then numwritten := 0  //reset for next big block read
                             else inc(numwritten);

end; // TSLAMMOutputFile.WriteNextNumber

end.
