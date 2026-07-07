---
id: UI-FRAPPE-VIS-008
type: ui
domain_object: DocTypeDesigner
competitors: [Frappe]
evidence: [E-FRAPPE-UI-008, E-FRAPPE-SRC-001, E-FRAPPE-SRC-002]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [DM-FRAPPE-SRC-001, DM-FRAPPE-SRC-002, PM-FRAPPE-SRC-002]
owner: AI
ai_generated: true
---

# Frappe DocType Features 拆解

## 页面目标

在 DocType 设计界面中集中配置字段、布局、表单设置、权限规则和展示字段。

## 页面分区

```text
Fields
Form Layout
Form Settings
Permission Rules
Title / Image Field
```

## 设计启发

自研平台对象设计器不应只维护数据库字段，还要把布局、标题字段、展示字段、权限规则纳入对象设计生命周期。

## 边界

尚未验证复杂字段、命名规则和迁移后的 DocType 差异。
