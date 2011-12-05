(*
    ICBC指令解析
    原始作者：王云涛
    建立时间：2011-12-02
*)
unit u_ICBCXMLAPI;

interface

uses

  SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, msxml, Variants, BASEXMLAPI, u_ICBCRec;

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
    procedure setQueryHistoryDetails(const indata: TQueryHistoryDetailsRec);
    //多账户余额查询
    procedure setQueryAccValue(const indata: TQueryAccValueRec);
    //查询网点信息
    procedure setQueryNetNodeRec(const indata: TQueryNetNodeRec);
    //支付指令提交
    procedure setPayEntRec(const indata: TPayEntRec);
  end;

  TICBCResponseAPI = class(TBASEXMLAPI)
  private
    FCMS, Feb: IXMLNode;
    _out, _pub: IXMLNode;
    FPubRec: TPubRec;
  protected
    procedure ParserXML(); override;
  public
    function getQueryNetNodeRec: TQueryNetNodeRec;
    function getQueryAccValue: TQueryAccValueRec;
    function getQueryHistoryDetails: TQueryHistoryDetailsRec;
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
  _in.AddChild('ReqReserved1').Text := indata.ReqReserved1;
  _in.AddChild('ReqReserved2').Text := indata.ReqReserved2;
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
  _in.AddChild('ReqReserved1').Text := indata.ReqReserved1;
  _in.AddChild('ReqReserved2').Text := indata.ReqReserved2;
end;

procedure TICBCRequestAPI.setQueryHistoryDetails(const indata: TQueryHistoryDetailsRec);
begin
  _in.ChildNodes.Clear;
  _in.AddChild('AccNo').Text := indata.AccNo;
  _in.AddChild('BeginDate').Text := indata.BeginDate;
  _in.AddChild('EndDate').Text := indata.EndDate;
  _in.AddChild('MinAmt').Text := indata.MinAmt;
  _in.AddChild('MaxAmt').Text := indata.MaxAmt;
  _in.AddChild('NextTag').Text := indata.NextTag;
  _in.AddChild('ReqReserved1').Text := indata.ReqReserved1;
  _in.AddChild('ReqReserved2').Text := indata.ReqReserved2;
end;

procedure TICBCRequestAPI.setQueryAccValue(const indata: TQueryAccValueRec);
var
  rd: IXMLNode;
  I: Integer;
begin
  _in.ChildNodes.Clear;
  _in.AddChild('TotalNum').Text := indata.TotalNum;
  _in.AddChild('ReqReserved1').Text := indata.ReqReserved1;
  _in.AddChild('ReqReserved2').Text := indata.ReqReserved2;
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

{ TICBCResponseAPI }

procedure TICBCResponseAPI.ParserXML;
begin
  inherited;
  FillChar(FPubRec, SizeOf(TPubRec), 0);
  FCMS := SelectXMLSingleNode('CMS');
  Feb := SelectXMLSingleNode(FCMS, 'eb');
  _pub := SelectXMLSingleNode(Feb, 'pub');
  _out := SelectXMLSingleNode(Feb, 'out');
  if Assigned(_pub) then
  begin
    StrPCopy(FPubRec.TransCode,GetSingleNodeValue(_pub.DOMNode, 'TransCode'));
    FPubRec.CIS := GetSingleNodeValue(_pub.DOMNode, 'CIS');
    FPubRec.BankCode := GetSingleNodeValue(_pub.DOMNode, 'BankCode');
    FPubRec.ID := GetSingleNodeValue(_pub.DOMNode, 'ID');
    FPubRec.TranDate := GetSingleNodeValue(_pub.DOMNode, 'TranDate');
    FPubRec.TranTime := GetSingleNodeValue(_pub.DOMNode, 'TranTime');
    FPubRec.fSeqno := GetSingleNodeValue(_pub.DOMNode, 'fSeqno');
    FPubRec.RetCode := GetSingleNodeValue(_pub.DOMNode, 'RetCode');
    FPubRec.RetMsg := GetSingleNodeValue(_pub.DOMNode, 'RetMsg');
  end;
end;

function TICBCResponseAPI.getQueryNetNodeRec(): TQueryNetNodeRec;
var
  I: integer;
  OutCList: IDOMNodeList;
  RDList: TList;
  RDC: IDOMNode;
begin
  FillChar(Result, SizeOf(TQueryNetNodeRec), 0);
  if not Assigned(_out) then Exit;
  Result.NextTag := GetSingleNodeValue(_out.DOMNode, 'NextTag');
  Result.ReqReserved1 := GetSingleNodeValue(_out.DOMNode, 'ReqReserved1');
  Result.ReqReserved2 := GetSingleNodeValue(_out.DOMNode, 'ReqReserved2');
  //RD
  OutCList := _out.DOMNode.childNodes;
  RDList := TList.Create;
  try
    for I := 0 to OutCList.length - 1 do
    begin
      RDC := OutCList.item[I];
      if RDC.nodeName = 'rd' then
        RDList.Add(Pointer(RDC));
    end;
    SetLength(Result.rd, RDList.Count);
    for I := 0 to RDList.Count - 1 do
    begin
      RDC := IDOMNode(RDList.Items[I]);
      Result.rd[I].AreaCode := GetSingleNodeValue(RDC, 'AreaCode');
      Result.rd[I].NetName := GetSingleNodeValue(RDC, 'NetName');
      Result.rd[I]._Reserved3 := GetSingleNodeValue(RDC, 'RepReserved3');
      Result.rd[I]._Reserved4 := GetSingleNodeValue(RDC, 'RepReserved4');
    end;
  finally
    RDList.Free;
  end;
end;

function TICBCResponseAPI.getQueryAccValue(): TQueryAccValueRec;
var
  I: integer;
  OutCList: IDOMNodeList;
  RDList: TList;
  RDC: IDOMNode;
begin
  FillChar(Result, SizeOf(TQueryAccValueRec), 0);
  if not Assigned(_out) then Exit;
  Result.TotalNum := GetSingleNodeValue(_out.DOMNode, 'TotalNum');
  Result.ReqReserved1 := GetSingleNodeValue(_out.DOMNode, 'ReqReserved1');
  Result.ReqReserved2 := GetSingleNodeValue(_out.DOMNode, 'ReqReserved2');
  //RD
  OutCList := _out.DOMNode.childNodes;
  RDList := TList.Create;
  try
    for I := 0 to OutCList.length - 1 do
    begin
      RDC := OutCList.item[I];
      if RDC.nodeName = 'rd' then
        RDList.Add(Pointer(RDC));
    end;
    SetLength(Result.rd, RDList.Count);
    for I := 0 to RDList.Count - 1 do
    begin
      RDC := IDOMNode(RDList.Items[I]);
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
  finally
    RDList.Free;
  end;
end;

function TICBCResponseAPI.getQueryHistoryDetails(): TQueryHistoryDetailsRec;
var
  I: integer;
  OutCList: IDOMNodeList;
  RDList: TList;
  RDC: IDOMNode;
begin
  FillChar(Result, SizeOf(TQueryHistoryDetailsRec), 0);
  if not Assigned(_out) then Exit;
  Result.AccNo := GetSingleNodeValue(_out.DOMNode, 'AccNo');

  Result.AccName := GetSingleNodeValue(_out.DOMNode, 'AccName');
  Result.CurrType := GetSingleNodeValue(_out.DOMNode, 'CurrType');

  Result.BeginDate := GetSingleNodeValue(_out.DOMNode, 'BeginDate');
  Result.EndDate := GetSingleNodeValue(_out.DOMNode, 'EndDate');
  Result.MinAmt := GetSingleNodeValue(_out.DOMNode, 'MinAmt');
  Result.MaxAmt := GetSingleNodeValue(_out.DOMNode, 'MaxAmt');
  Result.NextTag := GetSingleNodeValue(_out.DOMNode, 'NextTag');

  Result.TotalNum := GetSingleNodeValue(_out.DOMNode, 'TotalNum');

  Result.ReqReserved1 := GetSingleNodeValue(_out.DOMNode, 'ReqReserved1');
  Result.ReqReserved2 := GetSingleNodeValue(_out.DOMNode, 'ReqReserved2');
  //RD
  OutCList := _out.DOMNode.childNodes;
  RDList := TList.Create;
  try
    for I := 0 to OutCList.length - 1 do
    begin
      RDC := OutCList.item[I];
      if RDC.nodeName = 'rd' then
        RDList.Add(Pointer(RDC));
    end;
    SetLength(Result.rd, RDList.Count);
    for I := 0 to RDList.Count - 1 do
    begin
      RDC := IDOMNode(RDList.Items[I]);
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
  finally
    RDList.Free;
  end;
end;
end.

