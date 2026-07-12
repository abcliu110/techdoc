---
id: E-OSS-FORM-FORMKIT-001
type: evidence
competitor: FormKit
module: form-framework-schema
source_channel: github
source_type: repo
source_url: https://github.com/formkit/formkit
source_owner: open-source-community
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: MIT
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：FormKit 表单框架与 schema 安全边界

## 原始观察

FormKit GitHub README 将其定位为表单框架，强调 co-located validation、self-structuring data、composability 和 compact single-component API。官网也强调 schema overrides、验证和自结构化数据。

社区讨论中有用户提出用 FormKit Schema 让用户创建并渲染表单时的安全担忧，尤其是用户定义 schema 可能带来的 XSS 风险。

## 证据强度

直接事实：GitHub README 和官网说明框架定位；社区讨论可作为安全边界风险线索，不能当作漏洞事实。

## 可抽取知识

- 用户可配置 schema 必须进入安全审查范围，不能把 schema 当作纯配置。
- 表单运行时需要考虑 XSS、组件白名单、表达式能力、HTML 注入和服务端校验。
- FormKit 适合研究表单节点模型、schema、验证和安全边界。

