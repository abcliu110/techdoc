# 新 POS 与商户后台系统前端架构方案

## 1. 结论

如果是在维护现有 `nms4cloud-biz-ui`，继续使用 Umi Max 是合理的，因为旧系统已经围绕 Umi Max、Ant Design、ProComponents 建立了路由、菜单、权限、请求和大量页面。

但如果目标是重做一套新的 POS 与商户后台系统，不建议继续把 Umi Max 作为核心框架。新系统更适合采用：

```text
Vite
+ React
+ React Router
+ TanStack Query
+ Ant Design
+ TanStack Table
+ 自有 Merchant UI 组件库
+ 页面 Schema
+ 领域模型与状态机知识库
```

核心思想是：**应用壳要轻，业务能力要自有，页面生成要基于模型和 Schema，而不是绑定某个后台框架。**

## 2. 为什么旧系统可以保留 Umi Max

Umi Max 适合已有 Ant Design Pro 风格后台。它提供的是后台应用的基础设施：

- 路由。
- 菜单。
- 权限。
- 登录态。
- 全局状态。
- 请求封装。
- OpenAPI 接口生成。
- 构建和开发服务器。
- Ant Design Pro 布局集成。

对于 `nms4cloud-biz-ui` 这种已经运行的系统，Umi Max 是应用壳。它负责让系统跑起来，而不是负责表达商户业务本身。

所以旧系统中更合理的做法是：

```text
Umi Max 继续做应用壳
Ant Design 继续做基础组件
ProComponents 继续用于简单后台页面
自有 Merchant UI 逐步承接复杂业务页面
```

不建议为了技术洁癖迁移旧系统。迁移成本高，收益不一定能覆盖风险。

## 3. 为什么新系统不建议以 Umi Max 为核心

新系统的目标不是快速搭一个后台，而是建设一套可以长期演进、可以被 AI 学习、可以根据业务知识库生成页面和后端模型的新 POS/商户系统。

这个目标下，核心资产不是 Umi 插件，而是：

- 业务能力模型。
- 领域对象模型。
- 数据模型。
- 状态机。
- 流水事件模型。
- 报表指标模型。
- 页面 Schema。
- 表格 Schema。
- 动作和权限 Schema。
- 自有商户后台组件库。
- 竞品分析知识卡片。

Umi Max 解决的是应用组织问题，但不能解决这些业务建模问题。

如果新系统继续强依赖 Umi Max，容易出现以下问题：

- 页面生成体系被 Umi 路由、model、request、access 写法绑定。
- 业务组件和框架插件边界不清。
- ProTable 被误当成复杂表格最终方案。
- 后续如果迁移框架，页面、权限、请求、生成规则都会被牵连。
- AI 生成页面时容易生成框架代码，而不是稳定的业务 Schema。

新系统应该把框架控制在很薄的一层。框架只管运行，业务表达交给自有模型和组件库。

## 4. 推荐的新系统前端分层

建议采用以下分层：

```text
应用层
  apps/merchant-admin
  apps/pos-admin

基础工程层
  Vite
  React
  React Router
  TanStack Query
  OpenAPI TypeScript Client

基础 UI 层
  Ant Design
  Icons
  Design Tokens

业务 UI 层
  packages/merchant-ui
  packages/merchant-table
  packages/merchant-form
  packages/merchant-report

模型与生成层
  packages/domain-schema
  packages/page-schema
  packages/state-machine
  packages/api-contract

知识库层
  业务能力卡
  数据模型卡
  状态机卡
  UI 模式卡
  竞品对比卡
  设计决策卡
```

每一层职责要清楚：

| 层级 | 责任 | 不负责 |
|---|---|---|
| Vite | 构建、开发服务器、打包 | 业务模型 |
| React Router | 路由与页面加载 | 权限业务规则 |
| TanStack Query | 接口状态、缓存、刷新、错误状态 | 页面布局 |
| Ant Design | 基础 UI 零件 | 商户业务语义 |
| Merchant UI | 商户后台业务组件 | 请求协议细节 |
| Page Schema | 页面生成契约 | 具体渲染实现 |
| Domain Schema | 领域对象、字段、状态、动作 | UI 样式 |

## 5. 推荐技术栈

### 5.1 应用框架

推荐：

```text
Vite + React + React Router
```

原因：

- Vite 只负责构建和开发体验，框架绑定轻。
- React Router 负责路由，边界清楚。
- 不把路由、权限、请求、状态全部绑进一个大框架。
- 更适合未来做多应用、多包、页面 Schema 渲染和 AI 生成。

不首选 Next.js 的原因：

- 商户后台通常不依赖 SEO。
- 大部分页面是登录后的业务系统，不需要 SSR 优先。
- Next.js 的服务端能力对后台不是主要矛盾。
- 引入 App Router、Server Components 等复杂度，未必能服务商户后台核心目标。

不首选 Umi Max 的原因：

- Umi Max 更适合 Ant Design Pro 风格快速后台。
- 新系统核心是模型驱动和自有组件库，不应让 Umi 插件体系成为中心。

### 5.2 请求与状态

推荐：

```text
TanStack Query
```

用途：

- 查询缓存。
- 加载态。
- 错误态。
- 自动刷新。
- 分页查询。
- 乐观更新。
- 数据失效和重新拉取。

全局状态只保留少量内容：

- 当前用户。
- 当前商户。
- 当前门店。
- 权限摘要。
- 当前主题。
- 当前语言。

如果确实需要轻量全局状态，可以使用 Zustand 或 Jotai，但第一期不必急着引入。能用 React Context 和 TanStack Query 解决的，不新增状态库。

### 5.3 UI 基础组件

推荐继续使用：

```text
Ant Design
```

原因：

- 企业后台组件完整。
- 表单、弹窗、选择器、日期、上传、树、标签等基础能力成熟。
- 设计语言适合商户后台。
- 团队已有经验。

但要明确：Ant Design 是基础 UI 零件，不是最终商户后台组件库。

### 5.4 表格方案

商户后台的核心不是按钮和弹窗，而是表格。普通后台表格能力不够，需要单独设计。

推荐分级：

```text
普通列表：Ant Design Table 封装
复杂列表：TanStack Table
报表/类 Excel 场景：后期评估 AG Grid
```

第一期不建议全局引入 AG Grid。AG Grid 能力强，但重量和授权都需要单独评估。只有当报表中心、库存台账、财务对账确实需要接近 Excel 的能力时，再局部引入。

## 6. 自有 Merchant UI 组件库

新系统最重要的前端资产是自有 `Merchant UI`，它表达的是商户后台业务，而不是通用后台页面。

第一期建议建设以下组件：

```text
MerchantPageContainer
MerchantSearchForm
MerchantActionBar
MerchantQueryTable
MerchantEditableTable
MerchantReportTable
MerchantStatusTag
MerchantAmount
MerchantStoreSelector
MerchantProductSelector
MerchantMemberSelector
MerchantOrderTimeline
MerchantAuditLog
MerchantPermissionGuard
```

其中最关键的是表格族：

### 6.1 MerchantQueryTable

用于普通查询列表：

- 搜索表单。
- 分页。
- 排序。
- 服务端筛选。
- 列显示隐藏。
- 列宽拖拽。
- 固定列。
- 批量操作。
- 行操作。
- 状态驱动按钮。
- 字段权限。
- 导出。

### 6.2 MerchantEditableTable

用于单据明细、库存调整、采购明细、商品规格等：

- 行内编辑。
- 新增行。
- 删除行。
- 批量编辑。
- 单元格校验。
- 合计行。
- 明细级错误提示。

### 6.3 MerchantReportTable

用于报表和台账：

- 多级表头。
- 汇总行。
- 指标口径展示。
- 维度筛选。
- 钻取。
- 导出。
- 大数据虚拟滚动。
- 固定列。
- 保存视图。

这些组件可以内部使用 Ant Design Table、TanStack Table 或其他表格内核，但业务页面只能依赖 Merchant UI 暴露的接口。

也就是说，页面不要直接写：

```tsx
<ProTable />
```

而应该写：

```tsx
<MerchantQueryTable schema={orderListSchema} />
```

这样未来更换表格内核时，业务页面不用大规模重写。

## 7. 页面 Schema：AI 生成系统的关键

新系统不应该让 AI 直接生成大量 TSX 页面。更好的方式是让 AI 生成稳定的页面 Schema，再由自有组件库渲染。

示例：

```ts
export const orderListPage = {
  type: 'list',
  entity: 'Order',
  title: '订单列表',
  search: [
    { field: 'orderNo', label: '订单号', component: 'TextInput' },
    { field: 'storeId', label: '门店', component: 'StoreSelector' },
    { field: 'status', label: '订单状态', component: 'EnumSelect' },
    { field: 'createdAt', label: '下单时间', component: 'DateRange' },
  ],
  table: {
    rowKey: 'id',
    columns: [
      { field: 'orderNo', label: '订单号', fixed: 'left' },
      { field: 'storeName', label: '门店' },
      { field: 'amount', label: '金额', component: 'Amount' },
      { field: 'status', label: '状态', component: 'StatusTag' },
      { field: 'createdAt', label: '下单时间' },
    ],
  },
  actions: [
    { code: 'view', label: '查看', visibleWhen: 'always' },
    { code: 'refund', label: '退款', visibleWhen: "status === 'paid'" },
    { code: 'export', label: '导出', permission: 'order:export' },
  ],
};
```

业务页面只负责：

```tsx
<MerchantListPage schema={orderListPage} />
```

这样做的好处：

- AI 生成内容更稳定。
- 页面结构可审查。
- 权限、字段、状态、动作都有统一契约。
- 可以自动生成测试用例。
- 可以从同一份 Schema 生成前端页面、接口契约、文档和验收清单。

## 8. 数据模型与 UI 模型必须一起设计

商户后台不能只从页面出发，也不能只从数据库表出发。

正确流程是：

```text
业务能力
  -> 领域对象
  -> 状态机
  -> 流水事件
  -> 报表指标
  -> 页面任务
  -> 页面 Schema
  -> UI 组件组合
  -> 接口契约
  -> 测试模型
```

例如订单列表页不是一张表，而是多个模型的投影：

```text
Order
OrderLine
Payment
Refund
Member
Store
OrderStatus
PaymentStatus
OrderAction
OrderEvent
```

如果页面上有“退款”按钮，背后必须有：

- 状态机合法动作。
- 权限控制。
- 退款原因。
- 原支付关联。
- 退款流水。
- 操作日志。
- 报表影响。

UI 的每个动作都要能追溯到数据模型和状态机。

## 9. 竞品与开源项目怎么用

竞品和 GitHub 开源项目不能直接照搬。

### 9.1 顶级行业软件

金蝶、用友、SAP、Oracle、餐饮 POS、零售 POS 等顶级行业软件，主要用于学习：

- 业务能力划分。
- 页面任务模型。
- 信息架构。
- 单据模型。
- 状态机。
- 逆向流程。
- 报表口径。
- 权限与组织模型。
- 异常处理。

它们的价值在业务设计，不在代码。

### 9.2 GitHub 开源项目

GitHub 项目主要用于学习：

- 工程结构。
- 组件封装方式。
- 表格和表单组合。
- 页面模板。
- 权限路由。
- 主题系统。

其中 Ant Design Pro、ProComponents、react-admin、refine、Vue Vben Admin 可以作为 UI 工程参考。

POS 类开源项目多数不是顶级 UI 标杆，只适合当业务功能样本，不适合作为架构蓝本。

### 9.3 最终沉淀形式

每次分析竞品或开源项目后，不产出长篇感想，而是产出知识卡片：

```yaml
type: ui_pattern
name: 查询列表页三段式结构
source:
  - Ant Design Pro
  - 金蝶云星空列表页
problem: 后台用户需要在大量记录中快速筛选、比较、批量处理
solution: 搜索区 + 操作区 + 表格区，状态和动作在行内表达
reuse_when:
  - 订单列表
  - 商品列表
  - 会员列表
  - 库存单据列表
avoid_when:
  - 高频收银触屏场景
  - 强流程向导场景
risks:
  - 搜索项过多导致首屏压缩
  - 行操作过多导致用户无法判断主动作
confidence: medium
```

知识卡片才是 AI 后续生成系统时应该检索的内容。

## 10. 第一阶段落地范围

不要一开始重做完整 POS + 商户后台。第一阶段建议只验证一个闭环：

```text
商品
  -> 订单
  -> 支付
  -> 退款
  -> 会员权益
  -> 库存影响
  -> 销售报表
```

前端页面选择 3 类：

```text
商品列表
订单列表
销售报表
```

这三个页面足够验证：

- MerchantQueryTable。
- MerchantReportTable。
- SearchForm。
- ActionBar。
- StatusTag。
- StoreSelector。
- ProductSelector。
- 页面 Schema。
- 权限 Schema。
- 状态动作 Schema。
- 接口查询契约。

通过后，再扩展：

- 商品详情。
- 订单详情。
- 退款流程。
- 会员中心。
- 库存台账。
- 营销活动。
- 门店经营分析。
- 财务对账。

## 11. 推荐目录结构

建议采用 Monorepo：

```text
new-pos-platform/
  apps/
    merchant-admin/
    pos-admin/
  packages/
    merchant-ui/
    merchant-table/
    merchant-form/
    merchant-report/
    domain-schema/
    page-schema/
    api-client/
    design-tokens/
    test-kit/
  docs/
    knowledge/
    decisions/
    competitor-analysis/
    ui-patterns/
```

第一期不需要把每个包都做成独立 npm 包。可以先用 workspace 内部包，等边界稳定后再发布。

## 12. 技术决策边界

### 12.1 立即采用

- React。
- Vite。
- React Router。
- TanStack Query。
- Ant Design。
- TanStack Table。
- OpenAPI TypeScript 生成。
- 自有 Merchant UI。
- 页面 Schema。

### 12.2 暂缓采用

- AG Grid：等复杂报表和台账场景确认后再评估。
- 微前端：等多团队、多应用独立发布成为真实需求后再引入。
- Next.js：除非出现 SSR、SEO、BFF、全栈路由等明确需求。
- 大型低代码平台：先做页面 Schema 和模板生成，不直接上复杂低代码。
- 全量可视化页面搭建器：容易过度设计，第一期不做。

### 12.3 不建议采用

- 直接复制 Ant Design Pro 页面代码。
- 让 AI 直接生成大量不可治理的 TSX 页面。
- 把 ProTable 当所有表格的最终方案。
- 一开始就引入 AG Grid 覆盖全站。
- 为未来可能性提前设计复杂插件系统。

## 13. 最终判断

旧系统：

```text
保留 Umi Max
补 Merchant UI
逐步治理复杂表格和页面模式
```

新系统：

```text
不用 Umi Max 做核心
用轻应用壳
把核心资产放到 Merchant UI、Page Schema、Domain Schema、State Machine、Table Engine
```

一句话：

```text
新系统不要围绕框架设计，要围绕业务模型、页面 Schema 和自有商户后台组件库设计。
```
