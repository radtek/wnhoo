unit MainSvrFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs, ComCtrls, ExtCtrls, StdCtrls, SyncObjs,
  Buttons, jpeg, ImgList, XPMan, Menus, ActnList, ShellAPI, DateUtils,
  TCPSVR_Unit, u_Comm, u_OneIC, u_Mes;

type
  TPDASvrFrm = class(TForm)
    Img_Top: TImage;
    Img_Exit: TImage;
    XPManifest1: TXPManifest;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    SBar: TStatusBar;
    PDAList: TListView;
    DataList: TListView;
    lbl_SvrName: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Img_ExitClick(Sender: TObject);
  private
    SVR: TServerThread;
  public

  end;

var
  PDASvrFrm: TPDASvrFrm;
implementation

{$R *.dfm}


procedure TPDASvrFrm.FormCreate(Sender: TObject);
begin
  if not _LoadCfgFile() then
  begin
    Application.MessageBox('缺少配置文件！', PChar(Application.Title), MB_OK +
      MB_ICONWARNING);
    Application.Terminate;
    Exit;
  end;
  //标题
  lbl_SvrName.Caption:=_SvrName;
  //
  _SBar:=SBar;
  _PDAList := PDAList;
  _DataList := DataList;
  //临界操作
  _CS := TCriticalSection.Create;
  OneIC_CS := TCriticalSection.Create;
  MES_CS:= TCriticalSection.Create;
  //连接OneIC
  OneIC_DBC := TOneICDBCtl.Create(self);
  if not OneIC_DBC.ConnDB(OneIC_ConnCfg) then
  begin
    Application.MessageBox(PChar(OneIC_DBC.LastErrInfo), PChar(Application.Title), MB_OK +
      MB_ICONWARNING);
    Application.Terminate;
    Exit;
  end;
  //连接MES
  MES_DBC := TMESDBCtl.Create(self);
  if not MES_DBC.ConnDB(MES_ConnCfg) then
  begin
    Application.MessageBox(PChar(MES_DBC.LastErrInfo), PChar(Application.Title), MB_OK +
      MB_ICONWARNING);
    Application.Terminate;
    Exit;
  end;
  //开启服务
  SVR := TServerThread.Create(false, _SvrPort);
  SBar.Panels[1].Text := IntToStr(_SvrPort);
  SBar.Panels[3].Text := IntToStr(_ActiveTimeOut);
  _CheckDBConn();
  {
  SBar.Panels[5].Text := '连接';
  SBar.Panels[7].Text := '连接';
  }
  SBar.Panels[9].Text := '1.1.1 Build 20120517';
end;

procedure TPDASvrFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(SVR) then
  begin
    SVR.Terminate;
    SVR.WaitFor;
    SVR.Free;
  end;
  _CS.Free;
  OneIC_DBC.Free;
  MES_DBC.Free;
  OneIC_CS.Free;
  MES_CS.Free;
end;

procedure TPDASvrFrm.Img_ExitClick(Sender: TObject);
begin
  close;
end;

end.

