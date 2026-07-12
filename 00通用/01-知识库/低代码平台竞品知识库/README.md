# 低代码平台竞品知识库

采集日期：2026-07-06

## 范围

本知识库按《01-方法论-多竞品逆向学习与产品设计知识库》执行，第一版覆盖以下竞品：

| 类别 | 竞品 | 选择理由 |
|---|---|---|
| 企业级业务低代码 | 金蝶 AI 苍穹 / 云苍穹开发服务云 | 以动态领域模型、企业基础架构、流程、权限和模型资产化为核心，适合作为企业业务低代码标尺 |
| 内部工具低代码 | Appsmith、ToolJet、Budibase、Lowcoder | GitHub/开源生态中典型的 UI Builder + Data Source + Query + Binding 路线 |
| 数据模型驱动低代码 | NocoBase、NocoDB、Directus | 以 Collection/Table/Schema/Permission/API 为核心，适合学习数据模型驱动应用 |
| ERP 型元数据框架 | Frappe | DocType、权限、表单、列表、工作流等更接近业务系统平台化路线 |
| 专题型表单设计器 | Jotform、Typeform、Airtable Forms、SurveyJS、Formstack、Form.io | 用于补强表单设计器专题的规则、分支路径、schema、审批和安全边界参照 |

## 关键结论

1. 金蝶路线的本质是“业务元模型平台”：以元数据描述业务对象、动态表单、布局、规则、流程和组织权限，强调企业级业务资产沉淀。
2. Appsmith / ToolJet / Budibase / Lowcoder 路线的本质是“内部工具构建器”：组件、数据源、查询、脚本和权限足够强，但缺少 ERP 单据语义。
3. NocoBase / NocoDB / Directus 路线的本质是“数据模型驱动应用”：集合/表/字段/关系/权限/API 是第一等对象，适合构建数据后台和业务应用底座。
4. Frappe 路线的本质是“元数据驱动业务框架”：DocType 将数据模型、表单、列表、权限、工作流打通，是开源项目里最接近金蝶式业务低代码的参考对象之一。
5. 如果目标是建设自己的企业业务低代码平台，应采用“业务模型优先”，而不是从拖拽页面或通用 CRUD 开始。
6. 表单设计器专题的本质不是“字段拖拽”，而是对象字段、布局、条件规则、填写路径、提交、权限、审批和发布版本的组合建模；条件隐藏不能替代字段权限。

## 知识库目录

```text
00-domain/            领域定义、研究范围、术语表
01-evidence/          原始证据卡片
02-competitors/       竞品清单与分级
02-business-design/   业务设计抽象
03-ui-design/         UI 与交互模式
04-process/           应用构建流程
05-data-model/        低代码元模型
06-state-machine/     应用生命周期状态机
07-business-rule/     平台治理规则
08-permission/        权限模型
09-pain-point/        痛点与机会
10-decision/          ADR 产品决策
11-metrics/           指标体系
12-non-functional/    非功能性要求
13-license-pricing/   License、商业化与定价边界
matrices/             横向能力矩阵
gaps/                 补证计划与本轮增量记录
```

## 证据边界

- 本版只使用公开官网、官方文档、GitHub 仓库和公开社区资料。
- 金蝶没有公开源码，本知识库对其内部数据结构仅做“高可信推断”或“假设”，不写成直接事实。
- GitHub 开源项目已开始源码级分析：NocoBase 与 Frappe 已补充 200+ 张源码原子证据卡，覆盖数据模型、权限、页面/视图、工作流、扩展/迁移 5 个核心模块；Appsmith 本轮补充官方应用结构、绑定机制、Widget Development API 和导出权限安全公告；Directus 本轮补充 Fields、Access Control、ItemsService、Role/Policy/Access 和 Flows 证据。Appsmith/Directus 仍处于初始源码初证，不等同完整 S 级。

## 成熟度声明

当前整体成熟度：L0+（方向级增强，S 级核心模块源码证据数量已补足，但未达到完整 L1/S 级 DoD）。

原因：

- 尚未完成 NocoBase、Frappe、Appsmith、Directus 的本地安装/试用验证。
- NocoBase 与 Frappe 的每核心模块源码证据卡数量已达到方法论 §4.0.3 中“每核心模块 ≥20”的数量线，并已补各 10 张官方可见 UI 证据和 10 张页面拆解卡；但尚未满足完整 S 级的本地实测、运行时权限/工作流验证、业务规则卡与运行时导出要求。
- Frappe 权限链路与 Frappe/NocoBase 工作流模型已有源码级原子证据；Appsmith/Directus 已新增初始机制级证据；但尚未完成角色、字段级/行级权限、审批流和执行日志实测。
- 能力矩阵中有源码证据支撑的格子已标注“源码初证”，其余仍标注“未验证”。
- `10-decision/` 下 ADR 均为 `proposed`，不得作为最终商用架构决策直接执行。

## 模块成熟度

| 模块 | 当前等级 | 主要缺口 |
|---|---|---|
| 数据模型/元模型 | L0++ | NocoBase/Frappe 源码证据数量达标；Appsmith 应用构建元模型与 Directus Fields 已补初证；缺完整字段清单、UI schema/DocField 导出样例和运行时验证 |
| 权限模型 | L0++ | NocoBase ACL、Frappe permissions/DocPerm/User Permission 源码证据数量达标；Directus role/policy/access 与 ItemsService 已补初证；缺角色、字段级/行级权限实测 |
| 页面/视图构建 | L1- | NocoBase UI Schema 与 Frappe Form/List/Workspace 源码证据数量达标，官方可见 UI 证据和页面拆解卡数量线达标；缺本地构建页面截图、运行时权限差异、workflow 执行日志和配置字段实测 |
| 表单设计器 | L1- | 已新增金蝶动态表单/单据设计/在线表单平台证据，沉淀金蝶表单设计器界面模式和动态表单原理模型；同时新增 Jotform、Typeform、Airtable、SurveyJS、Formstack、Form.io 和阿里 Formily / Designable 公开资料证据；Formily/Designable 已补字段状态、批量状态读写、JSON Schema transformer、x-reactions 风险、reactive、validator、Designable designer tree 和 schema transform 源码初证，并沉淀字段状态模型、设计器物料协议、联动副作用、服务端校验边界和性能边界；缺完整 clone 级源码阅读、运行验证、金蝶真实截图/录屏、复杂规则冲突验证和与 NocoBase/Frappe 运行时表单的交叉验证 |
| 流程/工作流 | L0++ | NocoBase workflow collection 与 Frappe Workflow/Transition/State 源码证据数量达标；金蝶流程服务云与 Directus Flows 已补公开资料；缺审批动作、状态流转和执行记录实测 |
| 扩展机制 | L0++ | NocoBase PluginManager/Migration 与 Frappe hooks/site 源码证据数量达标；Appsmith Widget Development API 与金蝶集成服务云已补初证；缺插件样例、脚本注入点、API 表面和迁移实测 |
| License 与商业化 | L0+ | 已覆盖 NocoBase、Frappe、Appsmith、Directus；缺 ToolJet、Budibase、Lowcoder、NocoDB 与企业版边界 |
| 定价与打包 | L0 | 缺定价矩阵 |
| 表达式/公式引擎 | L0 | 缺公式、校验表达式、脚本沙箱拆解 |
| 元数据迁移与版本化 | L0 | 缺 duplicator/fixtures/migrations 等机制拆解 |
| 多租户与隔离 | L0 | 缺 site/workspace/base 等隔离机制实测 |

## DoD 缺口清单

对照方法论 §4.0.3 和升级指导书：

```text
S 级 NocoBase：每核心模块源码证据卡数量已达到 ≥20；已补官方可见 UI 证据 10 张和页面拆解卡 10 张；尚未本地安装；尚未构建“客户-订单-审批”样例；尚未补足业务规则卡 ≥5、实测证据和运行时导出样例。
S 级 Frappe：每核心模块源码证据卡数量已达到 ≥20；已补官方可见 UI 证据 10 张和页面拆解卡 10 张；尚未本地安装；尚未构建“客户-订单-审批”样例；尚未补足业务规则卡 ≥5、实测证据和运行时导出样例。
A 级金蝶：已从单一官网材料扩展到开发服务云、流程服务云、集成服务云和 KDDM 公开报道；尚未申请/进入试用环境；全部内部实现相关结论保持推断。
A 级 Appsmith/Directus：已补初始文档/源码/安全公告级机制证据；尚未 Docker 安装和 1 小时试用。
B 级 ToolJet/Budibase/Lowcoder/NocoDB：维持公开资料方向级参照，矩阵已标注未验证。
```

下一阶段进入实测前，需要恢复 Docker daemon。当前 Docker CLI、Docker Compose、Node、Python、Git 可用，但 Docker Desktop Service 停止且无法启动，详见 `E-LOCAL-DOCKER-001`。
