object ElevAnalysisForm: TElevAnalysisForm
  Left = 0
  Top = 0
  Caption = 'Elevation Inputs and Analysis'
  ClientHeight = 649
  ClientWidth = 1097
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  DesignSize = (
    1097
    649)
  PixelsPerInch = 96
  TextHeight = 13
  object ModLabel: TLabel
    Left = 6
    Top = 8
    Width = 42
    Height = 12
    Caption = '(modified)'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -9
    Font.Name = 'Arial'
    Font.Pitch = fpFixed
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object Label1: TLabel
    Left = 18
    Top = 8
    Width = 211
    Height = 19
    Caption = 'Elevation Inputs and Analysis'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Pitch = fpFixed
    Font.Style = []
    ParentFont = False
  end
  object ElevAnalysisLabel: TLabel
    Left = 90
    Top = 575
    Width = 198
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'Last Elevation Analysis: 9/11/2009'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Pitch = fpFixed
    Font.Style = []
    ParentFont = False
    ExplicitTop = 629
  end
  object HTULabel: TLabel
    Left = 242
    Top = 11
    Width = 587
    Height = 16
    Caption = 
      'Elevation Inputs and Analysis (Diked areas and "pre-processed" a' +
      'reas are excluded from these stats.)'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Pitch = fpFixed
    Font.Style = []
    ParentFont = False
  end
  object RunElevWarning: TLabel
    Left = 34
    Top = 627
    Width = 372
    Height = 14
    Anchors = [akLeft, akBottom]
    Caption = 
      'To Run Elevation Analysis, Map Must Be Loaded through "Set Map A' +
      'ttributes" '
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Pitch = fpFixed
    Font.Style = []
    ParentFont = False
    Visible = False
    ExplicitTop = 681
  end
  object Label2: TLabel
    Left = 8
    Top = 33
    Width = 697
    Height = 16
    Caption = 
      'Elevation Inputs and Analysis (Diked areas, "pre-processed" area' +
      's and areas with no tide are excluded from these stats.)'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Pitch = fpFixed
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 840
    Top = 11
    Width = 33
    Height = 16
    Caption = 'Units:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 840
    Top = 38
    Width = 35
    Height = 16
    Caption = 'Zero: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 968
    Top = 17
    Width = 87
    Height = 16
    Caption = 'Site or subsite:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Button3: TButton
    Left = 984
    Top = 597
    Width = 83
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
  object Button4: TButton
    Left = 864
    Top = 684
    Width = 81
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = Button4Click
  end
  object TSGrid: TStringGrid
    Left = 28
    Top = 62
    Width = 1061
    Height = 508
    Anchors = [akLeft, akTop, akRight, akBottom]
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
    TabOrder = 2
    OnDblClick = TSGridDblClick
    OnDrawCell = TSGridDrawCell
    OnExit = TSGridExit
    OnKeyDown = TSGridKeyDown
    OnMouseDown = TSGridMouseDown
    OnSelectCell = TSGridSelectCell
    OnSetEditText = TSGridSetEditText
    ColWidths = (
      64
      64
      64
      64
      64)
  end
  object ElevAnalysis: TButton
    Left = 34
    Top = 596
    Width = 207
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Run Elevation Analysis (This Site)'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OnClick = ElevAnalysisClick
  end
  object ExcelExport: TButton
    Left = 499
    Top = 616
    Width = 122
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Export to Excel'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnClick = ExcelExportClick
  end
  object HelpButton: TBitBtn
    Left = 891
    Top = 594
    Width = 31
    Height = 30
    Hint = 'Context Sensitive Help'
    Anchors = [akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Pitch = fpFixed
    Font.Style = [fsBold]
    Glyph.Data = {
      A2070000424DA207000000000000360000002800000019000000190000000100
      1800000000006C07000000000000000000000000000000000000C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C000C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0B3B3B3A1A1A1A7A7A7404040404040ADA1ADA7A7A7C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C000C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C07C7C7C16161616161670
      70708743875A165A383838C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C06363634C
      4C4C4C4C4C545454737373BABABAB597B58245824C0F4C4C4C4CA8A8A8C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C000C0C0C0C0C0C0C0C0C0A7
      A7A78282828282823B3B3B353535686868B1B1B1D4D4D4D5D5D5C8C8C8AE8CAE
      7F317F290029706770A7A7A7C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C000C0C0C0C0C0C0BBBBBB7070700606060808086C6C6CAAAAAAD8D8D8F9F9F9
      F9F9F9949494A2A2A2BEBEBEB39BB38208821E011E706D70BBBBBBC0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C000C0C0C0C0C0C06868684242426B6B6B929292
      D0D0D0E9E9E9CFCFCF9E9E9E9E9E9E383838616161A2A2A2BCB6BCB092B0711D
      71421B42686868C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C000C0C0C0C0C0C0
      724D72573357929292DEDEDEC7C7C7C1C1C18F8F8F4242424242423E0D3E4027
      40686868A7A7A7C0C0C0A570A56425644C274C767676C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C000C0C0C0C0C0C0994D99803380949494E5E5E57F7F7F666666473D
      471A001A1A001A6B006B430043382838757575B3B3B3BDBDBDA164A15F175F33
      1E33999999B8B8B8C0C0C0C0C0C0C0C0C000C0C0C0C0C0C0994D998033808181
      818989892323230A0A0A3506357600767600767D007D7A007A4A034A22222285
      8585B4B4B4BDB7BD9F6A9F6102610F0F0F9C9C9CC0C0C0C0C0C0C0C0C000C0C0
      C0C0C0C0994D995F125F2E2E2E2E2E2E4A094A52005264006480008080008080
      00808000806D006D4A094A2E2E2E818181AFAFAFB6A4B6976297520052473647
      8E8E8EC0C0C0C0C0C000C0C0C0C0C0C0994D995F125F2E252E2E002E6F006F80
      00808000800AEAF4515CAE5137896D12808000806F006F2E002E4A404A858585
      B2B2B2A999A9510051100010727272C0C0C0C0C0C000C0C0C0C0C0C09C569C83
      3883806080800A80800280800080800080682E970AEAF40E999B4C428875148A
      7710888000802200224A464A9191919595950000000C0C0C797979C0C0C0C0C0
      C000C0C0C0C0C0C0B8A9B89E669E8028808066808014808000808000807A0A85
      6632998F99AD4DC2D119CCE52DA3D18000806B006B380F384747477070700000
      007A7A7AB0B0B0C0C0C0C0C0C000C0C0C0C0C0C0C0C0C0B39BB39A5C9A803D80
      804180801A80800080720D803D4380558B984C88B028AED70CE6F23D85C2721B
      8D5B005B401840303030000000999999C0C0C0C0C0C0C0C0C000C0C0C0C0C0C0
      C0C0C0C0C0C0B6A3B68F2E8F8356838039808012806C13801F61800692983964
      9E3A8AC500F8F800E0E0662D93800080590059180018000000999999C0C0C0C0
      C0C0C0C0C000C0C0C0C0C0C0C0C0C0C0C0C0BFBEBFBDB8BD8C298C804B808049
      807F00807B058018C8E102F7FA03F9FC00E6E6008484661B818000807E007E62
      0062000000999999C0C0C0C0C0C0C0C0C000C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0AF8FAF914D91803B808046808000805F40A05750A85750A85748A057
      28807708808000805D005D200020000000999999C0C0C0C0C0C0C0C0C000C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0A97BA98F4C8F80478080338080
      0A808000808000808000808000805600564C004C4C1E4C4D4D4D4D4D4DA8A8A8
      C0C0C0C0C0C0C0C0C000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0A97CA9862986807080802380800680790079700070700070291229171717
      5A5A5AC0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C000C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0BCB4BCAB85AB801480805A80802B80540054
      140014140014858185A2A2A2ADADADC0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0BAAFBA
      A46CA48742875416544C2B4C6C6C6C6C6C6CAEAEAEC0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C09B529B5B365B6C6C6CC0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C000C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C000}
    Margin = 1
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    Spacing = 7
    TabOrder = 5
    TabStop = False
    OnClick = HelpButtonClick
  end
  object HistFormButton: TButton
    Left = 499
    Top = 585
    Width = 161
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Show Histograms'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
    OnClick = HistFormButtonClick
  end
  object ElevUnitsBox: TComboBox
    Left = 879
    Top = 8
    Width = 74
    Height = 21
    ItemIndex = 0
    TabOrder = 7
    Text = 'HTU'
    OnChange = ElevUnixBoxChange
    Items.Strings = (
      'HTU'
      'm')
  end
  object ElevZeroBox: TComboBox
    Left = 881
    Top = 35
    Width = 72
    Height = 21
    ItemIndex = 0
    TabOrder = 8
    Text = 'MTL'
    OnChange = ElevZeroBoxChange
    Items.Strings = (
      'MTL'
      'MHHW'
      'MLLW'
      'NAVD88')
  end
  object ElevAreasBox: TComboBox
    Left = 964
    Top = 35
    Width = 121
    Height = 21
    ItemIndex = 0
    TabOrder = 9
    OnChange = ElevAreasBoxChange
    Items.Strings = (
      '')
  end
  object ElevAll: TButton
    Tag = 2
    Left = 255
    Top = 596
    Width = 138
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Run Elevs (All Sites)'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 10
    OnClick = ElevAnalysisClick
  end
  object SaveDialog1: TSaveDialog
    Filter = 
      'Paradox Format (*.db)|*.DB|DBase Format (*.dbf)|*.DBF|Text Forma' +
      't (*.prn)|*.PRN'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofCreatePrompt]
    Title = 'Export Results As:'
    Left = 10
    Top = 65535
  end
end
