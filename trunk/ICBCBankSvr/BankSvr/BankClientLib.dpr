library BankClientLib;

uses
  SysUtils, Windows, Classes, uROClient, uROIndyTCPChannel, uROBinMessage, BankSvrLib_Intf;

{$R *.res}

var
  BS: IBankService;
  RoIndyTcp: TROIndyTCPChannel;
  ROBinMsg: TROBinMessage;

{
初始化参数
SvrIP   前置服务IP地址
SvrPort 前置服务的服务端口
}

function InitParams(const SvrIP: PChar; const SvrPort: Integer): Boolean; stdcall;
begin
  RoIndyTcp.Host := SvrIP;
  RoIndyTcp.Port := SvrPort;
  Result := True;
end;

{
获取服务器时间
dtStr   返回前置服务当前日期时间
}

function GetSvrDt(var dtStr: PChar): Boolean; stdcall;
var
  dt: TDateTime;
begin
  dt := BS.GetSvrDt();
  StrPCopy(dtStr, FormatDateTime('YYYY-MM-DD hh:nn:ss', Dt));
  Result := True;
end;

{
支付指令(单笔)
fSeqno        指令序号,系统内唯一,自定义
RecAccNo      收方帐号
RecAccNameCN  收方姓名
PayAmt        交易额,单位：分
UseCN         用途
PostScript    附言
Summary       摘要

rtCode        错误代码，保留
rtMsg         错误描述，前置服务与NC及ICBC通讯及解析的任何异常描述
rtStr         正常返回数据，以“|”分割，以#13#10(回车、换行)为结束符号
                            多条数据依次类退。
}

function PayEnt_S(const fSeqno, RecAccNo, RecAccNameCN, PayAmt, UseCN, PostScript, Summary: PChar;
  var rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
var
  _rtCode, _rtMsg, _rtStr: string;
begin
  Result := BS.PayEnt_S(fSeqno, RecAccNo, RecAccNameCN, PayAmt,
    UseCN, PostScript, Summary, _rtCode, _rtMsg, _rtStr);
  StrPCopy(rtCode, _rtCode);
  StrPCopy(rtMsg, _rtMsg);
  StrPCopy(rtStr, _rtStr);
end;

{
扣个人指令(单笔)
fSeqno        指令序号,系统内唯一,自定义
PayAccNo      付方帐号
PayAccNameCN  付方姓名
Portno        缴费编号
ContractNo    协议编号
PayAmt        交易额,单位：分
UseCN         用途
PostScript    附言
Summary       摘要

rtCode        错误代码，保留
rtMsg         错误描述，前置服务与NC及ICBC通讯及解析的任何异常描述
rtStr         正常返回数据，以“|”分割，以#13#10(回车、换行)为结束符号
                            多条数据依次类退。
}

function PerDis_S(const fSeqno, PayAccNo, PayAccNameCN, Portno,
  ContractNo, PayAmt, UseCN, PostScript, Summary: PChar;
  var rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
var
  _rtCode, _rtMsg, _rtStr: string;
begin
  Result := BS.PerDis_S(fSeqno, PayAccNo, PayAccNameCN, Portno,
    ContractNo, PayAmt, UseCN, PostScript, Summary, _rtCode, _rtMsg, _rtStr);
  StrPCopy(rtCode, _rtCode);
  StrPCopy(rtMsg, _rtMsg);
  StrPCopy(rtStr, _rtStr);
end;

{
查询集团帐户卡余(单笔)
fSeqno        指令序号,系统内唯一,自定义
AccNo0        帐号

rtCode        错误代码，保留
rtMsg         错误描述，前置服务与NC及ICBC通讯及解析的任何异常描述
rtStr         正常返回数据，以“|”分割，以#13#10(回车、换行)为结束符号
                            多条数据依次类退。
}

function QueryAccValue_S(const fSeqno, AccNo0: PChar;
  var rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
var
  _rtCode, _rtMsg, _rtStr: string;
begin
  Result := BS.QueryAccValue_S(fSeqno, AccNo0, _rtCode, _rtMsg, _rtStr);
  StrPCopy(rtCode, _rtCode);
  StrPCopy(rtMsg, _rtMsg);
  StrPCopy(rtStr, _rtStr);
end;

{
查询当日明细(多笔)
fSeqno        指令序号,系统内唯一,自定义
AccNo         帐号

NextTag       下笔标志，首次送空字符，如果执行成功此标志不为空，可以继续查询
                                      查询标志以上次返回为值，直至返回为空为止。
rtCode        错误代码，保留
rtMsg         错误描述，前置服务与NC及ICBC通讯及解析的任何异常描述
rtStr         正常返回数据，以“|”分割，以#13#10(回车、换行)为结束符号
                            多条数据依次类退。
}

function QueryCurDayDetails_M(const fSeqno, AccNo: PChar;
  var NextTag, rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
var
  _NextTag, _rtCode, _rtMsg, _rtStr: string;
begin
  Result := BS.QueryCurDayDetails_M(fSeqno, AccNo, _NextTag, _rtCode, _rtMsg, _rtStr);
  StrPCopy(NextTag, _NextTag);
  StrPCopy(rtCode, _rtCode);
  StrPCopy(rtMsg, _rtMsg);
  StrPCopy(rtStr, _rtStr);
end;

{
查询历史明细(多笔)
fSeqno        指令序号,系统内唯一,自定义
AccNo         帐号
BeginDate     开始日期，格式：YYYYMMDD
EndDate       结束日期，格式：YYYYMMDD

NextTag       下笔标志，首次送空字符，如果执行成功此标志不为空，可以继续查询
                                      查询标志以上次返回为值，直至返回为空为止。
rtCode        错误代码，保留
rtMsg         错误描述，前置服务与NC及ICBC通讯及解析的任何异常描述
rtStr         正常返回数据，以“|”分割，以#13#10(回车、换行)为结束符号
                            多条数据依次类退。
}

function QueryHistoryDetails_M(const fSeqno, AccNo, BeginDate, EndDate: PChar;
  var NextTag, rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
var
  _NextTag, _rtCode, _rtMsg, _rtStr: string;
begin
  Result := BS.QueryHistoryDetails_M(fSeqno, AccNo, BeginDate, EndDate, _NextTag, _rtCode, _rtMsg, _rtStr);
  StrPCopy(NextTag, _NextTag);
  StrPCopy(rtCode, _rtCode);
  StrPCopy(rtMsg, _rtMsg);
  StrPCopy(rtStr, _rtStr);
end;

{
查询支付指令(单笔)
fSeqno        指令序号,系统内唯一,自定义
QryfSeqno     上次指令序号

rtCode        错误代码，保留
rtMsg         错误描述，前置服务与NC及ICBC通讯及解析的任何异常描述
rtStr         正常返回数据，以“|”分割，以#13#10(回车、换行)为结束符号
                            多条数据依次类退。
}

function QueryPayEnt_S(const fSeqno, QryfSeqno: PChar;
  var rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
var
  _rtCode, _rtMsg, _rtStr: string;
begin
  Result := BS.QueryPayEnt_S(fSeqno, QryfSeqno, _rtCode, _rtMsg, _rtStr);
  StrPCopy(rtCode, _rtCode);
  StrPCopy(rtMsg, _rtMsg);
  StrPCopy(rtStr, _rtStr);
end;

{
查询扣个人指令(单笔)
fSeqno        指令序号,系统内唯一,自定义
QryfSeqno     上次指令序号

rtCode        错误代码，保留
rtMsg         错误描述，前置服务与NC及ICBC通讯及解析的任何异常描述
rtStr         正常返回数据，以“|”分割，以#13#10(回车、换行)为结束符号
                            多条数据依次类退。
}

function QueryPerDis_S(const fSeqno, QryfSeqno: PChar;
  var rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
var
  _rtCode, _rtMsg, _rtStr: string;
begin
  Result := BS.QueryPayEnt_S(fSeqno, QryfSeqno, _rtCode, _rtMsg, _rtStr);
  StrPCopy(rtCode, _rtCode);
  StrPCopy(rtMsg, _rtMsg);
  StrPCopy(rtStr, _rtStr);
end;

procedure DLLEntryPoint(dwReason: DWORD);
begin
  case dwReason of
    DLL_THREAD_ATTACH:
      ;
    DLL_THREAD_DETACH:
      ;
    DLL_PROCESS_ATTACH:
      begin
        RoIndyTcp := TROIndyTCPChannel.Create(nil);
        ROBinMsg := TROBinMessage.Create;
        RoIndyTcp.Host := '127.0.0.1';
        RoIndyTcp.Port := 8090;
        BS := CoBankService.Create(ROBinMsg, RoIndyTcp);
      end;
    DLL_PROCESS_DETACH:
      begin
        BS := nil;
        ROBinMsg.Free;
        RoIndyTcp.Free;
      end;
  else
    ;
  end;
end;


exports InitParams, GetSvrDt, QueryAccValue_S, QueryCurDayDetails_M, PayEnt_S, QueryPayEnt_S, PerDis_S, QueryPerDis_S;


begin
  DllProc := @DLLEntryPoint;
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.

