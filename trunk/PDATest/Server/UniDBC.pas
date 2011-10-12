unit UniDBC;

interface

uses
  SysUtils, Variants, Classes, Dialogs,
  UniProvider, OracleUniProvider, Uni, SQLServerUniProvider;

type
  TConnCfg = record
    ProviderName, Server: string;
    Port: Word;
    Database, Username, Password: string;
    IsDirect: Boolean;
  end;

  TDBCtl = class(TComponent)
  private
    FSQLServerPrv: TSQLServerUniProvider;
    FOraclePrv: TOracleUniProvider;
    FConn: TUniConnection;
    FTrans: TUniTransaction;
    FLastErrInfo: string;
    function _ConnDB(const ProviderName, Server: string; const Port: Word; const Database, Username, Password: string;
      const IsDirect: Boolean): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ConnDB(const ConnCfg: TConnCfg): Boolean;
    function ReConnDB(): Boolean;
    function IsConn(): Boolean;
    procedure StartTrans;
    procedure CommitTrans;
    procedure RollbackTrans;
    function GetQuery(var Qry: TUniQuery; const Sql: string;
      Pv: array of Variant): boolean;
    function ExecCmd(const Sql: string; Pv: array of Variant): Integer;
    //第一个字段值
    function GetFistFieldValue(const Sql: string; Pv: array of Variant;
      var Value: Variant): Integer;
    //服务器时间，可以覆盖
    function GetSvrDateTime(var dt: TDateTime): Boolean; virtual;
    property Conn: TUniConnection read FConn;
    property LastErrInfo: string read FLastErrInfo;
  end;

implementation

procedure TDBCtl.StartTrans();
begin
  FTrans.StartTransaction;
end;

procedure TDBCtl.CommitTrans();
begin
  FTrans.Commit;
end;

procedure TDBCtl.RollbackTrans();
begin
  FTrans.Rollback;
end;

function TDBCtl.GetQuery(var Qry: TUniQuery; const Sql: string; Pv: array of
  Variant): boolean;
var
  i: Integer;
begin
  Result := False;
  if Qry = nil then Exit;
  try
    Qry.Close;
    Qry.Connection := FConn;
    Qry.Sql.Text := Sql;
    for i := low(Pv) to high(Pv) do
      Qry.Params[i].Value := Pv[i];
    Qry.Open();
    Result := True;
  except
    on Ex: Exception do
      FLastErrInfo := Ex.Message;
  end;
end;

function TDBCtl.GetSvrDateTime(var dt: TDateTime): Boolean;
begin
  dt := Now();
  Result := True;
end;

function TDBCtl.ExecCmd(const Sql: string; Pv: array of
  Variant): Integer;
var
  Qry: TUniQuery;
  i: Integer;
begin
  Result := -1;
  Qry := TUniQuery.Create(Self);
  try
    Qry.Close;
    Qry.Connection := FConn;
    Qry.Sql.Text := Sql;
    for i := low(Pv) to high(Pv) do
      Qry.Params[i].Value := Pv[i];
    Qry.Execute;
    Result := Qry.RowsAffected;
  except
    on Ex: Exception do
      FLastErrInfo := Ex.Message;
  end;
end;

function TDBCtl.GetFistFieldValue(const Sql: string; Pv: array of
  Variant; var Value: Variant): Integer;
var
  Qry: TUniQuery;
  i: Integer;
begin
  Result := -1;
  Qry := TUniQuery.Create(Self);
  try
    Qry.Close;
    Qry.Connection := FConn;
    Qry.Sql.Text := Sql;
    for i := low(Pv) to high(Pv) do
      Qry.Params[i].Value := Pv[i];
    Qry.Open;
    if not Qry.IsEmpty then
      Value := Qry.Fields[0].Value;
    Result := Qry.RecordCount;
  except
    on Ex: Exception do
      FLastErrInfo := Ex.Message;
  end;
end;

function TDBCtl._ConnDB(const ProviderName, Server: string; const Port: Word; const Database, Username, Password: string;
  const IsDirect: Boolean): Boolean;
begin
  Result := False;
  try
    //建立连接
    FConn.Close;
    FConn.ProviderName := ProviderName;
    if IsDirect then
    begin
      //Oracle 直连
      if UpperCase(ProviderName) = UpperCase('Oracle') then
        FConn.SpecificOptions.Values['Direct'] := 'True';
    end;
    FConn.Server := Server;
    FConn.Port := Port;
    FConn.Database := Database;
    FConn.Username := Username;
    FConn.Password := Password;
    FConn.LoginPrompt := False;
    FConn.Connect;
    Result := FConn.Connected;
  except
    on Ex: Exception do
      FLastErrInfo := Ex.Message;
  end;
end;

function TDBCtl.ConnDB(const ConnCfg: TConnCfg): Boolean;
begin
  Result := _ConnDB(ConnCfg.ProviderName, ConnCfg.Server, ConnCfg.Port,
    ConnCfg.Database, ConnCfg.Username, ConnCfg.Password,
    ConnCfg.IsDirect);
end;

constructor TDBCtl.Create(AOwner: TComponent);
begin
  inherited;
  FSQLServerPrv := TSQLServerUniProvider.Create(Self);
  FOraclePrv := TOracleUniProvider.Create(Self);
  FConn := TUniConnection.Create(Self);
  FTrans := TUniTransaction.Create(Self);
  //建立事务连接
  FTrans.DefaultConnection := FConn;
end;

destructor TDBCtl.Destroy;
begin
  FTrans.Free;
  if FConn.Connected then
    FConn.Close;
  FConn.Free;
  FOraclePrv.Free;
  FSQLServerPrv.Free;
  inherited;
end;

function TDBCtl.IsConn: Boolean;
begin
  Result := FConn.Connected;
end;

function TDBCtl.ReConnDB: Boolean;
begin
  Result := False;
  try
    FConn.Close;
    FConn.Connect;
    Result := FConn.Connected;
  except
    on Ex: Exception do
      FLastErrInfo := Ex.Message;
  end;
end;

end.

