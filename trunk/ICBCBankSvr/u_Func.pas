unit u_Func;

interface


uses
  SysUtils, Classes, IniFiles, Forms, u_ICBCAPI, u_ICBCRec;

type
  TICBCCtlAPI = class(TComponent)
  private
    FICBC: TICBCAPI;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //查询帐户卡余(单)
    function QueryAccValue_S(const fSeqno, AccNo0: string;
      var rtCode, rtMsg, rtStr: string): Boolean;
    //查询当日交易记录(多)
    function QueryCurDayDetails_M(const fSeqno, AccNo: string;
      var NextTag, rtCode, rtMsg, rtStr: string): Boolean;
    //支付指令(单)
    function PayEnt_S(const fSeqno, RecAccNo, RecAccNameCN, PayAmt, UseCN, PostScript, Summary: string;
      var rtCode, rtMsg, rtStr: string): Boolean;
    //查询支付指令(单)
    function QueryPayEnt_S(const fSeqno, QryfSeqno: string;
      var rtCode, rtMsg, rtStr: string): Boolean;
    //扣个人指令(单)
    function PerDis_S(const fSeqno, PayAccNo, PayAccNameCN, Portno, ContractNo, PayAmt, UseCN, PostScript, Summary: string;
      var rtCode, rtMsg, rtStr: string): Boolean;
    //查询扣个人指令(单)
    function QueryPerDis_S(const fSeqno, QryfSeqno: string;
      var rtCode, rtMsg, rtStr: string): Boolean;
    //查询历史明细
    function QueryHistoryDetails_M(const fSeqno, AccNo, BeginDate,
      EndDate: string; var NextTag, rtCode, rtMsg, rtStr: string): Boolean;
  end;

var
  U_SvrPort: Word;
  U_CIS, U_BankCode, U_CAID: string;
  U_EPAccNo, U_EPAccNameCN, U_EPAccBankName: string;
  U_SIGN_URL, U_HTTPS_URL: string;
  U_ICBCCtl: TICBCCtlAPI;
procedure LoadCfg();
implementation

procedure LoadCfg();
var
  inicfg: TIniFile;
begin
  inicfg := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'BankCfg.ini');
  try
    U_SvrPort := inicfg.ReadInteger('BankSvr', 'SvrPort', 10008);
    U_CIS := inicfg.ReadString('BankSvr', 'CIS', '');
    U_BankCode := inicfg.ReadString('BankSvr', 'BankCode', '2');
    U_CAID := inicfg.ReadString('BankSvr', 'CAID', '');
    U_EPAccNo := inicfg.ReadString('BankSvr', 'EPAccNo', '5');
    U_EPAccNameCN := inicfg.ReadString('BankSvr', 'EPAccNameCN', '');
    U_EPAccBankName := inicfg.ReadString('BankSvr', 'EPAccBankName', '工商银行');

    U_SIGN_URL := inicfg.ReadString('NCSvr', 'SIGN_URL', 'http://127.0.0.1:449');
    U_HTTPS_URL := inicfg.ReadString('NCSvr', 'HTTPS_URL', 'http://127.0.0.1:448');
  finally
    inicfg.Free;
  end;
end;

{ TICBCCtlAPI }

function TICBCCtlAPI.QueryAccValue_S(const fSeqno, AccNo0: string;
  var rtCode, rtMsg, rtStr: string): Boolean;
var
  qav: TQueryAccValueRec;
  I: Integer;
  rtDataStr: string;
begin
  rtMsg := '';
  rtStr := '';
  Result := False;
  try
    FillChar(qav, SizeOf(TQueryAccValueRec), 0);
    //单帐户查询
    qav.TotalNum := '1';
    SetLength(qav.rd, 1);
    FillChar(qav.rd[0], SizeOf(qav.rd[0]), 0);
    qav.rd[0].iSeqno := '0';
    qav.rd[0].AccNo := AccNo0;

    if not FICBC.QueryAccValue(fSeqno, qav, rtDataStr) then
    begin
      rtMsg := rtDataStr;
      Exit;
    end;

    for I := Low(qav.rd) to High(qav.rd) do
    begin
      rtStr := rtStr +
        qav.rd[I].iSeqno + '|' +
        qav.rd[I].AccNo + '|' +
        qav.rd[I].CurrType + '|' +
        qav.rd[I].CashExf + '|' +
        qav.rd[I].AcctProperty + '|' +
        qav.rd[I].AccBalance + '|' +
        qav.rd[I].Balance + '|' +
        qav.rd[I].UsableBalance + '|' +
        qav.rd[I].FrzAmt + '|' +
        qav.rd[I].QueryTime + '|' +
        qav.rd[I].iRetCode + '|' +
        qav.rd[I].iRetMsg + '|' +
        qav.rd[I]._Reserved3 + '|' +
        qav.rd[I]._Reserved4 + #13#10
    end;
    Result := rtStr <> '';
  except
    on Ex: Exception do
      rtMsg := Ex.Message;
  end;
end;

function TICBCCtlAPI.QueryCurDayDetails_M(const fSeqno, AccNo: string;
  var NextTag, rtCode, rtMsg, rtStr: string): Boolean;
var
  qcd: TQueryCurDayDetailsRec;
  I: Integer;
  rtDataStr: string;
begin
  rtMsg := '';
  rtStr := '';
  Result := False;
  try
    FillChar(qcd, SizeOf(TQueryCurDayDetailsRec), 0);
    qcd.AccNo := AccNo;
    qcd.MinAmt := '0';
    qcd.MaxAmt := '100000000';
    qcd.NextTag := NextTag;

    if not FICBC.QueryCurDayDetails(fSeqno, qcd, rtDataStr) then
    begin
      rtMsg := rtDataStr;
      Exit;
    end;

    NextTag := qcd.NextTag;

    for I := Low(qcd.rd) to High(qcd.rd) do
    begin
      rtStr := rtStr +
        qcd.rd[I].Drcrf + '|' +
        qcd.rd[I].VouhNo + '|' +
        qcd.rd[I].Amount + '|' +
        qcd.rd[I].RecipBkNo + '|' +
        qcd.rd[I].RecipAccNo + '|' +
        qcd.rd[I].RecipName + '|' +
        qcd.rd[I].Summary + '|' +
        qcd.rd[I].UseCN + '|' +
        qcd.rd[I].PostScript + '|' +
        qcd.rd[I].Ref + '|' +
        qcd.rd[I].BusCode + '|' +
        qcd.rd[I].Oref + '|' +
        qcd.rd[i].EnSummary + '|' +
        qcd.rd[i].BusType + '|' +
        qcd.rd[i].CvouhType + '|' +
        qcd.rd[i].AddInfo + '|' +
        qcd.rd[i].TimeStamp + '|' +
        qcd.rd[i]._Reserved3 + '|' +
        qcd.rd[i]._Reserved4 + #13#10;
    end;
    Result := rtStr <> '';
  except
    on Ex: Exception do
      rtMsg := Ex.Message;
  end;
end;

function TICBCCtlAPI.QueryHistoryDetails_M(const fSeqno, AccNo, BeginDate, EndDate: string;
  var NextTag, rtCode, rtMsg, rtStr: string): Boolean;
var
  qhd: TQueryHistoryDetailsRec;
  I: Integer;
  rtDataStr: string;
begin
  rtMsg := '';
  rtStr := '';
  Result := False;
  try
    FillChar(qhd, SizeOf(TQueryHistoryDetailsRec), 0);
    qhd.AccNo := AccNo;
    qhd.BeginDate := BeginDate;
    qhd.EndDate := EndDate;
    qhd.MinAmt := '0';
    qhd.MaxAmt := '100000000';
    qhd.NextTag := NextTag;

    if not FICBC.QueryHistoryDetails(fSeqno, qhd, rtDataStr) then
    begin
      rtMsg := rtDataStr;
      Exit;
    end;

    NextTag := qhd.NextTag;

    for I := Low(qhd.rd) to High(qhd.rd) do
    begin
      rtStr := rtStr +
        qhd.rd[I].Drcrf + '|' +
        qhd.rd[I].VouhNo + '|' +
        qhd.rd[I].DebitAmount + '|' +
        qhd.rd[I].CreditAmount + '|' +
        qhd.rd[I].Balance + '|' +
        qhd.rd[I].RecipBkNo + '|' +
        qhd.rd[I].RecipBkName + '|' +
        qhd.rd[I].RecipAccNo + '|' +
        qhd.rd[I].RecipName + '|' +
        qhd.rd[I].Summary + '|' +
        qhd.rd[I].UseCN + '|' +
        qhd.rd[I].PostScript + '|' +
        qhd.rd[i].BusCode + '|' +
        qhd.rd[i].Date + '|' +
        qhd.rd[i].Time + '|' +
        qhd.rd[i].Ref + '|' +
        qhd.rd[i].Oref + '|' +
        qhd.rd[i].EnSummary + '|' +
        qhd.rd[i].BusType + '|' +
        qhd.rd[i].VouhType + '|' +
        qhd.rd[i].AddInfo + '|' +
        qhd.rd[i]._Reserved3 + '|' +
        qhd.rd[i]._Reserved4 + #13#10;
    end;
    Result := rtStr <> '';
  except
    on Ex: Exception do
      rtMsg := Ex.Message;
  end;
end;

constructor TICBCCtlAPI.Create(AOwner: TComponent);
begin
  inherited;
  FICBC := TICBCAPI.Create(self);
  FICBC.CIS := U_CIS;
  FICBC.BankCode := U_BankCode;
  FICBC.ID := U_CAID;
  FICBC.SIGN_URL := U_SIGN_URL;
  FICBC.HTTPS_URL := U_HTTPS_URL;
end;

destructor TICBCCtlAPI.Destroy;
begin
  FICBC.Free;
  inherited;
end;

function TICBCCtlAPI.PayEnt_S(const fSeqno, RecAccNo, RecAccNameCN, PayAmt, UseCN, PostScript, Summary: string;
  var rtCode, rtMsg, rtStr: string): Boolean;
var
  pe: TPayEntRec;
  I: Integer;
  rtDataStr: string;
begin
  rtMsg := '';
  rtStr := '';
  Result := False;
  try
    FillChar(pe, SizeOf(TPayEntRec), 0);
    pe.OnlBatF := '1'; //联机
    pe.SettleMode := '0'; //逐笔记账
    pe.TotalNum := '1'; //
    pe.TotalAmt := PayAmt; //
    pe.SignTime := FormatDateTime('YYYYMMDDhhnnsszzz', Now);
    SetLength(pe.rd, 1);

    FillChar(pe.rd[0], SizeOf(pe.rd[0]), 0);
    pe.rd[0].iSeqno := '0';
    pe.rd[0].PayType := '1'; //加急

    pe.rd[0].PayAccNo := U_EPAccNo;
    pe.rd[0].PayAccNameCN := U_EPAccNameCN;
    pe.rd[0].RecAccNo := RecAccNo;
    pe.rd[0].RecAccNameCN := RecAccNameCN;

    pe.rd[0].SysIOFlg := '1';
    pe.rd[0].RecBankName := '工商银行';
    pe.rd[0].CurrType := '001';
    pe.rd[0].PayAmt := PayAmt;
    //对私情况下,用途和备注不能同时为空
    pe.rd[0].UseCN := UseCN;
    pe.rd[0].PostScript := PostScript;
    pe.rd[0].Summary := Summary;

    if not FICBC.PayEnt(fSeqno, pe, rtDataStr) then
    begin
      rtMsg := rtDataStr;
      Exit;
    end;

    for I := Low(pe.rd) to High(pe.rd) do
    begin
      rtStr := rtStr +
        pe.rd[i].iSeqno + '|' +
        pe.rd[i].OrderNo + '|' +
        pe.rd[i].ReimburseNo + '|' +
        pe.rd[I].ReimburseNum + '|' +
        pe.rd[I].StartDate + '|' +
        pe.rd[I].StartTime + '|' +
        pe.rd[I].PayType + '|' +
        pe.rd[I].PayAccNo + '|' +
        pe.rd[I].PayAccNameCN + '|' +
        pe.rd[I].PayAccNameEN + '|' +
        pe.rd[I].RecAccNo + '|' +
        pe.rd[I].RecAccNameCN + '|' +
        pe.rd[i].RecAccNameEN + '|' +
        pe.rd[i].SysIOFlg + '|' +
        pe.rd[i].IsSameCity + '|' +
        pe.rd[i].Prop + '|' +
        pe.rd[i].RecICBCCode + '|' +
        pe.rd[i].RecCityName + '|' +
        pe.rd[i].RecBankNo + '|' +
        pe.rd[i].RecBankName + '|' +
        pe.rd[i].CurrType + '|' +
        pe.rd[i].PayAmt + '|' +
        pe.rd[i].UseCode + '|' +
        pe.rd[i].UseCN + '|' +
        pe.rd[i].EnSummary + '|' +
        pe.rd[i].PostScript + '|' +
        pe.rd[i].Summary + '|' +
        pe.rd[i].Ref + '|' +
        pe.rd[i].Oref + '|' +
        pe.rd[i].ERPSqn + '|' +
        pe.rd[i].BusCode + '|' +
        pe.rd[i].ERPcheckno + '|' +
        pe.rd[i].CrvouhType + '|' +
        pe.rd[i].CrvouhName + '|' +
        pe.rd[i].CrvouhNo + '|' +
        pe.rd[i].Result + '|' +
        pe.rd[i].iRetCode + '|' +
        pe.rd[i].iRetMsg + '|' +
        pe.rd[i]._Reserved3 + '|' +
        pe.rd[i]._Reserved4 + #13#10;
    end;
    Result := rtStr <> '';
  except
    on Ex: Exception do
      rtMsg := Ex.Message;
  end;
end;

function TICBCCtlAPI.QueryPayEnt_S(const fSeqno, QryfSeqno: string;
  var rtCode, rtMsg, rtStr: string): Boolean;
var
  qpe: TQueryPayEntRec;
  I: Integer;
  rtDataStr: string;
begin
  rtMsg := '';
  rtStr := '';
  Result := False;
  try
    FillChar(qpe, SizeOf(TQueryPayEntRec), 0);
    qpe.QryfSeqno := QryfSeqno;
    SetLength(qpe.rd, 1);
    FillChar(qpe.rd[0], SizeOf(qpe.rd[0]), 0);
    qpe.rd[0].iSeqno := '0';
    qpe.rd[0].QryiSeqno := '0';

    if not FICBC.QueryPayEnt(fSeqno, qpe, rtDataStr) then
    begin
      rtMsg := rtDataStr;
      Exit;
    end;

    for I := Low(qpe.rd) to High(qpe.rd) do
    begin
      rtStr := rtStr +
        qpe.rd[I].iSeqno + '|' +
        qpe.rd[I].QryiSeqno + '|' +
        qpe.rd[I].QryOrderNo + '|' +
        qpe.rd[I].ReimburseNo + '|' +
        qpe.rd[I].ReimburseNum + '|' +
        qpe.rd[I].StartDate + '|' +
        qpe.rd[I].StartTime + '|' +
        qpe.rd[I].PayType + '|' +
        qpe.rd[I].PayAccNo + '|' +
        qpe.rd[i].PayAccNameCN + '|' +
        qpe.rd[i].PayAccNameEN + '|' +
        qpe.rd[i].RecAccNo + '|' +
        qpe.rd[i].RecAccNameCN + '|' +
        qpe.rd[i].RecAccNameEN + '|' +
        qpe.rd[i].SysIOFlg + '|' +
        qpe.rd[i].IsSameCity + '|' +
        qpe.rd[i].RecICBCCode + '|' +
        qpe.rd[i].RecCityName + '|' +
        qpe.rd[i].RecBankNo + '|' +
        qpe.rd[i].RecBankName + '|' +
        qpe.rd[i].CurrType + '|' +
        qpe.rd[i].PayAmt + '|' +
        qpe.rd[i].UseCode + '|' +
        qpe.rd[i].UseCN + '|' +
        qpe.rd[i].EnSummary + '|' +
        qpe.rd[i].PostScript + '|' +
        qpe.rd[I].Summary + '|' +
        qpe.rd[i].Ref + '|' +
        qpe.rd[i].Oref + '|' +
        qpe.rd[i].ERPSqn + '|' +
        qpe.rd[i].BusCode + '|' +
        qpe.rd[i].ERPcheckno + '|' +
        qpe.rd[i].CrvouhType + '|' +
        qpe.rd[i].CrvouhName + '|' +
        qpe.rd[i].CrvouhNo + '|' +
        qpe.rd[i].iRetCode + '|' +
        qpe.rd[i].iRetMsg + '|' +
        qpe.rd[i].Result + '|' +
        qpe.rd[i].instrRetCode + '|' +
        qpe.rd[i].instrRetMsg + '|' +
        qpe.rd[i].BankRetTime + '|' +
        qpe.rd[i]._Reserved3 + '|' +
        qpe.rd[i]._Reserved4 + #13#10;
    end;
    Result := rtStr <> '';
  except
    on Ex: Exception do
      rtMsg := Ex.Message;
  end;
end;


function TICBCCtlAPI.PerDis_S(const fSeqno, PayAccNo, PayAccNameCN, Portno, ContractNo, PayAmt, UseCN, PostScript, Summary: string;
  var rtCode, rtMsg, rtStr: string): Boolean;
var
  pd: TPerDisRec;
  I: Integer;
  rtDataStr: string;
begin
  rtMsg := '';
  rtStr := '';
  Result := False;
  try
    FillChar(pd, SizeOf(TPerDisRec), 0);
    pd.OnlBatF := '1'; //联机
    pd.SettleMode := '0'; //逐笔记账
    pd.RecAccNo := U_EPAccNo;
    pd.RecAccNameCN := U_EPAccNameCN;
    pd.TotalNum := '1';
    pd.TotalAmt := PayAmt;
    pd.SignTime := FormatDateTime('YYYYMMDDhhnnsszzz', Now);
    SetLength(pd.rd, 1);
    FillChar(pd.rd[0], SizeOf(pd.rd[0]), 0);
    pd.rd[0].iSeqno := '0';
    pd.rd[0].PayAccNo := PayAccNo;
    pd.rd[0].PayAccNameCN := PayAccNameCN;
    pd.rd[0].PayBranch := '工商银行';
    pd.rd[0].Portno := Portno; //		缴费编号	必输项	字符	30
    pd.rd[0].ContractNo := ContractNo; //		协议编号	必输项	字符	15
    pd.rd[0].CurrType := '001';
    pd.rd[0].PayAmt := PayAmt;
    //对私情况下,用途和备注不能同时为空
    pd.rd[0].UseCN := UseCN;
    pd.rd[0].PostScript := PostScript;
    pd.rd[0].Summary := Summary;

    if not FICBC.PerDis(fSeqno, pd, rtDataStr) then
    begin
      rtMsg := rtDataStr;
      Exit;
    end;

    for I := Low(pd.rd) to High(pd.rd) do
    begin
      rtStr := rtStr +
        pd.rd[i].iSeqno + '|' +
        pd.rd[i].OrderNo + '|' +
        pd.rd[I].PayAccNo + '|' +
        pd.rd[I].PayAccNameCN + '|' +
        pd.rd[I].PayAccNameEN + '|' +
        pd.rd[I].PayBranch + '|' +
        pd.rd[I].Portno + '|' +
        pd.rd[I].ContractNo + '|' +
        pd.rd[I].CurrType + '|' +
        pd.rd[i].PayAmt + '|' +
        pd.rd[i].UseCode + '|' +
        pd.rd[i].UseCN + '|' +
        pd.rd[i].EnSummary + '|' +
        pd.rd[i].PostScript + '|' +
        pd.rd[I].Summary + '|' +
        pd.rd[i].Ref + '|' +
        pd.rd[i].Oref + '|' +
        pd.rd[i].ERPSqn + '|' +
        pd.rd[i].BusCode + '|' +
        pd.rd[i].ERPcheckno + '|' +
        pd.rd[i].CrvouhType + '|' +
        pd.rd[i].CrvouhName + '|' +
        pd.rd[i].CrvouhNo + '|' +
        pd.rd[i].Result + '|' +
        pd.rd[i].iRetCode + '|' +
        pd.rd[i].iRetMsg + '|' +
        pd.rd[i]._Reserved3 + '|' +
        pd.rd[i]._Reserved4 + #13#10;
    end;
    Result := rtStr <> '';
  except
    on Ex: Exception do
      rtMsg := Ex.Message;
  end;
end;

function TICBCCtlAPI.QueryPerDis_S(const fSeqno, QryfSeqno: string;
  var rtCode, rtMsg, rtStr: string): Boolean;
var
  qpd: TQueryPerDisRec;
  I: Integer;
  rtDataStr: string;
begin
  rtMsg := '';
  rtStr := '';
  Result := False;
  try
    FillChar(qpd, SizeOf(TQueryPerDisRec), 0);
    qpd.QryfSeqno := QryfSeqno;
    SetLength(qpd.rd, 1);
    FillChar(qpd.rd[0], SizeOf(qpd.rd[0]), 0);
    qpd.rd[0].iSeqno := '0';
    qpd.rd[0].QryiSeqno := '0';

    if not FICBC.QueryPerDis(fSeqno, qpd, rtDataStr) then
    begin
      rtMsg := rtDataStr;
      Exit;
    end;

    for I := Low(qpd.rd) to High(qpd.rd) do
    begin
      rtStr := rtStr +
        qpd.rd[I].iSeqno + '|' +
        qpd.rd[I].QryiSeqno + '|' +
        qpd.rd[I].QryOrderNo + '|' +
        qpd.rd[I].Portno + '|' +
        qpd.rd[I].OpType + '|' +
        qpd.rd[I].ContractNo + '|' +
        qpd.rd[I].PayAccNo + '|' +
        qpd.rd[I].PayAccNameCN + '|' +
        qpd.rd[I].PayAccNameEN + '|' +
        qpd.rd[i].PayBranch + '|' +
        //qpd.rd[i].CurrType + '|' +
      qpd.rd[i].PayAmt + '|' +
        qpd.rd[i].UseCode + '|' +
        qpd.rd[i].UseCN + '|' +
        qpd.rd[i].UserRem + '|' +
        qpd.rd[i].PostScript + '|' +
        qpd.rd[I].Summary + '|' +
        qpd.rd[i].Ref + '|' +
        qpd.rd[i].Oref + '|' +
        qpd.rd[i].ERPSqn + '|' +
        qpd.rd[i].BusCode + '|' +
        qpd.rd[i].ERPcheckno + '|' +
        qpd.rd[i].CrvouhType + '|' +
        qpd.rd[i].CrvouhName + '|' +
        qpd.rd[i].CrvouhNo + '|' +
        qpd.rd[i].Result + '|' +
        qpd.rd[i].BankRem + '|' +
        qpd.rd[i].BankRetime + '|' +
        qpd.rd[i].iRetCode + '|' +
        qpd.rd[i].iRetMsg + '|' +
        qpd.rd[i]._Reserved3 + '|' +
        qpd.rd[i]._Reserved4 + #13#10;
    end;
    Result := rtStr <> '';
  except
    on Ex: Exception do
      rtMsg := Ex.Message;
  end;
end;


end.

