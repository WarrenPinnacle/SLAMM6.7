unit OBJ2;

interface

uses
  Classes, SysUtils, ASE;

// OBJ file line tags.
const
  OBJ_TAG_VERTEX            = 'v';
  OBJ_TAG_TEXCOORD          = 'vt';
  OBJ_TAG_NORMAL            = 'vn';
  OBJ_TAG_GROUP             = 'g';
  OBJ_TAG_FACE              = 'f';
  OBJ_TAG_MATERIAL          = 'usemtl';
  OBJ_TAG_MATERIALLIB       = 'mtllib';
  OBJ_TAG_COMMENT           = '#';

// OBJ file data structures.
type
  TOBJVertex = record
    x, y, z, w: Single;
  end;
  TOBJTexVertex = record
    u, v, w: Single;
  end;
  TOBJNormal = record
    x, y, z: Single;
  end;
  TOBJFatVertex = record
    v, vt, vn: Integer;
  end;
  TOBJFace = record
    vertices: array of TOBJFatVertex;
    usemtl: ShortString;
  end;
  TOBJGroup = record
    name: ShortString;
    faces: array of TOBJFace;
    numfaces: Integer;
  end;

// MTL file line tags.
const
  OBJ_TAG_MTL_NEW_MATERIAL  = 'newmtl';
  OBJ_TAG_MTL_AMBIENT       = 'Ka';
  OBJ_TAG_MTL_DIFFUSE       = 'Kd';
  OBJ_TAG_MTL_SPECULAR      = 'Ks';
  OBJ_TAG_MTL_ILLUM         = 'illum';
  OBJ_TAG_MTL_SHININESS     = 'Ns';
  OBJ_TAG_MTL_MAP_Ka        = 'map_Ka';
  OBJ_TAG_MTL_MAP_Kd        = 'map_Kd';
  OBJ_TAG_MTL_MAP_Ks        = 'map_Ks';
  OBJ_TAG_MTL_MAP_Bump      = 'map_Bump';
  OBJ_TAG_MTL_MAP_d         = 'map_d';
  OBJ_TAG_MTL_DISSOLVE      = 'd';
  OBJ_TAG_MTL_REFRACTION    = 'Ni';

// MTL file lighting modes.
const
  OBJ_MTL_NO_LIGHTING       = 0;
  OBJ_MTL_NO_SPECULAR       = 1;
  OBJ_MTL_FULL_LIGHTING     = 2; 

// MTL file data structures.
type
  TOBJColor = record
    r, g, b, a: Single;
  end;
  TOBJMaterial = record
    name: ShortString;
    Ka, Kd, Ks: TOBJColor;
    illum: Integer;
    Ns: Single;
    map_Ka, map_Kd, map_Ks, map_Bump, map_d: ShortString;
    d: Single;
    Ni: Single;
  end;

const
  OBJ_DEFAULT_MATERIAL: TOBJMaterial = (
      name: '';
      Ka: ( r: 0; g: 0; b: 0; a: 1; );
      Kd: ( r: 1; g: 1; b: 1; a: 1; );
      Ks: ( r: 0; g: 0; b: 0; a: 1; );
      illum: 0;
      Ns: 0;
      map_Ka: '';
      map_Kd: '';
      map_Ks: '';
      map_Bump: '';
      map_d: '';
      d: 1;
      Ni: 1;
    );

type
  TOBJMaterialLib = class
  protected
    FName: ShortString;
    FMaterials: array of TOBJMaterial;
    function GetMtl(i: Integer): TOBJMaterial;
    function GetNumMtls: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const filename: ShortString);
    property Name: ShortString read FName;
    function GetMaterial(const name: ShortString; var m: TOBJMaterial): Boolean;
    property Materials[i: Integer]: TOBJMaterial read GetMtl;
    property NumMaterials: Integer read GetNumMtls;
  end;

  TOBJModel = class
  protected
    FVertices: array of TOBJVertex;          FNumVertices: Integer;
    FTexVertices: array of TOBJTexVertex;    FNumTexVertices: Integer;
    FNormals: array of TOBJNormal;           FNumNormals: Integer;
    FGroups: array of TOBJGroup;
    FCurrentMaterial: ShortString;
    FMaterialLibs: array of TOBJMaterialLib;
    function GetVertex(i: Integer): TOBJVertex;
    function GetTexVertex(i: Integer): TOBJTexVertex;
    function GetNormal(i: Integer): TOBJNormal;
    function GetGroup(i: Integer): TOBJGroup;
    function GetMtlLib(i: Integer): TOBJMaterialLib;
    function GetNumVertices: Integer;
    function GetNumTexVertices: Integer;
    function GetNumNormals: Integer;
    function GetNumGroups: Integer;
    function GetNumMtlLibs: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const filename: ShortString);
    procedure LoadMtlLib(const name: ShortString);
    function GetMaterial(const name: ShortString; var m: TOBJMaterial): Boolean;
    property Vertices[i: Integer]: TOBJVertex read GetVertex;
    property TexVertices[i: Integer]: TOBJTexVertex read GetTexVertex;
    property Normals[i: Integer]: TOBJNormal read GetNormal;
    property Groups[i: Integer]: TOBJGroup read GetGroup;
    property MtlLibs[i: Integer]: TOBJMaterialLib read GetMtlLib;
    property NumVertices: Integer read GetNumVertices;
    property NumTexVertices: Integer read GetNumTexVertices;
    property NumNormals: Integer read GetNumNormals;
    property NumGroups: Integer read GetNumGroups;
    property NumMtlLibs: Integer read GetNumMtlLibs;
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

type
  TCharSet = set of Char;

function GetToken(var InTxt : ShortString; const delimiters: TCharSet = [' ', #9, #10, #13]): ShortString;
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

function objStringToColor(const str: ShortString): TOBJColor;
var
  tstr, tok: ShortString;
const
  DEFAULT: TOBJColor = ( r: 0; g: 0; b: 0; a: 1; );
begin

  Result := DEFAULT;

  tstr := str;

  tok := GetToken(tstr);
  if tok <> '' then Result.r := StringToFloat(tok);

  tok := GetToken(tstr);
  if tok <> '' then Result.g := StringToFloat(tok);

  tok := GetToken(tstr);
  if tok <> '' then Result.b := StringToFloat(tok);

  tok := GetToken(tstr);
  if tok <> '' then Result.a := StringToFloat(tok);

end;

function objStringToVertex(const str: ShortString): TOBJVertex;
var
  tstr, tok: ShortString;
const
  DEFAULT: TOBJVertex = ( x: 0; y: 0; z: 0; w: 1; );
begin

  Result := DEFAULT;

  tstr := str;

  tok := GetToken(tstr);
  if tok <> '' then Result.x := StringToFloat(tok);

  tok := GetToken(tstr);
  if tok <> '' then Result.y := StringToFloat(tok);

  tok := GetToken(tstr);
  if tok <> '' then Result.z := StringToFloat(tok);

  tok := GetToken(tstr);
  if tok <> '' then Result.w := StringToFloat(tok);

end;

function objStringToTexVertex(const str: ShortString): TOBJTexVertex;
var
  tstr, tok: ShortString;
const
  DEFAULT: TOBJTexVertex = ( u: 0; v: 0; w: 1; );
begin

  Result := DEFAULT;

  tstr := str;

  tok := GetToken(tstr);
  if tok <> '' then Result.u := StringToFloat(tok);

  tok := GetToken(tstr);
  if tok <> '' then Result.v := StringToFloat(tok);

  tok := GetToken(tstr);
  if tok <> '' then Result.w := StringToFloat(tok);

end;

function objStringToNormal(const str: ShortString): TOBJNormal;
var
  tstr, tok: ShortString;
const
  DEFAULT: TOBJNormal = ( x: 0; y: 0; z: 0; );
begin

  Result := DEFAULT;

  tstr := str;

  tok := GetToken(tstr);
  if tok <> '' then Result.x := StringToFloat(tok);

  tok := GetToken(tstr);
  if tok <> '' then Result.y := StringToFloat(tok);

  tok := GetToken(tstr);
  if tok <> '' then Result.z := StringToFloat(tok);

end;

function objStringToFatVertex(const str: ShortString): TOBJFatVertex;
var
  tstr, tok: ShortString;
  indices: array [0..2] of Integer;
  i: Integer;
  slash: Integer;
const
  DEFAULT: TOBJFatVertex = ( v: -1; vt: -1; vn: -1; );
begin

  Result := DEFAULT;

  indices[0] := -1;
  indices[1] := -1;
  indices[2] := -1;
  i := 0;

  tstr := str;

  while Length(tstr) > 0 do
  begin
    slash := Pos('/', tstr);
    if slash = 0 then slash := Length(tstr)+1;

    tok := Copy(tstr, 1, slash-1);
    INC(i);
    if tok <> '' then indices[i-1] := StrToInt(tok)
    else indices[i-1] := -1;
    Delete(tstr, 1, slash);
  end;

  if i = 1 then Result.v := indices[0]
  else if i = 2 then
  begin
    Result.v := indices[0];
    Result.vt := indices[1];
  end
  else begin
    Result.v := indices[0];
    Result.vt := indices[1];
    Result.vn := indices[2];
  end;

end;

{*** TOBJMaterialLib **********************************************************}

function TOBJMaterialLib.GetMtl(i: Integer): TOBJMaterial;
begin

  Result := FMaterials[i];

end;

function TOBJMaterialLib.GetNumMtls: Integer;
begin

  Result := Length(FMaterials);

end;

constructor TOBJMaterialLib.Create;
begin

  inherited Create;

  FName := '';
  SetLength(FMaterials, 0);

end;

destructor TOBJMaterialLib.Destroy;
begin

  SetLength(FMaterials, 0);

  inherited Destroy;

end;

procedure TOBJMaterialLib.LoadFromFile(const filename: ShortString);
var
  f: TStringList;
  i: Integer;
  line: ShortString;
  tok: ShortString;
begin

  FName := filename;
  SetLength(FMaterials, 0);

  if not FileExists(filename) then Exit;

  f := TStringList.Create;
  f.LoadFromFile(filename);

  for i := 0 to f.Count - 1 do
  begin
    line := Trim(f[i]);
    // Skip empty lines.
    if line = '' then Continue;

    tok := GetToken(line);
    // Skip comment lines.
    if tok = OBJ_TAG_COMMENT then Continue;

    // Data line found: parse it.
    if tok = OBJ_TAG_MTL_NEW_MATERIAL then
    begin
      SetLength(FMaterials, Length(FMaterials) + 1);
      FMaterials[High(FMaterials)] := OBJ_DEFAULT_MATERIAL;
      FMaterials[High(FMaterials)].name := line;
    end
    else if tok = OBJ_TAG_MTL_AMBIENT then
    begin
      with FMaterials[High(FMaterials)] do
      begin
        Ka := objStringToColor(line);
      end;
    end
    else if tok = OBJ_TAG_MTL_DIFFUSE then
    begin
      with FMaterials[High(FMaterials)] do
      begin
        Kd := objStringToColor(line);
      end;
    end
    else if tok = OBJ_TAG_MTL_SPECULAR then
    begin
      with FMaterials[High(FMaterials)] do
      begin
        Ks := objStringToColor(line);
      end;
    end
    else if tok = OBJ_TAG_MTL_ILLUM then
    begin
      with FMaterials[High(FMaterials)] do
      begin
        illum := StrToInt(line);
      end;
    end
    else if tok = OBJ_TAG_MTL_SHININESS then
    begin
      with FMaterials[High(FMaterials)] do
      begin
        Ns := StringToFloat(line);
      end;
    end
    else if tok = OBJ_TAG_MTL_MAP_Ka then
    begin
      with FMaterials[High(FMaterials)] do
      begin
        map_Ka := line;
      end;
    end
    else if tok = OBJ_TAG_MTL_MAP_Kd then
    begin
      with FMaterials[High(FMaterials)] do
      begin
        map_Kd := line;
      end;
    end
    else if tok = OBJ_TAG_MTL_MAP_Ks then
    begin
      with FMaterials[High(FMaterials)] do
      begin
        map_Ks := line;
      end;
    end
    else if tok = OBJ_TAG_MTL_MAP_Bump then
    begin
      with FMaterials[High(FMaterials)] do
      begin
        map_Bump := line;
      end;
    end
    else if tok = OBJ_TAG_MTL_MAP_d then
    begin
      with FMaterials[High(FMaterials)] do
      begin
        map_d := line;
      end;
    end
    else if tok = OBJ_TAG_MTL_DISSOLVE then
    begin
      with FMaterials[High(FMaterials)] do
      begin
        d := StringToFloat(line);
      end;
    end
    else if tok = OBJ_TAG_MTL_REFRACTION then
    begin
      with FMaterials[High(FMaterials)] do
      begin
        Ni := StringToFloat(line);
      end;
    end;
  end;

  f.Free;

end;

function TOBJMaterialLib.GetMaterial(const name: ShortString; var m: TOBJMaterial): Boolean;
var
  i: Integer;
begin

  for i := 0 to High(FMaterials) do
  begin
    if SameText(FMaterials[i].name, name) then
    begin
      Result := TRUE;
      m := FMaterials[i];
      Exit;
    end;
  end;

  Result := FALSE;

end;

{*** TOBJModel ****************************************************************}

function TOBJModel.GetVertex(i: Integer): TOBJVertex;
begin

  Result := FVertices[i-1];

end;

function TOBJModel.GetTexVertex(i: Integer): TOBJTexVertex;
begin

  Result := FTexVertices[i-1];

end;

function TOBJModel.GetNormal(i: Integer): TOBJNormal;
begin

  Result := FNormals[i-1];

end;

function TOBJModel.GetGroup(i: Integer): TOBJGroup;
begin

  Result := FGroups[i];

end;

function TOBJModel.GetMtlLib(i: Integer): TOBJMaterialLib;
begin

  Result := FMaterialLibs[i];

end;

function TOBJModel.GetNumVertices: Integer;
begin

  Result := Length(FVertices);

end;

function TOBJModel.GetNumTexVertices: Integer;
begin

  Result := Length(FTexVertices);

end;

function TOBJModel.GetNumNormals: Integer;
begin

  Result := Length(FNormals);

end;

function TOBJModel.GetNumGroups: Integer;
begin

  Result := Length(FGroups);

end;

function TOBJModel.GetNumMtlLibs: Integer;
begin

  Result := Length(FMaterialLibs);

end;

constructor TOBJModel.Create;
begin

  inherited Create;

  SetLength(FVertices, 0);
  SetLength(FTexVertices, 0);
  SetLength(FNormals, 0);
  SetLength(FGroups, 0);
  FCurrentMaterial := '';
  SetLength(FMaterialLibs, 0);

end;

destructor TOBJModel.Destroy;
var
  i: Integer;
begin

  SetLength(FVertices, 0);
  SetLength(FTexVertices, 0);
  SetLength(FNormals, 0);
  SetLength(FGroups, 0);
  for i := 0 to High(FMaterialLibs) do FMaterialLibs[i].Free;
  SetLength(FMaterialLibs, 0);

  inherited Destroy;

end;

procedure TOBJModel.LoadFromFile(const filename: ShortString);
var
  f: TStringList;
  i: Integer;
  name, line, tok, wkdir: ShortString;
begin

  wkdir := GetCurrentDir;
  SetCurrentDir(ExtractFilePath(filename));
  name := ExtractFileName(filename);

  f := TStringList.Create;
  f.LoadFromFile(name);

  LoadMtlLib(ChangeFileExt(name, '.mtl'));

  for i := 0 to f.Count - 1 do
  begin
    line := Trim(f[i]);
    // Skip empty lines.
    if line = '' then Continue;

    tok := GetToken(line);
    // Skip comment lines.
    if tok = OBJ_TAG_COMMENT then Continue;

    // Data line found: parse it.
    if tok = OBJ_TAG_VERTEX then
    begin
      if FNumVertices >= Length(FVertices) then
      begin
        SetLength(FVertices, Length(FVertices) + 1000);
      end;
      FVertices[FNumVertices] := objStringToVertex(line);
      INC(FNumVertices);
    end
    else if tok = OBJ_TAG_TEXCOORD then
    begin
      if FNumTexVertices >= Length(FTexVertices) then
      begin
        SetLength(FTexVertices, Length(FTexVertices) + 1000);
      end;
      FTexVertices[FNumTexVertices] := objStringToTexVertex(line);
      INC(FNumTexVertices);
    end
    else if tok = OBJ_TAG_NORMAL then
    begin
      if FNumNormals >= Length(FNormals) then
      begin
        SetLength(FNormals, Length(FNormals) + 1000);
      end;
      FNormals[FNumNormals] := objStringToNormal(line);
      INC(FNumNormals);
    end
    else if tok = OBJ_TAG_MATERIAL then
    begin
      FCurrentMaterial := line;
    end
    else if tok = OBJ_TAG_MATERIALLIB then
    begin
      LoadMtlLib(line);
    end
    else if tok = OBJ_TAG_GROUP then
    begin
      if Length(FGroups) > 0 then
      begin
        with FGroups[High(FGroups)] do
        begin
          SetLength(faces, numfaces);
        end;
      end;
      SetLength(FGroups, Length(FGroups) + 1);
      with FGroups[High(FGroups)] do
      begin
        name := line;
        SetLength(faces, 0);
        numfaces := 0;
      end;
    end
    else if tok = OBJ_TAG_FACE then
    begin
      with FGroups[High(FGroups)] do
      begin
        if numfaces >= Length(faces) then
        begin
          SetLength(faces, Length(faces) + 1000);
        end;
        with faces[numfaces] do
        begin
          usemtl := FCurrentMaterial;
          SetLength(vertices, 0);
          tok := GetToken(line);
          while tok <> '' do
          begin
            SetLength(vertices, Length(vertices) + 1);
            vertices[High(vertices)] := objStringToFatVertex(tok);
            tok := GetToken(line);
          end;
        end;
        INC(numfaces);
      end;
    end;
  end;

  f.Free;

  SetCurrentDir(wkdir);

  SetLength(FVertices, FNumVertices);
  SetLength(FTexVertices, FNumTexVertices);
  SetLength(FNormals, FNumNormals);
  with FGroups[High(FGroups)] do SetLength(faces, numfaces);

end;

procedure TOBJModel.LoadMtlLib(const name: ShortString);
var
  i: Integer;
  lib: TOBJMaterialLib;
begin

  for i := 0 to High(FMaterialLibs) do
  begin
    if SameText(ExtractFileName(FMaterialLibs[i].FName),
                ExtractFileName(ChangeFileExt(name, '.mtl'))) then Exit;
  end;

  lib := TOBJMaterialLib.Create;
  lib.LoadFromFile(name);
  SetLength(FMaterialLibs, Length(FMaterialLibs) + 1);
  FMaterialLibs[High(FMaterialLibs)] := lib;

end;

function TOBJModel.GetMaterial(const name: ShortString; var m: TOBJMaterial): Boolean;
var
  i: Integer;
begin

  for i := 0 to High(FMaterialLibs) do
  begin
    if FMaterialLibs[i].GetMaterial(name, m) then
    begin
      Result := TRUE;
      Exit;
    end;
  end;

  Result := FALSE;

end;

initialization

  StringToFloat := StrToFloat_sep;

end.
