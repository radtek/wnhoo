unit u_Func;

{$mode objfpc}{$H+}

interface

uses
  Windows,Forms,Classes,Dialogs,StdCtrls, SysUtils,ComCtrls,MMSystem,IniFiles,
  u_SocketClient,u_CommBag,u_DM,Frm_InfoShow,u_DevAPI;

const
  WM_UPCtlState=WM_User+2011;

  //一些常数可以在Windows中发现
  POWER_STATE_ON = $00010000;
  POWER_STATE_OFF = $00020000;
  POWER_STATE_SUSPEND = $00200000;
  POWER_STATE_RESET = $00800000;
  POWER_FORCE = 4096;
  //some of consts already found in Windows
  SIPF_OFF    =	$00000000;
  SIPF_ON     =	$00000001;
  SIPF_DOCKED =	$00000002;
  SIPF_LOCKED =	$00000004;

//电源状态
function SetSystemPowerState(psState: PWideChar; StateFlags: DWORD; Options: DWORD): DWORD;
stdcall; external KernelDLL name 'SetSystemPowerState';

//软键盘
//aygshell 单元，SHSipPreference(handle,SIP_UP);  也可以，此单元很多CE专用函数

function SipShowIM(IPStatus:DWORD):Integer; external KernelDLL name 'SipShowIM';
//播放OK音乐
procedure PlayOK();
//载入配置
function LoadCfgFile():boolean;
//读取保安卡

//检测连接状态
procedure _CheckSvrConn();
//显示错误提示
procedure ShowErrMsg();
//清除驾驶员信息
procedure _ClearDriver();
//查询驾驶员信息
procedure _QueryDriver();
//清除车辆信息
procedure _ClearCar();
//查询车辆信息
procedure _QueryCar();
//IC卡号转换
function GetFullCardNum(Const FullCardNumHex:String;out FullCardNum:Cardinal):Boolean;
//记录日志
function WriteLog(const fn: TFileName; const log: string): Boolean;
//检测配置
Function CheckCfg():Boolean;
//保存登陆状态
procedure SaveLoginLog(State: integer);
var
  Pc:TPDAClient;
  StatusBar: TStatusBar;
  edtCarUL: TEdit;
  edtCarVIN: TEdit;
  edtDriverIC: TEdit;
  edtDriverName: TEdit;
  edtEngineNum: TEdit;
  edtProjectNum: TEdit;

  SvrIP:String;
  SvrPort:Word;
  HBI:DWord;
  PDANum:Word;

  U_Guard,U_Driver:TUserInfo;
  U_Car:TCarInfo;
implementation

{
procedure TMainFrm.Button1Click(Sender: TObject);
begin
  //dwReason ; always 0
  //dwflags ;  2 for reboot, 8 for shutdown
  //ExitWindowsEx(2, 0);
  SetSystemPowerState(nil, POWER_STATE_RESET, POWER_FORCE);
end;

procedure TMainFrm.Button2Click(Sender: TObject);
begin
  SetSystemPowerState(nil, POWER_STATE_SUSPEND, POWER_FORCE);
end;
}

procedure PlayOK();
begin
  PlaySoundW(PWideChar(UTF8Decode(ExpandFileName(Application.location + 'ok.wav')))
          , 0, SND_FILENAME or SND_ASYNC);
end;

function LoadCfgFile():boolean;
var
  inif:TIniFile;
  inifile:String;
begin
  Result:=False;
  inifile:=ExpandFileName(Application.location + 'config.ini');
  if not FileExists(inifile) then exit;
  inif:=TIniFile.Create(inifile);
  try
    PDANum:= inif.ReadInteger('PDAClient','PDANum',1);
    if (PDANum<1) then  PDANum:=1;
    if (PDANum>60000) then  PDANum:=60000;
    SvrIP:=inif.ReadString('PDAServer','IP','127.0.0.1');
    SvrPort:=inif.ReadInteger('PDAServer','Port',10008);
    HBI :=inif.ReadInteger('PDAServer','HBI',5000);
    if HBI<5 then  HBI:=5;
    if HBI>180 then  HBI:=180;
    Result:=True;
  finally
    inif.Free;
  end;
end;

procedure _CheckSvrConn();
var
  dt:TDateTime;
begin
  try
    dt:=Now();
    if Pc.GetSvrTime(dt) then
    begin
      StatusBar.Panels[1].Text:='正常';
    end
    else
    begin
      StatusBar.Panels[1].Text:='重连中...';
      application.ProcessMessages;
      if pc.ReConnPDASvr() then
         StatusBar.Panels[1].Text:='正常'
      else
         StatusBar.Panels[1].Text:='中断';
    end
  except
    ;
  end;
end;

procedure ShowErrMsg();
var
  ErrMsg:String;
begin
  ErrMsg:=GetErrCodeStr(Pc.LastErrCode);
  if Pc.LastErrCode=NormalErrCode then
     ErrMsg:=ErrMsg+Pc.NormalErr.Msg;
  ShowMessage(utf8Encode(ErrMsg));
end;

procedure _ClearDriver();
begin
  //初始化
  FillChar(U_Driver,SizeOf(TUserInfo),0);
  edtDriverIC.Clear;
  edtDriverName.Clear;
end;

procedure _QueryDriver();
begin
  //通讯，后台获取
  if not Pc.GetDriverInfo(U_Driver) then
  begin
    ShowErrMsg();
    _ClearDriver();
    exit;
  end;
  edtDriverIC.Text:=utf8EnCode(U_Driver.FullCardNum);
  edtDriverName.Text:=utf8EnCode(U_Driver.UserName);
end;

procedure _ClearCar();
begin
  //初始化
  Fillchar(U_Car,SizeOf(TCarInfo),0);
  edtCarUL.Clear;
  edtCarVIN.Clear;
  edtEngineNum.Clear;
  edtProjectNum.Clear;
end;

procedure _QueryCar();
begin
  //通讯，后台获取
  if not Pc.GetCarInfo(U_Car) then
  begin
    ShowErrMsg();
    _ClearCar();
    exit;
  end;
  edtCarUL.Text:=utf8EnCode(U_Car.RFID);
  edtCarVIN.Text:=utf8EnCode(U_Car.VIN);
  edtEngineNum.Text:=utf8EnCode(U_Car.EngineNum);
  edtProjectNum.Text:=utf8EnCode(U_Car.ProjectNum);
end;

function GetFullCardNum(Const FullCardNumHex:String;out FullCardNum:Cardinal):Boolean;
var
  Buf:array[0..3] of Byte;
  i:Integer;
begin
  FullCardNum:=0;
  Result:=False;
  try
    if Length(FullCardNumHex)<8 then Exit;
    for i:=0 to 3 do
      Buf[i]:=StrToInt('$'+Copy(FullCardNumHex,1+i*2,2));
    Move(Buf[0],FullCardNum,4);
    Result:=True;
  except
    ;
  end;
end;

function WriteLog(const fn: TFileName; const log: string): Boolean;
var
  f: TextFile;
begin
  Result := false;
  AssignFile(f, fn);
  try
    try
      if FileExists(fn) then
        Append(f)
      else
        Rewrite(f);
      Writeln(f, log);
      Result := True;
    except
      ;
    end;
  finally
    CloseFile(f);
  end;
end;

//读取保安卡
function ReaderGuardRF(var RFValue:String):Boolean;
var
  TagType:TTagType;
  UIDStr: string;
  K: Integer;
begin
  Result:=False;
  K := 0;
  while True do
  begin
    if not Init_RF_ISO14443A_Mode() then
    begin
      ShowMessage('初始化RFID失败！');
      Exit;
    end;
    try
      UIDStr:='';
      TagType:=None;
      if getRFID(TagType, UIDStr) then
         if TagType = Mifare_One_S50 then
         begin
           RFValue:= UIDStr;
           PlayOK();
           Result:=True;
           break;
         end;
      inc(k);
    finally
      Free_RF_ISO14443A_Mode();
    end;
    if k > 50 then break;
  end;
end;

Function CheckCfg():Boolean;
var
  InfoShowFrm: TInfoShowFrm;
  GuardCardNumHex:String;
  GuardCardNum:Cardinal;
begin
  Result:=False;
  InfoShowFrm:=TInfoShowFrm.Create(Application);
  try
    InfoShowFrm.Show;

    InfoShowFrm.InfoType:=IT_Info;
    InfoShowFrm.InfoStr:='正在载入配置文件...';
    InfoShowFrm.Repaint;
    if not LoadCfgFile() then
    begin
      ShowMessage('载入配置文件失败！');
      Exit;
    end;
    //建立服务器连接
    InfoShowFrm.InfoType:=IT_Info;
    InfoShowFrm.InfoStr:='正在连接服务器...';
    InfoShowFrm.Repaint;
    if not Pc.ConnPDASvr(SvrIP,SvrPort) then
    begin
       ShowMessage('无法连接服务器！');
       Exit;
    end;
    //建立本地数据库连接
    InfoShowFrm.InfoType:=IT_Info;
    InfoShowFrm.InfoStr:='正在连接本地库...';
    InfoShowFrm.Repaint;
    if not DMFrm.ReConn() then
    begin
      ShowMessage(DMFrm.LastErr);
      Exit;
    end;
    //保安登陆窗口
    InfoShowFrm.InfoType:=IT_Info;
    InfoShowFrm.InfoStr:='请刷操作员卡...';
    InfoShowFrm.Repaint;
    if not ReaderGuardRF(GuardCardNumHex) then
    begin
      Exit;
    end;
    if not GetFullCardNum(GuardCardNumHex,GuardCardNum) then
    begin
      ShowMessage('卡号数据异常！');
      Exit;
    end;
    //验证合法性
    Fillchar(U_Guard,SizeOf(TUserInfo),0);
    U_Guard.FullCardNum:=InttoStr(GuardCardNum);
    if not Pc.GetGuardInfo(U_Guard) then
    begin
      ShowErrMsg();
      Exit;
    end;
    Result:=True;
  finally
    InfoShowFrm.Free;
  end;
end;

procedure SaveLoginLog(State: integer);
begin
  DMFrm.AddLoginLog(U_Guard.UserID,State);
end;

end.

