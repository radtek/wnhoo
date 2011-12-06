(*
    NC通讯操作及解析
    原始作者：王云涛
    建立时间：2011-12-02
*)
unit u_NCAPI;

interface

uses

  SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, Variants, IdHTTP, BASEXMLAPI, u_ICBCRec;

type

  //签名信息
  TSignRec = record
    RtCode: string;
    RtStr: string;
    DataStr: string;
  end;

  //验签信息
  TVerifySignRec = TSignRec;

  TNCSvr = class(TComponent)
  private
    //安全http协议服务器
    FHTTPS_URL: string;
    //签名端口
    FSIGN_URL: string;
    procedure SetHttpParams(const http: TIdHttp);
  public
    function Sign(const DataStr: string; var rtDataStr: string): Boolean;
    function verify_sign(const DataStr: string; var rtDataStr: string): Boolean;
    function Request(const pub: TPubRec; const reqData: string;
      var rtDataStr: string): Boolean;
    property HTTPS_URL: string read FHTTPS_URL write FHTTPS_URL;
    property SIGN_URL: string read FSIGN_URL write FSIGN_URL;
  end;

  TSign = class(TBASEXMLAPI)
  private
    FSR: TSignRec;
  protected
    procedure ParserXML(); override;
  public
    function GetText: string;
    property SignRec: TSignRec read FSR;
  end;

  TVerifySign = class(TBASEXMLAPI)
  private
    FVSR: TVerifySignRec;
  protected
    procedure ParserXML(); override;
  public
    function GetText: string;
    property VerifySignRec: TVerifySignRec read FVSR;
  end;

implementation

{ TSignXML }

function TSign.GetText(): string;
begin
  Result :=
    '错误代码：' + FSR.RtCode + #13#10 +
    '错误说明：' + FSR.RtStr + #13#10 +
    '返回数据：' + FSR.DataStr;
end;

procedure TSign.ParserXML;
begin
  inherited;
  FillChar(FSR, Sizeof(TSignRec), 0);
  //错误代码
  FSR.RtCode := GetSingleNodeValue('/html/head/result');
  //错误提示
  FSR.RtStr := GetSingleNodeValue('/html/head/title');
  //数据
  if FSR.RtCode = '0' then
    FSR.DataStr := GetSingleNodeValue('/html/body/sign')
  else
    FSR.DataStr := GetSingleNodeValue('/html/body');
end;

{ TVerifySignXML }

function TVerifySign.GetText: string;
begin
  Result :=
    '错误代码：' + FVSR.RtCode + #13#10 +
    '错误说明：' + FVSR.RtStr + #13#10 +
    '返回数据：' + FVSR.DataStr;
end;

procedure TVerifySign.ParserXML;
begin
  inherited;
  FillChar(FVSR, Sizeof(TVerifySignRec), 0);
  //错误代码
  FVSR.RtCode := GetSingleNodeValue('/html/head/result');
  //错误提示
  FVSR.RtStr := GetSingleNodeValue('/html/head/title');
  //数据
  if FVSR.RtCode = '0' then
    FVSR.DataStr := GetSingleNodeValue('/html/body/sic')
  else
    FVSR.DataStr := GetSingleNodeValue('/html/body');

  //还有很多结果数据，见NC安装目录手册说明
end;

{ TNCSvr }

procedure TNCSvr.SetHttpParams(const http: TIdHttp);
begin
  http.Request.Clear;
  http.Request.Clear;
  //基本
  http.Request.AcceptLanguage := 'zh-cn';
  http.Request.UserAgent := 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)';
  http.Request.Pragma := 'no-cache';
  http.Request.CacheControl := 'no-cache';
  //超时
  http.ReadTimeout := 30000;
  http.ConnectTimeout:=30000;
  //使用 1.1 协议
  http.HTTPOptions := http.HTTPOptions + [hoKeepOrigProtocol]; //关键这行
  http.ProtocolVersion := pv1_1;
  //支持重定向,不是必要,加上无妨
  http.HandleRedirects := True;
end;

function TNCSvr.Sign(const DataStr: string; var rtDataStr: string): Boolean;
var
  DataSm: TStringStream;
  http: TIdHTTP;
begin
  Result := False;
  http := TIdHTTP.Create(self);
  DataSm := TStringStream.Create(DataStr);
  try
    DataSm.Position := 0;
    //统一设置参数
    SetHttpParams(http);
    //“Content-Type:”后面是需要签名的标记，为INFOSEC_SIGN/1.0。（注意大小写）
    http.Request.ContentType := 'INFOSEC_SIGN/1.0';
    //“Content-Length:”后面是需要签名的二进制数据包的长度
    http.Request.ContentLength := DataSm.Size;
    rtDataStr := http.Post(FSIGN_URL, DataSm);
    if http.Response.ContentType = 'INFOSEC_SIGN_RESULT/1.0' then
    begin
      rtDataStr := '<?xml version="1.0" encoding = "GBK"?>' + #13#10 + rtDataStr;
      Result := True;
    end;
  finally
    DataSm.Free;
    http.Free;
  end;
end;

function TNCSvr.verify_sign(const DataStr: string; var rtDataStr: string): Boolean;
var
  DataSm: TStringStream;
  http: TIdHTTP;
begin
  Result := False;
  http := TIdHTTP.Create(self);
  DataSm := TStringStream.Create(DataStr);
  try
    DataSm.Position := 0;
    //统一设置参数
    SetHttpParams(http);
    //“Content-Type:”为INFOSEC_VERIFY_SIGN/1.0。（注意大小写）
    http.Request.ContentType := 'INFOSEC_VERIFY_SIGN/1.0';
    //“Content-Length:”后面是需要签名的二进制数据包的长度
    http.Request.ContentLength := DataSm.Size;
    rtDataStr := http.Post(FSIGN_URL, DataSm);
    if http.Response.ContentType = 'INFOSEC_VERIFY_SIGN_RESULT/1.0' then
    begin
      rtDataStr := '<?xml version="1.0" encoding = "GBK"?>' + #13#10 + rtDataStr;
      Result := True;
    end;
  finally
    DataSm.Free;
    http.Free;
  end;
end;

function TNCSvr.Request(const pub: TPubRec; const reqData: string; var rtDataStr: string): Boolean;
var
  Params: TStrings;
  HTTPS_URL_Send, RtHtmlSrc: string;
  Pe: Integer;
  Pd: Integer;
  DataLen: Integer;
  http: TIdHTTP;
begin
  Result := False;
  http := TIdHTTP.Create(self);
  Params := TStringList.Create;
  try
    //在局域网内通过http协议以POST方式将交易包发送到NC的安全http协议服务器。
    //action中的证书ID、PackageID与请求数据格式中的证书ID、PackageID、
    //xml包中的证书ID、PackageID的值三者相一致。
    HTTPS_URL_Send := Format(
      '%s/servlet/ICBCCMPAPIReqServlet?userID=%s&PackageID=%s&SendTime=%s',
      [FHTTPS_URL, pub.ID, pub.fSeqno, FormatDateTime('YYYYMMDDhhnnsszzz', Now)]);
    //////////////////////请求数据格式//////////////////////////////////////////
    //版本号（区分版本时间，暂定0.0.0.1)
    Params.Add('Version=0.0.0.1');
    //交易代码（区分交易类型，每个交易固定)
    //TransCode交易名称应与xml包内标签<TransCode></TransCode>中的值一致
    Params.Add(Format('TransCode=%s', [pub.TransCode]));
    //客户的归属单位
    Params.Add(Format('BankCode=%s', [pub.BankCode]));
    //客户的归属编码
    Params.Add(Format('GroupCIS=%s', [pub.CIS]));
    //客户的证书ID（无证书客户可空)
    Params.Add(Format('ID=%s', [pub.ID]));
    //客户的指令包序列号（由客户ERP系统产生，不可重复)
    Params.Add(Format('PackageID=%s', [pub.fSeqno]));
    //客户的证书公钥信息（进行BASE64编码；NC客户送空)
    Params.Add(Format('Cert=%s', ['']));
    //客户的xml请求数据
    Params.Add(Format('reqData=%s', [reqData]));

    //统一设置参数
    SetHttpParams(http);
    RtHtmlSrc := http.Post(HTTPS_URL_Send, Params);

    //格式化 Java 返回Base64编码
    RtHtmlSrc := StringReplace(RtHtmlSrc, #$A, '', [rfReplaceAll, rfIgnoreCase]);
    DataLen := Length(RtHtmlSrc);
    Pe := Pos('errorCode=', RtHtmlSrc);
    if Pe > 0 then
    begin
      rtDataStr := Copy(RtHtmlSrc, Pe + 10, DataLen);
    end
    else
    begin
      Pd := Pos('reqData=', RtHtmlSrc);
      if Pd > 0 then
      begin
        rtDataStr := Copy(RtHtmlSrc, Pd + 8, DataLen);
        Result := True;
      end
      else
      begin
        raise Exception.Create('无法解析返回数据!');
      end;
    end;
  finally
    Params.Free;
    http.Free;
  end;
end;

end.

