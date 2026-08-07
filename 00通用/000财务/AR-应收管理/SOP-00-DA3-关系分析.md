# DA3 关系分析 — K3Cloud AR应收管理模块

## 模板加载记录
已读取 AP应付管理 SOP-00-DA3-关系分析.md，门禁检查 5 项全部通过（AR镜像）。

---

## 一、业务对象清单（10个）

| 编号 | 对象名称 | 对象类型 | 核心职责 | 关键属性 |
|---|---|---|---|---|
| BO-01 | AR_RECEIVABLE | 业务单据 | 应收单据主表，记录应收债权 | FBillNo, FSetAccountType, FWriteOffStatus, FUnWriteOffAmt |
| BO-02 | AR_RECEIVABLEENTRY | 业务单据分录 | 应收单据行，记录分项明细 | FEntryID, FMaterialID, FQty, FPrice, FAmount |
| BO-03 | AR_WRITEOFFRECORD | 核销记录 | 记录核销事务详情 | FWriteOffRecordID, FSourceBillID, FTargetBillID, FWriteOffAmt |
| BO-04 | AR_WRITEOFFRECORDENTRY | 核销分录 | 核销双方的分录对应 | FWriteOffEntryID, FSourceEntryID, FTargetEntryID, FAmt |
| BO-05 | AR_VERIFICATION | 钩稽关系 | 暂收与财务单据的对应关系 | FVerificationID, FSourceBillID, FTargetBillID, FVerificationStatus |
| BO-06 | AR_ReceivableMatchRule | 匹配规则 | 核销匹配的业务规则配置 | FMatchRuleID, FMatchMethod, FRowLimit, FOrgID |
| BO-07 | AR_InnerIVRecord | 内部应收 | 组织间内部应收单 | FInnerIVRecordID, FInnerOrgID, FAmount |
| BO-08 | AR_InnerAPRecord | 内部应付 | 组织间内部应付单（AR侧） | FInnerAPRecordID, FInnerOrgID, FAmount |
| BO-09 | AR_InnerClearRecord | 内部核销 | 组织间核销记录 | FInnerClearID, FSourceRecordID, FTargetRecordID, FClearAmt |
| BO-10 | BAS_BusinessVoucher | 业务凭证映射 | 业务单据与GL凭证的关联 | FMappingID, FSourceBillType, FSourceBillID, FVoucherID |

---

## 二、关联关系清单（13条）

### 2.1 核心关联（5条）

| 编号 | 关系名称 | 起点→终点 | 关系类型 | 说明 |
|---|---|---|---|---|
| REL-01 | 单据-分录 | AR_RECEIVABLE→AR_RECEIVABLEENTRY | 1:N | 一张应收单含多条分录行 |
| REL-02 | 核销-来源 | AR_WRITEOFFRECORD→AR_RECEIVABLE | N:1 | 核销记录关联来源应收单 |
| REL-03 | 核销-目标 | AR_WRITEOFFRECORD→AR_RECEIVABLE | N:1 | 核销记录关联目标应收单（或收款单） |
| REL-04 | 核销-凭证 | AR_WRITEOFFRECORD→GL_VOUCHER | N:1 | 核销触发生成GL凭证 |
| REL-05 | 映射-凭证 | BAS_BusinessVoucher→GL_VOUCHER | N:1 | 业务单据映射到GL凭证 |

### 2.2 钩稽关联（3条）

| 编号 | 关系名称 | 起点→终点 | 关系类型 | 说明 |
|---|---|---|---|---|
| REL-06 | 钩稽-暂收 | AR_VERIFICATION→AR_RECEIVABLE(暂收) | N:1 | 钩稽关系关联暂收单据 |
| REL-07 | 钩稽-财务 | AR_VERIFICATION→AR_RECEIVABLE(财务) | N:1 | 钩稽关系关联财务单据 |
| REL-08 | 钩稽-核销 | AR_VERIFICATION→AR_WRITEOFFRECORD | 1:N | 钩稽确认后触发核销 |

### 2.3 内部核销关联（3条）

| 编号 | 关系名称 | 起点→终点 | 关系类型 | 说明 |
|---|---|---|---|---|
| REL-09 | 内部核销-应收 | AR_InnerClearRecord→AR_InnerIVRecord | N:1 | 内部核销关联内部应收单 |
| REL-10 | 内部核销-应付 | AR_InnerClearRecord→AR_InnerAPRecord | N:1 | 内部核销关联内部应付单（AR侧） |
| REL-11 | 内部应收-组织 | AR_InnerIVRecord→BD_Org | N:1 | 内部应收关联内部组织 |

### 2.4 匹配与规则关联（2条）

| 编号 | 关系名称 | 起点→终点 | 关系类型 | 说明 |
|---|---|---|---|---|
| REL-12 | 单据-规则 | AR_RECEIVABLE→AR_ReceivableMatchRule | N:1 | 应收单按规则匹配核销 |
| REL-13 | 规则-组织 | AR_ReceivableMatchRule→BD_Org | N:1 | 匹配规则按组织配置 |

---

## 三、关系图（ASCII）

```
┌─────────────────────────────────────────────────────────────────────┐
│                        AR应收管理业务对象关系图                        │
└─────────────────────────────────────────────────────────────────────┘

  ┌────────────────┐         ┌────────────────────┐
  │   BD_Customer   │◀────────│   AR_RECEIVABLE    │ (REL-客户)
  │   客户主数据     │  N:1    │    应收单据主表     │
  └────────────────┘         └─────────┬──────────┘
                                        │ 1:N (REL-01)
                                        ▼
                               ┌────────────────────┐
                               │  AR_RECEIVABLEENTRY │
                               │    应收单据分录      │
                               └────────────────────┘

  ┌────────────────┐         ┌────────────────────┐
  │   BD_Org        │◀────────│AR_ReceivableMatchRule│ (REL-13)
  │   组织主数据     │  N:1    │     匹配规则        │
  └────────────────┘         └─────────┬──────────┘
                                        │ N:1 (REL-12)
                                        ▼
                               ┌────────────────────┐
                               │   AR_RECEIVABLE    │
                               └─────────┬──────────┘
                                         │
          ┌──────────────────────────────┼──────────────────────────────┐
          │                              │                              │
          ▼                              ▼                              ▼
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│  AR_VERIFICATION    │    │ AR_WRITEOFFRECORD   │    │BAS_BusinessVoucher │
│    钩稽关系          │    │    核销记录          │    │   业务凭证映射      │
│ 暂收 ◀───────▶ 财务  │    │                     │    │                    │
└─────────┬───────────┘    └──────────┬──────────┘    └─────────┬──────────┘
          │                           │                           │
          │ 1:N (REL-08)              │ N:1 (REL-04)             │ N:1 (REL-05)
          ▼                           ▼                           ▼
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│ AR_WRITEOFFRECORD   │    │    GL_VOUCHER      │    │    GL_VOUCHER       │
│    核销记录          │    │    GL凭证          │    │    GL凭证            │
└─────────┬───────────┘    └─────────────────────┘    └─────────────────────┘
          │
          │ 1:N
          ▼
┌─────────────────────┐
│AR_WRITEOFFRECORDENTRY│
│     核销分录          │
└─────────────────────┘

  ┌─────────────────────────────────────────────────────────────────┐
  │                      内部核销子域                                  │
  └─────────────────────────────────────────────────────────────────┘

       ┌────────────────────┐    ┌─────────────────────┐
       │  AR_InnerIVRecord  │    │  AR_InnerAPRecord   │
       │    内部应收单       │    │    内部应付单(AR侧)  │
       │◀──────────────────▶│ N:1 (REL-09/10)
       └─────────┬──────────┘    └──────────┬──────────┘
                 │ N:1 (REL-11)            │
                 ▼                         ▼
        ┌────────────────┐          ┌────────────────┐
        │    BD_Org      │          │  AR_InnerClearRecord
        │   内部组织      │          │     内部核销    │
        └────────────────┘          └────────────────┘
```

---

## 四、关键路径清单（10条）

### 4.1 销售应收核销路径（核心主路径）

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-01 | 销售应收核销 | 销售出库→暂收凭证→发票录入→发票审核→核算类型判断→发票凭证→钩稽确认→核销→核销凭证 | AR_RECEIVABLE→AR_VERIFICATION→AR_WRITEOFFRECORD→GL_VOUCHER | 核心主路径 |

### 4.2 收付款认领路径（AR独有）

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-02 | 收付款认领 | 收款单审核→打开认领界面→选择客户和收款→系统自动匹配应收单→确认认领金额→执行认领→更新未核销金额 | AR_RECEIVABLE→收款单→BillRecReport | 核心分支（AR独有） |

### 4.3 预收账款核销路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-03 | 预收账款核销 | 录入预收账款单→审核预收单→生成预收凭证→销售发生时执行核销→核销后更新余额 | AR_RECEIVABLE(预收)→AR_WRITEOFFRECORD | 核心分支 |

### 4.4 特殊核销路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-04 | 特殊核销 | 选择单据→行数校验(1:1/1:0/2:0)→金额计算→核销执行→凭证生成 | AR_RECEIVABLE→AR_ReceivableMatchRule→AR_WRITEOFFRECORD | 核心分支 |

### 4.5 反核销路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-05 | 反核销 | 打开核销记录→反核销→权限校验→UnVerifyResultAction→补偿凭证→状态恢复 | AR_WRITEOFFRECORD→GL_VOUCHER→AR_RECEIVABLE | 异常补偿 |

### 4.6 钩稽返回路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-06 | 钩稽返回 | 财务单→钩稽返回→暂收单→核算类型回退→凭证冲销 | AR_RECEIVABLE→AR_VERIFICATION | 异常分支 |

### 4.7 内部应收核销路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-07 | 内部应收核销 | 内部应收单→内部应付单(AR侧)→内部核销→内部抵消凭证→组织往来清零 | AR_InnerIVRecord→AR_InnerAPRecord→AR_InnerClearRecord | 边缘路径 |

### 4.8 账龄分析路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-08 | 账龄分析 | 应收余额→未核销金额→到期日期→账龄区间→逾期报表 | AR_RECEIVABLE→ReceivableBillReport | 分析报表 |

### 4.9 凭证追溯路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-09 | 凭证追溯 | 应收单→BAS_BusinessVoucher映射→GL_VOUCHER凭证→分录明细 | AR_RECEIVABLE→BAS_BusinessVoucher→GL_VOUCHERENTRY | 查询追溯 |

### 4.10 核销记录追溯路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-10 | 核销追溯 | 应收单→AR_WRITEOFFRECORD→核销双方单据→凭证 | AR_RECEIVABLE→AR_WRITEOFFRECORD→GL_VOUCHER | 查询追溯 |

---

## 五、关键路径时序摘要

### PATH-01：销售应收核销（最关键路径）

```
参与者: 销售员 → 应收会计 → 系统
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│销售出库单 │    │ 应收单据  │    │  凭证生成 │    │ 钩稽关系 │    │ 核销记录  │
└────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘
     │ 审核          │              │              │              │
     ├──────────────▶│ SetAccountType(暂收)        │              │
     │               │──────────▶  │ 暂收凭证     │              │
     │               │              ├────────────▶│              │
     │               │ 发票录入     │              │              │
     │               ├──────────────┤              │              │
     │               │ 发票审核     │              │              │
     │               ├──────────────┤              │              │
     │               │ SetAccountType(财务)       │              │
     │               │──────────▶  │ 发票凭证     │              │
     │               │              ├────────────▶│              │
     │               │ 钩稽确认     │              │              │
     │               ├────────────────────────────▶│              │
     │               │              │              │ 核销执行    │
     │               │              │              ├────────────▶│
     │               │              │ 核销凭证     │              │
     │               │              │              │◀────────────┤
     │               │ 更新FWriteOffStatus         │              │
     │               │◀────────────────────────────────────────────┤
```

---

## 六、AR vs AP 关系对比

| 对比维度 | AR应收管理 | AP应付管理 |
|---|---|---|
| 核心单据 | AR_RECEIVABLE（应收单） | AP_PAYABLE（应付单） |
| 债务方 | 客户（Customer） | 供应商（Supplier） |
| 核销对象 | 应收单 vs 收款单 | 应付单 vs 付款单 |
| AR独有 | 收付款认领（BillRecReport） | 无对应功能 |
| 钩稽起点 | 销售出库单审核 | 采购入库单审核 |
| 内部核销 | AR_InnerIVRecord ↔ AR_InnerAPRecord | AP_InnerIVRecord ↔ AP_InnerPayRecord |

---

## 七、关系复杂度分析

| 维度 | 评估 | 说明 |
|---|---|---|
| 对象数量 | 10个 | BO-01至BO-10 |
| 关联数量 | 13条 | REL-01至REL-13 |
| 路径数量 | 10条 | PATH-01至PATH-10 |
| 最大入度 | 3（AR_RECEIVABLE被核销/映射/规则引用） | 核心单据汇聚度高 |
| 最大出度 | 4（AR_RECEIVABLE发出核销/钩稽/映射/收款） | 核心单据发散度高 |
| 循环路径 | 无 | 业务对象关系为有向无环图 |
| 关键路径长度 | 5步（PATH-01最长） | 核心流程较长但清晰 |

---

## 八、关系-源码映射

| 关系 | 源码类/文件 | 核心方法 |
|---|---|---|
| REL-01 单据-分录 | ARReceivableEdit.cs | OnLoad加载分录 |
| REL-02/03 核销关联 | MatchServiceHelper.cs | Match()创建关联 |
| REL-04 核销-凭证 | ARFinMatch.cs | FinMatchProcess触发凭证 |
| REL-05 映射-凭证 | VoucherGenerateServiceHelper.cs | Generate()创建映射 |
| REL-06/07 钩稽关联 | VerificationServiceHelper.cs | Verify()建立关系 |
| REL-08 钩稽-核销 | VerificationServiceHelper.cs | Verify()触发核销 |
| REL-09/10 内部核销 | ARInnerIVSpecialMatchEdit.cs | InnerMatchProcess() |
| REL-11 内部应收-组织 | ARInnerIVSpecialMatchEdit.cs | 组织权限校验 |
| REL-12/13 规则关联 | ARFinMatch.cs | 规则加载匹配 |
