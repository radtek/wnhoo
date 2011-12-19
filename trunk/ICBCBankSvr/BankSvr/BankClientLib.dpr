library BankClientLib;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes;

{$R *.res}

{
    函数成功执行返回True,否则返回 False ,失败获取 rtMsg 可知错误描述
    rtCode 错误码,保留
    rtMsg  提示信息
    rtStr  数据返回,采用"|"分割,每行最后都以 #13#10 作为行结束符,可以返回多条数据
}

//查询帐户卡余(单)

function QueryAccValue_S(const fSeqno, AccNo0: PChar;
  var rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
begin
  rtStr := '0|1209230309049304635|001|0|0|47339538|47340838|47340838|0|20111207115116140591|0|||' + #13#10;
  Result := True;
end;

//查询当日交易记录(多)

function QueryCurDayDetails_M(const fSeqno, AccNo: PChar;
  var NextTag, rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
begin
  rtStr := '2|0|300|2325120|6222031202799000087|三套B|实时充值|一卡通预存|PS01|||||6|000||2011-12-18-22.35.52.672188||' + #13#10 +
    '2|0|300|2325120|6222031202799000087|三套B|实时充值|一卡通预存|PS01|||||6|000||2011-12-18-22.32.50.325419||' + #13#10 +
    '2|0|300|2325120|6222031202799000087|三套B|实时充值|一卡通预存|PS01|||||6|000||2011-12-18-22.31.32.807060||' + #13#10 +
    '2|0|300|2325120|6222031202799000087|三套B|实时充值|一卡通预存|PS01|||||6|000||2011-12-18-22.27.26.358088||' + #13#10 +
    '2|0|300|2325120|6222031202799000087|三套B|实时充值|一卡通预存|PS01|||||6|000||2011-12-18-22.24.51.293923||';
  Result := True;
end;

//支付指令(单) 企业帐户->个人 ,成功后,还需要判断rtStr中的标志,才能决定最终是否成功

function PayEnt_S(const fSeqno, RecAccNo, RecAccNameCN, PayAmt, UseCN, PostScript, Summary: PChar;
  var rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
begin
  rtStr := '';
  Result := True;
end;

//查询支付指令(单) 执行情况,只有交易通讯出现异常时候才查询的

function QueryPayEnt_S(const fSeqno, QryfSeqno: PChar;
  var rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
begin
  rtStr := '';
  Result := True;
end;

//扣个人指令(单)  个人->企业帐户  ,成功后,还需要判断rtStr中的标志,才能决定最终是否成功

function PerDis_S(const fSeqno, PayAccNo, PayAccNameCN, Portno, ContractNo, PayAmt, UseCN, PostScript, Summary: PChar;
  var rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
begin
  rtStr := '';
  Result := True;
end;

//查询扣个人指令(单)执行情况,只有交易通讯出现异常时候才查询的

function QueryPerDis_S(const fSeqno, QryfSeqno: PChar;
  var rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
begin
  rtStr := '';
  Result := True;
end;

exports QueryAccValue_S, QueryCurDayDetails_M, PayEnt_S, QueryPayEnt_S, PerDis_S, QueryPerDis_S;

begin
end.

