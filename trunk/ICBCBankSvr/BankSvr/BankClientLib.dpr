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

exports QueryAccValue_S, QueryCurDayDetails_M, PayEnt_S, QueryPayEnt_S, PerDis_S, QueryPerDis_S;

begin
end.

