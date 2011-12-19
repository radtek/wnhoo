unit fClientForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  uROClient, uROClientIntf, uRORemoteService, uROBinMessage, uROIndyTCPChannel;

type
  TClientForm = class(TForm)
    ROMessage: TROBinMessage;
    ROChannel: TROIndyTCPChannel;
    RORemoteService: TRORemoteService;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ClientForm: TClientForm;

implementation

{
  The unit BankSvrLib_Intf.pas will be generated by the RemObjects preprocessor the first time you
  compile your server application. Make sure to do that before trying to compile the client.

  To invoke your server simply typecast your server to the name of the service interface like this:

      (RORemoteService as IBankService).Sum(1,2)
}

uses BankSvrLib_Intf;

{$R *.dfm}

procedure TClientForm.Button1Click(Sender: TObject);
var
  rtMsg, rtStr: string;
begin
  if (RORemoteService as  IBankService).QueryAccValue_S('Q00001', '1209230309049304635', rtMsg, rtStr) then
    ShowMessage(rtStr)
  else
    ShowMessage(rtMsg);
end;


end.