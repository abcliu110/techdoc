# K3 Cloud 凭证接口：外部系统集成指南

> 文档版本：v1.0
> 创建日期：2026-09-18
> 分析来源：K3 Cloud BOS平台源码 + 开放平台文档
> 文档定位：第三方系统调用K3 Cloud生成凭证的完整指南

---

## 一、文档目的

本文档说明第三方系统如何调用K3 Cloud接口生成财务凭证，包括：
- 接口地址和认证方式
- 凭证保存接口参数
- 幂等性保障机制
- 常见错误处理

---

## 二、接口概览

### 2.1 WebAPI接口地址

```
K3 Cloud服务器地址：http://{服务器IP}:{端口}/K3Cloud/

凭证相关接口：
- 验证用户：AuthService.ValidateUser.common.kdsvc
- 保存单据：DynamicFormService.Save.common.kdsvc
- 审核单据：DynamicFormService.Audit.common.kdsvc
- 批量操作：DynamicFormService.BatchSave.common.kdsvc
```

### 2.2 凭证相关表

| 表名 | 说明 |
|------|------|
| GL_VOUCHER | 凭证主表 |
| GL_VOUCHERENTRY | 凭证分录表 |
| BAS_BusinessVoucher | 业务凭证映射表 |
| BD_AccountBook | 账簿表 |
| BD_Account | 会计科目表 |

---

## 三、认证方式

### 3.1 方式一：账号密码认证

```
POST /K3Cloud/AuthService.ValidateUser.common.kdsvc

请求体：
{
    "username": "管理员账号",
    "password": "密码",
    "lcid": 2052  // 中文简体
}

响应：
{
    "LoginResultType": 1,  // 1=成功
    "Context": {
        "UserId": "用户ID",
        "UserName": "用户名"
    }
}
```

### 3.2 方式二：AppKey/AppSecret认证（推荐）

```
在K3 Cloud中创建API应用：
路径：系统管理 → 第三方应用授权 → 新建应用

获取：
- AppId：应用ID
- AppSecret：应用密钥

调用接口时携带认证信息：
- 在请求头中携带AppId和AppSecret
```

---

## 四、凭证保存接口

### 4.1 接口地址

```
POST /K3Cloud/DynamicFormService.Save.common.kdsvc
```

### 4.2 请求格式

```json
{
    "FormId": "GL_VOUCHER",
    "Operation": "Save",
    "SubSystemId": "",
    "IsAutoSubmitAndAudit": false,
    "InterationFlags": "",
    "IsVerification": "",
    "Model": {
        "FACCOUNTBOOKID": {
            "FNumber": "账簿编码"
        },
        "FVOUCHERGROUPID": {
            "FNUMBER": "记"
        },
        "FDATE": "2024-01-15",
        "FEXPLANATION": "凭证摘要：第三方系统接入",
        "FBUSINESSDATE": "2024-01-15",
        "FATTACHMENTS": 0,
        "FVOUCHERENTRY": [
            {
                "FENTRYID": 0,
                "FACCOUNTID": {
                    "FNumber": "1122"
                },
                "FEXPLANATION": "借方分录摘要",
                "FDEBIT": 10000.00,
                "FCREDIT": 0,
                "FDC": 1,
                "FDIMENSIONLEVEL1": {
                    "FNUMBER": "BM001"
                },
                "FDIMENSIONLEVEL4": {
                    "FNUMBER": "KH001"
                }
            },
            {
                "FENTRYID": 0,
                "FACCOUNTID": {
                    "FNumber": "6001"
                },
                "FEXPLANATION": "贷方分录摘要",
                "FDEBIT": 0,
                "FCREDIT": 10000.00,
                "FDC": -1
            }
        ],
        "FSOURCEBILLID": "外部系统单据ID",
        "FSOURCEBILLNO": "外部系统单据编号"
    }
}
```

### 4.3 关键字段说明

#### 4.3.1 凭证主表字段

| 字段 | 类型 | 说明 | 必须 |
|------|------|------|------|
| FACCOUNTBOOKID | 对象 | 账簿，传入{FNumber:"账簿编码"} | 是 |
| FVOUCHERGROUPID | 对象 | 凭证字，传入{FNumber:"记"} | 是 |
| FDATE | 字符串 | 凭证日期，格式：yyyy-MM-dd | 是 |
| FEXPLANATION | 字符串 | 凭证摘要 | 否 |
| FVOUCHERENTRY | 数组 | 凭证分录列表 | 是 |
| FSOURCEBILLID | 字符串 | 来源单据ID（幂等键） | 推荐 |
| FSOURCEBILLNO | 字符串 | 来源单据编号 | 推荐 |

#### 4.3.2 凭证分录字段

| 字段 | 类型 | 说明 | 必须 |
|------|------|------|------|
| FACCOUNTID | 对象 | 科目，传入{FNumber:"科目编码"} | 是 |
| FEXPLANATION | 字符串 | 分录摘要 | 否 |
| FDEBIT | 数字 | 借方金额 | 是 |
| FCREDIT | 数字 | 贷方金额 | 是 |
| FDC | 数字 | 借贷方向：1=借，-1=贷 | 是 |
| FDIMENSIONLEVEL1 | 对象 | 核算维度1（部门），传入{FNumber:"部门编码"} | 否 |
| FDIMENSIONLEVEL2 | 对象 | 核算维度2（项目） | 否 |
| FDIMENSIONLEVEL3 | 对象 | 核算维度3（供应商） | 否 |
| FDIMENSIONLEVEL4 | 对象 | 核算维度4（客户） | 否 |
| FDIMENSIONLEVEL5 | 对象 | 核算维度5（职员） | 否 |

### 4.4 响应格式

```json
{
    "Result": {
        "ResponseStatus": {
            "IsSuccess": true,
            "ErrorCode": "",
            "Errors": [],
            "SuccessInfo": {
                "Id": "凭证ID",
                "Number": "凭证号：记-2024-00001"
            }
        }
    }
}
```

---

## 五、幂等性保障

### 5.1 K3 Cloud内部的幂等机制

| 机制 | 说明 |
|------|------|
| 凭证号唯一 | GL_VOUCHER表有IX_GL_VOUCHER_NO唯一索引 |
| 业务凭证映射 | BAS_BusinessVoucher记录业务单据与凭证的关联 |
| 来源单据追溯 | GL_VOUCHER.FSourceBillId记录外部传入的单据ID |

### 5.2 外部系统调用建议的幂等方案

#### 5.2.1 方案一：使用来源单据ID

```
1. 外部系统生成唯一业务ID作为幂等键
   例：外部订单号 + "_VOUCHER"

2. 调用K3 Cloud凭证接口时，将幂等键传入FSOURCEBILLID字段

3. 保存前先查询是否已存在
   SELECT * FROM GL_VOUCHER 
   WHERE FSOURCEBILLID = '外部订单号_VOUCHER'

4. 如果存在，返回已有凭证
   如果不存在，执行保存
```

#### 5.2.2 方案二：使用业务凭证映射表

```
1. 保存凭证后，K3 Cloud会自动创建BAS_BusinessVoucher映射记录

2. 后续调用时先查询映射表
   SELECT * FROM BAS_BusinessVoucher
   WHERE FSOURCEBILLID = '外部订单号'
   AND FSOURCEBILLTYPE = '第三方系统'

3. 如果存在映射记录，说明凭证已生成
```

### 5.3 幂等调用示例

```python
import requests
import json

class K3CloudVoucherClient:
    def __init__(self, base_url, db_id, username, password):
        self.base_url = base_url
        self.db_id = db_id
        self.username = username
        self.password = password
        self.session = requests.Session()
        self.cookies = None
        
    def login(self):
        """登录获取会话"""
        url = f"{self.base_url}/K3Cloud/AuthService.ValidateUser.common.kdsvc"
        data = {
            "username": self.username,
            "password": self.password,
            "lcid": 2052
        }
        resp = self.session.post(url, json=data)
        self.cookies = self.session.cookies
        return resp.json()
    
    def save_voucher(self, voucher_data, idempotency_key):
        """
        保存凭证（带幂等）
        voucher_data: 凭证数据
        idempotency_key: 幂等键
        """
        # 1. 先查询是否已存在
        existing = self.query_voucher_by_source(idempotency_key)
        if existing:
            return {"success": True, "voucher_id": existing["id"], "voucher_no": existing["number"], "is_existing": True}
        
        # 2. 设置来源单据ID（幂等键）
        voucher_data["Model"]["FSOURCEBILLID"] = idempotency_key
        voucher_data["Model"]["FSOURCEBILLNO"] = idempotency_key
        
        # 3. 保存凭证
        url = f"{self.base_url}/K3Cloud/DynamicFormService.Save.common.kdsvc"
        resp = self.session.post(url, json=voucher_data, cookies=self.cookies)
        result = resp.json()
        
        if result.get("Result", {}).get("ResponseStatus", {}).get("IsSuccess"):
            return {
                "success": True,
                "voucher_id": result["Result"]["ResponseStatus"]["SuccessInfo"]["Id"],
                "voucher_no": result["Result"]["ResponseStatus"]["SuccessInfo"]["Number"],
                "is_existing": False
            }
        else:
            return {"success": False, "error": result}
    
    def query_voucher_by_source(self, source_bill_id):
        """根据来源单据ID查询凭证"""
        url = f"{self.base_url}/K3Cloud/DynamicFormService.Execute.obj"
        data = {
            "FormId": "GL_VOUCHER",
            "FieldKeys": "FVOUCHERID,FBILLNO,FSOURCEBILLID",
            "FilterString": f"FSOURCEBILLID='{source_bill_id}'",
            "OrderString": "",
            "TopRowCount": 1,
            "StartRow": 0,
            "Limit": 1
        }
        resp = self.session.post(url, json=data, cookies=self.cookies)
        result = resp.json()
        
        if result.get("Result") and result["Result"].get("data"):
            return {
                "id": result["Result"]["data"][0][0],
                "number": result["Result"]["data"][0][1]
            }
        return None

# 使用示例
client = K3CloudVoucherClient(
    base_url="http://192.168.1.100:8090",
    db_id="YourDBID",
    username="admin",
    password="admin123"
)
client.login()

voucher = {
    "FormId": "GL_VOUCHER",
    "Operation": "Save",
    "Model": {
        "FACCOUNTBOOKID": {"FNumber": "001"},
        "FVOUCHERGROUPID": {"FNUMBER": "记"},
        "FDATE": "2024-01-15",
        "FEXPLANATION": "第三方系统凭证",
        "FVOUCHERENTRY": [...]
    }
}

result = client.save_voucher(voucher, idempotency_key="ORDER_20240115_001_VOUCHER")
print(result)
```

---

## 六、业务单据触发凭证方案

### 6.1 方式一：创建业务单据，审核时自动生成凭证

```
外部系统 → 创建收款单/付款单 → 审核 → 自动生成凭证
```

#### 6.1.1 收款单保存接口

```json
{
    "FormId": "AR_ReceiveBill",
    "Operation": "Save",
    "Model": {
        "FACCOUNTBOOKID": {"FNumber": "001"},
        "FCUSTOMERID": {"FNumber": "KH001"},
        "FDATE": "2024-01-15",
        "FBANKACCOUNTID": {"FNumber": "YH001"},
        "FRECEIVEAMOUNT": 10000.00,
        "FSOURCEBILLID": "外部订单号",
        "FSOURCEBILLNO": "外部订单号",
        "FENTRY": [
            {
                "FSETTLETYPEID": {"FNumber": "JS001"},
                "FAMOUNT": 10000.00,
                "FBANKBALANCE": 10000.00
            }
        ]
    }
}
```

#### 6.1.2 审核单据（触发凭证生成）

```json
{
    "FormId": "AR_ReceiveBill",
    "Operation": "Audit",
    "Numbers": ["收款单编号"]
}
```

### 6.2 方式二：直接保存凭证（推荐）

如果外部系统已经有完整的分录信息，直接保存凭证更简单：

```
外部系统 → 直接保存GL_VOUCHER
```

---

## 七、常见错误处理

### 7.1 借贷不平衡

```json
{
    "ResponseStatus": {
        "IsSuccess": false,
        "Errors": [
            {
                "FieldName": "",
                "Message": "借贷不平衡"
            }
        ]
    }
}
```

**解决**：检查借方合计是否等于贷方合计

### 7.2 凭证日期不在期间内

```json
{
    "ResponseStatus": {
        "IsSuccess": false,
        "Errors": [
            {
                "FieldName": "FDATE",
                "Message": "凭证日期不在已打开的会计期间内"
            }
        ]
    }
}
```

**解决**：检查账簿的会计期间是否已打开

### 7.3 科目不在科目体系中

```json
{
    "ResponseStatus": {
        "IsSuccess": false,
        "Errors": [
            {
                "FieldName": "FACCOUNTID",
                "Message": "科目不在当前账簿的科目体系中"
            }
        ]
    }
}
```

**解决**：确认科目编码正确，且科目在当前账簿的科目体系中

### 7.4 辅助核算维度不匹配

```json
{
    "ResponseStatus": {
        "IsSuccess": false,
        "Errors": [
            {
                "FieldName": "FDIMENSIONLEVEL1",
                "Message": "辅助核算维度不在科目允许的范围内"
            }
        ]
    }
}
```

**解决**：检查科目启用了哪些辅助核算维度，传入的维度是否匹配

### 7.5 会话过期

```json
{
    "Result": null
}
```

**解决**：重新调用登录接口获取新的会话

---

## 八、完整调用示例

### 8.1 C# 调用示例

```csharp
using System;
using System.Net.Http;
using System.Text;
using System.Net.Http.Headers;
using Newtonsoft.Json;

public class K3CloudClient
{
    private readonly string _baseUrl;
    private readonly string _dbId;
    private readonly string _username;
    private readonly string _password;
    private CookieContainer _cookies = new CookieContainer();
    
    public K3CloudClient(string baseUrl, string dbId, string username, string password)
    {
        _baseUrl = baseUrl;
        _dbId = dbId;
        _username = username;
        _password = password;
    }
    
    public bool Login()
    {
        using (var handler = new HttpClientHandler { CookieContainer = _cookies })
        using (var client = new HttpClient { BaseAddress = new Uri(_baseUrl) })
        {
            var request = new
            {
                username = _username,
                password = _password,
                lcid = 2052
            };
            
            var content = new StringContent(JsonConvert.SerializeObject(request), Encoding.UTF8, "application/json");
            var response = client.PostAsync("/K3Cloud/AuthService.ValidateUser.common.kdsvc", content).Result;
            var result = JsonConvert.DeserializeAnonymousType(
                response.Content.ReadAsStringAsync().Result,
                new { LoginResultType = 0 });
            
            return result?.LoginResultType == 1;
        }
    }
    
    public SaveVoucherResult SaveVoucher(VoucherModel voucher)
    {
        using (var handler = new HttpClientHandler { CookieContainer = _cookies })
        using (var client = new HttpClient { BaseAddress = new Uri(_baseUrl) })
        {
            var request = new
            {
                FormId = "GL_VOUCHER",
                Operation = "Save",
                Model = voucher
            };
            
            var content = new StringContent(JsonConvert.SerializeObject(request), Encoding.UTF8, "application/json");
            var response = client.PostAsync("/K3Cloud/DynamicFormService.Save.common.kdsvc", content).Result;
            var result = JsonConvert.DeserializeObject<SaveVoucherResult>(response.Content.ReadAsStringAsync().Result);
            
            return result;
        }
    }
}

public class VoucherModel
{
    public AccountBookRef FACCOUNTBOOKID { get; set; }
    public VoucherGroupRef FVOUCHERGROUPID { get; set; }
    public string FDATE { get; set; }
    public string FEXPLANATION { get; set; }
    public string FSOURCEBILLID { get; set; }
    public string FSOURCEBILLNO { get; set; }
    public List<VoucherEntryModel> FVOUCHERENTRY { get; set; }
}

public class AccountBookRef
{
    public string FNumber { get; set; }
}

public class VoucherGroupRef
{
    public string FNUMBER { get; set; }
}

public class VoucherEntryModel
{
    public int FENTRYID { get; set; }
    public AccountRef FACCOUNTID { get; set; }
    public string FEXPLANATION { get; set; }
    public decimal FDEBIT { get; set; }
    public decimal FCREDIT { get; set; }
    public int FDC { get; set; }
}

public class AccountRef
{
    public string FNumber { get; set; }
}

public class SaveVoucherResult
{
    public ResultData Result { get; set; }
}

public class ResultData
{
    public ResponseStatus ResponseStatus { get; set; }
}

public class ResponseStatus
{
    public bool IsSuccess { get; set; }
    public string ErrorCode { get; set; }
    public object Errors { get; set; }
    public SuccessInfo SuccessInfo { get; set; }
}

public class SuccessInfo
{
    public string Id { get; set; }
    public string Number { get; set; }
}
```

### 8.2 使用示例

```csharp
var client = new K3CloudClient(
    "http://192.168.1.100:8090",
    "YourDBID",
    "admin",
    "admin123"
);

if (client.Login())
{
    var voucher = new VoucherModel
    {
        FACCOUNTBOOKID = new AccountBookRef { FNumber = "001" },
        FVOUCHERGROUPID = new VoucherGroupRef { FNUMBER = "记" },
        FDATE = "2024-01-15",
        FEXPLANATION = "第三方系统接入测试",
        FSOURCEBILLID = "ORDER_20240115_001_VOUCHER",
        FSOURCEBILLNO = "ORDER_20240115_001_VOUCHER",
        FVOUCHERENTRY = new List<VoucherEntryModel>
        {
            new VoucherEntryModel
            {
                FENTRYID = 0,
                FACCOUNTID = new AccountRef { FNumber = "1122" },
                FEXPLANATION = "借：应收账款",
                FDEBIT = 11300.00m,
                FCREDIT = 0,
                FDC = 1
            },
            new VoucherEntryModel
            {
                FENTRYID = 0,
                FACCOUNTID = new AccountRef { FNumber = "6001" },
                FEXPLANATION = "贷：主营业务收入",
                FDEBIT = 0,
                FCREDIT = 10000.00m,
                FDC = -1
            },
            new VoucherEntryModel
            {
                FENTRYID = 0,
                FACCOUNTID = new AccountRef { FNumber = "2221" },
                FEXPLANATION = "贷：应交税费-销项税",
                FDEBIT = 0,
                FCREDIT = 1300.00m,
                FDC = -1
            }
        }
    };
    
    var result = client.SaveVoucher(voucher);
    
    if (result.Result.ResponseStatus.IsSuccess)
    {
        Console.WriteLine($"凭证保存成功：{result.Result.ResponseStatus.SuccessInfo.Number}");
    }
    else
    {
        Console.WriteLine($"凭证保存失败：{result.Result.ResponseStatus.Errors}");
    }
}
```

---

## 九、附录

### 9.1 凭证字说明

| 凭证字 | 说明 |
|--------|------|
| 记 | 记账凭证（默认） |
| 转 | 转账凭证 |
| 收 | 收款凭证 |
| 付 | 付款凭证 |

### 9.2 辅助核算维度

| 维度字段 | 维度类型 | 说明 |
|----------|----------|------|
| FDIMENSIONLEVEL1 | 部门 | 部门核算 |
| FDIMENSIONLEVEL2 | 项目 | 项目核算 |
| FDIMENSIONLEVEL3 | 供应商 | 供应商核算 |
| FDIMENSIONLEVEL4 | 客户 | 客户核算 |
| FDIMENSIONLEVEL5 | 职员 | 职员核算 |

### 9.3 科目类型

| 科目类型 | 余额方向 | 说明 |
|----------|----------|------|
| 1 | 借方 | 资产类 |
| 2 | 贷方 | 负债类 |
| 3 | 贷方 | 权益类 |
| 4 | 借方 | 成本类 |
| 5 | 贷方 | 损益类（收入） |
| 6 | 借方 | 损益类（费用） |

### 9.4 官方参考资料

| 资源 | 链接 |
|------|------|
| K3 Cloud开放平台 | https://open.kingdee.com |
| WebAPI开发指南 | 在开放平台搜索"WebAPI" |
| 登录接口说明 | 在开放平台搜索"登录" |
| 凭证接口说明 | 在开放平台搜索"凭证" |

---

## 十、变更记录

| 版本 | 日期 | 修改内容 |
|------|------|---------|
| v1.0 | 2026-09-18 | 初始版本，包含完整的凭证接口文档 |
