unit u_MainFrm;

interface

uses
  Windows, Messages, Graphics, SysUtils, Classes, Controls, Forms, Clipbrd,
  Dialogs, AppEvnts, StdActns, ActnList, Menus, ComCtrls, Grids,
  ExtCtrls, StdCtrls, variants, Registry, shellapi, activex,
  ImgList, ToolWin, Buttons,
  XPStyleActnCtrls, ActnMan, OleCtrls, SHDocVw, u_Func, u_WB, MSHTML, RzTray, RzPrgres, RzStatus, RzPanel, RzCmboBx;

type
  TMainFRM = class(TForm)
    ApplicationEvents1: TApplicationEvents;
    StatusBar: TRzStatusBar;
    StatusPane1: TRzStatusPane;
    ProgressBar: TRzProgressBar;
    StatusPane_web: TRzStatusPane;
    Panel1: TPanel;
    Button3: TButton;
    Button8: TButton;
    Button7: TButton;
    edt_Filter: TEdit;
    rg_FilterMode: TRadioGroup;
    edt_ref: TEdit;
    edt_url: TEdit;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button5: TButton;
    edt_y1: TEdit;
    edt_x2: TEdit;
    edt_y2: TEdit;
    PageControl: TPageControl;
    edt_x1: TEdit;
    Label1: TLabel;
    Button4: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure TreeView_blogDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);

  private
    SourceNode: TTreeNode;
    function CreateSiteTab(): TTabSheet;
    procedure WMHotKey(var Message: TWMHotkey); message wm_hotkey;
    function OpenSite(const url: string): TW_IEWB;
    procedure FreeNodeInfo(Node: TTreeNode);
    function IsNodeChild(Source, terget: TTreeNode): Boolean;
    function GetWBFromTabSheet(TB: TTabSheet): TW_IEWB;
    function GetActiveWB: TW_IEWB;
    procedure TBReSize(sender: Tobject);
    procedure TBMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    //////////////////////////WB////////////////////////////////////////////
    procedure WB_DocumentComplete(Sender: TObject);
    procedure WB_ProgressChange(Sender: TObject; Progress, ProgressMax: Integer);
    procedure WB_StatusTextChange(Sender: TObject; const Text: WideString);
    procedure WB_TitleChange(Sender: TObject; const Text: WideString);
    procedure WB_BeforeNavigate2(Sender: TObject; const pDisp: IDispatch;
      var URL, Flags, TargetFrameName, PostData, Headers: OleVariant;
      var Cancel: WordBool);
    procedure WB_NewWindow2(Sender: TObject; var ppDisp: IDispatch; var Cancel: WordBool);
    function WaitBusy(const wb: TW_IEWB; const timeout: Dword): Boolean;
    procedure ShowSListToFile(const SList: TStringList;
      const FileName: string);
  public
    { Public declarations }
  end;

var
  MainFRM: TMainFRM;
  UpTime: DWORD;
  upblogInterval: Integer;
implementation

{$R *.dfm}

procedure TMainFRM.WB_BeforeNavigate2(Sender: TObject; const pDisp: IDispatch;
  var URL: OleVariant; var Flags: OleVariant; var TargetFrameName: OleVariant;
  var PostData: OleVariant; var Headers: OleVariant; var Cancel: WordBool);

begin
 {pDisp.Document.parentWindow.execScript('window.alert=null;');
 pDisp.Document.parentWindow.execScript('window.confirm=null');
 pDisp.Document.parentWindow.execScript('window.showModalDialog=null');
 pDisp.Document.parentWindow.execScript('window.open=null');    }

  {ShowMessage(IsNull(URL) + #13#10 +
    IsNull(Flags) + #13#10 +
    IsNull(TargetFrameName) + #13#10 +
    IsNull(PostData) + #13#10 +
    IsNull(Headers)
    ); }
end;


procedure TMainFRM.WB_NewWindow2(Sender: TObject; var ppDisp: IDispatch;
  var Cancel: WordBool);
var
  TB: TTabSheet;
  WB: TW_IEWB;
begin
  TB := CreateSiteTab();
  if TB = nil then Exit;
  WB := GetWBFromTabSheet(TB);
  if WB = nil then
  begin
    Cancel := True;
    Exit;
  end;
  ppDisp := WB.DefaultDispatch;
end;

procedure TMainFRM.WB_ProgressChange(Sender: TObject; Progress,
  ProgressMax: Integer);
begin
  if TW_IEWB(Sender) = GetActiveWB then
  begin
    if ProgressBar.PartsComplete <> Progress then
    begin
      ProgressBar.PartsComplete := Progress;
      ProgressBar.TotalParts := ProgressMax;
    end;
  end;
end;

procedure TMainFRM.WB_StatusTextChange(Sender: TObject;
  const Text: WideString);
begin
  if TW_IEWB(Sender) = GetActiveWB then
    StatusPane_web.Caption := Text;
end;

procedure TMainFRM.WB_TitleChange(Sender: TObject;
  const Text: WideString);
var
  i: Integer;
  TB: TTabSheet;
begin
  for i := PageControl.ControlCount - 1 downto 0 do
    if PageControl.Controls[i] is TTabSheet then
    begin
      TB := (PageControl.Controls[i] as TTabSheet);
      if TB.handle = TW_IEWB(Sender).ParentWindow then
      begin
        TB.Caption := FormatTitle(trim(Text));
        TB.Hint := trim(Text);
        //保存收藏家时候用
        TB.ShowHint := true;
      end;
    end;
end;


function TMainFRM.OpenSite(const url: string): TW_IEWB;
var
  TB: TTabSheet;
begin
  Result := nil;
  TB := CreateSiteTab();
  if TB = nil then Exit;
  try
    Result := GetWBFromTabSheet(TB);
    if Result = nil then Exit;
    Result.GoToURL(url);
  except
    MessageBox(handle, '操作失败,请关闭当前窗口，重新开启新的窗口！',
      PChar(PChar(Application.Title)), MB_OK + MB_ICONWARNING);
  end;
end;

function TMainFRM.GetWBFromTabSheet(TB: TTabSheet): TW_IEWB;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to TB.ComponentCount - 1 do
    if TB.Components[i] is TW_IEWB then
    begin
      Result := (TB.Components[i] as TW_IEWB);
      Break;
    end;
end;

procedure TMainFRM.TBReSize(sender: Tobject);
var
  WB: TW_IEWB;
begin
  WB := GetWBFromTabSheet(TTabSheet(Sender));
  if WB = nil then Exit;
  WB.Width := TTabSheet(sender).Width;
  WB.Height := TTabSheet(sender).Height;
end;

procedure TMainFRM.TBMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 //
end;

function TMainFRM.CreateSiteTab(): TTabSheet;
var
  WB: TW_IEWB;
begin
  Result := TTabSheet.Create(PageControl);
  Result.PageControl := PageControl;
  Result.TabVisible := true;
  Result.ImageIndex := 57;
  Result.OnResize := TBReSize;
  Result.OnMouseDown := TBMouseDown;

  WB := TW_IEWB.Create(Result);
  WB.ParentWindow := Result.handle;
  WB.TheaterMode := true;
  //使webbrower不弹出错误提示框
  WB.silent := true;
  WB.Align := alClient;
  WB.Left := 0;
  WB.Top := 0;
  WB.Width := Result.Width;
  WB.Height := Result.Height;
  WB.Visible := true;
  //event
  WB.OnNewWindow2 := WB_NewWindow2;
  WB.OnBeforeNavigate2 := WB_BeforeNavigate2;
  WB.OnProgressChange := WB_ProgressChange;
  WB.OnStatusTextChange := WB_StatusTextChange;
  WB.onTitleChange := WB_TitleChange;
  WB.OnDownloadComplete := WB_DocumentComplete;

  PageControl.ActivePage := Result;
end;

function TMainFRM.GetActiveWB: TW_IEWB;
var
  TB: TTabSheet;
begin
  Result := nil;
  if PageControl.ActivePage is TTabSheet then
  begin
    TB := (PageControl.ActivePage as TTabSheet);
    Result := GetWBFromTabSheet(TB);
  end;
end;


procedure TMainFRM.FormDestroy(Sender: TObject);
var
  i: Integer;
  Component: TObject;
begin
  for i := PageControl.ComponentCount - 1 downto 0 do
  begin
    Component := PageControl.Components[i];
    Freeandnil(Component);
  end;
end;

procedure TMainFRM.WMHotKey(var Message: TWMHotkey);
begin
  if Message.HotKey = 1 then
    if Showing then
    begin
      ShowWindow(Application.handle, SW_hide);
      Hide;
    end
    else
    begin
      ShowWindow(Application.handle, SW_RESTORE);
      Show; //显示
      SetForegroundWindow(handle); //把窗口置前
    end;
end;

procedure TMainFRM.FreeNodeInfo(Node: TTreeNode);
var
  i: Integer;
begin
  if Node <> nil then
  begin
    if Node.Data <> nil then
      Dispose(PMyNodeInfo(Node.Data));
    for i := Node.Count - 1 downto 0 do
      FreeNodeInfo(Node.Item[i]);
  end;
end;

procedure TMainFRM.TrayIconClick(Sender: TObject);
begin
  Show;
end;

procedure TMainFRM.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
const
  StdKeys = [VK_TAB, VK_RETURN]; { standard keys }
  ExtKeys = [VK_DELETE, VK_BACK, VK_LEFT, VK_RIGHT]; { extended keys }
  fExtended = $01000000; { extended key flag }
var
  WB: TW_IEWB;
  Pt: TPoint;
begin
  WB := GetActiveWB;

  if IsChild(WB.Handle, Msg.Hwnd) and ((Msg.Message = WM_RBUTTONDOWN) or (Msg.Message = WM_RBUTTONUP)) then
  begin
    //弹出自己的菜单
    pt := ScreenToClient(Msg.pt);
    pt.Y := Pt.Y - WB.Top;
    pt.X := pt.X - wb.Left;
    ShowMessage(Format('-->%d,%d', [pt.X, pt.Y]) + #13#10 +
      Format('%d,%d', [Msg.pt.X, Msg.pt.Y]));
    //PopupMenu1.Popup(Msg.pt.X, Msg.pt.Y);
    Handled := True;
    exit;
  end;
  Handled := false;
  with Msg do
    if ((Message >= WM_KEYFIRST) and (Message <= WM_KEYLAST)) and
      ((WParam in StdKeys) or {$IFDEF VER120}(GetKeyState(VK_CONTROL) < 0) or
{$ENDIF}
      (WParam in ExtKeys) and ((LParam and fExtended) = fExtended)) then
    try
      if IsChild(GetActiveWB.handle, hWnd) then
        { handles all browser related messages }
      begin
        with GetActiveWB.Application as IOleInPlaceActiveObject do
          Handled := TranslateAccelerator(Msg) = S_OK;
        if not Handled then
        begin
          Handled := true;
          TranslateMessage(Msg);
          DispatchMessage(Msg);
        end;
      end;
    except
    end;
end; // IEMessageHandler

procedure TMainFRM.TreeView_blogDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  CurNode: TTreeNode;
begin
  Accept := false;
  CurNode := TTreeView(Sender).GetNodeAt(X, Y);
  if SourceNode = nil then
    Exit;
  if CurNode = nil then
    Exit;
  if CurNode = SourceNode then
    Exit;
  if PMyNodeinfo(CurNode.Data)^.MyNodeType = XmlFile then
    Exit;
  Accept := (not IsNodeChild(SourceNode, CurNode));
end;

function TMainFRM.IsNodeChild(Source, terget: TTreeNode): Boolean;
var
  i: Integer;
begin
  Result := false;
  for i := Source.Count - 1 downto 0 do
  begin
    if (Source.Item[i] = terget) then
    begin
      Result := true;
      Break;
    end
    else
    begin
      if Source.Item[i].Count > 0 then
        if IsNodeChild(Source.Item[i], terget) then
        begin
          Result := true;
          Break;
        end
    end;
  end;
end;

procedure TMainFRM.Button1Click(Sender: TObject);
var
  SList: TStringList;
begin
  if not GetActiveWB.Busy then
  begin
    SList := TStringList.Create;
    SList.Text := GetActiveWB.GetHtml;
    ShowSListToFile(SList, 'tmp.src');
    SList.Free;
  end
  else
    MessageBox(handle, '对不起，当前页面忙，请稍后重试！',
      PChar(PChar(Application.Title)), MB_OK + MB_ICONINFORMATION);
end;


procedure TMainFRM.ShowSListToFile(const SList: TStringList; const FileName: string);
var
  SFile: string;
begin
  if not Assigned(SList) then Exit;
  SFile := extractfilepath(Application.ExeName) + FileName;
  if FileExists(SFile) then
    deletefile(SFile);
  SList.SaveToFile(SFile);
 { if FileExists(SFile) then
    ShellExecute(handle, 'open', PChar('notepad.exe'), PChar('"' + SFile +
      '"'), nil, 1);  }
end;


procedure TMainFRM.Button2Click(Sender: TObject);
var
  i: Integer;
begin
  try
    for i := PageControl.PageCount - 1 downto 1 do
      if PageControl.Pages[i] <> nil then
        PageControl.Pages[i].Free;
  except
    ;
  end;
end;

 {
 
function TBlogEditForm.GetBlogHtml: string;
var
  switchMode, t: Olevariant;
begin
  try
    switchMode := wb.oleobject.document.all.item('switchMode', 0);
    switchMode.click;
    switchMode.click;
    t := Wb.OleObject.document.all.item('sourceEditor', 0);
    result := t.innerText;
  except
    Result := '';
  end;
end;

function TBlogEditForm.AddPicToBlogHtml(const url: string): Boolean;
var
  switchMode, t: Olevariant;
  checkstat: Boolean;
begin
  try
    switchMode := wb.oleobject.document.all.item('switchMode', 0);
    t := Wb.OleObject.document.all.item('sourceEditor', 0);
    checkstat := switchMode.checked;
    if not checkstat then
    begin
      switchMode.click;
    end;
    t.innerText := t.innerText + '<IMG src="' + url + '">';
    if not checkstat then
    begin
      switchMode.click;
    end;
    Result := True;
  except
    Result := false;
  end;
end;

function TBlogEditForm.SetBlogHtml(const info: string): Boolean;
var
  switchMode, t: Olevariant;
  checkstat: Boolean;
begin
  try
    switchMode := wb.oleobject.document.all.item('switchMode', 0);
    t := Wb.OleObject.document.all.item('sourceEditor', 0); //sourceEditor
    checkstat := switchMode.checked;
    if not checkstat then
    begin
      switchMode.click;
    end;
    t.innerText := info;
    if not checkstat then
    begin
      switchMode.click;
    end;
    Result := True;
  except
    Result := false;
  end;
end;

 }

function TMainFrm.WaitBusy(const wb: TW_IEWB; const timeout: Dword): Boolean;
var
  T: DWORD;
begin
  Result := False;
  T := GetTickCount;
  while (GetTickCount - T) < timeout do
  begin
    if not wb.Busy then
    begin
      Result := True;
      Break;
    end;
    Application.ProcessMessages;
  end;
end;

procedure TMainFRM.Button3Click(Sender: TObject);
var
  x1, y1, x2, y2: Integer;
begin
  x1 := StrToIntDef(edt_x1.Text, 0);
  y1 := StrToIntDef(edt_y1.Text, 0);
  x2 := StrToIntDef(edt_x2.Text, 0);
  y2 := StrToIntDef(edt_y2.Text, 0);
  RandomClickXY(GetActiveWB, x1, y1, x2, y2);
end;

procedure TMainFRM.WB_DocumentComplete(Sender: TObject);
begin

end;

procedure TMainFRM.Button5Click(Sender: TObject);
begin
  DeleteIECache('jstvfcwr.com');
end;

procedure TMainFRM.Button8Click(Sender: TObject);
var
  wb: TW_IEWB;
  gotourl, refurl, TagID: string;
begin
  refurl := Trim(edt_ref.Text);
  gotourl := Trim(edt_url.Text);
  if ((refurl = '') or (gotourl = '')) then Exit;

  wb := OpenSite(refurl);
  if not WaitBusy(wb, 3600 * 1000) then Exit;
  TagID := AddLinkToWB(wb, gotourl, gotourl, '_self');
  if TagID <> '' then
    wb.DoClickByTagId(TagID);
end;

procedure TMainFRM.Button7Click(Sender: TObject);
var
  urlList: TStringList;
  FM: TW_FilterMode;
  FilterStr, RUrl: string;
  k: Integer;
  WB: TW_IEWB;
  link: IHTMLElement;
begin
  urlList := TStringList.Create;
  try
    case rg_FilterMode.ItemIndex of
      1: FM := FM_Href;
      2: FM := FM_Title;
    else
      FM := FM_None;
    end;
    FilterStr := Trim(edt_Filter.Text);
    if FilterStr = '' then FM := FM_None;
    WB := GetActiveWB;
    WB.GetLinks(urlList, FilterStr, FM);
    if urlList.Count > 0 then
    begin
    //随机选择连接
      ShowSListToFile(urlList, 'tmp.list');
    //随机点击
      Randomize;
      k := Random(urlList.Count);
      RUrl := urlList.Strings[k];
      link := WB.FindLinkForHref(RUrl);
      if Assigned(link) then
        link.click;
    end
    else
      ShowMessage('无符合条件的连接!');
  finally
    urlList.Free;
  end;
end;

procedure TMainFRM.FormCreate(Sender: TObject);
begin
  OpenSite('about:blank');
end;

procedure TMainFRM.Button4Click(Sender: TObject);
var
  urlList: TStringList;
  FM: TW_FilterMode;
  FilterStr, RUrl: string;
  i, p: Integer;
  WB: TW_IEWB;
  divTag, InPutTag: IHTMLElement;
  divList, InPutList: IHTMLElementCollection;
  cssName, typeName, idName: Variant;
begin
  WB := GetActiveWB;
  divList := WB.getElementsByTagName('div');
  for i := 0 to divList.length - 1 do
  begin
    divTag := (divList.Item(i, varNull) as IHTMLElement);
    cssName := divTag.className; //divTag.getAttribute('class',0);
    if VarIsNull(cssName) then Continue;
    if VarIsEmpty(cssName) then Continue;
    if cssName <> 'tb-editor-editarea' then Continue;
    divTag.innerText :=
      '女嘉宾激情写真' + #13#10 +
      'http://www.jstvfcwr.com/jbxz/index.html' + #13#10 +
      '非诚勿扰直播' + #13#10 +
      'http://www.jstvfcwr.com/jmhg/index.html' + #13#10 +
      '女嘉宾资料' + #13#10 +
      'http://www.jstvfcwr.com/jbzl/index.html';
  end;
  InPutList := WB.getElementsByTagName('input');
  for i := 0 to InPutList.length - 1 do
  begin
    InPutTag := (InPutList.Item(i, varNull) as IHTMLElement);
    idName := InPutTag.getAttribute('id', 0);
    if VarIsNull(idName) then Continue;
    if VarIsEmpty(idName) then Continue;
    if Pos('aps', idName) < 1 then Continue;
    typeName := InPutTag.getAttribute('type', 0);
    if VarIsNull(typeName) then Continue;
    if VarIsEmpty(typeName) then Continue;
    if typeName <> 'submit' then Continue;
    InPutTag.click;
  end;
end;

initialization
  OleInitialize(nil);
finalization
  try
    OleUninitialize;
  except
    on e: Exception do
    begin
      MessageBox(0, PChar('出错信息:' + #13#10 + e.Message + #13#10#13#10 +
        '请将您的操作信息及错误提示，反馈给作者！'),
        '系统提示', MB_OK + MB_ICONWARNING);
    end;
  end;
end.

