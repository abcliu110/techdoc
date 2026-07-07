---
id: DM-APPSMITH-001
type: data-model
domain_object: AppsmithApplication
competitors: [Appsmith]
evidence: [E-APPSMITH-001, E-APPSMITH-DOC-002, E-APPSMITH-DOC-003, E-APPSMITH-SRC-001]
strength: 高可信推断
confidence: 0.7
status: active
collected_at: 2026-07-06
valid_until: 2026-10-06
links: [DM-LOWCODE-001, UI-LOWCODE-001, ADR-LOWCODE-UI-001]
owner: AI
ai_generated: true
---

# Appsmith 应用构建元模型

## 证据边界

本卡基于 Appsmith 官方文档和官方 GitHub 开发指南。已能确认其公开应用构成对象，但尚未完成运行时代码链路和本地实测。

## 元模型抽象

Appsmith 应用构建可抽象为：

```text
Application
→ Page
→ Widget / Canvas
→ Datasource
→ Query / API
→ JS Object
→ Binding / Event Handler
→ Deploy / Share / Git Version
```

## 机制判断

Appsmith 的强项在于把外部数据源、查询、JS 和 widget 属性快速连起来。它对内部工具非常高效，但业务规则容易出现在：

```text
widget 属性表达式
query 参数
JS Object
event handler
```

这些位置对开发者友好，但对企业级规则治理、审计和复用不天然友好。

## 对自研平台的启发

- 可以借鉴 Appsmith 的查询绑定和组件属性体验。
- 需要把业务规则从页面表达式中提升为可治理对象。
- Widget 扩展必须有组件 schema、事件、版本兼容、权限和安全边界。

## 不宜照搬

- 不应把全部业务逻辑沉入 JS binding。
- 不应只以 page/widget 作为应用设计中心。
- 不应在导出、复制、模板化能力中忽略 page/action/application/workspace 的归属校验。
