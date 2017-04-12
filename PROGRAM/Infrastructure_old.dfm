object FileSetupForm: TFileSetupForm
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsDialog
  Caption = 'SLAMM Infrastructures File Setup'
  ClientHeight = 748
  ClientWidth = 795
  Color = clGradientInactiveCaption
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label5: TLabel
    Left = 20
    Top = 327
    Width = 118
    Height = 13
    Caption = 'Raster Output Sites File:'
  end
  object Label7: TLabel
    Left = 74
    Top = 375
    Width = 64
    Height = 13
    Caption = 'VDATUM File:'
  end
  object Label8: TLabel
    Left = 33
    Top = 423
    Width = 107
    Height = 13
    Alignment = taRightJustify
    Caption = ' Uplift, Subidence File:'
  end
  object Label9: TLabel
    Left = 25
    Top = 556
    Width = 113
    Height = 13
    Alignment = taRightJustify
    Caption = 'Base Output File Name:'
  end
  object Label15: TLabel
    Left = 90
    Top = 341
    Width = 46
    Height = 13
    Caption = '(optional)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label16: TLabel
    Left = 90
    Top = 389
    Width = 46
    Height = 13
    Caption = '(optional)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label17: TLabel
    Left = 90
    Top = 434
    Width = 46
    Height = 13
    Caption = '(optional)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object FN6: TLabel
    Left = 153
    Top = 349
    Width = 48
    Height = 13
    Caption = 'File Note1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object FN7: TLabel
    Left = 153
    Top = 397
    Width = 48
    Height = 13
    Caption = 'File Note1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object FN8: TLabel
    Left = 153
    Top = 445
    Width = 48
    Height = 13
    Caption = 'File Note1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object FN9: TLabel
    Left = 153
    Top = 575
    Width = 48
    Height = 13
    Caption = 'File Note1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object Label18: TLabel
    Left = 14
    Top = 471
    Width = 126
    Height = 13
    Alignment = taRightJustify
    Caption = 'Salinity Raster File (base):'
  end
  object Label19: TLabel
    Left = 90
    Top = 482
    Width = 46
    Height = 13
    Caption = '(optional)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object SalFN: TLabel
    Left = 153
    Top = 493
    Width = 48
    Height = 13
    Caption = 'File Note1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGray
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object FileEdit6: TEdit
    Left = 151
    Top = 327
    Width = 549
    Height = 24
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnChange = FileEdit9Change
  end
  object FileEdit7: TEdit
    Left = 151
    Top = 375
    Width = 549
    Height = 24
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnChange = FileEdit9Change
  end
  object FileEdit8: TEdit
    Left = 151
    Top = 423
    Width = 549
    Height = 24
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnChange = FileEdit9Change
  end
  object FileEdit9: TEdit
    Left = 148
    Top = 551
    Width = 549
    Height = 24
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OnChange = FileEdit9Change
  end
  object Button6: TButton
    Left = 703
    Top = 327
    Width = 60
    Height = 19
    Caption = 'Browse'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnClick = Button1Click
  end
  object Button7: TButton
    Left = 703
    Top = 375
    Width = 60
    Height = 19
    Caption = 'Browse'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    OnClick = Button1Click
  end
  object Button8: TButton
    Left = 703
    Top = 423
    Width = 60
    Height = 19
    Caption = 'Browse'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    OnClick = Button1Click
  end
  object Button9: TButton
    Left = 703
    Top = 554
    Width = 60
    Height = 19
    Caption = 'Browse'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
    OnClick = Button1Click
  end
  object CheckValidityButton: TButton
    Left = 366
    Top = 655
    Width = 170
    Height = 24
    Caption = 'Re-check Files'#39' Validity'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 8
    OnClick = CheckValidityButtonClick
  end
  object OKButton10: TButton
    Left = 676
    Top = 654
    Width = 79
    Height = 27
    Caption = '&OK'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ModalResult = 1
    ParentFont = False
    TabOrder = 9
  end
  object CancelButton: TButton
    Left = 565
    Top = 654
    Width = 79
    Height = 27
    Caption = '&Cancel'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 10
    OnClick = CancelButtonClick
  end
  object HelpButton: TBitBtn
    Left = 731
    Top = 618
    Width = 32
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
  object SalRaster: TEdit
    Left = 148
    Top = 464
    Width = 549
    Height = 24
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 12
    OnChange = FileEdit9Change
  end
  object ButtonSal: TButton
    Left = 703
    Top = 472
    Width = 60
    Height = 19
    Caption = 'Browse'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 13
    OnClick = Button1Click
  end
  object SaveButton: TButton
    Left = 584
    Top = 698
    Width = 157
    Height = 27
    Hint = 'Model Will not be Executed'
    Caption = 'Save simulation'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 14
    OnClick = SaveButtonClick
  end
  object Panel1: TPanel
    Left = 66
    Top = 8
    Width = 697
    Height = 127
    Color = clGradientActiveCaption
    ParentBackground = False
    TabOrder = 15
    object Label6: TLabel
      Left = 64
      Top = 13
      Width = 122
      Height = 16
      Caption = 'Dikes and Levees File'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object FN4: TLabel
      Left = 67
      Top = 62
      Width = 48
      Height = 13
      Caption = 'File Note1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      Visible = False
    end
    object Label13: TLabel
      Left = 192
      Top = 15
      Width = 46
      Height = 13
      Caption = '(optional)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object FileEdit4: TEdit
      Left = 67
      Top = 32
      Width = 545
      Height = 24
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnChange = FileEdit9Change
    end
    object Button4: TButton
      Left = 620
      Top = 38
      Width = 60
      Height = 19
      Caption = 'Browse'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = Button1Click
    end
    object DikeCasePanel: TPanel
      Left = 64
      Top = 81
      Width = 547
      Height = 32
      Color = 14215660
      ParentBackground = False
      TabOrder = 2
      object ClassicDikeCaseRadioButton: TRadioButton
        Left = 28
        Top = 9
        Width = 218
        Height = 17
        Caption = 'Classic dike raster (protected areas)'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = DikeCaseRadioButtonClick
      end
      object DikeLocationCaseRadioButton: TRadioButton
        Left = 268
        Top = 9
        Width = 269
        Height = 17
        Caption = 'Dike location raster (dike locations and height)'
        TabOrder = 1
        OnClick = DikeCaseRadioButtonClick
      end
    end
  end
  object Panel2: TPanel
    Left = 66
    Top = 160
    Width = 697
    Height = 89
    Color = clGradientActiveCaption
    ParentBackground = False
    TabOrder = 16
    object Label4: TLabel
      Left = 60
      Top = 17
      Width = 53
      Height = 16
      Caption = 'Road File'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label14: TLabel
      Left = 119
      Top = 17
      Width = 46
      Height = 13
      Caption = '(optional)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object FN5: TLabel
      Left = 60
      Top = 66
      Width = 48
      Height = 13
      Caption = 'File Note1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      Visible = False
    end
    object FileEdit5: TEdit
      Left = 60
      Top = 36
      Width = 549
      Height = 24
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnChange = FileEdit9Change
    end
    object Button5: TButton
      Left = 617
      Top = 41
      Width = 60
      Height = 19
      Caption = 'Browse'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'asc or txt file (*.txt, *.asc)|*.txt;*.asc|any file (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Select File:'
  end
end
