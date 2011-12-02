(*
    ICBCͨѶAPI
    ԭʼ���ߣ�������
    ����ʱ�䣺2011-12-02
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
  //ǩ���˿�
  FNC.SIGN_URL := 'http://192.168.1.188:449';
  //��ȫhttpЭ�������
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
  //����XML����
  FICBCRsq.setPub(Pub);
  FICBCRsq.setQueryAccValue(qav);
  //GP BASE64���� ,ֱ������
  if not FNC.QueryRequest(Pub, FICBCRsq.GetXML, rtDataBase64Str) then
  begin
    //errcode
    rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
    Exit;
  end;
  //����
  rtDataStr := FdeBase64.DecodeString(rtDataBase64Str);
  //����
  FICBCRspon.SetXML(rtDataStr);
  if FICBCRspon.Pub.RetCode <> '0' then
  begin
       //���󷵻�
       Exit;
  end;
  //���ؽ��
end;


end.

