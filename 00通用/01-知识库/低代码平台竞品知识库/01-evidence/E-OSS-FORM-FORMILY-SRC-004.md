---
id: E-OSS-FORM-FORMILY-SRC-004
type: evidence
competitor: Formily
module: reactions-risk
source_channel: github
source_type: community-issue
source_url: https://github.com/alibaba/formily/discussions/3176
source_owner: user-community
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Formily x-reactions 使用风险线索

## 原始观察

Formily GitHub discussions 中有关于 jsonschema 中 radio 组件 `x-reactions` 无效的讨论。讨论片段展示了 schema 中使用 `x-component`、`x-decorator`、enum、`x-component-props`、`x-reactions` 等字段来定义组件和联动。

另有 discussion/issue 涉及 `useFieldEffects`、复杂对象字段联动、ArrayField 根据条件渲染不同子组件后的错误等。

## 证据强度

弱证据：社区 discussion/issue 只能说明使用场景和风险线索，不能证明框架设计缺陷或当前版本行为。

## 可抽取知识

- x-reactions 是 Formily schema 联动的重要表达方式，但复杂组件、外部封装和动态数组会提高调试难度。
- 自研平台若引入类似 reactions，需要提供规则可视化、依赖图、调试日志和失效检测。
- 用户自定义组件与联动规则之间要有清晰协议，否则 schema 迁移和组件复用会出现隐性风险。

