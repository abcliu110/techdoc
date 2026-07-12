---
id: E-OSS-FORM-FORMLY-001
type: evidence
competitor: ngx-formly
module: dynamic-form-runtime
source_channel: github
source_type: repo
source_url: https://github.com/ngx-formly/ngx-formly
source_owner: open-source-community
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-repo
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：ngx-formly Angular 动态表单

## 原始观察

ngx-formly GitHub README 和官网将其定位为 Angular 的动态、JSON powered 表单库，目标是提升应用表单可维护性。

GitHub issue 中也能看到使用者讨论将后端保存的 JSON 动态渲染为表单，以及 JSON Schema 与 Formly field config 的关系。

## 证据强度

直接事实：README 和官网说明动态 JSON 表单定位；issue 只能作为社区使用场景的弱证据。

## 可抽取知识

- Angular 生态的动态表单倾向于 field config 模型，而不一定直接等价 JSON Schema。
- 低代码平台需要决定内部 schema 是采用标准 JSON Schema、框架 field config，还是自定义 DSL。
- Formly 适合研究 wrappers、validators、field config 和动态渲染插件机制。

