program PDAServer;

uses
  FastMM4,
  Forms,
  MainSvrFrm in 'MainSvrFrm.pas' {PDASvrFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'PDA Access Control Server ';
  Application.CreateForm(TPDASvrFrm, PDASvrFrm);
  Application.Run;
end.

