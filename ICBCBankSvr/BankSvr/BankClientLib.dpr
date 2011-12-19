library BankClientLib;

uses
  SysUtils, Windows, Classes, uROClient, uROIndyTCPChannel, uROBinMessage, BankSvrLib_Intf;

{$R *.res}

var
  BS: IBankService;
  RoIndyTcp: TROIndyTCPChannel;
  ROBinMsg: TROBinMessage;

function InitParams(const SvrIP: PChar; const SvrPort: Integer): Boolean; stdcall;
begin
  RoIndyTcp.Host := SvrIP;
  RoIndyTcp.Port := SvrPort;
  Result := True;
end;

function GetSvrDt(var dtStr: PChar): Boolean;
var
  dt: TDateTime;
begin
  dt := BS.GetSvrDt();
  StrPCopy(dtStr, FormatDateTime('YYYY-MM-DD hh:nn:ss', Dt));
  Result := True;
end;


{
    �����ɹ�ִ�з���True,���򷵻� False ,ʧ�ܻ�ȡ rtMsg ��֪��������
    rtCode ������,����
    rtMsg  ��ʾ��Ϣ
    rtStr  ���ݷ���,����"|"�ָ�,ÿ������� #13#10 ��Ϊ�н�����,���Է��ض�������
}

//��ѯ�ʻ�����(��)

function QueryAccValue_S(const fSeqno, AccNo0: PChar;
  var rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
begin
  rtStr := '0|1209230309049304635|001|0|0|47339538|47340838|47340838|0|20111207115116140591|0|||' + #13#10;
  Result := True;
end;

//��ѯ���ս��׼�¼(��)

function QueryCurDayDetails_M(const fSeqno, AccNo: PChar;
  var NextTag, rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
begin
  rtStr := '2|0|300|2325120|6222031202799000087|����B|ʵʱ��ֵ|һ��ͨԤ��|PS01|||||6|000||2011-12-18-22.35.52.672188||' + #13#10 +
    '2|0|300|2325120|6222031202799000087|����B|ʵʱ��ֵ|һ��ͨԤ��|PS01|||||6|000||2011-12-18-22.32.50.325419||' + #13#10 +
    '2|0|300|2325120|6222031202799000087|����B|ʵʱ��ֵ|һ��ͨԤ��|PS01|||||6|000||2011-12-18-22.31.32.807060||' + #13#10 +
    '2|0|300|2325120|6222031202799000087|����B|ʵʱ��ֵ|һ��ͨԤ��|PS01|||||6|000||2011-12-18-22.27.26.358088||' + #13#10 +
    '2|0|300|2325120|6222031202799000087|����B|ʵʱ��ֵ|һ��ͨԤ��|PS01|||||6|000||2011-12-18-22.24.51.293923||';
  Result := True;
end;

//֧��ָ��(��) ��ҵ�ʻ�->���� ,�ɹ���,����Ҫ�ж�rtStr�еı�־,���ܾ��������Ƿ�ɹ�

function PayEnt_S(const fSeqno, RecAccNo, RecAccNameCN, PayAmt, UseCN, PostScript, Summary: PChar;
  var rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
begin
  rtStr := '';
  Result := True;
end;

//��ѯ֧��ָ��(��) ִ�����,ֻ�н���ͨѶ�����쳣ʱ��Ų�ѯ��

function QueryPayEnt_S(const fSeqno, QryfSeqno: PChar;
  var rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
begin
  rtStr := '';
  Result := True;
end;

//�۸���ָ��(��)  ����->��ҵ�ʻ�  ,�ɹ���,����Ҫ�ж�rtStr�еı�־,���ܾ��������Ƿ�ɹ�

function PerDis_S(const fSeqno, PayAccNo, PayAccNameCN, Portno, ContractNo, PayAmt, UseCN, PostScript, Summary: PChar;
  var rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
begin
  rtStr := '';
  Result := True;
end;

//��ѯ�۸���ָ��(��)ִ�����,ֻ�н���ͨѶ�����쳣ʱ��Ų�ѯ��

function QueryPerDis_S(const fSeqno, QryfSeqno: PChar;
  var rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;
begin
  rtStr := '';
  Result := True;
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
