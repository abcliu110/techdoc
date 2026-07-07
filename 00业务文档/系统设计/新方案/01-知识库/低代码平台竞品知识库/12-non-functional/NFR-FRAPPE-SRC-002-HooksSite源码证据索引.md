---
id: NFR-FRAPPE-SRC-002
type: non-functional
domain_object: FrappeHooksSiteSourceIndex
competitors: [Frappe]
evidence: [E-FRAPPE-SRC-094, E-FRAPPE-SRC-095, E-FRAPPE-SRC-096, E-FRAPPE-SRC-097, E-FRAPPE-SRC-098, E-FRAPPE-SRC-099, E-FRAPPE-SRC-100, E-FRAPPE-SRC-101, E-FRAPPE-SRC-102, E-FRAPPE-SRC-103, E-FRAPPE-SRC-104, E-FRAPPE-SRC-105, E-FRAPPE-SRC-106, E-FRAPPE-SRC-107, E-FRAPPE-SRC-108, E-FRAPPE-SRC-109, E-FRAPPE-SRC-110, E-FRAPPE-SRC-111, E-FRAPPE-SRC-112, E-FRAPPE-SRC-113]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [NFR-FRAPPE-SRC-001]
owner: AI
ai_generated: true
---

# Frappe Hooks/Site 源码证据索引

## 结论

Frappe 扩展机制由 hooks.py 和 site 命令共同支撑。hooks.py 暴露 permission_query_conditions、has_permission、doc_events、scheduler_events、override_whitelisted_methods、jinja 等扩展点；site.py 暴露 new-site、install-app、migrate、backup、drop-site、use 等多站点与应用生命周期命令。

## 源码证据范围

```text
E-FRAPPE-SRC-094..113
hooks.py: app metadata and extension hooks
site.py: site lifecycle, install app, migrate, backup, drop site
```

## 对自研平台的启发

商用平台需要把扩展机制和运维生命周期一起设计：

```text
HookRegistry
DocEventHook
PermissionHook
SchedulerHook
SiteLifecycle
AppInstall
Migration
Backup
TenantSwitch
```
