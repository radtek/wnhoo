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
    FNC: TNCSvr;
    FSign: TSign;
    FVerifySign: TVerifySign;
    FICBCRsq: TICBCRequestAPI;
    FICBCRspon: TICBCResponseAPI;
    function QueryAccValue(const Pub: TPubRec;
      var qav: TQueryAccValueRec): Boolean;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{ TICBCAPI }

constructor TICBCAPI.Create(AOwner: TComponent);
begin
  inherited;
  FdeBase64 := TIdDecoderMIME.Create(self);
  FNC := TNCSvr.Create(self);
  //签名端口
  FNC.SIGN_URL := 'http://192.168.1.188:449';
  //安全http协议服务器
  FNC.HTTPS_URL := 'http://192.168.1.188:448';
  FSign := TSign.create(Self);
  FVerifySign := TVerifySign.Create(Self);
  FICBCRsq := TICBCRequestAPI.Create(Self);
  FICBCRspon := TICBCResponseAPI.Create(self);
end;

destructor TICBCAPI.Destroy;
begin
  FICBCRspon.Free;
  FICBCRsq.Free;
  FVerifySign.Free;
  FSign.Free;
  FNC.Free;
  FdeBase64.Free;
  inherited;
end;

function TICBCAPI.QueryAccValue(const Pub: TPubRec; var qav: TQueryAccValueRec): Boolean;
var
  rtDataStr, rtDataBase64Str: string;
begin
  rtDataStr := '';
  rtDataBase64Str := '';
  //请求XML部分
  FICBCRsq.setPub(Pub);
  FICBCRsq.setQueryAccValue(qav);
  //GP BASE64编码 ,直接明文
  if not FNC.QueryRequest(Pub, FICBCRsq.GetXML, rtDataBase64Str) then
  begin
    //errcode
    rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
    Exit;
  end;
  //解码
  rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
  //解析
  FICBCRspon.SetXML(rtDataStr);
  if FICBCRspon.Pub.RetCode <> '0' then
  begin
       //错误返回
       Exit;
  end;
  //返回结果
end;


end.

