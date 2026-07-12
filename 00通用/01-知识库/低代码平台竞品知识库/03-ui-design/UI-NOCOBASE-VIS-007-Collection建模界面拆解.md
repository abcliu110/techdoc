---
id: UI-NOCOBASE-VIS-007
type: ui
domain_object: CollectionModelingUI
competitors: [NocoBase]
evidence: [E-NOCOBASE-UI-007, E-NOCOBASE-SRC-001, E-NOCOBASE-SRC-002]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [DM-NOCOBASE-SRC-001, DM-NOCOBASE-SRC-002]
owner: AI
ai_generated: true
---

# NocoBase Collection 建模界面拆解

## 页面目标

让管理员先定义数据对象，再由 collection 生成页面、字段、关系和 API 能力。

## 页面分区

```text
Collection 列表
Collection 基础属性
Field 列表
关系字段配置
数据源映射
```

## 设计启发

自研平台首屏不应是页面拖拽器，而应先有“对象建模中心”。对象建模需要支持字段、关系、索引、显示字段、权限边界和迁移版本。

## 边界

尚未验证 UI 中完整字段类型、默认值、唯一约束和导入导出行为。
