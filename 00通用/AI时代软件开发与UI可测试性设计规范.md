# AI 时代软件开发与 UI 可测试性设计规范

## 1. 文档目的

本文定义一套面向 AI 开发、前后端分离系统、Web 前端和微信小程序的 UI 可测试性设计规范。

目标不是让测试平台“更像人一样点页面”，而是让软件在设计和开发阶段就提供稳定的测试契约，使测试平台能够自动、重复、可靠地证明关键业务能力仍然正确。

核心原则：

```text
业务系统提供稳定测试契约。
测试平台验证测试契约是否成立。
自动化证据决定功能是否完成。
```

本文重点覆盖：

- 前端如何设计稳定 UI 测试选择器。
- 对话框、列表、异步状态如何可测试。
- 测试平台如何确认“点击了哪个按钮”。
- Web 和微信小程序测试桥如何通信。
- 正式包如何剥离测试属性。
- AI 开发如何按可测试性标准验收。

## 2. 适用范围

适用于以下项目：

- Web 管理后台。
- SaaS 商户后台。
- C 端 Web 页面。
- 微信小程序。
- Taro / React / Vue / uni-app 前端。
- 使用 UI 自动化、接口自动化、端到端测试的平台。
- AI 参与开发、修改或生成前端功能的项目。

不适用于：

- 纯后端服务测试规范。
- 视觉还原类设计规范。
- 不需要自动化测试的一次性页面。

## 3. 合格软件的可测试性标准

合格软件不只是“能运行”，还必须能够被证明正确。

最低标准：

1. 核心流程可自动化验证。
2. 关键业务状态可观察。
3. 关键 UI 元素可稳定定位。
4. 测试数据可构造、可隔离、可清理。
5. 异步流程可等待，不依赖固定 sleep。
6. 外部依赖可 mock、sandbox 或替换。
7. 失败场景可复现。
8. 正式包和测试包的业务逻辑一致。
9. 测试证据能说明失败原因。
10. 不能被自动化验证的核心能力，不能视为真正完成。

## 4. 软件开发与测试平台的协同关系

测试平台不是开发结束后的补丁，而是软件架构的一部分。

正确关系：

```text
业务系统暴露稳定契约
测试平台验证稳定契约

业务系统暴露状态和事件
测试平台断言状态和事件

业务系统支持数据隔离
测试平台构造测试场景

业务系统持续演进
测试平台持续防止回归
```

一个功能完成时，应同时具备：

- 业务实现。
- 接口契约。
- UI 测试选择器。
- 关键状态断言点。
- 测试数据方案。
- 自动化用例。
- 异常场景验证。
- 发布前回归命令。
- 未覆盖风险说明。

## 5. 测试分层

UI 自动化不能承担所有测试职责。

推荐分层：

| 层级 | 验证目标 | 推荐方式 |
|---|---|---|
| 单元测试 | 业务规则、纯函数、状态转换 | Jest / Vitest / JUnit |
| 接口测试 | 入参、出参、错误码、业务结果 | HTTP/API 自动化 |
| 集成测试 | 数据库、缓存、MQ、第三方适配 | Test container / mock service |
| 组件测试 | 前端组件状态和交互 | Testing Library / component test |
| UI 自动化 | 关键用户路径是否可走通 | Playwright / Cypress / 小程序 automator |
| 合成监控 | 线上关键路径巡检 | 生产巡检脚本 |

UI 自动化适合：

- 登录。
- 权限切换。
- 下单。
- 支付。
- 退款。
- 审批。
- 搜索和筛选。
- 表单提交。
- 微信小程序关键路径。

UI 自动化不适合：

- 覆盖所有字段组合。
- 覆盖所有业务规则。
- 大量边界条件穷举。
- 替代接口测试。
- 替代单元测试。

## 6. 前端 UI 测试契约

### 6.1 测试选择器属性名

推荐统一使用：

```text
data-qa
```

理由：

- 短。
- 不绑定具体测试框架。
- 语义清楚。
- 适合企业内部长期治理。

也可以使用已有历史属性，例如：

```text
data-testid
data-test
data-cy
```

但一个项目内必须统一，不允许混用多个测试定位属性。

### 6.2 测试选择器命名

推荐格式：

```text
<scope>.<name>
```

复杂区域允许三段式：

```text
<scope>.<group>.<name>
```

示例：

```text
order.root
order.submit
order.phone
order.payStatus
order.form.phone
order.summary.total
orders.row
orders.refund
refund.dialog
refund.confirm
refund.cancel
member.card.balance
```

命名规则：

- 使用英文和数字。
- 使用点号分段。
- 分段内使用 lowerCamelCase。
- 默认两段，必要时三段。
- 单个值建议不超过 32 个字符。
- 不使用中文、空格、下划线、随机后缀。
- 不使用颜色、位置、顺序、样式命名。
- 不把订单号、会员号、商品 ID 等运行时业务值拼进选择器。

禁止示例：

```text
blue-button
right-btn
div-3
modal-ok
button1
order-submit-button
orders.row.ORD001
```

### 6.3 业务值与选择器分离

错误方式：

```html
<tr data-qa="orders.row.ORD001">
```

正确方式：

```html
<tr data-qa="orders.row" data-order-no="ORD001">
```

测试平台表达：

```text
找到 data-qa=orders.row 且 data-order-no=ORD001 的订单行。
```

业务属性示例：

```text
data-order-no
data-member-id
data-product-id
data-task-id
```

业务属性不得在正式包剥离时被误删。

### 6.4 组件封装规则

业务页面负责声明稳定选择器值，基础组件只负责渲染。

推荐写法：

```tsx
<Button qa="order.submit">提交订单</Button>
<Input qa="order.phone" />
<Text qa="order.payStatus">{statusText}</Text>
```

基础组件内部：

```tsx
function Button(props) {
  return <button data-qa={props.qa}>{props.children}</button>
}
```

这里的 `props.qa` 只是组件内部透传，不代表业务层可以随意传动态变量。

大型项目可以使用集中常量表：

```ts
export const QA = {
  order: {
    root: 'order.root',
    submit: 'order.submit',
    phone: 'order.phone',
    payStatus: 'order.payStatus',
  },
  refund: {
    dialog: 'refund.dialog',
    confirm: 'refund.confirm',
    cancel: 'refund.cancel',
  },
} as const
```

业务页面：

```tsx
<Button qa={QA.order.submit}>提交订单</Button>
```

禁止写法：

```tsx
<Button qa={qaId}>提交订单</Button>
<Button qa={props.qa}>提交订单</Button>
<Button qa={`order.${action}`}>提交订单</Button>
<Button qa={`orders.row.${orderNo}`}>退款</Button>
```

禁止原因：

- `qaId` 来源不明，测试平台无法稳定定位。
- 模板字符串不可枚举、不可审查。
- 拼入业务值会导致选择器随数据变化。
- 父级随意透传会破坏组件测试契约。

### 6.5 静态检查要求

建议加入 ESLint / AST 规则：

- 禁止 `qa` / `data-qa` 使用模板字符串。
- 禁止 `qa` / `data-qa` 使用字符串拼接。
- 禁止 `qa` / `data-qa` 拼入运行时业务值。
- 禁止业务页面传入来源不明的 `qaId`。
- 允许字面量。
- 允许集中常量表。

示例规则口径：

```text
允许：qa="order.submit"
允许：qa={QA.order.submit}
禁止：qa={qaId}
禁止：qa={`order.${action}`}
禁止：data-qa={`orders.row.${orderNo}`}
```

## 7. 页面状态设计

页面状态必须可见、可等、可断言。

推荐状态选择器：

```text
order.ready
order.loading
order.empty
order.error
order.submit
order.submitOk
order.submitError
pay.processing
pay.success
pay.failed
permission.denied
```

测试平台应该：

```text
等待 order.ready
点击 order.submit
等待 order.submitOk
验证 order.status = 已提交
```

不应该：

```text
点击按钮后 sleep 5 秒
```

固定等待只能作为兜底超时，不能作为业务完成信号。

## 8. 列表测试规范

列表测试不能依赖顺序。

错误方式：

```text
点击第三行第二个按钮
```

正确方式：

```text
找到订单号 ORD001 的订单行。
点击该行的退款按钮。
验证该行状态变为退款中。
```

HTML 示例：

```html
<tr data-qa="orders.row" data-order-no="ORD001">
  <td data-qa="orders.payStatus">已支付</td>
  <button data-qa="orders.refund">退款</button>
</tr>
```

小程序示例：

```xml
<view data-qa="orders.row" data-order-no="{{order.orderNo}}">
  <text data-qa="orders.payStatus">{{order.statusName}}</text>
  <button data-qa="orders.refund">退款</button>
</view>
```

## 9. 对话框测试规范

### 9.1 基本原则

对话框测试必须首先证明：

```text
测试平台明确点击了哪个按钮。
```

不能通过结果倒推：

```text
弹窗关闭了，所以可能点了取消。
状态变了，所以可能点了确定。
```

正确证据链：

```text
1. 测试平台 action log：点击 refund.confirm
2. 前端测试桥事件：dialog.action refund confirm
3. 网络证据：发起退款确认请求
4. 业务证据：订单状态变为退款中
5. UI 证据：弹窗关闭或进入成功状态
```

### 9.2 对话框选择器

示例：

```html
<div data-qa="refund.dialog" role="dialog">
  <button data-qa="refund.cancel">取消</button>
  <button data-qa="refund.confirm">确定</button>
  <button data-qa="refund.close">关闭</button>
</div>
```

命名规则：

```text
<dialogScope>.dialog
<dialogScope>.confirm
<dialogScope>.cancel
<dialogScope>.close
<dialogScope>.error
```

示例：

```text
refund.dialog
refund.confirm
refund.cancel
refund.close
refund.error
delete.dialog
delete.confirm
delete.cancel
```

### 9.3 确定路径

测试步骤：

```text
1. 等待 refund.dialog 可见。
2. 点击 refund.confirm。
3. 记录 action log：clicked refund.confirm。
4. 读取测试桥事件：dialog.action refund confirm。
5. 断言发起 /refund/confirm 请求。
6. 断言请求参数正确。
7. 断言订单状态变为退款中。
8. 断言弹窗关闭或进入成功状态。
```

### 9.4 取消路径

测试步骤：

```text
1. 等待 refund.dialog 可见。
2. 点击 refund.cancel。
3. 记录 action log：clicked refund.cancel。
4. 读取测试桥事件：dialog.action refund cancel。
5. 断言没有发起 /refund/confirm 请求。
6. 断言订单状态不变。
7. 断言弹窗关闭。
```

### 9.5 遮罩、关闭按钮和 ESC

如果对话框支持遮罩、关闭按钮或 ESC，必须区分动作：

```text
refund.close
refund.mask
refund.esc
```

测试桥事件：

```json
{
  "type": "dialog.action",
  "target": "refund.close",
  "dialogId": "refund",
  "action": "close"
}
```

不允许把所有关闭动作都归为 `cancel`，除非业务明确规定它们等价。

## 10. 测试桥与 UI 事件日志

### 10.1 测试桥用途

测试桥用于让测试平台读取前端测试包暴露的观测事件。

它解决的问题是：

```text
测试平台知道自己点击了 refund.confirm。
但还需要确认前端事件系统确实触发了 refund.confirm。
```

测试桥不是业务功能，不得被生产业务依赖。

### 10.2 事件格式

推荐格式：

```json
{
  "type": "dialog.action",
  "target": "refund.confirm",
  "dialogId": "refund",
  "action": "confirm",
  "time": 123456789
}
```

通用字段：

| 字段 | 含义 |
|---|---|
| `type` | 事件类型，例如 `dialog.action`、`form.submit`、`route.change` |
| `target` | 对应的 `data-qa` 值 |
| `time` | 事件时间戳 |
| `payload` | 可选业务上下文，不得包含敏感信息 |

对话框字段：

| 字段 | 含义 |
|---|---|
| `dialogId` | 对话框业务 ID |
| `action` | `confirm`、`cancel`、`close`、`mask`、`esc` |

### 10.3 Web 测试桥实现

测试包初始化：

```js
window.__TEST_BRIDGE__ = {
  events: [],
  pushEvent(event) {
    this.events.push(event)
  },
  getEvents() {
    return this.events
  },
  clearEvents() {
    this.events = []
  },
}
```

记录事件：

```js
window.__TEST_BRIDGE__.pushEvent({
  type: 'dialog.action',
  target: 'refund.confirm',
  dialogId: 'refund',
  action: 'confirm',
  time: Date.now(),
})
```

测试平台读取：

```ts
const events = await page.evaluate(() => {
  return window.__TEST_BRIDGE__.getEvents()
})
```

通信原理：

```text
测试平台 Node.js 进程
  -> 通过浏览器自动化协议
  -> 在页面 JavaScript Runtime 执行函数
  -> 读取 window.__TEST_BRIDGE__
  -> 将可序列化结果返回测试进程
```

### 10.4 微信小程序测试桥实现

小程序没有 `window`，可以挂在 `getApp()`。

测试包初始化：

```js
const app = getApp()

app.__TEST_BRIDGE__ = app.__TEST_BRIDGE__ || {
  events: [],
  pushEvent(event) {
    this.events.push(event)
  },
  getEvents() {
    return this.events
  },
  clearEvents() {
    this.events = []
  },
}
```

记录事件：

```js
getApp().__TEST_BRIDGE__.pushEvent({
  type: 'dialog.action',
  target: 'refund.confirm',
  dialogId: 'refund',
  action: 'confirm',
  time: Date.now(),
})
```

测试平台读取：

```js
const events = await miniProgram.evaluate(() => {
  return getApp().__TEST_BRIDGE__.getEvents()
})
```

通信原理：

```text
测试平台 Node.js 进程
  -> 通过 miniprogram-automator / DevTools 自动化连接
  -> 在小程序 JavaScript Runtime 执行函数
  -> 读取 getApp().__TEST_BRIDGE__
  -> 将可序列化结果返回测试进程
```

### 10.5 测试桥限制

限制：

- 只在开发包、测试包、预发包启用。
- 正式包默认关闭或编译期剥离。
- 返回值必须可序列化。
- 不返回 DOM 节点。
- 不返回函数。
- 不返回循环引用对象。
- 页面刷新、路由重建、小程序分包切换后事件缓存可能丢失。
- 测试平台应在关键步骤前调用 `clearEvents()`，避免读取旧事件。
- 事件 payload 不得包含手机号、身份证、token、支付凭证等敏感信息。

## 11. 测试选择器剥离规范

### 11.1 构建矩阵

| 包类型 | `data-qa` | 测试桥 | 用途 |
|---|---|---|---|
| 本地开发包 | 保留 | 可启用 | 本地调试 |
| 自动化测试包 | 保留 | 启用 | UI / E2E 测试 |
| 预发包 | 默认保留 | 可启用 | 发布前验证 |
| 后台正式包 | 可保留或白名单 | 默认关闭 | 线上巡检可选 |
| C 端正式包 | 默认剥离 | 剥离 | 控制体积和暴露面 |
| 微信小程序正式包 | 默认剥离 | 剥离 | 控制包体积 |

### 11.2 剥离原则

正式包剥离必须在编译期完成。

推荐源码：

```tsx
<button data-qa="order.submit">提交订单</button>
```

正式产物：

```html
<button>提交订单</button>
```

禁止运行时判断：

```tsx
<button data-qa={isProd ? undefined : 'order.submit'}>提交订单</button>
```

原因：

- 污染业务代码。
- 容易让测试包和正式包逻辑不一致。
- 不利于静态扫描。
- 不能彻底减少产物复杂度。

### 11.3 React / Taro / JSX 剥离示例

Babel 插件示例：

```js
module.exports = function stripQaAttributes() {
  const attrs = new Set(['data-qa', 'data-testid', 'data-test', 'data-cy'])

  return {
    visitor: {
      JSXAttribute(path) {
        const name = path.node.name && path.node.name.name
        if (attrs.has(name)) {
          path.remove()
        }
      },
    },
  }
}
```

构建配置：

```js
plugins: [
  process.env.STRIP_QA === 'true' && './build/strip-qa-attributes.js',
].filter(Boolean)
```

Taro 小程序建议在 JSX 编译阶段剥离：

```text
TSX / JSX 源码
  -> Babel 删除 data-qa
  -> Taro 编译 WXML
  -> 正式 WXML 不含 data-qa
```

不推荐在 WXML 产物上用正则删除。

### 11.4 Vue / uni-app 剥离方式

可选方案：

- Vite 插件。
- Vue compiler node transform。
- 构建产物 AST transform。

原则：

```text
识别模板 AST 中的 data-qa。
只删除测试属性。
不删除业务 data-* 属性。
```

### 11.5 不得误删业务属性

允许剥离：

```text
data-qa
data-testid
data-test
data-cy
```

不得剥离：

```text
data-order-no
data-member-id
data-product-id
data-task-id
```

### 11.6 构建后产物检查

正式包必须扫描：

```text
不应残留 data-qa=
不应残留 data-testid=
不应残留 data-cy=
不应残留 __TEST_BRIDGE__
业务 data-order-no 不应被误删
业务 data-member-id 不应被误删
```

测试包必须扫描：

```text
关键页面应存在 data-qa
关键对话框应存在 confirm / cancel 选择器
测试桥应可读取事件
```

## 12. 前端架构分层与可测试性

推荐分层：

```text
Page 页面层：路由、权限、整体流程
Container 容器层：取数、提交、状态编排
Business Component 业务组件：订单表单、支付面板、商品列表
UI Component 展示组件：按钮、输入框、弹窗、表格
Service/API 层：请求封装
Domain/ViewModel 层：状态转换、金额格式化、按钮可用规则
```

测试分配：

| 层级 | 测试方式 |
|---|---|
| Domain / ViewModel | 单元测试 |
| Service / API | mock 测试、契约测试 |
| Business Component | 组件测试 |
| Page | UI 自动化、冒烟测试 |
| 后端接口 | 接口自动化、集成测试 |

不应只靠 UI 自动化验证：

- 金额计算。
- 优惠券可用规则。
- 权限判断。
- 按钮是否可点击。
- 订单状态转换。
- 表单校验规则。

## 13. 请求层与外部依赖设计

前端请求必须统一封装。

推荐：

```text
api/order.ts
api/member.ts
api/payment.ts
api/refund.ts
```

不推荐：

```text
页面中到处直接 fetch、axios、wx.request
```

统一请求层让测试平台可以模拟：

- 登录成功。
- 权限不足。
- 库存不足。
- 支付失败。
- 接口超时。
- 空列表。
- 分页数据。
- 后端返回脏数据。

微信小程序应封装：

```text
wx.request
wx.login
wx.getUserProfile
wx.scanCode
wx.requestPayment
```

## 14. 测试数据与测试环境

系统应支持：

- 创建测试租户。
- 创建测试门店。
- 创建测试会员。
- 创建测试商品。
- 创建测试订单。
- 使用 `testRunId` 隔离测试数据。
- 清理某次测试产生的数据。
- 重复清理不报错。

禁止长期依赖：

- 某个固定账号。
- 某条历史订单。
- 某个手工配置。
- 某个特定环境残留数据。

## 15. 测试辅助能力边界

可以提供：

- 测试环境 mock。
- 支付沙箱。
- 微信能力模拟器。
- 测试数据创建接口。
- 测试数据清理接口。
- 异步任务状态查询。
- 定时任务手动触发。
- 回调模拟入口。

要求：

- 只在测试环境启用。
- 需要测试权限。
- 有审计日志。
- 不影响生产。
- 不绕过真实业务规则。

禁止：

```js
if (isTest) {
  return success
}
```

正确方式是在边界层替换外部依赖，让真实业务逻辑仍然被测试。

## 16. 微信小程序特别规则

微信小程序 UI 自动化比 Web 更脆弱，因此必须更强调语义、状态和分层。

规则：

1. 页面根节点必须有页面标识。
2. 关键按钮、输入框、状态字段必须有 `data-qa`。
3. 列表项必须带业务唯一键。
4. 弹窗、loading、empty、error 必须可定位。
5. 请求层统一封装 `wx.request`。
6. 微信能力封装为 adapter。
7. 授权、扫码、支付、定位能力可模拟。
8. 复杂业务逻辑从 page.js 中抽出单测。
9. UI 自动化只做关键路径冒烟。
10. 大量业务规则交给接口测试和单元测试。

小程序业务动作默认使用元素 `tap()`，因为它更接近真实用户点击。测试平台不能默认使用坐标、`touchstart` / `touchend`、直接改 storage、直接调用页面方法来冒充用户行为。

`trigger('tap')` 只能作为例外进入正式测试平台代码。准入条件：

```text
[ ] 已确认当前页面状态正确。
[ ] 已通过源码确认事件绑定节点。
[ ] 已证明 tap() 在该事件节点上不稳定或无效。
[ ] 已证明 trigger('tap') 会产生和人工点击一致的请求、状态或 UI 事件。
[ ] 已封装为明确命名的原子能力，不散落在业务用例中。
[ ] 已写明为什么这里不能只用 tap()。
```

无论使用 `tap()` 还是 `trigger('tap')`，都不能把 API 没抛错当作业务成功。必须继续验证测试桥事件、页面状态、业务请求、业务数据或弹窗状态之一。

## 17. AI 开发规约

AI 开发必须遵守：

1. 修改前阅读现有代码、调用链、接口、配置和测试。
2. 保留旧逻辑兼容。
3. 不做无关重构。
4. 不新增无必要抽象。
5. 不新增无明确必要的依赖。
6. 不把猜测写成事实。
7. 不跳过测试直接声明完成。
8. 不写测试后门。
9. 必须说明自动化验证方式。
10. 必须说明回滚方案和未覆盖风险。

## 18. 验收清单

### 18.1 前端开发验收

```text
[ ] 页面根节点是否有稳定 data-qa？
[ ] 关键按钮是否有稳定 data-qa？
[ ] 关键输入框是否有稳定 data-qa？
[ ] 关键业务状态是否可断言？
[ ] 列表数据是否能按业务 key 定位？
[ ] 对话框 confirm / cancel / close 是否可区分？
[ ] 对话框动作是否写入测试桥事件？
[ ] 异步完成是否有明确状态？
[ ] 是否禁止固定 sleep 作为完成依据？
[ ] 选择器命名是否遵守 data-qa 规约？
[ ] 是否没有动态拼接 data-qa？
[ ] 正式包是否按策略剥离或白名单保留？
```

### 18.2 测试平台验收

```text
[ ] 是否能稳定创建测试数据？
[ ] 是否能稳定清理测试数据？
[ ] 是否能按业务 key 定位列表对象？
[ ] 是否能记录 action log？
[ ] 是否能读取 Web 测试桥？
[ ] 是否能读取小程序测试桥？
[ ] 是否能等待异步任务完成？
[ ] 是否能构造外部依赖失败？
[ ] 是否能输出失败截图、日志、接口响应、traceId？
[ ] 是否能区分业务失败、环境失败和测试脚本失败？
[ ] 是否能适配测试包保留选择器、正式包剥离选择器？
```

### 18.3 发布验收

```text
[ ] 测试包 UI 自动化通过。
[ ] 正式包冒烟测试通过。
[ ] 正式包已扫描确认 data-qa 被按策略处理。
[ ] 正式包已扫描确认 __TEST_BRIDGE__ 未残留。
[ ] 业务 data-* 属性未被误删。
[ ] 本次修改相关接口测试通过。
[ ] 本次修改相关单元测试通过。
[ ] 未覆盖风险已记录。
```

## 19. 推荐治理机制

建议团队建立：

1. 前端组件 `qa` 属性规范。
2. `data-qa` 命名规范。
3. `QA` 常量表或静态选择器清单。
4. ESLint / AST 静态检查。
5. 测试桥标准实现。
6. 对话框事件标准。
7. 测试包与正式包构建矩阵。
8. 正式包剥离扫描门禁。
9. UI 自动化证据报告标准。
10. AI 开发验收模板。

## 20. 可直接执行的开发与评审方案

本章用于直接指导人类开发、AI 生成代码和代码评审。开发者可以照此编写前端代码；评审者可以照此检查代码是否具备 UI 可测试性。

### 20.1 开发必须交付的内容

每个涉及 UI 的功能，开发完成时必须同时交付：

```text
[ ] 页面或区域根节点 data-qa。
[ ] 关键按钮 data-qa。
[ ] 关键输入框 data-qa。
[ ] 关键状态 data-qa。
[ ] 列表行 data-qa + 业务唯一属性。
[ ] 对话框 confirm / cancel / close data-qa。
[ ] 对话框动作测试桥事件。
[ ] 异步完成状态。
[ ] 测试数据准备方式。
[ ] UI 自动化或可重复验证用例。
[ ] 正式包剥离策略说明。
```

如果一个功能无法提供以上内容，必须说明原因和替代验证方式。

### 20.2 推荐工程目录

React / Taro / Web 项目推荐：

```text
src/
  qa/
    selectors.ts
    testBridge.ts
    emitTestEvent.ts
  components/
    Button.tsx
    Input.tsx
    ConfirmDialog.tsx
  pages/
    order/
      OrderDetail.tsx
build/
  strip-qa-attributes.js
  check-production-artifacts.js
tests/
  e2e/
    helpers/
      qa.ts
      testBridge.ts
      actionLog.ts
    order-refund.spec.ts
```

### 20.3 选择器常量表模板

推荐文件：`src/qa/selectors.ts`

```ts
export const QA = {
  order: {
    root: 'order.root',
    ready: 'order.ready',
    loading: 'order.loading',
    submit: 'order.submit',
    phone: 'order.phone',
    status: 'order.status',
    payStatus: 'order.payStatus',
    total: 'order.total',
  },
  orders: {
    row: 'orders.row',
    refund: 'orders.refund',
    payStatus: 'orders.payStatus',
  },
  refund: {
    dialog: 'refund.dialog',
    confirm: 'refund.confirm',
    cancel: 'refund.cancel',
    close: 'refund.close',
    error: 'refund.error',
  },
} as const

export type QaValue =
  | typeof QA.order[keyof typeof QA.order]
  | typeof QA.orders[keyof typeof QA.orders]
  | typeof QA.refund[keyof typeof QA.refund]
```

评审要求：

```text
[ ] 新增选择器是否进入 QA 常量表？
[ ] 是否符合 <scope>.<name> 或 <scope>.<group>.<name>？
[ ] 是否没有拼入订单号、会员号、商品 ID？
[ ] 是否没有使用颜色、位置、顺序命名？
```

### 20.4 基础组件模板

按钮组件：

```tsx
import type { ReactNode } from 'react'
import type { QaValue } from '../qa/selectors'

type ButtonProps = {
  qa?: QaValue
  disabled?: boolean
  loading?: boolean
  onClick?: () => void
  children: ReactNode
}

export function Button(props: ButtonProps) {
  return (
    <button
      data-qa={props.qa}
      disabled={props.disabled || props.loading}
      aria-busy={props.loading ? 'true' : undefined}
      onClick={props.onClick}
    >
      {props.children}
    </button>
  )
}
```

输入框组件：

```tsx
import type { QaValue } from '../qa/selectors'

type InputProps = {
  qa?: QaValue
  value: string
  placeholder?: string
  onChange: (value: string) => void
}

export function Input(props: InputProps) {
  return (
    <input
      data-qa={props.qa}
      value={props.value}
      placeholder={props.placeholder}
      onChange={(event) => props.onChange(event.target.value)}
    />
  )
}
```

评审要求：

```text
[ ] 基础组件是否只负责透传 qa？
[ ] 业务组件是否传入稳定字面量或 QA 常量？
[ ] 是否没有 qa={qaId} 这类来源不明变量？
[ ] 是否没有模板字符串拼接 qa？
```

### 20.5 业务页面模板

```tsx
import { QA } from '../../qa/selectors'
import { Button } from '../../components/Button'
import { Input } from '../../components/Input'

export function OrderDetailPage() {
  return (
    <main data-qa={QA.order.root}>
      <div data-qa={QA.order.ready} />

      <Input
        qa={QA.order.phone}
        value=""
        placeholder="会员手机号"
        onChange={() => {}}
      />

      <span data-qa={QA.order.status}>待提交</span>

      <Button qa={QA.order.submit} onClick={() => {}}>
        提交订单
      </Button>
    </main>
  )
}
```

列表模板：

```tsx
<tr data-qa={QA.orders.row} data-order-no={order.orderNo}>
  <td data-qa={QA.orders.payStatus}>{order.statusName}</td>
  <td>{order.amount}</td>
  <td>
    <Button qa={QA.orders.refund} onClick={() => openRefund(order)}>
      退款
    </Button>
  </td>
</tr>
```

评审要求：

```text
[ ] 页面根节点是否有 data-qa？
[ ] 关键状态是否有 data-qa？
[ ] 列表行是否使用 data-qa + 业务唯一属性？
[ ] 是否没有按行号、列号、DOM 层级作为测试依据？
```

### 20.6 测试桥模板

推荐文件：`src/qa/testBridge.ts`

```ts
export type TestEvent = {
  type: string
  target?: string
  time: number
  dialogId?: string
  action?: string
  payload?: Record<string, unknown>
}

type TestBridge = {
  events: TestEvent[]
  pushEvent: (event: TestEvent) => void
  getEvents: () => TestEvent[]
  clearEvents: () => void
}

declare global {
  interface Window {
    __TEST_BRIDGE__?: TestBridge
  }
}

export function installTestBridge() {
  if (process.env.ENABLE_TEST_BRIDGE !== 'true') {
    return
  }

  if (window.__TEST_BRIDGE__) {
    return
  }

  window.__TEST_BRIDGE__ = {
    events: [],
    pushEvent(event) {
      this.events.push(event)
    },
    getEvents() {
      return this.events.slice()
    },
    clearEvents() {
      this.events = []
    },
  }
}
```

推荐文件：`src/qa/emitTestEvent.ts`

```ts
import type { TestEvent } from './testBridge'

export function emitTestEvent(event: TestEvent) {
  if (process.env.ENABLE_TEST_BRIDGE !== 'true') {
    return
  }

  window.__TEST_BRIDGE__?.pushEvent(event)
}
```

入口安装：

```ts
import { installTestBridge } from './qa/testBridge'

installTestBridge()
```

评审要求：

```text
[ ] 测试桥是否只在测试包启用？
[ ] 正式包是否关闭或剥离？
[ ] 事件 payload 是否不包含敏感信息？
[ ] 是否提供 clearEvents，避免读取旧事件？
```

### 20.7 对话框组件模板

```tsx
import type { ReactNode } from 'react'
import type { QaValue } from '../qa/selectors'
import { emitTestEvent } from '../qa/emitTestEvent'

type ConfirmDialogProps = {
  dialogId: string
  qa: QaValue
  confirmQa: QaValue
  cancelQa: QaValue
  closeQa?: QaValue
  errorQa?: QaValue
  title: string
  open: boolean
  loading?: boolean
  error?: string
  onConfirm: () => void
  onCancel: () => void
  onClose?: () => void
  children?: ReactNode
}

export function ConfirmDialog(props: ConfirmDialogProps) {
  if (!props.open) {
    return null
  }

  const emitDialogAction = (target: QaValue, action: string) => {
    emitTestEvent({
      type: 'dialog.action',
      target,
      dialogId: props.dialogId,
      action,
      time: Date.now(),
    })
  }

  return (
    <div data-qa={props.qa} role="dialog" aria-modal="true">
      <h2>{props.title}</h2>
      {props.children}

      {props.error && props.errorQa ? (
        <div data-qa={props.errorQa}>{props.error}</div>
      ) : null}

      <button
        data-qa={props.cancelQa}
        disabled={props.loading}
        onClick={() => {
          emitDialogAction(props.cancelQa, 'cancel')
          props.onCancel()
        }}
      >
        取消
      </button>

      <button
        data-qa={props.confirmQa}
        disabled={props.loading}
        aria-busy={props.loading ? 'true' : undefined}
        onClick={() => {
          emitDialogAction(props.confirmQa, 'confirm')
          props.onConfirm()
        }}
      >
        确定
      </button>

      {props.closeQa && props.onClose ? (
        <button
          data-qa={props.closeQa}
          disabled={props.loading}
          onClick={() => {
            emitDialogAction(props.closeQa, 'close')
            props.onClose?.()
          }}
        >
          关闭
        </button>
      ) : null}
    </div>
  )
}
```

业务使用：

```tsx
<ConfirmDialog
  dialogId="refund"
  qa={QA.refund.dialog}
  confirmQa={QA.refund.confirm}
  cancelQa={QA.refund.cancel}
  closeQa={QA.refund.close}
  errorQa={QA.refund.error}
  title="确认退款"
  open={refundDialogOpen}
  loading={refundSubmitting}
  error={refundError}
  onConfirm={submitRefund}
  onCancel={closeRefundDialog}
  onClose={closeRefundDialog}
/>
```

评审要求：

```text
[ ] confirm / cancel / close 是否有独立 qa？
[ ] 点击 confirm 是否 emit dialog.action confirm？
[ ] 点击 cancel 是否 emit dialog.action cancel？
[ ] 点击 close 是否 emit dialog.action close？
[ ] 是否没有通过弹窗关闭反推用户动作？
[ ] 失败状态是否留在弹窗内并有 errorQa？
```

### 20.8 Playwright helper 模板

`tests/e2e/helpers/qa.ts`：

```ts
import type { Locator, Page } from '@playwright/test'

export function byQa(page: Page, qa: string): Locator {
  return page.locator(`[data-qa="${qa}"]`)
}

export function rowByBusinessKey(
  page: Page,
  rowQa: string,
  attr: string,
  value: string,
): Locator {
  return page.locator(`[data-qa="${rowQa}"][${attr}="${value}"]`)
}
```

`tests/e2e/helpers/actionLog.ts`：

```ts
type ActionLog = {
  type: 'ui.click'
  target: string
  selector: string
  time: number
}

export const actionLogs: ActionLog[] = []

export function recordClick(target: string, selector: string) {
  actionLogs.push({
    type: 'ui.click',
    target,
    selector,
    time: Date.now(),
  })
}
```

`tests/e2e/helpers/clickQa.ts`：

```ts
import type { Page } from '@playwright/test'
import { byQa } from './qa'
import { recordClick } from './actionLog'

export async function clickQa(page: Page, qa: string) {
  const selector = `[data-qa="${qa}"]`
  const locator = byQa(page, qa)

  await locator.waitFor({ state: 'visible' })
  await locator.click()
  recordClick(qa, selector)
}
```

`tests/e2e/helpers/testBridge.ts`：

```ts
import type { Page } from '@playwright/test'

export async function clearTestEvents(page: Page) {
  await page.evaluate(() => {
    window.__TEST_BRIDGE__?.clearEvents()
  })
}

export async function getTestEvents(page: Page) {
  return page.evaluate(() => {
    return window.__TEST_BRIDGE__?.getEvents() || []
  })
}

export async function lastTestEvent(page: Page, type: string) {
  const events = await getTestEvents(page)
  return [...events].reverse().find((event) => event.type === type)
}
```

### 20.9 对话框 E2E 用例模板

确定路径：

```ts
import { expect, test } from '@playwright/test'
import { byQa } from './helpers/qa'
import { clickQa } from './helpers/clickQa'
import { clearTestEvents, lastTestEvent } from './helpers/testBridge'

test('refund confirm should trigger confirm action and update order status', async ({ page }) => {
  await page.goto('/orders/ORD001')
  await clearTestEvents(page)

  await clickQa(page, 'orders.refund')
  await expect(byQa(page, 'refund.dialog')).toBeVisible()

  const refundRequest = page.waitForRequest((request) => {
    return request.url().includes('/refund/confirm')
  })

  await clickQa(page, 'refund.confirm')

  const event = await lastTestEvent(page, 'dialog.action')
  expect(event).toMatchObject({
    target: 'refund.confirm',
    dialogId: 'refund',
    action: 'confirm',
  })

  await refundRequest

  await expect(byQa(page, 'orders.payStatus')).toHaveText('退款中')
  await expect(byQa(page, 'refund.dialog')).toBeHidden()
})
```

取消路径：

```ts
test('refund cancel should not call confirm api', async ({ page }) => {
  await page.goto('/orders/ORD001')
  await clearTestEvents(page)

  const requests: string[] = []
  page.on('request', (request) => {
    requests.push(request.url())
  })

  await clickQa(page, 'orders.refund')
  await expect(byQa(page, 'refund.dialog')).toBeVisible()

  await clickQa(page, 'refund.cancel')

  const event = await lastTestEvent(page, 'dialog.action')
  expect(event).toMatchObject({
    target: 'refund.cancel',
    dialogId: 'refund',
    action: 'cancel',
  })

  expect(requests.some((url) => url.includes('/refund/confirm'))).toBe(false)
  await expect(byQa(page, 'orders.payStatus')).toHaveText('已支付')
  await expect(byQa(page, 'refund.dialog')).toBeHidden()
})
```

### 20.10 小程序 automator helper 模板

读取测试桥：

```js
async function getMiniappTestEvents(miniProgram) {
  return miniProgram.evaluate(() => {
    const app = getApp()
    return app.__TEST_BRIDGE__ ? app.__TEST_BRIDGE__.getEvents() : []
  })
}

async function clearMiniappTestEvents(miniProgram) {
  return miniProgram.evaluate(() => {
    const app = getApp()
    if (app.__TEST_BRIDGE__) {
      app.__TEST_BRIDGE__.clearEvents()
    }
  })
}
```

点击 helper：

```js
async function tapQa(page, qa, actionLogs) {
  const selector = `[data-qa="${qa}"]`
  const element = await page.$(selector)

  if (!element) {
    throw new Error(`element not found: ${selector}`)
  }

  await element.tap()

  actionLogs.push({
    type: 'ui.tap',
    target: qa,
    selector,
    time: Date.now(),
  })
}
```

小程序点击 helper 的默认实现必须保持 `element.tap()`。如果某个原子能力确实需要 `trigger('tap')`，必须单独封装，例如 `tapDishAddEventNode()`，并在代码注释或测试说明中写明源码事件绑定节点和验证证据。禁止把 `trigger('tap')` 加进通用 `tapQa()`，否则会让所有点击绕过真实用户交互条件。

对话框测试片段：

```js
const actionLogs = []

await clearMiniappTestEvents(miniProgram)

await tapQa(page, 'orders.refund', actionLogs)
await tapQa(page, 'refund.confirm', actionLogs)

const events = await getMiniappTestEvents(miniProgram)
const lastDialogEvent = [...events]
  .reverse()
  .find((event) => event.type === 'dialog.action')

expect(lastDialogEvent).toMatchObject({
  target: 'refund.confirm',
  dialogId: 'refund',
  action: 'confirm',
})
```

### 20.11 Babel 剥离插件模板

`build/strip-qa-attributes.js`：

```js
module.exports = function stripQaAttributes() {
  const attrs = new Set([
    'data-qa',
    'data-testid',
    'data-test',
    'data-cy',
  ])

  return {
    name: 'strip-qa-attributes',
    visitor: {
      JSXAttribute(path) {
        const nameNode = path.node.name
        const attrName = nameNode && nameNode.name

        if (typeof attrName === 'string' && attrs.has(attrName)) {
          path.remove()
        }
      },
      MemberExpression(path) {
        const object = path.node.object
        const property = path.node.property

        if (
          object &&
          object.type === 'Identifier' &&
          object.name === 'window' &&
          property &&
          property.type === 'Identifier' &&
          property.name === '__TEST_BRIDGE__'
        ) {
          path.replaceWithSourceString('undefined')
        }
      },
    },
  }
}
```

说明：

- JSX 属性删除适用于 React / Taro。
- `window.__TEST_BRIDGE__` 替换适用于 Web。
- 小程序 `getApp().__TEST_BRIDGE__` 建议通过测试桥正式包空实现处理。

### 20.12 测试桥正式包空实现

测试包：

```ts
export function emitTestEvent(event) {
  window.__TEST_BRIDGE__?.pushEvent(event)
}
```

正式包：

```ts
export function emitTestEvent() {
  // production noop
}
```

构建别名：

```js
resolve: {
  alias: {
    '@qa/emitTestEvent': process.env.ENABLE_TEST_BRIDGE === 'true'
      ? './src/qa/emitTestEvent.test.ts'
      : './src/qa/emitTestEvent.prod.ts',
  },
}
```

### 20.13 产物扫描脚本模板

`build/check-production-artifacts.js`：

```js
const fs = require('fs')
const path = require('path')

const root = process.argv[2]

if (!root) {
  console.error('usage: node build/check-production-artifacts.js <dist>')
  process.exit(1)
}

const forbidden = [
  'data-qa=',
  'data-testid=',
  'data-test=',
  'data-cy=',
  '__TEST_BRIDGE__',
]

function walk(dir) {
  const result = []
  for (const name of fs.readdirSync(dir)) {
    const file = path.join(dir, name)
    const stat = fs.statSync(file)
    if (stat.isDirectory()) {
      result.push(...walk(file))
    } else if (/\.(js|html|wxml|xml|css)$/.test(file)) {
      result.push(file)
    }
  }
  return result
}

const files = walk(root)
const violations = []

for (const file of files) {
  const text = fs.readFileSync(file, 'utf8')

  for (const pattern of forbidden) {
    if (text.includes(pattern)) {
      violations.push(`${file}: contains ${pattern}`)
    }
  }
}

if (violations.length > 0) {
  console.error(violations.join('\n'))
  process.exit(1)
}

console.log(`production artifact check passed: ${files.length} files scanned`)
```

### 20.14 package.json 命令模板

```json
{
  "scripts": {
    "build:test": "ENABLE_TEST_BRIDGE=true STRIP_QA=false vite build --mode test",
    "build:prod": "ENABLE_TEST_BRIDGE=false STRIP_QA=true vite build --mode production",
    "check:prod-artifact": "node build/check-production-artifacts.js dist",
    "test:e2e": "playwright test",
    "release:verify": "npm run build:test && npm run test:e2e && npm run build:prod && npm run check:prod-artifact"
  }
}
```

Taro 小程序：

```json
{
  "scripts": {
    "build:weapp:test": "ENABLE_TEST_BRIDGE=true STRIP_QA=false taro build --type weapp --mode test",
    "build:weapp:prod": "ENABLE_TEST_BRIDGE=false STRIP_QA=true taro build --type weapp --mode production",
    "check:weapp-prod": "node build/check-production-artifacts.js dist"
  }
}
```

### 20.15 CI 模板

```yaml
name: frontend-quality-gate

on:
  pull_request:
  push:
    branches:
      - main

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm

      - run: npm ci
      - run: npm run lint
      - run: npm run test
      - run: npm run build:test
      - run: npm run test:e2e
      - run: npm run build:prod
      - run: npm run check:prod-artifact
```

### 20.16 代码评审清单

评审 UI 功能时，必须检查：

```text
[ ] 是否新增或复用了稳定 data-qa？
[ ] data-qa 是否来自字面量或 QA 常量表？
[ ] 是否禁止动态拼接 data-qa？
[ ] 列表是否使用 data-qa + 业务唯一属性？
[ ] 对话框 confirm / cancel / close 是否可区分？
[ ] 对话框点击是否写入测试桥事件？
[ ] 测试平台是否能读取该事件？
[ ] 异步流程是否有 ready / loading / success / failed 状态？
[ ] 是否避免固定 sleep？
[ ] 请求层是否可 mock？
[ ] 正式包是否能剥离测试属性？
[ ] 是否有对应 UI 自动化或可重复验证说明？
```

阻断级问题：

```text
[阻断] 核心按钮没有 data-qa。
[阻断] 对话框确定/取消无法区分。
[阻断] data-qa 拼接业务 ID。
[阻断] 测试只能靠坐标或 DOM 层级定位。
[阻断] 异步完成只能靠 sleep。
[阻断] 正式包无法剥离测试桥。
[阻断] 测试桥事件包含敏感信息。
```

### 20.17 AI 开发交付模板

AI 完成前端功能后，最终说明必须包含：

```text
变更目标：

涉及页面：

新增 / 修改的 data-qa：

新增 / 修改的测试桥事件：

对话框动作证据：

列表业务 key：

测试数据：

自动化用例：

测试包验证：

正式包剥离验证：

保留的旧逻辑：

回滚方案：

未覆盖风险：
```

### 20.18 最小落地路线

已有系统不要一次性全量改造，推荐从一个核心流程开始。

第一阶段：

```text
1. 选择退款流程。
2. 给订单详情页补 order.root。
3. 给订单行补 orders.row + data-order-no。
4. 给退款按钮补 orders.refund。
5. 给退款弹窗补 refund.dialog / refund.confirm / refund.cancel。
6. 接入测试桥，只记录 dialog.action。
7. 写确认退款和取消退款两条 UI 自动化。
8. 增加正式包剥离插件。
9. 增加产物扫描门禁。
```

第一阶段验收：

```text
[ ] 退款确认路径可自动化验证。
[ ] 退款取消路径可自动化验证。
[ ] 测试包保留 data-qa 和测试桥。
[ ] 正式包不残留 data-qa 和 __TEST_BRIDGE__。
[ ] 业务 data-order-no 未被误删。
```

第二阶段：

```text
推广到下单、支付、审批、登录、权限切换等核心链路。
```

## 21. 架构师结论

易于 UI 测试的前端，不是让测试平台更聪明地模拟人的眼睛和手，而是让前端成为一个有稳定契约的交互系统。

最终目标：

```text
页面可定位。
状态可观察。
动作可确认。
数据可隔离。
依赖可替换。
产物可剥离。
结果可证明。
```

一句话总结：

```text
AI 写代码，人和规约定义契约，测试平台负责裁判，自动化证据决定是否完成。
```
