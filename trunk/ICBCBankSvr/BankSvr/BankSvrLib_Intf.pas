unit BankSvrLib_Intf;

{----------------------------------------------------------------------------}
{ This unit was automatically generated by the RemObjects SDK after reading  }
{ the RODL file associated with this project .                               }
{                                                                            }
{ Do not modify this unit manually, or your changes will be lost when this   }
{ unit is regenerated the next time you compile the project.                 }
{----------------------------------------------------------------------------}

{$I RemObjects.inc}

interface

uses
  {vcl:} Classes, TypInfo,
  {RemObjects:} uROXMLIntf, uROClasses, uROClient, uROTypes, uROClientIntf;

const
  { Library ID }
  LibraryUID = '{A4E0D59C-DBA0-4ABD-B359-FEB861DF1348}';
  TargetNamespace = '';

  { Service Interface ID's }
  IBankService_IID : TGUID = '{1AA774B9-B606-4BF3-A278-A2BCFB5B2D86}';

  { Event ID's }

type
  { Forward declarations }
  IBankService = interface;


  { IBankService }
  IBankService = interface
    ['{1AA774B9-B606-4BF3-A278-A2BCFB5B2D86}']
    function GetSvrDt: DateTime;
    function QueryAccValue_S(const fSeqno: AnsiString; const AccNo0: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; var rtStr: AnsiString): Boolean;
    function QueryCurDayDetails_M(const fSeqno: AnsiString; const AccNo: AnsiString; var NextTag: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; 
                                  var rtStr: AnsiString): Boolean;
    function PayEnt_S(const fSeqno: AnsiString; const RecAccNo: AnsiString; const RecAccNameCN: AnsiString; const PayAmt: AnsiString; 
                      const UseCN: AnsiString; const PostScript: AnsiString; const Summary: AnsiString; var rtCode: AnsiString; 
                      var rtMsg: AnsiString; var rtStr: AnsiString): Boolean;
    function QueryPayEnt_S(const fSeqno: AnsiString; const QryfSeqno: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; 
                           var rtStr: AnsiString): Boolean;
    function PerDis_S(const fSeqno: AnsiString; const PayAccNo: AnsiString; const PayAccNameCN: AnsiString; const Portno: AnsiString; 
                      const ContractNo: AnsiString; const PayAmt: AnsiString; const UseCN: AnsiString; const PostScript: AnsiString; 
                      const Summary: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; var rtStr: AnsiString): Boolean;
    function QueryPerDis_S(const fSeqno: AnsiString; const QryfSeqno: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; 
                           var rtStr: AnsiString): Boolean;
  end;

  { CoBankService }
  CoBankService = class
    class function Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): IBankService;
  end;

  { TBankService_Proxy }
  TBankService_Proxy = class(TROProxy, IBankService)
  protected
    function __GetInterfaceName:string; override;

    function GetSvrDt: DateTime;
    function QueryAccValue_S(const fSeqno: AnsiString; const AccNo0: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; var rtStr: AnsiString): Boolean;
    function QueryCurDayDetails_M(const fSeqno: AnsiString; const AccNo: AnsiString; var NextTag: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; 
                                  var rtStr: AnsiString): Boolean;
    function PayEnt_S(const fSeqno: AnsiString; const RecAccNo: AnsiString; const RecAccNameCN: AnsiString; const PayAmt: AnsiString; 
                      const UseCN: AnsiString; const PostScript: AnsiString; const Summary: AnsiString; var rtCode: AnsiString; 
                      var rtMsg: AnsiString; var rtStr: AnsiString): Boolean;
    function QueryPayEnt_S(const fSeqno: AnsiString; const QryfSeqno: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; 
                           var rtStr: AnsiString): Boolean;
    function PerDis_S(const fSeqno: AnsiString; const PayAccNo: AnsiString; const PayAccNameCN: AnsiString; const Portno: AnsiString; 
                      const ContractNo: AnsiString; const PayAmt: AnsiString; const UseCN: AnsiString; const PostScript: AnsiString; 
                      const Summary: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; var rtStr: AnsiString): Boolean;
    function QueryPerDis_S(const fSeqno: AnsiString; const QryfSeqno: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; 
                           var rtStr: AnsiString): Boolean;
  end;

implementation

uses
  {vcl:} SysUtils,
  {RemObjects:} uROEventRepository, uROSerializer, uRORes;

{ CoBankService }

class function CoBankService.Create(const aMessage: IROMessage; aTransportChannel: IROTransportChannel): IBankService;
begin
  result := TBankService_Proxy.Create(aMessage, aTransportChannel);
end;

{ TBankService_Proxy }

function TBankService_Proxy.__GetInterfaceName:string;
begin
  result := 'BankService';
end;

function TBankService_Proxy.GetSvrDt: DateTime;
begin
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'BankSvrLib', __InterfaceName, 'GetSvrDt');
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('Result', TypeInfo(DateTime), result, [paIsDateTime]);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

function TBankService_Proxy.QueryAccValue_S(const fSeqno: AnsiString; const AccNo0: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; var rtStr: AnsiString): Boolean;
begin
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'BankSvrLib', __InterfaceName, 'QueryAccValue_S');
    __Message.Write('fSeqno', TypeInfo(AnsiString), fSeqno, []);
    __Message.Write('AccNo0', TypeInfo(AnsiString), AccNo0, []);
    __Message.Write('rtCode', TypeInfo(AnsiString), rtCode, []);
    __Message.Write('rtMsg', TypeInfo(AnsiString), rtMsg, []);
    __Message.Write('rtStr', TypeInfo(AnsiString), rtStr, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('Result', TypeInfo(Boolean), result, []);
    __Message.Read('rtCode', TypeInfo(AnsiString), rtCode, []);
    __Message.Read('rtMsg', TypeInfo(AnsiString), rtMsg, []);
    __Message.Read('rtStr', TypeInfo(AnsiString), rtStr, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

function TBankService_Proxy.QueryCurDayDetails_M(const fSeqno: AnsiString; const AccNo: AnsiString; var NextTag: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; 
                                                 var rtStr: AnsiString): Boolean;
begin
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'BankSvrLib', __InterfaceName, 'QueryCurDayDetails_M');
    __Message.Write('fSeqno', TypeInfo(AnsiString), fSeqno, []);
    __Message.Write('AccNo', TypeInfo(AnsiString), AccNo, []);
    __Message.Write('NextTag', TypeInfo(AnsiString), NextTag, []);
    __Message.Write('rtCode', TypeInfo(AnsiString), rtCode, []);
    __Message.Write('rtMsg', TypeInfo(AnsiString), rtMsg, []);
    __Message.Write('rtStr', TypeInfo(AnsiString), rtStr, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('Result', TypeInfo(Boolean), result, []);
    __Message.Read('NextTag', TypeInfo(AnsiString), NextTag, []);
    __Message.Read('rtCode', TypeInfo(AnsiString), rtCode, []);
    __Message.Read('rtMsg', TypeInfo(AnsiString), rtMsg, []);
    __Message.Read('rtStr', TypeInfo(AnsiString), rtStr, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

function TBankService_Proxy.PayEnt_S(const fSeqno: AnsiString; const RecAccNo: AnsiString; const RecAccNameCN: AnsiString; const PayAmt: AnsiString; 
                                     const UseCN: AnsiString; const PostScript: AnsiString; const Summary: AnsiString; var rtCode: AnsiString; 
                                     var rtMsg: AnsiString; var rtStr: AnsiString): Boolean;
begin
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'BankSvrLib', __InterfaceName, 'PayEnt_S');
    __Message.Write('fSeqno', TypeInfo(AnsiString), fSeqno, []);
    __Message.Write('RecAccNo', TypeInfo(AnsiString), RecAccNo, []);
    __Message.Write('RecAccNameCN', TypeInfo(AnsiString), RecAccNameCN, []);
    __Message.Write('PayAmt', TypeInfo(AnsiString), PayAmt, []);
    __Message.Write('UseCN', TypeInfo(AnsiString), UseCN, []);
    __Message.Write('PostScript', TypeInfo(AnsiString), PostScript, []);
    __Message.Write('Summary', TypeInfo(AnsiString), Summary, []);
    __Message.Write('rtCode', TypeInfo(AnsiString), rtCode, []);
    __Message.Write('rtMsg', TypeInfo(AnsiString), rtMsg, []);
    __Message.Write('rtStr', TypeInfo(AnsiString), rtStr, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('Result', TypeInfo(Boolean), result, []);
    __Message.Read('rtCode', TypeInfo(AnsiString), rtCode, []);
    __Message.Read('rtMsg', TypeInfo(AnsiString), rtMsg, []);
    __Message.Read('rtStr', TypeInfo(AnsiString), rtStr, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

function TBankService_Proxy.QueryPayEnt_S(const fSeqno: AnsiString; const QryfSeqno: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; 
                                          var rtStr: AnsiString): Boolean;
begin
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'BankSvrLib', __InterfaceName, 'QueryPayEnt_S');
    __Message.Write('fSeqno', TypeInfo(AnsiString), fSeqno, []);
    __Message.Write('QryfSeqno', TypeInfo(AnsiString), QryfSeqno, []);
    __Message.Write('rtCode', TypeInfo(AnsiString), rtCode, []);
    __Message.Write('rtMsg', TypeInfo(AnsiString), rtMsg, []);
    __Message.Write('rtStr', TypeInfo(AnsiString), rtStr, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('Result', TypeInfo(Boolean), result, []);
    __Message.Read('rtCode', TypeInfo(AnsiString), rtCode, []);
    __Message.Read('rtMsg', TypeInfo(AnsiString), rtMsg, []);
    __Message.Read('rtStr', TypeInfo(AnsiString), rtStr, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

function TBankService_Proxy.PerDis_S(const fSeqno: AnsiString; const PayAccNo: AnsiString; const PayAccNameCN: AnsiString; const Portno: AnsiString; 
                                     const ContractNo: AnsiString; const PayAmt: AnsiString; const UseCN: AnsiString; const PostScript: AnsiString; 
                                     const Summary: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; var rtStr: AnsiString): Boolean;
begin
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'BankSvrLib', __InterfaceName, 'PerDis_S');
    __Message.Write('fSeqno', TypeInfo(AnsiString), fSeqno, []);
    __Message.Write('PayAccNo', TypeInfo(AnsiString), PayAccNo, []);
    __Message.Write('PayAccNameCN', TypeInfo(AnsiString), PayAccNameCN, []);
    __Message.Write('Portno', TypeInfo(AnsiString), Portno, []);
    __Message.Write('ContractNo', TypeInfo(AnsiString), ContractNo, []);
    __Message.Write('PayAmt', TypeInfo(AnsiString), PayAmt, []);
    __Message.Write('UseCN', TypeInfo(AnsiString), UseCN, []);
    __Message.Write('PostScript', TypeInfo(AnsiString), PostScript, []);
    __Message.Write('Summary', TypeInfo(AnsiString), Summary, []);
    __Message.Write('rtCode', TypeInfo(AnsiString), rtCode, []);
    __Message.Write('rtMsg', TypeInfo(AnsiString), rtMsg, []);
    __Message.Write('rtStr', TypeInfo(AnsiString), rtStr, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('Result', TypeInfo(Boolean), result, []);
    __Message.Read('rtCode', TypeInfo(AnsiString), rtCode, []);
    __Message.Read('rtMsg', TypeInfo(AnsiString), rtMsg, []);
    __Message.Read('rtStr', TypeInfo(AnsiString), rtStr, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

function TBankService_Proxy.QueryPerDis_S(const fSeqno: AnsiString; const QryfSeqno: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; 
                                          var rtStr: AnsiString): Boolean;
begin
  try
    __Message.InitializeRequestMessage(__TransportChannel, 'BankSvrLib', __InterfaceName, 'QueryPerDis_S');
    __Message.Write('fSeqno', TypeInfo(AnsiString), fSeqno, []);
    __Message.Write('QryfSeqno', TypeInfo(AnsiString), QryfSeqno, []);
    __Message.Write('rtCode', TypeInfo(AnsiString), rtCode, []);
    __Message.Write('rtMsg', TypeInfo(AnsiString), rtMsg, []);
    __Message.Write('rtStr', TypeInfo(AnsiString), rtStr, []);
    __Message.Finalize;

    __TransportChannel.Dispatch(__Message);

    __Message.Read('Result', TypeInfo(Boolean), result, []);
    __Message.Read('rtCode', TypeInfo(AnsiString), rtCode, []);
    __Message.Read('rtMsg', TypeInfo(AnsiString), rtMsg, []);
    __Message.Read('rtStr', TypeInfo(AnsiString), rtStr, []);
  finally
    __Message.UnsetAttributes(__TransportChannel);
    __Message.FreeStream;
  end
end;

initialization
  RegisterProxyClass(IBankService_IID, TBankService_Proxy);


finalization
  UnregisterProxyClass(IBankService_IID);

end.
