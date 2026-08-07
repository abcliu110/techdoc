# DA6 交互流程 — K3Cloud AP应付管理模块

## 模板加载记录
已读取 SOP-00-DA6-模板.md，门禁检查 5 项全部通过。

---

## 一、核心场景时序图（4个）

### 1.1 采购发票核销场景（核心主场景）

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ 采购员  │    │ 应付会计 │    │ Payable │    │  凭证   │    │ 钩稽   │    │ 核销   │
│         │    │         │    │  Edit    │    │ 生成    │    │ 服务    │    │ 服务    │
└────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘
     │              │              │              │              │              │
     │ 1.录入采购发票│              │              │              │              │
     │─────────────▶│              │              │              │              │
     │              │ 2.提交审核    │              │              │              │
     │─────────────▶│              │              │              │              │
     │              │ 3.OnDoOperation(Audit)│      │              │              │
     │              │─────────────▶│              │              │              │
     │              │              │ 4.判断核算类型 SetAccountType()│         │
     │              │              │──┤             │              │              │
     │              │              │  CG/FY不同逻辑 │              │              │
     │              │              │◀──┘             │              │              │
     │              │              │ 5.生成发票凭证  │              │              │
     │              │              │───────────────▶│              │              │
     │              │              │   VoucherGenerateServiceHelper.Generate()    │
     │              │              │◀───────────────│              │              │
     │              │              │ 6.创建BAS_BusinessVoucher映射               │
     │              │              │───────────────▶│              │              │
     │              │              │ 7.返回凭证ID    │              │              │
     │              │              │◀───────────────│              │              │
     │              │ 8.审核成功   │              │              │              │
     │◀─────────────│              │              │              │              │
     │              │ 9.执行钩稽确认│              │              │              │
     │              │──────────────┼──────────────┼─────────────▶│              │
     │              │              │              │ Verify()     │              │
     │              │              │              │ 10.建立钩稽关系│              │
     │              │              │              │◀─────────────│              │
     │              │              │              │ 11.返回VerificationID         │
     │              │              │◀─────────────┼─────────────┼──────────────│
     │              │              │ 12.更新AP_PAYABLE.FVerificationID            │
     │              │ 13.执行核销   │              │              │              │
     │              │──────────────┼──────────────┼─────────────┼──────────────│
     │              │              │              │  FinMatchProcess()             │
     │              │              │              │              │ 14.校验行数限制
     │              │              │              │              │◀──┐          │
     │              │              │              │              │行数1:1/1:0/2:0│
     │              │              │              │              │──┘          │
     │              │              │              │              │ 15.计算未核销金额
     │              │              │              │              │◀──┐          │
     │              │              │              │              │FUnWriteOffAmt│
     │              │              │              │              │──┘          │
     │              │              │              │              │ 16.创建核销记录
     │              │              │              │              │◀──┐          │
     │              │              │              │              │AP_WRITEOFFRECORD│
     │              │              │              │              │──┘          │
     │              │              │              │ 17.触发核销凭证│              │
     │              │              │              │◀─────────────┼──────────────│
     │              │              │              │◀─────────────┼──────────────│
     │              │              │ 18.更新未核销金额│              │              │
     │              │              │◀─────────────┼─────────────┼──────────────│
     │              │ 19.核销成功   │              │              │              │
     │◀─────────────│              │              │              │              │
     │              │              │              │              │              │
```

### 1.2 费用报销核销场景

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ 员工   │    │ 应付会计 │    │ Payable │    │  凭证   │    │ 核销   │
│         │    │         │    │  Edit    │    │ 生成    │    │ 服务    │
└────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘
     │              │              │              │              │
     │ 1.提交费用报销│              │              │              │
     │─────────────▶│              │              │              │
     │              │ 2.审核费用单  │              │              │
     │              │─────────────▶│              │              │
     │              │              │ 3.SetAccountType() FY逻辑│
     │              │              │──┤             │              │
     │              │              │ FY≠CG：特殊判断│              │
     │              │              │◀──┘             │              │
     │              │              │ 4.生成费用凭证  │              │
     │              │              │───────────────▶│              │
     │              │              │◀───────────────│              │
     │              │ 5.审核成功   │              │              │
     │◀─────────────│              │              │              │
     │              │ 6.执行核销   │              │              │
     │              │──────────────┼──────────────┼─────────────▶│
     │              │              │              │  FinMatchProcess()
     │              │              │              │ 7.核销匹配    │
     │              │              │              │◀─────────────│
     │              │              │ 8.更新未核销金额│              │
     │              │              │◀─────────────┼─────────────│
     │              │ 9.核销成功   │              │              │
     │◀─────────────│              │              │              │
```

### 1.3 反核销场景

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ 财务主管│    │ FinMatch│    │  凭证   │    │ Verification│  │ AP_PAYABLE│
│         │    │  服务    │    │ 生成    │    │ 服务     │    │          │
└────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘
     │              │              │              │              │
     │ 1.选择反核销  │              │              │              │
     │─────────────▶│              │              │              │
     │              │ 2.校验"反清理"权限│              │              │
     │              │◀──┐           │              │              │
     │              │权限│           │              │              │
     │              │不足│           │              │              │
     │              │──┘           │              │              │
     │              │ 3.UnVerifyResultAction分析│              │
     │              │──┐           │              │              │
     │              │判断│           │              │              │
     │              │补偿│           │              │              │
     │              │凭证│           │              │              │
     │              │──┘           │              │              │
     │              │ 4.生成补偿凭证│              │              │
     │              │─────────────▶│              │              │
     │              │◀─────────────│              │              │
     │              │ 5.恢复核销状态│              │              │
     │              │──────────────┼─────────────────────────────▶│
     │              │              │              │ 6.恢复未核销金额│
     │              │              │              │◀─────────────┼─│
     │              │ 7.反核销成功 │              │              │
     │◀─────────────│              │              │              │
```

### 1.4 内部核销场景

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ 财务主管│    │InnerClear│   │  凭证   │    │  AP模块 │    │ 组织账务│
│         │    │  服务    │    │ 生成    │    │          │    │         │
└────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘
     │              │              │              │              │
     │ 1.录入内部应收│              │              │              │
     │─────────────▶│              │              │              │
     │              │ 2.录入内部应付│              │              │
     │─────────────▶│              │              │              │
     │              │ 3.执行内部核销│              │              │
     │─────────────▶│              │              │              │
     │              │ 4.校验组织关系│              │              │
     │              │◀──┐           │              │              │
     │              │同体系│         │              │              │
     │              │组织?│         │              │              │
     │              │──┘           │              │              │
     │              │ 5.计算内部抵消│              │              │
     │              │◀──┐           │              │              │
     │              │金额│           │              │              │
     │              │匹配│           │              │              │
     │              │──┘           │              │              │
     │              │ 6.创建内部核销记录│          │              │
     │              │─────────────▶│              │              │
     │              │◀─────────────│              │              │
     │              │ 7.生成内部抵消凭证│          │              │
     │              │◀─────────────┼───────────────┼──────────────│
     │              │              │              │ 8.组织往来清零│
     │              │              │              │◀─────────────┼─│
     │              │ 9.内部核销成功│              │              │
     │◀─────────────│              │              │              │
```

---

## 二、API清单（15个）

### 2.1 应付单据API

| API ID | API名称 | 输入参数 | 输出参数 | 触发事件 |
|---|---|---|---|---|
| API-AP-01 | SavePayable | AP_PAYABLE实体 | BillID/错误信息 | EVT-AP-01 |
| API-AP-02 | AuditPayable | BillID | AuditResult | EVT-AP-02 |
| API-AP-03 | SetAccountType | BillID, IsNew | SetAccountTypeResult | EVT-AP-01/02 |
| API-AP-04 | UnAuditPayable | BillID | UnAuditResult | - |

### 2.2 核销API

| API ID | API名称 | 输入参数 | 输出参数 | 触发事件 |
|---|---|---|---|---|
| API-AP-10 | FinMatch | SourceBillID, TargetBillID, MatchMethod, WriteOffAmt | WriteOffRecordID | EVT-AP-04 |
| API-AP-11 | FinMatchProcess | MatchParams | MatchResult(行数校验/金额计算) | EVT-AP-04 |
| API-AP-12 | UnVerify | WriteOffRecordID | UnVerifyResultAction | EVT-AP-05 |
| API-AP-13 | InnerClear | InnerIVRecordID, InnerPayRecordID, ClearAmt | InnerClearRecordID | EVT-AP-06 |
| API-AP-14 | InnerUnClear | InnerClearID | InnerUnClearResult | EVT-AP-07 |

### 2.3 钩稽API

| API ID | API名称 | 输入参数 | 输出参数 | 触发事件 |
|---|---|---|---|---|
| API-AP-20 | Verify | SourceBillID, TargetBillID, VerifyAmt | VerificationID | EVT-AP-03 |
| API-AP-21 | UnVerifyVerification | VerificationID | UnVerifyResult | - |
| API-AP-22 | HookReturn | TargetBillID | HookReturnResult | - |

### 2.4 凭证生成API

| API ID | API名称 | 输入参数 | 输出参数 | 触发事件 |
|---|---|---|---|---|
| API-AP-30 | GenerateVoucher | BillID, VchTemplateID | VoucherID | - |
| API-AP-31 | CreateBusinessVoucherMapping | SourceBillID, VoucherID | MappingID | - |
| API-AP-32 | QueryVoucherBySourceBill | SourceBillID | Voucher列表 | - |

### 2.5 报表API

| API ID | API名称 | 输入参数 | 输出参数 | 触发事件 |
|---|---|---|---|---|
| API-AP-40 | AgingAnalysis | OrgID, SupplierID, DateRange | AgingReport | - |
| API-AP-41 | PayableOpenDetail | OrgID, SupplierID, Status | OpenDetailReport | - |
| API-AP-42 | MaturedDebt | OrgID, DueDateBefore | MaturedDebtReport | - |

---

## 三、交互边界

### 3.1 AP-GL边界

| 交互方向 | 交互内容 | 接口 | 数据流向 |
|---|---|---|---|
| AP→GL | 凭证生成请求 | VoucherGenerateServiceHelper.Generate() | AP触发GL生成凭证 |
| AP→GL | 核销凭证生成 | FinMatch触发 | AP触发GL生成核销凭证 |
| GL→AP | 凭证查询 | BAS_BusinessVoucher映射 | GL可查询业务来源 |
| GL→AP | 凭证追溯 | BAS_BusinessVoucher反向查询 | GL可追溯到AP单据 |

### 3.2 AP-PM边界（采购管理）

| 交互方向 | 交互内容 | 接口 | 数据流向 |
|---|---|---|---|
| PM→AP | 采购入库单审核触发 | PM单据审核事件 | PM触发AP生成暂估凭证 |
| PM→AP | 采购发票传入 | 采购发票录入 | PM传入AP应付单 |

### 3.3 AP-AR边界（应收管理）

| 交互方向 | 交互内容 | 接口 | 数据流向 |
|---|---|---|---|
| AP↔AR | 内部核销 | InnerClear | AP内部应付与AR内部应收抵消 |

### 3.4 AP-CM边界（现金管理）

| 交互方向 | 交互内容 | 接口 | 数据流向 |
|---|---|---|---|
| CM→AP | 付款确认 | 付款单审核 | CM触发AP更新FRelateHadPayAmount |
| AP→CM | 付款申请 | 付款申请单 | AP发起CM付款流程 |

---

## 四、交互模式分类

| 模式 | 场景 | 特点 | 风险 |
|---|---|---|---|
| 同步请求-响应 | 应付单保存/审核 | 即时反馈 | 超时风险 |
| 异步Floating窗口 | 凭证生成 | 窗口模式，可能超时 | 双向盲区 |
| 事件驱动 | 核销触发凭证 | 松耦合 | 事件丢失风险 |
| 回调 | 凭证生成完成通知 | AP等待GL回调 | 超时未回调 |
| 查询拉取 | 凭证追溯/报表 | 按需查询 | 数据一致性 |

---

## 五、交互-源码映射

| 交互 | 源码类/文件 | 核心方法 |
|---|---|---|
| 应付单保存 | PayableEdit.cs | Save() |
| 应付单审核 | PayableEdit.cs | OnDoOperation(Audit) |
| 核算类型判断 | PayableEdit.cs:643-715 | SetAccountType() |
| 核销匹配 | FinMatch.cs | FinMatchProcess() |
| 核销反操作 | VerificationServiceHelper.cs | UnVerify() |
| 内部核销 | InnerClearRecordEdit.cs | InnerClearProcess() |
| 凭证生成 | VoucherGenerateServiceHelper.cs | Generate() |
| 钩稽确认 | VerificationServiceHelper.cs | Verify() |
| 账龄分析 | AgingAnalysis.cs | AgingCalculate() |
| 凭证追溯 | ViewGlVoucher.cs | QueryBySourceBill() |
