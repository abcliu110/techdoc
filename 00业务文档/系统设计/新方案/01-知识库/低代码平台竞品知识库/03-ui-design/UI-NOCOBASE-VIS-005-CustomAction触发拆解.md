---
id: UI-NOCOBASE-VIS-005
type: ui
domain_object: ActionWorkflow
competitors: [NocoBase]
evidence: [E-NOCOBASE-UI-005, E-NOCOBASE-SRC-061, E-NOCOBASE-SRC-062]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [SM-NOCOBASE-SRC-001, ADR-LOWCODE-UI-001]
owner: AI
ai_generated: true
---

# NocoBase Custom Action Event 拆解

## 页面目标

把页面按钮升级为业务命令，让按钮点击可以触发 workflow，而不只是提交表单或跳转页面。

## 页面分区

```text
Workflow trigger：Custom Action Event
页面 block：Trigger Workflow 按钮
按钮配置：绑定目标 workflow
运行时：用户点击按钮触发流程
```

## 设计启发

自研平台动作模型必须独立于 UI 按钮：

```text
Action
-> Button binding
-> Permission check
-> Workflow trigger
-> Audit log
```

这样才能支持审批、状态变更、批量动作和自动化流程。

## 边界

尚未验证按钮触发后的运行时参数、权限拦截和失败重试行为。
