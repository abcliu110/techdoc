---
id: PM-FRAPPE-SRC-001
type: permission
domain_object: FrappePermission
competitors: [Frappe]
evidence: [E-FRAPPE-SRC-003]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [PM-LOWCODE-001, ADR-LOWCODE-PERM-001]
owner: AI
ai_generated: true
---

# Frappe 权限判定链路

## 源码依据

- 仓库：`frappe/frappe`
- 分支与 commit：`develop` / `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`
- 文件：`frappe/permissions.py`
- 可复核行号：
  - `has_permission()`：L80
  - `get_doc_permissions()`：L227
  - controller 权限检查：L237、L481
  - user permission 检查：L264、L351

## 源码观察

Frappe 的权限入口不是单一 RBAC 表判断，而是组合链路：

```text
doctype / ptype / doc / user / parent_doctype
-> 文档 meta
-> owner 判断
-> controller permission check
-> role permission
-> user permission
-> share / doc 级权限语义
```

`has_permission()` 支持只传 doctype 的类型级判断，也支持传入具体 doc 的文档级判断。

## 抽象结论

企业业务低代码平台的权限至少要分三层：

```text
类型级：某角色是否能读写某类业务对象
实例级：某用户是否能操作某一条业务记录
控制器级：业务代码是否追加特殊规则
```

仅靠“应用角色 + 菜单权限”无法覆盖 Frappe 这类业务系统框架的权限复杂度。

## 对自研平台的启发

自研平台权限内核建议按顺序组合：

```text
租户/组织隔离
角色权限
对象权限
动作权限
字段权限
记录范围权限
业务规则权限钩子
共享/委托权限
审计日志
```

其中“业务规则权限钩子”是必要逃逸通道，否则平台难以承载复杂业务对象。

## 边界

本卡只覆盖 Frappe `permissions.py` 的源码结构，不代表已经验证所有权限分支的运行时结果。
