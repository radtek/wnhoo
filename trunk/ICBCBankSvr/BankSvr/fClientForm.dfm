object ClientForm: TClientForm
  Left = 372
  Top = 277
  Caption = 'RemObjects Client'
  ClientHeight = 59
  ClientWidth = 212
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 104
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object ROMessage: TROBinMessage
    Envelopes = <>
    Left = 36
    Top = 8
  end
  object ROChannel: TROIndyTCPChannel
    ServerLocators = <>
    DispatchOptions = []
    Port = 10008
    Host = '127.0.0.1'
    IndyClient.ConnectTimeout = 0
    IndyClient.Host = '127.0.0.1'
    IndyClient.IPVersion = Id_IPv4
    IndyClient.Port = 10008
    IndyClient.ReadTimeout = -1
    Left = 8
    Top = 8
  end
  object RORemoteService: TRORemoteService
    Message = ROMessage
    Channel = ROChannel
    ServiceName = 'BankService'
    Left = 64
    Top = 8
  end
end
