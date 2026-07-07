---
id: E-OSS-FORM-FORMILY-001
type: evidence
competitor: Formily
module: form-engine
source_channel: github
source_type: repo
source_url: https://github.com/alibaba/formily
source_owner: open-source-community
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-repo
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Formily 高性能 schema 表单内核

## 原始观察

Alibaba Formily GitHub README 将其定位为跨端、高性能表单方案，说明其通过分布式管理每个表单字段状态来缓解受控表单整树渲染性能问题，并深度集成 JSON Schema 协议，支撑后端驱动表单渲染。

Formily 官网还把能力概括为 ultra-high performance、form builder、pure core、more extensibility。

## 证据强度

直接事实：GitHub README 和官网公开说明其设计目标、性能思路和 JSON Schema 集成。

## 可抽取知识

- 企业级表单运行时不能只考虑设计器画布，还要考虑字段级状态管理和联动性能。
- 后端驱动表单需要 schema 协议和前端字段状态模型共同工作。
- Formily 适合纳入 A 级源码深挖对象，重点研究字段状态、联动副作用、校验和设计器生态。

