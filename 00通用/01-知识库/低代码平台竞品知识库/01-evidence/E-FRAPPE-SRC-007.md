---
id: E-FRAPPE-SRC-007
type: evidence
competitor: Frappe
module: workflow
source_channel: github-source
source_type: source-code
source_url: https://github.com/frappe/frappe/blob/develop/frappe/workflow/doctype/workflow_transition/workflow_transition.json
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe Workflow Transition 元模型

## 源码定位

- 仓库：`frappe/frappe`
- 文件：`frappe/workflow/doctype/workflow_transition/workflow_transition.json`
- 版本：GitHub `develop` 分支，commit `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`，2026-07-05 访问
- 行号：`state` 在 L24，`action` 在 L34，`next_state` 在 L44，`allowed` 在 L54，`allow_self_approval` 在 L66，`condition` 在 L76。

## 原始观察

Workflow Transition 将来源状态、动作、下一状态、允许角色、自审批开关和条件表达式建模为字段。

## 证据强度

直接事实。源码 JSON 明确给出 Frappe 工作流状态转移元模型。
