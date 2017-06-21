object ExecuteOptionForm: TExecuteOptionForm
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  Caption = 'SLAMM Execution Options'
  ClientHeight = 734
  ClientWidth = 712
  Color = 15066597
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object SLRPanel: TPanel
    Left = 27
    Top = 17
    Width = 364
    Height = 244
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Ctl3D = True
    ParentBackground = False
    ParentCtl3D = False
    TabOrder = 0
    object Label4: TLabel
      Left = 7
      Top = 4
      Width = 135
      Height = 16
      Caption = 'SLR scenarios to Run'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Bevel2: TBevel
      Left = 195
      Top = 45
      Width = 150
      Height = 20
      ParentShowHint = False
      Shape = bsBottomLine
      ShowHint = False
    end
    object CustomSLRLabel: TLabel
      Left = 197
      Top = 38
      Width = 107
      Height = 14
      Caption = '(none selected to run)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object CustomButton: TButton
      Left = 7
      Top = 36
      Width = 154
      Height = 21
      Caption = 'NYS/ESVA SLR Scenarios'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = CustomButtonClick
    end
    object IPCCPanel: TPanel
      Left = -3
      Top = 75
      Width = 355
      Height = 167
      BevelOuter = bvNone
      ParentBackground = False
      ParentColor = True
      TabOrder = 1
      object Label6: TLabel
        Left = 24
        Top = -1
        Width = 62
        Height = 16
        Caption = 'IPCC 2001'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Label7: TLabel
        Left = 93
        Top = 0
        Width = 59
        Height = 16
        Caption = 'Estimates'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Label10: TLabel
        Left = 208
        Top = 5
        Width = 125
        Height = 42
        AutoSize = False
        Caption = 'Fixed Rise by 2100 (base year 1990)'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object Label1: TLabel
        Left = 274
        Top = 129
        Width = 61
        Height = 15
        Caption = 'm  by 2100'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label9: TLabel
        Left = 148
        Top = 148
        Width = 172
        Height = 14
        Caption = 'One or more levels e.g. 0.5, 1.4, 1.8'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Bevel1: TBevel
        Left = 164
        Top = 9
        Width = 14
        Height = 102
        ParentShowHint = False
        Shape = bsRightLine
        ShowHint = False
      end
      object A1B: TCheckBox
        Left = 32
        Top = 19
        Width = 68
        Height = 24
        Caption = 'A1B'
        Checked = True
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        State = cbChecked
        TabOrder = 0
        OnClick = A1BClick
      end
      object A1T: TCheckBox
        Left = 32
        Top = 41
        Width = 68
        Height = 25
        Caption = 'A1T'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        OnClick = A1BClick
      end
      object A1F1: TCheckBox
        Left = 32
        Top = 64
        Width = 68
        Height = 25
        Caption = 'A1F1'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        OnClick = A1BClick
      end
      object A2: TCheckBox
        Left = 32
        Top = 86
        Width = 68
        Height = 24
        Caption = 'A2'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
        OnClick = A1BClick
      end
      object B1: TCheckBox
        Left = 32
        Top = 109
        Width = 68
        Height = 25
        Caption = 'B1'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 4
        OnClick = A1BClick
      end
      object B2: TCheckBox
        Left = 32
        Top = 131
        Width = 68
        Height = 25
        Caption = 'B2'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 5
        OnClick = A1BClick
      end
      object Min: TCheckBox
        Left = 89
        Top = 20
        Width = 68
        Height = 24
        Caption = 'Min'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 6
        OnClick = A1BClick
      end
      object Mean: TCheckBox
        Left = 89
        Top = 42
        Width = 68
        Height = 25
        Caption = 'Mean'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 7
        OnClick = A1BClick
      end
      object Max: TCheckBox
        Left = 89
        Top = 65
        Width = 68
        Height = 25
        Caption = 'Max'
        Checked = True
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        State = cbChecked
        TabOrder = 8
        OnClick = A1BClick
      end
      object fix1: TCheckBox
        Left = 209
        Top = 39
        Width = 68
        Height = 24
        Caption = '1 meter'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 9
        OnClick = A1BClick
      end
      object fix15: TCheckBox
        Left = 209
        Top = 59
        Width = 85
        Height = 25
        Caption = '1.5 meters'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 10
        OnClick = A1BClick
      end
      object fix2: TCheckBox
        Left = 209
        Top = 82
        Width = 68
        Height = 25
        Caption = '2 meters'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 11
        OnClick = A1BClick
      end
      object CustomMeters: TCheckBox
        Left = 118
        Top = 123
        Width = 68
        Height = 25
        Caption = 'Custom'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 12
        OnClick = A1BClick
      end
      object CustomEdit: TEdit
        Left = 185
        Top = 125
        Width = 84
        Height = 24
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 13
        Text = '1.79'
        OnExit = CustomEditExit
      end
    end
    object CustomSLR: TButton
      Left = 194
      Top = 5
      Width = 154
      Height = 28
      Caption = 'Custom SLR Time Series'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = CustomSLRClick
    end
  end
  object Panel3: TPanel
    Left = 411
    Top = 17
    Width = 269
    Height = 114
    BevelOuter = bvNone
    BorderStyle = bsSingle
    ParentBackground = False
    TabOrder = 1
    object ProtectionPanel: TLabel
      Left = 29
      Top = 9
      Width = 177
      Height = 16
      Caption = 'Protection Scenarios to Run'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object ProtectAllBox: TCheckBox
      Left = 38
      Top = 77
      Width = 153
      Height = 25
      Caption = '  Protect All Dry Land'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = A1BClick
    end
    object ProtectDevBox: TCheckBox
      Left = 38
      Top = 55
      Width = 187
      Height = 25
      Caption = '  Protect Developed Dry Land'
      Checked = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      State = cbChecked
      TabOrder = 1
      OnClick = A1BClick
    end
    object DontProtectBox: TCheckBox
      Left = 38
      Top = 34
      Width = 165
      Height = 25
      Caption = '  Don'#39't Protect'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = A1BClick
    end
  end
  object Panel4: TPanel
    Left = 411
    Top = 138
    Width = 269
    Height = 183
    BevelOuter = bvNone
    BorderStyle = bsSingle
    ParentBackground = False
    TabOrder = 2
    object LastYearLabel: TLabel
      Left = 16
      Top = 81
      Width = 147
      Height = 16
      Caption = 'Last Year of Simulation'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object TimeStepLabel: TLabel
      Left = 55
      Top = 42
      Width = 111
      Height = 16
      Caption = 'Time Step (years)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 65
      Top = 158
      Width = 118
      Height = 16
      Caption = 'e.g. 2050,2075,2100'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object RunNWI: TCheckBox
      Left = 17
      Top = 10
      Width = 240
      Height = 17
      Caption = ' Run Model for NWI Photo Date (T0)'
      Checked = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      State = cbChecked
      TabOrder = 0
      Visible = False
      OnClick = A1BClick
    end
    object LastYearEdit: TEdit
      Left = 171
      Top = 80
      Width = 68
      Height = 24
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      Text = '  2100'
      OnExit = TimeStepEditExit
    end
    object TimeStepEdit: TEdit
      Left = 171
      Top = 39
      Width = 68
      Height = 24
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      Text = '  25'
      OnExit = TimeStepEditExit
    end
    object SpecificYearsEdit: TEdit
      Left = 12
      Top = 133
      Width = 232
      Height = 24
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Text = '  2100'
      OnChange = SpecificYearsEditChange
      OnExit = SpecificYearsEditExit
    end
    object RunSpecificYearsBox: TCheckBox
      Left = 17
      Top = 113
      Width = 240
      Height = 17
      Caption = ' Run Model for Specific Years'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      OnClick = A1BClick
    end
  end
  object Panel7: TPanel
    Left = 26
    Top = 431
    Width = 365
    Height = 81
    BevelOuter = bvNone
    BorderStyle = bsSingle
    ParentBackground = False
    TabOrder = 3
    object DikeBox: TCheckBox
      Left = 10
      Top = 3
      Width = 153
      Height = 25
      Caption = 'Include Dikes'
      Checked = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      State = cbChecked
      TabOrder = 0
      OnClick = A1BClick
    end
    object SoilSatBox: TCheckBox
      Left = 10
      Top = 26
      Width = 129
      Height = 25
      Caption = 'Use Soil Saturation'
      Checked = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      State = cbChecked
      TabOrder = 1
      OnClick = A1BClick
    end
    object NoDataBlanksBox: TCheckBox
      Left = 148
      Top = 3
      Width = 202
      Height = 25
      Caption = 'No-Data Elevs Loaded as Blanks'
      Checked = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      State = cbChecked
      TabOrder = 2
      OnClick = A1BClick
    end
    object UseBruunBox: TCheckBox
      Left = 10
      Top = 49
      Width = 263
      Height = 25
      Caption = 'Use Bruun Rule for "Ocean Beach" Erosion'
      Checked = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      State = cbChecked
      TabOrder = 3
      OnClick = A1BClick
    end
  end
  object ExecuteButton: TButton
    Left = 503
    Top = 662
    Width = 177
    Height = 36
    Hint = 'Execute the model with the options shown above'
    Caption = '&Execute'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    OnClick = ExecuteButtonClick
  end
  object SaveButton: TButton
    Left = 135
    Top = 657
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
    TabOrder = 5
    OnClick = SaveButtonClick
  end
  object Panel2: TPanel
    Left = 411
    Top = 330
    Width = 269
    Height = 113
    BevelOuter = bvNone
    BorderStyle = bsSingle
    ParentBackground = False
    TabOrder = 6
    object Label5: TLabel
      Left = 14
      Top = 5
      Width = 71
      Height = 15
      Caption = 'Data to Save'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object SaveGIS: TRadioButton
      Left = 19
      Top = 49
      Width = 164
      Height = 18
      Caption = 'Save Output for GIS'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = SaveTabularClick
    end
    object SaveTabular: TRadioButton
      Left = 19
      Top = 28
      Width = 164
      Height = 15
      Caption = 'Save Tabular Data Only'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = SaveTabularClick
    end
    object GISOptions: TButton
      Left = 158
      Top = 45
      Width = 101
      Height = 26
      Caption = 'GIS File Options'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = GISOptionsClick
    end
    object RunRecordBox: TCheckBox
      Left = 20
      Top = 86
      Width = 233
      Height = 17
      Caption = ' Save Comprehensive Run Record File'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = A1BClick
    end
  end
  object Panel5: TPanel
    Left = 27
    Top = 267
    Width = 364
    Height = 159
    BevelOuter = bvNone
    BorderStyle = bsSingle
    ParentBackground = False
    TabOrder = 7
    object displaymaps: TRadioButton
      Left = 13
      Top = 6
      Width = 210
      Height = 18
      Caption = ' Display Maps on screen'
      Checked = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      TabStop = True
      OnClick = displaymapsClick
    end
    object NoMaps: TRadioButton
      Left = 13
      Top = 134
      Width = 226
      Height = 15
      Caption = ' No Maps (Quicker Execution)'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = displaymapsClick
    end
    object QABox: TCheckBox
      Left = 28
      Top = 23
      Width = 221
      Height = 25
      Caption = 'Pause with Examination Tools'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = A1BClick
    end
    object AutoPasteMaps: TCheckBox
      Left = 28
      Top = 42
      Width = 221
      Height = 25
      Caption = 'Automatically Paste Maps to Word'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = A1BClick
    end
    object ROSResize: TComboBox
      Left = 248
      Top = 45
      Width = 98
      Height = 19
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      Text = '1x Output'
      OnChange = ROSResizeChange
      Items.Strings = (
        '0.25 x Output'
        '0.50 x Output'
        '1x Output'
        '2x Output'
        '3x Output'
        '4x Output')
    end
    object SaveToGIF: TCheckBox
      Left = 28
      Top = 61
      Width = 175
      Height = 21
      Caption = 'Save Maps to GIF Files'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      OnClick = A1BClick
    end
    object ExtraMapsOptButton: TButton
      Left = 28
      Top = 88
      Width = 175
      Height = 25
      Caption = 'Extra maps to save'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
      OnClick = ExtraMapsOptButtonClick
    end
  end
  object HelpButton: TBitBtn
    Left = 27
    Top = 668
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
    TabOrder = 8
    TabStop = False
    OnClick = HelpButtonClick
  end
  object CancelButton: TButton
    Left = 355
    Top = 671
    Width = 90
    Height = 27
    Hint = 'Discards all changes to inputs on this screen.'
    Caption = 'Cancel'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 9
    OnClick = CancelButtonClick
  end
  object Panel8: TPanel
    Left = 411
    Top = 539
    Width = 269
    Height = 111
    BevelOuter = bvNone
    BorderStyle = bsSingle
    ParentBackground = False
    TabOrder = 10
    object UncertaintySetupButton: TButton
      Left = 48
      Top = 48
      Width = 214
      Height = 27
      Hint = 'Model Will not be Executed'
      Caption = 'Uncertainty / Sensitivity Setup'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = UncertaintySetupButtonClick
    end
    object RunLHCheckBox: TCheckBox
      Left = 8
      Top = 5
      Width = 233
      Height = 17
      Caption = 'Run Latin-Hypercube Analysis'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = A1BClick
    end
    object RunSensBox: TCheckBox
      Left = 8
      Top = 28
      Width = 233
      Height = 17
      Caption = 'Run Sensitivity Analysis'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = A1BClick
    end
    object CellSizeBox: TComboBox
      Left = 11
      Top = 81
      Width = 146
      Height = 19
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemIndex = 0
      ParentFont = False
      TabOrder = 3
      Text = '1x Cell Size'
      OnChange = CellSizeBoxChange
      Items.Strings = (
        '1x Cell Size'
        '2x Cell Size (400% faster)'
        '3x Cell Size (900% faster)')
    end
  end
  object Button1: TButton
    Left = 135
    Top = 690
    Width = 157
    Height = 27
    Hint = 'Model Will not be Executed'
    Caption = 'Return to Main Menu'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ModalResult = 6
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 11
  end
  object Panel1: TPanel
    Left = 26
    Top = 580
    Width = 365
    Height = 70
    BevelOuter = bvNone
    BorderStyle = bsSingle
    ParentBackground = False
    TabOrder = 12
    object Label3: TLabel
      Left = 21
      Top = 12
      Width = 137
      Height = 16
      Caption = 'Optional Land Covers'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object UseFloodForestBox: TCheckBox
      Left = 241
      Top = 34
      Width = 187
      Height = 25
      Caption = ' Flooded Forest'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = A1BClick
    end
    object UseFloodDevDryLandBox: TCheckBox
      Left = 21
      Top = 34
      Width = 196
      Height = 25
      Caption = ' Flooded Developed Dry Land'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = A1BClick
    end
  end
  object Panel6: TPanel
    Left = 411
    Top = 452
    Width = 269
    Height = 78
    BevelOuter = bvNone
    BorderStyle = bsSingle
    ParentBackground = False
    TabOrder = 13
    object Label8: TLabel
      Left = 14
      Top = 3
      Width = 186
      Height = 15
      Caption = 'Area to Save (Tabular and/or GIS)'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object SaveAllArea: TRadioButton
      Left = 19
      Top = 28
      Width = 164
      Height = 15
      Caption = 'Save entire study area'
      Checked = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      TabStop = True
      OnClick = SaveAreaClick
    end
    object SaveROSArea: TRadioButton
      Left = 19
      Top = 48
      Width = 238
      Height = 18
      Caption = 'Save only ROS area'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = SaveAreaClick
    end
  end
  object Panel9: TPanel
    Left = 26
    Top = 516
    Width = 365
    Height = 60
    BevelOuter = bvNone
    BorderStyle = bsSingle
    ParentBackground = False
    TabOrder = 14
    object ConnectivityBox: TCheckBox
      Left = 18
      Top = 10
      Width = 126
      Height = 41
      Caption = 'Use Connectivity Algorithm'
      Checked = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      State = cbChecked
      TabOrder = 0
      WordWrap = True
      OnClick = A1BClick
    end
    object MinElevConnectBOx: TComboBox
      Left = 150
      Top = 8
      Width = 138
      Height = 19
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnChange = MinElevConnectBoxChange
      Items.Strings = (
        'Average cell elevation'
        'Minimum cell elevation')
    end
    object EightNearConnectBox: TComboBox
      Left = 150
      Top = 32
      Width = 138
      Height = 19
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnChange = EightNearConnectBoxChange
      Items.Strings = (
        '4 nearest neighbors'
        '8 nearest neighbors')
    end
  end
end
