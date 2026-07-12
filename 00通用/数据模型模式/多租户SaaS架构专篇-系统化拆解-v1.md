# 多租户 SaaS 架构专篇 - 系统化拆解 v1

## 1. 本质模型

多租户 SaaS 架构的本质，是一套系统同时服务多个企业客户，并让每个租户在数据、配置、权限、计量、升级和运维上都像独立系统一样安全运行。

核心抽象：

```text
租户 -> 隔离模式 -> tenant_id -> 配置覆盖 -> 计量计费 -> 升级迁移 -> 跨租户治理
```

## 2. 逻辑模型

### 2.1 实体清单

| 实体 | 关键字段 | 职责 |
|---|---|---|
| sys_tenant 租户档案 | tenant_code(唯一), name, status(TRIAL/ACTIVE/SUSPENDED/TERMINATED), plan_id, isolation_mode(SHARED/SCHEMA/DEDICATED), db_route_key, expire_at, parent_tenant_id | 租户即状态机；隔离模式是档案属性不是代码分支 |
| sys_tenant_status_log 生命周期流水 | tenant_id, 旧状态, 新状态, 触发原因, operator, 时间 | 试用→激活→暂停→终止每步留痕；欠费只封不删 |
| sys_plan 套餐 | plan_code, plan_name, 功能开关集, 配额定义集, 价格, status | 套餐是功能开关与配额的定义层，租户换 plan_id 即升降级 |
| sys_tenant_config 租户配置 | tenant_id, config_key, config_value, updated_by, updated_at | 分层覆盖的租户层；(tenant_id, config_key) 唯一，变更留审计流水 |
| sys_tenant_schema_version 租户版本 | tenant_id, current_version, upgraded_at, upgrade_status | 独立库滚动升级的进度账本；允许相邻版本并存 |
| sub_subscription 订阅 | tenant_id, plan_id, effective_from, effective_to, 周期, status, proration 折算明细 | 租户×套餐×生效区间；升降级折算显式建模 |
| usage_record 用量流水 | tenant_id, 计量项, 用量值, biz_ref, idempotent_key(幂等键), occurred_at | 计费的事实源，只增不改，账单可从流水重算 |
| usage_counter 配额计数器 | tenant_id, 计量项, 周期, current_usage, quota_limit | 预聚合原子累加供配额检查；流水异步对账校准 |
| bill 账单 | tenant_id, 账期, 账单明细行, 金额, status, issued_at | 周期从用量流水聚合生成，出具后冻结 |
| sys_cross_tenant_access 跨租户访问记录 | 平台操作人, 目标 tenant_id, 访问范围, 理由, 时间 | 平台正门的审计凭证：跨租户没有免审计通道 |

### 2.2 实体关系

```text
sys_tenant (1) ──< sys_tenant_status_log (N)   生命周期流水只增
sys_tenant (1) ──< sys_tenant (N)              parent_tenant_id 集团分租父子
sys_plan (1) ──< sys_tenant (N)                租户订套餐
sys_tenant (1) ──< sys_tenant_config (N)       租户配置层（平台默认→套餐→租户→用户逐层覆盖）
sys_tenant (1) ──< sub_subscription (N)        订阅历史多条，生效区间不重叠
sys_tenant (1) ──< usage_record (N)            用量流水
sys_tenant (1) ──< usage_counter (N)           租户×计量项×周期计数器
usage_record (N) >── 聚合 ──> bill (1)         账单从流水结算生成
sys_tenant (1) ── sys_tenant_schema_version (1)  独立库租户版本
sys_tenant (1) ──< sys_cross_tenant_access (N)  平台侧访问留痕
外部引用：tenant_id 贯穿全部业务域表（第一列业务字段，NOT NULL）；
         updated_by/操作人 → 用户域；配置变更/跨租户访问 → 审计域
        （引用不落外键，应用层校验）
```

### 2.3 关键约束与不变量落点

```text
唯一键：tenant_code 全局唯一；(tenant_id, config_key) 配置唯一；
       usage_record.idempotent_key 唯一（防重复计量）；
       业务表唯一键一律以 tenant_id 打头，如 (tenant_id, order_no)
tenant_id 纪律：每张业务表 NOT NULL tenant_id；索引前缀 tenant_id；
             ORM 全局过滤器 + 数据库 RLS 双防线强制注入；
             tenant_id 来自请求上下文而非方法传参；串租户越权测试进 CI
状态机约束：租户 TRIAL→ACTIVE→SUSPENDED→TERMINATED，暂停只封入口不动数据，
          终止按保留期导出后删除；每次转换写 status_log
版本固化：账单出具后冻结（争议走红冲/调整单）；订阅换 plan 记折算明细；
        独立库租户 schema_version 记账，代码兼容 N 与 N-1
配额纪律：检查走计数器（快），结算走流水（准），流水异步对账校准计数器
```

## 3. 核心张力

最大张力是：

```text
共享效率 vs 租户隔离
```

SaaS 想用同一套代码和基础设施降低成本，但客户要求自己的数据、配置、权限、账单、合规边界不被其他租户影响。

## 4. 不变量

- 每一行业务数据必须明确属于一个租户。
- 所有业务查询必须带租户边界。
- 唯一键和索引应包含 tenant_id。
- 租户生命周期不能通过删数据处理。
- 配置必须分层覆盖。
- 跨租户访问必须走平台正门并审计。
- 租户数据必须能导出、迁移和删除。

## 5. 为什么这样设计

tenant_id 贯穿所有业务表，是为了让系统能回答“这个租户有哪些数据”，并在查询、导出、迁移、删除、计费、报表时保持边界。

配置分层是为了支持平台默认、套餐差异、租户定制和用户偏好共存。

混合隔离模式是为了同时服务长尾小客户和高价值大客户。

## 6. 失败模式

- 某些表没有 tenant_id，导致无法导出租户全量数据。
- 查询靠开发自觉加租户条件，出现串租户事故。
- 大客户定制直接改共享表，后续全租户升级困难。
- 配额和功能开关混在一起，计费不准。
- 平台运营用“不带租户条件”的查询口查数据，审计缺失。

## 7. 适用边界

适用：

- B2B SaaS、连锁门店系统、云 ERP、CRM、HR、财务云、协作平台。

可简化：

- 单客户私有部署可以简化租户隔离，但仍建议保留 tenant_id 以支持未来迁移和多组织。

## 8. 设计取舍

优先保证：

- 数据隔离。
- 可迁移。
- 可计量。
- 可配置。
- 可灰度升级。

牺牲：

- 查询简单性。
- 索引成本。
- 配置复杂度。
- 运维治理成本。

## 9. 同一模型的多业务形态建模

多租户模型要同时支撑多种租户形态，核心方法是：**统一骨架 + 隔离模式作为租户档案属性 + 差异用配置分层吸收**。

### 9.1 统一骨架（所有形态不变的部分）

```text
sys_tenant（isolation_mode 标识隔离形态）→ tenant_id 贯穿业务表 → 配置分层覆盖 → 计量记录 → 生命周期状态
不变量全集：行行有租户归属、查询强制租户边界、配置分层、跨租户访问走正门并审计
```

骨架决不为某类租户特化——无论共享表还是独立库，"这个租户有哪些数据、什么配置、用了多少量"都用同一套模型回答。

### 9.2 各形态差异建模

| 业务形态 | 差异点 | 建模方式 |
|---|---|---|
| 长尾小租户共享表 | 成本敏感、量小 | isolation_mode=shared；共享库共享表，tenant_id 行级隔离，唯一键和索引前缀 tenant_id（标准形态，骨架原型） |
| 大客户独立库 | 性能与合规隔离要求 | isolation_mode=dedicated_db；租户档案挂数据源路由；schema 与共享库同源同版本，升级脚本统一发布 |
| 私有化部署 | 客户机房、无平台侧运维 | 单租户实例但保留 tenant_id（固定值）；配置仍走 sys_tenant_config 分层；计量改为本地留存 + 定期离线上报 |
| 免费试用租户 | 到期冻结、配额受限 | 租户状态机加 trial 态 + expire_at；配额走套餐配置层，不写死代码；到期不删数据，status 冻结写入 |
| 集团型租户（子公司分租） | 集团管控 + 子公司数据隔离 | 父子租户：parent_tenant_id 挂集团；数据边界仍按子 tenant_id，账单和用量向父租户归集；集团看板走跨租户正门 |

### 9.3 建模决策规则

- **隔离模式是租户档案的属性，不是代码分支**：业务代码只认 tenant_id，路由层按 isolation_mode 决定落到哪个库。
- **差异优先用配置分层吸收**（平台默认 → 套餐 → 租户定制），而不是改共享表结构；租户级定制字段走租户扩展元数据表。
- **租户状态机允许按形态裁剪但不新增语义**：试用租户跳过"签约"态，但不得发明骨架之外的新终态。
- **拆出 SaaS 的信号**：当客户要求代码级独立演化、配置分层无法表达差异时，那是私有化交付项目，不是一种租户类型。

## 10. AI 知识库沉淀

```yaml
type: model_decomposition
domain: 多租户SaaS
essence: 一套系统服务多个企业并保持隔离
core_tension: 共享效率 vs 租户隔离
invariants:
  - tenant_id 贯穿业务数据
  - 查询强制租户边界
  - 配置分层覆盖
  - 跨租户访问审计
failure_modes:
  - 串租户
  - 定制污染共享结构
  - 用量计费不可解释
business_forms:
  strategy: 统一骨架 + isolation_mode 租户档案属性 + 配置分层吸收差异
  forms: [共享表小租户, 独立库大客户, 私有化部署, 免费试用, 集团分租]
  split_signal: 配置分层无法表达差异、要求代码级独立演化时才是私有化项目而非租户类型
```

## 数据库字段中文名与主档引用补充

本篇 v1 的字段级数据库建模、字段中文名、主档/子表引用关系，统一见：v1数据库字段中文名与主档引用补充.md。本篇正文保留领域逻辑模型和不变量，补充文档负责数据库实施口径。

