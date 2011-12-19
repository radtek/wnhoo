program BankSvrClient;

uses
  uROComInit,
  Forms,
  fClientForm in 'fClientForm.pas' {ClientForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TClientForm, ClientForm);
  Application.Run;
end.
