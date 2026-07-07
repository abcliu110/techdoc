---
id: NFR-NOCOBASE-SRC-002
type: non-functional
domain_object: NocoBasePluginMigrationSourceIndex
competitors: [NocoBase]
evidence: [E-NOCOBASE-SRC-091, E-NOCOBASE-SRC-092, E-NOCOBASE-SRC-093, E-NOCOBASE-SRC-094, E-NOCOBASE-SRC-095, E-NOCOBASE-SRC-096, E-NOCOBASE-SRC-097, E-NOCOBASE-SRC-098, E-NOCOBASE-SRC-099, E-NOCOBASE-SRC-100, E-NOCOBASE-SRC-101, E-NOCOBASE-SRC-102, E-NOCOBASE-SRC-103, E-NOCOBASE-SRC-104, E-NOCOBASE-SRC-105, E-NOCOBASE-SRC-106, E-NOCOBASE-SRC-107, E-NOCOBASE-SRC-108, E-NOCOBASE-SRC-109, E-NOCOBASE-SRC-110]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [NFR-NOCOBASE-SRC-001]
owner: AI
ai_generated: true
---

# NocoBase 插件与迁移源码证据索引

## 结论

NocoBase 以 `PluginManager` 管理插件新增、加载、安装、启用、禁用、删除、升级和迁移。插件生命周期包含 before/after hook，并与数据库迁移、ACL、资源管理器和依赖排序耦合。

## 源码证据范围

```text
E-NOCOBASE-SRC-091..110
plugin-manager.ts: add / load / install / enable / disable / remove / addByNpm / migrations / sort
migration.ts: Migration context
```

## 对自研平台的启发

正式商用低代码平台的扩展机制至少需要：

```text
PluginManifest
PluginLifecycle
DependencySort
PluginMigration
InstallState
EnableState
UpgradePath
RollbackPolicy
```
