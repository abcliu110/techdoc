---
id: FLOW-KINGDEE-001
type: process
domain_object: KingdeeProcessService
competitors: [Kingdee-Cosmic]
evidence: [E-KINGDEE-COSMIC-004, E-KINGDEE-COSMIC-005]
strength: 高可信推断
confidence: 0.65
status: active
collected_at: 2026-07-06
valid_until: 2026-10-06
links: [FLOW-LOWCODE-001, SM-LOWCODE-001, ADR-LOWCODE-001]
owner: AI
ai_generated: true
---

# 金蝶流程服务云抽象

## 证据边界

金蝶流程服务云为闭源商业产品。本卡只基于官方页面和公开报道，不证明内部流程引擎实现。

## 流程能力抽象

公开资料可抽象出以下流程模型：

```text
业务模型库
→ 流程设计
→ 流程建模
→ 流程规则
→ 流程运行
→ 运行监控
→ 安全审计
→ 移动处理
```

## 关键结论

金蝶的流程能力不是孤立 BPMN 画布，而是与动态模型元数据、业务模型库、权限、审计和移动办公共同组成企业流程服务。

## 对自研平台的启发

- Workflow 必须绑定业务对象和状态，而不是只保存节点图。
- 流程规则调整需要版本、审计和影响分析。
- 运行监控和失败补偿应进入首版架构输入，不能等到上线后补。

## 待验证

- 金蝶流程模型字段结构。
- 流程权限与组织、岗位、人员的绑定方式。
- 流程运行日志、审计和异常恢复机制。
