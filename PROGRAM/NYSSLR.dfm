object NYSSLRForm: TNYSSLRForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'NYS SLR Scenario'
  ClientHeight = 344
  ClientWidth = 182
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object NYS_RIM_Min: TCheckBox
    Left = 35
    Top = 87
    Width = 97
    Height = 17
    Caption = 'NYS RIM Min'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = NYSSLRClick
  end
  object NYS_1M_2100: TCheckBox
    Left = 35
    Top = 55
    Width = 97
    Height = 17
    Caption = 'NYS 1M 2100'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    OnClick = NYSSLRClick
  end
  object NYS_RIM_Max: TCheckBox
    Left = 34
    Top = 119
    Width = 97
    Height = 17
    Caption = 'NYS RIM Max'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnClick = NYSSLRClick
  end
  object NYS_GCM_Max: TCheckBox
    Left = 35
    Top = 22
    Width = 97
    Height = 17
    Caption = 'NYS GCM Max'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OnClick = NYSSLRClick
  end
  object OKButton: TButton
    Left = 99
    Top = 311
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
    TabOrder = 4
    OnClick = OKButtonClick
  end
  object ESVA_Hist: TCheckBox
    Left = 34
    Top = 158
    Width = 97
    Height = 17
    Caption = 'ESVA Historic'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
    OnClick = NYSSLRClick
  end
  object ESVA_High: TCheckBox
    Left = 35
    Top = 223
    Width = 97
    Height = 17
    Caption = 'ESVA High'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
    OnClick = NYSSLRClick
  end
  object ESVA_Low: TCheckBox
    Left = 35
    Top = 191
    Width = 97
    Height = 17
    Caption = 'ESVA Low'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 7
    OnClick = NYSSLRClick
  end
  object ESVA_Highest: TCheckBox
    Left = 34
    Top = 254
    Width = 97
    Height = 17
    Caption = 'ESVA Highest'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 8
    OnClick = NYSSLRClick
  end
end
