---
id: E-FRAPPE-SRC-002
type: evidence
competitor: Frappe
module: data-model
source_channel: github-source
source_type: source-code
source_url: https://github.com/frappe/frappe/blob/develop/frappe/core/doctype/docfield/docfield.json
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe DocField 源码

## 源码定位

- 仓库：`frappe/frappe`
- 文件：`frappe/core/doctype/docfield/docfield.json`
- 版本：GitHub `develop` 分支，commit `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`，2026-07-05 访问
- 行号：raw 文件可复核；`fieldtype` 在 L110，`fieldname` 在 L122，`reqd` 在 L133，`options` 在 L237，`fetch_from` 在 L255，`depends_on` 在 L272。

## 原始观察

`docfield.json` 定义字段元模型：

- `label` 是 `Data` 字段。
- `fieldtype` 是必填 `Select`，其 `options` 列出大量字段类型，包括 `Data`、`Date`、`Datetime`、`Dynamic Link`、`Link`、`Table`、`Table MultiSelect`、`JSON`、`Code`、`Read Only` 等。
- `fieldname` 是 `Data` 字段。
- `reqd` 是 `Check` 字段，用于必填。
- `options` 是 `Small Text`，用于字段选项。
- `default` 是 `Small Text`。
- `fetch_from` 是 `Small Text`，用于字段带出。
- `depends_on` 是 `Code`，用于依赖条件。

## 证据强度

直接事实。源码 JSON 明确给出 DocField 的字段类型、选项、默认值、字段带出和依赖条件。
