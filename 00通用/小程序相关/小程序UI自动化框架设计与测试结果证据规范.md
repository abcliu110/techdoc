# 小程序 UI 自动化框架设计与测试结果证据规范

## 1. 文档目的

本文记录新小程序项目如何从 0 开始设计一套完整、可执行、可维护、可验收的 UI 自动化框架。

本文不讨论老项目如何补丁式改造。本文面向新项目，目标是在开发阶段就内建 UI 可测试性能力，而不是等页面写完后再让测试平台靠坐标、截图、文案或页面层级去猜。

核心结论：

```text
小程序提供稳定测试契约。
测试平台按契约执行动作。
后端提供业务查询证据。
证据包决定测试是否通过。
正式包剥离测试辅助能力。
```

最终目标：

```text
页面可定位。
状态可等待。
动作可追踪。
请求可关联。
业务结果可查询。
失败可归因。
证据可复现。
测试能力可剥离。
发布可门禁。
```

## 2. 小程序 UI 自动化和其他 UI 自动化的区别

小程序 UI 自动化和 Web / App UI 自动化的核心区别是：小程序不是浏览器页面，也不是原生 App，而是运行在微信受控运行时中。

| 维度 | Web UI 自动化 | 原生 App 自动化 | 小程序 UI 自动化 |
|---|---|---|---|
| 运行环境 | 浏览器 | Android / iOS App | 微信客户端 / 微信开发者工具 |
| 自动化工具 | Playwright / Cypress | Appium / Espresso / XCUITest | miniprogram-automator / DevTools 自动化 |
| 页面结构 | 标准 DOM | 原生控件树 | 小程序运行时节点 |
| JS 执行 | `page.evaluate()` 访问 `window` | 通常不能直接访问页面 JS | `miniProgram.evaluate()` 访问 `getApp()` |
| 路由 | 前端自由路由 | App 自己控制 | 页面必须在 `app.json` 或分包配置中注册 |
| tab 机制 | 普通组件 | 原生或自定义 | `tabBar` 由微信托管 |
| 点击语义 | `click()` 接近浏览器行为 | 真实触控或控件动作 | `tap()` 不总等同完整手指触摸链路 |
| 原生能力 | 浏览器 API | 系统 API | 微信 API：登录、支付、授权、扫码、定位 |
| 网络限制 | CORS / 浏览器安全 | App 自己控制 | 合法域名、HTTPS、微信审核 |
| 构建产物 | HTML / JS / CSS | APK / IPA | 小程序包，受包体和审核限制 |

小程序自动化的特殊点：

1. 小程序没有标准 DOM，不能照搬 Web DOM 测试思路。
2. 页面必须先注册，`navigateTo`、`switchTab`、`redirectTo`、`reLaunch` 有严格边界。
3. `tabBar` 是微信托管的一级导航，切换回来通常触发 `onShow`，不一定触发 `onLoad`。
4. `tap()` 更接近用户点击，`trigger()` 更像直接触发事件入口，二者必须分层使用。
5. 微信登录、手机号授权、支付、扫码、定位等能力不能当普通前端函数测试，必须区分真实链路、沙箱、mock 和回调逻辑。

一句话总结：

```text
Web 自动化更像操作浏览器 DOM。
App 自动化更像操作原生控件。
小程序自动化更像在微信受控运行时里验证页面契约、事件、生命周期和微信能力边界。
```

## 3. 总体架构

完整的小程序 UI 自动化框架分成两部分：

```text
小程序内置测试契约
+ 测试平台执行器
```

整体链路：

```text
miniapp source
  -> data-qa / page-state / testBridge / request trace
  -> build:weapp:test

automation runner
  -> 启动微信开发者工具
  -> 连接 miniprogram-automator
  -> 执行业务用例
  -> 采集 actionLog / uiEvents / apiEvents / backendEvidence / screenshot
  -> 输出 evidence.json
```

核心证据链：

```text
tapQa("refund.confirm")
-> actionLog 记录测试平台点击 refund.confirm
-> 小程序 testBridge 记录 ui.dialog.confirm
-> request wrapper 记录 api.request / api.response
-> 后端查询订单、支付、退款等业务结果
-> 页面状态进入 success / failed
-> evidence.json 固化证据
```

推荐组合：

```text
data-qa 选择器契约
+ QA 常量表
+ 页面状态契约
+ 小程序测试桥 getApp().__TEST_BRIDGE__
+ 测试平台 actionLog
+ 请求/响应记录
+ 后端业务结果查询
+ evidence.json 证据包
+ failureClass 失败分类
+ 测试包保留测试契约
+ 正式包剥离测试契约
```

## 4. 推荐目录结构

新项目从一开始就建议建立以下目录。

```text
src/
  app.ts
  app.config.ts

  qa/
    selectors.ts
    testBridge.ts
    emitTestEvent.ts
    pageState.ts

  components/
    PageRoot.tsx
    Button.tsx
    Input.tsx
    ConfirmDialog.tsx

  services/
    request.ts
    order.ts
    payment.ts
    refund.ts
    member.ts

  adapters/
    wxLogin.ts
    wxPayment.ts
    wxScan.ts
    wxLocation.ts

tests/
  miniapp/
    config/
      env.ts
      cases.ts

    core/
      devtools.ts
      miniappDriver.ts
      runner.ts
      evidence.ts
      failureClass.ts

    helpers/
      qa.ts
      tapQa.ts
      triggerEvent.ts
      testBridge.ts
      actionLog.ts
      waitPageState.ts
      backendAssert.ts

    atoms/
      loginAtoms.ts
      orderAtoms.ts
      paymentAtoms.ts
      refundAtoms.ts

    specs/
      login.spec.ts
      order-submit.spec.ts
      payment.spec.ts
      refund.spec.ts

build/
  strip-qa-attributes.js
  check-production-artifacts.js

artifacts/
  <runId>/
    evidence.json
    final.png
    failure.png
```

目录职责：

| 目录 | 职责 |
|---|---|
| `src/qa` | 小程序测试契约、选择器、测试桥、事件上报 |
| `src/components` | 支持 `qa` 透传的基础组件 |
| `src/services` | 统一请求层，记录 traceId 和 API 事件 |
| `src/adapters` | 微信能力封装，便于 mock、sandbox、替换 |
| `tests/miniapp/core` | 自动化运行器、DevTools 连接、证据包、失败分类 |
| `tests/miniapp/helpers` | 通用定位、点击、等待、测试桥读取、后端断言 |
| `tests/miniapp/atoms` | 业务原子能力，不让用例直接写底层选择器 |
| `tests/miniapp/specs` | 业务用例 |
| `build` | 测试属性剥离和正式包产物检查 |

## 5. 小程序侧测试契约

### 5.1 `data-qa` 选择器

统一使用：

```text
data-qa
```

命名格式：

```text
<scope>.<name>
<scope>.<group>.<name>
```

示例：

```text
login.page
login.phone
login.submit
login.error

order.page
order.ready
order.submit
order.total
order.success

orders.row
orders.pay
orders.refund
orders.status

refund.dialog
refund.reason
refund.confirm
refund.cancel
refund.close
refund.error
refund.success

payment.page
payment.confirm
payment.success
payment.failed
```

禁止：

```text
button1
rightBtn
blueButton
order.row.202607030001
member.13000000000
product.10001.add
```

业务值必须和选择器分离。

正确：

```xml
<view data-qa="orders.row" data-order-no="{{order.orderNo}}">
  <button data-qa="orders.refund">退款</button>
</view>
```

错误：

```xml
<view data-qa="orders.row.{{order.orderNo}}">
  <button data-qa="orders.refund">退款</button>
</view>
```

### 5.2 QA 常量表

新项目必须集中定义选择器，避免字符串散落。

```ts
export const QA = {
  login: {
    page: 'login.page',
    phone: 'login.phone',
    submit: 'login.submit',
    error: 'login.error',
  },

  order: {
    page: 'order.page',
    ready: 'order.ready',
    submit: 'order.submit',
    total: 'order.total',
    success: 'order.success',
  },

  orders: {
    row: 'orders.row',
    pay: 'orders.pay',
    refund: 'orders.refund',
    status: 'orders.status',
  },

  refund: {
    dialog: 'refund.dialog',
    reason: 'refund.reason',
    confirm: 'refund.confirm',
    cancel: 'refund.cancel',
    close: 'refund.close',
    error: 'refund.error',
    success: 'refund.success',
  },

  payment: {
    page: 'payment.page',
    confirm: 'payment.confirm',
    success: 'payment.success',
    failed: 'payment.failed',
  },
} as const
```

评审规则：

```text
允许 qa={QA.order.submit}
允许 data-qa="order.submit"
禁止 qa={qaId}
禁止 qa={props.qa}
禁止 qa={`order.${action}`}
禁止把订单号、手机号、商品 ID 拼进 qa
```

### 5.3 页面状态契约

每个关键页面根节点必须有：

```text
data-qa="<scope>.page"
data-page-state="loading|ready|empty|error|submitting|success|failed"
```

示例：

```tsx
<View data-qa={QA.order.page} data-page-state={pageState}>
  {pageState === 'ready' && <OrderContent />}
  {pageState === 'error' && <ErrorView data-qa="order.error" />}
</View>
```

测试等待：

```ts
await waitPageState(page, 'order.page', 'ready')
```

禁止把固定等待作为业务完成信号：

```ts
await page.waitFor(3000)
```

正确方式：

```text
等待 page-state。
等待测试桥事件。
等待 API 响应。
等待后端业务状态。
等待页面结果节点。
```

### 5.4 小程序测试桥

小程序没有 `window`，测试桥挂到 `getApp()`。

```ts
export function installMiniappTestBridge() {
  if (process.env.ENABLE_TEST_BRIDGE !== 'true') {
    return
  }

  const app = getApp()

  if (app.__TEST_BRIDGE__) {
    return
  }

  app.__TEST_BRIDGE__ = {
    events: [],

    record(event) {
      this.events.push({
        ...event,
        time: Date.now(),
      })
    },

    getEvents() {
      return [...this.events]
    },

    clear() {
      this.events = []
    },
  }
}
```

事件上报：

```ts
export function emitTestEvent(event) {
  if (process.env.ENABLE_TEST_BRIDGE !== 'true') {
    return
  }

  getApp().__TEST_BRIDGE__?.record(event)
}
```

对话框确认：

```ts
emitTestEvent({
  type: 'ui.dialog.confirm',
  qa: QA.refund.confirm,
  dialog: QA.refund.dialog,
})
```

对话框取消：

```ts
emitTestEvent({
  type: 'ui.dialog.cancel',
  qa: QA.refund.cancel,
  dialog: QA.refund.dialog,
})
```

限制：

```text
测试桥只在测试包启用。
正式包剥离或空实现。
payload 不允许包含手机号、token、openid、支付签名、身份证。
每个关键步骤前先 clear events。
```

### 5.5 请求层事件

所有请求必须走统一请求层，不允许页面到处直接调用 `wx.request` 或 `Taro.request`。

测试包中请求层记录 API 事件：

```ts
emitTestEvent({
  type: 'api.response',
  url,
  method,
  success: body.success,
  code: body.code,
  traceId: body.traceId,
})
```

请求层职责：

```text
baseURL
token
bizId / appId / sid / mid
traceId
loading
错误码
登录刷新
响应转换
失败日志
测试包 API 事件上报
```

## 6. 基础组件设计

### 6.1 Button

基础组件只透传 `qa`，不拼接 `qa`。

```tsx
type ButtonProps = {
  qa?: string
  loading?: boolean
  disabled?: boolean
  onClick?: () => void
  children: React.ReactNode
}

export function Button(props: ButtonProps) {
  return (
    <ButtonNative
      data-qa={props.qa}
      disabled={props.disabled || props.loading}
      loading={props.loading}
      onClick={props.onClick}
    >
      {props.children}
    </ButtonNative>
  )
}
```

### 6.2 ConfirmDialog

对话框必须区分 confirm、cancel、close。

```tsx
type ConfirmDialogProps = {
  dialogQa: string
  confirmQa: string
  cancelQa: string
  closeQa?: string
  open: boolean
  loading?: boolean
  onConfirm: () => void
  onCancel: () => void
  onClose?: () => void
}

export function ConfirmDialog(props: ConfirmDialogProps) {
  if (!props.open) {
    return null
  }

  return (
    <View data-qa={props.dialogQa}>
      <Button
        qa={props.cancelQa}
        disabled={props.loading}
        onClick={() => {
          emitTestEvent({
            type: 'ui.dialog.cancel',
            qa: props.cancelQa,
            dialog: props.dialogQa,
          })
          props.onCancel()
        }}
      >
        取消
      </Button>

      <Button
        qa={props.confirmQa}
        loading={props.loading}
        onClick={() => {
          emitTestEvent({
            type: 'ui.dialog.confirm',
            qa: props.confirmQa,
            dialog: props.dialogQa,
          })
          props.onConfirm()
        }}
      >
        确定
      </Button>
    </View>
  )
}
```

不能只通过“弹窗关闭了”倒推用户点了确定还是取消。必须用：

```text
actionLog 证明测试平台点了哪个按钮。
uiEvents 证明前端收到哪个动作。
network 证明是否发起提交请求。
backendEvidence 证明业务状态是否变化。
```

## 7. 测试平台核心模块

### 7.1 miniappDriver

`miniappDriver` 负责连接小程序。

```ts
type MiniappDriver = {
  miniProgram: any
  currentPage(): Promise<any>
  pagePath(): Promise<string>
  screenshot(path: string): Promise<void>
  close(): Promise<void>
}
```

职责：

```text
启动或连接微信开发者工具。
连接 miniprogram-automator。
获取当前页面。
读取当前页面路径。
截图。
关闭连接。
```

### 7.2 tapQa

默认真实点击使用 `tap()`。

```ts
export async function tapQa(ctx, qa: string) {
  const selector = `[data-qa="${qa}"]`
  const page = await ctx.driver.currentPage()
  const el = await page.$(selector)

  if (!el) {
    throw new Error(`element not found: ${selector}`)
  }

  ctx.evidence.actionLog.push({
    type: 'ui.tap',
    qa,
    selector,
    time: new Date().toISOString(),
    result: 'start',
  })

  await el.tap()

  ctx.evidence.actionLog.push({
    type: 'ui.tap',
    qa,
    selector,
    time: new Date().toISOString(),
    result: 'success',
  })
}
```

禁止把 `trigger('tap')` 写进通用 `tapQa()`。

### 7.3 testBridge helper

读取前端事件：

```ts
export async function getUiEvents(miniProgram) {
  return miniProgram.evaluate(() => {
    return getApp().__TEST_BRIDGE__?.getEvents?.() ?? []
  })
}
```

清理事件：

```ts
export async function clearUiEvents(miniProgram) {
  return miniProgram.evaluate(() => {
    return getApp().__TEST_BRIDGE__?.clear?.()
  })
}
```

断言事件：

```ts
export async function expectUiEvent(ctx, expected) {
  const events = await getUiEvents(ctx.driver.miniProgram)

  const matched = events.some((event) => {
    return Object.entries(expected).every(([key, value]) => event[key] === value)
  })

  ctx.evidence.uiEvents = events

  if (!matched) {
    throw new Error(`ui event not found: ${JSON.stringify(expected)}`)
  }
}
```

### 7.4 waitPageState

```ts
export async function waitPageState(page, qa: string, state: string) {
  await page.waitFor(async () => {
    const el = await page.$(`[data-qa="${qa}"]`)
    if (!el) {
      return false
    }

    const value = await el.attribute('data-page-state')
    return value === state
  })
}
```

## 8. tap 和 trigger 的决策

### 8.1 默认使用 tap

默认：

```text
所有业务按钮、卡片、菜单优先使用 tap()
```

因为 `tap()` 更接近真实用户点击。

### 8.2 允许使用 trigger 的场景

| 场景 | 推荐方式 |
|---|---|
| 普通按钮 | `tap()` |
| 图片包在 button 内 | 操作外层 button，优先 `tap()` |
| picker | `trigger('change', { value })` |
| input | 输入方法或 `trigger('input', { value })` |
| switch | `trigger('change', { value: true })` |
| checkbox-group | `trigger('change', { value: [] })` |
| radio-group | `trigger('change', { value })` |
| 自定义组件 confirm | `trigger('confirm', detail)` |
| 授权回调逻辑 | `trigger('getphonenumber', detail)` |

### 8.3 trigger('tap') 准入条件

只有满足以下条件才允许 `trigger('tap')`：

```text
[ ] 已确认当前页面状态正确。
[ ] 已通过源码确认事件绑定节点。
[ ] 已证明 tap() 在该事件节点上不稳定或无效。
[ ] 已证明 trigger('tap') 会产生和人工点击一致的请求、状态或 UI 事件。
[ ] 已封装为明确命名的原子能力。
[ ] 已写明为什么这里不能只用 tap()。
```

禁止：

```text
通用 tapQa 内部默认用 trigger('tap')。
业务用例里散落 trigger('tap')。
直接 setData 冒充用户操作。
直接 callMethod 冒充点击。
点内部 image 而不是外层事件节点。
```

## 9. 业务原子能力

业务用例不直接写底层选择器，而是调用业务原子能力。

错误：

```ts
await page.$('button').tap()
await page.waitFor(3000)
```

正确：

```ts
await loginAsTestMember(ctx)
await openOrderPage(ctx)
await addDishToCart(ctx, 'E2E-AUTO-菜品')
await submitOrder(ctx)
await assertOrderCreated(ctx)
```

示例：

```ts
export async function submitOrder(ctx) {
  const page = await ctx.driver.currentPage()

  await waitPageState(page, 'order.page', 'ready')
  await clearUiEvents(ctx.driver.miniProgram)

  await tapQa(ctx, 'order.submit')

  await expectUiEvent(ctx, {
    type: 'ui.form.submit',
    qa: 'order.submit',
  })

  await waitPageState(page, 'order.page', 'success')
}
```

业务原子能力必须负责：

```text
定位。
点击或触发事件。
等待状态。
记录日志。
采集证据。
失败分类。
```

## 10. 如何快速高效执行 UI 测试

### 10.1 UI 测试只覆盖关键路径

UI 自动化慢且脆弱，不应该覆盖所有字段组合。

正确分工：

```text
UI 测试：证明用户主流程能走通。
接口测试：证明业务结果正确。
单元测试：证明规则计算正确。
证据包：证明失败原因在哪里。
```

### 10.2 数据准备走接口

不要每次用 UI 创建会员、商品、优惠券。

推荐：

```text
接口创建测试数据。
UI 只执行待验证的关键动作。
后端接口查询结果。
```

例如退款测试：

```text
接口创建已支付订单
-> 小程序打开订单详情
-> UI 点击退款
-> 接口查询退款状态
```

### 10.3 登录态复用

不要每条用例都完整授权登录。

推荐：

```text
suite 启动时登录一次。
保存 token / storage / openid 上下文。
每条用例校验登录态有效。
失效时统一刷新。
```

### 10.4 等待状态，不 sleep

错误：

```ts
await waitForTimeout(5000)
```

正确：

```ts
await waitPageState(page, 'order.page', 'ready')
await waitUiEvent(ctx, 'ui.dialog.confirm')
await waitApiResponse(ctx, '/refund/submit')
await waitBackendState(orderNo, 'REFUNDING')
```

### 10.5 主流程用 UI，非核心分支用事件级测试

主流程按钮保留真实 `tap()` 冒烟。

事件级测试可以用 `trigger()`：

```ts
await triggerQa(page, 'shop.picker', 'change', { value: 1 })
```

这种测试目标是验证：

```text
当指定事件带指定 detail 进入业务逻辑时，页面状态和提交参数是否正确。
```

不是验证：

```text
真实用户是否能打开 picker 原生弹层并选择。
```

## 11. 如何精确获取测试结果

UI 测试结果不能来自“脚本没报错”，必须来自证据链。

### 11.1 actionLog

actionLog 证明测试平台做了什么。

```json
{
  "type": "ui.tap",
  "qa": "refund.confirm",
  "selector": "[data-qa=\"refund.confirm\"]",
  "time": "2026-07-03T12:00:00+08:00",
  "result": "success"
}
```

作用：

```text
证明测试平台点的是 refund.confirm，不是取消按钮、关闭按钮或遮罩层。
```

### 11.2 uiEvents

uiEvents 证明前端实际收到了什么事件。

```json
{
  "type": "ui.dialog.confirm",
  "qa": "refund.confirm",
  "dialog": "refund.dialog",
  "time": 123456789
}
```

如果 actionLog 有点击，但 uiEvents 没有，通常归类为：

```text
frontend_interaction_failure
```

### 11.3 apiEvents

apiEvents 证明 UI 动作后发出了什么请求，返回了什么结果。

```json
{
  "type": "api.response",
  "url": "/refund/submit",
  "method": "POST",
  "success": true,
  "code": "SUCCESS",
  "traceId": "trace-xxx",
  "time": 123456789
}
```

如果 uiEvents 有，但 apiEvents 没有，说明前端业务逻辑没有发起预期请求。

### 11.4 backendEvidence

backendEvidence 证明后端业务结果真实变化。

```json
{
  "type": "backend.order",
  "orderNo": "202607030001",
  "beforeStatus": "PAID",
  "afterStatus": "REFUNDING",
  "refundAmount": 18.7,
  "traceId": "trace-xxx"
}
```

如果接口返回成功但后端状态没变，通常归类为：

```text
business_failure
```

### 11.5 uiState

uiState 证明用户最终看到正确状态。

```json
{
  "type": "ui.state",
  "qa": "refund.page",
  "state": "success"
}
```

### 11.6 精确判断模型

以“确认退款”为例：

```text
A1. 页面已 ready。
A2. 测试点击 refund.confirm。
A3. 前端收到 ui.dialog.confirm。
A4. 发起 /refund/submit 请求。
A5. 接口返回 success=true，带 traceId。
A6. 后端订单状态变为 REFUNDING。
A7. 页面显示 refund.success。
```

只有全部成立，才能判断用例通过。

## 12. 证据包设计

每条用例输出：

```json
{
  "runId": "run-20260703-001",
  "caseId": "refund-confirm-success",
  "status": "passed",
  "durationMs": 12345,
  "pagePath": "pages/order/detail",
  "actionLog": [],
  "uiEvents": [],
  "apiEvents": [],
  "backendEvidence": [],
  "assertions": [],
  "screenshots": [],
  "failureClass": "",
  "failureReason": "",
  "createdAt": "2026-07-03T12:00:00+08:00"
}
```

失败时必须有：

```text
最后一个 actionLog。
最后一批 uiEvents。
最后一批 apiEvents。
当前 pagePath。
截图。
failureClass。
failureReason。
```

## 13. 失败分类

失败必须分类，不能只说“失败”。

| failureClass | 含义 |
|---|---|
| `frontend_interaction_failure` | 元素找不到、点击未触发、弹窗动作错误 |
| `frontend_state_failure` | 页面状态错误、加载失败、白屏 |
| `backend_api_failure` | 接口 5xx、业务错误码、响应结构错误 |
| `business_failure` | 接口成功但业务状态不符合预期 |
| `test_data_failure` | 测试数据缺失、过期、污染 |
| `environment_failure` | 环境不可用、DevTools 连接失败、网络异常 |
| `automation_script_failure` | 测试脚本自身错误 |
| `third_party_failure` | 支付、短信、微信等第三方异常 |
| `assertion_failure` | 断言口径错误或预期不匹配 |

判断示例：

| 断点 | 失败分类 |
|---|---|
| 找不到按钮 | `frontend_interaction_failure` |
| 点了按钮但无 uiEvent | `frontend_interaction_failure` |
| 有 uiEvent 但没请求 | `frontend_state_failure` |
| 请求 5xx | `backend_api_failure` |
| 请求成功但业务状态不对 | `business_failure` |
| 数据不存在 | `test_data_failure` |
| 微信开发者工具连接失败 | `environment_failure` |
| 断言代码写错 | `automation_script_failure` |

## 14. 执行器流程

标准执行流程：

```text
1. 读取 case 配置。
2. 创建 runId。
3. 启动或连接微信开发者工具。
4. 连接 miniprogram-automator。
5. 清理测试桥事件。
6. 准备测试数据。
7. 执行业务 atoms。
8. 拉取 uiEvents / apiEvents。
9. 查询后端业务结果。
10. 截图。
11. 写 evidence.json。
12. 失败时分类并保存 failure.png。
13. 清理或归档测试数据。
```

## 15. 测试数据设计

必须有测试数据服务或脚本：

```text
createTestMerchant
createTestStore
createTestTable
createTestMember
createTestDish
createTestCoupon
createTestOrder
cleanupByRunId
```

所有测试数据必须带：

```text
testRunId
E2E-AUTO-<runId>
```

禁止依赖：

```text
长期固定历史订单。
固定手工配置。
生产用户。
会过期的券。
多人共享同一可变会员。
```

## 16. 路由与 tabBar 自动化规则

小程序自动化必须遵守真实路由机制。

| 场景 | API |
|---|---|
| 普通页面跳转 | `navigateTo` |
| 提交成功不回原页 | `redirectTo` |
| 跳 tabBar | `switchTab` |
| 登录失效 / 切门店 / 重置流程 | `reLaunch` |
| 返回 | `navigateBack` |

tabBar 规则：

```text
switchTab 不能带 query。
switchTab 会关闭非 tabBar 页面。
tabBar 页面切回来通常只触发 onShow，不触发 onLoad。
tabBar 数据刷新必须放 onShow / useDidShow。
```

自动化断言页面路径时要区分：

```text
tabBar 页面。
普通页面。
分包页面。
```

## 17. 小程序 DevTools 自动化连接规则

启动 DevTools 自动化时必须记录启动输出里的端口，后续只连接这个端口。

示例：

```text
cli auto --project <project> --port 9531 --trust-project
```

如果该端口监听但 `miniprogram-automator` 连不上，不要长时间枚举猜端口。按下面顺序重启：

```text
cli quit
清理 wechatdevtools / WeChatAppEx
cli auto --project <project> --port <port> --trust-project
重新连接同一端口
```

## 18. 构建与 CI

测试包：

```bash
ENABLE_TEST_BRIDGE=true STRIP_QA=false npm run build:weapp:test
```

正式包：

```bash
ENABLE_TEST_BRIDGE=false STRIP_QA=true npm run build:weapp:prod
```

CI：

```text
npm run lint
npm run typecheck
npm run test
npm run build:weapp:test
npm run test:miniapp
npm run build:weapp:prod
npm run check:weapp-prod
```

正式包扫描阻断：

```text
data-qa
data-testid
data-test
data-cy
__TEST_BRIDGE__
```

不能误删业务属性：

```text
data-order-no
data-member-id
data-product-id
data-status
```

## 19. 用例分级和执行策略

### 19.1 用例分级

```text
P0 冒烟：登录、下单、支付、退款。
P1 核心业务：优惠券、会员、积分、订单状态。
P2 兼容分支：异常、取消、边界。
P3 视觉和低频路径。
```

PR 阶段：

```text
P0 + 受影响模块 P1
```

夜间：

```text
P0 + P1 + P2
```

发版前：

```text
全量关键链路
```

### 19.2 并行策略

可以并行：

```text
不同会员。
不同订单。
不同门店。
只读查询。
互不影响的场景。
```

不能并行：

```text
同一会员余额 / 积分变化。
同一订单退款 / 反结。
同一桌台点餐。
同一优惠券库存。
```

并行前提：

```text
testRunId 隔离数据。
独立会员。
独立订单。
独立桌台。
```

### 19.3 减少链路长度

不要每条支付测试都从扫码点餐开始。

推荐：

```text
支付用例：接口创建待支付订单 -> UI 支付。
退款用例：接口创建已支付订单 -> UI 退款。
订单详情用例：接口创建订单 -> UI 查看。
```

只保留少量完整端到端链路：

```text
扫码 -> 点餐 -> 下单 -> 支付 -> 退款
```

## 20. 标准用例模板

```ts
test('refund confirm should submit refund and update order status', async () => {
  const ctx = await createMiniappTestContext('refund-confirm-success')

  try {
    const order = await createPaidOrder(ctx)

    await openOrderDetail(ctx, order.orderNo)
    await waitPageState(ctx, 'orderDetail.page', 'ready')

    await clearUiEvents(ctx)

    await tapQa(ctx, 'orders.refund')
    await waitVisible(ctx, 'refund.dialog')

    await tapQa(ctx, 'refund.confirm')

    await expectUiEvent(ctx, {
      type: 'ui.dialog.confirm',
      qa: 'refund.confirm',
    })

    await expectApiEvent(ctx, {
      url: '/refund/submit',
      success: true,
    })

    await expectBackendOrder(ctx, {
      orderNo: order.orderNo,
      status: 'REFUNDING',
    })

    await waitPageState(ctx, 'refund.page', 'success')

    await pass(ctx)
  } catch (error) {
    await fail(ctx, error)
    throw error
  } finally {
    await writeEvidence(ctx)
    await cleanupTestData(ctx)
  }
})
```

## 21. 第一批必须实现的用例

最小可执行集：

```text
login-success
order-submit-success
payment-success
refund-confirm-success
refund-cancel-no-request
orders-row-operate-by-order-no
tabbar-refresh-on-show
```

这些用例跑通后，框架才算成立。

## 22. 最快落地路线

第一阶段先实现 7 个能力：

```text
1. data-qa
2. data-page-state
3. testBridge
4. actionLog
5. apiEvents
6. backendEvidence
7. evidence.json
```

然后只写 5 条用例：

```text
login-success
order-submit-success
payment-success
refund-confirm-success
refund-cancel-no-request
```

这 5 条跑稳后，再扩展其它业务。

## 23. 评审清单

前端评审：

```text
[ ] 页面根节点是否有 data-qa？
[ ] 页面是否有 data-page-state？
[ ] 关键按钮、输入框、列表、弹窗是否有 data-qa？
[ ] data-qa 是否来自字面量或 QA 常量表？
[ ] data-qa 是否没有动态拼接？
[ ] 列表行是否使用 data-qa + 业务唯一属性？
[ ] 对话框是否区分 confirm / cancel / close？
[ ] 关键动作是否记录测试桥事件？
[ ] 页面是否避免固定 sleep 作为状态判断？
```

测试评审：

```text
[ ] 是否通过 data-qa 定位？
[ ] 是否记录 actionLog？
[ ] 是否读取 uiEvents？
[ ] 是否记录 apiEvents？
[ ] 是否查询 backendEvidence？
[ ] 确认路径是否校验请求和业务结果？
[ ] 取消路径是否校验没有提交请求？
[ ] 失败是否生成 evidence.json？
[ ] failureClass 是否明确？
```

构建评审：

```text
[ ] 测试包是否保留 data-qa 和测试桥？
[ ] 正式小程序包是否剥离 data-qa？
[ ] 正式小程序包是否剥离或空实现测试桥？
[ ] 产物扫描是否执行？
[ ] 是否没有误删业务 data-* 属性？
```

阻断级问题：

```text
[阻断] 核心按钮没有 data-qa。
[阻断] 核心页面没有 page-state。
[阻断] 弹窗只能靠关闭判断动作。
[阻断] 列表只能点第几行。
[阻断] 测试只靠 sleep。
[阻断] 测试只靠截图。
[阻断] trigger('tap') 散落在业务用例。
[阻断] 正式包无法剥离测试桥。
[阻断] UI 自动化失败但没有 evidence.json。
```

## 24. 最终原则

快速高效的 UI 测试不是多写脚本，而是：

```text
少走 UI。
多用接口造数。
等待状态不 sleep。
动作有 actionLog。
前端有 uiEvents。
请求有 apiEvents。
结果查后端。
失败有 failureClass。
证据包作为最终结果。
```

精确测试结果必须来自完整证据链：

```text
actionLog + uiEvents + apiEvents + backendEvidence + uiState
```

只有这 5 个都成立，才能判定 UI 用例真正通过。

一句话总结：

```text
完整可执行的小程序 UI 自动化框架不是一堆脚本，而是小程序、测试平台、后端和 CI 共同遵守的一套质量契约。
```
