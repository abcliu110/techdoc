# T-205 页面 Schema 编辑与布局覆盖详细设计

> 版本：v0.1
> 里程碑：M2
> 适用任务：T-205
> 依据：PRD REQ-020~023、REQ-077、REQ-088；`03-设计器与前端设计.md`
> 5A 状态：baseline-approved。`../04-架构决策/UI-and-Component-Decision-Matrix.md` 已人工接受；本设计作为 M2 UI 详细设计基线，禁止提前在 M0/M1 实现。

---

## 1. 目标

允许设计者在不改变业务语义的前提下覆盖默认页面布局。页面 schema 只能收紧展示，不能放宽权限、校验、状态机和数据范围。

## 2. Schema 版本

```text
schemaVersion: page-schema-v1
viewType: list/form/detail/custom
bindObject
layout
actions
metadata
```

所有 schema 随 Version.snapshot 发布。

## 3. 可编辑能力

| 能力 | 边界 |
|---|---|
| 字段排序 | 只能引用存在字段 |
| 分组/分栏 | 只影响布局 |
| 隐藏字段 | 只能收紧展示 |
| 只读覆盖 | 只能收紧为只读 |
| 列表列 | 只能选择有读权限字段 |
| 筛选项 | 字段必须 in_filter 且可读 |
| 行/批量动作 | 动作必须存在且有权限 |
| 自定义区块 | M2 限内置 Block，不开放远程代码 |

## 4. 校验

保存草稿时返回 warning；发布必须阻断：

```text
引用不存在字段
引用不存在动作
字段类型与组件不匹配
无权限字段被强制显示
readonlyOverride 放宽后端只读
custom block 引用未启用插件
schemaVersion 不支持
```

## 5. 菜单/门户/移动端/i18n 边界

页面 schema 不承载导航和多端入口。菜单、门户、移动端和 i18n 使用独立元数据对象：

```text
Menu
PortalEntry
MobileView
I18nResource
```

M2 只实现 Menu/I18n 的最小编辑入口，Portal/Mobile 进入 T-310。

## 6. 验收

1. 表单可配置分组、分栏、字段顺序。
2. 悬空字段发布阻断。
3. 页面隐藏必填字段后，后端仍按规则校验。
4. 页面不能把无写权限字段改成可编辑。
5. 菜单权限不写入 PageSchema。

## 7. 5A 门禁补齐

### 7.1 需求引用

| requirementId | storyId | 承接说明 |
|---|---|---|
| REQ-020~REQ-023 | US-UI-001、US-RUNTIME-001 | 页面 schema 只覆盖展示和布局，不能放宽权限与校验 |
| REQ-077 | US-UI-001 | 菜单、门户、移动端、i18n 独立元数据边界 |
| REQ-088 | US-PACKAGE-001 | PageSchema 版本升级、兼容等级和回放测试 |

### 7.2 ADR 与决策矩阵引用

| 来源 | 承接行 |
|---|---|
| `../04-架构决策/UI-and-Component-Decision-Matrix.md` | 页面 Schema 协议、默认页面策略、发布与运行时集成 |
| `../04-架构决策/Permission-Model-Decision-Matrix.md` | UI 权限消费、字段权限与脱敏 |
| `../04-架构决策/Data-Model-Decision-Matrix.md` | 数据迁移与兼容升级 |

### 7.3 UI 设计系统对照

页面 Schema 编辑器采用区块/字段直接操纵 + 右侧属性面板；布局控件使用 AntD Form、Tree、Tabs、Drawer 组合。任何自定义区块都必须通过平台组件注册，不允许直接嵌入远程代码。

### 7.4 可访问性规则

| 规则 | 验收方式 |
|---|---|
| 拖拽有键盘替代 | 字段排序、分组、分栏可通过列表操作完成 |
| 属性面板可读 | 当前选中区块/字段通过标题和 aria-describedby 说明 |
| 隐藏/只读覆盖可解释 | 明确提示“只能收紧展示，不能放宽服务端权限” |
| 发布错误可定位 | 悬空字段、动作、组件、schemaVersion 错误能定位到 schema path |

### 7.5 状态组合

| 权限状态 | 数据状态 | 交互状态 | Schema 编辑行为 |
|---|---|---|---|
| design none | any | any | 不允许编辑 schema |
| design read | published | idle | 只读预览 schema 和运行态效果 |
| design write | draft/dirty/error | editing/submitting | 可编辑草稿，保存 warning，发布 blocking |
| runtime stale | stale/conflict | conflict | renderer 要求刷新 schema 并保留用户输入 |

### 7.6 失败模式

| 失败模式 | 处置 |
|---|---|
| 引用不存在字段/动作/组件 | 发布前阻断并定位 schema path |
| 页面试图放宽权限 | 发布前阻断；运行态仍以 `/meta` 为准 |
| schemaVersion 不支持 | 阻断发布或走升级器；旧版本必须有回放测试 |
| 菜单/门户/移动端/i18n 塞入 PageSchema | 阻断并要求迁移到独立元数据对象 |
| 自定义区块引用未启用插件 | 阻断发布；插件禁用后页面进入兼容提示 |

### 7.7 5.0 自检

| 检查项 | 结果 |
|---|---|
| 完整性 | 已补需求引用、ADR/矩阵引用、设计系统、可访问性、状态组合、失败模式 |
| 一致性 | 与自研精简 Schema + 兼容层预留决策一致 |
| 可测试性 | 已映射到 schema 校验、回放、权限收紧和键盘替代测试 |
| 可追溯性 | 需由 CapabilityTraceMatrix 登记 T-205 与矩阵关系 |
