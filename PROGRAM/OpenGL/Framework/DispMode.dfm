object DotDispModeDlg: TDotDispModeDlg
  Left = 350
  Top = 245
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Choose display settings'
  ClientHeight = 336
  ClientWidth = 240
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object chkFullscreen: TCheckBox
    Left = 8
    Top = 8
    Width = 225
    Height = 17
    Caption = 'Run in full screen'
    TabOrder = 0
  end
  object grpDispMode: TGroupBox
    Left = 8
    Top = 32
    Width = 225
    Height = 113
    Caption = 'Display mode'
    TabOrder = 1
    object lblRes: TLabel
      Left = 8
      Top = 24
      Width = 65
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Resolution:'
      Layout = tlCenter
    end
    object lblBPP: TLabel
      Left = 8
      Top = 48
      Width = 65
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Color depth:'
      Layout = tlCenter
    end
    object lblRefresh: TLabel
      Left = 8
      Top = 72
      Width = 65
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Refresh:'
      Layout = tlCenter
    end
    object cboResolution: TComboBox
      Left = 80
      Top = 24
      Width = 129
      Height = 21
      TabOrder = 0
      Text = '1024x768'
    end
    object cboColorDepth: TComboBox
      Left = 80
      Top = 48
      Width = 129
      Height = 21
      TabOrder = 1
      Text = '32 bpp'
    end
    object cboRefreshRate: TComboBox
      Left = 80
      Top = 72
      Width = 129
      Height = 21
      TabOrder = 2
      Text = '60 Hz'
    end
  end
  object grpPixelFormat: TGroupBox
    Left = 8
    Top = 152
    Width = 225
    Height = 145
    Caption = 'Pixel format'
    TabOrder = 2
    object lblZBits: TLabel
      Left = 8
      Top = 24
      Width = 65
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Depth bits:'
      Layout = tlCenter
    end
    object lblSBits: TLabel
      Left = 8
      Top = 48
      Width = 65
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Stencil bits:'
      Layout = tlCenter
    end
    object lblABits: TLabel
      Left = 8
      Top = 72
      Width = 65
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Alpha bits:'
      Layout = tlCenter
    end
    object Label7: TLabel
      Left = 168
      Top = 104
      Width = 41
      Height = 25
      AutoSize = False
      Caption = 'samples'
      Layout = tlCenter
    end
    object chkFSAA: TCheckBox
      Left = 16
      Top = 104
      Width = 89
      Height = 25
      Caption = 'Enable FSAA'
      TabOrder = 0
    end
    object cboDepthBits: TComboBox
      Left = 80
      Top = 24
      Width = 129
      Height = 21
      ItemIndex = 1
      Sorted = True
      TabOrder = 1
      Text = '24'
      Items.Strings = (
        '16'
        '24'
        '32')
    end
    object cboStencilBits: TComboBox
      Left = 80
      Top = 48
      Width = 129
      Height = 21
      ItemIndex = 0
      TabOrder = 2
      Text = '0'
      Items.Strings = (
        '0'
        '8')
    end
    object cboAlphaBits: TComboBox
      Left = 80
      Top = 72
      Width = 129
      Height = 21
      ItemIndex = 0
      TabOrder = 3
      Text = '0'
      Items.Strings = (
        '0'
        '8')
    end
    object edtFSAASamples: TSpinEdit
      Left = 112
      Top = 104
      Width = 49
      Height = 25
      AutoSize = False
      MaxValue = 128
      MinValue = 1
      TabOrder = 4
      Value = 2
    end
  end
  object btnOK: TButton
    Left = 152
    Top = 304
    Width = 81
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 64
    Top = 304
    Width = 81
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
end
