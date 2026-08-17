# 交互流程 — K3Cloud SVM供应商协同

## 版本信息
| 属性 | 值 |
|---|---|
| 分析模块 | SVM供应商协同 |
| 分析时间 | 2026-08-07 |

---

## 一、核心服务

### 1.1 服务清单

| 服务 | 类名 | 职责 |
|---|---|---|
| SVMInquiryService | SVMInquiryBillSvc | 询价单全生命周期管理 |
| SVMQuoteService | SVMQuoteBillSvc | 报价单全生命周期管理 |
| SVMCompareService | SVMComparePriceSvc | 比价单管理与比价算法 |
| SVMConvertService | SVMConvertPlugIn | 单据转换插件 |

---

## 二、关键API

### 2.1 询价服务API

| API | 方法 | 功能 |
|---|---|---|
| SVMInquiry.Create | POST | 创建询价单 |
| SVMInquiry.Update | PUT | 更新询价单 |
| SVMInquiry.Send | POST | 发送询价给供应商 |
| SVMInquiry.Close | POST | 关闭询价 |
| SVMInquiry.Audit | POST | 审核询价单 |

### 2.2 报价服务API

| API | 方法 | 功能 |
|---|---|---|
| SVMQuote.Create | POST | 供应商创建报价单 |
| SVMQuote.Submit | POST | 提交报价 |
| SVMQuote.Accept | POST | 接受报价 |
| SVMQuote.Reject | POST | 拒绝报价 |

### 2.3 比价服务API

| API | 方法 | 功能 |
|---|---|---|
| SVMCompare.Create | POST | 创建比价单 |
| SVMCompare.Execute | POST | 执行比价分析 |
| SVMCompare.Select | POST | 选择最优供应商 |
| SVMCompare.GenerateOrder | POST | 生成采购订单 |

---

## 三、时序图

### 3.1 标准询报价时序

```
┌────────┐     ┌────────┐     ┌────────┐     ┌────────┐     ┌────────┐
│ 采购员 │     │ SVMInquiry│  │SVMQuote│     │SVMCompare│  │Purchase │
└───┬────┘     └────┬───┘     └───┬────┘     └────┬───┘     └────┬────┘
    │              │              │              │              │
    │ 1.CreateInquiry│            │              │              │
    │─────────────▶│              │              │              │
    │              │              │              │              │
    │ 2.AddSupplier│              │              │              │
    │─────────────▶│              │              │              │
    │              │              │              │              │
    │ 3.SendInquiry│              │              │              │
    │─────────────▶│              │              │              │
    │              │              │              │              │
    │              │ 4.NotifySupplier│          │              │
    │              │─────────────────────────────────────────────▶│
    │              │              │              │              │
    │              │              │ 5.SubmitQuote│              │
    │              │◀─────────────────────────────────────────────│
    │              │              │              │              │
    │ 6.CreateCompare│            │              │              │
    │───────────────────────────────────────────▶│              │
    │              │              │              │              │
    │ 7.ExecuteCompare│           │              │              │
    │───────────────────────────────────────────▶│              │
    │              │              │              │              │
    │ 8.SelectBest │              │              │              │
    │───────────────────────────────────────────▶│              │
    │              │              │              │              │
    │ 9.GenerateOrder│            │              │              │
    │───────────────────────────────────────────────────────────▶│
    │              │              │              │              │
```

---

## 四、核心交互流程

### 4.1 询价创建流程

```
用户操作                    系统处理
──────────────────────────────────────────
填写询价主题        →       生成询价单号
选择询价物料        →       关联物料明细
维护物料数量        →       校验数量
期望单价            →       记录期望价
期望交期            →       记录期望日期
选择供应商          →       关联询价供应商
发送询价            →       更新发送状态
                    →       通知供应商
```

### 4.2 比价执行流程

```
用户操作                    系统处理
──────────────────────────────────────────
触发比价            →       检查报价数量
收集报价明细        →       汇总各供应商报价
计算价格得分        →       按价格排序
综合评分（如配置）  →       加权计算综合分
展示比价结果        →       生成比价单
用户确认最优        →       记录最优选择
生成采购订单        →       调用Purchase服务
```

---

## 五、跨域集成

### 5.1 SVM→Purchase

| 集成点 | 集成内容 | 集成方式 |
|---|---|---|
| 比价→订单 | 生成采购订单 | 服务调用 |
| 询价→申请 | 关联采购申请 | 数据关联 |

### 5.2 SVM→Supplier Portal

| 集成点 | 集成内容 | 集成方式 |
|---|---|---|
| 询价发送 | 推送询价通知 | 消息/邮件 |
| 报价接收 | 获取供应商报价 | 消息/API |

---

## 六、DA6分析结论

**服务清单**：4个
- SVMInquiryService：询价管理
- SVMQuoteService：报价管理
- SVMCompareService：比价管理
- SVMConvertService：转换管理

**关键API**：12个
- 询价API：5个
- 报价API：4个
- 比价API：3个

**进入DA7的输入**：
- 报表需求需明确
- 决策卡需与业务规则对应
