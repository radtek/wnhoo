unit u_Func;

interface

uses
  windows, forms, messages, SysUtils, Classes, inifiles,
  SHDocVw, mshtml, Variants, comobj, ActiveX, ComCtrls, Dialogs,
  ShlObj, shellapi, Registry, UrlMon, StdCtrls, Controls, wininet, u_WB;

type
  TCPUID = array[1..4] of Longint;
type
  PMyNodeinfo = ^TMyNodeinfo;
  TMyNodeinfo = record
    NodeName: string;
    BlogPath: TFileName;
    MyNodeType: (Folder, XmlFile);
  end;
type
  TCurNodeInfo = record
    MyNodeinfo: PMyNodeinfo;
    BlogHead: Pointer;
  end;


function DownLoadInternetFile(Source, Dest: string): Boolean;
function GetCPUID: TCPUID; assembler; register;
function FormatTitle(Title: string): string;
function IsNull(v: OleVariant): string;
procedure DeleteIECache(httpStr: string);
procedure RandomClickXY(const wb: TW_IEWB; const x1, y1, x2, y2: LongInt);
//增加连接
function AddLinkToWB(const wb: TW_IEWB; const gotourl, title, target: string): string;
implementation

function IsNull(v: OleVariant): string;
begin
  if VarIsNull(v) then
    Result := ''
  else
    Result := v;
end;

function FormatTitle(Title: string): string;
var
  FTitle: string;
begin
  if length(Title) > 21 then
    FTitle := copy(Title, 1, 18) + '...'
  else
    FTitle := Title;

  FTitle := FTitle + ' ';
  result := FTitle;
end;

function GetCPUID: TCPUID; assembler; register; //得到CPU序列号
asm
  PUSH    EBX         {Save affected register}
  PUSH    EDI
  MOV     EDI,EAX     {@Resukt}
  MOV     EAX,1
  DW      $A20F       {CPUID Command}
  STOSD          {CPUID[1]}
  MOV     EAX,EBX
  STOSD               {CPUID[2]}
  MOV     EAX,ECX
  STOSD               {CPUID[3]}
  MOV     EAX,EDX
  STOSD               {CPUID[4]}
  POP     EDI {Restore registers}
  POP     EBX
end;

function DownLoadInternetFile(Source, Dest: string): Boolean;
begin
  try
    result := URLDownloadToFile(nil, pchar(Source), pchar(Dest), 0, nil) = 0
  except
    result := False;
  end;
end;

procedure DeleteIECache(httpStr: string); // 清理IE缓存,IE.cookies
var
  lpEntryInfo: PInternetCacheEntryInfo;
  hCacheDir: LongWord;
  dwEntrySize: LongWord;
  cachefile: string;
begin
  dwEntrySize := 0;
  FindFirstUrlCacheEntry(nil, TInternetCacheEntryInfo(nil^), dwEntrySize);
  GetMem(lpEntryInfo, dwEntrySize);
  if dwEntrySize > 0 then
    lpEntryInfo^.dwStructSize := dwEntrySize;
  hCacheDir := FindFirstUrlCacheEntry(nil, lpEntryInfo^, dwEntrySize);
  if hCacheDir <> 0 then
  begin
    repeat
      if (lpEntryInfo^.CacheEntryType) and (NORMAL_CACHE_ENTRY) = NORMAL_CACHE_ENTRY then
        cachefile := pchar(lpEntryInfo^.lpszSourceUrlName);
      if pos(httpStr, cachefile) > 0 then //清除特定网站的cookies.例如baidu.com
        DeleteUrlCacheEntry(pchar(cachefile)); //执行删除操作
      FreeMem(lpEntryInfo, dwEntrySize);
      dwEntrySize := 0;
      FindNextUrlCacheEntry(hCacheDir, TInternetCacheEntryInfo(nil^), dwEntrySize);
      GetMem(lpEntryInfo, dwEntrySize);
      if dwEntrySize > 0 then
        lpEntryInfo^.dwStructSize := dwEntrySize;
    until not FindNextUrlCacheEntry(hCacheDir, lpEntryInfo^, dwEntrySize);
  end;
  FreeMem(lpEntryInfo, dwEntrySize);
  FindCloseUrlCache(hCacheDir);
end;

//坐标随机点击

procedure RandomClickXY(const wb: TW_IEWB; const x1, y1, x2, y2: LongInt);
var
  x, y: Integer;
begin
  if not Assigned(wb) then Exit;
  Randomize;
  x := Random(x2 - x1);
  x := x + x1;
  y := Random(y2 - y1);
  y := y + y1;
  wb.MouseLClick(x, y);
end;

//增加连接
function AddLinkToWB(const wb: TW_IEWB; const gotourl, title, target: string): string;
var
  html, ID: string;
begin
  try
    ID := 'WB_AD_' + FormatDateTime('YYYYMMDDhhnnsszzz', Now);
    html := Format('<a id="%s" href="%s" target="%s">%s</a>', [ID, gotourl,target, title]);
    wb.AddHtmlToBody(html);
  except
    ID := '';
  end;
  Result := ID;
end;





end.

