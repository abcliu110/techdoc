---
id: E-OSS-FORM-FORMILY-SRC-001
type: evidence
competitor: Formily
module: core-field-state
source_channel: github
source_type: source-observation
source_url: https://github.com/alibaba/formily/blob/formily_next/packages/core/src/models/Field.ts
source_owner: open-source-community
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-repo
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Formily Field 字段状态模型源码线索

## 原始观察

Formily `packages/core/src/models/Field.ts` 公开源码显示 Field 构造时接收 form、props、designable 等信息，并执行 locate、initialize、makeObservable、makeReactive、onInit 等初始化步骤。

源码片段可见字段状态包括 initialized、loading、validating、submitting、selfModified、active、visited、mounted 等。

## 证据强度

源码初证：已定位公开源码文件和字段初始化状态，但尚未完整阅读 Field、BaseField、ArrayField、ObjectField 调用链。

## 可抽取知识

- Formily 把字段作为可观察、可响应的独立状态单元，而不是只把字段当 schema JSON 节点。
- designable 标志说明同一字段模型需要兼容设计态和运行态。
- 低代码平台表单内核应显式建模字段生命周期、交互状态和校验/提交状态。

