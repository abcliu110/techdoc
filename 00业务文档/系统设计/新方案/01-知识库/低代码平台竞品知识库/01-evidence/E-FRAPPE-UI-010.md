---
id: E-FRAPPE-UI-010
type: evidence
competitor: Frappe
module: customization-export
source_channel: official-doc
source_type: screenshot
source_url: https://docs.frappe.io/framework/user/en/guides/app-development/exporting-customizations
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe Export Customizations 可见界面

## 原始观察

Frappe Exporting Customizations 文档说明在 Customize Form 中可点击 Export Customizations，选择 module，并把 Custom Fields 与 Property Setters 导出到 app 的 custom 目录；后续 bench update 或 bench migrate 会同步。

## 可抽取知识

- Frappe 的元数据变更可导出为应用资产，并通过 migrate 同步。
- 自研平台需要设计元数据版本化、导出、迁移和环境同步能力。
