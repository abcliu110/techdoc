---
id: UI-NOCOBASE-VIS-002
type: ui
domain_object: FormBuilder
competitors: [NocoBase]
evidence: [E-NOCOBASE-UI-002, E-NOCOBASE-SRC-021, E-NOCOBASE-SRC-022]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [UI-NOCOBASE-SRC-001, DM-NOCOBASE-SRC-001, ADR-LOWCODE-UI-001]
owner: AI
ai_generated: true
---

# NocoBase 表单弹窗与模板拆解

## 页面目标

在列表页上下文中快速完成新增、编辑和查看，减少页面跳转，并让表单字段来自当前 collection。

## 可见界面证据

- 官方教程展示在 Table block 的 Actions 中启用 Add new。
- Add new 打开 popup，popup 内添加 Form (Add new) block，并从当前 collection 选择字段。
- 官方教程展示保存表单模板、在编辑弹窗中复用字段模板，以及表格内快速编辑。

## 页面分区

```text
列表页：Table block + Actions 区
弹窗：Form block + Fields 配置 + Submit 动作
模板：Save as template / Field templates
行内编辑：Table block 或字段级 Quick editing
```

## 隐含规则

- 新增和编辑不是完全独立页面，而是由列表动作触发的上下文表单。
- 字段选择继承 collection 元数据，说明 UI 配置依赖数据模型。
- 模板复用解决同一对象多个表单配置漂移问题。

## 对自研平台的启发

自研平台应把“动作 -> 表单弹窗 -> 字段模板 -> 提交动作”作为一条可配置链路，而不是只保存静态页面 JSON。字段模板应有引用/复制两种语义，引用适合标准表单，复制适合局部差异页面。

## 边界

本卡未验证复杂校验、联动规则、权限差异和工作流触发表单在运行时的表现。
