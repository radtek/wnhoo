unit u_OneIC;

interface

uses
  SysUtils, Variants, Classes, Uni, UniDBC, u_CommBag;

type
  TOneICDBCtl = class(TDBCtl)
  private

  public
    function GetSvrDateTime(var dt: TDateTime): Boolean; override;
    function GetRtInfo(const rt: Integer): string;
    function GetUserInfo(var UI: TUserInfo): Integer;
    function GetPDAInfo(var PI: TPDAInfo): Integer;
    function UserAndMachIsLink(const UserID, MachID: Integer): Integer;
  end;

implementation

{ TOneICDBCtl }

function TOneICDBCtl.GetSvrDateTime(var dt: TDateTime): Boolean;
var
  Value: Variant;
  rt: Integer;
begin
  Result := False;
  rt := GetFistFieldValue('Select GetDate()', [], Value);
  if rt > 0 then
  begin
    dt := Value;
    Result := True;
  end;
end;

function TOneICDBCtl.GetRtInfo(const rt: Integer): string;
begin
  if rt > 0 then
  begin
    Result := '�ɹ���';
    Exit;
  end;
  case rt of
    0: Result := 'δ��������Ӱ�죡';
    -1: Result := 'OneIC�����쳣��';
    //IC
    -12: Result := '��δ��Ȩ��';
    -13: Result := '��״̬�쳣��';
    //PDA
    -22: Result := '�ֳֻ�δ��Ȩ��';
    //Link
    -32: Result := '��ʻԱ���Ž�ֹͨ�У�';
  else
    Result := 'δ֪�����룺' + InttoStr(rt);
  end;
end;

function TOneICDBCtl.UserAndMachIsLink(const UserID, MachID: Integer): Integer;
var
  Value: Variant;
  rt: Integer;
begin
  rt := GetFistFieldValue('Select UserID from UserAndMachList Where UserID=:1 and MachID=:2', [UserID, MachID], Value);
  if rt = 0 then
    Result := -32
  else
    Result := rt;
end;


function TOneICDBCtl.GetPDAInfo(var PI: TPDAInfo): Integer;
var
  Sql: string;
  Qry: TUniQuery;
begin
  Result := -1;
  Qry := TUniQuery.Create(self);
  try
    Sql := 'Select MachID,MachName from MachInfo Where MachNo=:1';
    if not GetQuery(Qry, Sql, [PI.PDANum]) then Exit;
    if Qry.IsEmpty then
    begin
      Result := -22; //δ��ȨPDA
      Exit;
    end;
    PI.MachID := Qry['MachID'];
    //PI.PDANum
    PI.PDAName := VarToStr(Qry['MachName']);
    Result := Qry.RecordCount;
  finally
    Qry.Free;
  end;
end;


function TOneICDBCtl.GetUserInfo(var UI: TUserInfo): Integer;
var
  Sql: string;
  Qry: TUniQuery;
  StatusFlagID: Integer;
begin
  Result := -1;
  Qry := TUniQuery.Create(self);
  try
    Sql := 'Select CI.CardID,CI.UserID,CI.UserNo,CI.UserName,CI.StatusFlagID,CI.FullCardNum,UIE.IdentityEx,UIE.ReMarkEx ' +
      'From V_CardInfo CI Inner Join T_YWK_UserInfoEx UIE On CI.UserID=UIE.UserID ' +
      'Where CI.FullCardNum=:1 And UIE.IdentityEx=:2';
    if not GetQuery(Qry, Sql, [UI.FullCardNum, UI.UserType]) then Exit;
    if Qry.IsEmpty then
    begin
      Result := -12; //��δ��Ȩ
      Exit;
    end;
    UI.CardID := Qry['CardID'];
    UI.UserID := Qry['UserID'];
    UI.UserNo := VarToStr(Qry['UserNo']);
    UI.UserName := VarToStr(Qry['UserName']);
    //UI.FullCardNum := VarToStr(Qry['FullCardNum']);
    //UI.UserType:= Qry['IdentityEx'];
    UI.TargetPlace := VarToStr(Qry['ReMarkEx']);
    if (Trim(UI.TargetPlace) = '') then
      UI.TargetPlace := '---';

    StatusFlagID := Qry['StatusFlagID'];
    if StatusFlagID <> 111 then
      Result := -13 //��״̬�쳣��
    else
      Result := Qry.RecordCount;
  finally
    Qry.Free;
  end;
end;

end.

