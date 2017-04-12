unit DispMode;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, Math, DotWindow, GLDraw;

type
  TDotDispModeDlg = class(TForm)
    chkFullscreen: TCheckBox;
    grpDispMode: TGroupBox;
    lblRes: TLabel;
    lblBPP: TLabel;
    lblRefresh: TLabel;
    grpPixelFormat: TGroupBox;
    cboResolution: TComboBox;
    cboColorDepth: TComboBox;
    cboRefreshRate: TComboBox;
    lblZBits: TLabel;
    lblSBits: TLabel;
    lblABits: TLabel;
    chkFSAA: TCheckBox;
    Label7: TLabel;
    cboDepthBits: TComboBox;
    cboStencilBits: TComboBox;
    cboAlphaBits: TComboBox;
    edtFSAASamples: TSpinEdit;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FFullScreen: Boolean;
    FDispW, FDispH, FDispBPP, FDispRefresh: Cardinal;
    FColorBits, FAlphaBits, FZBits, FStencilBits: Integer;
    FFSAA: Boolean;
    FFSAASamples: Integer;
    function EnumDM(w, h, bpp, refresh: Cardinal): Boolean;
  public
    property FullScreen: Boolean read FFullScreen;
    property DispWidth: Cardinal read FDispW;
    property DispHeight: Cardinal read FDispH;
    property DispDepth: Cardinal read FDispBPP;
    property DispRefresh: Cardinal read FDispRefresh;
    property ColorBits: Integer read FColorBits;
    property AlphaBits: Integer read FAlphaBits;
    property DepthBits: Integer read FZBits;
    property StencilBits: Integer read FStencilBits;
    property FSAA: Boolean read FFSAA;
    property FSAASamples: Integer read FFSAASamples;
  end;

var
  DotDispModeDlg: TDotDispModeDlg;

implementation

{$R *.dfm}

uses
  Main, System.UITypes;

function TDotDispModeDlg.EnumDM(w, h, bpp, refresh: Cardinal): Boolean;
var
  str: String;
begin

  // Display mode enumeration callback.

  Result := TRUE;

  // Skip useless display modes.
  if (bpp < 16) or (w < 640) then Exit;

  // Add information to combo boxes:

  // Resolution.
  str := Format('%dx%d', [w, h]);
  if cboResolution.Items.IndexOf(str) = -1 then
    cboResolution.Items.Add(str);

  // Color depth.
  str := Format('%d bpp', [bpp]);
  if cboColorDepth.Items.IndexOf(str) = -1 then
    cboColorDepth.Items.Add(str);

  // Refresh rate.
  str := Format('%d Hz', [refresh]);
  if cboRefreshRate.Items.IndexOf(str) = -1 then
    cboRefreshRate.Items.Add(str);

end;

procedure TDotDispModeDlg.FormCreate(Sender: TObject);
begin

  // Enumerate the available display modes.
  dotEnumerateDisplayModes(EnumDM);

  // Set defaults.
  cboResolution.ItemIndex := cboResolution.Items.IndexOf('1024x768');
  cboColorDepth.ItemIndex := cboColorDepth.Items.IndexOf('32 bpp');
  cboRefreshRate.ItemIndex := cboRefreshRate.Items.IndexOf('70 Hz');

end;

procedure TDotDispModeDlg.btnOKClick(Sender: TObject);
begin

  FFullScreen := chkFullscreen.Checked;

  FDispW := StrToInt(Copy(cboResolution.Text, 1, Pos('x', cboResolution.Text)-1));
  FDispH := StrToInt(Copy(cboResolution.Text, Pos('x', cboResolution.Text)+1, 10));
  FDispBPP := StrToInt(Copy(cboColorDepth.Text, 1, Pos(' ', cboColorDepth.Text)-1));
  FDispRefresh := StrToInt(Copy(cboRefreshRate.Text, 1, Pos(' ', cboRefreshRate.Text)-1));

  FColorBits := Min(FDispBPP, 24);
  FAlphaBits := StrToInt(cboAlphaBits.Text);
  FZBits := StrToInt(cboDepthBits.Text);
  FStencilBits := StrToInt(cboStencilBits.Text);

  FFSAA := chkFSAA.Checked;
  FFSAASamples := edtFSAASamples.Value;

  // If the user clicks OK, we open up the main window.
  try
    // Switch display mode if necessary.
    if FFullScreen then
    begin
      if not dotSetDisplayMode(DispWidth, DispHeight, DispDepth, DispRefresh) then
      begin
        raise Exception.Create('Could not switch to the requested screen resolution.'
                               + #13#10 + 'Please try to use different settings.');
      end;
    end;
    // Hide this window...
    Hide;
    // ... and open the main one.
    Delphi3DForm := TDelphi3DForm.Create(Self);
    Delphi3DForm.ShowModal;
    Delphi3DForm.Free;
    // Terminate when the main window closes.
    Close;
  except on E: Exception do
    begin
      // If something goes wrong, restore this window.
      dotSetDisplayMode(0, 0, 0, 0);
      Delphi3DForm.Free;
      Show;
      MessageDlg(E.Message, mtError, [mbOK], 0);
    end;
  end;

end;

procedure TDotDispModeDlg.btnCancelClick(Sender: TObject);
begin

  Close;

end;

end.
