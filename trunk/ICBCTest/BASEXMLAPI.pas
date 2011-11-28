(*
    XML��������
    ԭʼ���ߣ�������
    ����ʱ�䣺2011-12-02
*)
unit BASEXMLAPI;

interface

uses
  SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, Variants,MSXML;

type
  TBASEXMLAPI = class(TObject)
  private
    function GetIXMLDOMNode: IXMLDOMNode;
  protected
    FXD: TXMLDocument;
    function SelectSingleNode(const queryString: String):IXMLDOMNode;
    //XML�ڵ�ѡ��
    function SelectXMLNode(const ParentNode: IXMLNode; const NodeListStr: string): IXMLNode; overload;
    function SelectXMLNode(const NodeListStr: string): IXMLNode; overload;
    //XML �ڵ㴴��
    function CreateXMLNode(const ParentNode: IXMLNode;
      const NodeListStr: string): IXMLNode; overload;
    function CreateXMLNode(const NodeListStr: string): IXMLNode; overload;
    //���� �ڵ�ֵ
    procedure SetXMLNodeValue(const NodeListStr, Value: string);
    //����ڵ���Ϣ������ʵ��
    procedure ParserXML(); virtual;
  public
    constructor Create(AOwner: TComponent) ; virtual;
    destructor Destroy;override;
    //���벢����
    function LoadXMLFile(const XmlFile:String): Boolean;
    //���ã�������
    function SetXML(const Xml:String): Boolean;
    function GetXML():String;
  end;

//���ݸ�ʽ��
function FormatCDATAValue(const str: string): string;
function FormatXMLNodeValue(const Node: IXMLNode): string;
function FormatXMLDOMNodeValue(const Node: IXMLDOMNode): string;

implementation

function FormatCDATAValue(const str: string): string;
begin
  Result := '<![CDATA[' + str + ']]>';
end;

function FormatXMLNodeValue(const Node: IXMLNode): string;
begin
  Result := '';
  if not assigned(Node) then Exit;
  if not Node.HasChildNodes then Exit;
  Result :=Node.Text;
end;

function FormatXMLDOMNodeValue(const Node: IXMLDOMNode): string;
begin
  Result := '';
  if not assigned(Node) then Exit;
  Result :=Node.text;
end;


{ TBASEXMLAPI }

function TBASEXMLAPI.SelectXMLNode(const ParentNode: IXMLNode; const NodeListStr: string): IXMLNode;
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

function TBASEXMLAPI.SelectSingleNode(const queryString: String): IXMLDOMNode;
begin
  Result:=GetIXMLDOMNode.selectSingleNode(queryString);
end;

function TBASEXMLAPI.SelectXMLNode(const NodeListStr: string): IXMLNode;
begin
  Result := SelectXMLNode(FXD.Node, NodeListStr);
end;

function   TBASEXMLAPI.GetIXMLDOMNode():IXMLDOMNode;
begin
   Result:=(FXD.DocumentElement.DOMNode   as   IXMLDOMNodeRef).GetXMLDOMNode;
end;

function TBASEXMLAPI.GetXML: String;
begin
  Result:=FXD.XML.Text;
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
  Result := SelectXMLNode(FXD.Node, NodeListStr);
end;

procedure TBASEXMLAPI.SetXMLNodeValue(const NodeListStr, Value: string);
var
  XMLNode: IXMLNode;
begin
  XMLNode := CreateXMLNode(NodeListStr);
  if Assigned(XMLNode) then
    XMLNode.Text := Value;
end;

//XML ��������ʼ��

constructor TBASEXMLAPI.Create(AOwner: TComponent);
begin
  FXD := TXMLDocument.Create(AOwner);
  FXD.DOMVendor := GetDOMVendor(SMSXML);
end;

//XML �������ͷ�

destructor TBASEXMLAPI.Destroy;
begin
  FXD.Free;
end;

function TBASEXMLAPI.LoadXMLFile(const XmlFile:String): Boolean;
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
      FXD.Active:=False;
      FXD.LoadFromStream(Stream);
      FXD.Active := True;
      //����ʵ�ֽ�������
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

function TBASEXMLAPI.SetXML(const Xml:String): Boolean;
var
  Stream: TStringStream;
begin
  Result := False;
  Stream := TStringStream.Create(Xml);
  try
    try
      Stream.Position := 0;
      FXD.Active:=False;
      FXD.LoadFromStream(Stream);
      FXD.Active := True;
      //����ʵ�ֽ�������
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
            
