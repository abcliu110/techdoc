---
id: E-OSS-FORM-DESIGNABLE-SRC-002
type: evidence
competitor: Designable
module: schema-transform
source_channel: github
source_type: source-observation
source_url: https://github.com/alibaba/designable/blob/master/formily/transformer/src/index.ts
source_owner: open-source-community
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-repo
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Designable Formily transformer 源码线索

## 原始观察

Designable `formily/transformer/src/index.ts` 公开源码导入 `ISchema`、`Schema`、`ITreeNode`、`clone`、`uid`，并定义 `ITransformerOptions`，包含 `designableFieldName` 等选项。

GitHub 搜索片段显示该文件承担 Formily schema 与 Designable tree node 之间的转换职责。

## 证据强度

源码初证：已定位 transformer 文件和关键导入/选项，但尚未完整 clone 后逐行阅读转换函数。

## 可抽取知识

- Designable 对 Formily 的集成不是直接编辑运行时 schema，而是通过 transformer 在 schema 与设计器树之间转换。
- `ITreeNode` 是设计态结构的重要抽象；`ISchema/Schema` 是运行/发布态结构的重要抽象。
- 自研平台需要类似 transformer，把设计态拖拽树转换为发布态 schema，并支持反向加载。

