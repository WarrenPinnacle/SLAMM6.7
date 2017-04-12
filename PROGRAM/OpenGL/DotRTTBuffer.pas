unit DotRTTBuffer;

interface

uses
  Windows, SysUtils, DotWindow, DotOffscreenBuffer, DotUtils, GL, GLext;

type
  TDotRTTBuffer = class(TDotPbuffer)
  protected
    procedure SetDefaultPF; override;
  public
    constructor Create(DC: HDC; w, h: Integer); override;
    destructor Destroy; override;
    procedure QuickPF(colorbits, alphabits, depthbits, stencilbits: Integer); override;
    procedure BindImage; virtual;
    procedure ReleaseImage; virtual;
    procedure SetCubeMapTargetFace(f: GLenum); virtual;
  end;

implementation

constructor TDotRTTBuffer.Create(DC: HDC; w, h: Integer);
begin

  inherited Create(DC, w, h);

  if not glext_LoadExtension('WGL_ARB_render_texture') then
    raise EDotException.Create('WGL_ARB_render_texture not found!');

end;

destructor TDotRTTBuffer.Destroy;
begin

  inherited Destroy;

end;

procedure TDotRTTBuffer.SetDefaultPF;
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
  SetAttrib(WGL_BIND_TO_TEXTURE_RGBA_ARB, GL_TRUE);
  SetAttrib(WGL_SUPPORT_OPENGL_ARB, GL_TRUE);
  SetAttrib(WGL_DOUBLE_BUFFER_ARB, GL_FALSE);
  SetAttrib(WGL_COLOR_BITS_ARB, 24);
  SetAttrib(WGL_DEPTH_BITS_ARB, 24);
  SetAttrib(WGL_STENCIL_BITS_ARB, 8);

  SetLength(FPBAttribs, 1);
  FPBAttribs[0].Name := 0;
  FPBAttribs[0].Value := 0;

  SetPBAttrib(WGL_TEXTURE_FORMAT_ARB, WGL_TEXTURE_RGBA_ARB);
  SetPBAttrib(WGL_TEXTURE_TARGET_ARB, WGL_TEXTURE_2D_ARB);
  SetPBAttrib(WGL_MIPMAP_TEXTURE_ARB, GL_TRUE);

end;

procedure TDotRTTBuffer.QuickPF(colorbits, alphabits, depthbits, stencilbits: Integer);
begin

  // For convencience: quick 'n easy attribute settings.
  SetAttrib(WGL_ACCELERATION_ARB, WGL_FULL_ACCELERATION_ARB);
  SetAttrib(WGL_DRAW_TO_PBUFFER_ARB, GL_TRUE);
  SetAttrib(WGL_BIND_TO_TEXTURE_RGBA_ARB, GL_TRUE);
  SetAttrib(WGL_SUPPORT_OPENGL_ARB, GL_TRUE);
  SetAttrib(WGL_DOUBLE_BUFFER_ARB, GL_FALSE);
  SetAttrib(WGL_COLOR_BITS_ARB, colorbits);
  SetAttrib(WGL_ALPHA_BITS_ARB, alphabits);
  SetAttrib(WGL_DEPTH_BITS_ARB, depthbits);
  SetAttrib(WGL_STENCIL_BITS_ARB, stencilbits);

  SetPBAttrib(WGL_TEXTURE_FORMAT_ARB, WGL_TEXTURE_RGBA_ARB);
  SetPBAttrib(WGL_TEXTURE_TARGET_ARB, WGL_TEXTURE_2D_ARB);
  SetPBAttrib(WGL_MIPMAP_TEXTURE_ARB, GL_TRUE);

end;

procedure TDotRTTBuffer.BindImage;
begin

  wglBindTexImageARB(FPBuffer, WGL_FRONT_LEFT_ARB);

end;

procedure TDotRTTBuffer.ReleaseImage;
begin

  wglReleaseTexImageARB(FPBuffer, WGL_FRONT_LEFT_ARB);

end;

procedure TDotRTTBuffer.SetCubeMapTargetFace(f: GLenum);
const
  PBATTRIB: array [0..2] of Integer =
    ( WGL_CUBE_MAP_FACE_ARB, 0, 0 );
begin

  // Change the cube map face, and update the corresponding PBuffer attribute.
  PBATTRIB[1] := WGL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB +
                 (f - GL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB);
  wglSetPbufferAttribARB(FPBuffer, @PBATTRIB);

end;

end.
