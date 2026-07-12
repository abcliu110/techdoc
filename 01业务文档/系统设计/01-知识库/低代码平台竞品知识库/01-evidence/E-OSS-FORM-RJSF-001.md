---
id: E-OSS-FORM-RJSF-001
type: evidence
competitor: react-jsonschema-form
module: form-renderer
source_channel: github
source_type: repo
source_url: https://github.com/rjsf-team/react-jsonschema-form
source_owner: open-source-community
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-repo
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：react-jsonschema-form JSON Schema 表单渲染

## 原始观察

react-jsonschema-form GitHub README 将项目定位为一个 React 组件，可用 JSON Schema 声明式构建和自定义 Web 表单，并提供 Playground。

GitHub 讨论中有社区成员把基于 RJSF 的可视化表单构建器描述为“可视化 JSON 编辑器”，拖拽画布最终操作 state 中的 JSON schemas。

## 证据强度

直接事实：README 说明 RJSF 的 JSON Schema 表单渲染定位；社区讨论可作为弱证据说明其常被用作视觉 Builder 的渲染/导出目标。

## 可抽取知识

- JSON Schema 渲染器适合作为低代码表单运行时基础，但不等同完整表单设计器。
- 可视化 Builder 可以把拖拽结果写回 JSON Schema，但需要额外处理 UI Schema、规则、布局和权限。
- RJSF 适合作为 B 级渲染内核参考，而不是企业业务表单模型的完整答案。

