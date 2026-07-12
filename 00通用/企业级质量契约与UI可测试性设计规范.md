# 企业级质量契约与 UI 可测试性设计规范

## 1. 文档定位

本文档定义企业级前端、微信小程序、测试平台和 AI 开发之间的质量契约。

它不是单纯讨论 `data-testid` 或 `data-qa` 的命名问题，而是规定一个前端系统如何从设计阶段就具备可测试、可观测、可诊断、可验收、可剥离、可发布门禁控制的能力。

本文档要达到的效果：

- 前端开发可以照着写代码。
- AI 可以照着生成代码。
- 测试平台可以照着接入自动化。
- Code Review 可以照着审查。
- CI/CD 可以照着设置发布门禁。

适用范围：

- React / Vue / Umi / Ant Design / H5 Web 项目。
- Taro / uni-app / 原生微信小程序项目。
- 前后端分离项目。
- SaaS 后台、商户端、C 端、小程序。
- 由 AI 参与开发、测试和评审的项目。

## 2. 核心结论

一个合格软件，不能只做到“人工能用”。它必须做到：

```text
页面可定位。
状态可判断。
动作可追踪。
请求可关联。
结果可验证。
失败可归因。
证据可复现。
产物可剥离。
发布可阻断。
```

UI 自动化难做，根因通常不是测试平台不够聪明，而是前端没有给测试平台稳定契约。

错误方向：

```text
让测试平台靠坐标、截图、DOM 层级、按钮文案去猜。
```

正确方向：

```text
前端在设计阶段就暴露稳定交互契约，测试平台按契约执行和验收。
```

## 3. 企业级质量契约体系

推荐把 UI 可测试性提升为质量契约体系。

| 契约 | 责任方 | 解决的问题 |
|---|---|---|
| 产品验收契约 | 产品、开发、测试 | 明确什么叫功能完成 |
| 前端交互契约 | 前端、测试平台 | 明确元素、动作、状态如何被测试 |
| 测试桥契约 | 前端、测试平台 | 明确前端运行时如何暴露 UI 事件 |
| 后端接口契约 | 后端、测试平台 | 明确接口状态、错误码、traceId、幂等和查询验证 |
| 测试数据契约 | 测试平台、后端 | 明确测试数据如何创建、隔离、清理 |
| 证据包契约 | 测试平台、CI | 明确失败时必须留下哪些证据 |
| 构建发布契约 | 前端、DevOps | 明确测试属性和测试桥在不同包中的保留或剥离 |
| 线上合成监控契约 | 运维、测试平台 | 明确线上关键链路如何低侵入巡检 |

企业级 UI 自动化不是“点击页面”，而是建立证据链：

```text
测试平台点击了什么
-> 前端收到了什么
-> 发出了什么请求
-> 后端返回了什么
-> 业务数据变成什么
-> 页面最终显示什么
-> 失败时留下什么证据
```

## 4. 推荐总体方案

最终推荐组合：

```text
data-qa 选择器契约
+ QA 常量表
+ 页面状态契约
+ 对话框动作契约
+ 测试桥 UI 事件
+ 测试平台 actionLog
+ 网络请求记录
+ 后端 traceId
+ 业务结果查询
+ 证据包
+ failureClass
+ 构建期剥离
+ CI 发布门禁
```

这比单纯“加一个测试属性”更完整，也更符合大型企业实践。

## 5. 测试选择器规范

### 5.1 属性名

企业内部推荐统一使用：

```html
data-qa
```

不推荐团队内混用：

```text
data-testid
data-test
data-cy
testid
qa-id
```

`data-testid` 不是技术上错误，而是不适合作为企业统一规范的首选名称：

- 名称偏长。
- 绑定 testing library 语义。
- 容易和 Cypress、Playwright、Testing Library 的习惯混用。
- 不利于多端统一。

`data-qa` 的优点：

- 短。
- 语义明确。
- 不绑定测试工具。
- 适合 Web、小程序、H5、混合端统一。
- 适合构建期统一剥离。

### 5.2 命名格式

推荐格式：

```text
<scope>.<name>
<scope>.<group>.<name>
```

示例：

```text
order.submit
order.cancel
order.phone
order.amount
orders.row
orders.pay
orders.cancel
refund.dialog
refund.confirm
refund.cancel
cart.add
cart.checkout
login.phone
login.smsCode
login.submit
```

规则：

- 第一段是业务作用域或页面作用域。
- 最后一段是元素、动作或状态。
- 不超过 3 段，特殊情况最多 4 段。
- 不使用颜色、位置、顺序、组件库内部结构。
- 不拼接订单号、会员号、手机号、商品 ID。
- 不运行时动态拼接。

禁止：

```text
button1
rightButton
blueSubmit
div3
order.submit.OD202607020001
member.18923865943
product.1000123.add
```

### 5.3 业务值与选择器分离

`data-qa` 只表达测试定位语义，不表达业务数据。

错误：

```tsx
<tr data-qa={`orders.row.${order.orderNo}`}>
  ...
</tr>
```

正确：

```tsx
<tr data-qa="orders.row" data-order-no={order.orderNo}>
  ...
</tr>
```

测试平台定位：

```ts
const row = page.locator('[data-qa="orders.row"][data-order-no="OD202607020001"]');
await row.locator('[data-qa="orders.pay"]').click();
```

### 5.4 组件封装规则

业务代码应该写：

```tsx
<Button qa="order.submit">提交订单</Button>
```

或：

```tsx
<Button qa={ORDER_QA.submit}>提交订单</Button>
```

基础组件内部负责透传：

```tsx
type ButtonProps = {
  qa?: string;
  children: React.ReactNode;
  onClick?: () => void;
};

export function Button(props: ButtonProps) {
  return (
    <button data-qa={props.qa} onClick={props.onClick}>
      {props.children}
    </button>
  );
}
```

禁止业务代码写：

```tsx
<Button qa={qaId}>提交订单</Button>
<Button qa={props.qa}>提交订单</Button>
<Button qa={`order.${action}`}>提交订单</Button>
<Button qa={`orders.row.${orderNo}`}>订单行</Button>
```

原因：

- 测试平台无法提前知道 `qaId` 的真实值。
- 动态拼接无法静态检查。
- 拼入业务 ID 会导致选择器不稳定。
- AI 容易把任意变量传给 `qa`，必须通过规范阻断。

### 5.5 QA 常量表

每个页面或业务模块建立 QA 常量表。

推荐目录：

```text
src/
  qa/
    order.qa.ts
    refund.qa.ts
    cart.qa.ts
```

示例：

```ts
export const ORDER_QA = {
  page: 'order.page',
  loading: 'order.loading',
  empty: 'order.empty',
  error: 'order.error',
  submit: 'order.submit',
  cancel: 'order.cancel',
  phone: 'order.phone',
  remark: 'order.remark',
  amount: 'order.amount'
} as const;
```

## 6. 页面状态契约

测试平台不能只判断按钮是否存在，还要判断页面处于什么状态。

页面根节点推荐：

```tsx
<main data-qa="order.page" data-page-state={state}>
  {state === 'loading' && <Spin data-qa="order.loading" />}
  {state === 'empty' && <Empty data-qa="order.empty" />}
  {state === 'error' && <ErrorView data-qa="order.error" />}
  {state === 'ready' && <OrderForm />}
</main>
```

测试平台断言：

```ts
await expect(page.locator('[data-qa="order.page"]'))
  .toHaveAttribute('data-page-state', 'ready');
```

推荐状态：

```text
loading
ready
empty
error
submitting
success
failed
```

禁止只靠固定 sleep：

```ts
await page.waitForTimeout(3000);
```

推荐等待状态：

```ts
await expect(page.locator('[data-qa="order.page"]'))
  .toHaveAttribute('data-page-state', 'ready');
```

## 7. 列表与表格契约

列表必须同时有：

- 列表根节点。
- 行节点。
- 行业务 key。
- 行内动作。
- 空状态。
- 加载状态。

示例：

```tsx
<table data-qa="orders.table" data-page-state={state}>
  <tbody>
    {orders.map(order => (
      <tr
        key={order.orderNo}
        data-qa="orders.row"
        data-order-no={order.orderNo}
      >
        <td>{order.orderNo}</td>
        <td>{order.amount}</td>
        <td>
          <Button qa="orders.pay">支付</Button>
          <Button qa="orders.cancel">取消</Button>
        </td>
      </tr>
    ))}
  </tbody>
</table>
```

测试某个订单：

```ts
const row = page.locator('[data-qa="orders.row"][data-order-no="OD202607020001"]');
await row.locator('[data-qa="orders.pay"]').click();
```

禁止：

- 点第一行。
- 点第 N 个按钮。
- 用坐标。
- 用颜色。
- 把订单号拼进 `data-qa`。

## 8. 对话框契约

### 8.1 对话框必须明确动作

对话框测试不能只判断“弹窗消失”。确定、取消、右上角关闭、遮罩点击、ESC 都可能让弹窗消失。

必须明确区分：

```text
refund.dialog
refund.confirm
refund.cancel
refund.close
refund.maskClose
refund.escClose
```

示例：

```tsx
<Modal qa="refund.dialog" open={open} maskClosable={false} keyboard={false}>
  <Button qa="refund.cancel" onClick={onCancel}>取消</Button>
  <Button qa="refund.confirm" onClick={onConfirm}>确定</Button>
</Modal>
```

### 8.2 如何确认点的是确定还是取消

必须使用四类证据：

| 证据 | 作用 |
|---|---|
| actionLog | 测试平台记录自己点了哪个 selector |
| uiEvents | 前端测试桥记录自己收到哪个动作 |
| network | 确定通常产生提交请求，取消通常不产生提交请求 |
| finalState | 页面最终状态符合预期 |

确定路径证据：

```text
actionLog: click refund.confirm
uiEvents: ui.dialog.confirm / refund.confirm
network: POST /refund/submit
finalState: refund.success
```

取消路径证据：

```text
actionLog: click refund.cancel
uiEvents: ui.dialog.cancel / refund.cancel
network: 没有 POST /refund/submit
finalState: refund.dialog closed
```

## 9. 测试桥契约

### 9.1 测试桥是什么

测试桥是测试平台和前端运行时之间的受控通信通道。

它记录：

- 前端收到了哪个 UI 动作。
- 前端进入了哪个关键状态。
- 对话框点击的是确定、取消还是关闭。
- 页面当前业务上下文是什么。

它不做：

- 不修改业务状态。
- 不替代后端断言。
- 不写入敏感数据。
- 不在正式 C 端包暴露调试后门。

### 9.2 Web 测试桥

```ts
type TestEvent = {
  type: string;
  qa?: string;
  page?: string;
  dialog?: string;
  payload?: Record<string, unknown>;
  time: number;
};

type TestBridge = {
  record: (event: Omit<TestEvent, 'time'>) => void;
  getEvents: () => TestEvent[];
  clear: () => void;
};

declare global {
  interface Window {
    __TEST_BRIDGE__?: TestBridge;
  }
}

export function installTestBridge() {
  if (process.env.NODE_ENV === 'production') {
    return;
  }

  const events: TestEvent[] = [];

  window.__TEST_BRIDGE__ = {
    record(event) {
      events.push({
        ...event,
        time: Date.now()
      });
    },
    getEvents() {
      return [...events];
    },
    clear() {
      events.length = 0;
    }
  };
}

export function recordUiEvent(event: Omit<TestEvent, 'time'>) {
  window.__TEST_BRIDGE__?.record(event);
}
```

使用：

```tsx
function onConfirm() {
  recordUiEvent({
    type: 'ui.dialog.confirm',
    qa: 'refund.confirm',
    dialog: 'refund.dialog'
  });

  submitRefund();
}
```

测试平台读取：

```ts
const events = await page.evaluate(() => {
  return window.__TEST_BRIDGE__?.getEvents?.() ?? [];
});
```

### 9.3 微信小程序测试桥

小程序没有 `window`，推荐挂到 `getApp()`。

```ts
export function installMiniappTestBridge() {
  if (process.env.NODE_ENV === 'production') {
    return;
  }

  const app = getApp();
  const events: any[] = [];

  app.__TEST_BRIDGE__ = {
    record(event: any) {
      events.push({
        ...event,
        time: Date.now()
      });
    },
    getEvents() {
      return [...events];
    },
    clear() {
      events.length = 0;
    }
  };
}

export function recordMiniappUiEvent(event: any) {
  getApp().__TEST_BRIDGE__?.record(event);
}
```

测试平台读取：

```ts
const events = await miniProgram.evaluate(() => {
  return getApp().__TEST_BRIDGE__?.getEvents?.() ?? [];
});
```

### 9.4 通信原理

Web：

```text
Playwright / Puppeteer
-> Chrome DevTools Protocol
-> page.evaluate()
-> 在页面 JS 上下文读取 window.__TEST_BRIDGE__
```

微信小程序：

```text
miniprogram-automator
-> 微信开发者工具自动化 WebSocket
-> miniProgram.evaluate()
-> 在小程序运行时读取 getApp().__TEST_BRIDGE__
```

这不是测试平台直接读内存，也不是后门。它是自动化工具提供的运行时上下文执行能力。

## 10. 测试平台动作日志

测试平台必须记录自己的动作日志。前端测试桥不能替代 actionLog。

```ts
type ActionLog = {
  stepId: string;
  action: 'click' | 'fill' | 'select' | 'wait' | 'assert';
  qa?: string;
  selector?: string;
  valueMasked?: string;
  pageUrl?: string;
  pagePath?: string;
  time: string;
  result: 'success' | 'failed';
  error?: string;
};
```

封装：

```ts
export async function clickQa(page: Page, qaId: string) {
  const selector = `[data-qa="${qaId}"]`;

  actionLog.push({
    stepId: createStepId(),
    action: 'click',
    qa: qaId,
    selector,
    time: new Date().toISOString(),
    result: 'success'
  });

  await page.locator(selector).click();
}
```

判断点击是否成立：

```text
actionLog 证明测试平台点了什么。
uiEvents 证明前端收到了什么。
network / business state 证明业务是否成功。
```

## 11. 证据包规范

每次 UI 自动化执行必须生成证据包。

推荐结构：

```json
{
  "runId": "run-20260702-001",
  "caseId": "refund-confirm-success",
  "env": "test",
  "app": "mall-web",
  "version": "1.8.0",
  "actionLog": [],
  "uiEvents": [],
  "requests": [],
  "responses": [],
  "screenshots": [],
  "traceIds": [],
  "assertions": [],
  "failureClass": "",
  "failureReason": "",
  "createdAt": "2026-07-02T10:00:00+08:00"
}
```

失败时至少保留：

```text
最后一个 actionLog
最后一批 uiEvents
最后一批 requests/responses
当前页面 URL 或小程序 page path
截图
failureClass
failureReason
```

## 12. 失败分类

自动化失败必须分类。

| failureClass | 含义 |
|---|---|
| frontend_interaction_failure | 元素找不到、点击未触发、弹窗动作错误 |
| frontend_state_failure | 页面状态错误、加载失败、白屏 |
| backend_api_failure | 接口 5xx、业务错误码、响应结构错误 |
| business_failure | 接口成功但业务状态不符合预期 |
| test_data_failure | 测试数据缺失、过期、污染 |
| environment_failure | 环境不可用、服务未启动、网络异常 |
| automation_script_failure | 测试脚本自身错误 |
| third_party_failure | 支付、短信、微信等第三方异常 |
| assertion_failure | 断言口径错误或预期不匹配 |

示例：

```json
{
  "failureClass": "frontend_interaction_failure",
  "failureReason": "clicked refund.confirm but ui.dialog.confirm was not observed",
  "lastAction": {
    "action": "click",
    "qa": "refund.confirm"
  },
  "lastUiEvents": []
}
```

## 13. 构建期剥离

正式包可以剥离 `data-qa` 和测试桥，但测试包必须保留。

构建矩阵：

| 包类型 | data-qa | 测试桥 |
|---|---|---|
| 本地开发包 | 保留 | 保留 |
| 自动化测试包 | 保留 | 保留 |
| 预发包 | 可保留或白名单保留 | 可保留或白名单保留 |
| SaaS 后台正式包 | 可白名单保留 | 默认关闭，可按巡检开启 |
| C 端 Web 正式包 | 默认剥离 | 剥离或空实现 |
| 微信小程序正式包 | 默认剥离 | 剥离或空实现 |

可剥离：

```text
data-qa
data-testid
data-test
data-cy
__TEST_BRIDGE__
```

不可剥离：

```text
data-order-no
data-member-id
data-product-id
data-role
data-status
```

React / Taro Babel 插件示例：

```js
module.exports = function stripQaPlugin({ types: t }) {
  return {
    visitor: {
      JSXOpeningElement(path, state) {
        const strip = state.opts.strip === true;
        if (!strip) {
          return;
        }

        path.node.attributes = path.node.attributes.filter((attr) => {
          if (!t.isJSXAttribute(attr)) {
            return true;
          }

          const name = attr.name && attr.name.name;
          return name !== 'data-qa';
        });
      }
    }
  };
};
```

构建配置：

```js
plugins: [
  ['strip-qa-plugin', { strip: process.env.STRIP_QA === 'true' }]
]
```

产物扫描：

```bash
rg "data-qa|__TEST_BRIDGE__" dist
```

C 端正式包和小程序正式包扫描到测试属性，应阻断发布。

## 14. 后端接口契约

UI 测试不能只看前端。后端接口也必须可验证。

后端应提供：

- 稳定错误码。
- 稳定业务状态。
- traceId。
- 幂等键。
- 查询接口。
- 统一错误结构。

推荐响应：

```json
{
  "success": true,
  "code": "SUCCESS",
  "message": "ok",
  "traceId": "trace-xxx",
  "data": {}
}
```

错误响应：

```json
{
  "success": false,
  "code": "ORDER_STOCK_NOT_ENOUGH",
  "message": "库存不足",
  "traceId": "trace-xxx",
  "data": null
}
```

测试平台不能只断言 HTTP 200。HTTP 200 只能说明接口正常返回，不代表业务成功。

## 15. 测试数据契约

测试数据必须明确：

| 数据类型 | 要求 |
|---|---|
| 用户 | 账号、角色、权限、状态 |
| 会员 | 手机号、openid、余额、等级 |
| 商品 | 库存、价格、上下架状态 |
| 订单 | 状态、金额、支付状态 |
| 门店 | 营业状态、桌台、配置 |
| 优惠券 | 有效期、门槛、剩余数量 |

生命周期：

```text
创建 -> 使用 -> 校验 -> 清理或归档
```

禁止：

- 多个用例共享同一可变数据。
- 使用会过期的数据但不检查有效期。
- 使用生产真实用户数据。
- 敏感字段不脱敏。

## 16. 具体怎么做：从零落地步骤

这一章是实施手册。团队照着执行即可。

### 16.1 第 1 步：选一个核心流程试点

不要全系统一次性改。

推荐先选一个闭环流程：

```text
订单提交
退款确认
登录
支付
审批通过
购物车下单
```

试点必须包含：

- 页面入口。
- 表单或列表。
- 对话框。
- 后端请求。
- 页面最终状态。
- 业务结果查询。

例如选择“退款确认”。

### 16.2 第 2 步：定义 QA 常量表

新增文件：

```text
src/qa/refund.qa.ts
```

内容：

```ts
export const REFUND_QA = {
  open: 'refund.open',
  dialog: 'refund.dialog',
  reason: 'refund.reason',
  confirm: 'refund.confirm',
  cancel: 'refund.cancel',
  success: 'refund.success',
  error: 'refund.error'
} as const;
```

评审标准：

```text
[ ] 名称是否短。
[ ] 是否表达业务动作。
[ ] 是否没有订单号、会员号等动态值。
[ ] 是否没有颜色、位置、顺序。
```

### 16.3 第 3 步：改基础组件

如果项目已有 Button、Input、Modal 等基础组件，先让它们支持 `qa`。

Button：

```tsx
type ButtonProps = {
  qa?: string;
  children: React.ReactNode;
  onClick?: () => void;
};

export function Button({ qa, children, onClick }: ButtonProps) {
  return (
    <button data-qa={qa} onClick={onClick}>
      {children}
    </button>
  );
}
```

Input：

```tsx
type InputProps = {
  qa?: string;
  value?: string;
  onChange?: (value: string) => void;
};

export function Input({ qa, value, onChange }: InputProps) {
  return (
    <input
      data-qa={qa}
      value={value}
      onChange={(event) => onChange?.(event.target.value)}
    />
  );
}
```

Modal：

```tsx
type ModalProps = {
  qa?: string;
  open: boolean;
  children: React.ReactNode;
};

export function Modal({ qa, open, children }: ModalProps) {
  if (!open) {
    return null;
  }

  return (
    <div data-qa={qa} role="dialog">
      {children}
    </div>
  );
}
```

注意：

```text
业务页面传 qa。
基础组件只透传 qa。
基础组件不要自己拼 qa。
```

### 16.4 第 4 步：改业务页面

业务页面：

```tsx
import { REFUND_QA } from '@/qa/refund.qa';
import { recordUiEvent } from '@/test-bridge';

export function RefundPanel() {
  const [open, setOpen] = useState(false);
  const [state, setState] = useState<'ready' | 'submitting' | 'success' | 'error'>('ready');

  async function onConfirm() {
    recordUiEvent({
      type: 'ui.dialog.confirm',
      qa: REFUND_QA.confirm,
      dialog: REFUND_QA.dialog
    });

    setState('submitting');

    try {
      await submitRefund();
      setState('success');
      setOpen(false);
    } catch (error) {
      setState('error');
    }
  }

  function onCancel() {
    recordUiEvent({
      type: 'ui.dialog.cancel',
      qa: REFUND_QA.cancel,
      dialog: REFUND_QA.dialog
    });

    setOpen(false);
  }

  return (
    <section data-qa="refund.page" data-page-state={state}>
      <Button qa={REFUND_QA.open} onClick={() => setOpen(true)}>
        申请退款
      </Button>

      <Modal qa={REFUND_QA.dialog} open={open}>
        <Input qa={REFUND_QA.reason} />
        <Button qa={REFUND_QA.cancel} onClick={onCancel}>取消</Button>
        <Button qa={REFUND_QA.confirm} onClick={onConfirm}>确定</Button>
      </Modal>

      {state === 'success' && <div data-qa={REFUND_QA.success}>退款申请已提交</div>}
      {state === 'error' && <div data-qa={REFUND_QA.error}>退款申请失败</div>}
    </section>
  );
}
```

### 16.5 第 5 步：安装测试桥

Web 入口，例如 `src/main.tsx`：

```ts
import { installTestBridge } from './test-bridge';

installTestBridge();
```

小程序入口，例如 `app.ts`：

```ts
import { installMiniappTestBridge } from './test-bridge-miniapp';

installMiniappTestBridge();
```

验收：

```text
打开测试包。
点击 refund.confirm。
测试平台能读取 ui.dialog.confirm。
点击 refund.cancel。
测试平台能读取 ui.dialog.cancel。
```

### 16.6 第 6 步：写测试平台 helper

Web Playwright：

```ts
import { expect, Page } from '@playwright/test';

export function qa(qaId: string) {
  return `[data-qa="${qaId}"]`;
}

export async function clickQa(page: Page, qaId: string) {
  await page.locator(qa(qaId)).click();
}

export async function fillQa(page: Page, qaId: string, value: string) {
  await page.locator(qa(qaId)).fill(value);
}

export async function expectQaVisible(page: Page, qaId: string) {
  await expect(page.locator(qa(qaId))).toBeVisible();
}

export async function getUiEvents(page: Page) {
  return await page.evaluate(() => {
    return window.__TEST_BRIDGE__?.getEvents?.() ?? [];
  });
}

export async function expectUiEvent(page: Page, expected: Record<string, string>) {
  const events = await getUiEvents(page);
  const matched = events.some((event: any) => {
    return Object.entries(expected).every(([key, value]) => event[key] === value);
  });

  expect(matched).toBeTruthy();
}
```

小程序 automator：

```ts
export async function findMiniQa(page: any, qaId: string) {
  const items = await page.$$(`[data-qa="${qaId}"]`);
  if (!items || items.length === 0) {
    throw new Error(`miniapp qa not found: ${qaId}`);
  }
  return items[0];
}

export async function tapMiniQa(page: any, qaId: string) {
  const item = await findMiniQa(page, qaId);
  await item.tap();
}

export async function getMiniUiEvents(miniProgram: any) {
  return await miniProgram.evaluate(() => {
    return getApp().__TEST_BRIDGE__?.getEvents?.() ?? [];
  });
}
```

### 16.7 第 7 步：写第一条确定路径用例

```ts
test('refund confirm should submit request', async ({ page }) => {
  await clickQa(page, 'refund.open');
  await expectQaVisible(page, 'refund.dialog');

  const submitResponse = page.waitForResponse((response) => {
    return response.url().includes('/refund/submit') && response.status() === 200;
  });

  await clickQa(page, 'refund.confirm');

  await expectUiEvent(page, {
    type: 'ui.dialog.confirm',
    qa: 'refund.confirm'
  });

  const response = await submitResponse;
  const body = await response.json();
  expect(body.success).toBe(true);
  expect(body.traceId).toBeTruthy();

  await expectQaVisible(page, 'refund.success');
});
```

### 16.8 第 8 步：写第一条取消路径用例

```ts
test('refund cancel should not submit request', async ({ page }) => {
  const submitRequests: string[] = [];

  page.on('request', request => {
    if (request.url().includes('/refund/submit')) {
      submitRequests.push(request.url());
    }
  });

  await clickQa(page, 'refund.open');
  await expectQaVisible(page, 'refund.dialog');

  await clickQa(page, 'refund.cancel');

  await expectUiEvent(page, {
    type: 'ui.dialog.cancel',
    qa: 'refund.cancel'
  });

  expect(submitRequests).toHaveLength(0);
});
```

### 16.9 第 9 步：生成证据包

测试平台每个用例结束时写入：

```text
artifacts/
  run-20260702-001/
    evidence.json
    screenshot-final.png
    trace.zip
```

`evidence.json`：

```json
{
  "runId": "run-20260702-001",
  "caseId": "refund-confirm-success",
  "actionLog": [
    {
      "action": "click",
      "qa": "refund.confirm",
      "result": "success"
    }
  ],
  "uiEvents": [
    {
      "type": "ui.dialog.confirm",
      "qa": "refund.confirm",
      "dialog": "refund.dialog"
    }
  ],
  "requests": [],
  "responses": [],
  "traceIds": [],
  "assertions": [],
  "failureClass": ""
}
```

### 16.10 第 10 步：配置剥离

测试包：

```bash
STRIP_QA=false npm run build:test
```

正式包：

```bash
STRIP_QA=true npm run build:prod
```

正式包扫描：

```bash
rg "data-qa|__TEST_BRIDGE__" dist
```

CI 规则：

```text
测试包扫描到 data-qa：正常。
正式 C 端包扫描到 data-qa：失败。
正式小程序包扫描到 data-qa：失败。
后台正式包扫描到 data-qa：必须命中白名单。
```

### 16.11 第 11 步：加静态检查

必须阻断：

```tsx
<Button qa={qaId} />
<Button qa={props.qa} />
<Button qa={`order.${action}`} />
<div data-qa={`orders.row.${orderNo}`} />
```

允许：

```tsx
<Button qa="order.submit" />
<Button qa={ORDER_QA.submit} />
<tr data-qa="orders.row" data-order-no={order.orderNo} />
```

检查标准：

```text
qa 属性允许字符串字面量。
qa 属性允许来自 *.qa.ts 常量表。
data-qa 属性允许字符串字面量。
禁止模板字符串。
禁止任意变量。
禁止包含 orderNo、memberId、phone、productId 等业务 ID。
```

### 16.12 第 12 步：接入 Code Review

评审时直接用下面清单。

前端评审：

```text
[ ] 页面根节点是否有 qa？
[ ] 关键按钮、输入框、列表、对话框是否有 qa？
[ ] qa 是否符合 <scope>.<name>？
[ ] qa 是否没有动态拼接？
[ ] 列表行是否 data-qa + data-business-key？
[ ] 对话框是否区分 confirm / cancel / close？
[ ] 关键动作是否记录测试桥事件？
[ ] 页面是否有 loading / ready / error / success 状态？
```

测试评审：

```text
[ ] 是否通过 qa 定位？
[ ] 是否记录 actionLog？
[ ] 是否读取 uiEvents？
[ ] 确认路径是否校验请求和业务结果？
[ ] 取消路径是否校验没有提交请求？
[ ] 失败是否生成证据包？
[ ] failureClass 是否明确？
```

构建评审：

```text
[ ] 测试包是否保留 data-qa 和测试桥？
[ ] 正式 C 端包是否剥离 data-qa？
[ ] 正式小程序包是否剥离 data-qa？
[ ] 后台正式包如保留 data-qa，是否有白名单？
[ ] 产物扫描是否执行？
```

## 17. 微信小程序特别规则

小程序 UI 自动化更容易失败，因为运行时结构、编译后 class、组件层级会变化。

小程序必须优先依赖：

- `data-qa`。
- 页面状态。
- 测试桥事件。
- 业务请求。
- 业务结果。

禁止优先依赖：

- 坐标。
- 编译后随机 class。
- 第几个 view。
- 全局按钮文字。

### 17.1 `tap()` 与 `trigger('tap')` 的定位

小程序自动化里经常会遇到两个动作 API：

```ts
await element.tap();
await element.trigger('tap');
```

这两个 API 不是同一种能力。

`tap()` 更接近真实用户点击，默认应该优先使用。它的测试目标是验证：

```text
真实用户点这个元素时，业务是否真的发生。
```

`trigger('tap')` 更像直接向元素触发 `tap` 事件。它不是默认点击方式，只用于处理少数“小程序运行时节点和源码事件绑定节点不一致”的场景。

### 17.2 为什么必须默认使用 `tap()`

UI 自动化首先要模拟真实用户行为。

大多数业务动作都应该使用：

```ts
await element.tap();
```

适用场景：

```text
提交订单
确定退款
取消弹窗
加入购物车
立即支付
选择规格
选择列表项
点击底部操作按钮
```

如果测试平台绕过真实点击，直接改变量、改 storage、调页面方法或随意 trigger，就不是在测试真实 UI。

禁止把以下方式作为默认业务点击：

```ts
await element.trigger('touchstart');
await element.trigger('touchend');
await page.setData(...);
await page.callMethod(...);
```

这些方式可能绕过真实用户路径，导致测试通过但用户实际不可用。

### 17.3 为什么还需要 `trigger('tap')`

小程序、Taro、uni-app、第三方 UI 组件经常存在这种结构：

```tsx
<View className="add-btn" onClick={handleAdd}>
  <Text className="nut-icon-Add" />
</View>
```

用户视觉上看到的是里面的加号图标：

```text
Text.nut-icon-Add
```

但真正绑定业务事件的是外层：

```text
View.add-btn
```

如果测试平台定位到了内部图标并执行：

```ts
await icon.tap();
```

可能出现：

```text
自动化日志显示点了。
但没有请求。
没有状态变化。
人工点击却正常。
```

这时需要回到源码确认事件绑定在哪个节点。如果源码证明事件绑定在外层 `View`，测试平台必须定位外层事件节点。只有当 `tap()` 在该事件节点上仍不稳定，并且真实验证证明需要直接触发事件时，才允许：

```ts
await addButtonView.trigger('tap');
```

### 17.4 为什么不能只用 `trigger('tap')`

`trigger('tap')` 有绕过真实交互条件的风险。

可能绕过：

```text
元素是否真实可见。
元素是否被遮罩挡住。
元素是否 disabled。
真实用户是否点得到。
真实点击坐标是否落在有效区域。
组件库内部是否阻止事件冒泡。
```

例如按钮被弹窗遮罩挡住，真实用户点不到，但测试平台直接执行：

```ts
await button.trigger('tap');
```

可能仍然触发业务事件，导致测试假通过。

所以企业级规则是：

```text
tap() 是默认。
trigger('tap') 是经源码确认和真实验证后的例外。
```

### 17.5 企业级选择顺序

小程序测试平台执行业务动作时，必须按下面顺序处理：

```text
1. 先判断当前页面状态和业务上下文。
2. 通过 data-qa 或稳定契约找到目标元素。
3. 优先对目标元素执行 element.tap()。
4. 点击后检查 UI 状态、测试桥事件、请求或业务结果。
5. 如果 tap() 没有产生预期结果，读取源码确认事件绑定节点。
6. 如果定位错了内部图标或文字，改为定位真正绑定事件的外层节点。
7. 对外层节点再次优先尝试 tap()。
8. 只有真实验证证明 tap() 在该事件节点仍不可靠时，才固化 trigger('tap')。
9. trigger('tap') 必须封装在明确命名的原子能力里，不允许散落在业务用例中。
```

示例：

```ts
async function tapMiniappAddDish(page: any, dishName: string) {
  const addButton = await findDishAddButtonEventNode(page, dishName);

  await addButton.tap();

  const changed = await waitForCartRequestOrSpecPopup(page, 800);
  if (changed) {
    return;
  }

  // 只有该节点经过源码确认是事件绑定节点，并且 tap 在真实 DevTools 中不稳定时，才允许此兜底。
  await addButton.trigger('tap');
  await waitForCartRequestOrSpecPopup(page, 800);
}
```

### 17.6 固化 `trigger('tap')` 的准入条件

任何 `trigger('tap')` 进入正式测试平台代码前，必须满足：

```text
[ ] 已确认当前页面状态正确。
[ ] 已通过源码确认事件绑定节点。
[ ] 已证明 tap() 在该事件节点上不稳定或无效。
[ ] 已证明 trigger('tap') 会产生和人工点击一致的请求、状态或 UI 事件。
[ ] 已封装为原子能力，不散落在业务用例里。
[ ] 已写明为什么这里不能只用 tap()。
```

不满足以上条件时，不能使用 `trigger('tap')`。

### 17.7 判断点击是否成功的标准

无论使用 `tap()` 还是 `trigger('tap')`，都不能把“API 没抛错”当作业务成功。

必须验证至少一种真实结果：

```text
测试桥事件出现。
页面状态变化。
业务请求出现。
业务数据变化。
弹窗打开或关闭。
购物车数量变化。
订单状态变化。
```

例如点击“加入购物车”后，至少应看到：

```text
/shopping_cart/addDish 请求出现
或规格弹窗打开
或购物车数量增加
或测试桥记录 ui.cart.add
```

如果没有任何结果，只能说明“点击动作没有被业务接受”，不能继续假设成功。

## 18. CI 发布门禁

推荐门禁：

| 门禁 | 说明 |
|---|---|
| Typecheck | 类型检查 |
| Lint | 基础代码检查 |
| Unit Test | 纯逻辑测试 |
| Component Test | 组件交互测试 |
| API Contract Test | 接口契约测试 |
| UI Smoke Test | 关键链路 UI 冒烟 |
| QA Selector Scan | 检查选择器命名和动态拼接 |
| Artifact Strip Scan | 检查正式包是否剥离测试属性 |
| Evidence Package Check | 检查自动化是否生成证据包 |

阻断条件：

```text
[阻断] 核心按钮缺少 data-qa。
[阻断] data-qa 中出现动态业务 ID。
[阻断] 对话框确定/取消无法区分。
[阻断] 正式 C 端包仍包含 data-qa 或测试桥。
[阻断] 正式小程序包仍包含 data-qa 或测试桥。
[阻断] 自动化失败但没有证据包。
[阻断] 后端接口缺少 traceId。
[阻断] 测试数据不可复现。
```

## 19. AI 开发约束

AI 生成前端代码时必须遵守：

- 每个关键页面必须有 page/root qa。
- 每个关键按钮必须有 qa。
- 每个关键输入框必须有 qa。
- 每个关键对话框必须有 dialog、confirm、cancel。
- 每个列表行必须有 row qa 和独立业务 key。
- 每个关键动作必须记录测试桥事件。
- 不得使用坐标、颜色、顺序作为测试定位依据。
- 不得把订单号、手机号、会员号拼进 `data-qa`。
- 不得生成只靠文字定位的测试代码。
- 不得生成只靠截图判断成功的测试代码。

AI 交付模板：

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

## 20. 最小落地路线

第一周只做一个流程。

示例：退款流程。

```text
1. 新建 refund.qa.ts。
2. 改 Button / Input / Modal 支持 qa。
3. 给退款入口加 refund.open。
4. 给退款弹窗加 refund.dialog。
5. 给确定按钮加 refund.confirm。
6. 给取消按钮加 refund.cancel。
7. 接入 Web 或小程序测试桥。
8. confirm 记录 ui.dialog.confirm。
9. cancel 记录 ui.dialog.cancel。
10. 写确认退款 UI 自动化。
11. 写取消退款 UI 自动化。
12. 输出 evidence.json。
13. 配置测试包保留 data-qa。
14. 配置正式包剥离 data-qa。
15. CI 扫描正式包。
16. Code Review 按清单阻断违规。
```

第一周验收：

```text
[ ] 退款确认路径可自动化验证。
[ ] 退款取消路径可自动化验证。
[ ] 测试平台能明确区分点了确定还是取消。
[ ] 失败时有 actionLog、uiEvents、requests、screenshots。
[ ] 测试包保留 data-qa 和测试桥。
[ ] 正式包不残留 data-qa 和 __TEST_BRIDGE__。
```

第二周推广：

```text
订单提交。
支付。
登录。
审批。
购物车。
列表查询。
```

第三周治理：

```text
静态扫描。
CI 门禁。
证据包归档。
失败分类统计。
线上合成监控白名单。
```

## 21. 架构师结论

企业级 UI 可测试性不是“测试平台更会点”，而是“前端交互有稳定契约”。

一个按钮对用户来说是“提交订单”，对测试平台来说必须是稳定的 `order.submit`，对证据系统来说必须能证明：

```text
测试平台点击了它。
前端收到了它。
后端处理了它。
业务状态改变了。
页面最终正确了。
失败时证据留下了。
正式发布时测试辅助能力被正确处理了。
```

如果没有这些契约，自动化测试只能靠猜；如果具备这些契约，前端、测试平台、人类开发者和 AI 才能在同一套标准下协作。
