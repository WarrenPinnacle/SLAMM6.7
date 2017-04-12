unit TokenStream;

interface

uses
  SysUtils, Classes;

type
  TSetOfChar = set of Char;
  TTokenStream = class
  private
    FSeparators: TSetOfChar;
    FOpenBracket, FCloseBracket: String;
    FText: String;
    FPosition: Integer;
    FBrackets: Integer;
  public
    constructor Create(filename: String);
    function GetNextToken: String;
    procedure SkipLine;
    property BracketLevel: Integer read FBrackets;
    property Separators: TSetOfChar read FSeparators write FSeparators;
    property OpenBracket: String read FOpenBracket write FOpenBracket;
    property CloseBracket: String read FCloseBracket write FCloseBracket;
  end;

function StripQuotes(const s: String): String;

implementation

function StripQuotes(const s: String): String;
begin

  Result := s;
  if (Result[1] = '''') or (Result[1] = '"') then
    Delete(Result, 1, 1);

  if (Result[Length(Result)] = '''') or (Result[Length(Result)] = '"') then
    Delete(Result, Length(Result), 1);

end;

constructor TTokenStream.Create(filename: String);
var
  sl: TStringList;
begin

  inherited Create;

  FSeparators := [
        #0,       // Null character (is this ever used in Pascal strings?)
        #9,       // Tab
        #10,      // LF
        #13,      // CR
        ' '       // Space
      ];
  FOpenBracket := '{';
  FCloseBracket := '}';

  sl := TStringList.Create;
  sl.LoadFromFile(filename);
  FText := sl.Text;
  sl.Free;

  FPosition := 1;
  FBrackets := 0;

end;

function TTokenStream.GetNextToken: String;
var
  res: String;
  n: Integer;
begin

  n := Length(FText);

  while (FPosition <= n) and (FText[FPosition] in FSeparators) do INC(FPosition);

  res := '';
  while (FPosition <= n) and (not (FText[FPosition] in FSeparators)) do
  begin
    res := res + FText[FPosition];
    INC(FPosition);
  end;

  if res = FOpenBracket then INC(FBrackets)
  else if res = FCloseBracket then DEC(FBrackets);

  if FBrackets < 0 then raise Exception.Create('Brackets do not match!');

  Result := res;

end;

procedure TTokenStream.SkipLine;
const
  LINE_BREAK: TSetOfChar = [ #10, #13 ];
var
  n: Integer;
begin

  n := Length(FText);
  while (FPosition <= n) and (not (FText[FPosition] in LINE_BREAK)) do INC(FPosition);

end;

end.
