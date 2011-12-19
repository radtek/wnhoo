unit BankSvrLib_Invk;

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
  {vcl:} Classes,
  {RemObjects:} uROXMLIntf, uROServer, uROServerIntf, uROTypes, uROClientIntf,
  {Generated:} BankSvrLib_Intf;

type
  TBankService_Invoker = class(TROInvoker)
  private
  protected
  public
    constructor Create; override;
  published
    procedure Invoke_GetSvrDt(const __Instance:IInterface; const __Message:IROMessage; const __Transport:IROTransport; out __oResponseOptions:TROResponseOptions);
    procedure Invoke_QueryAccValue_S(const __Instance:IInterface; const __Message:IROMessage; const __Transport:IROTransport; out __oResponseOptions:TROResponseOptions);
  end;

implementation

uses
  {RemObjects:} uRORes, uROClient;

{ TBankService_Invoker }

constructor TBankService_Invoker.Create;
begin
  inherited Create;
  FAbstract := False;
end;

procedure TBankService_Invoker.Invoke_GetSvrDt(const __Instance:IInterface; const __Message:IROMessage; const __Transport:IROTransport; out __oResponseOptions:TROResponseOptions);
{ function GetSvrDt: DateTime; }
var
  lResult: DateTime;
begin
  try
    lResult := (__Instance as IBankService).GetSvrDt;

    __Message.InitializeResponseMessage(__Transport, 'BankSvrLib', 'BankService', 'GetSvrDtResponse');
    __Message.Write('Result', TypeInfo(DateTime), lResult, [paIsDateTime]);
    __Message.Finalize;
    __Message.UnsetAttributes(__Transport);

  finally
  end;
end;

procedure TBankService_Invoker.Invoke_QueryAccValue_S(const __Instance:IInterface; const __Message:IROMessage; const __Transport:IROTransport; out __oResponseOptions:TROResponseOptions);
{ function QueryAccValue_S(const fSeqno: AnsiString; const AccNo0: AnsiString; var rtCode: AnsiString; var rtMsg: AnsiString; var rtStr: AnsiString): Boolean; }
var
  fSeqno: AnsiString;
  AccNo0: AnsiString;
  rtCode: AnsiString;
  rtMsg: AnsiString;
  rtStr: AnsiString;
  lResult: Boolean;
begin
  try
    __Message.Read('fSeqno', TypeInfo(AnsiString), fSeqno, []);
    __Message.Read('AccNo0', TypeInfo(AnsiString), AccNo0, []);
    __Message.Read('rtCode', TypeInfo(AnsiString), rtCode, []);
    __Message.Read('rtMsg', TypeInfo(AnsiString), rtMsg, []);
    __Message.Read('rtStr', TypeInfo(AnsiString), rtStr, []);

    lResult := (__Instance as IBankService).QueryAccValue_S(fSeqno, AccNo0, rtCode, rtMsg, rtStr);

    __Message.InitializeResponseMessage(__Transport, 'BankSvrLib', 'BankService', 'QueryAccValue_SResponse');
    __Message.Write('Result', TypeInfo(Boolean), lResult, []);
    __Message.Write('rtCode', TypeInfo(AnsiString), rtCode, []);
    __Message.Write('rtMsg', TypeInfo(AnsiString), rtMsg, []);
    __Message.Write('rtStr', TypeInfo(AnsiString), rtStr, []);
    __Message.Finalize;
    __Message.UnsetAttributes(__Transport);

  finally
  end;
end;

initialization
end.
