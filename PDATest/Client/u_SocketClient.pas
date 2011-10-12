unit u_SocketClient;

{$MODE objfpc}{$H+}

interface

uses
  SysUtils, Socket_Unit, u_CommBag ,SyncObjs;

{ TPDAClient }
type
  TPDAClient = class
  private
    FRecvBuf: TByteArray;
    FBufMaxLen: integer;
    FClient: longint;
    FSvrIP:String;
    FSvrPort:Word;
    FCS: TCriticalSection;
    FLastErrCode:Integer;
    FNormalErr:TErrorInfo;
    FOrdNum:Byte;
    function _SendAndRecvCB(const OrdNum,CMD: byte; const Data; const DataLen: word;var RecvCB:TCommBag): boolean;
    function _GetSvr(const CMD: byte; var Data; const DataLen: word): boolean;
    function GetSvr(const CMD: byte; var Data; const DataLen: word): boolean;
    function _ReConnPDASvr(): boolean;
  public
    constructor Create;
    destructor Destroy;override;
    function ConnPDASvr(const ip: string; const port: integer): boolean;
    function ReConnPDASvr(): boolean;
    procedure DisConn();
    function GetSvrTime(var dt: TDateTime): boolean;
    function GetDriverInfo(var Driver: TUserInfo): boolean;
    function GetGuardInfo(var Guard: TUserInfo): boolean;
    function GetCarInfo(var Car: TCarInfo): boolean;
    function SaveInOutRec(var IOR: TInOutRec): boolean;
    property LastErrCode:Integer read FLastErrCode;
    property NormalErr:TErrorInfo read FNormalErr;
  end;

implementation

constructor TPDAClient.Create;
begin
  inherited;
  FOrdNum:=0;
  FCS:= TCriticalSection.Create;
end;

destructor TPDAClient.Destroy;
begin
  FCS.Free;
  inherited Destroy;
end;

function TPDAClient.ConnPDASvr(const ip: string; const port: integer): boolean;
begin
  FBufMaxLen := SizeOf(TByteArray);
  FillChar(FRecvBuf, FBufMaxLen, 0);
  FSvrIP:=ip;
  FSvrPort:=port;
  Result := ReConnPDASvr();
end;

function TPDAClient._ReConnPDASvr(): boolean;
begin
  Result:=False;
  try
    if Trim(FSvrIP)='' then   exit;
    if FClient > 0 then
       CloseNetDev(FClient);
    FClient := ConnNetDev(PChar(FSvrIP), FSvrPort);
    //CE Not Support
    if FClient > 0 then
       SetSocket_SR_Param(FClient, Send_TO, Recv_TO);
    Result := (FClient > 0);
  except
    ;
  end;
end;



function TPDAClient._SendAndRecvCB(const OrdNum,CMD: byte; const Data; const DataLen: word;var RecvCB:TCommBag): boolean;
var
  CB: TCommBag;
  readLen,rt: integer;
begin
  Result := False;
  CB := GetCommBag(OrdNum,CMD, Data, DataLen);
  rt := SendBag(FClient, CB);
  if rt <= 0 then
  begin
      FLastErrCode:=rt;
      exit;
  end;
  rt := SelectRecvData(FClient, FRecvBuf, FBufMaxLen);
  if rt <= 0 then
  begin
      FLastErrCode:=rt;
      exit;
  end;
  readLen:=rt;
  if not ParseCommBag(@FRecvBuf, readLen, RecvCB) then
  begin
      FLastErrCode:=-100; //数据包解析错误
      exit;
  end;
  Result:=True;
end;

function TPDAClient._GetSvr(const CMD: byte; var Data; const DataLen: word): boolean;
var
  RecvCB: TCommBag;
begin
  Result := False;
  try
    FLastErrCode:=0;
    FillChar(FNormalErr,SizeOf(TErrorInfo),0);
    Inc(FOrdNum);
    if not _SendAndRecvCB(FOrdNum,CMD, Data, DataLen,RecvCB) then exit;
    if RecvCB.OrdNum<>FOrdNum then
    begin
        FLastErrCode:=-103;//通讯序号不一致！
        Exit;
    end;
    if RecvCB.CMD<>CMD then
    begin
      case RecvCB.CMD of
        CMD_Error:begin
          Move(RecvCB.Data^, FNormalErr, RecvCB.DataLen);
          FLastErrCode:=-1000; //服务器提示
          end;
        else begin
          FLastErrCode:=-101; //异常返回指令
        end;
      end;
      Exit;
    end;

    //对数据包Data与Rec大小比较
    if DataLen<>RecvCB.DataLen then
    begin
      FLastErrCode:=-102; //返回的数据包长度异常
      Exit;
    end;

    Move(RecvCB.Data^, Data, RecvCB.DataLen);
    Result := True;
  finally
    if Assigned(RecvCB.Data) then
      FreeMem(RecvCB.Data,RecvCB.DataLen);
  end;
end;

function TPDAClient.ReConnPDASvr(): boolean;
begin
  FCS.Enter;
  try
    Result:=_ReConnPDASvr();
  finally
    FCS.Leave;;
  end;
end;

procedure TPDAClient.DisConn();
begin
  FCS.Enter;
  try
    CloseNetDev(FClient);
  finally
    FCS.Leave;;
  end;
end;

function TPDAClient.GetSvr(const CMD: byte; var Data; const DataLen: word): boolean;
begin
  FCS.Enter;
  try
    Result:=_GetSvr(CMD,Data,DataLen);
  finally
    FCS.Leave;;
  end;
end;

function TPDAClient.GetSvrTime(var dt: TDateTime): boolean;
begin
  Result := GetSvr(CMD_SvrTime,dt,sizeof(TDateTime));
end;

function TPDAClient.GetDriverInfo(var Driver: TUserInfo): boolean;
begin
  Driver.UserType:=UT_Driver;
  Result := GetSvr(CMD_User,Driver,sizeof(TUserInfo));
end;

function TPDAClient.GetGuardInfo(var Guard: TUserInfo): boolean;
begin
  Guard.UserType:=UT_Guard;
  Result := GetSvr(CMD_User,Guard,sizeof(TUserInfo));
end;

function TPDAClient.GetCarInfo(var Car: TCarInfo): boolean;
begin
  Result := GetSvr(CMD_Car,Car,sizeof(TCarInfo));
end;

function TPDAClient.SaveInOutRec(var IOR: TInOutRec): boolean;
begin
  Result := GetSvr(CMD_InOutRec,IOR,sizeof(TInOutRec));
end;

end.

