# CapabilityTraceMatrix

> 本矩阵用于阶段 6A 开发准入。2026-07-06 已完成 M0 范围精确核验：M0 只覆盖 T-001~T-005 元模型内核；M1/M2/M3 能力不作为 M0 开工阻断。

## 1. M0 must 能力追踪

| capabilityId | capabilityName | sourceEvidenceIds | evidenceLevel | productDecision | coverageStatus | prdRefs | adrRefs | designRefs | taskRefs | testRefs | lastCheckedAt |
|---|---|---|---|---|---|---|---|---|---|---|---|
| CAP-LCDP-M0-001 | 工程骨架、模块边界、本地环境和质量门禁 | EV-LOWCODE-PRD-001、EV-LOWCODE-ADR-TECH-001、EV-LOWCODE-ADR-M0-001 | 风险接受 | must | covered | REQ-030、REQ-078；`../03-需求/PRD-产品需求规格说明书.md` | `../04-架构决策/ADR/ADR-LOWCODE-TECH-001-technology-stack.md`、`../04-架构决策/ADR/ADR-LOWCODE-M0-001-modular-monolith.md`、`../04-架构决策/ADR/ADR-LOWCODE-ID-001-id-strategy.md` | `../05-详细设计/T-001-工程骨架详细设计.md`、`../05-详细设计/08-详细设计总纲.md` §2/§8 | `04-任务分配计划.md` T-001 | `测试规格/M0-测试规格.md` §3、§8.1 | 2026-07-06 |
| CAP-LCDP-M0-002 | 元数据表、实体层、JSON DTO、枚举、ID 与商用能力 DTO 预留 | EV-LOWCODE-PRD-001、EV-LOWCODE-ADR-DM-001、EV-LOWCODE-ADR-STORE-001 | 风险接受 | must | covered | REQ-001、REQ-002、REQ-010、REQ-011、REQ-030、REQ-070~REQ-078；`../03-需求/PRD-产品需求规格说明书.md` | `../04-架构决策/ADR/ADR-LOWCODE-DM-001-minimal-domain-model.md`、`../04-架构决策/ADR/ADR-LOWCODE-STORE-001-metadata-json-aggregate.md`、`../04-架构决策/ADR/ADR-LOWCODE-FIELDTYPE-SPI-001-field-type-handler-spi.md`、`../04-架构决策/ADR/ADR-LOWCODE-OBJECT-EXT-001-business-object-extension.md`、`../04-架构决策/ADR/ADR-LOWCODE-CONVERSION-001-document-conversion-writeback.md`、`../04-架构决策/ADR/ADR-LOWCODE-FLEXORG-001-flexfield-multi-org-code-rule.md`、`../04-架构决策/ADR/ADR-LOWCODE-APP-PACKAGE-001-marketplace-license-lifecycle.md` | `../05-详细设计/T-002-元数据表与实体层详细设计.md`、`../05-详细设计/08-详细设计总纲.md` §2.1/§6 | `04-任务分配计划.md` T-002 | `测试规格/M0-测试规格.md` §4、§8、§8.1 | 2026-07-06 |
| CAP-LCDP-M0-003 | 元模型领域服务、CRUD、引用索引、全图校验和误执行阻断 | EV-LOWCODE-PRD-001、EV-LOWCODE-ADR-DM-001 | 风险接受 | must | covered | REQ-001~REQ-004、REQ-010~REQ-013、REQ-070~REQ-078；`../03-需求/PRD-产品需求规格说明书.md` | `../04-架构决策/ADR/ADR-LOWCODE-DM-001-minimal-domain-model.md`、`../04-架构决策/ADR/ADR-LOWCODE-FIELDTYPE-SPI-001-field-type-handler-spi.md`、`../04-架构决策/ADR/ADR-LOWCODE-OBJECT-EXT-001-business-object-extension.md`、`../04-架构决策/ADR/ADR-LOWCODE-CONVERSION-001-document-conversion-writeback.md`、`../04-架构决策/ADR/ADR-LOWCODE-FLEXORG-001-flexfield-multi-org-code-rule.md` | `../05-详细设计/T-003-元模型领域服务详细设计.md`、`../05-详细设计/08-详细设计总纲.md` §2.1/§3 | `04-任务分配计划.md` T-003 | `测试规格/M0-测试规格.md` §5、§8、§9 | 2026-07-06 |
| CAP-LCDP-M0-004 | Schema Sync 动态 DDL、DDL Plan、发布状态机、Reconciler 和回滚边界 | EV-LOWCODE-ADR-PUBLISH-001、EV-LOWCODE-RISK-001 | 直接事实 / 风险接受 | must | covered | REQ-002、REQ-010~REQ-013、REQ-030、REQ-041、REQ-050~REQ-052；`../03-需求/PRD-产品需求规格说明书.md` | `../04-架构决策/ADR/ADR-LOWCODE-PUBLISH-001-persistent-publish-pipeline.md`、`../04-架构决策/ADR/ADR-LOWCODE-STORE-001-metadata-json-aggregate.md`、`../04-架构决策/ADR/ADR-LOWCODE-FIELDTYPE-SPI-001-field-type-handler-spi.md` | `../05-详细设计/T-004-SchemaSync动态DDL详细设计.md`、`../05-详细设计/08-详细设计总纲.md` §2/§6 | `04-任务分配计划.md` T-004 | `测试规格/M0-测试规格.md` §6、§8、§9 | 2026-07-06 |
| CAP-LCDP-M0-005 | MetaGraph 已发布快照加载、缓存、版本固定和多实例收敛 | EV-LOWCODE-ADR-PUBLISH-001、EV-LOWCODE-RISK-001 | 直接事实 / 风险接受 | must | covered | REQ-050、REQ-052、REQ-053、DEC-REQ-005；`../03-需求/PRD-产品需求规格说明书.md` | `../04-架构决策/ADR/ADR-LOWCODE-PUBLISH-001-persistent-publish-pipeline.md`、`../04-架构决策/ADR/ADR-LOWCODE-STORE-001-metadata-json-aggregate.md` | `../05-详细设计/T-005-MetaGraph缓存详细设计.md`、`../05-详细设计/08-详细设计总纲.md` §2/§6 | `04-任务分配计划.md` T-005 | `测试规格/M0-测试规格.md` §7、§8、§9 | 2026-07-06 |
| CAP-LCDP-5A-001 | 阶段 5A 领域模型、数据模型、业务规则、权限、设计模式、UI/组件决策矩阵 | EV-LOWCODE-ADR-001、EV-LOWCODE-ADR-002、EV-LOWCODE-RISK-001 | 风险接受 / 高可信推断混合 | gate | covered-for-gate | `../03-需求/PRD-产品需求规格说明书.md`、`../03-需求/需求追溯表.md` | `../04-架构决策/ADR/`、`../04-架构决策/Best-Design-Decision-Package.md` | `../04-架构决策/Domain-Model-Decision-Matrix.md`、`../04-架构决策/Data-Model-Decision-Matrix.md`、`../04-架构决策/Business-Rule-Decision-Matrix.md`、`../04-架构决策/Permission-Model-Decision-Matrix.md`、`../04-架构决策/Design-Pattern-Adoption-Matrix.md`、`../04-架构决策/UI-and-Component-Decision-Matrix.md`、`../05-详细设计/T-201-Renderer字段组件库详细设计.md`、`../05-详细设计/T-202-默认页面详细设计.md`、`../05-详细设计/T-203-ModelBuilder详细设计.md`、`../05-详细设计/T-204-状态机权限配置界面详细设计.md`、`../05-详细设计/T-205-页面Schema编辑详细设计.md`、`../05-详细设计/T-206-版本发布与前端集成详细设计.md` | `04-任务分配计划.md` T-201~T-206 | `测试规格/M0-测试规格.md`、`测试规格/M1-测试规格.md`、`测试规格/M2-测试规格.md` | 2026-07-06 |

## 2. 非 M0 能力追踪

| capabilityId | capabilityName | productDecision | coverageStatus | M0 判定 | 后续门禁 |
|---|---|---|---|---|---|
| CAP-LCDP-RUNTIME-001 | 动态数据 API 与运行态 CRUD | must | planned | not-applicable-for-M0 | M1：T-102、M1 测试规格、运行态 API 门禁 |
| CAP-LCDP-PERM-001 | AccessView 多层权限内核 | must | planned | not-applicable-for-M0 | M1：ADR-LOWCODE-PERM-001 终审、T-103、M1 权限测试 |
| CAP-LCDP-DESIGNER-001 | 设计器、Renderer 和页面 Schema | should | planned | not-applicable-for-M0 | M2：UI 矩阵已基线；T-201~T-206、M2 测试规格 |
| CAP-LCDP-PLUGIN-001 | 插件、导入导出、Connector、通知和商用能力 | planned | planned | not-applicable-for-M0 | M3：插件/包/Connector/License ADR 与 M3 测试规格 |

## 3. M0 准入判定

| 检查项 | 结果 | 说明 |
|---|---|---|
| M0 must 能力是否存在 missing | pass | CAP-LCDP-M0-001~005 均为 covered |
| M0 must 能力是否有 PRD 引用 | pass | 均引用到 REQ/DEC-REQ |
| M0 must 能力是否有 ADR 或设计承接 | pass | 高风险能力均有 accepted / accepted for M0 ADR 或明确 proposed 预留边界 |
| M0 must 能力是否有 T-001~T-005 详细设计 | pass | 均指向具体 T-00x 文件 |
| M0 must 能力是否有任务卡 | pass | 均指向 `04-任务分配计划.md` T-001~T-005 |
| M0 must 能力是否有 M0 测试规格 | pass | 均指向 `测试规格/M0-测试规格.md` 具体章节 |
| M1/M2/M3 能力是否误阻断 M0 | pass | 均标记 `not-applicable-for-M0` |

结论：`M0-ready`。本结论只允许进入 M0 元模型内核代码生成；M1/M2/M3 仍需按里程碑门禁推进。

