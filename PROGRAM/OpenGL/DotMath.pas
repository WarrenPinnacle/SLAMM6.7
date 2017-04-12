unit DotMath;

interface

uses
  Math;

const
  DOT_EPSILON: Single = 0.0001;

{*** Basic functions **********************************************************}

function dotSign(x: Single): Integer;

function dotMaxi(a, b: Integer): Integer; overload;
function dotMaxi(a, b, c: Integer): Integer; overload;
function dotMaxi(a, b, c, d: Integer): Integer; overload;
function dotMaxf(a, b: Single): Single; overload;
function dotMaxf(a, b, c: Single): Single; overload;
function dotMaxf(a, b, c, d: Single): Single; overload;

function dotMini(a, b: Integer): Integer; overload;
function dotMini(a, b, c: Integer): Integer; overload;
function dotMini(a, b, c, d: Integer): Integer; overload;
function dotMinf(a, b: Single): Single; overload;
function dotMinf(a, b, c: Single): Single; overload;
function dotMinf(a, b, c, d: Single): Single; overload;

{*** Vector types *************************************************************}
type
  TDotVector2 = record
    case Boolean of
      TRUE: ( x, y: Single; );
      FALSE: ( xy: array [0..1] of Single; );
  end;
  TDotVector3 = record
    case Boolean of
      TRUE: ( x, y, z: Single; );
      FALSE: ( xyz: array [0..2] of Single; );
  end;
  TDotVector4 = record
    case Boolean of
      TRUE: ( x, y, z, w: Single; );
      FALSE: ( xyzw: array [0..3] of Single; );
  end;

function dotVector2(x, y: Single): TDotVector2;
function dotVector3(x, y, z: Single): TDotVector3;
function dotVector4(x, y, z: Single; w: Single = 1): TDotVector4;

const
  DOT_ORIGIN2: TDotVector2 = (x: 0; y: 0);
  DOT_X_AXIS2: TDotVector2 = (x: 1; y: 0);
  DOT_Y_AXIS2: TDotVector2 = (x: 0; y: 1);
  DOT_Z_AXIS2: TDotVector2 = (x: 0; y: 0);

  DOT_ORIGIN3: TDotVector3 = (x: 0; y: 0; z: 0);
  DOT_X_AXIS3: TDotVector3 = (x: 1; y: 0; z: 0);
  DOT_Y_AXIS3: TDotVector3 = (x: 0; y: 1; z: 0);
  DOT_Z_AXIS3: TDotVector3 = (x: 0; y: 0; z: 1);

  DOT_ORIGIN4: TDotVector4 = (x: 0; y: 0; z: 0; w: 1);
  DOT_X_AXIS4: TDotVector4 = (x: 1; y: 0; z: 0; w: 1);
  DOT_Y_AXIS4: TDotVector4 = (x: 0; y: 1; z: 0; w: 1);
  DOT_Z_AXIS4: TDotVector4 = (x: 0; y: 0; z: 1; w: 1);

{*** Matrix types *************************************************************}
type
  // Matrix types
  TDotMatrix2x2 = array [0..1, 0..1] of Single;
  TDotMatrix3x3 = array [0..2, 0..2] of Single;
  TDotMatrix4x4 = array [0..3, 0..3] of Single;

const
  DOT_IDENTITY2: TDotMatrix2x2 = ((1, 0), (0, 1));
  DOT_NULLMATRIX2: TDotMatrix2x2 = ((0, 0), (0, 0));

  DOT_IDENTITY3: TDotMatrix3x3 = ((1, 0, 0), (0, 1, 0), (0, 0, 1));
  DOT_NULLMATRIX3: TDotMatrix3x3 = ((0, 0, 0), (0, 0, 0), (0, 0, 0));

  DOT_IDENTITY4: TDotMatrix4x4 = ((1, 0, 0, 0), (0, 1, 0, 0), (0, 0, 1, 0), (0, 0, 0, 1));
  DOT_NULLMATRIX4: TDotMatrix4x4 = ((0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0));

{*** Other types **************************************************************}
type
  // Other types
  TDotPlane = record
    case Boolean of
      TRUE: ( a, b, c, d: Single; );
      FALSE: ( normal: TDotVector3; dist: Single; );
  end;
  TDotQuaternion = record
    case Boolean of
      TRUE: ( w, x, y, z: Single; );
      FALSE: ( wxyz: array [0..3] of Single; );
  end;
  TDotSphereCoords = record
    r, theta, phi: Single;
  end;
  TDotEuler = record
    pitch, yaw, roll: Single;
  end;

function dotPlane(a, b, c, d: Single): TDotPlane; overload;
function dotPlane(normal: TDotVector3; d: Single): TDotPlane; overload;
function dotQuaternion(w, x, y, z: Single): TDotQuaternion;
function dotEuler(pitch, yaw, roll: Single): TDotEuler;

{*** Vector2 operations *******************************************************}
function dotVecComp2(v1, v2: TDotVector2): Boolean;
function dotVecAdd2(v1, v2: TDotVector2): TDotVector2;
function dotVecSubtract2(v1, v2: TDotVector2): TDotVector2;
function dotVecScalarMult2(v: TDotVector2; s: Single): TDotVector2;
function dotVecDot2(v1, v2: TDotVector2): Single;
function dotVecNegate2(v: TDotVector2): TDotVector2;
procedure dotVecScale2(var v: TDotVector2; sx, sy: Single); overload;
procedure dotVecScale2(var v: TDotVector2; s: Single); overload;
function dotVecMult2(v1, v2: TDotVector2): TDotVector2;
function dotVecLength2(v: TDotVector2): Single;
function dotVecLengthSquared2(v: TDotVector2): Single;
function dotVecAngle2(v1, v2, v3: TDotVector2): Single;
procedure dotVecNormalize2(var v: TDotVector2);
procedure dotVecRotate2(var v: TDotVector2; a: Single); overload;
procedure dotVecRotate2(var v: TDotVector2; center: TDotVector2; a: Single); overload;
procedure dotVecMatrixMult2(var v: TDotVector2; m: TDotMatrix2x2);
function dotVecLerp2(v1, v2: TDotVector2; w: Single): TDotVector2;

{*** Vector3 operations *******************************************************}
function dotVecComp3(v1, v2: TDotVector3): Boolean;
function dotVecAdd3(v1, v2: TDotVector3): TDotVector3;
function dotVecSubtract3(v1, v2: TDotVector3): TDotVector3;
function dotVecScalarMult3(v: TDotVector3; s: Single): TDotVector3;
function dotVecDot3(v1, v2: TDotVector3): Single;
function dotVecCross3(v1, v2: TDotVector3): TDotVector3;
function dotVecNegate3(v: TDotVector3): TDotVector3;
procedure dotVecScale3(var v: TDotVector3; sx, sy, sz: Single); overload;
procedure dotVecScale3(var v: TDotVector3; s: Single); overload;
function dotVecMult3(v1, v2: TDotVector3): TDotVector3;
function dotVecLength3(v: TDotVector3): Single;
function dotVecLengthSquared3(v: TDotVector3): Single;
function dotVecAngle3(v1, v2, v3: TDotVector3): Single;
procedure dotVecNormalize3(var v: TDotVector3);
procedure dotVecRotateX3(var v: TDotVector3; a: Single);
procedure dotVecRotateY3(var v: TDotVector3; a: Single);
procedure dotVecRotateZ3(var v: TDotVector3; a: Single);
procedure dotVecRotate3(var v: TDotVector3; axis: TDotVector3; a: Single);
procedure dotVecMatrixMult3(var v: TDotVector3; m: TDotMatrix3x3);
function dotVecLerp3(v1, v2: TDotVector3; w: Single): TDotVector3;

{*** Vector4 operations *******************************************************}
function dotVecComp4(v1, v2: TDotVector4): Boolean;
function dotVecAdd4(v1, v2: TDotVector4): TDotVector4;
function dotVecSubtract4(v1, v2: TDotVector4): TDotVector4;
function dotVecScalarMult4(v: TDotVector4; s: Single): TDotVector4;
function dotVecDot4(v1, v2: TDotVector4): Single;
function dotVecCross4(v1, v2: TDotVector4): TDotVector4;
function dotVecNegate4(v: TDotVector4): TDotVector4;
procedure dotVecScale4(var v: TDotVector4; sx, sy, sz: Single); overload;
procedure dotVecScale4(var v: TDotVector4; s: Single); overload;
function dotVecMult4(v1, v2: TDotVector4): TDotVector4;
function dotVecLength4(v: TDotVector4): Single;
function dotVecLengthSquared4(v: TDotVector4): Single;
function dotVecAngle4(v1, v2, v3: TDotVector4): Single;
procedure dotVecNormalize4(var v: TDotVector4);
procedure dotVecRotateX4(var v: TDotVector4; a: Single);
procedure dotVecRotateY4(var v: TDotVector4; a: Single);
procedure dotVecRotateZ4(var v: TDotVector4; a: Single);
procedure dotVecRotate4(var v: TDotVector4; axis: TDotVector4; a: Single);
procedure dotVecMatrixMult4(var v: TDotVector4; m: TDotMatrix4x4);
function dotVecLerp4(v1, v2: TDotVector4; w: Single): TDotVector4;

{*** Matrix3x3 operations *****************************************************}
function dotMatRotateX3(angle: Single): TDotMatrix3x3;
function dotMatRotateY3(angle: Single): TDotMatrix3x3;
function dotMatRotateZ3(angle: Single): TDotMatrix3x3;
function dotMatRotate3(pyr: TDotEuler): TDotMatrix3x3; overload;
function dotMatRotate3(angle: Single; axis: TDotVector3): TDotMatrix3x3; overload;
function dotMatScale3(sx, sy, sz: Single): TDotMatrix3x3;
procedure dotMatAdd3(var m1: TDotMatrix3x3; m2: TDotMatrix3x3);
procedure dotMatSubtract3(var m1: TDotMatrix3x3; m2: TDotMatrix3x3);
procedure dotMatMult3(var m1: TDotMatrix3x3; m2: TDotMatrix3x3);
procedure dotMatScalarMult3(var m: TDotMatrix3x3; s: Single);
procedure dotMatTranspose3(var m: TDotMatrix3x3);
function dotMatDeterminant3(const m: TDotMatrix3x3): Single;
function dotMatToEuler3(const m: TDotMatrix3x3): TDotEuler;
procedure dotMatSetColumn3(var m: TDotMatrix3x3; const c: Integer; const v: TDotVector3);
function dotMatGetColumn3(const m: TDotMatrix3x3; const c: Integer): TDotVector3;
function dotMatGetRow3(const m: TDotMatrix3x3; const r: Integer): TDotVector3;
function dotMatComp3(const m1, m2: TDotMatrix3x3): Boolean;
function dotMatInverse3(var mr: TDotMatrix3x3; const ma: TDotMatrix3x3): Boolean;
function dotMatMapAtoB3(const A, B: TDotVector3): TDotMatrix3x3;

{*** Matrix4x4 operations *****************************************************}
function dotMatRotateX4(angle: Single): TDotMatrix4x4;
function dotMatRotateY4(angle: Single): TDotMatrix4x4;
function dotMatRotateZ4(angle: Single): TDotMatrix4x4;
function dotMatRotate4(pyr: TDotEuler): TDotMatrix4x4; overload;
function dotMatRotate4(angle: Single; axis: TDotVector4): TDotMatrix4x4; overload;
function dotMatTranslate4(x, y, z: Single): TDotMatrix4x4;
function dotMatScale4(sx, sy, sz: Single): TDotMatrix4x4;
procedure dotMatAdd4(var m1: TDotMatrix4x4; m2: TDotMatrix4x4);
procedure dotMatSubtract4(var m1: TDotMatrix4x4; m2: TDotMatrix4x4);
procedure dotMatMult4(var m1: TDotMatrix4x4; m2: TDotMatrix4x4);
procedure dotMatScalarMult4(var m: TDotMatrix4x4; s: Single);
procedure dotMatTranspose4(var m: TDotMatrix4x4);
function dotMatDeterminant4(const m: TDotMatrix4x4): Single;
function dotMatToEuler4(const m: TDotMatrix4x4): TDotEuler;
procedure dotMatSetColumn4(var m: TDotMatrix4x4; const c: Integer; const v: TDotVector4);
function dotMatGetColumn4(const m: TDotMatrix4x4; const c: Integer): TDotVector4;
function dotMatGetRow4(const m: TDotMatrix4x4; const r: Integer): TDotVector4;
function dotMatComp4(const m1, m2: TDotMatrix4x4): Boolean;
function dotMatInverse4(var mr: TDotMatrix4x4; const ma: TDotMatrix4x4): Boolean;
function dotMatGet3x3SubMatrix4(const m: TDotMatrix4x4; i, j: Integer): TDotMatrix3x3;

{*** Plane operations *********************************************************}
function dotPlaneVecDist(plane: TDotPlane; point: TDotVector3): Single; overload;
function dotPlaneVecDist(plane: TDotPlane; point: TDotVector4): Single; overload;
function dotPlaneFromPoints(p1, p2, p3: TDotVector3): TDotPlane; overload;
function dotPlaneFromPoints(p1, p2, p3: TDotVector4): TDotPlane; overload;
//TODO: Intersection, transformation of planes.

{*** Quaternion operations ****************************************************}
function dotQuatNorm(const q: TDotQuaternion): Single;
procedure dotQuatNormalize(var q: TDotQuaternion);
function dotQuatMult(const q1, q2: TDotQuaternion): TDotQuaternion;
function dotQuatFromAxisAngle(const axis: TDotVector3; angle: Single): TDotQuaternion; overload;
function dotQuatFromEuler(pitch, yaw, roll: Single): TDotQuaternion; overload;
function dotQuatToMatrix(const q: TDotQuaternion): TDotMatrix3x3;
procedure dotQuatToAxisAngle(const q: TDotQuaternion; var axis: TDotVector3; var angle: Single);
function dotQuatSlerp(q1, q2: TDotQuaternion; t: Single): TDotQuaternion;

{*** Spherical coordinate operations ******************************************}
function dotVecCartesianToSpherical3(const v: TDotVector3): TDotSphereCoords;
function dotVecCartesianToSpherical4(const v: TDotVector4): TDotSphereCoords;
function dotVecSphericalToCartesian3(const s: TDotSphereCoords): TDotVector3;
function dotVecSphericalToCartesian4(const s: TDotSphereCoords): TDotVector4;

implementation

function dotSign(x: Single): Integer;
begin

  if x < -DOT_EPSILON then Result := -1
  else if x > DOT_EPSILON then Result := 1
  else Result := 0;

end;

{*** MAX functions ************************************************************}

function dotMaxi(a, b: Integer): Integer;
begin

  if a > b then Result := a
  else Result := b;

end;

function dotMaxi(a, b, c: Integer): Integer;
begin

  Result := dotMaxi(dotMaxi(a, b), c);

end;

function dotMaxi(a, b, c, d: Integer): Integer;
begin

  Result := dotMaxi(dotMaxi(a, b), dotMaxi(c, d));

end;

function dotMaxf(a, b: Single): Single;
begin

  if a > b then Result := a
  else Result := b;

end;

function dotMaxf(a, b, c: Single): Single;
begin

  Result := dotMaxf(dotMaxf(a, b), c);

end;

function dotMaxf(a, b, c, d: Single): Single;
begin

  Result := dotMaxf(dotMaxf(a, b), dotMaxf(c, d));

end;

{*** MIN functions ************************************************************}

function dotMini(a, b: Integer): Integer;
begin

  if a < b then Result := a
  else Result := b;

end;

function dotMini(a, b, c: Integer): Integer;
begin

  Result := dotMini(dotMini(a, b), c);

end;

function dotMini(a, b, c, d: Integer): Integer;
begin

  Result := dotMini(dotMini(a, b), dotMini(c, d));

end;

function dotMinf(a, b: Single): Single;
begin

  if a < b then Result := a
  else Result := b;

end;

function dotMinf(a, b, c: Single): Single;
begin

  Result := dotMinf(dotMinf(a, b), c);

end;

function dotMinf(a, b, c, d: Single): Single;
begin

  Result := dotMinf(dotMinf(a, b), dotMinf(c, d));

end;

{*** Vector types *************************************************************}

function dotVector2(x, y: Single): TDotVector2;
begin

  Result.x := x;
  Result.y := y;

end;

function dotVector3(x, y, z: Single): TDotVector3;
begin

  Result.x := x;
  Result.y := y;
  Result.z := z;

end;

function dotVector4(x, y, z: Single; w: Single = 1): TDotVector4;
begin

  Result.x := x;
  Result.y := y;
  Result.z := z;
  Result.w := w;

end;

{*** Other types **************************************************************}

function dotPlane(a, b, c, d: Single): TDotPlane;
begin

  Result.a := a;
  Result.b := b;
  Result.c := c;
  Result.d := d;

end;

function dotPlane(normal: TDotVector3; d: Single): TDotPlane;
begin

  Result.normal := normal;
  Result.dist := d;

end;

function dotQuaternion(w, x, y, z: Single): TDotQuaternion;
begin

  Result.w := w;
  Result.x := x;
  Result.y := y;
  Result.z := z;

end;

function dotEuler(pitch, yaw, roll: Single): TDotEuler;
begin

  Result.pitch := pitch;
  Result.yaw := yaw;
  Result.roll := roll;

end;

{*** Vector2 operations *******************************************************}

function dotVecComp2(v1, v2: TDotVector2): Boolean;
begin

  Result := (Abs(v1.x - v2.x) < DOT_EPSILON) and (Abs(v1.y - v2.y) < DOT_EPSILON);

end;

function dotVecAdd2(v1, v2: TDotVector2): TDotVector2;
begin

  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;

end;

function dotVecSubtract2(v1, v2: TDotVector2): TDotVector2;
begin

  Result.x := v1.x - v2.x;
  Result.y := v1.y - v2.y;

end;

function dotVecScalarMult2(v: TDotVector2; s: Single): TDotVector2;
begin

  Result.x := v.x * s;
  Result.y := v.y * s;

end;

function dotVecDot2(v1, v2: TDotVector2): Single;
begin

  Result := v1.x*v2.x + v1.y*v2.y;

end;

function dotVecNegate2(v: TDotVector2): TDotVector2;
begin

  Result.x := -v.x;
  Result.y := -v.y;

end;

procedure dotVecScale2(var v: TDotVector2; sx, sy: Single); overload;
begin

  v.x := v.x * sx;
  v.y := v.y * sy;

end;

procedure dotVecScale2(var v: TDotVector2; s: Single); overload;
begin

  v.x := v.x * s;
  v.y := v.y * s;

end;

function dotVecMult2(v1, v2: TDotVector2): TDotVector2;
begin

  Result.x := v1.x * v2.x;
  Result.y := v1.y * v2.y;

end;

function dotVecLength2(v: TDotVector2): Single;
begin

  Result := sqrt(v.x*v.x + v.y*v.y);

end;

function dotVecLengthSquared2(v: TDotVector2): Single;
begin

  Result := v.x*v.x + v.y*v.y;

end;

function dotVecAngle2(v1, v2, v3: TDotVector2): Single;
var
  a1, a2: TDotVector2;
  L1, L2: Single;
begin

  a1 := dotVecSubtract2(v1, v2);
  a2 := dotVecSubtract2(v3, v2);
  L1 := dotVecLength2(a1);
  L2 := dotVecLength2(a2);
  if (L1 = 0) or (L2 = 0) then Result := 0
  else Result := ArcCos(dotVecDot2(a1, a2) / (L1*L2));

end;

procedure dotVecNormalize2(var v: TDotVector2);
var
  L: Single;
begin

  L := dotVecLengthSquared2(v);
  if L = 0 then v := DOT_ORIGIN2
  else begin
    L := sqrt(L);
    v.x := v.x / L;
    v.y := v.y / L;
  end;

end;

procedure dotVecRotate2(var v: TDotVector2; a: Single);
var
  r: TDotVector2;
begin

  r.x := v.x*cos(a) - v.y*sin(a);
  r.y := v.y*cos(a) + v.x*sin(a);
  v := r;

end;

procedure dotVecRotate2(var v: TDotVector2; center: TDotVector2; a: Single);
var
  v0, r: TDotVector2;
begin

  v0 := dotVecSubtract2(v, center);
  r.x := v0.x*cos(a) - v0.y*sin(a);
  r.y := v0.y*cos(a) + v0.x*sin(a);
  v := dotVecAdd2(r, center);

end;

procedure dotVecMatrixMult2(var v: TDotVector2; m: TDotMatrix2x2);
var
  t: TDotVector2;
  r, c: Integer;
begin

  // Multiply v with the matrix m.
  for c := 0 to 1 do
  begin
    t.xy[c] := 0;
    for r := 0 to 1 do
    begin
      t.xy[c] := t.xy[c] + v.xy[r] * m[r,c];
    end;
  end;
  v := t;

end;

function dotVecLerp2(v1, v2: TDotVector2; w: Single): TDotVector2;
begin

  Result.x := (1-w)*v1.x + w*v2.x;
  Result.y := (1-w)*v1.y + w*v2.y;

end;

{*** Vector3 operations *******************************************************}

function dotVecComp3(v1, v2: TDotVector3): Boolean;
begin

  Result := (Abs(v1.x - v2.x) < DOT_EPSILON) and
            (Abs(v1.y - v2.y) < DOT_EPSILON) and
            (Abs(v1.z - v2.z) < DOT_EPSILON);

end;

function dotVecAdd3(v1, v2: TDotVector3): TDotVector3;
begin

  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
  Result.z := v1.z + v2.z;

end;

function dotVecSubtract3(v1, v2: TDotVector3): TDotVector3;
begin

  Result.x := v1.x - v2.x;
  Result.y := v1.y - v2.y;
  Result.z := v1.z - v2.z;

end;

function dotVecScalarMult3(v: TDotVector3; s: Single): TDotVector3;
begin

  Result.x := v.x * s;
  Result.y := v.y * s;
  Result.z := v.z * s;

end;

function dotVecDot3(v1, v2: TDotVector3): Single;
begin

  Result := v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;

end;

function dotVecCross3(v1, v2: TDotVector3): TDotVector3;
begin

  Result.x := v1.y * v2.z - v2.y * v1.z;
  Result.y := v2.x * v1.z - v1.x * v2.z;
  Result.z := v1.x * v2.y - v2.x * v1.y;

end;

function dotVecNegate3(v: TDotVector3): TDotVector3;
begin

  Result.x := -v.x;
  Result.y := -v.y;
  Result.z := -v.z;

end;

procedure dotVecScale3(var v: TDotVector3; sx, sy, sz: Single); overload;
begin

  v.x := v.x * sx;
  v.y := v.y * sy;
  v.z := v.z * sz;

end;

procedure dotVecScale3(var v: TDotVector3; s: Single); overload;
begin

  v.x := v.x * s;
  v.y := v.y * s;
  v.z := v.z * s;

end;

function dotVecMult3(v1, v2: TDotVector3): TDotVector3;
begin

  Result.x := v1.x * v2.x;
  Result.y := v1.y * v2.y;
  Result.z := v1.z * v2.z;

end;

function dotVecLength3(v: TDotVector3): Single;
begin

  Result := sqrt(v.x*v.x + v.y*v.y + v.z*v.z);

end;

function dotVecLengthSquared3(v: TDotVector3): Single;
begin

  Result := v.x*v.x + v.y*v.y + v.z*v.z;

end;

function dotVecAngle3(v1, v2, v3: TDotVector3): Single;
var
  a1, a2: TDotVector3;
  L1, L2: Single;
begin

  a1 := dotVecSubtract3(v1, v2);
  a2 := dotVecSubtract3(v3, v2);
  L1 := dotVecLength3(a1);
  L2 := dotVecLength3(a2);
  if (L1 = 0) or (L2 = 0) then Result := 0
  else Result := ArcCos(dotVecDot3(a1, a2) / (L1*L2));

end;

procedure dotVecNormalize3(var v: TDotVector3);
var
  L: Single;
begin

  L := dotVecLengthSquared3(v);
  if L = 0 then v := DOT_ORIGIN3
  else begin
    L := sqrt(L);
    v.x := v.x / L;
    v.y := v.y / L;
    v.z := v.z / L;
  end;

end;

procedure dotVecRotateX3(var v: TDotVector3; a: Single);
var
  temp: TDotVector3;
begin

  with temp do
  begin
    x := v.x;
    y := (v.y * cos(a)) + (v.z * -sin(a));
    z := (v.y * sin(a)) + (v.z * cos(a));
  end;
  v := temp;

end;

procedure dotVecRotateY3(var v: TDotVector3; a: Single);
var
  temp: TDotVector3;
begin

  with temp do
  begin
    x := (v.x * cos(a)) + (v.z * sin(a));
    y := v.y;
    z := (v.x * -sin(a)) + (v.z * cos(a));
  end;
  v := temp;

end;

procedure dotVecRotateZ3(var v: TDotVector3; a: Single);
var
  temp: TDotVector3;
begin

  with temp do
  begin
    x := (v.x * cos(a)) + (v.y * -sin(a));
    y := (v.x * sin(a)) + (v.y * cos(a));
    z := v.z;
  end;
  v := temp;

end;

procedure dotVecRotate3(var v: TDotVector3; axis: TDotVector3; a: Single);
begin

  dotVecMatrixMult3(v, dotMatRotate3(a, axis));

end;

procedure dotVecMatrixMult3(var v: TDotVector3; m: TDotMatrix3x3);
var
  t: TDotVector3;
  r, c: Integer;
begin

  // Multiply v with the matrix m.
  for c := 0 to 2 do
  begin
    t.xyz[c] := 0;
    for r := 0 to 2 do
    begin
      t.xyz[c] := t.xyz[c] + v.xyz[r] * m[r,c];
    end;
  end;
  v := t;

end;

function dotVecLerp3(v1, v2: TDotVector3; w: Single): TDotVector3;
begin

  Result.x := (1-w)*v1.x + w*v2.x;
  Result.y := (1-w)*v1.y + w*v2.y;
  Result.z := (1-w)*v1.z + w*v2.z;

end;

{*** Vector4 operations *******************************************************}

function dotVecComp4(v1, v2: TDotVector4): Boolean;
begin

  Result := (Abs(v1.x - v2.x) < DOT_EPSILON) and
            (Abs(v1.y - v2.y) < DOT_EPSILON) and
            (Abs(v1.z - v2.z) < DOT_EPSILON) and
            (Abs(v1.w - v2.w) < DOT_EPSILON);

end;

function dotVecAdd4(v1, v2: TDotVector4): TDotVector4;
begin

  Result.x := v1.x + v2.x;
  Result.y := v1.y + v2.y;
  Result.z := v1.z + v2.z;
  Result.w := 1;

end;

function dotVecSubtract4(v1, v2: TDotVector4): TDotVector4;
begin

  Result.x := v1.x - v2.x;
  Result.y := v1.y - v2.y;
  Result.z := v1.z - v2.z;
  Result.w := 1;

end;

function dotVecScalarMult4(v: TDotVector4; s: Single): TDotVector4;
begin

  Result.x := v.x * s;
  Result.y := v.y * s;
  Result.z := v.z * s;
  Result.w := 1;

end;

function dotVecDot4(v1, v2: TDotVector4): Single;
begin

  Result := v1.x*v2.x + v1.y*v2.y + v1.z*v2.z + v1.w*v2.w;

end;

function dotVecCross4(v1, v2: TDotVector4): TDotVector4;
begin

  Result.x := v1.y * v2.z - v2.y * v1.z;
  Result.y := v2.x * v1.z - v1.x * v2.z;
  Result.z := v1.x * v2.y - v2.x * v1.y;
  Result.w := 1;

end;

function dotVecNegate4(v: TDotVector4): TDotVector4;
begin

  Result.x := -v.x;
  Result.y := -v.y;
  Result.z := -v.z;
  Result.w := 1;

end;

procedure dotVecScale4(var v: TDotVector4; sx, sy, sz: Single); overload;
begin

  v.x := v.x * sx;
  v.y := v.y * sy;
  v.z := v.z * sz;

end;

procedure dotVecScale4(var v: TDotVector4; s: Single); overload;
begin

  v.x := v.x * s;
  v.y := v.y * s;
  v.z := v.z * s;

end;

function dotVecMult4(v1, v2: TDotVector4): TDotVector4;
begin

  Result.x := v1.x * v2.x;
  Result.y := v1.y * v2.y;
  Result.z := v1.z * v2.z;
  Result.w := 1;

end;

function dotVecLength4(v: TDotVector4): Single;
begin

  Result := sqrt(v.x*v.x + v.y*v.y + v.z*v.z);

end;

function dotVecLengthSquared4(v: TDotVector4): Single;
begin

  Result := v.x*v.x + v.y*v.y + v.z*v.z;

end;

function dotVecAngle4(v1, v2, v3: TDotVector4): Single;
var
  a1, a2: TDotVector4;
  L1, L2: Single;
begin

  a1 := dotVecSubtract4(v1, v2);
  a2 := dotVecSubtract4(v3, v2);
  L1 := dotVecLength4(a1);
  L2 := dotVecLength4(a2);
  if (L1 = 0) or (L2 = 0) then Result := 0
  else Result := ArcCos(dotVecDot4(a1, a2) / (L1*L2));

end;

procedure dotVecNormalize4(var v: TDotVector4);
var
  L: Single;
begin

  L := dotVecLengthSquared4(v);
  if L = 0 then v := DOT_ORIGIN4
  else begin
    L := sqrt(L);
    v.x := v.x / L;
    v.y := v.y / L;
    v.z := v.z / L;
  end;

end;

procedure dotVecRotateX4(var v: TDotVector4; a: Single);
var
  temp: TDotVector4;
begin

  with temp do
  begin
    x := v.x;
    y := (v.y * cos(a)) + (v.z * -sin(a));
    z := (v.y * sin(a)) + (v.z * cos(a));
    w := 1;
  end;
  v := temp;

end;

procedure dotVecRotateY4(var v: TDotVector4; a: Single);
var
  temp: TDotVector4;
begin

  with temp do
  begin
    x := (v.x * cos(a)) + (v.z * sin(a));
    y := v.y;
    z := (v.x * -sin(a)) + (v.z * cos(a));
    w := 1;
  end;
  v := temp;

end;

procedure dotVecRotateZ4(var v: TDotVector4; a: Single);
var
  temp: TDotVector4;
begin

  with temp do
  begin
    x := (v.x * cos(a)) + (v.y * -sin(a));
    y := (v.x * sin(a)) + (v.y * cos(a));
    z := v.z;
    w := 1;
  end;
  v := temp;

end;

procedure dotVecRotate4(var v: TDotVector4; axis: TDotVector4; a: Single);
begin

  // Rotate around an arbitrary axis through the origin.
  dotVecMatrixMult4(v, dotMatRotate4(a, axis));

end;

procedure dotVecMatrixMult4(var v: TDotVector4; m: TDotMatrix4x4);
var
  t: TDotVector4;
  r, c: Integer;
begin

  // Multiply v with the matrix m.
  for c := 0 to 3 do
  begin
    t.xyzw[c] := 0;
    for r := 0 to 3 do
    begin
      t.xyzw[c] := t.xyzw[c] + v.xyzw[r] * m[r,c];
    end;
  end;
  v := t;

end;

function dotVecLerp4(v1, v2: TDotVector4; w: Single): TDotVector4;
begin

  Result.x := (1-w)*v1.x + w*v2.x;
  Result.y := (1-w)*v1.y + w*v2.y;
  Result.z := (1-w)*v1.z + w*v2.z;
  Result.w := 1;

end;

{*** Matrix3x3 operations *****************************************************}

function dotMatRotateX3(angle: Single): TDotMatrix3x3;
begin

  Result := DOT_IDENTITY3;
  Result[1,1] := cos(angle);
  Result[2,2] := Result[1,1];
  Result[1,2] := sin(angle);
  Result[2,1] := -Result[1,2];

end;

function dotMatRotateY3(angle: Single): TDotMatrix3x3;
begin

  Result := DOT_IDENTITY3;
  Result[0,0] := cos(angle);
  Result[2,2] := Result[0,0];
  Result[0,2] := -sin(angle);
  Result[2,0] := -Result[0,2];

end;

function dotMatRotateZ3(angle: Single): TDotMatrix3x3;
begin

  Result := DOT_IDENTITY3;
  Result[0,0] := cos(angle);
  Result[1,1] := Result[0,0];
  Result[0,1] := sin(angle);
  Result[1,0] := -Result[0,1];

end;

function dotMatRotate3(pyr: TDotEuler): TDotMatrix3x3;
var
  A, B, C, D, E, F, AD, BD: Single;
begin

  A := cos(pyr.pitch);       B := sin(pyr.pitch);
  C := cos(pyr.yaw);         D := sin(pyr.yaw);
  E := cos(pyr.roll);        F := sin(pyr.roll);

  AD := A*D;
  BD := B*D;

  Result := DOT_IDENTITY3;

  Result[0,0] := C*E;
  Result[1,0] := -C*F;
  Result[2,0] := D;

  Result[0,1] := BD*E + A*F;
  Result[1,1] := -BD*F + A*E;
  Result[2,1] := -B*C;

  Result[0,2] := -AD*E + B*F;
  Result[1,2] := AD*F + B*E;
  Result[2,2] := A*C;

end;

function dotMatRotate3(angle: Single; axis: TDotVector3): TDotMatrix3x3;
var
  m: TDotMatrix3x3;
  cosA, sinA: Single;
begin

  // Return a rotation matrix for an arbitrary axis through the origin.
  m := DOT_IDENTITY3;
  cosA := cos(angle);
  sinA := sin(angle);

  m[0,0] := cosA + (1 - cosA)*axis.x*axis.x;
  m[1,0] := (1 - cosA)*axis.x*axis.y - axis.z*sinA;
  m[2,0] := (1 - cosA)*axis.x*axis.z + axis.y*sinA;
  m[0,1] := (1 - cosA)*axis.x*axis.z + axis.z*sinA;
  m[1,1] := cosA + (1 - cosA)*axis.y*axis.y;
  m[2,1] := (1 - cosA)*axis.y*axis.z - axis.x*sinA;
  m[0,2] := (1 - cosA)*axis.x*axis.z - axis.y*sinA;
  m[1,2] := (1 - cosA)*axis.y*axis.z + axis.x*sinA;
  m[2,2] := cosA + (1 - cosA)*axis.z*axis.z;

  Result := m;

end;

function dotMatScale3(sx, sy, sz: Single): TDotMatrix3x3;
begin

  Result := DOT_IDENTITY3;
  Result[0,0] := sx;
  Result[1,1] := sy;
  Result[2,2] := sz;

end;

procedure dotMatAdd3(var m1: TDotMatrix3x3; m2: TDotMatrix3x3);
var
  i, j: Integer;
begin

  for i := 0 to 2 do
  begin
    for j := 0 to 2 do
    begin
      m1[i,j] := m1[i,j] + m2[i,j];
    end;
  end;

end;

procedure dotMatSubtract3(var m1: TDotMatrix3x3; m2: TDotMatrix3x3);
var
  i, j: Integer;
begin

  for i := 0 to 2 do
  begin
    for j := 0 to 2 do
    begin
      m1[i,j] := m1[i,j] - m2[i,j];
    end;
  end;

end;

procedure dotMatMult3(var m1: TDotMatrix3x3; m2: TDotMatrix3x3);
var
  r, c, i: Byte;
  t: TDotMatrix3x3;
begin

  // Multiply two matrices.
  t := DOT_NULLMATRIX3;
  for r := 0 to 2 do
  begin
    for c := 0 to 2 do
    begin
      for i := 0 to 2 do
      begin
        t[r,c] := t[r,c] + (m1[r,i] * m2[i,c]);
      end;
    end;
  end;
  m1 := t;

end;

procedure dotMatScalarMult3(var m: TDotMatrix3x3; s: Single);
var
  i, j: Integer;
begin

  for i := 0 to 2 do
  begin
    for j := 0 to 2 do
    begin
      m[i,j] := m[i,j] * s;
    end;
  end;

end;

procedure dotMatTranspose3(var m: TDotMatrix3x3);
var
  mt: TDotMatrix3x3;
  r, c: Integer;
begin

  mt := m;
  for r := 0 to 2 do
  begin
    for c := 0 to 2 do
    begin
      mt[r,c] := m[c,r];
    end;
  end;
  m := mt;

end;

function dotMatDeterminant3(const m: TDotMatrix3x3): Single;
begin

  Result := m[0,0] * (m[1,1]*m[2,2] - m[2,1]*m[1,2])
          - m[0,1] * (m[1,0]*m[2,2] - m[2,0]*m[1,2])
          + m[0,2] * (m[1,0]*m[2,1] - m[2,0]*m[1,1]);

end;

function dotMatToEuler3(const m: TDotMatrix3x3): TDotEuler;
var
  angle_x, angle_y, angle_z: Single;
  C, D: Single;
  tx, ty: Single;
begin

  D :=  ArcSin(m[2,0]);
  angle_y := D;
  C := cos(angle_y);

  if Abs(C) > 0.005 then
  begin
    tx := m[2,2] / C;
    ty := -m[2,1] / C;

    angle_x := ArcTan2(ty, tx);

    tx := m[0,0] / C;
    ty := -m[1,0] / C;

    angle_z := ArcTan2(ty, tx);
  end
  else begin
    angle_x := 0;

    tx := m[1,1];
    ty := m[0,1];

    angle_z := ArcTan2(ty, tx);
  end;

  if angle_x < 0 then angle_x := angle_x + 2*PI;
  if angle_y < 0 then angle_y := angle_y + 2*PI;
  if angle_z < 0 then angle_z := angle_z + 2*PI;

  Result.pitch := angle_x;
  Result.yaw := angle_y;
  Result.roll := angle_z;

end;

procedure dotMatSetColumn3(var m: TDotMatrix3x3; const c: Integer; const v: TDotVector3);
begin

  m[c,0] := v.x;
  m[c,1] := v.y;
  m[c,2] := v.z;

end;

function dotMatGetColumn3(const m: TDotMatrix3x3; const c: Integer): TDotVector3;
begin

  with Result do
  begin
    x := m[c,0];
    y := m[c,1];
    z := m[c,2];
  end;

end;

function dotMatGetRow3(const m: TDotMatrix3x3; const r: Integer): TDotVector3;
begin

  with Result do
  begin
    x := m[0,r];
    y := m[1,r];
    z := m[2,r];
  end;

end;

function dotMatComp3(const m1, m2: TDotMatrix3x3): Boolean;
var
  r, c: Integer;
begin

  Result := TRUE;
  for r := 0 to 2 do
  begin
    for c := 0 to 2 do
    begin
      if Abs(m1[r,c] - m2[r,c]) > DOT_EPSILON then
      begin
        Result := FALSE;
        Exit;
      end;
    end;
  end;

end;

function dotMatInverse3(var mr: TDotMatrix3x3; const ma: TDotMatrix3x3): Boolean;
var
  det: Single;
begin

  det := dotMatDeterminant3(ma);

  if Abs(det) < DOT_EPSILON then
  begin
    mr := DOT_IDENTITY3;
    Result := FALSE;
    Exit;
  end;

  mr[0,0] :=    ma[1,1]*ma[2,2] - ma[1,2]*ma[2,1]   / det;
  mr[0,1] := -( ma[0,1]*ma[2,2] - ma[2,1]*ma[0,2] ) / det;
  mr[0,2] :=    ma[0,1]*ma[1,2] - ma[1,1]*ma[0,2]   / det;
  mr[1,0] := -( ma[1,0]*ma[2,2] - ma[1,2]*ma[2,0] ) / det;
  mr[1,1] :=    ma[0,0]*ma[2,2] - ma[2,0]*ma[0,2]   / det;
  mr[1,2] := -( ma[0,0]*ma[1,2] - ma[1,0]*ma[0,2] ) / det;
  mr[2,0] :=    ma[1,0]*ma[2,1] - ma[2,0]*ma[1,1]   / det;
  mr[2,1] := -( ma[0,0]*ma[2,1] - ma[2,0]*ma[0,1] ) / det;
  mr[2,2] :=    ma[0,0]*ma[1,1] - ma[0,1]*ma[1,0]   / det;

  Result := TRUE;

end;

function dotMatMapAtoB3(const A, B: TDotVector3): TDotMatrix3x3;
var
  axis: TDotVector3;
  angle, dot: Single;
  mat: TDotMatrix3x3;
  q: TDotQuaternion;
begin

  dot := dotVecDot3(A, B);

  // If the two inputs identical, we don't need a rotation at all.
  if Abs(dot - 1) < DOT_EPSILON then
  begin
    mat := DOT_IDENTITY3;
  end
  else begin
    // Rotation axis is the cross product of the two inputs.
    axis := dotVecCross3(A, B);

    // BUT! If the inputs are eachother's opposite, just use a 180° rotation.
    if Abs(dot + 1) < Dot_EPSILON then
    begin
      //TODO: This won't work if the inputs are on the X axis?
      q := dotQuatFromAxisAngle(dotVector3(1, 0, 0), PI);
      mat := dotQuatToMatrix(q);
    end
    else begin
      // The vectors are identical nor opposite, so proceed.
      angle := ArcCos(dot);
      //TODO: Isn't this redundant? Shouldn't it be in the "if opposite" test?
      if dotVecComp3(axis, DOT_ORIGIN3) then
      begin
        axis := dotVector3(B.y, A.z, A.x);
        dotVecNormalize3(axis);
        axis := dotVecCross3(A, axis);
        angle := PI;
      end;
      dotVecNormalize3(axis);

      // Now that we have axis/angle, convert it to a matrix.
      q := dotQuatFromAxisAngle(axis, angle);
      mat := dotQuatToMatrix(q);
    end;
  end;

  Result := mat;

end;

{*** Matrix4x4 operations *****************************************************}

function dotMatRotateX4(angle: Single): TDotMatrix4x4;
begin

  Result := DOT_IDENTITY4;
  Result[1,1] := cos(angle);
  Result[2,2] := Result[1,1];
  Result[1,2] := sin(angle);
  Result[2,1] := -Result[1,2];

end;

function dotMatRotateY4(angle: Single): TDotMatrix4x4;
begin

  Result := DOT_IDENTITY4;
  Result[0,0] := cos(angle);
  Result[2,2] := Result[0,0];
  Result[0,2] := -sin(angle);
  Result[2,0] := -Result[0,2];

end;

function dotMatRotateZ4(angle: Single): TDotMatrix4x4;
begin

  Result := DOT_IDENTITY4;
  Result[0,0] := cos(angle);
  Result[1,1] := Result[0,0];
  Result[0,1] := sin(angle);
  Result[1,0] := -Result[0,1];

end;

function dotMatRotate4(pyr: TDotEuler): TDotMatrix4x4;
var
  A, B, C, D, E, F, AD, BD: Single;
begin

  A := cos(pyr.pitch);       B := sin(pyr.pitch);
  C := cos(pyr.yaw);         D := sin(pyr.yaw);
  E := cos(pyr.roll);        F := sin(pyr.roll);

  AD := A*D;
  BD := B*D;

  Result := DOT_IDENTITY4;

  Result[0,0] := C*E;
  Result[1,0] := -C*F;
  Result[2,0] := D;

  Result[0,1] := BD*E + A*F;
  Result[1,1] := -BD*F + A*E;
  Result[2,1] := -B*C;

  Result[0,2] := -AD*E + B*F;
  Result[1,2] := AD*F + B*E;
  Result[2,2] := A*C;

end;

function dotMatRotate4(angle: Single; axis: TDotVector4): TDotMatrix4x4;
var
  m: TDotMatrix4x4;
  cosA, sinA: Single;
begin

  // Return a rotation matrix for an arbitrary axis through the origin.
  m := DOT_IDENTITY4;
  cosA := cos(angle);
  sinA := sin(angle);

  m[0,0] := cosA + (1 - cosA)*axis.x*axis.x;
  m[1,0] := (1 - cosA)*axis.x*axis.y - axis.z*sinA;
  m[2,0] := (1 - cosA)*axis.x*axis.z + axis.y*sinA;
  m[0,1] := (1 - cosA)*axis.x*axis.z + axis.z*sinA;
  m[1,1] := cosA + (1 - cosA)*axis.y*axis.y;
  m[2,1] := (1 - cosA)*axis.y*axis.z - axis.x*sinA;
  m[0,2] := (1 - cosA)*axis.x*axis.z - axis.y*sinA;
  m[1,2] := (1 - cosA)*axis.y*axis.z + axis.x*sinA;
  m[2,2] := cosA + (1 - cosA)*axis.z*axis.z;

  Result := m;

end;

function dotMatTranslate4(x, y, z: Single): TDotMatrix4x4;
begin

  Result := DOT_IDENTITY4;
  Result[3,0] := x;
  Result[3,1] := y;
  Result[3,2] := z;

end;

function dotMatScale4(sx, sy, sz: Single): TDotMatrix4x4;
begin

  Result := DOT_IDENTITY4;
  Result[0,0] := sx;
  Result[1,1] := sy;
  Result[2,2] := sz;

end;

procedure dotMatAdd4(var m1: TDotMatrix4x4; m2: TDotMatrix4x4);
var
  i, j: Integer;
begin

  for i := 0 to 3 do
  begin
    for j := 0 to 3 do
    begin
      m1[i,j] := m1[i,j] + m2[i,j];
    end;
  end;

end;

procedure dotMatSubtract4(var m1: TDotMatrix4x4; m2: TDotMatrix4x4);
var
  i, j: Integer;
begin

  for i := 0 to 3 do
  begin
    for j := 0 to 3 do
    begin
      m1[i,j] := m1[i,j] - m2[i,j];
    end;
  end;

end;

procedure dotMatMult4(var m1: TDotMatrix4x4; m2: TDotMatrix4x4);
var
  r, c, i: Byte;
  t: TDotMatrix4x4;
begin

  // Multiply two matrices.
  t := DOT_NULLMATRIX4;
  for r := 0 to 3 do
  begin
    for c := 0 to 3 do
    begin
      for i := 0 to 3 do
      begin
        t[r,c] := t[r,c] + (m1[r,i] * m2[i,c]);
      end;
    end;
  end;
  m1 := t;

end;

procedure dotMatScalarMult4(var m: TDotMatrix4x4; s: Single);
var
  i, j: Integer;
begin

  for i := 0 to 3 do
  begin
    for j := 0 to 3 do
    begin
      m[i,j] := m[i,j] * s;
    end;
  end;

end;

procedure dotMatTranspose4(var m: TDotMatrix4x4);
var
  mt: TDotMatrix4x4;
  r, c: Integer;
begin

  mt := m;
  for r := 0 to 3 do
  begin
    for c := 0 to 3 do
    begin
      mt[r,c] := m[c,r];
    end;
  end;
  m := mt;

end;

function dotMatDeterminant4(const m: TDotMatrix4x4): Single;
var
  det, i: Single;
  msub3: TDotMatrix3x3;
  n: Integer;
begin

  Result := 0;
  i := 1;

  for n := 0 to 3 do
  begin
    msub3 := dotMatGet3x3SubMatrix4(m, n, 0);
    det := dotMatDeterminant3(msub3);
    Result := Result + m[n,0] * det * i;

    i := -i;
  end;

end;

function dotMatToEuler4(const m: TDotMatrix4x4): TDotEuler;
var
  angle_x, angle_y, angle_z: Single;
  C, D: Single;
  tx, ty: Single;
begin

  D :=  ArcSin(m[2,0]);
  angle_y := D;
  C := cos(angle_y);

  if Abs(C) > 0.005 then
  begin
    tx := m[2,2] / C;
    ty := -m[2,1] / C;

    angle_x := ArcTan2(ty, tx);

    tx := m[0,0] / C;
    ty := -m[1,0] / C;

    angle_z := ArcTan2(ty, tx);
  end
  else begin
    angle_x := 0;

    tx := m[1,1];
    ty := m[0,1];

    angle_z := ArcTan2(ty, tx);
  end;

  if angle_x < 0 then angle_x := angle_x + 2*PI;
  if angle_y < 0 then angle_y := angle_y + 2*PI;
  if angle_z < 0 then angle_z := angle_z + 2*PI;

  Result.pitch := angle_x;
  Result.yaw := angle_y;
  Result.roll := angle_z;

end;

procedure dotMatSetColumn4(var m: TDotMatrix4x4; const c: Integer; const v: TDotVector4);
begin

  m[c,0] := v.x;
  m[c,1] := v.y;
  m[c,2] := v.z;
  m[c,3] := v.w;

end;

function dotMatGetColumn4(const m: TDotMatrix4x4; const c: Integer): TDotVector4;
begin

  with Result do
  begin
    x := m[c,0];
    y := m[c,1];
    z := m[c,2];
    w := m[c,3];
  end;

end;

function dotMatGetRow4(const m: TDotMatrix4x4; const r: Integer): TDotVector4;
begin

  with Result do
  begin
    x := m[0,r];
    y := m[1,r];
    z := m[2,r];
    w := m[3,r];
  end;

end;

function dotMatComp4(const m1, m2: TDotMatrix4x4): Boolean;
var
  r, c: Integer;
begin

  Result := TRUE;
  for r := 0 to 3 do
  begin
    for c := 0 to 3 do
    begin
      if Abs(m1[r,c] - m2[r,c]) > DOT_EPSILON then
      begin
        Result := FALSE;
        Exit;
      end;
    end;
  end;

end;

function dotMatInverse4(var mr: TDotMatrix4x4; const ma: TDotMatrix4x4): Boolean;
var
  mdet: Single;
  mtemp: TDotMatrix3x3;
  i, j, sign: Integer;
begin

  mdet := dotMatDeterminant4(ma);

  if Abs(mdet) < DOT_EPSILON then
  begin
    mr := DOT_IDENTITY4;
    Result := FALSE;
    Exit;
  end;

  for i := 0 to 3 do
  begin
    for j := 0 to 3 do
    begin
      sign := 1 - ((i+j) mod 2) * 2;
      mtemp := dotMatGet3x3SubMatrix4(ma, i, j);
      mr[j,i] := dotMatDeterminant3(mtemp) * sign / mdet;
    end;
  end;

  Result := TRUE;

end;

function dotMatGet3x3SubMatrix4(const m: TDotMatrix4x4; i, j: Integer): TDotMatrix3x3;
var
  di, dj, si, sj: Integer;
begin

  for di := 0 to 2 do
  begin
    for dj := 0 to 2 do
    begin
      if di >= i then si := di + 1
      else si := di;
      if dj >= j then sj := dj + 1
      else sj := dj;

      Result[di,dj] := m[si,sj];
    end;
  end;

end;

{*** Plane operations *********************************************************}

function dotPlaneVecDist(plane: TDotPlane; point: TDotVector3): Single;
begin

  Result := (plane.a * point.x) + (plane.b * point.y) + (plane.c * point.z) + plane.d;

end;

function dotPlaneVecDist(plane: TDotPlane; point: TDotVector4): Single;
begin

  Result := (plane.a * point.x) + (plane.b * point.y) + (plane.c * point.z) + plane.d;

end;

function dotPlaneFromPoints(p1, p2, p3: TDotVector3): TDotPlane;
var
  n: TDotVector3;
begin

  n := dotVecCross3(dotVecSubtract3(p2, p1), dotVecSubtract3(p3, p1));
  dotVecNormalize3(n);
  with Result do
  begin
    a := n.x;
    b := n.y;
    c := n.z;
    d := -(a * p1.x + b * p1.y + c * p1.z);
  end;

end;

function dotPlaneFromPoints(p1, p2, p3: TDotVector4): TDotPlane;
var
  n: TDotVector4;
begin

  n := dotVecCross4(dotVecSubtract4(p2, p1), dotVecSubtract4(p3, p1));
  dotVecNormalize4(n);
  with Result do
  begin
    a := n.x;
    b := n.y;
    c := n.z;
    d := -(a * p1.x + b * p1.y + c * p1.z);
  end;

end;

{*** Quaternion operations ****************************************************}

function dotQuatNorm(const q: TDotQuaternion): Single;
begin

  Result := sqrt(q.w*q.w + q.x*q.x + q.y*q.y + q.z*q.z);

end;

procedure dotQuatNormalize(var q: TDotQuaternion);
var
  mag: Single;
begin

  mag := dotQuatNorm(q);

  if mag <> 0 then
  begin
    q.x := q.x / mag;
    q.y := q.y / mag;
    q.z := q.z / mag;
    q.w := q.w / mag;
  end;

end;

function dotQuatMult(const q1, q2: TDotQuaternion): TDotQuaternion;
var
  v1, v2, qvec: TDotVector3;
  qr: TDotQuaternion;
begin

  v1 := dotVector3(q1.x, q1.y, q1.z);
  v2 := dotVector3(q2.x, q2.y, q2.z);

  qr.w := q1.w * q2.w - dotVecDot3(v1, v2);
  qvec := dotVecAdd3(dotVecScalarMult3(v2, q1.w),
              dotVecAdd3(dotVecScalarMult3(v1, q2.w), dotVecCross3(v1, v2)));
  qr.x := qvec.x;
  qr.y := qvec.y;
  qr.z := qvec.z;

  dotQuatNormalize(qr);

  Result := qr;

end;

function dotQuatFromAxisAngle(const axis: TDotVector3; angle: Single): TDotQuaternion; overload;
var
  sa2: Single;
begin

  Result.w := cos(angle/2);

  sa2 := sin(angle/2);

  Result.x := axis.x * sa2;
  Result.y := axis.y * sa2;
  Result.z := axis.z * sa2;

  dotQuatNormalize(Result);

end;

function dotQuatFromEuler(pitch, yaw, roll: Single): TDotQuaternion; overload;
var
  q1, q2, q3: TDotQuaternion;
begin

  q1 := dotQuaternion(cos(pitch/2), sin(pitch/2), 0, 0);
  q2 := dotQuaternion(cos(yaw/2), 0, sin(yaw/2), 0);
  q3 := dotQuaternion(cos(roll/2), 0, 0, sin(roll/2));

  Result := dotQuatMult(dotQuatMult(q3, q2), q1);

end;

function dotQuatToMatrix(const q: TDotQuaternion): TDotMatrix3x3;
begin

  Result[0,0] := 1 - 2*q.y*q.y - 2*q.z*q.z;
  Result[0,1] := 2*q.x*q.y + 2*q.w*q.z;
  Result[0,2] := 2*q.x*q.z - 2*q.w*q.y;

  Result[1,0] := 2*q.x*q.y - 2*q.w*q.z;
  Result[1,1] := 1 - 2*q.x*q.x - 2*q.z*q.z;
  Result[1,2] := 2*q.y*q.z + 2*q.w*q.x;

  Result[2,0] := 2*q.x*q.z + 2*q.w*q.y;
  Result[2,1] := 2*q.y*q.z - 2*q.w*q.x;
  Result[2,2] := 1 - 2*q.x*q.x - 2*q.y*q.y;

end;

procedure dotQuatToAxisAngle(const q: TDotQuaternion; var axis: TDotVector3; var angle: Single);
var
  s: Single;
begin

  s := q.x*q.x + q.y*q.y + q.z*q.z;

  angle := 2 * ArcCos(q.w);
  axis.x := q.x / s;
  axis.y := q.y / s;
  axis.z := q.z / s;

end;

function dotQuatSlerp(q1, q2: TDotQuaternion; t: Single): TDotQuaternion;
var
  q: array [0..3] of Single;
  omega, cosom, sinom, scale0, scale1: Single;
begin

  cosom := q1.x * q2.x + q1.y * q2.y + q1.z * q2.z + q1.w * q2.w;

  if cosom < 0 then
  begin
    cosom  := -cosom;
    q[0] := -q2.x;
    q[1] := -q2.y;
    q[2] := -q2.z;
    q[3] := -q2.w;
  end
  else begin
    q[0] := q2.x;
    q[1] := q2.y;
    q[2] := q2.z;
    q[3] := q2.w;
  end;

  if (1 - cosom) > DOT_EPSILON then
  begin
    omega := ArcCos(cosom);
    sinom := sin(omega);
    scale0 := sin((1.0 - t) * omega) / sinom;
    scale1 := sin(t * omega) / sinom;
  end
  else begin
    scale0 := 1 - t;
    scale1 := t;
  end;

  // calculate final values
  Result.x := (scale0 * q1.x) + (scale1 * q[0]);
  Result.y := (scale0 * q1.y) + (scale1 * q[1]);
  Result.z := (scale0 * q1.z) + (scale1 * q[2]);
  Result.w := (scale0 * q1.w) + (scale1 * q[3]);

end;

{*** Spherical coordinate operations ******************************************}

function dotVecCartesianToSpherical3(const v: TDotVector3): TDotSphereCoords;
begin

  with Result do
  begin
    r := dotVecLength3(v);
    theta := ArcCos(v.z/r);
    phi := dotSign(v.y)*ArcCos(v.x/sqrt(v.x*v.x + v.y*v.y));
  end;

end;

function dotVecCartesianToSpherical4(const v: TDotVector4): TDotSphereCoords;
begin

  with Result do
  begin
    r := dotVecLength4(v);
    theta := ArcCos(v.z/r);
    phi := dotSign(v.y)*ArcCos(v.x/sqrt(v.x*v.x + v.y*v.y));
  end;

end;

function dotVecSphericalToCartesian3(const s: TDotSphereCoords): TDotVector3;
begin

  with Result do
  begin
    x := s.r*sin(s.theta)*cos(s.phi);
    y := s.r*sin(s.theta)*sin(s.phi);
    z := s.r*cos(s.theta);
  end;

end;

function dotVecSphericalToCartesian4(const s: TDotSphereCoords): TDotVector4;
begin

  with Result do
  begin
    x := s.r*sin(s.theta)*cos(s.phi);
    y := s.r*sin(s.theta)*sin(s.phi);
    z := s.r*cos(s.theta);
    w := 1;
  end;

end;

end.
