# 侦察报告 — K3Cloud Sal销售

## 版本信息
| 属性 | 值 |
|---|---|
| 分析模块 | Sal销售 |
| 分析时间 | 2026-08-07 |
| 文档目录 | D:\mywork\techdoc\00通用\000供应链\Sal销售\ |
| 分析依据 | L1规范v1.7 + Profile v1.4 |

---

## 一、源码规模

| 指标 | 数值 |
|---|---|
| C#文件数 | 472 |
| 代码行数 | 114,436 |
| 子域排名 | 第二大子域（仅次于Stock库存） |

**对比参考**：
| 子域 | 文件 | 行数 |
|---|---|---|
| Stock库存 | 541 | 146,748 |
| **Sal销售** | **472** | **114,436** |
| Purchase采购 | 159 | 58,863 |
| CP电商 | 378 | 73,666 |

---

## 二、销售链流转（代码化最完整）

### 2.1 完整业务流程

```
CRM商机(OP)──CrmContractToSaleOrder──▶销售报价──SaleQuotationToSaleOrder──▶销售订单
  SaleOrderPur ◀────────────────────────────┐
  销售订单──SaleOrderToDeliverNotice──▶发货通知──DeliveryNoticeToSalOutStock──▶销售出库
  销售订单──SaleOrderToOutStock──────▶销售出库(可出量过滤+汇率/组织回填)
  销售出库──OutStockToSalReturnStock──▶销售退货 ──SaleOrderToSalReturnNotice──▶退货通知
```

### 2.2 21个下推转换插件（均在App.Sal.ServicePlugIn）

| 转换类型 | 插件名 | 特点 |
|---|---|---|
| 商机→报价 | CrmContractToSaleOrder | CRM→销售桥接 |
| 报价→订单 | SaleQuotationToSaleOrder | 标准下推 |
| 订单→发货通知 | SaleOrderToDeliverNotice | 发货前序 |
| 发货通知→销售出库 | DeliveryNoticeToSalOutStock | 审核流 |
| 订单→销售出库 | SaleOrderToOutStock | 可出量过滤+汇率/组织回填 |
| 销售出库→退货 | OutStockToSalReturnStock | 退货处理 |
| 订单→退货通知 | SaleOrderToSalReturnNotice | 退货前序 |

---

## 三、核心机制

### 3.1 过账引擎（与Stock共享）

- **OperationController** + 7策略子类
- 过账三步：分录→差异临时表→MERGE INTO T_STK_INVENTORY
- 与Stock共用同一套库存更新机制

### 3.2 库存锁定

- **可用量 = 现存量 − 锁定量**（实时聚合自T_PLN_RESERVELINKENTRY）
- 预留明细带生命周期（FRESERVEDATE/FRELEASEDATE）
- 自身订单出库可用量 = 现存 + 自身锁库（占用不阻塞自身发货）

### 3.3 销售定价

- **SaleService**：历史价/可售/物流/销售控制
- 价格策略：价格表/折扣/信用
- 多币种汇率处理

---

## 四、跨域集成

| 方向 | 集成内容 |
|---|---|
| Sal → Stock | 销售出库触发库存扣减，库存锁定用于可用量控制 |
| Sal → AR | 销售出库生成应收单（AR应收） |
| Sal → GL | 销售出库生成GL凭证（收入/成本） |
| Sal → OP | 商机→报价→订单闭环 |
| Stock → Sal | 库存可用量影响销售承诺 |

---

## 五、服务清单

| 服务 | 职责 | 关键方法 |
|---|---|---|
| SaleService | 销售核心服务 | 历史价/可售/物流/销售控制 |
| SaleOrderService | 订单管理 | Create/Update/Audit/UnAudit |
| SaleOutStockService | 出库管理 | Save/Audit/Cancel |
| SaleReturnService | 退货管理 | Save/Audit |
| DeliveryNoticeService | 发货通知 | Create/Update/Audit |
| SaleQuotationService | 报价管理 | Create/Update/Audit |

---

## 六、巨型类风险

| 类名 | 行数 | 风险 |
|---|---|---|
| SaleOrderEdit | 5,095 | 维护成本极高 |
| SaleService | ~3,000 | 职责过重 |
| CommonService | 3,082 | 跨域耦合 |

---

## 七、侦察结论

### 7.1 十大候选事实（CF）

| # | 候选事实 | 证据来源 |
|---|---|---|
| CF-01 | 销售链是SCM中代码化最完整的子域（21个转换插件） | SCM源码分析 |
| CF-02 | 销售出库触发库存扣减（Sal→Stock集成） | SCM→FIN集成分析 |
| CF-03 | 销售出库生成应收单（Sal→AR联动） | 供应链业务机制 |
| CF-04 | 销售出库生成GL凭证（收入/成本确认） | 过账引擎分析 |
| CF-05 | 可用量 = 现存量 − 锁定量（实时计算） | SCM源码分析 |
| CF-06 | 订单审核触发库存锁定 | 预留机制分析 |
| CF-07 | 自身订单出库可用量包含自身锁库 | SCM源码分析 |
| CF-08 | 退货流程与正向流程对称 | 转换插件分析 |
| CF-09 | 多组织销售支持货主/保管者分离 | 组织架构分析 |
| CF-10 | 信用管理贯穿销售全程 | Credit域集成 |

### 7.2 十大未知项（U）

| # | 未知项 | 优先级 |
|---|---|---|
| U-01 | 销售定价折扣的具体计算逻辑 | 高 |
| U-02 | 库存锁定的生命周期管理细节 | 高 |
| U-03 | 退货与正向订单的关联追溯机制 | 中 |
| U-04 | 信用额度占用的具体时点和释放时机 | 中 |
| U-05 | 多币种销售汇率的处理规则 | 中 |
| U-06 | 销售订单变更对已审核单据的影响 | 中 |
| U-07 | 发货通知与实际出库的差异处理 | 中 |
| U-08 | 跨组织销售的内部交易处理 | 低 |
| U-09 | 销售预测与库存的协同机制 | 低 |
| U-10 | 销售数据分析报表的数据来源 | 低 |

---

## 八、DA0侦察结论

**核心发现**：
1. Sal销售是K3Cloud SCM中代码化最完整的子域
2. 与Stock/AP/AR/GL形成完整的"销售→出库→应收→凭证"链路
3. 21个转换插件覆盖报价→订单→发货→出库→退货全流程

**DA1切面选择**：
- 销售订单生命周期
- 销售出库与库存联动
- 应收生成与收款闭环
- 退货与信用恢复

**DA2概念切分**：
- 销售主体：客户/商机/报价/订单
- 出库主体：发货通知/销售出库/退货
- 财务主体：应收/收款/凭证
- 库存主体：库存锁定/可用量

**执行路径**：路径A（核心抽象内进化）
