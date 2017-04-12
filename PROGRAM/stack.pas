//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//

unit stack;

interface

uses
  SysUtils, Classes, Types;

type
  TPointStack = class
  private
    FList: Array of TPoint;
    FCapacity, FCount: LongInt;
    procedure Grow;
  public
    constructor Init;
    destructor Destroy; override;
    procedure Push( const Data: TPoint );
    function Pop: TPoint;
  end;

implementation

{ TPointStack }

constructor TPointStack.Init;
begin
  FCapacity:= 200000;
  Grow;
  FCount:= 0;
end;

destructor TPointStack.Destroy;
begin
  FList:= nil;
  inherited;
end;

procedure TPointStack.Grow;
begin
  Inc( FCapacity, FCapacity div 2 );
  SetLength(FList, FCapacity);
end;

function TPointStack.Pop: TPoint;
var
  nilPt: TPoint;
begin
  if FCount > 0 then
  begin
    Dec( FCount );
    Result := FList[FCount];
  end
  else
  begin
    nilPt.x:= -99;    // signal that the stack is empty;
    Result := nilPt;
  end;
end;

procedure TPointStack.Push(const Data: TPoint);
begin
  if FCapacity = FCount then
    Grow;
  FList[FCount] := Data;
  Inc( FCount );
end;

end.

