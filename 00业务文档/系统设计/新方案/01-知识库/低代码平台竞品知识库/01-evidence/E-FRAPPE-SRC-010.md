---
id: E-FRAPPE-SRC-010
type: evidence
competitor: Frappe
module: tenancy-migration
source_channel: github-source
source_type: source-code
source_url: https://github.com/frappe/frappe/blob/develop/frappe/commands/site.py
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Frappe site 命令与多站点运维

## 源码定位

- 仓库：`frappe/frappe`
- 文件：`frappe/commands/site.py`
- 版本：GitHub `develop` 分支，commit `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`，2026-07-05 访问
- 行号：`new-site` 命令在 L18-L19，`new_site()` 在 L73，`_new_site()` 调用在 L131，`install-app` 在 L513/L517，`migrate` 在 L719-L732，`use(site)` 在 L814-L828，`drop-site` 在 L1017/L1037，backup 在 L833 之后。

## 原始观察

Frappe CLI 以 site 为运维单位，支持 new-site、restore、install-app、list-apps、migrate、use、backup、drop-site 等命令。多个命令按 context.sites 遍历并调用 `frappe.init(site)`。

## 证据强度

直接事实。源码明确给出 Frappe site 级创建、安装应用、迁移、备份和删除能力。
