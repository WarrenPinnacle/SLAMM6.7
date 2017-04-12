object FWFlowEdit: TFWFlowEdit
  Left = 0
  Top = 0
  Caption = 'Edit Freshwater Flow Characteristics'
  ClientHeight = 630
  ClientWidth = 596
  Color = clBtnFace
  Constraints.MinHeight = 513
  Constraints.MinWidth = 576
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    596
    630)
  PixelsPerInch = 96
  TextHeight = 13
  object ModLabel: TLabel
    Left = 31
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
  object Label3: TLabel
    Left = 99
    Top = 39
    Width = 79
    Height = 16
    Caption = 'Select Flow:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object ExtentOnlyWarning: TLabel
    Left = 91
    Top = 101
    Width = 417
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Caption = 'Set up as Fresh Water Extent Only, Parameters will not be used.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object Panel1: TPanel
    Left = 31
    Top = 63
    Width = 533
    Height = 511
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 4
    DesignSize = (
      533
      511)
    object OriginLabel: TLabel
      Left = 68
      Top = 480
      Width = 197
      Height = 16
      Anchors = [akLeft, akBottom]
      Caption = 'Origin of Salt Wedge (river km)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label9: TLabel
      Left = 93
      Top = 391
      Width = 294
      Height = 45
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 
        'To delete a record, click on record and  press <Ctrl> <Del>   To' +
        ' insert, click on table and press <Ctrl><Ins>                   ' +
        'Data may be pasted into existing cells from Excel.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object TurbLabel: TLabel
      Left = 22
      Top = 172
      Width = 159
      Height = 16
      Caption = 'Turbidity Factor (unitless)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object MeanFlowLabel: TLabel
      Left = 277
      Top = 172
      Width = 150
      Height = 16
      Caption = 'Mean Flow (cubic m / s)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label1: TLabel
      Left = 79
      Top = 59
      Width = 244
      Height = 16
      Caption = 'Tidal Swamp Max Elev (m above MTL)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object NameLabel: TLabel
      Left = 43
      Top = 19
      Width = 41
      Height = 16
      Caption = 'Name:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 94
      Top = 450
      Width = 171
      Height = 16
      Anchors = [akLeft, akBottom]
      Caption = 'Slope of Salt Wedge (m/m)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 53
      Top = 88
      Width = 270
      Height = 16
      Caption = 'Salinity of upstream fresh water input (ppt)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 124
      Top = 117
      Width = 198
      Height = 16
      Caption = 'Salinity of salt water input (ppt)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 357
      Top = 467
      Width = 172
      Height = 40
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 
        'If set to zero, origin will be auto calculated to the drawn exte' +
        'nt of freshwater influence.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object SaltWedgeSlopeEdit: TEdit
      Left = 279
      Top = 448
      Width = 68
      Height = 24
      Anchors = [akLeft, akBottom]
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnExit = TSwampEditExit
    end
    object MeanFlowEdit: TStringGrid
      Left = 273
      Top = 192
      Width = 200
      Height = 193
      Anchors = [akLeft, akTop, akBottom]
      ColCount = 2
      FixedCols = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
      TabOrder = 1
      OnDrawCell = TurbEditDrawCell
      OnExit = TurbEditExit
      OnKeyDown = TurbEditKeyDown
      OnSelectCell = TurbEditSelectCell
      OnSetEditText = TurbEditSetEditText
    end
    object TurbEdit: TStringGrid
      Left = 25
      Top = 192
      Width = 210
      Height = 193
      Anchors = [akLeft, akTop, akBottom]
      ColCount = 2
      FixedCols = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
      ParentFont = False
      TabOrder = 2
      OnDrawCell = TurbEditDrawCell
      OnExit = TurbEditExit
      OnKeyDown = TurbEditKeyDown
      OnSelectCell = TurbEditSelectCell
      OnSetEditText = TurbEditSetEditText
    end
    object UseTurbiditybox: TCheckBox
      Left = 25
      Top = 150
      Width = 154
      Height = 17
      Caption = 'Use Turbidity Factor'
      Checked = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      State = cbChecked
      TabOrder = 3
      OnClick = UseTurbidityboxClick
    end
    object TSwampEdit: TEdit
      Left = 340
      Top = 57
      Width = 68
      Height = 24
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnExit = TSwampEditExit
    end
    object NameEdit: TEdit
      Left = 172
      Top = 15
      Width = 200
      Height = 24
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      OnChange = NameEditChange
    end
    object OriginEdit: TEdit
      Left = 279
      Top = 477
      Width = 68
      Height = 24
      Anchors = [akLeft, akBottom]
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      OnExit = TSwampEditExit
    end
    object PPTEdit: TEdit
      Left = 340
      Top = 86
      Width = 68
      Height = 24
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 7
      OnExit = TSwampEditExit
    end
    object ASaltSalinEdit: TEdit
      Left = 340
      Top = 115
      Width = 68
      Height = 24
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 8
      OnExit = TSwampEditExit
    end
  end
  object OKBtn: TButton
    Left = 474
    Top = 594
    Width = 83
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
  object CancelBtn: TButton
    Left = 365
    Top = 594
    Width = 81
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = CancelBtnClick
  end
  object FWFlowBox: TComboBox
    Left = 204
    Top = 33
    Width = 200
    Height = 24
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnChange = FWFlowBoxChange
  end
  object HelpButton: TBitBtn
    Left = 278
    Top = 591
    Width = 32
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
    TabOrder = 3
    TabStop = False
    OnClick = HelpButtonClick
  end
end
