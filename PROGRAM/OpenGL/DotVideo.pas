unit DotVideo;

interface

uses
  SysUtils, Forms, Windows, VFW;

type
  TDotVideoRecorder = class
  private
    FName: String;                    // Output filename
    FWidth, FHeight: Integer;         // Output dimensions
    FHeader: TAVIStreamInfo;          // AVI header
    FFile: IAVIFile;
    FPS: IAVIStream;
    FPSCompressed: IAVIStream;        // Video stream handles
    FOpts: TAVICompressOptions;
    FAOpts: PAVICompressOptions;      // Output options (compression etc.)
    FNumFrames: Integer;              // Number of frames currently captured
    FOK: Boolean;                     // Any errors thusfar?
    FParentWin: TForm;                // Window we're recording from
    FFrameRate: Integer;              // AVI framerate
  public
    constructor Create;
    destructor Destroy; override;
    procedure StartCapture(const name: String; const window: TForm; const fps: Integer);
    procedure EndCapture;
    function Snap: Boolean;
    property OK: Boolean read FOK;
    property NumFrames: Integer read FNumFrames;
  end;

implementation

procedure Error(const s: String);
var
  f: TextFile;
begin

  // Write error messages to a log file.
  AssignFile(f, '.\errors.txt');
  if FileExists('.\errors.txt') then Append(f)
  else Rewrite(f);
  WriteLn(f, s);
  CloseFile(f);

end;

function GetDIBits(dc: HDC; bmp: HBITMAP; startscan, scanlines: UINT;
                   bits: Pointer; bi: PBitmapInfo; usage: UINT): Integer;
         stdcall; external 'GDI32.dll';

function dotMakeDib(hbmp: HBITMAP; bits: UINT): THandle;
var
  hdib: THandle;
  dc: HDC;
  bmp: BITMAP;
  wLineLen: UINT;
  dwSize: DWORD;
  wColSize: DWORD;
  lpbi: PBitmapInfoHeader;
  lpBits: ^Byte;
begin

  // Create a DIB that we can write to the AVI stream.

  GetObject(hbmp, SizeOf(BITMAP), @bmp);

  wLineLen := (bmp.bmWidth*bits + 31) div 32 * 4;
  if bits <= 8 then wColSize := SizeOf(RGBQUAD) * (1 shl bits)
  else wColSize := 0;
  dwSize := SizeOf(TBitmapInfoHeader) + wColSize + wLineLen*bmp.bmHeight;

  hdib := GlobalAlloc(GHND, dwSize);
  if hdib = 0 then
  begin
    Result := hdib;
    Exit;
  end;

  lpbi := GlobalLock(hdib);

  lpbi^.biSize := sizeof(BITMAPINFOHEADER) ;
  lpbi^.biWidth := bmp.bmWidth ;
  lpbi^.biHeight := bmp.bmHeight ;
  lpbi^.biPlanes := 1 ;
  lpbi^.biBitCount := bits ;
  lpbi^.biCompression := BI_RGB ;
  lpbi^.biSizeImage := dwSize - sizeof(BITMAPINFOHEADER) - wColSize ;
  lpbi^.biXPelsPerMeter := 0 ;
  lpbi^.biYPelsPerMeter := 0 ;
  if bits <= 8 then lpbi^.biClrUsed := 1 shl bits
  else lpbi^.biClrUsed := 0;
  lpbi^.biClrImportant := 0;

  lpBits := Pointer(Integer(lpbi) + SizeOf(TBitmapInfoHeader) + wColSize);

  dc := CreateCompatibleDC(0);

  GetDIBits(dc, hbmp, 0, bmp.bmHeight, lpBits, PBitmapInfo(lpbi), DIB_RGB_COLORS);

  if bits <= 8 then lpbi^.biClrUsed := 1 shl bits
  else lpbi^.biClrUsed := 0;

  DeleteDC(dc) ;
  GlobalUnlock(hdib);

  Result := hdib;

end;

function dotLoadBitmapFromFrameBuffer(w, h: Integer): HBITMAP;
var
  hdcScreen, hdcCompatible: HDC;
  hbmScreen: HBITMAP;
begin

  // Take a snapshot from the capture window, and return it as a HBITMAP.

  // Source DC:
  hdcScreen := wglGetCurrentDC();
  // Destination DC:
  hdcCompatible := CreateCompatibleDC(hdcScreen);

  hbmScreen := CreateCompatibleBitmap(hdcScreen, w, h);

  if hbmScreen = 0 then
  begin
    raise Exception.Create('CreateCompatibleBitmap() failed!');
  end;

  if SelectObject(hdcCompatible, hbmScreen) = 0 then
  begin
    raise Exception.Create('SelectObject() failed!');
  end;

  if not BitBlt(hdcCompatible, 0, 0, w, h, hdcScreen, 0, 0, SRCCOPY) then
  begin
    raise Exception.Create('BitBlt() failed!');
  end;

  DeleteDC(hdcCompatible);

  Result := hbmScreen;

end;

constructor TDotVideoRecorder.Create;
var
  ver: Word;
begin

  inherited Create;

  FName := '';
  FWidth := -1;
  FHeight := -1;
  FOK := TRUE;
  FNumFrames := 0;

  FFile := nil;
  FPS := nil;
  FPSCompressed := nil;
  FAOpts := @FOpts;
  FFrameRate := 0;

  // Check VFW version.
  ver := HiWord(VideoForWindowsVersion());
  if ver < $010A then
  begin
    raise Exception.Create('Your Video For Windows version is too old!');
  end;

  AVIFileInit;

end;

destructor TDotVideoRecorder.Destroy;
begin

  AVIFileExit;

  inherited Destroy;

end;

procedure TDotVideoRecorder.StartCapture(const name: String; const window: TForm; const fps: Integer);
begin

  FName := name;
  FWidth := window.ClientWidth;
  FHeight := window.ClientHeight;
  FParentWin := window;
  FFrameRate := fps;

end;

procedure TDotVideoRecorder.EndCapture;
begin

  FName := '';
  FWidth := -1;
  FHeight := -1;
  FOK := TRUE;
  FNumFrames := 0;

  { The Delphi compiler handles the ref-counting on these interfaces
    automagically, so don't free them explicitly! The original C++ code did
    have calls to AVIStreamRelease() here. }
  FFile := nil;
  FPS := nil;
  FPSCompressed := nil;
  FAOpts := @FOpts;

end;

function TDotVideoRecorder.Snap: Boolean;
var
  hr: HRESULT;
  bmp: HBITMAP;
  alpbi: PBitmapInfoHeader;
begin

  if not FOK then
  begin
    // Errors? Don't try to capture anything!
    Result := FALSE;
    Exit;
  end;

  // Snap the screenshot.
  bmp := dotLoadBitmapFromFrameBuffer(FWidth, FHeight);

  // Turn it into a DIB.
  alpbi := GlobalLock(dotMakeDib(bmp, 32));
  DeleteObject(bmp);

  // Lots of error checking:
  
  if alpbi = nil then
  begin
    FOK := FALSE;
    Result := FALSE;
    Error('alpbi = nil');
    Exit;
  end;

  if (FWidth >= 0) and (FWidth <> alpbi^.biWidth) then
  begin
    GlobalFreePtr(alpbi);
    FOK := FALSE;
    Result := FALSE;
    Error('alpbi width is invalid');
    Exit;
  end;

  if (FHeight >= 0) and (FHeight <> alpbi^.biHeight) then
  begin
    GlobalFreePtr(alpbi);
    FOK := FALSE;
    Result := FALSE;
    Error('alpbi height is invalid');
    Exit;
  end;

  // DIB is okay, so proceed:
  FWidth := alpbi^.biWidth;
  FHeight := alpbi^.biHeight;
  if FNumFrames = 0 then
  begin
    // If it's the first frame, open a stream and configure.
    hr := AVIFileOpen(FFile, PChar(FName), OF_WRITE or OF_CREATE, nil);
    if hr <> AVIERR_OK then
    begin
      GlobalFreePtr(alpbi);
      FOK := FALSE;
      Result := FALSE;
      Error('AVIFileOpen() failed');
      Exit;
    end;

    FillChar(FHeader, SizeOf(TAVIStreamInfo), 0);
    FHeader.fccType                := streamtypeVIDEO;
    FHeader.fccHandler             := 0;
    FHeader.dwScale                := 1;
    FHeader.dwRate                 := FFrameRate;
    FHeader.dwSuggestedBufferSize  := alpbi^.biSizeImage;
    SetRect(FHeader.rcFrame, 0, 0, alpbi^.biWidth, alpbi^.biHeight);

    hr := AVIFileCreateStream(FFile, FPS, FHeader);
    if hr <> AVIERR_OK then
    begin
      GlobalFreePtr(alpbi);
      FOK := FALSE;
      Result := FALSE;
      Error('AVIFileCreateStream() failed');
      Exit;
    end;

    FillChar(FOpts, SizeOf(TAVICompressOptions), 0);

    // Ask the user for compression options:
    if not AVISaveOptions(FParentWin.Handle, 0, 1, FPS, FAOpts) then
    begin
      GlobalFreePtr(alpbi);
      FOK := FALSE;
      Result := FALSE;
      Error('AVISaveOptions() failed');
      Exit;
    end;

    hr := AVIMakeCompressedStream(FPSCompressed, FPS, @FOpts, nil);
    if hr <> AVIERR_OK then
    begin
      GlobalFreePtr(alpbi);
      FOK := FALSE;
      Result := FALSE;
      Error('AVIMakeCompressedStream() failed');
      Exit;
    end;

    hr := AVIStreamSetFormat(FPSCompressed, 0, alpbi,
                             alpbi^.biSize + alpbi^.biClrUsed * SizeOf(RGBQUAD));
    if hr <> AVIERR_OK then
    begin
      GlobalFreePtr(alpbi);
      FOK := FALSE;
      Result := FALSE;
      Error('AVIStreamSetFormat() failed');
      Exit;
    end;
  end;

  // Write the image to the stream.
  hr := AVIStreamWrite(FPSCompressed, FNumFrames, 1,
                       Pointer(Integer(alpbi) + alpbi^.biSize + alpbi^.biClrUsed * sizeof(RGBQUAD)),
                       alpbi^.biSizeImage, AVIIF_KEYFRAME, nil, nil);
  if hr <> AVIERR_OK then
  begin
    GlobalFreePtr(alpbi);
    FOK := FALSE;
    Result := FALSE;
    Error('AVIStreamWrite() failed');
    Exit;
  end;

  GlobalFreePtr(alpbi);
  INC(FNumFrames);
  Result := TRUE;

end;

end.
