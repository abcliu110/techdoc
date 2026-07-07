---
id: NFR-LOWCODE-001
type: nfr
domain_object: LowCodePlatform
competitors: [Kingdee-Cosmic, ToolJet, Appsmith, NocoBase, Directus]
evidence: [E-KINGDEE-COSMIC-001, E-KINGDEE-COSMIC-002, E-TOOLJET-001, E-APPSMITH-001, E-NOCOBASE-001, E-DIRECTUS-001]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: []
owner: AI
ai_generated: true
---

# 非功能性：企业级低代码平台要求

成熟度说明：本卡基于公开资料和企业级平台通用要求抽象，尚未做安装、压测、安全测试或部署验证；当前只作为 L0 方向级非功能判断。

## 要求清单

1. 多租户隔离：租户、工作区、应用、数据源、模型资产必须隔离。
2. 权限与审计：设计、运行、发布、回滚、数据源访问都需要审计。
3. 版本治理：模型、页面、规则、流程发布必须有版本号和回滚路径。
4. 密钥安全：数据源凭证不得进入页面配置和导出包。
5. 插件隔离：插件能力需要权限声明和生命周期管理。
6. 性能护栏：列表、报表、查询必须有分页、超时、限流和缓存策略。
7. 可测试性：模型校验、规则校验、权限校验、流程执行应可自动测试。
8. 可观测性：查询、动作、流程、发布失败必须有日志和追踪。

## 设计启发

企业级低代码不是“能拖出页面”就完成。真正决定可用性的，是版本、权限、审计、隔离、密钥、可测试性和可观测性。
