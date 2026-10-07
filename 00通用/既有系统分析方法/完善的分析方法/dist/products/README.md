# 系统分析产物总览

## 基本信息

| 属性 | 值 |
|------|-----|
| 系统名称 | kaci-pos (来店餐饮POS系统) |
| 分析时间 | 2026-09-11 10:22:24 |
| 产物版本 | v1.0 |

## 产物清单

| 产物类型 | 数量 | 存放位置 |
|---------|------|----------|
| 聚合根 | 195 | 1-object-model/aggregate-cards/ |
| 实体 | 706 | 1-object-model/entity-cards/ |
| 值对象 | 3029 | 1-object-model/value-object-cards/ |
| 业务领域 | 10 | 1-object-model/domain-models/ |
| 业务模式 | 7 | 2-flow-analysis/process-patterns.md |
| 业务服务 | 409 | 2-flow-analysis/flow-cards/ |
| ID引用关系 | 276 | 1-object-model/relationship-network.md |

## 阅读顺序建议

1. 首先阅读 **[executive-summary.md](executive-summary.md)** 了解核心发现
2. 然后阅读 **[domain-map.md](1-object-model/domain-map.md)** 了解领域架构
3. 再阅读 **[process-patterns.md](2-flow-analysis/process-patterns.md)** 了解业务模式
4. 最后根据需要深入具体卡片

## 质量指标

| 指标 | 目标 | 实际 | 状态 |
|------|------|------|------|
| L4-L5占比 | ≥95% | 需人工评估 | ⚠️ 待评估 |
| L1占比 | ≤1% | 需人工评估 | ⚠️ 待评估 |
| 三跳完成度 | 100% | 需人工确认 | ⚠️ 待确认 |

## 业务领域

| 领域 | 对象数 | 聚合根 | 描述 |
|------|--------|--------|------|
| other | 2017 | 10 | other域 |
| order | 612 | 10 | 订单域 |
| goods | 360 | 10 | 商品域 |
| print | 274 | 10 | 打印域 |
| member | 179 | 3 | 会员域 |
| payment | 177 | 5 | 支付域 |
| kds | 122 | 10 | 厨房显示域 |
| table | 116 | 5 | 餐桌域 |
| takeout | 44 | 1 | 外卖域 |
| book | 29 | 1 | 预订域 |

## 核心发现预览

> 更多详细分析见 [executive-summary.md](executive-summary.md)

- 发现 1：系统包含 **10** 个业务领域
- 发现 2：识别出 **7** 种业务模式
- 发现 3：发现 **276** 条ID引用关系

---

**生成时间**: 2026-09-11 10:22:24
