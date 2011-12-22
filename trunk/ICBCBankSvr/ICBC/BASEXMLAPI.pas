(*
    XML基础解析
    原始作者：王云涛
    建立时间：2011-12-02
*)
unit BASEXMLAPI;

interface

uses
  SysUtils, Classes, XMLDoc, Variants, xmldom, XMLIntf, msxmldom, MSXML;

type
  TBASEXMLAPI = class(TObject)
  private
    //格式化节点值,不存在节点返回空白字符
    function FormatXMLDOMNodeValue(const Node: IXMLDOMNode): string;
  protected
    FXD: TXMLDocument;
    //返回单节点
    function SelectSingleNode(const queryString: string): IXMLDOMNode; overload;
    function SelectSingleNode(const ParentNode: IXMLDOMNode; const queryString: string): IXMLDOMNode; overload;
    //选择节点,返回节点列表
    function SelectNodes(const queryString: string): IXMLDOMNodeList; overload;
    function SelectNodes(const ParentNode: IXMLDOMNode; const queryString: string): IXMLDOMNodeList; overload;
    //获取单节点值,不存在节点返回空白字符
    function GetSingleNodeValue(const queryString: string): string; overload;
    function GetSingleNodeValue(const ParentNode: IXMLDOMNode; const queryString: string): string; overload;
    //载入节点信息，子类实现
    procedure ParserXML(); virtual;
  public
    constructor Create(AOwner: TComponent); virtual;
    destructor Destroy; override;
    //载入并解析
    function LoadXMLFile(const XmlFile: string): Boolean;
    //设置，并解析
    function SetXML(const Xml: string): Boolean;
    function GetXML(): string;
  end;

implementation

{ TBASEXMLAPI }

function TBASEXMLAPI.FormatXMLDOMNodeValue(const Node: IXMLDOMNode): string;
begin
  Result := '';
  if not assigned(Node) then Exit;
  Result := Node.text;
end;

function TBASEXMLAPI.GetSingleNodeValue(const queryString: string): string;
begin
  Result := GetSingleNodeValue(nil, queryString);
end;

function TBASEXMLAPI.GetSingleNodeValue(const ParentNode: IXMLDOMNode; const queryString: string): string;
var
  DomNode: IXMLDOMNode;
begin
  DomNode := SelectSingleNode(ParentNode, queryString);
  Result := FormatXMLDOMNodeValue(DomNode);
end;

function TBASEXMLAPI.SelectNodes(const ParentNode: IXMLDOMNode; const queryString: string): IXMLDOMNodeList;
begin
  if Assigned(ParentNode) then
    Result := ParentNode.selectNodes(queryString)
  else
    Result := (FXD.DocumentElement.DOMNode as IXMLDOMNodeRef).GetXMLDOMNode.selectNodes(queryString);
end;

function TBASEXMLAPI.SelectNodes(const queryString: string): IXMLDOMNodeList;
begin
  Result := SelectNodes(nil, queryString);
end;

function TBASEXMLAPI.SelectSingleNode(const ParentNode: IXMLDOMNode; const queryString: string): IXMLDOMNode;
begin
  if Assigned(ParentNode) then
    Result := ParentNode.selectSingleNode(queryString)
  else
    Result := (FXD.DocumentElement.DOMNode as IXMLDOMNodeRef).GetXMLDOMNode.selectSingleNode(queryString);
end;

function TBASEXMLAPI.SelectSingleNode(const queryString: string): IXMLDOMNode;
begin
  Result := SelectSingleNode(nil, queryString);
end;

function TBASEXMLAPI.GetXML: string;
begin
  Result := FXD.XML.Text;
end;

//XML 解析器初始化

constructor TBASEXMLAPI.Create(AOwner: TComponent);
begin
  FXD := TXMLDocument.Create(AOwner);
  FXD.DOMVendor := GetDOMVendor(SMSXML);
end;

//XML 解析器释放

destructor TBASEXMLAPI.Destroy;
begin
  FreeAndNil(FXD);
  //FXD.Free;
end;

function TBASEXMLAPI.LoadXMLFile(const XmlFile: string): Boolean;
var
  xmlFileList: TStringList;
  Stream: TMemoryStream;
begin
  Result := False;
  if not FileExists(XmlFile) then exit;
  xmlFileList := TStringList.Create;
  Stream := TMemoryStream.Create;
  try
    xmlFileList.LoadFromFile(XmlFile);
    xmlFileList.SaveToStream(Stream);
    Stream.Position := 0;
    FXD.Active := False;
    FXD.LoadFromStream(Stream);
    FXD.Active := True;
    //子类实现解析方法
    ParserXML();
    Result := True;
  finally
    Stream.Free;
    xmlFileList.Free;
  end;
end;

procedure TBASEXMLAPI.ParserXML;
begin
  ;
end;

function TBASEXMLAPI.SetXML(const Xml: string): Boolean;
var
  Stream: TStringStream;
begin
  Stream := TStringStream.Create(Xml);
  try
    Stream.Position := 0;
    FXD.Active := False;
    FXD.LoadFromStream(Stream);
    FXD.Active := True;
    //子类实现解析方法
    ParserXML();
    Result := True;
  finally
    Stream.Free;
  end;
end;


end.
            
