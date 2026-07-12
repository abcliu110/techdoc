---
id: BR-LOWCODE-001
type: rule
domain_object: LowCodeGovernance
competitors: [Kingdee-Cosmic, Frappe, NocoBase, Directus, Appsmith, ToolJet]
evidence: [E-KINGDEE-COSMIC-001, E-KINGDEE-COSMIC-002, E-FRAPPE-001, E-NOCOBASE-001, E-DIRECTUS-001, E-APPSMITH-001, E-TOOLJET-001]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [ADR-LOWCODE-RULE-001]
owner: AI
ai_generated: true
---

# 业务规则：低代码平台治理规则

成熟度说明：本卡为公开资料基础上的治理规则抽象，尚未通过实际安装、权限配置、发布流程和失败场景验证；当前只作为 L0 方向级规则判断。

## 规则清单

1. 业务对象发布前必须完成字段、关系、权限、页面和动作校验。
2. 所有关联关系必须明确删除策略：禁止删除、级联删除、置空、归档。
3. 运行中模型变更必须生成新版本，禁止覆盖历史元数据。
4. 外部数据源连接必须隔离密钥，页面/应用导出不得包含明文凭证。
5. 权限规则必须同时覆盖功能权限和数据权限。
6. 自动化流程必须有触发条件、重试策略、失败记录和人工介入路径。
7. AI 生成的页面、规则、SQL、脚本默认进入待审核状态，不能直接发布到生产。

## 设计启发

业务低代码平台的治理规则必须是平台内核能力，不是项目管理约定。否则应用数量增加后，会出现权限失控、模型不可追溯、外部数据源泄漏和流程难以排查的问题。
