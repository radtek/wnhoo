(*
    ICBCָ�����
    ԭʼ���ߣ�������
    ����ʱ�䣺2011-12-02
*)
unit u_ICBCXMLAPI;

interface

uses

  SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, Variants, BASEXMLAPI;

const
  PUBSTR='pub';
  INSTR='in';

type

  TPubRec = record
    TransCode: string[10]; //	���״���	������	�ַ�	10	PAYENT
    CIS: string[60]; //	����CIS��	������	�ַ�	60	�ͻ�ע��ʱ�Ĺ�������
    BankCode: string[3]; //	�������б��	������	�ַ�	3	�ͻ�ע��ʱ�Ĺ�����λ
    ID: string[40]; //	֤��ID	������	�ַ�	40	��֤��ͻ������Ϳ�
    TranDate: string[8]; //	��������	������	�ַ�	8	ERPϵͳ�����Ľ������ڣ���ʽ��yyyyMMdd
    TranTime: string[12]; //	����ʱ��	������	�ַ�	12	ERPϵͳ�����Ľ���ʱ�䣬��ʽ��hhmmssaaabbb����ȷ��΢�룻
    fSeqno: string[35]; //	ָ������к�	������	�ַ�	35	ERPϵͳ������ָ������кţ�һ��������Զ�����ظ���
  end;

  //��ѯ��ʷ��ϸ
  TQueryHistoryDetailsRec = record
    AccNo: string[19]; //	��ѯ�˺�	������	����	19
    BeginDate: string[8]; //	��ʼ����	������	����	8	��ʼ���ڱ���С�ڵ��ڽ�ֹ���ڣ�
    EndDate: string[8]; //	��ֹ����	������	����	8	��ʽ��yyyyMMdd
    MinAmt: string[17]; //	����������	ѡ����	����	17	�����������Ϊ���ڻ���������������λΪ��
    MaxAmt: string[17]; //	����������	ѡ����	����	17	�����������Ϊ���ڻ���������������λΪ��.�����������޶���ֵʱ�����ޱ���С�ڵ�������
    NextTag: string[60]; //	��ѯ��ҳ��ʶ	ѡ����	�ַ�	60	��ѯ��ҳ���Ϳգ�����ҳ�������з��ذ��ṩ��һ��
    ReqReserved1: string[3]; //	����������ֶ�1	ѡ����	����	3	�б�,�����������ʺ�ʱΪ����
    ReqReserved2: string[100]; //	����������ֶ�2	ѡ����	�ַ�	100	���ã�Ŀǰ������
  end;

  //���˻�����ѯ
  TQueryAccValueRec = record
    TotalNum: string[6]; //	�ܱ���	������	����	6	��Ҫ��ѯ��ϸ�ı���
    ReqReserved1: string[100]; //	����������ֶ�1	ѡ����	�ַ�	100	���ã�Ŀǰ������
    ReqReserved2: string[100]; //	����������ֶ�2	ѡ����	�ַ�	100	���ã�Ŀǰ������
    rd: array of record
      iSeqno: string[35]; //	ָ��˳���	������	�ַ�	35	����Ϊ�գ����Ҳ����ظ�
      AccNo: string[19]; //	�ʺ�	������	����	19
      CurrType: string[3]; //	����	ѡ����	�ַ�	3	���б��ִ���,���������Զ�ȡ�ʺű���
      ReqReserved3: string[3]; //	����������ֶ�3	ѡ����	����	3	�б�,�����������ʺ�ʱΪ������
      ReqReserved4: string[100]; //	����������ֶ�4	ѡ����	�ַ�	100	���ã�Ŀǰ������
    end;
  end;

  //֧��ָ���ύ
  TInOutCMDRec = record
    OnlBatF: string[1]; //	����������־	ѡ����	����	1	1������
    SettleMode: string[1]; //	���˷�ʽ	������	����	1	2���������� 0����ʼ���
    TotalNum: string[6]; //	�ܱ���	������	����	6	ָ����ڵ�ָ�����
    TotalAmt: string[20]; //	�ܽ��	������	����	20	�������ţ�����С���㣬�Է�����λ
    SignTime: string[17]; //	ǩ��ʱ��	������	�ַ�	17	��ʽ��yyyyMMddhhmmssSSS
    ReqReserved1: string[100]; //	�������ֶ�1	ѡ����	�ַ�	100	���ã�Ŀǰ������
    ReqReserved2: string[100]; //	�������ֶ�2	ѡ����	�ַ�	100	���ã�Ŀǰ������
    rd: array of record
      iSeqno: string[35]; //	ָ��˳���	������	�ַ�	35	ÿ��ָ�����ţ������ڲ��ظ���������ֻ�����ڲ��ظ�����ͬ�İ������в���ָ��˳����ظ��Եļ�顣��
      ReimburseNo: string[40]; //	�Զ������	ѡ����	�ַ�	40
      ReimburseNum: string[10]; //	��������	ѡ����	�ַ�	10
      StartDate: string[8]; //	��ʱ��������	ѡ����	�ַ�	8	��ʽ��yyyyMMdd
      StartTime: string[6]; //	��ʱ����ʱ��	ѡ����	�ַ�	6	��ʽ��hhmmss
      PayType: string[1]; //	���˴���ʽ	������	����	1	1���Ӽ� 2����ͨ
      PayAccNo: string[34]; //	�����˺�	������	����	34
      PayAccNameCN: string[100]; //	�����˻�����	ѡ����	�ַ�	100	�������б�׼��������˻��Ļ�����Ӧ����60�ֽڣ�������ֶο��ܱ���ȡ
      PayAccNameEN: string[100]; //	�����˻�Ӣ������	ѡ����	�ַ�	100	�������ơ�Ӣ�����ƶ��߱�����һ��
      RecAccNo: string[34]; //	�Է��˺�	������	�ַ�	34
      RecAccNameCN: string[100]; //	�Է��˻�����	ѡ����	�ַ�	100	�������б�׼��������˻��Ļ�����Ӧ����60�ֽڣ�������ֶο��ܱ���ȡ
      RecAccNameEN: string[100]; //	�Է��˻�Ӣ������	ѡ����	�ַ�	100	�������ơ�Ӣ�����ƶ��߱�����һ��
      SysIOFlg: string[1]; //	ϵͳ�����־	������	����	1	"1��ϵͳ�� 2��ϵͳ��"
      IsSameCity: string[1]; //	ͬ����ر�־	ѡ����	����	1	"1��ͬ�� 2�����"
      Prop: string[1]; //	�Թ���˽��־	ѡ����	����	1	"���б��� 0���Թ��˻� 1�������˻�"
      RecICBCCode: string[5]; //	���׶Է����е�����	ѡ����	����	5	4λ���е�����
      RecCityName: string[40]; //	�տ���ڳ�������	ѡ����	�ַ�	40	����ָ��������
      RecBankNo: string[13]; //	�Է����к�	ѡ����	�ַ�	13
      RecBankName: string[60]; //	���׶Է���������	������	�ַ�	60	����ָ��������,���ģ�60λ�ַ���
      CurrType: string[3]; //	����	������	�ַ�	3
      PayAmt: string[17]; //	���	������	����	17	�������ţ�����С���㣬�Է�����λ
      UseCode: string[3]; //	��;����	ѡ����	�ַ�	3
      UseCN: string[20]; //	��;��������	ѡ����	�ַ�	20	"��;�������;��������������һ;�������ʵʱ���ʴ������10���ַ�.��������ش���."
      EnSummary: string[40]; //	Ӣ�ı�ע	ѡ����	�ַ�	40	����ASCII�ַ�
      PostScript: string[100]; //	����	ѡ����	�ַ�	100
      Summary: string[20]; //	ժҪ	ѡ����	�ַ�	20
      Ref: string[20]; //	ҵ���ţ�ҵ��ο��ţ�	ѡ����	�ַ�	20	����ASCII�ַ�
      Oref: string[20]; //	���ҵ����	ѡ����	�ַ�	20	����ASCII�ַ�
      ERPSqn: string[20]; //	ERP��ˮ��	ѡ����	�ַ�	20	����ASCII�ַ�
      BusCode: string[5]; //	ҵ�����	ѡ����	�ַ�	5	����ASCII�ַ�
      ERPcheckno: string[8]; //	ERP֧Ʊ��	ѡ����	�ַ�	8	����ASCII�ַ�
      CrvouhType: string[3]; //	ԭʼƾ֤����	ѡ����	�ַ�	3	����ASCII�ַ�
      CrvouhName: string[30]; //	ԭʼƾ֤����	ѡ����	�ַ�	30
      CrvouhNo: string[20]; //	ԭʼƾ֤��	ѡ����	�ַ�	20	����ASCII�ַ�
      ReqReserved3: string[3]; //	�������ֶ�3	ѡ����	�ַ�	3	�����˺��б𣬲��������102������
      ReqReserved4: string[100]; //	�������ֶ�4	ѡ����	�ַ�	100	���ã�Ŀǰ������
    end;
  end;

  //������Ϣ����
  TQueryNetNodeRec = record
    NextTag: string[60]; //	��ѯ��ҳ��ʶ	ѡ����	�ַ�	60	��ѯ��ҳ���Ϳգ�����ҳ�������з��ذ��ṩ��һ��
    ReqReserved1: string[100]; //	�������ֶ�1	ѡ����	�ַ�	100	���ã�Ŀǰ������
    ReqReserved2: string[100]; //	�������ֶ�2	ѡ����	�ַ�	100	���ã�Ŀǰ������
  end;

  //�����к���Ϣ����
  THMHN = record
    BnkCode: string[3]; //	�б����	��ѡ��	�ַ�	3
    NextTag: string[60]; //	��ѯ��ҳ��ʶ	��ѡ��	�ַ�	60	��ѯ��ҳ���Ϳգ�����ҳ�������з��ذ��ṩ��һ��
    ReqReserved1: string[100]; //	�������ֶ�1	��ѡ��	�ַ�	100	���ã�Ŀǰ������
    ReqReserved2: string[100]; //	�������ֶ�2	��ѡ��	�ַ�	100	���ã�Ŀǰ������
  end;

  TICBCXMLAPI = class(TBASEXMLAPI)
  private
    FCMS, Feb: IXMLNode;
    _in,_pub: IXMLNode;
  public
    constructor Create(AOwner: TComponent); override;
    //����ͷ
    procedure addPub(const pub: TPubRec);
    //��ѯ��ʷ��ϸ
    procedure addQueryHistoryDetails(const indata: TQueryHistoryDetailsRec);
    //���˻�����ѯ
    procedure addQueryAccValue(const indata: TQueryAccValueRec);
    //��ѯ������Ϣ
    procedure addQueryNetNodeRec(const indata: TQueryNetNodeRec);
  end;

implementation

{ TICBCXMLAPI }

constructor TICBCXMLAPI.Create(AOwner: TComponent);
begin
  inherited;
  FXD.Active := True;
  FXD.Version := '1.0';
  FXD.Encoding := 'GBK';
  FXD.Options := [doNodeAutoCreate, doNodeAutoIndent,
    doAttrNull, doAutoPrefix, doNamespaceDecl];

  FCMS := FXD.CreateNode('CMS');
  FXD.DocumentElement := FCMS;
  Feb := FCMS.AddChild('eb');

  _pub := Feb.AddChild(PUBSTR);
  _in := Feb.AddChild(INSTR);
end;

procedure TICBCXMLAPI.addQueryNetNodeRec(const indata: TQueryNetNodeRec);
begin
  _in.AddChild('NextTag').Text := indata.NextTag;
  _in.AddChild('ReqReserved1').Text := indata.ReqReserved1;
  _in.AddChild('ReqReserved2').Text := indata.ReqReserved2;
end;

procedure TICBCXMLAPI.addPub(const pub: TPubRec);
begin
  _pub.AddChild('TransCode').Text := pub.TransCode;
  _pub.AddChild('CIS').Text := pub.CIS;
  _pub.AddChild('BankCode').Text := pub.BankCode;
  _pub.AddChild('ID').Text := pub.ID;
  _pub.AddChild('TranDate').Text := pub.TranDate;
  _pub.AddChild('TranTime').Text := pub.TranTime;
  _pub.AddChild('fSeqno').Text := pub.fSeqno;
end;

procedure TICBCXMLAPI.addQueryHistoryDetails(const indata: TQueryHistoryDetailsRec);
begin
  _in.AddChild('AccNo').Text := indata.AccNo;
  _in.AddChild('BeginDate').Text := indata.BeginDate;
  _in.AddChild('EndDate').Text := indata.EndDate;
  _in.AddChild('MinAmt').Text := indata.MinAmt;
  _in.AddChild('MaxAmt').Text := indata.MaxAmt;
  _in.AddChild('NextTag').Text := indata.NextTag;
  _in.AddChild('ReqReserved1').Text := indata.ReqReserved1;
  _in.AddChild('ReqReserved2').Text := indata.ReqReserved2;
end;

procedure TICBCXMLAPI.addQueryAccValue(const indata: TQueryAccValueRec);
var
  rd: IXMLNode;
  I: Integer;
begin
  _in.AddChild('TotalNum').Text := indata.TotalNum;
  _in.AddChild('ReqReserved1').Text := indata.ReqReserved1;
  _in.AddChild('ReqReserved2').Text := indata.ReqReserved2;
  for I := Low(indata.rd) to High(indata.rd) do
  begin
    rd := _in.AddChild('rd');
    rd.AddChild('iSeqno').Text := indata.rd[i].iSeqno;
    rd.AddChild('AccNo').Text := indata.rd[i].AccNo;
    rd.AddChild('CurrType').Text := indata.rd[i].CurrType;
    rd.AddChild('ReqReserved3').Text := indata.rd[i].ReqReserved3;
    rd.AddChild('ReqReserved4').Text := indata.rd[i].ReqReserved4;
  end;
end;

end.

