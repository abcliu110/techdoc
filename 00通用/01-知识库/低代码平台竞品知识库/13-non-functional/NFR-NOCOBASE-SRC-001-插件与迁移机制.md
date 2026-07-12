---
id: NFR-NOCOBASE-SRC-001
type: nfr
domain_object: NocoBaseExtensionMigration
competitors: [NocoBase]
evidence: [E-NOCOBASE-SRC-009, E-NOCOBASE-SRC-010]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [NFR-LOWCODE-001]
owner: AI
ai_generated: true
---

# NocoBase 插件与迁移机制

## 源码依据

- `packages/core/server/src/plugin-manager/plugin-manager.ts`
- `packages/core/server/src/migration.ts`

## 抽象

NocoBase 的扩展机制围绕 PluginManager：

```text
add
load
install
enable
disable
before/after plugin events
loadCollections
loadAI
loadMigrations
applicationPlugins repository
```

迁移基类继承数据库迁移，并在 context 中暴露：

```text
app
plugin manager
current plugin
```

## 对自研平台的启发

正式商用低代码平台必须把插件生命周期和迁移生命周期设计成一等能力：

```text
插件注册
插件安装
插件启用/停用
插件加载顺序
插件数据库同步
插件迁移 beforeLoad / afterLoad
插件事件钩子
```

否则平台后续无法稳定扩展，也无法处理版本升级。

## 边界

本卡未覆盖插件包格式、依赖解析细节和所有迁移文件，只覆盖生命周期主干。
