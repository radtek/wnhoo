unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdAntiFreezeBase, IdAntiFreeze, ExtCtrls,
  u_ICBCAPI, u_ICBCRec, ComCtrls,
  IdBaseComponent;

type
  TForm1 = class(TForm)
    IdAntiFreeze1: TIdAntiFreeze;
    Panel1: TPanel;
    Button2: TButton;
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
    Button1: TButton;
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
  private
    FICBC: TICBCAPI;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  qhd: TQueryHistoryDetailsRec;
  I: Integer;
  rtDataStr: string;
begin
  FillChar(qhd,SizeOf(TQueryHistoryDetailsRec),0);
  qhd.AccNo := '1209230309049304635';
  qhd.BeginDate:='20011111';
  qhd.EndDate:='20121231';
  qhd.MinAmt:='0';
  qhd.MaxAmt:='1000000';
  qhd.NextTag:='';
  qhd.ReqReserved1:='';
  qhd.ReqReserved2:='';

  if not FICBC.QueryHistoryDetails('1234561112', qhd, rtDataStr) then
  begin
    ShowMessage('标准错误:' + rtDataStr);
    Exit;
  end;

  mmo_cmdrt.Lines.Add('正常数据:');
  mmo_cmdrt.Lines.Add(rtDataStr);

  for I := Low(qhd.rd) to High(qhd.rd) do
  begin
    mmo_cmdrt.Lines.Add('=====================================');
    mmo_cmdrt.Lines.Add(qhd.rd[i].Drcrf);

  end;
end;


procedure TForm1.Button2Click(Sender: TObject);
 {var
 rtData: string;
  rt:Boolean; }
begin
  {rtData := '';
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
  mmo_rtdata.Lines.Add(FVerifySign.GetText);}
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  qav: TQueryAccValueRec;
  I: Integer;
  rtDataStr: string;
begin
  FillChar(qav,SizeOf(TQueryAccValueRec),0);
  qav.TotalNum := '1';
  qav.ReqReserved1 := '';
  qav.ReqReserved2 := '';
  SetLength(qav.rd, StrToInt(qav.TotalNum));
  for I := Low(qav.rd) to High(qav.rd) do
  begin
    qav.rd[i].iSeqno := IntToStr(I);
    qav.rd[i].AccNo := '1209230309049304635'; // '6222031202799000087';
    qav.rd[i].CurrType := '';
    qav.rd[i]._Reserved3 := '';
    qav.rd[i]._Reserved4 := '';
  end;

  if not FICBC.QueryAccValue('1234561111', qav, rtDataStr) then
  begin
    ShowMessage('标准错误:' + rtDataStr);
    Exit;
  end;

  mmo_cmdrt.Lines.Add('正常数据:');
  mmo_cmdrt.Lines.Add(rtDataStr);

  for I := Low(qav.rd) to High(qav.rd) do
  begin
    mmo_cmdrt.Lines.Add('=====================================');
    mmo_cmdrt.Lines.Add(qav.rd[i].iSeqno);
    mmo_cmdrt.Lines.Add(qav.rd[i].AccNo);
    mmo_cmdrt.Lines.Add(qav.rd[i].CurrType);

    mmo_cmdrt.Lines.Add(qav.rd[I].CashExf);
    mmo_cmdrt.Lines.Add(qav.rd[I].AcctProperty);
    mmo_cmdrt.Lines.Add(qav.rd[I].AccBalance);
    mmo_cmdrt.Lines.Add(qav.rd[I].Balance);
    mmo_cmdrt.Lines.Add(qav.rd[I].UsableBalance);
    mmo_cmdrt.Lines.Add(qav.rd[I].FrzAmt);
    mmo_cmdrt.Lines.Add(qav.rd[I].QueryTime);
    mmo_cmdrt.Lines.Add(qav.rd[I].iRetCode);
    mmo_cmdrt.Lines.Add(qav.rd[I].iRetMsg);

    mmo_cmdrt.Lines.Add(qav.rd[i]._Reserved3);
    mmo_cmdrt.Lines.Add(qav.rd[i]._Reserved4);
  end;
end;



procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FICBC.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FICBC := TICBCAPI.Create(self);
  FICBC.CIS := '120990000076433';
  FICBC.BankCode := '102';
  FICBC.ID := 'js01.y.1209';
end;

end.

