//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit GLDraw;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AppEvnts, DotWindow, DotUtils, DotMath, StdCtrls, GL, GLu, GLext, DotOffscreenBuffer,
  ExtCtrls, ComCtrls, Buttons, OpenGL;

type
  TDelphi3DForm = class(TDotForm)
    AppEvents: TApplicationEvents;
    lblStatus: TLabel;
    ControlPanel: TPanel;
    SpeedButton: TButton;
    SpeedFactor: TEdit;
    WireFrameButton: TButton;
    ResizeZButton: TButton;
    ZFactor: TEdit;
    ExitPanel: TButton;
    ShowControls: TButton;
    TrackBar1: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    HelpButton: TBitBtn;
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure AppEventsIdle(Sender: TObject; var Done: Boolean);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButtonClick(Sender: TObject);
    procedure ExitPanelClick(Sender: TObject);
    procedure ShowControlsClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ZFactorKeyPress(Sender: TObject; var Key: Char);
    procedure SpeedFactorChange(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
  private
    SpeedMult: Double;
    FMousePos: TPoint;
    FWire: Boolean;
    ShowTideRange: Boolean;
  public

    const yellowAmbientDiffuse : Array [1..4] of Real = (1.0, 1.0, 0, 1.0);
          lightColor : Array [1..4] of Real = (0.7, 0.7, 0.7, 1.0);
          lightPos : Array [1..4] of Real = (-2 * 6, 60, 4 * 6, 1.0);
          LightAmbient: array [0..3] of GLfloat = ( 0.5, 0.5, 0.5, 1.0 );
          LightDiffuse: array [0..3] of GLFloat = ( 1, 1, 1, 1.0 );
          LightPosition: array [0..3] of GLfloat = ( -133, -166, -189, 1.0 );
          BUFSIZE = 512;

    var
    //LightDiffuse: array [0..3] of GLFloat;// = ( 1.0, 1.0, 1.0, 1.0 );
    //LightPosition: array [0..3] of GLFloat;// = ( 0.0, 0.0, 2.0, 1.0 );
    HDc : HDC;
    selectBuf : array [1..BUFSIZE] of GLuint;
    listexist : boolean;
    SQUARES_DL, SQUARES_DL2 : integer;
    MapZs: Array of Double;
    MTLz, MHHWz, MHWSz, MLLWz, SaltLvlz: Double;
    NX, NY, Magnify: Integer;
    tide: double;
    MapColors: Array of TColor;
    FCamera: record
      Pos: TDotVector3;
      Pitch, Yaw: Single;
     end;


    procedure Status(const msg: String);
    constructor Create(AOwner: TComponent); override;
    procedure ConfigureDisplay;
    procedure LoadExtensions;
    procedure CreateScene;
    procedure CreateTextures;
    procedure CreateShaders;
    procedure setupform;
    procedure showform;
    procedure BuildLists;
    //procedure startPicking(cursorX, cursorY: integer);
  end;

var
  Delphi3DForm: TDelphi3DForm;
  paintTime, buildTime: Double;

  //FirstTime: Boolean;

implementation

{$R *.dfm}

uses
  DispMode, System.Types;


procedure TDelphi3DForm.BuildLists();
   Function Getnz(X,Y: Integer): Integer;
   Begin
     Getnz := y + (x * NY);
   End;

   Procedure SetColor(TC:TCOlor);
   Var r,g,b: real;
   Begin
     r := GetRValue(TC)/255;
     g := GetGValue(TC)/255;
     b := GetBValue(TC)/255;
     glColor3f(r, g, b);                       // change this to fit with shading/lighting terms
   End;

var  x,y: Integer;
      p1,p2,p3,p4: Double;
      Drawit: Boolean;
      count: double;
begin
  count:= now;
  glDeleteLists(SQUARES_DL2,1);
  SQUARES_DL2:= glGenLists(2);


  glNewList(SQUARES_DL2, GL_COMPILE);
    for x := 0 to NX-2 do
      for y := 0 to NY-2 do
        begin
          p1 := MapZs[Getnz(0+x,0+y)];
          p2 := MapZs[Getnz(0+x,1+y)];
          p3 := MapZs[Getnz(1+x,1+y)];
          p4 := MapZs[Getnz(1+x,0+y)];

          Drawit := (p1<>999) and (p2<>999) and (p3<>999) and (p4<>999);
          if Drawit then
            Begin
              glBegin(GL_POLYGON);
              SetColor(MapColors[Getnz(0+x,0+y)]);    glVertex3f(0+x, Magnify * p1, 0+y);     // make 3 a variable editable in the 3d graph window
              SetColor(MapColors[Getnz(0+x,1+y)]);    glVertex3f(0+x, Magnify * P2, 1+y);
              SetColor(MapColors[Getnz(1+x,1+y)]);    glVertex3f(1+x, Magnify * p3, 1+y);
              SetColor(MapColors[Getnz(1+x,0+y)]);    glVertex3f(1+x, Magnify * p4, 0+y);
              glEnd;
            End;
        end;
  glEndList;

  glDeleteLists(SQUARES_DL,1);
  SQUARES_DL:= glGenLists(1);

  if ShowTideRange then
  begin

  glNewList(SQUARES_DL, GL_COMPILE);
   for x := 0 to NX-2 do
     for y := 0 to NY-2 do
      begin
      glBegin(GL_POLYGON);
        if(MapZs[Getnz(0+x,0+y)] < tide) then
        begin
            glColor3f(0, 0, 1);   glVertex3f(0+x, Magnify * (tide), 0+y);
            glColor3f(0, 0, 1);   glVertex3f(0+x, Magnify * (tide), 1+y);
            glColor3f(0, 0, 1);   glVertex3f(1+x, Magnify * (tide), 1+y);
            glColor3f(0, 0, 1);   glVertex3f(1+x, Magnify * (tide), 0+y);
        end;
       glEnd;
    end;
    glEndList();
   end;
  buildTime:= now-count;
end;

(*procedure TDelphi3DForm.startPicking(cursorX, cursorY: integer);
var
  viewport: array[1..4] of integer;
begin
  glSelectBuffer(BUFSIZE,selectBuf);
	glRenderMode(GL_SELECT);

	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();

	glGetIntegerv(GL_VIEWPORT,viewport);
	gluPickMatrix(cursorX,viewport[3]-cursorY,
			5,5,viewport);
	gluPerspective(45,ratio,0.1,1000);
	glMatrixMode(GL_MODELVIEW);
	glInitNames();
end;        *)

procedure TDelphi3DForm.Status(const msg: String);
begin

  lblStatus.Caption := msg;
  Update;

end;

procedure TDelphi3DForm.LoadExtensions;
  procedure Load(const ext: AnsiString);
  begin
    if not glext_LoadExtension(ext) then
      raise Exception.Create('This demo requires ' + String(ext) + '!');
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
  
  //GLCompileShader;
  //glLightModelf(GL_LIGHT_MODEL_AMBIENT, 1);
  //glShadeModel(GL_SMOOTH);
  //glLightf(GL_LIGHT1,GL_POSITION,0.5);
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
      TDotContext.  }
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
// var pLightDiffuse: GLFloat;
begin

  inherited Create(AOwner);

  ConfigureDisplay;

  {***************************************************************************
    Other setup work here: configure GL, load extensions, textures, ...
    Throw an exception with a descriptive message if anything is wrong, and
    the demo will crash gracefully.
   **************************************************************************}

  //pLightDiffuse:= ^LightDiffuse;

  // Load all required data:
  {LoadExtensions;
  CreateScene;
  CreateTextures;
  CreateShaders; }

  // Miscellaneous setup work:
  glShadeModel(GL_SMOOTH);
  //glClearColor(0.0, 0.0, 0.0, 0.5);					// Black Background
	glClearDepth(1);
  glEnable(GL_DEPTH_TEST);
  glDepthFunc(GL_LEQUAL);
  //glColorMaterial ( GL_FRONT_AND_BACK, GL_EMISSION );
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);


  //glEnable(GL_LIGHTING);
  //glLightfv(GL_LIGHT0, GL_AMBIENT, @LightAmbient);
  glLightfv(GL_LIGHT1, GL_DIFFUSE, @LightDiffuse);
  glLightfv(GL_LIGHT1, GL_POSITION,@LightPosition);
  glEnable(GL_LIGHT1);
//  glEnable ( GL_COLOR_MATERIAL );                                        //ECL
  //glLightfv (GL_LIGHT0, GL_AMBIENT, @yellowambientdiffuse);
  //glLightfv (GL_LIGHT0, GL_DIFFUSE, @yellowambientdiffuse);
  //glLightfv (GL_LIGHT0, GL_POSITION, @lightPos);



  glEnable (GL_BLEND);
  //glBlendFunc (GL_SRC_ALPHA, GL_ONE);
  //glColorMaterial ( GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE );
  FWire := false;
  //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

  ShowTideRange := FALSE;
  ListExist := TRUE;
  //Hdc := NULL;

  GetCursorPos(FMousePos);
  FMousePos := ScreenToClient(FMousePos);

  lblStatus.Visible := FALSE;

  Magnify := 1;

  // If everything went well, hook up the event handlers:
  OnResize := FormResize;
  OnPaint := FormPaint;
  OnMouseMove := FormMouseMove;

  //glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
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

  Paint;
end;

procedure TDelphi3DForm.FormShow(Sender: TObject);
begin
  //SwapBuffers(hDC);
  //glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  SpeedMult := 1.0;

  BuildLists;
  //glEnable(GL_LIGHTING);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;



  // Initialize the camera:
  FCamera.Pos.x := NX div 2 + 1;
  FCamera.Pos.y := 66;
  FCamera.Pos.z := NY + 40;
  FCamera.Pitch := -34;
  FCamera.Yaw := 0;

  // Set the camera transform:
  glRotatef(-FCamera.Pitch, 100, 0, 0);          // x was 100
  glRotatef(-FCamera.Yaw, 0, 100, 0);             // y was 100
  glTranslatef(-FCamera.Pos.x, -FCamera.Pos.y, -FCamera.Pos.z);


end;

procedure TDelphi3DForm.HelpButtonClick(Sender: TObject);
begin
   Application.HelpContext(1006 );  //'3DGraphing.html');
end;

procedure TDelphi3DForm.ShowControlsClick(Sender: TObject);
begin
  ControlPanel.Visible := True;
  Paint;
end;

procedure TDelphi3DForm.SpeedFactorChange(Sender: TObject);
begin
  SpeedButtonClick(nil);
end;

procedure TDelphi3DForm.TrackBar1Change(Sender: TObject);
begin
ShowTideRange := true;
  case trackbar1.position of
    1:  tide:= MHWSz;
    2:  tide:= MHHWz;
    3:  tide:= 0;
    4:  tide:= MLLWz;
    5:  ShowTideRange := false;
  end;
  Buildlists;
  Paint;
end;

procedure TDelphi3DForm.ZFactorKeyPress(Sender: TObject; var Key: Char);
begin
  If not (Ansichar(Key) in ['0'..'9','.',Char(vk_delete),Char(vk_left),Char(vk_right)]) then key := #0;
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
Var Key: Word;
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


    If GetAsyncKeyState(VK_UP) <> 0
      then
        Begin
           Key := VK_Up;
           FormKeyDown(nil, Key, Shift);
        End
      else If GetAsyncKeyState(VK_Down) <> 0 then
        Begin
         Key := VK_Down;
         FormKeyDown(nil, Key, Shift);
        End
      else Paint;     
  end;
  FMousePos := Point(X, Y);

end;

procedure TDelphi3DForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

  {*****************************************************************************
    Add keyboard handlers here.
   ****************************************************************************}
var
//  dt: Single;
  speed: Single;
//  sqkm: real;
  MOVE_SPEED : double;                                                          // ECL SPEED
  V: TDotVector3;

  {**** This is the camera movement speed in units/second. Change it to match
        the units used in your scene. ****}
begin

  Move_Speed := 3 * SpeedMult;

  {dt := 3 ;} dotTimeElapsed;
  dotStartTiming;

  {*****************************************************************************
    Perform your animation updates here. Base them on dt, which is the time
    elapsed between this frame and the last.
   ****************************************************************************}

  // Update the camera:
  if ssShift in Shift then speed := MOVE_SPEED*5
                      else speed := MOVE_SPEED;

  If Key in [VK_UP,VK_Down,VK_Left,VK_Right,ORD('u'),ORD('U'),ORD('d'),ORD('D')] then
    Begin
      v := DOT_ORIGIN3;
      if Key = VK_UP then v.z := -{dt*}speed
      else if Key = VK_Down then v.z := {dt*}speed
      else if Key = VK_LEFT then v.x := -{dt*}speed
      else if Key = VK_RIGHT then v.x := {dt*}speed
      else if (Key = ORD('a')) or (Key=ORD('A')) then v.y := {dt*}speed
      else if (Key = ORD('z')) or (Key=ORD('Z')) then v.y := -{dt*}speed;

      dotVecRotateX3(v, FCamera.Pitch*PI/180);
      dotVecRotateY3(v, FCamera.Yaw*PI/180);
      FCamera.Pos := dotVecAdd3(FCamera.Pos, v);

(*    // Take framerate sample:
      fps := fps + 1000/dt;
      INC(fpsc);

      // If number of samples is high enough, average them and display the result:
      if fpsc = FPS_SMOOVE then
      begin
        fpsc := 0;
        fps := fps / FPS_SMOOVE;

        Caption := Format('Delphi3D OpenGL framework -- %.0f fps', [fps]);
        fps := 0;
      end; *)

      Key := 0;
      Paint;
      exit;
    End;

  // W toggles wireframe mode.
  if ANSICHAR(Key) in [ANSICHAR('w'), ANSICHAR('W')] then
  begin
    FWire := not FWire;
    if FWire then glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
    else glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    Paint;
  end;

end;

procedure TDelphi3DForm.Button1Click(Sender: TObject);            // Magnify z factor
var x,zfact, diff: integer;

begin
  zfact:= StrToInt(ZFactor.Text);
  if magnify = zfact then
    exit;
  if ((paintTime+buildTime)*86400) > 0.034 then
    begin
      Magnify := zfact;
      BuildLists;
      Paint;
      exit;
    end;
  diff := zfact - magnify;
  for x := 0 to abs(diff)-1 do        // change magnify to zfact
  begin
    Magnify := Magnify + trunc(abs(diff)/diff);
    BuildLists;
    Paint;
    SysUtils.Sleep(17);                                          // 60 fps
  end;
end;

procedure TDelphi3DForm.Button2Click(Sender: TObject);
begin
  FWire := not FWire;
  if FWire then glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
    else glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
  Paint;
end;




procedure TDelphi3DForm.SpeedButtonClick(Sender: TObject);
begin
  SpeedMult := StrToFloat(SpeedFactor.Text);
  Paint;
end;

procedure TDelphi3DForm.ExitPanelClick(Sender: TObject);
begin
  ControlPanel.Visible := False;
  Paint;
end;

procedure TDelphi3DForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin

  //dotSetDisplayMode(0, 0, 0, 0);             killed this code to make the screen stop flickering after window close

end;

procedure TDelphi3DForm.setupform;
//var x,y:integer;
Begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;
  glRotatef(-FCamera.Pitch, 1, 0, 0);
  glRotatef(-FCamera.Yaw, 0, 1, 0);
  glTranslatef(-FCamera.Pos.x, -FCamera.Pos.y, -FCamera.Pos.z);


End;

procedure TDelphi3DForm.showform;
Begin
  Context.PageFlip;
End;



procedure TDelphi3DForm.FormPaint(Sender: TObject);
var count: double;
begin
  count:= now;
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;

  // Set the camera transform:
  glRotatef(-FCamera.Pitch, 100, 0, 0);
  glRotatef(-FCamera.Yaw, 0, 100, 0);
  glTranslatef(-FCamera.Pos.x, -FCamera.Pos.y, -FCamera.Pos.z);

//  GlColor3f(0.5,0.5,0.5);

  glCallList(SQUARES_DL2);
  glCallList(SQUARES_DL);

  Context.PageFlip;
  paintTime:= now-count;
end;

end.
