object SAVParamForm: TSAVParamForm
  Left = 0
  Top = 0
  Caption = 'Edit Parameters for Probability of SAV'
  ClientHeight = 387
  ClientWidth = 370
  Color = clBtnFace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 300
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    370
    387)
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
  object Panel1: TPanel
    Left = 24
    Top = 32
    Width = 331
    Height = 288
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 2
    DesignSize = (
      331
      288)
    object DEM: TLabel
      Left = 8
      Top = 58
      Width = 197
      Height = 16
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'DEM'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Intercept: TLabel
      Left = 34
      Top = 27
      Width = 171
      Height = 16
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Intercept'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label1: TLabel
      Left = 8
      Top = 116
      Width = 197
      Height = 16
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'DEM Cubed'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 34
      Top = 86
      Width = 171
      Height = 16
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'DEM Squared'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 8
      Top = 178
      Width = 197
      Height = 16
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Distance to MHHW'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 34
      Top = 148
      Width = 171
      Height = 16
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Distance to MLLW'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 8
      Top = 236
      Width = 197
      Height = 16
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Distance to Mouth Squared'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label7: TLabel
      Left = 34
      Top = 206
      Width = 171
      Height = 16
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Distance to Mouth'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object EditA: TEdit
      Left = 223
      Top = 25
      Width = 95
      Height = 24
      Anchors = [akLeft, akRight, akBottom]
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnExit = EditExit
    end
    object EditB: TEdit
      Left = 223
      Top = 55
      Width = 95
      Height = 24
      Anchors = [akLeft, akRight, akBottom]
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnExit = EditExit
    end
    object EditC: TEdit
      Left = 223
      Top = 84
      Width = 95
      Height = 24
      Anchors = [akLeft, akRight, akBottom]
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnExit = EditExit
    end
    object EditD: TEdit
      Left = 223
      Top = 113
      Width = 95
      Height = 24
      Anchors = [akLeft, akRight, akBottom]
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnExit = EditExit
    end
    object EditE: TEdit
      Left = 223
      Top = 146
      Width = 95
      Height = 24
      Anchors = [akLeft, akRight, akBottom]
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnExit = EditExit
    end
    object EditF: TEdit
      Left = 223
      Top = 175
      Width = 95
      Height = 24
      Anchors = [akLeft, akRight, akBottom]
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 5
      OnExit = EditExit
    end
    object EditG: TEdit
      Left = 223
      Top = 204
      Width = 95
      Height = 24
      Anchors = [akLeft, akRight, akBottom]
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      OnExit = EditExit
    end
    object EditH: TEdit
      Left = 223
      Top = 233
      Width = 95
      Height = 24
      Anchors = [akLeft, akRight, akBottom]
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 7
      OnExit = EditExit
    end
  end
  object OKBtn: TButton
    Left = 248
    Top = 351
    Width = 83
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
  object CancelBtn: TButton
    Left = 139
    Top = 351
    Width = 81
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = CancelBtnClick
  end
  object DefaultsButt: TButton
    Left = 32
    Top = 40
    Width = 81
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'Zero All'
    TabOrder = 3
    OnClick = DefaultsButtClick
  end
end
