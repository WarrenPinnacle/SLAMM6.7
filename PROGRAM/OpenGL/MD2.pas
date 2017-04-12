unit MD2;

interface

uses
  SysUtils, Classes;

type
  // MD2 file header.
  TMD2Header = packed record
    Magic: Integer;
    Version: Integer;
    SkinWidth: Integer;
    SkinHeight: Integer;
    FrameSize: Integer;
    NumSkins: Integer;
    NumVertices: Integer;
    NumTexCoords: Integer;
    NumTriangles: Integer;
    NumGLCommands: Integer;
    NumFrames: Integer;
    OffsetSkins: Integer;
    OffsetTexCoords: Integer;
    OffsetTriangles: Integer;
    OffsetFrames: Integer;
    OffsetGLCommands: Integer;
    OffsetEnd: Integer;
  end;

const
  // Magic number that identifies MD2 files (ASCII: 'IDP2').
  MD2_MAGIC = $32504449;

type
  // One range-compressed vertex.
  TMD2Vertex = packed record
    Vertex: array [0..2] of Byte;
    LightNormalIndex: Byte;
  end;
  // One animation frame.
  TMD2Frame = record
    Scale: array [0..2] of Single;
    Translate: array [0..2] of Single;
    Name: array [0..15] of Char;
    Vertices: array of TMD2Vertex;
  end;
  // One triangle.
  TMD2Triangle = packed record
    VertexIndices: array [0..2] of SmallInt;
    TextureIndices: array [0..2] of SmallInt;
  end;
  // A skin name.
  TMD2Skin = array [0..63] of Char;
  // One pair of texcoords.
  TMD2TextureCoordinate = packed record
    s, t: SmallInt;
  end;
  // One vertex as sent to the GL.
  TMD2GLCommand = packed record
    s, t: Single;
    VertexIndex: Integer;
  end;
  // MD2s contain either strips or fans.
  TMD2GLCommandMode = ( MD2_GLCOMMAND_STRIP, MD2_GLCOMMAND_FAN );
  // List of GLCommands.
  TMD2GLCommands = record
    Mode: TMD2GLCommandMode;
    Commands: array of TMD2GLCommand;
  end;

const
  // Various MD2 limitations (not enforced by this loader).
  MD2_MAX_TRIANGLES = 4096;
  MD2_MAX_VERTICES  = 2048;
  MD2_MAX_TEXCOORDS = 2048;
  MD2_MAX_FRAMES    = 512;
  MD2_MAX_SKINS     = 32;

const
  MD2_VERTEX_NORMALS: array [0..161, 0..2] of Single =
    (
      ( -0.525731, 0.000000, 0.850651 ),
      ( -0.442863, 0.238856, 0.864188 ),
      ( -0.295242, 0.000000, 0.955423 ),
      ( -0.309017, 0.500000, 0.809017 ),
      ( -0.162460, 0.262866, 0.951056 ),
      ( 0.000000, 0.000000, 1.000000 ),
      ( 0.000000, 0.850651, 0.525731 ),
      ( -0.147621, 0.716567, 0.681718 ),
      ( 0.147621, 0.716567, 0.681718 ), 
      ( 0.000000, 0.525731, 0.850651 ), 
      ( 0.309017, 0.500000, 0.809017 ), 
      ( 0.525731, 0.000000, 0.850651 ), 
      ( 0.295242, 0.000000, 0.955423 ),
      ( 0.442863, 0.238856, 0.864188 ), 
      ( 0.162460, 0.262866, 0.951056 ), 
      ( -0.681718, 0.147621, 0.716567 ), 
      ( -0.809017, 0.309017, 0.500000 ), 
      ( -0.587785, 0.425325, 0.688191 ), 
      ( -0.850651, 0.525731, 0.000000 ), 
      ( -0.864188, 0.442863, 0.238856 ), 
      ( -0.716567, 0.681718, 0.147621 ), 
      ( -0.688191, 0.587785, 0.425325 ), 
      ( -0.500000, 0.809017, 0.309017 ), 
      ( -0.238856, 0.864188, 0.442863 ), 
      ( -0.425325, 0.688191, 0.587785 ), 
      ( -0.716567, 0.681718, -0.147621 ), 
      ( -0.500000, 0.809017, -0.309017 ), 
      ( -0.525731, 0.850651, 0.000000 ), 
      ( 0.000000, 0.850651, -0.525731 ), 
      ( -0.238856, 0.864188, -0.442863 ), 
      ( 0.000000, 0.955423, -0.295242 ), 
      ( -0.262866, 0.951056, -0.162460 ),
      ( 0.000000, 1.000000, 0.000000 ), 
      ( 0.000000, 0.955423, 0.295242 ),
      ( -0.262866, 0.951056, 0.162460 ), 
      ( 0.238856, 0.864188, 0.442863 ), 
      ( 0.262866, 0.951056, 0.162460 ), 
      ( 0.500000, 0.809017, 0.309017 ), 
      ( 0.238856, 0.864188, -0.442863 ),
      ( 0.262866, 0.951056, -0.162460 ), 
      ( 0.500000, 0.809017, -0.309017 ), 
      ( 0.850651, 0.525731, 0.000000 ), 
      ( 0.716567, 0.681718, 0.147621 ), 
      ( 0.716567, 0.681718, -0.147621 ),
      ( 0.525731, 0.850651, 0.000000 ), 
      ( 0.425325, 0.688191, 0.587785 ), 
      ( 0.864188, 0.442863, 0.238856 ), 
      ( 0.688191, 0.587785, 0.425325 ), 
      ( 0.809017, 0.309017, 0.500000 ), 
      ( 0.681718, 0.147621, 0.716567 ), 
      ( 0.587785, 0.425325, 0.688191 ), 
      ( 0.955423, 0.295242, 0.000000 ), 
      ( 1.000000, 0.000000, 0.000000 ), 
      ( 0.951056, 0.162460, 0.262866 ), 
      ( 0.850651, -0.525731, 0.000000 ), 
      ( 0.955423, -0.295242, 0.000000 ), 
      ( 0.864188, -0.442863, 0.238856 ), 
      ( 0.951056, -0.162460, 0.262866 ), 
      ( 0.809017, -0.309017, 0.500000 ), 
      ( 0.681718, -0.147621, 0.716567 ), 
      ( 0.850651, 0.000000, 0.525731 ), 
      ( 0.864188, 0.442863, -0.238856 ), 
      ( 0.809017, 0.309017, -0.500000 ),
      ( 0.951056, 0.162460, -0.262866 ), 
      ( 0.525731, 0.000000, -0.850651 ), 
      ( 0.681718, 0.147621, -0.716567 ), 
      ( 0.681718, -0.147621, -0.716567 ), 
      ( 0.850651, 0.000000, -0.525731 ), 
      ( 0.809017, -0.309017, -0.500000 ), 
      ( 0.864188, -0.442863, -0.238856 ),
      ( 0.951056, -0.162460, -0.262866 ), 
      ( 0.147621, 0.716567, -0.681718 ),
      ( 0.309017, 0.500000, -0.809017 ), 
      ( 0.425325, 0.688191, -0.587785 ), 
      ( 0.442863, 0.238856, -0.864188 ), 
      ( 0.587785, 0.425325, -0.688191 ), 
      ( 0.688191, 0.587785, -0.425325 ), 
      ( -0.147621, 0.716567, -0.681718 ), 
      ( -0.309017, 0.500000, -0.809017 ), 
      ( 0.000000, 0.525731, -0.850651 ), 
      ( -0.525731, 0.000000, -0.850651 ), 
      ( -0.442863, 0.238856, -0.864188 ), 
      ( -0.295242, 0.000000, -0.955423 ), 
      ( -0.162460, 0.262866, -0.951056 ), 
      ( 0.000000, 0.000000, -1.000000 ), 
      ( 0.295242, 0.000000, -0.955423 ), 
      ( 0.162460, 0.262866, -0.951056 ), 
      ( -0.442863, -0.238856, -0.864188 ), 
      ( -0.309017, -0.500000, -0.809017 ), 
      ( -0.162460, -0.262866, -0.951056 ), 
      ( 0.000000, -0.850651, -0.525731 ), 
      ( -0.147621, -0.716567, -0.681718 ), 
      ( 0.147621, -0.716567, -0.681718 ), 
      ( 0.000000, -0.525731, -0.850651 ),
      ( 0.309017, -0.500000, -0.809017 ), 
      ( 0.442863, -0.238856, -0.864188 ), 
      ( 0.162460, -0.262866, -0.951056 ), 
      ( 0.238856, -0.864188, -0.442863 ), 
      ( 0.500000, -0.809017, -0.309017 ), 
      ( 0.425325, -0.688191, -0.587785 ), 
      ( 0.716567, -0.681718, -0.147621 ),
      ( 0.688191, -0.587785, -0.425325 ), 
      ( 0.587785, -0.425325, -0.688191 ), 
      ( 0.000000, -0.955423, -0.295242 ), 
      ( 0.000000, -1.000000, 0.000000 ), 
      ( 0.262866, -0.951056, -0.162460 ), 
      ( 0.000000, -0.850651, 0.525731 ),
      ( 0.000000, -0.955423, 0.295242 ), 
      ( 0.238856, -0.864188, 0.442863 ), 
      ( 0.262866, -0.951056, 0.162460 ),
      ( 0.500000, -0.809017, 0.309017 ), 
      ( 0.716567, -0.681718, 0.147621 ), 
      ( 0.525731, -0.850651, 0.000000 ), 
      ( -0.238856, -0.864188, -0.442863 ), 
      ( -0.500000, -0.809017, -0.309017 ), 
      ( -0.262866, -0.951056, -0.162460 ), 
      ( -0.850651, -0.525731, 0.000000 ), 
      ( -0.716567, -0.681718, -0.147621 ), 
      ( -0.716567, -0.681718, 0.147621 ), 
      ( -0.525731, -0.850651, 0.000000 ), 
      ( -0.500000, -0.809017, 0.309017 ), 
      ( -0.238856, -0.864188, 0.442863 ), 
      ( -0.262866, -0.951056, 0.162460 ), 
      ( -0.864188, -0.442863, 0.238856 ), 
      ( -0.809017, -0.309017, 0.500000 ),
      ( -0.688191, -0.587785, 0.425325 ), 
      ( -0.681718, -0.147621, 0.716567 ), 
      ( -0.442863, -0.238856, 0.864188 ), 
      ( -0.587785, -0.425325, 0.688191 ), 
      ( -0.309017, -0.500000, 0.809017 ), 
      ( -0.147621, -0.716567, 0.681718 ), 
      ( -0.425325, -0.688191, 0.587785 ),
      ( -0.162460, -0.262866, 0.951056 ), 
      ( 0.442863, -0.238856, 0.864188 ), 
      ( 0.162460, -0.262866, 0.951056 ), 
      ( 0.309017, -0.500000, 0.809017 ), 
      ( 0.147621, -0.716567, 0.681718 ), 
      ( 0.000000, -0.525731, 0.850651 ),
      ( 0.425325, -0.688191, 0.587785 ), 
      ( 0.587785, -0.425325, 0.688191 ), 
      ( 0.688191, -0.587785, 0.425325 ), 
      ( -0.955423, 0.295242, 0.000000 ), 
      ( -0.951056, 0.162460, 0.262866 ), 
      ( -1.000000, 0.000000, 0.000000 ), 
      ( -0.850651, 0.000000, 0.525731 ), 
      ( -0.955423, -0.295242, 0.000000 ), 
      ( -0.951056, -0.162460, 0.262866 ), 
      ( -0.864188, 0.442863, -0.238856 ),
      ( -0.951056, 0.162460, -0.262866 ),
      ( -0.809017, 0.309017, -0.500000 ),
      ( -0.864188, -0.442863, -0.238856 ),
      ( -0.951056, -0.162460, -0.262866 ),
      ( -0.809017, -0.309017, -0.500000 ),
      ( -0.681718, 0.147621, -0.716567 ),
      ( -0.681718, -0.147621, -0.716567 ),
      ( -0.850651, 0.000000, -0.525731 ),
      ( -0.688191, 0.587785, -0.425325 ),
      ( -0.587785, 0.425325, -0.688191 ),
      ( -0.425325, 0.688191, -0.587785 ),
      ( -0.425325, -0.688191, -0.587785 ),
      ( -0.587785, -0.425325, -0.688191 ),
      ( -0.688191, -0.587785, -0.425325 )
    );

type
  TMD2Animation = (
      MD2_ANIM_STAND,
      MD2_ANIM_RUN,
      MD2_ANIM_ATTACK,
      MD2_ANIM_PAIN1,
      MD2_ANIM_PAIN2,
      MD2_ANIM_PAIN3,
      MD2_ANIM_JUMP,
      MD2_ANIM_FLIPOFF,
      MD2_ANIM_SALUTE,
      MD2_ANIM_TAUNT,
      MD2_ANIM_WAVE,
      MD2_ANIM_POINT,
      MD2_ANIM_CROUCH_STAND,
      MD2_ANIM_CROUCH_WALK,
      MD2_ANIM_CROUCH_ATTACK,
      MD2_ANIM_CROUCH_PAIN,
      MD2_ANIM_CROUCH_DEATH,
      MD2_ANIM_DEATH1,
      MD2_ANIM_DEATH2,
      MD2_ANIM_DEATH3
    );

const
  MD2_ANIM_FRAME_NUMBERS: array [TMD2Animation, 0..1] of Integer =
    (
      ( 0, 40 ),      //MD2_ANIM_STAND
      ( 40, 6 ),      //MD2_ANIM_RUN
      ( 46, 8 ),      //MD2_ANIM_ATTACK
      ( 54, 4 ),      //MD2_ANIM_PAIN1
      ( 58, 4 ),      //MD2_ANIM_PAIN2
      ( 62, 4 ),      //MD2_ANIM_PAIN3
      ( 66, 6 ),      //MD2_ANIM_JUMP
      ( 72, 12 ),     //MD2_ANIM_FLIPOFF
      ( 84, 11 ),     //MD2_ANIM_SALUTE
      ( 95, 17 ),     //MD2_ANIM_TAUNT
      ( 112, 11 ),    //MD2_ANIM_WAVE
      ( 123, 12 ),    //MD2_ANIM_POINT
      ( 135, 19 ),    //MD2_ANIM_CROUCH_STAND
      ( 154, 6 ),     //MD2_ANIM_CROUCH_WALK
      ( 160, 9 ),     //MD2_ANIM_CROUCH_ATTACK
      ( 169, 4 ),     //MD2_ANIM_CROUCH_PAIN
      ( 173, 5 ),     //MD2_ANIM_CROUCH_DEATH
      ( 178, 6 ),     //MD2_ANIM_DEATH1
      ( 184, 6 ),     //MD2_ANIM_DEATH2
      ( 190, 8 )      //MD2_ANIM_DEATH3
    );

type
  TMD2Model = class
  private
    FHeader: TMD2Header;
    FSkins: array of TMD2Skin;
    FTexCoords: array of TMD2TextureCoordinate;
    FTriangles: array of TMD2Triangle;
    FFrames: array of TMD2Frame;
    FGLCommands: array of TMD2GLCommands;
    function GetSkin(i: Integer): TMD2Skin;
    function GetTexCoord(i: Integer): TMD2TextureCoordinate;
    function GetTriangle(i: Integer): TMD2Triangle;
    function GetFrame(i: Integer): TMD2Frame;
    function GetGLCommands(i: Integer): TMD2GLCommands;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromStream(s: TStream);
    procedure LoadFromFile(filename: String);
    property Header: TMD2Header read FHeader;
    property Skins[i: Integer]: TMD2Skin read GetSkin;
    property TexCoords[i: Integer]: TMD2TextureCoordinate read GetTexCoord;
    property Triangles[i: Integer]: TMD2Triangle read GetTriangle;
    property Frames[i: Integer]: TMD2Frame read GetFrame;
    property GLCommands[i: Integer]: TMD2GLCommands read GetGLCommands;
  end;

implementation

function TMD2Model.GetSkin(i: Integer): TMD2Skin;
begin

  Result := FSkins[i];

end;

function TMD2Model.GetTexCoord(i: Integer): TMD2TextureCoordinate;
begin

  Result := FTexCoords[i];

end;

function TMD2Model.GetTriangle(i: Integer): TMD2Triangle;
begin

  Result := FTriangles[i];

end;

function TMD2Model.GetFrame(i: Integer): TMD2Frame;
begin

  Result := FFrames[i];

end;

function TMD2Model.GetGLCommands(i: Integer): TMD2GLCommands;
begin

  Result := FGLCommands[i];

end;

constructor TMD2Model.Create;
begin

  inherited Create;

  FillChar(FHeader, SizeOf(TMD2Header), 0);
  SetLength(FSkins, 0);
  SetLength(FTexCoords, 0);
  SetLength(FTriangles, 0);
  SetLength(FFrames, 0);
  SetLength(FGLcommands, 0);

end;

destructor TMD2Model.Destroy;
begin

  SetLength(FSkins, 0);
  SetLength(FTexCoords, 0);
  SetLength(FTriangles, 0);
  SetLength(FFrames, 0);
  SetLength(FGLcommands, 0);

  inherited Destroy;

end;

procedure TMD2Model.LoadFromStream(s: TStream);
var
  i: Integer;
  count: Integer;
  glcmds: TMD2GLCommands;
begin

  s.Read(FHeader, SizeOf(TMD2Header));

  with FHeader do
  begin
    if Magic <> MD2_MAGIC then
      raise Exception.Create('Not a valid MD2 file!');

    SetLength(FSkins, NumSkins);
    s.Seek(OffsetSkins, soFromBeginning);
    s.Read(FSkins[0], NumSkins*SizeOf(TMD2Skin));

    SetLength(FTexCoords, NumTexCoords);
    s.Seek(OffsetTexCoords, soFromBeginning);
    s.Read(FTexCoords[0], NumTexCoords*SizeOf(TMD2TextureCoordinate));

    SetLength(FTriangles, NumTriangles);
    s.Seek(OffsetTriangles, soFromBeginning);
    s.Read(FTriangles[0], NumTriangles*SizeOf(TMD2Triangle));

    SetLength(FFrames, NumFrames);
    s.Seek(OffsetFrames, soFromBeginning);
    for i := 0 to NumFrames - 1 do
    begin
      s.Read(FFrames[i], 40);
      SetLength(FFrames[i].Vertices, FrameSize div SizeOf(TMD2Vertex));
      s.Read(FFrames[i].Vertices[0], FrameSize - 40);
    end;

    SetLength(FGLCommands, 0);
    s.Seek(OffsetGLCommands, soFromBeginning);
    s.Read(count, SizeOf(Integer));
    while count <> 0 do
    begin
      if count > 0 then glcmds.Mode := MD2_GLCOMMAND_STRIP
      else glcmds.Mode := MD2_GLCOMMAND_FAN;

      count := Abs(count);
      SetLength(glcmds.Commands, count);
      s.Read(glcmds.Commands[0], count * SizeOf(TMD2GLCommand));

      SetLength(FGLCommands, Length(FGLCommands) + 1);
      FGLCommands[High(FGLCommands)] := glcmds;

      s.Read(count, SizeOf(Integer));
    end;

    { Trick: Change the value of header.NumGLCommands to reflect the number of
             groups rather than the number of bytes occupied by the combined
             groups. This is much more useful. }
    FHeader.NumGLCommands := Length(FGLCommands);
  end;

end;

procedure TMD2Model.LoadFromFile(filename: String);
var
  s: TFileStream;
begin

  s := TFileStream.Create(filename, fmOpenRead or fmShareDenyWrite);
  LoadFromStream(s);
  s.Free;

end;

end.
