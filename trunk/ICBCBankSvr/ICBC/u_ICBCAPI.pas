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
    FSIGN_URL, FHTTPS_URL: string;
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
    function PerDis(const fSeqno: string; var pd: TPerDisRec;
      var rtDataStr: string): Boolean;
    function QueryCurDayDetails(const fSeqno: string;
      var qcd: TQueryCurDayDetailsRec; var rtDataStr: string): Boolean;
    function QueryPerDis(const fSeqno: string; var qpd: TQueryPerDisRec;
      var rtDataStr: string): Boolean;
    function QueryPayEnt(const fSeqno: string; var qpe: TQueryPayEntRec;
      var rtDataStr: string): Boolean;
    function QueryPerInf(const fSeqno: string; var qpi: TQueryPerInf;
      var rtDataStr: string): Boolean;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property CIS: string read FCIS write FCIS;
    property BankCode: string read FBankCode write FBankCode;
    property ID: string read FID write FID;
    //签名端口
    property SIGN_URL: string read FSIGN_URL write FSIGN_URL;
    //安全http协议服务器
    property HTTPS_URL: string read FHTTPS_URL write FHTTPS_URL;
  end;

implementation

procedure WriteLog(const Str, flog: string);
var
  f: TextFile;
begin
  AssignFile(F, flog);
  try
    Rewrite(f);
    Write(f, Str);
  finally
    closeFile(F);
  end;
end;

function TICBCAPI.NCSvrRequest(const pub: TPubRec; const reqDataStr: string; const IsSign: Boolean;
  out rtDataBase64Str: string): Boolean;
var
  FNC: TNCSvr;
  FSign: TSign;
  reqData: string;
  rtxmlStr: string;
begin
  Result := False;
  reqData := '';
  rtxmlStr := '';
  FNC := TNCSvr.Create(Self);
  //签名端口
  FNC.SIGN_URL := FSIGN_URL;
  //安全http协议服务器
  FNC.HTTPS_URL := FHTTPS_URL;
  FSign := TSign.create(Self);
  try
    //签名
    if IsSign then
    begin
      if not FNC.Sign(reqDataStr, rtxmlStr) then Exit;
      if not FSign.SetXML(rtxmlStr) then Exit;
      if FSign.SignRec.RtCode <> '0' then
      begin
        raise Exception.Create('签名异常，' + FSign.SignRec.RtStr);
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
  StrPCopy(Result.TransCode, TransCode);
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
  WriteLog(FICBCRsq.GetXML, 'c:\查询卡余S.xml');
  WriteLog(rtDataStr, 'c:\查询卡余R.xml');
  //解析
  FICBCRspon.SetXML(rtDataStr);
  Pub := FICBCRspon.Pub;
  if Pub.RetCode <> '0' then
  begin
    rtDataStr := '[' + Pub.RetCode + ']' + Pub.RetMsg;
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
  FICBCRsq.setQueryHistoryDetailsRec(qhd);
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
    rtDataStr := '[' + Pub.RetCode + ']' + Pub.RetMsg;
    Exit;
  end;
  //返回结果
  qhd := FICBCRspon.getQueryHistoryDetails();
  Result := True;
end;


function TICBCAPI.QueryCurDayDetails(const fSeqno: string; var qcd: TQueryCurDayDetailsRec;
  var rtDataStr: string): Boolean;
var
  rtDataBase64Str: string;
  pub: TPubRec;
begin
  Result := False;
  rtDataStr := '';
  rtDataBase64Str := '';
  //请求XML部分
  pub := getPubRec('QPD', fSeqno);
  FICBCRsq.setPub(pub);
  FICBCRsq.setQueryCurDayDetailsRec(qcd);
  //GP BASE64编码 ,直接明文
  if not NCSvrRequest(Pub, FICBCRsq.GetXML, False, rtDataBase64Str) then
  begin
    //errorCode
    rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
    Exit;
  end;
  //解码
  rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
  WriteLog(FICBCRsq.GetXML, 'c:\当日明细S.xml');
  WriteLog(rtDataStr, 'c:\当日明细R.xml');
  //解析
  FICBCRspon.SetXML(rtDataStr);
  Pub := FICBCRspon.Pub;
  if Pub.RetCode <> '0' then
  begin
    rtDataStr := '[' + Pub.RetCode + ']' + Pub.RetMsg;
    Exit;
  end;
  //返回结果
  qcd := FICBCRspon.getQueryCurDayDetails();
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
  WriteLog(FICBCRsq.GetXML, 'c:\支付指令S.xml');
  WriteLog(rtDataStr, 'c:\支付指令R.xml');
  //解析
  FICBCRspon.SetXML(rtDataStr);
  Pub := FICBCRspon.Pub;
  if Pub.RetCode <> '0' then
  begin
    rtDataStr := '[' + Pub.RetCode + ']' + Pub.RetMsg;
    Exit;
  end;
  //返回结果
  pe := FICBCRspon.getPayEnt();
  Result := True;
end;

function TICBCAPI.PerDis(const fSeqno: string; var pd: TPerDisRec;
  var rtDataStr: string): Boolean;
var
  rtDataBase64Str: string;
  pub: TPubRec;
begin
  Result := False;
  rtDataStr := '';
  rtDataBase64Str := '';
  //请求XML部分
  pub := getPubRec('PERDIS', fSeqno);
  FICBCRsq.setPub(pub);
  FICBCRsq.setPerDisRec(pd);
  //GP BASE64编码 ,直接明文
  if not NCSvrRequest(Pub, FICBCRsq.GetXML, True, rtDataBase64Str) then
  begin
    //errorCode
    rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
    Exit;
  end;
  //解码
  rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
  WriteLog(FICBCRsq.GetXML, 'c:\批量扣个人S.xml');
  WriteLog(rtDataStr, 'c:\批量扣个人R.xml');
  //解析
  FICBCRspon.SetXML(rtDataStr);
  Pub := FICBCRspon.Pub;
  if Pub.RetCode <> '0' then
  begin
    rtDataStr := '[' + Pub.RetCode + ']' + Pub.RetMsg;
    Exit;
  end;
  //返回结果
  pd := FICBCRspon.getPerDis();
  Result := True;
end;

function TICBCAPI.QueryPerDis(const fSeqno: string; var qpd: TQueryPerDisRec;
  var rtDataStr: string): Boolean;
var
  rtDataBase64Str: string;
  pub: TPubRec;
begin
  Result := False;
  rtDataStr := '';
  rtDataBase64Str := '';
  //请求XML部分
  pub := getPubRec('QPERDIS', fSeqno);
  FICBCRsq.setPub(pub);
  FICBCRsq.setQueryPerDisRec(qpd);
  //GP BASE64编码 ,直接明文
  if not NCSvrRequest(Pub, FICBCRsq.GetXML, False, rtDataBase64Str) then
  begin
    //errorCode
    rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
    Exit;
  end;
  //解码
  rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
  WriteLog(FICBCRsq.GetXML, 'c:\批量扣个人指令查询S.xml');
  WriteLog(rtDataStr, 'c:\批量扣个人指令查询R.xml');
  //解析
  FICBCRspon.SetXML(rtDataStr);
  Pub := FICBCRspon.Pub;
  if Pub.RetCode <> '0' then
  begin
    rtDataStr := '[' + Pub.RetCode + ']' + Pub.RetMsg;
    Exit;
  end;
  //返回结果
  qpd := FICBCRspon.getQueryPerDis();
  Result := True;
end;


function TICBCAPI.QueryPayEnt(const fSeqno: string; var qpe: TQueryPayEntRec;
  var rtDataStr: string): Boolean;
var
  rtDataBase64Str: string;
  pub: TPubRec;
begin
  Result := False;
  rtDataStr := '';
  rtDataBase64Str := '';
  //请求XML部分
  pub := getPubRec('QPAYENT', fSeqno);
  FICBCRsq.setPub(pub);
  FICBCRsq.setQueryPayEntRec(qpe);
  //GP BASE64编码 ,直接明文
  if not NCSvrRequest(Pub, FICBCRsq.GetXML, False, rtDataBase64Str) then
  begin
    //errorCode
    rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
    Exit;
  end;
  //解码
  rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
  WriteLog(FICBCRsq.GetXML, 'c:\支付指令查询S.xml');
  WriteLog(rtDataStr, 'c:\支付指令查询R.xml');
  //解析
  FICBCRspon.SetXML(rtDataStr);
  Pub := FICBCRspon.Pub;
  if Pub.RetCode <> '0' then
  begin
    rtDataStr := '[' + Pub.RetCode + ']' + Pub.RetMsg;
    Exit;
  end;
  //返回结果
  qpe := FICBCRspon.getQueryPayEnt();
  Result := True;
end;

function TICBCAPI.QueryPerInf(const fSeqno: string; var qpi: TQueryPerInf;
  var rtDataStr: string): Boolean;
var
  rtDataBase64Str: string;
  pub: TPubRec;
begin
  Result := False;
  rtDataStr := '';
  rtDataBase64Str := '';
  //请求XML部分
  pub := getPubRec('QPERINF', fSeqno);
  FICBCRsq.setPub(pub);
  FICBCRsq.setQueryPerInf(qpi);
  //GP BASE64编码 ,直接明文
  if not NCSvrRequest(Pub, FICBCRsq.GetXML, False, rtDataBase64Str) then
  begin
    //errorCode
    rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
    Exit;
  end;
  //解码
  rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
  WriteLog(FICBCRsq.GetXML, 'c:\缴费个人信息查询S.xml');
  WriteLog(rtDataStr, 'c:\缴费个人信息查询R.xml');
  //解析
  FICBCRspon.SetXML(rtDataStr);
  Pub := FICBCRspon.Pub;
  if Pub.RetCode <> '0' then
  begin
    rtDataStr := '[' + Pub.RetCode + ']' + Pub.RetMsg;
    Exit;
  end;
  //返回结果
  qpi := FICBCRspon.getQueryPerInf();
  Result := True;
end;


end.

