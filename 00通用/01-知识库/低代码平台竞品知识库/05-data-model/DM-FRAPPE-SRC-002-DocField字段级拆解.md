---
id: DM-FRAPPE-SRC-002
type: data-model
domain_object: FrappeDocField
competitors: [Frappe]
evidence: [E-FRAPPE-SRC-002]
strength: 直接事实
confidence: 0.9
status: active
collected_at: 2026-07-05
valid_until: 2026-10-05
links: [DM-LOWCODE-001, ADR-LOWCODE-DM-001]
owner: AI
ai_generated: true
---

# Frappe DocField 字段级拆解

## 源码依据

- 仓库：`frappe/frappe`
- 分支与 commit：`develop` / `b2fd06632503ddffd751a1a5556e33cb2ceccc7c`
- 文件：`frappe/core/doctype/docfield/docfield.json`
- 可复核行号：
  - `fieldtype`：L110
  - `fieldname`：L122
  - `reqd`：L133
  - `options`：L237
  - `fetch_from`：L255
  - `depends_on`：L272

## 字段级观察

DocField 至少覆盖以下核心属性：

```text
fieldtype
fieldname
reqd
options
fetch_from
depends_on
default
```

`fieldtype` 采用 `Select`，其选项中包含 `Data`、`Date`、`Datetime`、`Dynamic Link`、`Link`、`Table`、`Table MultiSelect`、`JSON`、`Code`、`Read Only` 等类型。

## 抽象结论

Frappe 的字段模型同时承担四类职责：

```text
数据结构：fieldname、fieldtype、options、default
校验约束：reqd
关系/带出：Link、Dynamic Link、Table、fetch_from
动态表现：depends_on、Read Only、Code
```

这说明企业业务低代码的字段模型要覆盖“数据字段 + 表单字段 + 关系字段 + 动态规则字段”，不能只等价于数据库列。

## 对自研平台的启发

自研平台的字段定义建议拆为：

```text
identity: name / label
data: type / default / options
constraint: required / validation
relation: link / child table / dynamic link
behavior: fetch / dependency / readonly / formula
presentation: widget / layout / help text
```

这能让字段在数据建模、表单渲染、权限控制、工作流条件中复用同一份元数据。

## 边界

本卡不等价于 Frappe 全量 DocField 字段清单，只记录本轮源码定位到的关键字段。后续达到 L1/L2 需要补全全部 DocField 属性和 UI 表现。
