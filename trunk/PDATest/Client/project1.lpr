program project1;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  u_DM, unit1,u_Func,u_SocketClient;

{$R *.res}

begin
  Application.Title:='车辆出入管理';
  Application.Initialize;
  Application.CreateForm(TDMFrm, DMFrm);
  Pc:=TPDAClient.Create;
  try
    if CheckCfg() then
    begin
         Application.CreateForm(TMainFrm, MainFrm);
         Application.Run;
    end;
  finally
     Pc.DisConn();
     pc.Free;
  end;
end.
