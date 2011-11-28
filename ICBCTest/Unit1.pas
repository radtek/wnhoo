unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdAntiFreezeBase, IdAntiFreeze, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, ExtCtrls, IdCoder,
  IdCoder3to4, IdCoderMIME, BASEXMLAPI, u_NCAPI, u_ICBCXMLAPI, ComCtrls;

type
  TForm1 = class(TForm)
    IdHTTP1: TIdHTTP;
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
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FSign.Free;
  FVerifySign.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FNC:=TNCSvr.Create(self);
  //签名端口
  FNC.SIGN_URL:= 'http://192.168.1.188:449';
  //安全http协议服务器
  FNC.HTTPS_URL := 'http://192.168.1.188:448';

  FSign := TSign.create(Self);

  FVerifySign := TVerifySign.Create(Self);
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
  icbc: TICBCXMLAPI;
  pub: TPubRec;
  qhd: TQueryHistoryDetailsRec;
  qav: TQueryAccValueRec;
  qnn: TQueryNetNodeRec;
  I: Integer;
  xmlCmdBase64,rtDataStr:String;
begin

  pub.TransCode := 'NETINF';
  pub.CIS := '1209230309049304635';
  pub.BankCode := '001';
  pub.ID := '';
  pub.TranDate := FormatDateTime('YYYYMMDD', Now);
  pub.TranTime := FormatDateTime('hhnnsszzz001', Now);
  pub.fSeqno := '1234560001';

  FillChar(qhd, SizeOf(TQueryHistoryDetailsRec), 0);
  qhd.AccNo := '1209230309049304635';
  qhd.BeginDate := '20011201';
  qhd.EndDate := '20111231';
  qhd.MinAmt := '';

  qav.TotalNum := '5';
  qav.ReqReserved1 := '';
  qav.ReqReserved2 := '';
  SetLength(qav.rd, StrToInt(qav.TotalNum));
  for I := Low(qav.rd) to High(qav.rd) do
  begin
    qav.rd[i].iSeqno := IntToStr(I);
    qav.rd[i].AccNo := '111';
    qav.rd[i].CurrType := '';
    qav.rd[i].ReqReserved3 := '';
    qav.rd[i].ReqReserved4 := '';
  end;

  qnn.NextTag := '';
  qnn.ReqReserved1 := '';
  qnn.ReqReserved2 := '';

  icbc := TICBCXMLAPI.create(self);
  icbc.addPub(pub);
  //icbc.addQueryHistoryDetails(qhd);
  //icbc.addQueryAccValue(qav);
  icbc.addQueryNetNodeRec(qnn);
  mmo_xmlcmd.Clear;
  mmo_xmlcmd.Lines.Add(icbc.GetXML);
  //
  xmlCmdBase64:= IdEncoderMIME1.Encode(icbc.GetXML);
  if FNC.QueryRequest(pub,xmlCmdBase64,rtDataStr) then
  begin
  mmo_cmdrt.Lines.Add('正常数据:');
  end;
  mmo_cmdrt.Lines.Add(rtDataStr);
  ShowMessage(IdDecoderMIME1.DecodeString(rtDataStr));
  
  icbc.Free;
end;



end.

