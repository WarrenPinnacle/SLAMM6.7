object Delphi3DForm: TDelphi3DForm
  Left = 269
  Top = 214
  Caption = 'Delphi3D OpenGL basecode'
  ClientHeight = 473
  ClientWidth = 640
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 8
    Top = 8
    Width = 97
    Height = 20
    Caption = 'Initializing...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clLime
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object AppEvents: TApplicationEvents
    Left = 8
    Top = 40
  end
end
