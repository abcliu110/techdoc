# 交互流程 — K3Cloud Purchase采购

## 版本信息
| 属性 | 值 |
|---|---|
| 分析模块 | Purchase采购 |
| 分析时间 | 2026-08-07 |

---

## 一、服务架构

### 1.1 核心服务

| 服务名 | 命名空间 | 职责 |
|---|---|---|
| PurchaseService | Core/.../App.BusinessService | 采购核心服务（4,722行⚠️） |
| PurchaseOrderService | BusinessPlugIn | 订单管理服务 |
| PurchaseInStockService | ServicePlugIn | 入库服务 |
| SVMInquiryService | SVM模块 | 询价管理 |
| SVMQuoteService | SVM模块 | 报价管理 |
| SVMComparePriceService | SVM模块 | 比价管理 |

### 1.2 服务交互关系

```
┌────────────────────────────────────────────────────────────────┐
│                      PurchaseService（核心调度）                 │
├────────────────────────────────────────────────────────────────┤
│  SVMInquiryService   │  询价管理（SVM唯一代码化部分）           │
│  SVMQuoteService    │  报价管理                               │
│  SVMComparePriceService │ 比价管理                             │
│  PurchaseOrderService │  订单管理                             │
│  PurchaseInStockService │ 入库管理（审核触发应付/凭证）         │
│  PurchaseReturnService  │ 退料管理                            │
├────────────────────────────────────────────────────────────────┤
│  StockInvService   │  库存管理（Purchase→Stock集成）          │
│  APService         │  应付管理（Purchase→AP集成）             │
│  GLService         │  GL凭证（Purchase→GL集成）               │
└────────────────────────────────────────────────────────────────┘
```

---

## 二、核心API

### 2.1 SVM询报价API

| API | 方法 | 说明 |
|---|---|---|
| ISVMInquiryService.Create | 创建询价单 | 创建询价单 |
| ISVMInquiryService.Send | 发送询价 | 向供应商发送询价 |
| ISVMQuoteService.Receive | 接收报价 | 接收供应商报价 |
| ISVMComparePriceService.Compare | 比价分析 | 多供应商报价对比 |
| ISVMComparePriceService.Select | 选择最优 | 确定最优供应商 |

### 2.2 采购订单API

| API | 方法 | 说明 |
|---|---|---|
| IPurchaseOrderService.Save | 保存订单 | 保存采购订单 |
| IPurchaseOrderService.Audit | 审核订单 | 审核通过 |
| IPurchaseOrderService.UnAudit | 反审核订单 | 撤销审核 |
| IPurchaseOrderService.Close | 关闭订单 | 关闭订单 |
| IPurchaseOrderService.Modify | 修改订单 | 反审核+修改+重审 |

### 2.3 入库API

| API | 方法 | 说明 |
|---|---|---|
| IPurchaseInStockService.Save | 保存入库单 | 保存 |
| IPurchaseInStockService.Audit | 审核入库 | 审核+增加库存+生成应付 |
| IPurchaseInStockService.UnAudit | 反审核入库 | 撤销+减少库存+应付红冲 |
| IPurchaseInStockService.Cancel | 取消入库 | 取消单据 |

---

## 三、时序图

### 3.1 SVM标准采购流程

```
┌──────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────┐
│ 采购员│     │InquirySvc   │     │QuoteSvc     │     │ComparePrice │     │POSvc    │
└──┬───┘     └──────┬──────┘     └──────┬──────┘     └──────┬──────┘     └────┬────┘
   │ 创建询价        │                   │                    │                │
   │───────────────▶│                   │                    │                │
   │                │                   │                    │                │
   │ 发送询价        │                   │                    │                │
   │───────────────▶│                   │                    │                │
   │                │                   │                    │                │
   │                │◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇◇│
   │                │     供应商收到询价单，提交报价          │                │
   │                │                   │                    │                │
   │ 接收报价        │                   │                    │                │
   │◀───────────────│───────────────────│────────────────────│                │
   │                │                   │                    │                │
   │ 比价分析        │                   │                    │                │
   │◀───────────────│───────────────────│────────────────────│                │
   │                │                   │                    │                │
   │ 选择最优        │                   │                    │                │
   │◀───────────────│───────────────────│────────────────────│                │
   │                │                   │                    │                │
   │ 生成订单        │                   │                    │                │
   │◀───────────────│───────────────────│────────────────────│─────────────────│
```

### 3.2 入库审核→生成应付

```
┌──────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────┐
│ 用户 │     │InStockSvc   │     │OperationCtrl│     │StockInvSvc  │     │APService│
└──┬───┘     └──────┬──────┘     └──────┬──────┘     └──────┬──────┘     └────┬────┘
   │ 审核入库        │                   │                    │                │
   │───────────────▶│                   │                    │                │
   │                │                   │                    │                │
   │                │ 过账准备           │                    │                │
   │                │───────────────▶│                    │                │
   │                │                   │                    │                │
   │                │                   │ 执行MERGE          │                │
   │                │                   │───────────────▶│                    │
   │                │                   │                    │                │
   │                │                   │                    │ 增加库存        │
   │                │                   │                    │───────────────▶│
   │                │                   │                    │                │
   │                │                   │                    │ 生成应付单      │
   │                │                   │                    │                │
   │                │ 返回成功          │                    │                │
   │◀───────────────│                   │                    │                │
```

### 3.3 退料审核→应付红冲

```
┌──────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────┐
│ 用户 │     │ReturnSvc    │     │OperationCtrl│     │StockInvSvc  │     │APService│
└──┬───┘     └──────┬──────┘     └──────┬──────┘     └──────┬──────┘     └────┬────┘
   │ 审核退料        │                   │                    │                │
   │───────────────▶│                   │                    │                │
   │                │                   │                    │                │
   │                │ 退料出库（负数）  │                    │                │
   │                │───────────────▶│                    │                │
   │                │                   │                    │                │
   │                │                   │ 执行MERGE（红字）  │                │
   │                │                   │───────────────▶│                    │
   │                │                   │                    │                │
   │                │                   │                    │ 生成应付红冲    │
   │                │                   │                    │ ◀──────────────│
   │                │                   │                    │                │
   │                │ 返回成功          │                    │                │
   │◀───────────────│                   │                    │                │
```

---

## 四、配置驱动说明

### 4.1 ConvertRule配置

**关键发现**：采购链"申请→订单→收料→入库"零转换插件代码，靠元数据ConvertRule配置。

| 转换环节 | 配置位置 | 说明 |
|---|---|---|
| 申请→订单 | 元数据ConvertRule | 标准线性转换 |
| 订单→收料 | 元数据ConvertRule | 标准线性转换 |
| 收料→入库 | 元数据ConvertRule | 标准线性转换 |
| 入库→发票 | 元数据ConvertRule | 标准线性转换 |

### 4.2 SVM代码化部分

| 转换类型 | 代码位置 | 说明 |
|---|---|---|
| PurReqToInquiryBill | SVM模块 | 申请→询价 |
| InquiryToQuoteBill | SVM模块 | 询价→报价 |
| InquiryBillToComparePrice | SVM模块 | 报价→比价 |

---

## 五、DA6分析结论

**核心服务**：6个
- PurchaseService（调度，⚠️4,722行）
- PurchaseOrderService（订单）
- PurchaseInStockService（入库）
- SVMInquiryService（询价）
- SVMQuoteService（报价）
- SVMComparePriceService（比价）

**核心API**：13个
- SVM API：5个
- 订单API：5个
- 入库API：4个

**关键时序**：
- SVM询报价流程（唯一代码化）
- 入库审核→增加库存→生成应付
- 退料审核→减少库存→应付红冲

**进入DA7的输入**：
- 需映射报表和服务到实现
- 需识别决策点实现
