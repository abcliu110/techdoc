# DA7 实现映射 — K3Cloud AP应付管理模块

## 模板加载记录
已读取 SOP-00-DA7-模板.md，门禁检查 5 项全部通过。

---

## 一、核心类映射（14个）

### 1.1 业务单据类（3个）

| 类名 | 文件名 | 命名空间 | 核心职责 | 关键方法 |
|---|---|---|---|---|
| PayableEdit | PayableEdit.cs | Kingdee.K3.FIN.AP.Business | 应付单据编辑主插件 | OnLoad(), SetAccountType(), OnDoOperation() |
| PayableList | PayableList.cs | Kingdee.K3.FIN.AP.Business | 应付单列表插件 | PageLoad(), Filter() |
| PayableSummary | PayableSummary.cs | Kingdee.K3.FIN.AP.Report | 应付汇总报表 | BuildReport() |

### 1.2 核销匹配类（4个）

| 类名 | 文件名 | 命名空间 | 核心职责 | 关键方法 |
|---|---|---|---|---|
| FinMatch | FinMatch.cs | Kingdee.K3.FIN.AP.Business | 核销匹配界面 | FinMatchProcess(), CheckRowLimit() |
| MatchServiceHelper | MatchServiceHelper.cs | Kingdee.K3.FIN.AP.Service | 核销匹配服务 | Match(), Calculate() |
| MatchParameter | MatchParameter.cs | Kingdee.K3.FIN.AP.Model | 匹配参数模型 | - |
| MatchResult | MatchResult.cs | Kingdee.K3.FIN.AP.Model | 匹配结果模型 | - |

### 1.3 钩稽服务类（2个）

| 类名 | 文件名 | 命名空间 | 核心职责 | 关键方法 |
|---|---|---|---|---|
| VerificationServiceHelper | VerificationServiceHelper.cs | Kingdee.K3.FIN.AP.Service | 钩稽服务 | Verify(), UnVerify(), HookReturn() |
| UnVerifyResultAction | UnVerifyResultAction.cs | Kingdee.K3.FIN.AP.Model | 反核销结果动作 | - |

### 1.4 凭证生成类（2个）

| 类名 | 文件名 | 命名空间 | 核心职责 | 关键方法 |
|---|---|---|---|---|
| VoucherGenerateServiceHelper | VoucherGenerateServiceHelper.cs | Kingdee.K3.FIN.AP.Service | 凭证生成服务 | Generate(), ValidateScheme() |
| VoucherGenerateParameter | VoucherGenerateParameter.cs | Kingdee.K3.FIN.AP.Model | 凭证生成参数 | - |

### 1.5 内部核销类（2个）

| 类名 | 文件名 | 命名空间 | 核心职责 | 关键方法 |
|---|---|---|---|---|
| InnerClearRecordEdit | InnerClearRecordEdit.cs | Kingdee.K3.FIN.AP.Business | 内部核销编辑 | InnerClearProcess(), InnerUnClearProcess() |
| InnerClearServiceHelper | InnerClearServiceHelper.cs | Kingdee.K3.FIN.AP.Service | 内部核销服务 | Clear(), UnClear() |

### 1.6 报表类（2个）

| 类名 | 文件名 | 命名空间 | 核心职责 | 关键方法 |
|---|---|---|---|---|
| AgingAnalysis | AgingAnalysis.cs | Kingdee.K3.FIN.AP.Report | 账龄分析报表 | AgingCalculate() |
| PayableOpenDetail | PayableOpenDetail.cs | Kingdee.K3.FIN.AP.Report | 应付余额明细 | BuildReport() |

---

## 二、DEC卡（7张）

### DEC-01：核销匹配DEC

| 维度 | 内容 |
|---|---|
| **决策点** | 如何确定核销匹配的行数组合？ |
| **环境** | 用户在FinMatch界面选择来源单据和目标单据，执行核销 |
| **行动** | FinMatch.FinMatchProcess()根据iFinMatchMethod执行不同校验 |
| **结果** | 校验通过则创建AP_WRITEOFFRECORD，更新未核销金额 |

```
IF iFinMatchMethod == 72 THEN
    // 普通核销：自动按金额匹配，无行数限制
    CALL MatchServiceHelper.Match()
ELSE IF iFinMatchMethod == 73 THEN
    // 特殊核销：行数限制
    IF rowCountCombination NOT IN {1:1, 1:0, 2:0(正负)} THEN
        THROW AP-E102 // 行数不匹配
    CALL MatchServiceHelper.Match()
```

### DEC-02：核算类型判断DEC

| 维度 | 内容 |
|---|---|
| **决策点** | 如何判断应付单的核算类型（暂估/财务）？ |
| **环境** | 应付单保存或审核时，SetAccountType()被调用 |
| **行动** | PayableEdit.SetAccountType()根据业务类型(CG/FY)执行嵌套70+层判断 |
| **结果** | 确定FSetAccountType值（暂估=2, 财务=3） |

```
// CG采购业务逻辑（部分）
string sBusType = GetBusinessType();
if (sBusType == "CG") {
    if (入库单已审核 && 发票未到) SetAccountType(暂估);
    if (入库单已审核 && 发票已到) SetAccountType(财务);
    // ... 70+层嵌套
} else if (sBusType == "FY") {
    // FY费用逻辑完全不同
}
// FY逻辑分支...
```

### DEC-03：反核销补偿DEC

| 维度 | 内容 |
|---|---|
| **决策点** | 反核销后是否需要生成补偿凭证？ |
| **环境** | 用户执行反核销操作，UnVerify()被调用 |
| **行动** | VerificationServiceHelper.UnVerifyDataById()返回UnVerifyResultAction |
| **结果** | 根据Action类型决定是否生成补偿凭证，恢复核销状态 |

```
UnVerifyResultAction action = UnVerifyDataById(writeOffRecordId);
IF action.NeedCompensationVoucher THEN
    CALL VoucherGenerateServiceHelper.Generate(补偿凭证)
IF action.NeedStatusRecovery THEN
    UPDATE AP_PAYABLE.FWriteOffStatus = 恢复前状态
```

### DEC-04：凭证生成时机DEC

| 维度 | 内容 |
|---|---|
| **决策点** | 在什么时机触发凭证生成？ |
| **环境** | 业务单据状态变更（保存/审核/核销） |
| **行动** | 根据业务事件类型调用VoucherGenerateServiceHelper.Generate() |
| **结果** | 生成GL_VOUCHER，创建BAS_BusinessVoucher映射 |

### DEC-05：内部核销组织校验DEC

| 维度 | 内容 |
|---|---|
| **决策点** | 如何判断两个组织是否可以进行内部核销？ |
| **环境** | 用户执行内部核销，InnerClearRecordEdit被调用 |
| **行动** | InnerClearRecordEdit校验组织关系（同体系） |
| **结果** | 校验通过则执行内部抵消，生成内部抵消凭证 |

### DEC-06：钩稽确认DEC

| 维度 | 内容 |
|---|---|
| **决策点** | 钩稽确认如何影响核算类型转换？ |
| **环境** | Verify()被调用，建立暂估与财务单据的关联 |
| **行动** | VerificationServiceHelper.Verify()更新AP_VERIFICATION表 |
| **结果** | 暂估单据FSetAccountType保持暂估，财务单据确认钩稽关系 |

### DEC-07：账龄分析DEC

| 维度 | 内容 |
|---|---|
| **决策点** | 如何计算应付账款的账龄区间？ |
| **环境** | 用户打开账龄分析报表，设置参数 |
| **行动** | AgingAnalysis.AgingCalculate()按到期日期和未核销金额计算 |
| **结果** | 生成账龄区间报表（0-30/31-60/61-90/90+） |

---

## 三、关键方法实现映射

| 方法名 | 类名 | 行号 | 实现要点 |
|---|---|---|---|
| FinMatchProcess | FinMatch.cs | 171-196 | 特殊核销行数限制判断 |
| FinMatchProcess | FinMatch.cs | 156-209 | 核销匹配复杂校验 |
| SetAccountType | PayableEdit.cs | 643-715 | CG/FY核算类型70+层嵌套判断 |
| Verify | VerificationServiceHelper.cs | 50-80 | 钩稽确认逻辑 |
| UnVerify | VerificationServiceHelper.cs | 100-117 | UnVerifyResultAction返回结构 |
| Match | MatchServiceHelper.cs | - | 未核销金额计算 |
| Generate | VoucherGenerateServiceHelper.cs | - | 凭证生成服务 |
| InnerClearProcess | InnerClearRecordEdit.cs | 54-67 | 内部核销权限校验 |
| CheckPermission | InnerClearRecordEdit.cs | 54-67 | "反清理"权限检查 |
| AgingCalculate | AgingAnalysis.cs | - | 账龄计算逻辑 |

---

## 四、模式应用映射

| 设计模式 | 应用场景 | 源码证据 |
|---|---|---|
| Strategy | CG vs FY不同核算逻辑 | PayableEdit.cs SetAccountType() |
| Template Method | 应付单保存/审核/反审核模板 | PayableEdit.cs OnLoad/OnDoOperation |
| Helper/Service | 核销/凭证/钩稽服务封装 | MatchServiceHelper等 |
| Observer | 业务事件触发下游处理 | 凭证生成事件 |
| Factory | 凭证生成工厂 | VoucherGenerateServiceHelper |
| Builder | 核销参数构建 | MatchParameter构建 |

---

## 五、实现复杂度评估

| 类 | 圈复杂度 | 行数 | 关键风险 |
|---|---|---|---|
| PayableEdit.SetAccountType() | 极高(70+) | ~100 | CG/FY逻辑难以维护 |
| FinMatch.FinMatchProcess() | 高(15-20) | ~80 | 行数限制逻辑复杂 |
| MatchServiceHelper.Match() | 中(8-12) | ~60 | 金额计算准确性 |
| VerificationServiceHelper.UnVerify() | 中(6-10) | ~50 | UnVerifyResultAction处理 |
| VoucherGenerateServiceHelper.Generate() | 中(8-12) | ~70 | Floating窗口超时 |

---

## 六、依赖关系图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           AP类依赖关系图                                  │
└─────────────────────────────────────────────────────────────────────────┘

  ┌────────────────┐
  │  PayableEdit   │ ←─────────────── AP业务单据编辑入口
  │  (主插件)       │
  └───────┬────────┘
          │ 依赖
          ▼
  ┌────────────────────────────────────────────────────────────────────────┐
  │                          Service层（业务服务）                           │
  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐     │
  │  │MatchServiceHelper│  │VoucherGenerate   │  │Verification      │     │
  │  │   (核销匹配)      │  │ServiceHelper     │  │ServiceHelper     │     │
  │  └────────┬─────────┘  │   (凭证生成)      │  │   (钩稽服务)      │     │
  │           │             └────────┬─────────┘  └────────┬─────────┘     │
  └───────────┼──────────────────────┼─────────────────────┼───────────────┘
              │                      │                     │
              ▼                      ▼                     ▼
  ┌────────────────────────────────────────────────────────────────────────┐
  │                          数据层（Model/Entity）                         │
  │  MatchParameter│MatchResult│VoucherGenerateParameter│UnVerifyResultAction│
  └────────────────────────────────────────────────────────────────────────┘
              │
              ▼
  ┌──────────────────┐     ┌──────────────────┐
  │  FinMatch        │     │InnerClearRecord  │
  │  (核销界面)       │     │  Edit            │
  │                   │     │  (内部核销编辑)   │
  └──────────────────┘     └──────────────────┘

  ┌────────────────────────────────────────────────────────────────────────┐
  │                          报表层（Report）                               │
  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐     │
  │  │  AgingAnalysis   │  │PayableOpenDetail│  │PayableSummary    │     │
  │  │  (账龄分析)       │  │  (余额明细)      │  │  (应付汇总)       │     │
  │  └──────────────────┘  └──────────────────┘  └──────────────────┘     │
  └────────────────────────────────────────────────────────────────────────┘
```
