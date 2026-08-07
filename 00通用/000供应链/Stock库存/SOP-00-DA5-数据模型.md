# Stock库存 — SOP-00-DA5-数据模型

## 版本信息
| 属性 | 值 |
|---|---|
| 模块 | K3Cloud SCM - Stock库存 |
| 分析时间 | 2026-08-07 |
| 文档目录 | D:\mywork\techdoc\00通用\000供应链\Stock库存\ |
| 前置文档 | SOP-00-DA0-DA4 |
| 状态 | DA5进行中 |

---

## 一、数据模型概述

Stock库存模块的数据模型围绕**T_STK_INVENTORY库存台账**为核心，构建6张核心表、6个关键事件、5个重要索引。与GL/CB等财务账类共享"账本+凭证+日记账"的核心表结构，同时增加了批次、锁定期、在途量等库存特有字段。

---

## 二、核心数据表（6张）

### T_STK_INVENTORY — 库存台账（核心表）

| 字段 | 类型 | 说明 | 账类对应 |
|---|---|---|---|
| FORGID | INT | 组织ID | GL.组织ID |
| FSTOCKID | INT | 仓库ID | - |
| FMATERIALID | INT | 物料ID | - |
| FBATCHNO | NVARCHAR | 批号 | - |
| FSERIALNO | NVARCHAR | 序列号 | - |
| FUNITID | INT | 单位ID | - |
| FAUXPROPID | INT | 辅助属性ID | - |
| FOWNERID | INT | 保管者ID | - |
| FPROJECTID | INT | 项目ID | - |
| FUSETYPEID | INT | 用途ID | - |
| FCOLORID | INT | 颜色ID | - |
| FSPECIFICATIONID | INT | 规格ID | - |
| FCUSTOMERID | INT | 客户ID | - |
| FSUPPLIERID | INT | 供应商ID | - |
| FEXPIRYDATE | DATETIME | 有效期 | - |
| **FSTOCKQTY** | DECIMAL(18,6) | **现存量** | GL.FBALAMOUNT |
| **FLOCKQTY** | DECIMAL(18,6) | **锁定量** | - |
| **FAVAILQTY** | DECIMAL(18,6) | **可用量** | GL.FBALAMOUNT |
| FRESERVEQTY | DECIMAL(18,6) | 预留量 | - |
| FTRANSITQTY | DECIMAL(18,6) | 在途量 | - |
| FBALANCEQTY | DECIMAL(18,6) | 账存数量 | 期末对账用 |
| FKEEPERID | INT | 保管者 | - |
| FLOCATORID | INT | 库位ID | - |
| FCREATEDATE | DATETIME | 创建日期 | - |
| FCLOSEDATE | DATETIME | 关账日期 | GL.关账日期 |
| FPERIODID | INT | 会计期间ID | GL.期间ID |

**主键**：15个维度键组合（FORGID + FSTOCKID + FMATERIALID + ... + FEXPIRYDATE）

**五量关系**：
```
AvailQty = StockQty - LockQty - ReserveQty
TransitQty 独立计算（PO在途）
```

---

### T_STK_INSTOCK — 入库单主表

| 字段 | 类型 | 说明 |
|---|---|---|
| FBILLNO | NVARCHAR(50) | 单据编号 |
| FBILLTYPE | NVARCHAR(50) | 单据类型（采购入库/生产入库等） |
| FORGID | INT | 组织ID |
| FSTOCKID | INT | 目标仓库ID |
| FBILLDATE | DATETIME | 单据日期 |
| FSUPPLIERID | INT | 供应商ID（采购） |
| FCUSTOMERID | INT | 客户ID（退货） |
| FDEPTID | INT | 部门ID |
| FEMPLOYEEID | INT | 业务员ID |
| FTOTALQTY | DECIMAL(18,6) | 总数量 |
| FTOTALAMOUNT | DECIMAL(18,6) | 总金额（成本） |
| FAUDITSTATUS | INT | 审核状态（0/1/2） |
| FPOSTSTATUS | INT | 过账状态（0/未过账/1/已过账） |
| FCREATORID | INT | 创建人ID |
| FCREATETIME | DATETIME | 创建时间 |
| FAUDITORID | INT | 审核人ID |
| FAUDITTIME | DATETIME | 审核时间 |

---

### T_STK_INSTOCKENTRY — 入库单明细

| 字段 | 类型 | 说明 |
|---|---|---|
| FENTRYID | INT | 明细行ID |
| FMATERIALID | INT | 物料ID |
| FUNITID | INT | 单位ID |
| FQTY | DECIMAL(18,6) | 数量 |
| FPRICE | DECIMAL(18,8) | 单价 |
| FAMOUNT | DECIMAL(18,2) | 金额 |
| FBATCHNO | NVARCHAR(50) | 批号 |
| FEXPIRYDATE | DATETIME | 有效期 |
| FSOURCETYPE | NVARCHAR(50) | 来源类型（PO等） |
| FSOURCEBILLNO | NVARCHAR(50) | 来源单据号 |
| FSTOCKID | INT | 入库仓库ID |
| FLOCATORID | INT | 库位ID |

---

### T_STK_OUTSTOCK — 出库单主表

| 字段 | 类型 | 说明 |
|---|---|---|
| FBILLNO | NVARCHAR(50) | 单据编号 |
| FBILLTYPE | NVARCHAR(50) | 单据类型（销售出库/领料等） |
| FORGID | INT | 组织ID |
| FSTOCKID | INT | 出库仓库ID |
| FBILLDATE | DATETIME | 单据日期 |
| FCUSTOMERID | INT | 客户ID（销售） |
| FDEPTID | INT | 部门ID |
| FEMPLOYEEID | INT | 业务员ID |
| FTOTALQTY | DECIMAL(18,6) | 总数量 |
| FAUDITSTATUS | INT | 审核状态 |
| FPOSTSTATUS | INT | 过账状态 |
| FREFPOSTSTATUS | INT | 引用过账状态 |
| FCREATETIME | DATETIME | 创建时间 |
| FAUDITTIME | DATETIME | 审核时间 |

---

### T_STK_STOCKTRANS — 库存变动记录（日记账）

| 字段 | 类型 | 说明 | 账类对应 |
|---|---|---|---|
| FTRANSID | BIGINT | 变动记录ID | GL.凭证ID |
| FBILLID | INT | 业务单据ID | GL.凭证号 |
| FBILLTYPE | NVARCHAR(50) | 单据类型 | GL.凭证字 |
| FBILLNO | NVARCHAR(50) | 单据编号 | GL.凭证号 |
| FBILLDATE | DATETIME | 单据日期 | GL.日期 |
| FORGID | INT | 组织ID | GL.组织ID |
| FSTOCKID | INT | 仓库ID | - |
| FMATERIALID | INT | 物料ID | GL.科目ID |
| FBATCHNO | NVARCHAR(50) | 批号 | - |
| FUNITID | INT | 单位ID | - |
| FQTY | DECIMAL(18,6) | 变动数量 | GL.金额 |
| FTRANSACTIONTYPE | INT | 变动类型（入库/出库/调整） | GL.借贷方向 |
| FBALANCEBEFORE | DECIMAL(18,6) | 变动前数量 | GL.期初余额 |
| FBALANCEAFTER | DECIMAL(18,6) | 变动后数量 | GL.期末余额 |
| FCREATETIME | DATETIME | 记录时间 | GL.过账时间 |
| FOPERATORID | INT | 操作人ID | GL.制单人 |
| FPOSTERID | INT | 过账人ID | GL.审核人 |

**核心价值**：库存日记账，记录每笔库存变动，可追溯

---

### T_STK_STOCKLOCK — 锁定期记录

| 字段 | 类型 | 说明 |
|---|---|---|
| FLOCKID | BIGINT | 锁定ID |
| FLOCKTYPE | NVARCHAR(50) | 锁定类型（SO/MO） |
| FSOURCEBILLID | INT | 来源单据ID |
| FSOURCEBILLNO | NVARCHAR(50) | 来源单据号 |
| FORGID | INT | 组织ID |
| FSTOCKID | INT | 仓库ID |
| FMATERIALID | INT | 物料ID |
| FBATCHNO | NVARCHAR(50) | 批号 |
| FLOCKQTY | DECIMAL(18,6) | 锁定数量 |
| FAVAILABLEQTY | DECIMAL(18,6) | 可用数量 |
| FLOCKSTATUS | INT | 锁定状态（1/占用/2/部分释放/3/完全释放/4/归档） |
| FCREATETIME | DATETIME | 创建时间 |
| FRELEASETIME | DATETIME | 释放时间 |
| FREMARK | NVARCHAR(500) | 备注 |

⚠️ **反证#2关联**：订单关闭后FLOCKSTATUS未更新为4（归档）

---

## 三、关键事件（6个）

### EVT-01：库存入库事件（StockIn）
| 属性 | 内容 |
|---|---|
| 触发时机 | 入库单审核通过 |
| 过账引擎 | OperationController.InstockPosting |
| 原子操作 | MERGE T_STK_INVENTORY |
| 后置动作 | 生成T_STK_STOCKTRANS记录，触发GL凭证生成 |
| 账类同构 | CB收款单审核（EVT-CB-01） |

### EVT-02：库存出库事件（StockOut）
| 属性 | 内容 |
|---|---|
| 触发时机 | 出库单审核通过 |
| 过账引擎 | OperationController.OutstockPosting |
| 原子操作 | MERGE T_STK_INVENTORY + 锁定释放 |
| 前置校验 | BR-ST-201（AvailQty >= 出库量） |
| 后置动作 | 生成T_STK_STOCKTRANS记录，触发GL凭证生成 |

### EVT-03：库存锁定事件（StockLock）
| 属性 | 内容 |
|---|---|
| 触发时机 | SO/MO审核通过 |
| 操作 | INSERT T_STK_STOCKLOCK + UPDATE T_STK_INVENTORY.FLOCKQTY |
| 异常场景 | ⚠️ 订单关闭后未触发解锁（反证#2） |

### EVT-04：库存解锁事件（StockUnlock）
| 属性 | 内容 |
|---|---|
| 触发时机 | SO/MO关闭/取消，或关联出库单审核 |
| 操作 | UPDATE T_STK_STOCKLOCK + UPDATE T_STK_INVENTORY.FLOCKQTY |
| 异常场景 | ⚠️ 未执行导致僵尸锁定 |

### EVT-05：盘点调整事件（StockAdjust）
| 属性 | 内容 |
|---|---|
| 触发时机 | 盘点单确认，生成盘点损溢单 |
| 过账引擎 | OperationController.AdjustPosting |
| 异常场景 | ⚠️ 未生成完整溯源链（反证#3） |

### EVT-06：期末关账事件（PeriodClose）
| 属性 | 内容 |
|---|---|
| 触发时机 | 账套管理员执行期末关账 |
| 操作 | UPDATE T_STK_INVENTORY.FCLOSEDATE + 固化期间数据 |
| 后置动作 | 触发GL期末关账协同 |

---

## 四、重要索引（5个）

| 索引 | 表 | 索引字段 | 用途 |
|---|---|---|---|
| IDX_STK_INV_ORG_STOCK_MAT | T_STK_INVENTORY | FORGID+FSTOCKID+FMATERIALID | 库存查询最常用组合 |
| IDX_STK_INV_BATCH | T_STK_INVENTORY | FBATCHNO+FEXPIRYDATE | 批次效期查询 |
| IDX_STK_TRANS_DATE | T_STK_STOCKTRANS | FBILLDATE+FORGID | 日记账时间序查询 |
| IDX_STK_TRANS_SOURCE | T_STK_STOCKTRANS | FSOURCEBILLNO+FBILLTYPE | 单据追溯 |
| IDX_STK_LOCK_SOURCE | T_STK_STOCKLOCK | FSOURCEBILLNO+FLOCKTYPE | 锁定追溯 |

---

## 五、数据模型与账类系统映射

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            库存账类系统                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│  T_STK_INVENTORY（库存台账）              ←→  GL总账台账                    │
│  ┌─────────────────────┐                ┌─────────────────────┐            │
│  │  15维主键            │                │  科目+辅助核算       │            │
│  │  FSTOCKQTY（现存量） │                │  FBALAMOUNT（余额）  │            │
│  │  FLOCKQTY（锁定量）  │                │  FGLAMOUNT（凭证数） │            │
│  │  FAVAILQTY（可用量） │                │  FCNAMOUNT（业务数） │            │
│  └─────────────────────┘                └─────────────────────┘            │
│              │                                      │                      │
│              ▼                                      ▼                      │
│  T_STK_STOCKTRANS（日记账）           ←→  GL日记账/ CB日记账                │
│  ┌─────────────────────┐                ┌─────────────────────┐            │
│  │  业务单据→库存变动   │                │  业务单据→账目变更   │            │
│  │  FBALANCEBEFORE/AFTER│               │  期初/期末余额      │            │
│  └─────────────────────┘                └─────────────────────┘            │
│              │                                      │                      │
│              ▼                                      ▼                      │
│  T_STK_INSTOCK/OUTSTOCK（凭证）       ←→  GL凭证/CB收付单                   │
│  ┌─────────────────────┐                ┌─────────────────────┐            │
│  │  FAUDITSTATUS       │                │  FAUDITSTATUS       │            │
│  │  FPOSTSTATUS        │                │  FPOSTSTATUS        │            │
│  └─────────────────────┘                └─────────────────────┘            │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 六、DA5覆盖清单

- [x] 6张核心数据表（T_STK_INVENTORY/T_STK_INSTOCK/T_STK_INSTOCKENTRY/T_STK_OUTSTOCK/T_STK_STOCKTRANS/T_STK_STOCKLOCK）
- [x] 6个关键事件
- [x] 5个重要索引
- [x] 五量关系模型
- [x] 数据模型与账类系统映射
- [ ] DA6交互流程（4时序图/12API/7服务类）
