---
id: UI-FRAPPE-VIS-009
type: ui
domain_object: DocTypeRuntimeGeneration
competitors: [Frappe]
evidence: [E-FRAPPE-UI-009, E-FRAPPE-SRC-001, E-FRAPPE-SRC-012]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [DM-FRAPPE-SRC-001, UI-FRAPPE-VIS-001, UI-FRAPPE-VIS-002]
owner: AI
ai_generated: true
---

# Frappe DocType 生成运行时页面闭环拆解

## 页面目标

从 DocType 定义自动生成数据库表、New 按钮、表单页和列表页，形成对象到运行时 UI 的闭环。

## 页面分区

```text
DocType 创建
字段定义
New 按钮
Form 页面
List 页面
数据库表
```

## 设计启发

自研平台 MVP 必须优先完成：

```text
对象定义
-> 字段定义
-> 生成表
-> 生成列表
-> 生成表单
-> 基础 CRUD
```

没有这个闭环，后续工作流、权限和插件都无法稳定落地。

## 边界

尚未本地验证创建 DocType 后数据库表、权限和页面缓存刷新细节。
