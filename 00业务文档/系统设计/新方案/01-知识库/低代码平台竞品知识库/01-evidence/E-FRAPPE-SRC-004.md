---
id: E-FRAPPE-SRC-004
type: evidence
competitor: Frappe
module: workflow
source_channel: github-source
source_type: source-code
source_url: https://github.com/frappe/frappe/blob/develop/frappe/workflow/doctype/workflow/workflow.json
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe Workflow 源码

## 源码定位

- 仓库：`frappe/frappe`
- 文件：`frappe/workflow/doctype/workflow/workflow.json`
- 版本：GitHub `develop` 分支，commit `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`，2026-07-05 访问
- 行号：raw 文件可复核；`states` 在 L79，`states.options = Workflow Document State` 在 L82，`transitions` 在 L92，`transitions.options = Workflow Transition` 在 L95，`workflow_state_field` 在 L100，`workflow_data` 在 L106。

## 原始观察

Workflow 元模型包含：

- `states`：`Table` 字段，`options` 指向 `Workflow Document State`，用于定义所有可能文档状态和角色。
- `transitions`：`Table` 字段，`options` 指向 `Workflow Transition`，用于定义状态转移规则。
- `workflow_state_field`：默认值为 `workflow_state`，表示事务状态字段；若字段不存在，会创建隐藏 Custom Field。
- `workflow_data`：`JSON` 且 hidden。

## 证据强度

直接事实。源码 JSON 明确给出 Workflow 的状态、转移和状态字段模型。
