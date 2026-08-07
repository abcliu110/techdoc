# DA7 实现映射 — K3Cloud AR应收管理模块

## 模板加载记录
已读取 AP应付管理 SOP-00-DA7-实现映射.md，门禁检查 5 项全部通过（AR镜像）。

---

## 一、核心类映射（14个）

### 1.1 业务单据类（3个）

| 类名 | 文件名 | 命名空间 | 核心职责 | 关键方法 |
|---|---|---|---|---|
| ARReceivableEdit | ARReceivableEdit.cs | Kingdee.K3.FIN.AR.Business | 应收单据编辑主插件 | OnLoad(), SetAccountType(), OnDoOperation() |
| ARReceivableList | ARReceivableList.cs | Kingdee.K3.FIN.AR.Business | 应收单列表插件 | PageLoad(), Filter() |
| ReceivableSumReport | ReceivableSumReport.cs | Kingdee.K3.FIN.AR.Report | 应收汇总报表 | BuildReport() |

### 1.2 核销匹配类（4个）

| 类名 | 文件名 | 命名空间 | 核心职责 | 关键方法 |
|---|---|---|---|---|
| ARFinMatch | ARFinMatch.cs | Kingdee.K3.FIN.AR.Business | 核销匹配界面 | FinMatchProcess(), CheckRowLimit() |
| MatchServiceHelper | MatchServiceHelper.cs | Kingdee.K3.FIN.AR.Service | 核销匹配服务（与AP共用） | Match(), Calculate() |
| MatchParameter | MatchParameter.cs | Kingdee.K3.FIN.AR.Model | 匹配参数模型 | - |
| MatchResult | MatchResult.cs | Kingdee.K3.FIN.AR.Model | 匹配结果模型 | - |

### 1.3 钩稽服务类（2个）

| 类名 | 文件名 | 命名空间 | 核心职责 | 关键方法 |
|---|---|---|---|---|
| VerificationServiceHelper | VerificationServiceHelper.cs | Kingdee.K3.FIN.AR.Service（与AP共用） | 钩稽服务 | Verify(), UnVerify(), HookReturn() |
| UnVerifyResultAction | UnVerifyResultAction.cs | Kingdee.K3.FIN.AR.Model | 反核销结果动作 | - |

### 1.4 凭证生成类（2个）

| 类名 | 文件名 | 命名空间 | 核心职责 | 关键方法 |
|---|---|---|---|---|
| VoucherGenerateServiceHelper | VoucherGenerateServiceHelper.cs | Kingdee.K3.FIN.AR.Service（与AP共用） | 凭证生成服务 | Generate(), ValidateScheme() |
| VoucherGenerateParameter | VoucherGenerateParameter.cs | Kingdee.K3.FIN.AR.Model | 凭证生成参数 | - |

### 1.5 内部核销类（2个）

| 类名 | 文件名 | 命名空间 | 核心职责 | 关键方法 |
|---|---|---|---|---|
| ARInnerIVSpecialMatchEdit | ARInnerIVSpecialMatchEdit.cs | Kingdee.K3.FIN.AR.Business | AR内部特殊匹配编辑 | InnerMatchProcess(), InnerIVProcess() |
| InnerClearServiceHelper | InnerClearServiceHelper.cs | Kingdee.K3.FIN.AR.Service | 内部核销服务 | Clear(), UnClear() |

### 1.6 报表类（3个，AR独有）

| 类名 | 文件名 | 命名空间 | 核心职责 | 关键方法 |
|---|---|---|---|---|
| BillRecReport | BillRecReport.cs | Kingdee.K3.FIN.AR.Report | 收付款认领报表（AR独有） | BillRecReport处理, Claim处理 |
| ReceivableBillReport | ReceivableBillReport.cs | Kingdee.K3.FIN.AR.Report | 应收账龄报表 | AgingCalculate() |
| ReceivableBillBalRpt | ReceivableBillBalRpt.cs | Kingdee.K3.FIN.AR.Report | 应收余额明细 | BuildReport() |

---

## 二、DEC卡（8张，含AR独有）

### DEC-01：核销匹配DEC

| 维度 | 内容 |
|---|---|
| **决策点** | 如何确定核销匹配的行数组合？ |
| **环境** | 用户在ARFinMatch界面选择来源单据和目标单据，执行核销 |
| **行动** | ARFinMatch.FinMatchProcess()根据iFinMatchMethod执行不同校验 |
| **结果** | 校验通过则创建AR_WRITEOFFRECORD，更新未核销金额 |

```
IF iFinMatchMethod == 72 THEN
    // 普通核销：自动按金额匹配，无行数限制
    CALL MatchServiceHelper.Match()
ELSE IF iFinMatchMethod == 73 THEN
    // 特殊核销：行数限制
    IF rowCountCombination NOT IN {1:1, 1:0, 2:0(正负)} THEN
        THROW AR-E102 // 行数不匹配
    CALL MatchServiceHelper.Match()
```

### DEC-02：核算类型判断DEC

| 维度 | 内容 |
|---|---|
| **决策点** | 如何判断应收单的核算类型（暂收/财务）？ |
| **环境** | 应收单保存或审核时，SetAccountType()被调用 |
| **行动** | ARReceivableEdit.SetAccountType()根据业务类型(SA/其他)执行嵌套判断 |
| **结果** | 确定FSetAccountType值（暂收=2, 财务=3） |

```
// SA销售业务逻辑（部分）
string sBusType = GetBusinessType();
if (sBusType == "SA") {
    if (出库单已审核 && 发票未开) SetAccountType(暂收);
    if (出库单已审核 && 发票已开) SetAccountType(财务);
    // ... 嵌套判断
} else {
    // 其他业务类型逻辑
}
```

### DEC-03：反核销补偿DEC

| 维度 | 内容 |
|---|---|
| **决策点** | 反核销后是否需要生成补偿凭证？ |
| **环境** | 用户执行反核销操作，UnVerify()被调用 |
| **行动** | VerificationServiceHelper.UnVerifyDataById()返回UnVerifyResultAction |
| **结果** | 根据Action类型决定是否生成补偿凭证，恢复核销状态 |

### DEC-04：收付款认领DEC（AR独有）

| 维度 | 内容 |
|---|---|
| **决策点** | 如何实现客户对账的自动匹配？ |
| **环境** | 用户在BillRecReport界面选择客户和收款记录 |
| **行动** | BillRecReport自动匹配该客户名下的应收单据 |
| **结果** | 确认认领金额后执行认领，更新FUnWriteOffAmt |

### DEC-05：凭证生成时机DEC

| 维度 | 内容 |
|---|---|
| **决策点** | 在什么时机触发凭证生成？ |
| **环境** | 业务单据状态变更（保存/审核/核销/收款） |
| **行动** | 根据业务事件类型调用VoucherGenerateServiceHelper.Generate() |
| **结果** | 生成GL_VOUCHER，创建BAS_BusinessVoucher映射 |

### DEC-06：内部应收核销组织校验DEC

| 维度 | 内容 |
|---|---|
| **决策点** | 如何判断两个组织是否可以进行内部应收核销？ |
| **环境** | 用户执行内部应收核销，ARInnerIVSpecialMatchEdit被调用 |
| **行动** | ARInnerIVSpecialMatchEdit校验组织关系（同体系） |
| **结果** | 校验通过则执行内部抵消，生成内部抵消凭证 |

### DEC-07：钩稽确认DEC

| 维度 | 内容 |
|---|---|
| **决策点** | 钩稽确认如何影响核算类型转换？ |
| **环境** | Verify()被调用，建立暂收与财务单据的关联 |
| **行动** | VerificationServiceHelper.Verify()更新AR_VERIFICATION表 |
| **结果** | 暂收单据FSetAccountType保持暂收，财务单据确认钩稽关系 |

### DEC-08：账龄分析DEC

| 维度 | 内容 |
|---|---|
| **决策点** | 如何计算应收账款的账龄区间？ |
| **环境** | 用户打开账龄分析报表，设置参数 |
| **行动** | ReceivableBillReport.AgingCalculate()按到期日期和未核销金额计算 |
| **结果** | 生成账龄区间报表（0-30/31-60/61-90/90+） |

---

## 三、关键方法实现映射

| 方法名 | 类名 | 行号 | 实现要点 |
|---|---|---|---|
| FinMatchProcess | ARFinMatch.cs | 171-196 | 特殊核销行数限制判断 |
| FinMatchProcess | ARFinMatch.cs | 156-209 | 核销匹配复杂校验 |
| SetAccountType | ARReceivableEdit.cs | - | SA业务核算类型判断 |
| Verify | VerificationServiceHelper.cs | 50-80 | 钩稽确认逻辑 |
| UnVerify | VerificationServiceHelper.cs | 100-117 | UnVerifyResultAction返回结构 |
| Match | MatchServiceHelper.cs | - | 未核销金额计算 |
| Generate | VoucherGenerateServiceHelper.cs | - | 凭证生成服务 |
| InnerMatchProcess | ARInnerIVSpecialMatchEdit.cs | - | 内部应收特殊匹配 |
| BillRecReport | BillRecReport.cs | - | 收付款认领处理 |
| AgingCalculate | ReceivableBillReport.cs | - | 账龄计算逻辑 |

---

## 四、AR vs AP 类映射对比

| 对比维度 | AR应收管理 | AP应付管理 |
|---|---|---|
| 业务单据编辑类 | ARReceivableEdit | PayableEdit |
| 核销匹配类 | ARFinMatch | FinMatch |
| 钩稽服务 | VerificationServiceHelper（共用） | VerificationServiceHelper（共用） |
| 凭证生成服务 | VoucherGenerateServiceHelper（共用） | VoucherGenerateServiceHelper（共用） |
| 内部核销编辑 | ARInnerIVSpecialMatchEdit | InnerClearRecordEdit |
| 账龄分析报表 | ReceivableBillReport | AgingAnalysis |
| AR独有 | BillRecReport、ReceivableBillBalRpt | 无对应 |

---

## 五、模式应用映射

| 设计模式 | 应用场景 | 源码证据 |
|---|---|---|
| Strategy | SA vs 其他不同核算逻辑 | ARReceivableEdit.cs SetAccountType() |
| Template Method | 应收单保存/审核/反审核模板 | ARReceivableEdit.cs OnLoad/OnDoOperation |
| Helper/Service | 核销/凭证/钩稽服务封装 | MatchServiceHelper等（与AP共用） |
| Observer | 业务事件触发下游处理 | 凭证生成事件 |
| Factory | 凭证生成工厂 | VoucherGenerateServiceHelper |
| Builder | 核销参数构建 | MatchParameter构建 |

---

## 六、实现复杂度评估

| 类 | 圈复杂度 | 行数 | 关键风险 |
|---|---|---|---|
| ARReceivableEdit.SetAccountType() | 高（嵌套判断） | ~80 | SA业务逻辑难以维护 |
| ARFinMatch.FinMatchProcess() | 高(15-20) | ~80 | 行数限制逻辑复杂 |
| MatchServiceHelper.Match() | 中(8-12) | ~60 | 金额计算准确性 |
| VerificationServiceHelper.UnVerify() | 中(6-10) | ~50 | UnVerifyResultAction处理 |
| VoucherGenerateServiceHelper.Generate() | 中(8-12) | ~70 | Floating窗口超时 |

---

## 七、依赖关系图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           AR类依赖关系图                                  │
└─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────┐
  │   ARReceivableEdit  │ ←─────────────── AR业务单据编辑入口
  │     (主插件)         │
  └─────────┬───────────┘
            │ 依赖
            ▼
  ┌────────────────────────────────────────────────────────────────────────┐
  │                          Service层（业务服务，与AP共用）                  │
  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐     │
  │  │MatchServiceHelper│  │VoucherGenerate   │  │Verification      │     │
  │  │   (核销匹配)      │  │ServiceHelper     │  │ServiceHelper     │     │
  │  │   (与AP共用)      │  │   (凭证生成)      │  │   (钩稽服务)      │     │
  │  │                  │  │   (与AP共用)      │  │   (与AP共用)      │     │
  │  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘     │
  └───────────┼──────────────────────┼─────────────────────┼───────────────┘
              │                      │                     │
              ▼                      ▼                     ▼
  ┌────────────────────────────────────────────────────────────────────────┐
  │                          数据层（Model/Entity）                         │
  │  MatchParameter│MatchResult│VoucherGenerateParameter│UnVerifyResultAction│
  └────────────────────────────────────────────────────────────────────────┘
              │
              ▼
  ┌──────────────────────┐     ┌──────────────────────────┐
  │     ARFinMatch       │     │ ARInnerIVSpecialMatchEdit│
  │     (核销界面)        │     │   (内部应收特殊匹配)      │
  └──────────────────────┘     └──────────────────────────┘

  ┌────────────────────────────────────────────────────────────────────────┐
  │                          报表层（Report）                               │
  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐     │
  │  │ReceivableBill   │  │ ReceivableBill   │  │ ReceivableSum    │     │
  │  │  Report         │  │  BalRpt          │  │  Report          │     │
  │  │  (账龄分析)      │  │  (余额明细)      │  │  (客户汇总)       │     │
  │  └──────────────────┘  └──────────────────┘  └──────────────────┘     │
  │  ┌────────────────────────────────────────────────────────────────┐   │
  │  │                    BillRecReport (AR独有)                      │   │
  │  │                    收付款认领报表                               │   │
  │  └────────────────────────────────────────────────────────────────┘   │
  └────────────────────────────────────────────────────────────────────────┘
```
