# T-207 全新表单设计器：Schema 与运行时架构

> 状态：v0.2
> 日期：2026-07-09
> 上游依据：
> - `../01-产品定位与范围/T-207-全新表单设计器-产品定位与范围.md`
> - `../02-信息架构与工作台/T-207-全新表单设计器-工作台信息架构.md`
> - `../03-Web布局引擎/T-207-全新表单设计器-Web布局引擎设计.md`
> - `../04-表单元素与字段体系/T-207-全新表单设计器-表单元素与字段体系.md`
> - `../05-强表格与分录设计/T-207-全新表单设计器-强表格与分录设计.md`
> - `../06-规则权限流程集成/T-207-全新表单设计器-规则权限流程集成.md`

---

## 1. 设计目标

Schema 与运行时架构要回答一个核心问题：

```text
设计器产出的 PageSchema 如何被保存、归一化、分析、发布、版本化，
并在设计态、预览态、运行态用同一套 RuntimeRenderer 渲染。
```

T-207 必须避免三类失败：

1. 设计态能看，运行态不能跑。
2. Schema 可以保存，但发布后 Analyzer 才发现结构断裂。
3. 每个子系统各自定义路径、测试标识和版本格式，导致无法定位和回滚。

---

## 2. 总体架构

```text
Designer Command
  -> CommandStack
  -> SchemaStore
  -> Incremental SchemaNormalizer
  -> AnalyzerPipeline
  -> DraftStore
  -> PublishService
  -> VersionStore
  -> RuntimeSchemaLoader
  -> RuntimeRenderer
  -> RuntimeStateStore
```

| 模块 | 职责 | P0 |
|---|---|---|
| SchemaStore | 设计态内存 Schema 状态 | 是 |
| CommandStack | 撤销/重做命令栈 | 是 |
| SchemaNormalizer | 跨域 Schema 归一化总编排 | 是 |
| AnalyzerPipeline | 统一运行布局、字段、表格、规则权限分析 | 是 |
| DraftStore | 草稿保存 | 是 |
| PublishService | 发布校验和状态流转 | 是 |
| VersionStore | draft / published / archived 版本历史 | 是 |
| RuntimeSchemaLoader | 运行态加载已发布 Schema | 是 |
| RuntimeRenderer | 同源渲染页面 | 是 |
| RuntimeStateStore | 运行态字段、表格、动作状态 | 是 |

---

## 3. PageSchema 总结构

### 3.1 Schema 示例

```json
{
  "schemaVersion": "1.0",
  "pageId": "sales_order_form",
  "version": 12,
  "status": "draft",
  "basePublishedVersion": 11,
  "metadata": {
    "title": "销售订单",
    "businessObject": "SalesOrder",
    "updatedAt": "2026-07-09T10:00:00+08:00"
  },
  "root": "page_root",
  "components": {},
  "rules": {},
  "permissions": {},
  "stateMachine": null,
  "assets": {},
  "design": {
    "breakpoints": [1280, 1440, 1600, 1920],
    "defaultBreakpoint": 1440
  }
}
```

### 3.2 顶层命名空间

| 命名空间 | 说明 | P0 |
|---|---|---|
| metadata | 页面元信息 | 是 |
| root | 根组件 ID | 是 |
| components | PageRoot、布局容器、字段、表格、按钮等组件 | 是 |
| rules | RuleSchema | 入口；P1 完整 |
| permissions | PermissionSchema | 静态权限 P0，动态 P1 |
| stateMachine | StateMachineSchema | 最小结构 P0，完整 P1 |
| assets | 图片、图标、附件引用 | P1 |
| design | 设计态断点、辅助配置 | 是 |

P0 中所有可渲染对象必须能通过 `components.{nodeId}` 定位。Rule、Permission、StateMachine 使用独立顶层命名空间，但 target 必须引用 components 中的对象 ID。

### 3.3 components 与 layout 的关系

`components` 是 P0 唯一权威的可渲染节点命名空间。PageRoot、布局容器、字段、表格、按钮都存放在 `components.{nodeId}`，父子关系通过节点自身的 `children`、`tabs[].children`、`split` 子区引用表达。

PageRoot 自身也必须存入 `components`。`root` 字段只保存根组件 ID，例如 `root: "page_root"`；因此页面根的标准 schemaPath 是 `components.page_root`，而不是单独的顶层 `layout` 或 `pageRoot`。

`layout` 不是 PageSchema 的顶层命名空间。早期示例、导入文件或局部说明中如果出现 `layout.children[...]` 路径，只能视为旧格式或说明性伪路径；保存、发布、Analyzer、Inspector、Outline、自动化测试必须统一使用 `components.*` schemaPath。

SchemaNormalizer 在导入或保存旧 Schema 时负责把可迁移的 `layout.children` 树提升为 `components` 字典和 `root` 引用；无法稳定迁移的节点由 Analyzer 输出 Error 阻断发布。

---

## 4. ComponentSchema 分类

| 类型 | 示例 | 归属文档 |
|---|---|---|
| PageRoot | PageRoot | Web 布局引擎 |
| LayoutContainer | GridLayout、FlexLayout、Tabs、SplitPane、ScrollContainer、StickyBar | Web 布局引擎 |
| Field | FieldNode | 表单元素与字段体系 |
| EntryTable | EntryTableSchema | 强表格与分录设计 |
| TableColumn | EntryTable.columns[] | 强表格与分录设计 |
| ActionButton | ActionButton | 规则权限流程集成 |
| BusinessPanel | ApprovalPanel、AttachmentPanel、RelatedBillPanel | 后续扩展 |

TableColumn 不作为 `components.{id}` 顶层组件存储，统一放在 `components.{entryTableId}.columns[]`。这样可以避免表格列和布局节点混淆。

---

## 5. schemaPath 统一规范

### 5.1 路径规则

`schemaPath` 使用 JSONPath 风格，从 PageSchema 根开始，不使用 `$` 前缀。

| 规则 | 示例 |
|---|---|
| 顶层命名空间 | `components.field_customer` |
| 点号访问属性 | `components.field_customer.binding` |
| 数组使用下标 | `components.entry_items.columns[3]` |
| 不使用显示名定位 | 禁止 `components.客户字段` |
| 不使用临时 DOM ID 定位 | 禁止 `dom.#xxx` |

### 5.2 标准路径

| 场景 | schemaPath |
|---|---|
| 页面根 | `components.page_root` |
| 字段绑定 | `components.field_customer.binding` |
| 字段编辑器 | `components.field_customer.editor.type` |
| Grid 子节点 | `components.grid_basic.children[2]` |
| EntryTable 数据源 | `components.entry_items.dataSource` |
| TableColumn | `components.entry_items.columns[3]` |
| TableColumn 编辑器 | `components.entry_items.columns[3].editor.type` |
| SummaryRow | `components.entry_items.summaryRow.items[0]` |
| Rule | `rules.rule_credit_required` |
| Permission | `permissions.perm_sales_amount.static.readonly` |
| StateMachine transition | `stateMachine.transitions[1]` |
| ActionButton | `components.action_submit.action.transition` |

Analyzer、Inspector、Outline、Canvas 定位必须使用同一套 schemaPath。

---

## 6. data-testid 统一规范

### 6.1 命名原则

| 原则 | 说明 |
|---|---|
| 稳定 | 不随中文标题、排序、语言变化 |
| 可读 | 带对象类型和 ID |
| 分层 | 根节点、内部抓手、弹窗、错误区分开 |
| 不复用 | 不同对象类型不能共享同一个 testId |

### 6.2 命名空间

| 对象 | testId |
|---|---|
| 画布组件根节点 | `designer-node-{nodeId}` |
| 通用拖拽抓手 | `designer-handle-{nodeId}-drag` |
| 选中框 | `designer-selection-{nodeId}` |
| 通用投放点 | `designer-drop-target-{targetId}-{position}` |
| 字段根 | `field-node-{fieldId}` |
| 字段编辑器 | `field-editor-{fieldId}` |
| 字段错误 | `field-error-{fieldId}` |
| 表格根 | `designer-node-{tableId}` |
| 表格拖拽抓手 | `table-handle-{tableId}-drag` |
| 表格列投放点 | `table-column-drop-{tableId}-{position}` |
| 表格列头 | `table-column-header-{tableId}-{columnId}` |
| 表格单元格 | `table-cell-{tableId}-{rowKey}-{columnId}` |
| 表格列宽抓手 | `table-column-resize-{tableId}-{columnId}` |
| 规则项 | `rule-item-{ruleId}` |
| 权限行 | `permission-row-{targetId}` |
| 状态徽标 | `state-badge-{stateId}` |
| 动作按钮 | `action-button-{actionId}` |
| Analyzer 问题 | `analyzer-issue-{issueId}` |

所有自动化测试必须通过真实 DOM 操作这些 testId，不能直接修改内部状态。

通用 `designer-*` 用于所有画布节点的选择、移动和容器投放；表格内部列拖拽、列投放、列宽调整使用 `table-*` 专属命名空间，避免与普通布局容器的 drop target 混淆。

---

## 7. SchemaNormalizer

### 7.1 归一化职责

SchemaNormalizer 是保存、发布、导入和渲染前增量修复的总编排器。它不是替代 LayoutNormalizer 的另一个同级模块，而是调用各领域 Normalizer：

| 子 Normalizer | 职责 |
|---|---|
| LayoutNormalizer | PageRoot、Grid、Flex、Tabs、Split、Scroll、Sticky 的默认值、children 引用和非法嵌套修复 |
| FieldNormalizer | 字段默认编辑器、绑定、校验、状态默认值 |
| TableNormalizer | EntryTable columns/detail、列默认值、旧 children 迁移 |
| RulePermissionNormalizer | P0 静态状态、权限、动作引用的结构修正 |
| TestIdNormalizer | 节点、抓手、投放点和错误区域的稳定 testId |

保存和发布前必须执行完整 SchemaNormalizer：

```text
draft schema
  -> SchemaNormalizer
     -> LayoutNormalizer
     -> FieldNormalizer
     -> TableNormalizer
     -> RulePermissionNormalizer
     -> TestIdNormalizer
  -> ReferenceValidator
  -> AnalyzerPipeline
```

设计态交互不每次都执行完整保存链路。CommandStack 修改内存草稿后，SchemaStore 触发增量 SchemaNormalizer，只归一化受影响子树，再驱动 Analyzer 增量检查和 RuntimeRenderer 重渲染。保存、发布、导入时才执行完整归一化并写入持久化。

### 7.2 P0 归一化规则

| 规则 | 说明 |
|---|---|
| 补齐 id | 缺失 ID 的节点生成稳定 ID |
| 补齐 testId | 按统一命名规范生成 |
| 补齐布局默认值 | 由 LayoutNormalizer 补齐 span、labelWidth、minWidth、gap 等 |
| 迁移 EntryTable.children | 由 TableNormalizer 迁移为 columns/detail，无法迁移则 Error |
| 清理非法属性 | 删除 P0 不支持的复杂表头、P1 动态规则启用项 |
| 校验引用 | root、children、target、binding、schemaRef 必须可解析 |
| 稳定排序 | children、columns、rules、permissions 使用稳定顺序 |

Normalizer 只做结构归一化，不执行业务规则求值。

RulePermissionNormalizer 在 P0 只做结构级修复：

| 项 | P0 处理 |
|---|---|
| 静态状态 | 补齐 `visible/required/readonly/disabled` 默认值 |
| 静态权限 | 归一化 read/edit/readonly/action 可用性配置 |
| 动作引用 | 校验 ActionButton 的 target、transition、serviceRef 是否可解析 |
| 动态规则 | 保留入口但不启用动态求值；P1 字段需标记为 inactive 或产生 Warning |
| 状态机引用 | 只校验结构和 ID，不参与 P0 finalState 动态计算 |

---

## 8. AnalyzerPipeline

### 8.1 分析器组成

| Analyzer | 输入 | 输出 |
|---|---|---|
| LayoutAnalyzer | LayoutContainer / Field layout | 布局溢出、Sticky 冲突、最小宽风险 |
| FieldAnalyzer | FieldNode / TableColumn 子集 | 绑定、编辑器、校验、权限风险 |
| TableAnalyzer | EntryTableSchema | 列宽、冻结、明细、表格性能 |
| RulePermissionAnalyzer | rules / permissions / stateMachine / actions | 规则、权限、状态、动作问题 |
| PublishAnalyzer | 汇总所有 Analyzer | 发布门禁 |

### 8.2 严重级别

| 级别 | 发布影响 |
|---|---|
| Error | 阻断发布，不可忽略 |
| Warning | 不阻断发布，可要求说明 |
| Suggestion | 不阻断发布 |

Analyzer 输出必须包含：

```json
{
  "severity": "error",
  "code": "FIELD_BINDING_MISSING",
  "message": "客户字段缺少数据绑定。",
  "nodeId": "field_customer",
  "schemaPath": "components.field_customer.binding",
  "quickFix": "绑定到 salesOrder.customerId"
}
```

---

## 9. 版本状态与发布

### 9.1 状态

| Schema 版本状态 | 说明 |
|---|---|
| draft | 草稿，可编辑 |
| published | 已发布，运行态可加载 |
| archived | 已归档，不可作为运行态默认版本 |

本文的 `draft/published/archived` 指 Schema 版本状态，PageSchema 字段统一命名为 `status`。业务流程状态属于 StateMachine/RuntimeState，字段统一命名为 `bizState`，即使业务状态也叫 `draft/submitted/approved/archived`，也不得与 Schema 版本状态混用。

### 9.2 发布流程

```text
draft
  -> check stale draft
  -> SchemaNormalizer
  -> AnalyzerPipeline
  -> no Error
  -> create published version
  -> mark previous published as archived or historical published
  -> notify runtime
```

P0 支持三态流转和版本历史列表。依赖分析、破坏性变更检测、版本 Diff 归 P1。

发布前必须检查当前 draft 的 `basePublishedVersion` 是否仍等于最新 published 版本。若不一致，说明其他人已经发布过更新，当前草稿进入 stale 状态；P0 必须阻断发布并提示重新拉取或另存为新草稿，不能覆盖最新 published 版本。

### 9.3 版本记录

| 字段 | 说明 |
|---|---|
| pageId | 页面 ID |
| version | 版本号 |
| status | draft / published / archived |
| basePublishedVersion | 草稿基于的已发布版本号，用于 stale draft 检测 |
| schemaHash | Schema 内容哈希 |
| createdBy | 创建人 |
| createdAt | 创建时间 |
| publishMessage | 发布说明 |

`schemaHash` 在发布时生成，P0 采用 SHA-256 对归一化后的 PageSchema JSON 串计算。用途包括运行态缓存校验、版本完整性校验和后续 P1 版本 Diff 的快速预筛；它不是业务版本号，不能替代 `version`。

---

## 10. RuntimeRenderer

### 10.1 同源渲染

设计态、预览态、运行态必须使用同一套 RuntimeRenderer：

| 模式 | 差异 |
|---|---|
| design | 显示 DesignerOverlay、测试抓手和设计态权限辅助 |
| preview | 隐藏设计辅助，使用样例数据和样例权限结果 |
| runtime | 加载真实数据和真实权限结果 |

Renderer 不允许读取设计器内部状态来渲染页面，必须只依赖 PageSchema、RuntimeState 和 Registry。

### 10.2 渲染链路

```text
RuntimeSchemaLoader
  -> ComponentRegistry
  -> RuntimeStateResolver
  -> RuntimeRenderer
  -> FieldRenderer / TableEngine / ActionRenderer
```

| 模块 | 说明 |
|---|---|
| ComponentRegistry | 注册布局、字段、表格、按钮组件 |
| RuntimeStateResolver | 合并静态状态、权限、规则结果 |
| FieldRenderer | 渲染字段 |
| TableEngine | 渲染表格 |
| ActionRenderer | 渲染动作按钮 |

### 10.3 设计态事件链路

设计态的 CommandStack 与 RuntimeStateResolver 通过 SchemaStore 事件衔接：

```text
CommandStack.execute
  -> SchemaStore.applyPatch
  -> Incremental SchemaNormalizer
  -> AnalyzerPipeline.incrementalCheck
  -> RuntimeStateResolver.recomputeFinalStates
  -> RuntimeRenderer.rerender affected subtree
  -> MeasurementService update
  -> DesignerOverlay redraw
```

P0 要求这条链路对单节点属性修改、字段 span 调整、表格列宽调整可用。批量命令、跨页面依赖影响和远程增量 schema diff 归 P1。

---

## 11. RuntimeState

### 11.1 状态分类

| 状态 | 说明 |
|---|---|
| fieldValues | 字段运行态值 |
| tableRows | 表格行数据 |
| rowStates | 行编辑状态 |
| validationErrors | 校验错误 |
| finalStates | visible/required/readonly/disabled 等最终状态 |
| currentRole | 当前角色，P1，仅角色预览和动态权限使用 |
| currentBizState | 当前业务状态 |

RuntimeState 不写回 Schema。用户输入只改变 RuntimeState，设计器属性修改才改变 Schema。

P0 阶段 `stateMachine` 作为 PageSchema 内嵌子对象保存和发布，不提供独立 CRUD API。运行态只读取已发布 Schema 中的 `stateMachine`，并将当前业务状态写入 RuntimeState 的 `currentBizState`。完整流程建模器、独立状态机版本管理和流程接口归 P1。

角色预览不属于 P0 RuntimeState。设计器在 P1 引入 PreviewState 承载 `previewRole/currentRole`，用于模拟角色权限；运行态 P0 不依赖该字段。

### 11.2 提交边界

| 行为 | 影响 |
|---|---|
| 输入字段值 | RuntimeState |
| 调整字段 span | Schema |
| 编辑表格单元格 | RuntimeState |
| 调整列宽 | Schema |
| 切换角色预览 | PreviewState，P1 |
| 发布页面 | VersionStore |

---

## 12. CommandStack

### 12.1 命令类型

| 命令 | 示例 |
|---|---|
| AddNode | 拖入字段 |
| MoveNode | 移动布局节点 |
| UpdateProp | 修改属性 |
| ResizeField | 调整字段 span |
| ResizeColumn | 调整表格列宽 |
| AddColumn | 添加表格列 |
| AddRule | P1 添加规则 |
| SetPermission | 设置权限 |
| DeleteNode | 删除节点 |

P0 命令以单节点为主。P1 批量命令必须具备原子性。

### 12.2 命令记录

```json
{
  "id": "cmd_001",
  "type": "UpdateProp",
  "targetPath": "components.field_customer.title",
  "before": "客户",
  "after": "订货客户"
}
```

CommandStack 必须使用 schemaPath 定位修改目标。

---

## 13. API 草案

| API | 说明 | P0 |
|---|---|---|
| `GET /api/design/schema/{pageId}` | 获取草稿 | 是 |
| `POST /api/design/schema/save` | 保存草稿 | 是 |
| `POST /api/design/schema/analyze` | 执行 Analyzer | 是 |
| `POST /api/design/schema/publish` | 发布草稿 | 是 |
| `GET /api/design/schema/versions/{pageId}` | 版本历史 | 是 |
| `GET /api/runtime/page/{pageId}` | 获取最新发布版本 | 是 |
| `GET /api/runtime/page/{pageId}?schemaVersion=x` | 获取指定版本 | 是，需权限 |

P0 不提供 `stateMachine`、`rules`、`permissions` 的独立保存接口；它们随 PageSchema 一起保存、分析、发布。P1 如引入独立规则设计器或流程设计器，必须仍以 PageSchema 发布快照为运行态加载边界。

---

## 14. 热更新

P0 热更新策略：

| 步骤 | 说明 |
|---|---|
| 发布成功 | 写入 published version |
| 广播事件 | `schema:updated` |
| 运行态收到事件 | 重新拉取全量 Schema |
| 保留 RuntimeState | RuntimeRenderer 在本地尽量保留可兼容字段值，并只重渲染受影响子树 |
| 最大延迟 | ≤ 5 秒 |

P0 的热更新是“事件通知 + 全量 Schema 重新拉取 + 本地尽量局部重渲染”。远程增量 Schema diff 下发、真正的区块级热更新、破坏性变更检测和依赖影响分析归 P1。

---

## 15. P0 验收标准

| 标准 | 验收方式 |
|---|---|
| Schema 可保存 | draft 写入成功 |
| Schema 可归一化 | children、columns、testId、默认值统一 |
| Analyzer 可阻断 | Error 阻断发布 |
| Schema 可发布 | 无 Error 后生成 published 版本 |
| 版本可查询 | 返回版本历史 |
| 运行态可加载 | RuntimeRenderer 渲染 published 版本 |
| 设计态同源 | 设计态和预览态布局一致 |
| schemaPath 可定位 | Analyzer 问题能打开 Inspector |
| testId 可测试 | Playwright 可定位节点和抓手 |
| RuntimeState 不污染 Schema | 输入值不改变 Schema |
| 性能门禁可执行 | 冷启动、页面加载、拖拽帧率、Schema size 等阈值引用 08 的 PerformanceGate |

---

## 16. 下一步

下一篇文档建议输出：

```text
../08-测试验收与质量门禁/T-207-全新表单设计器-测试验收与质量门禁.md
```

它应定义单元测试、Schema 快照测试、Analyzer 测试、Playwright 自动化测试、视觉回归测试、发布门禁和验收矩阵。
