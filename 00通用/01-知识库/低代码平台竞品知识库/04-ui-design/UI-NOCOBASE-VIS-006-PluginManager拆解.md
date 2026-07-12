---
id: UI-NOCOBASE-VIS-006
type: ui
domain_object: PluginManagerUI
competitors: [NocoBase]
evidence: [E-NOCOBASE-UI-006, E-NOCOBASE-SRC-101, E-NOCOBASE-SRC-102]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [NFR-NOCOBASE-SRC-001, ADR-LOWCODE-UI-001]
owner: AI
ai_generated: true
---

# NocoBase Plugin Manager 拆解

## 页面目标

让管理员查看、启用、禁用和进入插件配置，管理平台运行时能力。

## 页面分区

```text
插件列表：已安装插件
状态操作：Enable / Disable
插件入口：进入插件配置页
插件能力：主题、工作流、权限、数据源等
```

## 设计启发

正式商用低代码平台应设计插件生命周期：

```text
安装
启用
禁用
配置
升级
迁移
卸载
```

插件管理需要和权限、迁移、版本兼容绑定。

## 边界

尚未本地验证插件安装失败、依赖冲突和版本升级行为。
