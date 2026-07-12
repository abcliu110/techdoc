---
id: UI-NOCOBASE-VIS-008
type: ui
domain_object: MultiAppManagement
competitors: [NocoBase]
evidence: [E-NOCOBASE-UI-008]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [NFR-LOWCODE-001]
owner: AI
ai_generated: true
---

# NocoBase Multi-app 管理拆解

## 页面目标

在平台层创建和管理多个物理隔离的应用实例，满足多业务线或多环境需求。

## 页面分区

```text
应用实例列表
创建应用
运行环境
实例状态
应用维护入口
```

## 设计启发

商用平台必须明确：

```text
Tenant
App
Environment
Workspace
Database
```

NocoBase 的 Multi-app 更接近“物理隔离应用实例”，不能简单等同于同库多租户。

## 边界

尚未验证实际创建应用、数据库隔离和跨应用权限边界。
