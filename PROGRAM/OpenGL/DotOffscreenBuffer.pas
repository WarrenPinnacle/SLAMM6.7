unit DotOffscreenBuffer;

interface

uses
  Windows, SysUtils, DotWindow, DotUtils, GL, GLext;

type
  TDotPbuffer = class(TDotContext)
  protected
    FPbuffer: THandle;
    FWidth, FHeight: Integer;
    FPBAttribs: array of TDotPFAttribi;
    function GetPBAttrib(i: Integer): TDotPFAttribi; virtual;
    procedure SetDefaultPF; override;
  public
    constructor Create(DC: HDC; w, h: Integer); reintroduce; virtual;
    destructor Destroy; override;
    procedure SetPBAttrib(name, value: GLint); virtual;
    procedure QuickPF(colorbits, alphabits, depthbits, stencilbits: Integer); override;
    function InitGL: Boolean; override;
    property PBAttribs[i: Integer]: TDotPFAttribi read GetPBAttrib;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
  end;

implementation

constructor TDotPbuffer.Create(DC: HDC; w, h: Integer);
begin

  SetLength(FPBAttribs, 1);
  FPBAttribs[0].Name := 0;
  FPBAttribs[0].Value := 0;

  // Warning: you need an active context before you can do this.
  inherited Create(DC, TRUE);

  if not glext_LoadExtension('WGL_ARB_pixel_format') then
    raise EDotException.Create('Pbuffers require WGL_ARB_pixel_format!');
  if not glext_LoadExtension('WGL_ARB_pbuffer') then
    raise EDotException.Create('Pbuffers require WGL_ARB_pbuffer!');

  FWidth := w;
  FHeight := h;

end;

destructor TDotPbuffer.Destroy;
begin

  wglReleasePbufferDCARB(FPBuffer, FDC);
  wglDestroyPbufferARB(FPBuffer);

  inherited Destroy;

end;

function TDotPbuffer.GetPBAttrib(i: Integer): TDotPFAttribi;
begin

  Result := FPBAttribs[i];

end;

procedure TDotPbuffer.SetPBAttrib(name, value: GLint);
var
  i: Integer;
begin

  // Override an existing attribute...
  for i := 0 to High(FPBAttribs) do
  begin
    if FPBAttribs[i].Name = name then
    begin
      FPBAttribs[i].Value := value;
      Exit;
    end;
  end;

  // ... Or add a new one.
  i := Length(FPBAttribs);
  SetLength(FPBAttribs, i+1);
  FPBAttribs[i-1].Name := name;
  FPBAttribs[i-1].Value := value;
  FPBAttribs[i].Name := 0;
  FPBAttribs[i].Value := 0;

end;

procedure TDotPbuffer.SetDefaultPF;
begin

  SetLength(FIntAttribs, 1);
  FIntAttribs[0].Name := 0;
  FIntAttribs[0].Value := 0;

  SetLength(FFloatAttribs, 1);
  FFloatAttribs[0].Name := 0;
  FFloatAttribs[0].Value := 0;

  // Set the default PF attributes:
  SetAttrib(WGL_ACCELERATION_ARB, WGL_FULL_ACCELERATION_ARB);
  SetAttrib(WGL_DRAW_TO_PBUFFER_ARB, GL_TRUE);
  SetAttrib(WGL_SUPPORT_OPENGL_ARB, GL_TRUE);
  SetAttrib(WGL_DOUBLE_BUFFER_ARB, GL_FALSE);
  SetAttrib(WGL_COLOR_BITS_ARB, 24);
  SetAttrib(WGL_DEPTH_BITS_ARB, 24);
  SetAttrib(WGL_STENCIL_BITS_ARB, 8);

end;

procedure TDotPbuffer.QuickPF(colorbits, alphabits, depthbits, stencilbits: Integer);
begin

  // For convencience: quick 'n easy attribute settings.
  SetAttrib(WGL_ACCELERATION_ARB, WGL_FULL_ACCELERATION_ARB);
  SetAttrib(WGL_DRAW_TO_PBUFFER_ARB, GL_TRUE);
  SetAttrib(WGL_SUPPORT_OPENGL_ARB, GL_TRUE);
  SetAttrib(WGL_DOUBLE_BUFFER_ARB, GL_FALSE);
  SetAttrib(WGL_COLOR_BITS_ARB, colorbits);
  SetAttrib(WGL_ALPHA_BITS_ARB, alphabits);
  SetAttrib(WGL_DEPTH_BITS_ARB, depthbits);
  SetAttrib(WGL_STENCIL_BITS_ARB, stencilbits);

end;

function TDotPbuffer.InitGL: Boolean;
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
      FPbuffer := wglCreatePbufferARB(FDC, formats[i], FWidth, FHeight, @FPBAttribs[0]);
      if FPbuffer <> 0 then
      begin
        // Create a context and make it current.
        FDC := wglGetPbufferDCARB(FPbuffer);
        FRC := wglCreateContext(FDC);
        wglShareLists(wglGetCurrentContext, FRC);
        wglMakeCurrent(FDC, FRC);
        // Re-query pbuffer dimensions.
        wglQueryPbufferARB(FPbuffer, WGL_PBUFFER_WIDTH_ARB, @FWidth);
        wglQueryPbufferARB(FPbuffer, WGL_PBUFFER_HEIGHT_ARB, @FHeight);
        // Hurrah, it worked!
        Result := TRUE;
        Exit;
      end;
    end;
  end;

  Result := FALSE;

end;

end.
