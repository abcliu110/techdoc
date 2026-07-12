---
id: DM-FRAPPE-SRC-003
type: data-model
domain_object: FrappeDataModelSourceIndex
competitors: [Frappe]
evidence: [E-FRAPPE-SRC-014, E-FRAPPE-SRC-015, E-FRAPPE-SRC-016, E-FRAPPE-SRC-017, E-FRAPPE-SRC-018, E-FRAPPE-SRC-019, E-FRAPPE-SRC-020, E-FRAPPE-SRC-021, E-FRAPPE-SRC-022, E-FRAPPE-SRC-023, E-FRAPPE-SRC-024, E-FRAPPE-SRC-025, E-FRAPPE-SRC-026, E-FRAPPE-SRC-027, E-FRAPPE-SRC-028, E-FRAPPE-SRC-029, E-FRAPPE-SRC-030, E-FRAPPE-SRC-031, E-FRAPPE-SRC-032, E-FRAPPE-SRC-033]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [DM-FRAPPE-SRC-001, DM-FRAPPE-SRC-002]
owner: AI
ai_generated: true
---

# Frappe 数据模型源码证据索引

## 结论

Frappe 数据模型以 DocType 和 DocField 为中心。DocType 承载 module、submit、tracking、autoname、fields、permissions、actions、links、states、naming_rule；DocField 承载 fieldtype、fieldname、reqd、options、fetch_from、depends_on、in_list_view、permlevel、unique、columns 等字段级元数据。

## 源码证据范围

```text
E-FRAPPE-SRC-014..033
doctype.json: DocType metadata
docfield.json: DocField metadata
```

## 对自研平台的启发

业务低代码平台应把对象元数据、字段元数据、权限元数据、视图元数据和状态元数据放在同一个对象定义体系中，而不是拆成互不关联的配置表。
