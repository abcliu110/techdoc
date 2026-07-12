---
id: UI-FRAPPE-VIS-006
type: ui
domain_object: WebFormLayout
competitors: [Frappe]
evidence: [E-FRAPPE-UI-006]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [UI-FRAPPE-VIS-005]
owner: AI
ai_generated: true
---

# Frappe Web Form 多步骤与布局拆解

## 页面目标

治理长表单输入体验，通过 Page Break、Section Break、Column Break 等布局控制把表单拆成易填写步骤。

## 页面分区

```text
字段布局
Section / Column / Page Break
步骤导航
提交按钮文案
Banner / Breadcrumbs
```

## 设计启发

自研平台表单模型应支持多步骤表单，并把步骤、分组、列布局作为元数据，而不是仅靠前端代码硬写。

## 边界

尚未验证多步骤表单的校验时机、保存草稿和移动端体验。
