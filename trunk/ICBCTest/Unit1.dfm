object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 450
  ClientWidth = 842
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 842
    Height = 41
    Align = alTop
    TabOrder = 0
    object Button2: TButton
      Left = 16
      Top = 10
      Width = 105
      Height = 25
      Caption = 'NC '#31614#21517'/'#39564#31614
      TabOrder = 0
      OnClick = Button2Click
    end
    object Button4: TButton
      Left = 127
      Top = 10
      Width = 75
      Height = 25
      Caption = #26597#35810#31867
      TabOrder = 1
      OnClick = Button4Click
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 41
    Width = 842
    Height = 409
    ActivePage = TabSheet3
    Align = alClient
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = #25351#20196
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object mmo_xmlcmd: TMemo
        Left = 0
        Top = 0
        Width = 834
        Height = 381
        Align = alClient
        Lines.Strings = (
          #25105#26159
          #35785#35772#27861' aaabbcc  dfsf '
          'fs '#25105#30340'%^^&^&#'
          '#$@#$#$%'
          #27979#35797)
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = #31614#21517'/'#39564#31614
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object mmo_rtdata: TMemo
        Left = 0
        Top = 0
        Width = 834
        Height = 381
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object TabSheet3: TTabSheet
      Caption = #21453#39304
      ImageIndex = 2
      object mmo_cmdrt: TMemo
        Left = 0
        Top = 0
        Width = 834
        Height = 381
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'TabSheet4'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Memo1: TMemo
        Left = 0
        Top = 0
        Width = 834
        Height = 381
        Align = alClient
        Lines.Strings = (
          
            'PD94bWwgIHZlcnNpb249IjEuMCIgZW5jb2Rpbmc9IkdCSyIgPz4KPENNUz4KPGVi' +
            'Pgo8cHViPgo8VHJhbnNDb2RlPk5FVElORjwvVHJhbnNDb2RlPgo8Q0lTPjwvQ0lT' +
            'Pgo8QmFua0N'
          
            'vZGU+PC9CYW5rQ29kZT4KPElEPjwvSUQ+CjxUcmFuRGF0ZT48L1RyYW5EYXRlPgo' +
            '8VHJhblRpbWU+PC9UcmFuVGltZT4KPGZTZXFubz48L2ZTZXFubz4KPFJldENvZGU'
          '+RDAwODk8L1JldENvZGU+CjxSZXRNc2c'
          
            '+eG1sveKw/LTtzvMhRmFpbGVkIHRvIHVuZm9ybWF0IGRhdGEhClRhZ25hbWU9VHJ' +
            'hbnNDb2RlCklucHV0PTwvUmV0TXNnPgo8L3B1Yj4KPG91dD4KPE5leHRUYWc'
          
            '+PC9OZXh0VGFnPgo8UmVwUmVzZXJ2ZWQxPjwvUmVwUmVzZXJ2ZWQxPgo8UmVwUmV' +
            'zZXJ2ZWQyPjwvUmVwUmVzZXJ2ZWQyPgo8cmQ'
          
            '+CjxBcmVhQ29kZT48L0FyZWFDb2RlPgo8TmV0TmFtZT48L05ldE5hbWU+CjxSZXB' +
            'SZXNlcnZlZDM+PC9SZXBSZXNlcnZlZDM+CjxSZXBSZXNlcnZlZDQ+PC9SZXBSZXN' +
            'lcnZlZDQ'
          '+CjwvcmQ+Cjwvb3V0Pgo8L2ViPgo8L0NNUz4K')
        TabOrder = 0
      end
    end
  end
  object IdAntiFreeze1: TIdAntiFreeze
    Left = 56
    Top = 104
  end
  object IdEncoderMIME1: TIdEncoderMIME
    FillChar = '='
    Left = 248
    Top = 152
  end
  object IdDecoderMIME1: TIdDecoderMIME
    FillChar = '='
    Left = 288
    Top = 136
  end
end
