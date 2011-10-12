unit Frm_InfoShow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type
  TInfoType=(IT_Info,IT_WARN,IT_ERR,IT_Help);
  { TInfoShowFrm }

  TInfoShowFrm = class(TForm)
    ImgLst_InfoIco: TImageList;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    bmp:TBitmap;
    FInfoType:TInfoType;
    FInfoStr:String;
    procedure SetInfoType(const AValue: TInfoType);
  public
    property InfoType:TInfoType read FInfoType write SetInfoType;
    property InfoStr:String read FInfoStr write FInfoStr;
  end; 

implementation

{$R *.lfm}

{ TInfoShowFrm }

procedure TInfoShowFrm.FormPaint(Sender: TObject);
begin
  if assigned(bmp) then
     Canvas.Draw(10,10,Bmp);
  Canvas.Brush.Color:=self.Color;
  Canvas.Font.Size:=12;
  Canvas.TextOut(60,25,FInfoStr);
end;

procedure TInfoShowFrm.SetInfoType(const AValue: TInfoType);
begin
  if FInfoType=AValue then exit;
  FInfoType:=AValue;
  //载入标志图片
  ImgLst_InfoIco.GetBitmap(Ord(FInfoType),bmp);
end;

procedure TInfoShowFrm.FormCreate(Sender: TObject);
begin
  Caption:=application.Title;
  DoubleBuffered:=True;
  bmp:=TBitmap.Create;
  FInfoType:=IT_Info;
  //载入标志图片
  ImgLst_InfoIco.GetBitmap(Ord(FInfoType),bmp);
end;

procedure TInfoShowFrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if (CloseAction=caFree) then
     bmp.Free;
end;

end.

