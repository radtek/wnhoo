unit u_WB;

interface

uses
  windows, SysUtils, Classes, Controls, OleCtrls, SHDocVw, MSHTML,
  Variants, comobj, ActiveX, Messages;

type
  TW_FilterMode = (FM_None, FM_Href, FM_Title);
  TW_ExecCMD = (EC_SAVEAS, EC_SAVE, EC_PAGESETUP, EC_PRINTPREVIEW, EC_PRINT, EC_STOP,
    EC_REFRESH, EC_COPY, EC_PASTE, EC_CUT, EC_SELECTALL, EC_FIND, EC_PROPERTIES);

  TW_IEWB = class(TWebBrowser)
  private
    Furl: string;
  protected

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ShowFind();
    //使WebBrowser获得焦点
    procedure SetFous();
    function hasFous(): Boolean;
    function FindText(text: string): integer;
    procedure ExecCMD(EC: TW_ExecCMD);
    procedure SetFontSize(value: olevariant);
    procedure ShowHtml(title, content: string);
    procedure ADDCollention(const thistilte: string = '');
    procedure GoToURL(const url: string);
    function Version(): string;
    //文档代码
    function GetHtml: string;
    //插入Html代码
    procedure AddHtmlToBody(const html: string);
    //模拟鼠标点击
    procedure MouseLClick(const x, y: Integer);
    //获取ElementById
    function getElementById(const id: string): IHTMLElement;
    function getElementsByTagName(const Tag: string): IHTMLElementCollection;
    //触发TagID的Click事件
    procedure DoClickByTagId(const id: string);
    //获取连接列表
    procedure GetLinks(var LinkList: TStringList; const Filter: string; const FM: TW_FilterMode);
    //根据连接获取
    function FindLinkForHref(var url: string): IHTMLElement;
  published
    property Url: string read Furl;
  end;

implementation

{TMyWebBrowser}

//使WebBrowser获得焦点

procedure TW_IEWB.SetFous();
begin
  if Document <> nil then
    IHTMLWindow2(IHTMLDocument2(Document).ParentWindow).focus
end;

function TW_IEWB.hasFous(): Boolean;
begin
  Result := IHTMLDocument4(Document).hasfocus;
end;

procedure TW_IEWB.GetLinks(var LinkList: TStringList; const Filter: string; const FM: TW_FilterMode);
var
  doc2: IHTMLDocument2;
  Links: IHTMLElementCollection;
  link: IHTMLElement;
  i: Integer;
  href: OleVariant;
  title: string;
  IsFilter: Boolean;
begin
  if not Assigned(LinkList) then Exit;
  doc2 := Document as IHTMLDocument2;
  if not Assigned(doc2) then Exit;
  Links := doc2.links;
  LinkList.Clear;
  for i := 0 to Links.length - 1 do
  begin
    link := (Links.Item(i, varNull) as IHTMLElement);
    if Assigned(link) then
    begin
      //可能连接字符串javascript ，调用者自行判断
      href := link.getAttribute('href', 0);
      title := link.innerText;
      if (VarIsNull(href) or VarIsEmpty(href)) then Continue;
      IsFilter := false;
      case FM of
        FM_Href: IsFilter := (Pos(Filter, href) <= 0);
        FM_Title: IsFilter := (Pos(Filter, title) <= 0);
      end;
      if not IsFilter then
        LinkList.Add(href);
    end;
  end;
end;

function TW_IEWB.FindLinkForHref(var url: string): IHTMLElement;
var
  doc2: IHTMLDocument2;
  Links: IHTMLElementCollection;
  link: IHTMLElement;
  i: Integer;
  href: OleVariant;
begin
  result := nil;
  doc2 := Document as IHTMLDocument2;
  if not Assigned(doc2) then Exit;
  Links := doc2.links;
  for i := 0 to Links.length - 1 do
  begin
    link := (Links.Item(i, varNull) as IHTMLElement);
    if Assigned(link) then
    begin
      href := link.getAttribute('href', 0);
      if not (VarIsNull(href) or VarIsEmpty(href)) then
        if href = url then
        begin
          result := link;
          Break;
        end;
    end;
  end;
end;

procedure TW_IEWB.MouseLClick(const x, y: LongInt);
var
  LP: LPARAM;
  Ph: THandle;
begin
  LP := MakeLParam(x, y); //  x + y shl 16;
  //Ph := FindWindowEx(PageControl.ActivePage.Handle, 0, 'Shell Embedding',nil);
  Ph := FindWindowEx(Handle, 0, 'Shell DocObject View', nil);
  Ph := FindWindowEx(Ph, 0, 'Internet Explorer_Server', nil);
  if Ph > 0 then
  begin
    //用SendMessage 比较稳妥，但是容易会阻赛
    PostMessage(Ph, WM_LBUTTONDOWN, 0, LP); //鼠标按下
    PostMessage(Ph, WM_LBUTTONUP, 0, LP); // 鼠标抬起
  end;
end;

function TW_IEWB.getElementById(const id: string): IHTMLElement;
var
  doc3: IHTMLDocument3;
begin
  result := nil;
  doc3 := Document as IHTMLDocument3;
  if not Assigned(doc3) then Exit;
  result := doc3.getElementById(id);
end;


function TW_IEWB.getElementsByTagName(const Tag: string): IHTMLElementCollection;
var
  doc3: IHTMLDocument3;
begin
  result := nil;
  doc3 := Document as IHTMLDocument3;
  if not Assigned(doc3) then Exit;
  result := doc3.getElementsByTagName(Tag);
end;


procedure TW_IEWB.DoClickByTagId(const id: string);
var
  Element: IHTMLElement;
begin
  Element := getElementById(id);
  if Assigned(Element) then
    Element.click;
end;

procedure TW_IEWB.AddHtmlToBody(const html: string);
var
  doc2: IHTMLDocument2;
begin
  doc2 := Document as IHTMLDocument2;
  if not Assigned(doc2) then Exit;
  doc2.body.insertAdjacentHTML('afterBegin', html)
 {
  Range: IHTMLTxtRange;
  Range := (body as IHTMLBodyElement).createTextRange;
  if not Assigned(Range) then Exit;
  Range.collapse(False);
  Range.pasteHTML(html);
 }
end;

procedure TW_IEWB.GoToURL(const url: string);
begin
  Navigate(url, EmptyParam, EmptyParam, EmptyParam, EmptyParam);
end;

procedure TW_IEWB.SetFontSize(Value: olevariant);
begin
  ExecWB(OLECMDID_ZOOM, OLECMDEXECOPT_DONTPROMPTUSER, Value, Value);
end;

procedure TW_IEWB.ShowFind;
var
  CmdTarget: IOleCommandTarget;
  PtrGUID: PGUID;
  vaIn, vaOut: Olevariant;
const
  CLSID_WebBrowser: TGUID = '{ED016940-BD5B-11cf-BA4E-00C04FD70816}';
  HTMLID_FIND = 1;
begin
  New(PtrGUID);
  try
    PtrGUID^ := CLSID_WebBrowser;
    if Document <> nil then
    try
      Document.QueryInterface(IOleCommandTarget, CmdTarget);
      if CmdTarget <> nil then
      try
        CmdTarget.Exec(PtrGuid, HTMLID_FIND, 0, vaIn, vaOut);
      finally
        CmdTarget._Release;
      end;
    except
      ;
    end;
  finally
    Dispose(PtrGUID);
  end;
end;

procedure TW_IEWB.ShowHtml(title, content: string);
var
  doc2: IHTMLDocument2;
  vv: olevariant;
begin
  doc2 := Document as IHTMLDocument2;
  if not Assigned(doc2) then Exit;
  vv := VarArrayCreate([0, 0], varVariant);
  vv[0] := content;
  doc2.write(PSafeArray(TVarData(vv).VArray));
  doc2.title := title;
end;

function TW_IEWB.FindText(text: string): integer;
var
  i, k, len: Integer;
begin
  k := 0;
  len := self.OleObject.Document.All.Length - 1;
  for i := 0 to len do
  begin
    if Pos(text, self.OleObject.Document.All.Item(i).InnerText) <> 0 then
    begin
      self.OleObject.Document.All.Item(i).Style.Color := '#4BA444';
      Inc(k);
    end;
    if k = len then self.OleObject.Document.All.Item(i).ScrollIntoView(true);
  end;
  result := k;
end;

procedure TW_IEWB.ExecCMD(EC: TW_ExecCMD);
begin
  try
    case EC of
      EC_SAVEAS: ExecWB(OLECMDID_SAVEAS, OLECMDEXECOPT_DODEFAULT, EmptyParam);
      EC_SAVE: ExecWB(OLECMDID_SAVE, OLECMDEXECOPT_DODEFAULT, EmptyParam);
      EC_PAGESETUP: ExecWB(OLECMDID_PAGESETUP, OLECMDEXECOPT_DODEFAULT, EmptyParam);
      EC_PRINTPREVIEW: ExecWB(OLECMDID_PRINTPREVIEW, OLECMDEXECOPT_DODEFAULT, EmptyParam);
      EC_PRINT: ExecWB(OLECMDID_PRINT, OLECMDEXECOPT_DODEFAULT, EmptyParam);
      EC_STOP: ExecWB(OLECMDID_STOP, OLECMDEXECOPT_DODEFAULT, EmptyParam);
      EC_REFRESH: ExecWB(OLECMDID_REFRESH, OLECMDEXECOPT_DODEFAULT, EmptyParam);
      EC_Find: ExecWB(OLECMDID_FIND, OLECMDEXECOPT_DODEFAULT, EmptyParam);
      ///////////////////////////////////////////////////////////////////////////////
      EC_COPY: ExecWB(OLECMDID_COPY, OLECMDEXECOPT_DODEFAULT, EmptyParam);
      EC_PASTE: ExecWB(OLECMDID_PASTE, OLECMDEXECOPT_DODEFAULT, EmptyParam);
      EC_CUT: ExecWB(OLECMDID_CUT, OLECMDEXECOPT_DODEFAULT, EmptyParam);
      EC_SELECTALL: ExecWB(OLECMDID_SELECTALL, OLECMDEXECOPT_DODEFAULT, EmptyParam);
      ///////////////////////////////////////////////////////////////////////////////
      EC_PROPERTIES: ExecWB(OLECMDID_PROPERTIES, OLECMDEXECOPT_DODEFAULT, EmptyParam);
    end;
  except
    on e: Exception do
    begin
      MessageBox(0, PChar('出错信息:' + #13#10 + e.Message),
        '系统提示', MB_OK + MB_ICONWARNING);
    end;
  end;
end;


function TW_IEWB.GetHtml: string;
var
  doc2: IHTMLDocument2;
begin
  Result := '';
  doc2 := Document as IHTMLDocument2;
  if not Assigned(doc2) then Exit;
  result := doc2.Body.OuterHtml;
end;


procedure TW_IEWB.ADDCollention(const thistilte: string = '');
const
  CLSID_ShellUIHelper: TGUID = '{64AB4BB7-111E-11D1-8F79-00C04FC2FBE1}';
var
  ShellUIHelper: ISHellUIHelper;
  url, title: olevariant;
begin
  if thistilte <> '' then
    title := thistilte
  else
    title := LocationName;
  url := LocationUrl;
  if url <> '' then
  begin
    ShellUIHelper := CreateComObject(CLSID_ShellUIHelper) as ISHellUIHelper;
    ShellUIHelper.AddFavorite(url, title);
  end;
end;

constructor TW_IEWB.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TW_IEWB.Destroy;
begin

  inherited;
end;

function TW_IEWB.Version: string;
begin
  Result := 'WB 1.0 By 20100729';
end;

end.

