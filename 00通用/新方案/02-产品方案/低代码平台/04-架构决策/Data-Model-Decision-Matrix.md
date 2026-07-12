# Data-Model-Decision-Matrix

> 阶段：5A 统一设计决策工作流  
> 质量流水线：入口检查已读取 PRD、元模型设计、发布 ADR、存储 ADR、T-002/T-004/T-005 与 M0 测试规格；本文件为数据模型单向门决策输入。

| 设计点 | 候选A(知识库/竞品证据) | 候选B(行业标准/最佳实践) | 候选C(自主创新方案) | 采纳结论 | 各落选候选拒绝理由 | 验证方式 | 承接ADR |
|---|---|---|---|---|---|---|---|
| 元数据存储 | 少表 + JSON 聚合，整体加载为 MetaGraph | 规范化拆表，字段/动作/规则分别建表，靠 FK 和事务维护一致性 | JSON 聚合 + 引用影子表 + 热点影子列：聚合保持演进弹性，lc_meta_ref 维护引用，高频查询字段按发布计划物化 | M0 采纳 JSON 聚合 + lc_meta_ref；热点影子列作为 M1 Spike | B JOIN 和保存事务复杂；C 的热点影子列首版引入 DDL 演化成本，先不直接实现 | JSON snapshot 升级、lc_meta_ref 重建、未知字段兼容、并发 revision 冲突测试 | ADR-LOWCODE-STORE-001、T-002、T-003 |
| 业务数据存储 | 每对象真实动态表，竞品企业平台通常偏真实表和索引 | 关系型 OLTP：业务查询、约束、索引、权限裁剪应可解释 | 动态表 + SchemaSync 风险解释器：每次发布先输出 DDL Plan、锁风险、数据迁移风险和回滚边界给设计者确认 | 采纳真实动态表 + DDL Plan；风险解释器作为发布管线必需体验 | EAV 查询、排序、报表和权限复杂；JSON 宽表约束和索引不可控 | 建表/加列/危险变更阻断、MDL 预检、Reconciler 差异分类 | ADR-LOWCODE-PUBLISH-001、01-元模型设计.md、T-004 |
| 元数据版本与运行快照 | 竞品低代码平台通常区分设计态和运行态 | 版本化配置、不可变快照、请求级版本固定 | 双快照校验：MetaGraph snapshot 与 PageSchema snapshot 同步发布，运行时请求记录 metaHash/pageSchemaVersion 组合，用于回放和故障定位 | 采纳 Version snapshot + 请求级 metaHash；双快照校验进入 M2 | 设计态直接生效风险高；只固定后端元数据会导致前端 schema 漂移 | 发布中请求钉住旧版本；旧页面 schema 回放测试；META_VERSION_STALE 前端处理 | ADR-LOWCODE-PUBLISH-001、T-005、T-206 |
| 字段类型与物理列映射 | 竞品均有字段类型注册表和渲染映射 | Strategy/SPI 管理类型转换、DDL、校验、渲染键 | FieldType Capability Vector：每种 field_type 必须声明 DDL、输入归一化、权限状态、rendererKey、契约测试向量 | 采纳字段类型 SPI；Capability Vector 作为 M0/M2 测试资产 | 固定 switch-case 易散落；只靠 UI 配置无法保证后端 DDL 与前端组件一致 | 22 种 field_type DDL/转换/rendererKey 全覆盖测试 | ADR-LOWCODE-FIELDTYPE-SPI-001、T-004、T-201 |
| 数据迁移与兼容升级 | 竞品导入导出和应用包需要版本兼容 | 迁移脚本、兼容等级、回放测试是配置平台基础能力 | Migration Replay Harness：元模型 JSON、PageSchema、导入包、插件 manifest 共用回放器，按兼容等级自动生成阻断/警告/迁移报告 | M0 只实现元模型升级器骨架；统一回放器进入 M2/M3 | 手工 SQL 或临时转换不可审计；首版全量统一回放器范围过大 | 旧 snapshot、旧 PageSchema、旧导出包回放测试 | REQ-088、ADR-LOWCODE-PUBLISH-001、T-206、T-304/T-305 |

## 5.0 自检

| 检查项 | 结果 |
|---|---|
| 完整性 | 已覆盖元数据、业务数据、版本快照、字段类型、迁移兼容 |
| 一致性 | 与 ADR-LOWCODE-STORE-001、ADR-LOWCODE-PUBLISH-001、T-004/T-005/T-206 一致 |
| 可测试性 | 每行均给出 DDL、回放、契约或并发验证 |
| 可追溯性 | 已引用 PRD REQ-050~053、REQ-088 与 CapabilityTraceMatrix 相关能力 |

