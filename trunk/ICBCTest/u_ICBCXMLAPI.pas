(*
    ICBC指令解析
    原始作者：王云涛
    建立时间：2011-12-02
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
    TransCode: string[10]; //	交易代码	必输项	字符	10	PAYENT
    CIS: string[60]; //	集团CIS号	必输项	字符	60	客户注册时的归属编码
    BankCode: string[3]; //	归属银行编号	必输项	字符	3	客户注册时的归属单位
    ID: string[40]; //	证书ID	必输项	字符	40	无证书客户可上送空
    TranDate: string[8]; //	交易日期	必输项	字符	8	ERP系统产生的交易日期，格式是yyyyMMdd
    TranTime: string[12]; //	交易时间	必输项	字符	12	ERP系统产生的交易时间，格式如hhmmssaaabbb，精确到微秒；
    fSeqno: string[35]; //	指令包序列号	必输项	字符	35	ERP系统产生的指令包序列号，一个集团永远不能重复；
  end;

  //查询历史明细
  TQueryHistoryDetailsRec = record
    AccNo: string[19]; //	查询账号	必输项	数字	19
    BeginDate: string[8]; //	起始日期	必输项	数字	8	起始日期必须小于等于截止日期；
    EndDate: string[8]; //	截止日期	必输项	数字	8	格式是yyyyMMdd
    MinAmt: string[17]; //	发生额下限	选输项	数字	17	若输入则必须为大于或等于零的整数，单位为分
    MaxAmt: string[17]; //	发生额上限	选输项	数字	17	若输入则必须为大于或等于零的整数，单位为分.发生额上下限都有值时则下限必须小于等于上限
    NextTag: string[60]; //	查询下页标识	选输项	字符	60	查询首页上送空；其他页需与银行返回包提供的一致
    ReqReserved1: string[3]; //	请求包备用字段1	选输项	数字	3	行别,集团有他行帐号时为必输
    ReqReserved2: string[100]; //	请求包备用字段2	选输项	字符	100	备用，目前无意义
  end;

  //多账户余额查询
  TQueryAccValueRec = record
    TotalNum: string[6]; //	总笔数	必输项	数字	6	需要查询明细的笔数
    ReqReserved1: string[100]; //	请求包备用字段1	选输项	字符	100	备用，目前无意义
    ReqReserved2: string[100]; //	请求包备用字段2	选输项	字符	100	备用，目前无意义
    rd: array of record
      iSeqno: string[35]; //	指令顺序号	必输项	字符	35	不能为空，并且不能重复
      AccNo: string[19]; //	帐号	必输项	数字	19
      CurrType: string[3]; //	币种	选输项	字符	3	工行币种代码,不输入则自动取帐号币种
      ReqReserved3: string[3]; //	请求包备用字段3	选输项	数字	3	行别,集团有他行帐号时为必输项
      ReqReserved4: string[100]; //	请求包备用字段4	选输项	字符	100	备用，目前无意义
    end;
  end;

  //支付指令提交
  TInOutCMDRec = record
    OnlBatF: string[1]; //	联机批量标志	选输项	数字	1	1：联机
    SettleMode: string[1]; //	入账方式	必输项	数字	1	2：并笔入账 0：逐笔记账
    TotalNum: string[6]; //	总笔数	必输项	数字	6	指令包内的指令笔数
    TotalAmt: string[20]; //	总金额	必输项	数字	20	无正负号，不带小数点，以分作单位
    SignTime: string[17]; //	签名时间	必输项	字符	17	格式是yyyyMMddhhmmssSSS
    ReqReserved1: string[100]; //	请求备用字段1	选输项	字符	100	备用，目前无意义
    ReqReserved2: string[100]; //	请求备用字段2	选输项	字符	100	备用，目前无意义
    rd: array of record
      iSeqno: string[35]; //	指令顺序号	必输项	字符	35	每笔指令的序号，本包内不重复。（工行只检查包内不重复，不同的包，工行不做指令顺序号重复性的检查。）
      ReimburseNo: string[40]; //	自定义序号	选输项	字符	40
      ReimburseNum: string[10]; //	单据张数	选输项	字符	10
      StartDate: string[8]; //	定时启动日期	选输项	字符	8	格式是yyyyMMdd
      StartTime: string[6]; //	定时启动时间	选输项	字符	6	格式是hhmmss
      PayType: string[1]; //	记账处理方式	必输项	数字	1	1：加急 2：普通
      PayAccNo: string[34]; //	本方账号	必输项	数字	34
      PayAccNameCN: string[100]; //	本方账户名称	选输项	字符	100	根据人行标准，人民币账户的户名不应超过60字节，否则该字段可能被截取
      PayAccNameEN: string[100]; //	本方账户英文名称	选输项	字符	100	中文名称、英文名称二者必输其一。
      RecAccNo: string[34]; //	对方账号	必输项	字符	34
      RecAccNameCN: string[100]; //	对方账户名称	选输项	字符	100	根据人行标准，人民币账户的户名不应超过60字节，否则该字段可能被截取
      RecAccNameEN: string[100]; //	对方账户英文名称	选输项	字符	100	中文名称、英文名称二者必输其一。
      SysIOFlg: string[1]; //	系统内外标志	必输项	数字	1	"1：系统内 2：系统外"
      IsSameCity: string[1]; //	同城异地标志	选输项	数字	1	"1：同城 2：异地"
      Prop: string[1]; //	对公对私标志	选输项	数字	1	"跨行必输 0：对公账户 1：个人账户"
      RecICBCCode: string[5]; //	交易对方工行地区号	选输项	数字	5	4位工行地区号
      RecCityName: string[40]; //	收款方所在城市名称	选输项	字符	40	跨行指令此项必输
      RecBankNo: string[13]; //	对方行行号	选输项	字符	13
      RecBankName: string[60]; //	交易对方银行名称	必输项	字符	60	跨行指令此项必输,中文，60位字符。
      CurrType: string[3]; //	币种	必输项	字符	3
      PayAmt: string[17]; //	金额	必输项	数字	17	无正负号，不带小数点，以分作单位
      UseCode: string[3]; //	用途代码	选输项	字符	3
      UseCN: string[20]; //	用途中文描述	选输项	字符	20	"用途代码和用途中文描述必输其一;如需跨行实时到帐此项最多10个字符.超长则落地处理."
      EnSummary: string[40]; //	英文备注	选输项	字符	40	必须ASCII字符
      PostScript: string[100]; //	附言	选输项	字符	100
      Summary: string[20]; //	摘要	选输项	字符	20
      Ref: string[20]; //	业务编号（业务参考号）	选输项	字符	20	必须ASCII字符
      Oref: string[20]; //	相关业务编号	选输项	字符	20	必须ASCII字符
      ERPSqn: string[20]; //	ERP流水号	选输项	字符	20	必须ASCII字符
      BusCode: string[5]; //	业务代码	选输项	字符	5	必须ASCII字符
      ERPcheckno: string[8]; //	ERP支票号	选输项	字符	8	必须ASCII字符
      CrvouhType: string[3]; //	原始凭证种类	选输项	字符	3	必须ASCII字符
      CrvouhName: string[30]; //	原始凭证名称	选输项	字符	30
      CrvouhNo: string[20]; //	原始凭证号	选输项	字符	20	必须ASCII字符
      ReqReserved3: string[3]; //	请求备用字段3	选输项	字符	3	付款账号行别，不输或输入102代表工行
      ReqReserved4: string[100]; //	请求备用字段4	选输项	字符	100	备用，目前无意义
    end;
  end;

  //网点信息下载
  TQueryNetNodeRec = record
    NextTag: string[60]; //	查询下页标识	选输项	字符	60	查询首页上送空；其他页需与银行返回包提供的一致
    ReqReserved1: string[100]; //	请求备用字段1	选输项	字符	100	备用，目前无意义
    ReqReserved2: string[100]; //	请求备用字段2	选输项	字符	100	备用，目前无意义
  end;

  //行名行号信息下载
  THMHN = record
    BnkCode: string[3]; //	行别代码	可选项	字符	3
    NextTag: string[60]; //	查询下页标识	可选项	字符	60	查询首页上送空；其他页需与银行返回包提供的一致
    ReqReserved1: string[100]; //	请求备用字段1	可选项	字符	100	备用，目前无意义
    ReqReserved2: string[100]; //	请求备用字段2	可选项	字符	100	备用，目前无意义
  end;

  TICBCXMLAPI = class(TBASEXMLAPI)
  private
    FCMS, Feb: IXMLNode;
    _in,_pub: IXMLNode;
  public
    constructor Create(AOwner: TComponent); override;
    //公共头
    procedure addPub(const pub: TPubRec);
    //查询历史明细
    procedure addQueryHistoryDetails(const indata: TQueryHistoryDetailsRec);
    //多账户余额查询
    procedure addQueryAccValue(const indata: TQueryAccValueRec);
    //查询网点信息
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

