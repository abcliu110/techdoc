# Evidence-Maturity-Matrix

> 初始矩阵用于标记当前文档中已采用结论的证据状态。完整矩阵需要从竞品知识库和源码/实测记录抽取后补齐。

| evidenceId | sourceType | sourcePath | claim | evidenceLevel | verificationStatus | risk | nextVerificationAction |
|---|---|---|---|---|---|---|---|
| EV-LOWCODE-PRD-001 | 业务决策 | `../03-需求/PRD-产品需求规格说明书.md` | 首版围绕客户-订单-审批样例构建低代码平台主链路 | 风险接受 | 已形成 PRD | 范围漂移 | 人工确认首版非目标 |
| EV-LOWCODE-ADR-001 | ADR | `../04-架构决策/ADR/ADR-LOWCODE-DM-001-minimal-domain-model.md` | M0 使用最小业务元模型 | 直接事实 | ADR 已成文 | 单向门 | 代码实现前复核 ADR 状态 |
| EV-LOWCODE-ADR-002 | ADR | `../04-架构决策/ADR/ADR-LOWCODE-PUBLISH-001-persistent-publish-pipeline.md` | 发布管线采用持久化状态机、DDL Plan、Reconciler | 直接事实 | ADR 已成文 | 发布恢复复杂 | T-004 实现时跑故障注入测试 |
| EV-LOWCODE-RISK-001 | 风险清单 | `../07-知识库同步/07-低代码平台级架构陷阱与高难度问题清单.md` | 动态 DDL、租户隔离、权限和兼容是高风险主线 | 高可信推断 | 已被设计承接 | 覆盖可能不完整 | 与测试规格和工程规范逐项对齐 |
| EV-COMPETITOR-TBD | 竞品知识库 | `../../../../01-知识库/低代码平台竞品知识库/` | 竞品能力和差距来源 | 高可信推断 / 源码初证混合 | 已建立 KnowledgeSnapshot，未完成原子 evidenceId 结构化 | 误把竞品描述当需求 | 补原子证据卡 evidenceId，并与 CapabilityTraceMatrix 对齐 |

## 强制规则

- `未验证` 证据不得进入 PRD 的 must 范围。
- `源码初证` 进入实现前必须补实测、源码复核或 ADR 风险接受。
- 高风险能力缺少 ADR 时，覆盖状态不能判定为 covered。
