# 实现映射 — K3Cloud Purchase采购

## 版本信息
| 属性 | 值 |
|---|---|
| 分析模块 | Purchase采购 |
| 分析时间 | 2026-08-07 |

---

## 一、报表实现映射

### 1.1 采购报表清单

| 报表 | 类名 | 数据来源 | 关键方法 |
|---|---|---|---|
| 采购订单汇总 | PurchaseOrderReport | T_PUR_POORDER | Query/Sum |
| 采购订单明细 | PurchaseOrderDetailRpt | T_PUR_POORDERENTRY | Query |
| 采购入库汇总 | PurchaseInStockReport | T_PUR_InStock | Query |
| 采购入库明细 | PurchaseInStockDetailRpt | T_PUR_InStockENTRY | Query |
| SVM询报价汇总 | SVMReport | T_SVM_* | Query |
| 采购价格分析 | PurchasePriceAnalysisRpt | 订单×入库 | Compare |
| 供应商交货及时率 | SupplierDeliveryRpt | 订单-入库对比 | Calculate |
| 应付汇总 | APSummaryReport | T_AP_INVOICE | Query |

### 1.2 报表插件模式

```
AbstractSysReportPlugIn
    │
    ├── 取数插件（Query）
    │   └── 自定义SQL/ORM查询
    │
    ├── 过滤插件（Filter）
    │   └── 权限过滤、数据过滤
    │
    └── 格式化插件（Format）
        └── 列格式化、金额显示
```

---

## 二、服务类实现映射

### 2.1 PurchaseService

| 方法 | 实现类 | 关键逻辑 |
|---|---|---|
| GetPrice | PurchaseService | 价格查询（协议价/价目表） |
| ComparePrice | PurchaseService | 多供应商比价 |
| AllocateQuota | PurchaseService | 配额分配 |
| ControlByPolicy | PurchaseService | 采购控制策略 |

### 2.2 PurchaseOrderService

| 方法 | 实现类 | 关键逻辑 |
|---|---|---|
| OnSave | PurchaseOrderEdit | 保存校验 |
| OnAudit | PurchaseOrderEdit | 审核确认 |
| OnUnAudit | PurchaseOrderEdit | 反审核 |
| OnClose | PurchaseOrderEdit | 关闭订单 |

### 2.3 PurchaseInStockService

| 方法 | 实现类 | 关键逻辑 |
|---|---|---|
| OnSave | InStockEdit | 保存校验 |
| OnAudit | InStockEdit | 审核+入库+生成应付 |
| OnUnAudit | InStockEdit | 反审核+红冲应付 |

---

## 三、决策卡实现

### 3.1 DEC-Pur-01：比价策略

```
决策点：是否进行SVM询报价
输入：采购申请、物料、供应商
规则：
  IF 启用SVM模块 AND 物料需要比价 THEN
    执行SVM询报价流程
    申请 → 询价 → 报价 → 比价 → 订单
  ELSE
    直接创建采购订单
    申请 → 订单
  END IF
输出：订单创建方式
```

### 3.2 DEC-Pur-02：入库成本计价

```
决策点：入库成本计算方式
输入：入库单
规则：
  IF 存在关联订单 THEN
    成本单价 = 订单单价
  ELSE IF 存在协议价 THEN
    成本单价 = 协议价
  ELSE
    成本单价 = 计划价
  END IF
  成本金额 = 成本单价 × 入库数量
输出：成本单价和成本金额
```

### 3.3 DEC-Pur-03：应付生成时机

```
决策点：应付单生成时机
输入：入库审核请求
规则：
  生成应付单
  应付.金额 = 入库.含税金额
  应付.币种 = 入库.币种
  应付.到期日 = 入库.日期 + 供应商.账期
  应付.税率 = 入库.税率
输出：应付单
```

### 3.4 DEC-Pur-04：发票校验方式

```
决策点：发票与应付金额差异处理
输入：发票数据、应付数据
规则：
  差异 = ABS(发票.金额 - 应付.金额)
  IF 差异 > 容差 THEN
    进入审批流程
    审批通过后方可确认发票
  ELSE
    自动匹配
  END IF
输出：发票校验结果
```

### 3.5 DEC-Pur-05：GL凭证生成

```
决策点：入库审核时的凭证生成
输入：入库单
规则：
  生成采购成本凭证：
    借：库存科目
    贷：应付科目
  IF 已启用金额核算 THEN
    生成成本金额凭证
  END IF
输出：GL凭证号
```

---

## 四、巨型类分析

### 4.1 巨型类清单

| 类名 | 行数 | 风险 | 建议拆分 |
|---|---|---|---|
| PurchaseService | 4,722 | 维护困难 | 按功能模块拆分 |
| CommonService | 3,082 | 跨域耦合 | 按业务域拆分 |
| PurchaseRequisitionEdit | - | 空catch{}吞异常 | 完善异常处理 |

### 4.2 PurchaseService拆分建议

```
原：PurchaseService (4,722行)

拆分为：
  ├── PurchasePriceService    (价格服务，~1500行)
  ├── PurchaseCompareService  (比价服务，~1000行)
  ├── PurchaseQuotaService    (配额服务，~800行)
  ├── PurchasePolicyService   (策略服务，~800行)
  └── PurchaseReportService   (报表服务，~622行)
```

---

## 五、DA7分析结论

**报表清单**：8个
- 订单报表：2个
- 入库报表：2个
- SVM报表：1个
- 分析报表：2个
- 应付报表：1个

**服务类**：3个核心
- PurchaseService（⚠️4,722行）
- PurchaseOrderService
- PurchaseInStockService

**决策卡**：5个
- 比价策略
- 入库成本计价
- 应付生成时机
- 发票校验方式
- GL凭证生成

**巨型类风险**：3个
- PurchaseService
- CommonService
- PurchaseRequisitionEdit

**进入DA8的输入**：
- 需验证假设与约束
- 需识别反证案例
