unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  uROClient, uROClientIntf, uROServer, uROBinMessage, uROIndyTCPServer;

type
  TService1 = class(TService)
    ROMessage: TROBinMessage;
    ROServer: TROIndyTCPServer;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  Service1: TService1;

implementation

uses u_Func;

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  Service1.Controller(CtrlCode);
end;

function TService1.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TService1.ServiceStart(Sender: TService; var Started: Boolean);
begin
  RoServer.Active := true;
end;

procedure TService1.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  RoServer.Active := false;
end;

procedure TService1.ServicePause(Sender: TService; var Paused: Boolean);
begin
  RoServer.Active := false;
end;

procedure TService1.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  RoServer.Active := true;
end;

procedure TService1.ServiceCreate(Sender: TObject);
begin
  LoadCfg();
  RoServer.Port:=U_SvrPort;
  U_ICBCCtl := TICBCCtlAPI.Create(self);
end;

procedure TService1.ServiceDestroy(Sender: TObject);
begin
  U_ICBCCtl.Free;
end;

end.

