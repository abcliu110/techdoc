# 数据模型 — K3Cloud Purchase采购

## 版本信息
| 属性 | 值 |
|---|---|
| 分析模块 | Purchase采购 |
| 分析时间 | 2026-08-07 |

---

## 一、核心数据表

### 1.1 采购单据表

| 表名 | 中文名 | 主键 | 说明 |
|---|---|---|---|
| T_PUR_POORDER | 采购订单表头 | FID | 订单基本信息、供应商、金额 |
| T_PUR_POORDERENTRY | 采购订单分录 | FENTRYID | 物料明细、数量、单价、折扣 |
| T_PUR_Requisition | 采购申请表头 | FID | 申请基本信息 |
| T_PUR_RequisitionENTRY | 采购申请分录 | FENTRYID | 申请物料明细 |
| T_PUR_ReceiveNotice | 收料通知表头 | FID | 收料通知基本信息 |
| T_PUR_ReceiveNoticeENTRY | 收料通知分录 | FENTRYID | 收料明细 |
| T_PUR_InStock | 采购入库表头 | FID | 入库单基本信息 |
| T_PUR_InStockENTRY | 采购入库分录 | FENTRYID | 入库物料明细、批号、序列号 |
| T_PUR_Return | 采购退料表头 | FID | 退料单基本信息 |
| T_PUR_ReturnENTRY | 采购退料分录 | FENTRYID | 退料物料明细 |

### 1.2 SVM询报价表

| 表名 | 中文名 | 主键 | 说明 |
|---|---|---|---|
| T_SVM_InquiryBill | 询价单表头 | FID | 询价基本信息、截止日期 |
| T_SVM_InquiryBillENTRY | 询价单分录 | FENTRYID | 询价物料明细 |
| T_SVM_QuoteBill | 报价单表头 | FID | 供应商报价信息 |
| T_SVM_QuoteBillENTRY | 报价单分录 | FENTRYID | 报价物料明细、价格 |
| T_SVM_ComparePrice | 比价单表头 | FID | 比价分析结果 |
| T_SVM_ComparePriceENTRY | 比价单分录 | FENTRYID | 比价明细、最优选择 |

### 1.3 应付财务表

| 表名 | 中文名 | 主键 | 说明 |
|---|---|---|---|
| T_AP_INVOICE | 应付发票表头 | FID | 应付单基本信息 |
| T_AP_INVOICEENTRY | 应付发票分录 | FENTRYID | 应付明细、金额 |
| T_AP_PAYMENTBILL | 付款单表头 | FID | 付款单基本信息 |
| T_AP_PAYMENTBILLENTRY | 付款单分录 | FENTRYID | 付款明细、金额 |
| T_AP_CLOSEACCOUNT | 核销记录表 | FID | 核销关系记录 |

---

## 二、表结构详情

### 2.1 T_PUR_POORDER（采购订单表头）

| 字段 | 类型 | 说明 | 约束 |
|---|---|---|---|
| FID | BIGINT | 主键 | PK |
| FBILLNO | VARCHAR(50) | 单据编号 | NOT NULL, UNIQUE |
| FSUPPLIERID | BIGINT | 供应商ID | FK→T_BD_SUPPLIER |
| FBUYERID | BIGINT | 采购员ID | FK→T_BD_BUYER |
| FBILLDATE | DATE | 单据日期 | NOT NULL |
| FTOTALAMOUNT | DECIMAL(18,6) | 订单总金额 | |
| FCURRENCYID | BIGINT | 币种ID | FK→T_BD_CURRENCY |
| FEXCHANGERATE | DECIMAL(18,10) | 汇率 | |
| FPAYMENTTERMID | BIGINT | 付款条件ID | FK→T_AP_PAYMENTTERM |
| FSTATUS | VARCHAR(10) | 单据状态 | DRAFT/AUDIT/CLOSE |
| FORGID | BIGINT | 组织ID | FK→T_ORG_ORGANIZATIONS |
| FCREATORID | BIGINT | 创建人ID | |
| FCREATEDATE | DATETIME | 创建日期 | |
| FAPPROVERID | BIGINT | 审核人ID | |
| FAPPROVEDATE | DATETIME | 审核日期 | |

### 2.2 T_PUR_POORDERENTRY（采购订单分录）

| 字段 | 类型 | 说明 | 约束 |
|---|---|---|---|
| FENTRYID | BIGINT | 分录ID | PK |
| FID | BIGINT | 表头ID | FK→T_PUR_POORDER |
| FMATERIALID | BIGINT | 物料ID | FK→T_BD_MATERIAL |
| FUNITID | BIGINT | 计量单位ID | FK→T_BD_UNIT |
| FQTY | DECIMAL(18,6) | 订单数量 | NOT NULL |
| FPRICE | DECIMAL(18,6) | 单价 | NOT NULL |
| FTAXRATE | DECIMAL(10,4) | 税率 | |
| FTAXAMOUNT | DECIMAL(18,6) | 税额 | |
| FALLAMOUNT | DECIMAL(18,6) | 价税合计 | |
| FDELIVERYDATE | DATE | 交货日期 | |
| FSTOCKID | BIGINT | 仓库ID | FK→T_BD_STOCK |
| FRECEIVEQTY | DECIMAL(18,6) | 已收数量 | |
| FINSTOCKQTY | DECIMAL(18,6) | 已入库数量 | |
| FRETURNQTY | DECIMAL(18,6) | 已退货数量 | |
| FBATCHNO | VARCHAR(100) | 批号 | |
| FSUPPLIERID | BIGINT | 供应商ID | FK→T_BD_SUPPLIER |

### 2.3 T_PUR_InStockENTRY（采购入库分录）

| 字段 | 类型 | 说明 | 约束 |
|---|---|---|---|
| FENTRYID | BIGINT | 分录ID | PK |
| FID | BIGINT | 表头ID | FK→T_PUR_InStock |
| FSOURCEBILLID | BIGINT | 源单据ID | FK→T_PUR_POORDER |
| FMATERIALID | BIGINT | 物料ID | FK→T_BD_MATERIAL |
| FUNITID | BIGINT | 计量单位ID | FK→T_BD_UNIT |
| FQTY | DECIMAL(18,6) | 入库数量 | NOT NULL |
| FPRICE | DECIMAL(18,6) | 成本单价 | |
| FCOSTAMOUNT | DECIMAL(18,6) | 成本金额 | |
| FSTOCKID | BIGINT | 仓库ID | FK→T_BD_STOCK |
| FBATCHNO | VARCHAR(100) | 批号 | |
| FEXPIRYDATE | DATE | 效期 | |
| FPRODUCTDATE | DATE | 生产日期 | |

---

## 三、索引设计

### 3.1 主键索引

| 表名 | 索引名 | 字段 |
|---|---|---|
| T_PUR_POORDER | PK_T_PUR_POORDER | FID |
| T_PUR_POORDERENTRY | PK_T_PUR_POORDERENTRY | FENTRYID |
| T_PUR_InStock | PK_T_PUR_InStock | FID |
| T_PUR_InStockENTRY | PK_T_PUR_InStockENTRY | FENTRYID |

### 3.2 业务索引

| 表名 | 索引名 | 字段 | 类型 |
|---|---|---|---|
| T_PUR_POORDER | IDX_POORDER_NO | FBILLNO | UNIQUE |
| T_PUR_POORDER | IDX_POORDER_SUP | FSUPPLIERID | |
| T_PUR_POORDER | IDX_POORDER_DATE | FBILLDATE | |
| T_PUR_POORDER | IDX_POORDER_STATUS | FSTATUS | |
| T_PUR_POORDERENTRY | IDX_POORDERENTRY_MAT | FMATERIALID | |
| T_PUR_InStock | IDX_INSTOCK_DATE | FBILLDATE | |
| T_PUR_InStockENTRY | IDX_INSTOCK_SOURCE | FSOURCEBILLID | |

---

## 四、事件模型

### 4.1 单据事件

| 事件 | 触发时机 | 操作 |
|---|---|---|
| OnSave | 单据保存 | 数据校验、必填检查 |
| OnSubmit | 单据提交 | 状态变更、记录创建 |
| OnAudit | 单据审核 | 审核确认、应付生成 |
| OnUnAudit | 反审核 | 状态回退、应付红冲 |
| OnClose | 订单关闭 | 订单结束、未执行量冻结 |

### 4.2 库存事件

| 事件 | 触发时机 | 操作 |
|---|---|---|
| OnInStock | 入库审核 | 增加库存、更新批次 |
| OnReturn | 退料审核 | 减少库存、退回供应商 |

### 4.3 财务事件

| 事件 | 触发时机 | 操作 |
|---|---|---|
| OnARCreate | 入库审核 | 创建T_AP_INVOICE |
| OnARCredit | 退料审核 | 创建应付红字 |
| OnARPay | 付款核销 | 更新应付状态、核销记录 |
| OnGLPost | 入库审核 | 生成成本凭证 |

---

## 五、DA5分析结论

**数据表清单**：15张
- 采购单据表：6张
- SVM询报价表：6张
- 应付财务表：3张

**关键索引**：7个
- 主键索引：4个
- 业务索引：3个

**事件模型**：
- 单据事件：5个
- 库存事件：2个
- 财务事件：4个

**进入DA6的输入**：
- 需建立API契约
- 事件触发点需与API对应
