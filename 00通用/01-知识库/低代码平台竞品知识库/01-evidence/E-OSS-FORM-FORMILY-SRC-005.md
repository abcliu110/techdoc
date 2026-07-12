---
id: E-OSS-FORM-FORMILY-SRC-005
type: evidence
competitor: Formily
module: validator
source_channel: github
source_type: discussion
source_url: https://github.com/alibaba/formily/discussions/4056
source_owner: user-community
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Formily validator 前后端复用讨论

## 原始观察

Formily GitHub discussion 中有用户提出希望在 Node 后端使用 `@formily/validator` 包验证 JSON Schema，从而前后端复用同一份 schema。讨论内容指出 validation logic 被隔离在 `@formily/validator` 包中。

## 证据强度

弱证据：该来源是社区 discussion，能说明使用者诉求和包边界线索，不能证明官方推荐的后端校验方案。

## 可抽取知识

- 表单 schema 的服务端校验复用是低代码平台关键问题。
- 即使前端框架有 validator 包，也不能默认它适合服务端生产校验，需要验证 API、依赖、性能和安全边界。
- 自研平台需要明确“前端即时校验”和“服务端最终校验”的职责边界。

