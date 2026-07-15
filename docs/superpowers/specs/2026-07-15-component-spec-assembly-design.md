# 控件规范 Schema 装配体系设计

> 状态：已批准进入 Shadow 试点（2026-07-15）
>
> 试点范围：`02:data-grid`
>
> 约束：不新增依赖；不覆盖现有权威规范；试点通过前 `implementationAllowed=false`

## 1. 目标

建立一套规范化、可读、可组合、可校验的控件规范体系：

```text
公共元 Schema
  + 类别 Profile
  + 能力 Profile
  + 控件装配清单
  = 控件有效 Schema
      -> 校验控件规范实例
      -> 校验规范内部语义
      -> 校验组件 SOP 引用
      -> 生成可读说明与追踪矩阵
```

本体系解决两个问题：

1. 309 个组件共享同一种规范语言，不分别发明 Schema。
2. 组件 SOP 通过语义路径引用规范，不复制 API、状态、视觉结果和质量阈值，防止规范变化后发生术语漂移。

## 2. 核心决策

### 2.1 权威格式采用 JSON

权威元 Schema、Profile、装配清单和规范实例全部使用格式化 JSON。

原因：

- JSON 是 JSON Schema 2020-12 的原生实例格式。
- 当前目录的维护工具已经使用 Node 标准库读取 JSON。
- 仓库没有可复用 YAML 解析器或 JSON Schema 验证库。
- 工作区规则禁止未经明确授权增加依赖。
- JSON Pointer 可以直接、无歧义地引用实例路径。

YAML 不是数据模型的一部分。后续若需要 YAML 编辑体验，只增加 JSON/YAML 转换层，不改变 Schema、语义路径和校验器。

### 2.2 不创建人工编号语言

有名称的对象使用语义键映射：

```text
/api/props/data
/api/events/rowSelectionChange
/behavior/states/errorRefresh
/view/statePresentation/errorRefresh
/quality/oracles/selectionStableAfterSort
```

只对本来就需要稳定业务标识的数组项保留 `id`，例如异常流程和状态转换。不得再增加 `API-DG-01` 这类与对象名称重复的人工编号。

### 2.3 Profile 只施加约束，不生成答案

Profile 可以规定：

- 必须出现哪些规范区域。
- 某项能力至少需要哪些 API 槽位、状态、界面状态和 oracle。
- 风险最低等级和审批角色。
- 必须通过哪些语义关系校验。

Profile 不得生成：

- 最终 TypeScript API 类型。
- 具体错误恢复结果。
- 界面区域顺序和视觉尺寸。
- 性能预算数值。
- 服务端职责和审批结果。

这些答案只能由单组件规范实例给出并经过评审。

### 2.4 试点并行，不原地升级

现有 `component-spec.schema.json` 和 5 份候选规范继续作为 v1 权威输入。v2 试点存放在独立目录，直到全部迁移门禁通过：

- v2 元 Schema 和 Profile 自检通过。
- DataGrid v2 实例通过结构与语义校验。
- SOP 引用校验能重现并阻断旧 `rows/querySnapshot/onSelectionChange` 漂移。
- 从 v2 生成的可读说明经过人工复核。
- v1 到 v2 的差异报告完整。
- DataGrid v2 获得规定角色审批。

试点通过后才把 DataGrid 权威入口切换到 v2；其余 4 份候选规范不自动迁移。

## 3. 目录结构

```text
04-机器索引与Schema/
  v2/
    core/
      component-spec.schema.json
      implementation-sop.schema.json
    profiles/
      categories/
        table.profile.json
      capabilities/
        sorting.profile.json
        filtering.profile.json
        row-selection.profile.json
        pagination.profile.json
        column-pinning.profile.json
        column-sizing.profile.json
    assemblies/
      02-data-grid.assembly.json
    effective-schemas/
      02-data-grid.schema.json
    reference-catalogs/
      02-data-grid.references.json

02-组件规范/
  v2-candidates/
    02-表格类/
      02-data-grid.spec.json
      02-data-grid.generated.md
      02-data-grid.traceability.json

03-生产SOP/
  组件实施SOP-v2-candidates/
    02-data-grid.implementation-sop.json
    02-data-grid.generated.md

06-维护工具/
  spec-assembly/
    assemble-effective-schema.mjs
    validate-spec-instance.mjs
    validate-spec-semantics.mjs
    validate-sop-references.mjs
    render-spec-markdown.mjs
    build-reference-catalog.mjs
    *.test.mjs
```

`effective-schemas/`、`reference-catalogs/` 和 `*.generated.md` 是派生产物；只能由工具重建，不人工编辑。权威输入是 core、profiles、assemblies、规范实例和 SOP 实例。

## 4. 公共元 Schema

公共元 Schema 使用 JSON Schema Draft 2020-12，顶层固定为：

```json
{
  "schemaVersion": 2,
  "specificationVersion": "0.3.0",
  "component": {},
  "lifecycle": {},
  "scope": {},
  "api": {},
  "behavior": {},
  "view": {},
  "accessibility": {},
  "quality": {},
  "security": {},
  "compatibility": {},
  "risk": {},
  "decisions": [],
  "approval": {}
}
```

规范化规则：

- `additionalProperties:false` 用于固定契约对象，防止拼写错误静默进入。
- `props`、`events`、`states`、`regions`、`statePresentation`、`oracles` 使用语义键对象。
- `transitions`、`exceptionFlows`、`decisions`、审批记录使用数组，因为顺序或多实例有意义。
- 数值预算使用 `{operator,value,unit,fixture}`，不得埋入自然语言。
- 描述、原因、边界和 oracle 的 Given/When/Then 保留自然语言。

## 5. Profile 结构

类别和能力 Profile 使用统一结构：

```json
{
  "profileVersion": 1,
  "profileKey": "capability:row-selection",
  "appliesTo": "component-spec-v2",
  "constraints": {
    "requiredPointers": [],
    "requiredImplementationPointers": [],
    "requiredSemanticChecks": [],
    "minimumRisk": "R2",
    "requiredApprovalRoles": []
  }
}
```

表格类别 Profile 至少要求：

```text
/behavior/identity/row
/behavior/identity/column
/view/regions/header
/view/regions/body
/accessibility/keyboardModel
/quality/scaleFixtures
```

`row-selection` 能力 Profile 至少要求：

```text
/api/features/rowSelection
/view/statePresentation/ready
/quality/oracles/selectionStableAfterSort
semantic check: selection-is-bound-to-row-identity
```

Profile 的 `requiredPointers` 只说明槽位必须存在，不复制槽位的具体内容。

Profile 的 `requiredImplementationPointers` 只列出必须由 SOP `implements` 覆盖的规范路径；它不复制实现步骤，也不替代 oracle 的 `verifies` 覆盖。

## 6. 装配清单

DataGrid 装配清单只表达采用哪些 Profile：

```json
{
  "assemblyVersion": 1,
  "componentKey": "02:data-grid",
  "coreSchema": "../core/component-spec.schema.json",
  "profiles": [
    "../profiles/categories/table.profile.json",
    "../profiles/capabilities/sorting.profile.json",
    "../profiles/capabilities/filtering.profile.json",
    "../profiles/capabilities/row-selection.profile.json",
    "../profiles/capabilities/pagination.profile.json",
    "../profiles/capabilities/column-pinning.profile.json",
    "../profiles/capabilities/column-sizing.profile.json"
  ],
  "dataModes": ["local", "remote-page"]
}
```

装配器必须拒绝：

- 重复 Profile。
- 不存在或越出 v2 根目录的 `$ref`。
- Profile key 与文件声明不一致。
- 互斥能力组合。
- Profile 要求互相矛盾的最低风险或字段类型。

## 7. 有效 Schema 生成

因为 Profile 表达的是 required pointer 和语义检查，而不重复完整 JSON Schema，装配器生成：

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "effective/02-data-grid.schema.json",
  "allOf": [
    { "$ref": "../core/component-spec.schema.json" }
  ],
  "x-component-key": "02:data-grid",
  "x-applied-profiles": [],
  "x-required-pointers": [],
  "x-required-implementation-pointers": [],
  "x-required-semantic-checks": [],
  "x-minimum-risk": "R2",
  "x-required-approval-roles": []
}
```

`allOf/$ref` 保持标准 JSON Schema 组合；`x-*` 是项目注解，由语义校验器读取，不改变标准校验器行为。

输出必须稳定排序，重复运行产生字节完全相同的文件。生成器不得修改 core、Profile、装配清单和组件规范实例。

## 8. 结构与语义校验分工

### 8.1 结构校验

结构校验负责：

- 类型、必填、枚举、格式和额外字段。
- Profile 要求的 pointer 是否存在。
- 组件 key、版本和风险格式。

当前仓库无 JSON Schema 验证依赖，因此第一阶段实现一个明确受限的验证器，只支持本项目实际使用的 Draft 2020-12 关键字：

```text
type, required, properties, additionalProperties,
items, minItems, uniqueItems, enum, const, pattern,
minLength, minimum, allOf, $ref
```

它不是通用 JSON Schema 实现。元 Schema 必须声明 `x-supported-keywords`；发现未支持关键字时直接失败，禁止静默忽略。未来接入标准验证库时，使用相同测试夹具做一致性验证后替换。

### 8.2 语义校验

语义校验器负责 JSON Schema 不适合表达的关系：

- transition 的 `from/to` 必须存在于 states。
- exception flow 的状态、区域和恢复动作必须存在。
- oracle 引用的 API、状态、区域和异常必须存在。
- 每个用户可见状态必须有 `statePresentation`。
- `statePresentation` 引用的区域必须存在于 regions。
- Profile 要求的 semantic check 必须有注册实现且通过。
- R2/R3 的审批角色满足风险要求。

语义校验器输出稳定的问题代码、JSON Pointer 和消息，不只输出自由文本。

## 9. SOP 结构与引用

正式 SOP 实例采用结构化 JSON，生成 Markdown 给人阅读：

```json
{
  "sopVersion": "0.2.0",
  "componentKey": "02:data-grid",
  "specification": {
    "path": "../../02-组件规范/v2-candidates/02-表格类/02-data-grid.spec.json",
    "version": "0.3.0",
    "digest": "sha256:<generated>"
  },
  "steps": [
    {
      "key": "rowSelection",
      "action": "implement-and-verify",
      "implements": ["/api/features/rowSelection"],
      "verifies": ["/quality/oracles/selectionStableAfterSort"],
      "evidenceKinds": ["red-output", "green-output", "interaction-test"]
    }
  ]
}
```

SOP 的自由文本只描述操作方法和顺序。以下内容禁止出现在 SOP 权威实例中：

- TypeScript 类型签名。
- API payload 定义。
- 状态结果定义。
- 性能预算值。
- 视觉尺寸和令牌值。
- Given/When/Then 验收结论。

这些内容通过 JSON Pointer 从组件规范读取。

## 10. SOP 跨引用校验

引用校验器执行：

1. 规范路径只能位于 `02-组件规范/v2-candidates/`。
2. `componentKey` 和版本必须与规范实例一致。
3. 规范规范化序列化后的 SHA-256 必须匹配 `digest`。
4. 每个 `implements` 和 `verifies` 必须是有效 JSON Pointer。
5. `implements` 只能指向允许的规范分区。
6. 每个强制 oracle 必须被至少一个 SOP step 覆盖。
7. 每个 Profile 强制实施路径必须被至少一个 SOP step 的 `implements` 覆盖。
8. 规范 digest 变化后 SOP 状态为 `Stale`，不得批准或实施。
9. SOP 批准记录必须绑定 SOP 内容 digest、SOP 版本、规范版本和规范 digest；作者不得批准自己的 SOP。

必须包含以下防复发夹具：

- 删除 `/api/props/data` 后引用失败。
- 把 `rowSelectionChange` 政名后引用失败。
- 把规范从 `querySnapshot` 改成 `queryId` 后，SOP 不存在旧文本副本可漂移。
- 修改性能预算后只导致 digest 变化和对应测量步骤重新复核，不需要在 SOP 搜索旧数值。

## 11. 派生产物

### 11.1 引用目录

`02-data-grid.references.json` 包含：

```json
{
  "componentKey": "02:data-grid",
  "specificationVersion": "0.3.0",
  "digest": "sha256:...",
  "pointers": [
    "/api/props/data",
    "/behavior/states/errorRefresh",
    "/quality/oracles/selectionStableAfterSort"
  ]
}
```

### 11.2 可读 Markdown

规范说明按固定章节生成：范围、API、行为状态机、界面结构、状态视图、无障碍、质量预算、异常、oracle、风险和审批。生成内容标记“请勿手工编辑”，并显示源文件、版本和 digest。

### 11.3 追踪矩阵

追踪矩阵记录：

```text
规范 pointer -> SOP step -> oracle -> evidence kind
```

缺少 SOP 步骤、oracle 或证据类型的强制要求必须阻断准入。

## 12. DataGrid v2 界面规范最低内容

DataGrid 试点不能只迁移现有行为字段，必须补齐：

```text
view.regions
  toolbar, header, body, status, pagination

view.layout
  region order, scroll owner, sticky regions,
  column sizing, row/header height ranges

view.statePresentation
  loadingInitial, ready, empty, refreshing,
  errorInitial, errorRefresh

view.tokens
  surface, border, text, muted text, selection,
  focus ring, spacing, density and motion semantics

view.responsive
  390, 768, 1280, 1440 and adjacent-width behavior

quality.visualOracles
  alignment, reachability, clipping, state retention,
  fixed-column boundary and focus visibility
```

具体设计值由 DataGrid 规范作者和 UX/无障碍评审者确认，Profile 只保证这些区域不可缺失。

## 13. 生命周期与准入

v2 分开记录：

```text
specificationStatus: Draft | ReviewReady | Frozen
sopStatus: Missing | Draft | ReviewReady | Approved | Stale
referenceStatus: NotRun | Passed | Failed
planStatus: Unbound | Bound
```

只有同时满足以下条件才允许生产实现：

```text
specificationStatus = Frozen
sopStatus = Approved
referenceStatus = Passed
planStatus = Bound
规范和 SOP 审批绑定当前版本与 digest
无未决事项
```

DataGrid v2 试点完成前，现有索引仍保持 `implementationAllowed=false`。

## 14. 测试策略

每个工具严格执行 RED/GREEN：

1. 先建立最小失败夹具并确认因目标能力缺失而失败。
2. 实现使该夹具通过的最小代码。
3. 运行当前 38 项规范变异/准入判断、12 项基线合同断言和 14 项分层 SOP 合同断言，保证 v1 不回归。
4. 每种错误至少有一个问题代码断言。
5. 生成器执行两次并比较字节，证明确定性。
6. 修改一项规范输入，确认只重建预期派生产物。
7. 任何工具不得覆盖权威输入文件。

## 15. 迁移与回滚

迁移分三步：

1. `Shadow`：v1 权威，v2 并行生成和校验，不参与准入。
2. `Candidate`：DataGrid v2 完成审批，索引同时显示 v1/v2 差异，仍不允许实现。
3. `Authoritative`：人工批准切换，索引仅将 DataGrid 指向 v2；保留 v1 历史快照。

回滚只需将 DataGrid 索引入口切回 v1 并撤销 v2 准入，不删除 v2 输入和失败证据。其余组件不受 DataGrid 试点切换影响。

## 16. 非目标

- 不在本阶段迁移 309 个组件。
- 不生成最终 API、视觉、业务不变量或审批答案。
- 不实现通用 YAML 解析器。
- 不实现完整 JSON Schema 标准。
- 不把派生 Markdown 作为权威输入。
- 不开始 React DataGrid 生产代码。

## 17. 验收标准

设计实施完成时必须证明：

1. DataGrid 有效 Schema 可由相同输入确定性重建。
2. DataGrid v2 规范结构、语义和界面完整性校验通过。
3. SOP 只包含操作和 JSON Pointer，不重复规范答案。
4. 删除、重命名或改变被引用规范对象时，引用校验稳定失败。
5. 规范 digest 变化时，SOP 自动成为 `Stale`。
6. 可读 Markdown 和追踪矩阵由权威输入生成且可重复。
7. v1 全部回归通过，其他 4 份候选规范和 304 项 Backlog 状态不变。
8. DataGrid 在获得独立审批和绑定实际 React 仓库前仍不允许编码。
