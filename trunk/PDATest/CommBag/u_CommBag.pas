unit u_CommBag;

interface

uses
  SysUtils, WinSock, Socket_Unit;

const
  CMD_None = 0;
  CMD_SvrTime = 1;
  CMD_User = 2;
  CMD_Car=3;
  CMD_InOutRec = 4;
  CMD_Error = 100;
  Boot0 = $FA;
  Boot1 = $FB;
  Boot2 = $FC;
  UT_Guard =1;
  UT_Driver =2;

  NormalErrCode=-1000;
  //最小包长，除了数据区
  CommBagMinLen=(3+1+1+2+4);

type
  TErrorInfo=packed record
    ErrorCode:Integer;
    Msg:String[50];
  end;

  TUserInfo = packed record
    CardID, UserID: integer;
    UserNo, UserName: string[20];
    FullCardNum: string[20];
    UserType:Byte;{1 Guard 2 Driver}
    TargetPlace:string[50];
  end;

  TPDAInfo=packed record
    MachID:Integer;
    PDANum:Word;
    PDAName:string[50];
  end;

  TCarInfo = packed record
    VIN, RFID: string[20];
    EngineNum,
    ProjectNum: string[50];
  end;

  TInOutRec = packed record
    PDANum: Word;
    Driver: TUserInfo;
    Car: TCarInfo;
    Guard: TUserInfo;
    DirectionFlag:Byte;//方向标志
    RecTime: TDateTime;
  end;

  TCommBag = packed record
    Boot: array[0..2] of byte;
    OrdNum: byte; //序号
    CMD: byte;
    DataLen: word;
    Data: PByte;
    CRC: longword;
  end;

function GetBufStr(const buf; const b,e: Integer): string;
function GetBufCRC(const buf; const b,e: Integer):LongWord;

function ParseCommBag(const PBuf: PByteArray; const BufLen: integer;
  var CB: TCommBag): boolean;
function GetCommBag(const OrdNum,CMD: byte; const Data; const DataLen: word): TCommBag;
function SendBag(s: longint; var CB: TCommBag): longint;
function SelectSendData(s: longint; var Buf; BufLen: longint): longint;
function SelectRecvData(s: longint; var Buf; BufLen: longint): longint;
function GetErrCodeStr(const Code:Integer):String;

implementation

function GetBufStr(const buf; const b,e: Integer): string;
var
  i: integer;
  pc:PChar;
begin
  Result := '';
  pc:=@Buf;
  for i := b to e do
    Result := Result + InttoHex(Byte(pc[i]), 2) + ' ';
end;

function GetBufCRC(const buf; const b,e: Integer):LongWord;
var
  i: integer;
  pc:PChar;
begin
  Result := 0;
  pc:=@Buf;
  for i := b to e do
    Result := Result + Byte(pc[i]);
end;

function ParseCommBag(const PBuf: PByteArray; const BufLen: integer;
  var CB: TCommBag): boolean;
var
  CRC: longword;
begin
  Result := False;
  if BufLen < CommBagMinLen then
  begin
    Exit;
  end;
  FillChar(CB, SizeOf(TCommBag), 0);
  //boot
  Move(PBuf^[0], CB.Boot[0], 3);
  if not ((CB.Boot[0] = Boot0) and (CB.Boot[1] = Boot1) and (CB.Boot[2] = Boot2)) then
    Exit;
  //OrdNum
  CB.OrdNum := PBuf^[3];
  //cmd
  CB.CMD := PBuf^[4];
  //DataLen
  Move(PBuf^[5], CB.DataLen, 2);
  if BufLen <> CommBagMinLen + CB.DataLen then
    Exit;
  //Data
  CB.Data := AllocMem(CB.DataLen);
  Move(PBuf^[7], CB.Data^, CB.DataLen);
  //CRC
  Move(PBuf^[7 + CB.DataLen], CB.CRC, 4);
  //检测CRC ,不含自身
  CRC := GetBufCRC(PBuf^,0,BufLen - (1 + 4));
  if CRC <> CB.CRC then
    Exit;
  Result := True;
end;

function GetCommBag(const OrdNum,CMD: byte; const Data; const DataLen: word): TCommBag;
begin
  Result.Boot[0] := Boot0;
  Result.Boot[1] := Boot1;
  Result.Boot[2] := Boot2;
  Result.OrdNum := OrdNum;
  Result.CMD := CMD;
  Result.DataLen := DataLen;
  //Data
  Result.Data := AllocMem(Result.DataLen);
  if Result.DataLen > 0 then
    Move(Data, Result.Data^, Result.DataLen);
  Result.CRC:=0;//发送时候自动计算
  {
  //=======================Bug纪念============================
  //CRC,不含自身
  CRC:= 0;
  for i := Low(Result.Boot) to High(Result.Boot) do
    CRC := CRC + Result.Boot[i];
  //此处出现Bug,CRC按字节累计，那么Result.DataLen 就是一个2Byte整数，不能直接累加！
  CRC := CRC + Result.OrdNum + Result.CMD + Result.DataLen;
  //Add Data Crc
  P := Result.Data;
  for i := 0 to DataLen - 1 do
  begin
    CRC := CRC + P^;
    Inc(P);
  end;
  Result.CRC:=CRC;
  }
end;

function SendBag(s: longint; var CB: TCommBag): longint;
var
  SendBuf: PChar;
  SendLen: integer;
begin
  SendLen := CommBagMinLen + CB.DataLen;
  SendBuf := AllocMem(SendLen);
  try
    //boot
    Move(CB.Boot[0], SendBuf[0], 3);
    //OrdNum
    SendBuf[3] := char(CB.OrdNum);
    //cmd
    SendBuf[4] := char(CB.CMD);
    //DataLen
    Move(CB.DataLen, SendBuf[5], 2);
    //Data
    Move(CB.Data^, SendBuf[7], CB.DataLen);
    //Free Data
    FreeMem(CB.Data, CB.DataLen);
    //计算CRC ,不含自身
    CB.CRC := GetBufCRC(SendBuf^,0,SendLen - (1 + 4));
    //CRC
    Move(CB.CRC, SendBuf[7 + CB.DataLen], 4);
    //Result
    Result := SelectSendData(s, SendBuf^, SendLen);
  finally
    FreeMem(SendBuf, SendLen);
  end;
end;

function SelectRecvData(s: longint; var Buf; BufLen: longint): longint;
var
  fds: TFDSet;
  timeout: TTimeVal;
  rt: longint;
begin
  timeout.tv_sec := Recv_TO div 1000;
  timeout.tv_usec := 0;
  FD_ZERO(fds);
  FD_SET(s, fds);

  rt := select(s+1, @fds, nil, nil, @timeout);
  //-1 失败 0 超时 (服务器断开也会超时)
  if rt <=0 then
  begin
    if rt<0 then
       Result:=-1
     else
       Result:=-2;
    Exit;
  end;
  //检测fdset中文件fd有无发生变化
  //connect()失败，进行错处理
  if (not FD_ISSET(s, fds)) then
  begin
    Result := -3;
    exit;
  end;
  //超时接收也是-1
  rt := recv(s, buf, BufLen, 0);
  if rt<=0 then
  begin
    Result := -10;
    exit;
  end;
  Result:=rt;
end;

function SelectSendData(s: longint; var Buf; BufLen: longint): longint;
var
  fds: TFDSet;
  timeout: TTimeVal;
  rt: longint;
begin
  timeout.tv_sec := Send_TO div 1000;
  timeout.tv_usec := 0;
  FD_ZERO(fds);
  FD_SET(s, fds);

  rt := select(s+1, nil, @fds, nil, @timeout);
  //-1 失败 0 超时 (服务器断开也会超时)
  if rt <=0 then
  begin
    if rt<0 then
       Result:=-1
    else
       Result:=-2;
    Exit;
  end;
  //检测fdset中文件fd有无发生变化
  //connect()失败，进行错处理
  if (not FD_ISSET(s, fds)) then
  begin
    Result := -3;
    exit;
  end;
  //网络中断CE -1 PC OK
  rt := SendData(s, buf, BufLen, 0);
  if rt<=0 then
  begin
    Result := -20;
    exit;
  end;
  Result:=rt;
end;


function GetErrCodeStr(const Code:Integer):String;
begin
  case Code of
    -1:Result:='通讯失败，网络异常！';
    -2:Result:='通讯超时！';
    -3:Result:='FD检测异常!';
    -10:Result:='接收数据异常！';
    -20:Result:='发送数据异常！' ;

    -100:Result:='数据包解析错误！';
    -101:Result:='异常返回指令！';
    -102:Result:='返回的数据包长度异常！';
    -103:Result:='通讯序号不一致！';

    NormalErrCode:Result:='S：';
  else
    Result:=Format('错误代码：%d',[Code]);
  end;
end;

end.

