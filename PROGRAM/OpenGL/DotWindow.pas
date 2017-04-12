unit DotWindow;

interface

uses
  Windows, Forms, Classes, SysUtils, DotTmpWin, GL, GLext;

type
  TDotPFAttribi = record
    Name: GLint;
    Value: GLint;
  end;
  TDotPFAttribf = record
    Name: GLfloat;
    Value: GLfloat;
  end;

type
  TDotContext = class
  protected
    FDC: HDC;
    FRC: HGLRC;
    FTempWin: TDotTempWindow;
    FIntAttribs: array of TDotPFAttribi;
    FFloatAttribs: array of TDotPFAttribf;
    function GetIntAttrib(i: Integer): TDotPFAttribi; virtual;
    function GetFloatAttrib(i: Integer): TDotPFAttribf; virtual;
    procedure SetDefaultPF; virtual;
  public
    constructor Create(DC: HDC; hasFuncPtrs: Boolean); virtual;
    destructor Destroy; override;
    procedure SetAttrib(name, value: GLint); overload; virtual;
    procedure SetAttrib(name, value: GLfloat); overload; virtual;
    procedure QuickPF(colorbits, alphabits, depthbits, stencilbits: Integer); virtual;
    function InitGL: Boolean; virtual;
    procedure PageFlip; virtual;
    procedure MakeCurrent; virtual;
    property DC: HDC read FDC write FDC;
    property RC: HGLRC read FRC;
    property IntAttribs[i: Integer]: TDotPFAttribi read GetIntAttrib;
    property FloatAttribs[i: Integer]: TDotPFAttribf read GetFloatAttrib;
  end;

type
  TDotForm = class(TForm)
  protected
    FContext: TDotContext;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Context: TDotContext read FContext;
  end;

type
  TDotDisplayModeEnumCB = function(w, h, bpp, refresh: Cardinal): Boolean of object;

procedure dotEnumerateDisplayModes(cb: TDotDisplayModeEnumCB);
function dotSetDisplayMode(w, h, bpp, refresh: Cardinal): Boolean;

implementation

{*** TDotContext **************************************************************}

constructor TDotContext.Create(DC: HDC; hasFuncPtrs: Boolean);
begin

  inherited Create;

  FDC := DC;
  // Create a temporary window -- needed in order to load the WGL entry points.
  if not hasFuncPtrs then FTempWin := TDotTempWindow.Create(nil)
  else FTempWin := nil;

  // Set some default PF attributes.
  SetDefaultPF;

end;

destructor TDotContext.Destroy;
begin

  wglDeleteContext(FRC);

  inherited Destroy;

end;

procedure TDotContext.SetAttrib(name, value: GLint);
var
  i: Integer;
begin

  // Override an existing attribute...
  for i := 0 to High(FIntAttribs) do
  begin
    if FIntAttribs[i].Name = name then
    begin
      FIntAttribs[i].Value := value;
      Exit;
    end;
  end;

  // ... Or add a new one.
  i := Length(FIntAttribs);
  SetLength(FIntAttribs, i+1);
  FIntAttribs[i-1].Name := name;
  FIntAttribs[i-1].Value := value;
  FIntAttribs[i].Name := 0;
  FIntAttribs[i].Value := 0;

end;

procedure TDotContext.SetAttrib(name, value: GLfloat);
var
  i: Integer;
begin

  // Override an existing attribute...
  for i := 0 to High(FFloatAttribs) do
  begin
    if FFloatAttribs[i].Name = name then
    begin
      FFloatAttribs[i].Value := value;
      Exit;
    end;
  end;

  // ... Or add a new one.
  i := Length(FFloatAttribs);
  SetLength(FFloatAttribs, i+1);
  FFloatAttribs[i-1].Name := name;
  FFloatAttribs[i-1].Value := value;
  FFloatAttribs[i].Name := 0;
  FFloatAttribs[i].Value := 0;

end;

procedure TDotContext.SetDefaultPF;
begin

  SetLength(FIntAttribs, 1);
  FIntAttribs[0].Name := 0;
  FIntAttribs[0].Value := 0;

  SetLength(FFloatAttribs, 1);
  FFloatAttribs[0].Name := 0;
  FFloatAttribs[0].Value := 0;

  // Set the default PF attributes:
  SetAttrib(WGL_ACCELERATION_ARB, WGL_FULL_ACCELERATION_ARB);
  SetAttrib(WGL_DRAW_TO_WINDOW_ARB, GL_TRUE);
  SetAttrib(WGL_SUPPORT_OPENGL_ARB, GL_TRUE);
  SetAttrib(WGL_DOUBLE_BUFFER_ARB, GL_TRUE);
  SetAttrib(WGL_COLOR_BITS_ARB, 24);
  SetAttrib(WGL_DEPTH_BITS_ARB, 24);
  SetAttrib(WGL_STENCIL_BITS_ARB, 8);

end;

procedure TDotContext.QuickPF(colorbits, alphabits, depthbits, stencilbits: Integer);
begin

  // For convencience: quick 'n easy attribute settings.
  SetAttrib(WGL_ACCELERATION_ARB, WGL_FULL_ACCELERATION_ARB);
  SetAttrib(WGL_DRAW_TO_WINDOW_ARB, GL_TRUE);
  SetAttrib(WGL_SUPPORT_OPENGL_ARB, GL_TRUE);
  SetAttrib(WGL_DOUBLE_BUFFER_ARB, GL_TRUE);
  SetAttrib(WGL_COLOR_BITS_ARB, colorbits);
  SetAttrib(WGL_ALPHA_BITS_ARB, alphabits);
  SetAttrib(WGL_DEPTH_BITS_ARB, depthbits);
  SetAttrib(WGL_STENCIL_BITS_ARB, stencilbits);

end;

function TDotContext.InitGL: Boolean;
const
  MAX_PF = 1024;
var
  formats: array [0..MAX_PF-1] of Integer;
  numPF: Cardinal;
  i: Integer;
begin

  // Find matching pixel formats.
  wglChoosePixelFormatARB(FDC, @FIntAttribs[0], @FFloatAttribs[0], MAX_PF, @formats, @numPF);

  // Try them out one by one until we find one that works.
  if numPF > 0 then
  begin
    for i := 0 to numPF - 1 do
    begin
      if SetPixelFormat(FDC, formats[i], nil) then
      begin
        // Clean up the temporary window.
        if FTempWin <> nil then
        begin
          FTempWin.Close;
          FTempWin.Free;
          FTempWin := nil;
        end;
        
        // Create a context and make it current.
        FRC := wglCreateContext(FDC);
        wglMakeCurrent(FDC, FRC);
        // Hurrah, it worked!
        Result := TRUE;
        Exit;
      end;
    end;
  end;

  Result := FALSE;

end;

procedure TDotContext.PageFlip;
begin

  SwapBuffers(FDC);

end;

procedure TDotContext.MakeCurrent;
begin

  wglMakeCurrent(FDC, FRC);

end;

function TDotContext.GetIntAttrib(i: Integer): TDotPFAttribi;
begin

  Result := FIntAttribs[i];

end;

function TDotContext.GetFloatAttrib(i: Integer): TDotPFAttribf;
begin

  Result := FFloatAttribs[i];

end;

{*** TDotForm *****************************************************************}

constructor TDotForm.Create(AOwner: TComponent);
begin

  inherited Create(AOwner);

  FContext := TDotContext.Create(GetDC(Handle), FALSE);

end;

destructor TDotForm.Destroy;
begin

  FContext.Free;

  inherited Destroy;

end;

{******************************************************************************}

function ChangeDisplaySettingsA(lpDevMode: PDevMode; dwflags: DWORD): Integer;
  stdcall; external 'user32.dll';

function dotSetDisplayMode(w, h, bpp, refresh: Cardinal): Boolean;
var
  devMode: TDeviceMode;
  modeExists: LongBool;
  modeSwitch, closeMode, i: Integer;
begin

  Result := FALSE;

  // Change the display resolution to w x h x bpp @ refresh
  // Use dotChangeRes(0, 0, 0, 0) to restore the normal resolution.
  closeMode := 0;
  i := 0;
  repeat
    modeExists := EnumDisplaySettings(nil, i, devMode);
    // if not modeExists then: This mode may not be supported. We'll try anyway, though.
    with devMode do
    begin
      if (dmPelsWidth = w) and (dmPelsHeight = h) and
         (dmBitsPerPel = bpp) and (dmDisplayFrequency = refresh) then
      begin
        modeSwitch := ChangeDisplaySettingsA(@devMode, CDS_FULLSCREEN);
        if modeSwitch = DISP_CHANGE_SUCCESSFUL then
        begin
          Result := TRUE;
          Exit;
        end;
      end;
    end;
    if closeMode <> 0 then closeMode := i;
    INC(i);
  until not modeExists;

  EnumDisplaySettings(nil, closeMode, devMode);
  with devMode do
  begin
    dmBitsPerPel := bpp;
    dmPelsWidth := w;
    dmPelsHeight := h;
    dmDisplayFrequency := refresh;
    dmFields := DM_BITSPERPEL or DM_PELSWIDTH or DM_PELSHEIGHT or DM_DISPLAYFREQUENCY;
  end;
  modeSwitch := ChangeDisplaySettingsA(@devMode, CDS_FULLSCREEN);
  if modeSwitch = DISP_CHANGE_SUCCESSFUL then
  begin
    Result := TRUE;
    Exit;
  end;

  devMode.dmFields := DM_BITSPERPEL;
  modeSwitch := ChangeDisplaySettingsA(@devMode, CDS_FULLSCREEN);
  if modeSwitch = DISP_CHANGE_SUCCESSFUL then
  begin
    devMode.dmFields := DM_PELSWIDTH or DM_PELSHEIGHT;
    modeSwitch := ChangeDisplaySettingsA(@devMode, CDS_FULLSCREEN);
    if modeSwitch = DISP_CHANGE_SUCCESSFUL then
    begin
      ChangeDisplaySettingsA(nil, 0);
      Result := TRUE;
      Exit;
    end;
  end;

end;

procedure dotEnumerateDisplayModes(cb: TDotDisplayModeEnumCB);
var
  i: Integer;
  modeExists: LongBool;
  devMode: TDevMode;
begin

  i := 0;
  modeExists := EnumDisplaySettings(nil, i, devMode);
  while modeExists do
  begin
    with devMode do
    begin
      if not cb(dmPelsWidth, dmPelsHeight, dmBitsPerPel, dmDisplayFrequency) then
        Exit;
    end;
    INC(i);
    modeExists := EnumDisplaySettings(nil, i, devMode);
  end;

end;

end.
