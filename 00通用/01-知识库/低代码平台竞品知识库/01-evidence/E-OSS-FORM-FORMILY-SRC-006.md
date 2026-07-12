---
id: E-OSS-FORM-FORMILY-SRC-006
type: evidence
competitor: Formily
module: reactive
source_channel: npm
source_type: package-page
source_url: https://www.npmjs.com/package/@formily/reactive
source_owner: package-registry
captured_at: 2026-07-07
valid_until: 2026-10-07
license_note: public-package
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：@formily/reactive 响应式包

## 原始观察

npm 页面将 `@formily/reactive` 描述为类似 MobX 的 Web Reactive Library，属于 Formily 生态包。

Formily Field 源码线索中字段初始化会执行 `makeObservable` 和 `makeReactive`。

## 证据强度

直接事实：npm 包页和公开源码线索共同说明 Formily 使用独立 reactive 包支撑响应式状态。

## 可抽取知识

- Formily 的字段级状态管理依赖响应式基础设施，而不是单纯 React setState。
- 自研平台如果实现复杂联动，应避免把规则和字段状态完全绑死在某个 UI 框架生命周期中。
- reactive 层需要单独评估内存释放、依赖追踪、批量更新和调试能力。

