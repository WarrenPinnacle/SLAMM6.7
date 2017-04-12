//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

{$EXTERNALSYM SetFilePointerEx}
function SetFilePointerEx; external kernel32 name 'SetFilePointerEx';

function FileSeek64(Handle: Integer; const Offset: Int64; Origin: Integer): Int64;
begin
  Result := Offset;
  Int64Rec(Result).Lo := SetFilePointerEx(THandle(Handle),Offset,nil, Origin);
end;


PROCEDURE TSLAMM_Simulation.SetBit(N: BYTE; Row, Col: INTEGER; SetTrue: BOOLEAN);
BEGIN
    IF SetTrue THEN
      BMatrix[Site.RunCols*(Row)+(Col)] := (BMatrix[Site.RunCols*(Row)+(Col)] OR N)
    ELSE
      BMatrix[Site.RunCols*(Row)+(Col)] := (BMatrix[Site.RunCols*(Row)+(Col)] AND (NOT N))
END;

FUNCTION TSLAMM_Simulation.GetBit(N: BYTE; Row, Col: INTEGER): BOOLEAN;
BEGIN
    GetBit := ((BMatrix[Site.RunCols*(Row)+(Col)] AND N) > 0);
END;

Function CopyFileProg(Src,Dst: String): Boolean;
{Copy a file from the source to the destination paths indicated,
 Copied out of Delphi Help under BlockRead}

        procedure CardinalsToI64(var I: Int64; const LowPart, HighPart: Cardinal);
        begin
          TULargeInteger(I).LowPart := LowPart;
          TULargeInteger(I).HighPart := HighPart;
        end;

Var Source,Dest: File;
    ProgPct,NumRead,NumWritten: Integer;
    TotalNumWritten, TotalNumToWrite: Int64;
    Buf: array[1..32768] of Char;

Begin
  CopyFileProg:=True;
  TotalNumWritten:=0;
  ProgForm.Gauge1.Progress:=0;
  ProgForm.ProgressLabel.Caption:='Copying File to Working Map File (*.S50 to *.MAPBAK)';
  ProgForm.Show;
  ProgForm.Update;
     Try
         AssignFile(Source,Src);
         AssignFile(Dest,Dst);
         Reset(Source,1);
         Try
           TotalNumToWrite:=FileSize(Source);
         Except
           TotalNumToWrite := 2000000000;  {bytes, at least}
         End;

         Rewrite(Dest,1);
         Repeat
           Blockread(Source,Buf,Sizeof(Buf),NumRead);
           Blockwrite(Dest,Buf,NumRead,NumWritten);
           TotalNumWritten:=TotalNumWritten+NumWritten;
           ProgPct := Trunc(TotalNumWritten/TotalNumToWrite*100);
           If ProgPct>100 then ProgPct := (ProgPct MOD 100);  {loop through pctgs when file > 2gb}
           If ProgPct>ProgForm.Gauge1.Progress then If Not ProgForm.Update2Gages(ProgPct,0) then Begin Result := False; Exit; End;
         Until (NumRead=0) or (NumWritten<>NumRead);
         System.CloseFile(Source);
         System.CloseFile(Dest);
      Except
         MessageDlg('File Copy Error:  '+src+'  to  '+dst,mterror,[mbOK],0);
         CopyFileProg:=False;
      end; {try}
  ProgForm.Hide;
End;


PROCEDURE TSLAMM_Simulation.MakeMem(Cell: CompressedCell);
VAR I, j: Integer;
    LF: Integer;
    NumBlocks: Integer;
BEGIN
  If NumMMEntries < 1 then
      Count_MMEntries;

  NumBlocks := (NumMMEntries DIV BLOCKSIZE) + 1;

  LF := Length(Map);
  If LF < NumBlocks then
     Begin
       DisposeMem;
       If BatchMode then SetLength(Map,TRUNC(1.2*NumBlocks))
                    else SetLength(Map,NumBlocks);

       For i := 0 to NumBlocks-1 do
         New(Map[i]);
     End;

  FOR I := 0 TO (NumBlocks-1) DO
   For j := 0 to BLOCKSIZE - 1 do
    Map[I]^[J] := Cell;
END;

PROCEDURE TSLAMM_Simulation.DisposeMem;
Var LF, i: Integer;
Begin
  If Map<>nil then
    Begin
      LF := Length(Map);
      For i := 0 to LF-1 do
        Dispose(Map[i]);
      Map := nil;
    End;
End;


Function TSLAMM_Simulation.RetCellMatrix(Row, Col: Int64; Var Cell: CompressedCell):Boolean;  {returns optimized cell based on matrix, not map}
Var MatrResult: Integer;
Begin
  MatrResult := MapMatrix[Site.RunCols*(Row)+(Col)];

  if Large_Raster_Edit then Begin  BlankCell.Cats[1] := MatrResult-1; Cell := BlankCell; Result := True; Exit; End;

  Result := False;
  If MatrResult >= 0 then exit;

  Result := True;
  If MatrResult = -99  then Cell := BlankCell;
  With Categories do
    Begin
      If MatrResult = -(ORD(OpenOcean)+1)then Cell := OceanCell;
      If MatrResult = -(ORD(EstuarineWater)+1) then Cell := EOWCell;
      If MatrResult = -(ORD(DevDryLand)+1)then Cell := DevDryCell;
      If MatrResult = -(ORD(UndDryLand)+1)then Cell := UndDryCell;
    End;
End;


PROCEDURE TSLAMM_Simulation.RetMem(VAR F: MSArray; Row, Col: WORD; Var Cell: CompressedCell);
Var Block,SubBlock: Integer;

BEGIN
  Try

  If RetCellMatrix(Row,Col,Cell) then exit;

  Block := MapMatrix[Site.RunCols*(Row)+(Col)] div BLOCKSIZE;
  SubBlock := MapMatrix[Site.RunCols*(Row)+(Col)] - (Block*BLOCKSIZE);

  Cell := F[Block]^[SubBlock];

  Except
    ShowMessage('SLAMM Memory Read Error.  Possibly maps have changed since last time SLAMM "counted" cells.  Try using the "count" button within "File Setup."');
    Raise;
  End;

END;

PROCEDURE TSLAMM_Simulation.SetMem(VAR F: MSArray; Row, Col: WORD; Var Cell: CompressedCell);
Var Block,SubBlock: Integer;
    FlatCalc: LongInt;

BEGIN
  FlatCalc := Site.RunCols*(Row)+(Col);
  if Large_Raster_Edit then Begin MapMatrix[FlatCalc] := ORD(Cell.Cats[1])+1; exit; end;

  With Categories do
  If MapMatrix[FlatCalc] = -(ORD(EstuarineWater)+1)
    then Begin
           If CellWidth(@Cell,OpenOcean) > CellWidth(@Cell,EstuarineWater)
              then MapMatrix[FlatCalc] := -(ORD(OpenOcean)+1);
           Exit;
         End;
  If MapMatrix[FlatCalc] < 0 then exit;

  Block := MapMatrix[FlatCalc] div BLOCKSIZE;
  SubBlock := MapMatrix[FlatCalc] - (Block*BLOCKSIZE);   //optimize?

  Try
    F[Block]^[SubBlock] := Cell;
  Except
    on E:ERangeError do
     begin
       If OptimizeLevel>0 then
         If MessageDlg('Range Check Error.  This likely means your map has changed and you need to re-count cells to track for optimization.  Recount now?',
            mtconfirmation,[mbyes,mbno],0) = MRYes then
              Begin
                Count_MMEntries;
                ShowMessage('The original range-check error will now show at which point you can retry your operation because the cells have been counted.');
              End;
       Raise;
     end;
  End
END;


PROCEDURE TSLAMM_Simulation.LoadFile(VAR H: THandle; filen: String);

BEGIN
  H := FileOpen(filen,fmOpenReadWrite);
END;


FUNCTIOn TSLAMM_Simulation.MakeFile(VAR H: THandle; Rows, Cols: WORD; filen: String; Cell: CompressedCell): Boolean;

VAR
  I: Integer;
  DA: Array of CompressedCell;

BEGIN
  H := FileCreate(FileN);

  SetLength(DA,DiskUnit);

  For i := 1 to DiskUnit do
    DA[i-1] := Cell;

  ProgForm.ProgressLabel.Caption:='Creating File on Disk';

  FOR I := 1 TO (NumMMEntries Div DiskUnit) DO
    Begin

      If Trunc(I/((NumMMEntries) Div DiskUnit) *100) <> ProgForm.Gauge1.Progress then
               If Not ProgForm.Update2Gages(Trunc(I/((NumMMEntries) Div DiskUnit) *100),0)
                  then Begin Result := False; UserStop := True; Exit;  End;

      FileWrite(H,DA[0],Sizeof(Cell)*DiskUnit);
    End;

 FileWrite(H,DA[0],Sizeof(Cell)*((NumMMEntries) MOD DiskUnit));

 DA := nil;
 Result := True;

END;

PROCEDURE TSLAMM_Simulation.RetFile(VAR H: THandle; Row, Col: Int64; VAR Cell: CompressedCell);
const fsFromBeginning = 0;
      fsFromCurrent = 1;

Var sfp: Int64;
    res: Integer;
BEGIN
  If RetCellMatrix(Row,Col,Cell) then exit;

  sfp := Int64(MapMatrix[Site.RunCols*(Row)+(Col)])* Int64(Sizeof(Cell));
  FileSeek64(MapHandle,Int64(sfp),fsFromBeginning);
  Cell := BlankCell;
  Res := FileRead(MapHandle,Cell,Sizeof(Cell));
  If Res<Sizeof(Cell) then
    Begin
       Raise ESLAMMError.Create('File Read Error.');
    End;

END;

PROCEDURE TSLAMM_Simulation.SetFile(Row, Col: Int64; VAR Cell: CompressedCell);
const fsFromBeginning = 0;
Var sfp: Int64;

BEGIN
  If not SaveMapsToDisk then Exit;
  With Categories do
  If MapMatrix[Site.RunCols*(Row)+(Col)] = -(ORD(EstuarineWater)+1)
    then Begin
           If CellWidth(@Cell,OpenOcean) > CellWidth(@Cell,EstuarineWater)
              then MapMatrix[Site.RunCols*(Row)+(Col)] := -(ORD(OpenOcean)+1);
           Exit;
         End;
  If MapMatrix[Site.RunCols*(Row)+(Col)] < 0 then exit;

  sfp := Int64(MapMatrix[Site.RunCols*(Row)+(Col)])* Int64(Sizeof(Cell));

  FileSeek64(MapHandle,sfp,fsFromBeginning);
  FileWrite(MapHandle,Cell,Sizeof(Cell));
END;

PROCEDURE TSLAMM_Simulation.RetA(Row, Col: WORD; VAR Cell: CompressedCell);

BEGIN
  If SaveMapsToDisk
    then RetFile(MapHandle,Row,Col,Cell)
    else RetMem(Map,Row,Col,Cell);
END;


PROCEDURE TSLAMM_Simulation.SetA(Row, Col: WORD; VAR Cell: CompressedCell);

BEGIN
  If SaveMapsToDisk
    then SetFile(Row,Col,Cell)
    else SetMem(Map,Row,Col,Cell);
END;



PROCEDURE TSLAMM_Simulation.DisposeFile(VAR H: THandle; Delete_file: BOOLEAN; FileN: String);
Var F: File;
BEGIN
  If SaveMapsToDisk then
    Begin
      FileClose(H);
      IF Delete_File THEN
        Begin
          AssignFile(F,filen);
          Erase(F);
        End;
    End;
END;