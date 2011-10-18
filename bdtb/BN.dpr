program BN;

uses
  Forms,
  u_MainFrm in 'Src\u_MainFrm.pas' {MainFRM};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '';
  Application.CreateForm(TMainFRM, MainFRM);
  Application.Run;
end.

