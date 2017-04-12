unit TGA2;

interface

uses
  SysUtils, Classes;

type
  TTGAHeader = packed record
    IDLength: Byte;
    CMapType: Byte;
    ImageType: Byte;
    CMapSpec: packed record
        FirstEntryIndex: Word;
        Length: Word;
        EntrySize: Byte;
      end;
    ImgSpec: packed record
        Xorg: Word;
        Yorg: Word;
        Width: Word;
        Height: Word;
        Depth: Byte;
        Desc: Byte;
      end;
  end;

type
  TTGAImage = class
  protected
    FHeader: TTGAHeader;
    FData: array of Byte;
    FPalette: array of Byte;
    function GetDataPointer: Pointer;
    function GetPalettePointer: Pointer;
    procedure RLEDecode(s: TStream);
  public
    constructor Create;
    procedure LoadFromStream(s: TStream);
    procedure LoadFromFile(filename: String);
    procedure ExpandToTrueColor;
    procedure BGRtoRGB;
    procedure FlipVertically;
    procedure FlipHorizontally;
    destructor Destroy; override;
    property Header: TTGAHeader read FHeader;
    property Data: Pointer read GetDataPointer;
    property Palette: Pointer read GetPalettePointer;
  end;

implementation

function TTGAImage.GetDataPointer: Pointer;
begin

  Result := FData;

end;

function TTGAImage.GetPalettePointer: Pointer;
begin

  Result := FPalette;

end;

procedure TTGAImage.RLEDecode(s: TStream);
var
  pixelSize: Integer;
  i, j, n: Integer;
  packetHdr: Byte;
  packet: array of Byte;
  packetLen: Byte;
begin

  // Data is RLE compressed, so decode it.
  pixelSize := FHeader.ImgSpec.Depth div 8;
  n := FHeader.ImgSpec.Width * FHeader.ImgSpec.Height * pixelSize;
  SetLength(FData, n);

  SetLength(packet, pixelSize);

  i := 0;
  while i < n do
  begin
    // Read the packet header:
    s.Read(packetHdr, 1);
    packetLen := (packetHdr and $7F) + 1;
    if (packetHdr and $80) <> 0 then
    begin
      // Run-length packet.
      s.Read(packet[0], pixelSize);
      // Replicate the packet in the destination buffer.
      for j := 0 to (packetLen*pixelSize) - 1 do
      begin
        FData[i] := packet[j mod pixelSize];
        INC(i);
      end;
    end
    else begin
      // Raw packet.
      for j := 0 to (packetLen * pixelSize) - 1 do
      begin
        s.Read(packet[j mod pixelSize], 1);
        FData[i] := packet[j mod pixelSize];
        INC(i);
      end;
    end;
  end;

  // Change image type to the corresponding uncompressed format.
  FHeader.ImageType := FHeader.ImageType - 8;

end;

procedure TTGAImage.FlipVertically;
var
  scanLine: array of Byte;
  i, w, h, pixelSize: Integer;
begin

  w := FHeader.ImgSpec.Width;
  h := FHeader.ImgSpec.Height;
  pixelSize := FHeader.ImgSpec.Depth div 8;

  SetLength(scanLine, w*pixelSize);

  for i := 0 to h div 2 - 1 do
  begin
    Move(FData[i*w*pixelSize], scanLine[0], w*pixelSize);
    Move(FData[(h-i-1)*w*pixelSize], FData[i*w*pixelSize], w*pixelSize);
    Move(scanLine[0], FData[(h-i-1)*w*pixelSize], w*pixelSize);
  end;

end;

procedure TTGAImage.FlipHorizontally;
var
  scanLine: array of Byte;
  i, j, x, w, h, pixelSize: Integer;
begin

  w := FHeader.ImgSpec.Width;
  h := FHeader.ImgSpec.Height;
  pixelSize := FHeader.ImgSpec.Depth div 8;

  SetLength(scanLine, w*pixelSize);

  for i := 0 to h - 1 do
  begin
    Move(FData[i*w*pixelSize], scanLine[0], w*pixelSize);
    for x := 0 to w div 2 do
    begin
      for j := 0 to pixelSize - 1 do
        scanLine[x*pixelSize + j] := scanLine[(w-1-x)*pixelSize + j];
    end;
  end;

end;

procedure TTGAImage.ExpandToTrueColor;
var
  i, n, base: Integer;
  hasPalette: Boolean;
  entry: Byte;
begin

  // Not an 8-bit image? Bail out.
  if FHeader.ImageType = 2 then Exit;

  hasPalette := FHeader.CMapType = 1;
  if hasPalette and (FHeader.CMapSpec.EntrySize <> 24) then
    raise Exception.Create('Unsupported color palette type!');

  base := FHeader.CMapSpec.FirstEntryIndex;
  n := Length(FData);

  FHeader.ImageType := 2;
  FHeader.ImgSpec.Depth := 24;
  FHeader.CMapType := 0;
  FillChar(FHeader.CMapSpec, SizeOf(FHeader.CMapSpec), 0);
  SetLength(FData, Length(FData)*3);

  // Convert the 8-bit pixels to 24-bit.
  for i := n - 1 downto 0 do
  begin
    entry := FData[i];
    if hasPalette then
    begin
      // Do a palette lookup.
      FData[i*3] := FPalette[entry*3 - base];
      FData[i*3+1] := FPalette[entry*3+1 - base];
      FData[i*3+2] := FPalette[entry*3+2 - base];
    end
    else begin
      // No palette, so just replicate the gray value to R, G and B.
      FData[i*3] := entry;
      FData[i*3+1] := entry;
      FData[i*3+2] := entry;
    end;
  end;

end;

procedure TTGAImage.BGRtoRGB;
var
  pixelSize, i: Integer;
  temp: Byte;
begin

  // Convert BGR(A) to RGB(A).
  pixelSize := FHeader.ImgSpec.Depth div 8;
  if pixelSize < 3 then
  begin
    // Convert the entries in the palette if the image is palettized.
    if FHeader.CMapType = 0 then Exit;
    for i := 0 to (Length(FPalette) div 3) - 1 do
    begin
      temp := FPalette[i*3];
      FPalette[i*3] := FPalette[i*3 + 2];
      FPalette[i*3+2] := temp;
    end;
  end
  else begin
    // Convert the pixel data if the image is not palettized.
    for i := 0 to (Length(FData) div pixelSize) - 1 do
    begin
      temp := FData[i*pixelSize];
      FData[i*pixelSize] := FData[i*pixelSize + 2];
      FData[i*pixelSize + 2] := temp;
    end;
  end;

end;

constructor TTGAImage.Create;
begin

  inherited Create;

  FillChar(FHeader, SizeOf(TTGAHeader), 0);
  SetLength(FData, 0);

end;

procedure TTGAImage.LoadFromStream(s: TStream);
var
  hasPalette, isRLE: Boolean;
  pixelSize: Integer;
begin

  s.Read(FHeader, SizeOf(TTGAHeader));

  hasPalette := FHeader.CMapType = 1;
  isRLE := FHeader.ImageType >= 9;
  pixelSize := FHeader.ImgSpec.Depth div 8;

  if hasPalette then
  begin
    with FHeader.CMapSpec do SetLength(FPalette, Length*EntrySize div 8);
    s.Read(FPalette[0], Length(FPalette));
  end;

  if isRLE then RLEDecode(s)
  else begin
    SetLength(FData, FHeader.ImgSpec.Width * FHeader.ImgSpec.Height * pixelSize);
    s.Read(FData[0], Length(FData));
  end;

  // If necessary, flip the image so that it's oriented the way the GL likes it.
  if (FHeader.ImgSpec.Desc and (1 shl 4)) <> 0 then FlipHorizontally;
  if (FHeader.ImgSpec.Desc and (1 shl 5)) <> 0 then FlipVertically;

end;

procedure TTGAImage.LoadFromFile(filename: String);
var
  s: TFileStream;
begin

  s := TFileStream.Create(filename, fmOpenRead or fmShareDenyWrite);
  LoadFromStream(s);
  s.Free;

end;

destructor TTGAImage.Destroy;
begin

  SetLength(FData, 0);
  inherited Destroy;

end;

end.
