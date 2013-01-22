unit Socket_Unit;

interface

uses
  Sockets,SysUtils;

const
  SVRDLL = 'SVR.DLL';
  Send_TO = 30000;
  Recv_TO = 30000;

type
  TBusinessFunc = function(const cIP: PChar; const Port: Word; const InData: Pchar; var OutData: Pchar): Boolean of object; stdcall;
  TProDataFunc = procedure(const SVRHandle: Integer) of object; stdcall;

procedure Startup; stdcall; External SVRDLL;
procedure Cleanup; stdcall; External SVRDLL;
function SetSocket_SR_Param(const SVRHandle: Integer; const Send_TO, Recv_TO: LongInt): Boolean; stdcall; External SVRDLL;
function StartServerForTCP(const SERVER_PORT: Integer): Integer; stdcall; External SVRDLL;
function StartServerForUDP(const SERVER_PORT: Integer): Integer; stdcall; External SVRDLL;
function StopServer(const SVRHandle: Integer): Integer; stdcall; External SVRDLL;
////////////////////////////////////////////////////////////////////////////////
function ConnNetDev(const ip: PChar; const port: integer): longint; stdcall; External SVRDLL;
function ConnNetDevBindIP(const ip: PChar; const port: integer; const LocalIP: PChar): longint; stdcall; External SVRDLL;
function CloseNetDev(s: longint): longint; stdcall; External SVRDLL;
function SendData(s: Longint; var Buf; BufLen, Flags: Longint): Longint; stdcall; External SVRDLL;
function RecvData(s: Longint; var Buf; BufLen, Flags: Longint): Longint; stdcall; External SVRDLL;
////////////////////////////////////////////////////////////////////////////////
procedure acceptClient(const SVRHandle: Integer; ProDataFunc: TProDataFunc); stdcall; External SVRDLL;
procedure acceptClientForTCP(const SVRHandle: Integer; BusinessFunc: TBusinessFunc); stdcall; External SVRDLL;
procedure acceptClientForUDP(const SVRHandle: Integer; BusinessFunc: TBusinessFunc); stdcall; External SVRDLL;
function GetLocalIP(const SVRHandle: Integer; var IP: PChar; var Port: Word): Boolean; stdcall; External SVRDLL;
function GetRemoteIP(const CHandle: Integer; var IP: PChar; var Port: Word): Boolean; stdcall; External SVRDLL;

implementation

initialization
  Startup;

finalization
  Cleanup;

end.

