# 实现映射 — K3Cloud Sal销售

## 版本信息
| 属性 | 值 |
|---|---|
| 分析模块 | Sal销售 |
| 分析时间 | 2026-08-07 |

---

## 一、报表实现映射

### 1.1 销售报表清单

| 报表 | 类名 | 数据来源 | 关键方法 |
|---|---|---|---|
| 销售订单汇总 | SaleOrderReport | T_SAL_ORDER | Query/Sum |
| 销售订单明细 | SaleOrderDetailRpt | T_SAL_ORDERENTRY | Query |
| 发货通知汇总 | DeliveryNoticeReport | T_SAL_DELIVERYNOTICE | Query |
| 销售出库汇总 | SaleOutStockReport | T_SAL_OUTSTOCK | Query |
| 销售出库明细 | SaleOutStockDetailRpt | T_SAL_OUTSTOCKENTRY | Query |
| 销售退货汇总 | SaleReturnReport | T_SAL_RETURNSTOCK | Query |
| 销售毛利分析 | SaleProfitRpt | 出库单×成本 | Calculate |
| 订单执行进度 | OrderProgressRpt | 订单-出库对比 | Progress |
| 客户销售排名 | CustomerSalesRankRpt | 客户维度汇总 | Rank |

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

### 1.3 权限控制实现

| 权限类型 | 实现方式 | 说明 |
|---|---|---|
| 组织权限 | 多组织过滤 | 组织隔离 |
| 金额权限 | IsCanViewAmount | 无金额权限隐藏列 |
| 单据权限 | 状态过滤 | 只看权限内单据 |

---

## 二、服务类实现映射

### 2.1 SaleService

| 方法 | 实现类 | 关键逻辑 |
|---|---|---|
| GetHistoryPrice | SaleService | 历史价查询 |
| CheckCanSale | SaleService | 可售检查 |
| GetLogistics | SaleService | 物流信息 |
| ControlByPolicy | SaleService | 销售控制策略 |

### 2.2 SaleOrderService

| 方法 | 实现类 | 关键逻辑 |
|---|---|---|
| OnSave | SaleOrderEdit | 保存校验 |
| OnAudit | SaleOrderEdit | 审核+锁定+信用 |
| OnUnAudit | SaleOrderEdit | 反审核+释放 |
| OnClose | SaleOrderEdit | 关闭+全释放 |

### 2.3 SaleOutStockService

| 方法 | 实现类 | 关键逻辑 |
|---|---|---|
| OnSave | OutStockEdit | 保存校验 |
| OnAudit | OutStockEdit | 审核+过账+应收 |
| OnUnAudit | OutStockEdit | 反审核+红冲 |

### 2.4 DeliveryNoticeService

| 方法 | 实现类 | 关键逻辑 |
|---|---|---|
| OnSave | DeliveryNoticeEdit | 保存校验 |
| OnAudit | DeliveryNoticeEdit | 审核确认 |

---

## 三、决策卡实现

### 3.1 DEC-Sal-01：锁定时机

```
决策点：订单审核时的库存锁定策略
输入：订单审核请求
规则：
  IF 订单.审核状态 == 已审核 THEN
    IF 物料.启用库存管理 == TRUE THEN
      创建库存锁定记录
      可用量 -= 锁定数量
    END IF
  END IF
输出：锁定结果
```

### 3.2 DEC-Sal-02：应收生成时机

```
决策点：出库审核时的应收生成策略
输入：出库审核请求
规则：
  IF 出库.审核状态 == 已审核 THEN
    生成应收单
    应收.金额 = 出库.含税金额
    应收.币种 = 出库.币种
    应收.到期日 = 出库.日期 + 客户.账期
    信用占用 += 出库.金额
  END IF
输出：应收单
```

### 3.3 DEC-Sal-03：价格来源优先级

```
决策点：订单单价来源
输入：订单物料、客户
规则：
  IF 存在价目表价格 THEN
    单价 = 价目表价格
  ELSE IF 存在历史价格 THEN
    单价 = 最近一次历史价格
  ELSE
    单价 = 标准价格
  END IF
输出：单价
```

### 3.4 DEC-Sal-04：信用检查

```
决策点：订单审核时的信用检查
输入：订单客户、订单金额
规则：
  可用信用 = 客户.信用额度 - 已占用信用
  IF 订单金额 > 可用信用 THEN
    IF 客户.超额度审批 == 需要 THEN
      进入审批流程
    ELSE
      提示警告（可继续）
    END IF
  END IF
输出：检查结果
```

### 3.5 DEC-Sal-05：GL凭证生成

```
决策点：出库审核时的凭证生成
输入：出库单
规则：
  生成销售收入凭证：
    借：应收科目（客户）
    贷：销售收入科目
  生成销售成本凭证：
    借：销售成本科目
    贷：库存科目
输出：GL凭证号
```

---

## 四、巨型类分析

### 4.1 巨型类清单

| 类名 | 行数 | 风险 | 建议拆分 |
|---|---|---|---|
| SaleOrderEdit | 5,095 | 维护困难 | 按功能模块拆分 |
| PurchaseService | 4,722 | 跨域耦合 | 提取独立服务 |
| CommonService | 3,082 | 职责过重 | 按业务域拆分 |

### 4.2 SaleOrderEdit拆分建议

```
原：SaleOrderEdit (5,095行)

拆分为：
  ├── SaleOrderEdit_Header    (表头操作，~1000行)
  ├── SaleOrderEdit_Entry     (分录操作，~1500行)
  ├── SaleOrderEdit_Audit     (审核逻辑，~800行)
  ├── SaleOrderEdit_Price     (价格计算，~500行)
  ├── SaleOrderEdit_Lock      (锁定处理，~400行)
  └── SaleOrderEdit_Credit    (信用检查，~395行)
```

---

## 五、DA7分析结论

**报表清单**：9个
- 订单报表：3个
- 出库报表：2个
- 分析报表：4个

**服务类**：4个核心
- SaleService
- SaleOrderService
- SaleOutStockService
- DeliveryNoticeService

**决策卡**：5个
- 锁定时机
- 应收生成
- 价格来源
- 信用检查
- GL凭证

**巨型类风险**：3个
- SaleOrderEdit
- PurchaseService
- CommonService

**进入DA8的输入**：
- 需验证假设与约束
- 需识别反证案例
