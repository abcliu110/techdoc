# 架构与设计权衡矩阵

> 本矩阵按《02-流程-知识库驱动新产品创建与迭代.md》阶段 5A 建立。它不推翻已有 ADR，而是把已有 PRD、知识库、ADR、架构设计和详细设计纳入统一权衡视图。

## 1. 权衡维度

| 维度 | 本项目解释 |
|---|---|
| 业务目标适配 | 是否服务“企业业务低代码平台”，而不是内部工具构建器 |
| 领域模型表达力 | 是否能表达业务对象、字段、关系、状态、规则、权限、页面和版本 |
| 质量属性 | 性能、安全、可用性、可维护性、可测试性、可观测性、可扩展性 |
| 企业软件共性能力 | 权限、组织、审计、配置、报表、集成、扩展、数据治理 |
| 实现复杂度 | M0~M3 是否可分阶段落地 |
| 团队能力 | 是否匹配 Java/Spring/MySQL/React/AntD 既有能力 |
| 交付周期 | 是否能先跑通“客户-订单-审批”样例 |
| 演进成本 | 后续工作流、插件、导入导出、License、多组织是否可承接 |
| 数据一致性 | 动态 DDL、发布快照、状态流转、副作用是否可恢复 |
| 外部依赖 | 是否依赖不可控竞品实现或高风险新技术 |
| 失败模式 | 是否覆盖动态 DDL、租户隔离、权限、表达式、Connector、发布失败等风险 |
| 回滚成本 | 是否明确可回滚和不可物理回滚边界 |

## 2. 核心决策权衡

> v0.6 补齐说明：本节保留总览视图；独立矩阵已拆分到 `Domain-Model-Decision-Matrix.md`、`Data-Model-Decision-Matrix.md`、`Business-Rule-Decision-Matrix.md`、`Permission-Model-Decision-Matrix.md`、`Design-Pattern-Adoption-Matrix.md`、`UI-and-Component-Decision-Matrix.md`。候选 C 为自主创新方案，必须进入比较；落选时必须给出具体拒绝理由。

| 关键设计点 | 候选A(知识库/竞品证据) | 候选B(行业标准/最佳实践) | 候选C(自主创新方案) | 采纳结论 | 各落选候选拒绝理由 | 验证方式 | 承接 ADR/设计 | 状态 |
|---|---|---|---|---|---|---|---|---|
| 产品路线 | 业务元模型优先，贴合金蝶/Frappe 企业业务平台路线 | 页面拖拽优先，快速形成可视化搭建体验 | 模型安全内核优先：业务元模型 + MetaGraph + AccessView + Version snapshot 先成闭环，页面只能消费已发布模型 | 采纳 C | A 单独采用容易变成竞品复刻，缺安全内核约束；B 易退化为内部工具构建器，状态/规则/权限难治理 | 客户-订单-审批样例无需页面配置也可 CRUD，页面覆盖不能绕过服务端校验 | PRD §1、`00-总体架构与技术选型.md`、Domain 矩阵 | accepted for product direction，需人工 owner 终审 |
| 架构形态 | 模块化平台内核，竞品常见平台/插件边界 | 模块化单体优先，边界清晰后再拆服务 | 模块化单体 + Fitness Functions：用 ArchUnit、包依赖、事件边界和 CI 门禁持续约束模块边界 | 采纳 C | 首版微服务过早引入分布式复杂度；单模块大应用长期腐化；A 只描述形态，不足以防边界退化 | ArchUnit 模块依赖测试、模块 README、CI 门禁 | `ADR-LOWCODE-M0-001-modular-monolith.md`、Design Pattern 矩阵 | accepted |
| 技术栈 | Java/Spring + React/AntD，匹配企业交付和团队能力 | Node.js/Python 全栈可复用生态但会改变团队主能力 | 既有栈 + 端到端契约生成：后端 OpenAPI/元模型契约驱动前端类型、字段组件和测试向量 | 采纳 C 的约束化版本 | B 团队迁移成本高；Python/Frappe 同栈复用思想但不复用工程栈；A 若不加契约生成会产生前后端漂移 | OpenAPI/Meta DTO 生成、字段组件契约测试、前后端错误码对齐 | `ADR-LOWCODE-TECH-001-technology-stack.md`、T-001、T-201 | accepted |
| 领域模型 | BusinessObject 聚合根承载字段、关系、状态、规则、权限和版本 | DDD 聚合根保护业务不变量 | BusinessObject + Capability Contract：每个对象发布后生成可用字段、动作、权限、页面和测试向量契约 | 采纳 A；C 作为 M1/M2 增强候选 | B 单独采用不覆盖动态 UI/发布快照；C 首版全量实现会扩大 M0，先保留为契约增强 | T-002/T-003 元模型服务测试，M2 renderer 读取同一契约 | `ADR-LOWCODE-DM-001-minimal-domain-model.md`、`01-元模型设计.md`、Domain 矩阵 | accepted for M0 |
| 元数据存储 | 少表 + JSON 聚合，适合整体加载和版本快照 | 子定义全部拆表，强 FK/约束但 JOIN 与保存事务复杂 | JSON 聚合 + 引用影子表 + 热点影子列：lc_meta_ref 维护引用，高频查询字段按发布计划物化 | 采纳 A + lc_meta_ref；C 的热点影子列进入 M1 Spike | B 事务和演进成本高；C 热点影子列涉及额外 DDL 演化，M0 不直接实现 | JSON snapshot 升级、lc_meta_ref 重建、未知字段兼容、revision 冲突 | `ADR-LOWCODE-STORE-001-metadata-json-aggregate.md`、Data 矩阵 | accepted for M0 |
| 业务数据存储 | 每对象真实动态表，查询和索引可控 | EAV 或 JSON 宽表可减少 DDL 但损失约束和性能 | 动态表 + SchemaSync 风险解释器：发布前输出 DDL Plan、锁风险、迁移风险和回滚边界 | 采纳 C 的 DDL Plan/解释约束 | EAV 单据查询复杂；JSON 宽表权限和报表困难；单纯动态表若无解释器会让设计者误判风险 | 建表/加列/危险变更阻断、MDL 预检、Reconciler 差异分类 | `01-元模型设计.md` §3.2、T-004、Data 矩阵 | accepted for M0 |
| 发布模型 | 设计态/运行态分离 + Version snapshot | 版本化配置、不可变快照、请求级版本固定 | UI Snapshot Pairing：MetaGraph snapshot 与 PageSchema snapshot 成对发布，运行时记录 metaHash/pageSchemaVersion 组合 | 采纳 A；C 进入 M2 前端集成 | B 设计态直接生效风险高；手工 SQL 发布不可审计；C 的 UI 双快照需等 M2 矩阵人工确认 | 发布中请求钉住旧版本、旧 PageSchema 回放、META_VERSION_STALE 前端处理 | `ADR-LOWCODE-PUBLISH-001-persistent-publish-pipeline.md`、T-206、Data/UI 矩阵 | accepted for M0；UI 部分 pending |
| 权限模型 | AccessView 单一入口统一对象、字段、数据范围 | RBAC + ABAC 混合，服务端统一裁剪 | AccessView + Permission Explain + Tenant-Safe Data Path：所有入口只消费同一权限视图，拒绝可解释，tenant/app/object 缺失即阻断 | 倾向 C，M1 前终审 | 页面端控制会越权；SQL 散落拼接不可证明一致；A 若无 explain/tenant path 仍难排障和审计 | /meta/list/get/update/export/import/action/link 展开字段权限一致性测试，双租户隔离测试 | `ADR-LOWCODE-PERM-001-access-view-permission-core.md`、T-103、Permission 矩阵 | proposed，M1 前终审 |
| 副作用模型 | Outbox 支持幂等、重试、补偿 | Outbox Pattern + 死信 + 人工重放 | Auditable Outbox Receipt：副作用都有租户、来源、幂等键、脱敏 payload、投递收据和重放边界 | 倾向 C，M1/M3 分阶段实现 | 同步直接调用耦合主事务；各模块自建重试一致性不可控；A 若无 receipt 审计不足 | outbox 重试、死信、人工重放、敏感字段脱敏测试 | `ADR-LOWCODE-OUTBOX-001-local-outbox-side-effects.md`、Business Rule/Design Pattern 矩阵 | proposed，M1 前终审 |
| UI 架构 | 业务建模 + 页面编排双层构建器 | 组件库 + Renderer + 设计系统 + 可访问性基线 | Schema Capability Ladder：默认页面、布局覆盖、自定义区块、插件组件按能力阶梯开放，每一级都有权限、可访问性和兼容门禁 | 采纳 C 作为 M2 基线 | 自由画布优先容易绕过模型；纯默认页面表达力不足；A 若无能力阶梯和 a11y 门禁会使 T-201~T-206 难定稿 | T-201~T-206 组件、schema、权限、a11y、发布回放测试 | `03-设计器与前端设计.md`、T-201~T-206、UI 矩阵 | accepted baseline，M2 实现前复核 |

## 3. 当前不能判定为最终完成的点

| 设计点 | 原因 | 下一步 |
|---|---|---|
| 权限内核 | ADR 为 proposed，字段权限、数据范围、调岗语义需 M1 测试闭环 | M1 前终审 ADR，补权限矩阵测试 |
| 表达式引擎 | Aviator 暂定，知识库表达式/公式拆解成熟度不足 | M1 前补表达式 ADR 和沙箱测试 |
| UI 组件体系 | 已有设计，但缺完整组件决策矩阵与可访问性验收 | M2 前补 UI-and-Component Decision Matrix |
| 插件/Connector/License | M3 能力，当前多为 proposed | M3 前补决策包和安全测试 |

## 4. 门禁结论

```text
M0 架构可作为 conditional-pass 输入：
  - 模块化单体、技术栈、最小业务元模型、元数据存储、发布管线已具备 ADR 和详细设计承接。
  - decisionOwner 已确认为“我本人”，但仍不能宣称全流程 pass。
  - M1/M2/M3 的 proposed ADR 不得提前作为 accepted 实现。
```
