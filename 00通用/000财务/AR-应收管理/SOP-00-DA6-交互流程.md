# DA6 交互流程 — K3Cloud AR应收管理模块

## 模板加载记录
已读取 AP应付管理 SOP-00-DA6-交互流程.md，门禁检查 5 项全部通过（AR镜像）。

---

## 一、核心场景时序图（4个）

### 1.1 销售应收核销场景（核心主场景）

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ 销售员  │    │ 应收会计 │    │ARReceiv-│    │  凭证   │    │  钩稽   │    │  核销   │
│         │    │         │    │  ableEdit│    │ 生成    │    │  服务    │    │  服务    │
└────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘
     │              │              │              │              │              │
     │ 1.录入销售发票│              │              │              │              │
     │─────────────▶│              │              │              │              │
     │              │ 2.提交审核    │              │              │              │
     │─────────────▶│              │              │              │              │
     │              │ 3.OnDoOperation(Audit)│      │              │              │
     │              │─────────────▶│              │              │              │
     │              │              │ 4.判断核算类型 SetAccountType()│         │
     │              │              │──┤             │              │              │
     │              │              │  SA业务逻辑   │              │              │
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
     │              │              │ 12.更新AR_RECEIVABLE.FVerificationID         │
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
     │              │              │              │              │AR_WRITEOFFRECORD│
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

### 1.2 收付款认领场景（AR独有）

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  出纳   │    │ 应收会计 │    │BillRec- │    │  核销   │    │ 应收单  │
│         │    │         │    │ Report  │    │  服务    │    │         │
└────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘
     │              │              │              │              │
     │ 1.收款单审核  │              │              │              │
     │─────────────▶│              │              │              │
     │              │ 2.打开收付款认领│              │              │
     │              │─────────────▶│              │              │
     │              │              │ 3.选择客户和收款│              │
     │              │◀─────────────│              │              │
     │              │              │ 4.系统自动匹配应收单│              │
     │              │◀─────────────│              │              │
     │              │ 5.确认认领金额│              │              │
     │              │─────────────▶│              │              │
     │              │              │ 6.执行认领    │              │
     │              │              │─────────────▶│              │
     │              │              │              │ 7.更新FUnWriteOffAmt│
     │              │              │◀─────────────┼─────────────│
     │              │              │ 8.认领成功   │              │
     │              │◀─────────────│              │              │
     │              │              │              │              │
```

### 1.3 反核销场景

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ 财务主管│    │ARFinMatch│   │  凭证   │    │Verification│  │AR_RECEIVABLE│
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

### 1.4 内部应收核销场景

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ 财务主管│    │ARInnerIV│   │  凭证   │    │  AR模块 │    │ 组织账务│
│         │    │Special- │    │ 生成    │    │          │    │         │
│         │    │MatchEdit│    │         │    │          │    │         │
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

### 2.1 应收单据API

| API ID | API名称 | 输入参数 | 输出参数 | 触发事件 |
|---|---|---|---|---|
| API-AR-01 | SaveReceivable | AR_RECEIVABLE实体 | BillID/错误信息 | EVT-AR-01 |
| API-AR-02 | AuditReceivable | BillID | AuditResult | EVT-AR-02 |
| API-AR-03 | SetAccountType | BillID, IsNew | SetAccountTypeResult | EVT-AR-01/02 |
| API-AR-04 | UnAuditReceivable | BillID | UnAuditResult | - |

### 2.2 核销API

| API ID | API名称 | 输入参数 | 输出参数 | 触发事件 |
|---|---|---|---|---|
| API-AR-10 | FinMatch | SourceBillID, TargetBillID, MatchMethod, WriteOffAmt | WriteOffRecordID | EVT-AR-04 |
| API-AR-11 | FinMatchProcess | MatchParams | MatchResult(行数校验/金额计算) | EVT-AR-04 |
| API-AR-12 | UnVerify | WriteOffRecordID | UnVerifyResultAction | EVT-AR-05 |
| API-AR-13 | InnerClear | InnerIVRecordID, InnerAPRecordID, ClearAmt | InnerClearRecordID | EVT-AR-06 |
| API-AR-14 | InnerUnClear | InnerClearID | InnerUnClearResult | EVT-AR-07 |

### 2.3 钩稽API

| API ID | API名称 | 输入参数 | 输出参数 | 触发事件 |
|---|---|---|---|---|
| API-AR-20 | Verify | SourceBillID, TargetBillID, VerifyAmt | VerificationID | EVT-AR-03 |
| API-AR-21 | UnVerifyVerification | VerificationID | UnVerifyResult | - |
| API-AR-22 | HookReturn | TargetBillID | HookReturnResult | - |

### 2.4 收付款认领API（AR独有）

| API ID | API名称 | 输入参数 | 输出参数 | 触发事件 |
|---|---|---|---|---|
| API-AR-30 | BillRecReport | CustomerID, ReceiveRecordID | MatchResult | - |
| API-AR-31 | ClaimReceive | ClaimParams | ClaimResult | - |

### 2.5 凭证生成API

| API ID | API名称 | 输入参数 | 输出参数 | 触发事件 |
|---|---|---|---|---|
| API-AR-40 | GenerateVoucher | BillID, VchTemplateID | VoucherID | - |
| API-AR-41 | CreateBusinessVoucherMapping | SourceBillID, VoucherID | MappingID | - |
| API-AR-42 | QueryVoucherBySourceBill | SourceBillID | Voucher列表 | - |

### 2.6 报表API

| API ID | API名称 | 输入参数 | 输出参数 | 触发事件 |
|---|---|---|---|---|
| API-AR-50 | AgingAnalysis | OrgID, CustomerID, DateRange | AgingReport | - |
| API-AR-51 | ReceivableBillBalRpt | OrgID, CustomerID, Status | BalReport | - |
| API-AR-52 | MaturedDebt | OrgID, DueDateBefore | MaturedDebtReport | - |

---

## 三、交互边界

### 3.1 AR-GL边界

| 交互方向 | 交互内容 | 接口 | 数据流向 |
|---|---|---|---|
| AR→GL | 凭证生成请求 | VoucherGenerateServiceHelper.Generate() | AR触发GL生成凭证 |
| AR→GL | 核销凭证生成 | FinMatch触发 | AR触发GL生成核销凭证 |
| GL→AR | 凭证查询 | BAS_BusinessVoucher映射 | GL可查询业务来源 |
| GL→AR | 凭证追溯 | BAS_BusinessVoucher反向查询 | GL可追溯到AR单据 |

### 3.2 AR-SA边界（销售管理）

| 交互方向 | 交互内容 | 接口 | 数据流向 |
|---|---|---|---|
| SA→AR | 销售出库单审核触发 | SA单据审核事件 | SA触发AR生成暂收凭证 |
| SA→AR | 销售发票传入 | 销售发票录入 | SA传入AR应收单 |

### 3.3 AR-AP边界（应收应付对抵）

| 交互方向 | 交互内容 | 接口 | 数据流向 |
|---|---|---|---|
| AR↔AP | 内部核销 | InnerClear | AR内部应收与AP内部应付抵消 |

### 3.4 AR-CM边界（现金管理）

| 交互方向 | 交互内容 | 接口 | 数据流向 |
|---|---|---|---|
| CM→AR | 收款确认 | 收款单审核 | CM触发AR更新FRelateHadReceiveAmount |
| AR→CM | 收款认领 | BillRecReport | AR发起CM收款认领流程 |

---

## 四、交互模式分类

| 模式 | 场景 | 特点 | 风险 |
|---|---|---|---|
| 同步请求-响应 | 应收单保存/审核 | 即时反馈 | 超时风险 |
| 异步Floating窗口 | 凭证生成 | 窗口模式，可能超时 | 双向盲区 |
| 事件驱动 | 核销触发凭证 | 松耦合 | 事件丢失风险 |
| 回调 | 凭证生成完成通知 | AR等待GL回调 | 超时未回调 |
| 查询拉取 | 凭证追溯/报表 | 按需查询 | 数据一致性 |

---

## 五、交互-源码映射

| 交互 | 源码类/文件 | 核心方法 |
|---|---|---|
| 应收单保存 | ARReceivableEdit.cs | Save() |
| 应收单审核 | ARReceivableEdit.cs | OnDoOperation(Audit) |
| 核算类型判断 | ARReceivableEdit.cs | SetAccountType() SA业务逻辑 |
| 核销匹配 | ARFinMatch.cs | FinMatchProcess() |
| 核销反操作 | VerificationServiceHelper.cs | UnVerify() |
| 内部核销 | ARInnerIVSpecialMatchEdit.cs | InnerMatchProcess() |
| 凭证生成 | VoucherGenerateServiceHelper.cs | Generate() |
| 钩稽确认 | VerificationServiceHelper.cs | Verify() |
| 收付款认领 | BillRecReport.cs | BillRecReport处理 |
| 账龄分析 | ReceivableBillReport.cs | AgingCalculate() |
| 凭证追溯 | ViewGlVoucher.cs | QueryBySourceBill() |
