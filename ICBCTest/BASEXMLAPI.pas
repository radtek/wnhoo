(*
    XML基础解析
    原始作者：王云涛
    建立时间：2011-12-02
*)
unit BASEXMLAPI;

interface

uses
  SysUtils, Classes,  XMLDoc, Variants,xmldom, XMLIntf, msxmldom, MSXML,NativeXml;

type
  TBASEXMLAPI = class(TObject)
  private

  protected
    FXD: TXMLDocument;
    function SelectSingleNode(const queryString: string): IXMLDOMNode; overload;
    function SelectSingleNode(const ParentNode: IDOMNode; const queryString: string): IXMLDOMNode; overload;
    //
    function SelectNodes(const queryString: string): IXMLDOMNodeList; overload;
    function SelectNodes(const ParentNode: IDOMNode; const queryString: string): IXMLDOMNodeList; overload;
    //
    function GetSingleNodeValue(const queryString: string): string; overload;
    function GetSingleNodeValue(const ParentNode: IDOMNode; const queryString: string): string; overload;
    //XML节点选择
    function SelectXMLSingleNode(const ParentNode: IXMLNode; const NodeListStr: string): IXMLNode; overload;
    function SelectXMLSingleNode(const NodeListStr: string): IXMLNode; overload;
    //XML 节点创建
    function CreateXMLNode(const ParentNode: IXMLNode;
      const NodeListStr: string): IXMLNode; overload;
    function CreateXMLNode(const NodeListStr: string): IXMLNode; overload;
    //设置 节点值
    procedure SetXMLNodeValue(const NodeListStr, Value: string);
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

//数据格式化
function FormatCDATAValue(const str: string): string;
function FormatXMLNodeValue(const Node: IXMLNode): string;
function FormatXMLDOMNodeValue(const Node: IXMLDOMNode): string;
//DOMNode -> XMLDOMNode
function GetIXMLDOMNode(const DOMNode: IDOMNode): IXMLDOMNode;
implementation

function FormatCDATAValue(const str: string): string;
begin
  Result := '<![CDATA[' + str + ']]>';
end;

function FormatXMLNodeValue(const Node: IXMLNode): string;
var
  DomNode: IXMLDOMNode;
begin
  Result := '';
  if not assigned(Node) then Exit;
  if not Node.HasChildNodes then Exit;
  DomNode := (Node as IXMLDOMNodeRef).GetXMLDOMNode;
  if not Assigned(DomNode) then Exit;
  Result := DomNode.Text;
end;

function FormatXMLDOMNodeValue(const Node: IXMLDOMNode): string;
begin
  Result := '';
  if not assigned(Node) then Exit;
  Result := Node.text;
end;

function GetIXMLDOMNode(const DOMNode: IDOMNode): IXMLDOMNode;
begin
  Result := (DOMNode as IXMLDOMNodeRef).GetXMLDOMNode;
end;

{ TBASEXMLAPI }
function TBASEXMLAPI.SelectXMLSingleNode(const NodeListStr: string): IXMLNode;
begin
  Result := SelectXMLSingleNode(FXD.Node, NodeListStr);
end;


function TBASEXMLAPI.SelectXMLSingleNode(const ParentNode: IXMLNode; const NodeListStr: string): IXMLNode;
var
  TmpNode: IXMLNode;
  NodeNameList: TStringList;
  i: Integer;
begin
  Result := nil;
  NodeNameList := TStringList.Create;
  try
    NodeNameList.Clear;
    ExtractStrings(['/'], [], PChar(NodeListStr), NodeNameList);
    TmpNode := ParentNode;
    if not assigned(TmpNode) then Exit;
    if not TmpNode.HasChildNodes then Exit;
    for i := 0 to NodeNameList.Count - 1 do
    begin
      if not assigned(TmpNode) then Exit;
      if not TmpNode.HasChildNodes then Exit;
      TmpNode := TmpNode.ChildNodes.FindNode(NodeNameList[i])
    end;
    Result := TmpNode;
  finally
    NodeNameList.Free;
  end;
end;

function TBASEXMLAPI.GetSingleNodeValue(const queryString: string): string;
begin
  Result := GetSingleNodeValue(nil, queryString);
end;

function TBASEXMLAPI.GetSingleNodeValue(const ParentNode: IDOMNode; const queryString: string): string;
var
  DomNode: IXMLDOMNode;
begin
  DomNode := SelectSingleNode(ParentNode, queryString);
  Result := FormatXMLDOMNodeValue(DomNode);
end;

function TBASEXMLAPI.SelectNodes(const ParentNode: IDOMNode; const queryString: string): IXMLDOMNodeList;
begin
  if Assigned(ParentNode) then
    Result := GetIXMLDOMNode(ParentNode).selectNodes(queryString)
  else
    Result := GetIXMLDOMNode(FXD.DocumentElement.DOMNode).selectNodes(queryString);
end;

function TBASEXMLAPI.SelectNodes(const queryString: string): IXMLDOMNodeList;
begin
  Result := SelectNodes(nil, queryString);
end;

function TBASEXMLAPI.SelectSingleNode(const ParentNode: IDOMNode; const queryString: string): IXMLDOMNode;
begin
  if Assigned(ParentNode) then
    Result := GetIXMLDOMNode(ParentNode).selectSingleNode(queryString)
  else
    Result := GetIXMLDOMNode(FXD.DocumentElement.DOMNode).selectSingleNode(queryString);
end;

function TBASEXMLAPI.SelectSingleNode(const queryString: string): IXMLDOMNode;
begin
  Result := SelectSingleNode(nil, queryString);
end;

function TBASEXMLAPI.GetXML: string;
begin
  Result := FXD.XML.Text;
end;

function TBASEXMLAPI.CreateXMLNode(const ParentNode: IXMLNode; const NodeListStr: string): IXMLNode;
var
  TmpNode: IXMLNode;
  NodeNameList: TStringList;
  i: Integer;
begin
  Result := nil;
  NodeNameList := TStringList.Create;
  try
    NodeNameList.Clear;
    ExtractStrings(['/'], [], PChar(NodeListStr), NodeNameList);
    TmpNode := ParentNode;
    if not assigned(TmpNode) then Exit;
    if not TmpNode.HasChildNodes then Exit;
    for i := 0 to NodeNameList.Count - 1 do
    begin
      if not assigned(TmpNode) then Exit;
      TmpNode := TmpNode.ChildNodes.FindNode(NodeNameList[i]);
      if not Assigned(TmpNode) then
        TmpNode := TmpNode.AddChild(NodeNameList[i]);
    end;
    Result := TmpNode;
  finally
    NodeNameList.Free;
  end;
end;

function TBASEXMLAPI.CreateXMLNode(const NodeListStr: string): IXMLNode;
begin
  Result := CreateXMLNode(FXD.Node, NodeListStr);
end;

procedure TBASEXMLAPI.SetXMLNodeValue(const NodeListStr, Value: string);
var
  XMLNode: IXMLNode;
begin
  XMLNode := CreateXMLNode(NodeListStr);
  if Assigned(XMLNode) then
    XMLNode.Text := Value;
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
    except
      ;
    end;
  finally
    Stream.Free;
    xmlFileList.Free;
  end;
end;

procedure TBASEXMLAPI.ParserXML;
begin

end;

function TBASEXMLAPI.SetXML(const Xml: string): Boolean;
var
  Stream: TStringStream;
begin
  Result := False;
  Stream := TStringStream.Create(Xml);
  try
    try
      Stream.Position := 0;
      FXD.Active := False;
      FXD.LoadFromStream(Stream);
      FXD.Active := True;
      //子类实现解析方法
      ParserXML();
      Result := True;
    except
      ;
    end;
  finally
    Stream.Free;
  end;
end;


end.
            
