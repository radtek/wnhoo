unit u_DevAPI;

{$MODE objfpc}{$H+}

interface

uses
  windows,Classes, SysUtils;

type
   TTagType=(None,ultra_light,Mifare_DESFire,Mifare_One_S50,Mifare_ProX,Mifare_One_S70,Mifare_Pro);

const
  DevAPI_DLL = 'DevAPI.dll';
  WIFI_DLL='wifi.dll';

  ISO14443A = 0;

//获取硬件版本号
function HardwareVersion_Ex(pszData: Pbyte): Integer; stdcall; External DevAPI_DLL;
//端口选择 0 RFID 1 外接串口 2 Barcode 3 GPS
procedure SerialPortSwitch_Ex(ComID: Byte); stdcall; External DevAPI_DLL;
//IO控制，对相应的功能模块上/下电 uPortID 端口  uValue 0 低电平 1 高电平
procedure SerialPortControl_Ex(uPortID, uValue: Byte); stdcall; External DevAPI_DLL;
//设置波特率（针对RFID、条码）
function SerialPortSetBaudRate_Ex(iBaudRate: Integer): LongBool; stdcall; External DevAPI_DLL;
//功能模块切换（针对RFID、条码），必须在上电之后使用
//0 RFID 1 条码
function SerialPortFunctionSwitch_Ex(iModule: Integer): LongBool; stdcall; External DevAPI_DLL;
//RFID模式切换（需要执行该命令之后，才可进行相应的卡操作，默认ISO14443A）
//0 ISO14443A 1  ISO14443B 2 ISO15693
function RF_ModeSwitch(iMode: Integer): Integer; stdcall; External DevAPI_DLL;
//震动器（毫秒）
procedure StartShake(iTime: Integer); stdcall; External DevAPI_DLL;
//获取背光等级
function GetBackLightLevel(): Integer; stdcall; External DevAPI_DLL;
//设置背光等级 1-10
function SetBackLightLevel(iLevel: Integer): LongBool; stdcall; External DevAPI_DLL;
//打开WIFI模块
function WLanOn():LongBool;stdcall; External WIFI_DLL;
//关闭WIFI模块
function WLanOff():LongBool;stdcall; External WIFI_DLL;
//1D条码======================================================================
//初始化
procedure Barcode1D_init(); stdcall; External DevAPI_DLL;
//释放
procedure Barcode1D_free(); stdcall; External DevAPI_DLL;
//扫描 (条码<=255 Byte)
function Barcode1D_scan(pszData: PByte): Integer; stdcall; External DevAPI_DLL;
//ISO 14443A==================================================================
//初始化
function RF_ISO14443A_init(): LongBool; stdcall; External DevAPI_DLL;
//释放
procedure RF_ISO14443A_free(); stdcall; External DevAPI_DLL;
//呼叫天线内电子标签 0 未休眠电子标签  1 所有状态电子标签   返回ATQA信息
function RF_ISO14443A_request(iMode: Integer; pszATQA: PByte): Integer; stdcall; External DevAPI_DLL;
//查询电子标签 0 未休眠电子标签  1 所有状态电子标签   返回ATQA信息2Byte+UID长度1Byte+UID(S50为4Byte)
function RF_ISO14443A_request_Ex(iMode: Integer; pszData: PByte): Integer; stdcall; External DevAPI_DLL;
//防冲突 返回标签UID
function RF_ISO14443A_anticoll(pszUID: Pbyte): Integer; stdcall; External DevAPI_DLL;
//选择电子标签指令(选择之后标签处于激活状态)
function RF_ISO14443A_select(pszUID: Pbyte; iLenUID: Integer; pszSAK: Pbyte): Integer; stdcall; External DevAPI_DLL;
//A卡休眠指令(电子标签接收到该指令后退出激活状态)
function RF_ISO14443A_halt(): Integer; stdcall; External DevAPI_DLL;
//认证卡密钥
function RF_ISO14443A_authentication(iMode, iBlock: Integer; pszKey: PByte; iLenKey: Integer): Integer; stdcall; External DevAPI_DLL;
//读取标签内容
function RF_ISO14443A_read(iBlock: Integer; pszData: PByte): Integer; stdcall; External DevAPI_DLL;
//写入标签内容
function RF_ISO14443A_write(iBlock: Integer; pszData: PByte; iLenData: Integer): Integer; stdcall; External DevAPI_DLL;
//电子钱包初始化
function RF_ISO14443A_initval(iBlock, iValue: Integer): Integer; stdcall; External DevAPI_DLL;
//读取电子钱包
function RF_ISO14443A_readval(iBlock: Integer; pszValue: Pbyte): Integer; stdcall; External DevAPI_DLL;
//电子钱包  减
function RF_ISO14443A_decrement(iBlockValue, iBlockResult, iValue: Integer): Integer; stdcall; External DevAPI_DLL;
//电子钱包  增
function RF_ISO14443A_increment(iBlockValue, iBlockResult, iValue: Integer): Integer; stdcall; External DevAPI_DLL;
//回传函数,将EEPROM中内容传入卡的内部寄存器
function RF_ISO14443A_restore(iBlock: Integer): Integer; stdcall; External DevAPI_DLL;
//传送,将寄存器内通传送到EEPROM
function RF_ISO14443A_transfer(iBlock: Integer): Integer; stdcall; External DevAPI_DLL;
//ul防冲突    UID 7Byte
function RF_ISO14443A_ul_anticoll(pszUID: Pbyte): Integer; stdcall; External DevAPI_DLL;
//ul 写入数据 0-3 不能写入数据
function RF_ISO14443A_ul_write(iBlock: Integer; pszData: Pbyte; iLenData: Integer): Integer; stdcall; External DevAPI_DLL;

function Init_RF_ISO14443A_Mode(): Boolean;
function Halt_RF_ISO14443A(): Boolean;
procedure Free_RF_ISO14443A_Mode();
function getRFID(var TagType:TTagType;var UIDStr: string): Boolean;

implementation

function Init_RF_ISO14443A_Mode(): Boolean;
begin
  Result := RF_ISO14443A_init();
  if Result then
    Result := RF_ModeSwitch(ISO14443A) = 0;
end;

// halt 标签休眠

function Halt_RF_ISO14443A(): Boolean;
begin
  Result := (RF_ISO14443A_halt() = 0);
end;

// 释放资源

procedure Free_RF_ISO14443A_Mode();
begin
  RF_ISO14443A_free();
end;

//寻卡  成功返回true

function ReadID(pszData: Pbyte): Boolean;
begin
  //寻卡指令
  Result := (RF_ISO14443A_request_Ex(1, pszData) = 0);
end;

function getRFID(var TagType:TTagType;var UIDStr: string): Boolean;
var
  pszData: PByte;
  i: Integer;
  DLen, UIDLen: Byte;
  ATAQ: array[0..1] of Byte;
begin
  Result := False;
  pszData := GetMem(255);
  try
    FillChar(pszData^, 255, 0);
    //电子标签  寻卡操作 look for cards
    if (RF_ISO14443A_request_Ex(1, pszData) <> 0) then exit;
    //寻卡成功  返回数组 0字节数据长度 1，2字节ATQA 3字节UID长度 4字节后为UID信息
    DLen := pszData[0];
    Move(pszData[1], ATAQ[0], 2);
    UIDLen := pszData[3];
    UIDStr := '';
    for i := 4 to (UIDLen + 4)-1 do
      UIDStr := UIDStr + InttoHex(pszData[i], 2);
    //卡类型
    TagType := None;
    case ATAQ[0] of
      $44: begin
          if (ATAQ[1] = $00) then
            TagType := ultra_light;
          if (ATAQ[1] = $03) then
            TagType := Mifare_DESFire;
        end;
      $04: begin
          if (ATAQ[1] = $00) then
            TagType := Mifare_One_S50;
          if (ATAQ[1] = $03) then
            TagType := Mifare_ProX;
        end;
      $02: begin
          if (ATAQ[1] = $00) then
            TagType := Mifare_One_S70;
        end;
      $08: begin
          if (ATAQ[1] = $00) then
            TagType := Mifare_Pro;
        end;
    end;
    Result := (TagType <> None);
  finally
    FreeMem(pszData, 255);
  end;
end;


end.

