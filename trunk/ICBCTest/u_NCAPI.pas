(*
    NCͨѶ����������
    ԭʼ���ߣ�������
    ����ʱ�䣺2011-12-02
*)
unit u_NCAPI;

interface

uses

  SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, Variants, IdHTTP, BASEXMLAPI, u_ICBCRec;

type

  //ǩ����Ϣ
  TSignRec = record
    RtCode: string;
    RtStr: string;
    DataStr: string;
  end;

  //��ǩ��Ϣ
  TVerifySignRec = TSignRec;

  TNCSvr = class(TComponent)
  private
    //��ȫhttpЭ�������
    FHTTPS_URL: string;
    //ǩ���˿�
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
    '������룺' + FSR.RtCode + #13#10 +
    '����˵����' + FSR.RtStr + #13#10 +
    '�������ݣ�' + FSR.DataStr;
end;

procedure TSign.ParserXML;
begin
  inherited;
  FillChar(FSR, Sizeof(TSignRec), 0);
  //�������
  FSR.RtCode := GetSingleNodeValue('/html/head/result');
  //������ʾ
  FSR.RtStr := GetSingleNodeValue('/html/head/title');
  //����
  if FSR.RtCode = '0' then
    FSR.DataStr := GetSingleNodeValue('/html/body/sign')
  else
    FSR.DataStr := GetSingleNodeValue('/html/body');
end;

{ TVerifySignXML }

function TVerifySign.GetText: string;
begin
  Result :=
    '������룺' + FVSR.RtCode + #13#10 +
    '����˵����' + FVSR.RtStr + #13#10 +
    '�������ݣ�' + FVSR.DataStr;
end;

procedure TVerifySign.ParserXML;
begin
  inherited;
  FillChar(FVSR, Sizeof(TVerifySignRec), 0);
  //�������
  FVSR.RtCode := GetSingleNodeValue('/html/head/result');
  //������ʾ
  FVSR.RtStr := GetSingleNodeValue('/html/head/title');
  //����
  if FVSR.RtCode = '0' then
    FVSR.DataStr := GetSingleNodeValue('/html/body/sic')
  else
    FVSR.DataStr := GetSingleNodeValue('/html/body');

  //���кܶ������ݣ���NC��װĿ¼�ֲ�˵��
end;

{ TNCSvr }

procedure TNCSvr.SetHttpParams(const http: TIdHttp);
begin
  http.Request.Clear;
  http.Request.Clear;
  //����
  http.Request.AcceptLanguage := 'zh-cn';
  http.Request.UserAgent := 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)';
  http.Request.Pragma := 'no-cache';
  http.Request.CacheControl := 'no-cache';
  //��ʱ
  http.ReadTimeout := 30000;
  http.ConnectTimeout:=30000;
  //ʹ�� 1.1 Э��
  http.HTTPOptions := http.HTTPOptions + [hoKeepOrigProtocol]; //�ؼ�����
  http.ProtocolVersion := pv1_1;
  //֧���ض���,���Ǳ�Ҫ,�����޷�
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
    //ͳһ���ò���
    SetHttpParams(http);
    //��Content-Type:����������Ҫǩ���ı�ǣ�ΪINFOSEC_SIGN/1.0����ע���Сд��
    http.Request.ContentType := 'INFOSEC_SIGN/1.0';
    //��Content-Length:����������Ҫǩ���Ķ��������ݰ��ĳ���
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
    //ͳһ���ò���
    SetHttpParams(http);
    //��Content-Type:��ΪINFOSEC_VERIFY_SIGN/1.0����ע���Сд��
    http.Request.ContentType := 'INFOSEC_VERIFY_SIGN/1.0';
    //��Content-Length:����������Ҫǩ���Ķ��������ݰ��ĳ���
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
    //�ھ�������ͨ��httpЭ����POST��ʽ�����װ����͵�NC�İ�ȫhttpЭ���������
    //action�е�֤��ID��PackageID���������ݸ�ʽ�е�֤��ID��PackageID��
    //xml���е�֤��ID��PackageID��ֵ������һ�¡�
    HTTPS_URL_Send := Format(
      '%s/servlet/ICBCCMPAPIReqServlet?userID=%s&PackageID=%s&SendTime=%s',
      [FHTTPS_URL, pub.ID, pub.fSeqno, FormatDateTime('YYYYMMDDhhnnsszzz', Now)]);
    //////////////////////�������ݸ�ʽ//////////////////////////////////////////
    //�汾�ţ����ְ汾ʱ�䣬�ݶ�0.0.0.1)
    Params.Add('Version=0.0.0.1');
    //���״��루���ֽ������ͣ�ÿ�����׹̶�)
    //TransCode��������Ӧ��xml���ڱ�ǩ<TransCode></TransCode>�е�ֵһ��
    Params.Add(Format('TransCode=%s', [pub.TransCode]));
    //�ͻ��Ĺ�����λ
    Params.Add(Format('BankCode=%s', [pub.BankCode]));
    //�ͻ��Ĺ�������
    Params.Add(Format('GroupCIS=%s', [pub.CIS]));
    //�ͻ���֤��ID����֤��ͻ��ɿ�)
    Params.Add(Format('ID=%s', [pub.ID]));
    //�ͻ���ָ������кţ��ɿͻ�ERPϵͳ�����������ظ�)
    Params.Add(Format('PackageID=%s', [pub.fSeqno]));
    //�ͻ���֤�鹫Կ��Ϣ������BASE64���룻NC�ͻ��Ϳ�)
    Params.Add(Format('Cert=%s', ['']));
    //�ͻ���xml��������
    Params.Add(Format('reqData=%s', [reqData]));

    //ͳһ���ò���
    SetHttpParams(http);
    RtHtmlSrc := http.Post(HTTPS_URL_Send, Params);

    //��ʽ�� Java ����Base64����
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
        raise Exception.Create('�޷�������������!');
      end;
    end;
  finally
    Params.Free;
    http.Free;
  end;
end;

end.

