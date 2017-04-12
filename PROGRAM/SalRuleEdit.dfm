object SalRuleForm: TSalRuleForm
  Left = 10
  Top = 10
  Caption = 'Edit Salinity Rules'
  ClientHeight = 283
  ClientWidth = 559
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  PixelsPerInch = 96
  TextHeight = 13
  object ModLabel: TLabel
    Left = 6
    Top = 4
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
  object NameLabel: TLabel
    Left = 51
    Top = 188
    Width = 39
    Height = 16
    Caption = 'Notes:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 51
    Top = 23
    Width = 77
    Height = 16
    Caption = 'Select Rule:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label1: TLabel
    Left = 51
    Top = 63
    Width = 98
    Height = 16
    Caption = 'When Category'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 51
    Top = 143
    Width = 126
    Height = 16
    Caption = 'Convert to Category'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 334
    Top = 100
    Width = 40
    Height = 16
    Caption = 'at tide'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 51
    Top = 99
    Width = 164
    Height = 16
    Caption = '                     Salinity (ppt)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object OKBtn: TButton
    Left = 428
    Top = 241
    Width = 83
    Height = 25
    Caption = 'OK'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ModalResult = 1
    ParentFont = False
    TabOrder = 8
  end
  object CancelBtn: TButton
    Left = 308
    Top = 241
    Width = 81
    Height = 25
    Caption = 'Cancel'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 7
    OnClick = CancelBtnClick
  end
  object NotesEdit: TEdit
    Left = 180
    Top = 184
    Width = 269
    Height = 24
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    OnChange = NotesEditChange
  end
  object PPTEdit: TEdit
    Left = 232
    Top = 97
    Width = 81
    Height = 24
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnExit = TSwampEditExit
  end
  object RuleBox: TComboBox
    Left = 180
    Top = 17
    Width = 269
    Height = 24
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnChange = RuleBoxChange
  end
  object NewButton: TButton
    Left = 469
    Top = 16
    Width = 67
    Height = 24
    Caption = 'New'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 9
    OnClick = NewButtonClick
  end
  object FromBox: TComboBox
    Left = 204
    Top = 57
    Width = 175
    Height = 24
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnChange = FromBoxChange
  end
  object ToBox: TComboBox
    Left = 204
    Top = 137
    Width = 175
    Height = 24
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    OnChange = ToBoxChange
  end
  object TideBox: TComboBox
    Left = 380
    Top = 96
    Width = 83
    Height = 24
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    Text = 'MLLW'
    OnChange = TideBoxChange
    Items.Strings = (
      'MLLW'
      'MTL'
      'MHHW'
      '30 day')
  end
  object GreaterThanBox: TComboBox
    Left = 27
    Top = 96
    Width = 101
    Height = 24
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ItemIndex = 0
    ParentFont = False
    TabOrder = 2
    Text = 'Exceeds'
    OnChange = GreaterThanBoxChange
    Items.Strings = (
      'Exceeds'
      'Is Less Than')
  end
  object DelButt: TButton
    Left = 469
    Top = 48
    Width = 67
    Height = 24
    Caption = 'Delete'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 10
    OnClick = DelButtClick
  end
  object HelpButton: TBitBtn
    Left = 230
    Top = 238
    Width = 31
    Height = 30
    Hint = 'Context Sensitive Help'
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
    TabOrder = 11
    TabStop = False
    OnClick = HelpButtonClick
  end
end
