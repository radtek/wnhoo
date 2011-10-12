unit ProClientThread_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, WinSock, u_CommBag, u_Comm;

type
  TProClientThread = class(TThread)
  private
    FRecvBuf: TByteArray;
    FClient: TSocket;
    FClientIP, FInfo: string;
    function SendMsg(const OrdNum, CMD: Byte; const Data; const DataLen: Word): Boolean;
    function SendErrMsg(const OrdNum: Byte; const ErrorCode: Integer; const Msg: string): Boolean;
    procedure UpdateActiveTime;
    procedure AddDataList;
    procedure SyncAddDataList(const Info: string);
  public
    procedure Execute; override;
    constructor Create(CreateSuspended: Boolean);
    property ClientSocket: TSocket read FClient write FClient;
    property ClientIP: string read FClientIP write FClientIP;
  end;

implementation

constructor TProClientThread.Create(CreateSuspended: Boolean);
begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
  FClient := INVALID_Socket;
  FClientIP := '';
  FInfo := '';
  FillChar(FRecvBuf, SizeOf(TByteArray), 0);
end;

procedure TProClientThread.AddDataList();
begin
  _AddDataList(ThreadID, FClientIP, FInfo);
end;

procedure TProClientThread.SyncAddDataList(const Info: string);
begin
  FInfo := Info;
  Synchronize(AddDataList);
end;

function TProClientThread.SendMsg(const OrdNum, CMD: Byte; const Data; const DataLen: Word): Boolean;
var
  sendLen: integer;
  SendCB: TCommBag;
begin
  SendCB := GetCommBag(OrdNum, CMD, Data, DataLen);
  sendLen := SendBag(FClient, SendCB);
  Result := (sendLen > 0);
end;

function TProClientThread.SendErrMsg(const OrdNum: Byte; const ErrorCode: Integer; const Msg: string): Boolean;
var
  EI: TErrorInfo;
begin
  EI.ErrorCode := ErrorCode;
  EI.Msg := Msg;
  Result := SendMsg(OrdNum, CMD_Error, EI, SizeOf(TErrorInfo));
end;


procedure TProClientThread.Execute;
var
  fds: TFDSet;
  readLen: integer;
  RecvCB: TCommBag;
  SvrTime: TDateTime;
  UI: TUserInfo;
  CI: TCarInfo;
  IOR: TInOutRec;
  IsSendSucc: Boolean;
  timeout: TTimeVal;
  rt: Integer;
  rtStr: string;
  DataFlag: Integer;
  IsCheckSucc: Boolean;
begin
  IsSendSucc := False;
  SyncAddDataList('��������...');
  while (not Terminated) do
  begin
    FD_ZERO(fds);
    FD_SET(FClient, fds);
    //int maxfdp��һ������ֵ����ָ�����������ļ��������ķ�Χ���������ļ������������ֵ��1
    //�����ܴ���Windows�����������ֵ����ν���������ò���ȷ??
    timeout.tv_sec := _ActiveTimeOut;
    timeout.tv_usec := 0;
    if (select(FClient + 1, @fds, nil, nil, @timeout) <= 0) then
    begin
      SyncAddDataList('���ʱ��ǿ�ƶϿ����ӣ�');
      Break;
    end;
    if (not FD_ISSET(FClient, fds)) then Break;
    //��������,<=0 �����ж��ˣ�ͨ���ͻ��������Ͽ�
    readLen := recv(FClient, FRecvBuf, SizeOf(TByteArray), 0);
    if readLen <= 0 then Break;
    try
      //��������
      if not ParseCommBag(@FRecvBuf, readLen, RecvCB) then
      begin
        SyncAddDataList('�Ƿ����ݰ���ǿ�ƶϿ����ӣ�');
        Break;
      end;
      //����ָ��
      case RecvCB.CMD of
        CMD_SvrTime: begin
            SvrTime := Now;
            IsSendSucc := SendMsg(RecvCB.OrdNum, RecvCB.CMD, SvrTime, SizeOf(SvrTime));
          end;
        CMD_User: begin
            if RecvCB.DataLen <> SizeOf(TUserInfo) then Break;
            Move(RecvCB.Data^, UI, RecvCB.DataLen);
            _GetUserInfo(UI, rt, rtStr);
            if rt > 0 then
            begin
              IsSendSucc := SendMsg(RecvCB.OrdNum, RecvCB.CMD, UI, SizeOf(TUserInfo));
              SyncAddDataList(Format('OneIC��%s��%d��%d��%s', [UI.FullCardNum, UI.UserType, rt, UI.UserName]));
            end
            else
            begin
              IsSendSucc := SendErrMsg(RecvCB.OrdNum, rt, rtStr);
              SyncAddDataList(Format('OneIC��%s��%d��%d��%s', [UI.FullCardNum, UI.UserType, rt, rtStr]));
            end;

          end;
        CMD_Car: begin
            if RecvCB.DataLen <> SizeOf(TCarInfo) then Break;
            Move(RecvCB.Data^, CI, RecvCB.DataLen);
            _GetCarInfo(CI, rt, rtStr);
            if rt > 0 then
            begin
              IsSendSucc := SendMsg(RecvCB.OrdNum, RecvCB.CMD, CI, SizeOf(TCarInfo));
              SyncAddDataList(Format('MES��%s��%s��%d��%s��%s', [CI.VIN, CI.RFID, rt, CI.EngineNum, CI.ProjectNum]));
            end
            else
            begin
              IsSendSucc := SendErrMsg(RecvCB.OrdNum, rt, rtStr);
              SyncAddDataList(Format('MES��%s��%s��%d��%s', [CI.VIN, CI.RFID, rt, rtStr]));
            end;
          end;
        CMD_InOutRec: begin
            if RecvCB.DataLen <> SizeOf(TInOutRec) then Break;
            Move(RecvCB.Data^, IOR, RecvCB.DataLen);
            //�Է�����ʱ��Ϊ׼
            IOR.RecTime := Now();
            IsCheckSucc := _SaveInOutRec(IOR, DataFlag, rt, rtStr);
            if (IsCheckSucc and (rt > 0)) then
              IsSendSucc := SendMsg(RecvCB.OrdNum, RecvCB.CMD, IOR, SizeOf(TInOutRec))
            else
              IsSendSucc := SendErrMsg(RecvCB.OrdNum, rt, rtStr);
            //ͬ����ʾ
            SyncAddDataList(Format('MES��%d��%d��%s��%s��%s��%s��%d��%s', [
              IOR.PDANum, IOR.DirectionFlag,
                FormatDateTime('YYYY-MM-DD hh:nn:ss', IOR.RecTime),
                IOR.Driver.UserName, IOR.Car.VIN, IOR.Guard.UserName,
                rt, rtStr]));
          end;
      else
        begin
          rt := -1;
          rtStr := '��Ч��ָ�';
          IsSendSucc := SendErrMsg(RecvCB.OrdNum, rt, rtStr);
        end;
      end;

      _CS.Enter;
      try
        _PI.TID := ThreadID;
        _PI.IP := FClientIP;
        Synchronize(UpdateActiveTime);
        if not IsSendSucc then
        begin
          SyncAddDataList('��������ʧ�ܣ�ͨѶ�쳣��');
          Break; //�쳣�˳�
        end;
      finally
        _CS.Leave;
      end;
    finally
      if Assigned(RecvCB.Data) then
        FreeMem(RecvCB.Data, RecvCB.DataLen);
    end;
  end;
  SyncAddDataList('�Ͽ����ӣ�');
end;

procedure TProClientThread.UpdateActiveTime();
var
  Value: string;
begin
  Value := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
  _UpdatePDAList(3, Value);
end;

end.

