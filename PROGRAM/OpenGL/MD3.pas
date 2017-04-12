unit MD3;

interface

uses
  SysUtils, Classes, DotMath, DotUtils;

{*** TMD3Skins: collection of skin->mesh assignments **************************}

type
  TMD3SkinAssignment = record
    Surface, Skin: String;
  end;
  TMD3SkinFile = class
  private
    FName: String;
    FAssignments: array of TMD3SkinAssignment;
    function GetAssignment(surf: String): String;
    procedure LoadFromStream(s: TStream);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(filename: String);
    property Name: String read FName;
    property Assignments[s: String]: String read GetAssignment;
  end;

{*** TMD3Mesh: represents the contents of one .MD3 file ***********************}

const
  MD3_MAX_QPATH = 64;

type
  // MD3 file header.
  TMD3Header = packed record
    Ident: array [0..3] of Char;
    Version: Integer;
    Name: array [0..MD3_MAX_QPATH-1] of Char;
    Flags: Integer;
    NumFrames: Integer;
    NumTags: Integer;
    NumSurfaces: Integer;
    NumSkins: Integer;
    OffsetFrames: Integer;
    OffsetTags: Integer;
    OffsetSurfaces: Integer;
    OffsetEOF: Integer;
  end;

const
  // Magic number that identifies MD3 files.
  MD3_MAGIC = 'IDP3';
  // Some max. sizes:
  MD3_MAX_FRAMES = 1024;
  MD3_MAX_TAGS = 16;
  MD3_MAX_SURFACES = 32;
  MD3_MAX_SHADERS = 256;
  MD3_MAX_VERTS = 4096;
  MD3_MAX_TRIANGLES = 8192;

type
  TMD3Frame = packed record
    MinBounds, MaxBounds: TDotVector3;
    LocalOrigin: TDotVector3;
    Radius: Single;
    Name: array [0..15] of Char;
  end;

  TMD3Tag = packed record
    Name: array [0..MD3_MAX_QPATH-1] of Char;
    Origin: TDotVector3;
    Axes: TDotMatrix3x3;
  end;

  TMD3Shader = packed record
    Name: array [0..MD3_MAX_QPATH-1] of Char;
    Index: Integer;
  end;

  TMD3Triangle = packed record
    A, B, C: Integer;
  end;

  TMD3Normal = packed record
    Lat, Long: Byte;
  end;

  TMD3Vertex = packed record
    X, Y, Z: SmallInt;
    Normal: TMD3Normal;
  end;

  TMD3Surface = packed record
    Ident: array [0..3] of Char;
    Name: array [0..MD3_MAX_QPATH-1] of Char;
    Flags: Integer;
    NumFrames: Integer;
    NumShaders: Integer;
    NumVerts: Integer;
    NumTriangles: Integer;
    OffsetTriangles: Integer;
    OffsetShaders: Integer;
    OffsetST: Integer;
    OffsetXYZNormal: Integer;
    OffsetEnd: Integer;

    Shaders: array of TMD3Shader;
    Triangles: array of TMD3Triangle;
    TexCoords: array of TDotVector2;
    XYZN: array of TMD3Vertex;
  end;

type
  TMD3Mesh = class
  private
    FName: String;
    FHeader: TMD3Header;
    FFrames: array of TMD3Frame;
    FTags: array of TMD3Tag;
    FSurfaces: array of TMD3Surface;
    FSkinFiles: array of TMD3SkinFile;

    function GetFrame(i: Integer): TMD3Frame;
    function GetTag(i: Integer): TMD3Tag;
    function GetSurface(i: Integer): TMD3Surface;
    function GetSkinFile(i: Integer): TMD3SkinFile;
    function GetNumSkins: Integer;
    procedure LoadFromStream(s: TStream);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(filename: String);

    property Header: TMD3Header read FHeader;
    property Frames[i: Integer]: TMD3Frame read GetFrame;
    property Tags[i: Integer]: TMD3Tag read GetTag;
    property Surfaces[i: Integer]: TMD3Surface read GetSurface;
    property SkinFiles[i: Integer]: TMD3SkinFile read GetSkinFile;
    property NumSkins: Integer read GetNumSkins;
  end;

function md3DecodeNormal(const n: TMD3Normal): TDotVector3;

{*** TMD3Animations: keyframe information contained in animation.cfg files ****}

type
  TMD3Animation = record
    FirstFrame, NumFrames: Integer;
    LoopingFrames: Integer;
    FramesPerSecond: Integer;
  end;

  TMD3CharacterSex = ( MD3_SEX_HE, MD3_SEX_SHE, MD3_SEX_IT );

  TMD3AnimationName = (
      MD3_ANIM_BOTH_DEATH1,
      MD3_ANIM_BOTH_DEAD1,
      MD3_ANIM_BOTH_DEATH2,
      MD3_ANIM_BOTH_DEAD2,
      MD3_ANIM_BOTH_DEATH3,
      MD3_ANIM_BOTH_DEAD3,

      MD3_ANIM_TORSO_GESTURE,

      MD3_ANIM_TORSO_ATTACK,
      MD3_ANIM_TORSO_ATTACK2,

      MD3_ANIM_TORSO_DROP,
      MD3_ANIM_TORSO_RAISE,

      MD3_ANIM_TORSO_STAND,
      MD3_ANIM_TORSO_STAND2,

      MD3_ANIM_LEGS_WALKCR,
      MD3_ANIM_LEGS_WALK,
      MD3_ANIM_LEGS_RUN,
      MD3_ANIM_LEGS_BACK,
      MD3_ANIM_LEGS_SWIM,

      MD3_ANIM_LEGS_JUMP,
      MD3_ANIM_LEGS_LAND,

      MD3_ANIM_LEGS_JUMPB,
      MD3_ANIM_LEGS_LANDB,

      MD3_ANIM_LEGS_IDLE,
      MD3_ANIM_LEGS_IDLECR,

      MD3_ANIM_LEGS_TURN
    );

  TMD3AnimationConfig = class
  private
    FHeadOffset: TDotVector3;
    FFootSteps: String;
    FSex: TMD3CharacterSex;
    FAnimations: array [TMD3AnimationName] of TMD3Animation;
    function GetAnim(a: TMD3AnimationName): TMD3Animation;
    procedure LoadFromStream(s: TStream);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(filename: String);
    property HeadOffset: TDotVector3 read FHeadOffset;
    property FootSteps: String read FFootSteps;
    property Sex: TMD3CharacterSex read FSex;
    property Animations[a: TMD3AnimationName]: TMD3Animation read GetAnim;
  end;

{*** TMD3Model: collection of TMD3Mesh combined with a TMD3Animation **********}

type
  TMD3ModelSegments = ( MD3_SEGMENT_HEAD, MD3_SEGMENT_TORSO, MD3_SEGMENT_LEGS );

const
  MD3_MODEL_SEGMENT_NAMES: array [TMD3ModelSegments] of String = (
      'head.md3',
      'upper.md3',
      'lower.md3'
    );

type
  TMD3Model = class
  private
    FMeshes: array [TMD3ModelSegments] of TMD3Mesh;
    FAnimCfg: TMD3AnimationConfig;
    function GetMesh(s: TMD3ModelSegments): TMD3Mesh;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(filename: String);
    property Segments[s: TMD3ModelSegments]: TMD3Mesh read GetMesh;
    property AnimationConfig: TMD3AnimationConfig read FAnimCfg;
  end;

implementation

type
  TCharSet = set of Char;

function GetToken(var InTxt : String; const delimiters: TCharSet = [' ', #9, #10, #13]): String;
var
  i: Integer;
begin

  i := 1;
  while (i <= Length(InTxt)) and not (InTxt[i] in delimiters) do INC(i);

  Result := Copy(InTxt, 1, i-1);
  Delete(InTxt, 1, i);

  i := 1;
  while (i <= Length(InTxt)) and (InTxt[i] in delimiters) do INC(i);
  Delete(InTxt, 1, i-1);

end;

{*** TMD3SkinFile *************************************************************}

function TMD3SkinFile.GetAssignment(surf: String): String;
var
  i: Integer;
begin

  for i := 0 to High(FAssignments) do
  begin
    if SameText(FAssignments[i].Surface, surf) then
    begin
      Result := FAssignments[i].Skin;
      Exit;
    end; 
  end;

  Result := '';

end;

constructor TMD3SkinFile.Create;
begin

  inherited Create;

  SetLength(FAssignments, 0);
  FName := '';

end;

destructor TMD3SkinFile.Destroy;
begin

  SetLength(FAssignments, 0);

  inherited Destroy;

end;

procedure TMD3SkinFile.LoadFromStream(s: TStream);
var
  txt: TStringList;
  i: Integer;
  line: String;
  ass: TMD3SkinAssignment;
begin

  txt := TStringList.Create;
  txt.LoadFromStream(s);

  for i := 0 to txt.Count - 1 do
  begin
    line := Trim(txt[i]);
    if Pos(',', line) = 0 then Continue;

    ass.Surface := GetToken(line, [',']);
    ass.Skin := line;

    SetLength(FAssignments, Length(FAssignments) + 1);
    FAssignments[High(FAssignments)] := ass;
  end;

  txt.Free;

end;

procedure TMD3SkinFile.LoadFromFile(filename: String);
var
  s: TFileStream;
begin

  s := TFileStream.Create(filename, fmOpenRead or fmShareDenyWrite);
  LoadFromStream(s);
  s.Free;

  FName := ExtractFileName(filename);

end;

{*** TMD3Mesh *****************************************************************}

function TMD3Mesh.GetFrame(i: Integer): TMD3Frame;
begin

  Result := FFrames[i];

end;

function TMD3Mesh.GetTag(i: Integer): TMD3Tag;
begin

  Result := FTags[i];

end;

function TMD3Mesh.GetSurface(i: Integer): TMD3Surface;
begin

  Result := FSurfaces[i];

end;

function TMD3Mesh.GetSkinFile(i: Integer): TMD3SkinFile;
begin

  Result := FSkinFiles[i];

end;

function TMD3Mesh.GetNumSkins: Integer;
begin

  Result := Length(FSkinFiles);

end;

constructor TMD3Mesh.Create;
begin

  inherited Create;

  FillChar(FHeader, SizeOf(TMD3Header), 0);
  SetLength(FFrames, 0);
  SetLength(FTags, 0);
  SetLength(FSurfaces, 0);

end;

destructor TMD3Mesh.Destroy;
begin

  SetLength(FFrames, 0);
  SetLength(FTags, 0);
  SetLength(FSurfaces, 0);

  inherited Destroy;

end;

procedure TMD3Mesh.LoadFromStream(s: TStream);
var
  i: Integer;
  o: Int64;
begin

  s.Read(FHeader, SizeOf(TMD3Header));

  if CompareText(FHeader.Ident, MD3_MAGIC) <> 0 then
    raise Exception.Create('Invalid MD3 file!');

  SetLength(FFrames, FHeader.NumFrames);
  s.Seek(FHeader.OffsetFrames, soFromBeginning);
  s.Read(FFrames[0], SizeOf(TMD3Frame)*FHeader.NumFrames);

  SetLength(FTags, FHeader.NumTags*FHeader.NumFrames);
  s.Seek(FHeader.OffsetTags, soFromBeginning);
  s.Read(FTags[0], SizeOf(TMD3Tag)*FHeader.NumTags*FHeader.NumFrames);

  SetLength(FSurfaces, FHeader.NumSurfaces);
  o := FHeader.OffsetSurfaces;
  s.Seek(o, soFromBeginning);
  for i := 0 to FHeader.NumSurfaces - 1 do
  begin
    s.Read(FSurfaces[i], SizeOf(TMD3Surface) - 16);
    with FSurfaces[i] do
    begin
      if CompareText(Ident, MD3_MAGIC) <> 0 then
        raise Exception.Create('Invalid MD3 surface!');

      SetLength(Shaders, NumShaders); // --> These names identify the surface in the skin file.
      s.Seek(o + OffsetShaders, soFromBeginning);
      s.Read(Shaders[0], SizeOf(TMD3Shader)*NumShaders);

      SetLength(Triangles, NumTriangles);
      s.Seek(o + OffsetTriangles, soFromBeginning);
      s.Read(Triangles[0], SizeOf(TMD3Triangle)*NumTriangles);

      SetLength(XYZN, NumVerts * NumFrames);
      s.Seek(o + OffsetXYZNormal, soFromBeginning);
      s.Read(XYZN[0], SizeOf(TMD3Vertex)*NumVerts*NumFrames);

      SetLength(TexCoords, NumVerts);
      s.Seek(o + OffsetST, soFromBeginning);
      s.Read(TexCoords[0], SizeOf(TDotVector2)*NumVerts);

      INC(o, OffsetEnd);
      s.Seek(o, soFromBeginning);
    end;
  end;

end;

procedure TMD3Mesh.LoadFromFile(filename: String);
var
  s: TFileStream;
  skins: TStringList;
  i: Integer;
  pwd: String;
begin

  pwd := GetCurrentDir;
  SetCurrentDir(ExtractFilePath(filename));

  FName := ChangeFileExt(ExtractFileName(filename), '');

  skins := dotFindFiles(FName + '_*.skin', faAnyFile);
  SetLength(FSkinFiles, skins.Count);
  for i := 0 to High(FSkinFiles) do
  begin
    FSkinFiles[i] := TMD3SkinFile.Create;
    FSkinFiles[i].LoadFromFile(skins[i]);
  end;

  s := TFileStream.Create(filename, fmOpenRead or fmShareDenyWrite);
  LoadFromStream(s);
  s.Free;

  SetCurrentDir(pwd);

end;

function md3DecodeNormal(const n: TMD3Normal): TDotVector3;
var
  lat, long: Single;
begin

  lat := n.Lat * (2*PI) / 255;
  long := n.Long * (2*PI) / 255;

  Result.X := cos(lat) * sin(long);
  Result.Y := sin(lat) * sin(long);
  Result.Z := cos(long);

end;

{*** TMD3Animation ************************************************************}

function TMD3AnimationConfig.GetAnim(a: TMD3AnimationName): TMD3Animation;
begin

  Result := FAnimations[a];

end;

constructor TMD3AnimationConfig.Create;
begin

  inherited Create;

  FHeadOffset := DOT_ORIGIN3;
  FFootSteps := '';
  FSex := MD3_SEX_IT;  // More politically correct than defaulting to either male or female?

  FillChar(FAnimations, SizeOf(FAnimations), 0);

end;

destructor TMD3AnimationConfig.Destroy;
begin

  inherited Destroy;

end;

procedure TMD3AnimationConfig.LoadFromStream(s: TStream);
var
  txt: TStringList;
  line, tok: String;
  i, j: Integer;
  curAnim: TMD3AnimationName;
  skip: Integer;
begin

  curAnim := Low(TMD3AnimationName);

  txt := TStringList.Create;
  txt.LoadFromStream(s);

  for i := 0 to txt.Count - 1 do
  begin
    line := Trim(txt[i]);

    if Length(line) = 0 then Continue;
    tok := GetToken(line);
    if Pos('//', tok) = 1 then Continue;

    if SameText(tok, 'headoffset') then
    begin
      for j := 0 to 2 do
      begin
        FHeadOffset.xyz[j] := StrToFloat(GetToken(line));
      end;
    end
    else if SameText(tok, 'sex') then
    begin
      tok := GetToken(line);
      if SameText(tok, 'm') then FSex := MD3_SEX_HE
      else if SameText(tok, 'f') then FSex := MD3_SEX_SHE
      else FSex := MD3_SEX_IT;
    end
    else if SameText(tok, 'footsteps') then
    begin
       FFootSteps := GetToken(line);
    end
    else begin
      // If it's not numeric we don't know what it is.
      try
        StrToInt(tok);
      except on Exception do
        Continue;
      end;

      with FAnimations[curAnim] do
      begin
        FirstFrame := StrToInt(tok);
        NumFrames := StrToInt(GetToken(line));
        LoopingFrames := StrToInt(GetToken(line));
        FramesPerSecond := StrToInt(GetToken(line));

        if curAnim < High(TMD3AnimationName) then
          INC(curAnim);
      end;
    end;
  end;

  skip := FAnimations[MD3_ANIM_LEGS_WALKCR].FirstFrame
           - FAnimations[MD3_ANIM_TORSO_GESTURE].FirstFrame;

  for curAnim := MD3_ANIM_LEGS_WALKCR to High(TMD3AnimationName) do
    FAnimations[curAnim].FirstFrame := FAnimations[curAnim].FirstFrame - skip;
  
  txt.Free;

end;

procedure TMD3AnimationConfig.LoadFromFile(filename: String);
var
  s: TFileStream;
begin

  s := TFileStream.Create(filename, fmOpenRead or fmShareDenyWrite);
  LoadFromStream(s);
  s.Free;

end;

{*** TMD3Model ****************************************************************}

function TMD3Model.GetMesh(s: TMD3ModelSegments): TMD3Mesh;
begin

  Result := FMeshes[s];

end;

constructor TMD3Model.Create;
var
  i: TMD3ModelSegments;
begin

  inherited Create;

  FAnimCfg := TMD3AnimationConfig.Create;
  for i := Low(TMD3ModelSegments) to High(TMD3ModelSegments) do
    FMeshes[i] := TMD3Mesh.Create;

end;

destructor TMD3Model.Destroy;
var
  i: TMD3ModelSegments;
begin

  for i := Low(TMD3ModelSegments) to High(TMD3ModelSegments) do
    FMeshes[i].Free;

  FAnimCfg.Free;

  inherited Destroy;

end;

procedure TMD3Model.LoadFromFile(filename: String);
var
  path: String;
  i: TMD3ModelSegments;
begin

  path := ExtractFilePath(filename);

  FAnimCfg.LoadFromFile(filename);

  for i := Low(TMD3ModelSegments) to High(TMD3ModelSegments) do
  begin
    FMeshes[i].LoadFromFile(path + MD3_MODEL_SEGMENT_NAMES[i]);
  end;

end;

end.
