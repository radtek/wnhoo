unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdAntiFreezeBase, IdAntiFreeze, ExtCtrls, IdCoder,
  IdCoder3to4, IdCoderMIME, BASEXMLAPI, u_NCAPI, u_ICBCXMLAPI,u_ICBCRec, ComCtrls,
  IdBaseComponent;

type
  TForm1 = class(TForm)
    IdAntiFreeze1: TIdAntiFreeze;
    Panel1: TPanel;
    Button2: TButton;
    IdEncoderMIME1: TIdEncoderMIME;
    IdDecoderMIME1: TIdDecoderMIME;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    mmo_xmlcmd: TMemo;
    TabSheet3: TTabSheet;
    mmo_cmdrt: TMemo;
    mmo_rtdata: TMemo;
    Button4: TButton;
    TabSheet4: TTabSheet;
    Memo1: TMemo;
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
  private
    FNC:TNCSvr;
    FSign: TSign;
    FVerifySign: TVerifySign;
    FICBCRsq: TICBCRequestAPI;
    FICBCRsp:TICBCResponseAPI;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
procedure TForm1.FormCreate(Sender: TObject);
begin
  FNC:=TNCSvr.Create(self);
  //签名端口
  FNC.SIGN_URL:= 'http://192.168.1.188:449';
  //安全http协议服务器
  FNC.HTTPS_URL := 'http://192.168.1.188:448';
  FSign := TSign.create(Self);
  FVerifySign := TVerifySign.Create(Self);
  FICBCRsq:=TICBCRequestAPI.Create(Self);
  FICBCRsp:=TICBCResponseAPI.Create(self);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FICBCRsq.Free;
  FSign.Free;
  FVerifySign.Free;
  FICBCRsp.Free;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  rtData: string;
  rt:Boolean;
begin
  rtData := '';
  mmo_rtdata.Lines.Clear;
  rt:=FNC.Sign(mmo_xmlcmd.Lines.Text, rtData);
  mmo_rtdata.Lines.Add(rtData);
  if not rt then Exit;
  if not FSign.SetXML(rtData) then Exit;
  mmo_rtdata.Lines.Add(FSign.GetText);
  if FSign.SignRec.RtCode <> '0' then Exit;
  //验签
   mmo_rtdata.Lines.Add(#13#10);
  rt:=FNC.verify_sign(FSign.SignRec.DataStr, rtData);
  mmo_rtdata.Lines.Add(rtData);
  if not rt then Exit;
  if not FVerifySign.SetXML(rtData) then Exit;
  mmo_rtdata.Lines.Add(FVerifySign.GetText);
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  pub: TPubRec;
  qhd: TQueryHistoryDetailsRec;
  qav: TQueryAccValueRec;
  qnn: TQueryNetNodeRec;
  I: Integer;
  xmlCmdBase64,rtDataStr:String;
begin

  FillChar(pub,SizeOf(TPubRec),0);
  //pub.TransCode := 'NETINF';
  pub.TransCode := 'QACCBAL';
  pub.CIS := '120990000076433';
  pub.BankCode := '102';
  pub.ID := 'js01.y.1209';
  pub.TranDate := FormatDateTime('YYYYMMDD', Now);
  pub.TranTime := FormatDateTime('hhnnsszzz001', Now);
  pub.fSeqno := '1234561111';

  FillChar(qhd, SizeOf(TQueryHistoryDetailsRec), 0);
  qhd.AccNo := '1209230309049304635';
  qhd.BeginDate := '20011201';
  qhd.EndDate := '20111231';
  qhd.MinAmt := '';

  qav.TotalNum := '1';
  qav.ReqReserved1 := '';
  qav.ReqReserved2 := '';
  SetLength(qav.rd, StrToInt(qav.TotalNum));
  for I := Low(qav.rd) to High(qav.rd) do
  begin
    qav.rd[i].iSeqno := IntToStr(I);
    qav.rd[i].AccNo := '6222031202799000087';
    qav.rd[i].CurrType := '';
    qav.rd[i].ReqReserved3 := '';
    qav.rd[i].ReqReserved4 := '';
  end;

  FillChar(qnn,SizeOf(TQueryNetNodeRec),0);
  qnn.NextTag := '';
  qnn.ReqReserved1 := '';
  qnn.ReqReserved2 := '';

  //请求XML部分
  FICBCRsq.setPub(pub);
  //FICBCRsq.setQueryHistoryDetails(qhd);
  FICBCRsq.setQueryAccValue(qav);
  //FICBCRsq.setQueryNetNodeRec(qnn);
  mmo_xmlcmd.Lines.Add(FICBCRsq.GetXML);
  //BASE64编码
  xmlCmdBase64:= IdEncoderMIME1.Encode(FICBCRsq.GetXML);
  if FNC.QueryRequest(pub,xmlCmdBase64,rtDataStr) then
  begin
    mmo_cmdrt.Lines.Add('正常数据:');
    FICBCRsp.SetXML(IdDecoderMIME1.DecodeString(rtDataStr));
    ShowMessage(FICBCRsp.Pub.RetMsg);

    //ShowMessage(FICBCRsp.getQueryNetNodeRec().rd[0].AreaCode);
  end;
  mmo_cmdrt.Lines.Add(rtDataStr);
  ShowMessage(IdDecoderMIME1.DecodeString(rtDataStr));
end;



end.

