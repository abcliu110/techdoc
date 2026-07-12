---
id: UI-NOCOBASE-VIS-010
type: ui
domain_object: AIPluginDevelopment
competitors: [NocoBase]
evidence: [E-NOCOBASE-UI-010, E-NOCOBASE-SRC-101, E-NOCOBASE-SRC-102]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [NFR-NOCOBASE-SRC-001]
owner: AI
ai_generated: true
---

# NocoBase AI 插件开发能力拆解

## 页面目标

让开发者用自然语言生成插件能力，并把数据模型、API、前端 block、权限、i18n、迁移纳入插件包。

## 页面分区

```text
需求输入
插件生成
前后端能力
Collection / API / Block / Action
权限与 i18n
Migration
```

## 设计启发

商用低代码平台的扩展机制不能只支持“写代码插件”，还要支持 AI 辅助生成、版本化、权限声明和迁移脚本。

## 边界

本卡基于官方能力说明，尚未验证生成插件质量、代码结构和运行时安装流程。
