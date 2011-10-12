unit u_DM;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, FileUtil;

type

  { TDMFrm }

  TDMFrm = class(TDataModule)
    SQLite3Connection1: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private
    FLastErr: string;
  public
    function ReConn(): boolean;
    procedure AddLoginLog(const UID, State: integer);
    property LastErr: string read FLastErr;
  end;

var
  DMFrm: TDMFrm;

implementation

{$R *.lfm}

{ TDMFrm }

procedure TDMFrm.DataModuleCreate(Sender: TObject);
begin
  //SQLite3Connection1.CharSet:='UTF-8';
  SQLite3Connection1.KeepConnection := True;
  SQLite3Connection1.DatabaseName :=
    UTF8Encode(ExtractFilePath(ParamStr(0)) + 'ctllog.db');
  SQLite3Connection1.Transaction := SQLTransaction1;
  SQLQuery1.DataBase := SQLite3Connection1;
end;

function TDMFrm.ReConn(): boolean;
begin
  Result:=False;
  try
    SQLite3Connection1.Close;
    SQLite3Connection1.Open;
    Result:=SQLite3Connection1.Connected;
  except
    On Ex: Exception do
      FLastErr := Ex.Message;
  end;
end;

procedure TDMFrm.AddLoginLog(const UID, State: integer);
begin
  try
    try
      if not SQLTransaction1.Active then
        SQLTransaction1.StartTransaction;
      SQLQuery1.Close;
      SQLQuery1.SQL.Text :=
        'insert into LoginLog (UID,LoginTime,State) values (:1,:2,:3)';
      SQLQuery1.Params[0].AsInteger := UID;
      SQLQuery1.Params[1].Value :=FormatDateTime('YYYY-MM-DD hh:nn:ss',Now);
      SQLQuery1.Params[2].AsInteger := State; //1 Login 2 LogOut
      SQLQuery1.ExecSQL;
    finally
      SQLTransaction1.Commit;
    end;
  except
    On Ex: Exception do
      FLastErr := Ex.Message;
  end;
end;

end.

