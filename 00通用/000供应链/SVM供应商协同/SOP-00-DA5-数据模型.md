# 数据模型 — K3Cloud SVM供应商协同

## 版本信息
| 属性 | 值 |
|---|---|
| 分析模块 | SVM供应商协同 |
| 分析时间 | 2026-08-07 |

---

## 一、核心表结构

### 1.1 询价单表（T_SVM_InquiryBill）

| 字段名 | 中文名 | 数据类型 | 说明 |
|---|---|---|---|
| FID | 主键 | BIGINT | 主键 |
| FBILLNO | 询价单号 | VARCHAR(50) | 单据编号唯一 |
| FTITLE | 询价主题 | VARCHAR(200) | 询价标题 |
| FBUSINESSTYPE | 业务类型 | VARCHAR(20) | 业务分类 |
| FSOURCEBILLTYPE | 源单类型 | VARCHAR(50) | 采购申请 |
| FSOURCEBILLID | 源单ID | BIGINT | 采购申请FID |
| FSUPPLIERCOUNT | 供应商数量 | INT | 邀请供应商数 |
| FINQUIRYDATE | 询价日期 | DATE | 询价发起日期 |
| FENDDATE | 截止日期 | DATE | 报价截止日期 |
| FSTATUS | 状态 | VARCHAR(20) | 状态枚举 |
| FCREATORID | 创建人 | BIGINT | 创建人ID |
| FCREATETIME | 创建时间 | DATETIME | 创建时间 |
| FLASTMODIFYUSERID | 最后修改人 | BIGINT | 修改人ID |
| FLASTMODIFYTIME | 最后修改时间 | DATETIME | 修改时间 |
| FAUDITORID | 审核人 | BIGINT | 审核人ID |
| FAUDITTIME | 审核时间 | DATETIME | 审核时间 |

### 1.2 询价明细表（T_SVM_InquiryEntry）

| 字段名 | 中文名 | 数据类型 | 说明 |
|---|---|---|---|
| FENTRYID | 分录ID | BIGINT | 主键 |
| FID | 表头ID | BIGINT | 关联询价单 |
| FMATERIALID | 物料ID | BIGINT | 物料FID |
| FMATERIALNAME | 物料名称 | VARCHAR(200) | 物料名称 |
| FMATERIALSPEC | 规格型号 | VARCHAR(200) | 规格 |
| FUNITID | 单位 | BIGINT | 单位 |
| FPRICEQTY | 询价数量 | DECIMAL(18,6) | 数量 |
| FUNITPRICE | 期望单价 | DECIMAL(18,4) | 期望单价 |
| FTAXPRICE | 含税单价 | DECIMAL(18,4) | 含税单价 |
| EXPECTDATE | 期望交期 | DATE | 期望交货日期 |
| FREMARK | 备注 | VARCHAR(500) | 备注 |

### 1.3 询价供应商表（T_SVM_InquirySupplier）

| 字段名 | 中文名 | 数据类型 | 说明 |
|---|---|---|---|
| FENTRYID | 分录ID | BIGINT | 主键 |
| FID | 表头ID | BIGINT | 关联询价单 |
| FSUPPLIERID | 供应商ID | BIGINT | 供应商FID |
| FSUPPLIERNAME | 供应商名称 | VARCHAR(200) | 供应商 |
| FSENDSTATUS | 发送状态 | VARCHAR(20) | 已发送/未发送 |
| FSENDTIME | 发送时间 | DATETIME | 发送时间 |
| FREPLYSTATUS | 回复状态 | VARCHAR(20) | 已回复/未回复 |
| FREPLYTIME | 回复时间 | DATETIME | 回复时间 |

### 1.4 报价单表（T_SVM_QuoteBill）

| 字段名 | 中文名 | 数据类型 | 说明 |
|---|---|---|---|
| FID | 主键 | BIGINT | 主键 |
| FBILLNO | 报价单号 | VARCHAR(50) | 单据编号 |
| FTITLE | 报价主题 | VARCHAR(200) | 报价标题 |
| FINQUIRYBILLID | 询价单ID | BIGINT | 关联询价单 |
| FSUPPLIERID | 供应商ID | BIGINT | 供应商FID |
| FQUOTEDATE | 报价日期 | DATE | 报价日期 |
| FEXPIRYDATE | 有效期至 | DATE | 报价有效期 |
| FSTATUS | 状态 | VARCHAR(20) | 状态枚举 |
| FISCURRENT | 是否当前 | TINYINT | 是否现行报价 |
| FCREATORID | 创建人 | BIGINT | 创建人ID |
| FCREATETIME | 创建时间 | DATETIME | 创建时间 |

### 1.5 报价明细表（T_SVM_QuoteEntry）

| 字段名 | 中文名 | 数据类型 | 说明 |
|---|---|---|---|
| FENTRYID | 分录ID | BIGINT | 主键 |
| FID | 表头ID | BIGINT | 关联报价单 |
| FMATERIALID | 物料ID | BIGINT | 物料FID |
| FUNITID | 单位 | BIGINT | 单位 |
| FPRICEQTY | 报价数量 | DECIMAL(18,6) | 数量 |
| FPRICE | 单价 | DECIMAL(18,4) | 报价单价 |
| FTAXPRICE | 含税单价 | DECIMAL(18,4) | 含税单价 |
| FPRICEAMOUNT | 金额 | DECIMAL(18,2) | 报价金额 |
| FTAXAMOUNT | 税额 | DECIMAL(18,2) | 税额 |
| FALLAMOUNT | 价税合计 | DECIMAL(18,2) | 含税金额 |
| FDELIVERYDATE | 交货日期 | DATE | 承诺交货日期 |

### 1.6 比价单表（T_SVM_ComparePrice）

| 字段名 | 中文名 | 数据类型 | 说明 |
|---|---|---|---|
| FID | 主键 | BIGINT | 主键 |
| FBILLNO | 比价单号 | VARCHAR(50) | 单据编号 |
| FTITLE | 比价主题 | VARCHAR(200) | 比价标题 |
| FINQUIRYBILLID | 询价单ID | BIGINT | 关联询价单 |
| FCREATORID | 创建人 | BIGINT | 创建人ID |
| FCREATETIME | 创建时间 | DATETIME | 创建时间 |
| FCOMPAREDATE | 比价日期 | DATE | 比价执行日期 |
| FSTATUS | 状态 | VARCHAR(20) | 状态枚举 |
| FBESTSUPPLIERID | 最优供应商ID | BIGINT | 最优供应商 |
| FBESTSUPPLIERNAME | 最优供应商 | VARCHAR(200) | 最优供应商名 |
| FBESTPRICE | 最优价格 | DECIMAL(18,4) | 最优单价 |
| FTOTALAMOUNT | 比价总额 | DECIMAL(18,2) | 最优总金额 |

### 1.7 比价明细表（T_SVM_CompareEntry）

| 字段名 | 中文名 | 数据类型 | 说明 |
|---|---|---|---|
| FENTRYID | 分录ID | BIGINT | 主键 |
| FID | 表头ID | BIGINT | 关联比价单 |
| FMATERIALID | 物料ID | BIGINT | 物料FID |
| FUNITID | 单位 | BIGINT | 单位 |
| FSUPPLIER1ID | 供应商1 | BIGINT | 报价供应商1 |
| FSUPPLIER1PRICE | 供应商1单价 | DECIMAL(18,4) | 供应商1报价 |
| FSUPPLIER2ID | 供应商2 | BIGINT | 报价供应商2 |
| FSUPPLIER2PRICE | 供应商2单价 | DECIMAL(18,4) | 供应商2报价 |
| FSUPPLIER3ID | 供应商3 | BIGINT | 报价供应商3 |
| FSUPPLIER3PRICE | 供应商3单价 | DECIMAL(18,4) | 供应商3报价 |
| FBESTSUPPLIERID | 最优供应商 | BIGINT | 最优供应商 |
| FBESTPRICE | 最优单价 | DECIMAL(18,4) | 最优报价 |
| FPRICEDIFF | 价差 | DECIMAL(18,4) | 与最优价差 |

---

## 二、索引设计

### 2.1 主键索引

| 表名 | 索引字段 | 类型 |
|---|---|---|
| T_SVM_InquiryBill | FID | 主键 |
| T_SVM_InquiryEntry | FENTRYID | 主键 |
| T_SVM_QuoteBill | FID | 主键 |
| T_SVM_QuoteEntry | FENTRYID | 主键 |
| T_SVM_ComparePrice | FID | 主键 |
| T_SVM_CompareEntry | FENTRYID | 主键 |

### 2.2 业务索引

| 表名 | 索引字段 | 类型 | 说明 |
|---|---|---|---|
| T_SVM_InquiryBill | FBILLNO | 唯一索引 | 单据编号唯一 |
| T_SVM_InquiryBill | FSOURCEBILLID | 普通索引 | 按源单查询 |
| T_SVM_InquiryBill | FSTATUS | 普通索引 | 按状态查询 |
| T_SVM_QuoteBill | FINQUIRYBILLID | 普通索引 | 关联询价 |
| T_SVM_QuoteBill | FSUPPLIERID | 普通索引 | 按供应商查询 |
| T_SVM_ComparePrice | FINQUIRYBILLID | 普通索引 | 关联询价 |

---

## 三、数据关系

### 3.1 ER图

```
┌──────────────────┐     ┌──────────────────┐
│ T_SVM_InquiryBill│────▶│T_SVM_InquiryEntry│
│ 询价单表头        │ 1:N │ 询价明细         │
└────────┬─────────┘     └──────────────────┘
         │
         │ 1:N
         ▼
┌──────────────────┐     ┌──────────────────┐
│T_SVM_InquirySupp │     │  T_SVM_QuoteBill │
│ 询价供应商        │     │   报价单表头      │
└──────────────────┘     └────────┬─────────┘
                                  │
                                  │ 1:N
                                  ▼
┌──────────────────┐     ┌──────────────────┐
│T_SVM_ComparePrice│◀────│  T_SVM_QuoteEntry│
│   比价单表头      │ N:1 │   报价明细       │
└──────────────────┘     └──────────────────┘
         │
         │ 1:N
         ▼
┌──────────────────┐
│T_SVM_CompareEntry│
│   比价明细       │
└──────────────────┘
```

---

## 四、DA5分析结论

**数据表清单**：7张表
- 询价单表头：1张
- 询价明细：2张
- 报价单表头：1张
- 报价明细：1张
- 比价单表头：1张
- 比价明细：1张

**索引设计**：
- 主键索引：6个
- 业务索引：7个

**进入DA6的输入**：
- 服务层需与数据表操作对应
- 单据转换需涉及多表操作
