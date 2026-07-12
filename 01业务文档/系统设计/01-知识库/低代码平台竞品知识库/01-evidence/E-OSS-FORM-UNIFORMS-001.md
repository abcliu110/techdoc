---
id: E-OSS-FORM-UNIFORMS-001
type: evidence
competitor: uniforms
module: schema-form-runtime
source_channel: github
source_type: repo
source_url: https://github.com/vazco/uniforms
source_owner: open-source-community
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-repo
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：uniforms 多 schema React 表单

## 原始观察

uniforms GitHub README 说明它是一个从任意 schema 构建表单的 React 库，包含自动生成表单、可渲染每种 schema 的字段、一行创建自定义字段、同步/异步校验，以及 JSON Schema、SimpleSchema、Zod 等 schema 集成和多种主题。

## 证据强度

直接事实：GitHub README 明确列出自动表单生成、多 schema 集成、校验和主题能力。

## 可抽取知识

- 表单运行时可以通过 schema bridge/adaptor 兼容多种 schema，而不是绑定单一协议。
- 自研平台如果未来接入业务对象、JSON Schema、Zod 或外部 API schema，需要考虑 schema adapter 层。
- uniforms 适合 B 级研究，重点看 schema bridge、AutoForm 和主题适配。

