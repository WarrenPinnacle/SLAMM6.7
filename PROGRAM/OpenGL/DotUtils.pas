unit DotUtils;

interface

uses
  Windows, Forms, SysUtils, Classes, GL, GLu;

// Timer functions.
function dotTime: Int64;
function dotTimeSince(start: Int64): Single;
procedure dotStartTiming;
function dotTimeElapsed: Single;

// File functions.
function dotFindFiles(const mask: String; attrib: Integer): TStringList;

// Debugging functions.
function dotWin32ErrorString(code: Integer): String;
function dotReadVersionInfo(filename: String): String;
procedure dotGLAssert(const cause: TObject; const location, msg: String);

type
  EDotException = class(Exception);

implementation

uses
  Dialogs;

var
  StartTime: Int64;
  freq: Int64;

function dotTime: Int64;
begin

  // Return the current performance counter value.
  QueryPerformanceCounter(Result);

end;

function dotTimeSince(start: Int64): Single;
var
  x: Int64;
begin

  // Return the time elapsed since start (get start with dotTime()).
  QueryPerformanceCounter(x);
  Result := (x - start) * 1000 / freq;

end;

procedure dotStartTiming;
begin

  // Call this to start measuring elapsed time.
  StartTime := dotTime;

end;

function dotTimeElapsed: Single;
begin

  // Call this to measure the time elapsed since the last StartTiming call.
  Result := dotTimeSince(StartTime);

end;

function dotFindFiles(const mask: String; attrib: Integer): TStringList;
var
  srec: TSearchRec;
begin

  // Find all files matching the given mask (e.g. '*.pas').
  Result := TStringList.Create;
  FillChar(srec, SizeOf(srec), 0);
  if FindFirst(mask, attrib, srec) = 0 then
  begin
    Result.Add(srec.Name);
    while FindNext(srec) = 0 do Result.Add(srec.Name);
    FindClose(srec);
  end;

end;

function dotWin32ErrorString(code: Integer): String;
var
  lpMsgBuf: PChar;
begin

  FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or
                FORMAT_MESSAGE_FROM_SYSTEM or
                FORMAT_MESSAGE_IGNORE_INSERTS,
                nil,
                code,
                0,
                @lpMsgBuf,
                0,
                nil);
  Result := String(lpMsgBuf);
  LocalFree(Cardinal(lpMsgBuf));              

end;

function dotReadVersionInfo(filename: String): String;
type
  T2Words = record
    case Boolean of
      TRUE: (C: Cardinal);
      FALSE: (Lo, Hi: Word);
  end;
var
  size: Cardinal;
  p, vs: Pointer;
  MS, LS: T2Words;
begin

  // Read a file's version info resource and return it as a string.
  size := GetFileVersionInfoSize(PChar(filename), size);

  if size > 0 then
  begin
    GetMem(p, size);
    GetFileVersionInfo(PChar(Application.ExeName), 0, size, p);

    VerQueryValue(p, '\', vs, size);
    with TVSFixedFileInfo(vs^) do
    begin
      MS.C := dwFileVersionMS;
      LS.C := dwFileVersionLS;
      Result := Format('%d.%d.%d build %d', [MS.Hi, MS.Lo, LS.Hi, LS.Lo]);
    end;
  end
  else Result := 'unknown';

end;

procedure dotGLAssert(const cause: TObject; const location, msg: String);
{$IFOPT C+}
var
  err: GLenum;
  err_string: String;
{$ENDIF}
begin

{$IFOPT C+}
  err := glGetError;
  if err <> GL_NO_ERROR then
  begin
    err_string := UpperCase(String(PChar(gluErrorString(err))));
    if msg <> '' then
    begin
      err_string := err_string + ' at ';
      if cause <> nil then err_string := err_string + cause.ClassName + '.';
      err_string := err_string + location + ': ' + msg;
    end;
    MessageBox(0,
               PChar(EAssertionFailed.Create(err_string).Message),
               PChar('OpenGL error'),
               MB_OK or MB_ICONERROR or MB_SYSTEMMODAL);
    // Halt($D07);
  end;
{$ENDIF}

end;

initialization

  QueryPerformanceFrequency(freq);

end.
