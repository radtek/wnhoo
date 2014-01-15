object MainFRM: TMainFRM
  Left = 148
  Top = 77
  VertScrollBar.Style = ssFlat
  ClientHeight = 620
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TRzStatusBar
    Left = 0
    Top = 601
    Width = 800
    Height = 19
    BorderInner = fsNone
    BorderOuter = fsNone
    BorderSides = [sdLeft, sdTop, sdRight, sdBottom]
    BorderWidth = 0
    TabOrder = 0
    object StatusPane1: TRzStatusPane
      Left = 0
      Top = 0
      Width = 215
      Height = 19
      Align = alLeft
    end
    object ProgressBar: TRzProgressBar
      Left = 215
      Top = 0
      Height = 19
      Align = alLeft
      BackColor = clBtnFace
      BorderInner = fsFlat
      BorderOuter = fsNone
      BorderWidth = 1
      InteriorOffset = 0
      PartsComplete = 0
      Percent = 0
      TotalParts = 0
    end
    object StatusPane_web: TRzStatusPane
      Left = 415
      Top = 0
      Width = 385
      Height = 19
      Align = alClient
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 491
    Width = 800
    Height = 110
    Align = alBottom
    TabOrder = 1
    object Label1: TLabel
      Left = 78
      Top = 69
      Width = 33
      Height = 13
      AutoSize = False
      Caption = '>>'
    end
    object Button3: TButton
      Left = 334
      Top = 66
      Width = 112
      Height = 25
      Caption = #22352#26631'_'#38543#26426#28857#20987
      TabOrder = 0
      OnClick = Button3Click
    end
    object Button8: TButton
      Left = 333
      Top = 4
      Width = 113
      Height = 54
      Caption = #27169#25311#26469#36335
      TabOrder = 1
      OnClick = Button8Click
    end
    object Button7: TButton
      Left = 484
      Top = 73
      Width = 227
      Height = 25
      Caption = #36807#28388#36830#25509','#24182#36830#25509'_'#38543#26426#28857#20987
      TabOrder = 2
      OnClick = Button7Click
    end
    object edt_Filter: TEdit
      Left = 678
      Top = 26
      Width = 104
      Height = 21
      TabOrder = 3
      Text = 'http://tieba.baidu.com/p/'
    end
    object rg_FilterMode: TRadioGroup
      Left = 483
      Top = 3
      Width = 185
      Height = 65
      Caption = #36807#28388#26041#24335
      ItemIndex = 1
      Items.Strings = (
        #19981#36807#28388
        #25353'Url'#36807#28388
        #25353#26631#39064#65288#20851#38190#23383#65289#36807#28388)
      TabOrder = 4
    end
    object edt_ref: TEdit
      Left = 6
      Top = 6
      Width = 323
      Height = 21
      TabOrder = 5
      Text = 'http://www.baidu.com'
    end
    object edt_url: TEdit
      Left = 6
      Top = 38
      Width = 323
      Height = 21
      TabOrder = 6
      Text = 'http://bisai.tiankong520.com/poem/works/316099'
    end
    object edt_y1: TEdit
      Left = 40
      Top = 66
      Width = 31
      Height = 21
      TabOrder = 7
      Text = '48'
    end
    object edt_x2: TEdit
      Left = 97
      Top = 66
      Width = 31
      Height = 21
      TabOrder = 8
      Text = '671'
    end
    object edt_y2: TEdit
      Left = 132
      Top = 66
      Width = 31
      Height = 21
      TabOrder = 9
      Text = '73'
    end
    object edt_x1: TEdit
      Left = 5
      Top = 66
      Width = 31
      Height = 21
      TabOrder = 10
      Text = '276'
    end
    object Button4: TButton
      Left = 456
      Top = 40
      Width = 75
      Height = 25
      Caption = 'Button4'
      TabOrder = 11
      OnClick = Button4Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 450
    Width = 800
    Height = 41
    Align = alBottom
    TabOrder = 2
    object Button1: TButton
      Left = 6
      Top = 8
      Width = 136
      Height = 25
      Caption = #28304#20195#30721
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 146
      Top = 8
      Width = 136
      Height = 25
      Caption = #37322#25918#31383#21475
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button5: TButton
      Left = 286
      Top = 8
      Width = 136
      Height = 25
      Caption = #28165#38500'Cookie '#19982' Cache'
      TabOrder = 2
      OnClick = Button5Click
    end
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 800
    Height = 450
    Align = alClient
    TabOrder = 3
    TabPosition = tpBottom
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 399
    Top = 160
  end
end
