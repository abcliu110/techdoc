---
id: E-SURVEYJS-FORM-001
type: evidence
competitor: SurveyJS
module: form-builder
source_channel: official-doc
source_type: doc
source_url: https://surveyjs.io/survey-creator/documentation/end-user-guide/form-display-logic
source_owner: competitor-official
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：SurveyJS 显示逻辑与集中 Logic Tab

## 原始观察

SurveyJS 官方文档说明 display logic 可控制字段、选项、section/panel 和页面的可见性，也可控制 read-only 状态。配置方式包括在 Property Grid 的 Conditions 中设置规则，以及通过专门的 Logic tab 集中查看和编辑条件规则。

文档说明 Logic tab 会汇总各元素 Conditions 中创建的条件规则，并支持在 Preview tab 中交互测试规则效果。

## 证据强度

直接事实：官方文档明确说明规则作用层级、Property Grid、Logic tab 和 Preview tab。

## 可抽取知识

- 表单规则需要同时支持局部配置和全局集中治理。
- 页面、分组、字段、选项都可能成为规则目标，规则模型不应只绑定字段。
- 复杂规则需要预览验证入口，否则设计器无法可靠支撑业务用户自助配置。

