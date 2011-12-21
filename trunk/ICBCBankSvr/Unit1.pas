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
��ʼ������
SvrIP   ǰ�÷���IP��ַ
SvrPort ǰ�÷���ķ���˿�
}
function InitParams(const SvrIP: PChar; const SvrPort: Integer): Boolean; stdcall;External 'BankClientLib.dll';

{
��ȡ������ʱ��
dtStr   ����ǰ�÷���ǰ����ʱ��
}
function GetSvrDt(var dtStr: PChar): Boolean;stdcall;External 'BankClientLib.dll';

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
function PayEnt_S(const fSeqno, RecAccNo, RecAccNameCN, PayAmt,
  UseCN, PostScript, Summary: PChar; var rtCode, rtMsg, rtStr: PChar): Boolean;stdcall;External 'BankClientLib.dll';

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
  ContractNo, PayAmt, UseCN, PostScript, Summary: PChar; var rtCode, rtMsg,
  rtStr: PChar): Boolean;stdcall;External 'BankClientLib.dll';

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
  var rtCode, rtMsg, rtStr: PChar): Boolean;stdcall;External 'BankClientLib.dll';

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
  var NextTag, rtCode, rtMsg, rtStr: PChar): Boolean;stdcall;External 'BankClientLib.dll';

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
  var NextTag, rtCode, rtMsg, rtStr: PChar): Boolean; stdcall;External 'BankClientLib.dll';

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
  var rtCode, rtMsg, rtStr: PChar): Boolean;stdcall; External 'BankClientLib.dll';

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
  //�״��Ϳ�
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
  if U_ICBCCtl.PayEnt_S('PE00010', '6222031202799000087', '����B', '200', 'һ��ͨ�˿�', 'OneIC01', 'һ��ͨ���ҵ��', rtCode, rtMsg, rtStr) then
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
  if U_ICBCCtl.PerDis_S('PD00001', '6222031202799000087', '����B', '111', 'BDP300080432', '300', 'һ��ͨԤ��', 'PS01', 'ʵʱ��ֵ',
    rtCode, rtMsg, rtStr) then
    WriteCmdRtLog(rtStr)
  else
    ShowMsg(rtMsg);
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  rtMsg, rtCode, rtStr, NextTag: string;
begin
  //�״��Ϳ�
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

