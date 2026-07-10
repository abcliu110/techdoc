---
id: DM-KINGDEE-DEVPLATFORM-001
type: data-model
domain_object: KingdeeDeveloperPlatformMetaModel
competitors: [Kingdee-Cosmic]
evidence: [E-KINGDEE-COSMIC-007, E-KINGDEE-COSMIC-008, E-KINGDEE-COSMIC-009, E-KINGDEE-COSMIC-010]
strength: 高可信推断
confidence: 0.6
status: active
collected_at: 2026-07-08
valid_until: 2026-10-08
links: [BIZ-KINGDEE-001, DM-KINGDEE-FORM-001, DM-LOWCODE-001, BR-KINGDEE-001]
owner: AI
ai_generated: true
---

# 数据模型：金蝶开发平台架构元模型

## 证据边界

本卡基于金蝶 AI 苍穹开发指南公开页面抽象。金蝶为闭源商业平台，因此本卡不能证明其内部源码、数据库表结构或完整 XML 字段清单，只能作为公开架构对象和设计方法的高可信推断。

## 分层抽象

```text
业务域治理层
  BusinessCloud / 业务云

应用交付层
  Application / FunctionGroup / Menu / Package / ImportExport

元数据设计层
  PageDefinition / EntityMetadata / PageMetadata / Field / Control / Property

页面类型层
  DynamicForm / Bill / BaseData / Report / Parameter / Card / Layout

运行时解释层
  RuntimePage / FormView / ControlProxy / DataModel / Permission / Rule / Action

扩展层
  Plugin / PluginEvent / OperationPlugin / ReportPlugin / WorkflowPlugin / OpenApiPlugin / BackgroundTaskPlugin

工程治理层
  DeveloperId / Code / GitOrSvnSync / InstallOrder / ResourceFile / SqlScript
```

## 核心对象

| 对象 | 金蝶公开概念 | 职责 |
|---|---|---|
| BusinessCloud | 云 | 企业业务领域 / 解决方案包，是应用的上级边界 |
| Application | 应用 | 某业务域下的一组功能，包含功能分组、页面、菜单、导入导出和版本同步 |
| FunctionGroup | 功能分组 | 应用内页面的分类管理单元 |
| Menu | 应用菜单 | 把页面发布为运行入口，并绑定打开方式、权限项、入口参数等 |
| PageDefinition | 页面定义 | 动态表单、单据、基础资料、报表等页面类型的元数据载体 |
| EntityMetadata | 实体元数据 | 主实体、子实体、字段、单据体等数据结构定义 |
| PageMetadata | 页面元数据 | 控件、布局、样式、视图、页面属性等交互结构定义 |
| DynamicForm | 动态表单 | 最基础、最高灵活度的页面类型，业务存取通常由插件完成 |
| Bill | 单据 | 动态表单上的业务交易对象，内置存储、查询、状态、常用操作和多视图 |
| BaseData | 基础资料 | 可被其他表单引用的特殊单据，承担主数据 / 基础档案职责 |
| Report | 报表 | 非录入型查询分析页面，围绕数据源、过滤条件和字段映射建模 |
| Parameter | 参数 | 多作用域运行配置，包括公共、云、应用、单据、用户、组织等层级 |
| Card | 卡片 | 可复用展示或业务入口片段，可用于首页、门户、统计和复杂单据布局 |
| Layout | 布局 | 同一实体的多场景展示配置，不改变实体字段结构 |
| Rule | 规则 | 界面规则、业务规则、操作规则等配置化行为 |
| Permission | 权限 | 页面整体权限、操作权限、组织 / 业务维度隔离 |
| Plugin | 插件 | 在受控事件点补足配置无法覆盖的复杂逻辑 |

## 关键架构判断

金蝶开发平台不是“表单 JSON + 拖拽控件”的单层模型，而是围绕企业业务对象的多层元数据平台：

```text
业务域 -> 应用 -> 功能分组 -> 页面/菜单 -> 实体/控件/属性 -> 运行时规则/权限/插件 -> 发布包/版本同步
```

动态表单承担页面基类角色；单据、基础资料、参数、卡片、布局等是带业务语义的页面类型扩展。单据进一步把页面元数据与数据库表、主键、组织隔离、状态字段、工作流、转换、打印、导入导出等企业应用能力连接起来。

## 对自研平台的启发

1. 先建业务元模型，再建页面设计器。页面设计器应编辑业务对象和页面元数据，而不是只生成前端组件树。
2. 业务域和应用是治理对象。自研平台需要支持业务域、应用、功能分组、菜单、版本包和导入导出。
3. 页面类型应有继承关系。动态表单是基础，单据、基础资料、报表、参数、卡片、布局在不同维度叠加能力。
4. 数据模型与展示布局必须解耦。同一实体可以有多个布局，布局不能随意改变实体结构。
5. 规则、权限、操作、插件必须服务端化。它们是运行时约束，不应只存在于前端 schema。
6. 插件扩展应有受控事件点。开放能力要围绕视图模型、控件代理、数据模型和上下文对象设计。
7. 工程治理不能后补。开发商标识、编码规范、Git/SVN、安装顺序、SQL、资源文件和发布包都属于平台元模型的一部分。

## 待补证

- XML 元数据导出样例。
- 单据保存后实际生成的物理表和字段映射。
- 列表属性、列表插件与列表数据提供器的完整运行链路。
- 微服务开发、SDK、ORM 页面当前存在下架或加载失败情况，需要补充可访问版本或其他官方证据。
