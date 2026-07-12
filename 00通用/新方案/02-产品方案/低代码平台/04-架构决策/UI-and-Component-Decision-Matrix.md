# UI-and-Component-Decision-Matrix

> 阶段：5A 统一设计决策工作流  
> 状态：accepted-baseline  
> 质量流水线：入口检查已读取 PRD、用户故事、03-设计器与前端设计、T-201~T-206、权限/发布 ADR 与 M2 测试规格。本矩阵已由 decisionOwner 在 T-5A-05 确认接受，作为 T-201~T-206 的 M2 详细设计基线。

| 设计点 | 候选A(知识库/竞品证据) | 候选B(行业标准/最佳实践) | 候选C(自主创新方案) | 采纳结论 | 各落选候选拒绝理由 | 验证方式 | 承接ADR |
|---|---|---|---|---|---|---|---|
| 组件库策略 | AntD 直用，竞品 demo 多可快速搭建表单和列表 | 封装企业设计系统组件，统一状态、可访问性、错误、权限 | Thin Wrapper + Field Capability Contract：AntD 作为底座，字段组件只暴露平台统一 FieldRenderer 接口，并由能力契约驱动状态组合 | 采纳 C | A 直用会让权限/脱敏/错误状态散落；B 全自研成本高且拖慢 M2 | 22 种字段组件注册、权限状态、XSS、link suggest 权限测试 | T-201、ADR-LOWCODE-FIELDTYPE-SPI-001 |
| 字段组件状态模型 | 竞品字段通常支持只读、禁用、隐藏、必填、错误 | UI 状态机应区分权限状态、数据状态、交互状态 | Permission x Data x Interaction 三轴状态表：NONE/MASKED/READ/WRITE × empty/dirty/stale/error × idle/loading/submitting/conflict | 采纳 C | A 状态语义不完整；B 若只按组件内部状态会忽略权限和版本冲突 | T-201 状态组合表；META_VERSION_STALE 保留输入；只读字段恶意提交被后端拒绝 | T-201、T-206、ADR-LOWCODE-PERM-001 |
| 页面 Schema 协议 | NocoBase UI Schema 启发：组件树 + 绑定对象 | 采用成熟协议如 amis/formily 可提高生态复用 | 自研精简 Schema + 兼容层预留：首版只保留对象绑定、布局、字段、动作、区块；不引入外部协议作为持久化格式 | 采纳 C | A 直接照搬受竞品结构限制；B 外部协议锁定过深，权限和发布语义难收敛 | PageSchemaValidationTest、旧 schema 回放、schemaVersion 不支持阻断 | 03-设计器与前端设计.md、T-205、T-206 |
| 可访问性基线 | 现有竞品 UI 证据以截图/文档为主，未形成可访问性保证 | WCAG 2.2 AA、WAI-ARIA APG、键盘可达、错误可感知 | Accessibility Gate：所有字段组件、表格、弹窗、画布和属性面板必须有 keyboard path、aria label/description、错误关联和焦点恢复验收 | M2 采纳 WCAG 2.2 AA 作为目标基线，复杂画布先达到键盘替代操作 | A 无法支撑企业软件合规；只追求 AA 全覆盖但不分组件风险会拖慢首版 | axe/组件单测、键盘路径清单、错误 message 与控件 aria-describedby 关联 | T-201~T-206、M2 测试规格 |
| 设计器交互范式 | Frappe 字段表格、NocoBase 区块、金蝶流程设计均有不同范式 | 属性面板、直接操纵、表格编辑应按任务复杂度组合 | Mixed Builder：模型编辑用表格 + 抽屉，状态机用画布 + 属性面板，页面布局用区块/字段直接操纵 + 右侧属性面板 | 采纳 C | 纯属性面板低效；纯直接操纵难表达权限/状态/规则；纯表格不适合布局和状态机 | ModelBuilder、状态机画布、页面 schema 三类任务的 E2E 验收 | T-203、T-204、T-205 |
| 默认页面策略 | 建对象即生成默认列表/表单/详情 | CRUD scaffold 是低代码平台降低首用成本的常见做法 | Default Page + Explainable Override：默认页面可直接运行，任何覆盖都说明“只影响展示/收紧权限/不改变语义” | 采纳 C | 只靠自定义页面首用成本高；默认页面若不可解释会误导设计者认为可放权 | 客户/order/order_item 默认页面无需配置可用；隐藏必填字段后后端仍校验 | T-202、T-205 |
| 发布与运行时集成 | 竞品通常有设计态/运行态分离 | 版本快照、兼容检查、回放测试 | UI Snapshot Pairing：PageSchema、fieldTypeCapabilities、expressionVersion 与 metaHash 成对发布，renderer 必须上报组合版本 | 采纳 C | 只发布后端元数据会导致前端 schema 漂移；设计态直接生效风险高 | v1/v2 schema 回放、META_VERSION_STALE、双实例 60 秒收敛 | ADR-LOWCODE-PUBLISH-001、T-206 |

## 5.0 自检

| 检查项 | 结果 |
|---|---|
| 完整性 | 已覆盖组件库策略、字段状态模型、页面 Schema、可访问性、交互范式、默认页面、发布集成 |
| 一致性 | 与 PRD REQ-020~023、REQ-077、REQ-084、REQ-088、REQ-090 和 03-设计器与前端设计一致 |
| 可测试性 | 每行均给出组件、E2E、axe/键盘、schema 回放或版本冲突验证 |
| 可追溯性 | 已映射到 T-201~T-206 和 M2 测试规格；需登记 CapabilityTraceMatrix |

## 评审状态

本矩阵已完成 T-5A-05 人工确认。T-201~T-206 已恢复为 M2 可基线详细设计；实现仍按 M2 里程碑门禁推进，不得提前进入 M0/M1。
