unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, u_Func, ComCtrls;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheet3: TTabSheet;
    mmo_cmdrt: TMemo;
    Button4: TButton;
    Button1: TButton;
    Button3: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button2: TButton;
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure WriteCmdRtLog(const Str: string);
    procedure ShowMsg(const rtMsg: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}



procedure TForm1.WriteCmdRtLog(const Str: string);
begin
  mmo_cmdrt.Lines.Add(Str);
end;

procedure TForm1.ShowMsg(const rtMsg: string);
begin
  ShowMessage(rtMsg);
end;

procedure TForm1.Button1Click(Sender: TObject);
{var
  qhd: TQueryHistoryDetailsRec;
  I: Integer;
  rtDataStr: string; }
begin
 {FillChar(qhd, SizeOf(TQueryHistoryDetailsRec), 0);
  qhd.AccNo := '1209230309049304635';
  qhd.BeginDate := '20111201';
  qhd.EndDate := '20121206';
  qhd.MinAmt := '0';
  qhd.MaxAmt := '1000000';
  qhd.NextTag := '';

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

  end;  }
end;


procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  U_ICBCCtl.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  LoadCfg();
  U_ICBCCtl := TICBCCtlAPI.Create(self);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  rtCode, rtMsg, rtStr: string;
begin
  if U_ICBCCtl.QueryPayEnt_S('Q00008', 'PE00003', rtCode, rtMsg, rtStr) then
    WriteCmdRtLog(rtStr)
  else
    ShowMsg(rtMsg);
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  rtCode, rtMsg, rtStr: string;
begin
  if U_ICBCCtl.PayEnt_S('PE00003', '6222031202799000087', '三套B', '200', '一卡通退款', 'OneIC01', '一卡通相关业务', rtCode, rtMsg, rtStr) then
    WriteCmdRtLog(rtStr)
  else
    ShowMsg(rtMsg);
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  rtCode, rtMsg, rtStr: string;
begin
  if U_ICBCCtl.QueryAccValue_S('Q00001', '1209230309049304635', rtCode, rtMsg, rtStr) then
    WriteCmdRtLog(rtStr)
  else
    ShowMsg(rtMsg);
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  rtCode, rtMsg, rtStr: string;
begin
  if U_ICBCCtl.QueryPerDis_S('Q00008', 'PD00002', rtCode, rtMsg, rtStr) then
    WriteCmdRtLog(rtStr)
  else
    ShowMsg(rtMsg);
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  rtCode, rtMsg, rtStr: string;
begin
  if U_ICBCCtl.PerDis_S('PD00008', '6222031202799000087', '三套B', '111', 'BDP300080432', '300', '一卡通预存', 'PS01', '实时充值',
    rtCode, rtMsg, rtStr) then
    WriteCmdRtLog(rtStr)
  else
    ShowMsg(rtMsg);
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  rtMsg, rtCode, rtStr, NextTag: string;
begin
  //首次送空
  NextTag := '';
  while True do
  begin
    if U_ICBCCtl.QueryCurDayDetails_M('Q00001', '1209230309049304635', NextTag, rtCode, rtMsg, rtStr) then
      WriteCmdRtLog(rtStr)
    else
      ShowMsg(rtMsg);
    if NextTag = '' then Break;
  end;
end;
end.

