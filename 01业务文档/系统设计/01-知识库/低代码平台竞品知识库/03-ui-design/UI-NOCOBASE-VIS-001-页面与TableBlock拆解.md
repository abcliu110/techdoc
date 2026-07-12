---
id: UI-NOCOBASE-VIS-001
type: ui
domain_object: PageBuilder
competitors: [NocoBase]
evidence: [E-NOCOBASE-UI-001, E-NOCOBASE-SRC-021, E-NOCOBASE-SRC-022]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [UI-NOCOBASE-SRC-001, ADR-LOWCODE-UI-001]
owner: AI
ai_generated: true
---

# NocoBase 页面与 Table Block 拆解

## 页面目标

让业务配置者把 collection 中的数据快速发布成可操作页面，并通过 block 组合完成列表、筛选和布局调整。

## 可见界面证据

- 官方教程展示 UI Editor、Add menu item、Modern page、Add block、Data blocks -> Table、字段选择、Filter Form、拖拽布局和 tree table 配置。
- 这些证据来自官方文档截图，不是本地运行截图；当前证据强度可支撑页面模式拆解，但不能替代实测。

## 页面分区

```text
顶部：UI Editor / 菜单入口 / 页面入口
左侧：菜单或子页面导航
中间：页面内容区，由 Table、Filter Form 等 block 组成
块内：字段配置、动作配置、排序、过滤、分页
```

## UI 模式

NocoBase 的页面构建核心不是自由拖组件，而是“选择 collection -> 放置 block -> 配置字段与动作 -> 调整块布局”。这更适合企业业务系统，因为列表、筛选、详情等页面形态天然围绕数据对象生成。

## 对自研平台的启发

自研平台页面构建应采用“对象驱动 block”优先：

```text
业务对象
-> 默认列表/详情/表单 block
-> 页面布局编排
-> 动作与权限配置
```

避免首版直接做无限自由画布；自由画布复杂度高，且难以保证权限、字段规则和状态机一致性。

## 边界

本卡补齐可见界面证据，但仍未覆盖本地安装、真实响应行为、复杂页面性能和权限切换后的页面差异。
