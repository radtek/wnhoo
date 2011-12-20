unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  uROClient, uROClientIntf, uROServer, uROBinMessage, uROIndyTCPServer;

type
  TICBCService = class(TService)
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
  ICBCService: TICBCService;

implementation

uses u_Func;

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ICBCService.Controller(CtrlCode);
end;

function TICBCService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TICBCService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  RoServer.Active := true;
end;

procedure TICBCService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  RoServer.Active := false;
end;

procedure TICBCService.ServicePause(Sender: TService; var Paused: Boolean);
begin
  RoServer.Active := false;
end;

procedure TICBCService.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  RoServer.Active := true;
end;

procedure TICBCService.ServiceCreate(Sender: TObject);
begin
  LoadCfg();
  RoServer.Port:=U_SvrPort;
  U_ICBCCtl := TICBCCtlAPI.Create(self);
end;

procedure TICBCService.ServiceDestroy(Sender: TObject);
begin
  U_ICBCCtl.Free;
end;

end.

