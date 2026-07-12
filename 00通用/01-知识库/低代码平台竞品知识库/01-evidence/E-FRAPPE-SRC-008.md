---
id: E-FRAPPE-SRC-008
type: evidence
competitor: Frappe
module: workflow
source_channel: github-source
source_type: source-code
source_url: https://github.com/frappe/frappe/blob/develop/frappe/workflow/doctype/workflow_document_state/workflow_document_state.json
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe Workflow Document State 元模型

## 源码定位

- 仓库：`frappe/frappe`
- 文件：`frappe/workflow/doctype/workflow_document_state/workflow_document_state.json`
- 版本：GitHub `develop` 分支，commit `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`，2026-07-05 访问
- 行号：`state` 在 L27，`doc_status` 在 L39，`update_field` 在 L48，`update_value` 在 L55，`allow_edit` 在 L61，`is_optional_state` 在 L87。

## 原始观察

Workflow Document State 将状态名、文档状态、字段更新、允许编辑角色和可选状态建模为字段。

## 证据强度

直接事实。源码 JSON 明确给出 Frappe 工作流状态节点元模型。
