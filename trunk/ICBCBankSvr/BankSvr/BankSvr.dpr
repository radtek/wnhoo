program BankSvr;

{#ROGEN:BankSvrLib.rodl} // RemObjects: Careful, do not remove!

uses
  uROComInit,
  SvcMgr,
  Unit1 in 'Unit1.pas' {Service1: TService},
  BankSvrLib_Intf in 'BankSvrLib_Intf.pas',
  BankSvrLib_Invk in 'BankSvrLib_Invk.pas',
  BankService_Impl in 'BankService_Impl.pas';

{$R *.RES}
{$R RODLFile.res}

begin
  Application.Initialize;
  Application.CreateForm(TService1, Service1);
  Application.Run;
end.
