---
id: E-DIRECTUS-DOC-004
type: evidence
competitor: Directus
module: flows
source_channel: official-doc
source_type: doc
source_url: https://directus.com/docs/guides/flows
source_owner: competitor-official
captured_at: 2026-07-06
valid_until: 2026-10-06
license_note: public-page
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Directus Flows

## 原始观察

Directus 官方 Flows 文档说明 Flows 用于事件驱动的数据处理和任务自动化。每个 Flow 包含一个 trigger、一系列 operations，以及在步骤之间传递的数据链。

文档同时提醒 Flows 可在 elevated accountability 下运行任意代码，因此需要限制谁可以创建、编辑或触发它们。

## 证据强度

直接事实：官方文档明确说明 Flow 的结构和安全边界。

## 可抽取知识

- 自动化流程的元模型至少包含 trigger、operation、data chain 和执行身份。
- 低代码平台中的流程能力是安全高风险点，尤其是能执行代码或外部请求时。
- 自研平台需要把流程设计权限、触发权限、运行身份、审计日志和失败重试一起设计。
