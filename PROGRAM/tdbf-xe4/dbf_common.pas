unit dbf_common;

interface

{$I dbf_common.inc}

uses
  {$IFDEF UNICODE}AnsiStrings,{$ENDIF}
  SysUtils, Classes, DB
{$ifndef MSWINDOWS}
  , Types, dbf_wtil
{$ifdef KYLIX}
  , Libc
{$endif}  
{$endif}
  ;


const
  TDBF_MAJOR_VERSION      = 7;
  TDBF_MINOR_VERSION      = 0;
  TDBF_SUB_MINOR_VERSION  = 0;

  TDBF_TABLELEVEL_FOXPRO = 25;

  JulianDateDelta = 1721425; { number of days between 1.1.4714 BC and "0" }

type
  EDbfError = class (EDatabaseError);
  EDbfWriteError = class (EDbfError);

  TDbfFieldType = AnsiChar;

  TXBaseVersion   = (xUnknown, xClipper, xBaseIII, xBaseIV, xBaseV, xFoxPro, xBaseVII);
  TSearchKeyType = (stEqual, stGreaterEqual, stGreater);

  TDateTimeHandling       = (dtDateTime, dtBDETimeStamp);

//-------------------------------------

  PDateTime = ^TDateTime;
{$ifdef FPC_VERSION}
  TDateTimeAlias = type TDateTime;
  TDateTimeRec = record
    case TFieldType of
      ftDate: (Date: Longint);
      ftTime: (Time: Longint);
      ftDateTime: (DateTime: TDateTimeAlias);
  end;
{$else}
  PtrInt = Longint;
{$endif}

  PSmallInt = ^SmallInt;
  PCardinal = ^Cardinal;
  PDouble = ^Double;
  PString = ^String;
  PDateTimeRec = ^TDateTimeRec;

{$ifdef SUPPORT_INT64}
  PLargeInt = ^Int64;
{$endif}

{$ifdef DELPHI_3}
  LongWord = cardinal;
{$endif}

//-------------------------------------

{$ifndef SUPPORT_FREEANDNIL}
// some procedures for the less lucky who don't have newer versions yet :-)
procedure FreeAndNil(var v);
{$endif}
procedure FreeMemAndNil(var P: Pointer);

//-------------------------------------

{$ifndef SUPPORT_PATHDELIM}
const
{$ifdef MSWINDOWS}
  PathDelim = '\';
{$else}
  PathDelim = '/';
{$endif}
{$endif}

{$ifndef SUPPORT_INCLTRAILPATHDELIM}
function IncludeTrailingPathDelimiter(const Path: string): string;
{$endif}

//-------------------------------------

function GetCompletePath(const Base, Path: string): string;
function GetCompleteFileName(const Base, FileName: string): string;
function IsFullFilePath(const Path: string): Boolean; // full means not relative
function DateTimeToBDETimeStamp(aDT: TDateTime): double;
function BDETimeStampToDateTime(aBT: double): TDateTime;
function  GetStrFromInt(Val: Integer; const Dst: PChar): Integer;
procedure GetStrFromInt_Width(Val: Integer; const Width: Integer; const Dst: PAnsiChar; const PadChar: Char);
{$ifdef SUPPORT_INT64}
function  GetStrFromInt64(Val: Int64; const Dst: PChar): Integer;
procedure GetStrFromInt64_Width(Val: Int64; const Width: Integer; const Dst: PAnsiChar; const PadChar: Char);
{$endif}
procedure FindNextName(BaseName: string; var OutName: string; var Modifier: Integer);
{$ifdef USE_CACHE}
function GetFreeMemory: Integer;
{$endif}

// OH 2000-11-15 dBase7 support. Swap Byte order for 4 and 8 Byte Integer
function SwapWord(const Value: word): word;
function SwapInt(const Value: LongWord): LongWord;
{ SwapInt64 NOTE: do not call with same value for Value and Result ! }
procedure SwapInt64(Value, Result: Pointer); register;

function TranslateString(FromCP, ToCP: Cardinal; Src, Dest: PAnsiChar; Length: Integer): Integer;

// Returns a pointer to the first occurence of Chr in Str within the first Length characters
// Does not stop at null (#0) terminator!
function MemScan(const Buffer: Pointer; Chr: Byte; Length: Integer): Pointer;

// Delphi 3 does not have a Min function
{$ifdef DELPHI_3}
{$ifndef DELPHI_4}
function Min(x, y: integer): integer;
function Max(x, y: integer): integer;
{$endif}
{$endif}

implementation

{$ifdef MSWINDOWS}
uses
  Windows;
{$endif}

//====================================================================

function GetCompletePath(const Base, Path: string): string;
begin
  if IsFullFilePath(Path)
  then begin
    Result := Path;
  end else begin
    if Length(Base) > 0 then
      Result := ExpandFileName(IncludeTrailingPathDelimiter(Base) + Path)
    else
      Result := ExpandFileName(Path);
  end;

  // add last backslash if not present
  if Length(Result) > 0 then
    Result := IncludeTrailingPathDelimiter(Result);
end;

function IsFullFilePath(const Path: string): Boolean; // full means not relative
begin
{$ifdef MSWINDOWS}
  Result := Length(Path) > 1;
  if Result then
    // check for 'x:' or '\\' at start of path
    Result := ((Path[2]=':') and {$IFDEF DELPHI_2009}CharInSet{$ENDIF}(upcase(Path[1]) {$IFDEF DELPHI_2009},{$ELSE} in {$ENDIF}['A'..'Z']))
      or ((Path[1]='\') and (Path[2]='\'));
{$else}  // Linux
  Result := Length(Path) > 0;
  if Result then
    Result := Path[1]='/';
 {$endif}
end;

//====================================================================

function GetCompleteFileName(const Base, FileName: string): string;
var
  lpath: string;
  lfile: string;
begin
  lpath := GetCompletePath(Base, ExtractFilePath(FileName));
  lfile := ExtractFileName(FileName);
  lpath := lpath + lfile;
  result := lpath;
end;

// it seems there is no pascal function to convert an integer into a PAnsiChar???

procedure GetStrFromInt_Width(Val: Integer; const Width: Integer; const Dst: PAnsiChar; const PadChar: Char);
var
  Temp: array[0..10] of AnsiChar;
  I, J: Integer;
  NegSign: boolean;
begin
  {$I getstrfromint.inc}
end;

{$ifdef SUPPORT_INT64}

procedure GetStrFromInt64_Width(Val: Int64; const Width: Integer; const Dst: PAnsiChar; const PadChar: Char);
var
  Temp: array[0..19] of AnsiChar;
  I, J: Integer;
  NegSign: boolean;
begin
  {$I getstrfromint.inc}
end;

{$endif}

// it seems there is no pascal function to convert an integer into a PAnsiChar???
// NOTE: in dbf_dbffile.pas there is also a convert routine, but is slightly different

function GetStrFromInt(Val: Integer; const Dst: PChar): Integer;
var
  Temp: array[0..10] of Char;
  I, J: Integer;
begin
  Val := Abs(Val);
  // we'll have to store characters backwards first
  I := 0;
  J := 0;
  repeat
    Temp[I] := Chr((Val mod 10) + Ord('0'));
    Val := Val div 10;
    Inc(I);
  until Val = 0;

  // remember number of digits
  Result := I;
  // copy value, remember: stored backwards
  repeat
    Dst[J] := Temp[I-1];
    Inc(J);
    Dec(I);
  until I = 0;
  // done!
end;

{$ifdef SUPPORT_INT64}

function GetStrFromInt64(Val: Int64; const Dst: PChar): Integer;
var
  Temp: array[0..19] of Char;
  I, J: Integer;
begin
  Val := Abs(Val);
  // we'll have to store characters backwards first
  I := 0;
  J := 0;
  repeat
    Temp[I] := Chr((Val mod 10) + Ord('0'));
    Val := Val div 10;
    Inc(I);
  until Val = 0;

  // remember number of digits
  Result := I;
  // copy value, remember: stored backwards
  repeat
    Dst[J] := Temp[I-1];
    inc(J);
    dec(I);
  until I = 0;
  // done!
end;

{$endif}

function DateTimeToBDETimeStamp(aDT: TDateTime): double;
var
  aTS: TTimeStamp;
begin
  aTS := DateTimeToTimeStamp(aDT);
  Result := TimeStampToMSecs(aTS);
end;

function BDETimeStampToDateTime(aBT: double): TDateTime;
var
  aTS: TTimeStamp;
begin
  aTS := MSecsToTimeStamp(Round(aBT));
  Result := TimeStampToDateTime(aTS);
end;

//====================================================================

{$ifndef SUPPORT_FREEANDNIL}

procedure FreeAndNil(var v);
var
  Temp: TObject;
begin
  Temp := TObject(v);
  TObject(v) := nil;
  Temp.Free;
end;

{$endif}

procedure FreeMemAndNil(var P: Pointer);
var
  Temp: Pointer;
begin
  Temp := P;
  P := nil;
  FreeMem(Temp);
end;

//====================================================================

{$ifndef SUPPORT_INCLTRAILPATHDELIM}
{$ifndef SUPPORT_INCLTRAILBACKSLASH}

function IncludeTrailingPathDelimiter(const Path: string): string;
var
  len: Integer;
begin
  Result := Path;
  len := Length(Result);
  if len = 0 then
    Result := PathDelim
  else
  if Result[len] <> PathDelim then
    Result := Result + PathDelim;
end;

{$else}

function IncludeTrailingPathDelimiter(const Path: string): string;
begin
{$ifdef MSWINDOWS}
  Result := IncludeTrailingBackslash(Path);
{$else}
  Result := IncludeTrailingSlash(Path);
{$endif}
end;

{$endif}
{$endif}

{$ifdef USE_CACHE}

function GetFreeMemory: Integer;
var
  MemStatus: TMemoryStatus;
begin
  GlobalMemoryStatus(MemStatus);
  Result := MemStatus.dwAvailPhys;
end;

{$endif}

//====================================================================
// Utility routines
//====================================================================

function SwapWord(const Value: word): word;
begin
  Result := ((Value and $FF) shl 8) or ((Value shr 8) and $FF);
end;

{$ifdef USE_ASSEMBLER_486_UP}

function SwapInt(const Value: LongWord): LongWord; register; assembler;
asm
  BSWAP EAX;
end;

procedure SwapInt64(Value {EAX}, Result {EDX}: Pointer); register; assembler;
asm
  MOV ECX, LongWord ptr [EAX]
  MOV EAX, LongWord ptr [EAX + 4]
  BSWAP ECX 
  BSWAP EAX 
  MOV LongWord ptr [EDX+4], ECX
  MOV LongWord ptr [EDX], EAX
end;

{$else}

function SwapInt(const Value: Cardinal): Cardinal;
begin
  PByteArray(@Result)[0] := PByteArray(@Value)[3];
  PByteArray(@Result)[1] := PByteArray(@Value)[2];
  PByteArray(@Result)[2] := PByteArray(@Value)[1];
  PByteArray(@Result)[3] := PByteArray(@Value)[0];
end;

procedure SwapInt64(Value, Result: Pointer); register;
var
  PtrResult: PByteArray;
  PtrSource: PByteArray;
begin
  // temporary storage is actually not needed, but otherwise compiler crashes (?)
  PtrResult := PByteArray(Result);
  PtrSource := PByteArray(Value);
  PtrResult[0] := PtrSource[7];
  PtrResult[1] := PtrSource[6];
  PtrResult[2] := PtrSource[5];
  PtrResult[3] := PtrSource[4];
  PtrResult[4] := PtrSource[3];
  PtrResult[5] := PtrSource[2];
  PtrResult[6] := PtrSource[1];
  PtrResult[7] := PtrSource[0];
end;

{$endif}

function TranslateString(FromCP, ToCP: Cardinal; Src, Dest: PAnsiChar; Length: Integer): Integer;
var
  WideCharStr: array[0..1023] of WideChar;
  wideBytes: Cardinal;
begin
  if Length = -1 then
    Length := {$IFDEF DELPHI_XE4}AnsiStrings.StrLen(Src){$ELSE}StrLen(Src){$ENDIF};
  Result := Length;
  if (FromCP = GetOEMCP) and (ToCP = GetACP) then
  begin
    {$IFDEF DELPHI_2009}   // Rafal Chlopek (14-03-2010):  I've commented DELPHI_2010
    OemToCharBuff(Src, PChar(Dest), Length)
    {$ELSE}
    OemToCharBuff(Src, PChar(Dest), Length)
    {$ENDIF}
  end
  else
  if (FromCP = GetACP) and (ToCP = GetOEMCP) then
  begin
    {$IFDEF DELPHI_2009}
    CharToOemBuff(PChar(Src), Dest, Length)
    {$ELSE}
    CharToOemBuff(PChar(Src), Dest, Length)
    {$ENDIF}
  end
  else
  if FromCP = ToCP then
  begin
    if Src <> Dest then
      Move(Src^, Dest^, Length);
  end else begin
    // does this work on Win95/98/ME?
    wideBytes := MultiByteToWideChar(FromCP, MB_PRECOMPOSED, PAnsiChar(Src), Length, LPWSTR(@WideCharStr[0]), 1024);
    WideCharToMultiByte(ToCP, 0, LPWSTR(@WideCharStr[0]), wideBytes, PAnsiChar(Dest), Length, nil, nil);
  end;
end;

procedure FindNextName(BaseName: string; var OutName: string; var Modifier: Integer);
var
  Extension: string;
begin
  Extension := ExtractFileExt(BaseName);
  BaseName := Copy(BaseName, 1, Length(BaseName)-Length(Extension));
  repeat
    Inc(Modifier);
    OutName := ChangeFileExt(BaseName+'_'+IntToStr(Modifier), Extension);
  until not FileExists(OutName);
end;

{$ifdef FPC}

function MemScan(const Buffer: Pointer; Chr: Byte; Length: Integer): Pointer;
var
  I: Integer;
begin
  I := System.IndexByte(Buffer, Length, Chr);
  if I = -1 then
    Result := nil
  else
    Result := Buffer+I;
end;

{$else}

function MemScan(const Buffer: Pointer; Chr: Byte; Length: Integer): Pointer;
var
  p: PByte;
begin
  p := Buffer;

  while ( (Length>0) and (p^ <> Chr) ) do
  begin
    Inc(p);
    Dec(Length);
  end;

  if Length>0 then
    Result := p
  else
    Result := nil;
end;


(*
function MemScan(const Buffer: Pointer; Chr: Byte; Length: Integer): Pointer;
asm
        PUSH    EDI
        MOV     EDI,Buffer
        MOV     AL, Chr
        MOV     ECX,Length
        REPNE   SCASB
        MOV     EAX,0
        JNE     @@1
        MOV     EAX,EDI
        DEC     EAX
@@1:    POP     EDI
end; *)

{$endif}

{$ifdef DELPHI_3}
{$ifndef DELPHI_4}

function Min(x, y: integer): integer;
begin
  if x < y then
    result := x
  else
    result := y;
end;

function Max(x, y: integer): integer;
begin
  if x < y then
    result := y
  else
    result := x;
end;

{$endif}
{$endif}

end.



