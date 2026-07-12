---
id: E-KINGDEE-UI-013
type: evidence
competitor: Kingdee-Cosmic
module: classic-development-platform
source_channel: authenticated-product-observation
source_type: first-party-runtime
source_owner: competitor-official
captured_at: 2026-07-11
valid_until: 2026-10-11
license_note: authenticated-read-write-sandbox-observation
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：金蝶云·苍穹经典开发平台四类页面实测

## 证据边界

本证据来自金蝶云·苍穹社区版登录态产品环境中的 `tst` 研究应用。实测创建并进入了基础资料、单据、动态表单和报表设计器；没有启用应用、发布页面或录入真实业务数据。

本证据只能证明 2026-07-11 社区版当前环境中可观察到的产品行为，不能证明闭源服务端实现、物理表结构、完整权限优先级或其他版本行为。

## 直接观察

### 应用与页面创建

- 应用管理先选择业务云和应用，再进入应用内功能分组与页面列表。
- 页面按设备、页面类型和排序维度筛选；页面类型包括单据、基础资料、动态表单、PC 布局、报表、打印模板、参数、移动表单、移动单据和其他。
- PC 端创建向导先选择页面类型，再选择模板，最后填写编码和名称。
- 页面列表保留源模板，并提供布局、继承、打印、移动、复制和导出等衍生入口。

### 基础资料

- 同一基础资料关联表单、列表、移动表单和移动列表四个设计面。
- PC 表单预置编码、名称、数据状态、组织和控制策略等字段；PC 列表预置快速过滤、方案查询、批量操作和表格/卡片/轻分析视图。
- 移动设计面使用独立模板，并提供场景卡片、组件示例和新手引导入口。

### 单据

- 单据向导明确说明其用于流水数据，存储和查询由框架提供。
- 单据带组织模板预置主业务组织并支持按组织隔离数据。
- 默认表单包含单据编号、单据状态、组织、分录和附件；操作集合包含提交、审核、反审核、撤销、打印和下推等企业单据动作。

### 动态表单

- 动态表单向导明确说明其提供最高灵活度，但存储和查询需由插件完成。
- 模板覆盖内容弹窗、应用首页栅格、门户、向导和空白页面。
- 空白动态表单没有默认持久化字段或业务操作，但保留字段、控件、容器、图表、工作流、属性和插件扩展面。

### 报表

- 报表模板包括通用查询、分组、轻分析和基础报表。
- 通用查询模板预置快速过滤、常用条件、方案查询、引出、刷新和报表配置。
- 报表控件库额外包含计算字段、自定义过滤、数据控件、报表列表和报表树。

### 共同设计器结构

- 顶部：设计面切换、XML、预览、保存。
- 左侧：控件、大纲、实体；移动端额外包含场景卡片。
- 中间：页面画布和上下文工具栏。
- 右侧：业务、样式、布局属性。
- 页面级插件、允许的权限动作和运行时按钮集合均可配置。

### 新版开发平台对同一资产的编辑

- 经典平台创建的基础资料和单据会自动出现在新版开发平台的业务对象列表中，并提供“实体/布局”入口，证明两套工作台共享业务对象元数据资产。
- 同一研究单据在新版布局设计器中保持相同的字段、分录、附件和操作集，但顶部导航改为页面设计、插件管理、批量编辑、基本信息和页面规则。
- 页面规则是独立编辑模式，分为实体和服务两个规则域；实体下按主实体和单据体分别统计规则数。
- 插件管理以有序表格呈现，支持注册、注册脚本、编辑、上移、下移、删除和禁用事件；研究单据继承 `TemplateBillEdit` 与 `CodeRulePlugin` 两个插件。
- 批量编辑将主实体和单据体字段展开成矩阵，支持按控件名或控件标识搜索，并以复选状态批量维护多项字段配置。
- 当前研究单据顶部未出现“业务操作”和“权限控制”入口；此前在其他页面看到的这两个入口不能泛化为所有页面类型或所有对象状态。

## 本地截图

- `../../../02-产品方案/低代码平台v2/reports/screenshots/kingdee-classic-app-page-list.png`
- `../../../02-产品方案/低代码平台v2/reports/screenshots/kingdee-classic-basedata-form.png`
- `../../../02-产品方案/低代码平台v2/reports/screenshots/kingdee-classic-basedata-list.png`
- `../../../02-产品方案/低代码平台v2/reports/screenshots/kingdee-classic-basedata-mobile-form.png`
- `../../../02-产品方案/低代码平台v2/reports/screenshots/kingdee-classic-research-bill.png`
- `../../../02-产品方案/低代码平台v2/reports/screenshots/kingdee-classic-research-dynamic-form.png`
- `../../../02-产品方案/低代码平台v2/reports/screenshots/kingdee-classic-research-report.png`
- `../../../02-产品方案/低代码平台v2/reports/screenshots/kingdee-new-designer-research-bill.png`
- `../../../02-产品方案/低代码平台v2/reports/screenshots/kingdee-new-designer-page-rules.png`
- `../../../02-产品方案/低代码平台v2/reports/screenshots/kingdee-new-designer-plugins.png`

## 未知项

- 页面保存后的 XML 全量结构和物理存储映射。
- 规则、权限、插件、工作流在运行时的完整优先级。
- 报表数据提供器、查询模型和服务端执行链路。
- 经典开发平台与新版开发平台的迁移、兼容和长期产品边界。
