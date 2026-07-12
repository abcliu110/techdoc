# Product-Capability-Coverage-Audit

| auditId | date | scope | conclusion |
|---|---|---|---|
| AUDIT-LOWCODE-M0-READY-001 | 2026-07-06 | M0 元模型内核开工门禁 | M0-ready |

## 1. 审计口径

本次只审计 M0 范围，不审计 M1/M2/M3 是否可开工。

M0 范围：

```text
T-001 工程骨架
T-002 元数据表与实体层
T-003 元模型领域服务
T-004 Schema Sync 动态 DDL
T-005 MetaGraph 缓存
```

判定规则：

```text
covered = PRD/ADR/详细设计/任务卡/M0 测试规格均可反查
partial = 有承接但缺关键引用或缺测试
missing = M0 must 能力没有下游承接
not-applicable-for-M0 = 后续里程碑能力，不阻断 M0
```

## 2. M0 能力覆盖摘要

| capabilityId | coverageStatus | matchedRefs | missingRefs | actionItems |
|---|---|---|---|---|
| CAP-LCDP-M0-001 | covered | REQ-030/REQ-078；ADR-TECH/ADR-M0/ADR-ID；T-001；任务 T-001；M0 测试 §3/§8.1 | 无 | 可进入 M0 T-001 |
| CAP-LCDP-M0-002 | covered | REQ-001/002/010/011/030/070~078；ADR-DM/STORE/FIELDTYPE/OBJECT-EXT/CONVERSION/FLEXORG/APP-PACKAGE；T-002；任务 T-002；M0 测试 §4/§8/§8.1 | 无 | 可进入 M0 T-002，后续能力只做 DTO/阻断 |
| CAP-LCDP-M0-003 | covered | REQ-001~004/010~013/070~078；ADR-DM/FIELDTYPE/OBJECT-EXT/CONVERSION/FLEXORG；T-003；任务 T-003；M0 测试 §5/§8/§9 | 无 | 可进入 M0 T-003 |
| CAP-LCDP-M0-004 | covered | REQ-002/010~013/030/041/050~052；ADR-PUBLISH/STORE/FIELDTYPE；T-004；任务 T-004；M0 测试 §6/§8/§9 | 无 | 可进入 M0 T-004 |
| CAP-LCDP-M0-005 | covered | REQ-050/052/053/DEC-REQ-005；ADR-PUBLISH/STORE；T-005；任务 T-005；M0 测试 §7/§8/§9 | 无 | 可进入 M0 T-005 |
| CAP-LCDP-5A-001 | covered-for-gate | 8 个 5A 矩阵、T-5A-05、Best-Design-Decision-Package、T-201~T-206 基线状态 | 无 | 不阻断 M0；M2 UI 实现前复核 |

## 3. 非 M0 能力处理

| capabilityId | coverageStatus | M0 判定 | 后续处理 |
|---|---|---|---|
| CAP-LCDP-RUNTIME-001 | planned | not-applicable-for-M0 | M1 T-102 前复核运行态 CRUD、API、幂等、审计 |
| CAP-LCDP-PERM-001 | planned | not-applicable-for-M0 | M1 T-103 前终审 AccessView 权限 ADR |
| CAP-LCDP-DESIGNER-001 | planned | not-applicable-for-M0 | M2 T-201~T-206 前按 UI 基线实现 |
| CAP-LCDP-PLUGIN-001 | planned | not-applicable-for-M0 | M3 前补插件/包/Connector/License 门禁 |

## 4. 结论

```text
M0-ready
```

理由：

1. M0 must 能力没有 `missing`。
2. M0 must 能力均能反查到 PRD、ADR/设计、T-001~T-005 任务和 M0 测试规格。
3. M1/M2/M3 能力已明确为 `not-applicable-for-M0` 或 planned，不再阻断 M0。
4. T-5A-05 已人工确认，全量范围按 M0/M1/M2/M3 分阶段实现。

边界：

1. 本结论只允许生成 M0 元模型内核代码。
2. 不允许生成 M1 动态数据 API、权限运行态、表达式运行时。
3. 不允许生成 M2 前端设计器、Renderer、页面 Schema。
4. 不允许生成 M3 插件、导入导出、Connector、License 和商业能力。

## 5. 5.0 自检

| 检查项 | 结果 |
|---|---|
| 完整性 | 已覆盖 M0 T-001~T-005 和非 M0 能力排除清单 |
| 一致性 | 与 PRD、详细设计总纲、任务计划、M0 测试规格和 T-5A-05 结论一致 |
| 可测试性 | 每个 M0 能力均指向 M0 测试规格章节 |
| 可追溯性 | 已与 `../06-任务与测试/CapabilityTraceMatrix.md` 对齐 |

