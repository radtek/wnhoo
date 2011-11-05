unit Unit1;

{$MODE objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls,ComCtrls, ExtCtrls, Windows, LMessages, LCLIntf, Menus, Buttons,
  u_Func, u_CommBag,u_ReaderThread;

type

  { TMainFrm }

  TMainFrm = class(TForm)
    btn_cb: TButton;
    btn_ic: TButton;
    btn_OK: TButton;
    btn_Reset: TButton;
    btn_ul: TButton;
    edt_Msg: TEdit;
    edt_CarUL: TEdit;
    edt_CarVIN: TEdit;
    edt_DriverIC: TEdit;
    edt_DriverName: TEdit;
    edt_EngineNum: TEdit;
    edt_ProjectNum: TEdit;
    gb_Car: TGroupBox;
    gb_driver: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    pnl_top: TPanel;
    pnl_Main: TPanel;
    rg_Direction: TRadioGroup;
    sb: TStatusBar;
    procedure btn_cbClick(Sender: TObject);
    procedure btn_OKClick(Sender: TObject);
    procedure btn_ResetClick(Sender: TObject);
    procedure btn_ulClick(Sender: TObject);
    procedure btn_icClick(Sender: TObject);
    procedure edt_CarVINEnter(Sender: TObject);
    procedure edt_CarVINExit(Sender: TObject);
    procedure edt_CarVINKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ShortcutEvent(var Msg: TLMKey; var Handled: Boolean);
  private
    hTaskBar: THANDLE;
    Rdt:TReaderThread;
    OldShortcutEvent:TShortcutEvent;
  public

  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.lfm}

{ TMainFrm }

procedure TMainFrm.btn_OKClick(Sender: TObject);
var
  IOR:TInOutRec;
begin
  TButton(sender).Enabled:=False;
  try
     if U_Guard.UserID<=0 then Exit;
     if U_Driver.UserID<=0 then Exit;
     if not((Trim(U_Car.VIN)<>'') and (Trim(U_Car.EngineNum)<>'')) then Exit;
     if rg_Direction.ItemIndex<0 then Exit;
     IOR.PDANum:=PDANum;
     IOR.Car:=U_Car;
     IOR.Driver:=U_Driver;
     IOR.Guard:=U_Guard;
     IOR.RecTime:=Now; //服务器修正登记时间
     IOR.DirectionFlag:=rg_Direction.ItemIndex+1;
     if not Pc.SaveInOutRec(IOR) then
     begin
          ShowErrMsg();
          Exit;
     end;
     PlayWav(WT_GO);
     //登记成功，服务器修正登记时间
     //ShowMessage('登记成功！');
     edtMsg.Text:='登记成功！';
     //清除
     _ClearDriver();
     _ClearCar();
     rg_Direction.ItemIndex:=0;
  finally
     TButton(sender).Enabled:=True;
  end;
end;

procedure TMainFrm.btn_ResetClick(Sender: TObject);
begin
  _ClearDriver();
  _ClearCar();
  edt_msg.Clear;
end;

procedure TMainFrm.edt_CarVINKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
 VIN:String;
begin
  if key=13 then
  begin
   VIN:=Trim(edt_CarVIN.Text);
   if VIN<>'' then
   begin
     //初始化
     _ClearCar();
     U_Car.VIN:=VIN;
     _QueryCar();
   end;
  end;
end;

procedure TMainFrm.btn_cbClick(Sender: TObject);
begin
  if Rdt.ReaderCMD<>RC_None then exit;
  //初始化
  _ClearCar();
  edt_CarVIN.Text := '请扫描条码...';
  Rdt.ReaderCMD:=RC_1D;
end;

procedure TMainFrm.btn_ulClick(Sender: TObject);
begin
  if Rdt.ReaderCMD<>RC_None then exit;
  //初始化
  _ClearCar();
  edt_CarUL.Text := '请刷RFID...';
  Rdt.ReaderCMD:=RC_UL;
end;

procedure TMainFrm.btn_icClick(Sender: TObject);
begin
  if Rdt.ReaderCMD<>RC_None then exit;
  //初始化
  _ClearDriver();
  edt_DriverIC.Text := '请刷IC...';
  Rdt.ReaderCMD:=RC_IC;
end;

procedure TMainFrm.edt_CarVINEnter(Sender: TObject);
begin
   SipShowIM(SIPF_ON);
end;

procedure TMainFrm.edt_CarVINExit(Sender: TObject);
begin
   SipShowIM(SIPF_OFF);
end;

procedure TMainFrm.FormCreate(Sender: TObject);
begin
  StatusBar:=sb;
  edtCarUL:=edt_CarUL;
  edtCarVIN:=edt_CarVIN;
  edtDriverIC:=edt_DriverIC;
  edtDriverName:=edt_DriverName;
  edtEngineNum:=edt_EngineNum;
  edtProjectNum:=edt_ProjectNum;
  edtMsg:=edt_msg;

  DoubleBuffered := True;
  _ClearDriver();
  _ClearCar();
  OldShortcutEvent:=Application.OnShortcut;
  Application.OnShortcut := @ShortcutEvent;
  //hTaskBar := findwindow('HHTaskBar', '');
  //ShowWindow(hTaskBar, SW_HIDE); //Hide任务栏

  width:=Screen.Width;
  //height:=Screen.Height;

  StatusBar.Panels[1].Text:='正常';
  StatusBar.Panels[2].Text:=UTF8EnCode(U_Guard.UserName);
  StatusBar.Panels[3].Text:=InttoStr(PDANum);

  edt_msg.Text:='操作信息提示区';
  //记录登陆日志
  SaveLoginLog(1);
  Rdt:=TReaderThread.Create(false);
end;

procedure TMainFrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //关闭软键盘
  SipShowIM(SIPF_OFF);
  //退出显示任务栏
  //ShowWindow(hTaskBar, SW_SHOW);
  //退出Reader线程
  Rdt.Terminate;
  Rdt.SetEvent();
  Rdt.WaitFor;
  Rdt.Free;
  //Log
  SaveLoginLog(2);
  //Close
  CloseAction := caFree;
end;

procedure TMainFrm.ShortcutEvent(var Msg: TLMKey; var Handled: Boolean);
begin
  Handled := True;
  case Msg.CharCode of
    VK_F4:begin
        //中止
        Rdt.ReaderCMD:=RC_None;
    end;
    VK_F3:btn_cb.Click;
    VK_F2:btn_ul.Click;
    VK_F1:btn_ic.Click;
    VK_F5:btn_ok.Click;
  else
    Handled := False;
  end;

  if Assigned(OldShortcutEvent) then
   OldShortcutEvent(Msg,Handled);
end;



end.

