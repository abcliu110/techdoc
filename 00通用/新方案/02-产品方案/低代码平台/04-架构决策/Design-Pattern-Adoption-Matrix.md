# Design-Pattern-Adoption-Matrix

> 阶段：5A 统一设计决策工作流  
> 质量流水线：入口检查已读取总体架构、ADR、详细设计总纲、代码规范与测试规格；本文件用于说明企业软件架构、设计模式和拒绝方案。

| 设计点 | 候选A(知识库/竞品证据) | 候选B(行业标准/最佳实践) | 候选C(自主创新方案) | 采纳结论 | 各落选候选拒绝理由 | 验证方式 | 承接ADR |
|---|---|---|---|---|---|---|---|
| 企业软件架构形态 | 竞品平台多为模块化平台内核 + 插件/扩展 | 模块化单体先行，边界清晰后再拆服务 | Modular Monolith + Fitness Functions：模块边界用 ArchUnit、包依赖、公共 DTO 和事件边界自动校验 | 采纳 C | 首版微服务过早引入分布式复杂度；单模块大应用长期腐化 | ArchUnit 模块依赖测试、CI 门禁、模块 README | ADR-LOWCODE-M0-001、T-001 |
| 元模型访问模式 | 竞品运行态会缓存元数据图 | Repository + Snapshot Cache，读写分离、请求级版本固定 | MetaGraph as Read Model：设计态写模型，发布态生成不可变读模型，运行时只读 MetaGraph | 采纳 C | 运行时直接查设计表会受未发布草稿影响；纯缓存无版本钉住难回放 | 请求级 metaHash 固定、Redis 失效 DB polling 收敛、旧 snapshot 回放 | ADR-LOWCODE-PUBLISH-001、T-005 |
| 字段类型扩展 | 竞品有字段类型与组件注册体系 | Strategy/SPI，开放封闭原则 | Capability Vector SPI：每个字段类型必须声明 DDL、转换、权限、renderer、测试向量，缺项不得启用 | 采纳 C | switch-case 散落不可维护；无测试向量的 SPI 只是形式扩展 | 字段类型 22 项契约测试、插件字段禁用后发布阻断 | ADR-LOWCODE-FIELDTYPE-SPI-001、T-004、T-201、T-302/T-303 |
| 规则与表达式 | 竞品提供表达式、公式、自动化 | Interpreter + Sandbox + Facade | Versioned Interpreter Facade：业务代码只能依赖 lowcode-expression 门面，表达式版本进入快照和回放 | 倾向 C；M1 前补表达式 ADR | 直接 import 引擎会锁死语法；通用脚本安全边界过大 | 沙箱测试、表达式版本回放、前后端子集对齐 | 待补 ADR-LOWCODE-EXPR-001、T-101 |
| 副作用与集成 | 竞品有通知、Webhook、Connector | Outbox、幂等、重试、死信、补偿 | Auditable Outbox Receipt：所有副作用都有租户、来源、幂等键、投递收据和人工重放边界 | 倾向 C | 同步调用耦合主事务；各模块自建重试不可治理 | outbox 重试/死信/重放/脱敏测试 | ADR-LOWCODE-OUTBOX-001、T-107、T-306 |
| UI 渲染架构 | 竞品有 UI Schema、字段组件、默认页面 | Renderer + Component Registry + Design System | Schema Capability Ladder：默认页面、布局覆盖、自定义区块、插件组件按能力阶梯开放，每一级都有权限和兼容门禁 | 采纳为 UI 矩阵的核心模式，M2 前终审 | 自由画布优先会绕过业务语义；纯默认页面表达力不足 | T-201~T-206 组件、schema、权限、发布回放测试 | UI-and-Component-Decision-Matrix、03-设计器与前端设计.md |

## 5.0 自检

| 检查项 | 结果 |
|---|---|
| 完整性 | 已覆盖架构形态、MetaGraph、字段 SPI、表达式、Outbox、UI 渲染模式 |
| 一致性 | 与 ADR 目录、T-001/T-004/T-005/T-101/T-107/T-201~T-206 一致 |
| 可测试性 | 每个模式均绑定自动化门禁或回放测试 |
| 可追溯性 | 已引用承接 ADR/详细设计；需登记 CapabilityTraceMatrix |

