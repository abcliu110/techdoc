---
id: E-NOCOBASE-SRC-009
type: evidence
competitor: NocoBase
module: extension
source_channel: github-source
source_type: source-code
source_url: https://github.com/nocobase/nocobase/blob/main/packages/core/server/src/plugin-manager/plugin-manager.ts
source_owner: competitor-official
captured_at: 2026-07-05
valid_until: 2026-10-05
license_note: public-source
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：NocoBase PluginManager

## 源码定位

- 仓库：`nocobase/nocobase`
- 文件：`packages/core/server/src/plugin-manager/plugin-manager.ts`
- 版本：GitHub `main` 分支，commit `1c41defe6c458771dd3449cb8b4557a49e584737`，2026-07-05 访问
- 行号：`PluginManager` 类在 L66，repository 绑定在 L124-L130，公开 pm list 权限在 L132-L133，`add()` 在 L370，`load()` 在 L428，插件 loadCollections/loadAI/load 在 L467-L469，`install()` 在 L513，`enable()` 在 L556，`disable()` 在 L690，插件 migrations 加载在 L1043-L1122。

## 原始观察

PluginManager 通过 `applicationPlugins` repository 管理插件状态，支持 add/load/install/enable/disable，并触发 before/after plugin 事件。插件加载阶段会执行 `loadCollections()`、`loadAI()`、`load()`；启用插件时会同步数据库和安装未安装插件；插件迁移分为 preset/other 与 beforeLoad/afterLoad 等阶段。

## 证据强度

直接事实。源码明确给出 NocoBase 插件生命周期、安装启停、事件钩子和迁移加载机制。
