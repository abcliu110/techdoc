---
id: E-OSS-FORM-FORMILY-SRC-002
type: evidence
competitor: Formily
module: core-batch-state
source_channel: github
source_type: source-observation
source_url: https://github.com/alibaba/formily/blob/formily_next/packages/core/src/shared/internals.ts
source_owner: open-source-community
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-repo
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Formily 批量字段状态读写机制源码线索

## 原始观察

Formily `packages/core/src/shared/internals.ts` 公开源码中可见 `createBatchStateSetter` 和 `createBatchStateGetter`。Setter 支持 Query、GeneralField 或路径模式；路径模式会通过 `form.query(path)` 找字段并执行 `field.setState(payload)`，如果未匹配或是通配路径，会订阅后续更新。

## 证据强度

源码初证：已定位批量状态读写逻辑，但尚未完整阅读 query、FormPath、subscribeUpdate、生命周期通知链。

## 可抽取知识

- Formily 字段状态更新支持按路径批量匹配和通配订阅，适合复杂动态表单的联动场景。
- 设计器中的“规则影响字段集合”可以借鉴路径模式和批量状态更新，而不是逐控件硬编码。
- 自研平台需要把字段地址/路径作为稳定标识，否则联动、校验、影响分析都难以实现。

