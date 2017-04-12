object Binary_Conv_Form: TBinary_Conv_Form
  Left = 0
  Top = 0
  Caption = 'Convert SLAMM Binary Files to ASCII'
  ClientHeight = 328
  ClientWidth = 674
  Color = clBtnFace
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    674
    328)
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 20
    Top = 16
    Width = 633
    Height = 292
    Anchors = [akLeft, akTop, akRight, akBottom]
    DragMode = dmAutomatic
    Lines.Strings = (
      
        'Drop one or more SLAMM Binary Files (SLB) here to convert to ASC' +
        'II'
      
        'Or drop one or more SLAMM ASCII files (TXT or ASX) to convert to' +
        ' SLB')
    TabOrder = 0
  end
end
