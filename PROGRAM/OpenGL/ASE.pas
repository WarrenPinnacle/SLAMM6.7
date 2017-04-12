unit ASE;

{*******************************************************************************

  ASE reader for Delphi, by Tom Nuydens (tom@delphi3d.net, www.delphi3d.net).

  To use this, simply create a new TASEFile object and call LoadFromFile(). You
  can then access all the data in pretty much the same structure as it is stored
  in inside the file. Just let Delphi's code completion be your guide :-)

  The ASE reader will handle any kind of mesh, with or without vertex/face
  normals, vertex colors or texture coordinates. It also parses material lists,
  groups, the "*SCENE" block, and a bunch of other stuff. What it definitely
  doesn't parse is animation data and any non-visual data such as cameras and
  helpers.

*******************************************************************************}

interface

uses
  SysUtils, Classes, TokenStream, ASETokens;

type
  TASEColor = record
    R, G, B, A: Single;
  end;
  TASEVector = record
    X, Y, Z: Single;
  end;
  TASEMatrix = array [0..3, 0..3] of Single;
  TASEFace = record
    A, B, C: Integer;
    AB, BC, CA: Boolean;
    Smoothing: Integer;
    MtlID: Integer;
  end;
  TASETVertex = record
    U, V, W: Single;
  end;
  TASEFaceRef = record
    A, B, C: Integer;
  end;

const
  ASE_BLACK: TASEColor = (R: 0; G: 0; B: 0; A: 1);
  ASE_ORIGIN: TASEVector = (X: 0; Y: 0; Z: 0);
  ASE_IDENTITY: TASEMatrix = ( (1, 0, 0, 0), (0, 1, 0, 0), (0, 0, 1, 0), (0, 0, 0, 1) );

type
  TASEHeader = class
  protected
    FVersion: String;
  public
    constructor Create;
    procedure Parse(source: TTokenStream);
    property Version: String read FVersion;
  end;

type
  TASEComment = class
  protected
    FText: String;
  public
    constructor Create;
    procedure Parse(source: TTokenStream);
    property Text: String read FTExt;
  end;

type
  TASEUnknownElement = class
  protected
    FText: String;
  public
    constructor Create;
    procedure Parse(source: TTokenStream);
    property Text: String read FText;
  end;

type
  TASEScene = class
  protected
    FFilename: String;
    FFirstFrame, FLastFrame: Integer;
    FFps: Integer;
    FTicksPerFrame: Integer;
    FBackground: TASEColor;
    FAmbient: TASEColor;
  public
    constructor Create;
    procedure Parse(source: TTokenStream);
    property Filename: String read FFilename;
    property FirstFrame: Integer read FFirstFrame;
    property LastFrame: Integer read FLastFrame;
    property Fps: Integer read FFps;
    property TicksPerFrame: Integer read FTicksPerFrame;
    property Background: TASEColor read FBackground;
    property Ambient: TASEColor read FAmbient;
  end;

type
  TASEMap = class
  protected
    FName: String;
    FClass: String;
    FSubNo: Integer;
    FAmount: Single;
    FBitmap: String;
    FType: String;
    FUOffset: Single;
    FVOffset: Single;
    FUTiling: Single;
    FVTiling: Single;
    FUVWAngle: Single;
    FBlur: Single;
    FBlurOffset: Single;
    FNoiseAmt: Single;
    FNoiseSize: Single;
    FNoiseLevel: Single;
    FNoisePhase: Single;
    FBitmapFilter: String;
  public
    constructor Create;
    procedure Parse(source: TTokenStream);
    property Name: String read FName;
    property MapClass: String read FClass;
    property SubNo: Integer read FSubNo;
    property Amount: Single read FAmount;
    property Bitmap: String read FBitmap;
    property MapType: String read FType;
    property UOffset: Single read FUOffset;
    property VOffset: Single read FVOffset;
    property UTiling: Single read FUTiling;
    property VTiling: Single read FVTiling;
    property UVWAngle: Single read FUVWAngle;
    property Blur: Single read FBlur;
    property BlurOffset: Single read FBlurOffset;
    property NoiseAmt: Single read FNoiseAmt;
    property NoiseSize: Single read FNoiseSize;
    property NoiseLevel: Single read FNoiseLevel;
    property NoisePhase: Single read FNoisePhase;
    property BitmapFilter: String read FBitmapFilter;
  end;

type
  TASEMapType = (ASE_AMBIENT_MAP, ASE_DIFFUSE_MAP, ASE_SPECULAR_MAP,
                 ASE_SHINE_MAP, ASE_SHINESTRENGTH_MAP, ASE_SELFILLUM_MAP,
                 ASE_OPACITY_MAP, ASE_FILTERCOLOR_MAP, ASE_BUMP_MAP,
                 ASE_REFLECT_MAP, ASE_REFRACT_MAP);
  TASEMaterial = class
  protected
    FName: String;
    FClass: String;
    FAmbient: TASEColor;
    FDiffuse: TASEColor;
    FSpecular: TASEColor;
    FShine: Single;
    FShineStrength: Single;
    FTransparency: Single;
    FWireSize: Single;
    FShading: String;
    FXPFalloff: Single;
    FSelfIllum: Single;
    FFalloff: String;
    FXPType: String;
    FMaps: array [TASEMapType] of TASEMap; //TODO: How many different kinds of maps are there?
    FSubMaterials: array of TASEMaterial;
    FNumSubMaterials: Integer;
    function GetMap(i: TASEMapType): TASEMap;
    function GetSubMaterial(i: Integer): TASEMaterial;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(source: TTokenStream);
    function NumMaps: Integer;
    property Name: String read FName;
    property MatClass: String read FClass;
    property Ambient: TASEColor read FAmbient;
    property Diffuse: TASEColor read FDiffuse;
    property Specular: TASEColor read FSpecular;
    property Shine: Single read FShine;
    property ShineStrength: Single read FShineStrength;
    property Transparency: Single read FTransparency;
    property WireSize: Single read FWireSize;
    property Shading: String read FShading;
    property XPFalloff: Single read FXPFalloff;
    property SelfIllum: Single read FSelfIllum;
    property Falloff: String read FFalloff;
    property XPType: String read FXPType;
    property Maps[i: TASEMapType]: TASEMap read GetMap;
    property SubMaterials[i: Integer]: TASEMaterial read GetSubMaterial;
    property NumSubMaterials: Integer read FNumSubMaterials;
  end;

type
  TASEMaterialList = class
  protected
    FMaterials: array of TASEMaterial;
    function GetMaterial(i: Integer): TASEMaterial;
  public
    constructor Create;
    destructor Destroy; override;
    function NumMaterials: Integer;
    procedure Parse(source: TTokenStream);
    property Materials[i: Integer]: TASEMaterial read GetMaterial;
  end;

type
  TASENodeTM = class
  protected
    FNodeName: String;
    FInheritPos: TASEVector;
    FInheritRot: TASEVector;
    FInheritScale: TASEVector;
    FMatrix: TASEMatrix;
    FPosition: TASEVector;
    FRotAxis: TASEVector;
    FRotAngle: Single;
    FScale: TASEVector;
    FScaleAxis: TASEVector;
    FScaleAxisAngle: Single;
  public
    constructor Create;
    procedure Parse(source: TTokenStream);
    property NodeName: String read FNodeName;
    property InheritPos: TASEVector read FInheritPos;
    property InheritRot: TASEVector read FInheritRot;
    property InheritScale: TASEVector read FInheritScale;
    property Matrix: TASEMatrix read FMatrix;
    property Position: TASEVector read FPosition;
    property RotAxis: TASEVector read FRotAxis;
    property RotAngle: Single read FRotAngle;
    property Scale: TASEVector read FScale;
    property ScaleAxis: TASEVector read FScaleAxis;
    property ScaleAxisAngle: Single read FScaleAxisAngle;
  end;

type
  TASEMeshVertexList = class
  protected
    FVerts: array of TASEVector;
    function GetVertex(i: Integer): TASEVector;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(source: TTokenStream);
    function NumVertices: Integer;
    property Vertices[i: Integer]: TASEVector read GetVertex; default;
  end;

type
  TASEMeshFaceList = class
  protected
    FFaces: array of TASEFace;
    function GetFace(i: Integer): TASEFace;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(source: TTokenStream);
    function NumFaces: Integer;
    property Faces[i: Integer]: TASEFace read GetFace; default;
  end;

type
  TASEMeshNormals = class
  protected
    FVertexNormals: array of TASEVector;
    FVNormalIndices: array of Cardinal;
    FFaceNormals: array of TASEVector;
    function GetVertexNormal(i: Integer): TASEVector;
    function GetFaceNormal(i: Integer): TASEVector;
    function GetVNormalIndex(i: Integer): Cardinal;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(source: TTokenStream);
    function NumVertexNormals: Integer;
    function NumFaceNormals: Integer;
    property VertexNormals[i: Integer]: TASEVector read GetVertexNormal;
    property FaceNormals[i: Integer]: TASEVector read GetFaceNormal;
    property VNormalIndices[i: Integer]: Cardinal read GetVNormalIndex;
  end;

type
  TASEMeshTVertexList = class
  protected
    FTVerts: array of TASETVertex;
    function GetTVertex(i: Integer): TASETVertex;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(source: TTokenStream);
    function NumTVertices: Integer;
    property TVertices[i: Integer]: TASETVertex read GetTVertex; default;
  end;

type
  TASEMeshCVertexList = class
  protected
    FCVerts: array of TASEColor;
    function GetCVertex(i: Integer): TASEColor;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(source: TTokenStream);
    function NumCVertices: Integer;
    property CVertices[i: Integer]: TASEColor read GetCVertex; default;
  end;

type
  TASEMeshTFaceList = class
  protected
    FTFaces: array of TASEFaceRef;
    function GetTFace(i: Integer): TASEFaceRef;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(source: TTokenStream);
    function NumTFaces: Integer;
    property TFaces[i: Integer]: TASEFaceRef read GetTFace; default;
  end;

type
  TASEMeshCFaceList = class
  protected
    FCFaces: array of TASEFaceRef;
    function GetCFace(i: Integer): TASEFaceRef;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(source: TTokenStream);
    function NumCFaces: Integer;
    property CFaces[i: Integer]: TASEFaceRef read GetCFace; default;
  end;

type
  TASEMesh = class
  protected
    FVertexList: TASEMeshVertexList;
    FFaceList: TASEMeshFaceList;
    FNormals: TASEMeshNormals;
    FTVertexList: TASEMeshTVertexList;
    FCVertexList: TASEMeshCVertexList;
    FTFaceList: TASEMeshTFaceList;
    FCFaceList: TASEMeshCFaceList;
    FTimeValue: Integer; //TODO: Integer or Single?
    FNumVertex: Integer;
    FNumFaces: Integer;
    FNumTVertex: Integer;
    FNumCVertex: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(source: TTokenStream);
    property VertexList: TASEMeshVertexList read FVertexList;
    property FaceList: TASEMeshFaceList read FFaceList;
    property Normals: TASEMeshNormals read FNormals;
    property TVertexList: TASEMeshTVertexList read FTVertexList;
    property TFaceList: TASEMeshTFaceList read FTFaceList;
    property CVertexList: TASEMeshCVertexList read FCVertexList;
    property CFaceList: TASEMeshCFaceList read FCFaceList;
    property TimeValue: Integer read FTimeValue;
    property NumVertex: Integer read FNumVertex;
    property NumFaces: Integer read FNumFaces;
    property NumTVertex: Integer read FNumTVertex;
    property NumCVertex: Integer read FNumCVertex;
  end;

type
  TASEGeomObject = class
  protected
    FNodeName: String;
    FNodeTM: TASENodeTM;
    FMesh: TASEMesh;
    FMotionBlur: Boolean;
    FCastShadow: Boolean;
    FRecvShadow: Boolean;
    FMaterialRef: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(source: TTokenStream);
    property NodeName: String read FNodeName;
    property NodeTM: TASENodeTM read FNodeTM;
    property Mesh: TASEMesh read FMesh;
    property MotionBlur: Boolean read FMotionBlur;
    property CastShadow: Boolean read FCastShadow;
    property RecvShadow: Boolean read FRecvShadow;
    property MaterialRef: Integer read FMaterialRef;
  end;

type
  TASEGroup = class
  protected
    FName: String;
    FGeomObjects: array of TASEGeomObject;
    function GetGeomObject(i: Integer): TASEGeomObject;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(source: TTokenStream);
    function NumGeomObjects: Integer;
    property Name: String read FName;
    property GeomObjects[i: Integer]: TASEGeomObject read GetGeomObject;
  end;

type
  TASEFile = class
  protected
    FHeader: TASEHeader;
    FComments: array of TASEComment;
    FScene: TASEScene;
    FMaterialList: TASEMaterialList;
    FGeomObjects: array of TASEGeomObject;
    FGroups: array of TASEGroup;
    function GetComment(i: Integer): TASEComment;
    function GetGeomObject(i: Integer): TASEGeomObject;
    function GetGroup(i: Integer): TASEGroup;
    procedure Parse(source: TTokenStream);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(filename: String);
    function NumComments: Integer;
    function NumGeomObjects: Integer;
    function NumGroups: Integer;
    property Header: TASEHeader read FHeader;
    property Comments[i: Integer]: TASEComment read GetComment;
    property Scene: TASEScene read FScene;
    property MaterialList: TASEMaterialList read FMaterialList;
    property GeomObjects[i: Integer]: TASEGeomObject read GetGeomObject; default;
    property Groups[i: Integer]: TASEGroup read GetGroup;
  end;

implementation

var
  StringToFloat: function(const S: string): Extended = nil;

function StrToFloat_sep(const S: string): Extended;
begin

  if Pos(',', S) > 0 then DecimalSeparator := ','
  else DecimalSeparator := '.';
  StringToFloat := StrToFloat;
  Result := StrToFloat(S);

end;

{*** TASEHeader ***************************************************************}

constructor TASEHeader.Create;
begin

  inherited Create;

  FVersion := '';

end;

procedure TASEHeader.Parse(source: TTokenStream);
begin

  FVersion := source.GetNextToken;

end;

{*** TASEComment **************************************************************}

constructor TASEComment.Create;
begin

  inherited Create;

  FText := '';

end;

procedure TASEComment.Parse(source: TTokenStream);
var
  t, c: String;
begin

  t := source.GetNextToken;
  c := '';
  if t[1] = '"' then
  begin
    c := c + Copy(t, 2, Length(t) - 1);
    t := source.GetNextToken;
    while t[Length(t)] <> '"' do
    begin
      if t = '' then raise Exception.Create('Unterminated string!');
      c := c + ' ' + t;
      t := source.GetNextToken;
    end;
    c := c + Copy(t, 1, Length(t) - 1);
  end
  else raise Exception.Create('Comment not in quotes? (Last token: "' + t + '")');

  FText := StripQuotes(c);

end;

{*** TASEScene ****************************************************************}

constructor TASEScene.Create;
begin

  inherited Create;

  FFilename := '';
  FFirstFrame := 0;
  FLastFrame := 0;
  FFps := 0;
  FTicksPerFrame := 0;
  FBackground := ASE_BLACK;
  FAmbient := ASE_BLACK;

end;

procedure TASEScene.Parse(source: TTokenStream);
var
  blevel: Integer;
  tok: String;
begin

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    if tok = '' then raise Exception.Create('Brackets do not match!');

    if SameText(tok, ASE_SCENE_FILENAME) then
    begin
      tok := source.GetNextToken;
      FFileName := tok;
      while tok[Length(tok)] <> '"' do
      begin
        tok := source.GetNextToken;
        FFilename := FFilename + ' ' + tok;
      end;
      FFilename := StripQuotes(FFilename);
    end
    else if SameText(tok, ASE_SCENE_FIRSTFRAME) then FFirstFrame := StrToInt(source.GetNextToken)
    else if SameText(tok, ASE_SCENE_LASTFRAME) then FLastFrame := StrToInt(source.GetNextToken)
    else if SameText(tok, ASE_SCENE_FRAMESPEED) then FFps := StrToInt(source.GetNextToken)
    else if SameText(tok, ASE_SCENE_TICKSPERFRAME) then FTicksPerFrame := StrToInt(source.GetNextToken)
    else if SameText(tok, ASE_SCENE_BACKGROUND_STATIC) then
    begin
      FBackground.R := StringToFloat(source.GetNextToken);
      FBackground.G := StringToFloat(source.GetNextToken);
      FBackground.B := StringToFloat(source.GetNextToken);
      FBackground.A := 1;
    end
    else if SameText(tok, ASE_SCENE_AMBIENT_STATIC) then
    begin
      FAmbient.R := StringToFloat(source.GetNextToken);
      FAmbient.G := StringToFloat(source.GetNextToken);
      FAmbient.B := StringToFloat(source.GetNextToken);
      FAmbient.A := 1;
    end;

    tok := source.GetNextToken;
  end;

  if source.BracketLevel <> blevel then raise Exception.Create('Brackets do not match!');

end;

{*** TASEMap ******************************************************************}

constructor TASEMap.Create;
begin

  inherited Create;

  FName := '';
  FClass := '';
  FSubNo := 0;
  FAmount := 0;
  FBitmap := '';
  FType := '';
  FUOffset := 0;
  FVOffset := 0;
  FUTiling := 0;
  FVTiling := 0;
  FUVWAngle := 0;
  FBlur := 0;
  FBlurOffset := 0;
  FNoiseAmt := 0;
  FNoiseSize := 0;
  FNoiseLevel := 0;
  FNoisePhase := 0;
  FBitmapFilter := '';

end;

procedure TASEMap.Parse(source: TTokenStream);
var
  blevel: Integer;
  tok: String;
begin

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    if SameText(tok, ASE_MAP_NAME) then
    begin
      tok := source.GetNextToken;
      FName := tok;
      while tok[Length(tok)] <> '"' do
      begin
        tok := source.GetNextToken;
        FName := FName + ' ' + tok;
      end;
      FName := StripQuotes(FName);
    end
    else if SameText(tok, ASE_MAP_CLASS) then
    begin
      tok := source.GetNextToken;
      FClass := tok;
      while tok[Length(tok)] <> '"' do
      begin
        tok := source.GetNextToken;
        FClass := FClass + ' ' + tok;
      end;
      FClass := StripQuotes(FClass);
    end
    else if SameText(tok, ASE_MAP_SUBNO) then FSubNo := StrToInt(source.GetNextToken)
    else if SameText(tok, ASE_MAP_AMOUNT) then FAmount := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MAP_BITMAP) then
    begin
      tok := source.GetNextToken;
      FBitmap := tok;
      while tok[Length(tok)] <> '"' do
      begin
        tok := source.GetNextToken;
        FBitmap := FBitmap + ' ' + tok;
      end;
      FBitmap := StripQuotes(FBitmap);
    end
    else if SameText(tok, ASE_MAP_TYPE) then FType := source.GetNextToken
    else if SameText(tok, ASE_MAP_UVW_U_OFFSET) then FUOffset := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MAP_UVW_V_OFFSET) then FVOffset := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MAP_UVW_U_TILING) then FUTiling := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MAP_UVW_V_TILING) then FVTiling := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MAP_UVW_ANGLE) then FUVWAngle := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MAP_UVW_BLUR) then FBlur := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MAP_UVW_BLUR_OFFSET) then FBlurOffset := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MAP_UVW_NOISE_AMT) then FNoiseAmt := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MAP_UVW_NOISE_SIZE) then FNoiseSize := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MAP_UVW_NOISE_LEVEL) then FNoiseLevel := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MAP_UVW_NOISE_PHASE) then FNoisePhase := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MAP_BITMAP_FILTER) then FBitmapFilter := source.GetNextToken;
    tok := source.GetNextToken;
  end;

  if source.BracketLevel <> blevel then raise Exception.Create('Brackets do not match!');

end;

{*** TASEMaterial *************************************************************}

constructor TASEMaterial.Create;
var
  i: TASEMapType;
begin

  inherited Create;

  FName := '';
  FClass := '';
  FAmbient := ASE_BLACK;
  FDiffuse := ASE_BLACK;
  FSpecular := ASE_BLACK;
  FShine := 0;
  FShineStrength := 0;
  FTransparency := 1;
  FWireSize := 1;
  FShading := '';
  FXPFalloff := 0;
  FSelfIllum := 0;
  FFalloff := '';
  FXPType := '';

  for i := Low(TASEMapType) to High(TASEMapType) do
  begin
    FMaps[i] := nil;
  end;

  SetLength(FSubMaterials, 0);
  FNumSubMaterials := 0;

end;

destructor TASEMaterial.Destroy;
var
  i: TASEMapType;
begin

  for i := Low(TASEMapType) to High(TASEMapType) do
  begin
    if Assigned(FMaps[i]) then FMaps[i].Free;
  end;

  inherited Destroy;

end;

function TASEMaterial.NumMaps: Integer;
var
  i: TASEMapType;
begin

  Result := 0;
  for i := Low(TASEMapType) to High(TASEMapType) do
  begin
    if FMaps[i] <> nil then INC(Result);
  end;

end;

function TASEMaterial.GetSubMaterial(i: Integer): TASEMaterial;
begin

  Result := FSubMaterials[i];

end;

function TASEMaterial.GetMap(i: TASEMapType): TASEMap;
begin

  Result := FMaps[i];

end;

procedure TASEMaterial.Parse(source: TTokenStream);
var
  blevel: Integer;
  tok: String;
begin

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    if SameText(tok, ASE_MATERIAL_NAME) then
    begin
      tok := source.GetNextToken;
      FName := tok;
      while tok[Length(tok)] <> '"' do
      begin
        tok := source.GetNextToken;
        FName := FName + ' ' + tok;
      end;
      FName := StripQuotes(FName);
    end
    else if SameText(tok, ASE_MATERIAL_CLASS) then
    begin
      tok := source.GetNextToken;
      FClass := tok;
      while tok[Length(tok)] <> '"' do
      begin
        tok := source.GetNextToken;
        FClass := FClass + ' ' + tok;
      end;
      FClass := StripQuotes(FClass);
    end
    else if SameText(tok, ASE_MATERIAL_AMBIENT) then
    begin
      with FAmbient do
      begin
        R := StringToFloat(source.GetNextToken);
        G := StringToFloat(source.GetNextToken);
        B := StringToFloat(source.GetNextToken);
      end;
    end
    else if SameText(tok, ASE_MATERIAL_DIFFUSE) then
    begin
      with FDiffuse do
      begin
        R := StringToFloat(source.GetNextToken);
        G := StringToFloat(source.GetNextToken);
        B := StringToFloat(source.GetNextToken);
      end;
    end
    else if SameText(tok, ASE_MATERIAL_SPECULAR) then
    begin
      with FSpecular do
      begin
        R := StringToFloat(source.GetNextToken);
        G := StringToFloat(source.GetNextToken);
        B := StringToFloat(source.GetNextToken);
      end;
    end
    else if SameText(tok, ASE_MATERIAL_SHINE) then FShine := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MATERIAL_SHINESTRENGTH) then FShineStrength := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MATERIAL_TRANSPARENCY) then FTransparency := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MATERIAL_WIRESIZE) then FWireSize := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MATERIAL_SHADING) then FShading := source.GetNextToken
    else if SameText(tok, ASE_MATERIAL_XP_FALLOFF) then FXPFalloff := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MATERIAL_SELFILLUM) then FSelfIllum := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_MATERIAL_FALLOFF) then FFalloff := source.GetNextToken
    else if SameText(tok, ASE_MATERIAL_XP_TYPE) then FXPType := source.GetNextToken
    else if SameText(tok, ASE_MATERIAL_MAP_AMBIENT) then
    begin
      FMaps[ASE_AMBIENT_MAP] := TASEMap.Create;
      FMaps[ASE_AMBIENT_MAP].Parse(source);
    end
    else if SameText(tok, ASE_MATERIAL_MAP_DIFFUSE) then
    begin
      FMaps[ASE_DIFFUSE_MAP] := TASEMap.Create;
      FMaps[ASE_DIFFUSE_MAP].Parse(source);
    end
    else if SameText(tok, ASE_MATERIAL_MAP_SPECULAR) then
    begin
      FMaps[ASE_SPECULAR_MAP] := TASEMap.Create;
      FMaps[ASE_SPECULAR_MAP].Parse(source);
    end
    else if SameText(tok, ASE_MATERIAL_MAP_SHINE) then
    begin
      FMaps[ASE_SHINE_MAP] := TASEMap.Create;
      FMaps[ASE_SHINE_MAP].Parse(source);
    end
    else if SameText(tok, ASE_MATERIAL_MAP_SHINESTRENGTH) then
    begin
      FMaps[ASE_SHINESTRENGTH_MAP] := TASEMap.Create;
      FMaps[ASE_SHINESTRENGTH_MAP].Parse(source);
    end
    else if SameText(tok, ASE_MATERIAL_MAP_SELFILLUM) then
    begin
      FMaps[ASE_SELFILLUM_MAP] := TASEMap.Create;
      FMaps[ASE_SELFILLUM_MAP].Parse(source);
    end
    else if SameText(tok, ASE_MATERIAL_MAP_OPACITY) then
    begin
      FMaps[ASE_OPACITY_MAP] := TASEMap.Create;
      FMaps[ASE_OPACITY_MAP].Parse(source);
    end
    else if SameText(tok, ASE_MATERIAL_MAP_FILTERCOLOR) then
    begin
      FMaps[ASE_FILTERCOLOR_MAP] := TASEMap.Create;
      FMaps[ASE_FILTERCOLOR_MAP].Parse(source);
    end
    else if SameText(tok, ASE_MATERIAL_MAP_BUMP) then
    begin
      FMaps[ASE_BUMP_MAP] := TASEMap.Create;
      FMaps[ASE_BUMP_MAP].Parse(source);
    end
    else if SameText(tok, ASE_MATERIAL_MAP_REFLECT) then
    begin
      FMaps[ASE_REFLECT_MAP] := TASEMap.Create;
      FMaps[ASE_REFLECT_MAP].Parse(source);
    end
    else if SameText(tok, ASE_MATERIAL_MAP_REFRACT) then
    begin
      FMaps[ASE_REFRACT_MAP] := TASEMap.Create;
      FMaps[ASE_REFRACT_MAP].Parse(source);
    end
    else if SameText(tok, ASE_MATERIAL_NUMSUBMTLS) then
    begin
      FNumSubMaterials := StrToInt(source.GetNextToken);
    end
    else if SameText(tok, ASE_MATERIAL_SUBMATERIAL) then
    begin
      source.GetNextToken; //TODO: Make sure skipping this is okay.
      SetLength(FSubMaterials, Length(FSubMaterials) + 1);
      FSubMaterials[High(FSubMaterials)] := TASEMaterial.Create;
      FSubMaterials[High(FSubMaterials)].Parse(source);
    end;
    tok := source.GetNextToken;
  end;

  if source.BracketLevel <> blevel then raise Exception.Create('Brackets do not match!');

end;

{*** TASEMaterialList *********************************************************}

constructor TASEMaterialList.Create;
begin

  inherited Create;

  SetLength(FMaterials, 0);

end;

destructor TASEMaterialList.Destroy;
var
  i: Integer;
begin

  for i := 0 to High(FMaterials) do FMaterials[i].Free;
  SetLength(FMaterials, 0);
  inherited Destroy;

end;

function TASEMaterialList.NumMaterials: Integer;
begin

  Result := Length(FMaterials);

end;

function TASEMaterialList.GetMaterial(i: Integer): TASEMaterial;
begin

  Result := FMaterials[i];

end;

procedure TASEMaterialList.Parse(source: TTokenStream);
var
  blevel: Integer;
  tok: String;
  i: Integer;
begin

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    if SameText(tok, ASE_MATERIAL) then
    begin
      i := StrToInt(source.GetNextToken);
      if i > High(FMaterials) then SetLength(FMaterials, i+1);
      FMaterials[i] := TASEMaterial.Create;
      FMaterials[i].Parse(source);
    end;
    tok := source.GetNextToken;
  end;

  if source.BracketLevel <> blevel then raise Exception.Create('Brackets do not match!');

end;

{*** TASENodeTM ***************************************************************}

constructor TASENodeTM.Create;
begin

  inherited Create;

  FNodeName := '';
  FInheritPos := ASE_ORIGIN;
  FInheritRot := ASE_ORIGIN;
  FInheritScale := ASE_ORIGIN;
  FMatrix := ASE_IDENTITY;
  FPosition := ASE_ORIGIN;
  FRotAxis := ASE_ORIGIN;
  FRotAngle := 0;
  FScale := ASE_ORIGIN;
  FScaleAxis := ASE_ORIGIN;
  FScaleAxisAngle := 0;

end;

procedure TASENodeTM.Parse(source: TTokenStream);
var
  blevel: Integer;
  tok: String;
begin

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    if SameText(tok, ASE_NODE_TM_NODE_NAME) then
    begin
      tok := source.GetNextToken;
      FNodeName := tok;
      while tok[Length(tok)] <> '"' do
      begin
        tok := source.GetNextToken;
        FNodeName := FNodeName + ' ' + tok;
      end;
      FNodeName := StripQuotes(FNodeName);
    end
    else if SameText(tok, ASE_NODE_TM_INHERIT_POS) then
    begin
      FInheritPos.X := StringToFloat(source.GetNextToken);
      FInheritPos.Y := StringToFloat(source.GetNextToken);
      FInheritPos.Z := StringToFloat(source.GetNextToken);
    end
    else if SameText(tok, ASE_NODE_TM_INHERIT_ROT) then
    begin
      FInheritRot.X := StringToFloat(source.GetNextToken);
      FInheritRot.Y := StringToFloat(source.GetNextToken);
      FInheritRot.Z := StringToFloat(source.GetNextToken);
    end
    else if SameText(tok, ASE_NODE_TM_INHERIT_SCL) then
    begin
      FInheritScale.X := StringToFloat(source.GetNextToken);
      FInheritScale.Y := StringToFloat(source.GetNextToken);
      FInheritScale.Z := StringToFloat(source.GetNextToken);
    end
    else if SameText(tok, ASE_NODE_TM_TM_ROW0) then
    begin
      FMatrix[0][0] := StringToFloat(source.GetNextToken);
      FMatrix[1][0] := StringToFloat(source.GetNextToken);
      FMatrix[2][0] := StringToFloat(source.GetNextToken);
      FMatrix[3][0] := 0;
    end
    else if SameText(tok, ASE_NODE_TM_TM_ROW1) then
    begin
      FMatrix[0][1] := StringToFloat(source.GetNextToken);
      FMatrix[1][1] := StringToFloat(source.GetNextToken);
      FMatrix[2][1] := StringToFloat(source.GetNextToken);
      FMatrix[3][1] := 0;
    end
    else if SameText(tok, ASE_NODE_TM_TM_ROW2) then
    begin
      FMatrix[0][2] := StringToFloat(source.GetNextToken);
      FMatrix[1][2] := StringToFloat(source.GetNextToken);
      FMatrix[2][2] := StringToFloat(source.GetNextToken);
      FMatrix[3][2] := 0;
    end
    else if SameText(tok, ASE_NODE_TM_TM_ROW3) then
    begin
      FMatrix[0][3] := StringToFloat(source.GetNextToken);
      FMatrix[1][3] := StringToFloat(source.GetNextToken);
      FMatrix[2][3] := StringToFloat(source.GetNextToken);
      FMatrix[3][3] := 1;
    end
    else if SameText(tok, ASE_NODE_TM_TM_POS) then
    begin
      FPosition.X := StringToFloat(source.GetNextToken);
      FPosition.Y := StringToFloat(source.GetNextToken);
      FPosition.Z := StringToFloat(source.GetNextToken);
    end
    else if SameText(tok, ASE_NODE_TM_TM_ROTAXIS) then
    begin
      FRotAxis.X := StringToFloat(source.GetNextToken);
      FRotAxis.Y := StringToFloat(source.GetNextToken);
      FRotAxis.Z := StringToFloat(source.GetNextToken);
    end
    else if SameText(tok, ASE_NODE_TM_TM_ROTANGLE) then FRotAngle := StringToFloat(source.GetNextToken)
    else if SameText(tok, ASE_NODE_TM_TM_SCALE) then
    begin
      FScale.X := StringToFloat(source.GetNextToken);
      FScale.Y := StringToFloat(source.GetNextToken);
      FScale.Z := StringToFloat(source.GetNextToken);
    end
    else if SameText(tok, ASE_NODE_TM_TM_SCALEAXIS) then
    begin
      FScaleAxis.X := StringToFloat(source.GetNextToken);
      FScaleAxis.Y := StringToFloat(source.GetNextToken);
      FScaleAxis.Z := StringToFloat(source.GetNextToken);
    end
    else if SameText(tok, ASE_NODE_TM_TM_SCALEAXISANG) then FScaleAxisAngle := StringToFloat(source.GetNextToken);
    tok := source.GetNextToken;
  end;

  if source.BracketLevel <> blevel then raise Exception.Create('Brackets do not match!');

end;

{*** TASEMeshVertexList *******************************************************}

constructor TASEMeshVertexList.Create;
begin

  inherited Create;

  SetLength(FVerts, 0);

end;

destructor TASEMeshVertexList.Destroy;
begin

  SetLength(FVerts, 0);

  inherited Destroy;

end;

function TASEMeshVertexList.GetVertex(i: Integer): TASEVector;
begin

  Result := FVerts[i];

end;

function TASEMeshVertexList.NumVertices: Integer;
begin

  Result := Length(FVerts);

end;

procedure TASEMeshVertexList.Parse(source: TTokenStream);
var
  blevel: Integer;
  tok: String;
  i: Integer;
  vx, vy, vz: Single;
begin

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    if SameText(tok, ASE_MESH_VERTEX) then
    begin
      i := StrToInt(source.GetNextToken);
      vx := StringToFloat(source.GetNextToken);
      vy := StringToFloat(source.GetNextToken);
      vz := StringToFloat(source.GetNextToken);
      if i > High(FVerts) then SetLength(FVerts, i+1);
      with FVerts[i] do
      begin
        X := vx;
        Y := vy;
        Z := vz;
      end;
    end
    else raise Exception.Create('Invalid token in vertex list! ("' + tok + '")');
    tok := source.GetNextToken;
  end;

  if source.BracketLevel <> blevel then raise Exception.Create('Brackets do not match!');

end;

{*** TASEMeshFaceList*********************************************************}

constructor TASEMeshFaceList.Create;
begin

  inherited Create;

  SetLength(FFaces, 0);

end;

destructor TASEMeshFaceList.Destroy;
begin

  SetLength(FFaces, 0);

  inherited Destroy;

end;

function TASEMeshFaceList.GetFace(i: Integer): TASEFace;
begin

  Result := FFaces[i];

end;

function TASEMeshFaceList.NumFaces: Integer;
begin

  Result := Length(FFaces);

end;

procedure TASEMeshFaceList.Parse(source: TTokenStream);
var
  blevel: Integer;
  tok: String;
  fi, fa, fb, fc, smoove, mtl: Integer;
  fab, fbc, fca: Boolean;
begin

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  fi := -1;

  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    if SameText(tok, ASE_MESH_FACE) then
    begin
      tok := source.GetNextToken;
      fi := StrToInt(Copy(tok, 1, Length(tok) - 1));

      tok := source.GetNextToken;
      fa := StrToInt(source.GetNextToken);
      tok := source.GetNextToken;
      fb := StrToInt(source.GetNextToken);
      tok := source.GetNextToken;
      fc := StrToInt(source.GetNextToken);

      tok := source.GetNextToken;
      fab := source.GetNextToken <> '0';
      tok := source.GetNextToken;
      fbc := source.GetNextToken <> '0';
      tok := source.GetNextToken;
      fca := source.GetNextToken <> '0';
      tok := source.GetNextToken;

      smoove := 0;
      mtl := 0;

      if fi > High(FFaces) then SetLength(FFaces, fi+1);
      with FFaces[fi] do
      begin
        A := fa;
        B := fb;
        C := fc;
        AB := fab;
        BC := fbc;
        CA := fca;
        Smoothing := smoove;
        MtlID := mtl;
      end;
    end
    else if SameText(tok, ASE_MESH_SMOOTHING) then
    begin
      smoove := StrToInt(source.GetNextToken);
      if fi < Length(FFaces) then FFaces[fi].Smoothing := smoove
      else raise Exception.Create('Misplaced *MESH_SMOOTHING tag?');
    end
    else if SameText(tok, ASE_MESH_MTLID) then
    begin
      mtl := StrToInt(source.GetNextToken);
      if fi < Length(FFaces) then FFaces[fi].MtlID := mtl
      else raise Exception.Create('Misplaced *MESH_MTLID tag?');
    end;
    tok := source.GetNextToken;
  end;

  if source.BracketLevel <> blevel then raise Exception.Create('Brackets do not match!');

end;

{*** TASEMeshNormals **********************************************************}

constructor TASEMeshNormals.Create;
begin

  inherited Create;

  SetLength(FFaceNormals, 0);
  SetLength(FVertexNormals, 0);

end;

destructor TASEMeshNormals.Destroy;
begin

  SetLength(FFaceNormals, 0);
  SetLength(FVertexNormals, 0);
  SetLength(FVNormalIndices, 0);

  inherited Destroy;

end;

function TASEMeshNormals.GetVertexNormal(i: Integer): TASEVector;
begin

  Result := FVertexNormals[i];

end;

function TASEMeshNormals.GetFaceNormal(i: Integer): TASEVector;
begin

  Result := FFaceNormals[i];

end;

function TASEMeshNormals.GetVNormalIndex(i: Integer): Cardinal;
begin

  Result := FVNormalIndices[i];

end;

function TASEMeshNormals.NumVertexNormals: Integer;
begin

  Result := Length(FVertexNormals);

end;

function TASEMeshNormals.NumFaceNormals: Integer;
begin

  Result := Length(FFaceNormals);

end;

procedure TASEMeshNormals.Parse(source: TTokenStream);
var
  blevel: Integer;
  tok: String;
  ni: Integer;
  nx, ny, nz: Single;
begin

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    if SameText(tok, ASE_MESH_FACENORMAL) then
    begin
      ni := StrToInt(source.GetNextToken);
      nx := StringToFloat(source.GetNextToken);
      ny := StringToFloat(source.GetNextToken);
      nz := StringToFloat(source.GetNextToken);
      if ni > High(FFaceNormals) then SetLength(FFaceNormals, ni+1);
      with FFaceNormals[ni] do
      begin
        X := nx;
        Y := ny;
        Z := nz;
      end;
    end
    else if SameText(tok, ASE_MESH_VERTEXNORMAL) then
    begin
      SetLength(FVertexNormals, Length(FVertexNormals) + 1);
      SetLength(FVNormalIndices, Length(FVNormalIndices) + 1);
      
      ni := StrToInt(source.GetNextToken);
      FVNormalIndices[High(FVNormalIndices)] := ni;
      
      nx := StringToFloat(source.GetNextToken);
      ny := StringToFloat(source.GetNextToken);
      nz := StringToFloat(source.GetNextToken);
      with FVertexNormals[High(FVertexNormals)] do
      begin
        X := nx;
        Y := ny;
        Z := nz;
      end;
    end;
    tok := source.GetNextToken;
  end;

  if source.BracketLevel <> blevel then raise Exception.Create('Brackets do not match!');

end;

{*** TASEMeshTVertexList ******************************************************}

constructor TASEMeshTVertexList.Create;
begin

  inherited Create;

  SetLength(FTVerts, 0);

end;

destructor TASEMeshTVertexList.Destroy;
begin

  SetLength(FTVerts, 0);

  inherited Destroy;

end;

function TASEMeshTVertexList.NumTVertices: Integer;
begin

  Result := Length(FTVerts);

end;

function TASEMeshTVertexList.GetTVertex(i: Integer): TASETVertex;
begin

  Result := FTVerts[i];

end;

procedure TASEMeshTVertexList.Parse(source: TTokenStream);
var
  blevel: Integer;
  tok: String;
  i: Integer;
  tu, tv, tw: Single;
begin

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    if SameText(tok, ASE_MESH_TVERT) then
    begin
      i := StrToInt(source.GetNextToken);
      tu := StringToFloat(source.GetNextToken);
      tv := StringToFloat(source.GetNextToken);
      tw := StringToFloat(source.GetNextToken);
      if i > High(FTVerts) then SetLength(FTVerts, i+1);
      with FTVerts[i] do
      begin
        U := tu;
        V := tv;
        W := tw;
      end;
    end
    else raise Exception.Create('Invalid token in tvertex list! ("' + tok + '")');
    tok := source.GetNextToken;
  end;

  if source.BracketLevel <> blevel then raise Exception.Create('Brackets do not match!');

end;

{*** TASEMeshCVertexList ******************************************************}

constructor TASEMeshCVertexList.Create;
begin

  inherited Create;

  SetLength(FCVerts, 0);

end;

destructor TASEMeshCVertexList.Destroy;
begin

  SetLength(FCVerts, 0);

  inherited Destroy;

end;

function TASEMeshCVertexList.NumCVertices: Integer;
begin

  Result := Length(FCVerts);

end;

function TASEMeshCVertexList.GetCVertex(i: Integer): TASEColor;
begin

  Result := FCVerts[i];

end;

procedure TASEMeshCVertexList.Parse(source: TTokenStream);
var
  blevel: Integer;
  tok: String;
  i: Integer;
  cr, cg, cb: Single;
begin

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    if SameText(tok, ASE_MESH_VERTCOL) then
    begin
      i := StrToInt(source.GetNextToken);
      cr := StringToFloat(source.GetNextToken);
      cg := StringToFloat(source.GetNextToken);
      cb := StringToFloat(source.GetNextToken);
      if i > High(FCVerts) then SetLength(FCVerts, i+1);
      with FCVerts[i] do
      begin
        R := cr;
        G := cg;
        B := cb;
      end;
    end
    else raise Exception.Create('Invalid token in cvertex list! ("' + tok + '")');
    tok := source.GetNextToken;
  end;

  if source.BracketLevel <> blevel then raise Exception.Create('Brackets do not match!');

end;

{*** TASEMeshTFaceList ********************************************************}

constructor TASEMeshTFaceList.Create;
begin

  inherited Create;

  SetLength(FTFaces, 0);

end;

destructor TASEMeshTFaceList.Destroy;
begin

  SetLength(FTFaces, 0);

  inherited Destroy;

end;

function TASEMeshTFaceList.NumTFaces: Integer;
begin

  Result := Length(FTFaces);

end;

function TASEMeshTFaceList.GetTFace(i: Integer): TASEFaceRef;
begin

  Result := FTFaces[i];

end;

procedure TASEMeshTFaceList.Parse(source: TTokenStream);
var
  blevel: Integer;
  tok: String;
  i: Integer;
  fa, fb, fc: Integer;
begin

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    if SameText(tok, ASE_MESH_TFACE) then
    begin
      i := StrToInt(source.GetNextToken);
      fa := StrToInt(source.GetNextToken);
      fb := StrToInt(source.GetNextToken);
      fc := StrToInt(source.GetNextToken);
      if i > High(FTFaces) then SetLength(FTFaces, i+1);
      with FTFaces[i] do
      begin
        A := fa;
        B := fb;
        C := fc;
      end;
    end
    else raise Exception.Create('Invalid token in tface list! ("' + tok + '")');
    tok := source.GetNextToken;
  end;

  if source.BracketLevel <> blevel then raise Exception.Create('Brackets do not match!');

end;

{*** TASEMeshCFaceList ********************************************************}

constructor TASEMeshCFaceList.Create;
begin

  inherited Create;

  SetLength(FCFaces, 0);

end;

destructor TASEMeshCFaceList.Destroy;
begin

  SetLength(FCFaces, 0);

  inherited Destroy;

end;

function TASEMeshCFaceList.NumCFaces: Integer;
begin

  Result := Length(FCFaces);

end;

function TASEMeshCFaceList.GetCFace(i: Integer): TASEFaceRef;
begin

  Result := FCFaces[i];

end;

procedure TASEMeshCFaceList.Parse(source: TTokenStream);
var
  blevel: Integer;
  tok: String;
  i: Integer;
  fa, fb, fc: Integer;
begin

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    if SameText(tok, ASE_MESH_CFACE) then
    begin
      i := StrToInt(source.GetNextToken);
      fa := StrToInt(source.GetNextToken);
      fb := StrToInt(source.GetNextToken);
      fc := StrToInt(source.GetNextToken);
      if i > High(FCFaces) then SetLength(FCFaces, i+1);
      with FCFaces[i] do
      begin
        A := fa;
        B := fb;
        C := fc;
      end;
    end
    else raise Exception.Create('Invalid token in cface list! ("' + tok + '")');
    tok := source.GetNextToken;
  end;

  if source.BracketLevel <> blevel then raise Exception.Create('Brackets do not match!');

end;

{*** TASEMesh *****************************************************************}

constructor TASEMesh.Create;
begin

  inherited Create;

  FVertexList := nil;
  FFaceList := nil;
  FNormals := nil;
  FTVertexList := nil;
  FCVertexList := nil;
  FTFaceList := nil;
  FCFaceList := nil;
  FTimeValue := 0;
  FNumVertex := 0;
  FNumFaces := 0;
  FNumTVertex := 0;
  FNumCVertex := 0;

end;

destructor TASEMesh.Destroy;
begin

  if Assigned(FVertexList) then FVertexList.Free;
  if Assigned(FFaceList) then FFaceList.Free;
  if Assigned(FNormals) then FNormals.Free;
  if Assigned(FTVertexList) then FTVertexList.Free;
  if Assigned(FCVertexList) then FCVertexList.Free;
  if Assigned(FTFaceList) then FTFaceList.Free;
  if Assigned(FCFaceList) then FCFaceList.Free;

  inherited Destroy;

end;

procedure TASEMesh.Parse(source: TTokenStream);
var
  blevel: Integer;
  tok: String;
begin

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    if SameText(tok, ASE_MESH_TIMEVALUE) then FTimeValue := StrToInt(source.GetNextToken)
    else if SameText(tok, ASE_MESH_NUMVERTEX) then FNumVertex := StrToInt(source.GetNextToken)
    else if SameText(tok, ASE_MESH_NUMFACES) then FNumFaces := StrToInt(source.GetNextToken)
    else if SameText(tok, ASE_MESH_VERTEX_LIST) then
    begin
      FVertexList := TASEMeshVertexList.Create;
      FVertexList.Parse(source);
    end
    else if SameText(tok, ASE_MESH_FACE_LIST) then
    begin
      FFaceList := TASEMeshFaceList.Create;
      FFaceList.Parse(source);
    end
    else if SameText(tok, ASE_MESH_TVERTLIST) then
    begin
      FTVertexList := TASEMeshTVertexList.Create;
      FTVertexList.Parse(source);
    end
    else if SameText(tok, ASE_MESH_CVERTLIST) then
    begin
      FCVertexList := TASEMeshCVertexList.Create;
      FCVertexList.Parse(source);
    end
    else if SameText(tok, ASE_MESH_TFACELIST) then
    begin
      FTFaceList := TASEMeshTFaceList.Create;
      FTFaceList.Parse(source);
    end
    else if SameText(tok, ASE_MESH_CFACELIST) then
    begin
      FCFaceList := TASEMeshCFaceList.Create;
      FCFaceList.Parse(source);
    end
    else if SameText(tok, ASE_MESH_NUMTVERTEX) then FNumTVertex := StrToInt(source.GetNextToken)
    else if SameText(tok, ASE_MESH_NUMCVERTEX) then FNumCVertex := StrToInt(source.GetNextToken)
    else if SameText(tok, ASE_MESH_NORMALS) then
    begin
      FNormals := TASEMeshNormals.Create;
      FNormals.Parse(source);
    end;
    tok := source.GetNextToken;
  end;

  if source.BracketLevel <> blevel then raise Exception.Create('Brackets do not match!');

end;

{*** TASEGeomObject ***********************************************************}

constructor TASEGeomObject.Create;
begin

  inherited Create;

  FNodeName := '';
  FNodeTM := nil;
  FMesh := nil;
  FMotionBlur := FALSE;
  FCastShadow := FALSE;
  FRecvShadow := FALSE;
  FMaterialRef := 0;

end;

destructor TASEGeomObject.Destroy;
begin

  if Assigned(FMesh) then FMesh.Free;

  inherited Destroy;

end;

procedure TASEGeomObject.Parse(source: TTokenStream);
var
  blevel: Integer;
  tok: String;
begin

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    if SameText(tok, ASE_GEOMOBJECT_NODE_NAME) then
    begin
      tok := source.GetNextToken;
      FNodeName := tok;
      while tok[Length(tok)] <> '"' do
      begin
        tok := source.GetNextToken;
        FNodeName := FNodeName + ' ' + tok;
      end;
      FNodeName := StripQuotes(FNodeName);
    end
    else if SameText(tok, ASE_GEOMOBJECT_NODE_TM) then
    begin
      FNodeTM := TASENodeTM.Create;
      FNodeTM.Parse(source);
    end
    else if SameText(tok, ASE_GEOMOBJECT_MESH) then
    begin
      FMesh := TASEMesh.Create;
      FMesh.Parse(source);
    end
    else if SameText(tok, ASE_GEOMOBJECT_PROP_MOTIONBLUR) then
    begin
      tok := source.GetNextToken;
      FMotionBlur := (tok <> '0');
    end
    else if SameText(tok, ASE_GEOMOBJECT_PROP_CASTSHADOW) then
    begin
      tok := source.GetNextToken;
      FCastShadow := (tok <> '0');
    end
    else if SameText(tok, ASE_GEOMOBJECT_PROP_RECVSHADOW) then
    begin
      tok := source.GetNextToken;
      FRecvShadow := (tok <> '0');
    end
    else if SameText(tok, ASE_GEOMOBJECT_MATERIAL_REF) then FMaterialRef := StrToInt(source.GetNextToken);
    tok := source.GetNextToken;
  end;

  if source.BracketLevel <> blevel then raise Exception.Create('Brackets do not match!');

end;

{*** TASEGroup ****************************************************************}

function TASEGroup.GetGeomObject(i: Integer): TASEGeomObject;
begin

  Result := FGeomObjects[i];

end;

constructor TASEGroup.Create;
begin

  inherited Create;

  FName := '';
  SetLength(FGeomObjects, 0);

end;

destructor TASEGroup.Destroy;
var
  i: Integer;
begin

  for i := 0 to High(FGeomObjects) do FGeomObjects[i].Free;
  SetLength(FGeomObjects, 0);

  inherited Destroy;

end;

function TASEGroup.NumGeomObjects: Integer;
begin

  Result := Length(FGeomObjects);

end;

procedure TASEGroup.Parse(source: TTokenStream);
var
  tok, n: String;
  blevel: Integer;
begin

  tok := source.GetNextToken;
  n := '';

  n := n + Copy(tok, 2, Length(tok) - 1);
  while tok[Length(tok)] <> '"' do
  begin
    if tok = '' then raise Exception.Create('Unterminated string!');

    n := n + ' ' + tok;
    tok := source.GetNextToken;
    n := n + Copy(tok, 1, Length(tok) - 1);
  end;

  FName := StripQuotes(n);

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    if SameText(tok, ASE_GEOMOBJECT) then
    begin
      SetLength(FGeomObjects, Length(FGeomObjects) + 1);
      FGeomObjects[High(FGeomObjects)] := TASEGeomObject.Create;
      FGeomObjects[High(FGeomObjects)].Parse(source);
    end;
    tok := source.GetNextToken;
  end;

end;

{*** TASEUnknownElement *******************************************************}

constructor TASEUnknownElement.Create;
begin

  inherited Create;

  FText := '';

end;

procedure TASEUnknownElement.Parse(source: TTokenStream);
var
  tok: String;
  blevel: Integer;
begin

  blevel := source.BracketLevel;

  tok := source.GetNextToken;
  if tok <> '{' then raise Exception.Create('Can''t deal with this! (Token: "' + tok + '")');

  FText := '';
  tok := source.GetNextToken;
  while source.BracketLevel > blevel do
  begin
    FText := FText + ' ' + tok;
    tok := source.GetNextToken;
    if tok = '' then raise Exception.Create('Brackets do not match!');
  end;

  Self.Free;

end;

{*** TASEFile *****************************************************************}

constructor TASEFile.Create;
begin

  inherited Create;

  FHeader := nil;
  SetLength(FComments, 0);
  FScene := nil;
  SetLength(FGeomObjects, 0);
  SetLength(FGroups, 0);

end;

destructor TASEFile.Destroy;
var
  i: Integer;
begin

  if Assigned(FHeader) then FHeader.Free;
  for i := 0 to High(FComments) do FComments[i].Free;
  SetLength(FComments, 0);
  if Assigned(FScene) then FScene.Free;
  for i := 0 to High(FGeomObjects) do FGeomObjects[i].Free;
  SetLength(FGeomObjects, 0);
  for i := 0 to High(FGroups) do FGroups[i].Free;
  SetLength(FGroups, 0);

  inherited Destroy;

end;

function TASEFile.GetComment(i: Integer): TASEComment;
begin

  Result := FComments[i];

end;

function TASEFile.GetGeomObject(i: Integer): TASEGeomObject;
begin

  Result := FGeomObjects[i]

end;

function TASEFile.GetGroup(i: Integer): TASEGroup;
begin

  Result := FGroups[i]

end;

function TASEFile.NumComments: Integer;
begin

  Result := Length(FComments);

end;

function TASEFile.NumGeomObjects: Integer;
begin

  Result := Length(FGeomObjects);

end;

function TASEFile.NumGroups: Integer;
begin

  Result := Length(FGroups);

end;

procedure TASEFile.Parse(source: TTokenStream);
var
  tok: String;
begin

  tok := source.GetNextToken;
  while tok <> '' do
  begin
    if SameText(tok, ASE_MAGIC) then
    begin
      FHeader := TASEHeader.Create;
      FHeader.Parse(source);
    end
    else if SameText(tok, ASE_COMMENT) then
    begin
      SetLength(FComments, Length(FComments) + 1);
      FComments[High(FComments)] := TASEComment.Create;
      FComments[High(FComments)].Parse(source);
    end
    else if SameText(tok, ASE_SCENE) then
    begin
      FScene := TASEScene.Create;
      FScene.Parse(source);
    end
    else if SameText(tok, ASE_MATERIAL_LIST) then
    begin
      FMaterialList := TASEMaterialList.Create;
      FMaterialList.Parse(source);
    end
    else if SameText(tok, ASE_GEOMOBJECT) then
    begin
      SetLength(FGeomObjects, Length(FGeomObjects) + 1);
      FGeomObjects[High(FGeomObjects)] := TASEGeomObject.Create;
      FGeomObjects[High(FGeomObjects)].Parse(source);
    end
    else if SameText(tok, ASE_GROUP) then
    begin
      SetLength(FGroups, Length(FGroups) + 1);
      FGroups[High(FGroups)] := TASEGroup.Create;
      FGroups[High(FGroups)].Parse(source);
    end;
    tok := source.GetNextToken;
  end;

end;

procedure TASEFile.LoadFromFile(filename: String);
var
  ts: TTokenStream;
begin

  ts := TTokenStream.Create(filename);
  Parse(ts);
  ts.Free;

end;

initialization

  StringToFloat := StrToFloat_sep;

end.
