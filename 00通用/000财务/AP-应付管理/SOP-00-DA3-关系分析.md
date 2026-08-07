# DA3 关系分析 — K3Cloud AP应付管理模块

## 模板加载记录
已读取 SOP-00-DA3-模板.md，门禁检查 5 项全部通过。

---

## 一、业务对象清单（10个）

| 编号 | 对象名称 | 对象类型 | 核心职责 | 关键属性 |
|---|---|---|---|---|
| BO-01 | AP_PAYABLE | 业务单据 | 应付单据主表，记录应付债务 | FBillNo, FSetAccountType, FWriteOffStatus, FUnWriteOffAmt |
| BO-02 | AP_PAYABLEENTRY | 业务单据分录 | 应付单据行，记录分项明细 | FEntryID, FMaterialID, FQty, FPrice, FAmount |
| BO-03 | AP_WRITEOFFRECORD | 核销记录 | 记录核销事务详情 | FWriteOffRecordID, FSourceBillID, FTargetBillID, FWriteOffAmt |
| BO-04 | AP_WRITEOFFRECORDENTRY | 核销分录 | 核销双方的分录对应 | FWriteOffEntryID, FSourceEntryID, FTargetEntryID, FAmt |
| BO-05 | AP_VERIFICATION | 钩稽关系 | 暂估与财务单据的对应关系 | FVerificationID, FSourceBillID, FTargetBillID, FVerificationStatus |
| BO-06 | AP_PayableMatchRule | 匹配规则 | 核销匹配的业务规则配置 | FMatchRuleID, FMatchMethod, FRowLimit, FOrgID |
| BO-07 | AP_InnerIVRecord | 内部应收 | 组织间内部应收单 | FInnerIVRecordID, FInnerOrgID, FAmount |
| BO-08 | AP_InnerPayRecord | 内部应付 | 组织间内部应付单 | FInnerPayRecordID, FInnerOrgID, FAmount |
| BO-09 | AP_InnerClearRecord | 内部核销 | 组织间核销记录 | FInnerClearID, FSourceRecordID, FTargetRecordID, FClearAmt |
| BO-10 | BAS_BusinessVoucher | 业务凭证映射 | 业务单据与GL凭证的关联 | FMappingID, FSourceBillType, FSourceBillID, FVoucherID |

---

## 二、关联关系清单（13条）

### 2.1 核心关联（5条）

| 编号 | 关系名称 | 起点→终点 | 关系类型 | 说明 |
|---|---|---|---|---|
| REL-01 | 单据-分录 | AP_PAYABLE→AP_PAYABLEENTRY | 1:N | 一张应付单含多条分录行 |
| REL-02 | 核销-来源 | AP_WRITEOFFRECORD→AP_PAYABLE | N:1 | 核销记录关联来源应付单 |
| REL-03 | 核销-目标 | AP_WRITEOFFRECORD→AP_PAYABLE | N:1 | 核销记录关联目标应付单 |
| REL-04 | 核销-凭证 | AP_WRITEOFFRECORD→GL_VOUCHER | N:1 | 核销触发生成GL凭证 |
| REL-05 | 映射-凭证 | BAS_BusinessVoucher→GL_VOUCHER | N:1 | 业务单据映射到GL凭证 |

### 2.2 钩稽关联（3条）

| 编号 | 关系名称 | 起点→终点 | 关系类型 | 说明 |
|---|---|---|---|---|
| REL-06 | 钩稽-暂估 | AP_VERIFICATION→AP_PAYABLE(暂估) | N:1 | 钩稽关系关联暂估单据 |
| REL-07 | 钩稽-财务 | AP_VERIFICATION→AP_PAYABLE(财务) | N:1 | 钩稽关系关联财务单据 |
| REL-08 | 钩稽-核销 | AP_VERIFICATION→AP_WRITEOFFRECORD | 1:N | 钩稽确认后触发核销 |

### 2.3 内部核销关联（3条）

| 编号 | 关系名称 | 起点→终点 | 关系类型 | 说明 |
|---|---|---|---|---|
| REL-09 | 内部核销-应收 | AP_InnerClearRecord→AP_InnerIVRecord | N:1 | 内部核销关联内部应收单 |
| REL-10 | 内部核销-应付 | AP_InnerClearRecord→AP_InnerPayRecord | N:1 | 内部核销关联内部应付单 |
| REL-11 | 内部应收-组织 | AP_InnerIVRecord→BD_Org | N:1 | 内部应收关联内部组织 |

### 2.4 匹配与规则关联（2条）

| 编号 | 关系名称 | 起点→终点 | 关系类型 | 说明 |
|---|---|---|---|---|
| REL-12 | 单据-规则 | AP_PAYABLE→AP_PayableMatchRule | N:1 | 应付单按规则匹配核销 |
| REL-13 | 规则-组织 | AP_PayableMatchRule→BD_Org | N:1 | 匹配规则按组织配置 |

---

## 三、关系图（ASCII）

```
┌─────────────────────────────────────────────────────────────────────┐
│                        AP应付管理业务对象关系图                       │
└─────────────────────────────────────────────────────────────────────┘

  ┌────────────────┐         ┌────────────────────┐
  │   BD_Supplier  │◀────────│    AP_PAYABLE      │ (REL-供应商)
  │   供应商主数据  │  N:1    │    应付单据主表     │
  └────────────────┘         └─────────┬──────────┘
                                        │ 1:N (REL-01)
                                        ▼
                               ┌────────────────────┐
                               │  AP_PAYABLEENTRY   │
                               │    应付单据分录     │
                               └────────────────────┘

  ┌────────────────┐         ┌────────────────────┐
  │   BD_Org       │◀────────│  AP_PayableMatchRule│ (REL-13)
  │   组织主数据    │  N:1    │     匹配规则        │
  └────────────────┘         └─────────┬──────────┘
                                        │ N:1 (REL-12)
                                        ▼
                               ┌────────────────────┐
                               │    AP_PAYABLE      │
                               └─────────┬──────────┘
                                         │
          ┌──────────────────────────────┼──────────────────────────────┐
          │                              │                              │
          ▼                              ▼                              ▼
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│  AP_VERIFICATION    │    │ AP_WRITEOFFRECORD   │    │BAS_BusinessVoucher  │
│    钩稽关系          │    │    核销记录          │    │   业务凭证映射       │
│ 暂估 ◀───────▶ 财务  │    │                     │    │                     │
└─────────┬───────────┘    └──────────┬──────────┘    └─────────┬──────────┘
          │                           │                           │
          │ 1:N (REL-08)              │ N:1 (REL-04)             │ N:1 (REL-05)
          ▼                           ▼                           ▼
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│ AP_WRITEOFFRECORD   │    │    GL_VOUCHER      │    │    GL_VOUCHER       │
│    核销记录          │    │    GL凭证          │    │    GL凭证            │
└─────────┬───────────┘    └─────────────────────┘    └─────────────────────┘
          │
          │ 1:N
          ▼
┌─────────────────────┐
│AP_WRITEOFFRECORDENTRY│
│     核销分录          │
└─────────────────────┘

  ┌─────────────────────────────────────────────────────────────────┐
  │                      内部核销子域                                  │
  └─────────────────────────────────────────────────────────────────┘

       ┌────────────────────┐    ┌─────────────────────┐
       │  AP_InnerIVRecord  │    │  AP_InnerPayRecord  │
       │    内部应收单       │    │    内部应付单        │
       │◀──────────────────▶│ N:1 (REL-09/10)
       └─────────┬──────────┘    └──────────┬──────────┘
                 │ N:1 (REL-11)            │
                 ▼                         ▼
        ┌────────────────┐          ┌────────────────┐
        │    BD_Org      │          │  AP_InnerClearRecord
        │   内部组织      │          │     内部核销    │
        └────────────────┘          └────────────────┘
```

---

## 四、关键路径清单（10条）

### 4.1 采购发票核销路径（核心主路径）

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-01 | 采购发票核销 | 采购入库→暂估凭证→发票录入→发票审核→核算类型判断→发票凭证→钩稽确认→核销→核销凭证 | AP_PAYABLE→AP_VERIFICATION→AP_WRITEOFFRECORD→GL_VOUCHER | 核心主路径 |

### 4.2 费用报销路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-02 | 费用报销 | 费用录入→费用审核→FY核算逻辑→凭证生成→核销→核销凭证 | AP_PAYABLE→BAS_BusinessVoucher→GL_VOUCHER | 核心主路径 |

### 4.3 特殊核销路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-03 | 特殊核销 | 选择单据→行数校验(1:1/1:0/2:0)→金额计算→核销执行→凭证生成 | AP_PAYABLE→AP_PayableMatchRule→AP_WRITEOFFRECORD | 核心分支 |

### 4.4 反核销路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-04 | 反核销 | 打开核销记录→反核销→权限校验→UnVerifyResultAction→补偿凭证→状态恢复 | AP_WRITEOFFRECORD→GL_VOUCHER→AP_PAYABLE | 异常补偿 |

### 4.5 钩稽返回路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-05 | 钩稽返回 | 财务单→钩稽返回→暂估单→核算类型回退→凭证冲销 | AP_PAYABLE→AP_VERIFICATION | 异常分支 |

### 4.6 内部核销路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-06 | 内部核销 | 内部应收→内部应付→内部核销→内部抵消凭证→组织往来清零 | AP_InnerIVRecord→AP_InnerPayRecord→AP_InnerClearRecord | 边缘路径 |

### 4.7 账龄分析路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-07 | 账龄分析 | 应付余额→未核销金额→到期日期→账龄区间→逾期报表 | AP_PAYABLE→AgingAnalysis | 分析报表 |

### 4.8 付款路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-08 | 付款 | 付款申请→付款审核→付款执行→付款凭证→更新FRelateHadPayAmount | AP_PAYABLE→付款模块 | 核心分支 |

### 4.9 凭证追溯路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-09 | 凭证追溯 | 应付单→BAS_BusinessVoucher映射→GL_VOUCHER凭证→分录明细 | AP_PAYABLE→BAS_BusinessVoucher→GL_VOUCHERENTRY | 查询追溯 |

### 4.10 核销记录追溯路径

| 路径ID | 路径名称 | 路径步骤 | 涉及对象 | 路径类型 |
|---|---|---|---|---|
| PATH-10 | 核销追溯 | 应付单→AP_WRITEOFFRECORD→核销双方单据→凭证 | AP_PAYABLE→AP_WRITEOFFRECORD→GL_VOUCHER | 查询追溯 |

---

## 五、关键路径时序摘要

### PATH-01：采购发票核销（最关键路径）

```
参与者: 采购员 → 应付会计 → 系统
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│采购入库单 │    │ 应付单据  │    │ 凭证生成 │    │ 钩稽关系 │    │ 核销记录  │
└────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘
     │ 审核          │              │              │              │
     ├──────────────▶│ SetAccountType(暂估)         │              │
     │               │──────────▶  │ 暂估凭证     │              │
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

## 六、关系复杂度分析

| 维度 | 评估 | 说明 |
|---|---|---|
| 对象数量 | 10个 | BO-01至BO-10 |
| 关联数量 | 13条 | REL-01至REL-13 |
| 路径数量 | 10条 | PATH-01至PATH-10 |
| 最大入度 | 3（AP_PAYABLE被核销/映射/规则引用） | 核心单据汇聚度高 |
| 最大出度 | 4（AP_PAYABLE发出核销/钩稽/映射/付款） | 核心单据发散度高 |
| 循环路径 | 无 | 业务对象关系为有向无环图 |
| 关键路径长度 | 5步（PATH-01最长） | 核心流程较长但清晰 |

---

## 七、关系-源码映射

| 关系 | 源码类/文件 | 核心方法 |
|---|---|---|
| REL-01 单据-分录 | PayableEdit.cs | OnLoad加载分录 |
| REL-02/03 核销关联 | MatchServiceHelper.cs | Match()创建关联 |
| REL-04 核销-凭证 | FinMatch.cs | FinMatchProcess触发凭证 |
| REL-05 映射-凭证 | VoucherGenerateServiceHelper.cs | Generate()创建映射 |
| REL-06/07 钩稽关联 | VerificationServiceHelper.cs | Verify()建立关系 |
| REL-08 钩稽-核销 | VerificationServiceHelper.cs | Verify()触发核销 |
| REL-09/10 内部核销 | InnerClearRecordEdit.cs | InnerClearProcess() |
| REL-11 内部应收-组织 | InnerClearRecordEdit.cs | 组织权限校验 |
| REL-12/13 规则关联 | FinMatch.cs | 规则加载匹配 |
