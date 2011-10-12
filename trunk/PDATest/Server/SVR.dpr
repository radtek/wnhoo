library SVR;

uses
  Windows, SysUtils, WinSock;

{$R *.res}
const
  PacketLen = 8192;
type
  TBusinessFunc = function(const cIP: PChar; const Port: Word; const InData: Pchar; var OutData: Pchar): Boolean of object; stdcall;
  TProDataFunc = procedure(const SVRHandle: Integer) of object; stdcall;
var
  WSAData: TWSAData;

procedure Startup; stdcall;
var
  ErrorCode: Integer;
begin
  ErrorCode := WSAStartup($0101, WSAData);
  if ErrorCode <> 0 then
    raise Exception.Create('WSAStartup Fail!');
end;

procedure Cleanup; stdcall;
var
  ErrorCode: Integer;
begin
  ErrorCode := WSACleanup;
  if ErrorCode <> 0 then
    raise Exception.Create('WSACleanup Fail!');
end;

//����Socket����(�����뷢�ͳ�ʱ������)

function SetSocket_SR_Param(const SVRHandle: Integer; const Send_TO, Recv_TO: LongInt): Boolean; stdcall;
const
  TCPBUFLEN = 8192;
var
  timeout: longint;
  bufLen: longint;
  Len: integer;
begin
  //���ó�ʱ
  timeout := Send_TO;
  if (setsockopt(SVRHandle, SOL_SOCKET, SO_SNDTIMEO, PChar(@timeout), sizeof(timeout)) = SOCKET_ERROR) then
  begin
    Result := False;
    Exit;
  end;
  timeout := Recv_TO;
  if (setsockopt(SVRHandle, SOL_SOCKET, SO_RCVTIMEO, PChar(@timeout), sizeof(timeout)) = SOCKET_ERROR) then
  begin
    Result := False;
    Exit;
  end;
  //ϵͳ�ṩ��socket��������СΪ8K������Խ�֮����64K�������ڴ���ʵʱ��Ƶ
  //���÷��ͺͽ��ջ���
  Len := sizeof(bufLen);
  if getsockopt(SVRHandle, SOL_SOCKET, SO_RCVBUF, PChar(@bufLen), Len) <> SOCKET_ERROR then
    if bufLen < TCPBUFLEN then
    begin
      bufLen := TCPBUFLEN;
      setsockopt(SVRHandle, SOL_SOCKET, SO_RCVBUF, PChar(@bufLen), Len);
    end;

  if getsockopt(SVRHandle, SOL_SOCKET, SO_SNDBUF, PChar(@bufLen), Len) <> SOCKET_ERROR then
    if (bufLen < TCPBUFLEN) then
    begin
      bufLen := TCPBUFLEN;
      setsockopt(SVRHandle, SOL_SOCKET, SO_SNDBUF, PChar(@bufLen), Len);
    end;
  Result := True;
end;


function StartServer(const SERVER_PORT: Integer; const Struct, Protocol: Integer): Integer; stdcall;
var
  SADDR: sockaddr_in;
  FServer: TSocket;
begin
  //����Socket
  FServer := socket(PF_INET, Struct, Protocol);
  if FServer = INVALID_Socket then raise Exception.Create('����Socketʧ��!');
  //���������Socket
  SADDR.sin_family := PF_INET;
  SADDR.sin_port := htons(SERVER_PORT);
  SADDR.sin_addr.S_addr := INADDR_ANY;
  if bind(FServer, SADDR, SizeOf(SADDR)) = Socket_ERROR then
    raise Exception.Create('�˿ڰ�ʧ��,������˿�!');
  //��ʼ����
  Listen(FServer, 5);
  Result := FServer;
end;

function StartServerForTCP(const SERVER_PORT: Integer): Integer; stdcall;
begin
  Result := StartServer(SERVER_PORT, SOCK_STREAM, IPPROTO_TCP);
end;

function StartServerForUDP(const SERVER_PORT: Integer): Integer; stdcall;
begin
  Result := StartServer(SERVER_PORT, SOCK_DGRAM, IPPROTO_UDP);
end;

function StopServer(const SVRHandle: Integer): Integer; stdcall;
begin
  shutdown(SVRHandle, SD_BOTH);
  Result := closesocket(SVRHandle);
  if Result = Socket_ERROR then
    raise Exception.Create('�����Socket�ر�ʧ��!');
end;

//�����豸

function ConnNetDev(const ip: PChar; const port: integer): longint; stdcall;
var
  c_tcp: longint;
  saddr: sockaddr_in;
begin
  Result := SOCKET_ERROR;
  c_tcp := Socket(AF_INET, SOCK_STREAM, 0);
  if c_tcp = SOCKET_ERROR then
    exit;
  fillchar(saddr, sizeof(saddr), 0);
  saddr.sin_family := AF_INET;
  saddr.sin_port := htons(port);
  saddr.sin_addr.s_addr := inet_addr(ip);
  if connect(c_tcp, saddr, sizeof(saddr)) = SOCKET_ERROR then
    exit;
  Result := c_tcp;
end;

function ConnNetDevBindIP(const ip: PChar; const port: integer; const LocalIP: PChar): longint; stdcall;
var
  c_tcp: longint;
  saddr, caddr: sockaddr_in;
begin
  Result := SOCKET_ERROR;
  c_tcp := Socket(AF_INET, SOCK_STREAM, 0);
  if c_tcp = SOCKET_ERROR then
    exit;
  //Bind IP
  fillchar(caddr, sizeof(caddr), 0);
  caddr.sin_family := AF_INET;
  caddr.sin_port := 0;
  caddr.sin_addr.S_addr := inet_addr(LocalIP);
  if bind(c_tcp, caddr, SizeOf(caddr)) = Socket_ERROR then
    raise Exception.Create('�󶨱���IPʧ��!');
  //Connect
  fillchar(saddr, sizeof(saddr), 0);
  saddr.sin_family := AF_INET;
  saddr.sin_port := htons(port);
  saddr.sin_addr.s_addr := inet_addr(ip);
  if connect(c_tcp, saddr, sizeof(saddr)) = SOCKET_ERROR then
    exit;
  Result := c_tcp;
end;

//�ر��豸����

function CloseNetDev(s: longint): longint; stdcall;
begin
  shutdown(s, SD_BOTH);
  Result := CloseSocket(s);
end;

//��������

function SendData(s: Longint; var Buf; BufLen, Flags: Longint): Longint; stdcall;
begin
  Result := Send(s, Buf, BufLen, Flags);
end;

//��������

function RecvData(s: Longint; var Buf; BufLen, Flags: Longint): Longint; stdcall;
begin
  Result := recv(s, Buf, BufLen, Flags);
end;

////////////////////////////////////////////////////////////////////////////////


procedure acceptClient(const SVRHandle: Integer; ProDataFunc: TProDataFunc); stdcall;
var
  fd_read: TFDSet;
  timeout: TTimeVal;
  i: Integer;
begin
  FD_ZERO(fd_read);
  FD_SET(SVRHandle, fd_read);
  timeout.tv_sec := 0;
  timeout.tv_usec := 500;
  if select(0, @fd_read, nil, nil, @timeout) > 0 then //������1���ȴ�Accept��connection
  begin
    if FD_ISSET(SVRHandle, fd_read) then
    begin
      for i := 0 to fd_read.fd_count - 1 do
      begin
        if Assigned(ProDataFunc) then
          ProDataFunc(SVRHandle);
      end;
    end;
  end;
end;


procedure acceptClientForTCP(const SVRHandle: Integer; BusinessFunc: TBusinessFunc); stdcall;
var
  fd_read: TFDSet;
  timeout: TTimeVal;
  i: Integer;
  ClientSocket: TSocket;
  Ra: sockaddr_in;
  RaLen: Integer;
  ///////////////////
  RecvPacketBuf, SendPacketBuf: Pchar;
  RecvLen: Integer;
begin
  GetMem(RecvPacketBuf, PacketLen);
  GetMem(SendPacketBuf, PacketLen);
  try
    FD_ZERO(fd_read);
    FD_SET(SVRHandle, fd_read);
    timeout.tv_sec := 0;
    timeout.tv_usec := 500;
    if select(0, @fd_read, nil, nil, @timeout) > 0 then //������1���ȴ�Accept��connection
    begin
      if FD_ISSET(SVRHandle, fd_read) then
      begin
        for i := 0 to fd_read.fd_count - 1 do
        begin
          RaLen := SizeOf(Ra);
          ClientSocket := accept(SVRHandle, @Ra, @RaLen);
          if ClientSocket <> INVALID_SOCKET then
          begin
            ZeroMemory(RecvPacketBuf, PacketLen);
            ZeroMemory(SendPacketBuf, PacketLen);
            try
              RecvLen := recv(ClientSocket, RecvPacketBuf^, PacketLen, 0);
              if RecvLen > 0 then
                if Assigned(BusinessFunc) then
                  if BusinessFunc(PChar(inet_ntoa(Ra.sin_addr)), 0, RecvPacketBuf, SendPacketBuf) then
                    Send(ClientSocket, SendPacketBuf^, StrLen(SendPacketBuf), 0);
            finally
              shutdown(ClientSocket, SD_BOTH);
              CloseSocket(ClientSocket);
            end;
          end;
        end;
      end;
    end;
  finally
    FreeMem(SendPacketBuf);
    FreeMem(RecvPacketBuf);
  end;
end;

procedure acceptClientForUDP(const SVRHandle: Integer; BusinessFunc: TBusinessFunc); stdcall;
var
  fd_read: TFDSet;
  timeout: TTimeVal;
  i: Integer;
  ////////////////////
  RecvPacketBuf, SendPacketBuf: Pchar;
  RecvLen: Integer;
  Sa: TSockAddr;
  SaLen: Integer;
begin
  GetMem(RecvPacketBuf, PacketLen);
  GetMem(SendPacketBuf, PacketLen);
  try
    FD_ZERO(fd_read);
    FD_SET(SVRHandle, fd_read);
    timeout.tv_sec := 0;
    timeout.tv_usec := 500;
    if select(0, @fd_read, nil, nil, @timeout) > 0 then //������1���ȴ�Accept��connection
    begin
      if FD_ISSET(SVRHandle, fd_read) then
      begin
        for i := 0 to fd_read.fd_count - 1 do
        begin
          ZeroMemory(RecvPacketBuf, PacketLen);
          ZeroMemory(SendPacketBuf, PacketLen);
          SaLen := SizeOf(Sa);
          RecvLen := recvfrom(SVRHandle, RecvPacketBuf^, PacketLen, 0, Sa, SaLen);
          if RecvLen > 0 then
            if Assigned(BusinessFunc) then
              if BusinessFunc(inet_ntoa(Sa.sin_addr), ntohs(Sa.sin_port), RecvPacketBuf, SendPacketBuf) then
                sendto(SVRHandle, SendPacketBuf^, StrLen(SendPacketBuf), 0, Sa, SaLen);
        end;
      end;
    end;
  finally
    FreeMem(SendPacketBuf);
    FreeMem(RecvPacketBuf);
  end;
end;


function GetLocalIP(const SVRHandle: Integer; var IP: PChar; var Port: Word): Boolean; stdcall;
var
  SockAddrIn: TSockAddrIn;
  Size: integer;
begin
  Result := False;
  Size := sizeof(SockAddrIn);
  if getsockname(SVRHandle, SockAddrIn, Size) = 0 then
  begin
    IP := inet_ntoa(SockAddrIn.sin_addr);
    Port := ntohs(SockAddrIn.sin_port);
    Result := True;
  end;
end;

function GetRemoteIP(const CHandle: Integer; var IP: PChar; var Port: Word): Boolean; stdcall;
var
  SockAddrIn: TSockAddrIn;
  Size: Integer;
begin
  Result := False;
  Size := sizeof(SockAddrIn);
  if getpeername(CHandle, SockAddrIn, Size) = 0 then
  begin
    IP := inet_ntoa(SockAddrIn.sin_addr);
    Port := ntohs(SockAddrIn.sin_port);
    Result := True;
  end;
end;

exports
  Startup, Cleanup, StartServerForTCP, StartServerForUDP, StopServer, SetSocket_SR_Param,
  ConnNetDev,ConnNetDevBindIP, CloseNetDev, SendData, RecvData,
  acceptClient, acceptClientForTCP, acceptClientForUDP, GetLocalIP, GetRemoteIP;

begin

end.

