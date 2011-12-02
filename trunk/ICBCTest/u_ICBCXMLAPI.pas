(*
    ICBC指令解析
    原始作者：王云涛
    建立时间：2011-12-02
*)
unit u_ICBCXMLAPI;

interface

uses

  SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, msxml, Variants, BASEXMLAPI,u_ICBCRec;

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
    rd.AddChild('ReqReserved3').Text := indata.rd[i].ReqReserved3;
    rd.AddChild('ReqReserved4').Text := indata.rd[i].ReqReserved4;
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
    FPubRec.TransCode := GetSingleNodeValue(_pub.DOMNode, 'TransCode');
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
      Result.rd[I].RepReserved3 := GetSingleNodeValue(RDC, 'RepReserved3');
      Result.rd[I].RepReserved3 := GetSingleNodeValue(RDC, 'RepReserved4');
    end;
  finally
    RDList.Free;
  end;
end;

end.

