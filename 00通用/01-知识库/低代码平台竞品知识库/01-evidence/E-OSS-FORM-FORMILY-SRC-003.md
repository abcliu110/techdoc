---
id: E-OSS-FORM-FORMILY-SRC-003
type: evidence
competitor: Formily
module: json-schema-transformer
source_channel: github
source_type: source-observation
source_url: https://github.com/alibaba/formily/blob/formily_next/packages/json-schema/src/transformer.ts
source_owner: open-source-community
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-repo
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Formily JSON Schema transformer 源码线索

## 原始观察

Formily `packages/json-schema/src/transformer.ts` 公开源码文件位于 json-schema 包中，文件规模约 277 行，用于处理 JSON Schema 转换相关逻辑。

Formily README 和相关文档说明其深度集成 JSON Schema 协议，用于后端驱动表单渲染。

## 证据强度

源码初证：已定位 transformer 文件与 JSON Schema 包，但尚未完整阅读转换规则和关键类型定义。

## 可抽取知识

- Formily 将 schema 转换独立成包，说明 schema 不是 UI 组件内部私有结构。
- 低代码平台应把 schema transform 作为一等模块，专门处理设计态、后端态、运行态之间的转换。
- 需要进一步阅读 x-component、x-decorator、x-reactions、validator 等字段如何在转换中保留或剥离。

