unit DotShaders;

interface

uses
  GL, GLext, SysUtils, Classes;

// ARB_vp/ARB_fp style shader loading:
function dotLoadASMShader(target: GLenum; filename: String): GLuint;

// GLSL shader loading:
function dotGLSLGetInfoLog(s: GLhandleARB): String;
function dotGLSLLoadShader(const src: String; const stype: GLenum): GLhandleARB;
function dotGLSLLoadShaderFromFile(const filename: String; const stype: GLenum): GLhandleARB;
function dotGLSLLoadProgram(const sources: array of const): GLhandleARB;
function dotGLSLLoadProgramFromFiles(const filenames: array of const): GLhandleARB;
function dotGLSLLinkPrograms(const programs: array of GLhandleARB): GLhandleARB;
function dotGLSLUniformLocation(const shader: GLhandleARB; const name: String): Integer;

implementation

{ Loads an assembly shader program from disk. The target parameters should be
  either GL_VERTEX_PROGRAM_ARB or GL_FRAGMENT_PROGRAM_ARB. An exception will be
  raised if there is a compilation error. }
function dotLoadASMShader(target: GLenum; filename: String): GLuint;
var
  txt: TStringList;
  err: String;
  i: GLint;
  s: GLuint;
begin

  txt := TStringList.Create;
  txt.LoadFromFile(filename);

  glGenProgramsARB(1, @s);
  glBindProgramARB(target, s);
  glProgramStringARB(target, GL_PROGRAM_FORMAT_ASCII_ARB, Length(txt.Text),
                     PChar(txt.Text));

  txt.Free;

  err := PChar(glGetString(GL_PROGRAM_ERROR_STRING_ARB));
  if err <> '' then
  begin
    glGetIntegerv(GL_PROGRAM_ERROR_POSITION_ARB, @i);
            raise Exception.CreateFmt('Shader program "%s" contains errors:' + #10#10 + err +
                              #10#10 + ' (pos %d)', [ExtractFileName(filename), i]);
  end;

  Result := s;

end;

function dotGLSLGetInfoLog(s: GLhandleARB): String;
var
  blen, slen: Integer;
  infolog: array of Char;
begin

  glGetObjectParameterivARB(s, GL_OBJECT_INFO_LOG_LENGTH_ARB, @blen);

  if blen > 1 then
  begin
    SetLength(infolog, blen);
    glGetInfoLogARB(s, blen, @slen, @infolog[0]);
    Result := String(infolog);
    Exit;
  end;

  Result := '';

end;

function dotGLSLLoadShader(const src: String; const stype: GLenum): GLhandleARB;
var
  source: PChar;
  compiled, len: Integer;
  log: String;
begin

  source := PChar(src);
  len := Length(src);

  Result := glCreateShaderObjectARB(stype);

  glShaderSourceARB(Result, 1, @source, @len);
  glCompileShaderARB(Result);
  glGetObjectParameterivARB(Result, GL_OBJECT_COMPILE_STATUS_ARB, @compiled);
  log := dotGLSLGetInfoLog(Result);

  if compiled <> GL_TRUE then
  begin
    raise Exception.Create(log);
  end;

end;

function dotGLSLLoadShaderFromFile(const filename: String; const stype: GLenum): GLhandleARB;
var
  txt: TStringList;
begin

  txt := TStringList.Create;
  txt.LoadFromFile(filename);

  try
    Result := dotGLSLLoadShader(txt.Text, stype);
  except on E: Exception do
    raise Exception.Create(filename + ' contains errors!' + #10 + e.Message);
  end;

  txt.Free;

end;

function dotGLSLLoadProgram(const sources: array of const): GLhandleARB;
var
  i, linked: Integer;
  shader: GLhandleARB;
  log: String;
begin

  Result := glCreateProgramObjectARB;

  i := 0;
  while i < High(sources) do
  begin
    shader := dotGLSLLoadShader(sources[i+1].VPChar, sources[i].VInteger);

    glAttachObjectARB(Result, shader);
    glDeleteObjectARB(shader);

    INC(i, 2);
  end;

  glLinkProgramARB(Result);
  glGetObjectParameterivARB(Result, GL_OBJECT_LINK_STATUS_ARB, @linked);
  log := dotGLSLGetInfoLog(Result);

  if linked <> GL_TRUE then
    raise Exception.Create(log);

end;

function dotGLSLLoadProgramFromFiles(const filenames: array of const): GLhandleARB;
var
  i, linked: Integer;
  shader: GLhandleARB;
  log: String;
begin

  Result := glCreateProgramObjectARB;

  i := 0;
  while i < High(filenames) do
  begin
    shader := dotGLSLLoadShaderFromFile(filenames[i+1].VPChar, filenames[i].VInteger);

    glAttachObjectARB(Result, shader);

    INC(i, 2);
  end;

  glLinkProgramARB(Result);
  glGetObjectParameterivARB(Result, GL_OBJECT_LINK_STATUS_ARB, @linked);
  log := dotGLSLGetInfoLog(Result);

  if linked <> GL_TRUE then
    raise Exception.Create(log);

end;

function dotGLSLLinkPrograms(const programs: array of GLhandleARB): GLhandleARB;
var
  i, linked: Integer;
  shader: GLhandleARB;
  log: String;
begin

  Result := glCreateProgramObjectARB;

  i := 0;
  while i <= High(programs) do
  begin
    shader := programs[i];

    glAttachObjectARB(Result, shader);

    INC(i);
  end;

  glLinkProgramARB(Result);
  glGetObjectParameterivARB(Result, GL_OBJECT_LINK_STATUS_ARB, @linked);
  log := dotGLSLGetInfoLog(Result);

  if linked <> GL_TRUE then
    raise Exception.Create(log);

end;

function dotGLSLUniformLocation(const shader: GLhandleARB; const name: String): Integer;
var
  n: array [0..63] of Char;
begin

  StrCopy(@n[0], PChar(name + #0));
  Result := glGetUniformLocationARB(shader, @n[0]);

end;

end.
