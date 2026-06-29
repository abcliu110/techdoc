# pos-merchant-backend-autotest-newshop 平台内核优先整改设计

记录时间：2026-06-29 15:07:12

## 1. 设计目标

本设计用于解决小程序/POS 混合测试中暴露出的框架级不稳定问题。整改顺序采用“先 2 再 1”：

1. 先补测试平台内核：能力级 ledger、Surface Runtime 边界、Stage 失败归因、单操作 10 秒约束、跨页面请求证据链。
2. 再重构第 1 个真实用例依赖的 `miniapp.orderDishByAmount`，让第 1 用例复用平台内核能力跑通。

目标不是继续给单个脚本打补丁，而是把失败定位、原子能力复用和证据记录变成平台机制。

## 2. 当前已确认问题

第 1 用例“小程序开台点餐，小程序会员付款，要求有积分、赠券、返现”的最新失败点不是权益、充值或付款，而是小程序加菜能力：

- 已进入点餐页。
- 已找到目标菜品 `江小白`。
- 点击加号/规格弹窗后，没有稳定捕获 `/shopping_cart/addDish` 成功请求。
- 页面从 `pagePop/orderfoods/index` 回到 `pagesIndex/page1/index`。
- 脚本继续操作旧页面元素，出现 `page destroyed`。

框架层同时存在以下缺陷：

1. Stage 失败后把所有能力批量标记 failed，真实失败能力不清楚。
2. `business-capabilities.json` 注册了能力，但运行时仍由大脚本内部逻辑完成，不是真正执行原子。
3. 小程序加菜依赖模糊 UI 猜测和多动作轰炸，容易点错或状态漂移。
4. 小程序页面状态变化后缺少强约束，旧元素句柄继续被使用。
5. 请求证据依赖页面内变量，页面销毁后可能丢失证据。
6. 单操作 10 秒约束没有成为统一硬规则。

## 3. 设计原则

1. 能力状态必须真实：没有执行到的能力不能标记为 failed。
2. Stage 只是调度容器，不能替代 capability 级状态。
3. 小程序和 POS 是两个独立 Surface，不能混用 UI 操作、locator、runtime、controller。
4. 每个 UI 操作都必须有 10 秒以内的硬超时和即时页面健康检查。
5. 证据必须先于结论：失败报告必须说明页面、请求、业务状态和失败分类。
6. 先包装现有 runner，再逐步拆出真正 capability adapter，避免一次性重写造成更大风险。

## 4. 目标架构

```text
Business Case / Mixed Order Runner
  -> Ordered Stage Scheduler
  -> Capability Runtime Ledger
  -> Surface Runtime Adapter
       -> miniapp runtime adapter
       -> pos runtime adapter
  -> Evidence Collector
       -> UI page state
       -> request ledger
       -> screenshots/text snapshots
       -> business API evidence
  -> Summary / Report
```

### 4.1 Capability Runtime Ledger

每个 capability 独立记录生命周期：

```json
{
  "capabilityId": "miniapp.orderDishByAmount",
  "stageId": "miniapp.orderAndPay",
  "status": "failed",
  "startedAt": "2026-06-29T07:00:00.000Z",
  "finishedAt": "2026-06-29T07:00:08.000Z",
  "failureClass": "miniapp-request-not-observed",
  "blockedBy": null,
  "evidence": {
    "surface": "miniapp",
    "pagePath": "pagesIndex/page1/index",
    "expectedPagePath": "pagePop/orderfoods/index",
    "recentRequestsPath": ".../requests.json",
    "screenshotPath": ".../tap-dish-add.png"
  }
}
```

允许的状态：

| 状态 | 含义 |
|---|---|
| `planned` | 已编排，尚未执行 |
| `running` | 正在执行 |
| `passed` | 能力完成并有证据 |
| `failed` | 能力执行失败 |
| `blocked` | 前置能力失败导致无法执行 |
| `not_run` | 流程提前结束，能力未开始 |
| `skipped` | 按策略跳过，例如余额充足跳过储值 |

### 4.2 Stage Summary 归因规则

Stage summary 只汇总 capability ledger，不能反推能力结果。

规则：

- 如果 `miniapp.openOrderingPage` 已 passed，不能因为后续加菜失败而改成 failed。
- 如果 `miniapp.orderDishByAmount` failed，后续 `miniapp.submitOrder` 和 `miniapp.pay.existingBill` 标记为 `blocked` 或 `not_run`。
- Stage 的失败分类来自第一个 failed capability。
- Summary 必须输出 `failedCapabilityId`。

### 4.3 Surface Runtime Contract

每个 UI capability 必须声明：

```json
{
  "surface": "miniapp",
  "controller": "miniprogram-automator",
  "runtime": "wechat-devtools",
  "adapter": "miniapp.order"
}
```

POS 示例：

```json
{
  "surface": "pos",
  "controller": "playwright",
  "runtime": "pos-browser",
  "adapter": "pos.cashier"
}
```

目录校验规则：

- `kind=ui-action` 必须声明 `surface/controller/runtime/adapter`。
- `surface=miniapp` 只能使用小程序 runner 或小程序 capability 文件。
- `surface=pos` 只能使用 POS spec/helper。
- 一个 stage 内不能混合两个 UI controller。

### 4.4 单操作 10 秒约束

定义统一 UI 操作包装器：

```text
runUiActionWithGate(actionName, expectedPage, action)
  1. 记录 capabilityId/actionName
  2. 操作前检查当前页是否非空白
  3. 执行动作，硬超时 <= 10 秒
  4. 操作后检查当前页是否符合预期
  5. 捕获页面文本、截图、最近请求
  6. 输出 action evidence
```

约束：

- 单次 tap、元素查找、页面等待、请求等待都不能超过 10 秒。
- 完整流程可以有更长总超时，但不能掩盖单动作超时。
- 页面空白、页面跳转、旧元素销毁必须立即变成明确失败分类。

### 4.5 小程序请求证据链

现状依赖 `globalThis.__automationMiniappRequests`，页面销毁后可能丢证据。设计上增加 request ledger 抽象：

```json
{
  "requestId": "...",
  "at": "2026-06-29T07:00:05.000Z",
  "pagePath": "pagePop/orderfoods/index",
  "method": "POST",
  "url": "https://newshop.gzjjzhy.com/api/sorder/shopping_cart/addDish",
  "statusCode": 200,
  "success": true,
  "requestContext": {
    "sid": "...",
    "tblId": "...",
    "bizId": "yszx"
  },
  "responsePreview": "..."
}
```

短期方案：继续用现有注入变量，但在每个 capability 开始和结束时立即落盘快照，避免只在失败最后读一次。

中期方案：封装 miniapp request collector，页面切换后重新挂载并合并历史请求。

## 5. 第 1 用例重构设计

第 1 用例不直接重写完整流程，先重构失败的核心能力：`miniapp.orderDishByAmount`。

### 5.1 输入

```json
{
  "dishNamePattern": "江小白",
  "targetCount": 17,
  "expectedPage": "pagePop/orderfoods/index",
  "tableContext": {
    "sid": "1942885905090105345",
    "tblId": "1965656292984889345"
  }
}
```

### 5.2 输出

```json
{
  "capabilityId": "miniapp.orderDishByAmount",
  "status": "passed",
  "beforeQuantity": 1,
  "afterQuantity": 17,
  "evidenceMode": "addDish-request-and-cart-quantity",
  "addDishRequestCount": 1,
  "cartReady": true
}
```

### 5.3 失败分类

| 失败分类 | 含义 |
|---|---|
| `miniapp-page-blank` | 当前页空白 |
| `miniapp-page-lost` | 当前页不是预期页面 |
| `miniapp-element-not-found` | 找不到目标菜品或加菜按钮 |
| `miniapp-wrong-element-tapped` | 点击后页面/状态不符合业务预期 |
| `miniapp-request-not-observed` | 未观察到 addDish 请求，也无数量变化 |
| `miniapp-request-failed` | addDish 请求返回失败 |
| `miniapp-stale-element` | 页面销毁或元素句柄失效 |
| `miniapp-cart-not-ready` | 加菜后购物车仍无目标菜品 |

### 5.4 行为约束

- 只允许小程序 tap，不混用 POS 定位或 POS helper。
- 每次点击后立即检查页面和请求，不继续操作旧句柄。
- 如果页面跳回账单首页，立即记录 `miniapp-page-lost`，不继续点旧元素。
- 如果已有目标菜品数量，可优先通过购物车数量补齐，不做重复 UI 猜测。
- 不能靠延长等待解决失败。

## 6. 分阶段落地

### 阶段 1：平台内核最小闭环

范围：

- capability ledger 数据结构。
- mixed order summary 改为读取 capability ledger。
- failureClass 标准化。
- UI action 10 秒 gate。
- miniapp 页面健康检查和请求快照落盘。

验收：

- 第 1 用例失败时 summary 能准确显示 `failedCapabilityId=miniapp.orderDishByAmount`。
- `miniapp.submitOrder` 和 `miniapp.pay.existingBill` 未执行时不能标 failed。
- 每个 UI action 超时都有独立 evidence。

### 阶段 2：重构 miniapp.orderDishByAmount

范围：

- 从 `run-miniapp-order-pay-benefits.mjs` 中抽出可独立记录状态的加菜能力边界。
- 加菜前后记录页面、菜品数量、请求、购物车状态。
- 页面销毁/跳转后不继续使用旧句柄。

验收：

- 单独执行小程序加菜能力可稳定把目标菜品加到目标数量。
- 失败时能明确区分页面问题、元素问题、请求问题、购物车问题。

### 阶段 3：重跑第 1 用例

范围：

- 第 1 用例复用阶段 1 和阶段 2 的能力。
- 付款后用统一权益原子断言判断积分、赠券、返现。

验收：

- 小程序开台点餐成功。
- 小程序会员付款成功。
- 权益前后快照完整。
- 积分、赠券、返现分别给出变化证据。

## 7. 测试策略

### 单元/平台测试

- capability ledger 状态流转测试。
- Stage summary 归因测试。
- 未执行能力标记 `blocked/not_run` 测试。
- Surface runtime contract 校验测试。
- 小程序加菜失败分类测试。

### 真实数据测试

执行顺序：

1. 单独跑 `miniapp.orderDishByAmount`。
2. 跑第 1 用例。
3. 再回归第 2-5 用例。

真实数据测试必须输出 evidence 目录，不能只看控制台日志。

## 8. 风险与约束

1. 当前已有其他 AI/用户改动，实施时必须先看 `git status`，不能覆盖无关文件。
2. 小程序真实 UI 可能存在页面自动跳转，必须作为失败分类处理，而不是继续重试。
3. 短期 request ledger 仍依赖小程序注入，页面级证据只能通过快照降低丢失风险；完全跨页面 collector 是中期增强。
4. 现有大 runner 暂时保留，通过包装和能力边界逐步拆分。

## 9. 明确不做的事

本轮不做以下内容：

- 不直接重写全部小程序下单脚本。
- 不引入新的 UI 自动化依赖。
- 不把 API 造单当成小程序点菜的替代，除非 capability 明确声明为 API preflight 或 evidence 辅助。
- 不为了通过用例延长单操作等待时间。

## 10. 最终验收标准

平台内核验收：

- summary 可以准确定位第一个失败 capability。
- 未执行能力不会被错误标记 failed。
- 小程序和 POS UI capability 有明确 surface/runtime 边界。
- 每个 UI 操作失败都有 10 秒以内 evidence。

第 1 用例验收：

- 使用真实小程序 UI 完成开台点餐。
- 使用小程序会员付款完成支付。
- 付款前后权益快照来自统一权益原子断言。
- 积分、赠券、返现都有明确变化证据。