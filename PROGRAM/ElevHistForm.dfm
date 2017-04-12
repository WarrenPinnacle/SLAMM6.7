object ElevHist: TElevHist
  Left = 0
  Top = 0
  Caption = 'ElevHist'
  ClientHeight = 606
  ClientWidth = 891
  Color = clBtnFace
  Constraints.MinHeight = 460
  Constraints.MinWidth = 890
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    891
    606)
  PixelsPerInch = 96
  TextHeight = 13
  object Chart1: TChart
    Left = 19
    Top = 16
    Width = 526
    Height = 582
    BackWall.Color = clWhite
    Legend.LegendStyle = lsSeries
    Title.Font.Color = clNavy
    Title.Font.Height = -13
    Title.Font.Style = [fsBold]
    Title.Text.Strings = (
      'Elevation Histogram')
    BottomAxis.Automatic = False
    BottomAxis.AutomaticMaximum = False
    BottomAxis.AutomaticMinimum = False
    BottomAxis.Grid.Visible = False
    BottomAxis.LabelsSeparation = 30
    BottomAxis.TicksInner.Visible = False
    BottomAxis.Title.Caption = 'Elevation (HTU)'
    DepthAxis.Automatic = False
    DepthAxis.AutomaticMaximum = False
    DepthAxis.AutomaticMinimum = False
    DepthAxis.Maximum = 2.809999999999996000
    DepthAxis.Minimum = 1.809999999999999000
    DepthTopAxis.Automatic = False
    DepthTopAxis.AutomaticMaximum = False
    DepthTopAxis.AutomaticMinimum = False
    DepthTopAxis.Maximum = 2.809999999999996000
    DepthTopAxis.Minimum = 1.809999999999999000
    LeftAxis.Grid.Visible = False
    LeftAxis.TicksInner.Visible = False
    LeftAxis.Title.Caption = 'Fraction'
    RightAxis.Automatic = False
    RightAxis.AutomaticMaximum = False
    RightAxis.AutomaticMinimum = False
    View3D = False
    TabOrder = 0
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColorPaletteIndex = 13
  end
  object Panel2: TPanel
    Left = 561
    Top = 12
    Width = 322
    Height = 329
    Anchors = [akTop, akRight]
    TabOrder = 1
    DesignSize = (
      322
      329)
    object CheckBox1: TCheckBox
      Left = 16
      Top = 4
      Width = 145
      Height = 17
      Caption = 'CheckBox1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = CheckBoxClick
    end
    object CheckBox2: TCheckBox
      Left = 16
      Top = 27
      Width = 145
      Height = 17
      Caption = 'CheckBox2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = CheckBoxClick
    end
    object CheckBox3: TCheckBox
      Left = 16
      Top = 50
      Width = 145
      Height = 17
      Caption = 'Swamp'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = CheckBoxClick
    end
    object CheckBox4: TCheckBox
      Left = 16
      Top = 73
      Width = 145
      Height = 17
      Caption = 'Cypress Swamp'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = CheckBoxClick
    end
    object CheckBox5: TCheckBox
      Left = 16
      Top = 96
      Width = 145
      Height = 17
      Caption = 'CheckBox5'
      TabOrder = 4
      OnClick = CheckBoxClick
    end
    object CheckBox6: TCheckBox
      Left = 16
      Top = 119
      Width = 137
      Height = 17
      Caption = 'CheckBox6'
      TabOrder = 5
      OnClick = CheckBoxClick
    end
    object CheckBox7: TCheckBox
      Left = 16
      Top = 142
      Width = 153
      Height = 17
      Caption = 'CheckBox7'
      TabOrder = 6
      OnClick = CheckBoxClick
    end
    object CheckBox8: TCheckBox
      Left = 16
      Top = 165
      Width = 153
      Height = 17
      Caption = 'CheckBox8'
      TabOrder = 7
      OnClick = CheckBoxClick
    end
    object CheckBox9: TCheckBox
      Left = 16
      Top = 188
      Width = 153
      Height = 17
      Caption = 'CheckBox9'
      TabOrder = 8
      OnClick = CheckBoxClick
    end
    object CheckBox10: TCheckBox
      Left = 16
      Top = 211
      Width = 145
      Height = 17
      Caption = 'CheckBox10'
      TabOrder = 9
      OnClick = CheckBoxClick
    end
    object CheckBox11: TCheckBox
      Left = 16
      Top = 234
      Width = 153
      Height = 17
      Caption = 'CheckBox11'
      TabOrder = 10
      OnClick = CheckBoxClick
    end
    object CheckBox12: TCheckBox
      Left = 16
      Top = 257
      Width = 153
      Height = 17
      Caption = 'CheckBox12'
      TabOrder = 11
      OnClick = CheckBoxClick
    end
    object CheckBox13: TCheckBox
      Left = 16
      Top = 279
      Width = 153
      Height = 17
      Caption = 'CheckBox13'
      TabOrder = 12
      OnClick = CheckBoxClick
    end
    object CheckBox14: TCheckBox
      Left = 16
      Top = 301
      Width = 140
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'CheckBox14'
      TabOrder = 13
      OnClick = CheckBoxClick
    end
    object CheckBox15: TCheckBox
      Left = 184
      Top = 3
      Width = 140
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'CheckBox15'
      TabOrder = 14
      OnClick = CheckBoxClick
    end
    object CheckBox16: TCheckBox
      Left = 184
      Top = 26
      Width = 140
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'CheckBox16'
      TabOrder = 15
      OnClick = CheckBoxClick
    end
    object CheckBox17: TCheckBox
      Left = 184
      Top = 49
      Width = 140
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'CheckBox17'
      TabOrder = 16
      OnClick = CheckBoxClick
    end
    object CheckBox18: TCheckBox
      Left = 184
      Top = 72
      Width = 140
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'CheckBox18'
      TabOrder = 17
      OnClick = CheckBoxClick
    end
    object CheckBox19: TCheckBox
      Left = 184
      Top = 95
      Width = 132
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'CheckBox19'
      TabOrder = 18
      OnClick = CheckBoxClick
    end
    object CheckBox20: TCheckBox
      Left = 184
      Top = 118
      Width = 146
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'CheckBox20'
      TabOrder = 19
      OnClick = CheckBoxClick
    end
    object CheckBox21: TCheckBox
      Left = 184
      Top = 141
      Width = 132
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'CheckBox21'
      TabOrder = 20
      OnClick = CheckBoxClick
    end
    object CheckBox22: TCheckBox
      Left = 185
      Top = 164
      Width = 137
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'CheckBox22'
      TabOrder = 21
      OnClick = CheckBoxClick
    end
    object CheckBox23: TCheckBox
      Left = 184
      Top = 187
      Width = 123
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'CheckBox23'
      TabOrder = 22
      OnClick = CheckBoxClick
    end
    object CheckBox24: TCheckBox
      Left = 184
      Top = 210
      Width = 123
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'CheckBox24'
      TabOrder = 23
      OnClick = CheckBoxClick
    end
    object CheckBox25: TCheckBox
      Left = 185
      Top = 233
      Width = 123
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'CheckBox25'
      TabOrder = 24
      OnClick = CheckBoxClick
    end
    object CheckBox26: TCheckBox
      Left = 185
      Top = 256
      Width = 123
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'CheckBox26'
      TabOrder = 25
      OnClick = CheckBoxClick
    end
    object CheckBox27: TCheckBox
      Left = 185
      Top = 279
      Width = 123
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'CheckBox27'
      TabOrder = 26
      OnClick = CheckBoxClick
    end
    object CheckBox28: TCheckBox
      Left = 185
      Top = 301
      Width = 123
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'CheckBox28'
      TabOrder = 27
      OnClick = CheckBoxClick
    end
  end
  object CopyGraphButton1: TButton
    Left = 561
    Top = 540
    Width = 153
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Copy graph to clipboard'
    TabOrder = 2
    OnClick = CopyGraphButton1Click
  end
  object SaveExcelButton1: TButton
    Left = 561
    Top = 571
    Width = 153
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Save results to Excel'
    TabOrder = 3
    OnClick = SaveExcelButton1Click
  end
  object HorzAxisOptPanel: TPanel
    Left = 729
    Top = 347
    Width = 153
    Height = 121
    Anchors = [akTop, akRight]
    TabOrder = 4
    DesignSize = (
      153
      121)
    object HorzAxisOptLabel: TLabel
      Left = 16
      Top = 8
      Width = 131
      Height = 16
      Anchors = [akTop, akRight]
      Caption = 'Horizontal Axis Options'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object XMinLabel: TLabel
      Left = 16
      Top = 30
      Width = 57
      Height = 16
      Anchors = [akTop, akRight]
      Caption = 'Minimum:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object XMaxLabel: TLabel
      Left = 11
      Top = 72
      Width = 60
      Height = 16
      Anchors = []
      Caption = 'Maximum:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object AutoXMinRadioButton: TRadioButton
      Left = 16
      Top = 52
      Width = 41
      Height = 17
      Caption = 'Auto'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = RadioButtonClick
    end
    object XMinRadioButton: TRadioButton
      Left = 63
      Top = 52
      Width = 48
      Height = 17
      Caption = 'Fixed'
      TabOrder = 1
      OnClick = RadioButtonClick
    end
    object XMinEdit: TEdit
      Left = 117
      Top = 48
      Width = 35
      Height = 21
      TabOrder = 2
      Text = '0'
      OnClick = XMinEditClick
      OnEnter = XMinEditClick
      OnExit = RadioButtonClick
      OnKeyPress = XEditKeyPress
    end
    object MaxAxisOptPanel: TPanel
      Left = 8
      Top = 75
      Width = 145
      Height = 41
      BevelOuter = bvNone
      TabOrder = 3
      object AutoXMaxRadioButton: TRadioButton
        Left = 11
        Top = 24
        Width = 41
        Height = 17
        Caption = 'Auto'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = RadioButtonClick
      end
      object XMaxRadioButton: TRadioButton
        Left = 58
        Top = 24
        Width = 48
        Height = 17
        Caption = 'Fixed'
        TabOrder = 1
        OnClick = XMaxRadioButtonClick
      end
      object XMaxEdit: TEdit
        Left = 106
        Top = 20
        Width = 35
        Height = 21
        TabOrder = 2
        Text = '0'
        OnClick = XMaxEditClick
        OnEnter = XMaxEditClick
        OnExit = RadioButtonClick
        OnKeyPress = XEditKeyPress
      end
    end
  end
  object ElevHistOptPanel: TPanel
    Left = 562
    Top = 347
    Width = 161
    Height = 187
    Anchors = [akTop, akRight]
    TabOrder = 5
    DesignSize = (
      161
      187)
    object ElevUnitLabel: TLabel
      Left = 15
      Top = 38
      Width = 35
      Height = 16
      Anchors = []
      AutoSize = False
      Caption = 'Units:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object ElevZeroLabel: TLabel
      Left = 15
      Top = 63
      Width = 35
      Height = 16
      Anchors = []
      AutoSize = False
      Caption = 'Zero: '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object ElevBinLabel: TLabel
      Left = 10
      Top = 117
      Width = 40
      Height = 16
      Anchors = []
      AutoSize = False
      Caption = 'NBins:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object ElevHistOptLabel: TLabel
      Left = 38
      Top = 10
      Width = 105
      Height = 16
      Anchors = [akTop, akRight]
      Caption = 'Histogram Options'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitLeft = 22
    end
    object AreaLabel: TLabel
      Left = 15
      Top = 90
      Width = 35
      Height = 16
      Anchors = []
      AutoSize = False
      Caption = 'Area:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object ElevUnitsBox: TComboBox
      Left = 56
      Top = 36
      Width = 97
      Height = 21
      Anchors = []
      ItemIndex = 0
      TabOrder = 0
      Text = 'HTU'
      OnChange = BoxChange
      Items.Strings = (
        'HTU'
        'm')
    end
    object ElevZeroBox: TComboBox
      Left = 56
      Top = 63
      Width = 97
      Height = 21
      Anchors = []
      ItemIndex = 0
      TabOrder = 1
      Text = 'MTL'
      OnChange = BoxChange
      Items.Strings = (
        'MTL'
        'MHHW'
        'MLLW'
        'NAVD88')
    end
    object ElevBinsBox: TComboBox
      Left = 56
      Top = 117
      Width = 97
      Height = 21
      Anchors = []
      ItemIndex = 5
      TabOrder = 2
      Text = '100'
      OnChange = BoxChange
      Items.Strings = (
        '5'
        '10'
        '20'
        '25'
        '50'
        '100'
        '250'
        '500')
    end
    object AreaBox: TComboBox
      Left = 56
      Top = 90
      Width = 97
      Height = 21
      Anchors = []
      TabOrder = 3
      OnChange = BoxChange
    end
    object CellCountBox: TCheckBox
      Left = 16
      Top = 152
      Width = 121
      Height = 17
      Caption = 'Cell Count'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnClick = CellCountBoxClick
    end
  end
  object VertAxisOptPanel: TPanel
    Left = 730
    Top = 474
    Width = 153
    Height = 121
    Anchors = [akTop, akRight]
    TabOrder = 6
    DesignSize = (
      153
      121)
    object Label1: TLabel
      Left = 16
      Top = 8
      Width = 117
      Height = 16
      Anchors = [akTop, akRight]
      Caption = 'Vertical Axis Options'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object YMinLabel: TLabel
      Left = 16
      Top = 30
      Width = 57
      Height = 16
      Anchors = [akTop, akRight]
      Caption = 'Minimum:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 11
      Top = 72
      Width = 60
      Height = 16
      Anchors = []
      Caption = 'Maximum:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object AutoYMinRadioButton: TRadioButton
      Left = 16
      Top = 52
      Width = 41
      Height = 17
      Caption = 'Auto'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = RadioButtonClick
    end
    object YMinRadioButton: TRadioButton
      Left = 63
      Top = 52
      Width = 48
      Height = 17
      Caption = 'Fixed'
      TabOrder = 1
      OnClick = RadioButtonClick
    end
    object YMinEdit: TEdit
      Left = 117
      Top = 48
      Width = 35
      Height = 21
      TabOrder = 2
      Text = '0'
      OnClick = XMinEditClick
      OnEnter = XMinEditClick
      OnExit = RadioButtonClick
      OnKeyPress = XEditKeyPress
    end
    object MaxYOptPanel: TPanel
      Left = 8
      Top = 75
      Width = 145
      Height = 41
      BevelOuter = bvNone
      TabOrder = 3
      object AutoYMaxRadioButton: TRadioButton
        Left = 11
        Top = 24
        Width = 41
        Height = 17
        Caption = 'Auto'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = RadioButtonClick
      end
      object YMaxRadioButton: TRadioButton
        Left = 58
        Top = 24
        Width = 48
        Height = 17
        Caption = 'Fixed'
        TabOrder = 1
        OnClick = XMaxRadioButtonClick
      end
      object YMaxEdit: TEdit
        Left = 106
        Top = 20
        Width = 35
        Height = 21
        TabOrder = 2
        Text = '0'
        OnClick = XMaxEditClick
        OnEnter = XMaxEditClick
        OnExit = RadioButtonClick
        OnKeyPress = XEditKeyPress
      end
    end
  end
end
