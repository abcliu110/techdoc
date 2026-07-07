# Permission-Model-Decision-Matrix

> 阶段：5A 统一设计决策工作流  
> 质量流水线：入口检查已读取 PRD、运行时引擎、权限 ADR、T-103、T-201~T-206 与测试规格；本文件为权限模型、安全边界和 UI 权限承接输入。

| 设计点 | 候选A(知识库/竞品证据) | 候选B(行业标准/最佳实践) | 候选C(自主创新方案) | 采纳结论 | 各落选候选拒绝理由 | 验证方式 | 承接ADR |
|---|---|---|---|---|---|---|---|
| 权限内核 | Frappe DocPerm/UserPermission/permlevel + NocoBase ACL resource/action/scope | ABAC/RBAC 混合，服务端统一裁剪，前端只消费授权结果 | AccessView + Permission Explain：每个入口只读取同一 AccessView，拒绝时输出六层链路、metaHash、permVersion、traceId | 倾向采纳 C；M1 前必须人工终审 proposed ADR | A 单独照搬不能覆盖本项目所有入口；B 抽象过宽，若无 explain 难排障 | /meta/list/get/update/export/import/action/link 展开字段权限一致性测试 | ADR-LOWCODE-PERM-001、T-103 |
| 租户隔离 | SaaS 平台均要求 tenant/app/object 隔离 | 强制租户上下文、查询条件注入、跨租户 fail-fast | Tenant-Safe Data Path：从 API、MetaGraph、AccessView、SQL Builder、Outbox 到导出包都要求 tenant/app/object 三元上下文，缺失即阻断 | 采纳 C 作为安全底线 | 只在控制器校验会被内部服务绕过；只靠数据库 schema 隔离不匹配动态对象模型 | 双租户同名对象、同名字段、同 id 记录互不可见；outbox/export 不跨租户 | ADR-LOWCODE-PERM-001、T-102、T-103 |
| 字段权限与脱敏 | Frappe permlevel、NocoBase ACL 字段控制 | 字段级读写、脱敏、审计最小化 | Field Permission Lattice：NONE/MASKED/READ/WRITE 四档统一用于 /meta、renderer、导出、审计和通知模板，任何升级必须由服务端返回 | 采纳 C | 只读/写二值权限无法表达 masked；前端自行脱敏会泄露原值 | 无 read 字段不出现在 /meta/list/get/export；MASKED 字段导出/通知/审计最小化 | ADR-LOWCODE-PERM-001、T-103、T-201 |
| 调岗、组织移动和历史语义 | 竞品通常有组织/角色变化后的数据范围问题 | 企业权限模型必须明确“当前组织”还是“历史快照” | Permission Version Timeline：角色、组织树、数据范围变化生成 permVersion，并在审计和 explain 中记录判定版本 | M1 前需人工终审；首版至少保留 permVersion 边界 | 不定义会由实现偶然决定；完整历史 ACL 快照首版成本过高 | 用户调岗后历史订单可见性按决策一致；缓存按 permVersion 失效 | ADR-LOWCODE-PERM-001、T-103 |
| break-glass 与代客操作 | 企业 SaaS 常见运维代客入口 | 最小权限、双人/理由/审计、不可自删审计 | Break-glass Session：限时、限范围、强理由、敏感字段默认不可见，全部行为写不可篡改审计 | proposed，M1 前终审 | 普通超级管理员绕过审计风险高；首版若不做则必须明确禁用代客操作 | break-glass 不可读取密钥明文；审计不可由同主体删除；指标脱敏 | ADR-LOWCODE-PERM-001、T-103、REQ-034 |
| UI 权限消费 | UI 只消费 `/meta` 和 allowed actions | 前端权限不是安全边界，服务端最终裁决 | Permission Drift Detector：组件测试用同一权限矩阵生成 /meta、按钮、提交 payload 和 API 拒绝的对照用例 | M2 作为 UI 测试增强候选 | 前端隐藏按钮不能防 API 越权；仅后端拒绝但 UI 不解释会降低可用性 | 无权限字段不渲染也不提交；按钮可见性与 action API 一致 | UI-and-Component-Decision-Matrix、T-201~T-206 |

## 5.0 自检

| 检查项 | 结果 |
|---|---|
| 完整性 | 已覆盖权限内核、租户隔离、字段权限、组织变更、break-glass、UI 消费 |
| 一致性 | 与 PRD REQ-030~034、REQ-084、REQ-105 和 ADR-LOWCODE-PERM-001 一致 |
| 可测试性 | 每行均给出权限矩阵、双租户、缓存失效、审计或漂移检测验证 |
| 可追溯性 | 已引用 T-103/T-201~T-206 与 M1/M2 测试规格；需登记 RTM |

