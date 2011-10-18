object MainFRM: TMainFRM
  Left = 205
  Top = 149
  Width = 725
  Height = 583
  VertScrollBar.Style = ssFlat
  Caption = #21338#23458#35270#28857
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  ShowHint = True
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel_Frm: TPanel
    Left = 0
    Top = 97
    Width = 717
    Height = 440
    Align = alClient
    BevelOuter = bvLowered
    Caption = 'Panel_Frm'
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 0
    object PageControl: TPageControl
      Left = 1
      Top = 1
      Width = 715
      Height = 419
      Align = alClient
      TabOrder = 0
      OnChange = PageControlChange
    end
    object StatusBar1: TStatusBar
      Left = 1
      Top = 420
      Width = 715
      Height = 19
      Panels = <>
    end
    object Panel2: TPanel
      Left = 0
      Top = 16
      Width = 473
      Height = 233
      Caption = 'Panel2'
      TabOrder = 2
    end
  end
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 717
    Height = 26
    AutoSize = True
    Bands = <
      item
        Control = ToolBar2
        ImageIndex = -1
        MinHeight = 22
        Text = #22320#22336':'
        Width = 713
      end>
    Color = clBtnFace
    ParentColor = False
    object ToolBar2: TToolBar
      Left = 40
      Top = 0
      Width = 669
      Height = 22
      AutoSize = True
      ButtonWidth = 25
      Caption = 'ToolBar1'
      EdgeInner = esNone
      EdgeOuter = esNone
      Flat = True
      TabOrder = 0
      OnResize = ToolBar2Resize
      object URLpath: TRzComboBox
        Left = 0
        Top = 0
        Width = 577
        Height = 21
        ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
        ItemHeight = 13
        TabOrder = 0
        OnDropDown = URLpathDropDown
        OnKeyDown = URLpathKeyDown
      end
      object search_ToolButton: TToolButton
        Left = 577
        Top = 0
        Hint = #36716#21040
        Caption = #36716#21040
        ImageIndex = 49
        Wrap = True
        OnClick = GoToURLExecute
      end
    end
  end
  object StatusBar: TRzStatusBar
    Left = 0
    Top = 537
    Width = 717
    Height = 19
    BorderInner = fsNone
    BorderOuter = fsNone
    BorderSides = [sdLeft, sdTop, sdRight, sdBottom]
    BorderWidth = 0
    TabOrder = 2
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
      Width = 302
      Height = 19
      Align = alClient
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 26
    Width = 717
    Height = 71
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 3
    object Button6: TButton
      Left = 222
      Top = 3
      Width = 163
      Height = 22
      Caption = #28857#20987'(URL'#25110#20851#38190#23383#36830#25509')'
      TabOrder = 0
      OnClick = Button6Click
    end
    object Button4: TButton
      Left = 394
      Top = 3
      Width = 90
      Height = 22
      Caption = #27169#25311#28857#20987
      TabOrder = 1
      OnClick = Button4Click
    end
    object Button2: TButton
      Left = 494
      Top = 3
      Width = 90
      Height = 22
      Caption = 'Free'
      TabOrder = 2
      OnClick = Button2Click
    end
    object Button1: TButton
      Left = 0
      Top = 3
      Width = 90
      Height = 22
      Caption = #20195#30721
      TabOrder = 3
      OnClick = Button1Click
    end
    object Button7: TButton
      Left = 128
      Top = 0
      Width = 75
      Height = 25
      Caption = #27169#25311#26469#36335'2'
      TabOrder = 4
      OnClick = Button7Click
    end
    object Button3: TButton
      Left = 616
      Top = 8
      Width = 75
      Height = 25
      Caption = #27169#25311#28857#20987'2'
      TabOrder = 5
      OnClick = Button3Click
    end
    object Button5: TButton
      Left = 544
      Top = 32
      Width = 75
      Height = 25
      Caption = 'Button5'
      TabOrder = 6
      OnClick = Button5Click
    end
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 295
    Top = 88
  end
end
