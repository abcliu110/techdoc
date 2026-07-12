---
id: FLOW-DIRECTUS-001
type: process
domain_object: DirectusFlow
competitors: [Directus]
evidence: [E-DIRECTUS-DOC-004, E-DIRECTUS-SRC-001]
strength: 高可信推断
confidence: 0.75
status: active
collected_at: 2026-07-06
valid_until: 2026-10-06
links: [FLOW-LOWCODE-001, SM-LOWCODE-001]
owner: AI
ai_generated: true
---

# Directus Flows 自动化模型

## 证据边界

本卡基于 Directus 官方 Flows 文档和 ItemsService 源码线索，尚未阅读完整 Flow engine 源码。

## 元模型抽象

Directus Flow 可抽象为：

```text
Flow
→ Trigger
→ Operation
→ Data Chain
→ Execution Accountability
→ Security Restriction
```

## 对自研平台的启发

- 自动化流程不能只设计“节点列表”，还要设计节点间数据链。
- 执行身份是流程模型的一等字段。
- 支持任意代码或外部请求的流程，应进入高风险权限和审计门禁。

## 待验证

- Directus Flow trigger 与 operation 的源码字段。
- Flow 与 permission/accountability 的实际运行关系。
- Flow 失败、重试、日志、告警机制。
