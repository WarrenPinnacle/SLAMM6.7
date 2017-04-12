object CustomSLRForm: TCustomSLRForm
  Left = 0
  Top = 0
  Caption = 'Custom SLR'
  ClientHeight = 609
  ClientWidth = 498
  Color = clBtnFace
  Constraints.MaxWidth = 514
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    498
    609)
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 21
    Top = 23
    Width = 95
    Height = 32
    Caption = 'Select Custom SLR Scenario:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object Panel1: TPanel
    Left = 38
    Top = 78
    Width = 415
    Height = 474
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    DesignSize = (
      415
      474)
    object Label9: TLabel
      Left = 78
      Top = 404
      Width = 294
      Height = 45
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 
        'To delete a record, click on record and  press <Ctrl> <Del>   To' +
        ' insert, click on table and press <Ctrl><Ins>                   ' +
        'Data may be pasted from Excel.  Select cell then <Ctrl><V>.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      ExplicitTop = 381
    end
    object SLRLabel: TLabel
      Left = 144
      Top = 113
      Width = 128
      Height = 16
      Caption = 'Sea Level Rise Data'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object NameLabel: TLabel
      Left = 43
      Top = 51
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
    object YearLabel: TLabel
      Left = 43
      Top = 83
      Width = 63
      Height = 16
      Caption = 'Base Year'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object SLREdit: TStringGrid
      Left = 112
      Top = 136
      Width = 196
      Height = 263
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
      TabOrder = 0
      OnExit = SLREditExit
      OnKeyDown = SLREditKeyDown
      OnSelectCell = SLREditSelectCell
      OnSetEditText = SLREditSetEditText
      ExplicitHeight = 275
    end
    object NameEdit: TEdit
      Left = 112
      Top = 48
      Width = 200
      Height = 24
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnChange = NameEditChange
    end
    object BaseYearEdit: TEdit
      Left = 128
      Top = 80
      Width = 57
      Height = 24
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnExit = BaseYearEditExit
    end
    object RunNowBox: TCheckBox
      Left = 43
      Top = 16
      Width = 198
      Height = 17
      Caption = ' Run In Current Simulation'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = RunNowBoxClick
    end
  end
  object OKBtn: TButton
    Left = 374
    Top = 568
    Width = 83
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ModalResult = 1
    ParentFont = False
    TabOrder = 1
  end
  object CancelBtn: TButton
    Left = 272
    Top = 568
    Width = 81
    Height = 26
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnClick = CancelBtnClick
  end
  object SLRBox: TComboBox
    Left = 132
    Top = 23
    Width = 200
    Height = 24
    Style = csDropDownList
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnChange = SLRBoxChange
  end
  object NewButton: TButton
    Left = 349
    Top = 8
    Width = 67
    Height = 24
    Caption = 'New'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnClick = NewButtonClick
  end
  object DelButt: TButton
    Left = 349
    Top = 38
    Width = 67
    Height = 24
    Caption = 'Delete'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
    OnClick = DelButtClick
  end
  object SaveButton: TButton
    Left = 41
    Top = 567
    Width = 56
    Height = 26
    Anchors = [akLeft, akBottom]
    Caption = '&Save'
    Font.Charset = ANSI_CHARSET
    Font.Color = clGray
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
    OnClick = SaveButtonClick
    ExplicitTop = 571
  end
  object LoadButton: TButton
    Left = 121
    Top = 567
    Width = 56
    Height = 26
    Anchors = [akLeft, akBottom]
    Caption = '&Load'
    Font.Charset = ANSI_CHARSET
    Font.Color = clGray
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 7
    OnClick = LoadButtonClick
  end
end
