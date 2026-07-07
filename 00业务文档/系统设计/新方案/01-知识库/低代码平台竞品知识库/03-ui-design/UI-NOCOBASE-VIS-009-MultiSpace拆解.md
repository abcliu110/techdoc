---
id: UI-NOCOBASE-VIS-009
type: ui
domain_object: MultiSpaceManagement
competitors: [NocoBase]
evidence: [E-NOCOBASE-UI-009]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [NFR-LOWCODE-001, ADR-LOWCODE-PERM-001]
owner: AI
ai_generated: true
---

# NocoBase Multi-space 管理拆解

## 页面目标

在单个应用实例中创建多个逻辑隔离的数据空间，用于多业务空间管理。

## 页面分区

```text
空间列表
创建空间
空间切换
空间内数据与页面
权限边界
```

## 设计启发

自研平台需要同时支持：

```text
物理隔离：多应用 / 多数据库
逻辑隔离：多空间 / 多组织 / 数据范围
```

二者不能混为一个“tenant_id”字段，否则后续迁移和权限治理会失控。

## 边界

尚未验证空间切换后的菜单、数据、workflow 和插件配置隔离程度。
