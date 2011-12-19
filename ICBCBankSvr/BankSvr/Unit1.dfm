object Service1: TService1
  OldCreateOrder = False
  OnCreate = ServiceCreate
  OnDestroy = ServiceDestroy
  DisplayName = 'ICBCBankSvr'
  OnContinue = ServiceContinue
  OnPause = ServicePause
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 150
  Width = 215
  object ROMessage: TROBinMessage
    Envelopes = <>
    Left = 64
    Top = 88
  end
  object ROServer: TROIndyTCPServer
    Dispatchers = <
      item
        Name = 'ROMessage'
        Message = ROMessage
        Enabled = True
      end>
    IndyServer.Bindings = <>
    IndyServer.DefaultPort = 8090
    Port = 8090
    Left = 56
    Top = 8
  end
end
