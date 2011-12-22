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
    object Button4: TButton
      Left = 4
      Top = 10
      Width = 75
      Height = 25
      Caption = #26597#35810#21345#20313
      TabOrder = 0
      OnClick = Button4Click
    end
    object Button1: TButton
      Left = 166
      Top = 10
      Width = 97
      Height = 25
      Caption = #26597#35810#21382#21490#32426#24405
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button7: TButton
      Left = 85
      Top = 10
      Width = 75
      Height = 25
      Caption = #24403#26085#26126#32454
      TabOrder = 2
      OnClick = Button7Click
    end
    object Button2: TButton
      Left = 369
      Top = 10
      Width = 89
      Height = 25
      Caption = #25903#20184#25351#20196#26597#35810
      TabOrder = 3
      OnClick = Button2Click
    end
    object Button6: TButton
      Left = 481
      Top = 10
      Width = 75
      Height = 25
      Caption = #25209#37327#25187#20010#20154
      TabOrder = 4
      OnClick = Button6Click
    end
    object Button5: TButton
      Left = 562
      Top = 10
      Width = 113
      Height = 25
      Caption = #25209#25187#20010#20154#26597#35810
      TabOrder = 5
      OnClick = Button5Click
    end
    object Button3: TButton
      Left = 288
      Top = 10
      Width = 75
      Height = 25
      Caption = #25903#20184#25351#20196
      TabOrder = 6
      OnClick = Button3Click
    end
    object Button15: TButton
      Left = 689
      Top = 10
      Width = 120
      Height = 25
      Caption = #32564#36153#20010#20154#20449#24687#26597#35810
      TabOrder = 7
      OnClick = Button15Click
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 82
    Width = 842
    Height = 368
    ActivePage = TabSheet3
    Align = alClient
    TabOrder = 1
    object TabSheet3: TTabSheet
      Caption = #21453#39304
      ImageIndex = 2
      object mmo_cmdrt: TMemo
        Left = 0
        Top = 0
        Width = 834
        Height = 340
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 842
    Height = 41
    Align = alTop
    TabOrder = 2
    object Button8: TButton
      Left = 4
      Top = 10
      Width = 75
      Height = 25
      Caption = #26597#35810#21345#20313
      TabOrder = 0
      OnClick = Button8Click
    end
    object Button9: TButton
      Left = 166
      Top = 10
      Width = 97
      Height = 25
      Caption = #26597#35810#21382#21490#32426#24405
      TabOrder = 1
    end
    object Button10: TButton
      Left = 85
      Top = 10
      Width = 75
      Height = 25
      Caption = #24403#26085#26126#32454
      TabOrder = 2
    end
    object Button11: TButton
      Left = 369
      Top = 10
      Width = 89
      Height = 25
      Caption = #25903#20184#25351#20196#26597#35810
      TabOrder = 3
    end
    object Button12: TButton
      Left = 481
      Top = 10
      Width = 75
      Height = 25
      Caption = #25209#37327#25187#20010#20154
      TabOrder = 4
    end
    object Button13: TButton
      Left = 562
      Top = 10
      Width = 113
      Height = 25
      Caption = #25209#25187#20010#20154#26597#35810
      TabOrder = 5
    end
    object Button14: TButton
      Left = 288
      Top = 10
      Width = 75
      Height = 25
      Caption = #25903#20184#25351#20196
      TabOrder = 6
      OnClick = Button14Click
    end
  end
end
