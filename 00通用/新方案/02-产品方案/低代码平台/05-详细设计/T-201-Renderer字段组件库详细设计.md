# T-201 Renderer 字段组件库详细设计

> 版本：v0.1
> 里程碑：M2
> 适用任务：T-201
> 依据：PRD REQ-020~023、REQ-030~034、REQ-084；`03-设计器与前端设计.md`
> 5A 状态：baseline-approved。`../04-架构决策/UI-and-Component-Decision-Matrix.md` 已人工接受；本设计作为 M2 UI 详细设计基线，禁止提前在 M0/M1 实现。

---

## 1. 目标

实现运行时 renderer 的字段组件库。renderer 只消费服务端 `/meta` 和已发布 page schema，不自行推导权限、不放宽校验。

## 2. 模块边界

| 包 | 职责 |
|---|---|
| `packages/renderer` | 运行态页面渲染、路由、数据提交 |
| `packages/field-registry` | 22 种 field_type 到组件的映射 |
| `packages/shared-schema` | PageSchema、Meta DTO、表达式安全子集类型 |
| `packages/runtime-client` | 统一 POST API、traceId、tenant/app 上下文 |

## 3. FieldRegistry

```ts
type FieldRenderer = {
  typeCode: string;
  display: React.ComponentType<FieldDisplayProps>;
  editor: React.ComponentType<FieldEditorProps>;
  filter?: React.ComponentType<FieldFilterProps>;
  normalizeInput(value: unknown): unknown;
  supportsReadonly: boolean;
  supportsMask: boolean;
};
```

组件注册必须与后端 `FieldTypeHandler.rendererKey()` 一致。

## 4. 22 种字段组件

| 类型 | 编辑组件 | 显示规则 |
|---|---|---|
| text/textarea/code | Input/TextArea/CodeEditor-lite | 长文本截断、tooltip |
| richtext | 安全富文本编辑器 | DOMPurify 白名单渲染 |
| integer/decimal/percent/currency | InputNumber | decimal/currency 禁浮点展示误差 |
| date/datetime/time | DatePicker/TimePicker | 租户时区格式化 |
| select/multiselect/checkbox | Select/Checkbox | option code 显示 label |
| link/user/org | RemoteSelect | suggest 复用 AccessView |
| table | SubTable | 子表行内编辑，提交父子结构 |
| multilink | MultiRemoteSelect | M2 只在后端支持时启用 |
| autonumber | ReadonlyInput | 新增时显示自动生成占位 |
| attachment | AttachmentPicker | 下载预览走签名 URL |
| formula | ReadonlyComputed | 服务端值为准 |

## 5. 权限消费

1. `/meta` 不返回无读权限字段，renderer 不渲染。
2. READ 字段只显示，不提交。
3. WRITE 字段可编辑。
4. MASKED 字段显示脱敏值，编辑取决于服务端 meta。
5. 前端隐藏字段不代表免校验。

## 6. 安全

1. richtext 必须做 XSS 白名单。
2. code 字段不执行，只展示/编辑文本。
3. attachment 下载使用一次性签名 URL，不暴露真实路径。
4. 所有提交携带 requestMetaHash。
5. API 错误按字段 path 展示，不展示堆栈和 SQL。

## 7. 验收

1. 22 种字段均能渲染 display/editor。
2. 无读权限字段不出现在页面和提交 payload。
3. 只读字段无法编辑，恶意手工提交被后端拒绝并前端显示字段错误。
4. richtext XSS 用例不执行脚本。
5. link suggest 不泄露无权限目标记录。

## 8. 5A 门禁补齐

### 8.1 需求引用

| requirementId | storyId | 承接说明 |
|---|---|---|
| REQ-020~REQ-023 | US-UI-001、US-RUNTIME-001 | 默认页面、PageSchema、renderer 唯一元数据来源、运行时 schema 校验 |
| REQ-030~REQ-034 | US-PERM-001 | 租户隔离、对象/字段/动作权限、masked、break-glass 边界 |
| REQ-084 | US-OPS-001 | 指标、日志、错误展示和导出/附件最小化脱敏 |

### 8.2 ADR 与决策矩阵引用

| 来源 | 承接行 |
|---|---|
| `../04-架构决策/UI-and-Component-Decision-Matrix.md` | 组件库策略、字段组件状态模型、可访问性基线、发布与运行时集成 |
| `../04-架构决策/Permission-Model-Decision-Matrix.md` | 字段权限与脱敏、UI 权限消费 |
| `../04-架构决策/Data-Model-Decision-Matrix.md` | 字段类型与物理列映射 |
| `../04-架构决策/ADR/ADR-LOWCODE-PERM-001-access-view-permission-core.md` | AccessView 字段权限 |
| `../04-架构决策/ADR/ADR-LOWCODE-FIELDTYPE-SPI-001-field-type-handler-spi.md` | FieldTypeHandler 与 rendererKey 一致性 |

### 8.3 UI 设计系统对照

| 项 | 决策 |
|---|---|
| 设计系统 | AntD 5 作为视觉和基础交互底座 |
| 平台封装 | 字段组件必须通过 `FieldRenderer` 接口封装，不允许业务页面直接拼 AntD 字段组件绕过权限状态 |
| 偏离说明 | richtext、code、attachment、subtable、link suggest 允许平台封装专用组件；偏离 AntD 默认行为时必须保留键盘路径和错误关联 |

### 8.4 可访问性规则

| 规则 | 验收方式 |
|---|---|
| WCAG 2.2 AA：字段 label、错误、帮助文本必须可感知 | 表单控件通过 `aria-describedby` 关联错误和提示 |
| WAI-ARIA APG：combobox/listbox/dialog/table 按对应模式实现 | link/user/org suggest、附件弹窗、子表行编辑覆盖键盘路径 |
| 键盘可达 | 不使用鼠标可完成字段输入、错误定位、附件选择和子表增删 |
| 焦点恢复 | 弹窗关闭、提交失败、版本冲突后焦点回到触发控件或首个错误字段 |

### 8.5 状态组合

| 权限状态 | 数据状态 | 交互状态 | 组件行为 |
|---|---|---|---|
| NONE | any | any | 不渲染、不提交、不在错误中泄露字段名以外敏感值 |
| MASKED | clean/dirty | idle/loading | 显示脱敏值；是否允许编辑只按服务端 meta 的 write 能力 |
| READ | clean/stale/error | idle/loading/conflict | 只读展示；提交 payload 排除字段 |
| WRITE | empty/dirty/error | idle/loading/submitting/conflict | 可编辑；提交携带 requestMetaHash；冲突时保留用户输入并要求刷新 |

### 8.6 失败模式

| 失败模式 | 处置 |
|---|---|
| 字段类型无注册组件 | 渲染阻断该字段并记录 telemetry，发布前由 PageSchema 校验阻断 |
| Schema 与 field_type 不兼容 | 发布前阻断；运行态遇到旧 schema 时进入兼容降级提示 |
| 权限裁剪冲突 | 以服务端 `/meta` 为准，前端不得显示或提交无权限字段 |
| richtext/code XSS | richtext 白名单清洗；code 只作文本，不执行 |
| link suggest 泄露目标记录 | suggest API 复用 AccessView；前端不缓存跨租户候选 |

### 8.7 5.0 自检

| 检查项 | 结果 |
|---|---|
| 完整性 | 已补需求引用、ADR/矩阵引用、设计系统、可访问性、状态组合、失败模式 |
| 一致性 | 与 UI 决策矩阵的 Thin Wrapper + Field Capability Contract 一致 |
| 可测试性 | 已映射到字段组件、XSS、权限裁剪、键盘路径和版本冲突测试 |
| 可追溯性 | 需由 CapabilityTraceMatrix 登记 T-201 与 UI 矩阵关系 |
