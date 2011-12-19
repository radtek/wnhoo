(*
    ICBC指令解析
    原始作者：王云涛
    建立时间：2011-12-02
*)
unit u_ICBCXMLAPI;

interface

uses

  SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, msxml, Variants, BASEXMLAPI, u_ICBCRec, Dialogs;

type

  TICBCRequestAPI = class(TBASEXMLAPI)
  private
    FCMS, Feb: IXMLNode;
    _in, _pub: IXMLNode;

  public
    constructor Create(AOwner: TComponent); override;
    //公共头
    procedure setPub(const pub: TPubRec);
    //查询历史明细
    procedure setQueryHistoryDetailsRec(const indata: TQueryHistoryDetailsRec);
    //查询当日明细
    procedure setQueryCurDayDetailsRec(const indata: TQueryCurDayDetailsRec);
    //多账户余额查询
    procedure setQueryAccValue(const indata: TQueryAccValueRec);
    //查询网点信息
    procedure setQueryNetNodeRec(const indata: TQueryNetNodeRec);
    //支付指令提交
    procedure setPayEntRec(const indata: TPayEntRec);
    //支付指令提交查询
    procedure setQueryPayEntRec(const indata: TQueryPayEntRec);
    //批量扣个人指令提交(汇总)
    procedure setPerDisRec(const indata: TPerDisRec);
    //批量扣个人指令查询
    procedure setQueryPerDisRec(const indata: TQueryPerDisRec);
  end;

  TICBCResponseAPI = class(TBASEXMLAPI)
  private
    _out, _pub: IXMLDOMNode;
    FPubRec: TPubRec;
  protected
    procedure ParserXML(); override;
  public
    //查询网点信息
    function getQueryNetNodeRec: TQueryNetNodeRec;
    //多账户余额查询
    function getQueryAccValue: TQueryAccValueRec;
    //查询历史明细
    function getQueryHistoryDetails: TQueryHistoryDetailsRec;
    //查询当日明细
    function getQueryCurDayDetails: TQueryCurDayDetailsRec;
    //支付指令提交
    function getPayEnt: TPayEntRec;
    //支付指令提交查询
    function getQueryPayEnt: TQueryPayEntRec;
    //批量扣个人指令提交(汇总)
    function getPerDis: TPerDisRec;
    //批量扣个人指令查询
    function getQueryPerDis: TQueryPerDisRec;

    property Pub: TPubRec read FPubRec;

  end;

implementation

{ TICBCXMLAPI }

constructor TICBCRequestAPI.Create(AOwner: TComponent);
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

  _pub := Feb.AddChild('pub');
  _in := Feb.AddChild('in');
end;

procedure TICBCRequestAPI.setPayEntRec(const indata: TPayEntRec);
var
  rd: IXMLNode;
  I: Integer;
begin
  _in.ChildNodes.Clear;
  _in.AddChild('OnlBatF').Text := indata.OnlBatF;
  _in.AddChild('SettleMode').Text := indata.SettleMode;
  _in.AddChild('TotalNum').Text := indata.TotalNum;
  _in.AddChild('TotalAmt').Text := indata.TotalAmt;
  _in.AddChild('SignTime').Text := indata.SignTime;
  _in.AddChild('ReqReserved1').Text := indata._Reserved1;
  _in.AddChild('ReqReserved2').Text := indata._Reserved2;
  for I := Low(indata.rd) to High(indata.rd) do
  begin
    rd := _in.AddChild('rd');
    rd.AddChild('iSeqno').Text := indata.rd[i].iSeqno;
    rd.AddChild('ReimburseNo').Text := indata.rd[i].ReimburseNo;
    rd.AddChild('ReimburseNum').Text := indata.rd[i].ReimburseNum;
    rd.AddChild('StartDate').Text := indata.rd[i].StartDate;
    rd.AddChild('StartTime').Text := indata.rd[i].StartTime;
    rd.AddChild('PayType').Text := indata.rd[i].PayType;
    rd.AddChild('PayAccNo').Text := indata.rd[i].PayAccNo;
    rd.AddChild('PayAccNameCN').Text := indata.rd[i].PayAccNameCN;
    rd.AddChild('PayAccNameEN').Text := indata.rd[i].PayAccNameEN;
    rd.AddChild('RecAccNo').Text := indata.rd[i].RecAccNo;
    rd.AddChild('RecAccNameCN').Text := indata.rd[i].RecAccNameCN;
    rd.AddChild('RecAccNameEN').Text := indata.rd[i].RecAccNameEN;
    rd.AddChild('SysIOFlg').Text := indata.rd[i].SysIOFlg;
    rd.AddChild('IsSameCity').Text := indata.rd[i].IsSameCity;
    rd.AddChild('Prop').Text := indata.rd[i].Prop;
    rd.AddChild('RecICBCCode').Text := indata.rd[i].RecICBCCode;
    rd.AddChild('RecCityName').Text := indata.rd[i].RecCityName;
    rd.AddChild('RecBankNo').Text := indata.rd[i].RecBankNo;
    rd.AddChild('RecBankName').Text := indata.rd[i].RecBankName;
    rd.AddChild('CurrType').Text := indata.rd[i].CurrType;
    rd.AddChild('PayAmt').Text := indata.rd[i].PayAmt;
    rd.AddChild('UseCode').Text := indata.rd[i].UseCode;
    rd.AddChild('UseCN').Text := indata.rd[i].UseCN;
    rd.AddChild('EnSummary').Text := indata.rd[i].EnSummary;
    rd.AddChild('PostScript').Text := indata.rd[i].PostScript;
    rd.AddChild('Summary').Text := indata.rd[i].Summary;
    rd.AddChild('Ref').Text := indata.rd[i].Ref;
    rd.AddChild('Oref').Text := indata.rd[i].Oref;
    rd.AddChild('ERPSqn').Text := indata.rd[i].ERPSqn;
    rd.AddChild('BusCode').Text := indata.rd[i].BusCode;
    rd.AddChild('ERPcheckno').Text := indata.rd[i].ERPcheckno;
    rd.AddChild('CrvouhType').Text := indata.rd[i].CrvouhType;
    rd.AddChild('CrvouhName').Text := indata.rd[i].CrvouhName;
    rd.AddChild('CrvouhNo').Text := indata.rd[i].CrvouhNo;

    rd.AddChild('ReqReserved3').Text := indata.rd[i]._Reserved3;
    rd.AddChild('ReqReserved4').Text := indata.rd[i]._Reserved4;
  end;
end;

procedure TICBCRequestAPI.setPub(const pub: TPubRec);
begin
  _pub.ChildNodes.Clear;
  _pub.AddChild('TransCode').Text := pub.TransCode;
  _pub.AddChild('CIS').Text := pub.CIS;
  _pub.AddChild('BankCode').Text := pub.BankCode;
  _pub.AddChild('ID').Text := pub.ID;
  _pub.AddChild('TranDate').Text := pub.TranDate;
  _pub.AddChild('TranTime').Text := pub.TranTime;
  _pub.AddChild('fSeqno').Text := pub.fSeqno;
end;

procedure TICBCRequestAPI.setQueryNetNodeRec(const indata: TQueryNetNodeRec);
begin
  _in.ChildNodes.Clear;
  _in.AddChild('NextTag').Text := indata.NextTag;
  _in.AddChild('ReqReserved1').Text := indata._Reserved1;
  _in.AddChild('ReqReserved2').Text := indata._Reserved2;
end;

procedure TICBCRequestAPI.setQueryHistoryDetailsRec(const indata: TQueryHistoryDetailsRec);
begin
  _in.ChildNodes.Clear;
  _in.AddChild('AccNo').Text := indata.AccNo;
  _in.AddChild('BeginDate').Text := indata.BeginDate;
  _in.AddChild('EndDate').Text := indata.EndDate;
  _in.AddChild('MinAmt').Text := indata.MinAmt;
  _in.AddChild('MaxAmt').Text := indata.MaxAmt;
  _in.AddChild('NextTag').Text := indata.NextTag;
  _in.AddChild('ReqReserved1').Text := indata._Reserved1;
  _in.AddChild('ReqReserved2').Text := indata._Reserved2;
end;

procedure TICBCRequestAPI.setQueryAccValue(const indata: TQueryAccValueRec);
var
  rd: IXMLNode;
  I: Integer;
begin
  _in.ChildNodes.Clear;
  _in.AddChild('TotalNum').Text := indata.TotalNum;
  _in.AddChild('ReqReserved1').Text := indata._Reserved1;
  _in.AddChild('ReqReserved2').Text := indata._Reserved2;
  for I := Low(indata.rd) to High(indata.rd) do
  begin
    rd := _in.AddChild('rd');
    rd.AddChild('iSeqno').Text := indata.rd[i].iSeqno;
    rd.AddChild('AccNo').Text := indata.rd[i].AccNo;
    rd.AddChild('CurrType').Text := indata.rd[i].CurrType;
    rd.AddChild('ReqReserved3').Text := indata.rd[i]._Reserved3;
    rd.AddChild('ReqReserved4').Text := indata.rd[i]._Reserved4;
  end;
end;

procedure TICBCRequestAPI.setQueryCurDayDetailsRec(
  const indata: TQueryCurDayDetailsRec);
begin
  _in.ChildNodes.Clear;
  _in.AddChild('AccNo').Text := indata.AccNo;
  _in.AddChild('AreaCode').Text := indata.AreaCode;
  _in.AddChild('MinAmt').Text := indata.MinAmt;
  _in.AddChild('MaxAmt').Text := indata.MaxAmt;
  _in.AddChild('BeginTime').Text := indata.BeginTime;
  _in.AddChild('EndTime').Text := indata.EndTime;
  _in.AddChild('NextTag').Text := indata.NextTag;
  _in.AddChild('ReqReserved1').Text := indata._Reserved1;
  _in.AddChild('ReqReserved2').Text := indata._Reserved2;
end;


procedure TICBCRequestAPI.setPerDisRec(const indata: TPerDisRec);
var
  rd: IXMLNode;
  I: Integer;
begin
  _in.ChildNodes.Clear;
  _in.AddChild('OnlBatF').Text := indata.OnlBatF;
  _in.AddChild('SettleMode').Text := indata.SettleMode;
  _in.AddChild('RecAccNo').Text := indata.RecAccNo;
  _in.AddChild('RecAccNameCN').Text := indata.RecAccNameCN;
  _in.AddChild('RecAccNameEN').Text := indata.RecAccNameEN;
  _in.AddChild('TotalNum').Text := indata.TotalNum;
  _in.AddChild('TotalAmt').Text := indata.TotalAmt;
  _in.AddChild('SignTime').Text := indata.SignTime;
  _in.AddChild('ReqReserved1').Text := indata._Reserved1;
  _in.AddChild('ReqReserved2').Text := indata._Reserved2;
  for I := Low(indata.rd) to High(indata.rd) do
  begin
    rd := _in.AddChild('rd');
    rd.AddChild('iSeqno').Text := indata.rd[i].iSeqno;
    rd.AddChild('PayAccNo').Text := indata.rd[i].PayAccNo;
    rd.AddChild('PayAccNameCN').Text := indata.rd[i].PayAccNameCN;
    rd.AddChild('PayAccNameEN').Text := indata.rd[i].PayAccNameEN;
    rd.AddChild('PayBranch').Text := indata.rd[i].PayBranch;
    rd.AddChild('Portno').Text := indata.rd[i].Portno;
    rd.AddChild('ContractNo').Text := indata.rd[i].ContractNo;
    rd.AddChild('CurrType').Text := indata.rd[i].CurrType;
    rd.AddChild('PayAmt').Text := indata.rd[i].PayAmt;
    rd.AddChild('UseCode').Text := indata.rd[i].UseCode;
    rd.AddChild('UseCN').Text := indata.rd[i].UseCN;
    rd.AddChild('EnSummary').Text := indata.rd[i].EnSummary;
    rd.AddChild('PostScript').Text := indata.rd[i].PostScript;
    rd.AddChild('Summary').Text := indata.rd[i].Summary;
    rd.AddChild('Ref').Text := indata.rd[i].Ref;
    rd.AddChild('Oref').Text := indata.rd[i].Oref;
    rd.AddChild('ERPSqn').Text := indata.rd[i].ERPSqn;
    rd.AddChild('BusCode').Text := indata.rd[i].BusCode;
    rd.AddChild('ERPcheckno').Text := indata.rd[i].ERPcheckno;
    rd.AddChild('CrvouhType').Text := indata.rd[i].CrvouhType;
    rd.AddChild('CrvouhName').Text := indata.rd[i].CrvouhName;
    rd.AddChild('CrvouhNo').Text := indata.rd[i].CrvouhNo;

    rd.AddChild('ReqReserved3').Text := indata.rd[i]._Reserved3;
    rd.AddChild('ReqReserved4').Text := indata.rd[i]._Reserved4;
  end;
end;

procedure TICBCRequestAPI.setQueryPayEntRec(const indata: TQueryPayEntRec);
var
  rd: IXMLNode;
  I: Integer;
begin
  _in.ChildNodes.Clear;
  _in.AddChild('QryfSeqno').Text := indata.QryfSeqno;
  _in.AddChild('QrySerialNo').Text := indata.QrySerialNo;
  _in.AddChild('ReqReserved1').Text := indata._Reserved1;
  _in.AddChild('ReqReserved2').Text := indata._Reserved2;
  for I := Low(indata.rd) to High(indata.rd) do
  begin
    rd := _in.AddChild('rd');
    rd.AddChild('iSeqno').Text := indata.rd[i].iSeqno;
    rd.AddChild('QryiSeqno').Text := indata.rd[i].QryiSeqno;
    rd.AddChild('QryOrderNo').Text := indata.rd[i].QryOrderNo;

    rd.AddChild('ReqReserved3').Text := indata.rd[i]._Reserved3;
    rd.AddChild('ReqReserved4').Text := indata.rd[i]._Reserved4;
  end;
end;


procedure TICBCRequestAPI.setQueryPerDisRec(const indata: TQueryPerDisRec);
var
  rd: IXMLNode;
  I: Integer;
begin
  _in.ChildNodes.Clear;
  _in.AddChild('QryfSeqno').Text := indata.QryfSeqno;
  _in.AddChild('QrySerialNo').Text := indata.QrySerialNo;
  _in.AddChild('ReqReserved1').Text := indata._Reserved1;
  _in.AddChild('ReqReserved2').Text := indata._Reserved2;
  for I := Low(indata.rd) to High(indata.rd) do
  begin
    rd := _in.AddChild('rd');
    rd.AddChild('iSeqno').Text := indata.rd[i].iSeqno;
    rd.AddChild('QryiSeqno').Text := indata.rd[i].QryiSeqno;
    rd.AddChild('QryOrderNo').Text := indata.rd[i].QryOrderNo;
    rd.AddChild('ReqReserved3').Text := indata.rd[i]._Reserved3;
    rd.AddChild('ReqReserved4').Text := indata.rd[i]._Reserved4;
  end;
end;


{ TICBCResponseAPI }

procedure TICBCResponseAPI.ParserXML;
begin
  inherited;
  FillChar(FPubRec, SizeOf(TPubRec), 0);
  //FCMS := SelectSingleNode('/CMS');
  //Feb := SelectSingleNode('/CMS/eb');
  _pub := SelectSingleNode('/CMS/eb/pub');
  _out := SelectSingleNode('/CMS/eb/out');
  if Assigned(_pub) then
  begin
    StrPCopy(FPubRec.TransCode, GetSingleNodeValue(_pub, 'TransCode'));
    FPubRec.CIS := GetSingleNodeValue(_pub, 'CIS');
    FPubRec.BankCode := GetSingleNodeValue(_pub, 'BankCode');
    FPubRec.ID := GetSingleNodeValue(_pub, 'ID');
    FPubRec.TranDate := GetSingleNodeValue(_pub, 'TranDate');
    FPubRec.TranTime := GetSingleNodeValue(_pub, 'TranTime');
    //支付指令、批扣个人返回专用...........................
    FPubRec.fSeqno := GetSingleNodeValue(_pub, 'fSeqno');
    FPubRec.RetCode := GetSingleNodeValue(_pub, 'RetCode');
    FPubRec.RetMsg := GetSingleNodeValue(_pub, 'RetMsg');
  end;
end;

function TICBCResponseAPI.getQueryNetNodeRec(): TQueryNetNodeRec;
var
  I: integer;
  RDC: IXMLDOMNode;
  RDList: IXMLDOMNodeList;
begin
  FillChar(Result, SizeOf(TQueryNetNodeRec), 0);
  if not Assigned(_out) then Exit;
  Result.NextTag := GetSingleNodeValue(_out, 'NextTag');
  Result._Reserved1 := GetSingleNodeValue(_out, 'RepReserved1');
  Result._Reserved2 := GetSingleNodeValue(_out, 'RepReserved2');
  //RD
  RDList := SelectNodes(_out, 'rd');
  SetLength(Result.rd, RDList.length);
  for I := 0 to RDList.length - 1 do
  begin
    RDC := RDList.item[I];
    Result.rd[I].AreaCode := GetSingleNodeValue(RDC, 'AreaCode');
    Result.rd[I].NetName := GetSingleNodeValue(RDC, 'NetName');
    Result.rd[I]._Reserved3 := GetSingleNodeValue(RDC, 'RepReserved3');
    Result.rd[I]._Reserved4 := GetSingleNodeValue(RDC, 'RepReserved4');
  end;
end;

function TICBCResponseAPI.getQueryAccValue(): TQueryAccValueRec;
var
  I: integer;
  RDC: IXMLDOMNode;
  RDList: IXMLDOMNodeList;
begin
  FillChar(Result, SizeOf(TQueryAccValueRec), 0);
  if not Assigned(_out) then Exit;
  Result.TotalNum := GetSingleNodeValue(_out, 'TotalNum');
  Result._Reserved1 := GetSingleNodeValue(_out, 'RepReserved1');
  Result._Reserved2 := GetSingleNodeValue(_out, 'RepReserved2');
  //RD
  RDList := SelectNodes(_out, 'rd');
  SetLength(Result.rd, RDList.length);
  for I := 0 to RDList.length - 1 do
  begin
    RDC := RDList.item[I];
    Result.rd[I].iSeqno := GetSingleNodeValue(RDC, 'iSeqno');
    Result.rd[I].AccNo := GetSingleNodeValue(RDC, 'AccNo');
    Result.rd[I].CurrType := GetSingleNodeValue(RDC, 'CurrType');

    Result.rd[I].CashExf := GetSingleNodeValue(RDC, 'CashExf');
    Result.rd[I].AcctProperty := GetSingleNodeValue(RDC, 'AcctProperty');
    Result.rd[I].AccBalance := GetSingleNodeValue(RDC, 'AccBalance');
    Result.rd[I].Balance := GetSingleNodeValue(RDC, 'Balance');
    Result.rd[I].UsableBalance := GetSingleNodeValue(RDC, 'UsableBalance');
    Result.rd[I].FrzAmt := GetSingleNodeValue(RDC, 'FrzAmt');
    Result.rd[I].QueryTime := GetSingleNodeValue(RDC, 'QueryTime');
    Result.rd[I].iRetCode := GetSingleNodeValue(RDC, 'iRetCode');
    Result.rd[I].iRetMsg := GetSingleNodeValue(RDC, 'iRetMsg');

    Result.rd[I]._Reserved3 := GetSingleNodeValue(RDC, 'RepReserved3');
    Result.rd[I]._Reserved4 := GetSingleNodeValue(RDC, 'RepReserved4');
  end;
end;


function TICBCResponseAPI.getQueryHistoryDetails(): TQueryHistoryDetailsRec;
var
  I: integer;
  RDC: IXMLDOMNode;
  RDList: IXMLDOMNodeList;
begin
  FillChar(Result, SizeOf(TQueryHistoryDetailsRec), 0);
  if not Assigned(_out) then Exit;
  Result.AccNo := GetSingleNodeValue(_out, 'AccNo');

  Result.AccName := GetSingleNodeValue(_out, 'AccName');
  Result.CurrType := GetSingleNodeValue(_out, 'CurrType');

  Result.BeginDate := GetSingleNodeValue(_out, 'BeginDate');
  Result.EndDate := GetSingleNodeValue(_out, 'EndDate');
  Result.MinAmt := GetSingleNodeValue(_out, 'MinAmt');
  Result.MaxAmt := GetSingleNodeValue(_out, 'MaxAmt');
  Result.NextTag := GetSingleNodeValue(_out, 'NextTag');

  Result.TotalNum := GetSingleNodeValue(_out, 'TotalNum');

  Result._Reserved1 := GetSingleNodeValue(_out, 'RepReserved1');
  Result._Reserved2 := GetSingleNodeValue(_out, 'RepReserved2');
  //RD
  RDList := SelectNodes(_out, 'rd');
  SetLength(Result.rd, RDList.length);
  for I := 0 to RDList.length - 1 do
  begin
    RDC := RDList.item[I];
    Result.rd[I].Drcrf := GetSingleNodeValue(RDC, 'Drcrf');
    Result.rd[I].VouhNo := GetSingleNodeValue(RDC, 'VouhNo');
    Result.rd[I].DebitAmount := GetSingleNodeValue(RDC, 'DebitAmount');
    Result.rd[I].CreditAmount := GetSingleNodeValue(RDC, 'CreditAmount');
    Result.rd[I].Balance := GetSingleNodeValue(RDC, 'Balance');
    Result.rd[I].RecipBkNo := GetSingleNodeValue(RDC, 'RecipBkNo');
    Result.rd[I].RecipBkName := GetSingleNodeValue(RDC, 'RecipBkName');
    Result.rd[I].RecipAccNo := GetSingleNodeValue(RDC, 'RecipAccNo');
    Result.rd[I].RecipName := GetSingleNodeValue(RDC, 'RecipName');
    Result.rd[I].Summary := GetSingleNodeValue(RDC, 'Summary');
    Result.rd[I].UseCN := GetSingleNodeValue(RDC, 'UseCN');

    Result.rd[I].PostScript := GetSingleNodeValue(RDC, 'PostScript');
    Result.rd[I].BusCode := GetSingleNodeValue(RDC, 'BusCode');
    Result.rd[I].Date := GetSingleNodeValue(RDC, 'Date');
    Result.rd[I].Time := GetSingleNodeValue(RDC, 'Time');
    Result.rd[I].Ref := GetSingleNodeValue(RDC, 'Ref');
    Result.rd[I].Oref := GetSingleNodeValue(RDC, 'Oref');
    Result.rd[I].EnSummary := GetSingleNodeValue(RDC, 'EnSummary');
    Result.rd[I].BusType := GetSingleNodeValue(RDC, 'BusType');
    Result.rd[I].VouhType := GetSingleNodeValue(RDC, 'VouhType');
    Result.rd[I].AddInfo := GetSingleNodeValue(RDC, 'AddInfo');
    Result.rd[I]._Reserved3 := GetSingleNodeValue(RDC, 'RepReserved3');
    Result.rd[I]._Reserved4 := GetSingleNodeValue(RDC, 'RepReserved4');
  end;
end;


function TICBCResponseAPI.getQueryCurDayDetails(): TQueryCurDayDetailsRec;
var
  I: integer;
  RDC: IXMLDOMNode;
  RDList: IXMLDOMNodeList;
begin
  FillChar(Result, SizeOf(TQueryCurDayDetailsRec), 0);
  if not Assigned(_out) then Exit;
  Result.AccNo := GetSingleNodeValue(_out, 'AccNo');

  Result.AccName := GetSingleNodeValue(_out, 'AccName');
  Result.CurrType := GetSingleNodeValue(_out, 'CurrType');

  Result.AreaCode := GetSingleNodeValue(_out, 'AreaCode');
  Result.MinAmt := GetSingleNodeValue(_out, 'MinAmt');
  Result.MaxAmt := GetSingleNodeValue(_out, 'MaxAmt');
  Result.BeginTime := GetSingleNodeValue(_out, 'BeginTime');
  Result.EndTime := GetSingleNodeValue(_out, 'EndTime');
  Result.NextTag := GetSingleNodeValue(_out, 'NextTag');

  Result.TotalNum := GetSingleNodeValue(_out, 'TotalNum');

  Result._Reserved1 := GetSingleNodeValue(_out, 'RepReserved1');
  Result._Reserved2 := GetSingleNodeValue(_out, 'RepReserved2');
  //RD
  RDList := SelectNodes(_out, 'rd');
  SetLength(Result.rd, RDList.length);
  for I := 0 to RDList.length - 1 do
  begin
    RDC := RDList.item[I];
    Result.rd[I].Drcrf := GetSingleNodeValue(RDC, 'Drcrf');
    Result.rd[I].VouhNo := GetSingleNodeValue(RDC, 'VouhNo');
    Result.rd[I].Amount := GetSingleNodeValue(RDC, 'Amount');
    Result.rd[I].RecipBkNo := GetSingleNodeValue(RDC, 'RecipBkNo');
    Result.rd[I].RecipAccNo := GetSingleNodeValue(RDC, 'RecipAccNo');
    Result.rd[I].RecipName := GetSingleNodeValue(RDC, 'RecipName');
    Result.rd[I].Summary := GetSingleNodeValue(RDC, 'Summary');
    Result.rd[I].UseCN := GetSingleNodeValue(RDC, 'UseCN');
    Result.rd[I].PostScript := GetSingleNodeValue(RDC, 'PostScript');
    Result.rd[I].Ref := GetSingleNodeValue(RDC, 'Ref');
    Result.rd[I].BusCode := GetSingleNodeValue(RDC, 'BusCode');
    Result.rd[I].Oref := GetSingleNodeValue(RDC, 'Oref');
    Result.rd[I].EnSummary := GetSingleNodeValue(RDC, 'EnSummary');
    Result.rd[I].BusType := GetSingleNodeValue(RDC, 'BusType');
    Result.rd[I].CvouhType := GetSingleNodeValue(RDC, 'CvouhType');
    Result.rd[I].AddInfo := GetSingleNodeValue(RDC, 'AddInfo');
    Result.rd[I].TimeStamp := GetSingleNodeValue(RDC, 'TimeStamp');
    Result.rd[I]._Reserved3 := GetSingleNodeValue(RDC, 'RepReserved3');
    Result.rd[I]._Reserved4 := GetSingleNodeValue(RDC, 'RepReserved4');
  end;
end;

function TICBCResponseAPI.getPayEnt(): TPayEntRec;
var
  I: integer;
  RDC: IXMLDOMNode;
  RDList: IXMLDOMNodeList;
begin
  FillChar(Result, SizeOf(TPayEntRec), 0);
  if not Assigned(_out) then Exit;
  Result.OnlBatF := GetSingleNodeValue(_out, 'OnlBatF');
  Result.SettleMode := GetSingleNodeValue(_out, 'SettleMode');
  Result.TotalNum := GetSingleNodeValue(_out, 'TotalNum');
  Result.TotalAmt := GetSingleNodeValue(_out, 'TotalAmt');
  Result._Reserved1 := GetSingleNodeValue(_out, 'RepReserved1');
  Result._Reserved2 := GetSingleNodeValue(_out, 'RepReserved2');
  //RD
  RDList := SelectNodes(_out, 'rd');
  SetLength(Result.rd, RDList.length);
  for I := 0 to RDList.length - 1 do
  begin
    RDC := RDList.item[I];
    Result.rd[I].iSeqno := GetSingleNodeValue(RDC, 'iSeqno');
    Result.rd[I].OrderNo := GetSingleNodeValue(RDC, 'OrderNo');
    Result.rd[I].ReimburseNo := GetSingleNodeValue(RDC, 'ReimburseNo');
    Result.rd[I].ReimburseNum := GetSingleNodeValue(RDC, 'ReimburseNum');
    Result.rd[I].StartDate := GetSingleNodeValue(RDC, 'StartDate');
    Result.rd[I].StartTime := GetSingleNodeValue(RDC, 'StartTime');
    Result.rd[I].PayType := GetSingleNodeValue(RDC, 'PayType');
    Result.rd[I].PayAccNo := GetSingleNodeValue(RDC, 'PayAccNo');
    Result.rd[I].PayAccNameCN := GetSingleNodeValue(RDC, 'PayAccNameCN');
    Result.rd[I].PayAccNameEN := GetSingleNodeValue(RDC, 'PayAccNameEN');
    Result.rd[I].RecAccNo := GetSingleNodeValue(RDC, 'RecAccNo');
    Result.rd[I].RecAccNameCN := GetSingleNodeValue(RDC, 'RecAccNameCN');
    Result.rd[I].RecAccNameEN := GetSingleNodeValue(RDC, 'RecAccNameEN');
    Result.rd[I].SysIOFlg := GetSingleNodeValue(RDC, 'SysIOFlg');
    Result.rd[I].IsSameCity := GetSingleNodeValue(RDC, 'IsSameCity');
    Result.rd[I].Prop := GetSingleNodeValue(RDC, 'Prop');
    Result.rd[I].RecICBCCode := GetSingleNodeValue(RDC, 'RecICBCCode');
    Result.rd[I].RecCityName := GetSingleNodeValue(RDC, 'RecCityName');
    Result.rd[I].RecBankNo := GetSingleNodeValue(RDC, 'RecBankNo');
    Result.rd[I].RecBankName := GetSingleNodeValue(RDC, 'RecBankName');
    Result.rd[I].CurrType := GetSingleNodeValue(RDC, 'CurrType');
    Result.rd[I].PayAmt := GetSingleNodeValue(RDC, 'PayAmt');
    Result.rd[I].UseCode := GetSingleNodeValue(RDC, 'UseCode');
    Result.rd[I].UseCN := GetSingleNodeValue(RDC, 'UseCN');
    Result.rd[I].EnSummary := GetSingleNodeValue(RDC, 'EnSummary');
    Result.rd[I].PostScript := GetSingleNodeValue(RDC, 'PostScript');
    Result.rd[I].Summary := GetSingleNodeValue(RDC, 'Summary');
    Result.rd[I].Ref := GetSingleNodeValue(RDC, 'Ref');
    Result.rd[I].Oref := GetSingleNodeValue(RDC, 'Oref');
    Result.rd[I].ERPSqn := GetSingleNodeValue(RDC, 'ERPSqn');
    Result.rd[I].BusCode := GetSingleNodeValue(RDC, 'BusCode');
    Result.rd[I].ERPcheckno := GetSingleNodeValue(RDC, 'ERPcheckno');
    Result.rd[I].CrvouhType := GetSingleNodeValue(RDC, 'CrvouhType');
    Result.rd[I].CrvouhName := GetSingleNodeValue(RDC, 'CrvouhName');
    Result.rd[I].CrvouhNo := GetSingleNodeValue(RDC, 'CrvouhNo');
    Result.rd[I].Result := GetSingleNodeValue(RDC, 'Result');
    Result.rd[I].iRetCode := GetSingleNodeValue(RDC, 'iRetCode');
    Result.rd[I].iRetMsg := GetSingleNodeValue(RDC, 'iRetMsg');
    Result.rd[I]._Reserved3 := GetSingleNodeValue(RDC, 'RepReserved3');
    Result.rd[I]._Reserved4 := GetSingleNodeValue(RDC, 'RepReserved4');
  end;
end;

function TICBCResponseAPI.getPerDis(): TPerDisRec;
var
  I: integer;
  RDC: IXMLDOMNode;
  RDList: IXMLDOMNodeList;
begin
  FillChar(Result, SizeOf(TPerDisRec), 0);
  if not Assigned(_out) then Exit;
  Result.OnlBatF := GetSingleNodeValue(_out, 'OnlBatF');
  Result.SettleMode := GetSingleNodeValue(_out, 'SettleMode');

  Result.RecAccNo := GetSingleNodeValue(_out, 'RecAccNo');
  Result.RecAccNameCN := GetSingleNodeValue(_out, 'RecAccNameCN');
  Result.RecAccNameEN := GetSingleNodeValue(_out, 'RecAccNameEN');
  Result.TotalNum := GetSingleNodeValue(_out, 'TotalNum');
  Result.TotalAmt := GetSingleNodeValue(_out, 'TotalAmt');

  Result._Reserved1 := GetSingleNodeValue(_out, 'RepReserved1');
  Result._Reserved2 := GetSingleNodeValue(_out, 'RepReserved2');
  //RD
  RDList := SelectNodes(_out, 'rd');
  SetLength(Result.rd, RDList.length);
  for I := 0 to RDList.length - 1 do
  begin
    RDC := RDList.item[I];
    Result.rd[I].iSeqno := GetSingleNodeValue(RDC, 'iSeqno');
    Result.rd[I].OrderNo := GetSingleNodeValue(RDC, 'OrderNo');
    Result.rd[I].PayAccNo := GetSingleNodeValue(RDC, 'PayAccNo');
    Result.rd[I].PayAccNameCN := GetSingleNodeValue(RDC, 'PayAccNameCN');
    Result.rd[I].PayAccNameEN := GetSingleNodeValue(RDC, 'PayAccNameEN');
    Result.rd[I].PayBranch := GetSingleNodeValue(RDC, 'PayBranch');
    Result.rd[I].Portno := GetSingleNodeValue(RDC, 'Portno');
    Result.rd[I].ContractNo := GetSingleNodeValue(RDC, 'ContractNo');
    Result.rd[I].CurrType := GetSingleNodeValue(RDC, 'CurrType');
    Result.rd[I].PayAmt := GetSingleNodeValue(RDC, 'PayAmt');
    Result.rd[I].UseCode := GetSingleNodeValue(RDC, 'UseCode');
    Result.rd[I].UseCN := GetSingleNodeValue(RDC, 'UseCN');
    Result.rd[I].EnSummary := GetSingleNodeValue(RDC, 'EnSummary');
    Result.rd[I].PostScript := GetSingleNodeValue(RDC, 'PostScript');
    Result.rd[I].Summary := GetSingleNodeValue(RDC, 'Summary');
    Result.rd[I].Ref := GetSingleNodeValue(RDC, 'Ref');
    Result.rd[I].Oref := GetSingleNodeValue(RDC, 'Oref');
    Result.rd[I].ERPSqn := GetSingleNodeValue(RDC, 'ERPSqn');
    Result.rd[I].BusCode := GetSingleNodeValue(RDC, 'BusCode');
    Result.rd[I].ERPcheckno := GetSingleNodeValue(RDC, 'ERPcheckno');
    Result.rd[I].CrvouhType := GetSingleNodeValue(RDC, 'CrvouhType');
    Result.rd[I].CrvouhName := GetSingleNodeValue(RDC, 'CrvouhName');
    Result.rd[I].CrvouhNo := GetSingleNodeValue(RDC, 'CrvouhNo');
    Result.rd[I].Result := GetSingleNodeValue(RDC, 'Result');
    Result.rd[I].iRetCode := GetSingleNodeValue(RDC, 'iRetCode');
    Result.rd[I].iRetMsg := GetSingleNodeValue(RDC, 'iRetMsg');
    Result.rd[I]._Reserved3 := GetSingleNodeValue(RDC, 'RepReserved3');
    Result.rd[I]._Reserved4 := GetSingleNodeValue(RDC, 'RepReserved4');
  end;
end;


function TICBCResponseAPI.getQueryPayEnt: TQueryPayEntRec;
var
  I: integer;
  RDC: IXMLDOMNode;
  RDList: IXMLDOMNodeList;
begin
  FillChar(Result, SizeOf(TQueryPayEntRec), 0);
  if not Assigned(_out) then Exit;
  Result.QryfSeqno := GetSingleNodeValue(_out, 'QryfSeqno');
  Result.QrySerialNo := GetSingleNodeValue(_out, 'QrySerialNo');
  Result.OnlBatF := GetSingleNodeValue(_out, 'OnlBatF');
  Result.SettleMode := GetSingleNodeValue(_out, 'SettleMode');
  Result.BusType := GetSingleNodeValue(_out, 'BusType');

  Result._Reserved1 := GetSingleNodeValue(_out, 'RepReserved1');
  Result._Reserved2 := GetSingleNodeValue(_out, 'RepReserved2');
  //RD
  RDList := SelectNodes(_out, 'rd');
  SetLength(Result.rd, RDList.length);
  for I := 0 to RDList.length - 1 do
  begin
    RDC := RDList.item[I];
    Result.rd[I].iSeqno := GetSingleNodeValue(RDC, 'iSeqno');
    Result.rd[I].QryiSeqno := GetSingleNodeValue(RDC, 'QryiSeqno');
    Result.rd[I].QryOrderNo := GetSingleNodeValue(RDC, 'QryOrderNo');
    Result.rd[I].ReimburseNo := GetSingleNodeValue(RDC, 'ReimburseNo');
    Result.rd[I].ReimburseNum := GetSingleNodeValue(RDC, 'ReimburseNum');
    Result.rd[I].StartDate := GetSingleNodeValue(RDC, 'StartDate');
    Result.rd[I].StartTime := GetSingleNodeValue(RDC, 'StartTime');
    Result.rd[I].PayType := GetSingleNodeValue(RDC, 'PayType');
    Result.rd[I].PayAccNo := GetSingleNodeValue(RDC, 'PayAccNo');
    Result.rd[I].PayAccNameCN := GetSingleNodeValue(RDC, 'PayAccNameCN');
    Result.rd[I].PayAccNameEN := GetSingleNodeValue(RDC, 'PayAccNameEN');
    Result.rd[I].RecAccNo := GetSingleNodeValue(RDC, 'RecAccNo');
    Result.rd[I].RecAccNameCN := GetSingleNodeValue(RDC, 'RecAccNameCN');
    Result.rd[I].RecAccNameEN := GetSingleNodeValue(RDC, 'RecAccNameEN');
    Result.rd[I].SysIOFlg := GetSingleNodeValue(RDC, 'SysIOFlg');
    Result.rd[I].IsSameCity := GetSingleNodeValue(RDC, 'IsSameCity');
    Result.rd[I].RecICBCCode := GetSingleNodeValue(RDC, 'RecICBCCode');
    Result.rd[I].RecCityName := GetSingleNodeValue(RDC, 'RecCityName');
    Result.rd[I].RecBankNo := GetSingleNodeValue(RDC, 'RecBankNo');
    Result.rd[I].RecBankName := GetSingleNodeValue(RDC, 'RecBankName');
    Result.rd[I].CurrType := GetSingleNodeValue(RDC, 'CurrType');
    Result.rd[I].PayAmt := GetSingleNodeValue(RDC, 'PayAmt');
    Result.rd[I].UseCode := GetSingleNodeValue(RDC, 'UseCode');
    Result.rd[I].UseCN := GetSingleNodeValue(RDC, 'UseCN');
    Result.rd[I].EnSummary := GetSingleNodeValue(RDC, 'EnSummary');
    Result.rd[I].PostScript := GetSingleNodeValue(RDC, 'PostScript');
    Result.rd[I].Summary := GetSingleNodeValue(RDC, 'Summary');
    Result.rd[I].Ref := GetSingleNodeValue(RDC, 'Ref');
    Result.rd[I].Oref := GetSingleNodeValue(RDC, 'Oref');
    Result.rd[I].ERPSqn := GetSingleNodeValue(RDC, 'ERPSqn');
    Result.rd[I].BusCode := GetSingleNodeValue(RDC, 'BusCode');
    Result.rd[I].ERPcheckno := GetSingleNodeValue(RDC, 'ERPcheckno');
    Result.rd[I].CrvouhType := GetSingleNodeValue(RDC, 'CrvouhType');
    Result.rd[I].CrvouhName := GetSingleNodeValue(RDC, 'CrvouhName');
    Result.rd[I].CrvouhNo := GetSingleNodeValue(RDC, 'CrvouhNo');
    Result.rd[I].iRetCode := GetSingleNodeValue(RDC, 'iRetCode');
    Result.rd[I].iRetMsg := GetSingleNodeValue(RDC, 'iRetMsg');
    Result.rd[I].Result := GetSingleNodeValue(RDC, 'Result');
    Result.rd[I].instrRetCode := GetSingleNodeValue(RDC, 'instrRetCode');
    Result.rd[I].instrRetMsg := GetSingleNodeValue(RDC, 'instrRetMsg');
    Result.rd[I].BankRetTime := GetSingleNodeValue(RDC, 'BankRetTime');
    Result.rd[I]._Reserved3 := GetSingleNodeValue(RDC, 'RepReserved3');
    Result.rd[I]._Reserved4 := GetSingleNodeValue(RDC, 'RepReserved4');
  end;
end;

function TICBCResponseAPI.getQueryPerDis: TQueryPerDisRec;
var
  I: integer;
  RDC: IXMLDOMNode;
  RDList: IXMLDOMNodeList;
begin
  FillChar(Result, SizeOf(TPerDisRec), 0);
  if not Assigned(_out) then Exit;
  Result.QryfSeqno := GetSingleNodeValue(_out, 'QryfSeqno');
  Result.QrySerialNo := GetSingleNodeValue(_out, 'QrySerialNo');
  Result.OnlBatF := GetSingleNodeValue(_out, 'OnlBatF');
  Result.SettleMode := GetSingleNodeValue(_out, 'SettleMode');
  Result.RecAccNo := GetSingleNodeValue(_out, 'RecAccNo');
  Result.RecAccNameCN := GetSingleNodeValue(_out, 'RecAccNameCN');
  Result.RecAccNameEN := GetSingleNodeValue(_out, 'RecAccNameEN');
  Result.RetTotalNum := GetSingleNodeValue(_out, 'RetTotalNum');
  Result.RetTotalAmt := GetSingleNodeValue(_out, 'RetTotalAmt');
  Result.CurrType := GetSingleNodeValue(_out, 'CurrType');
  Result.BusType := GetSingleNodeValue(_out, 'BusType');
  Result._Reserved1 := GetSingleNodeValue(_out, 'RepReserved1');
  Result._Reserved2 := GetSingleNodeValue(_out, 'RepReserved2');
  //RD
  RDList := SelectNodes(_out, 'rd');
  SetLength(Result.rd, RDList.length);
  for I := 0 to RDList.length - 1 do
  begin
    RDC := RDList.item[I];
    Result.rd[I].iSeqno := GetSingleNodeValue(RDC, 'iSeqno');
    Result.rd[I].QryiSeqno := GetSingleNodeValue(RDC, 'QryiSeqno');
    Result.rd[I].QryOrderNo := GetSingleNodeValue(RDC, 'QryOrderNo');
    Result.rd[I].Portno := GetSingleNodeValue(RDC, 'Portno');
    Result.rd[I].OpType := GetSingleNodeValue(RDC, 'OpType');
    Result.rd[I].ContractNo := GetSingleNodeValue(RDC, 'ContractNo');
    Result.rd[I].PayAccNo := GetSingleNodeValue(RDC, 'PayAccNo');
    Result.rd[I].PayAccNameCN := GetSingleNodeValue(RDC, 'PayAccNameCN');
    Result.rd[I].PayAccNameEN := GetSingleNodeValue(RDC, 'PayAccNameEN');
    Result.rd[I].PayBranch := GetSingleNodeValue(RDC, 'PayBranch');
    //Result.rd[I].CurrType := GetSingleNodeValue(RDC, 'CurrType');
    Result.rd[I].PayAmt := GetSingleNodeValue(RDC, 'PayAmt');
    Result.rd[I].UseCode := GetSingleNodeValue(RDC, 'UseCode');
    Result.rd[I].UseCN := GetSingleNodeValue(RDC, 'UseCN');
    Result.rd[I].UserRem := GetSingleNodeValue(RDC, 'UserRem');
    Result.rd[I].PostScript := GetSingleNodeValue(RDC, 'PostScript');
    Result.rd[I].Summary := GetSingleNodeValue(RDC, 'Summary');
    Result.rd[I].Ref := GetSingleNodeValue(RDC, 'Ref');
    Result.rd[I].Oref := GetSingleNodeValue(RDC, 'Oref');
    Result.rd[I].ERPSqn := GetSingleNodeValue(RDC, 'ERPSqn');
    Result.rd[I].BusCode := GetSingleNodeValue(RDC, 'BusCode');
    Result.rd[I].ERPcheckno := GetSingleNodeValue(RDC, 'ERPcheckno');
    Result.rd[I].CrvouhType := GetSingleNodeValue(RDC, 'CrvouhType');
    Result.rd[I].CrvouhName := GetSingleNodeValue(RDC, 'CrvouhName');
    Result.rd[I].CrvouhNo := GetSingleNodeValue(RDC, 'CrvouhNo');
    Result.rd[I].Result := GetSingleNodeValue(RDC, 'Result');
    Result.rd[I].BankRem := GetSingleNodeValue(RDC, 'BankRem');
    Result.rd[I].BankRetime := GetSingleNodeValue(RDC, 'BankRetime');
    Result.rd[I].iRetCode := GetSingleNodeValue(RDC, 'iRetCode');
    Result.rd[I].iRetMsg := GetSingleNodeValue(RDC, 'iRetMsg');
    Result.rd[I]._Reserved3 := GetSingleNodeValue(RDC, 'RepReserved3');
    Result.rd[I]._Reserved4 := GetSingleNodeValue(RDC, 'RepReserved4');
  end;
end;


end.

