---
id: BIZ-LOWCODE-001
type: business
domain_object: LowCodePlatform
competitors: [Kingdee-Cosmic, Appsmith, ToolJet, Budibase, Lowcoder, NocoBase, NocoDB, Frappe, Directus]
evidence: [E-KINGDEE-COSMIC-001, E-KINGDEE-COSMIC-002, E-APPSMITH-001, E-TOOLJET-001, E-BUDIBASE-001, E-NOCOBASE-001, E-NOCODB-001, E-FRAPPE-001, E-DIRECTUS-001, E-LOWCODER-001]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [ADR-LOWCODE-001]
owner: AI
ai_generated: true
---

# 业务设计：低代码平台的三类路线

成熟度说明：本卡基于公开文档和 GitHub/官网材料形成，尚未完成 NocoBase、Frappe、Appsmith、Directus 的本地安装或试用验证；按指导书要求，当前只作为 L0 方向级判断。

## 核心抽象

低代码平台不是单一物种。按公开资料和产品能力，可拆成三条路线：

| 路线 | 代表 | 本质模型 | 主要用户 | 适合场景 |
|---|---|---|---|---|
| 业务元模型平台 | 金蝶 AI 苍穹、Frappe | 用元数据描述业务对象、规则、流程、权限、表单和运行时 | 企业应用团队、ERP/业务平台团队 | ERP、单据、主数据、审批、企业级扩展 |
| 内部工具构建器 | Appsmith、ToolJet、Budibase、Lowcoder | UI 组件 + 数据源 + 查询 + 脚本/绑定 + 发布 | 开发者、运营/数据团队 | 管理后台、内部工具、看板、简单审批 |
| 数据模型驱动平台 | NocoBase、NocoDB、Directus | Collection/Table + Field + Relation + View/API + Permission | 数据应用团队、业务应用团队 | 数据后台、轻业务应用、表格协作、自动 API |

## 核心判断

如果目标是“企业业务低代码”，不能从拖拽页面开始。页面只是业务对象的一个视图，真正的核心是：

```text
业务对象
→ 字段与关系
→ 状态与动作
→ 规则与流程
→ 权限与组织
→ 页面与报表
→ API 与集成
```

内部工具构建器可以快速解决“把数据拿出来操作”的问题，但不能天然解决“业务对象的生命周期、状态机、引用关系和企业治理”。

## 设计启发

- 新平台首要建模对象应是 BusinessObject / Form / Action / Rule / Workflow / Permission，而不是 Button / Table / Input。
- UI Builder 应作为业务模型的展现层，而不是平台内核。
- 数据模型驱动平台值得借鉴 collection、association、permission、API 自动生成能力。
- 金蝶/Frappe 路线值得借鉴元数据和运行时一致的业务平台思想。
