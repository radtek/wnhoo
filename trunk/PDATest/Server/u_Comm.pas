unit u_Comm;

interface

uses Windows, Forms, Messages, ComCtrls, SysUtils, Variants, Classes, SyncObjs, IniFiles
  , UniDBC, u_OneIC, u_Mes, u_CommBag;

type
  TPDAConnInfo = record
    TID: THandle;
    IP: string;
    Port: Word;
    CreateTime: TDateTime;
    LastActiveTime: TDateTime;
  end;

procedure _AddPDAList();
procedure _RemovePDAList();
procedure _UpdatePDAList(const SubIndex: Integer; const Value: string);
procedure _AddDataList(const TID: THandle; const ClientIP, Info: string);
//检测数据库连接
procedure _CheckDBConn();
//获取帐户信息
procedure _GetUserInfo(var UI: TUserInfo; var rt: Integer; var rtStr: string);
//获取车辆信息
procedure _GetCarInfo(var CI: TCarInfo; var rt: Integer; var rtStr: string);
//保存登记记录
function _SaveInOutRec(const IOR: TInOutRec; var DataFlag, rt: Integer; var rtStr: string): Boolean;
//载入配置文件
function _LoadCfgFile(): boolean;
var
  _PI: TPDAConnInfo;
  _SBar: TStatusBar;
  _PDAList: TListView;
  _DataList: TListView;
  _CS: TCriticalSection;
  //配置文件
  _SvrName:string;
  _SvrPort: Word;
  _ActiveTimeOut: Word;
  _CheckDBTimeOut: Word;
  //OneIC Conn
  OneIC_ConnCfg: TConnCfg;
  OneIC_DBC: TOneICDBCtl;
  OneIC_CS: TCriticalSection;
  //MES Conn
  MES_ConnCfg: TConnCfg;
  MES_DBC: TMESDBCtl;
  MES_CS: TCriticalSection;
implementation

function _LoadCfgFile(): boolean;
var
  inif: TIniFile;
  inifile: string;
begin
  Result := False;
  inifile := ExtractFilePath(Application.ExeName) + 'PDAServer.ini';
  if not FileExists(inifile) then exit;
  inif := TIniFile.Create(inifile);
  try
    _SvrName:= inif.ReadString('PDAServer', 'SvrName', '');
    _SvrPort := inif.ReadInteger('PDAServer', 'SvrPort', 10008);
    _ActiveTimeOut := inif.ReadInteger('PDAServer', 'ActiveTimeOut', 200);
    if _ActiveTimeOut < 200 then _ActiveTimeOut := 200;
    if _ActiveTimeOut > 600 then _ActiveTimeOut := 600;
    _CheckDBTimeOut := inif.ReadInteger('PDAServer', 'CheckDBTimeOut', 60);
    if _CheckDBTimeOut < 60 then _CheckDBTimeOut := 60;
    if _CheckDBTimeOut > 600 then _CheckDBTimeOut := 600;
    //OneIC Conn
    OneIC_ConnCfg.ProviderName := inif.ReadString('OneIC', 'ProviderName', 'SQL Server');
    OneIC_ConnCfg.IsDirect := inif.ReadBool('OneIC', 'IsDirect', false);
    OneIC_ConnCfg.Server := inif.ReadString('OneIC', 'Server', '');
    OneIC_ConnCfg.Port := inif.ReadInteger('OneIC', 'Port', 0);
    OneIC_ConnCfg.Database := inif.ReadString('OneIC', 'Database', '');
    OneIC_ConnCfg.Username := inif.ReadString('OneIC', 'UID', '');
    OneIC_ConnCfg.Password := inif.ReadString('OneIC', 'PWD', '');
    //MES Conn
    MES_ConnCfg.ProviderName := inif.ReadString('MES', 'ProviderName', 'Oracle');
    MES_ConnCfg.IsDirect := inif.ReadBool('MES', 'IsDirect', false);
    MES_ConnCfg.Server := inif.ReadString('MES', 'Server', '');
    MES_ConnCfg.Port := inif.ReadInteger('MES', 'Port', 0);
    MES_ConnCfg.Database := inif.ReadString('MES', 'Database', '');
    MES_ConnCfg.Username := inif.ReadString('MES', 'UID', '');
    MES_ConnCfg.Password := inif.ReadString('MES', 'PWD', '');

    Result := True;
  finally
    inif.Free;
  end;
end;

procedure _UpdatePDAList(const SubIndex: Integer; const Value: string);
var
  Item: TListItem;
  i: Integer;
begin
  try
    for I := _PDAList.Items.Count - 1 downto 0 do
    begin
      Item := _PDAList.Items[i];
      if (IntToStr(_PI.TID) = Trim(Item.Caption)) and (_PI.IP = Item.SubItems[0]) then
        Item.SubItems[SubIndex] := Value;
    end;
  except
    ;
  end;
end;

procedure _AddPDAList();
var
  Item: TListItem;
begin
  Item := _PDAList.Items.Add;
  Item.Caption := IntToStr(_PI.TID);
  Item.SubItems.Add(_PI.IP);
  Item.SubItems.Add(IntToStr(_PI.Port));
  Item.SubItems.Add(FormatDateTime('YYYY-MM-DD hh:nn:ss', _PI.CreateTime));
  Item.SubItems.Add(FormatDateTime('YYYY-MM-DD hh:nn:ss', _PI.LastActiveTime));
end;

procedure _AddDataList(const TID: THandle; const ClientIP, Info: string);
var
  Item: TListItem;
begin
  Item := _DataList.Items.Insert(0);
  Item.Caption :=FormatDateTime('YYYY-MM-DD hh:nn:ss', Now) ;
  Item.SubItems.Add(IntToStr(TID));
  Item.SubItems.Add(ClientIP);
  Item.SubItems.Add(Info);
  if _DataList.Items.Count > 50 then
    _DataList.Items.Delete(50);
end;

procedure _RemovePDAList();
var
  Item: TListItem;
  i: Integer;
begin
  for I := _PDAList.Items.Count - 1 downto 0 do
  begin
    Item := _PDAList.Items[i];
    if (IntToStr(_PI.TID) = Trim(Item.Caption)) and (_PI.IP = Item.SubItems[0]) then
      Item.Delete;
  end;
end;

procedure _CheckDBConn();
var
  dt: TDateTime;
begin
  OneIC_CS.Enter;
  try
    if not OneIC_DBC.GetSvrDateTime(dt) then
    begin
      _SBar.Panels[5].Text := '重连中...';
      Application.ProcessMessages;
      OneIC_DBC.ReConnDB;
    end;
    if OneIC_DBC.IsConn then
      _SBar.Panels[5].Text := '正常'
    else
      _SBar.Panels[5].Text := '断开';
  finally
    OneIC_CS.Leave;
  end;
  MES_CS.Enter;
  try
    if not MES_DBC.GetSvrDateTime(dt) then
    begin
      _SBar.Panels[7].Text := '重连中...';
      Application.ProcessMessages;
      MES_DBC.ReConnDB;
    end;
    if MES_DBC.IsConn then
      _SBar.Panels[7].Text := '正常'
    else
      _SBar.Panels[7].Text := '断开';
  finally
    MES_CS.Leave;
  end;
end;

procedure _GetUserInfo(var UI: TUserInfo; var rt: Integer; var rtStr: string);
begin
  OneIC_CS.Enter;
  try
    rt := OneIC_DBC.GetUserInfo(UI);
    rtStr := OneIC_DBC.GetRtInfo(rt);
  finally
    OneIC_CS.Leave;
  end;
end;

procedure _GetCarInfo(var CI: TCarInfo; var rt: Integer; var rtStr: string);
begin
  MES_CS.Enter;
  try
    rt := MES_DBC.GetCarInfo(CI);
    rtStr := MES_DBC.GetRtInfo(rt);
  finally
    MES_CS.Leave;
  end;
end;

function _SaveInOutRec(const IOR: TInOutRec; var DataFlag, rt: Integer; var rtStr: string): Boolean;
var
  PI: TPDAInfo;
begin
  Result := False;
  DataFlag := 0;

  OneIC_CS.Enter;
  try
    //如果找不到此PDA，那么提示未授权PDA设备
    FillChar(PI, SizeOf(TPDAInfo), 0);
    PI.PDANum := IOR.PDANum;
    PI.PDAName := '---';
    rt := OneIC_DBC.GetPDAInfo(PI);
    rtStr := OneIC_DBC.GetRtInfo(rt);
    if rt > 0 then
    begin
      //检测PDA与驾驶员关联
      rt := OneIC_DBC.UserAndMachIsLink(IOR.Driver.UserID, PI.MachID);
      rtStr := OneIC_DBC.GetRtInfo(rt);
      if rt > 0 then
        DataFlag := 1
      else
        DataFlag := -2; //未关联PDA
    end
    else
      DataFlag := -1; //未授权PDA
  finally
    OneIC_CS.Leave;
  end;
  //////////////////////////////////////////////////////////////
  MES_CS.Enter;
  try
    if DataFlag > 0 then
    begin
      rt := MES_DBC.SaveInOutRec(IOR, PI.PDAName, DataFlag);
      rtStr := MES_DBC.GetRtInfo(rt);
      Result := True;
    end
    else
    begin
      //异常记录，不提示是否成功!
      MES_DBC.SaveInOutRec(IOR, PI.PDAName, DataFlag);
    end;
  finally
    MES_CS.Leave;
  end;
end;

end.

