---
id: E-APPSMITH-SRC-001
type: evidence
competitor: Appsmith
module: widget-extension
source_channel: github
source_type: source-doc
source_url: https://github.com/appsmithorg/appsmith/blob/release/contributions/AppsmithWidgetDevelopmentGuide.md
source_owner: project-official
captured_at: 2026-07-06
valid_until: 2026-10-06
license_note: public-repository
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：Appsmith Widget Development API

## 原始观察

Appsmith 仓库中的 Widget Development Guide 描述了 widget 开发者如何用 Widget Development APIs 把 React 组件连接到 Appsmith 平台，并通过 `registerWidget` 注册给平台使用。

该文档还定义了 Appsmith 应用中的实体，包括 widgets、queries、APIs、`appsmith.store` 和 JS Objects。

## 证据强度

源码初证：来源位于官方 GitHub 仓库，但这是开发指南而非运行时代码路径；需要继续阅读 widget runtime、DSL 和 editor store 源码。

## 可抽取知识

- Appsmith 的 widget 是可注册实体，不只是静态组件库。
- Widget 暴露哪些属性和事件由 widget 开发者与平台 API 共同决定。
- 自研平台若引入组件扩展，应把组件注册、属性 schema、事件、权限和版本兼容纳入治理。
