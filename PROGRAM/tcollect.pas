//SLAMM SOURCE CODE copyright (c) 2009 - 2016 Warren Pinnacle Consulting, Inc.
//Code Use and Redistribution is Subject to Licensing, SEE SLAMM_License.txt
//
unit TCollect;
interface
uses classes,sysutils,graphics;

{ This library borrowed from BP 7.0 and then modified to exclude
  assembly language to provide 16-32-64 bit compatibility by JSC           }

{ Duplicates are turned off in the sorted list and ForEach was not coded }

type
  TCollectionError = Exception;

  Baseclass = class
    Procedure WriteText(Var LF: TextFile); virtual;
    Function ObjectID: SmallInt; virtual;
    Procedure Store(IsTemp: Boolean; var st: Tstream);  virtual;
  end;

{ TCollection types }

  TItemList = array of Pointer;

{ TCollection object }

  TCollection = class(Baseclass)
    Items: TItemList;
    Count: Integer;
    Limit: Integer;
    Delta: Integer;
    LastIndexRead: Integer;  {last index read, for optimization...  does not req. save}
    constructor Init(ALimit, ADelta: Integer);
    constructor Load(IsTemp: Boolean; S: Tstream; ReadVersionNum: Double);
    destructor Destroy; Override;
//    destructor SavePointers;
    function At(Index: Integer): Pointer;
    procedure AtFree(Index: Integer);
    procedure AtInsert(Index: Integer; Item: Pointer);
    procedure AtPut(Index: Integer; Item: Pointer);
    procedure FreeAll;
    procedure FreeItem(Item: Pointer); virtual;
    function  IndexOf(Item: Pointer): Integer; virtual;
    function Insert(Item: Pointer):Boolean; virtual;
    procedure SetLimit(ALimit: Integer); virtual;
    procedure Store(IsTemp: Boolean; var S: TStream); Override;
  end;

{ TSortedCollection object }

  TSortedCollection = class(TCollection)
    Duplicates: Boolean;
    constructor Init(ALimit, ADelta: Integer);
    constructor Load(IsTemp: Boolean; S: Tstream; ReadVersionNum: Double);
    function Compare(Key1, Key2: Pointer): Integer; virtual;
    function IndexOf(Item: Pointer): Integer; override;
    function Insert(Item: Pointer):Boolean; override;
    function KeyOf(Item: Pointer): Pointer; virtual;
    function Search(Key: Pointer; var Index: Integer): Boolean; virtual;
    procedure Store(IsTemp: Boolean; var S: TStream); override;
  end;


implementation

uses WinProcs;

{ TBaseClass }

Procedure Baseclass.WriteText(Var LF: TextFile);
Begin

End;

Function Baseclass.ObjectID: SmallInt;
Begin
  Result := -1;
End;

Procedure Baseclass.Store(IsTemp: Boolean; var st: Tstream);  
Begin
  
End;

{ TCollection }

constructor TCollection.Init(ALimit, ADelta: Integer);
begin
  Items := nil;
  Count := 0;
  Limit := 0;
  Delta := ADelta;
  SetLimit(ALimit);
  LastIndexRead := -1;
end;

{$STACKFRAMES OFF}
constructor TCollection.Load(IsTemp: Boolean; S: TStream; ReadVersionNum: Double);
var
  Long: Integer;
  Short: SmallInt;
  I,C : Integer;
  junk: array[0..3] of byte;
begin
  LastIndexRead := -1;
  If ReadVersionNum<1.955
    then
      Begin
        Short:=0;
        S.Read(Short, 2);
        S.Read(Junk,4);
        Count:=Short;
      End
    else
      Begin
        Long:=0;
        S.Read(Long, 4);
        S.Read(Junk,2);
        Count:=Long;
      End;

  Items := nil;

  I := Count;
  C := Count;

  Delta := Count div 2;
  If Delta<2 then Delta := 2;

  Limit := 0;
  Count := 0;
  SetLimit(I);
  Count := C;
end;
{$STACKFRAMES ON}

destructor TCollection.Destroy;
begin
  FreeAll;
  Count := 0;
  SetLimit(0);
end;

{destructor TCollection.SavePointers;
Begin
  SetLimit(0);
End; }


function TCollection.At(Index: Integer): Pointer;

begin
  If (Index>(Count-1)) or (Index<0) then
      raise tCollectionerror.create('Programming Error: Internal data structure Problem (Collection Boundary Exceeded)');
  At:=Items[Index];
end;

procedure TCollection.AtFree(Index: Integer);
Var Loop: Integer;
begin
  If (Index>(Count-1)) or (Index<0) then raise tCollectionerror.create('Programming Error: Internal data structure Problem (Collection Boundary Exceeded on Free)');

  FreeItem(Items[index]);

  For Loop:=Index+1 to Count-1 do
      Items[Loop-1]:=Items[Loop];

  Count:=Count-1;
end;

procedure TCollection.AtInsert(Index: Integer; Item: Pointer);
Var Loop : Integer;

begin
  If (Index>(Count)) or (Index<0)
    then raise tCollectionerror.create('Programming Error: Internal data structure Problem (Collection Boundary Exceeded on Insert)');
  If Count=Limit then SetLimit(Limit+Delta);
  Count:=Count+1;

  For Loop:=Count-1 downto Index+1 do
      Items[Loop]:=Items[loop-1];

  AtPut(Index,Item);
end;

procedure TCollection.AtPut(Index: Integer; Item: Pointer);

begin
  If (Index>(Count-1)) or (Index<0) then raise tCollectionerror.create('Collection Boundary Exceeded on Put');
  Items[Index]:=Item;
end;

procedure TCollection.FreeAll;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do FreeItem(At(I));
  Count := 0;
end;

procedure TCollection.FreeItem(Item:Pointer);
begin
  if Item <> nil then BaseClass(Item).Destroy;
end;

function TCollection.IndexOf(Item: Pointer): Integer;
Var Loop: Integer;
begin
  Indexof := -1;
  For Loop:=0 to count-1 do
      If At(Loop)=Item then begin Indexof:=Loop; exit; end;

end;

Function TCollection.Insert(Item: Pointer):Boolean;
begin
  AtInsert(Count, Item);
  Result := True;
end;

procedure TCollection.SetLimit(ALimit: Integer);
begin
{  if ALimit < Count then ALimit := Count; }
  if ALimit <> Limit then
    Begin
      If ALimit = 0 then Items := nil
                    else SetLength(Items,ALimit+1);
    End;
  Limit := ALimit;
end;

{$STACKFRAMES OFF}

procedure TCollection.Store(IsTemp: Boolean; var S: TStream);
Var BgCt: Integer;
begin
   BgCt:=Count;
   S.Write(BgCt, 6);
end;
{$STACKFRAMES ON}

{ TSortedCollection }

constructor TSortedCollection.Init(ALimit, ADelta: Integer);
begin
  Inherited Init(ALimit, ADelta);
  Duplicates := False;
end;

constructor TSortedCollection.Load(IsTemp: Boolean; S: Tstream; ReadVersionNum: Double);
begin
  Inherited Load(IsTemp, S, ReadVersionNum); {TCollection}
  Duplicates := False;
end;

procedure TSortedCollection.Store(IsTemp: Boolean; var S: TStream);
begin
  Inherited Store(IsTemp,S);
end;


function TSortedCollection.Compare(Key1, Key2: Pointer): Integer;
begin
   Compare:=0;
end;

function TSortedCollection.IndexOf(Item: Pointer): Integer;
{gives index of a given item in the list}
var
  I: Integer;
begin
  IndexOf := -1;
  if Search(KeyOf(Item), I) then
  begin
    if Duplicates then
      while (I < Count) and (Item <> Items[I]) do Inc(I);
    if I < Count then IndexOf := I;
  end;
end;

Function TSortedCollection.Insert(Item: Pointer):Boolean;
var
  I: Integer;
begin
  Result := True;
  If Search(KeyOf(Item),I) and (not Duplicates)
    then
      Begin
        AtInsert(I, Item);
        Result := False;  {Indicate that a duplicate error has been found}
      {  raise tCollectionerror.create('Programming Error: Duplicate Items in This Sorted Collection are not allowed') }
      End
    else AtInsert(I, Item);
end;

function TSortedCollection.KeyOf(Item: Pointer): Pointer;
begin
  KeyOf := Item;
end;

function TSortedCollection.Search(Key: Pointer; var Index: Integer): Boolean;
{if duplicates, gives the index of the first item in the list}

var
  L, H, I, C: Integer;
begin
  Search := False;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    I := (L + H) div 2;
    C := Compare(KeyOf(Items[I]), Key);
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Search := True;
        if not Duplicates then L := I;
        if Duplicates then while Compare(Keyof(Items[L]),Key)<>0 do
            inc(L);
      end;
    end;
  end;
  Index := L;
end;


end.
