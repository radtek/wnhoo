unit TCPSVR_Unit;

interface

uses
  Windows, Messages, ComCtrls, SysUtils, Variants, Classes, WinSock, ProClientThread_Unit,
  Socket_Unit, u_Comm;

type
  TServerThread = class(TThread)
  private
    FServer: TSocket;
    procedure ProDataFunc(const SVRHandle: Integer); stdcall;
    procedure ClientTerminate(Sender: TObject);
    procedure AddPDAList;
    procedure RemovePDAList;
    procedure CheckDBConn;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean; SERVER_PORT: Integer);
    destructor Destroy; override;
  end;


implementation

constructor TServerThread.Create(CreateSuspended: Boolean; SERVER_PORT: Integer);
begin
  inherited Create(CreateSuspended);
  //这儿如果抛出异常,那么将无法显示,程序卡住。
  FServer := StartServerForTCP(SERVER_PORT);
  if FServer > 0 then
    SetSocket_SR_Param(FServer, Send_TO, Recv_TO);
end;

destructor TServerThread.Destroy;
begin
  //关闭Socket
  if FServer > 0 then
    StopServer(FServer);
  inherited;
end;

procedure TServerThread.ProDataFunc(const SVRHandle: Integer);
var
  ClientSocket: TSocket;
  Ra: sockaddr_in;
  RaLen: Integer;
  cIP: PChar;
  PC: TProClientThread;
begin
  RaLen := SizeOf(Ra);
  ClientSocket := accept(SVRHandle, @Ra, @RaLen);
  if ClientSocket = INVALID_SOCKET then Exit;
  cIP := inet_ntoa(Ra.sin_addr);

  Pc := TProClientThread.Create(true);
  Pc.ClientSocket := ClientSocket;
  Pc.ClientIP := cIP;
  Pc.OnTerminate := ClientTerminate;
  //UI状态更新，增加TID
  _CS.Enter;
  try
    _PI.TID := Pc.ThreadID;
    _PI.IP := cIP;
    _PI.Port := Ra.sin_port;
    _PI.CreateTime := Now();
    _PI.LastActiveTime := _PI.CreateTime;
    Synchronize(AddPDAList);
  finally
    _CS.Leave;
  end;
  Pc.Resume;
end;

procedure TServerThread.AddPDAList();
begin
  _AddPDAList();
end;

procedure TServerThread.RemovePDAList();
begin
  _RemovePDAList();
end;

procedure TServerThread.ClientTerminate(Sender: TObject);
var
  Pc: TProClientThread;
begin
  if sender is TProClientThread then
  begin
    Pc := (sender as TProClientThread);
    _CS.Enter;
    try
      _PI.TID := pc.ThreadID;
      _PI.IP := Pc.ClientIP;
      Synchronize(RemovePDAList);
    finally
      _CS.Leave;
    end;
  end;
end;

procedure TServerThread.Execute;
var
  T1: DWORD;
begin
  T1 := GetTickCount;
  while not Terminated do
  begin
    try
      acceptClient(FServer, ProDataFunc);
      //检测数据库连接(秒)
      if ((GetTickCount - T1) div 1000) > _CheckDBTimeOut then
      begin
        Synchronize(CheckDBConn);
        T1 := GetTickCount;
      end;
    except
      ;
    end;
    Sleep(100);
  end;
end;

procedure TServerThread.CheckDBConn();
begin
  _CheckDBConn();
end;
end.

