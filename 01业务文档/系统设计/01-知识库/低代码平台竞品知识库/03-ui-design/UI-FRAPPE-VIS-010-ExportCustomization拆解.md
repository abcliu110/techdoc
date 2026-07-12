---
id: UI-FRAPPE-VIS-010
type: ui
domain_object: MetadataMigrationUI
competitors: [Frappe]
evidence: [E-FRAPPE-UI-010]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [NFR-FRAPPE-SRC-001, NFR-FRAPPE-SRC-002]
owner: AI
ai_generated: true
---

# Frappe Export Customizations 拆解

## 页面目标

把 Customize Form 中的元数据变更导出成应用资产，随 app 版本和 migrate 流程同步到其他环境。

## 页面分区

```text
Customize Form
Export Customizations
Module 选择
Custom Fields
Property Setters
bench migrate / update
```

## 设计启发

商用低代码平台必须提供元数据迁移能力：

```text
设计态变更
-> 变更包
-> 版本号
-> 环境发布
-> 回滚
```

否则开发、测试、生产环境会因为手工配置漂移而不可控。

## 边界

尚未实测导出文件内容、冲突处理和回滚策略。
