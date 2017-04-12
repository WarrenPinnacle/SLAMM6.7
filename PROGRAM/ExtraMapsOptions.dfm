object ExtraMapsForm: TExtraMapsForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Extra Maps Options'
  ClientHeight = 330
  ClientWidth = 281
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object SAVWarningLabel: TLabel
    Left = 33
    Top = 248
    Width = 211
    Height = 26
    Caption = 'Not Relevant; No Distance to Mouth Raster Specified.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object RoadInundWarningLabel: TLabel
    Left = 33
    Top = 206
    Width = 196
    Height = 13
    Caption = 'Not Relevant; No Road Raster Specified.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object RoadInundMapsBox: TCheckBox
    Left = 33
    Top = 183
    Width = 221
    Height = 25
    Caption = 'Save Road Inundation Maps'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 7
    OnClick = ExtraMapsBoxClick
  end
  object SAVMapsBox: TCheckBox
    Left = 33
    Top = 225
    Width = 112
    Height = 25
    Hint = 'No SAV Raster included'
    Caption = 'Save SAV Maps'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnClick = ExtraMapsBoxClick
  end
  object SalinityMapsBox: TCheckBox
    Left = 33
    Top = 24
    Width = 221
    Height = 25
    Caption = 'Save Salinity Maps'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = ExtraMapsBoxClick
  end
  object DucksMapsBox: TCheckBox
    Left = 33
    Top = 89
    Width = 221
    Height = 25
    Caption = 'Additional Simplified Category Maps'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = ExtraMapsBoxClick
  end
  object Button1: TButton
    Left = 179
    Top = 280
    Width = 75
    Height = 25
    Caption = '&OK'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ModalResult = 1
    ParentFont = False
    TabOrder = 2
  end
  object AccretionMapsBox: TCheckBox
    Left = 33
    Top = 56
    Width = 221
    Height = 25
    Caption = 'Save Accretion Maps'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OnClick = ExtraMapsBoxClick
  end
  object ConnectMapsBox: TCheckBox
    Left = 33
    Top = 121
    Width = 221
    Height = 25
    Caption = 'Save Connectivity Maps'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
    OnClick = ExtraMapsBoxClick
  end
  object InundMapsBox: TCheckBox
    Left = 33
    Top = 152
    Width = 221
    Height = 25
    Caption = 'Save Inundation Maps'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
    OnClick = ExtraMapsBoxClick
  end
end
