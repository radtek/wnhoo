(*
    ICBC通讯API
    原始作者：王云涛
    建立时间：2011-12-02
*)
unit u_ICBCAPI;

interface

uses

  SysUtils, Classes, Variants, IdCoderMIME, u_NCAPI, u_ICBCXMLAPI, u_ICBCRec;

type

  TICBCAPI = class(TComponent)
  private
    FdeBase64: TIdDecoderMIME;
    FICBCRsq: TICBCRequestAPI;
    FICBCRspon: TICBCResponseAPI;

    FCIS, FBankCode, FID: string;
    function getPubRec(const TransCode, fSeqno: string): TPubRec;
    function NCSvrRequest(const pub: TPubRec; const reqDataStr: string;
      const IsSign: Boolean; out rtDataBase64Str: string): Boolean;
  public
    function QueryAccValue(const fSeqno: string; var qav: TQueryAccValueRec;
      var rtDataStr: string): Boolean;
    function QueryHistoryDetails(const fSeqno: string;
      var qhd: TQueryHistoryDetailsRec; var rtDataStr: string): Boolean;
    function PayEnt(const fSeqno: string; var pe: TPayEntRec;
      var rtDataStr: string): Boolean;

      
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property CIS: string read FCIS write FCIS;
    property BankCode: string read FBankCode write FBankCode;
    property ID: string read FID write FID;
  end;

implementation

function TICBCAPI.NCSvrRequest(const pub: TPubRec; const reqDataStr: string; const IsSign: Boolean;
  out rtDataBase64Str: string): Boolean;
var
  FNC: TNCSvr;
  FSign: TSign;
  reqData: string;
  rtxmlStr: string;
begin
  Result := False;
  reqData:='';
  rtxmlStr:='';
  FNC := TNCSvr.Create(Self);
  //签名端口
  FNC.SIGN_URL := 'http://192.168.1.189:449';
  //安全http协议服务器
  FNC.HTTPS_URL := 'http://192.168.1.189:448';
  FSign := TSign.create(Self);
  try
    //签名
    if IsSign then
    begin
      if not FNC.Sign(reqDataStr, rtxmlStr) then Exit;
      if not FSign.SetXML(rtxmlStr) then Exit;
      if FSign.SignRec.RtCode <> '0' then
      begin
        raise Exception.Create(FSign.SignRec.RtStr);
        Exit;
      end;
      //Sign 后字符
      reqData := FSign.SignRec.DataStr;
    end
    else
    begin
      //GP BASE64编码 ,直接明文
      reqData := reqDataStr;
    end;
    Result := FNC.Request(Pub, reqData, rtDataBase64Str);
  finally
    FSign.Free;
    FNC.Free;
  end;
end;


{ TICBCAPI }

constructor TICBCAPI.Create(AOwner: TComponent);
begin
  inherited;
  FdeBase64 := TIdDecoderMIME.Create(self);
  FICBCRsq := TICBCRequestAPI.Create(Self);
  FICBCRspon := TICBCResponseAPI.Create(self);
end;

destructor TICBCAPI.Destroy;
begin
  FICBCRspon.Free;
  FICBCRsq.Free;
  FdeBase64.Free;
  inherited;
end;

function TICBCAPI.getPubRec(const TransCode, fSeqno: string): TPubRec;
begin
  FillChar(Result, SizeOf(TPubRec), 0);
  StrPCopy(Result.TransCode,TransCode);
  Result.CIS := FCIS;
  Result.BankCode := FBankCode;
  Result.ID := FID;
  Result.TranDate := FormatDateTime('YYYYMMDD', Now);
  //去掉微秒
  Result.TranTime := FormatDateTime('hhnnsszzz', Now);
  Result.fSeqno := fSeqno;
end;

function TICBCAPI.QueryAccValue(const fSeqno: string; var qav: TQueryAccValueRec;
  var rtDataStr: string): Boolean;
var
  rtDataBase64Str: string;
  pub: TPubRec;
begin
  Result := False;
  rtDataStr := '';
  rtDataBase64Str := '';
  //请求XML部分
  pub := getPubRec('QACCBAL', fSeqno);
  FICBCRsq.setPub(pub);
  FICBCRsq.setQueryAccValue(qav);
  //GP BASE64编码 ,直接明文
  if not NCSvrRequest(Pub, FICBCRsq.GetXML, False, rtDataBase64Str) then
  begin
    //errorCode
    rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
    Exit;
  end;
  //解码
  rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
  //解析
  FICBCRspon.SetXML(rtDataStr);
  Pub := FICBCRspon.Pub;
  if Pub.RetCode <> '0' then
  begin
    rtDataStr := Pub.RetMsg;
    Exit;
  end;
  //返回结果
  qav := FICBCRspon.getQueryAccValue();
  Result := True;
end;


function TICBCAPI.QueryHistoryDetails(const fSeqno: string; var qhd: TQueryHistoryDetailsRec;
  var rtDataStr: string): Boolean;
var
  rtDataBase64Str: string;
  pub: TPubRec;
begin
  Result := False;
  rtDataStr := '';
  rtDataBase64Str := '';
  //请求XML部分
  pub := getPubRec('QHISD', fSeqno);
  FICBCRsq.setPub(pub);
  FICBCRsq.setQueryHistoryDetails(qhd);
  //GP BASE64编码 ,直接明文
  if not NCSvrRequest(Pub, FICBCRsq.GetXML, False, rtDataBase64Str) then
  begin
    //errorCode
    rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
    Exit;
  end;
  //解码
  rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
  //解析
  FICBCRspon.SetXML(rtDataStr);
  Pub := FICBCRspon.Pub;
  if Pub.RetCode <> '0' then
  begin
    rtDataStr := Pub.RetMsg;
    Exit;
  end;
  //返回结果
  qhd := FICBCRspon.getQueryHistoryDetails();
  Result := True;
end;


function TICBCAPI.PayEnt(const fSeqno: string; var pe: TPayEntRec;
  var rtDataStr: string): Boolean;
var
  rtDataBase64Str: string;
  pub: TPubRec;
begin
  Result := False;
  rtDataStr := '';
  rtDataBase64Str := '';
  //请求XML部分
  pub := getPubRec('PAYENT', fSeqno);
  FICBCRsq.setPub(pub);
  FICBCRsq.setPayEntRec(pe);
  //GP BASE64编码 ,直接明文
  if not NCSvrRequest(Pub, FICBCRsq.GetXML, True, rtDataBase64Str) then
  begin
    //errorCode
    rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
    Exit;
  end;
  //解码
  rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
  //解析
  FICBCRspon.SetXML(rtDataStr);
  Pub := FICBCRspon.Pub;
  if Pub.RetCode <> '0' then
  begin
    rtDataStr := Pub.RetMsg;
    Exit;
  end;
  //返回结果
  //qhd := FICBCRspon.getQueryHistoryDetails();
  Result := True;
end;

end.

