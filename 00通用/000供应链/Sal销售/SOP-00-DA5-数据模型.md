# 数据模型 — K3Cloud Sal销售

## 版本信息
| 属性 | 值 |
|---|---|
| 分析模块 | Sal销售 |
| 分析时间 | 2026-08-07 |

---

## 一、核心数据表

### 1.1 销售单据表

| 表名 | 中文名 | 主键 | 说明 |
|---|---|---|---|
| T_SAL_ORDER | 销售订单表头 | FID | 订单基本信息、客户、金额 |
| T_SAL_ORDERENTRY | 销售订单分录 | FENTRYID | 物料明细、数量、单价、折扣 |
| T_SAL_QUOTATION | 销售报价表头 | FID | 报价基本信息 |
| T_SAL_QUOTATIONENTRY | 销售报价分录 | FENTRYID | 报价物料明细 |
| T_SAL_DELIVERYNOTICE | 发货通知表头 | FID | 发货通知基本信息 |
| T_SAL_DELIVERYNOTICEENTRY | 发货通知分录 | FENTRYID | 发货明细 |
| T_SAL_OUTSTOCK | 销售出库表头 | FID | 出库单基本信息 |
| T_SAL_OUTSTOCKENTRY | 销售出库分录 | FENTRYID | 出库物料明细、批号、序列号 |
| T_SAL_RETURNSTOCK | 销售退货表头 | FID | 退货单基本信息 |
| T_SAL_RETURNSTOCKENTRY | 销售退货分录 | FENTRYID | 退货物料明细 |

### 1.2 库存锁定表

| 表名 | 中文名 | 主键 | 说明 |
|---|---|---|---|
| T_PLN_RESERVELINK | 预留主表 | FID | 预留单据信息 |
| T_PLN_RESERVELINKENTRY | 预留明细表 | FENTRYID | 物料、数量、有效期 |

### 1.3 应收财务表

| 表名 | 中文名 | 主键 | 说明 |
|---|---|---|---|
| T_AR_RECEIVEBILL | 应收单表头 | FID | 应收单基本信息 |
| T_AR_RECEIVEBILLENTRY | 应收单分录 | FENTRYID | 应收明细、金额 |
| T_AR_RECEIVEBILLENTRY_R | 应收单分录关联 | FENTRYID | 与来源单据关联 |
| T_AR_CLOSEACCOUNT | 核销记录表 | FID | 核销关系记录 |

---

## 二、表结构详情

### 2.1 T_SAL_ORDER（销售订单表头）

| 字段 | 类型 | 说明 | 约束 |
|---|---|---|---|
| FID | BIGINT | 主键 | PK |
| FBILLNO | VARCHAR(50) | 单据编号 | NOT NULL, UNIQUE |
| FCUSTOMERID | BIGINT | 客户ID | FK→T_BD_CUSTOMER |
| FSALERID | BIGINT | 业务员ID | FK→T_BD_SALER |
| FBILLDATE | DATE | 单据日期 | NOT NULL |
| FTOTALAMOUNT | DECIMAL(18,6) | 订单总金额 | |
| FCURRENCYID | BIGINT | 币种ID | FK→T_BD_CURRENCY |
| FEXCHANGERATE | DECIMAL(18,10) | 汇率 | |
| FPAYMENTTERMID | BIGINT | 付款条件ID | FK→T_SAL_PAYMENTTERM |
| FSTATUS | VARCHAR(10) | 单据状态 | DRAFT/AUDIT/CLOSE |
| FORDERSTYPEID | BIGINT | 订单类型ID | FK→T_SAL_ORDERSTYPE |
| FORGID | BIGINT | 组织ID | FK→T_ORG_ORGANIZATIONS |
| FCREATORID | BIGINT | 创建人ID | |
| FCREATEDATE | DATETIME | 创建日期 | |
| FAPPROVERID | BIGINT | 审核人ID | |
| FAPPROVEDATE | DATETIME | 审核日期 | |

### 2.2 T_SAL_ORDERENTRY（销售订单分录）

| 字段 | 类型 | 说明 | 约束 |
|---|---|---|---|
| FENTRYID | BIGINT | 分录ID | PK |
| FID | BIGINT | 表头ID | FK→T_SAL_ORDER |
| FMATERIALID | BIGINT | 物料ID | FK→T_BD_MATERIAL |
| FUNITID | BIGINT | 计量单位ID | FK→T_BD_UNIT |
| FQTY | DECIMAL(18,6) | 数量 | NOT NULL |
| FPRICE | DECIMAL(18,6) | 单价 | NOT NULL |
| FTAXRATE | DECIMAL(10,4) | 税率 | |
| FTAXAMOUNT | DECIMAL(18,6) | 税额 | |
| FALLAMOUNT | DECIMAL(18,6) | 价税合计 | |
| FDISCOUNT | DECIMAL(18,6) | 折扣额 | |
| FDELIVERYDATE | DATE | 交货日期 | |
| FSTOCKID | BIGINT | 仓库ID | FK→T_BD_STOCK |
| FOUTQTY | DECIMAL(18,6) | 已出库数量 | |
| FRETURNQTY | DECIMAL(18,6) | 已退货数量 | |
| FASSISTQTY | DECIMAL(18,6) | 辅助数量 | |
| FBATCHNO | VARCHAR(100) | 批号 | |
| FSERIALNO | VARCHAR(100) | 序列号 | |

### 2.3 T_PLN_RESERVELINKENTRY（预留明细表）

| 字段 | 类型 | 说明 | 约束 |
|---|---|---|---|
| FENTRYID | BIGINT | 分录ID | PK |
| FID | BIGINT | 表头ID | FK→T_PLN_RESERVELINK |
| FSOURCEBILLID | BIGINT | 源单据ID | FK→T_SAL_ORDER |
| FSOURCEBILLNO | VARCHAR(50) | 源单据编号 | |
| FMATERIALID | BIGINT | 物料ID | FK→T_BD_MATERIAL |
| FSTOCKID | BIGINT | 仓库ID | FK→T_BD_STOCK |
| FRESERVEQTY | DECIMAL(18,6) | 预留数量 | |
| FRESERVEDATE | DATE | 预留日期 | |
| FRELEASEDATE | DATE | 释放日期 | |
| FRESERVESTATUS | VARCHAR(10) | 预留状态 | RESERVED/RELEASED |
| FUSEDQTY | DECIMAL(18,6) | 已使用数量 | |
| FRESERVETYPE | INT | 预留类型 | 1=普通，3=强预留 |

---

## 三、索引设计

### 3.1 主键索引

| 表名 | 索引名 | 字段 |
|---|---|---|
| T_SAL_ORDER | PK_T_SAL_ORDER | FID |
| T_SAL_ORDERENTRY | PK_T_SAL_ORDERENTRY | FENTRYID |
| T_PLN_RESERVELINKENTRY | PK_T_PLN_RESERVELINKENTRY | FENTRYID |

### 3.2 业务索引

| 表名 | 索引名 | 字段 | 类型 |
|---|---|---|---|
| T_SAL_ORDER | IDX_SAL_ORDER_NO | FBILLNO | UNIQUE |
| T_SAL_ORDER | IDX_SAL_ORDER_CUST | FCUSTOMERID | |
| T_SAL_ORDER | IDX_SAL_ORDER_DATE | FBILLDATE | |
| T_SAL_ORDER | IDX_SAL_ORDER_STATUS | FSTATUS | |
| T_SAL_ORDERENTRY | IDX_SAL_ORDERENTRY_MAT | FMATERIALID | |
| T_SAL_ORDERENTRY | IDX_SAL_ORDERENTRY_BATCH | FBATCHNO | |
| T_PLN_RESERVELINKENTRY | IDX_RESERVE_SOURCE | FSOURCEBILLID | |
| T_PLN_RESERVELINKENTRY | IDX_RESERVE_MAT | FMATERIALID | |

---

## 四、事件模型

### 4.1 单据事件

| 事件 | 触发时机 | 操作 |
|---|---|---|
| OnSave | 单据保存 | 数据校验、必填检查 |
| OnSubmit | 单据提交 | 状态变更、锁定创建 |
| OnAudit | 单据审核 | 审核确认、应收生成、信用检查 |
| OnUnAudit | 反审核 | 状态回退、锁定释放、应收红冲 |
| OnClose | 订单关闭 | 锁定全释放、订单结束 |

### 4.2 库存事件

| 事件 | 触发时机 | 操作 |
|---|---|---|
| OnLock | 订单审核 | 创建T_PLN_RESERVELINKENTRY |
| OnUnlock | 订单关闭/出库 | 更新FRESERVEDATE/FSTATUS |
| OnOutStock | 出库审核 | 扣减库存、扣减锁定 |

### 4.3 财务事件

| 事件 | 触发时机 | 操作 |
|---|---|---|
| OnARCreate | 出库审核 | 创建T_AR_RECEIVEBILL |
| OnARCredit | 退货审核 | 创建应收红字 |
| OnARReceive | 收款核销 | 更新应收状态、核销记录 |
| OnGLPost | 出库审核 | 生成收入+成本凭证 |

---

## 五、DA5分析结论

**数据表清单**：11张
- 销售单据表：6张
- 库存锁定表：2张
- 应收财务表：3张

**关键索引**：8个
- 主键索引：3个
- 业务索引：5个

**事件模型**：
- 单据事件：5个
- 库存事件：3个
- 财务事件：4个

**进入DA6的输入**：
- 需建立API契约
- 事件触发点需与API对应
