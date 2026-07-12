---
id: MT-LOWCODE-001
type: metric
domain_object: LowCodeMetrics
competitors: [Kingdee-Cosmic, Appsmith, ToolJet, Budibase, NocoBase]
evidence: [E-KINGDEE-COSMIC-001, E-APPSMITH-001, E-TOOLJET-001, E-BUDIBASE-001, E-NOCOBASE-001]
strength: 高可信推断
confidence: 0.5
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: []
owner: AI
ai_generated: true
---

# 指标：低代码平台运营指标

成熟度说明：本卡为自研平台建议指标，不是竞品公开指标直接事实；未实测前按假设级处理。

## 建议指标

| 指标 | 含义 |
|---|---|
| 应用数 | 平台已创建应用数量 |
| 已发布应用数 | 进入运行状态的应用数量 |
| 模型复用率 | 被多个应用引用的业务对象/组件/流程比例 |
| 页面生成率 | 由模型自动生成页面占比 |
| 脚本逃逸率 | 需要手写脚本绕过模型能力的配置占比 |
| 发布失败率 | 校验或部署失败次数 / 发布次数 |
| 权限拦截数 | 因权限规则阻止的访问或动作次数 |
| 流程失败率 | 自动化/工作流执行失败次数 / 执行总次数 |
| 平均构建周期 | 从新建应用到发布的耗时 |

## 设计启发

低代码平台不能只统计“创建了多少页面”。更关键的是模型复用率、脚本逃逸率和发布失败率，这些指标能反映平台是否真的降低复杂度。
