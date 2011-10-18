unit MainForm;

interface

uses
  Windows, Messages, Graphics, SysUtils, Classes, Controls, Forms, Clipbrd,
  Dialogs, AppEvnts, StdActns, ActnList, Menus, ComCtrls, Grids,
  ExtCtrls, StdCtrls, variants, Registry, shellapi, activex,
  ImgList, ToolWin, Buttons,
  XPStyleActnCtrls, ActnMan, OleCtrls, SHDocVw, u_Func, u_WB, u_MSHTML, RzTray,
  RzPrgres, RzStatus, RzPanel, RzCmboBx;

type
  TMainFRM = class(TForm)
    Panel_Frm: TPanel;
    ApplicationEvents1: TApplicationEvents;
    CoolBar1: TCoolBar;
    ToolBar2: TToolBar;
    search_ToolButton: TToolButton;
    PageControl: TPageControl;
    StatusBar: TRzStatusBar;
    StatusPane1: TRzStatusPane;
    ProgressBar: TRzProgressBar;
    StatusPane_web: TRzStatusPane;
    URLpath: TRzComboBox;
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    Button6: TButton;
    Button4: TButton;
    Button2: TButton;
    Button1: TButton;
    Button7: TButton;
    Button3: TButton;
    Panel2: TPanel;
    Button5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure TreeView_bloginfoMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ToolBar2Resize(Sender: TObject);
    procedure URLpathDropDown(Sender: TObject);
    procedure URLpathKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TreeView_webMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TreeView_webDblClick(Sender: TObject);
    procedure GoToURLExecute(Sender: TObject);
    procedure TreeView_blogDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TreeView_blogDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure TreeView_blogMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure TreeView_blogMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);

  private
    SourceNode: TTreeNode;
    function CreateSiteTab(): TTabSheet;
    procedure WMHotKey(var Message: TWMHotkey); message wm_hotkey;
    procedure OpenSite(const url: string);
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
    procedure AD_Mouse_Click_Event(const pt: TPoint);
    procedure AD_Mouse_Click_Msg(const h: THandle; const LP: LPARAM);
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
  if not URLpath.Focused then
    URLpath.Text := GetActiveWB.LocationURL; //取得地址栏目地址
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


procedure TMainFRM.FormCreate(Sender: TObject);
begin
  //打开主页
  OpenSite('http://www.hao123.com/');
  //http://blog.sina.com.cn/s/blog_68c926890100kwtv.html
  //初始化
  URLpathDropDown(URLpath);
end;

procedure TMainFRM.OpenSite(const url: string);
var
  TB: TTabSheet;
  WB: TW_IEWB;
begin
  TB := CreateSiteTab();
  if TB = nil then Exit;
  try
    WB := GetWBFromTabSheet(TB);
    if WB = nil then Exit;
    WB.Navigate(url, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
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


procedure TMainFRM.PageControlChange(Sender: TObject);
begin
  PageControl.SetFocus;
  if not URLpath.Focused then
    URLpath.Text := GetActiveWB.LocationURL;
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
  if ProgressBar <> nil then
    ProgressBar.Free;
  UnregisterHotKey(handle, 1);
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

  if {IsChild(WB.Handle, Msg.Hwnd) and }((Msg.Message = WM_RBUTTONDOWN) or (Msg.Message = WM_RBUTTONUP)) then
  begin
    //弹出自己的菜单
    pt := ScreenToClient(Msg.pt);
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

procedure TMainFRM.TreeView_bloginfoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if TTreeView(Sender).GetNodeAt(X, Y) <> nil then
    TTreeView(Sender).GetNodeAt(X, Y).Selected := true;
end;

procedure TMainFRM.ToolBar2Resize(Sender: TObject);
begin
  URLpath.Width := ToolBar2.Width - search_ToolButton.Width - 20;
end;

procedure TMainFRM.URLpathDropDown(Sender: TObject);
var
  reg: TRegistry;
  i: Integer;
  str: string;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    reg.openkey(RegHistoryUrl, true);
    for i := 0 to 25 do
    begin
      str := trim(reg.ReadString('url' + inttostr(i)));
      if (str <> '') and (pos('://', str) > 0) then
        if TComboBox(Sender).Items.IndexOf(str) < 0 then
          TComboBox(Sender).Items.Add(str);
    end;
    reg.closekey;
  finally
    reg.Free;
  end;
end;

procedure TMainFRM.URLpathKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  url: string;
begin
  if pos('.', TComboBox(Sender).Text) > 0 then
    if not (pos(':', TComboBox(Sender).Text) > 0) then
    begin
      TComboBox(Sender).Text := 'http://' + TComboBox(Sender).Text;
      TComboBox(Sender).SelStart := Length(TComboBox(Sender).Text);
    end;
  url := TComboBox(Sender).Text;
  if (Key = 13) and (url <> '') then
  begin
    if Shift = [ssCtrl] then
    begin
      TComboBox(Sender).Text := 'www.' + url + '.com';
      url := TComboBox(Sender).Text;
    end;

    if Shift = [ssshift] then
      OpenSite(url);
  end;
end;

procedure TMainFRM.TreeView_webMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if TTreeView(Sender).GetNodeAt(X, Y) <> nil then
    TTreeView(Sender).GetNodeAt(X, Y).Selected := true;
end;


procedure TMainFRM.TreeView_webDblClick(Sender: TObject);
begin
  if TTreeView(Sender).Selected <> nil then
    if TTreeView(Sender).Selected.Data <> nil then
      if PFavouritesinfo(TTreeView(Sender).Selected.Data)^._type = _URL then
        OpenSite(PFavouritesinfo(TTreeView(Sender).Selected.Data)^.url);
end;

procedure TMainFRM.GoToURLExecute(Sender: TObject);
begin
  URLpath.Perform(wm_keydown, VK_RETURN, 0);
end;

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

procedure TMainFRM.TreeView_blogDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  CurNode: TTreeNode;
begin
  CurNode := TTreeView(Sender).GetNodeAt(X, Y);
  if CurNode = nil then
    Exit;
  if MoveFileToDir(PMyNodeinfo(CurNode.Data)^.BlogPath,
    PMyNodeinfo(SourceNode.Data)^.BlogPath) then
  begin
    PMyNodeInfo(SourceNode.Data)^.BlogPath :=
      PMyNodeinfo(CurNode.Data)^.BlogPath
      +
      PMyNodeinfo(SourceNode.Data)^.NodeName + '.xml';
    SourceNode.MoveTo(CurNode, naAddChild);
  end;
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

procedure TMainFRM.TreeView_blogMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  TTreeView(Sender).EndDrag(True);
  if Shift = [ssLeft] then
    if TTreeView(Sender).Selected <> nil then
      if PMyNodeInfo(TTreeView(Sender).Selected.Data)^.MyNodeType = xmlfile then
      begin
        SourceNode := TTreeView(Sender).Selected;
        TTreeView(Sender).BeginDrag(True);
      end;
end;

procedure TMainFRM.TreeView_blogMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if TTreeView(Sender).GetNodeAt(X, Y) <> nil then
    TTreeView(Sender).GetNodeAt(x, y).Selected := True;
end;

procedure TMainFRM.Button1Click(Sender: TObject);
var
  SFile: string;
  SList: TStringList;
begin
  if not GetActiveWB.Busy then
  begin
    if FileExists(SFile) then
      deletefile(SFile);
    SFile := extractfilepath(Application.ExeName) + 'tmp.src';
    SList := TStringList.Create;
    SList.Text := GetActiveWB.GetHtml;
    SList.SaveToFile(SFile);
    SList.Free;
    if FileExists(SFile) then
      ShellExecute(handle, 'open', PChar('notepad.exe'), PChar('"' + SFile +
        '"'), nil, 1);
  end
  else
    MessageBox(handle, '对不起，当前页面忙，请稍后重试！',
      PChar(PChar(Application.Title)), MB_OK + MB_ICONINFORMATION);
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

procedure TMainFRM.AD_Mouse_Click_Event(const pt: TPoint);
begin
  SetCursorPos(Pt.X, Pt.Y);
  mouse_event(MOUSEEVENTF_LEFTDOWN or MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
end;

procedure TMainFRM.AD_Mouse_Click_Msg(const h: THandle; const LP: LPARAM);
begin
  //用SendMessage 比较稳妥，但是容易会阻赛
  PostMessage(h, WM_LBUTTONDOWN, 0, LP); //鼠标按下
  PostMessage(h, WM_LBUTTONUP, 0, LP); // 鼠标抬起
end;



procedure TMainFRM.Button4Click(Sender: TObject);
var
  OldPt: TPoint;
  Pt, pt1: TPoint;
  LP: LPARAM;
  h: THandle;
  x, y: Longint;
begin
  Randomize;
  if GetCursorPos(OldPt) then
  begin
    //282,171
    //951,209
    x := Random(951 - 282);
    x := x + 282;
    y := Random(209 - 171);
    y := y + 171;
    Pt.X := x;
    Pt.Y := y;
    pt1 := ClientToScreen(pt);
    AD_Mouse_Click_Event(pt1);
    //LP := Pt.X + pt.Y shl 16;
    //AD_Mouse_Click_Msg(self.Handle, LP);
    if SetCursorPos(OldPt.X, OldPt.Y) then
      TButton(Sender).SetFocus;
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

procedure TMainFRM.Button6Click(Sender: TObject);
var
  i, k: Integer;
  doc, ls, a: oleVariant;
  url, curl: string;
  urlList: TStringList;
begin
  urlList := TStringList.Create;
  doc := GetActiveWB.OleObject.document;
  ls := doc.links;
  for i := 0 to ls.length - 1 do
  begin
    a := ls.item(i);
    url := Trim(a.href);
    if Pos('jstvfcwr.com', url) > 0 then
    begin
      urlList.Add(url);

      //ls.item(i).click(); //引发”CLICK”事件
      //break;
    end;
  end;
  Randomize;
  k := Random(urlList.Count);
  curl := urlList.Strings[k];
  urlList.Free;
  for i := 0 to ls.length - 1 do
  begin
    a := ls.item(i);
    url := Trim(a.href);
    if url = curl then
    begin
      a.click(); //引发”CLICK”事件
      break;
    end;
  end;
end;

procedure TMainFRM.Button7Click(Sender: TObject);
var
  i, k: Integer;
  doc, ls, a: oleVariant;
  url, curl: string;
  urlList: TStringList;
begin
  doc := GetActiveWB.OleObject.document;
  ls := doc.links;
  for i := 0 to ls.length - 1 do
  begin
    a := ls.item(i);
    a.href := 'http://www.jstvfcwr.com/jmhg';
    Break;
  end;
end;

procedure TMainFRM.Button3Click(Sender: TObject);
var
  OldPt: TPoint;
  Pt, pt1: TPoint;
  LP: LPARAM;
  h, Ph: THandle;
  x, y: Longint;
begin
  Pt.X := 136;
  Pt.Y := 20;
  LP := MakeLParam(Pt.X, pt.Y); //  Pt.X + pt.Y shl 16;
 // if GetActiveWB.Document <> nil then
 //   IHTMLWindow2(IHTMLDocument2(GetActiveWB.Document).ParentWindow).focus;
  //Ph := FindWindowEx(PageControl.ActivePage.Handle, 0, 'Shell Embedding',nil);
  Ph := FindWindowEx(GetActiveWB.Handle, 0, 'Shell DocObject View', nil);
  Ph := FindWindowEx(Ph, 0, 'Internet Explorer_Server', nil);
  if Ph > 0 then
    AD_Mouse_Click_Msg(Ph, LP);
end;

procedure TMainFRM.WB_DocumentComplete(Sender: TObject);
begin

end;

procedure TMainFRM.Button5Click(Sender: TObject);
var
  OldPt: TPoint;
  Pt, pt1: TPoint;
  LP: LPARAM;
  h: THandle;
  x, y: Longint;
begin
  Pt.X := 105;
  Pt.Y := 137;
  pt1 := ClientToScreen(pt);
  AD_Mouse_Click_Event(pt1);
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

