---
id: NFR-FRAPPE-SRC-001
type: nfr
domain_object: FrappeExtensionSite
competitors: [Frappe]
evidence: [E-FRAPPE-SRC-009, E-FRAPPE-SRC-010]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [NFR-LOWCODE-001]
owner: AI
ai_generated: true
---

# Frappe Hooks 与 Site 机制

## 源码依据

- `frappe/hooks.py`
- `frappe/commands/site.py`

## 扩展机制

Frappe hooks.py 暴露：

```text
doctype_js
permission_query_conditions
has_permission
doc_events
scheduler_events
override_whitelisted_methods
```

这说明 Frappe 的扩展点覆盖前端脚本、权限、文档事件、定时任务和 API 方法覆盖。

## Site 机制

`site.py` 显示 Frappe 以 site 为运维单位，支持：

```text
new-site
install-app
list-apps
migrate
use
backup
restore
drop-site
```

多个命令会遍历 `context.sites` 并调用 `frappe.init(site)`。

## 对自研平台的启发

正式商用低代码平台至少需要：

```text
应用级 hooks
对象级事件 hooks
权限 hooks
定时任务 hooks
API 覆盖/扩展机制
租户/站点级初始化
站点级迁移
站点级备份恢复
站点级应用安装
```

## 边界

本卡不等同于完整多租户实现验证，只证明 Frappe 源码存在 site 级运维和 hooks 扩展机制。
