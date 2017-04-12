unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AppEvnts, DotWindow, DotUtils, DotMath, GL, GLu, GLext, StdCtrls;

type
  TDelphi3DForm = class(TDotForm)
    AppEvents: TApplicationEvents;
    lblStatus: TLabel;
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure AppEventsIdle(Sender: TObject; var Done: Boolean);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FCamera: record
      Pos: TDotVector3;
      Pitch, Yaw: Single;
    end;
    FMousePos: TPoint;
    FWire: Boolean;
  public
    procedure Status(const msg: String);
    constructor Create(AOwner: TComponent); override;
    procedure ConfigureDisplay;
    procedure LoadExtensions;
    procedure CreateScene;
    procedure CreateTextures;
    procedure CreateShaders;
  end;

var
  Delphi3DForm: TDelphi3DForm;

implementation

{$R *.dfm}

uses
  DispMode;

procedure TDelphi3DForm.Status(const msg: String);
begin

  lblStatus.Caption := msg;
  Update;

end;

procedure TDelphi3DForm.LoadExtensions;
  procedure Load(const ext: String);
  begin
    if not glext_LoadExtension(ext) then
      raise Exception.Create('This demo requires ' + ext + '!');
  end;
begin

  Status('Checking required extensions...');

  {*****************************************************************************
    Load all required OpenGL extensions here, and throw an exception if any of
    them are not found.
   ****************************************************************************}

  Load('GL_ARB_multitexture');

end;

procedure TDelphi3DForm.CreateScene;
begin

  Status('Preparing scene...');

  {*****************************************************************************
    Load your 3D scene here, e.g. using OBJ.pas or ASE.pas.
   ****************************************************************************}

end;

procedure TDelphi3DForm.CreateTextures;
begin

  Status('Preparing textures...');

  {*****************************************************************************
    Create the textures used in your scene here. Create texture objects, set
    their parameters, load an image...
   ****************************************************************************}

end;

procedure TDelphi3DForm.CreateShaders;
begin

  Status('Preparing shaders...');

  {*****************************************************************************
    Load and compile any required vertex or pixel shaders here.
   ****************************************************************************}

end;

procedure TDelphi3DForm.ConfigureDisplay;
begin

  // Maximize the form if we're running fullscreen.
  if DotDispModeDlg.FullScreen then
  begin
    Position := poDefault;
    BorderStyle := bsNone;
    WindowState := wsMaximized;
    { I have no idea why, but changing Position or BorderStyle apparently
      invalidates your DC, so we have to get a new DC and give it to our
      TDotContext. }
    Context.DC := GetDC(Handle);
  end;

  with DotDispModeDlg do
  begin
    // Set the pixel format and initialize a rendering context.
    Context.QuickPF(ColorBits, AlphaBits, DepthBits, StencilBits);
    if FSAA then
    begin
      Context.SetAttrib(WGL_SAMPLE_BUFFERS_ARB, 1);
      Context.SetAttrib(WGL_SAMPLES_ARB, FSAASamples);
    end;

    if not Context.InitGL then
    begin
      raise Exception.Create('Could not set the requested pixel format.'
                             + #13#10 + 'Please try to use different settings.');
    end;
  end;

end;

constructor TDelphi3DForm.Create(AOwner: TComponent);
begin

  inherited Create(AOwner);
  ConfigureDisplay;
  
  {***************************************************************************
    Other setup work here: configure GL, load extensions, textures, ...
    Throw an exception with a descriptive message if anything is wrong, and
    the demo will crash gracefully.
   **************************************************************************}

  // Load all required data:
  LoadExtensions;
  CreateScene;
  CreateTextures;
  CreateShaders;

  // Miscellaneous setup work:
  glEnable(GL_DEPTH_TEST);
  FWire := FALSE;

  // Initialize the camera:
  FCamera.Pos := DOT_ORIGIN3;
  FCamera.Pitch := 0;
  FCamera.Yaw := 0;
  GetCursorPos(FMousePos);
  FMousePos := ScreenToClient(FMousePos);

  lblStatus.Visible := FALSE;

  // If everything went well, hook up the event handlers:
  OnResize := FormResize;
  OnPaint := FormPaint;
  OnMouseMove := FormMouseMove;
  OnKeyPress := FormKeyPress;
  AppEvents.OnIdle := AppEventsIdle;
  // Force FormResize() to be called, so perspective gets set up:
  Resize;
  dotStartTiming;

end;

procedure TDelphi3DForm.FormResize(Sender: TObject);
begin

  glViewport(0, 0, ClientWidth, ClientHeight);

  // Update the projection matrix:
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(60, ClientWidth/ClientHeight, 1, 1000);
  glMatrixMode(GL_MODELVIEW);

end;

var
  fps: Single = 0;    // Sum of framerate samples.
  fpsc: Integer = 0;  // Number of framerate samples taken.

const
  FPS_SMOOVE = 25;    // Number of samples to use for smoothing the fps counter.

procedure TDelphi3DForm.AppEventsIdle(Sender: TObject;
  var Done: Boolean);
var
  dt: Single;
  speed: Single;
  v: TDotVector3;
const
  {**** This is the camera movement speed in units/second. Change it to match
        the units used in your scene. ****}
  MOVE_SPEED = 0.0025;
begin

  Done := FALSE;

  dt := dotTimeElapsed;
  dotStartTiming;

  {*****************************************************************************
    Perform your animation updates here. Base them on dt, which is the time
    elapsed between this frame and the last.
   ****************************************************************************}

  // Update the camera:
  if GetAsyncKeyState(VK_SHIFT) <> 0 then speed := MOVE_SPEED*2
  else speed := MOVE_SPEED;

  v := DOT_ORIGIN3;

  if GetAsyncKeyState(VK_UP) <> 0 then v.z := -dt*speed
  else if GetAsyncKeyState(VK_DOWN) <> 0 then v.z := dt*speed;
  if GetAsyncKeyState(VK_LEFT) <> 0 then v.x := -dt*speed
  else if GetAsyncKeyState(VK_RIGHT) <> 0 then v.x := dt*speed;

  dotVecRotateX3(v, FCamera.Pitch*PI/180);
  dotVecRotateY3(v, FCamera.Yaw*PI/180);
  FCamera.Pos := dotVecAdd3(FCamera.Pos, v);

  // Take framerate sample:
  fps := fps + 1000/dt;
  INC(fpsc);

  // If number of samples is high enough, average them and display the result:
  if fpsc = FPS_SMOOVE then
  begin
    fpsc := 0;
    fps := fps / FPS_SMOOVE;
    Caption := Format('Delphi3D OpenGL framework -- %.0f fps', [fps]);
    fps := 0;
  end;

  Paint;

end;

procedure TDelphi3DForm.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin

  // Update the camera:
  if ssLeft in Shift then
  begin
    FCamera.Pitch := FCamera.Pitch - (Y - FMousePos.Y)/5;
    FCamera.Yaw := FCamera.Yaw - (X - FMousePos.X)/5;

    if FCamera.Pitch > 90 then FCamera.Pitch := 90
    else if FCamera.Pitch < -90 then FCamera.Pitch := -90;

    if FCamera.Yaw > 360 then FCamera.Yaw := FCamera.Yaw - 360
    else if FCamera.Yaw < 0 then FCamera.Yaw := FCamera.Yaw + 360;
  end;
  FMousePos := Point(X, Y);

end;

procedure TDelphi3DForm.FormKeyPress(Sender: TObject; var Key: Char);
begin

  {*****************************************************************************
    Add keyboard handlers here.
   ****************************************************************************}

  // W toggles wireframe mode.
  if Key in ['w', 'W'] then
  begin
    FWire := not FWire;
    if FWire then glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
    else glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
  end
  // ESC quits.
  else if Key = #27 then Close;

end;

procedure TDelphi3DForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin

  dotSetDisplayMode(0, 0, 0, 0);

end;

procedure TDelphi3DForm.FormPaint(Sender: TObject);
var x,y: integer; r,g,b: real;

begin
  r:=1; g:=0; b:=0;
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;

  // Set the camera transform:
  glRotatef(-FCamera.Pitch, 1, 0, 0);
  glRotatef(-FCamera.Yaw, 0, 1, 0);
  glTranslatef(-FCamera.Pos.x, -FCamera.Pos.y, -FCamera.Pos.z);

  {*****************************************************************************
    Render stuff here.
   ****************************************************************************}

    for x := 0 to 100 do
      for y := 0 to 200 do

        begin
        glBegin(GL_POLYGON);
        glColor3f(r, g, b);     glVertex3f(0+x, 0+y, -20);
        {glColor3f(0, 1, 0);}     glVertex3f(0+x, 1+y, -20);
        {glColor3f(0, 0, 1);}     glVertex3f(1+x, 1+y, -20);
        glColor3f(r, g, 1);     glVertex3f(1+x, 0+y, -20);
        glEnd;
         end;

         
    


  Context.PageFlip;

end;

end.
