unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, u_Func, ComCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheet3: TTabSheet;
    mmo_cmdrt: TMemo;
    Button4: TButton;
    Button1: TButton;
    Button3: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button2: TButton;
    Panel2: TPanel;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
    procedure WriteCmdRtLog(const Str: string);
    procedure ShowMsg(const rtMsg: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

{
初始化参数
SvrIP   前置服务IP地址
SvrPort 前置服务的服务端口
}
function InitParams(const SvrIP: PChar; const SvrPort: Integer): Boolean; stdcall;External 'BankClientLib.dll';

{
获取服务器时间
dtStr   返回前置服务当前日期时间
}
function GetSvrDt(var dtStr: PChar): Boolean;stdcall;External 'BankClientLib.dll';

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
function PayEnt_S(const fSeqno, RecAccNo, RecAccNameCN, PayAmt,
  UseCN, PostScript, Summary: PChar; var rtCode, rtMsg, rtStr: PChar): Boolean;stdcall;External 'BankClientLib.dll';

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
  ContractNo, PayAmt, UseCN, PostScript, Summary: PChar; var rtCode, rtMsg,
  rtStr: PChar): Boolean;stdcall;External 'BankClientLib.dll';

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
  var rtCode, rtMsg, rtStr: PChar): Boolean;stdcall;External 'BankClientLib.dll';

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
  var NextTag, rtCode, rtMsg, rtStr: PChar): Boolean;stdcall;External 'BankClientLib.dll';

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
  var NextTag, rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;External 'BankClientLib.dll';

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
  var rtCode, rtMsg, rtStr: PChar): Boolean;stdcall; External 'BankClientLib.dll';

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
  var rtCode, rtMsg, rtStr: PChar): Boolean;stdcall; External 'BankClientLib.dll';

implementation

{$R *.dfm}



procedure TForm1.WriteCmdRtLog(const Str: string);
begin
  mmo_cmdrt.Lines.Add(Str);
end;

procedure TForm1.ShowMsg(const rtMsg: string);
begin
  ShowMessage(rtMsg);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  U_ICBCCtl.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  InitParams('127.0.0.1',10008);
  LoadCfg();
  U_ICBCCtl := TICBCCtlAPI.Create(self);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  rtMsg, rtCode, rtStr, NextTag: string;
begin
  //首次送空
  NextTag := '';
  while True do
  begin
    if U_ICBCCtl.QueryHistoryDetails_M('Q00001', '1209230309049304635','20111201','20111208 ', NextTag, rtCode, rtMsg, rtStr) then
      WriteCmdRtLog(rtStr)
    else
      ShowMsg(rtMsg);
    if NextTag = '' then Break;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  rtCode, rtMsg, rtStr: string;
begin
  if U_ICBCCtl.QueryPayEnt_S('Q00008', 'PE00010', rtCode, rtMsg, rtStr) then
    WriteCmdRtLog(rtStr)
  else
    ShowMsg(rtMsg);
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  rtCode, rtMsg, rtStr: string;
begin
  if U_ICBCCtl.PayEnt_S('PE00010', '6222031202799000087', '三套B', '200', '一卡通退款', 'OneIC01', '一卡通相关业务', rtCode, rtMsg, rtStr) then
    WriteCmdRtLog(rtStr)
  else
    ShowMsg(rtMsg);
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  rtCode, rtMsg, rtStr: string;
begin
  if U_ICBCCtl.QueryAccValue_S('Q00001', '1209230309049304635', rtCode, rtMsg, rtStr) then
    WriteCmdRtLog(rtStr)
  else
    ShowMsg(rtMsg);
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  rtCode, rtMsg, rtStr: string;
begin
  if U_ICBCCtl.QueryPerDis_S('Q00008', 'PD00001', rtCode, rtMsg, rtStr) then
    WriteCmdRtLog(rtStr)
  else
    ShowMsg(rtMsg);
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  rtCode, rtMsg, rtStr: string;
begin
  if U_ICBCCtl.PerDis_S('PD00001', '6222031202799000087', '三套B', '111', 'BDP300080432', '300', '一卡通预存', 'PS01', '实时充值',
    rtCode, rtMsg, rtStr) then
    WriteCmdRtLog(rtStr)
  else
    ShowMsg(rtMsg);
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  rtMsg, rtCode, rtStr, NextTag: string;
begin
  //首次送空
  NextTag := '';
  while True do
  begin
    if U_ICBCCtl.QueryCurDayDetails_M('Q00001', '1209230309049304635', NextTag, rtCode, rtMsg, rtStr) then
      WriteCmdRtLog(rtStr)
    else
      ShowMsg(rtMsg);
    if NextTag = '' then Break;
  end;
end;

procedure TForm1.Button8Click(Sender: TObject);
var
  rtCode, rtMsg, rtStr:PChar;
begin
  GetMem(rtCode,100);
  GetMem(rtMsg,512);
  GetMem(rtStr,512);
  if QueryAccValue_S('Q00001', '1209230309049304635', rtCode, rtMsg, rtStr) then
    WriteCmdRtLog(rtStr)
  else
    ShowMsg(rtMsg);
  FreeMem(rtCode,100);
  FreeMem(rtMsg,512);
  FreeMem(rtStr,512);
end;


end.

