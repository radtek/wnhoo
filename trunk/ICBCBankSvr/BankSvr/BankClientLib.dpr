library BankClientLib;

uses
  SysUtils, Windows, Classes, uROClient, uROIndyTCPChannel, uROBinMessage, BankSvrLib_Intf;

{$R *.res}

var
  BS: IBankService;
  RoIndyTcp: TROIndyTCPChannel;
  ROBinMsg: TROBinMessage;

{
��ʼ������
SvrIP   ǰ�÷���IP��ַ
SvrPort ǰ�÷���ķ���˿�
}

function InitParams(const SvrIP: PChar; const SvrPort: Integer): Boolean; stdcall;
begin
  RoIndyTcp.Host := SvrIP;
  RoIndyTcp.Port := SvrPort;
  Result := True;
end;

{
��ȡ������ʱ��
dtStr   ����ǰ�÷���ǰ����ʱ��
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
֧��ָ��(����)
fSeqno        ָ�����,ϵͳ��Ψһ,�Զ���
RecAccNo      �շ��ʺ�
RecAccNameCN  �շ�����
PayAmt        ���׶�,��λ����
UseCN         ��;
PostScript    ����
Summary       ժҪ

rtCode        ������룬����
rtMsg         ����������ǰ�÷�����NC��ICBCͨѶ���������κ��쳣����
rtStr         �����������ݣ��ԡ�|���ָ��#13#10(�س�������)Ϊ��������
                            ���������������ˡ�
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
�۸���ָ��(����)
fSeqno        ָ�����,ϵͳ��Ψһ,�Զ���
PayAccNo      �����ʺ�
PayAccNameCN  ��������
Portno        �ɷѱ��
ContractNo    Э����
PayAmt        ���׶�,��λ����
UseCN         ��;
PostScript    ����
Summary       ժҪ

rtCode        ������룬����
rtMsg         ����������ǰ�÷�����NC��ICBCͨѶ���������κ��쳣����
rtStr         �����������ݣ��ԡ�|���ָ��#13#10(�س�������)Ϊ��������
                            ���������������ˡ�
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
��ѯ�����ʻ�����(����)
fSeqno        ָ�����,ϵͳ��Ψһ,�Զ���
AccNo0        �ʺ�

rtCode        ������룬����
rtMsg         ����������ǰ�÷�����NC��ICBCͨѶ���������κ��쳣����
rtStr         �����������ݣ��ԡ�|���ָ��#13#10(�س�������)Ϊ��������
                            ���������������ˡ�
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
��ѯ������ϸ(���)
fSeqno        ָ�����,ϵͳ��Ψһ,�Զ���
AccNo         �ʺ�

NextTag       �±ʱ�־���״��Ϳ��ַ������ִ�гɹ��˱�־��Ϊ�գ����Լ�����ѯ
                                      ��ѯ��־���ϴη���Ϊֵ��ֱ������Ϊ��Ϊֹ��
rtCode        ������룬����
rtMsg         ����������ǰ�÷�����NC��ICBCͨѶ���������κ��쳣����
rtStr         �����������ݣ��ԡ�|���ָ��#13#10(�س�������)Ϊ��������
                            ���������������ˡ�
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
��ѯ��ʷ��ϸ(���)
fSeqno        ָ�����,ϵͳ��Ψһ,�Զ���
AccNo         �ʺ�
BeginDate     ��ʼ���ڣ���ʽ��YYYYMMDD
EndDate       �������ڣ���ʽ��YYYYMMDD

NextTag       �±ʱ�־���״��Ϳ��ַ������ִ�гɹ��˱�־��Ϊ�գ����Լ�����ѯ
                                      ��ѯ��־���ϴη���Ϊֵ��ֱ������Ϊ��Ϊֹ��
rtCode        ������룬����
rtMsg         ����������ǰ�÷�����NC��ICBCͨѶ���������κ��쳣����
rtStr         �����������ݣ��ԡ�|���ָ��#13#10(�س�������)Ϊ��������
                            ���������������ˡ�
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
��ѯ֧��ָ��(����)
fSeqno        ָ�����,ϵͳ��Ψһ,�Զ���
QryfSeqno     �ϴ�ָ�����

rtCode        ������룬����
rtMsg         ����������ǰ�÷�����NC��ICBCͨѶ���������κ��쳣����
rtStr         �����������ݣ��ԡ�|���ָ��#13#10(�س�������)Ϊ��������
                            ���������������ˡ�
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
��ѯ�۸���ָ��(����)
fSeqno        ָ�����,ϵͳ��Ψһ,�Զ���
QryfSeqno     �ϴ�ָ�����

rtCode        ������룬����
rtMsg         ����������ǰ�÷�����NC��ICBCͨѶ���������κ��쳣����
rtStr         �����������ݣ��ԡ�|���ָ��#13#10(�س�������)Ϊ��������
                            ���������������ˡ�
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

