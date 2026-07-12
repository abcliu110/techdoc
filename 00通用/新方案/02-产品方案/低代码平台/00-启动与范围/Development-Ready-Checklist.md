# Development-Ready-Checklist

> 结论字段由 `Development-Ready-Review.md` 汇总。本文记录准入检查项。

| 检查项 | 当前状态 | 证据 | 处理 |
|---|---|---|---|
| 首版目标客户、核心场景、非目标已确认 | done | `ProductFactory-Brief.md`、PRD、`../07-知识库同步/T-5A-05-人工决策材料.md` | decisionOwner 已确认为“我本人”；全量范围按 M0/M1/M2/M3 分阶段推进 |
| 知识库基线快照已建立 | done | `../01-知识库盘点/KnowledgeSnapshot.json` | 后续迭代以该快照为基线 |
| 知识库差异报告已建立 | done | `../01-知识库盘点/KnowledgeDiff.md` | 首次基线，无上一版可比对 |
| 阶段 5A 最佳设计决策包已建立 | done | `../04-架构决策/Best-Design-Decision-Package.md` | 8 个矩阵已补齐；T-5A-05 已确认 |
| 架构与设计权衡矩阵已建立 | done | `../04-架构决策/Architecture-and-Design-Tradeoff-Matrix.md` | 已补 10 个关键设计点候选C、落选理由和验证方式 |
| 阶段 5A 六个缺失独立矩阵已补齐 | done | `../04-架构决策/Domain-Model-Decision-Matrix.md` 等 6 个文件 | UI-and-Component-Decision-Matrix 独立成文且已人工接受 |
| T-201~T-206 UI 详细设计门禁字段齐备 | done | `../05-详细设计/T-201~T-206` | 已恢复为 M2 可基线详细设计，不进入 M0/M1 |
| 用户需求文档已建立 | done | `../03-需求/02-用户需求-用例与用户故事.md` | 阶段 4 PRD 门禁输入已补齐 |
| 需求追溯表已建立 | done | `../03-需求/需求追溯表.md` | P0/P1 需求可进入追溯评审 |
| M0 P0/P1 需求有 requirementId | done | `../03-需求/PRD-产品需求规格说明书.md`、`../05-详细设计/08-详细设计总纲.md` | M0 范围 REQ-001~004、REQ-010~013、REQ-030、REQ-041、REQ-050~053、REQ-070~078 已承接 |
| M0 P0/P1 需求可追溯到设计、任务、测试 | done | `../06-任务与测试/CapabilityTraceMatrix.md` | CAP-LCDP-M0-001~005 均为 covered |
| M0 单向门、安全、数据、租户边界有 ADR/设计承接 | done | `../04-架构决策/ADR/`、`../05-详细设计/08-详细设计总纲.md` | M0 使用 accepted / accepted for M0 ADR；proposed ADR 只做预留和阻断 |
| M0 must 能力没有 missing | done | `../06-任务与测试/CapabilityTraceMatrix.md`、`../07-知识库同步/Product-Capability-Coverage-Audit.md` | 审计结论 M0-ready |
| Open-Questions 没有阻断 M0 的问题 | done | `../01-知识库盘点/Open-Questions.md` | 剩余问题不阻断 M0；M1/M2/M3 按里程碑门禁 |
| M0 任务卡可独立验收 | done | `../06-任务与测试/04-任务分配计划.md` | T-001~T-005 已在覆盖审计中核验 |
| M0 测试规格覆盖风险匹配类型 | done | `../06-任务与测试/测试规格/M0-测试规格.md` | M0 风险覆盖见测试规格 §8 |
| 上线门禁、监控、回滚、迁移边界有草案 | partial | `../08-上线运营/Release-Checklist.md` | 不阻断 M0 代码生成；上线前必须补齐 |

## 当前准入建议

当前给出：

```text
M0-ready
```

允许生成 M0 元模型内核代码并执行 T-001~T-005。M1/M2/M3 的 proposed ADR 仍按对应里程碑终审后实现。

