# Best-Design-Decision-Package

> 阶段：5A 统一设计决策工作流  
> 产品：低代码平台  
> 日期：2026-07-06  
> 结论：T-5A-05 已人工确认；全量范围接受但按 M0/M1/M2/M3 分阶段实现。M0 可继续开发准入复核；M1/M2/M3 的 proposed 决策不得提前视为 accepted。

## 1. 输入材料

| 输入 | 路径 | 作用 |
|---|---|---|
| 知识库快照 | `../01-知识库盘点/KnowledgeSnapshot.json` | 锁定本轮知识库输入基线 |
| 知识库差异 | `../01-知识库盘点/KnowledgeDiff.md` | 确认本轮为首次基线，不自动变更 PRD |
| PRD | `../03-需求/PRD-产品需求规格说明书.md` | 定义产品范围、用户角色、里程碑和验收样例 |
| 总体架构 | `00-总体架构与技术选型.md` | 定义技术栈、模块、质量属性和 ADR 清单 |
| 元模型设计 | `01-元模型设计.md` | 定义领域模型、元数据存储和动态表策略 |
| 架构与设计权衡矩阵 | `Architecture-and-Design-Tradeoff-Matrix.md` | 汇总 10 个关键设计点的候选 A/B/C、落选理由和验证方式 |
| 领域模型决策矩阵 | `Domain-Model-Decision-Matrix.md` | 承接产品路线、BusinessObject、扩展、关系链路和状态动作 |
| 数据模型决策矩阵 | `Data-Model-Decision-Matrix.md` | 承接元数据、动态业务表、快照、字段类型和迁移兼容 |
| 业务规则决策矩阵 | `Business-Rule-Decision-Matrix.md` | 承接表达式、状态机、规则链、副作用和单据转换 |
| 权限模型决策矩阵 | `Permission-Model-Decision-Matrix.md` | 承接 AccessView、租户隔离、字段权限、调岗语义和 break-glass |
| 设计模式采纳矩阵 | `Design-Pattern-Adoption-Matrix.md` | 承接模块化单体、MetaGraph、SPI、Outbox、UI 渲染等模式 |
| UI/组件决策矩阵 | `UI-and-Component-Decision-Matrix.md` | 独立承接 UI 架构、组件库、状态组合、可访问性和发布集成 |
| ADR | `ADR/` | 承接单向门决策 |
| 风险清单 | `../07-知识库同步/07-低代码平台级架构陷阱与高难度问题清单.md` | 约束失败模式和测试门禁 |
| 任务与测试 | `../06-任务与测试/` | 承接实现、测试和追踪矩阵 |

## 2. 关键设计点判定

| 关键设计点 | 是否关键 | 原因 |
|---|---|---|
| 产品路线 | 是 | 决定是业务低代码平台还是内部工具构建器 |
| 企业软件架构 | 是 | 决定模块边界、部署、测试和后续拆分路径 |
| 领域模型 | 是 | 影响所有元数据、动态表、权限、页面和发布 |
| 数据模型 | 是 | 动态表、元数据 JSON 聚合和业务查询性能是核心风险 |
| 业务规则/状态机 | 是 | 影响副作用、幂等、规则循环、流程扩展 |
| 权限模型 | 是 | 低代码平台核心安全边界 |
| UI/组件设计 | 是 | 决定设计器、renderer 和权限/字段状态的一致性 |
| 非功能性设计 | 是 | 性能、安全、可观测、可运维是平台级门槛 |

## 3. 决策包摘要

| 设计点 | 推荐方案 | 依据 | ADR 状态 | 是否可进入实现 |
|---|---|---|---|---|
| 产品路线 | 业务元模型优先 | 知识库 README、PRD、总体架构 | 产品方向已进入 PRD | M0 可执行，需人工确认 owner |
| 架构形态 | 模块化单体 | ADR-LOWCODE-M0-001、质量属性权衡 | accepted | M0 可执行 |
| 技术栈 | Java 21 + Spring Boot + React + AntD | ADR-LOWCODE-TECH-001、团队能力 | accepted | M0 可执行 |
| 领域模型 | BusinessObject 聚合根 + 19 元模型对象 | ADR-LOWCODE-DM-001、元模型设计 | accepted for M0 | M0 子集可执行 |
| 元数据存储 | 9 张元数据表 + JSON 聚合 + lc_meta_ref | ADR-LOWCODE-STORE-001 | accepted for M0 | M0 可执行 |
| 动态业务表 | 每实体对象一张真实动态表 | 元模型设计 §3.2、T-004 | 设计承接 | M0 可执行 |
| 发布管线 | Version snapshot + DDL Plan + Reconciler | ADR-LOWCODE-PUBLISH-001 | accepted for M0 | M0 可执行 |
| 权限模型 | AccessView 多层权限内核 | ADR-LOWCODE-PERM-001 | proposed | M1 前终审 |
| 副作用模型 | Outbox | ADR-LOWCODE-OUTBOX-001 | proposed | M1 前终审 |
| UI/组件 | 双层构建器 + Renderer 字段组件库 | 03-设计器与前端设计、T-201~T-206 | proposed | M2 前终审 |
| 插件/Connector/License | SPI + 生命周期治理 | ADR-LOWCODE-APP-PACKAGE-001 等 | proposed | M3 前终审 |

## 4. 5A 矩阵等价映射与独立产出声明

v0.6 要求 8 个决策矩阵默认逐一独立产出；本轮处理如下：

| v0.6 要求矩阵 | 本轮承载文件 | 关系 | 结论 |
|---|---|---|---|
| 领域模型候选方案比较 | `Domain-Model-Decision-Matrix.md` | 独立成文 | done |
| 企业软件架构候选方案比较 | `Architecture-and-Design-Tradeoff-Matrix.md` + `Design-Pattern-Adoption-Matrix.md` | 总体权衡 + 设计模式矩阵共同承载；架构形态行已显式写候选 A/B/C | done |
| 架构与设计权衡矩阵 | `Architecture-and-Design-Tradeoff-Matrix.md` | 独立总览矩阵 | done |
| 数据模型决策矩阵 | `Data-Model-Decision-Matrix.md` | 独立成文 | done |
| 业务规则决策矩阵 | `Business-Rule-Decision-Matrix.md` | 独立成文 | done |
| 权限模型决策矩阵 | `Permission-Model-Decision-Matrix.md` | 独立成文 | done |
| 设计模式采纳矩阵 | `Design-Pattern-Adoption-Matrix.md` | 独立成文 | done |
| UI/组件决策矩阵 | `UI-and-Component-Decision-Matrix.md` | 独立成文，不使用等价映射替代 | accepted by decisionOwner，M2 实现前仍需里程碑复核 |

## 5. 创新候选说明

权衡矩阵 10 个关键设计点均已补候选 C。创新候选不是独立炫技方案，而是对候选 A（知识库/竞品证据）和候选 B（行业标准/最佳实践）的组合、约束或增强。

| 关键设计点 | 候选C 摘要 | 当前处理 |
|---|---|---|
| 产品路线 | 模型安全内核优先 | 采纳为产品路线约束 |
| 架构形态 | 模块化单体 + Fitness Functions | 采纳为工程边界约束 |
| 技术栈 | 既有栈 + 端到端契约生成 | 采纳为前后端一致性约束 |
| 领域模型 | BusinessObject + Capability Contract | 采纳 BusinessObject；Capability Contract 作为 M1/M2 增强候选 |
| 元数据存储 | JSON 聚合 + 引用影子表 + 热点影子列 | M0 采纳 JSON 聚合 + lc_meta_ref；热点影子列进入 Spike |
| 业务数据存储 | 动态表 + SchemaSync 风险解释器 | 采纳为发布体验与测试约束 |
| 发布模型 | UI Snapshot Pairing | 后端发布采纳；UI 部分待 M2 人工确认 |
| 权限模型 | AccessView + Permission Explain + Tenant-Safe Data Path | proposed，M1 前人工终审 |
| 副作用模型 | Auditable Outbox Receipt | proposed，M1/M3 分阶段终审 |
| UI 架构 | Schema Capability Ladder | accepted as baseline，M2 实现前复核 |

未采纳或延后创新候选的具体拒绝理由已写入 `Architecture-and-Design-Tradeoff-Matrix.md` 和对应独立矩阵：主要原因是 M0 范围控制、DDL 演化成本、UI 决策需人工确认、proposed ADR 不得提前实现。

## 6. “最佳”判定说明

本轮不把“最佳”理解为绝对最优，而定义为：

```text
在企业业务低代码平台目标、M0~M3 分阶段交付、Java/Spring/MySQL/React 团队能力、客户-订单-审批样例、动态 DDL 与权限高风险约束下，当前最合适。
```

M0 可执行的理由：

1. 产品路线、技术栈、模块化单体、最小元模型、元数据存储、发布管线均有 ADR 或架构设计承接。
2. M0 不提前实现完整权限、设计器、插件、工作流和 Connector，范围可控。
3. 动态 DDL、元数据快照和 MetaGraph 是当前最大技术风险，已有 T-002/T-004/T-005 详细设计和 M0 测试规格承接。

保留风险：

1. 竞品知识库整体成熟度仍为 L0+，不能把竞品内部实现当直接事实。
2. decisionOwner 已确认为“我本人”，但 M0 覆盖审计和 evidenceId 结构化仍未完全关闭。
3. 权限、表达式、UI、插件、License 等 M1/M2/M3 决策仍需里程碑终审。

## 7. 验证与追踪

| 决策 | 验证方式 | 追踪位置 |
|---|---|---|
| 模块化单体 | ArchUnit 模块依赖测试 | T-001、M0 测试规格 |
| 最小元模型 | 客户-订单-审批元数据样例 | T-002/T-003、M0 测试规格 |
| JSON 聚合元数据 | DTO 序列化、JsonUpgrader、lc_meta_ref 重建 | T-002/T-003 |
| 动态 DDL | 建表、加列、危险变更阻断、Reconciler | T-004 |
| MetaGraph | 快照加载、版本固定、缓存失效 | T-005 |
| 权限模型 | 字段权限、数据范围、双租户隔离 | T-103、M1 测试规格 |
| UI 组件 | 字段组件状态、权限裁剪、XSS | T-201、M2 测试规格 |

## 8. 阶段 5A 结论

```text
decision: conditional-pass-candidate
reason:
  5A 要求的 8 个矩阵已独立产出或有明确等价映射；
  10 个关键设计点已补候选C、落选拒绝理由和验证方式；
  T-5A-05 已人工确认全量范围按里程碑推进；
  但知识库 evidenceId 结构化和 M0 covered 状态精确核验尚未关闭。
allowed:
  可继续补 Development-Ready-Review 和 CapabilityTraceMatrix；
  可继续 M0 开发准入复核和实现材料准备。
notAllowed:
  不得宣称全流程 pass；
  不得把 proposed ADR 当 accepted 实现；
  T-201~T-206 已恢复为 M2 基线输入，但不得提前在 M0/M1 实现；
  不得绕过人工门禁进入高风险实现或上线。
```

## 9. 5.0 自检

| 检查项 | 结果 |
|---|---|
| 完整性 | 已列入 8 个矩阵承载关系、10 个候选 C 摘要、验证与追踪位置 |
| 一致性 | 与 v0.6 阶段 5A、任务书 07d 和 Development-Ready conditional 状态一致 |
| 可测试性 | 每类决策均保留验证方式，UI/权限/副作用仍按里程碑终审 |
| 可追溯性 | 已指向 CapabilityTraceMatrix 更新项和各详细设计承接位置 |
