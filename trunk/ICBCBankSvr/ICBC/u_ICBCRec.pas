unit u_ICBCRec;

interface

type

  //公共头
  TPubRec = packed record
    TransCode: array[0..10] of Char; //	交易代码	必输项	字符	10	PAYENT
    CIS: string[60]; //	集团CIS号	必输项	字符	60	客户注册时的归属编码
    BankCode: string[3]; //	归属银行编号	必输项	字符	3	客户注册时的归属单位
    ID: string[40]; //	证书ID	必输项	字符	40	无证书客户可上送空
    TranDate: string[8]; //	交易日期	必输项	字符	8	ERP系统产生的交易日期，格式是yyyyMMdd
    TranTime: string[12]; //	交易时间	必输项	字符	12	ERP系统产生的交易时间，格式如hhmmssaaabbb，精确到微秒；
    fSeqno: string[35]; //	指令包序列号	必输项	字符	35	ERP系统产生的指令包序列号，一个集团永远不能重复；
    //返回专用..................................................................
    //支付指令、批扣个人返回专用...........................
    SerialNo: string[15]; //	平台交易流水号	否	字符	15	银行产生的银行批次号
    //...........................................
    RetCode: string[5]; //	交易返回码	否	字符	5
    RetMsg: string[100]; //	交易返回描述	否	字符	100
    //..........................................................................
  end;

  //查询当日明细
  TQueryCurDayDetailsRec = packed record
    AccNo: string[19]; //	查询账号	必输项	数字	19
    //返回专用..................................................................
    AccName: string[80]; //	户名	否	字符	80
    CurrType: string[3]; //	币种	否	字符	3
    //..........................................................................
    AreaCode: string[4]; //	地区代码	选输项	数字	4	4位工行地区代码
    MinAmt: string[17]; //	发生额下限	选输项	数字	17	若输入则必须为大于或等于零的整数，单位为分
    MaxAmt: string[17]; //	发生额上限	选输项	数字	17	若输入则必须为大于或等于零的整数，单位为分.发生额上下限都有值时则下限必须小于等于上限
    BeginTime: string[8]; //	预留，目前无意义
    EndTime: string[8]; //	预留，目前无意义
    NextTag: string[60]; //	查询下页标识	选输项	字符	60	查询首页上送空；其他页需与银行返回包提供的一致
    //返回专用..................................................................
    TotalNum: string[6]; //	交易条数	否	数字	6
    //..........................................................................
    _Reserved1: string[3]; //	请求包备用字段1	选输项	数字	3	行别,集团有他行帐号时为必输
    _Reserved2: string[100]; //	请求包备用字段2	选输项	字符	100	备用，目前无意义
    //返回专用..................................................................
    rd: array of packed record
      Drcrf: string[1]; //	借贷标志	否	数字	1	1:借 2:贷
      VouhNo: string[9]; //	凭证号	否	字符	9
      Amount: string[17]; //		发生额	否	数字	17	无正负号，不带小数点，以币种的最小单位为单位
      RecipBkNo: string[13]; //		对方行号	否	字符	13
      RecipAccNo: string[34]; //		对方账号	否	数字	34
      RecipName: string[60]; //		对方户名	否	字符	60
      Summary: string[20]; //		摘要	否	字符	20
      UseCN: string[20]; //		用途	否	字符	20
      PostScript: string[100]; //		附言	否	字符	100
      Ref: string[20]; //		业务编号	否	字符	20
      BusCode: string[5]; //		业务代码	否	字符	5
      Oref: string[20]; //		相关业务编号	否	字符	20
      EnSummary: string[40]; //		英文备注	否	字符	40
      BusType: string[3]; //		业务种类	否	字符	3
      CvouhType: string[3]; //		凭证种类	否	字符	3
      AddInfo: string[210]; //		附加信息	否	字符	210
      TimeStamp: string[26]; //		时间戳	否	字符	26
      _Reserved3: string[100]; //	响应备用字段3	否	字符	100	集团如果开通了“电子回单”的高级功能,则返回"地区号|网点号|柜员号|主机交易流水号"
      _Reserved4: string[100]; //	响应备用字段4	否	字符	100	备用，目前无意义
    end;
    //..........................................................................
  end;


  //查询历史明细
  TQueryHistoryDetailsRec = packed record
    AccNo: string[19]; //	查询账号	必输项	数字	19
    //返回专用..................................................................
    AccName: string[80]; //	户名	否	字符	80
    CurrType: string[3]; //	币种	否	字符	3
    //..........................................................................
    BeginDate: string[8]; //	起始日期	必输项	数字	8	起始日期必须小于等于截止日期；
    EndDate: string[8]; //	截止日期	必输项	数字	8	格式是yyyyMMdd
    MinAmt: string[17]; //	发生额下限	选输项	数字	17	若输入则必须为大于或等于零的整数，单位为分
    MaxAmt: string[17]; //	发生额上限	选输项	数字	17	若输入则必须为大于或等于零的整数，单位为分.发生额上下限都有值时则下限必须小于等于上限
    NextTag: string[60]; //	查询下页标识	选输项	字符	60	查询首页上送空；其他页需与银行返回包提供的一致
    //返回专用..................................................................
    TotalNum: string[6]; //	交易条数	否	数字	6
    //..........................................................................
    _Reserved1: string[3]; //	请求包备用字段1	选输项	数字	3	行别,集团有他行帐号时为必输
    _Reserved2: string[100]; //	请求包备用字段2	选输项	字符	100	备用，目前无意义
    //返回专用..................................................................
    rd: array of packed record
      Drcrf: string[1]; //	借贷标志	否	数字	1	1:借 2:贷
      VouhNo: string[9]; //	凭证号	否	字符	9
      DebitAmount: string[18]; //	借方发生额	否	数字	18	以币种的最小单位为单位
      CreditAmount: string[18]; //	贷方发生额	否	数字	18	以币种的最小单位为单位
      Balance: string[18]; //	余额	否	数字	18	以币种的最小单位为单位
      RecipBkNo: string[12]; //	对方行号	否	字符	12
      RecipBkName: string[140]; //	对方行名	否	字符	140
      RecipAccNo: string[34]; //	对方账号	否	字符	34
      RecipName: string[140]; //	对方户名	否	字符	140
      Summary: string[20]; //	摘要	否	字符	20
      UseCN: string[20]; //	用途	否	字符	20

      PostScript: string[100]; //	附言	否	字符	100
      BusCode: string[5]; //	业务代码	否	字符	5
      Date: string[8]; //	交易日期	否	字符	8	yyyyMMdd
      Time: string[26]; //	时间戳	否	字符	26
      Ref: string[20]; //	业务编号	否	字符	20
      Oref: string[20]; //	相关业务编号	否	字符	20
      EnSummary: string[40]; // 	英文备注	否	字符	40
      BusType: string[3]; //	业务种类	否	字符	3
      VouhType: string[3]; //	凭证种类	否	字符	3
      AddInfo: string[210]; //	附加信息	否	字符	210
      _Reserved3: string[100]; //	响应备用字段3	否	字符	100	集团如果开通了“电子回单”的高级功能,则返回"地区号|网点号|柜员号|主机交易流水号"
      _Reserved4: string[100]; //	响应备用字段4	否	字符	100	备用，目前无意义
    end;
    //..........................................................................
  end;

  //多账户余额查询
  TQueryAccValueRec = packed record
    //发送专用..................................................................
    TotalNum: string[6]; //	总笔数	必输项	数字	6	需要查询明细的笔数
    _Reserved1: string[100]; //	请求包备用字段1	选输项	字符	100	备用，目前无意义
    _Reserved2: string[100]; //	请求包备用字段2	选输项	字符	100	备用，目前无意义
    //..........................................................................
    rd: array of packed record
      iSeqno: string[35]; //	指令顺序号	必输项	字符	35	不能为空，并且不能重复
      AccNo: string[19]; //	帐号	必输项	数字	19
      CurrType: string[3]; //	币种	选输项	字符	3	工行币种代码,不输入则自动取帐号币种
      //返回专用................................................................
      CashExf: string[1]; //	钞汇标志	否	数字	1	0：钞 1：汇
      AcctProperty: string[1]; //	账户属性	否	数字	1	1：基本户 2：一般结算户 3：临时户 4：专用户 6：集团二级户 7：协定存款户 8：保证金户
      AccBalance: string[20]; //	昨日余额	否	数字	20	以币种的最小单位为单位
      Balance: string[20]; //	当前余额	否	数字	20	以币种的最小单位为单位
      UsableBalance: string[20]; //	可用余额	否	数字	20	以币种的最小单位为单位
      FrzAmt: string[20]; //	冻结额度合计	否	数字	20	以币种的最小单位为单位
      QueryTime: string[20]; //	查询时间	否	数字	20
      iRetCode: string[5]; //	返回码	否	字符	5
      iRetMsg: string[100]; //	返回描述	否	字符	100
      //........................................................................
      _Reserved3: string[3]; //	请求包备用字段3	选输项	数字	3	行别,集团有他行帐号时为必输项
      _Reserved4: string[100]; //	请求包备用字段4	选输项	字符	100	备用，目前无意义
    end;
  end;

  //支付指令提交
  TPayEntRec = packed record
    OnlBatF: string[1]; //	联机批量标志	选输项	数字	1	1：联机
    SettleMode: string[1]; //	入账方式	必输项	数字	1	2：并笔入账 0：逐笔记账
    TotalNum: string[6]; //	总笔数	必输项	数字	6	指令包内的指令笔数
    TotalAmt: string[20]; //	总金额	必输项	数字	20	无正负号，不带小数点，以分作单位
    //发送专用..................................................................
    SignTime: string[17]; //	签名时间	必输项	字符	17	格式是yyyyMMddhhmmssSSS
    //..........................................................................
    _Reserved1: string[100]; //	请求备用字段1	选输项	字符	100	备用，目前无意义
    _Reserved2: string[100]; //	请求备用字段2	选输项	字符	100	备用，目前无意义
    rd: array of packed record
      iSeqno: string[35]; //	指令顺序号	必输项	字符	35	每笔指令的序号，本包内不重复。（工行只检查包内不重复，不同的包，工行不做指令顺序号重复性的检查。）
      //返回专用................................................................
      OrderNo: string[6]; //	平台交易序号	否	字符	6	银行产生的批次内的小序号
      //........................................................................
      ReimburseNo: string[40]; //	自定义序号	选输项	字符	40
      ReimburseNum: string[10]; //	单据张数	选输项	字符	10
      StartDate: string[8]; //	定时启动日期	选输项	字符	8	格式是yyyyMMdd
      StartTime: string[6]; //	定时启动时间	选输项	字符	6	格式是hhmmss
      PayType: string[1]; //	记账处理方式	必输项	数字	1	1：加急 2：普通
      PayAccNo: string[34]; //	本方账号	必输项	数字	34
      PayAccNameCN: string[100]; //	本方账户名称	选输项	字符	100	根据人行标准，人民币账户的户名不应超过60字节，否则该字段可能被截取
      PayAccNameEN: string[100]; //	本方账户英文名称	选输项	字符	100	中文名称、英文名称二者必输其一。
      RecAccNo: string[34]; //	对方账号	必输项	字符	34
      RecAccNameCN: string[100]; //	对方账户名称	选输项	字符	100	根据人行标准，人民币账户的户名不应超过60字节，否则该字段可能被截取
      RecAccNameEN: string[100]; //	对方账户英文名称	选输项	字符	100	中文名称、英文名称二者必输其一。
      SysIOFlg: string[1]; //	系统内外标志	必输项	数字	1	"1：系统内 2：系统外"
      IsSameCity: string[1]; //	同城异地标志	选输项	数字	1	"1：同城 2：异地"
      Prop: string[1]; //	对公对私标志	选输项	数字	1	"跨行必输 0：对公账户 1：个人账户"
      RecICBCCode: string[5]; //	交易对方工行地区号	选输项	数字	5	4位工行地区号
      RecCityName: string[40]; //	收款方所在城市名称	选输项	字符	40	跨行指令此项必输
      RecBankNo: string[13]; //	对方行行号	选输项	字符	13
      RecBankName: string[60]; //	交易对方银行名称	必输项	字符	60	跨行指令此项必输,中文，60位字符。
      CurrType: string[3]; //	币种	必输项	字符	3
      PayAmt: string[17]; //	金额	必输项	数字	17	无正负号，不带小数点，以分作单位
      UseCode: string[3]; //	用途代码	选输项	字符	3
      UseCN: string[20]; //	用途中文描述	选输项	字符	20	"用途代码和用途中文描述必输其一;如需跨行实时到帐此项最多10个字符.超长则落地处理."
      EnSummary: string[40]; //	英文备注	选输项	字符	40	必须ASCII字符
      PostScript: string[100]; //	附言	选输项	字符	100
      Summary: string[20]; //	摘要	选输项	字符	20
      Ref: string[20]; //	业务编号（业务参考号）	选输项	字符	20	必须ASCII字符
      Oref: string[20]; //	相关业务编号	选输项	字符	20	必须ASCII字符
      ERPSqn: string[20]; //	ERP流水号	选输项	字符	20	必须ASCII字符
      BusCode: string[5]; //	业务代码	选输项	字符	5	必须ASCII字符
      ERPcheckno: string[8]; //	ERP支票号	选输项	字符	8	必须ASCII字符
      CrvouhType: string[3]; //	原始凭证种类	选输项	字符	3	必须ASCII字符
      CrvouhName: string[30]; //	原始凭证名称	选输项	字符	30
      CrvouhNo: string[20]; //	原始凭证号	选输项	字符	20	必须ASCII字符
      //返回专用................................................................
      Result: string[2]; {指令状态	否	字符	2	"0：提交成功,等待银行处理
                                                1：授权成功, 等待银行处理
                                                2：等待授权
                                                3：等待二次授权
                                                4：等待银行答复
                                                5：主机返回待处理
                                                6：被银行拒绝
                                                7：处理成功
                                                8：指令被拒绝授权
                                                9：银行正在处理
                                                10：预约指令
                                                11：预约取消"
                          }
      iRetCode: string[5]; //	返回码	否	字符	5
      iRetMsg: string[100]; //	交易返回描述	否	字符	100
      //........................................................................
      _Reserved3: string[3]; //	请求备用字段3	选输项	字符	3	付款账号行别，不输或输入102代表工行
      _Reserved4: string[100]; //	请求备用字段4	选输项	字符	100	备用，目前无意义
    end;
  end;

  //支付指令提交查询
  TQueryPayEntRec = packed record
    QryfSeqno: string[35]; //	待查指令包序列号	选输项	字符	35	判断待查指令包序列号和待查平台交易序列号必须至少有一项有值,如同时有则以后者为准
    QrySerialNo: string[15]; //	待查平台交易序列号	选输项	字符	15
    //返回专用................................................................
    OnlBatF: string[1]; //	联机批量标志	选输项	数字	1	1：联机
    SettleMode: string[1]; //	入账方式	必输项	数字	1	2：并笔入账 0：逐笔记账
    BusType: string[2]; //	业务种类	否	字符	2	1－15的数字
    //..........................................................................
    _Reserved1: string[100]; //	请求备用字段1	选输项	字符	100	备用，目前无意义
    _Reserved2: string[100]; //	请求备用字段2	选输项	字符	100	备用，目前无意义
    rd: array of packed record
      iSeqno: string[35]; //	指令顺序号	必输项	字符	35	每笔指令的序号，本包内不重复。（工行只检查包内不重复，不同的包，工行不做指令顺序号重复性的检查。）
      QryiSeqno: string[35]; //	待查指令包顺序号	否	字符	35
      QryOrderNo: string[6]; //	待查平台交易顺序号	否	字符	6	银行产生的批次内的小序号
      //返回专用................................................................
      ReimburseNo: string[40]; //	自定义序号	选输项	字符	40
      ReimburseNum: string[10]; //	单据张数	选输项	字符	10
      StartDate: string[8]; //	定时启动日期	选输项	字符	8	格式是yyyyMMdd
      StartTime: string[6]; //	定时启动时间	选输项	字符	6	格式是hhmmss
      PayType: string[1]; //	记账处理方式	必输项	数字	1	1：加急 2：普通
      PayAccNo: string[34]; //	本方账号	必输项	数字	34
      PayAccNameCN: string[100]; //	本方账户名称	选输项	字符	100	根据人行标准，人民币账户的户名不应超过60字节，否则该字段可能被截取
      PayAccNameEN: string[100]; //	本方账户英文名称	选输项	字符	100	中文名称、英文名称二者必输其一。
      RecAccNo: string[34]; //	对方账号	必输项	字符	34
      RecAccNameCN: string[100]; //	对方账户名称	选输项	字符	100	根据人行标准，人民币账户的户名不应超过60字节，否则该字段可能被截取
      RecAccNameEN: string[100]; //	对方账户英文名称	选输项	字符	100	中文名称、英文名称二者必输其一。
      SysIOFlg: string[1]; //	系统内外标志	必输项	数字	1	"1：系统内 2：系统外"
      IsSameCity: string[1]; //	同城异地标志	选输项	数字	1	"1：同城 2：异地"
      RecICBCCode: string[5]; //	交易对方工行地区号	选输项	数字	5	4位工行地区号
      RecCityName: string[40]; //	收款方所在城市名称	选输项	字符	40	跨行指令此项必输
      RecBankNo: string[13]; //	对方行行号	选输项	字符	13
      RecBankName: string[60]; //	交易对方银行名称	必输项	字符	60	跨行指令此项必输,中文，60位字符。
      CurrType: string[3]; //	币种	必输项	字符	3
      PayAmt: string[17]; //	金额	必输项	数字	17	无正负号，不带小数点，以分作单位
      UseCode: string[3]; //	用途代码	选输项	字符	3
      UseCN: string[20]; //	用途中文描述	选输项	字符	20	"用途代码和用途中文描述必输其一;如需跨行实时到帐此项最多10个字符.超长则落地处理."
      EnSummary: string[40]; //	英文备注	选输项	字符	40	必须ASCII字符
      PostScript: string[100]; //	附言	选输项	字符	100
      Summary: string[20]; //	摘要	选输项	字符	20
      Ref: string[20]; //	业务编号（业务参考号）	选输项	字符	20	必须ASCII字符
      Oref: string[20]; //	相关业务编号	选输项	字符	20	必须ASCII字符
      ERPSqn: string[20]; //	ERP流水号	选输项	字符	20	必须ASCII字符
      BusCode: string[5]; //	业务代码	选输项	字符	5	必须ASCII字符
      ERPcheckno: string[8]; //	ERP支票号	选输项	字符	8	必须ASCII字符
      CrvouhType: string[3]; //	原始凭证种类	选输项	字符	3	必须ASCII字符
      CrvouhName: string[30]; //	原始凭证名称	选输项	字符	30
      CrvouhNo: string[20]; //	原始凭证号	否	字符	20
      //文档中无,测试环境有.....................................................s
      iRetCode: string[5]; //	返回码	否	字符	5
      iRetMsg: string[100]; //	交易返回描述	否	字符	100
      //........................................................................
      Result: string[2]; {指令状态	否	字符	2	"0：提交成功,等待银行处理
                                                1：授权成功, 等待银行处理
                                                2：等待授权
                                                3：等待二次授权
                                                4：等待银行答复
                                                5：主机返回待处理
                                                6：被银行拒绝
                                                7：处理成功
                                                8：指令被拒绝授权
                                                9：银行正在处理
                                                10：预约指令
                                                11：预约取消"
                          }
      instrRetCode: string[5]; //	返回码	否	字符	5
      instrRetMsg: string[100]; //	交易返回描述	否	字符	100
      BankRetTime: string[14]; //	银行反馈时间	否	字符	14
      //........................................................................
      _Reserved3: string[3]; //	请求备用字段3	选输项	字符	3	付款账号行别，不输或输入102代表工行
      _Reserved4: string[100]; //	请求备用字段4	选输项	字符	100	备用，目前无意义
    end;
  end;

  //批扣个人指令提交
  TPerDisRec = packed record
    OnlBatF: string[1]; //	联机批量标志	选输项	数字	1	1：联机
    //批扣个人指令提交 专用.....................................................
    SettleMode: string[1]; //	入账方式	必输项	数字	1	2：并笔入账 0：逐笔记账
    //..........................................................................
    //批扣个人指令提交汇总记帐 专用 PerDiscol...................................
    BusType: string[2]; //	业务种类编号	必输项	数字	2	1－15的数字
    //..........................................................................
    RecAccNo: string[19]; //	收方账号	必输项	数字	19
    RecAccNameCN: string[60]; //	收方账户名称	选输项	字符	60	中文名称、英文名称二者必输其一。
    RecAccNameEN: string[60]; //	收方账户英文名称	选输项	字符	60	中文名称、英文名称二者必输其一。
    TotalNum: string[6]; //	总笔数	必输项	数字	6	指令包内的指令笔数
    TotalAmt: string[20]; //	总金额	必输项	数字	20	无正负号，不带小数点，以分作单位
    //发送专用..................................................................
    SignTime: string[17]; //	签名时间	必输项	字符	17	格式是yyyyMMddhhmmssSSS
    //..........................................................................
    _Reserved1: string[100]; //	请求备用字段1	选输项	字符	100	备用，目前无意义
    _Reserved2: string[100]; //	请求备用字段2	选输项	字符	100	备用，目前无意义
    rd: array of packed record
      iSeqno: string[35]; //	指令顺序号	必输项	字符	35	每笔指令的序号，本包内不重复。（工行只检查包内不重复，不同的包，工行不做指令顺序号重复性的检查。）
      //返回专用................................................................
      OrderNo: string[6]; //	平台交易序号	否	字符	6	银行产生的批次内的小序号
      //........................................................................
      PayAccNo: string[34]; //	本方账号	必输项	数字	34
      PayAccNameCN: string[100]; //	本方账户名称	选输项	字符	100	根据人行标准，人民币账户的户名不应超过60字节，否则该字段可能被截取
      PayAccNameEN: string[100]; //	本方账户英文名称	选输项	字符	100	中文名称、英文名称二者必输其一。
      PayBranch: string[60]; //		付款账号开户行	必输项	字符	60
      Portno: string[30]; //		缴费编号	必输项	字符	30
      ContractNo: string[15]; //		协议编号	必输项	字符	15
      CurrType: string[3]; //	币种	必输项	字符	3
      PayAmt: string[17]; //	金额	必输项	数字	17	无正负号，不带小数点，以分作单位
      UseCode: string[3]; //	用途代码	选输项	字符	3
      UseCN: string[20]; //	用途中文描述	选输项	字符	20	"用途代码和用途中文描述必输其一;如需跨行实时到帐此项最多10个字符.超长则落地处理."
      EnSummary: string[40]; //	英文备注	选输项	字符	40	必须ASCII字符
      PostScript: string[100]; //	附言	选输项	字符	100
      Summary: string[20]; //	摘要	选输项	字符	20
      Ref: string[20]; //	业务编号（业务参考号）	选输项	字符	20	必须ASCII字符
      Oref: string[20]; //	相关业务编号	选输项	字符	20	必须ASCII字符
      ERPSqn: string[20]; //	ERP流水号	选输项	字符	20	必须ASCII字符
      BusCode: string[5]; //	业务代码	选输项	字符	5	必须ASCII字符
      ERPcheckno: string[8]; //	ERP支票号	选输项	字符	8	必须ASCII字符
      CrvouhType: string[3]; //	原始凭证种类	选输项	字符	3	必须ASCII字符
      CrvouhName: string[30]; //	原始凭证名称	选输项	字符	30
      CrvouhNo: string[20]; //	原始凭证号	选输项	字符	20	必须ASCII字符
      //返回专用................................................................
      Result: string[2]; {指令状态	否	字符	2	"0：提交成功,等待银行处理
                                                1：授权成功, 等待银行处理
                                                2：等待授权
                                                3：等待二次授权
                                                4：等待银行答复
                                                5：主机返回待处理
                                                6：被银行拒绝
                                                7：处理成功
                                                8：指令被拒绝授权
                                                9：银行正在处理
                                                10：预约指令
                                                11：预约取消"
                          }
      iRetCode: string[5]; //	返回码	否	字符	5
      iRetMsg: string[100]; //	交易返回描述	否	字符	100
      //........................................................................
      _Reserved3: string[3]; //	请求备用字段3	选输项	字符	3	付款账号行别，不输或输入102代表工行
      _Reserved4: string[100]; //	请求备用字段4	选输项	字符	100	备用，目前无意义
    end;
  end;

  //批量扣个人指令查询
  TQueryPerDisRec = packed record
    QryfSeqno: string[35]; //	待查指令包序列号	可选项	字符	35
    QrySerialNo: string[15]; //	待查平台交易流水号	可选项	字符	15
    //返回专用..................................................................
    OnlBatF: string[1]; //	联机批量标志	选输项	数字	1	1：联机
    SettleMode: string[1]; //	入账方式	必输项	数字	1	2：并笔入账 0：逐笔记账
    RecAccNo: string[19]; //	收方账号	必输项	数字	19
    RecAccNameCN: string[60]; //	收方账户名称	选输项	字符	60	中文名称、英文名称二者必输其一。
    RecAccNameEN: string[60]; //	收方账户英文名称	选输项	字符	60	中文名称、英文名称二者必输其一。
    RetTotalNum: string[6]; //	总笔数	必输项	数字	6	指令包内的指令笔数
    RetTotalAmt: string[20]; //	总金额	必输项	数字	20	无正负号，不带小数点，以分作单位
    CurrType: string[3]; //	币种	否	字符	3
    BusType: string[2]; //	业务种类编号	否	字符	2	1－15的数字
    //..........................................................................
    _Reserved1: string[100]; //	请求备用字段1	选输项	字符	100	备用，目前无意义
    _Reserved2: string[100]; //	请求备用字段2	选输项	字符	100	备用，目前无意义
    rd: array of packed record
      iSeqno: string[35]; //	指令顺序号	必输项	字符	35	每笔指令的序号，本包内不重复。（工行只检查包内不重复，不同的包，工行不做指令顺序号重复性的检查。）
      QryiSeqno: string[35]; //	待查指令顺序号	可选项	字符	35
      QryOrderNo: string[6]; //	待查平台交易序号	可选项	字符	6
      //返回专用................................................................
      Portno: string[30]; //	缴费编号	否	字符	30
      //XML 返回 <OpType>资金汇划普通</OpType>
      OpType: string[20]; {	缴费类型	否	数字	1	"0:同城转账
                                                  1:资金汇划普通
                                                  2:资金汇划加急" }
      ContractNo: string[15]; //	协议编号	否	字符	15
      PayAccNo: string[34]; //	本方账号	必输项	数字	34
      PayAccNameCN: string[100]; //	本方账户名称	选输项	字符	100	根据人行标准，人民币账户的户名不应超过60字节，否则该字段可能被截取
      PayAccNameEN: string[100]; //	本方账户英文名称	选输项	字符	100	中文名称、英文名称二者必输其一。
      PayBranch: string[60]; //		付款账号开户行	必输项	字符	60
      //CurrType: string[3]; //	币种	必输项	字符	3
      PayAmt: string[17]; //	金额	必输项	数字	17	无正负号，不带小数点，以分作单位
      UseCode: string[3]; //	用途代码	选输项	字符	3
      UseCN: string[20]; //	用途中文描述	选输项	字符	20	"用途代码和用途中文描述必输其一;如需跨行实时到帐此项最多10个字符.超长则落地处理."
      UserRem: string[40]; //	备注信息	否	字符	40
      PostScript: string[100]; //	附言	选输项	字符	100
      Summary: string[20]; //	摘要	选输项	字符	20
      Ref: string[20]; //	业务编号（业务参考号）	选输项	字符	20	必须ASCII字符
      Oref: string[20]; //	相关业务编号	选输项	字符	20	必须ASCII字符
      ERPSqn: string[20]; //	ERP流水号	选输项	字符	20	必须ASCII字符
      BusCode: string[5]; //	业务代码	选输项	字符	5	必须ASCII字符
      ERPcheckno: string[8]; //	ERP支票号	选输项	字符	8	必须ASCII字符
      CrvouhType: string[3]; //	原始凭证种类	选输项	字符	3	必须ASCII字符
      CrvouhName: string[30]; //	原始凭证名称	选输项	字符	30
      CrvouhNo: string[20]; //	原始凭证号	选输项	字符	20	必须ASCII字符
      Result: string[2]; {指令状态	否	字符	2	"0：提交成功,等待银行处理
                                                1：授权成功, 等待银行处理
                                                2：等待授权
                                                3：等待二次授权
                                                4：等待银行答复
                                                5：主机返回待处理
                                                6：被银行拒绝
                                                7：处理成功
                                                8：指令被拒绝授权
                                                9：银行正在处理
                                                10：预约指令
                                                11：预约取消"
                          }
      BankRem: string[100]; //	银行备注	否	字符	100
      BankRetime: string[14]; //	银行批复时间	否	字符	14	yyyymmddhhmmss
      iRetCode: string[5]; //	返回码	否	字符	5
      iRetMsg: string[100]; //	交易返回描述	否	字符	100
      //........................................................................
      _Reserved3: string[3]; //	请求备用字段3	选输项	字符	3	付款账号行别，不输或输入102代表工行
      _Reserved4: string[100]; //	请求备用字段4	选输项	字符	100	备用，目前无意义
    end;
  end;


  //网点信息下载
  TQueryNetNodeRec = packed record
    NextTag: string[60]; //	查询下页标识	选输项	字符	60	查询首页上送空；其他页需与银行返回包提供的一致
    _Reserved1: string[100]; //	请求备用字段1	选输项	字符	100	备用，目前无意义
    _Reserved2: string[100]; //	请求备用字段2	选输项	字符	100	备用，目前无意义
    //返回专用..................................................................
    rd: array of packed record
      AreaCode: string[4]; //	地区号	否	字符	4
      NetName: string[40]; //	网点名称	否	字符	40
      _Reserved3: string[100]; //	响应备用字段3	否	字符	100	备用，目前无意义
      _Reserved4: string[100]; //	响应备用字段4	否	字符	100	备用，目前无意义
    end;
    //..........................................................................
  end;

  //缴费个人信息查询
  TQueryPerInf = packed record
    //发送专用..................................................................
    BeginDate: string[8]; //	起始日期	必输项	字符	8	起始日期不能晚于终止日期；格式为YYYYMMDD
    EndDate: string[8]; //	终止日期	必输项	字符	8	终止日期不能早于起始日期 格式为YYYYMMDD
    BeginTime: string[6]; //	开始时间	选输项	字符	6	同一天的情况下，开始时间不能晚于终止时间 格式为hhmmss(暂时不起作用)
    EndTime: string[6]; //	终止时间	选输项	字符	6	同一天的情况下，开始时间不能晚于终止时间 格式为hhmmss(暂时不起作用)
    PayAccNo: string[19]; //	付款账号	选输项	字符	19
    Portno: string[30]; //	缴费编号	选输项	字符	30
    //..........................................................................
    RecAccNo: string[19]; //	收费企业账号	必输项	字符	19
    QueryTag: string[1]; //	查询协议类型	必输项	字符	1	0：签订协议  1：撤销协议
    NextTag: string[60]; //	查询下页标识	选输项	字符	60	查询首页上送空；其他页与银行返回包提供的一致
    _Reserved1: string[100]; //	请求备用字段1	选输项	字符	100	备用，目前无意义
    _Reserved2: string[100]; //	请求备用字段2	选输项	字符	100	备用，目前无意义
    //返回专用..................................................................
    rd: array of packed record
      ContractNo: string[35]; //	协议编号	否	字符	35
      Portno: string[30]; //	缴费编号	否	字符	30
      OpType: string[20]; //	缴费种类	否	字符	20
      PayAccNo: string[19]; //	付款帐号	否	字符	19
      PayAccNameCN: string[60]; //	付款帐号名称	否	字符	60
      SignDate: string[14]; //	签定/撤销协议时间	否	字符	14	YYYYMMDDHHMMSS
      _Reserved3: string[100]; //	响应备用字段3	否	字符	100	备用，目前无意义
      _Reserved4: string[100]; //	响应备用字段4	否	字符	100	备用，目前无意义
    end;
    //..........................................................................
  end;


implementation

end.

