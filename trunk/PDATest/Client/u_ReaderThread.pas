unit u_ReaderThread;

{$MODE objfpc}{$H+}

interface

uses
  Windows,Classes, FileUtil, LCLIntf, u_DevAPI, u_Func, SysUtils,SyncObjs;

type

  TReaderCMD=(RC_None=0,RC_1D=1,RC_UL=2,RC_IC=3);

  { TReaderThread }

  TReaderThread=Class(TThread)
    private
      FReaderCMD:TReaderCMD;
      FSEvent:TSimpleEvent;
      procedure CheckSvrConn;
      procedure ClearDriver;
      procedure QueryDriver;
      procedure ClearCar;
      procedure QueryCar;
      function ReaderBarcode1D(var B1DValue:String):Boolean;
      function ReaderRF(Const TagTypeFlag:TTagType;var RFValue:String):Boolean;
      procedure SleepEv(Const Timeout : Cardinal);
    public
      constructor Create(CreateSuspended: Boolean);
      destructor Destroy; override;
      procedure Execute; override;
      procedure SetEvent();
      property ReaderCMD: TReaderCMD read FReaderCMD write FReaderCMD default RC_None;
  end;
implementation

{ TReaderThread }

constructor TReaderThread.Create(CreateSuspended: Boolean);
begin
  FreeOnTerminate := False;
  inherited Create(CreateSuspended);
  FSEvent:=TSimpleEvent.Create;
end;

destructor TReaderThread.Destroy;
begin
  FSEvent.Free;
  inherited Destroy;
end;

procedure TReaderThread.SleepEv(Const Timeout : Cardinal);
begin
  //Sleep(Timeout);
  FSEvent.WaitFor(Timeout);
  FSEvent.ResetEvent;
end;

procedure TReaderThread.SetEvent();
begin
  FSEvent.SetEvent();
end;

procedure TReaderThread.Execute;
var
  Value:String;
  T1:DWord;
  FullCardNum:Cardinal;
begin
  T1:=GetTickCount();
  while (not Terminated) do
  begin
    if FReaderCMD<>RC_None then
    begin
       Value:='';
       case FReaderCMD of
         RC_1D : begin
           if ReaderBarcode1D(Value) then
           begin
             U_Car.VIN:=Value;
             Synchronize(@QueryCar);
           end
           else
           begin
             Synchronize(@ClearCar);
           end;
         end;
         RC_UL : begin
           if ReaderRF(ultra_light,Value) then
           begin
            U_Car.RFID:=Value;
            Synchronize(@QueryCar);
           end
           else
           begin
             Synchronize(@ClearCar);
           end;
         end;
         RC_IC :begin
           if ReaderRF(Mifare_One_S50,Value) then
           begin
             if GetFullCardNum(Value,FullCardNum) then
             begin
               U_Driver.FullCardNum:=InttoStr(FullCardNum);
               Synchronize(@QueryDriver);
             end
             else
             begin
               Synchronize(@ClearDriver);
             end;
           end
           else
           begin
             Synchronize(@ClearDriver);
           end;
         end;
       end;
       FReaderCMD:=RC_None;
       T1:=GetTickCount();
    end;
    //空闲检测网络连接
    if DWord(GetTickCount()-T1)>(HBI*1000) then
    begin
       //防止休眠 VK_NONAME =$FC
       SystemIdleTimerReset();
       //SHIdleTimerReset();
       keybd_event($FC , 0, KEYEVENTF_SILENT, 0);
       keybd_event($FC , 0, KEYEVENTF_KEYUP or KEYEVENTF_SILENT, 0);
       //心跳
       Synchronize(@CheckSvrConn);
       T1:=GetTickCount();
    end;
    SleepEv(300);
   end;
end;

function TReaderThread.ReaderRF(Const TagTypeFlag:TTagType;var RFValue:String):Boolean;
var
  TagType:TTagType;
  UIDStr: string;
  K: Integer;
  Pre_ReaderCMD:TReaderCMD;
begin
  Result:=False;
  //保存最新命令，如果有新命令插入就中止
  Pre_ReaderCMD:=FReaderCMD;
  try
    Init_RF_ISO14443A_Mode();
    K := 0;
    while ((not Terminated) and (FReaderCMD=Pre_ReaderCMD)) do
    begin
      UIDStr:='';
      TagType:=None;
      if getRFID(TagType, UIDStr) then
        if TagType = TagTypeFlag then
        begin
          RFValue:= UIDStr;
          PlayOK();
          Result:=True;
          break;
        end;
      inc(k);
      if k > 30 then break;
      SleepEv(200);
    end;
  finally
    Free_RF_ISO14443A_Mode();
  end;
end;

function TReaderThread.ReaderBarcode1D(var B1DValue:String):Boolean;
Const
  BufLen=255;
var
  Buf: PByte;
  rt, K: Integer;
  Pre_ReaderCMD:TReaderCMD;
begin
  Result:=False;
  //保存最新命令，如果有新命令插入就中止
  Pre_ReaderCMD:=FReaderCMD;
  Buf := GetMem(BufLen);
  try
    Barcode1D_init();
    K := 0;
    while ((not Terminated) and (FReaderCMD=Pre_ReaderCMD)) do
    begin
      FillChar(Buf^, BufLen, 0);
      rt := Barcode1D_scan(Buf);
      if rt > 0 then
      begin
        B1DValue:= StrPas(PChar(Buf));
        PlayOK();
        Result:=True;
        break;
      end;
      inc(k);
      if k > 50 then break;
      SleepEv(100);
    end;
  finally
    FreeMem(Buf, BufLen);
    Barcode1D_free();
  end;
end;

procedure TReaderThread.CheckSvrConn();
begin
   _CheckSvrConn();
end;

procedure TReaderThread.ClearDriver;
begin
   _ClearDriver();
end;

procedure TReaderThread.QueryDriver;
begin
   _QueryDriver();
end;

procedure TReaderThread.ClearCar;
begin
   _ClearCar();
end;

procedure TReaderThread.QueryCar;
begin
   _QueryCar();
end;

end.
