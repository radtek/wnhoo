unit u_Mes;

interface

uses
  Forms, SysUtils, Variants, Classes, Uni, UniDBC, u_CommBag;

type
  TMESDBCtl = class(TDBCtl)
  private

  public
    function GetSvrDateTime(var dt: TDateTime): Boolean; override;
    function GetRtInfo(const rt: Integer): string;
    function GetCarInfo(var Car: TCarInfo): Integer;
    function SaveInOutRec(const IOR: TInOutRec; const PDAName: string; const DataFlag: Integer): Integer;
  end;

implementation

function TMESDBCtl.GetSvrDateTime(var dt: TDateTime): Boolean;
var
  Value: Variant;
  rt: Integer;
begin
  Result := False;
  rt := GetFistFieldValue('SELECT SYSDATE FROM SYS.DUAL', [], Value);
  if rt > 0 then
  begin
    dt := Value;
    Result := True;
  end;
end;

function TMESDBCtl.GetRtInfo(const rt: Integer): string;
begin
  if rt > 0 then
  begin
    Result := '成功！';
    Exit;
  end;
  case rt of
    0: Result := '未产生数据影响！';
    -1: Result := 'MES操作异常！';
    //Car
    -12: Result := '无匹配车辆信息！';
  else
    Result := '未知错误代码：' + InttoStr(rt);
  end;
  //Result:=Result+'->'+LastErrInfo;
end;

function TMESDBCtl.SaveInOutRec(const IOR: TInOutRec; const PDAName: string; const DataFlag: Integer): Integer;
var
  Sql: string;
begin
  try
    Sql := 'Insert Into T_CarInOutRec(InOutRecID' +
    //--保安(Guard)
    ',G_UID,G_Name,G_Num,G_CID,G_FCN' +
    //--驾驶员(Driver)
    ',D_UID,D_Name,D_Num,D_CID,D_FCN' +
    //--Car数据来自MES
    ',VIN,RFID,EngineNum,ProjectNum' +
    //--手持PDA
    ',PDANum,PDAName' +
    //--辅助数据
    ',DirectionFlag,RecTime,TargetPlace,DataFlag)' +
      ' Values ' +
      '(SYS_GUID()' +
      ',:1,:2,:3,:4,:5' +
      ',:6,:7,:8,:9,:10' +
      ',:11,:12,:13,:14' +
      ',:15,:16' +
      ',:17,:18,:19,:20)';
    Result := ExecCmd(Sql, [
      IOR.Guard.UserID, IOR.Guard.UserName, IOR.Guard.UserNo, IOR.Guard.CardID, IOR.Guard.FullCardNum,
        IOR.Driver.UserID, IOR.Driver.UserName, IOR.Driver.UserNo, IOR.Driver.CardID, IOR.Driver.FullCardNum,
        IOR.Car.VIN, IOR.Car.RFID, IOR.Car.EngineNum, IOR.Car.ProjectNum,
        IOR.PDANum, PDAName,
        IOR.DirectionFlag, IOR.RecTime, IOR.Driver.TargetPlace, DataFlag
        ]);
  except
    Result := -1;
  end;
end;

function TMESDBCtl.GetCarInfo(var Car: TCarInfo): Integer;
var
  SqlList: TStringList;
  ParValue: string;
  Qry: TUniQuery;
begin
  Result := -1;
  SqlList := TStringList.Create;
  Qry := TUniQuery.Create(self);
  try
    if Trim(Car.RFID) <> '' then
    begin
      SqlList.LoadFromFile(ExtractFilePath(Application.ExeName) + 'sql\MES_RFID.sql');
      ParValue := Trim(Car.RFID);
    end
    else if Trim(Car.VIN) <> '' then
    begin
      SqlList.LoadFromFile(ExtractFilePath(Application.ExeName) + 'sql\MES_VIN.sql');
      ParValue := Trim(Car.VIN);
    end;
    if not GetQuery(Qry, SqlList.Text, [ParValue]) then Exit;
    if Qry.IsEmpty then
    begin
      Result := -12; //无匹配车辆信息！
      Exit;
    end;
    Car.VIN := Qry['PROSN'];
    Car.RFID := Qry['RFID'];
    Car.EngineNum := VarToStr(Qry['PRAMATCODE']);
    Car.ProjectNum := VarToStr(Qry['MATCODE']);
    Result := Qry.RecordCount;
  finally
    Qry.Free;
    SqlList.Free;
  end;
end;

end.

