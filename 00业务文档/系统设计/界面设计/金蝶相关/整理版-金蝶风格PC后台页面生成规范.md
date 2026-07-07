# 整理版：金蝶风格 PC 后台页面生成规范

## 1. 文档目的

本文解决一个具体问题：

```text
如何根据业务需求，生成一份接近金蝶 / KDesign / ERP 风格的 PC 后端管理界面？
```

前面的文档已经沉淀了：

```text
ERP 设计精髓。
KDesign 页面体系。
PC 后台经典界面模型。
左树右表、上筛下表、主从表等模式。
配色和反馈原则。
测试契约。
```

但这些仍偏知识库。要真正生成页面，还需要一套“页面生成协议”。

本文就是页面生成协议。

## 2. 生成目标

生成的页面应该像企业级 ERP / SaaS 后台，而不是营销页、移动端页面或普通 CRUD 页面。

目标特征：

```text
业务对象清楚。
页面结构稳定。
信息密度适中偏高。
视觉克制。
操作路径高效。
状态和权限清楚。
批量和导出可控。
错误和反馈可恢复。
自动化测试可定位。
```

禁止生成：

```text
营销落地页。
大面积渐变背景。
大圆角卡片堆叠。
装饰性插画主导页面。
移动端卡片列表硬搬到 PC。
只有表格和按钮的低质量 CRUD。
没有状态、权限、批量、测试契约的页面。
```

## 3. 输入需求格式

生成页面前，必须先把业务需求整理成结构化输入。

推荐输入：

```yaml
pageName: 商品管理
businessDomain: 商品中心
objectType: 商品
pageGoal: 管理商品基础资料
primaryUser: 商品运营
secondaryUsers:
  - 门店管理员
  - 审核人员
dataRelationship: 分类范围 -> 商品集合
mainActions:
  - 新增商品
  - 编辑商品
  - 批量启用
  - 批量停用
  - 导入
  - 导出
riskActions:
  - 删除商品
  - 批量停用
keyFields:
  - 商品编码
  - 商品名称
  - 分类
  - 状态
  - 售价
  - 库存
  - 创建时间
states:
  - 启用
  - 停用
  - 草稿
permissions:
  - 查看
  - 新增
  - 编辑
  - 导入
  - 导出
  - 停用
  - 删除
```

如果需求没有这些信息，AI 或设计师必须先补齐假设。

## 4. 页面生成总流程

生成页面按 10 步执行。

```text
1. 识别业务对象。
2. 判断数据关系。
3. 选择页面模式。
4. 套用页面结构模板。
5. 设计区域和组件。
6. 定义字段和表格列。
7. 定义状态、权限、操作和反馈。
8. 套用视觉 token。
9. 输出工程契约和测试属性。
10. 按 A 级清单验收。
```

不要从视觉开始。

正确顺序是：

```text
业务模型 -> 页面模式 -> 信息架构 -> 组件组合 -> 状态权限 -> 视觉 token -> 测试契约
```

## 5. 页面模式选择决策树

根据业务关系选择页面模式。

```text
1. 是否先选择组织、分类、仓库、区域等范围？
   是 -> 左树右表。

2. 是否主要通过条件查询对象集合？
   是 -> 上筛下表。

3. 是否一个主对象对应多条明细？
   是 -> 主从表。

4. 是否维护层级对象本身？
   是 -> 树表一体。

5. 是否需要连续处理待办、工单、审批、异常？
   是 -> 三栏工作界面。

6. 是否配置二维关系？
   是 -> 矩阵表。

7. 是否按状态推进对象？
   是 -> 看板。

8. 是否从指标追溯到明细和原始对象？
   是 -> 图表钻取。

9. 是否批量导入外部数据？
   是 -> 导入向导。

10. 是否围绕一个对象看完整事实、流程和证据？
    是 -> 详情页。

11. 是否录入或修改业务事实？
    是 -> 表单页。

12. 是否作为角色首页承载待办、异常、指标和入口？
    是 -> 工作台。
```

如果一个页面同时满足多个条件，应采用组合模式。

例如：

```text
商品管理 = 左树右表 + 上筛下表 + 批量操作 + 导入导出。
审批中心 = 工作台 + 三栏 + 详情页 + 审批动作。
销售分析 = 报表页 + 图表钻取 + 明细表 + 订单详情。
```

## 6. 视觉风格 token

### 6.1 总体风格

```text
风格：企业级、克制、高密度、清晰、专业。
背景：浅灰页面背景。
容器：白色或接近白色面板。
边框：低对比灰色。
圆角：4-8px，小圆角。
阴影：克制，只用于弹窗、抽屉、浮层。
主色：蓝色系，用于主按钮、选中态、链接、焦点。
状态色：成功绿、警告橙、危险红、禁用灰。
字体：清晰、紧凑、数字可读。
```

### 6.2 颜色 token

```text
page.bg = #f6f8fb
panel.bg = #ffffff
border.default = #d7dde8
text.primary = #0f172a
text.secondary = #334155
text.muted = #64748b
brand.primary = #2563eb
brand.soft = #dbeafe
success = #16a34a
success.soft = #dcfce7
warning = #ea580c
warning.soft = #fff7ed
danger = #dc2626
danger.soft = #fee2e2
disabled = #94a3b8
```

### 6.3 密度 token

```text
页面左右边距：24px。
区域间距：16px。
表格行高：40-48px。
筛选项高度：32-36px。
按钮高度：32px。
工具栏高度：48-56px。
面板圆角：6px。
表格字体：13-14px。
标题字体：16-20px。
```

## 7. 通用组件库

生成页面时优先使用这些组件。

```text
PageShell：页面壳。
PageHeader：页面标题和说明。
MetricStrip：指标摘要条。
QueryBar：查询筛选区。
AdvancedFilter：高级筛选。
Toolbar：工具栏。
BatchActionBar：批量操作栏。
DataTable：数据表格。
TreePanel：左侧范围树。
TreeGrid：树表一体。
StatusTag：状态标签。
PermissionGuard：权限控制。
DetailDrawer：详情抽屉。
AuditTimeline：审计时间线。
AttachmentPanel：附件面板。
ImportWizard：导入向导。
ReportChart：报表图表。
DrilldownTable：钻取明细表。
Pagination：分页。
EmptyState：空状态。
ErrorPanel：错误状态。
```

## 8. 左树右表生成模板

### 8.1 适用输入

```text
业务对象存在范围层级。
用户先选范围，再处理对象。
范围影响新增、查询、批量、导出、权限。
```

### 8.2 页面结构

```text
PageShell
  PageHeader
  ContentSplit
    TreePanel
    MainPanel
      CurrentScopeBar
      QueryBar
      Toolbar
      BatchActionBar
      DataTable
      Pagination
```

### 8.3 生成要求

```text
左侧树必须有搜索、展开、选中态。
右侧必须展示当前范围。
父节点是否包含子节点必须明确。
新增对象默认归属当前范围。
批量操作必须说明影响范围。
导出必须说明范围。
无权限节点不能伪装成无数据。
```

### 8.4 Prompt 模板

```text
生成一个 PC 后台左树右表页面。
业务对象：{objectType}
范围对象：{scopeType}
页面目标：{pageGoal}
风格：企业级 ERP / KDesign 类后台，浅色、克制、高密度、蓝色主色。

页面必须包含：
1. 页面标题区
2. 左侧范围树，支持搜索、展开、选中态
3. 当前范围提示
4. 查询筛选区
5. 工具栏：新增、导入、导出、刷新、列设置
6. 批量操作栏
7. 数据表格
8. 分页
9. 状态标签
10. 空态、加载态、错误态
11. 权限禁用态
12. data-page-id / data-pattern / data-scope-id / data-row-id

不要生成营销页。
不要使用大面积渐变。
不要用大圆角卡片堆叠。
```

## 9. 上筛下表生成模板

### 9.1 页面结构

```text
PageShell
  PageHeader
  QueryBar
  Toolbar
  BatchActionBar
  DataTable
  Pagination
```

### 9.2 生成要求

```text
默认筛选必须安全。
高频筛选外露。
低频筛选进入高级筛选。
重置回到默认条件。
查询结果显示总数。
导出范围必须明确。
表格列按识别列、判断列、行动列组织。
```

### 9.3 Prompt 模板

```text
生成一个 PC 后台上筛下表页面。
业务对象：{objectType}
筛选条件：{filters}
表格列：{columns}
主要操作：{actions}
风险操作：{riskActions}

要求：
1. 顶部查询区
2. 高级筛选折叠
3. 工具栏
4. 批量操作栏
5. 高密度表格
6. 状态标签
7. 分页
8. 导出范围说明
9. 空态和错误态
10. 测试属性
```

## 10. 主从表生成模板

### 10.1 页面结构

```text
PageShell
  PageHeader
  MasterTable
  DetailPanel
    DetailTitle
    DetailTable
    DetailActions
```

### 10.2 生成要求

```text
主表当前行必须明显。
从表标题必须显示当前主对象。
主表切换后从表刷新。
从表为空要说明原因。
从表操作影响主对象时，主表状态必须同步。
```

## 11. 详情页生成模板

### 11.1 页面结构

```text
PageShell
  PageHeader
    ObjectIdentity
    StatusTag
    PrimaryActions
  SummaryPanel
  Tabs
    BasicInfo
    DetailLines
    Relations
    ApprovalTimeline
    Attachments
    OperationLog
```

### 11.2 生成要求

```text
对象编号、状态、组织、日期必须在顶部可见。
关键摘要必须前置。
上下游关系必须可追溯。
审批、日志、附件不能缺失。
风险操作降级。
详情页不是只读表单，而是业务事实和证据中心。
```

## 12. 表单页生成模板

### 12.1 页面结构

```text
PageShell
  PageHeader
  FormSection: BasicInfo
  FormSection: BusinessInfo
  LineItemsTable
  AttachmentPanel
  FooterActions
```

### 12.2 生成要求

```text
字段按业务语义分组。
字段顺序按用户决策顺序，不按数据库顺序。
必填字段说明必填阶段。
支持草稿。
提交前校验。
错误定位到字段或分录行。
离开页面时提示未保存。
```

## 13. 工作台生成模板

### 13.1 页面结构

```text
PageShell
  RoleHeader
  MetricStrip
  TodoPanel
  AlertPanel
  ShortcutPanel
  RecentObjects
```

### 13.2 生成要求

```text
必须按角色生成。
待办和异常优先。
指标必须可下钻。
快捷入口服务高频任务。
不要把工作台做成菜单门户。
```

## 14. 报表页生成模板

### 14.1 页面结构

```text
PageShell
  ReportHeader
  ScopeFilter
  MetricCards
  ChartPanel
  DrilldownCondition
  DetailTable
  SourceObjectLink
```

### 14.2 生成要求

```text
指标口径必须清楚。
统计范围必须清楚。
图表和明细筛选一致。
钻取条件必须显示。
明细能回到原始业务对象。
导出时保留筛选和钻取条件。
```

## 15. 导入向导生成模板

### 15.1 页面结构

```text
ImportWizard
  Step1 DownloadTemplate
  Step2 UploadFile
  Step3 FieldMapping
  Step4 ValidationResult
  Step5 ConfirmImport
  Step6 ImportResult
```

### 15.2 生成要求

```text
上传不能直接入库。
必须先校验。
失败必须定位到行、字段、原因。
支持下载失败明细。
导入结果显示成功、失败、跳过数量。
重复导入要有幂等提示。
```

## 16. 页面状态规范

所有生成页面必须包含状态。

通用页面状态：

```text
initial。
loading。
loaded。
empty。
error。
noPermission。
submitting。
success。
failed。
```

操作状态：

```text
idle。
confirming。
processing。
success。
failed。
retrying。
```

表格状态：

```text
querying。
querySuccess。
queryEmpty。
queryFailed。
batchSelecting。
batchOperating。
exporting。
```

## 17. 权限和风险规范

页面生成时必须考虑权限。

权限类型：

```text
页面访问权限。
数据查看权限。
按钮权限。
字段权限。
导出权限。
打印权限。
审批权限。
批量权限。
```

风险操作：

```text
删除。
作废。
反审核。
批量停用。
批量导出。
付款。
退款。
生成凭证。
修改权限。
导入覆盖。
```

风险操作必须：

```text
二次确认。
显示影响范围。
校验权限。
记录日志。
失败可恢复。
```

## 18. 测试属性规范

生成页面必须包含测试属性。

页面级：

```html
<div
  data-page-id="productManage"
  data-page-type="list"
  data-pattern="tree-table"
  data-object-type="product"
  data-state="loaded"
>
```

范围级：

```html
<div
  data-scope-type="productCategory"
  data-scope-id="cat_1001"
  data-scope-name="饮料"
>
```

行级：

```html
<tr
  data-row-id="P001"
  data-object-type="product"
  data-biz-no="SP0001"
  data-status="enabled"
>
```

动作级：

```html
<button
  data-action="batchDisable"
  data-action-state="idle"
  data-permission="allowed"
>
```

## 19. 生成后验收清单

页面生成后必须检查。

```text
1. 是否识别了业务对象？
2. 是否选对了页面模式？
3. 页面结构是否符合模式？
4. 当前范围或查询条件是否清楚？
5. 表格列是否按识别、判断、行动组织？
6. 状态标签是否稳定？
7. 权限不可用是否有合理表现？
8. 批量操作是否显示影响范围？
9. 导入导出是否可追溯？
10. 错误是否能定位到字段、行或对象？
11. 视觉是否克制、清晰、企业级？
12. 是否避免营销风格、大渐变、大圆角卡片？
13. 是否包含测试属性？
14. 是否包含空态、加载态、错误态？
15. 是否能支持自动化测试？
```

## 20. 完整生成 Prompt 示例

```text
你是世界顶级企业级后台产品设计师和前端架构师。

请生成一个 PC 后端管理界面，风格参考金蝶 KDesign / ERP 后台，但不要复制任何金蝶图片或品牌资产。

业务需求：
- 页面名称：商品管理
- 业务对象：商品
- 范围对象：商品分类
- 页面目标：按分类管理商品基础资料
- 用户角色：商品运营、门店管理员
- 主要操作：新增、编辑、批量启用、批量停用、导入、导出
- 风险操作：删除、批量停用、批量导出

页面模式判断：
- 这是左树右表，因为用户先选择商品分类，再处理分类下的商品集合。

页面必须包含：
1. 页面标题区
2. 左侧商品分类树，支持搜索、展开、选中态
3. 右侧当前范围提示
4. 查询筛选区
5. 工具栏
6. 批量操作栏
7. 商品表格
8. 分页
9. 状态标签
10. 详情抽屉入口
11. 导入向导入口
12. 空态、加载态、错误态
13. 权限禁用态
14. 测试属性

视觉要求：
- 浅灰页面背景
- 白色面板
- 低对比边框
- 蓝色主色
- 小圆角
- 高密度表格
- 状态色语义稳定
- 风险操作使用危险色但不要滥用

不要：
- 不要生成营销页
- 不要大面积渐变
- 不要大圆角卡片堆叠
- 不要移动端风格
- 不要只做普通 CRUD
```

## 21. 最终结论

如果要生成一份接近金蝶/KDesign 的 PC 后台页面，不能只说“做得像金蝶”。

必须把它拆成：

```text
业务对象。
页面模式。
组件组合。
视觉 token。
状态权限。
测试契约。
验收清单。
```

这套生成规范的目标是：

```text
让 AI 或开发人员拿到一个业务需求后，可以稳定判断应该生成什么页面、用什么结构、放什么组件、采用什么视觉风格、暴露什么测试属性。
```

