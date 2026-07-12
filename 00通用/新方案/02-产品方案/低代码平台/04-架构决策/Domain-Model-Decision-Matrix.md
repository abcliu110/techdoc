# Domain-Model-Decision-Matrix

> 阶段：5A 统一设计决策工作流  
> 质量流水线：入口检查已读取 PRD、用户需求、总体架构、元模型设计、ADR 与 CapabilityTraceMatrix；本文件为生产产物，需经自检、评审、基线后才能作为实现输入。

| 设计点 | 候选A(知识库/竞品证据) | 候选B(行业标准/最佳实践) | 候选C(自主创新方案) | 采纳结论 | 各落选候选拒绝理由 | 验证方式 | 承接ADR |
|---|---|---|---|---|---|---|---|
| 产品路线与核心领域模型 | 金蝶/Frappe 路线：业务对象、字段、状态、规则、权限、页面围绕业务元模型组织 | DDD 聚合根 + 元数据驱动应用，业务语义优先于页面控件 | 模型安全内核优先：首版只允许页面消费已发布模型，所有 UI 能力必须通过 MetaGraph、AccessView、Version snapshot 三重内核验证 | 采纳 C 作为 A/B 的收敛增强，M0/M1 按模型内核优先推进 | A 单独采用会偏竞品复刻，缺少本项目的安全内核约束；B 单独采用会偏传统代码建模，低代码配置闭环不足 | 客户-订单-审批样例中，页面不配置时仍可由 BusinessObject 生成 CRUD、状态动作和权限裁剪；页面覆盖不得绕过服务端校验 | ADR-LOWCODE-DM-001、00-总体架构与技术选型.md、01-元模型设计.md |
| BusinessObject 聚合边界 | Frappe DocType / NocoBase Collection 均以对象定义承载字段和关系 | 聚合根保护不变量，外部只能通过领域服务修改聚合 | BusinessObject + Capability Contract：每个对象发布时生成“能力契约”，列出可用字段类型、动作、权限、页面、测试向量，供 UI 和测试共同消费 | 采纳 BusinessObject 聚合根；Capability Contract 作为 M1/M2 增强候选 | 只用竞品对象模型会缺统一测试契约；纯 DDD 聚合不天然覆盖动态 UI 和发布快照 | T-002/T-003 元模型服务测试；M2 renderer 读取同一契约验证字段组件能力 | ADR-LOWCODE-DM-001、T-002、T-003、T-201 |
| 标准对象与客户扩展 | 金蝶式标准单据 + 扩展字段/扩展规则；Frappe 支持 DocType Custom Field | 企业软件常用扩展点模式：标准对象不可直接改，客户扩展单独分层 | ObjectExtension 差异层 + 升级回放器：客户扩展以补丁层叠加，升级时先回放 vendor snapshot 再重放客户扩展并生成冲突报告 | M0 只预留 DTO 与阻断，M2/M3 前终审 proposed ADR | A 直接照搬会带来复杂升级语义；B 若只做扩展点不做回放报告，无法解释升级冲突 | 标准对象升级不覆盖客户字段；冲突字段、权限覆盖和页面覆盖能出报告并阻断 | ADR-LOWCODE-OBJECT-EXT-001、T-307~T-310 |
| 关系与单据链路 | 竞品普遍支持 link、table、multilink、单据转换和反写 | 企业应用要求引用完整性、状态约束、审计链路和幂等 | LinkTrace + ConvertRule 双层链路：普通关系只表达引用，单据转换单独记录来源、目标、数量/金额反写和幂等键 | M0 预留关系模型；ConvertRule 进入 M2/M3 proposed | A 若把单据链路当普通 link 会丢失反写和超额控制；B 若首版完整实现会扩大 M0 范围 | M0 校验悬空 link；M3 覆盖超额转换、回滚、删除和导入导出链路 | ADR-LOWCODE-CONVERSION-001、T-002、T-307~T-310 |
| 状态与动作模型 | Frappe Workflow / 金蝶流程均把状态和动作作为单据语义 | 状态机模式：状态转换必须显式、可审计、可测试 | StateAction Contract：每个动作发布时生成允许角色、前置条件、后置规则和 UI 可见性解释，供 AccessView、renderer 和测试复用 | 采纳显式状态机；StateAction Contract 作为 M1/M2 增强候选 | 只按竞品界面配置会缺统一运行时解释；只按后端状态机实现会让 UI 可见性漂移 | 状态动作按钮、API action、审计日志和测试规格对同一动作给出一致结果 | 02-运行时引擎设计.md、T-104、T-204 |

## 5.0 自检

| 检查项 | 结果 |
|---|---|
| 完整性 | 已覆盖产品路线、聚合边界、扩展、关系链路、状态动作 5 个领域模型关键点 |
| 一致性 | 与 PRD REQ-001~013、REQ-040~043、REQ-070~078 和既有 ADR 状态一致 |
| 可测试性 | 每行均给出样例、契约、阻断或回放类验证方式 |
| 可追溯性 | 已引用 ADR、详细设计和测试承接位置；需登记 CapabilityTraceMatrix |

