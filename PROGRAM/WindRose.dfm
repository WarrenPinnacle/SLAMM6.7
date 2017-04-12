object WindForm: TWindForm
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  Caption = 'Wind Rose Data Entry'
  ClientHeight = 683
  ClientWidth = 656
  Color = clBtnFace
  Constraints.MinHeight = 721
  Constraints.MinWidth = 672
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  DesignSize = (
    656
    683)
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 32
    Top = 384
    Width = 297
    Height = 267
    Anchors = [akLeft, akTop, akRight, akBottom]
    ExplicitHeight = 275
  end
  object Label1: TLabel
    Left = 440
    Top = 400
    Width = 46
    Height = 13
    Anchors = [akRight, akBottom]
    Caption = '0-0.5 m/s'
    ExplicitLeft = 452
  end
  object Shape1: TShape
    Left = 374
    Top = 400
    Width = 57
    Height = 13
    Anchors = [akRight, akBottom]
    Brush.Color = clRed
    ExplicitLeft = 376
  end
  object Shape2: TShape
    Left = 374
    Top = 416
    Width = 57
    Height = 13
    Anchors = [akRight, akBottom]
    Brush.Color = clRed
    ExplicitLeft = 376
  end
  object Label2: TLabel
    Left = 440
    Top = 416
    Width = 46
    Height = 13
    Anchors = [akRight, akBottom]
    Caption = '0-0.5 m/s'
    ExplicitLeft = 452
  end
  object Shape3: TShape
    Left = 374
    Top = 432
    Width = 57
    Height = 13
    Anchors = [akRight, akBottom]
    Brush.Color = clRed
    ExplicitLeft = 376
  end
  object Label3: TLabel
    Left = 440
    Top = 432
    Width = 46
    Height = 13
    Anchors = [akRight, akBottom]
    Caption = '0-0.5 m/s'
    ExplicitLeft = 452
  end
  object Shape4: TShape
    Left = 374
    Top = 448
    Width = 57
    Height = 13
    Anchors = [akRight, akBottom]
    Brush.Color = clRed
    ExplicitLeft = 376
  end
  object Label4: TLabel
    Left = 440
    Top = 448
    Width = 46
    Height = 13
    Anchors = [akRight, akBottom]
    Caption = '0-0.5 m/s'
    ExplicitLeft = 452
  end
  object Shape5: TShape
    Left = 374
    Top = 464
    Width = 57
    Height = 13
    Anchors = [akRight, akBottom]
    Brush.Color = clRed
    ExplicitLeft = 376
  end
  object Label5: TLabel
    Left = 440
    Top = 464
    Width = 46
    Height = 13
    Anchors = [akRight, akBottom]
    Caption = '0-0.5 m/s'
    ExplicitLeft = 452
  end
  object Shape6: TShape
    Left = 374
    Top = 480
    Width = 57
    Height = 13
    Anchors = [akRight, akBottom]
    Brush.Color = clRed
    ExplicitLeft = 376
  end
  object Label6: TLabel
    Left = 440
    Top = 480
    Width = 46
    Height = 13
    Anchors = [akRight, akBottom]
    Caption = '0-0.5 m/s'
    ExplicitLeft = 452
  end
  object Shape7: TShape
    Left = 374
    Top = 496
    Width = 57
    Height = 13
    Anchors = [akRight, akBottom]
    Brush.Color = clRed
    ExplicitLeft = 376
  end
  object Label7: TLabel
    Left = 440
    Top = 496
    Width = 46
    Height = 13
    Anchors = [akRight, akBottom]
    Caption = '0-0.5 m/s'
    ExplicitLeft = 452
  end
  object NorthLabel: TLabel
    Left = 176
    Top = 371
    Width = 8
    Height = 14
    Caption = 'N'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label8: TLabel
    Left = 374
    Top = 544
    Width = 237
    Height = 41
    Anchors = [akRight, akBottom]
    AutoSize = False
    Caption = 
      'Wind Rose Data Should Be Derived based on 10 meter data with 10 ' +
      'minute averaging intervals '
    WordWrap = True
  end
  object RoseGrid: TStringGrid
    Left = 24
    Top = 16
    Width = 587
    Height = 344
    ColCount = 9
    Ctl3D = False
    DefaultRowHeight = 18
    DrawingStyle = gdsClassic
    RowCount = 18
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial Narrow'
    Font.Style = []
    GradientStartColor = 14079702
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 0
    OnDrawCell = RoseGridDrawCell
    OnExit = RoseGridExit
    OnKeyDown = RoseGridKeyDown
    OnSelectCell = RoseGridSelectCell
    OnSetEditText = RoseGridSetEditText
    ColWidths = (
      64
      64
      64
      64
      64
      64
      64
      64
      64)
    RowHeights = (
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18
      18)
  end
  object OKBtn: TButton
    Left = 528
    Top = 626
    Width = 83
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
  object CancelBtn: TButton
    Left = 429
    Top = 628
    Width = 81
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
