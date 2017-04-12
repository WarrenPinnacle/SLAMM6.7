unit NV_parse;

{
  NVparse import unit for Delphi.
  Written by Tom Nuydens (tom@delphi3d.net -- http://www.delphi3d.net).

  NVparse itself is available (with source code) in NVIDIA's OpenGL SDK, at
  http://www.nvidia.com/developer. This site also has more information on how to
  use NVparse.
}

interface

const
  NVPARSE_DLL = 'nvparse.dll';

type
  PPChar = ^PChar;

procedure nvparse(const input_string: PChar); cdecl; external NVPARSE_DLL;
function nvparse_get_errors: PPChar; cdecl; external NVPARSE_DLL;

function nvparse_error_strings: String;

implementation

{ Utility function to get a Pascal string containing the error messages
  returned by nvparse_get_errors(). The strings are separated by line breaks,
  and can be appended to a TStringList if you want to display them in a TMemo,
  for example. }
function nvparse_error_strings: String;
var
  err: PPChar;
  str: PChar;
begin

  err := nvparse_get_errors;

  Result := '';
  while err^ <> nil do
  begin
    str := err^;
    Result := Result + str + #13;
    INC(Integer(err), 4);
  end;

end;

end.
