unit DotTmpWin;

interface

uses
  Windows, SysUtils, Forms, GL, GLext;

type
  TDotTempWindow = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FDC: HDC;
    FRC: HGLRC;
  public
    { Public declarations }
  end;

var
  DotTempWindow: TDotTempWindow;

implementation

{$R *.dfm}

uses
  DotUtils, Dialogs, System.UITypes;

procedure dotInitDC(DC: HDC);
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
  err: Integer;
begin

  // Initialise the form's DC for OpenGL, and setup a palette.
  FillChar(pfd, SizeOf(pfd), 0);
  with pfd do
  begin
    nSize        := SizeOf(TPixelFormatDescriptor);
    nVersion     := 1;                             
    dwFlags      := PFD_DRAW_TO_WINDOW or
                    PFD_SUPPORT_OPENGL;            
    dwFlags      := dwFlags or PFD_DOUBLEBUFFER;   
    iPixelType   := PFD_TYPE_RGBA;                 
    cColorBits   := 24;                            
    cAlphaBits   := 0;
    cDepthBits   := 0;                             
    cStencilBits := 0;                             
    iLayerType   := PFD_MAIN_PLANE;                
  end;

  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  if nPixelFormat = 0 then
  begin
    err := GetLastError;
    raise EDotException.CreateFmt('Couldn''t choose pixel format for temp window.'
                                  + #10 + '%d: %s', [err, dotWin32ErrorString(err)]);
  end;

  if not SetPixelFormat(DC, nPixelFormat, @pfd) then
  begin
    err := GetLastError;
    raise EDotException.CreateFmt('Couldn''t set pixel format for temp window.'
                                  + #10 + '%d: %s', [err, dotWin32ErrorString(err)]);
  end;

end;

procedure TDotTempWindow.FormCreate(Sender: TObject);
var
  err: Integer;
begin

  try
    FDC := GetDC(Handle);
    dotInitDC(FDC);

    FRC := wglCreateContext(FDC);
    if FRC = 0 then
    begin
      err := GetLastError;
      raise EDotException.CreateFmt('Couldn''t create temporary context.'
                                    + #10 + '%d: %s', [err, dotWin32ErrorString(err)]);
    end;
    wglMakeCurrent(FDC, FRC);

    wglGetExtensionsStringARB := wglGetProcAddress('wglGetExtensionsStringARB');
    if not Assigned(wglGetExtensionsStringARB) then
      raise EDotException.Create('WGL_ARB_extensions_string not found!');

    if not glext_LoadExtension('WGL_ARB_pixel_format') then
      raise EDotException.Create('WGL_ARB_pixel_format not found!');
  except on E: Exception do
    begin
      MessageDlg(E.Message, mtError, [mbOK], 0);
      // Halt(1);
    end;
  end;

end;

procedure TDotTempWindow.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin

  wglDeleteContext(FRC);
  ReleaseDC(Handle, FDC);

end;

end.
